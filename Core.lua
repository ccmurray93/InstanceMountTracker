local addonName, vars = ...
InstanceMountFarmer = vars
local addon = vars
-- local data = vars.data
local addonAbbrev = "IMF"
vars.core = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local core = vars.core
vars.LDB = LibStub("LibDataBroker-1.1", true)
vars.icon = vars.LDB and LibStub("LibDBIcon-1.0", true)

local QTip = LibStub("LibQTip-1.0")

local DEBUG = true
local DEBUG_ALL_MOUNTS = true

local fontSize = {
    header = 16,
    section = 14,
    standard = 12,
}

local zones, mountSections
local dataobject, db
local tooltip, indicatortip
local dungeonHLine, raidHLine

local thisToon = {
    name = UnitName("player") .. " - " .. GetRealmName(),
    faction = UnitFactionGroup("player")
}

local INSTANCE_TYPE, INSTANCE_DIFFICULTY, INSTANCE_SIZE,
      EXPANSION, INSTANCE_DIFFICULTY_MAP, INSTANCE_MOUNTS

-- local (optimal) references to Blizzard's strings
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local FONTEND = FONT_COLOR_CODE_CLOSE
local GOLDFONT = NORMAL_FONT_COLOR_CODE
local YELLOWFONT = LIGHTYELLOW_FONT_COLOR_CODE
local REDFONT = RED_FONT_COLOR_CODE
local GREENFONT = GREEN_FONT_COLOR_CODE
local WHITEFONT = HIGHLIGHT_FONT_COLOR_CODE
local GRAYFONT = GRAY_FONT_COLOR_CODE

vars.defaultDB = {
    DBVersion = 1,
    Toons = {}, -- table key: "ToonName - Realm"; value:
        -- class: string
        -- level: integer
        -- faction: integer
        -- lastUpdated: integer
        -- instances key: "InstanceName"; value:
            -- key: "difficulty" (Normal, Heroic, Mythic); value:
                -- bosses key: "BossName"; value: boolean (Killed)
                -- resetsAt: integer
    MinimapIcon = {
        hide = false
    },
}

function core:OnInitialize()
    addon:Debug("OnInitialize")
    InstanceMountFarmerDB = InstanceMountFarmerDB or vars.defaultDB
    db = db or InstanceMountFarmerDB
    vars.db = db

    addon:toonInit()

    INSTANCE_TYPE = vars.data.INSTANCE_TYPE
    INSTANCE_DIFFICULTY = vars.data.INSTANCE_DIFFICULTY
    INSTANCE_SIZE = vars.data.INSTANCE_SIZE
    EXPANSION = vars.data.EXPANSION
    INSTANCE_DIFFICULTY_MAP = vars.data.INSTANCE_DIFFICULTY_MAP
    INSTANCE_MOUNTS = vars.data.INSTANCE_MOUNTS


    vars.dataobject = vars.LDB and vars.LDB:NewDataObject(addonName, {
        text = addonAbbrev,
        type = "launcher",
        icon = "Interface\\Icons\\INV_Chest_Cloth_17",
        -- OnEnter = function(frame)
        --       if not addon:IsDetached() and not db.Tooltip.DisableMouseover then
        --     core:ShowTooltip(frame)
        --           end
        -- end,
        OnEnter = function(frame) core:ShowTooltip(frame) end,
        OnLeave = function(frame) end,
        -- OnClick = function(frame, button)
        --     if button == "MiddleButton" then
        --         ToggleFriendsFrame(4) -- open Blizzard Raid window
        --         RaidInfoFrame:Show()
        --     elseif button == "LeftButton" then
        --        addon:ToggleDetached()
        --     else
        --         config:ShowConfig()
        --     end
        -- end
    })
    if vars.icon then
        vars.icon:Register(addonName, vars.dataobject, db.MinimapIcon)
        vars.icon:Refresh(addonName)
    end


    self:RequestLockInfo() -- get lockout data

    -- self:RegisterChatCommand("scaninstances", function()
    --     addon:ScanSavedInstances()
    -- end)
end

