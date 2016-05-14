local addonName, vars = ...
local core = vars.core
local addon = vars
vars.config = core:NewModule(addonName.."Config")
local module = vars.config

local Config = LibStub("AceConfig-3.0")

local db
local firstoptiongroup, lastoptiongroup

function module:table_clone(t)
    if not t then return nil end
    local r = {}
    for k,v in pairs(t) do
        local nk,nv = k,v
        if type(k) == "table" then
            nk = module:table_clone(k)
        end
        if type(v) == "table" then
            nv = module:table_clone(v)
        end
        r[nk] = nv
    end
    return r
end


function module:OnInitialize()
    local ACD = LibStub("AceConfigDialog-3.0")
    db = vars.db
    db.Config = db.Config and db.Config or vars.defaultDB.Config
    db.Config.General = db.Config.General and db.Config.General or vars.defaultDB.Config.General
    -- db.Config.Toons = db.Config.Toons and db.Config.Toons or vars.defaultDB.Config.Toons

    module:BuildOptions()
    Config:RegisterOptionsTable(addonName, core.options, { "mh", "mounthunter" })

    local general = ACD:AddToBlizOptions(addonName, nil)
    firstoptiongroup = general
    general.default = function()
       -- addon.debug("RESET: General")
       db.Config.General = module:table_clone(vars.defaultDB.Config.General)
       db.MinimapIcon = module:table_clone(vars.defaultDB.MinimapIcon)
       -- module:ReopenConfigDisplay(fgen)
    end
end

