-- constants
STAR_EXIT = 0x10                 -- player can leave when grabbing this star
STAR_IGNORE_STARMODE = 0x20      -- star is not counted in star mode
STAR_ACT_SPECIFIC = 0x40         -- star can only be gotten in this act
STAR_NOT_ACT_1 = 0x80            -- star cannot be gotten in act 1
STAR_APPLY_NO_ACTS = 0x100       -- applies even if disable acts is on (like in OMM)
STAR_NOT_BEFORE_THIS_ACT = 0x200 -- star cannot be gotten before this act
STAR_REPLICA = 0x400             -- replica flag (uses replica_start or replica_func)
STAR_MULTIPLE_AREAS = 0x800      -- only needed if your star can be obtained in only certain areas
STAR_AREA_MASK = 0xF             -- 1-15

local romhack_data = {           -- supported rom hack data

  ["vanilla"] = {
    name = "Super Mario 64",
    default_stars = 70, -- stars in a glitchless run
    max_stars = 120,    -- maximum stars collectible
    ommColorStar = true,
    requirements = {
      [LEVEL_WF] = 1,
      [LEVEL_PSS] = 1,
      [LEVEL_CCM] = 3,
      [LEVEL_JRB] = 3,
      [LEVEL_BITDW] = 8,
      [LEVEL_DDD] = 30,
      [LEVEL_BITFS] = 31,
      [LEVEL_TTC] = 50,
      [LEVEL_RR] = 50,
      [LEVEL_WMOTR] = 50,
      [LEVEL_BITS] = 70,
      [LEVEL_BOWSER_3] = 121, -- NOTE: This is overridden by the default star run
    },
    ddd = true,               -- pretty much only relevant for vanilla
    heartReplace = true,      -- replaces all hearts with 1ups

    -- all one table now!
    star_data = {
      [COURSE_BOB] = { 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8, 8 },
      [COURSE_WF] = { 8 | STAR_ACT_SPECIFIC, 8 | STAR_NOT_ACT_1, 8, 8, 8 | STAR_NOT_ACT_1, 8 | STAR_ACT_SPECIFIC, 8 },
      [COURSE_JRB] = { 8 | STAR_ACT_SPECIFIC, 1 | STAR_ACT_SPECIFIC, 1, 1, 1, 1 | STAR_NOT_ACT_1, 1 },
      [COURSE_CCM] = { 8 | STAR_ACT_SPECIFIC, 8, 8 | STAR_NOT_ACT_1, 8, 8 | STAR_ACT_SPECIFIC, 8, 8 },
      [COURSE_BBH] = { 8 | STAR_ACT_SPECIFIC, 8 | STAR_NOT_ACT_1, 8, 8, 8, 8, 8 },
      [COURSE_LLL] = { 1, 1, 1, 1, 8, 8, 1 },
      [COURSE_SSL] = { 1 | STAR_ACT_SPECIFIC, 1, 8, 8 | STAR_EXIT, 1, 8, 1 },
      [COURSE_DDD] = { 8, 8, 8, 8, 8 | STAR_ACT_SPECIFIC, 8 | STAR_EXIT, 8 },
      [COURSE_WDW] = { 1, 1, 1, 1, 8, 8, 1 },
      [COURSE_TTM] = { 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8, 8 },
      [COURSE_THI] = { 8, 8, 8 | STAR_ACT_SPECIFIC, 8, 8, 8 | STAR_EXIT, 8 },
      [COURSE_TOTWC] = { 8 | STAR_IGNORE_STARMODE },
      [COURSE_VCUTM] = { 8 | STAR_IGNORE_STARMODE },
      [COURSE_PSS] = { 8 | STAR_EXIT | STAR_APPLY_NO_ACTS, 8 },
      [COURSE_WMOTR] = { 8 | STAR_IGNORE_STARMODE | STAR_APPLY_NO_ACTS }
    },

    -- exclude some stars in MiniHunt
    mini_exclude = {
      [103] = 1, -- In The Deep Freeze (too easy)
      [124] = 1, -- Mysterious Mountainside (too easy)
      [84] = 1,  -- Stand Tall On Four Pillars (too annoying)
      [45] = 1,  -- Snowman's Lost His Head (inconsistent)
      [12] = 1, -- Footrace With Koopa The Quick (takes FOREVER)
      [133] = 1, -- Rematch With Koopa The Quick (takes FOREVER)
      [56] = 1, -- Eye-To-Eye In The Secret Room (one-sided)
      [42] = 1, -- L'il Penguin Lost (basically impossible tbh)
    },

    -- this is a function run every frame for all players. This one in particular ttc speed in minihunt
    special_run = function(m, gotStar)
      if gGlobalSyncTable.mhMode == 2 and gGlobalSyncTable.gameLevel == LEVEL_TTC then
        if gGlobalSyncTable.getStar == 6 then
          set_ttc_speed_setting(3)
        else
          set_ttc_speed_setting(1)
        end
      end
    end,

    -- custom star names!
    starNames = {
      [161] = "Red Coins Of The Dark",
      [171] = "8 Flaming Coins",
      [181] = "Skybound Red Coins",
      [191] = "The Slide's Secret",
      [192] = "Speedy Sliding",
      [201] = "Coins In The Cavern",
      [211] = "Flight For 8 Red Coins",
      [221] = "Red Coin Acrobatics",
      [231] = "The Rainbow's Red Coins",
      [241] = "Swimming With The Coins",
    },

    -- information for the Game Area setting
    gameAreaData = {
      { -- default
        entryLevel = LEVEL_CASTLE_GROUNDS,
        entryNode = 0, -- uses default warp
        exitCastleLevel = LEVEL_CASTLE,
        exitCastleWarpNode = 0x1F,
      },
      {
        name = "Main Floor",
        entryLevel = LEVEL_CASTLE_GROUNDS,
        entryNode = 0, -- uses default warp
        exitCastleLevel = LEVEL_CASTLE,
        exitCastleWarpNode = 0x1F,
        default_stars = 15,
        max_stars = 42,
        bannedAreas = {
          [62] = 1, -- Upper Floor
          [63] = 1, -- Basement
        },
        doorCost = {
          [8] = 15,
        },
        requirements = {
          [LEVEL_COTMC] = 3,
          [LEVEL_BITDW] = 15,
          [LEVEL_BOWSER_1] = 121,
        },
        runner_victory = function(m)
          return (save_file_get_flags() & (SAVE_FLAG_HAVE_KEY_1 | SAVE_FLAG_UNLOCKED_BASEMENT_DOOR)) ~= 0
        end,
        extraObject = {
          [61] = { -- Main Floor
            -- formatted as oid, model, x, y, z, warp level, warp area
            {id_bhvWarp, E_MODEL_NONE, 2000, 819, -1700, 0, LEVEL_COTMC, 1},
          },
          [261] = { -- Courtyard
            {id_bhvWaterLevelPillar, E_MODEL_CASTLE_WATER_LEVEL_PILLAR, 3300, 400, -2800},
            {id_bhvWaterLevelPillar, E_MODEL_CASTLE_WATER_LEVEL_PILLAR, -3300, 400, -2800},
          },
        },
        warpNodeOverride = {
          [63] = { -- warps from COTMC
            [0x34] = {LEVEL_CASTLE, 1, 0x27}, -- star
            [0x66] = {LEVEL_CASTLE, 1, 0x28}, -- death
          },
        },
      },
      {
        name = "Basement",
        entryLevel = LEVEL_CASTLE,
        entryNode = 0, -- uses default warp
        entryArea = 3,
        exitCastleLevel = LEVEL_CASTLE,
        exitCastleArea = 3,
        exitCastleWarpNode = 0,
        ddd = true,
        default_stars = 16,
        max_stars = 34,
        bannedAreas = {
          [61] = 1, -- Main Floor
          [62] = 1, -- Upper Floor
        },
        doorCost = {
          [30] = 15,
        },
        requirements = {
          [LEVEL_DDD] = 15,
          [LEVEL_BITFS] = 16,
          [LEVEL_BOWSER_2] = 121,
        },
        runner_victory = function(m)
          return (save_file_get_flags() & (SAVE_FLAG_HAVE_KEY_2 | SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR)) ~= 0
        end,
        extraObject = {
          [63] = { -- Basement
            -- formatted as oid, model, x, y, z, warp level, warp area
            {id_bhvMHWingCapWarp, E_MODEL_TOTWC_ENTRANCE, -765, -1279, 2386, 0, LEVEL_TOTWC, 1},
          },
          [161] = { -- Grounds
            -- pipe to basement (in case someone gets sent to grounds without moat drained)
            {id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, 0, 803, -2800, 0, LEVEL_CASTLE, 2},
          },
        },
        warpNodeOverride = {
          [61] = { -- warps from TOTWC
            [0x26] = {LEVEL_CASTLE, 3, 0x0A}, -- star
            [0x23] = {LEVEL_CASTLE, 3, 0x0A}, -- death
            [0x20] = {LEVEL_CASTLE, 3, 0x0A}, -- flying OOB
          },
          [161] = { -- warps from COTMC + Castle Death
            [0x14] = {LEVEL_CASTLE, 3, 0x66}, -- falling in COTMC
            [0x03] = {LEVEL_CASTLE, 3, 0x0A}, -- castle death
          },
        },
      },
      {
        name = "Upstairs",
        entryLevel = LEVEL_CASTLE,
        entryNode = 1,
        entryArea = 2,
        exitCastleLevel = LEVEL_CASTLE,
        exitCastleArea = 2,
        exitCastleWarpNode = 1,
        default_stars = 25,
        max_stars = 49,
        bannedAreas = {
          [61] = 1, -- Main Floor
          [63] = 1, -- Basement
        },
        requirements = {
          [LEVEL_TTC] = 10,
          [LEVEL_RR] = 10,
          [LEVEL_WMOTR] = 10,
          [LEVEL_BITS] = 48,
        },
        doorCost = {
          [50] = 10,
        },
        extraObject = {
          [62] = { -- Upper Floor
            -- formatted as oid, model, x, y, z, warp level, warp area
            {id_bhvMHWingCapWarp, E_MODEL_TOTWC_ENTRANCE, 1660, 2765, 6630, 0, LEVEL_TOTWC, 1},
            {id_bhvWarpPipe, E_MODEL_NONE, 3550, 1408, 3447, 0, LEVEL_VCUTM, 1}, -- real pipe (invisible)
            {id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, 5113, 1408, 3447, 0, 0, 0}, -- pipe in mirror
          },
          [112] = { -- Wet-Dry World
            {id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, 1967, -2559, 2627, 0, LEVEL_COTMC, 1},
          },
          [161] = { -- Grounds
            -- pipe to upper floor (in case someone gets sent to grounds)
            {id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, 0, 803, -2800, 0, LEVEL_CASTLE, 3},
          },
        },
        warpNodeOverride = {
          [61] = { -- warps from TOTWC
            [0x26] = {LEVEL_CASTLE, 2, 0x38}, -- star
            [0x23] = {LEVEL_CASTLE, 2, 0x6D}, -- death
            [0x20] = {LEVEL_CASTLE, 2, 0x38}, -- flying OOB
          },
          [63] = { -- warps from COTMC
            [0x34] = {LEVEL_CASTLE, 2, 0x32}, -- star
            [0x66] = {LEVEL_CASTLE, 2, 0x64}, -- death
          },
          [161] = { -- warps from WMOTR, VCUTM, and COTMC (+ castle death)
            [0x0A] = {LEVEL_CASTLE, 2, 0x6D}, -- falling OOB in WMOTR (uses death warp instead)
            [0x08] = {LEVEL_CASTLE, 2, 0x36}, -- star in VCUTM
            [0x07] = {LEVEL_CASTLE, 2, 0x68}, -- death in VCUTM
            [0x06] = {LEVEL_CASTLE, 2, 0x68}, -- falling in VCUTM
            [0x14] = {LEVEL_CASTLE, 2, 0x64}, -- falling in COTMC
            [0x03] = {LEVEL_CASTLE, 2, 0x01}, -- castle death
          },
        },
      },
      {
        name = "Top Floor",
        entryLevel = LEVEL_CASTLE,
        entryNode = 53,
        entryArea = 2,
        exitCastleLevel = LEVEL_CASTLE,
        exitCastleArea = 2,
        exitCastleWarpNode = 53,
        default_stars = 8,
        max_stars = 17,
        bannedAreas = {
          [61] = 1, -- Main Floor
          [63] = 1, -- Basement
          [101] = 1, -- SL
          [111] = 1, -- WDW
          [361] = 1, -- TTM
          [131] = 1, -- THI (Huge)
          [132] = 1, -- THI (Tiny)
          [181] = 1, -- VCUTM
        },
        doorCost = {
          [70] = 16,
        },
        requirements = {
          [LEVEL_TTC] = 0,
          [LEVEL_RR] = 0,
          [LEVEL_WMOTR] = 0,
          [LEVEL_BITS] = 16,
        },
        extraObject = {
          [62] = { -- Upper Floor
            -- formatted as oid, model, x, y, z, warp level, warp area
            {id_bhvMHWingCapWarp, E_MODEL_TOTWC_ENTRANCE, 1660, 2765, 6630, 0, LEVEL_TOTWC, 1},
            {id_bhvPushableMetalBox, E_MODEL_METAL_BOX, -200, 2203, 4781, 0},
            {id_bhvPushableMetalBox, E_MODEL_METAL_BOX, -973, 1153, 2621, 0},
          },
          [161] = { -- Grounds
            -- pipe to upper floor (in case someone gets sent to grounds)
            {id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, 0, 803, -2800, 0, LEVEL_CASTLE, 3, 53},
          },
        },
        warpNodeOverride = {
          [61] = { -- warps from TOTWC
            [0x26] = {LEVEL_CASTLE, 2, 0x38}, -- star
            [0x23] = {LEVEL_CASTLE, 2, 0x6D}, -- death
            [0x20] = {LEVEL_CASTLE, 2, 0x38}, -- flying OOB
          },
          [161] = { -- warps from WMOTR (+ castle death)
            [0x0A] = {LEVEL_CASTLE, 2, 0x6D}, -- falling OOB in WMOTR (uses death warp instead)
            [0x03] = {LEVEL_CASTLE, 2, 0x67}, -- castle death
          },
        },
      },
    },

    minimap_data = {
      [91] = { "bob-map" },   -- BOB area 1
      [241] = { "wf-map" },   -- WF area 1
      [161] = { "cg-map" },   -- CG area 1
      [61] = { "ic-map" },    -- IC area 1
      [62] = { "ica-map" },   -- IC area 2
      [63] = { "icb-map" },   -- IC area 3
      [171] = { "fb-map" },   -- B1 area 1
      [301] = { "fbb-map" },  -- B1 area 2
      [191] = { "bfs-map" },  -- B2 area 1
      [331] = { "bfsb-map" }, -- B2 area 2
      [51] = { "ccm-map" },   -- CCM area 1
      [52] = { "ccms-map" },  -- CCM area 1
      [121] = { "jrb-map" },  -- JRB area 1
      [122] = { "jrbs-map" }, -- JRB area 2
      [271] = { "pss-map" },  -- PSS area 1
      [41] = { "bbh-map" },   -- BBH area 1
      [261] = { "cc-map" },   -- BBH area 1
      [71] = { "hmc-map" },   -- HMC area 1
      [221] = { "lll-map" },  -- LLL area 1
      [222] = { "lllv-map" }, -- LLL area 2
      [81] = { "ssl-map" },   -- SSL area 1
      [82] = { "sslp-map" },  -- SSL area 2
      [83] = { "sslie-map" }, -- SSL area 2
      [231] = { "ddd-map" },  -- SSL area 2
      [232] = { "ddds-map" }, -- SSL area 2
      [101] = { "sl-map" },   -- SL area 1
      [102] = { "sli-map" },  -- SL area 2
      [111] = { "wdw-map" },  -- WDW area 1
      [112] = { "wdwu-map" }, -- WDW area 2
      [361] = { "ttm-map" },  -- TTM area 1
      -- [362] = { "ttms-map" },    -- TTM area 2 (removed due to inaccuracy)
      -- [363] = { "ttms-map" },    -- TTM area 3 (removed due to inaccuracy)
      -- [364] = { "ttms-map" },    -- TTM area 4 (removed due to inaccuracy)
      [131] = { "thih-map" },  -- THI area 1
      [132] = { "thit-map" },  -- THI area 2
      [133] = { "thim-map" },  -- THI area 3
      [141] = { "ttc-map" },   -- TTC area 1
      [151] = { "rr-map" },    -- RR area 1
      [201] = { "tsa-map" },   -- SA area 1
      [281] = { "btw-map" },   -- MCL area 1
      [311] = { "otr-map" },   -- RC area 1
      [211] = { "bits-map" },  -- BITS area 1
      [341] = { "bitsb-map" }, -- bitsb area 1
      [181] = { "vcutm-map" }, -- vcutm area 1
      [291] = { "totwc-map" }, -- totwc area 1
    },

    runner_victory = function(m)
      return m.action == ACT_JUMBO_STAR_CUTSCENE
    end,
  },

  ["star-road"] = {
    name = "Star Road",
    default_stars = 80,
    max_stars = 130,
    ommColorStar = true,
    requirements = {
      [LEVEL_CCM] = 8,  -- Chuckya Harbor
      [LEVEL_BBH] = 8,  -- Gloomy Garden
      [LEVEL_BITDW] = 20,
      [LEVEL_DDD] = 30, -- Mad Musical Mess
      [LEVEL_BITFS] = 40,
      [LEVEL_BITS] = 80,
      [LEVEL_WMOTR] = 120, -- Hidden Palace Finale
    },
    heartReplace = true,   -- replaces all hearts with 1ups (doesn't affect the bubbles in the coral level, thankfully)
    lifeOverride = true,   -- prevent star road 0 life

    -- mostly defining replicas
    star_data = {
      [COURSE_NONE] = { 8, 8, 8, 8 },
      [COURSE_BOB] = { 8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8, 8, 8 },
      [COURSE_WF] = { 8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8, 8, 8 },
      [COURSE_JRB] = { 8, 8, 8, 8, 8, 8 | STAR_ACT_SPECIFIC, 8 },
      [COURSE_CCM] = { 8, 8, 8, 8, 8, 8 | STAR_IGNORE_STARMODE | STAR_EXIT | STAR_APPLY_NO_ACTS, 8 },                         -- don't get trapped in The Other Entrance
      [COURSE_BBH] = { 8 | STAR_ACT_SPECIFIC, 8, 8, 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8 }, -- wow, Gloomy Garden has a lot of act specifics
      [COURSE_HMC] = { 8, 8 | STAR_ACT_SPECIFIC, 8, 8 | STAR_ACT_SPECIFIC, 8, 8, 8 },
      [COURSE_LLL] = { 8, 8 | STAR_ACT_SPECIFIC, 8 | STAR_NOT_BEFORE_THIS_ACT, 8, 8, 8, 8 },
      -- I decided to flag 100 coins here because I don't think there's enough coins without getting up the tree
      [COURSE_SSL] = { 8 | STAR_ACT_SPECIFIC | STAR_IGNORE_STARMODE, 8 | STAR_NOT_ACT_1, 8, 8 | STAR_NOT_ACT_1, 8 | STAR_NOT_ACT_1, 8, 8 | STAR_NOT_ACT_1 },
      [COURSE_SL] = { 8, 8 | STAR_NOT_ACT_1, 8, 8, 8, 8, 8 },
      [COURSE_TTM] = { 8, 8 | STAR_NOT_ACT_1, 8 | STAR_NOT_ACT_1, 8 | STAR_NOT_ACT_1, 8, 8, 8 },
      [COURSE_TTC] = { 8, 8, 8, 8, 8, 8 | STAR_ACT_SPECIFIC, 8 },                                                         -- star 1 actually disappears in acts 5 and 6 (I could account for that but ehhh)
      [COURSE_WDW] = { 8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8, 8, 8 },
      [COURSE_THI] = { 8, 8 | STAR_ACT_SPECIFIC, 8, 8, 8 | STAR_NOT_BEFORE_THIS_ACT, 8 | STAR_ACT_SPECIFIC | STAR_EXIT, 8 },
      [COURSE_RR] = { 8, 8, 8 | STAR_IGNORE_STARMODE | STAR_APPLY_NO_ACTS, 8, 8, 8 | STAR_EXIT | STAR_APPLY_NO_ACTS, 8 }, -- don't get trapped in In The Cage
      [COURSE_BITDW] = { 8, 0, 0, 8 | STAR_REPLICA },
      [COURSE_BITFS] = { 8, 0, 0, 0, 8 | STAR_REPLICA },
      [COURSE_BITS] = { 8, 0, 0, 0, 0, 8 | STAR_REPLICA },
      [COURSE_PSS] = { 8, 8, 0, 0, 0, 8 | STAR_REPLICA },
      [COURSE_COTMC] = { 8, 0, 0, 0, 8 | STAR_REPLICA },
      [COURSE_TOTWC] = { 8, 0, 0, 0, 0, 8 | STAR_REPLICA },
      [COURSE_VCUTM] = { 8, 0, 0, 0, 0, 8 | STAR_REPLICA },
      [COURSE_WMOTR] = { 8, 0, 0, 0, 0, 8 | STAR_REPLICA },
      [COURSE_SA] = { 8, 8 | STAR_IGNORE_STARMODE | STAR_APPLY_NO_ACTS, 0, 0, 0, 8 | STAR_REPLICA }, -- can fail time challenge
      [COURSE_CAKE_END] = { 0, 8 },
    },

    -- exclude some stars in MiniHunt
    mini_exclude = {
      [46] = 1,  -- The Other Entrance
      [205] = 1, -- Replica for Creepy Cap Cave
    },

    special_run = function(m, gotStar)
      deleteStarRoadStuff(m)
      local np = gNetworkPlayers[0]
      -- prevent getting trapped in cage star
      if m.action == ACT_TELEPORT_FADE_IN and m.playerIndex == 0 and np.currLevelNum == LEVEL_CCM
          and m.pos.x < -3200 and m.pos.z < -4600 then
        local sMario = gPlayerSyncTable[0]
        sMario.allowLeave = true
      end
    end,

    -- custom star names!
    starNames = {
      [161] = "Across The Sinking Slabs",
      [164] = "Replica Of The Tall Logs",
      [171] = "Castle Detour",
      [175] = "Replica Of The Fire Statue",
      [181] = "Atop The Twisted Planet",
      [186] = "Replica Of The Flaming Spiral",
      [191] = "Climb With Koopa The Quick",
      [192] = "Red Coins 'Round Town",
      [196] = "Replica Of The Village Hermit",
      [201] = "Coins In The Cave",
      [205] = "Replica Of The Cave Entrance",
      [211] = "Windy Red Coin Search",
      [216] = "Replica Of The Flying Ship",
      [221] = "Hidden In The Light",
      [226] = "Replica Of The Cogs",
      [231] = "On Top Of The World",
      [236] = "Replica Of The Palace Ledge",
      [241] = "Slip Slidin' For Red Coins",
      [242] = "Sand Slide Speedrun",
      [246] = "Replica Of The Steel Beams",
      [252] = "Bowser's Power Star",
    },
    replica_start = 121, -- replicas are considered at this star count

    -- information for the Game Area setting (TODO: goals for other areas, access cap stages)
    gameAreaData = {
      { -- default
        entryLevel = LEVEL_CASTLE_GROUNDS,
        entryNode = 0, -- uses default warp
        exitCastleLevel = LEVEL_CASTLE_GROUNDS,
        exitCastleWarpNode = 128,

        extraObject = {
          [261] = {
            {id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, -989, 3925, -1365, 0, LEVEL_CASTLE, 1}, -- pipe over cannon to Star Haven
          },
          [61] = {
            {id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, 3400, 160, -2733, 0, LEVEL_CASTLE_COURTYARD, 1, 39}, -- Star Haven pipe to Star Leap Tower
          },
        }
      },
      {
        name = "Courtyard",
        entryLevel = LEVEL_CASTLE_GROUNDS,
        entryNode = 0, -- uses default warp
        exitCastleLevel = LEVEL_CASTLE_GROUNDS,
        exitCastleWarpNode = 128,
        default_stars = 20,
        max_stars = 40,
        bannedAreas = {
          [261] = 1, -- Star-Leap Tower
          [61] = 1, -- Star Haven
        },
        requirements = {
          [LEVEL_BITDW] = 20,
          [LEVEL_BOWSER_1] = 150,
        },
        runner_victory = function(m)
          return (save_file_get_flags() & (SAVE_FLAG_HAVE_KEY_1 | SAVE_FLAG_UNLOCKED_BASEMENT_DOOR)) ~= 0
        end,
        extraObject = {
          [241] = {
            {id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, 4023, 1744, -6491, 0, LEVEL_TOTWC, 1}, -- pipe in SKR to wing cap
          },
        },
        warpNodeOverride = {
          [261] = { -- warps from TOTWC
            [0x27] = {LEVEL_CASTLE_GROUNDS, 1, 0x24}, -- star
            [0x28] = {LEVEL_CASTLE_GROUNDS, 1, 0x25}, -- death
          },
        },
      },
      {
        name = "Lower Tower",
        entryLevel = LEVEL_CASTLE_COURTYARD,
        entryNode = 256,
        exitCastleLevel = LEVEL_CASTLE_COURTYARD,
        exitCastleWarpNode = 256,
        default_stars = 20,
        max_stars = 41,
        bannedAreas = {
          [161] = 1, -- Courtyard
          [61] = 1, -- Star Haven
        },
        doorCost = {
          [30] = 8, -- only 8 because there is no 10 star door texture
          [40] = 20,
        },
        requirements = {
          [LEVEL_DDD] = 8, -- Mad Musical Mess
          [LEVEL_BITFS] = 20,
          [LEVEL_BOWSER_2] = 150,
        },
        runner_victory = function(m)
          return (save_file_get_flags() & (SAVE_FLAG_HAVE_KEY_2 | SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR)) ~= 0
        end,
        extraObject = {
          [71] = {
            {id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, 6305, 3374, 4200, 0, LEVEL_COTMC, 1}, -- pipe in CCC to metal cap
          },
          [231] = {
            {id_bhvWarp, E_MODEL_NONE, 2007, 1800, 1258, 0x14000000, LEVEL_TOTWC, 1}, -- warp in MMM to wing cap
          },
          [101] = {
            {id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, -1847, 285, -4682, 0, LEVEL_VCUTM, 1}, -- pipe in MSP to vanish cap
          },
        },
        warpNodeOverride = {
          [161] = { -- warps from VCUTM and COTMC
            [0x1B] = {LEVEL_CASTLE_COURTYARD, 1, 0x15}, -- cotmc star
            [0x1C] = {LEVEL_CASTLE_COURTYARD, 1, 0x16}, -- cotmc death
            [0x2A] = {LEVEL_CASTLE_COURTYARD, 1, 0x0C}, -- vcutm star
            [0x2B] = {LEVEL_CASTLE_COURTYARD, 1, 0x0D}, -- vcutm death
          },
          [261] = { -- warps from TOTWC
            [0x27] = {LEVEL_CASTLE_COURTYARD, 1, 0x12}, -- star
            [0x28] = {LEVEL_CASTLE_COURTYARD, 1, 0x13}, -- death
          },
        },
      },
      {
        name = "Upper Tower",
        entryLevel = LEVEL_CASTLE_COURTYARD,
        entryNode = 8,
        exitCastleLevel = LEVEL_CASTLE_COURTYARD,
        exitCastleWarpNode = 8,
        default_stars = 20,
        max_stars = 36,
        bannedAreas = {
          [161] = 1, -- Courtyard
        },
        doorCost = {
          [65] = 10, -- only 8 because there is no 10 star door texture
          [80] = 20,
        },
        requirements = {
          [LEVEL_BITS] = 20,
        },
        extraObject = {
          [261] = {
            {id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, -989, 3925, -1365, 0, LEVEL_CASTLE, 1}, -- pipe over cannon to Star Haven
          },
          [61] = {
            {id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, 3400, 160, -2733, 0, LEVEL_CASTLE_COURTYARD, 1, 39}, -- Star Haven pipe to Star Leap Tower
          },
          [141] = {
            {id_bhvDoorWarp, E_MODEL_HMC_METAL_DOOR, -800, -774, 200, 0, LEVEL_VCUTM, 1}, -- door in factory to vanish cap
          },
          [131] = {
            {id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, -4676, -464, -2729, 0, LEVEL_COTMC, 1}, -- pipe in FFF to metal cap
          },
        },
        warpNodeOverride = {
          [161] = { -- warps from VCUTM and COTMC
            [0x1B] = {LEVEL_CASTLE_COURTYARD, 1, 0x2A}, -- cotmc star
            [0x1C] = {LEVEL_CASTLE_COURTYARD, 1, 0x2B}, -- cotmc death
            [0x2A] = {LEVEL_CASTLE, 1, 0x06}, -- vcutm star
            [0x2B] = {LEVEL_CASTLE, 1, 0x07}, -- vcutm death
          },
        },
      },
    },

    otherStarIds = (function()
      return { -- table of other objects to be marked as stars
        [bhvSMSRStarReplica] = "bhvSMSRStarReplica",
        [bhvSMSRStarMoving] = "bhvSMSRStarMoving",
      }
    end),

    runner_victory = function(m)
      if gGlobalSyncTable.bowserBeaten and m.numStars >= gGlobalSyncTable.starRun then
        return true
      elseif m.playerIndex == 0 then
        local np = gNetworkPlayers[0]
        if np.currLevelNum == LEVEL_ENDING then
          gGlobalSyncTable.bowserBeaten = true
        end
      end
      return false
    end,
  },

  -- Replica Comet
  ["coop-romhacks-star-road"] = {
    name = "Star Road: The Replica Comet",
    inherit = "star-road",
    max_stars = 150,

    -- new replicas
    star_data = {
      [COURSE_NONE] = { 8, 8, 8, 8, 8 | STAR_REPLICA, 8 | STAR_REPLICA, 8 | STAR_REPLICA },
      [COURSE_BITDW] = { 8, 0, 0, 8 | STAR_REPLICA, 0, 8 | STAR_REPLICA },
      [COURSE_BITFS] = { 8, 0, 0, 0, 0, 8 | STAR_REPLICA | STAR_EXIT | STAR_APPLY_NO_ACTS },
      [COURSE_BITS] = { 8, 0, 0, 0, 8 | STAR_REPLICA, 8 | STAR_REPLICA },
      [COURSE_PSS] = { 8, 8, 0, 0, 8 | STAR_REPLICA | STAR_EXIT, 8 | STAR_REPLICA, 8 | STAR_REPLICA },
      [COURSE_COTMC] = { 8, 0, 0, 0, 8 | STAR_REPLICA, 8 | STAR_REPLICA | STAR_EXIT | STAR_APPLY_NO_ACTS },
      [COURSE_TOTWC] = { 8, 0, 0, 8 | STAR_REPLICA, 8 | STAR_REPLICA, 8 | STAR_REPLICA },
      [COURSE_VCUTM] = { 8, 0, 0, 8 | STAR_REPLICA | STAR_EXIT | STAR_APPLY_NO_ACTS, 8 | STAR_REPLICA | STAR_APPLY_NO_ACTS, 8 | STAR_REPLICA, 8 | STAR_REPLICA },
      [COURSE_WMOTR] = { 8, 0, 8 | STAR_REPLICA | STAR_EXIT | STAR_APPLY_NO_ACTS, 8 | STAR_REPLICA, 8 | STAR_REPLICA, 8 | STAR_REPLICA, 8 | STAR_REPLICA },
      [COURSE_SA] = { 8, 8 | STAR_IGNORE_STARMODE | STAR_APPLY_NO_ACTS, 0, 0, 8 | STAR_REPLICA, 8 | STAR_REPLICA, 8 | STAR_REPLICA }, -- can fail time challenge
      [COURSE_CAKE_END] = { 0, 8, 0, 8 | STAR_REPLICA },
    },

    -- contains the new replicas
    starNames = {
      [5] = "Replica Of The Blocked Moat",
      [6] = "Replica Of Star Leap's Peak",
      [7] = "Replica Of The Special World",
      [166] = "Replica Of The Steep Slope",
      [176] = "Replica Of The Bill Blasters",
      [185] = "Replica Of The Shining Star",
      [195] = "Replica Of The Shifting Saws",
      [197] = "Replica Of The Mountain Crate",
      [206] = "Replica Of The Flaming Flow",
      [214] = "Replica Of The Windy Mill",
      [215] = "Replica Of The Distant Hill",
      [224] = "Replica Of The Metal Box",
      [225] = "Replica Of The Perilous Pipe",
      [227] = "Replica Of The Hidden Entrance",
      [233] = "Replica Of The Slippery Roof",
      [234] = "Replica Of The World's End",
      [235] = "Replica Of The Hidden Window",
      [237] = "Replica Of The Palace Window",
      [245] = "Replica Of The Scenic Pipe",
      [247] = "Replica Of The Raceside Pipe",
      [254] = "Replica Of The Castle View",
    },

    mini_exclude = {
      [227] = 1, -- uses hidden entrance
    }
  },

  ["sm74"] = {
    name = "Super Mario 74 (+EE)",
    default_stars = 110,
    max_stars = 157, -- impossible in normal, but not in ee
    ommColorStar = true,
    requirements = {
      [LEVEL_BITDW] = 10,
      [LEVEL_BITFS] = 50,
      [LEVEL_BITS] = 110,
      [LEVEL_BOWSER_3] = 157,
      [LEVEL_SA] = 150,
    },
    noLobby = true,

    star_data = {
      [COURSE_COTMC] = { 8, 8, 8, 8, 8 },    -- Toxic-Switch of Danger
      [COURSE_BITDW] = { 8, 8, 8, 8 },       -- Bowser's Badlands-Battlefield
      [COURSE_WMOTR] = { 8, 8, 8, 8, 8, 8 }, -- Tower of the East
      [COURSE_TOTWC] = { 8, 8, 8 },          -- Lava-Switch of Eruption
      [COURSE_VCUTM] = { 8, 8, 8, 8, 8, 8 }, -- Dust-Switch of Identity
      [COURSE_PSS] = { 8, 8, 8, 8 },         -- Frozen Slide
      [COURSE_BITFS] = { 8, 8, 8, 8, 8 },    -- Bowser's Aquatic Castle
      [COURSE_SA] = { 8 },                   -- Champion's Challenge (there's another star but it is hard to get so we ignore in the time)
      [COURSE_BITS] = { 8, 8, 8, 8, 8, 8 },  -- Bowser's Crystal Palace
    },

    -- EE has some different counts
    star_data_ee = {
      [COURSE_COTMC] = { 8, 8, 8, 8, 8, 8 }, -- Toxic Terrace
      [COURSE_SA] = { 8, 8, 8, 8, 8, 8, 8 }, -- Triarc-Bridge
    },
    -- custom star names!
    starNames = {
      [161] = "The Tower's Top",
      [162] = "Hidden In The Towers",
      [163] = "Climbing The Scaffold",
      [164] = "Red Coins In Battle",
      [171] = "The Central Mountain",
      [172] = "Bowels Of The Castle",
      [173] = "Rush Along The Cliffside",
      [174] = "Cliffside Hike",
      [175] = "Diving For Red Coins",
      [181] = "Don't Look Down",
      [182] = "The Palace's Side Tower",
      [183] = "Slip Through The Cracks",
      [184] = "Among The Palace Rooftops",
      [185] = "The Thin Walkway",
      [186] = "16 Sinister Coins",
      [191] = "Steady Sliding Wins The Race",
      [192] = "Slippery Platforming!",
      [193] = "Off The Slide, Onto The Ledge",
      [194] = "Red Coins in The Frost",
      [201] = "Wheezing Wall Kicks",
      [202] = "Bright Down Low",
      [203] = "Secret In The Toxins",
      [204] = "A Breathtaking View",
      [205] = "Toxic Red Coins",
      [211] = "Tower Flight for Red Coins",
      [212] = "Secret Tower Storage",
      [213] = "Low, But Not Too Low",
      [221] = "Sunken In The Dust",
      [222] = "Tip-Toe Through The Dust",
      [223] = "8 Coins Of Identity",
      [224] = "Quick As A Hare",
      [225] = "Light As A Feather",
      [226] = "Highest of All",
      [231] = "Alcove Of The East",
      [232] = "Roof Of The Slide",
      [233] = "Bowser's Secret Treat",
      [234] = "East And West For Red Coins",
      [235] = "A Quick Climb",
      [236] = "The Central Tower's Loot",
      [241] = "A Super Champion",
      [243] = "The Champion Of All",
    },
    starNames_ee = {
      [161] = "Peeking Out The Tower",
      [162] = "Off In The Distance",
      [163] = "Trapped In The Towers",
      [164] = "Flowering Red Coins",
      [171] = "Breaking And Entering",
      [172] = "Surfin' On Sand Mountain",
      [173] = "Wall Kicks In The Pit",
      [174] = "Timed Jumps And Tricky Platforms",
      [175] = "The Pit's Crimson Coins",
      [181] = "Broken Burning Walkway",
      [182] = "Leaps O'er The Void",
      [183] = "THIRTY ????ING RED COINS",
      [184] = "Hole In The Wall",
      [185] = "Thin Wall Ledges",
      [186] = "Down The Deadly Slide",
      [191] = "End Of The Supply Chain",
      [192] = "Another Star In The Wall",
      [193] = "Tight Jumps Needed!",
      [194] = "8 Red Deliveries",
      [201] = "Tiny Platforms, Huge Jumps",
      [202] = "Scaling The Lava",
      [203] = "In The Terrace Depths",
      [204] = "Thread The Needle",
      [205] = "Atop The Terrace",
      [206] = "Coin Search In The Terrace",
      [211] = "How Low Can You Go?",
      [212] = "The Height Of Hell",
      [213] = "Devilish Red Coins",
      [221] = "Under The Arches",
      [222] = "Fast-Paced Delivery",
      [223] = "Slip Under The Mist",
      [224] = "Final Destination",
      [225] = "Dive Through The Dust",
      [226] = "Red Coins in The Fog",
      [231] = "The Lord's Red Coins",
      [232] = "Top Of The Broken Tower",
      [233] = "Corner In the Sky",
      [234] = "Long Leaps Above The Lake",
      [235] = "Sloped Triple Jumps",
      [236] = "Hidden Corner Of The Cave",
      [241] = "Red Coin Stroll",
      [242] = "Below The Hanging Floor",
      [243] = "Troll Under The Bridge",
      [244] = "Hidden in The Tower",
      [245] = "Towers Over The Void",
      [246] = "Under The Castle Wall",
      [247] = "Literally Under Ground",
    },
    mini_exclude = {
      [221] = 1, -- also excludes its equivalent in ee, unintentionally (I don't care that much)
    },

    -- extra hub stages (that aren't part of the castle)
    hubStages = {
      [COURSE_WMOTR] = 1, -- Tower Of The East
    },

    runner_victory = function(m)
      return m.action == ACT_JUMBO_STAR_CUTSCENE
    end,

    -- prevent swap except by host
    special_run = function(m, gotStar)
      if m.playerIndex ~= 0 then return end
      --- @type NetworkPlayer
      local np = gNetworkPlayers[0]
      if gotStar and gGlobalSyncTable.ee and np.currLevelNum == LEVEL_SA then
        m.pos.x, m.pos.y, m.pos.z = 6044, 136, -5564 -- make this level possible without dying
        set_mario_action(m, ACT_SPAWN_NO_SPIN_AIRBORNE, 0)
      end
      if (np.currAreaIndex == 1) == gGlobalSyncTable.ee and gPlayerSyncTable[0].spectator ~= 1 then
        if network_is_server() then
          gGlobalSyncTable.ee = (np.currAreaIndex ~= 1)
          warpCooldown = 0
          close_menu()
        else
          if gGlobalSyncTable.ee then
            djui_chat_message_create(trans("using_ee"))
          else
            djui_chat_message_create(trans("not_using_ee"))
          end
          close_menu()
          warp_to_level(np.currLevelNum, np.currAreaIndex ~ 3, np.currActNum)
        end
      end
    end,
  },

  ["sapphire"] = {
    name = "SM64 Sapphire",
    default_stars = 30,
    max_stars = 30,
    requirements = {
      [LEVEL_BITS] = 30,
      [LEVEL_BOWSER_3] = 30,
    },
    heartReplace = true, -- replaces all hearts with 1ups
    noCapDefault = true,

    -- since not all courses are modified here, exclude those
    star_data = {
      [COURSE_NONE] = {},
      [COURSE_BOB] = { 8, 8, 8, 8, 8, 8 | STAR_ACT_SPECIFIC, 8 },
      [COURSE_CCM] = { 8, 8, 8, 8, 8, 8 | STAR_ACT_SPECIFIC, 8 },
      [COURSE_BBH] = {},
      [COURSE_HMC] = {},
      [COURSE_LLL] = {},
      [COURSE_SSL] = {},
      [COURSE_DDD] = {},
      [COURSE_SL] = {},
      [COURSE_WDW] = {},
      [COURSE_TTM] = {},
      [COURSE_THI] = {},
      [COURSE_TTC] = {},
      [COURSE_RR] = {},
      [COURSE_BITDW] = {},
      [COURSE_BITFS] = {},
      [COURSE_BITS] = {},
      [COURSE_PSS] = { 8 | STAR_EXIT, 8 }, -- includes toad star
      [COURSE_COTMC] = {},
      [COURSE_TOTWC] = {},
      [COURSE_VCUTM] = {},
      [COURSE_WMOTR] = {},
      [COURSE_SA] = {},

      [COURSE_WF] = { 8, 8, 8 | STAR_EXIT, 8, 8, 8 | STAR_EXIT, 8 }, -- prevent getting stuck
      [COURSE_JRB] = { 8, 8 | STAR_EXIT, 8, 8, 8, 8, 8 },            -- prevent getting stuck
      [COURSE_CCM] = { 8, 8, 8, 8, 8, 8 | STAR_EXIT, 8 },            -- prevent getting stuck
    },
    -- custom star names!
    starNames = {
      [191] = "Sonic Speed Star",
      [192] = "Shoutouts to SimpleFlips",
    },

    -- exclude some stars in MiniHunt
    mini_exclude = {
      [192] = 1, -- Toad star doesn't respawn
    },

    runner_victory = function(m)
      local np = gNetworkPlayers[m.playerIndex]
      if np.currLevelNum == LEVEL_ENDING then
        return true
      end
      return false
    end,
  },

  ["SM64 Sapphire Green Comet"] = {
    name = "SM64 Sapphire Green Comet",
    inherit = "sapphire",
    noLobby = true,   -- hack tries to warp out of lobby, so don't use it
    no_bowser = true, -- technically there is an endscreen but there's no reason to require it
    noCapDefault = true,
    requirements = {
      [LEVEL_BITS] = 0,
      [LEVEL_BOWSER_3] = 0,
    },

    starColor = { r = 0, g = 255, b = 0 }, -- guess what color the stars are

    -- 100c stars do not exist
    star_data = {
      [COURSE_PSS] = { 8 | STAR_EXIT, 8, 8 | STAR_EXIT, 8 | STAR_EXIT },

      [COURSE_BOB] = { 8, 8, 8, 8, 8, 8 },
      [COURSE_CCM] = { 8, 8, 8, 8, 8, 8 },
      [COURSE_WF] = { 8 | STAR_EXIT, 8, 8 | STAR_EXIT, 8, 8, 8 | STAR_EXIT },  -- prevent getting stuck
      [COURSE_JRB] = { 8, 8, 8 | STAR_EXIT, 8, 8, 8 },                         -- prevent getting stuck
      [COURSE_CCM] = { 8, 8, 8, 8 | STAR_EXIT, 8 | STAR_EXIT, 8 | STAR_EXIT }, -- prevent getting stuck
      [COURSE_BITS] = { 8, 8 | STAR_EXIT },
    },
    -- same as in lug's
    starNames = {
      -- Gloomy Sea
      [181] = "Green Star 1",
      [182] = "Green Star 2",

      -- Slide
      [191] = "Green Star 1",
      [192] = "Green Star 2",
      [193] = "Green Star 3",
      [194] = "Green Star 4",
    },

    -- exclude some stars in MiniHunt
    mini_exclude = {
      [41] = 1, -- It's literally just in the lava
      [45] = 1, -- same
    },
  },

  ["Ztar Attack 2"] = {
    name = "\\#0c33c2\\Ztar Attack \\#c20c0c\\2",
    default_stars = -1, -- no stars required!
    max_stars = 91,
    -- no requirements!
    stalk = true,                              -- makes this hack less annoying
    starColor = { r = 145, g = 207, b = 187 }, -- stars are light green
    final = -1,
    noCapDefault = true,

    -- gotta define almost every level in the game, yay
    star_data = { -- in order
      -- World 1
      [COURSE_BOB] = { 8, 8 },
      [COURSE_WF] = { 8, 8 },
      [COURSE_JRB] = { 8, 8, 8 },
      [COURSE_BITDW] = { 8, 8, 8, 8 },
      -- World 2
      [COURSE_CCM] = { 8, 8 },
      [COURSE_BBH] = { 8, 8, 8, 8 },
      [COURSE_HMC] = { 8, 8, 8, 8, 8 },
      [COURSE_BITFS] = { 8, 8, 8, 8, 8 },
      -- World 3
      [COURSE_LLL] = { 8, 8, 8, 8 },
      [COURSE_SSL] = { 8, 8, 8 },
      [COURSE_DDD] = { 8, 8, 8 },
      [COURSE_COTMC] = { 8, 8, 8, 8, 8, 8 },
      -- World 4
      [COURSE_SL] = { 8, 8 },
      [COURSE_WDW] = { 8, 8, 8, 8, 8, 8 },
      [COURSE_TTM] = { 8, 8, 8 },
      [COURSE_VCUTM] = { 8, 8, 8, 8, 8 },
      -- World 5
      [COURSE_THI] = { 8, 8, 8, 8 },
      [COURSE_TTC] = { 8, 8, 8, 8, 8, 8 },
      [COURSE_RR] = { 8, 8, 8, 8, 8, 8 },
      [COURSE_BITS] = { 8, 8, 8, 8, 8, 8 },
      [COURSE_TOTWC] = { 8 },
      -- Extra
      -- [COURSE_PSS] = {8}, -- The Super Quiz
      -- [COURSE_WMOTR] = {8}, -- Negative Realm
      [COURSE_SA] = { 8, 8, 0, 0, 8, 8 }, -- Gaell's Dream
      [COURSE_CAKE_END] = { 0, 0, 8 },    -- The End
      [COURSE_NONE] = { 0, 0, 0, 8 },     -- has mips
    },
    -- custom star names!
    starNames = {
      -- 1-4
      [161] = "Swinging Platform Romp",
      [162] = "Climbing The Steep Hill",
      [163] = "Swimming Deep In The Castle",
      [164] = "Prepare For Poison Wiggler!",
      -- 2-4
      [171] = "Climbing Through The Pyramid",
      [172] = "The Trial Of Flame",
      [173] = "Trial Of The Pit",
      [174] = "Shell Surfin' Trial",
      [175] = "Blastoff To Eyerok",
      -- 3-4
      [201] = "Scaling The Plant",
      [202] = "Dodging Cannonballs",
      [203] = "The Plant's Storage Room",
      [204] = "Sliding Past Explosives",
      [205] = "Power Plant's Peak",
      [206] = "Conquering The Corrupt King",
      -- 4-4
      [221] = "Of Flames And Frost",
      [222] = "Deep In The Cavern",
      [223] = "Scaling The Ice",
      [224] = "The Crystal Maze",
      [226] = "A Brainwashed King",
      -- 5-4
      [181] = "Bowser's Beautiful Garden",
      [182] = "Castle Siege",
      [183] = "Quicksand Surfin'",
      [184] = "Tight Jumps Above Lava",
      [185] = "By The Books",
      [186] = "Bowser Draws Near...",
      -- 5-5
      [211] = "Ztar Attack!",
      -- extra levels
      [231] = "A Hundred Coins Of Chaos", -- Negative Realm
      [191] = "Quizmaster",               -- The Super Quiz
      [251] = "Thanks For Playing!",      -- The End
      [253] = "The Princess's Present",   -- The End
      -- Gaell's Dream
      [241] = "Stars Across Time And Space",
      [242] = "The End Of Time",
      [245] = "Timeless Red Coins",
      [246] = "A Bout With Gaell",
    },

    hubStages = {
      [COURSE_PSS] = 1, -- The Super Quiz
    },

    gameAreaData = {
      { -- default
        entryLevel = LEVEL_CASTLE_GROUNDS,
        entryNode = 0, -- uses default warp
        exitCastleLevel = LEVEL_CASTLE_GROUNDS,
        exitCastleWarpNode = 10,
      },
      {
        name = "World 1",
        entryLevel = LEVEL_BOB,
        entryNode = 10,
        exitCastleLevel = LEVEL_BOB,
        exitCastleWarpNode = 10,
        default_stars = -1,
        max_stars = 11,
        bannedAreas = {
          [161] = 1, -- Castle Grounds
          [71] = 1, -- 2-3 (prevent warp zone in 1-2)
        },
        runner_victory = function(m)
          return (save_file_get_flags() & (SAVE_FLAG_HAVE_KEY_1 | SAVE_FLAG_UNLOCKED_BASEMENT_DOOR)) ~= 0
        end,
      },
      {
        name = "World 2",
        entryLevel = LEVEL_CCM,
        entryNode = 10,
        exitCastleLevel = LEVEL_CCM,
        exitCastleWarpNode = 10,
        default_stars = -1,
        max_stars = 16,
        bannedAreas = {
          [161] = 1, -- Castle Grounds
          [221] = 1, -- 3-1 (prevent warp zone in 2-2)
        },
        runner_victory = function(m)
          return (save_file_get_flags() & (SAVE_FLAG_HAVE_KEY_2 | SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR)) ~= 0
        end,
      },
      {
        name = "World 3",
        entryLevel = LEVEL_LLL,
        entryNode = 10,
        exitCastleLevel = LEVEL_LLL,
        exitCastleWarpNode = 10,
        default_stars = -1,
        max_stars = 16,
        bannedAreas = {
          [161] = 1, -- Castle Grounds
          [261] = 1, -- Castle Courtyard
          [141] = 1, -- 5-2 (prevent warp zone in 3-2)
        },
        runner_victory = function(m)
          return (save_file_get_flags() & (SAVE_FLAG_HAVE_METAL_CAP)) ~= 0
        end,
      },
      {
        name = "World 4",
        entryLevel = LEVEL_SL,
        entryNode = 10,
        exitCastleLevel = LEVEL_SL,
        exitCastleWarpNode = 10,
        default_stars = -1,
        max_stars = 16,
        bannedAreas = {
          [161] = 1, -- Castle Grounds
          [261] = 1, -- Castle Courtyard
          [131] = 1, -- 5-1 (prevent warp zone in 4-1)
        },
        runner_victory = function(m)
          return (save_file_get_flags() & (SAVE_FLAG_HAVE_VANISH_CAP)) ~= 0
        end,
      },
      {
        name = "World 5",
        entryLevel = LEVEL_THI,
        entryNode = 10,
        exitCastleLevel = LEVEL_THI,
        exitCastleWarpNode = 10,
        default_stars = -1,
        max_stars = 22,
        bannedAreas = {
          [161] = 1, -- Castle Grounds
          [261] = 1, -- Castle Courtyard
          [61] = 1, -- Castle
          [291] = 1, -- 5-5
        },
      },
    },

    runner_victory = function(m) -- red switch is after bowser
      if (save_file_get_flags() & SAVE_FLAG_HAVE_WING_CAP) ~= 0 and not gGlobalSyncTable.bowserBeaten then
        gGlobalSyncTable.bowserBeaten = true
      end
      if gGlobalSyncTable.bowserBeaten and m.numStars >= gGlobalSyncTable.starRun then
        return true
      end
      return false
    end,
  },

  ["coop-mods-green-stars"] = {
    name = "SM64: The Green Stars",
    default_stars = 80,
    max_stars = 131,
    ommColorStar = true,
    requirements = {
      [LEVEL_BBH] = 4,  -- Fiery Factory
      [LEVEL_BITDW] = 15,
      [LEVEL_LLL] = 20, -- Giant Overgrown Garden
      [LEVEL_DDD] = 20, -- Sandy Seaside Bay
      [LEVEL_SL] = 30,  -- Molten Magma Galaxy
      [LEVEL_BITFS] = 40,
      [LEVEL_TTM] = 50, -- Perilous Cliffs
      [LEVEL_RR] = 65,  -- Rainbow Star Haven
      [LEVEL_BITS] = 80,
      [LEVEL_BOWSER_3] = 130,
    },
    starColor = { r = 92, g = 255, b = 92 }, -- stars are green (duh)
    heartReplace = true,                     -- replaces all hearts with 1ups

    star_data = {
      [COURSE_NONE] = { 8, 8, 8 }, -- no mips
      [COURSE_BOB] = { 8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8, 8, 8 },
      [COURSE_WF] = { 8 | STAR_ACT_SPECIFIC, 8, 8 | STAR_EXIT, 8, 8, 8, 8 },
      [COURSE_BBH] = { 8, 8, 8, 8, 8 | STAR_NOT_BEFORE_THIS_ACT, 8, 8 },
      [COURSE_HMC] = { 8, 8 | STAR_NOT_BEFORE_THIS_ACT, 8, 8, 8 | STAR_ACT_SPECIFIC, 8, 8 },
      [COURSE_SSL] = { 8, 8, 8, 8, 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8 },
      [COURSE_DDD] = { 8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8, 8, 8 },
      [COURSE_SL] = { 8, 8, 8, 8 | STAR_ACT_SPECIFIC, 8, 8 | STAR_NOT_ACT_1, 8 }, -- the act 6 star is obtainable in acts 4-6, so this was the best solution I could think of
      [COURSE_DDD] = { 8, 8 | STAR_ACT_SPECIFIC | STAR_EXIT, 8 | STAR_ACT_SPECIFIC, 8, 8, 8 | STAR_ACT_SPECIFIC, 8 },
      [COURSE_THI] = { 8, 8, 8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8 },
      [COURSE_TTC] = { 8, 8 | STAR_NOT_BEFORE_THIS_ACT, 8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8 }, -- star 2 isn't actually available in acts 5 and 6 :/
      [COURSE_BITDW] = { 8, 8, 8 },
      [COURSE_BITFS] = { 8, 8, 8, 8 },
      [COURSE_BITS] = { 8, 8, 8, 8 },
      [COURSE_PSS] = { 8 | STAR_IGNORE_STARMODE | STAR_APPLY_NO_ACTS, 8, 8, 8 | STAR_EXIT | STAR_APPLY_NO_ACTS },
      [COURSE_COTMC] = { 8, 8 | STAR_EXIT | STAR_APPLY_NO_ACTS, 8 },
      [COURSE_TOTWC] = { 8, 8 },
      [COURSE_VCUTM] = {}, -- does not exist
      [COURSE_WMOTR] = { 8 },
      [COURSE_SA] = { 8, 8 },
    },
    -- custom star names!
    starNames = {
      [161] = "Frightening Red Coins",
      [162] = "Puzzle Of The Blasters",
      [163] = "Scary Jump To The Castle Wall",
      [171] = "8 Coins Ablaze",
      [172] = "Wait, Go Back",
      [173] = "Back Ledge Of The Tower",
      [174] = "Scaling The Lavafall",
      [181] = "Based Red Coins",
      [182] = "Perilous Wall Climb",
      [183] = "Mechanics Of The Base",
      [184] = "Above The Toxic Waste",
      [191] = "Memorable Red Coins",
      [192] = "Quick Trip Down Memory Lane",
      [193] = "The Beginning Tower",
      [194] = "Star On A Star",
      [201] = "Flaming-Frost Red Coins",
      [202] = "Hot-Footing Once Again",
      [203] = "Atop The Icefall",
      [211] = "Palace Flight For Red Coins",
      [212] = "The Tallest Tower",
      [231] = "Thanks For Playing!",
      [241] = "8 Ancient Coins",
      [242] = "Dangerous Dive Under The Wall",
    },
    -- a bunch of stars are at the start
    mini_exclude = {
      [43] = 1,
      [172] = 1,
      [193] = 1,
      [231] = 1,
    },

    runner_victory = function(m)
      if gGlobalSyncTable.bowserBeaten and m.numStars >= gGlobalSyncTable.starRun then
        return true
      elseif m.action == ACT_JUMBO_STAR_CUTSCENE then
        gGlobalSyncTable.bowserBeaten = true
      end
      return false
    end,
  },

  ["underworld"] = {
    name = "SM64: The Underworld",
    default_stars = 30,
    max_stars = 30,
    no_bowser = false,         -- can't disable
    badGuy = "The Shitilizer", -- this will display in the rules
    badGuy_es = "El Shitilizer",
    badGuy_de = "Den Shitilizer",
    ["badGuy_pt-br"] = "O Shitilizer",
    badGuy_fr = "Le Shitilizer",
    badGuy_it = "Il Shitilizer",
    badGuy_ro = "Shitilizerul",              -- I think this is right?
    isUnder = true,                          -- activates special star detection
    noLobby = true,
    starColor = { r = 0, g = 255, b = 255 }, -- light blue
    final = -1,

    -- prevents moving at start, disables some things
    special_run = function(m, gotStar)
      if gGlobalSyncTable.mhMode == 2 then
        change_game_mode(nil, 0)
        djui_popup_create(trans("wrong_mode"), 1)
      end
      if gGlobalSyncTable.starRun ~= 30 then
        gGlobalSyncTable.starRun = 30
        djui_popup_create(trans("wrong_mode"), 1)
      end
      if gGlobalSyncTable.mhState == 0 then
        set_mario_action(m, ACT_SPAWN_NO_SPIN_AIRBORNE, 0)
        if m.playerIndex == 0 and (m.controller.buttonPressed & R_TRIG) ~= 0 then
          djui_open_pause_menu()
        end
      end

      if m.playerIndex ~= 0 then return end
      local np = gNetworkPlayers[0]
      gLevelValues.entryLevel = np.currLevelNum
    end,

    -- no typical stars
    star_data = {
      [COURSE_NONE] = {},
      [COURSE_BOB] = {},
      [COURSE_WF] = {},
      [COURSE_JRB] = {},
      [COURSE_CCM] = {},
      [COURSE_BBH] = {},
      [COURSE_HMC] = {},
      [COURSE_LLL] = {},
      [COURSE_SSL] = {},
      [COURSE_DDD] = {},
      [COURSE_SL] = {},
      [COURSE_WDW] = {},
      [COURSE_TTM] = {},
      [COURSE_THI] = {},
      [COURSE_TTC] = {},
      [COURSE_RR] = {},
      [COURSE_BITDW] = {},
      [COURSE_BITFS] = {},
      [COURSE_BITS] = {},
      [COURSE_PSS] = {},
      [COURSE_COTMC] = {},
      [COURSE_TOTWC] = {},
      [COURSE_VCUTM] = {},
      [COURSE_WMOTR] = {},
      [COURSE_SA] = {},
    },

    -- custom star names! (30 omg)
    starNames = {
      [11] = "The Land Of The Condemned",
      [12] = "Remnant Across From The Tower",
      [13] = "The Entrance Remnant",
      [14] = "Beside the Remnant Pair",
      [15] = "The Battlefield Remnant",
      [16] = "Nowhere to Blast",
      [17] = "Bob-Omb Battlefield?",
      [18] = "Seek The Soul Star",
      [19] = "Behind No Such Gate",
      [20] = "Soul Star Of The Summit",
      [21] = "Underworld Plains",
      [22] = "A Glow In The Dark",
      [23] = "Fortress In The Deep",
      [24] = "Beneath The Wild Blue",
      [25] = "Beside The Deep's Fortress",
      [26] = "To The Top Of Deep's Fortress",
      [27] = "Open In The Fortress",
      [28] = "View From The Fortress",
      [29] = "Midway Up The Fortress",
      [30] = "Sunken Sand Land",
      [31] = "Corner Of The Lava",
      [32] = "Stand Tall On Second Pillar", -- going clockwise
      [33] = "Stand Tall On First Pillar",
      [34] = "Stand Tall On Fourth Pillar",
      [35] = "Stand Tall On Third Pillar",
      [36] = "Pyramid of the Underworld",
      [37] = "Remnant Pair 1",
      [38] = "Remnant Pair 2",
      [39] = "The Tower Remnant",
      [40] = "Beside-Across From The Tower",
      [1099511627776] = "Master Of OMM", -- did you know OMM adds a 31st star?
    },

    runner_victory = function(m)
      return m.action == ACT_JUMBO_STAR_CUTSCENE
    end,
  },

  ["B3313"] = {
    name = "B3313",
    default_stars = 30, -- just a number
    max_stars = 120,    -- unknown how many stars there actually are (auto-generated)
    vagueName = true,   -- the names are all identical, just use course numbers
    -- no requirements
    parseStars = true,  -- automatically generate star list (this hack is too large I can't be bothered)
    stalk = true,       -- the hack is confusing, so let people warp
    final = -1,
    noCapDefault = true,
    checkAreaWarp = true,

    star_data = {}, -- filled when parsed

    -- overrides the generated information
    game_exclude = {
      [34] = 1,  -- is area 3 meant to appear?
      [73] = 1,  -- prevent lava death

      [122] = 0, -- unobtainable (can't enter act 2)... but you CAN get this star in OMM

      -- test rooms
      [212] = 0,
      [213] = 0,
      [214] = 0,
      [215] = 0,
      [216] = 0,

      -- I don't think area 3 is meant to appear
      [132] = 7,
      [133] = 2,

      [117] = 0, -- same for this area
      [231] = 1, -- instant death
    },

    mini_exclude = {
      [124] = 1, -- this is literally "Mysterious Mountainside" unchanged; as such, too easy

      -- too easy (some are "Checkerboard")
      [132] = 1,
      [213] = 1,
      [152] = 1,
      [153] = 1,
      [44] = 1,
      [45] = 1,
    },

    starNames = {
      [151] = "Star (1)",             -- Manta Ray is not possible
      [211] = "5 Hidden Secrets (1)", -- Same here
    },

    -- wip (from b3313 wiki)
    levelNames = {
      [41] = "Whomp's Kingdom",
      [42] = "Whomp's Prison",
      [43] = "Whomps Fortress (beta)?", -- no stars; is similar to the correct one
      [44] = "King Whomp's Battle Arena",
      [45] = "Flower Fields",
      [46] = "Vanish Cap Under The Moat (beta)",

      [51] = "Jolly Roger Lagoon",
      [52] = "Orange Hall",
      [53] = "Test Level",
      [54] = "Checkerboard (C4)",
      [55] = "Holy Yellow Switch Palace",
      [56] = "Holy Yellow Switch Palace?", -- duplicate with wdw diamonds for some reason

      [71] = "Hazy Maze Cave (empty)",
      [72] = "Tick Tock Blocks",
      [73] = "Midnight Meadow",
      [74] = "Lethal Cavern",
      [75] = "Plains", -- couldn't find on wiki; probably unused
      [76] = "Cave City",
      [77] = "Click Clock Climb",

      [81] = "Desert Maze",
      [82] = "Shifted Sand Land",
      [83] = "Scary Sewer Maze",
      [84] = "Eyerok's Tomb",
      [85] = "Sandy Skyloft",
      [86] = "Scary Sewer Maze", -- shadow mario encounter
      [87] = "Scary Sewer Maze", -- death

      [91] = "Crimson Hallway",
      [92] = "3rd Floor (beta)",
      [93] = "athletic",
      [94] = "Bowser's Castle",
      [95] = "Fake Lobby",
      [96] = "Crescent Castle",
      [97] = "Goomba Hills",

      [101] = "Floating Hotel",
      [102] = "Haunted Castle Grounds",
      [103] = "Wing Cap by the Rainbow Highway",
      [104] = "Tower of the Wing Cap (beta)",
      [105] = "Rainbow Ride (beta)",
      [106] = "Vanish Cap within the Plexus",

      [111] = "Snow Slide (B-Roll)?", -- duplicate (is accessible?)
      [112] = "Snowman's Darkness",
      [113] = "Frosty Highlands?",    -- duplicate?
      [114] = "Cool, Cool Mountain (beta)",
      [115] = "Chief Chilly's Ring",
      [116] = "Cold, Cold Crevasse",
      [117] = "Chroma Tundra",

      [121] = "Bob-Omb River",
      [122] = "Big Bob-Omb's Fortress?", -- duplicate with fog
      [123] = "Piranha Plant Garden",
      [124] = "Minion Base?",            -- duplicate with different skybox
      [125] = "Piranha's Igloo",

      [131] = "Castle Grounds",
      [132] = "Bob-Omb Tower",
      [133] = "Creepy Cove?", -- Seems to be a duplicate
      [134] = "Grassy Highlands",
      [135] = "Minion Base",
      [136] = "Peach's Cell",
      [137] = "Peach's Cell",

      [141] = "Big Boo's Haunted Forest",
      [142] = "Dark Lobby",
      [143] = "Plexal Lobby",
      [144] = "Clock Hall",
      [145] = "Big Boo's Fortress",
      [146] = "Plexal Hallway",
      [147] = "???'s Floor", -- both peach/bowser floor are here

      [151] = "Jolly Roger Bay (beta)",
      [152] = "Dead Fortress", -- empty wiggler's forest fortress; unused?
      [153] = "Checkerboard (C15)",
      [154] = "Bowser's Maze",
      [155] = "Balcony",

      [161] = "Castle Grounds?", -- not quite a duplicate
      [162] = "Beta Lobby C/D",  -- both rooms are connected
      [163] = "Beta Lobby B",
      [164] = "Beta Lobby A",
      [165] = "Genesis Basement",
      [166] = "Bowser's Hallway/Prison", -- both are here
      [167] = "Plexal Upstairs",

      [171] = "Tiny Huge Island (beta)",
      [172] = "Red Courtyard", -- unknown
      [173] = "Creepy Cove",
      [174] = "Sunken Castle",
      [175] = "Mario's Maze",
      [176] = "Mario's Maze", -- get attacked by faceless marios (doesn't work in this port)

      [181] = "Battle Fort",
      [182] = "Floor 2B",
      [183] = "Randomized Realm",
      [184] = "Unknown Lobby",     -- unused lobby; doesn't lead anywhere good
      [185] = "Bob-omb Test Site", -- also called "test field"?
      [186] = "Big Bob-Omb's Fortress",

      [191] = "Aquatic Tunnel",
      [192] = "Cryptic Hideout",
      [193] = "Cryptic Hideout", -- faceless mario encounter (instant death)
      [194] = "Cryptic Hideout", -- ??? (instant death)
      [195] = "Funhouse",

      [201] = "Dry Town",
      [202] = "Wiggler's Forest Fortress",
      [203] = "Pleasant, Pleasant Falls",
      [204] = "Sky-High Pathway",
      [206] = "Ruins In The Blood Lake",

      [211] = "Wet-Dry World (beta)?", -- no pipe here
      [213] = "Ice-Cold Warzone",
      [214] = "Bob-omb Battlefield (beta)",

      [221] = "Blazing Bully Base", -- red version
      [222] = "Peaceful Sewer Maze",
      [223] = "Blazing Bully Base", -- blue version
      [224] = "Infernal Tower",
      [225] = "Fire Bubble (B-Roll)",

      [231] = "Dark Hallway",
      [232] = "Checkerboard (C9)",
      [233] = "Deadly Descent",
      [234] = "Delicious Cake",
      [235] = "Snow Slide (B-Roll)",
      [236] = "Snowman's Land (beta)",
      [237] = "Frosty Highlands",

      [241] = "Cryptic Hideout?",     -- possibly an early version
      [242] = "Dark Lobby?",          -- duplicate with different warps?
      [243] = "Plexal Basement",
      [244] = "Flooded Hallway",      -- unknown
      [245] = "Empty Flooded Hallway",
      [246] = "Lavish Lava Mountain", -- grass side
      [247] = "Lavish Lava Mountain", -- lava side

      [251] = "Flooded Town",
      [252] = "Underground Passageway",
      [256] = "Wet-Dry World (beta)",

      [261] = "Uncanny Courtyard",
      [262] = "Forest Maze",
      [263] = "The Star",
      [264] = "Purple Upstairs",
      [265] = "The Void",
      [266] = "Uncanny Courtyard", -- crimson state
      [267] = "Uncanny Courtyard", -- windy state

      [271] = "Dark Downtown",
      [272] = "castle2",
      [273] = "Cubic Greens",
      [274] = "Purple Cavern", -- probably unused
      [275] = "Bob-Omb Village",
      [276] = "Dead Village",
      [277] = "Dark Plexal Upstairs",

      [281] = "Mountain (B-Roll)",
      [282] = "Goomboss Battle",
      [283] = "Sinister Clockwork",
      [284] = "Whomp's Fortress (beta)",
      [285] = "Tall Floating Fortress",
      [286] = "Rocky Trek",

      [291] = "Eel Graveyard",
      [292] = "Empty Graveyard",  -- unused?
      [293] = "Checkboard (WC)",
      [294] = "Plexal Upstairs?", -- somewhat different
      [295] = "Silent Hall",
      [296] = "Void?",            -- just like 34 area 2; idk
      [297] = "Void?",            -- another one? instant death this time

      [301] = "Bowser 1",

      [311] = "Water Land",
      [312] = "Castle1",       -- layout 2?
      [313] = "Castle1",
      [314] = "Forgotten Bay", -- couldn't find this one, so I made this name up
      [315] = "Castle Garden",
      [316] = "Water Land",    -- Unused duplicate?

      [331] = "Bowser's Checkered Madness",
      [332] = "Bowser In The Bully Battlefield",
      [333] = "Bowser 2",

      [341] = "Eternal Fort",
      [342] = "Void?", -- unused, perhaps? somewhat similar to void

      -- vanilla tall tall mountain
      [361] = "Tall, Tall Mountain",
      [362] = "Tall, Tall Mountain",
      [363] = "Tall, Tall Mountain",
      [364] = "Tall, Tall Mountain",
    },

    -- warp to ruins in the blood lake
    special_run = function(m, gotStar)
      if m.playerIndex == 0 and gotStar == 2 and gNetworkPlayers[0].currLevelNum == LEVEL_THI and gNetworkPlayers[0].currAreaIndex == 7 then
        warp_to_level(LEVEL_SA, 6, 0)
      end
    end,

    runner_victory = function(m)
      return m.action == ACT_JUMBO_STAR_CUTSCENE
    end,
  },

  ["moonshine"] = {
    name = "SM64 Moonshine",
    default_stars = 50, -- there is no end, really
    max_stars = 50,
    no_bowser = true,
    requirements = {
      [LEVEL_LLL] = 8,                       -- Sweet Sweet Rush
      [LEVEL_BITS] = 30,                     -- Down Street
    },
    starColor = { r = 92, g = 255, b = 92 }, -- all moons are green
    heartReplace = true,                     -- replaces all hearts with 1ups
    isMoonshine = true,                      -- changes hud elements
    coinColor = { r = 0, g = 255, b = 0 },   -- green coins

    star_data = {
      [COURSE_NONE] = { 0, 8 },               -- only toad star 2
      [COURSE_JRB] = {},
      [COURSE_LLL] = { 8, 8, 0, 0, 0, 0, 8 }, -- Sweet Sweet Rush
      [COURSE_SSL] = {},
      [COURSE_DDD] = {},
      [COURSE_SL] = {},
      [COURSE_WDW] = { 8, 8, 8, 8, 0, 0, 8 }, -- Green Plains
      [COURSE_TTM] = {},
      [COURSE_THI] = {},
      [COURSE_TTC] = {},
      [COURSE_RR] = {},
      [COURSE_BITDW] = {},
      [COURSE_BITFS] = { 8, 8 }, -- Purple Swampy Swamp
      [COURSE_BITS] = { 8, 8 },  -- Moonshine
      [COURSE_PSS] = {},
      [COURSE_COTMC] = {},
      [COURSE_TOTWC] = {},
      [COURSE_VCUTM] = {},
      [COURSE_WMOTR] = {},
      [COURSE_PSS] = { 8, 8 }, -- Forest Valley
      [COURSE_SA] = {},
    },
    -- custom star names!
    starNames = {
      [2] = "Toad's Gift",
      [171] = "Surviving The Swamp",
      [172] = "8 Coins Across The Swamp",
      [181] = "Shining Moon",
      [182] = "8 Shining Coins",
      [191] = "Top Of The Valley",
      [192] = "Green Coins Among Green Trees",
    },

    mini_exclude = {}, -- none!
  },

  ["ldd"] = {
    name = "Lug's Delightful Dioramas",
    default_stars = 64,
    max_stars = 74,

    starColor = { r = 255, g = 255, b = 255 }, -- stars are white
    disableNonStop = true,                     -- omm actually disables non stop for this hack
    no_bowser = true,                          -- no bowser.
    final = -1,

    -- warp to sweet delight after getting spectral spectacle star
    special_run = function(m, gotStar)
      if m.playerIndex == 0 and gotStar == 1 and gNetworkPlayers[0].currLevelNum == LEVEL_BITFS then
        warp_to_level(LEVEL_BITS, 1, 0)
      end
    end,

    -- so many act specific stars...
    star_data = {
      [COURSE_NONE] = { 8, 8, 8 },
      [COURSE_BOB] = { 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC },
      [COURSE_WF] = { 8 | STAR_ACT_SPECIFIC, 8, 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8, 8 | STAR_ACT_SPECIFIC },
      [COURSE_JRB] = { 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8 | STAR_EXIT, 8 | STAR_ACT_SPECIFIC },
      [COURSE_CCM] = { 8 | STAR_ACT_SPECIFIC, 8, 8, 8 | STAR_ACT_SPECIFIC, 8, 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC },
      [COURSE_BBH] = { 8 | STAR_ACT_SPECIFIC, 8, 8 | STAR_ACT_SPECIFIC, 8, 8 | STAR_EXIT, 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC },
      [COURSE_LLL] = { 8, 8, 8, 8, 8, 8, 8 }, -- actually not any act specific stars

      [COURSE_BITDW] = { 8 | STAR_EXIT, 8 | STAR_EXIT, 8 | STAR_EXIT },
      [COURSE_BITFS] = { 8 },
      [COURSE_BITS] = {},
      [COURSE_PSS] = { 8, 8, 8 },
      [COURSE_COTMC] = { 8, 8, 8 },
      [COURSE_TOTWC] = { 8, 8, 8 },
      [COURSE_VCUTM] = { 8, 8, 8 },
      [COURSE_WMOTR] = { 8, 8, 8 },
      [COURSE_SA] = { 8, 8, 8 },

      -- do not exist
      [COURSE_SSL] = {},
      [COURSE_DDD] = {},
      [COURSE_SL] = {},
      [COURSE_WDW] = {},
      [COURSE_TTM] = {},
      [COURSE_THI] = {},
      [COURSE_TTC] = {},
      [COURSE_RR] = {},
    },

    requirements = {
      [LEVEL_HMC] = 30,   -- Scorching Jaws
      [LEVEL_CASTLE_COURTYARD] = 8,
      [LEVEL_BITFS] = 50, -- Spectral Spectacle
      [LEVEL_BITS] = 51,  -- A Sweet Delight
    },

    starNames = {
      -- Tilted Side
      [161] = "Slip On The Red Towers",
      [162] = "Slidin' On Down",
      [163] = "Canyon Underside",

      [171] = "8 Fantastic Feats", -- Spectral Spectacle

      -- Yellow Side
      [191] = "Height Of The Desert",
      [192] = "Sandy Secrets",
      [193] = "A Side Of Red Coins",

      -- Green Side
      [201] = "Burning Up The Tree",
      [202] = "Boxed-In Secrets",
      [203] = "Present In The Canyon",

      -- Red Side
      [211] = "Climb Up Chuckya Towers",
      [212] = "Back To Roots",
      [213] = "Wall Jump In The Wireframe",

      -- Blue Side
      [221] = "Slip In The Cages",
      [222] = "Rush Down Poison Way",
      [223] = "Deserted Red Coins",

      -- Purple Side
      [231] = "Poisoned Wireframe",
      [232] = "A Leap of Faith or 8",
      [233] = "The Abandoned Canyon",

      -- Orange Side
      [241] = "Grand View From The Canyon",
      [242] = "Red Towers, Red Guys",
      [243] = "Beat Up Brick Guy",
    },
  },

  ["ldd_green_comet"] = {
    name = "LDD - Green Comet",
    inherit = "ldd",
    default_stars = 42,
    max_stars = 80,
    requirements = {
      [LEVEL_HMC] = 0,   -- Scorching Jaws
      [LEVEL_CASTLE_COURTYARD] = 0,
      [LEVEL_BITFS] = 0, -- Spectral Spectacle
      [LEVEL_BITS] = 0,  -- A Sweet Delight
    },

    starColor = { r = 0, g = 255, b = 0 }, -- guess what color the stars are

    -- actually no act specific stars (but a lot of them are exit stars)
    star_data = {
      [COURSE_NONE] = {},
      [COURSE_BOB] = { 8, 8, 8, 8, 8, 8 },
      [COURSE_WF] = { 8, 8 | STAR_EXIT, 8, 8, 8, 8 | STAR_EXIT },
      [COURSE_JRB] = { 8 | STAR_EXIT, 8 | STAR_ACT_SPECIFIC, 8 | STAR_EXIT, 8 | STAR_EXIT, 8 | STAR_ACT_SPECIFIC | STAR_EXIT, 8 | STAR_EXIT },
      [COURSE_CCM] = { 8, 8, 8, 8, 8, 8 },
      [COURSE_BBH] = { 8, 8, 8, 8, 8, 8 },
      [COURSE_LLL] = { 8 | STAR_EXIT, 8 | STAR_EXIT, 8 | STAR_EXIT, 8, 8, 8 | STAR_EXIT },

      [COURSE_BITDW] = { 8 | STAR_EXIT, 8 | STAR_EXIT, 8 | STAR_EXIT, 8 | STAR_EXIT, 8 | STAR_EXIT },
      [COURSE_BITFS] = { 8 | STAR_EXIT, 8 | STAR_EXIT, 8 | STAR_EXIT },
      [COURSE_BITS] = {},
      [COURSE_PSS] = { 8 | STAR_EXIT, 8 | STAR_EXIT, 8 | STAR_EXIT, 8, 8 | STAR_EXIT },
      [COURSE_COTMC] = { 8, 8, 8 | STAR_EXIT, 8 | STAR_EXIT, 8 | STAR_EXIT },
      [COURSE_TOTWC] = { 8, 8 | STAR_EXIT, 8 | STAR_EXIT, 8 | STAR_EXIT, 8 | STAR_EXIT },
      [COURSE_VCUTM] = { 8, 8 | STAR_EXIT, 8 | STAR_EXIT, 8 | STAR_EXIT, 8 | STAR_EXIT },
      [COURSE_WMOTR] = { 8 | STAR_EXIT, 8 | STAR_EXIT, 8 | STAR_EXIT, 8 | STAR_EXIT, 8 | STAR_EXIT },
      [COURSE_SA] = { 8, 8 | STAR_EXIT, 8 | STAR_EXIT, 8 | STAR_EXIT, 8 | STAR_EXIT },
    },

    special_run = function(m, gotStar) end, -- override

    -- if I named all of these I'd have to name the other 42, haha no
    starNames = {
      -- Tilted Side
      [161] = "Green Star 1",
      [162] = "Green Star 2",
      [163] = "Green Star 3",
      [164] = "Green Star 4",
      [165] = "Green Star 5",

      [171] = "Green Star 1", -- Spectral Spectacle
      [172] = "Green Star 2",
      [173] = "Green Star 3",

      -- Yellow Side
      [191] = "Green Star 1",
      [192] = "Green Star 2",
      [193] = "Green Star 3",
      [194] = "Green Star 4",
      [195] = "Green Star 5",

      -- Green Side
      [201] = "Green Star 1",
      [202] = "Green Star 2",
      [203] = "Green Star 3",
      [204] = "Green Star 4",
      [205] = "Green Star 5",

      -- Red Side
      [211] = "Green Star 1",
      [212] = "Green Star 2",
      [213] = "Green Star 3",
      [214] = "Green Star 4",
      [215] = "Green Star 5",

      -- Blue Side
      [221] = "Green Star 1",
      [222] = "Green Star 2",
      [223] = "Green Star 3",
      [224] = "Green Star 4",
      [225] = "Green Star 5",

      -- Purple Side
      [231] = "Green Star 1",
      [232] = "Green Star 2",
      [233] = "Green Star 3",
      [234] = "Green Star 4",
      [235] = "Green Star 5",

      -- Orange Side
      [241] = "Green Star 1",
      [242] = "Green Star 2",
      [243] = "Green Star 3",
      [244] = "Green Star 4",
      [245] = "Green Star 5",
    },
  },

  ["luigis-mansion-64"] = { -- TODO: Make WMOTR accessible
    name = "Luigi's Mansion 64",
    inherit = "vanilla",    -- this actually causes the minimap to be inheritted too, which is... fine, I guess
    max_stars = 118,
    default_stars = 65,
    badGuy = "King Boo",

    -- some levels have been moved around
    requirements = {
      [LEVEL_BOB] = 1,
      [LEVEL_WF] = 0,
      [LEVEL_SL] = 50,
      [LEVEL_RR] = 50,
      [LEVEL_BITFS] = 0,
      [LEVEL_WMOTR] = 0,
      [LEVEL_BOWSER_3] = 118,
    },

    starColor = { r = 180, g = 180, b = 180 }, -- stars are gray

    special_run = function(m, gotStar)
      if gGlobalSyncTable.freeRoam and gGlobalSyncTable.noBowser then
        gBehaviorValues.GrateStarRequirement = 0
      else
        gBehaviorValues.GrateStarRequirement = gGlobalSyncTable.starRun
      end
    end,

    star_data = {
      [COURSE_SL] = { 8, 8, 8, 8, 8, 8 | STAR_EXIT, 8 },
      [COURSE_THI] = { 8 | STAR_ACT_SPECIFIC | STAR_EXIT, 8, 8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8 },
      [COURSE_TTC] = { 8, 8, 8, 8, 8 | STAR_EXIT, 8, 8 },
      [COURSE_NONE] = { 0, 8, 8, 8, 8 },
      [COURSE_PSS] = { 0, 8 },
      [COURSE_BOB] = { 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8, 8 | STAR_NOT_ACT_1 },
    },

    -- custom star names!
    starNames = {
      [107] = "Hearts Of The Igloo", -- this is NOT a 100 coin star
      [161] = "Outta' This World Red Coins",
      [171] = "Boiling Hot Coins",
      [181] = "Coins From Another Dimension",
      [192] = "Crush King Boo's Slide",
      [201] = "Red Sparkles In The Ice",
      [211] = "Red Coins Of The Night",
      [221] = "Underground Red Treasures",
      [231] = "The 7 Holy Coins",
      [241] = "Coins In The Cube",
    },
  },

  ["sr7-coop-port"] = {
    name = "\\#FFC600\\Star \\#00BEFF\\Revenge \\#FF0034\\7\\#E7E7E7\\-Park of Time",
    default_stars = 60,
    heartReplace = true,
    max_stars = 121,
    starColor = { r = 100, g = 255, b = 255 }, -- stars are light blue (same as runners! funny)
    coinColor = { r = 155, g = 255, b = 155 }, -- I'm not making the gradient effect sorry
    numRedCoins = 6,
    requirements = {
      [LEVEL_CCM] = 8,
      [LEVEL_BBH] = 8,
      [LEVEL_HMC] = 10,
      [LEVEL_DDD] = 25,
      [LEVEL_WDW] = 40,
      [LEVEL_TTM] = 40,
      [LEVEL_THI] = 40,
      [LEVEL_RR] = 90,
      [LEVEL_BITDW] = 15,
      [LEVEL_PSS] = 8,
      [LEVEL_BITFS] = 30,
      [LEVEL_COTMC] = 30,
      [LEVEL_WMOTR] = 50,
      [LEVEL_TOTWC] = 100,
      [LEVEL_BITS] = 60,
    },
    badGuy = "Timerock",
    noLobby = true, -- lack of wall jumps makes the parkour impossible
    noCapDefault = true,

    star_data = {
      [COURSE_NONE] = { 0, 8, 8, 8, 8 },
      [COURSE_PSS] = { 8 | STAR_EXIT | STAR_APPLY_NO_ACTS, 8 },
      [23] = { 0, 8 },
      [COURSE_SA] = { 8, 8 | STAR_IGNORE_STARMODE | STAR_EXIT | STAR_APPLY_NO_ACTS, 8 },
    },

    starNames = {
      [161] = "Coins O'er The Sea",
      [171] = "Coins 'Round The Factory",
      [181] = "Time To Raise The Roof",
      [191] = "Coins On The Mountain",
      [192] = "Fast Mountaineer",
      [201] = "...Give Or Take 2", -- This is meant to go with the name of the level itself
      [211] = "Coins Back In 1988",
      [221] = "The Limbo's Secret",
      [232] = "Besting Brodute",
      [241] = "Coins Around The Tower",
      [242] = "Hidden Pipe!",
      [243] = "The Shattered Balcony",
    },

    mini_exclude = {
      [181] = 1, -- eyerok moment
      [221] = 1, -- impossible without dying
      [242] = 1, -- pipe required

      -- unfortunately we have to exclude every star that requires a badge
      [15] = 1,
      [16] = 1,
      [55] = 1,
      [56] = 1,
      [62] = 1,
      [63] = 1,
      [65] = 1,
      [66] = 1,
      [74] = 1,
      [75] = 1,
      [76] = 1,
      [84] = 1,
      [86] = 1,
      [91] = 1,
      [94] = 1,
      [95] = 1,
      [102] = 1,
      [103] = 1,
      [104] = 1,
      [105] = 1,
      [106] = 1,
      [111] = 1,
      [112] = 1,
      [113] = 1,
      [114] = 1,
      [115] = 1,
      [116] = 1,
      [121] = 1,
      [122] = 1,
      [123] = 1,
      [124] = 1,
      [125] = 1,
      [126] = 1,
      [151] = 1,
      [211] = 1,
    },

    -- warps for end and ktq
    special_run = function(m, gotStar)
      if m.playerIndex ~= 0 then return end
      if gotStar == 1 and gNetworkPlayers[0].currLevelNum == LEVEL_BITS then
        warp_to_level(LEVEL_VCUTM, 1, 0)
      elseif gotStar == 2 and gNetworkPlayers[0].currLevelNum == 31 then
        warp_to_warpnode(31, 1, 0, 0xf0)
      end
    end,

    -- marks stars that require certain badges as unobtainable
    getStarFlagsFunc = function(file, course, recalc)
      local course_star_flags = save_file_get_star_flags(file, course)
      if not recalc then return course_star_flags end
      local badgeNames = { -- lava defense is not required
        "W",
        "U",
        "S",
        "T",
      }
      for i = 0, 6 do
        local name = get_custom_star_name(course + 1, i + 1)
        for a, badgeName in ipairs(badgeNames) do
          if name:find("-" .. badgeName .. "b-") and tonumber(romhackbadges.hasbadge(badgeName .. "B")) == 0 then
            course_star_flags = course_star_flags | (1 << i)
          end
        end
      end
      return course_star_flags
    end,

    runner_victory = function(m)
      if gGlobalSyncTable.bowserBeaten and m.numStars >= gGlobalSyncTable.starRun then
        return true
      elseif m.playerIndex == 0 then
        local np = gNetworkPlayers[0]
        if np.currLevelNum == 18 then
          gGlobalSyncTable.bowserBeaten = true
        end
      end
      return false
    end,
  },

  default = {
    name = "Default",
    default_stars = -1,
    max_stars = 255,
    requirements = { [LEVEL_BOWSER_3] = 255, [LEVEL_ENDING] = 255 }, -- block off Bowser 3 until needed stars are collected
    parseStars = true,                                               -- automatically generate star list
    checkAreaWarp = true,

    star_data = {},                                                  -- assume every secret stage has 1 star

    runner_victory = function(m)
      local np = gNetworkPlayers[m.playerIndex]
      return m.action == ACT_JUMBO_STAR_CUTSCENE or np.currCourseNum == COURSE_CAKE_END
    end,
  },

}

ROMHACK = {}               -- table containing the romhack data we're using
PARSE_COURSE = 0           -- what course we're parsing in level_script_parse
PARSE_AREA = 0             -- what area we're parsing in level_script_parse
PARSE_LEVEL = 0            -- what level we're parsing in level_script_parse
PARSE_PRINT = false        -- used in debug command; displays information about found stars
PARSE_FOUND_STARS = {}     -- stars we've found in the level we're parsing
PARSE_MINI_EXCLUDE = {}    -- stars we've found to exclude in minihunt
PARSE_STAR_NAMES = {}      -- the name of the stars we've found

disable_chat_hook = false  -- disabled if a mod uses it (swear filter, for example)
voice_chat_enabled = false -- limbokong's proximity voicechat; changes how spectator mode works

function setup_hack_data(settingRomHack, initial, usingOMM)
  local romhack_file = gGlobalSyncTable.romhackFile
  ROMHACK = romhack_data[romhack_file]
  if initial and usingOMM then
    local verstring = (OmmVersion and OmmVersion:sub(9)) or "Unknown"
    if tonumber(verstring) and tonumber(verstring) >= 1.2 then
      djui_popup_create(trans("omm_detected"), 1)
    else
      djui_popup_create(trans("omm_bad_version", "1.2", verstring), 3)
    end
  end

  local found_121 = false
  if not ROMHACK and settingRomHack then
    if not (mhApi and mhApi.romhackSetup) then
      romhack_file = "vanilla"
    else
      romhack_file = "custom"
    end
    for i, mod in pairs(gActiveMods) do
      if mod.enabled then
        if not (mhApi and mhApi.romhackSetup) and incompatible_or_category(mod, "romhack") then   -- is a romhack
          romhack_file = mod.relativePath:gsub("ROMHACK - ", "")
          found_121 = false
        elseif initial and not (usingOMM or movesetEnabled) and incompatible_or_category(mod, "moveset") then   -- is moveset
          movesetEnabled = true
        elseif (not found_121) and (romhack_file == "vanilla") and string.find(mod.name, "121rst star") then                         -- 121rst star support
          found_121 = true
        elseif not voice_chat_enabled and mod.name and (remove_color(mod.name) == ("Limbokong's Voicechat") or mod.name:find("Roblox Chat Bubbles")) and not mod.name:find("(MH)") then
          voice_chat_enabled = true
        elseif not disable_chat_hook then                                                                                            -- disable hook for some mods
          local name = mod.name:lower()
          if (name:find("mute") or name:find("swear filter") or name:find("nicknames")) and not name:find("(mh)") then
            disable_chat_hook = true
          end
        end
      end
    end
    print("Romhack is", romhack_file)
    ROMHACK = romhack_data[romhack_file]
  end
  if romhack_file == "custom" and (mhApi and mhApi.romhackSetup) then
    ROMHACK = mhApi.romhackSetup()
    print("Romhack is", ROMHACK.name, "custom")
  end

  if initial and romhack_file == "vanilla" then
    dialog_replace()
    omm_replace(usingOMM)
  end

  -- inherit
  if ROMHACK and ROMHACK.inherit then
    local new_rom = romhack_data[ROMHACK.inherit]
    if new_rom then
      print("Inheriting data from", ROMHACK.inherit)
      for i, v in pairs(ROMHACK) do
        if type(v) ~= "table" then
          new_rom[i] = v
        else
          if not new_rom[i] then
            new_rom[i] = {}
          end
          for a, b in pairs(v) do
            new_rom[i][a] = b
          end
        end
      end
      ROMHACK = new_rom
    end
  end

  if found_121 then
    ROMHACK.star_data[COURSE_NONE] = { 8, 8, 8, 8, 8, 8 }
    ROMHACK.starNames[6] = "Red Coins at Midnight"
  end

  if not ROMHACK then
    romhack_file = "default"
    ROMHACK = romhack_data["default"]
    print("Not compatible!")
    djui_popup_create(trans("incompatible_hack"), 1)
    gGlobalSyncTable.romhackFile = "default"
  elseif romhack_file ~= "vanilla" then
    djui_popup_create(trans("set_hack", ROMHACK.name), 1)
  end

  if ROMHACK.starColor then
    defaultStarColor = ROMHACK.starColor
  else
    defaultStarColor = { r = 255, g = 255, b = 92 } -- yellow
  end
  if ROMHACK.noMiniMap then
    showMiniMap = false
  end
  if ROMHACK.noRadar then
    showRadar = false
  end

  if initial then
    if ROMHACK.otherStarIds then
      local otherStarIds = ROMHACK.otherStarIds() or {}
      for id, name in pairs(otherStarIds) do
        star_ids[id] = name
      end
    end
    if ROMHACK.otherStarSources then
      local otherStarSources = ROMHACK.otherStarSources() or {}
      for id, data in pairs(otherStarSources) do
        star_sources[id] = data
      end
    end
    -- ONLY enable base fix collision bugs so that most vanilla tricks still work
    if gLevelValues.fixCollisionBugs and gLevelValues.fixCollisionBugs ~= 0 then
      disableWallFixOption = true
    else
      gLevelValues.fixCollisionBugs                 = bool_to_int(gGlobalSyncTable.invisWallFix)
      gLevelValues.fixCollisionBugsRoundedCorners   = 0
      gLevelValues.fixCollisionBugsFalseLedgeGrab   = 0
      gLevelValues.fixCollisionBugsGroundPoundBonks = 0
      gLevelValues.fixCollisionBugsPickBestWall     = 0
    end
  end

  -- support for old format
  if not ROMHACK.star_data then
    ROMHACK.star_data = {}
    for level, course in pairs(level_to_course) do
      if ROMHACK.starCount[level] then
        if not ROMHACK.star_data[course] then ROMHACK.star_data[course] = {} end
        if ROMHACK.starCount[level] > 0 then
          for i = 1, ROMHACK.starCount[level] do
            local starNum = i
            if ROMHACK.renumber_stars and ROMHACK.renumber_stars[course * 10 + i] then
              starNum = ROMHACK.renumber_stars[course * 10 + i]
            end
            if starNum ~= 0 then
              ROMHACK.star_data[course][starNum] = 8
            end
          end
        end
      end
    end
  end

  if ROMHACK.parseStars then
    for course = 0, COURSE_MAX - 1 do
      parse_course_stars(course, course_to_level[course] or 0)
    end
  end

  if settingRomHack then
    gGlobalSyncTable.allowStalk = ROMHACK.stalk or false
    if (ROMHACK and not ROMHACK.stalk) then
      update_chat_command_description("stalk", "- " .. trans("command_disabled"))
    else
      update_chat_command_description("stalk", trans("stalk_desc"))
    end
    gGlobalSyncTable.starRun = ROMHACK.default_stars
    gGlobalSyncTable.noBowser = ROMHACK.no_bowser or false
    gGlobalSyncTable.romhackFile = romhack_file
    change_setting_default("allowStalk", gGlobalSyncTable.allowStalk)
    change_setting_default("starRun", gGlobalSyncTable.starRun)
    change_setting_default("noBowser", gGlobalSyncTable.noBowser)
  end
  return romhack_file
end

-- checks both mod.incompatible and mod.category
function incompatible_or_category(mod, category)
  if mod.category then
    return mod.category == category
  elseif mod.incompatible and string.find(mod.incompatible, category) then
    return true
  end
  return false
end

-- uses level_script_parse to setup romhack data
function parse_course_stars(course, level)
  if gGlobalSyncTable.romhackFile ~= "vanilla" and level_is_vanilla_level(level) then
    print(level, "is vanilla", course)
    ROMHACK.star_data[course] = {}
    return
  end
  PARSE_COURSE = course
  PARSE_LEVEL = level
  PARSE_AREA = 1
  PARSE_FOUND_STARS = {}
  PARSE_MINI_EXCLUDE = {}
  PARSE_STAR_NAMES = {}

  if not ROMHACK.mini_exclude then ROMHACK.mini_exclude = {} end
  if not ROMHACK.starNames then ROMHACK.starNames = {} end
  if not ROMHACK.star_data[course] then ROMHACK.star_data[course] = {} end

  local exText = ""
  local renumText = ""

  print(PARSE_LEVEL)
  level_script_parse(PARSE_LEVEL, parse_stars)
  if course == 0 then
    PARSE_LEVEL = LEVEL_CASTLE
    level_script_parse(PARSE_LEVEL, parse_stars)
    PARSE_LEVEL = LEVEL_CASTLE_COURTYARD
    level_script_parse(PARSE_LEVEL, parse_stars)
  end

  local starCount = 0
  for i = 1, 7 do
    if (PARSE_FOUND_STARS[i] or (i == 7 and course <= 15 and course > 0 and gLevelValues.coinsRequiredForCoinStar ~= 255 and gLevelValues.coinsRequiredForCoinStar ~= 0)) then
      ROMHACK.star_data[course][i] = PARSE_FOUND_STARS[i] or 1 -- 100 coin star is always area 1

      if not ROMHACK.starNames[course * 10 + i] then
        ROMHACK.starNames[course * 10 + i] = PARSE_STAR_NAMES[course * 10 + i]
      end

      if course ~= 0 and course ~= 25 then
        if PARSE_MINI_EXCLUDE[i] == 1 then
          exText = exText .. (string.format("[%d%d] = 1,", course, i)) .. "\n"
          ROMHACK.mini_exclude[course * 10 + i] = 1
        elseif PARSE_MINI_EXCLUDE[i] and PARSE_MINI_EXCLUDE[i] ~= 0 then
          exText = exText .. (string.format("[%d%d] = %d,", course, i, PARSE_MINI_EXCLUDE[i])) .. "\n"
          ROMHACK.mini_exclude[course * 10 + i] = PARSE_MINI_EXCLUDE[i]
        end
      end
    else
      ROMHACK.star_data[course][i] = 0
    end
  end
  if PARSE_PRINT then
    print(string.format("[%d] = %d,\n", level, starCount))
  end
  if PARSE_PRINT then
    print(renumText)
    print(exText)
  end
end

-- gets all stars (and star sources, such as King Bob-omb); used with level_script_parse
function parse_stars(area, bhvData, macroBhvIds, macroBhvArgs)
  if macroBhvIds then
    for i, id in pairs(macroBhvIds) do
      parse_stars(nil, { behavior = id, behaviorArg = macroBhvArgs[i] }) -- parse for each macro object
    end
  elseif area and area ~= 0 then
    PARSE_AREA = area
    -- check for slide star
    local surfaceTypeData = smlua_collision_util_find_surface_types(smlua_collision_util_get_level_collision(PARSE_LEVEL, PARSE_AREA))
    for i, floorType in ipairs(surfaceTypeData) do
      if floorType == SURFACE_TIMER_START then
        PARSE_FOUND_STARS[gLevelValues.pssSlideStarIndex+1] = PARSE_AREA | STAR_APPLY_NO_ACTS
        local custom_name = (gLevelValues.pssSlideStarTime//30) .. " Second Challenge (" .. (gLevelValues.pssSlideStarIndex+1) .. ")"
        PARSE_STAR_NAMES[PARSE_COURSE * 10 + gLevelValues.pssSlideStarIndex+1] = custom_name
        if PARSE_PRINT then
          djui_chat_message_create(string.format("%s (C%d, L%d, A%d)", custom_name, PARSE_COURSE, PARSE_LEVEL, PARSE_AREA))
          print(custom_name, PARSE_COURSE, PARSE_AREA)
        end
        break
      end
    end
  elseif bhvData then
    local starNum = 0
    local obj_id = bhvData.behavior
    local byte1 = bhvData.behaviorArg >> 24            -- first byte
    local byte2 = (bhvData.behaviorArg >> 16 & 0x00FF) -- second byte

    local neededByte2
    local custom_name
    if star_sources[obj_id] then
      neededByte2 = star_sources[obj_id][1] or 0
      custom_name = star_sources[obj_id][2]
    end

    local mini_invalid = false

    if star_ids[obj_id] then
      custom_name = "Star"
      starNum = (byte1) + 1
    elseif neededByte2 == true then
      starNum = (byte1) + 1
    elseif neededByte2 == 0xFF then
      if byte2 ~= 0 then
        starNum = (byte1) + 1
      end
    elseif neededByte2 then
      if byte2 == neededByte2 then
        starNum = (byte1) + 1
      end
    elseif obj_id == id_bhvKoopa then -- koopa the quick special case
      if byte2 > 0x01 then
        custom_name = "Race with Koopa The Quick"
        starNum = (byte1) + 1
      end
    elseif obj_id == id_bhvExclamationBox then -- exclamation box special case
      if exclamation_box_valid[byte2] then
        custom_name = "Box Star"

        if byte2 == 8 then
          starNum = (byte1) + 1
        else
          starNum = byte2 - 8
        end
      end
    elseif obj_id == id_bhvToadMessage then -- toad special case
      mini_invalid = true
      custom_name = "Toad Star"
      if byte1 == gBehaviorValues.dialogs.ToadStar1Dialog then
        starNum = 1
      elseif byte1 == gBehaviorValues.dialogs.ToadStar2Dialog then
        starNum = 2
      elseif byte1 == gBehaviorValues.dialogs.ToadStar3Dialog then
        starNum = 3
      end
    elseif obj_id == id_bhvMips then -- mips special case
      mini_invalid = true
      custom_name = "Mips Star"
      if area then -- if the area was set, we're doing mip's second star
        starNum = 5
      else
        -- two stars from mips, perhaps (check if star 2 is disabled)
        if gBehaviorValues.MipsStar2Requirement ~= 255 then
          parse_stars(0, bhvData) -- call again with area set to 0; this normally doesn't happen
        end
        starNum = 4
      end
    end

    if (starNum > 0 and starNum < 8) and (
          not ROMHACK.game_exclude or not ROMHACK.game_exclude[PARSE_COURSE * 10 + starNum] or
          ROMHACK.game_exclude[PARSE_COURSE * 10 + starNum] == PARSE_AREA
        ) then
      custom_name = custom_name .. " (" .. starNum .. ")"

      if PARSE_PRINT then
        djui_chat_message_create(string.format("%s (C%d, L%d, A%d)", custom_name, PARSE_COURSE, PARSE_LEVEL, PARSE_AREA))
        print(custom_name, PARSE_COURSE, PARSE_AREA)
      end

      if not PARSE_FOUND_STARS[starNum] then
        PARSE_FOUND_STARS[starNum] = PARSE_AREA | STAR_APPLY_NO_ACTS
      else
        PARSE_FOUND_STARS[starNum] = PARSE_FOUND_STARS[starNum] & ~STAR_AREA_MASK
        PARSE_FOUND_STARS[starNum] = PARSE_FOUND_STARS[starNum] | (STAR_MULTIPLE_AREAS << (PARSE_AREA - 1))
      end

      if mini_invalid and not PARSE_MINI_EXCLUDE[starNum] then
        PARSE_MINI_EXCLUDE[starNum] = 1
      elseif PARSE_AREA ~= 1 and (not mini_invalid) then
        PARSE_MINI_EXCLUDE[starNum] = PARSE_AREA
      else
        PARSE_MINI_EXCLUDE[starNum] = 0
      end

      if ROMHACK.vagueName or PARSE_COURSE > 15 or PARSE_COURSE == 0 then
        PARSE_STAR_NAMES[PARSE_COURSE * 10 + starNum] = custom_name
      end
    end
  end
end

-- exteme edition and game area support, and sets minihunt level as beginning
function warp_beginning(returnInfo)
  local warpLevel, warpArea, warpAct, warpNode = 0, 0, 0, -1
  warpCooldown = 0
  if gGlobalSyncTable.mhMode == 2 and gGlobalSyncTable.mhState ~= 0 then
    local correctAct = gGlobalSyncTable.getStar

    local course = level_to_course[gGlobalSyncTable.gameLevel] or 0
    local area = (ROMHACK.mini_exclude and ROMHACK.mini_exclude[course * 10 + correctAct]) or 1
    if gGlobalSyncTable.ee then area = 2 end

    if correctAct == 7 then correctAct = 6 end
    if course == 0 then correctAct = 0 end
    warpLevel, warpArea, warpAct = gGlobalSyncTable.gameLevel, area, correctAct
  elseif gGlobalSyncTable.mhState == 0 and LEVEL_LOBBY and not ROMHACK.noLobby then
    gMarioStates[0].health = 0x880
    warpLevel, warpArea, warpAct = LEVEL_LOBBY, 1, 0 -- go to custom lobby!
  elseif entryArea ~= 1 or entryNode ~= 0 then
    warpLevel, warpArea, warpAct = gLevelValues.entryLevel, entryArea, 0
    warpNode = (entryNode == 0) and -1 or entryNode
  elseif gGlobalSyncTable.ee then
    gMarioStates[0].health = 0x880
    warpLevel, warpArea, warpAct = gLevelValues.entryLevel, 2, 0
  else
    gMarioStates[0].health = 0x880
    if not returnInfo then
      return warp_to_start_level()
    else
      warpLevel, warpArea, warpAct, warpNode = gLevelValues.entryLevel, 1, 0, 10
      if is_vanilla_like() and warpLevel == LEVEL_CASTLE_GROUNDS then
        warpNode = 3 -- death node
      end
    end
  end

  if warpLevel == 0 then return end

  if not returnInfo then
    if warpNode == -1 then
      return warp_to_level(warpLevel, warpArea, warpAct)
    else
      return warp_to_warpnode(warpLevel, warpArea, warpAct, warpNode)
    end
  end
  return warpLevel, warpArea, warpAct, warpNode
end

-- updates information when the game area is changed, such as the Exit To Castle level and such
entryArea = 1
entryNode = 0
function update_game_area(area)
  local data = ROMHACK and ROMHACK.gameAreaData and ROMHACK.gameAreaData[area+1]
  if not data then return end

  gLevelValues.entryLevel = data.entryLevel
  entryNode = data.entryNode or 0
  entryArea = data.entryArea or 1
  gLevelValues.exitCastleArea = data.exitCastleArea or 1
  gLevelValues.exitCastleLevel = data.exitCastleLevel
  gLevelValues.exitCastleWarpNode = data.exitCastleWarpNode
  -- load only the category setting
  if network_is_server() then
    local fileName = string.gsub(gGlobalSyncTable.romhackFile, " ", "_")
    local toLoad = "starRun"
    if area ~= 0 then
      toLoad = tostring(area) .. "_" .. toLoad
    end
    if fileName ~= "vanilla" then
      toLoad = fileName .. "_" .. toLoad
    end
    local starRun = tonumber(mod_storage_load(toLoad)) or data.default_stars or ROMHACK.default_stars or -1
    gGlobalSyncTable.starRun = math.floor(starRun)
  end
end

-- checks if ROMHACK.ddd is set, either for vanilla or LM64
-- if checkDDD is true, it also checks if our game area has the ddd flag
function is_vanilla_like(checkDDD)
  if not (ROMHACK and ROMHACK.ddd) then return false end
  if checkDDD and gGlobalSyncTable.gameArea ~= 0 then
    return ROMHACK.gameAreaData and ROMHACK.gameAreaData[gGlobalSyncTable.gameArea+1] and ROMHACK.gameAreaData[gGlobalSyncTable.gameArea+1].ddd
  end
  return true
end

-- deletes certain objects when their star conditions are met
function deleteStarRoadStuff(m)
  local starCategory = gGlobalSyncTable.starRun or -1
  --if (gGlobalSyncTable.gameArea ~= 2) and (not gGlobalSyncTable.freeRoam) and (starCategory == -1 or starCategory > m.numStars) then return end -- only if have enough for run
  local np = gNetworkPlayers[0]
  if m.playerIndex ~= 0 or np.currCourseNum ~= COURSE_NONE then return end                                           -- only for local and in castle

  local obj = obj_get_first(OBJ_LIST_SURFACE)
  while obj do
    local objID = get_id_from_behavior(obj.behavior)
    local starsNeeded = 1000
    if objID == bhvSMSRStarDoor then
      starsNeeded = (obj.oBehParams >> 24)
    elseif objID == bhvSMSR30StarDoorWall then
      starsNeeded = 0 -- always erase
    elseif objID == bhvSMSRHiddenAt120Stars then
      starsNeeded = 65
      if gGlobalSyncTable.gameArea ~= 0 then
        local data = ROMHACK and ROMHACK.gameAreaData and ROMHACK.gameAreaData[gGlobalSyncTable.gameArea + 1]
        if data and data.doorCost and data.doorCost[starsNeeded] then
          starsNeeded = data.doorCost[starsNeeded]
        end
      end
    elseif objID == bhvMhCustomDoor then
      -- adjust 30 star doors to actually be 30 star doors
      if (obj.oBehParams >> 24) == 4 then
        local newCount = 30
        if gGlobalSyncTable.gameArea ~= 0 then
          local data = ROMHACK and ROMHACK.gameAreaData and ROMHACK.gameAreaData[gGlobalSyncTable.gameArea + 1]
          if data and data.doorCost and data.doorCost[newCount] then
            newCount = data.doorCost[newCount]
          end
        end

        obj.oBehParams = (obj.oBehParams & 0xFFFFFF) | (newCount << 24)
        if newCount == 8 then
          obj_set_model_extended(obj, E_MODEL_CASTLE_DOOR_1_STAR)
        end
      end
    end
    if starsNeeded ~= 1000 and starCategory ~= -1 and starsNeeded > starCategory then
      starsNeeded = starCategory
    end
    if (starsNeeded ~= 1000 and (gGlobalSyncTable.freeRoam or m.numStars >= starsNeeded)) then
      print("deleted", objID, get_behavior_name_from_id(objID), (obj.oBehParams >> 24))
      obj_mark_for_deletion(obj)
      return
    end
    obj = obj_get_next(obj)
  end
end

-- sets up the minihunt blacklist using an encrypted value and mini_exclude
function setup_mini_blacklist(blacklistData)
  mini_blacklist = {}
  if blacklistData and blacklistData ~= "none" then
    decrypt_black(blacklistData)
  elseif ROMHACK.mini_exclude then
    for id, value in pairs(ROMHACK.mini_exclude) do
      if value == 1 then
        mini_blacklist[id] = 1
      end
    end
  end
end

-- takes the encrypted data and returns the blacklist
function decrypt_black(blacklistData)
  mini_blacklist = {}
  local i = 0
  for course = 1, 24 do -- exclude ending
    if string.len(blacklistData) <= i - 1 then break end

    local courseData = tonumber("0x" .. string.sub(blacklistData, i + 1, i + 2)) or 0
    --print(courseData)
    for act = 1, 7 do
      if (courseData & 2 ^ (act - 1)) ~= 0 then
        mini_blacklist[course * 10 + act] = 1
        --djui_chat_message_create(tostring(courseData))
      end
    end
    -- unused because we don't store course 0
    --[[if (courseData & 128) ~= 0 then -- use star 8 of other courses as course 0
      mini_blacklist[course] = 1
      --print(0,course)
    end]]
    i = i + 2
  end
end

-- encrypts the blacklist into one number value
function encrypt_black()
  local fullEncrypt = ""
  local encrypted = "00"
  for course = 1, 24 do -- exclude ending
    local courseData = 0
    for act = 1, 7 do
      local doCourse = course
      local doAct = act
      -- unused because we don't store course 0
      --[[if act == 8 then -- use act 8 for course 0
        if course > 7 then break end
        doAct = course
        doCourse = 0
      end]]
      if mini_blacklist[doCourse * 10 + doAct] then
        courseData = courseData + 2 ^ (act - 1)
      end
    end
    --djui_chat_message_create(string.format("%02x",courseData))
    fullEncrypt = fullEncrypt .. string.format("%02x", courseData)
    if courseData ~= 0 then
      encrypted = fullEncrypt
    end
  end
  return encrypted
end

-- runs for all players unless dontReload is true
function on_black_changed(tag, oldVal, newVal)
  if oldVal ~= newVal and (not dontReload) then
    print("updated blacklist")
    setup_mini_blacklist(newVal)
  elseif dontReload then
    dontReload = false
  end
end

hook_on_sync_table_change(gGlobalSyncTable, "blacklistData", "blacklist_change", on_black_changed)

-- stars to track (replicas and such are in romhack_data)
star_ids = {
  [id_bhvStar] = "bhvStar",
  [id_bhvSpawnedStar] = "bhvSpawnedStar",
  [id_bhvSpawnedStarNoLevelExit] = "bhvSpawnedStarNoLevelExit",
  [id_bhvStarSpawnCoordinates] = "bhvStarSpawnCoordinates",
}

-- other sources for stars (again, more in romhack_data)
-- The second argument is:
-- TRUE if the 2nd byte doesn't matter
-- 0xFF for any non-zero value for the second byte
-- some other number value for the second byte being equal to such
-- exclamation boxes, KTQ, toad, mips, and piranha plants are special cases
star_sources = {
  [id_bhvKingBobomb] = { true, "Big Battle with King Bob-Omb" },
  [id_bhvWhompKingBoss] = { true, "Chip Off Whomp's Block" },
  [id_bhvHiddenRedCoinStar] = { true, "Find The Red Coins" },
  [id_bhvBowserCourseRedCoinStar] = { true, "Find The Red Coins" },
  [id_bhvHiddenStar] = { true, "5 Hidden Secrets" },
  [id_bhvTuxiesMother] = { true, "Li'l Penguin Lost" },
  [id_bhvWigglerHead] = { true, "Make Wiggler Squirm" },
  [id_bhvEyerokBoss] = { true, "Hand to Hand with Eyerok" },
  [id_bhvBalconyBigBoo] = { true, "Bout with Big Boo" },
  [id_bhvGhostHuntBigBoo] = { true, "Go On A Ghost Hunt" },
  [id_bhvMerryGoRoundBooManager] = { true, "Merry Go Round" },
  [id_bhvTreasureChests] = { true, "Puzzle of the Chests" },
  [id_bhvTreasureChestsJrb] = { true, "Puzzle of the Chests" },
  [id_bhvRacingPenguin] = { true, "Penguin Race" },
  [id_bhvUnagi] = { 0x01, "Can The Eel Come Out To Play?" }, -- Is this correct?
  [id_bhvSnowmansHead] = { true, "Snowman's Lost His Head" },
  [id_bhvBigBully] = { true, "Battle the Big Bully" },
  [id_bhvBigChillBully] = { true, "Chill With The Bully" },
  [id_bhvBigBullyWithMinions] = { true, "Bully The Bullies" },
  [id_bhvCcmTouchedStarSpawn] = { true, "Sliding Star" },
  [id_bhvMrI] = { 0xFF, "Eye To Eye" }, -- any set byte
  [id_bhvMantaRay] = { true, "The Manta Ray's Reward" },
  [id_bhvJetStreamRingSpawner] = { true, "Through The Jet Stream" },
  [id_bhvKlepto] = { 0xFF, "In The Talons Of The Big Bird" },      -- any set byte
  [id_bhvUkikiCage] = { true, "Mystery Of The Monkey Cage" },
  [id_bhvFirePiranhaPlant] = { 0xFF, "Pluck The Piranha Plants" }, -- any set byte
}

-- thank you sunk
exclamation_box_valid = {
  [8] = true,
  [10] = true,
  [11] = true,
  [12] = true,
  [13] = true,
  [14] = true
}

-- I wish there was a better way to do this
course_to_level = {
  [COURSE_NONE] = LEVEL_CASTLE_GROUNDS, -- Course 0 (note that courtyard and inside are also course 0); won't appear in minihunt
  [COURSE_BOB] = LEVEL_BOB,             -- Course 1
  [COURSE_WF] = LEVEL_WF,               -- Course 2
  [COURSE_JRB] = LEVEL_JRB,             -- Course 3
  [COURSE_CCM] = LEVEL_CCM,             -- Course 4
  [COURSE_BBH] = LEVEL_BBH,             -- Course 5
  [COURSE_HMC] = LEVEL_HMC,             -- Course 6
  [COURSE_LLL] = LEVEL_LLL,             -- Course 7
  [COURSE_SSL] = LEVEL_SSL,             -- Course 8
  [COURSE_DDD] = LEVEL_DDD,             -- Course 9
  [COURSE_SL] = LEVEL_SL,               -- Course 10
  [COURSE_WDW] = LEVEL_WDW,             -- Course 11
  [COURSE_TTM] = LEVEL_TTM,             -- Course 12
  [COURSE_THI] = LEVEL_THI,             -- Course 13
  [COURSE_TTC] = LEVEL_TTC,             -- Course 14
  [COURSE_RR] = LEVEL_RR,               -- Course 15
  [COURSE_BITDW] = LEVEL_BITDW,         -- Course 16 (also bowser 1)
  [COURSE_BITFS] = LEVEL_BITFS,         -- Course 17 (also bowser 2)
  [COURSE_BITS] = LEVEL_BITS,           -- Course 18 (also bowser 3)
  [COURSE_PSS] = LEVEL_PSS,             -- Course 19
  [COURSE_COTMC] = LEVEL_COTMC,         -- Course 20
  [COURSE_TOTWC] = LEVEL_TOTWC,         -- Course 21
  [COURSE_VCUTM] = LEVEL_VCUTM,         -- Course 22
  [COURSE_WMOTR] = LEVEL_WMOTR,         -- Course 23
  [COURSE_SA] = LEVEL_SA,               -- Course 24
  [COURSE_CAKE_END] = LEVEL_ENDING,     -- Course 25 (will not appear in MiniHunt)
}
string_to_level = {
  ["grounds"] = LEVEL_CASTLE_GROUNDS,
  ["castle"] = LEVEL_CASTLE,
  ["courtyard"] = LEVEL_CASTLE_COURTYARD,
  ["bob"] = LEVEL_BOB,     -- Course 1
  ["wf"] = LEVEL_WF,       -- Course 2
  ["jrb"] = LEVEL_JRB,     -- Course 3
  ["ccm"] = LEVEL_CCM,     -- Course 4
  ["bbh"] = LEVEL_BBH,     -- Course 5
  ["hmc"] = LEVEL_HMC,     -- Course 6
  ["lll"] = LEVEL_LLL,     -- Course 7
  ["ssl"] = LEVEL_SSL,     -- Course 8
  ["ddd"] = LEVEL_DDD,     -- Course 9
  ["sl"] = LEVEL_SL,       -- Course 10
  ["wdw"] = LEVEL_WDW,     -- Course 11
  ["ttm"] = LEVEL_TTM,     -- Course 12
  ["thi"] = LEVEL_THI,     -- Course 13
  ["ttc"] = LEVEL_TTC,     -- Course 14
  ["rr"] = LEVEL_RR,       -- Course 15
  ["bitdw"] = LEVEL_BITDW, -- Course 16
  ["b1"] = LEVEL_BOWSER_1,
  ["bitfs"] = LEVEL_BITFS, -- Course 17
  ["b2"] = LEVEL_BOWSER_2,
  ["bits"] = LEVEL_BITS,   -- Course 18
  ["b3"] = LEVEL_BOWSER_3,
  ["pss"] = LEVEL_PSS,     -- Course 19
  ["cotmc"] = LEVEL_COTMC, -- Course 20
  ["totwc"] = LEVEL_TOTWC, -- Course 21
  ["vcutm"] = LEVEL_VCUTM, -- Course 22
  ["wmotr"] = LEVEL_WMOTR, -- Course 23
  ["sa"] = LEVEL_SA,       -- Course 24
  ["end"] = LEVEL_ENDING,  -- Course 25
}
string_to_course = {
  ["grounds"] = COURSE_NONE,
  ["castle"] = COURSE_NONE,
  ["courtyard"] = COURSE_NONE,
  ["bob"] = COURSE_BOB,      -- Course 1
  ["wf"] = COURSE_WF,        -- Course 2
  ["jrb"] = COURSE_JRB,      -- Course 3
  ["ccm"] = COURSE_CCM,      -- Course 4
  ["bbh"] = COURSE_BBH,      -- Course 5
  ["hmc"] = COURSE_HMC,      -- Course 6
  ["lll"] = COURSE_LLL,      -- Course 7
  ["ssl"] = COURSE_SSL,      -- Course 8
  ["ddd"] = COURSE_DDD,      -- Course 9
  ["sl"] = COURSE_SL,        -- Course 10
  ["wdw"] = COURSE_WDW,      -- Course 11
  ["ttm"] = COURSE_TTM,      -- Course 12
  ["thi"] = COURSE_THI,      -- Course 13
  ["ttc"] = COURSE_TTC,      -- Course 14
  ["rr"] = COURSE_RR,        -- Course 15
  ["bitdw"] = COURSE_BITDW,  -- Course 16
  ["b1"] = COURSE_BITDW,
  ["bitfs"] = COURSE_BITFS,  -- Course 17
  ["b2"] = COURSE_BITFS,
  ["bits"] = COURSE_BITS,    -- Course 18
  ["b3"] = COURSE_BITS,
  ["pss"] = COURSE_PSS,      -- Course 19
  ["cotmc"] = COURSE_COTMC,  -- Course 20
  ["totwc"] = COURSE_TOTWC,  -- Course 21
  ["vcutm"] = COURSE_VCUTM,  -- Course 22
  ["wmotr"] = COURSE_WMOTR,  -- Course 23
  ["sa"] = COURSE_SA,        -- Course 24
  ["end"] = COURSE_CAKE_END, -- Course 25
}
level_to_course = {
  [LEVEL_CASTLE_GROUNDS] = COURSE_NONE,   -- Course 0
  [LEVEL_CASTLE] = COURSE_NONE,           -- Course 0
  [LEVEL_CASTLE_COURTYARD] = COURSE_NONE, -- Course 0
  [LEVEL_BOB] = COURSE_BOB,               -- Course 1
  [LEVEL_WF] = COURSE_WF,                 -- Course 2
  [LEVEL_JRB] = COURSE_JRB,               -- Course 3
  [LEVEL_CCM] = COURSE_CCM,               -- Course 4
  [LEVEL_BBH] = COURSE_BBH,               -- Course 5
  [LEVEL_HMC] = COURSE_HMC,               -- Course 6
  [LEVEL_LLL] = COURSE_LLL,               -- Course 7
  [LEVEL_SSL] = COURSE_SSL,               -- Course 8
  [LEVEL_DDD] = COURSE_DDD,               -- Course 9
  [LEVEL_SL] = COURSE_SL,                 -- Course 10
  [LEVEL_WDW] = COURSE_WDW,               -- Course 11
  [LEVEL_TTM] = COURSE_TTM,               -- Course 12
  [LEVEL_THI] = COURSE_THI,               -- Course 13
  [LEVEL_TTC] = COURSE_TTC,               -- Course 14
  [LEVEL_RR] = COURSE_RR,                 -- Course 15
  [LEVEL_BITDW] = COURSE_BITDW,           -- Course 16
  [LEVEL_BOWSER_1] = COURSE_BITDW,        -- Course 16
  [LEVEL_BITFS] = COURSE_BITFS,           -- Course 17
  [LEVEL_BOWSER_2] = COURSE_BITFS,        -- Course 17
  [LEVEL_BITS] = COURSE_BITS,             -- Course 18
  [LEVEL_BOWSER_3] = COURSE_BITS,         -- Course 18
  [LEVEL_PSS] = COURSE_PSS,               -- Course 19
  [LEVEL_COTMC] = COURSE_COTMC,           -- Course 20
  [LEVEL_TOTWC] = COURSE_TOTWC,           -- Course 21
  [LEVEL_VCUTM] = COURSE_VCUTM,           -- Course 22
  [LEVEL_WMOTR] = COURSE_WMOTR,           -- Course 23
  [LEVEL_SA] = COURSE_SA,                 -- Course 24
  [LEVEL_ENDING] = COURSE_CAKE_END,       -- Course 25 (will not appear in MiniHunt)
}