function core:OnEnable()
    addon:Debug("OnEnable")

    -- Register Events
    self:RegisterEvent("UPDATE_INSTANCE_INFO", function() addon:UpdateToonData() end)
    self:RegisterEvent("PLAYER_ENTERING_WORLD", function() addon:RefreshAll() end)
    -- self:RegisterEvent("PLAYER_LOGOUT", function() addon:UpdateToonData() end)

    self:RegisterEvent("ENCOUNTER_END", "RefreshLockInfo")
    self:RegisterEvent("LFG_COMPLETION_REWARD", "RefreshLockInfo")
    self:RegisterEvent("LFG_UPDATE_RANDOM_INFO", "RefreshLockInfo")
    self:RegisterEvent("LFG_LOCK_INFO_RECEIVED", "RefreshLockInfo")

    self:RegisterEvent("COMPANION_LEARNED", function() addon:RefreshAll() end)
    self:RegisterEvent("COMPANION_UNLEARNED", function() addon:RefreshAll() end)
    self:RegisterEvent("COMPANION_UPDATE", function() addon:RefreshAll() end)
end

function core:OnDisable()
    addon:Debug("OnDisable")

end

-- General Helper Functions
function addon:Debug(message)
    if DEBUG then
        core:Print(message)
    end
end

function addon:toonInit()
    local ti = db.Toons[thisToon.name] or {}
    db.Toons[thisToon.name] = ti
    ti.lClass, ti.class = UnitClass("player")
    ti.level = UnitLevel("player")
    ti.faction = thisToon.faction
end

function addon:InitCollectedMounts()
    local collectedFilterCur, notCollectedFilterCur = C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED), C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED)
    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED, true)
    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED, true)

    for i = 1, C_MountJournal.GetNumMounts() do
        local name, id, icon, _, summonable, source, _, _, faction, hidden, owned = C_MountJournal.GetMountInfo(i)
        local f = faction == 0 and "Horde" or "Alliance"
        if INSTANCE_MOUNTS[name] and (faction == nil or f == thisToon.faction) then
            -- IMCAddon:Debug(name)
            local c = owned
            if DEBUG_ALL_MOUNTS then c = false end
            INSTANCE_MOUNTS[name].collected = c
        end
    end

    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED, collectedFilterCur)
    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED, notCollectedFilterCur)
end

function addon:InitZoneTable()
    zones = {}
    for mountName,mount in pairs(INSTANCE_MOUNTS) do
        if mount.collected == false then
            local zn = mount.zone
            if not zones[zn] then
                zones[zn] = {
                    locked = false,
                    bosses = {}, -- string:"BossName" => bool:"Killed"
                    mounts = {}, -- integer => string:"MountName"
                }
            end
            table.insert(zones[zn].mounts, mountName)
        end
    end
end

function addon:ScanSavedInstances()
    local ti = {}
    for i = 1, GetNumSavedInstances() do
        local instanceName, _, instanceReset, instanceDifficulty, locked, _, _, _, _, difficultyName, maxBosses = GetSavedInstanceInfo(i)
        if locked and zones[instanceName] then -- Only care about instance if locked and need mount
            if not ti[instanceName] then ti[instanceName] = {} end
            local diff = INSTANCE_DIFFICULTY_MAP[instanceDifficulty]
            if diff == INSTANCE_DIFFICULTY.normal or diff == INSTANCE_DIFFICULTY.heroic or diff == INSTANCE_DIFFICULTY.mythic then
                ti[instanceName][diff] = {
                    bosses = {},
                    resetsAt = time() + instanceReset
                }
                -- addon:Debug(instanceReset)
                for bossIndex = 1, maxBosses do
                    local name, _, isKilled = GetSavedInstanceEncounterInfo(i, bossIndex)
                    ti[instanceName][diff].bosses[name] = isKilled
                end
            end
        end
    end
    vars.db.Toons[thisToon.name].instances = ti
end

function addon:RefreshAll()
    addon:RefreshMountStatus()
    core:RequestLockInfo()
end

function addon:RefreshMountStatus()
    addon:InitCollectedMounts()
    addon:InitZoneTable()
    addon:RefreshMountSections()
end

