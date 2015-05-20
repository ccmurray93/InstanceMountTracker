local addonShortName = "InstanceMountCollector"
local addonAbbr = "IMC"

IMCAddon = LibStub("AceAddon-3.0"):NewAddon(addonShortName, "AceConsole-3.0", "AceEvent-3.0")

local LibQTip = LibStub('LibQTip-1.0')

-- local LDB = LibStub("LibDataBroker-1.1"):NewDataObject(addonShortName, {
--     type = "launcher",
--     -- text = addonShortName,
--     icon = "Interface\\Icons\\INV_Chest_Cloth_17",
--     OnEnter = function(frame) IMCAddon:IconOnEnter(frame) end,
--     OnLeave = function(frame) IMCAddon:IconOnLeave(frame) end
-- })
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LDB and LibStub("LibDBIcon-1.0")


local DEBUG = true
local DEBUG_ALL_MOUNTS = true

local tooltip, indicatortip

local FACTION = {
    [0] = "Horde",
    [1] = "Alliance"
}

local MOUNT_SOURCE = {
    drop = 1
}

local INSTANCE_TYPE = {
    raid = "Raid",
    dungeon = "Dungeon",
    world = "World"
}

local INSTANCE_DIFFICULTY = {
    all = "All",
    normal = "Normal",
    heroic = "Heroic",
    mythic = "Mythic"
}

local INSTANCE_SIZE = {
    all = "All",
    ten = "10m",
    twentyFive = "25m"
}

local EXPANSION = {
    classic = "Classic",
    bc = "Burning Crusade",
    wrath = "Wrath of the Lich King",
    cata = "Cataclysm",
    mop = "Mists of Pandaria",
    wod = "Warlords of Draenor",
}

