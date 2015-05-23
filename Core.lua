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
local DEBUG_ALL_MOUNTS = false

local fontSize = {
    header = 16,
    section = 14,
    standard = 12,
}

local zones, mountSections
local dataobject, db
local tooltip, indicatortip
local keepToons = {}

local tooltipCache = {}

local thisToon = {
    name = UnitName("player") .. " - " .. GetRealmName(),
    faction = UnitFactionGroup("player"),
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
    DBVersion = 2,
    Toons = {}, -- table key: "ToonName - Realm"; value:
        -- class: string
        -- level: integer
        -- faction: integer
        -- lastUpdated: integer
        -- instances key: "InstanceName"; value:
            -- key: "difficulty" (Normal, Heroic, Mythic); value:
                -- bosses key: "BossName"; value: boolean (Killed)
                -- resetsAt: integer
        -- worldBosses key: "DropsFrom"; value: boolean (Killed)
        -- weeklyResetsAt: integer
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
        icon = "Interface\\Icons\\Ability_Mount_BigBlizzardBear",
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
    ti.instances = ti.instances or {}
    ti.worldBosses = ti.worldBosses or {}
    ti.lClass, ti.class = UnitClass("player")
    ti.level = UnitLevel("player")
    ti.faction = thisToon.faction
    if ti.weeklyResetsAt == nil or ti.weeklyResetsAt < time() then
        ti.weeklyResetsAt = addon:GetNextWeeklyResetTime()
    end
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
    tooltipCache = nil
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

function addon:ScanWorldBosses()
    tooltipCache = nil
    for _,exp in pairs({EXPANSION.mop, EXPANSION.wod}) do
        local mountZones = mountSections[exp][INSTANCE_TYPE.world]
        for _,zone in pairs(mountZones) do
            for _,mountName in pairs(zone.mounts) do
                local questID = INSTANCE_MOUNTS[mountName].questID
                local dropsFrom = INSTANCE_MOUNTS[mountName].dropsFrom
                local questCompleted = IsQuestFlaggedCompleted(questID)
                -- addon:Debug(strjoin(" | ", mountName, questID, dropsFrom, questCompleted and "Dead" or "Not Dead"))
                db.Toons[thisToon.name].worldBosses[dropsFrom] = questCompleted
            end
        end
    end
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
    tooltipCache = nil
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
            [INSTANCE_TYPE.world] = {},
        },
        [EXPANSION.wod] = {
            [INSTANCE_TYPE.world] = {},
        }
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
    -- IMF_MS = mountSections
end

function addon:UpdateToonData()
    local t = db.Toons[thisToon.name]
    if t.weeklyResetsAt == nil or t.weeklyResetsAt < time() then
        t.weeklyResetsAt = addon:GetNextWeeklyResetTime()
    end
    addon:ScanSavedInstances()
    addon:ScanWorldBosses()
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

-- returns how many hours the server time is ahead of local time
-- convert local time -> server time: add this value
-- convert server time -> local time: subtract this value
function addon:GetServerOffset()
    local serverDay = CalendarGetDate() - 1 -- 1-based starts on Sun
    local localDay = tonumber(date("%w")) -- 0-based starts on Sun
    local serverHour, serverMinute = GetGameTime()
    local localHour, localMinute = tonumber(date("%H")), tonumber(date("%M"))
    if serverDay == (localDay + 1)%7 then -- server is a day ahead
        serverHour = serverHour + 24
    elseif localDay == (serverDay + 1)%7 then -- local is a day ahead
        localHour = localHour + 24
    end
    local server = serverHour + serverMinute / 60
    local localT = localHour + localMinute / 60
    local offset = floor((server - localT) * 2 + 0.5) / 2
    return offset
end

function addon:GetRegion()
    if not addon.region then
        local reg
        reg = GetCVar("portal")
        if reg == "public-test" then -- PTR uses US region resets, despite the misleading realm name suffix
            reg = "US"
        end
        if not reg or #reg ~= 2 then
            reg = (GetCVar("realmList") or ""):match("^(%a+)%.")
        end
        if not reg or #reg ~= 2 then -- other test realms?
            reg = (GetRealmName() or ""):match("%((%a%a)%)")
        end
        reg = reg and reg:upper()
        if reg and #reg == 2 then
            addon.region = reg
        end
    end
    return addon.region