function addon:RefreshMountSections()
    addon:Debug("RefreshMountSections")
    mountSections = {
        [EXPANSION.classic] = {
            [INSTANCE_TYPE.dungeon] = {},
            [INSTANCE_TYPE.raid] = {},
        },
        [EXPANSION.bc] = {
            [INSTANCE_TYPE.dungeon] = {},
            [INSTANCE_TYPE.raid] = {},
        },
        [EXPANSION.wrath] = {
            [INSTANCE_TYPE.dungeon] = {},
            [INSTANCE_TYPE.raid] = {},
        },
        [EXPANSION.cata] = {
            [INSTANCE_TYPE.dungeon] = {},
            [INSTANCE_TYPE.raid] = {},
        },
        [EXPANSION.mop] = {
            [INSTANCE_TYPE.raid] = {},
            -- [INSTANCE_TYPE.world] = {},
        },
        -- [EXPANSION.wod] = {
        --     [INSTANCE_TYPE.world] = {},
        -- }
    }

    for mountName,mount in pairs(INSTANCE_MOUNTS) do
        if not mount.collected then
            if not mountSections[mount.expansion][mount.instanceType][mount.zone] then
                mountSections[mount.expansion][mount.instanceType][mount.zone] = {
                    mounts = {},
                    lineNum = nil
                }
            end
            table.insert(mountSections[mount.expansion][mount.instanceType][mount.zone].mounts, mountName)
        end
    end

    IMF_MS = mountSections
end

function addon:UpdateToonData()
    local t = db.Toons[thisToon.name]
    addon:ScanSavedInstances()
    t.lastUpdated = time()
end

function core:RequestLockInfo()
    RequestRaidInfo()
end