local INSTANCE_MOUNTS = {
    -- Vanilla
    ["Rivendare's Deathcharger"] = {
        zone =               "Stratholme",
        dropsFrom =          "Lord Aurius Rivendare",
        instanceType =       INSTANCE_TYPE.dungeon,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.classic
    },

    ["Blue Qiraji Battle Tank"] = {
        zone =               "Temple of Ahn'Qiraj",
        dropsFrom =          "",
        note =               "Trash",
        saveCheck =          "C'Thun",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.classic
    },

    ["Green Qiraji Battle Tank"] = {
        zone =               "Temple of Ahn'Qiraj",
        dropsFrom =          "",
        note =               "Trash",
        saveCheck =          "C'Thun",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.classic
    },

    ["Yellow Qiraji Battle Tank"] = {
        zone =               "Temple of Ahn'Qiraj",
        dropsFrom =          "",
        note =               "Trash",
        saveCheck =          "C'Thun",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.classic
    },

    ["Red Qiraji Battle Tank"] = {
        zone =               "Temple of Ahn'Qiraj",
        dropsFrom =          "",
        note =               "Trash",
        saveCheck =          "C'Thun",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.classic
    },


    -- Burning Crusade
    ["Raven Lord"] = {
        zone =               "Sethekk Halls",
        dropsFrom =          "Anzu",
        instanceType =       INSTANCE_TYPE.dungeon,
        instanceDifficulty = INSTANCE_DIFFICULTY.heroic,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.bc
    },

    ["Swift White Hawkstrider"] = {
        zone =               "Magisters' Terrace",
        dropsFrom =          "Kael'thas Sunstrider",
        instanceType =       INSTANCE_TYPE.dungeon,
        instanceDifficulty = INSTANCE_DIFFICULTY.heroic,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.bc
    },

    ["Fiery Warhorse"] = {
        zone =               "Karazhan",
        dropsFrom =          "Attumen the Huntsman",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.bc
    },

    ["Ashes of Al'ar"] = {
        zone =               "Tempest Keep",
        dropsFrom =          "Kael'thas Sunstrider",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.bc
    },


    -- Wrath of the Lich King
    ["Blue Proto-Drake"] = {
        zone =               "Utgarde Pinnacle",
        dropsFrom =          "Skadi the Ruthless",
        instanceType =       INSTANCE_TYPE.dungeon,
        instanceDifficulty = INSTANCE_DIFFICULTY.heroic,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.wrath
    },

    ["Bronze Drake"] = {
        zone =               "The Culling of Stratholme",
        dropsFrom =          "Infinite Corruptor",
        instanceType =       INSTANCE_TYPE.dungeon,
        instanceDifficulty = INSTANCE_DIFFICULTY.heroic,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.wrath
    },

    ["Grand Black War Mammoth"] = {
        zone =               "Vault of Archavon",
        dropsFrom =          {
            "Archavon the Stone Watcher",
            "Emalon the Storm Watcher",
            "Koralon the Flame Watcher",
            "Toravon the Ice Watcher"
        },
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.wrath
    },

    ["Azure Drake"] = {
        zone =               "The Eye of Eternity",
        dropsFrom =          "Malygos",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.wrath
    },

    ["Blue Drake"] = {
        zone =               "The Eye of Eternity",
        dropsFrom =          "Malygos",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.wrath
    },

    ["Black Drake"] = {
        zone =               "The Obsidian Sanctum",
        dropsFrom =          "Sartharion",
        note =               "3 Drakes",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.ten,
        expansion =          EXPANSION.wrath
    },

    ["Twilight Drake"] = {
        zone =               "The Obsidian Sanctum",
        dropsFrom =          "Sartharion",
        note =               "3 Drakes",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.twentyFive,
        expansion =          EXPANSION.wrath
    },

    ["Onyxian Drake"] = {
        zone =               "Onyxia's Lair",
        dropsFrom =          "Onyxia",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.wrath
    },

    ["Mimiron's Head"] = {
        zone =               "Ulduar",
        dropsFrom =          "Yogg-Saron",
        note =               "No Watchers",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.twentyFive,
        expansion =          EXPANSION.wrath
    },

    ["Invincible"] = {
        zone =               "Icecrown Citadel",
        dropsFrom =          "The Lich King",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.heroic,
        instanceSize =       INSTANCE_SIZE.twentyFive,
        expansion =          EXPANSION.wrath
    },


    -- Cataclysm
    ["Drake of the North Wind"] = {
        zone =               "The Vortex Pinnacle",
        dropsFrom =          "Altairus",
        instanceType =       INSTANCE_TYPE.dungeon,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.cata
    },

    ["Vitreous Stone Drake"] = {
        zone =               "The Stonecore",
        dropsFrom =          "Slabhide",
        instanceType =       INSTANCE_TYPE.dungeon,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.cata
    },

    ["Swift Zulian Panther"] = {
        zone =               "Zul'Gurub",
        dropsFrom =          "High Priestess Kilnara",
        instanceType =       INSTANCE_TYPE.dungeon,
        instanceDifficulty = INSTANCE_DIFFICULTY.heroic,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.cata
    },

    ["Armored Razzashi Raptor"] = {
        zone =               "Zul'Gurub",
        dropsFrom =          "Bloodlord Mandokir",
        instanceType =       INSTANCE_TYPE.dungeon,
        instanceDifficulty = INSTANCE_DIFFICULTY.heroic,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.cata
    },

    ["Amani Battle Bear"] = {
        zone =               "Zul'Aman",
        dropsFrom =          "",
        note =               "Timed Reward",
        instanceType =       INSTANCE_TYPE.dungeon,
        instanceDifficulty = INSTANCE_DIFFICULTY.heroic,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.cata
    },

    ["Drake of the South Wind"] = {
        zone =               "Throne of the Four Winds",
        dropsFrom =          "Al'Akir",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.cata
    },

    ["Flametalon of Alysrazor"] = {
        zone =               "Firelands",
        dropsFrom =          "Alysrazor",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.cata
    },

    ["Pureblood Fire Hawk"] = {
        zone =               "Firelands",
        dropsFrom =          "Ragnaros",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.cata
    },

    ["Experiment 12-B"] = {
        zone =               "Dragon Soul",
        dropsFrom =          "Ultraxion",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.cata
    },

    ["Blazing Drake"] = {
        zone =               "Dragon Soul",
        dropsFrom =          "Deathwing",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.cata
    },

    ["Life-Binder's Handmaiden"] = {
        zone =               "Dragon Soul",
        dropsFrom =          "Deathwing",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.heroic,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.cata
    },


    -- Mists of Pandaria
    ["Heavenly Onyx Cloud Serpent"] = {
        zone =               "Kun-Lai Summit",
        dropsFrom =          "Sha of Anger",
        instanceType =       INSTANCE_TYPE.world,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.mop
    },

    ["Son of Galleon"] = {
        zone =               "Valley of the Four Winds",
        dropsFrom =          "Galleon",
        instanceType =       INSTANCE_TYPE.world,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.mop
    },

    ["Thundering Cobalt Cloud Serpent"] = {
        zone =               "Isle of Thunder",
        dropsFrom =          "Nalak",
        instanceType =       INSTANCE_TYPE.world,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.mop
    },

    ["Cobalt Primordial Direhorn"] = {
        zone =               "Isle of Giants",
        dropsFrom =          "Oondasta",
        instanceType =       INSTANCE_TYPE.world,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.mop
    },

    ["Astral Cloud Serpent"] = {
        zone =               "Mogu'shan Vaults",
        dropsFrom =          "Elegon",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.mop
    },

    ["Spawn of Horridon"] = {
        zone =               "Throne of Thunder",
        dropsFrom =          "Horridon",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.mop
    },

    ["Clutch of Ji-Kun"] = {
        zone =               "Throne of Thunder",
        dropsFrom =          "Ji-Kun",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.mop
    },

    ["Kor'kron Juggernaut"] = {
        zone =               "Siege of Orgrimmar",
        dropsFrom =          "Garrosh Hellscream",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.mythic,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.mop
    },

    -- Warlords of Draenor
    ["Solar Spirehawk"] = {
        zone =               "Spires of Arak",
        dropsFrom =          "Rukhmar",
        instanceType =       INSTANCE_TYPE.world,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.wod
    }
}

