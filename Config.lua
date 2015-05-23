local addonName, vars = ...
local core = vars.core
local addon = vars
vars.config = core:NewModule(addonName.."Config")
local module = vars.config

local Config = LibStub("AceConfig-3.0")

local db


function module:OnInitialize()
    db = vars.db
    module:BuildOptions()
    Config:RegisterOptionsTable(addonName, core.options, { "imf", "instancemountfarmer" })
end

function module:BuildOptions()
    local opts = {
        type = "group",
        name = addonName,
        handler = InstanceMountFarmer,
        args = {


        },
    }

    core.options = opts
end