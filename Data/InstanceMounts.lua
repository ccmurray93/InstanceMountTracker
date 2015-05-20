local addonName, vars = ...
vars.data = {}

vars.data.INSTANCE_TYPE = {
    raid = "Raid",
    dungeon = "Dungeon",
    world = "World"
}

vars.data.INSTANCE_DIFFICULTY = {
    all = "All",
    normal = "Normal",
    heroic = "Heroic",
    mythic = "Mythic",
    lfr = "Looking For Raid",
    cm = "Challenge Mode",
}

vars.data.INSTANCE_SIZE = {
    all = "All",
    ten = "10m",
    twentyFive = "25m"
}

vars.data.EXPANSION = {
    classic = "Classic",
    bc = "Burning Crusade",
    wrath = "Wrath of the Lich King",
    cata = "Cataclysm",
    mop = "Mists of Pandaria",
    wod = "Warlords of Draenor",
}

vars.data.INSTANCE_DIFFICULTY_MAP = {
    vars.data.INSTANCE_DIFFICULTY.normal, --  1 | "Normal"
    vars.data.INSTANCE_DIFFICULTY.heroic, --  2 | "Heroic"
    vars.data.INSTANCE_DIFFICULTY.normal, --  3 | "10 Player"
    vars.data.INSTANCE_DIFFICULTY.normal, --  4 | "25 Player"
    vars.data.INSTANCE_DIFFICULTY.heroic, --  5 | "10 Player (Heroic)"
    vars.data.INSTANCE_DIFFICULTY.heroic, --  6 | "25 Player (Heroic)"
    vars.data.INSTANCE_DIFFICULTY.lfr,    --  7 | "Looking For Raid"
    vars.data.INSTANCE_DIFFICULTY.cm,     --  8 | "Challenge Mode"
    vars.data.INSTANCE_DIFFICULTY.normal, --  9 | "40 Player"
    nil,                        -- 10 | nil
    vars.data.INSTANCE_DIFFICULTY.heroic, -- 11 | "Heroic Scenario"
    vars.data.INSTANCE_DIFFICULTY.normal, -- 12 | "Normal Scenario"
    nil,                        -- 13 | nil
    vars.data.INSTANCE_DIFFICULTY.normal, -- 14 | "Normal"
    vars.data.INSTANCE_DIFFICULTY.heroic, -- 15 | "Heroic"
    vars.data.INSTANCE_DIFFICULTY.mythic, -- 16 | "Mythic"
    vars.data.INSTANCE_DIFFICULTY.lfr,    -- 17 | "Looking For Raid"
    nil,                        -- 18 | "Event"
    nil,                        -- 19 | "Event"
    nil,                        -- 20 | "Event Scenario"
    nil,                        -- 21 | nil
    nil,                        -- 22 | nil
    vars.data.INSTANCE_DIFFICULTY.mythic, -- 23 | "Mythic" (Dungeons)
}