end

function addon:GetNextDailyResetTime()
    local resettime = GetQuestResetTime()
    if not resettime or resettime <= 0 or -- ticket 43: can fail during startup
        -- also right after a daylight savings rollover, when it returns negative values >.<
        resettime > 24*3600+30 then -- can also be wrong near reset in an instance
        return nil
    end
    return time() + resettime
end

function addon:GetNextWeeklyResetTime()
    if not addon.resetDays then
        local region = addon:GetRegion()
        if not region then return nil end
        addon.resetDays = {}
        if region == "US" then
            addon.resetDays["2"] = true -- tuesday
        elseif region == "EU" then
            addon.resetDays["3"] = true -- wednesday
        elseif region == "CN" or region == "KR" or region == "TW" then -- XXX: codes unconfirmed
            addon.resetDays["4"] = true -- thursday
        else
            addon.resetDays["2"] = true -- tuesday?
        end
    end
    local offset = addon:GetServerOffset() * 3600
    local nightlyReset = addon:GetNextDailyResetTime()
    if not nightlyReset then return nil end
    --while date("%A",nightlyReset+offset) ~= WEEKDAY_TUESDAY do
    while not addon.resetDays[date("%w",nightlyReset+offset)] do
        nightlyReset = nightlyReset + 24 * 3600
    end
    return nightlyReset
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
            if instance.resetsAt < time() then -- instance lock is old, remove
                db.Toons[toonName].instances[zoneName] = nil
                return false
            else
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
            end
        else
            return false
        end
    elseif db.Toons[toonName].worldBosses and db.Toons[toonName].worldBosses[bossName] then
        local weeklyResetsAt = db.Toons[toonName].weeklyResetsAt and db.Toons[toonName].weeklyResetsAt or 0
        if weeklyResetsAt < time() then
            db.Toons[toonName].worldBosses = {}
            return false
        else
            return true
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
    indicatortip:Show()
end

local function CloseIndicator()
    if indicatortip then
        indicatortip:Hide()
    end
end

local function GenerateAlphaToonList()
    if not addon.alphatoonlist then
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
        addon.alphatoonlist = alphaToonList
    end
    return addon.alphatoonlist
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

    if not arg.line then
        local secondsToReset = nil
        if db.Toons[arg.toonName].instances[arg.zoneName] then
            local _, instance = next(db.Toons[arg.toonName].instances[arg.zoneName])
            secondsToReset = instance.resetsAt - time()
        elseif arg.itype == INSTANCE_TYPE.world and db.Toons[arg.toonName].weeklyResetsAt then
            -- addon:Debug()
            secondsToReset = db.Toons[arg.toonName].weeklyResetsAt - time()
        end
        if secondsToReset then
            indicatortip:AddLine(YELLOWFONT.."Resets in:", "", SecondsToTime(secondsToReset))
        end
    end

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
                        dropsFrom = dropsFrom.." (Unavailable after "..mount.saveCheck..")"
                    else
                        dropsFrom = dropsFrom.." (Unavailable once locked)"
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

            local available = ""
            if not arg.line then
                local saved = ToonIsSaved(arg.toonName, mount.expansion, arg.zoneName, mount.instanceDifficulty, mount.dropsFrom)
                available = saved and REDFONT.."Unavailable" or GREENFONT.."Available"
                available = available..FONTEND
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

