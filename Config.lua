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

    module:BuildOptions()
    Config:RegisterOptionsTable(addonName, core.options, { "imf", "instancemountfarmer" })

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
        handler = InstanceMountFarmer,
        args = {
            General = {
                order = 1,
                type = "group",
                name = "General settings",
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
                        desc = "Show the InstanceMountFarmer minimap button",
                        order = 2.1,
                        hidden = function() return not vars.icon end,
                        get = function(info) return not db.MinimapIcon.hide end,
                        set = function(info, value)
                            db.MinimapIcon.hide = not value
                            vars.icon:Refresh(addonName)
                        end,
                    },
                    ShowHints = {
                        type = "toggle",
                        name = "Show tooltip hints",
                        desc = "Show usage hints at bottom of tooltip",
                        order = 2.2,
                    },

                    CharactersHeader = {
                        order = 3,
                        type = "header",
                        name = "Characters",
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
                            end,
                    },
                    SelfAlways = {
                        type = "toggle",
                        name = "Show self always",
                        desc = "Always show current character",
                        order = 3.3,
                        set = function(info, value)
                                db.Config.General.SelfAlways = value
                                addon.alphatoonlist = nil
                            end,
                    },
                },
            },
        },
    }

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