vars.data.INSTANCE_MOUNTS = {
    -- Vanilla
    ["Rivendare's Deathcharger"] = {
        zone =               "Stratholme",
        dropsFrom =          "Lord Aurius Rivendare",
        instanceType =       vars.data.INSTANCE_TYPE.dungeon,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.classic
    },

    ["Blue Qiraji Battle Tank"] = {
        zone =               "Temple of Ahn'Qiraj",
        dropsFrom =          "",
        note =               "Trash",
        saveCheck =          "C'Thun",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.classic
    },

    ["Green Qiraji Battle Tank"] = {
        zone =               "Temple of Ahn'Qiraj",
        dropsFrom =          "",
        note =               "Trash",
        saveCheck =          "C'Thun",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.classic
    },

    ["Yellow Qiraji Battle Tank"] = {
        zone =               "Temple of Ahn'Qiraj",
        dropsFrom =          "",
        note =               "Trash",
        saveCheck =          "C'Thun",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.classic
    },

    ["Red Qiraji Battle Tank"] = {
        zone =               "Temple of Ahn'Qiraj",
        dropsFrom =          "",
        note =               "Trash",
        saveCheck =          "C'Thun",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.classic
    },


    -- Burning Crusade
    ["Raven Lord"] = {
        zone =               "Sethekk Halls",
        dropsFrom =          "Anzu",
        instanceType =       vars.data.INSTANCE_TYPE.dungeon,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.heroic,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.bc
    },

    ["Swift White Hawkstrider"] = {
        zone =               "Magisters' Terrace",
        dropsFrom =          "Kael'thas Sunstrider",
        instanceType =       vars.data.INSTANCE_TYPE.dungeon,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.heroic,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.bc
    },

    ["Fiery Warhorse"] = {
        zone =               "Karazhan",
        dropsFrom =          "Attumen the Huntsman",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.bc
    },

    ["Ashes of Al'ar"] = {
        zone =               "Tempest Keep",
        dropsFrom =          "Kael'thas Sunstrider",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.bc
    },


    -- Wrath of the Lich King
    ["Blue Proto-Drake"] = {
        zone =               "Utgarde Pinnacle",
        dropsFrom =          "Skadi the Ruthless",
        instanceType =       vars.data.INSTANCE_TYPE.dungeon,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.heroic,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.wrath
    },

    ["Bronze Drake"] = {
        zone =               "The Culling of Stratholme",
        dropsFrom =          "Infinite Corruptor",
        instanceType =       vars.data.INSTANCE_TYPE.dungeon,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.heroic,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.wrath
    },

    ["Grand Black War Mammoth"] = {
        zone =               "Vault of Archavon",
        dropsFrom =          {
            "Archavon the Stone Watcher",
            "Emalon the Storm Watcher",
            "Koralon the Flame Watcher",
            "Toravon the Ice Watcher"
        },
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.wrath
    },

    ["Azure Drake"] = {
        zone =               "The Eye of Eternity",
        dropsFrom =          "Malygos",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.wrath
    },

    ["Blue Drake"] = {
        zone =               "The Eye of Eternity",
        dropsFrom =          "Malygos",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.wrath
    },

    ["Black Drake"] = {
        zone =               "The Obsidian Sanctum",
        dropsFrom =          "Sartharion",
        note =               "3 Drakes",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.ten,
        expansion =          vars.data.EXPANSION.wrath
    },

    ["Twilight Drake"] = {
        zone =               "The Obsidian Sanctum",
        dropsFrom =          "Sartharion",
        note =               "3 Drakes",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.twentyFive,
        expansion =          vars.data.EXPANSION.wrath
    },

    ["Onyxian Drake"] = {
        zone =               "Onyxia's Lair",
        dropsFrom =          "Onyxia",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.wrath
    },

    ["Mimiron's Head"] = {
        zone =               "Ulduar",
        dropsFrom =          "Yogg-Saron",
        note =               "No Watchers",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.twentyFive,
        expansion =          vars.data.EXPANSION.wrath
    },

    ["Invincible"] = {
        zone =               "Icecrown Citadel",
        dropsFrom =          "The Lich King",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.heroic,
        instanceSize =       vars.data.INSTANCE_SIZE.twentyFive,
        expansion =          vars.data.EXPANSION.wrath
    },


    -- Cataclysm
    ["Drake of the North Wind"] = {
        zone =               "The Vortex Pinnacle",
        dropsFrom =          "Altairus",
        instanceType =       vars.data.INSTANCE_TYPE.dungeon,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.cata
    },

    ["Vitreous Stone Drake"] = {
        zone =               "The Stonecore",
        dropsFrom =          "Slabhide",
        instanceType =       vars.data.INSTANCE_TYPE.dungeon,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.cata
    },

    ["Swift Zulian Panther"] = {
        zone =               "Zul'Gurub",
        dropsFrom =          "High Priestess Kilnara",
        instanceType =       vars.data.INSTANCE_TYPE.dungeon,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.heroic,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.cata
    },

    ["Armored Razzashi Raptor"] = {
        zone =               "Zul'Gurub",
        dropsFrom =          "Bloodlord Mandokir",
        instanceType =       vars.data.INSTANCE_TYPE.dungeon,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.heroic,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.cata
    },

    ["Amani Battle Bear"] = {
        zone =               "Zul'Aman",
        dropsFrom =          "",
        note =               "Timed Reward",
        instanceType =       vars.data.INSTANCE_TYPE.dungeon,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.heroic,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.cata
    },

    ["Drake of the South Wind"] = {
        zone =               "Throne of the Four Winds",
        dropsFrom =          "Al'Akir",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.cata
    },

    ["Flametalon of Alysrazor"] = {
        zone =               "Firelands",
        dropsFrom =          "Alysrazor",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.cata
    },

    ["Pureblood Fire Hawk"] = {
        zone =               "Firelands",
        dropsFrom =          "Ragnaros",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.cata
    },

    ["Experiment 12-B"] = {
        zone =               "Dragon Soul",
        dropsFrom =          "Ultraxion",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.cata
    },

    ["Blazing Drake"] = {
        zone =               "Dragon Soul",
        dropsFrom =          "Deathwing",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.cata
    },

    ["Life-Binder's Handmaiden"] = {
        zone =               "Dragon Soul",
        dropsFrom =          "Deathwing",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.heroic,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.cata
    },


    -- Mists of Pandaria
    -- ["Heavenly Onyx Cloud Serpent"] = {
    --     zone =               "Kun-Lai Summit",
    --     dropsFrom =          "Sha of Anger",
    --     instanceType =       vars.data.INSTANCE_TYPE.world,
    --     instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
    --     instanceSize =       vars.data.INSTANCE_SIZE.all,
    --     expansion =          vars.data.EXPANSION.mop
    -- },

    -- ["Son of Galleon"] = {
    --     zone =               "Valley of the Four Winds",
    --     dropsFrom =          "Galleon",
    --     instanceType =       vars.data.INSTANCE_TYPE.world,
    --     instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
    --     instanceSize =       vars.data.INSTANCE_SIZE.all,
    --     expansion =          vars.data.EXPANSION.mop
    -- },

    -- ["Thundering Cobalt Cloud Serpent"] = {
    --     zone =               "Isle of Thunder",
    --     dropsFrom =          "Nalak",
    --     instanceType =       vars.data.INSTANCE_TYPE.world,
    --     instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
    --     instanceSize =       vars.data.INSTANCE_SIZE.all,
    --     expansion =          vars.data.EXPANSION.mop
    -- },

    -- ["Cobalt Primordial Direhorn"] = {
    --     zone =               "Isle of Giants",
    --     dropsFrom =          "Oondasta",
    --     instanceType =       vars.data.INSTANCE_TYPE.world,
    --     instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
    --     instanceSize =       vars.data.INSTANCE_SIZE.all,
    --     expansion =          vars.data.EXPANSION.mop
    -- },

    ["Astral Cloud Serpent"] = {
        zone =               "Mogu'shan Vaults",
        dropsFrom =          "Elegon",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.mop
    },

    ["Spawn of Horridon"] = {
        zone =               "Throne of Thunder",
        dropsFrom =          "Horridon",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.mop
    },

    ["Clutch of Ji-Kun"] = {
        zone =               "Throne of Thunder",
        dropsFrom =          "Ji-Kun",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.mop
    },

    ["Kor'kron Juggernaut"] = {
        zone =               "Siege of Orgrimmar",
        dropsFrom =          "Garrosh Hellscream",
        instanceType =       vars.data.INSTANCE_TYPE.raid,
        instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.mythic,
        instanceSize =       vars.data.INSTANCE_SIZE.all,
        expansion =          vars.data.EXPANSION.mop
    }

    -- Warlords of Draenor
    -- ["Solar Spirehawk"] = {
    --     zone =               "Spires of Arak",
    --     dropsFrom =          "Rukhmar",
    --     instanceType =       vars.data.INSTANCE_TYPE.world,
    --     instanceDifficulty = vars.data.INSTANCE_DIFFICULTY.all,
    --     instanceSize =       vars.data.INSTANCE_SIZE.all,
    --     expansion =          vars.data.EXPANSION.wod
    -- }
}