local function GenerateAlphaZoneList(exp, itype)
    local alphaZoneList = {}
    local section = mountSections[exp][itype]
    for name,value in pairs(section) do
        alphaZoneList[#alphaZoneList+1] = name
    end
    table.sort(alphaZoneList, function(a,b)
        if itype == INSTANCE_TYPE.world then
            local _,ma = next(section[a].mounts)
            ma = INSTANCE_MOUNTS[ma].dropsFrom
            local _,mb = next(section[b].mounts)
            mb = INSTANCE_MOUNTS[mb].dropsFrom
            return ma < mb
        else
            return a < b
        end
    end)
    return alphaZoneList
end

local function AddInstanceRows(exp, itype)
    local section = mountSections[exp][itype]
    local alphaZoneList = GenerateAlphaZoneList(exp, itype)

    for k,zoneName in pairs(alphaZoneList) do
        local hasLock = false
        local worldBossName = nil
        for k,mountName in pairs(section[zoneName].mounts) do
            local mount = INSTANCE_MOUNTS[mountName]
            local bosses = type(mount.dropsFrom) == "table" and mount.dropsFrom or {mount.dropsFrom}
            if (mount.instanceDifficulty == INSTANCE_DIFFICULTY.heroic or mount.instanceDifficulty == INSTANCE_DIFFICULTY.mythic or
               mount.instanceType == INSTANCE_TYPE.raid or mount.instanceType == INSTANCE_TYPE.world) then
                hasLock = true
            end
            if mount.instanceType == INSTANCE_TYPE.world then
                worldBossName = mount.dropsFrom
            end
        end

        tooltipCache[itype][exp][k] = {
            zoneName = zoneName,
            hasLock = hasLock,
            worldBossName = worldBossName,
            lineScript = {
                line = true,
                zoneName = zoneName,
                mounts = section[zoneName].mounts,
            },
            toons = {}
        }
    end
end

local function FillToonColumn(toonName, toonClass, colNum, exp, itype)
    local section = mountSections[exp][itype]
    local alphaZoneList = GenerateAlphaZoneList(exp, itype)

    for k,zoneName in pairs(alphaZoneList) do
        local totalBosses = CountUniqueBosses(section[zoneName])
        local killedBosses = 0

        local hasLock = false
        for _,mountName in pairs(section[zoneName].mounts) do
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
                        if instance.resetsAt < time() then -- instance lock is old, remove
                            db.Toons[toonName].instances[zoneName] = nil
                        else
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
                elseif db.Toons[toonName].worldBosses and db.Toons[toonName].worldBosses[mount.dropsFrom] then
                    killedBosses = 1
                end
            end
        end

        local bossCount = killedBosses.."/"..totalBosses
        if not hasLock then
            bossCount = ""
        end

        local done = (killedBosses == totalBosses)
        if toonName ~= thisToon.name and not hasLock then
            done = true
        end

        table.insert(tooltipCache[itype][exp][k].toons, {
            value = ClassColorize(toonClass, bossCount),
            done = done,
            -- hasLock = hasLock,
            cellScript = {
                line = false,
                zoneName = zoneName,
                mounts = section[zoneName].mounts,
                itype = itype,
                bossStatus = bossCount,
                toonName = toonName,
                toonClass = toonClass
            }
        })
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

local function RemoveCompletedFromCache()
    keepToons = {}

    local itypes = {INSTANCE_TYPE.dungeon, INSTANCE_TYPE.raid}

    local toonCount = nil
    for _,itype in pairs(itypes) do
        local keepInstanceType = false
        if tooltipCache[itype] then
            for exp,instances in pairs(tooltipCache[itype]) do
                local keepExp = false
                for k,v in pairs(instances) do
                    local keep = false
                    toonCount = toonCount and toonCount or #v.toons
                    for t,toon in pairs(v.toons) do
                        -- addon:Debug(strjoin(" | ", toon.cellScript.toonName, v.zoneName, toon.value, toon.done and "Done" or "Not Done"))
                        if not toon.done then
                            keepToons[t] = true
                            keep = true
                            -- break
                        end
                    end
                    if not keep then
                        tooltipCache[itype][exp][k] = nil
                    else
                        keepExp = true
                    end
                end
                if not keepExp then
                    tooltipCache[itype][exp] = nil
                else
                    keepInstanceType = true
                end
            end

            if not keepInstanceType then
                tooltipCache[itype] = nil
            end
        end
    end

    toonCount = toonCount and toonCount or 0
    for t = 1, toonCount do
        local keep = keepToons[t]
        if not keep then
            for _,itype in pairs(itypes) do
                if tooltipCache[itype] then
                    for exp,instances in pairs(tooltipCache[itype]) do
                        for k,v in pairs(instances) do
                            v.toons[t] = nil
                        end
                    end
                end
            end
        end
    end
end

local function DisplayTooltipFromCache()
    tooltip:AddHeader(tooltipCache.header)

    RemoveCompletedFromCache()

    for _,_ in pairs(db.Toons) do tooltip:AddColumn("CENTER") end

    local count = 0
    local toonNum = 0
    local lineNum

    local hasDungeons = tooltipCache[INSTANCE_TYPE.dungeon]
    local hasRaids = tooltipCache[INSTANCE_TYPE.raid]

    local toonList = {}
    for k,toonFullName in pairs(GenerateAlphaToonList()) do
        if keepToons[k] then
            local toonName = strsplit(" - ", toonFullName)
            table.insert(toonList, ClassColorize(db.Toons[toonFullName].class, toonName))
        end
    end

    local first = true

    for _,itype in pairs({INSTANCE_TYPE.dungeon, INSTANCE_TYPE.raid, INSTANCE_TYPE.world}) do
        if tooltipCache[itype] then
            if not first then tooltip:AddSeparator(8, 0, 0, 0, 0) end
            first = false
            tooltip:AddSeparator(2, 0, 0, 0, 0)
            tooltip:AddHeader(GOLDFONT..itype..FONTEND, unpack(toonList))
            for _,exp in pairs({EXPANSION.classic, EXPANSION.bc, EXPANSION.wrath, EXPANSION.cata, EXPANSION.mop, EXPANSION.wod}) do
                local instances = tooltipCache[itype][exp]
                if instances then
                    if count > 0 then tooltip:AddSeparator(2, 0, 0, 0, 0) end
                    tooltip:AddHeader(YELLOWFONT..exp..FONTEND)
                    local hi = true
                    for k,v in pairs(instances) do
                        local name = v.worldBossName and v.worldBossName or v.zoneName
                        lineNum = tooltip:AddLine(name)
                        tooltip:SetLineScript(lineNum, "OnEnter", InstanceOnEnter, v.lineScript)
                        tooltip:SetLineScript(lineNum, "OnLeave", InstanceOnLeave)

                        if hi then
                            tooltip:SetLineColor(lineNum, 1,1,1, 0.1)
                            hi = false
                        else
                            tooltip:SetLineColor(lineNum, 1,1,1, 0)
                            hi = true
                        end

                        toonNum = 0
                        for _,toon in pairs(v.toons) do
                            toonNum = toonNum + 1
                            local text = toon.value
                            if toon.done and toon.cellScript.bossStatus ~= "" then
                                text = "|TInterface\\RAIDFRAME\\ReadyCheck-Ready:16|t"
                            end
                            tooltip:SetCell(lineNum, toonNum+1, text)
                            if v.hasLock then
                                tooltip:SetCellScript(lineNum, toonNum+1, "OnEnter", InstanceOnEnter, toon.cellScript)
                                tooltip:SetCellScript(lineNum, toonNum+1, "OnLeave", InstanceOnLeave)
                            end
                        end
                    end
                    count = count + 1
                end
            end
        end
    end

    if first then -- no mounts needed
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddLine("Looks like you've finished farming all available instances!")
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

    if not tooltipCache then
        tooltipCache = {}
        tooltipCache.header = GOLDFONT..addonName..FONTEND

        local classicDungeon = next(mountSections[EXPANSION.classic][INSTANCE_TYPE.dungeon]) ~= nil
        local bcDungeon = next(mountSections[EXPANSION.bc][INSTANCE_TYPE.dungeon]) ~= nil
        local wrathDungeon = next(mountSections[EXPANSION.wrath][INSTANCE_TYPE.dungeon]) ~= nil
        local cataDungeon = next(mountSections[EXPANSION.cata][INSTANCE_TYPE.dungeon]) ~= nil


        if classicDungeon or bcDungeon or wrathDungeon or cataDungeon then
            tooltipCache[INSTANCE_TYPE.dungeon] = {}
        end

        if classicDungeon then
            tooltipCache[INSTANCE_TYPE.dungeon][EXPANSION.classic] = {}
            AddInstanceRows(EXPANSION.classic, INSTANCE_TYPE.dungeon)
        end
        if bcDungeon then
            tooltipCache[INSTANCE_TYPE.dungeon][EXPANSION.bc] = {}
            AddInstanceRows(EXPANSION.bc, INSTANCE_TYPE.dungeon)
        end
        if wrathDungeon then
            tooltipCache[INSTANCE_TYPE.dungeon][EXPANSION.wrath] = {}
            AddInstanceRows(EXPANSION.wrath, INSTANCE_TYPE.dungeon)
        end
        if cataDungeon then
            tooltipCache[INSTANCE_TYPE.dungeon][EXPANSION.cata] = {}
            AddInstanceRows(EXPANSION.cata, INSTANCE_TYPE.dungeon)
        end


        local classicRaid = next(mountSections[EXPANSION.classic][INSTANCE_TYPE.raid]) ~= nil
        local bcRaid = next(mountSections[EXPANSION.bc][INSTANCE_TYPE.raid]) ~= nil
        local wrathRaid = next(mountSections[EXPANSION.wrath][INSTANCE_TYPE.raid]) ~= nil
        local cataRaid = next(mountSections[EXPANSION.cata][INSTANCE_TYPE.raid]) ~= nil
        local mopRaid = next(mountSections[EXPANSION.mop][INSTANCE_TYPE.raid]) ~= nil
        local mopWorld = next(mountSections[EXPANSION.mop][INSTANCE_TYPE.world]) ~= nil
        local wodWorld = next(mountSections[EXPANSION.wod][INSTANCE_TYPE.world]) ~= nil

        if classicRaid or bcRaid or wrathRaid or cataRaid or mopRaid then
            tooltipCache[INSTANCE_TYPE.raid] = {}
        end

        if classicRaid then
            tooltipCache[INSTANCE_TYPE.raid][EXPANSION.classic] = {}
            AddInstanceRows(EXPANSION.classic, INSTANCE_TYPE.raid)
        end
        if bcRaid then
            tooltipCache[INSTANCE_TYPE.raid][EXPANSION.bc] = {}
            AddInstanceRows(EXPANSION.bc, INSTANCE_TYPE.raid)
        end
        if wrathRaid then
            tooltipCache[INSTANCE_TYPE.raid][EXPANSION.wrath] = {}
            AddInstanceRows(EXPANSION.wrath, INSTANCE_TYPE.raid)
        end
        if cataRaid then
            tooltipCache[INSTANCE_TYPE.raid][EXPANSION.cata] = {}
            AddInstanceRows(EXPANSION.cata, INSTANCE_TYPE.raid)
        end
        if mopRaid then
            tooltipCache[INSTANCE_TYPE.raid][EXPANSION.mop] = {}
            AddInstanceRows(EXPANSION.mop, INSTANCE_TYPE.raid)
        end

        if mopWorld or wodWorld then
            tooltipCache[INSTANCE_TYPE.world] = {}
        end

        if mopWorld then
            tooltipCache[INSTANCE_TYPE.world][EXPANSION.mop] = {}
            AddInstanceRows(EXPANSION.mop, INSTANCE_TYPE.world)
        end
        if wodWorld then
            tooltipCache[INSTANCE_TYPE.world][EXPANSION.wod] = {}
            AddInstanceRows(EXPANSION.wod, INSTANCE_TYPE.world)
        end


        -- Add Toon Columns
        local alphaToonList = GenerateAlphaToonList()

        for k,toonFullName in pairs(alphaToonList) do
            local toonName = strsplit(" - ", toonFullName)

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
            if mopWorld then
                FillToonColumn(toonFullName, db.Toons[toonFullName].class, toonNum, EXPANSION.mop, INSTANCE_TYPE.world)
            end
            if wodWorld then
                FillToonColumn(toonFullName, db.Toons[toonFullName].class, toonNum, EXPANSION.wod, INSTANCE_TYPE.world)
            end
        end
    end

    DisplayTooltipFromCache()

    tooltip:SmartAnchorTo(anchorframe)
    tooltip:SetAutoHideDelay(0.1, anchorframe)
    tooltip.OnRelease = function() tooltip = nil end

    tooltip:Show()
end