function module:BuildOptions()
    local opts = {
        type = "group",
        name = addonName,
        handler = MountHunter,
        args = {
            General = {
                order = 1,
                type = "group",
                name = "Display settings",
                get = function(info)
                        return db.Config.General[info[#info]]
                end,
                set = function(info, value)
                        -- addon.debug(info[#info].." set to: "..tostring(value))
                        db.Config.General[info[#info]] = value
                        addon:ClearTooltipCache()
                end,
                args = {
                    GeneralHeader = {
                        order = 2,
                        type = "header",
                        name = "General settings",
                    },
                    MinimapIcon = {
                        type = "toggle",
                        name = "Show minimap button",
                        desc = "Show the MountHunter minimap button",
                        order = 2.1,
                        hidden = function() return not vars.icon end,
                        get = function(info) return not db.MinimapIcon.hide end,
                        set = function(info, value)
                            db.MinimapIcon.hide = not value
                            vars.icon:Refresh(addonName)
                        end,
                    },
                    -- ShowHints = {
                    --     type = "toggle",
                    --     name = "Show tooltip hints",
                    --     desc = "Show usage hints at bottom of tooltip",
                    --     order = 2.2,
                    -- },

                    CharactersHeader = {
                        order = 3,
                        type = "header",
                        name = "Character settings",
                    },
                    ShowServer = {
                        type = "toggle",
                        name = "Show server name",
                        desc = "Show character and server name in column header",
                        order = 3.1,
                    },
                    SelfFirst = {
                        type = "toggle",
                        name = "Show self first",
                        desc = "Show current character first",
                        order = 3.2,
                        set = function(info, value)
                                db.Config.General.SelfFirst = value
                                addon.alphatoonlist = nil
                                addon:ClearTooltipCache()
                            end,
                    },
                    SelfAlways = {
                        type = "toggle",
                        name = "Show self always",
                        desc = "Always show current character (Character Filter settings will take precedence)",
                        order = 3.3,
                        set = function(info, value)
                                db.Config.General.SelfAlways = value
                                addon.alphatoonlist = nil
                                addon:ClearTooltipCache()
                            end,
                    },
                    SelfOnly = {
                        type = "toggle",
                        name = "Show only self",
                        desc = "Only show current character (Character Filter settings will take precedence)",
                        order = 3.31,
                        set = function(info, value)
                                db.Config.General.SelfOnly = value
                                addon.alphatoonlist = nil
                                addon:ClearTooltipCache()
                            end,
                    },
                    HideRowWhenDone = {
                        type = "toggle",
                        name = "Hide row when done",
                        desc = "Hide a row when all characters have completed the instance",
                        order = 3.4,
                        set = function(info, value)
                                db.Config.General.HideRowWhenDone = value
                                addon:ClearTooltipCache()
                            end,
                    },
                    HideColumnWhenDone = {
                        type = "toggle",
                        name = "Hide column when done",
                        desc = "Hide a column when that character has completed all instances",
                        order = 3.5,
                        set = function(info, value)
                                db.Config.General.HideColumnWhenDone = value
                                addon:ClearTooltipCache()
                            end,
                    },
                },
            },
            LevelFilter = {
                order = 2,
                type = "group",
                name = "Level Filters",
                get = function(info)
                        return db.Config.LevelFilter[info[#info]]
                end,
                set = function(info, value)
                        -- addon.debug(info[#info].." set to: "..tostring(value))
                        db.Config.LevelFilter[info[#info]] = value
                        addon:ClearTooltipCache()
                end,
                args = {
                    ExpLvlHeader = {
                        order = 2,
                        type = "header",
                        name = "Expansion Level Filter",
                    },
                    ExpLvlDesc = {
                        order = 2.1,
                        type = "description",
                        name = "The below settings control the minimum level a character must have before being included for a specific expansion's dungeon/raid lockouts in the tooltip",
                    },
                    ClassicDungMinLevel = {
                        order = 2.21,
                        type = "range",
                        name = "Classic Dungeons",
                        desc = "Level a character must be to be included in the tooltip for a Classic Dungeon",
                        min = 1,
                        max = 100,
                        bigStep = 1,
                    },
                    ClassicRaidMinLevel = {
                        order = 2.22,
                        type = "range",
                        name = "Classic Raids",
                        desc = "Level a character must be to be included in the tooltip for a Classic Raid",
                        min = 1,
                        max = 100,
                        bigStep = 1,
                    },
                    BCDungMinLevel = {
                        order = 2.31,
                        type = "range",
                        name = "BC Dungeons",
                        desc = "Level a character must be to be included in the tooltip for a Burning Crusade Dungeon",
                        min = 1,
                        max = 100,
                        bigStep = 1,
                    },
                    BCRaidMinLevel = {
                        order = 2.32,
                        type = "range",
                        name = "BC Raids",
                        desc = "Level a character must be to be included in the tooltip for a Burning Crusade Raid",
                        min = 1,
                        max = 100,
                        bigStep = 1,
                    },
                    WrathDungMinLevel = {
                        order = 2.41,
                        type = "range",
                        name = "Wrath Dungeons",
                        desc = "Level a character must be to be included in the tooltip for a Wrath of the Lich King Dungeon",
                        min = 1,
                        max = 100,
                        bigStep = 1,
                    },
                    WrathRaidMinLevel = {
                        order = 2.42,
                        type = "range",
                        name = "Wrath Raids",
                        desc = "Level a character must be to be included in the tooltip for a Wrath of the Lich King Raid",
                        min = 1,
                        max = 100,
                        bigStep = 1,
                    },
                    CataDungMinLevel = {
                        order = 2.51,
                        type = "range",
                        name = "Cata Dungeons",
                        desc = "Level a character must be to be included in the tooltip for a Cataclysm Dungeon",
                        min = 1,
                        max = 100,
                        bigStep = 1,
                    },
                    CataRaidMinLevel = {
                        order = 2.52,
                        type = "range",
                        name = "Cata Raids",
                        desc = "Level a character must be to be included in the tooltip for a Cataclysm Raid",
                        min = 1,
                        max = 100,
                        bigStep = 1,
                    },
                    MopRaidMinLevel = {
                        order = 2.61,
                        type = "range",
                        name = "MoP Raids",
                        desc = "Level a character must be to be included in the tooltip for a Mists of Pandaria Raid",
                        min = 1,
                        max = 100,
                        bigStep = 1,
                    },
                    MopWorldMinLevel = {
                        order = 2.62,
                        type = "range",
                        name = "MoP World",
                        desc = "Level a character must be to be included in the tooltip for a Mists of Pandaria World boss",
                        min = 1,
                        max = 100,
                        bigStep = 1,
                    },
                    -- WodRaidMinLevel = {
                    --     order = 2.71,
                    --     type = "range",
                    --     name = "Wod Raids",
                    --     desc = "Level a character must be to be included in the tooltip for a Warlords of Draenor Raid",
                    --     min = 1,
                    --     max = 100,
                    --     bigStep = 1,
                    -- },
                    WodWorldMinLevel = {
                        order = 2.72,
                        type = "range",
                        name = "WoD World",
                        desc = "Level a character must be to be included in the tooltip for a Warlords of Draenor World boss",
                        min = 1,
                        max = 100,
                        bigStep = 1,
                    },
                },
            },
            ToonFilter = {
                order = 3,
                type = "group",
                name = "Character Filter",
                -- get = function(info)
                --         return db.Config.ToonFilter[info[#info]]
                -- end,
                -- set = function(info, value)
                --         -- addon.debug(info[#info].." set to: "..tostring(value))
                --         db.Config.ToonFilter[info[#info]] = value
                --         addon:ClearTooltipCache()
                -- end,
                args = {
                    ToonFilterHeader = {
                        order = 3,
                        type = "header",
                        name = "Character Filter",
                    },
                    ToonFilterDesc = {
                        order = 3.1,
                        type = "description",
                        name = "The below settings control which characters are ignored when displaying the tooltip. A checked box indicates that the character will not show up in the tooltip. This settings overrides 'Show Self Always'.",
                    },
                },
            },
        },
    }


    -- Add toon filters
    local curOrder = 3.2
    local toonNum = 0
    for toonName,toon in pairs(db.Toons) do
        curOrder = curOrder + 0.01
        local configSection = {
            type = "toggle",
            name = addon:ClassColorize(toon.class, toonName),
            desc = "Ignore "..toonName.." when showing tooltip",
            order = curOrder,
            get = function(info) return db.Toons[toonName].ignore end,
            set = function(info, value)
                db.Toons[toonName].ignore = value
                addon:ClearTooltipCache()
            end,
        }

        toonNum = toonNum + 1
        opts.args.ToonFilter.args["Toon"..tostring(toonNum)] = configSection

    end





    core.options = opts
end

function module:ShowConfig()
    if InterfaceOptionsFrame:IsShown() then
        InterfaceOptionsFrame:Hide()
    else
        -- twice to account for bad blizz ui decisions
        InterfaceOptionsFrame_OpenToCategory(firstoptiongroup)
        InterfaceOptionsFrame_OpenToCategory(firstoptiongroup)
    end
end