function MOUNT_SECTIONS()
    return {
        [EXPANSION.classic] = {
            [INSTANCE_TYPE.dungeon] = {
                -- [INSTANCE_DIFFICULTY.all] = {}
            },
            [INSTANCE_TYPE.raid] = {
                -- [INSTANCE_DIFFICULTY.all] = {}
            }
        },
        [EXPANSION.bc] = {
            [INSTANCE_TYPE.dungeon] = {
                -- [INSTANCE_DIFFICULTY.heroic] = {}
            },
            [INSTANCE_TYPE.raid] = {
                -- [INSTANCE_DIFFICULTY.all] = {}
            }
        },
        [EXPANSION.wrath] = {
            [INSTANCE_TYPE.dungeon] = {
                -- [INSTANCE_DIFFICULTY.heroic] = {}
            },
            [INSTANCE_TYPE.raid] = {
                -- [INSTANCE_DIFFICULTY.all] = {},
                -- [INSTANCE_DIFFICULTY.heroic] = {}
            }
        },
        [EXPANSION.cata] = {
            [INSTANCE_TYPE.dungeon] = {
                -- [INSTANCE_DIFFICULTY.all] = {},
                -- [INSTANCE_DIFFICULTY.heroic] = {},
            },
            [INSTANCE_TYPE.raid] = {
                -- [INSTANCE_DIFFICULTY.all] = {},
                -- [INSTANCE_DIFFICULTY.heroic] = {}
            }
        },
        [EXPANSION.mop] = {
            [INSTANCE_TYPE.raid] = {
                -- [INSTANCE_DIFFICULTY.all] = {},
                -- [INSTANCE_DIFFICULTY.heroic] = {},
                -- [INSTANCE_DIFFICULTY.mythic] = {},
            },
            [INSTANCE_TYPE.world] = {},
        },
        [EXPANSION.wod] = {
            [INSTANCE_TYPE.world] = {},
        }
    }
end

local ZONES = {}

function IMCAddon:Debug(message)
    if DEBUG then
        IMCAddon:Print(message)
    end
end