function core:RefreshLockInfo() -- throttled lock update with retry
    local now = GetTime()
    if now > (core.lastrefreshlock or 0) + 1 then
        core.lastrefreshlock = now
        core:RequestLockInfo()
    end
    if now > (core.lastrefreshlocksched or 0) + 120 then
        -- make sure we update any lockout info (sometimes there's server-side delay)
        core.lastrefreshlocksched = now
        core:ScheduleTimer("RequestLockInfo",5)
        core:ScheduleTimer("RequestLockInfo",30)
        core:ScheduleTimer("RequestLockInfo",60)
        core:ScheduleTimer("RequestLockInfo",90)
        core:ScheduleTimer("RequestLockInfo",120)
    end
end

function core:HeaderFont()
    if not addon.headerfont then
        local temp = QTip:Acquire(addonName.."HeaderTooltip", 1, "LEFT")
        addon.headerfont = CreateFont(addonName.."TooltipHeaderFont")
        local hFont = temp:GetHeaderFont()
        local hFontPath, hFontSize, _ = hFont:GetFont()
        addon.headerfont:SetFont(hFontPath, fontSize.section, "OUTLINE")
        QTip:Release(temp)
    end
    return addon.headerfont
end

-- function core:SectionTitleFont()
--     if not addon.sectionfont then
--         local temp = QTip:Acquire(addonName.."SectionTitleTooltip", 1, "LEFT")
--         addon.sectionfont = CreateFont(addonName.."TooltipSectionTitleFont")
--         local hFont = temp:GetHeaderFont()
--         local hFontPath, hFontSize, _ = hFont:GetFont()
--         addon.sectionfont:SetFont(hFontPath, fontSize.section, "MONOCHROME")
--         QTip:Release(temp)
--     end
--     return addon.sectionfont
-- end

function core:RowFont()
    if not addon.rowfont then
        local temp = QTip:Acquire(addonName.."RowTooltip", 1, "LEFT")
        addon.rowfont = CreateFont(addonName.."TooltipRowFont")
        local rFont = temp:GetFont()
        local rFontPath, rFontSize, rFontStyle  = rFont:GetFont()
        addon.rowfont:SetFont(rFontPath, fontSize.standard, rFontStyle)
        QTip:Release(temp)
    end
    return addon.rowfont
end

local function CountUniqueBosses(t)
    local count = 0
    local temp = {}
    for k,mountName in pairs(t.mounts) do
        local mount = INSTANCE_MOUNTS[mountName]
        local bosses = type(mount.dropsFrom) == "table" and mount.dropsFrom or {mount.dropsFrom}
        for i,j in pairs(bosses) do
            if not temp[j] then
                count = count + 1
                temp[j] = true
            end
        end
    end
    return count
end

local function ToonIsSaved(toonName, exp, zoneName, instanceDiff, bossName)
    -- addon:Debug("ToonIsSaved")
    -- addon:Debug(strjoin(" | ", toonName, exp, zoneName, instanceDiff, bossName))
    if db.Toons[toonName].instances[zoneName] ~= nil then
        local instance = nil
        if exp == EXPANSION.wod or zoneName == "Siege of Orgrimmar" then
            -- special check for change to instance locks
            -- Locks for each difficulty, must check for specific difficulty
            -- instanceDiff = mount.instanceDifficulty
            instance = db.Toons[toonName].instances[zoneName][instanceDiff]
        else
            -- Locked to any difficulty is locked to all
            instanceDiff, instance = next(db.Toons[toonName].instances[zoneName])
        end

        if instance ~= nil then
            if bossName == "" and mount.saveCheck then
                bossName = mount.saveCheck -- AQ check
            end
            if instance.bosses[bossName] then
                return true
            elseif bossName == "" and mount.saveCheck == nil then -- ZA check
                return true
            else
                return false
            end
        else
            return false
        end
    else
        return false
    end
end

local function ColorCodeOpen(color)
    return ColorCodeOpenRGB(color[1] or color.r,
        color[2] or color.g,
        color[3] or color.b,
        color[4] or color.a or 1)
end

local function ClassColorize(class, targetstring)
    local c = RAID_CLASS_COLORS[class]
    if c.colorStr then
        c = "|c"..c.colorStr
    else
        c = ColorCodeOpen(c)
    end
    return c .. targetstring .. FONTEND
end

local function openIndicator(...)
    indicatortip = QTip:Acquire(addonName.."IndicatorTip", ...)
    indicatortip:Clear()
    -- indicatortip:SetHeaderFont(core:HeaderFont())
    -- indicatortip:SetScale(vars.db.Tooltip.Scale)
end

local function finishIndicator(parent)
    parent = parent or tooltip
    indicatortip:SetAutoHideDelay(0.1, parent)
    indicatortip.OnRelease = function() indicatortip = nil end -- extra-safety: update our variable on auto-release
    indicatortip:SmartAnchorTo(parent)
    indicatortip:SetFrameLevel(100) -- ensure visibility when forced to overlap main tooltip
    -- addon:SkinFrame(indicatortip,"SavedInstancesIndicatorTooltip")
    indicatortip:Show()
end

local function CloseIndicator()
    if indicatortip then
        indicatortip:Hide()
    end
end

local function DoNothing()

end

local function InstanceOnEnter(cell, arg, ...)
    -- addon:Debug("ZoneTooltipOnEnter")
    local mountNames = arg.mounts
    local bossStatus = arg.bossStatus
    local zoneName = arg.zoneName
    local num = 0

    openIndicator(3, "LEFT", "CENTER", "RIGHT")

    local toonName = ""
    if not arg.line then
        zoneName = zoneName.." ("..bossStatus..")"
        toonName = ClassColorize(arg.toonClass, arg.toonName)
    end

    indicatortip:AddHeader(GOLDFONT..zoneName..FONTEND, "", toonName)

    if not arg.line and db.Toons[arg.toonName].instances[arg.zoneName] then
        local _, instance = next(db.Toons[arg.toonName].instances[arg.zoneName])
        local secondsToReset = instance.resetsAt - time()
        -- local days = math.floor(secondsToReset / (60*60*24))
        -- local r = secondsToReset - (days*60*60*24)
        -- local hours = math.floor(r / (60*60))
        -- r = r - (hours*60*60)
        -- local minutes = math.floor(r / 60)


        indicatortip:AddLine(YELLOWFONT.."Time Left:", "", SecondsToTime(secondsToReset))
    end
    -- if not arg.line then
    --     local tmpm = mounts[0]
    --     local z = tmpm.instanceType == INSTANCE_TYPE.world and INSTANCE_TYPE.world or tmpm.zone
    --     indicatortip:AddHeader(bossStatus, next(mounts).zone, UnitName("player"))
    --     -- indicatortip:AddSeparator(3, 1, 1, 1, 0)
    -- end
    for k,mountName in pairs(mountNames) do
        local mount = INSTANCE_MOUNTS[mountName]
        if not arg.line or num > 0 then
            indicatortip:AddSeparator(2, 1, 1, 1, 0)
        end
        num = num + 1

        indicatortip:AddHeader(YELLOWFONT..mountName..FONTEND)
        local bosses = type(mount.dropsFrom) == "table" and mount.dropsFrom or {mount.dropsFrom}
        for i,j in pairs(bosses) do
            local dropsFrom = j
            if mount.note then
                if dropsFrom == "" then
                    dropsFrom = mount.note
                    if mount.saveCheck then
                        dropsFrom = dropsFrom.." (Unavailable after"..mount.saveCheck..")"
                    else
                        dropsFrom = dropsFrom.." (Unavailable once saved)"
                    end
                else
                    dropsFrom = dropsFrom.." ("..mount.note..")"
                end
            end

            local mods = ""

            local tmp = {}
            if mount.instanceSize ~= INSTANCE_SIZE.all then
                table.insert(tmp, mount.instanceSize)
            end
            if mount.instanceDifficulty ~= INSTANCE_DIFFICULTY.all then
                table.insert(tmp, mount.instanceDifficulty)
            end

            if #tmp > 0 then
                mods = strjoin(", ", unpack(tmp))
            end

            -- local z = mount.instanceType == INSTANCE_TYPE.world and INSTANCE_TYPE.world or mount.zone
            local available = ""
            if not arg.line then
                local saved = ToonIsSaved(arg.toonName, mount.expansion, arg.zoneName, mount.instanceDifficulty, dropsFrom)
                available = saved and REDFONT.."Unavailable" or GREENFONT.."Available"
                available = available..FONTEND
                -- if j ~= "" then
                --     available = ZONES[z].killedBosses[dropsFrom] and "Unavailable" or "Available"
                -- elseif mount.saveCheck then
                --     available = ZONES[z].killedBosses[mount.saveCheck] and "Unavailable" or "Available"
                -- else
                --     available = ZONES[z].saved and "Unavailable" or "Available"
                -- end
            end
            indicatortip:AddLine(dropsFrom, mods, available)
        end
    end
    -- finishIndicator(cell)
    finishIndicator()
end

local function InstanceOnLeave()
    CloseIndicator()
end

local function AddInstanceRows(exp, itype)
    local alphaZoneList = {}
    local section = mountSections[exp][itype]
    for name,value in pairs(section) do
        alphaZoneList[#alphaZoneList+1] = name
    end
    table.sort(alphaZoneList)

    for k,zoneName in pairs(alphaZoneList) do
        -- local totalBosses = CountUniqueBosses(section[zoneName])
        -- local killedBosses = 0
        local hasLock = false
        for k,mountName in pairs(section[zoneName].mounts) do
            local mount = INSTANCE_MOUNTS[mountName]
            local bosses = type(mount.dropsFrom) == "table" and mount.dropsFrom or {mount.dropsFrom}
            if (mount.instanceDifficulty == INSTANCE_DIFFICULTY.heroic or mount.instanceDifficulty == INSTANCE_DIFFICULTY.mythic or
               mount.instanceType == INSTANCE_TYPE.raid or mount.instanceType == INSTANCE_TYPE.world) then
                hasLock = true
            end
            -- for i,bossName in pairs(bosses) do
            --     if zones[mount.zone].bosses[bossName] then
            --         killedBosses = killedBosses + 1
            --     end
            -- end
        end
        local name = zoneName
        -- local bossCount = killedBosses.."/"..totalBosses
        -- if not hasLock then
        --     bossCount = ""
        -- end
        local lineNum = tooltip:AddLine(name)
        section[zoneName].lineNum = lineNum
        -- local lineNum = tooltip:AddLine(YELLOWFONT..name..FONTEND)
        -- tooltip:EnableMouse(true)


        tooltip:SetLineScript(lineNum, "OnEnter", InstanceOnEnter, {
            line = true,
            zoneName = zoneName,
            mounts = section[zoneName].mounts,
        })
        tooltip:SetLineScript(lineNum, "OnLeave", InstanceOnLeave)

        -- if hasLock then
        --     tooltip:SetLineScript(lineNum, "OnEnter", DoNothing)
        --     -- tooltip:SetCellScript(lineNum, 2, "OnEnter", InstanceOnEnter, {
        --     --     line = false,
        --     --     mounts = section[zoneName],
        --     --     bossStatus = bossCount
        --     -- })
        --     -- tooltip:SetCellScript(lineNum, 2, "OnLeave", ZoneTooltipOnLeave)
        -- else
        --     tooltip:SetLineScript(lineNum, "OnEnter", InstanceOnEnter, {
        --         line = true,
        --         zoneName = zoneName,
        --         mounts = section[zoneName].mounts,
        --     })
        --     tooltip:SetLineScript(lineNum, "OnLeave", InstanceOnLeave)
        -- end


    end
end

local function FillToonColumn(toonName, toonClass, colNum, exp, itype)
    local alphaZoneList = {}
    local section = mountSections[exp][itype]
    for name,value in pairs(section) do
        alphaZoneList[#alphaZoneList+1] = name
    end
    table.sort(alphaZoneList)

    for k,zoneName in pairs(alphaZoneList) do
        local lineNum = section[zoneName].lineNum
        local totalBosses = CountUniqueBosses(section[zoneName])
        local killedBosses = 0

        local hasLock = false
        for k,mountName in pairs(section[zoneName].mounts) do
            local mount = INSTANCE_MOUNTS[mountName]
            local bosses = type(mount.dropsFrom) == "table" and mount.dropsFrom or {mount.dropsFrom}
            if (mount.instanceDifficulty == INSTANCE_DIFFICULTY.heroic or mount.instanceDifficulty == INSTANCE_DIFFICULTY.mythic or
               mount.instanceType == INSTANCE_TYPE.raid or mount.instanceType == INSTANCE_TYPE.world) then
                hasLock = true
                local instance, instanceDiff
                if db.Toons[toonName].instances[zoneName] ~= nil then
                    if exp == EXPANSION.wod or zoneName == "Siege of Orgrimmar" then
                        -- special check for change to instance locks
                        -- Locks for each difficulty, must check for specific difficulty
                        instanceDiff = mount.instanceDifficulty
                        instance = db.Toons[toonName].instances[zoneName][instanceDiff]
                    else
                        -- Locked to any difficulty is locked to all
                        instanceDiff, instance = next(db.Toons[toonName].instances[zoneName])
                    end

                    if instance ~= nil then
                        for i,bossName in pairs(bosses) do
                            if bossName == "" and mount.saveCheck then
                                bossName = mount.saveCheck -- AQ check
                            end
                            if instance.bosses[bossName] then
                                killedBosses = killedBosses + 1
                            end

                            if bossName == "" and mount.saveCheck == nil then -- ZA check
                                killedBosses = 1
                            end
                        end
                    end
                end
            end
        end

        local bossCount = killedBosses.."/"..totalBosses
        if not hasLock then
            bossCount = ""
        end

        tooltip:SetCell(lineNum, colNum, ClassColorize(toonClass, bossCount))
        if hasLock then
            tooltip:SetCellScript(lineNum, colNum, "OnEnter", InstanceOnEnter, {
                line = false,
                zoneName = zoneName,
                mounts = section[zoneName].mounts,
                bossStatus = bossCount,
                toonName = toonName,
                toonClass = toonClass
            })
            tooltip:SetCellScript(lineNum, colNum, "OnLeave", InstanceOnLeave)
        end
        lineNum = lineNum + 1
    end
end

local function UpdateTooltip(self,elap)
    addon.updatetooltip_throttle = (addon.updatetooltip_throttle or 10) + elap
    if addon.updatetooltip_throttle < 0.5 then return end
    addon.updatetooltip_throttle = 0
    if tooltip:IsShown() and tooltip.anchorframe then
       core:ShowTooltip(tooltip.anchorframe)
    end
end

function core:ShowTooltip(anchorframe)
    -- addon:Debug("ShowTooltip")
    if tooltip then QTip:Release(tooltip) end
    tooltip = QTip:Acquire(addonName.."Tooltip", 1, "LEFT")
    tooltip:SetCellMarginH(0)
    tooltip.anchorframe = anchorframe
    tooltip:SetScript("OnUpdate", UpdateTooltip)
    tooltip:Clear()

    tooltip:SetHeaderFont(core:HeaderFont())
    tooltip:SetFont(core:RowFont())

    local headLine = tooltip:AddHeader(GOLDFONT..addonName..FONTEND)

    -- tooltip:SetHeaderFont(core:SectionTitleFont())

    local classicDungeon = next(mountSections[EXPANSION.classic][INSTANCE_TYPE.dungeon]) ~= nil
    local bcDungeon = next(mountSections[EXPANSION.bc][INSTANCE_TYPE.dungeon]) ~= nil
    local wrathDungeon = next(mountSections[EXPANSION.wrath][INSTANCE_TYPE.dungeon]) ~= nil
    local cataDungeon = next(mountSections[EXPANSION.cata][INSTANCE_TYPE.dungeon]) ~= nil


    if classicDungeon or bcDungeon or wrathDungeon or cataDungeon then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        dungeonHLine = tooltip:AddHeader(GOLDFONT.."Dungeons"..FONTEND)
    end

    if classicDungeon then
        -- tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(YELLOWFONT..EXPANSION.classic..FONTEND)
        AddInstanceRows(EXPANSION.classic, INSTANCE_TYPE.dungeon)
    end
    if bcDungeon then
        if classicDungeon then tooltip:AddSeparator(2, 0, 0, 0, 0) end
        tooltip:AddHeader(YELLOWFONT..EXPANSION.bc..FONTEND)
        AddInstanceRows(EXPANSION.bc, INSTANCE_TYPE.dungeon)
    end
    if wrathDungeon then
        if classicDungeon or bcDungeon then tooltip:AddSeparator(2, 0, 0, 0, 0) end
        tooltip:AddHeader(YELLOWFONT..EXPANSION.wrath..FONTEND)
        AddInstanceRows(EXPANSION.wrath, INSTANCE_TYPE.dungeon)
    end
    if cataDungeon then
        if classicDungeon or bcDungeon or wrathDungeon then tooltip:AddSeparator(2, 0, 0, 0, 0) end
        tooltip:AddHeader(YELLOWFONT..EXPANSION.cata..FONTEND)
        AddInstanceRows(EXPANSION.cata, INSTANCE_TYPE.dungeon)
    end


    local classicRaid = next(mountSections[EXPANSION.classic][INSTANCE_TYPE.raid]) ~= nil
    local bcRaid = next(mountSections[EXPANSION.bc][INSTANCE_TYPE.raid]) ~= nil
    local wrathRaid = next(mountSections[EXPANSION.wrath][INSTANCE_TYPE.raid]) ~= nil
    local cataRaid = next(mountSections[EXPANSION.cata][INSTANCE_TYPE.raid]) ~= nil
    local mopRaid = next(mountSections[EXPANSION.mop][INSTANCE_TYPE.raid]) ~= nil
    -- local mopWorld = next(mountSections[EXPANSION.mop][INSTANCE_TYPE.world]) ~= nil
    -- local wodWorld = next(mountSections[EXPANSION.wod][INSTANCE_TYPE.world]) ~= nil

    if classicRaid or bcRaid or wrathRaid or cataRaid or mopRaid then
        tooltip:AddSeparator(15, 1, 1, 1, 0)
        raidHLine = tooltip:AddHeader(GOLDFONT.."Raids"..FONTEND)
    end

    if classicRaid then
        -- tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(YELLOWFONT..EXPANSION.classic..FONTEND)
        AddInstanceRows(EXPANSION.classic, INSTANCE_TYPE.raid)
    end
    if bcRaid then
        if classicRaid then tooltip:AddSeparator(2, 0, 0, 0, 0) end
        tooltip:AddHeader(YELLOWFONT..EXPANSION.bc..FONTEND)
        AddInstanceRows(EXPANSION.bc, INSTANCE_TYPE.raid)
    end
    if wrathRaid then
        if classicRaid or bcRaid then tooltip:AddSeparator(2, 0, 0, 0, 0) end
        tooltip:AddHeader(YELLOWFONT..EXPANSION.wrath..FONTEND)
        AddInstanceRows(EXPANSION.wrath, INSTANCE_TYPE.raid)
    end
    if cataRaid then
        if classicRaid or bcRaid or wrathRaid then tooltip:AddSeparator(2, 0, 0, 0, 0) end
        tooltip:AddHeader(YELLOWFONT..EXPANSION.cata..FONTEND)
        AddInstanceRows(EXPANSION.cata, INSTANCE_TYPE.raid)
    end
    if mopRaid then
        if classicRaid or bcRaid or wrathRaid or cataRaid then tooltip:AddSeparator(2, 0, 0, 0, 0) end
        tooltip:AddHeader(YELLOWFONT..EXPANSION.mop..FONTEND)
        AddInstanceRows(EXPANSION.mop, INSTANCE_TYPE.raid)
    end

    -- if mopWorld or wodWorld then
    --     tooltip:AddSeparator(15, 1, 1, 1, 0)
    --     tooltip:AddHeader("World", UnitName("player"))
    -- end

    -- if mopWorld then
    --     tooltip:AddSeparator(2, 0, 0, 0, 0)
    --     tooltip:AddHeader(YELLOWFONT..EXPANSION.mop..FONTEND)
    --     AddInstanceRows(EXPANSION.mop, INSTANCE_TYPE.world)
    -- end
    -- if wodWorld then
    --     tooltip:AddSeparator(2, 0, 0, 0, 0)
    --     tooltip:AddHeader(YELLOWFONT..EXPANSION.wod..FONTEND)
    --     AddInstanceRows(EXPANSION.wod, INSTANCE_TYPE.world)
    -- end


    -- Add Toon Columns
    local toons = db.Toons

    local alphaToonList = {}
    for name,value in pairs(toons) do
        alphaToonList[#alphaToonList+1] = name
    end
    table.sort(alphaToonList, function(a,b)
        if a == thisToon.name then
            return true
        elseif b == thisToon.name then
            return false
        else
            return a < b
        end
    end)


    local toonNum = 1
    for k,toonFullName in pairs(alphaToonList) do
        toonNum = toonNum + 1
        local toonName = strsplit(" - ", toonFullName)
        tooltip:AddColumn("CENTER")
        if classicDungeon or bcDungeon or wrathDungeon or cataDungeon then
            tooltip:SetCell(dungeonHLine, toonNum, ClassColorize(db.Toons[toonFullName].class, toonName))
        end

        if classicDungeon then
            FillToonColumn(toonFullName, db.Toons[toonFullName].class, toonNum, EXPANSION.classic, INSTANCE_TYPE.dungeon)
        end
        if bcDungeon then
            FillToonColumn(toonFullName, db.Toons[toonFullName].class, toonNum, EXPANSION.bc, INSTANCE_TYPE.dungeon)
        end
        if wrathDungeon then
            FillToonColumn(toonFullName, db.Toons[toonFullName].class, toonNum, EXPANSION.wrath, INSTANCE_TYPE.dungeon)
        end
        if cataDungeon then
            FillToonColumn(toonFullName, db.Toons[toonFullName].class, toonNum, EXPANSION.cata, INSTANCE_TYPE.dungeon)
        end


        if classicRaid or bcRaid or wrathRaid or cataRaid or mopRaid then
            tooltip:SetCell(raidHLine, toonNum, ClassColorize(db.Toons[toonFullName].class, toonName))
        end

        if classicRaid then
            FillToonColumn(toonFullName, db.Toons[toonFullName].class, toonNum, EXPANSION.classic, INSTANCE_TYPE.raid)
        end
        if bcRaid then
            FillToonColumn(toonFullName, db.Toons[toonFullName].class, toonNum, EXPANSION.bc, INSTANCE_TYPE.raid)
        end
        if wrathRaid then
            FillToonColumn(toonFullName, db.Toons[toonFullName].class, toonNum, EXPANSION.wrath, INSTANCE_TYPE.raid)
        end
        if cataRaid then
            FillToonColumn(toonFullName, db.Toons[toonFullName].class, toonNum, EXPANSION.cata, INSTANCE_TYPE.raid)
        end
        if mopRaid then
            FillToonColumn(toonFullName, db.Toons[toonFullName].class, toonNum, EXPANSION.mop, INSTANCE_TYPE.raid)
        end
    end



    tooltip:SmartAnchorTo(anchorframe)
    tooltip:SetAutoHideDelay(0.1, anchorframe)
    tooltip.OnRelease = function() tooltip = nil end

    tooltip:Show()
end