local addonShortName = "IMC"

IMCAddon = LibStub("AceAddon-3.0"):NewAddon(addonShortName, "AceConsole-3.0", "AceEvent-3.0")

local LibQTip = LibStub('LibQTip-1.0')

local LDB = LibStub("LibDataBroker-1.1"):NewDataObject(addonShortName, {
    type = "launcher",
    -- text = addonShortName,
    icon = "Interface\\Icons\\INV_Chest_Cloth_17",
    OnEnter = function(frame) IMCAddon:IconOnEnter(frame) end,
    OnLeave = function(frame) IMCAddon:IconOnLeave(frame) end
})
local LDBIcon = LDB and LibStub("LibDBIcon-1.0")


local DEBUG = true

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
    ten = "10 man",
    twentyFive = "25 man"
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
        dropsFrom =          "Trash",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.classic
    },

    ["Green Qiraji Battle Tank"] = {
        zone =               "Temple of Ahn'Qiraj",
        dropsFrom =          "Trash",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.classic
    },

    ["Yellow Qiraji Battle Tank"] = {
        zone =               "Temple of Ahn'Qiraj",
        dropsFrom =          "Trash",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.all,
        expansion =          EXPANSION.classic
    },

    ["Red Qiraji Battle Tank"] = {
        zone =               "Temple of Ahn'Qiraj",
        dropsFrom =          "Trash",
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
        dropsFrom =          "All 4 Bosses",
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
        dropsFrom =          "Sartharion (3 Drakes)",
        instanceType =       INSTANCE_TYPE.raid,
        instanceDifficulty = INSTANCE_DIFFICULTY.all,
        instanceSize =       INSTANCE_SIZE.ten,
        expansion =          EXPANSION.wrath
    },

    ["Twilight Drake"] = {
        zone =               "The Obsidian Sanctum",
        dropsFrom =          "Sartharion (3 Drakes)",
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
        dropsFrom =          "Yogg-Saron (No Watchers)",
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
        dropsFrom =          "(Timed Reward)",
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
                [INSTANCE_DIFFICULTY.all] = {}
            },
            [INSTANCE_TYPE.raid] = {
                [INSTANCE_DIFFICULTY.all] = {}
            }
        },
        [EXPANSION.bc] = {
            [INSTANCE_TYPE.dungeon] = {
                [INSTANCE_DIFFICULTY.heroic] = {}
            },
            [INSTANCE_TYPE.raid] = {
                [INSTANCE_DIFFICULTY.all] = {}
            }
        },
        [EXPANSION.wrath] = {
            [INSTANCE_TYPE.dungeon] = {
                [INSTANCE_DIFFICULTY.heroic] = {}
            },
            [INSTANCE_TYPE.raid] = {
                [INSTANCE_DIFFICULTY.all] = {},
                [INSTANCE_DIFFICULTY.heroic] = {}
            }
        },
        [EXPANSION.cata] = {
            [INSTANCE_TYPE.dungeon] = {
                [INSTANCE_DIFFICULTY.all] = {},
                [INSTANCE_DIFFICULTY.heroic] = {},
            },
            [INSTANCE_TYPE.raid] = {
                [INSTANCE_DIFFICULTY.all] = {},
                [INSTANCE_DIFFICULTY.heroic] = {}
            }
        },
        [EXPANSION.mop] = {
            [INSTANCE_TYPE.raid] = {
                [INSTANCE_DIFFICULTY.all] = {},
                [INSTANCE_DIFFICULTY.heroic] = {},
                [INSTANCE_DIFFICULTY.mythic] = {},
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
    self:RegisterChatCommand("scanmounts", "ScanMounts")
    self:RegisterChatCommand("instances", "AvailableMountInstances")

    self.db = LibStub("AceDB-3.0"):New("IMCDB", {
        profile = {
            minimap = {
                hide = false,
            },
        },
    })

    LDBIcon:Register(addonShortName, LDB, self.db.profile.minimap)
    self:RegisterChatCommand("toggleimcicon", "ToggleMinimapIcon")

    -- Setup mount list by zone
    for k,v in pairs(INSTANCE_MOUNTS) do
        local z = v.instanceType == INSTANCE_TYPE.world and INSTANCE_TYPE.world or v.zone
        if not ZONES[z] then
            ZONES[z] = {
                name = z,
                saved = false,
                killedBosses = {},
                mounts = {}
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

    -- Acquire a tooltip with 3 columns, respectively aligned to left, center and right
    -- local tooltip = LibQTip:Acquire("IMCTooltip", 3, "LEFT", "LEFT", "LEFT")
    local tooltip = LibQTip:Acquire("IMCTooltip", 2, "LEFT", "CENTER")
    self.tooltip = tooltip

    -- Add an header filling only the first two columns
    -- tooltip:AddHeader("Instance", "Boss", "Mount")

    -- Add an new line, using all columns
    -- tooltip:AddLine("Hello", "World", "!")

    -- local normalDungeons = {}
    -- local heroicDungeons = {}
    -- local raids = {}
    -- local world = {}


    -- for k,v in pairs(INSTANCE_TYPE) do
    --     -- table.insert(MOUNT_SECTIONS, v)
    --     MOUNT_SECTIONS[v] = {}
    --     for i,j in pairs(INSTANCE_DIFFICULTY) do
    --         -- table.insert(MOUNT_SECTIONS[v], j)
    --         MOUNT_SECTIONS[v][j] = {}
    --     end
    -- end

    local mountSections = MOUNT_SECTIONS()

    for name,mount in pairs(INSTANCE_MOUNTS) do
        if not mount.collected or DEBUG then
            if mount.instanceType == INSTANCE_TYPE.dungeon then
                if mount.instanceDifficulty == INSTANCE_DIFFICULTY.all then
                    if not mountSections[mount.expansion][INSTANCE_TYPE.dungeon][INSTANCE_DIFFICULTY.all][mount.zone] then
                        mountSections[mount.expansion][INSTANCE_TYPE.dungeon][INSTANCE_DIFFICULTY.all][mount.zone] = {}
                    end
                    mountSections[mount.expansion][INSTANCE_TYPE.dungeon][INSTANCE_DIFFICULTY.all][mount.zone][name] = mount
                elseif mount.instanceDifficulty == INSTANCE_DIFFICULTY.heroic then
                    if not mountSections[mount.expansion][INSTANCE_TYPE.dungeon][INSTANCE_DIFFICULTY.heroic][mount.zone] then
                        mountSections[mount.expansion][INSTANCE_TYPE.dungeon][INSTANCE_DIFFICULTY.heroic][mount.zone] = {}
                    end
                    mountSections[mount.expansion][INSTANCE_TYPE.dungeon][INSTANCE_DIFFICULTY.heroic][mount.zone][name] = mount
                end
            elseif mount.instanceType == INSTANCE_TYPE.raid then
                if mount.instanceDifficulty == INSTANCE_DIFFICULTY.all then
                    if not mountSections[mount.expansion][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.all][mount.zone] then
                        mountSections[mount.expansion][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.all][mount.zone] = {}
                    end
                    mountSections[mount.expansion][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.all][mount.zone][name] = mount
                elseif mount.instanceDifficulty == INSTANCE_DIFFICULTY.heroic then
                    if not mountSections[mount.expansion][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.heroic][mount.zone] then
                        mountSections[mount.expansion][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.heroic][mount.zone] = {}
                    end
                    mountSections[mount.expansion][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.heroic][mount.zone][name] = mount
                elseif mount.instanceDifficulty == INSTANCE_DIFFICULTY.mythic then
                    if not mountSections[mount.expansion][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.mythic][mount.zone] then
                        mountSections[mount.expansion][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.mythic][mount.zone] = {}
                    end
                    mountSections[mount.expansion][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.mythic][mount.zone][name] = mount
                end
            elseif mount.instanceType == INSTANCE_TYPE.world then
                if not mountSections[mount.expansion][INSTANCE_TYPE.world][mount.zone] then
                    mountSections[mount.expansion][INSTANCE_TYPE.world][mount.zone] = {}
                end
                mountSections[mount.expansion][INSTANCE_TYPE.world][mount.zone][name] = mount
            end
        end
    end

    -- IMC_MOUNT_SECTIONS = mountSections


    local classicDungeonAll = next(mountSections[EXPANSION.classic][INSTANCE_TYPE.dungeon][INSTANCE_DIFFICULTY.all]) ~= nil
    local bcDungeonHeroic = next(mountSections[EXPANSION.bc][INSTANCE_TYPE.dungeon][INSTANCE_DIFFICULTY.heroic]) ~= nil
    local wrathDungeonHeroic = next(mountSections[EXPANSION.wrath][INSTANCE_TYPE.dungeon][INSTANCE_DIFFICULTY.heroic]) ~= nil
    local cataDungeonAll = next(mountSections[EXPANSION.cata][INSTANCE_TYPE.dungeon][INSTANCE_DIFFICULTY.all]) ~= nil
    local cataDungeonHeroic = next(mountSections[EXPANSION.cata][INSTANCE_TYPE.dungeon][INSTANCE_DIFFICULTY.heroic]) ~= nil


    if classicDungeonAll or bcDungeonHeroic or wrathDungeonHeroic or cataDungeonAll or cataDungeonHeroic then
        tooltip:AddHeader("Daily", UnitName("player"))
    end

    function addZoneRow(sections, exp, itype, diff)
        local alphaZoneList = {}
        -- IMCAddon:Debug(sections)
        -- IMCAddon:Debug(exp)
        -- IMCAddon:Debug(type)
        -- IMCAddon:Debug(diff)
        local section = itype == INSTANCE_TYPE.world and sections[exp][itype] or sections[exp][itype][diff]
        for name,value in pairs(section) do
            alphaZoneList[#alphaZoneList+1] = name
        end
        table.sort(alphaZoneList)
        for k,zoneName in pairs(alphaZoneList) do
            local totalBosses = countTable(section[zoneName])
            local killedBosses = 0
            for k,v in pairs(section[zoneName]) do
                IMC_V = section
                local z = itype == INSTANCE_TYPE.world and INSTANCE_TYPE.world or v.zone
                if ZONES[z].killedBosses[v.dropsFrom] then
                    killedBosses = killedBosses + 1
                end
            end
            local name = "  "..zoneName
            if diff == INSTANCE_DIFFICULTY.heroic or diff == INSTANCE_DIFFICULTY.mythic then
                name = name .. " (" .. diff .. ")"
            end
            tooltip:AddLine(name, killedBosses.."/"..totalBosses)
        end
    end

    if classicDungeonAll then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(EXPANSION.classic..": "..INSTANCE_TYPE.dungeon)
        addZoneRow(mountSections, EXPANSION.classic, INSTANCE_TYPE.dungeon, INSTANCE_DIFFICULTY.all)
        -- local alphaZoneList = {}
        -- for name,value in pairs(mountSections[EXPANSION.classic][INSTANCE_TYPE.dungeon][INSTANCE_DIFFICULTY.all]) do
        --     alphaZoneList[#alphaZoneList+1] = name
        -- end
        -- for k,zoneName in pairs(alphaZoneList) do
        --     local totalBosses = countTable(mountSections[EXPANSION.classic][INSTANCE_TYPE.dungeon][INSTANCE_DIFFICULTY.all][zoneName])
        --     local killedBosses = 0
        --     for k,v in pairs(mountSections[EXPANSION.classic][INSTANCE_TYPE.dungeon][INSTANCE_DIFFICULTY.all][zoneName]) do
        --         if ZONES[v.zone].killedBosses[v.dropsFrom] then
        --             killedBosses = killedBosses + 1
        --         end
        --     end
        --     tooltip:AddLine("  "..zoneName, killedBosses.."/"..totalBosses)
        -- end
    end
    if bcDungeonHeroic then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(EXPANSION.bc..": "..INSTANCE_TYPE.dungeon)
        addZoneRow(mountSections, EXPANSION.bc, INSTANCE_TYPE.dungeon, INSTANCE_DIFFICULTY.heroic)
        -- for zoneName,zone in pairs(mountSections[EXPANSION.bc][INSTANCE_TYPE.dungeon][INSTANCE_DIFFICULTY.heroic]) do
        --     local totalBosses = countTable(zone)
        --     local killedBosses = 0
        --     for k,v in pairs(zone) do
        --         if ZONES[v.zone].killedBosses[v.dropsFrom] then
        --             killedBosses = killedBosses + 1
        --         end
        --     end
        --     tooltip:AddLine("  "..zoneName.." ("..INSTANCE_DIFFICULTY.heroic..")", killedBosses.."/"..totalBosses)
        -- end
    end
    if wrathDungeonHeroic then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(EXPANSION.wrath..": "..INSTANCE_TYPE.dungeon)
        addZoneRow(mountSections, EXPANSION.wrath, INSTANCE_TYPE.dungeon, INSTANCE_DIFFICULTY.heroic)
        -- for zoneName,zone in pairs(mountSections[EXPANSION.wrath][INSTANCE_TYPE.dungeon][INSTANCE_DIFFICULTY.heroic]) do
        --     local totalBosses = countTable(zone)
        --     local killedBosses = 0
        --     for k,v in pairs(zone) do
        --         if ZONES[v.zone].killedBosses[v.dropsFrom] then
        --             killedBosses = killedBosses + 1
        --         end
        --     end
        --     tooltip:AddLine("  "..zoneName.." ("..INSTANCE_DIFFICULTY.heroic..")", killedBosses.."/"..totalBosses)
        -- end
    end
    if cataDungeonAll or
       cataDungeonHeroic then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(EXPANSION.cata..": "..INSTANCE_TYPE.dungeon)
        addZoneRow(mountSections, EXPANSION.cata, INSTANCE_TYPE.dungeon, INSTANCE_DIFFICULTY.all)
        -- for zoneName,zone in pairs(mountSections[EXPANSION.cata][INSTANCE_TYPE.dungeon][INSTANCE_DIFFICULTY.all]) do
        --     local totalBosses = countTable(zone)
        --     local killedBosses = 0
        --     for k,v in pairs(zone) do
        --         if ZONES[v.zone].killedBosses[v.dropsFrom] then
        --             killedBosses = killedBosses + 1
        --         end
        --     end
        --     tooltip:AddLine("  "..zoneName, killedBosses.."/"..totalBosses)
        -- end
        addZoneRow(mountSections, EXPANSION.cata, INSTANCE_TYPE.dungeon, INSTANCE_DIFFICULTY.heroic)
        -- for zoneName,zone in pairs(mountSections[EXPANSION.cata][INSTANCE_TYPE.dungeon][INSTANCE_DIFFICULTY.heroic]) do
        --     local totalBosses = countTable(zone)
        --     local killedBosses = 0
        --     for k,v in pairs(zone) do
        --         if ZONES[v.zone].killedBosses[v.dropsFrom] then
        --             killedBosses = killedBosses + 1
        --         end
        --     end
        --     tooltip:AddLine("  "..zoneName.." ("..INSTANCE_DIFFICULTY.heroic..")", killedBosses.."/"..totalBosses)
        -- end
    end


    local classicRaidAll = next(mountSections[EXPANSION.classic][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.all]) ~= nil
    local bcRaidAll = next(mountSections[EXPANSION.bc][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.all]) ~= nil
    local wrathRaidAll = next(mountSections[EXPANSION.wrath][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.all]) ~= nil
    local wrathRaidHeroic = next(mountSections[EXPANSION.wrath][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.heroic]) ~= nil
    local cataRaidAll = next(mountSections[EXPANSION.cata][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.all]) ~= nil
    local cataRaidHeroic = next(mountSections[EXPANSION.cata][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.heroic]) ~= nil
    local mopRaidAll = next(mountSections[EXPANSION.mop][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.all]) ~= nil
    local mopRaidHeroic = next(mountSections[EXPANSION.mop][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.heroic]) ~= nil
    local mopRaidMythic = next(mountSections[EXPANSION.mop][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.mythic]) ~= nil

    if classicRaidAll or bcRaidAll or wrathRaidAll or wrathRaidHeroic or cataRaidAll or cataRaidHeroic or mopRaidAll or mopRaidHeroic or mopRaidMythic then
        tooltip:AddSeparator(15, 1, 1, 1, 0)
        tooltip:AddHeader("Weekly", UnitName("player"))
    end

    if classicRaidAll then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(EXPANSION.classic..": "..INSTANCE_TYPE.raid)
        addZoneRow(mountSections, EXPANSION.classic, INSTANCE_TYPE.raid, INSTANCE_DIFFICULTY.all)
        -- for zoneName,zone in pairs(mountSections[EXPANSION.classic][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.all]) do
        --     local totalBosses = countTable(zone)
        --     local killedBosses = 0
        --     for k,v in pairs(zone) do
        --         if ZONES[v.zone].killedBosses[v.dropsFrom] then
        --             killedBosses = killedBosses + 1
        --         end
        --     end
        --     tooltip:AddLine("  "..zoneName, killedBosses.."/"..totalBosses)
        -- end
    end
    if bcRaidAll then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(EXPANSION.bc..": "..INSTANCE_TYPE.raid)
        addZoneRow(mountSections, EXPANSION.bc, INSTANCE_TYPE.raid, INSTANCE_DIFFICULTY.all)
        -- for zoneName,zone in pairs(mountSections[EXPANSION.bc][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.all]) do
        --     local totalBosses = countTable(zone)
        --     local killedBosses = 0
        --     for k,v in pairs(zone) do
        --         if ZONES[v.zone].killedBosses[v.dropsFrom] then
        --             killedBosses = killedBosses + 1
        --         end
        --     end
        --     tooltip:AddLine("  "..zoneName, killedBosses.."/"..totalBosses)
        -- end
    end
    if wrathRaidAll or
       wrathRaidHeroic then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(EXPANSION.wrath..": "..INSTANCE_TYPE.raid)
        addZoneRow(mountSections, EXPANSION.wrath, INSTANCE_TYPE.raid, INSTANCE_DIFFICULTY.all)
        -- for zoneName,zone in pairs(mountSections[EXPANSION.wrath][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.all]) do
        --     local totalBosses = countTable(zone)
        --     local killedBosses = 0
        --     for k,v in pairs(zone) do
        --         if ZONES[v.zone].killedBosses[v.dropsFrom] then
        --             killedBosses = killedBosses + 1
        --         end
        --     end
        --     tooltip:AddLine("  "..zoneName, killedBosses.."/"..totalBosses)
        -- end
        addZoneRow(mountSections, EXPANSION.wrath, INSTANCE_TYPE.raid, INSTANCE_DIFFICULTY.heroic)
        -- for zoneName,zone in pairs(mountSections[EXPANSION.wrath][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.heroic]) do
        --     local totalBosses = countTable(zone)
        --     local killedBosses = 0
        --     for k,v in pairs(zone) do
        --         if ZONES[v.zone].killedBosses[v.dropsFrom] then
        --             killedBosses = killedBosses + 1
        --         end
        --     end
        --     tooltip:AddLine("  "..zoneName.." ("..INSTANCE_DIFFICULTY.heroic..")", killedBosses.."/"..totalBosses)
        -- end
    end
    if cataRaidAll or
       cataRaidHeroic then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(EXPANSION.cata..": "..INSTANCE_TYPE.raid)
        addZoneRow(mountSections, EXPANSION.cata, INSTANCE_TYPE.raid, INSTANCE_DIFFICULTY.all)
        -- for zoneName,zone in pairs(mountSections[EXPANSION.cata][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.all]) do
        --     local totalBosses = countTable(zone)
        --     local killedBosses = 0
        --     for k,v in pairs(zone) do
        --         if ZONES[v.zone].killedBosses[v.dropsFrom] then
        --             killedBosses = killedBosses + 1
        --         end
        --     end
        --     tooltip:AddLine("  "..zoneName, killedBosses.."/"..totalBosses)
        -- end
        addZoneRow(mountSections, EXPANSION.cata, INSTANCE_TYPE.raid, INSTANCE_DIFFICULTY.heroic)
        -- for zoneName,zone in pairs(mountSections[EXPANSION.cata][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.heroic]) do
        --     local totalBosses = countTable(zone)
        --     local killedBosses = 0
        --     for k,v in pairs(zone) do
        --         if ZONES[v.zone].killedBosses[v.dropsFrom] then
        --             killedBosses = killedBosses + 1
        --         end
        --     end
        --     tooltip:AddLine("  "..zoneName.." ("..INSTANCE_DIFFICULTY.heroic..")", killedBosses.."/"..totalBosses)
        -- end
    end
    if mopRaidAll or
       mopRaidHeroic or
       mopRaidMythic then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(EXPANSION.mop..": "..INSTANCE_TYPE.raid)
        addZoneRow(mountSections, EXPANSION.mop, INSTANCE_TYPE.raid, INSTANCE_DIFFICULTY.all)
        -- for zoneName,zone in pairs(mountSections[EXPANSION.mop][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.all]) do
        --     local totalBosses = countTable(zone)
        --     local killedBosses = 0
        --     for k,v in pairs(zone) do
        --         if ZONES[v.zone].killedBosses[v.dropsFrom] then
        --             killedBosses = killedBosses + 1
        --         end
        --     end
        --     tooltip:AddLine("  "..zoneName, killedBosses.."/"..totalBosses)
        -- end
        addZoneRow(mountSections, EXPANSION.mop, INSTANCE_TYPE.raid, INSTANCE_DIFFICULTY.heroic)
        -- for zoneName,zone in pairs(mountSections[EXPANSION.mop][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.heroic]) do
        --     local totalBosses = countTable(zone)
        --     local killedBosses = 0
        --     for k,v in pairs(zone) do
        --         if ZONES[v.zone].killedBosses[v.dropsFrom] then
        --             killedBosses = killedBosses + 1
        --         end
        --     end
        --     tooltip:AddLine("  "..zoneName.." ("..INSTANCE_DIFFICULTY.heroic..")", killedBosses.."/"..totalBosses)
        -- end
        addZoneRow(mountSections, EXPANSION.mop, INSTANCE_TYPE.raid, INSTANCE_DIFFICULTY.mythic)
        -- for zoneName,zone in pairs(mountSections[EXPANSION.mop][INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.mythic]) do
        --     local totalBosses = countTable(zone)
        --     local killedBosses = 0
        --     for k,v in pairs(zone) do
        --         if ZONES[v.zone].killedBosses[v.dropsFrom] then
        --             killedBosses = killedBosses + 1
        --         end
        --     end
        --     tooltip:AddLine("  "..zoneName.." ("..INSTANCE_DIFFICULTY.mythic..")", killedBosses.."/"..totalBosses)
        -- end
    end
    if next(mountSections[EXPANSION.mop][INSTANCE_TYPE.world]) ~= nil then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(EXPANSION.mop..": "..INSTANCE_TYPE.world)
        addZoneRow(mountSections, EXPANSION.mop, INSTANCE_TYPE.world)
        -- for zoneName,zone in pairs(mountSections[EXPANSION.mop][INSTANCE_TYPE.world]) do
        --     local totalBosses = countTable(zone)
        --     local killedBosses = 0
        --     for k,v in pairs(zone) do
        --         if ZONES[INSTANCE_TYPE.world].killedBosses[v.dropsFrom] then
        --             killedBosses = killedBosses + 1
        --         end
        --     end
        --     tooltip:AddLine("  "..zoneName, killedBosses.."/"..totalBosses)
        -- end
    end
    if next(mountSections[EXPANSION.wod][INSTANCE_TYPE.world]) ~= nil then
        tooltip:AddSeparator(2, 0, 0, 0, 0)
        tooltip:AddHeader(EXPANSION.wod..": "..INSTANCE_TYPE.world)
        addZoneRow(mountSections, EXPANSION.wod, INSTANCE_TYPE.world)
        -- for zoneName,zone in pairs(mountSections[EXPANSION.wod][INSTANCE_TYPE.world]) do
        --     local totalBosses = countTable(zone)
        --     local killedBosses = 0
        --     for k,v in pairs(zone) do
        --         if ZONES[INSTANCE_TYPE.world].killedBosses[v.dropsFrom] then
        --             killedBosses = killedBosses + 1
        --         end
        --     end
        --     tooltip:AddLine("  "..zoneName, killedBosses.."/"..totalBosses)
        -- end
    end


    -- if next(MOUNT_SECTIONS[INSTANCE_TYPE.dungeon][INSTANCE_DIFFICULTY.all]) ~= nil then
    --     tooltip:AddHeader("Dungeon (Normal)", "Boss", "Mount")
    --     for k,v in pairs(MOUNT_SECTIONS[INSTANCE_TYPE.dungeon][INSTANCE_DIFFICULTY.all]) do
    --         tooltip:AddLine(v.zone, v.dropsFrom, k)
    --     end
    -- end
    -- tooltip:AddSeparator(5, 0, 0, 0, 0)
    -- if next(MOUNT_SECTIONS[INSTANCE_TYPE.dungeon][INSTANCE_DIFFICULTY.heroic]) ~= nil then
    --     tooltip:AddHeader("Dungeon (Heroic)", "Boss", "Mount")
    --     for k,v in pairs(MOUNT_SECTIONS[INSTANCE_TYPE.dungeon][INSTANCE_DIFFICULTY.heroic]) do
    --         tooltip:AddLine(v.zone, v.dropsFrom, k)
    --     end
    -- end
    -- tooltip:AddSeparator(5, 0, 0, 0, 0)
    -- if next(MOUNT_SECTIONS[INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.all]) ~= nil then
    --     tooltip:AddHeader("Raid (All)", "Boss", "Mount")
    --     for k,v in pairs(MOUNT_SECTIONS[INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.all]) do
    --         tooltip:AddLine(v.zone, v.dropsFrom, k)
    --     end
    -- end
    -- tooltip:AddSeparator(5, 0, 0, 0, 0)
    -- if next(MOUNT_SECTIONS[INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.heroic]) ~= nil then
    --     tooltip:AddHeader("Raid (Heroic)", "Boss", "Mount")
    --     for k,v in pairs(MOUNT_SECTIONS[INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.heroic]) do
    --         tooltip:AddLine(v.zone, v.dropsFrom, k)
    --     end
    -- end
    -- tooltip:AddSeparator(5, 0, 0, 0, 0)
    -- if next(MOUNT_SECTIONS[INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.mythic]) ~= nil then
    --     tooltip:AddHeader("Raid (Mythic)", "Boss", "Mount")
    --     for k,v in pairs(MOUNT_SECTIONS[INSTANCE_TYPE.raid][INSTANCE_DIFFICULTY.mythic]) do
    --         tooltip:AddLine(v.zone, v.dropsFrom, k)
    --     end
    -- end
    -- tooltip:AddSeparator(5, 0, 0, 0, 0)
    -- if next(MOUNT_SECTIONS[INSTANCE_TYPE.world]) ~= nil then
    --     tooltip:AddHeader("World", "Boss", "Mount")
    --     for k,v in pairs(MOUNT_SECTIONS[INSTANCE_TYPE.world]) do
    --         tooltip:AddLine(v.zone, v.dropsFrom, k)
    --     end
    -- end




    -- Use smart anchoring code to anchor the tooltip to our frame
    tooltip:SmartAnchorTo(frame)

    -- Show it, et voilà !
    tooltip:Show()
end

function countTable(t)
    local count = 0
    for k,v in pairs(t) do
        count = count + 1
    end
    return count
end

function IMCAddon:IconOnLeave(frame)
    -- Release the tooltip
    LibQTip:Release(self.tooltip)
end

function IMCAddon:ToggleMinimapIcon()
    self.db.profile.minimap.hide = not self.db.profile.minimap.hide
    if self.db.profile.minimap.hide then
        LDBIcon:Hide(addonShortName)
    else
        LDBIcon:Show(addonShortName)
    end
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
        local instanceName, _, _, _, locked, _, _, _, _, _, maxBosses = GetSavedInstanceInfo(i)
        if ZONES[instanceName] then
            ZONES[instanceName].saved = locked
            for bossIndex = 1, maxBosses do
                local name, _, isKilled = GetSavedInstanceEncounterInfo(i, bossIndex)
                ZONES[instanceName].killedBosses[name] = isKilled
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