function IMCAddon:OnInitialize()
    self:Debug("OnInitialize")
    -- self:RegisterChatCommand("scanmounts", "ScanMounts")
    -- self:RegisterChatCommand("instances", "AvailableMountInstances")

    self.db = LibStub("AceDB-3.0"):New("IMCDB", {
        profile = {
            minimap = {
                hide = false,
            },
        },
    })


    local dataobject = LDB:NewDataObject(addonShortName, {
        text = addonAbbr,
        type = "launcher",
        icon = "Interface\\Icons\\INV_Chest_Cloth_17",
        OnEnter = function(frame) IMCAddon:IconOnEnter(frame) end,
        OnLeave = function(frame) end,
    })

    LDBIcon:Register(addonShortName, dataobject, self.db.profile.minimap)



    -- LDBIcon:Register(addonShortName, LDB, self.db.profile.minimap)
    self:RegisterChatCommand("toggleimcicon", "ToggleMinimapIcon")

    -- Setup mount list by zone
    for k,v in pairs(INSTANCE_MOUNTS) do
        local z = v.instanceType == INSTANCE_TYPE.world and INSTANCE_TYPE.world or v.zone
        if not ZONES[z] then
            ZONES[z] = {
                name = z,
                saved = false,
                killedBosses = {},
                mounts = {},
                saveEndTime = nil,
                saveDifficultyName = nil,
            }
        end
        table.insert(ZONES[z].mounts, k)
    end

    self:RegisterEvent("PLAYER_LOGIN")

    -- For dumping
    -- IMC_MOUNTS = INSTANCE_MOUNTS
    -- IMC_ZONES = ZONES
end

function IMCAddon:OnEnable()
    IMCAddon:Debug("OnEnable")
end

function IMCAddon:OnDisable()
    IMCAddon:Debug("OnDisable")
end

function IMCAddon:PLAYER_LOGIN()
    self:Debug("PLAYER_LOGIN")
    self:ScanMounts()
    self:ScanSavedInstances()
end

function IMCAddon:IconOnEnter(frame)
    self:Debug("IconOnEnter")
    self:ScanMounts()
    self:ScanSavedInstances()

    if tooltip then
        LibQTip:Release(tooltip)
        tooltip = nil
    end

    tooltip = LibQTip:Acquire(addonShortName, 2, "LEFT", "CENTER")
    tooltip.anchorframe = frame
    tooltip:Clear()
    tooltip:SetAutoHideDelay(0.1, frame)
    tooltip.OnRelease = function() tooltip = nil end
    -- tooltip:SetScript("OnLeave", TooltipOnLeave)


    local mountSections = MOUNT_SECTIONS()

    for name,mount in pairs(INSTANCE_MOUNTS) do
        if not mount.collected or DEBUG_ALL_MOUNTS then
            if not mountSections[mount.expansion][mount.instanceType][mount.zone] then
                mountSections[mount.expansion][mount.instanceType][mount.zone] = {}
            end
            mountSections[mount.expansion][mount.instanceType][mount.zone][name] = mount

        end
    end
    function addZoneRow(sections, exp, itype, diff)
        local alphaZoneList = {}
        local section = sections[exp][itype]
        for name,value in pairs(section) do
            alphaZoneList[#alphaZoneList+1] = name
        end
        table.sort(alphaZoneList)
        for k,zoneName in pairs(alphaZoneList) do
            local totalBosses = countUniqueBosses(section[zoneName])
            local killedBosses = 0
            local hasLock = false
            for k,v in pairs(section[zoneName]) do
                local bosses = type(v.dropsFrom) == "table" and v.dropsFrom or {v.dropsFrom}
                for i,j in pairs(bosses) do
                    if (v.instanceDifficulty == INSTANCE_DIFFICULTY.heroic or v.instanceDifficulty == INSTANCE_DIFFICULTY.mythic or
                       v.instanceType == INSTANCE_TYPE.raid or v.instanceType == INSTANCE_TYPE.world) and
                       j ~= "Trash" then -- AQ check
                        hasLock = true
                    end
                    local z = itype == INSTANCE_TYPE.world and INSTANCE_TYPE.world or v.zone
                    if ZONES[z].killedBosses[j] then
                        killedBosses = killedBosses + 1
                    end
                end
            end
            local name = "  "..zoneName
            local bossCount = killedBosses.."/"..totalBosses
            if not hasLock then
                bossCount = ""
            end
            local lineNum = tooltip:AddLine(name, bossCount)
            -- tooltip:EnableMouse(true)


            -- tooltip:SetLineScript(lineNum, "OnEnter", ZoneTooltipOnEnter, {
            --     zone = name,
            --     mounts = section[zoneName],
            -- })
            if hasLock then
                tooltip:SetLineScript(lineNum, "OnEnter", DoNothing)
                tooltip:SetCellScript(lineNum, 2, "OnEnter", ZoneTooltipOnEnter, {
                    line = false,
                    mounts = section[zoneName],
                    bossStatus = bossCount
                })
                tooltip:SetCellScript(lineNum, 2, "OnLeave", ZoneTooltipOnLeave)
            else
                tooltip:SetLineScript(lineNum, "OnEnter", ZoneTooltipOnEnter, {
                    line = true,
                    mounts = section[zoneName],
                    bossStatus = bossCount
                })
                tooltip:SetLineScript(lineNum, "OnLeave", ZoneTooltipOnLeave)
            end


        end
    end


    local classicDungeon = next(mountSections[EXPANSION.classic][INSTANCE_TYPE.dungeon]) ~= nil
    local bcDungeon = next(mountSections[EXPANSION.bc][INSTANCE_TYPE.dungeon]) ~= nil
    local wrathDungeon = next(mountSections[EXPANSION.wrath][INSTANCE_TYPE.dungeon]) ~= nil
    local cataDungeon = next(mountSections[EXPANSION.cata][INSTANCE_TYPE.dungeon]) ~= nil


    if classicDungeon or bcDungeon or wrathDungeon or cataDungeon then
        tooltip:AddHeader("Dungeons", UnitName("player"))
    end

    if classicDungeon then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(EXPANSION.classic)
        addZoneRow(mountSections, EXPANSION.classic, INSTANCE_TYPE.dungeon)
    end
    if bcDungeon then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(EXPANSION.bc)
        addZoneRow(mountSections, EXPANSION.bc, INSTANCE_TYPE.dungeon)
    end
    if wrathDungeon then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(EXPANSION.wrath)
        addZoneRow(mountSections, EXPANSION.wrath, INSTANCE_TYPE.dungeon)
    end
    if cataDungeon then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(EXPANSION.cata)
        addZoneRow(mountSections, EXPANSION.cata, INSTANCE_TYPE.dungeon)
    end


    local classicRaid = next(mountSections[EXPANSION.classic][INSTANCE_TYPE.raid]) ~= nil
    local bcRaid = next(mountSections[EXPANSION.bc][INSTANCE_TYPE.raid]) ~= nil
    local wrathRaid = next(mountSections[EXPANSION.wrath][INSTANCE_TYPE.raid]) ~= nil
    local cataRaid = next(mountSections[EXPANSION.cata][INSTANCE_TYPE.raid]) ~= nil
    local mopRaid = next(mountSections[EXPANSION.mop][INSTANCE_TYPE.raid]) ~= nil
    local mopWorld = next(mountSections[EXPANSION.mop][INSTANCE_TYPE.world]) ~= nil
    local wodWorld = next(mountSections[EXPANSION.wod][INSTANCE_TYPE.world]) ~= nil

    if classicRaid or bcRaid or wrathRaid or cataRaid or mopRaid then
        tooltip:AddSeparator(15, 1, 1, 1, 0)
        tooltip:AddHeader("Raids", UnitName("player"))
    end

    if classicRaid then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(EXPANSION.classic)
        addZoneRow(mountSections, EXPANSION.classic, INSTANCE_TYPE.raid)
    end
    if bcRaid then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(EXPANSION.bc)
        addZoneRow(mountSections, EXPANSION.bc, INSTANCE_TYPE.raid)
    end
    if wrathRaid then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(EXPANSION.wrath)
        addZoneRow(mountSections, EXPANSION.wrath, INSTANCE_TYPE.raid)
    end
    if cataRaid then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(EXPANSION.cata)
        addZoneRow(mountSections, EXPANSION.cata, INSTANCE_TYPE.raid)
    end
    if mopRaid then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(EXPANSION.mop)
        addZoneRow(mountSections, EXPANSION.mop, INSTANCE_TYPE.raid)
    end

    if mopWorld or wodWorld then
        tooltip:AddSeparator(15, 1, 1, 1, 0)
        tooltip:AddHeader("World", UnitName("player"))
    end

    if mopWorld then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(EXPANSION.mop)
        addZoneRow(mountSections, EXPANSION.mop, INSTANCE_TYPE.world)
    end
    if wodWorld then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(EXPANSION.wod)
        addZoneRow(mountSections, EXPANSION.wod, INSTANCE_TYPE.world)
    end

    -- Use smart anchoring code to anchor the tooltip to our frame
    tooltip:SmartAnchorTo(frame)

    -- tooltip:SetLineScript(1, "OnEnter", ShowZoneCellTooltip)


    -- Show it, et voilà !
    tooltip:Show()
end

function countUniqueBosses(t)
    -- IMC_T = t
    local count = 0
    local temp = {}
    for k,v in pairs(t) do
        local bosses = type(v.dropsFrom) == "table" and v.dropsFrom or {v.dropsFrom}
        for i,j in pairs(bosses) do
            if not temp[j] then
                count = count + 1
                temp[j] = true
            end
        end
    end
    return count
end

function IMCAddon:IconOnLeave(frame)
    -- Release the tooltip
    -- LibQTip:Release(tooltip)
end

function IMCAddon:ToggleMinimapIcon()
    self.db.profile.minimap.hide = not self.db.profile.minimap.hide
    if self.db.profile.minimap.hide then
        LDBIcon:Hide(addonShortName)
    else
        LDBIcon:Show(addonShortName)
    end
end

function TooltipOnLeave()
    IMCAddon:Debug("TooltipOnLeave")
end

function DoNothing()

end

function ZoneTooltipOnEnter(cell, arg, ...)
    IMCAddon:Debug("ZoneTooltipOnEnter")
    local mounts = arg.mounts
    local bossStatus = arg.bossStatus
    local num = 0
    -- IMCAddon:Debug(cell)
    -- tooltipClosable = false
    -- additionalInfoTip = LibQTip:Acquire(addonShortName.."AddInfoTip", 1, "LEFT")
    -- additionalInfoTip:SetScript("OnLeave", CloseAdditionalInfoTip)
    -- IMC_ARG = arg
    openIndicator(3, "LEFT", "CENTER", "RIGHT")
    if not arg.line then
        local tmpm = mounts[0]
        local z = tmpm.instanceType == INSTANCE_TYPE.world and INSTANCE_TYPE.world or tmpm.zone
        indicatortip:AddHeader(bossStatus, next(mounts).zone, UnitName("player"))
        -- indicatortip:AddSeparator(3, 1, 1, 1, 0)
    end
    for k,v in pairs(mounts) do
        if not arg.line or num > 0 then
            indicatortip:AddSeparator(2, 1, 1, 1, 0)
        end
        num = num + 1

        indicatortip:AddHeader(k)
        local bosses = type(v.dropsFrom) == "table" and v.dropsFrom or {v.dropsFrom}
        for i,j in pairs(bosses) do
            local dropsFrom = j
            if v.note then
                if dropsFrom == "" then
                    dropsFrom = v.note
                else
                    dropsFrom = dropsFrom.." ("..v.note..")"
                end
            end

            local mods = ""

            local tmp = {}
            if v.instanceDifficulty ~= INSTANCE_DIFFICULTY.all then
                table.insert(tmp, v.instanceDifficulty)
            end
            if v.instanceSize ~= INSTANCE_SIZE.all then
                table.insert(tmp, v.instanceSize)
            end

            if #tmp > 0 then
                mods = strjoin(", ", unpack(tmp))
            end

            local z = v.instanceType == INSTANCE_TYPE.world and INSTANCE_TYPE.world or v.zone
            local available = ""
            if not arg.line then
                if j ~= "" then
                    available = ZONES[z].killedBosses[dropsFrom] and "Unavailable" or "Available"
                elseif v.saveCheck then
                    available = ZONES[z].killedBosses[v.saveCheck] and "Unavailable" or "Available"
                else
                    available = ZONES[z].saved and "Unavailable" or "Available"
                end
            end
            indicatortip:AddLine(dropsFrom, mods, available)
        end
    end
    -- finishIndicator(cell)
    finishIndicator()
end

function ZoneTooltipOnLeave(cell, arg, ...)
    IMCAddon:Debug("ZoneTooltipOnLeave")
    -- tooltipClosable = true
    CloseIndicator()
end

function IMCAddon:ScanMounts()
    -- IMCAddon:Debug("ScanMounts")

    local collectedFilterCur, notCollectedFilterCur = C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED), C_MountJournal.GetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED)
    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED, true)
    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED, true)

    local playerFaction = UnitFactionGroup("player")

    for i = 1, C_MountJournal.GetNumMounts() do
        local name, id, icon, _, summonable, source, _, _, faction, hidden, owned = C_MountJournal.GetMountInfo(i)
        if INSTANCE_MOUNTS[name] and (faction == nil or FACTION[faction] == playerFaction) then
            -- IMCAddon:Debug(name)
            INSTANCE_MOUNTS[name].collected = owned
        end
    end

    for k,v in pairs(INSTANCE_MOUNTS) do
        if not v.collected then
            -- IMCAddon:Debug("Not Collected: " .. k)
        end
    end

    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED, collectedFilterCur)
    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED, notCollectedFilterCur)
end

function IMCAddon:ScanSavedInstances()
    for i = 1, GetNumSavedInstances() do
        local instanceName, _, instanceReset, instanceDifficulty, locked, _, _, _, _, difficultyName, maxBosses = GetSavedInstanceInfo(i)
        if instanceDifficulty ~= 7 then -- Don't count LFR
            if ZONES[instanceName] then
                ZONES[instanceName].saved = locked
                ZONES[instanceName].saveDifficultyName = difficultyName
                ZONES[instanceName].saveEndTime = time() + instanceReset
                for bossIndex = 1, maxBosses do
                    local name, _, isKilled = GetSavedInstanceEncounterInfo(i, bossIndex)
                    ZONES[instanceName].killedBosses[name] = isKilled
                end
            end
        end
    end
end

function IMCAddon:AvailableMountInstances()
    for k,v in pairs(ZONES) do
        local availableMounts = {}
        for i,m in pairs(v.mounts) do
            if not INSTANCE_MOUNTS[m].collected then
                local dropsFrom = INSTANCE_MOUNTS[m].dropsFrom
                if not v.killedBosses[dropsFrom] then
                    table.insert(availableMounts, m)
                end
            end
        end
        if next(availableMounts) ~= nil then
            IMCAddon:Print(k .. " - " .. strjoin(", ", unpack(availableMounts)))
        end
    end
end

function openIndicator(...)
    indicatortip = LibQTip:Acquire(addonShortName.."IndicatorTip", ...)
    indicatortip:Clear()
    -- indicatortip:SetHeaderFont(core:HeaderFont())
    -- indicatortip:SetScale(vars.db.Tooltip.Scale)
end

function finishIndicator(parent)
    parent = parent or tooltip
    indicatortip:SetAutoHideDelay(0.1, parent)
    indicatortip.OnRelease = function() indicatortip = nil end -- extra-safety: update our variable on auto-release
    indicatortip:SmartAnchorTo(parent)
    indicatortip:SetFrameLevel(100) -- ensure visibility when forced to overlap main tooltip
    -- addon:SkinFrame(indicatortip,"SavedInstancesIndicatorTooltip")
    indicatortip:Show()
end

function CloseIndicator()
    if indicatortip then
        indicatortip:Hide()
    end
end