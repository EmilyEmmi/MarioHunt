romhack_data["vanilla"] = {
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
        [84] = 1, -- Stand Tall On Four Pillars (too annoying)
        [45] = 1, -- Snowman's Lost His Head (inconsistent)
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
        {              -- default
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
                    -- formatted as oid, model, x, y, z, params, warp level, warp area
                    { id_bhvWarp, E_MODEL_NONE, 2000, 819, -1700, 0, LEVEL_COTMC, 1 },
                },
                [261] = { -- Courtyard
                    { id_bhvWaterLevelPillar, E_MODEL_CASTLE_WATER_LEVEL_PILLAR, 3300,  400, -2800 },
                    { id_bhvWaterLevelPillar, E_MODEL_CASTLE_WATER_LEVEL_PILLAR, -3300, 400, -2800 },
                },
            },
            warpNodeOverride = {
                [63] = {                      -- warps from COTMC
                    [0x34] = { LEVEL_CASTLE, 1, 0x27 }, -- star
                    [0x66] = { LEVEL_CASTLE, 1, 0x28 }, -- death
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
                    -- formatted as oid, model, x, y, z, params, warp level, warp area
                    { id_bhvMHWingCapWarp, E_MODEL_TOTWC_ENTRANCE, -765, -1279, 2386, 0, LEVEL_TOTWC, 1 },
                },
                [161] = { -- Grounds
                    -- pipe to basement (in case someone gets sent to grounds without moat drained)
                    { id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, 0, 803, -2800, 0, LEVEL_CASTLE, 3 },
                },
            },
            warpNodeOverride = {
                [61] = {                      -- warps from TOTWC
                    [0x26] = { LEVEL_CASTLE, 3, 0x0A }, -- star
                    [0x23] = { LEVEL_CASTLE, 3, 0x0A }, -- death
                    [0x20] = { LEVEL_CASTLE, 3, 0x0A }, -- flying OOB
                },
                [161] = {                     -- warps from COTMC + Castle Death
                    [0x14] = { LEVEL_CASTLE, 3, 0x66 }, -- falling in COTMC
                    [0x03] = { LEVEL_CASTLE, 3, 0x0A }, -- castle death
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
                [70] = 48,
            },
            extraObject = {
                [62] = { -- Upper Floor
                    -- formatted as oid, model, x, y, z, params, warp level, warp area
                    { id_bhvMHWingCapWarp, E_MODEL_TOTWC_ENTRANCE, 1660, 2765, 6630, 0, LEVEL_TOTWC, 1 },
                    { id_bhvWarpPipe,      E_MODEL_NONE,           3550, 1408, 3447, 0, LEVEL_VCUTM, 1 }, -- real pipe (invisible)
                    { id_bhvWarpPipe,      E_MODEL_BITS_WARP_PIPE, 5113, 1408, 3447, 0 }, -- pipe in mirror
                },
                [112] = {                                                        -- Wet-Dry World
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, 1967, -2559, 2627, 0, LEVEL_COTMC, 1 },
                },
                [161] = { -- Grounds
                    -- pipe to upper floor (in case someone gets sent to grounds)
                    { id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, 0, 803, -2800, 0, LEVEL_CASTLE, 3 },
                },
            },
            warpNodeOverride = {
                [61] = {                      -- warps from TOTWC
                    [0x26] = { LEVEL_CASTLE, 2, 0x38 }, -- star
                    [0x23] = { LEVEL_CASTLE, 2, 0x6D }, -- death
                    [0x20] = { LEVEL_CASTLE, 2, 0x38 }, -- flying OOB
                },
                [63] = {                      -- warps from COTMC
                    [0x34] = { LEVEL_CASTLE, 2, 0x32 }, -- star
                    [0x66] = { LEVEL_CASTLE, 2, 0x64 }, -- death
                },
                [161] = {                     -- warps from WMOTR, VCUTM, and COTMC (+ castle death)
                    [0x0A] = { LEVEL_CASTLE, 2, 0x6D }, -- falling OOB in WMOTR (uses death warp instead)
                    [0x08] = { LEVEL_CASTLE, 2, 0x36 }, -- star in VCUTM
                    [0x07] = { LEVEL_CASTLE, 2, 0x68 }, -- death in VCUTM
                    [0x06] = { LEVEL_CASTLE, 2, 0x68 }, -- falling in VCUTM
                    [0x14] = { LEVEL_CASTLE, 2, 0x64 }, -- falling in COTMC
                    [0x03] = { LEVEL_CASTLE, 2, 0x01 }, -- castle death
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
                    -- formatted as oid, model, x, y, z, params, warp level, warp area
                    { id_bhvMHWingCapWarp,    E_MODEL_TOTWC_ENTRANCE, 1660, 2765, 6630, 0, LEVEL_TOTWC, 1 },
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX,      -200, 2203, 4781, 0 },
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX,      -973, 1153, 2621, 0 },
                },
                [161] = { -- Grounds
                    -- pipe to upper floor (in case someone gets sent to grounds)
                    { id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, 0, 803, -2800, 0, LEVEL_CASTLE, 3, 53 },
                },
            },
            warpNodeOverride = {
                [61] = {                      -- warps from TOTWC
                    [0x26] = { LEVEL_CASTLE, 2, 0x38 }, -- star
                    [0x23] = { LEVEL_CASTLE, 2, 0x6D }, -- death
                    [0x20] = { LEVEL_CASTLE, 2, 0x38 }, -- flying OOB
                },
                [161] = {                     -- warps from WMOTR (+ castle death)
                    [0x0A] = { LEVEL_CASTLE, 2, 0x6D }, -- falling OOB in WMOTR (uses death warp instead)
                    [0x03] = { LEVEL_CASTLE, 2, 0x67 }, -- castle death
                },
            },
        },
    },

    minimap_data = {
        [91] = { "bob-map" }, -- BOB area 1
        [241] = { "wf-map" }, -- WF area 1
        [161] = { "cg-map" }, -- CG area 1
        [61] = { "ic-map" },  -- IC area 1
        [62] = { "ica-map" }, -- IC area 2
        [63] = { "icb-map" }, -- IC area 3
        [171] = { "fb-map" }, -- B1 area 1
        [301] = { "fbb-map" }, -- B1 area 2
        [191] = { "bfs-map" }, -- B2 area 1
        [331] = { "bfsb-map" }, -- B2 area 2
        [51] = { "ccm-map" }, -- CCM area 1
        [52] = { "ccms-map" }, -- CCM area 1
        [121] = { "jrb-map" }, -- JRB area 1
        [122] = { "jrbs-map" }, -- JRB area 2
        [271] = { "pss-map" }, -- PSS area 1
        [41] = { "bbh-map" }, -- BBH area 1
        [261] = { "cc-map" }, -- BBH area 1
        [71] = { "hmc-map" }, -- HMC area 1
        [221] = { "lll-map" }, -- LLL area 1
        [222] = { "lllv-map" }, -- LLL area 2
        [81] = { "ssl-map" }, -- SSL area 1
        [82] = { "sslp-map" }, -- SSL area 2
        [83] = { "sslie-map" }, -- SSL area 2
        [231] = { "ddd-map" }, -- SSL area 2
        [232] = { "ddds-map" }, -- SSL area 2
        [101] = { "sl-map" }, -- SL area 1
        [102] = { "sli-map" }, -- SL area 2
        [111] = { "wdw-map" }, -- WDW area 1
        [112] = { "wdwu-map" }, -- WDW area 2
        [361] = { "ttm-map" }, -- TTM area 1
        -- [362] = { "ttms-map" },    -- TTM area 2 (removed due to inaccuracy)
        -- [363] = { "ttms-map" },    -- TTM area 3 (removed due to inaccuracy)
        -- [364] = { "ttms-map" },    -- TTM area 4 (removed due to inaccuracy)
        [131] = { "thih-map" }, -- THI area 1
        [132] = { "thit-map" }, -- THI area 2
        [133] = { "thim-map" }, -- THI area 3
        [141] = { "ttc-map" }, -- TTC area 1
        [151] = { "rr-map" },  -- RR area 1
        [201] = { "tsa-map" }, -- SA area 1
        [281] = { "btw-map" }, -- MCL area 1
        [311] = { "otr-map" }, -- RC area 1
        [211] = { "bits-map" }, -- BITS area 1
        [341] = { "bitsb-map" }, -- bitsb area 1
        [181] = { "vcutm-map" }, -- vcutm area 1
        [291] = { "totwc-map" }, -- totwc area 1
    },

    actlessData = {
        [LEVEL_BOB] = {{
            -- act 1
            {
                id = id_bhvKingBobomb,
                acts = ACT_1,
            },
            {
                id = id_bhvBobombBuddy,
                oBehParams = (DIALOG_001 << 16),
                acts = ACT_1,
            },
            {
                id = id_bhvBobombBuddy,
                oBehParams = (DIALOG_002 << 16),
                acts = ACT_1,
            },
            {
                id = id_bhvWaterBombCannon,
                oBehParams2ndByte = 1,
                acts = ACT_1,
            },
            {
                id = id_bhvBobBowlingBallSpawner,
                acts = (ACT_1 | ACT_2),
            },

            -- act 2
            {
                id = id_bhvKoopa,
                oBehParams2ndByte = KOOPA_BP_KOOPA_THE_QUICK_BOB,
                acts = ACT_2,
            },
            {
                id = id_bhvKoopaFlag,
                acts = ACT_2,
            },
            {
                id = id_bhvPitBowlingBall,
                oSyncID = 120,
                acts = NOT_ACT_1,
            },
            {
                id = id_bhvBobombBuddy,
                oBehParams = (DIALOG_003 << 16),
                acts = NOT_ACT_1,
            },
            {
                id = id_bhvBobombBuddyOpensCannon,
                acts = NOT_ACT_1,
            },
            {
                id = id_bhvCannonClosed,
                oSyncID = 180,
                acts = NOT_ACT_1,
            },

            -- act 3+
            {
                id = {id_bhvKoopa, id_bhvTtmBowlingBallSpawner},
                oBehParams2ndByte = KOOPA_BP_NORMAL,
                acts = (ACT_3 | ACT_4 | ACT_5 | ACT_6),
            },
        }},
        [LEVEL_WF] = {{
            -- act 1
            {
                id = id_bhvWhompKingBoss,
                acts = ACT_1,
            },

            -- act 2
            {
                id = {id_bhvKickableBoard, id_bhvBulletBill, id_bhvBulletBillCannon},
                acts = NOT_ACT_1,
            },
            {
                id = id_bhvStar,
                oBehParams = 0x01000000,
                acts = NOT_ACT_1,
            },
            {
                id = id_bhvTower,
                pushRadius = 600,
                pushExtentY = 1740,
                acts = NOT_ACT_1,
            },
            {
                id = {id_bhv1Up, id_bhvTowerPlatformGroup, id_bhvTowerDoor, id_bhvWfSolidTowerPlatform, id_bhvWfSlidingTowerPlatform, id_bhvWfElevatorTowerPlatform},
                acts = NOT_ACT_1,
            },

            -- act 3+
            {
                id = {id_bhvHoot, id_bhvBobombBuddyOpensCannon},
                acts = (ACT_3 | ACT_4 | ACT_5 | ACT_6),
            },
        }},
        [LEVEL_JRB] = {
            [1] = {
                -- act 1
                {
                    id = {id_bhvSunkenShipPart, id_bhvSunkenShipPart2, id_bhvInSunkenShip, id_bhvInSunkenShip2},
                    acts = ACT_1,
                },
                {
                    id = id_bhvUnagi,
                    oBehParams2ndByte = 0,
                    acts = ACT_1,
                },

                -- act 2
                {
                    id = {id_bhvShipPart3, id_bhvJrbSlidingBox, id_bhvInSunkenShip3, id_bhvJetStream, id_bhvBobombBuddyOpensCannon},
                    acts = NOT_ACT_1,
                },
                {
                    id = id_bhvStar,
                    oBehParams = 0x05000000,
                    acts = NOT_ACT_1,
                },
                {
                    id = id_bhvUnagi,
                    oBehParams2ndByte = 1,
                    acts = ACT_2,
                },

                -- act 3+
                {
                    id = id_bhvUnagi,
                    oBehParams2ndByte = 2,
                    acts = (ACT_3 | ACT_4 | ACT_5 | ACT_6),
                },
            },
            [2] = {
                extra = { -- to get out of ship
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, 798, 942, 2689, 0, LEVEL_JRB, 1 },
                },
            }
        },
        [LEVEL_CCM] = {
            [1] = {
                -- act 5+ (this normally doesn't appear in act 6 but it looks weird that way)
                {
                    id = id_bhvSnowmansBottom,
                    acts = (ACT_5 | ACT_6),
                },
            },
            [2] = {
                -- act 2+
                {
                    id = id_bhvRacingPenguin,
                    acts = NOT_ACT_1,
                },
            },
        },
        [LEVEL_BBH] = {{
            -- act 1
            {
                id = {id_bhvGhostHuntBoo, id_bhvGhostHuntBigBoo, id_bhvBooBossSpawnedBridge},
                acts = ACT_1,
            },

            -- act 2+
            {
                id = {id_bhvHiddenStaircaseStep, id_bhvFlamethrower, id_bhvMerryGoRoundBooManager},
                acts = NOT_ACT_1,
            },
            {
                id = id_bhvBoo, -- There's 1 actless boo but idc
                acts = NOT_ACT_1,
            },
        }},
        [LEVEL_LLL] = {
            [1] = {
                -- act 5+
                {
                    id = id_bhvExclamationBox,
                    oBehParams2ndByte = 3,
                    acts = (ACT_5 | ACT_6),
                },
            },
            [2] = {
                extra = { -- to get out of volcano
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, -1650, 96, 596, 0, LEVEL_LLL, 1 },
                },
            },
        },
        [LEVEL_SSL] = {
            [1] = {
                -- act 1
                {
                    id = id_bhvKlepto,
                    oBehParams2ndByte = 1,
                    acts = ACT_1,
                },

                -- act 2
                {
                    id = id_bhvKlepto,
                    oBehParams2ndByte = 0,
                    acts = NOT_ACT_1,
                },

                -- act 4+
                {
                    id = id_bhvTweester,
                    oBehParams2ndByte = 0x19,
                    acts = (ACT_4 | ACT_5 | ACT_6),
                },
            },
            [2] = {
                extra = { -- to get out of pyramid
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, 0, 0, 6708, 0, LEVEL_SSL, 1 },
                },
            },
            [3] = {
                extra = { -- to get out of arena
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, 0, -1176, -3904, 0, LEVEL_SSL, 1 },
                },
            },
        },
        [LEVEL_DDD] = {{
            -- act 2+
            {
                id = id_bhvMantaRay,
                acts = NOT_ACT_1,
            },
        }},
        -- Not much point in doing TTM; if you get scale the mountain, you're already at monkey cage
        [LEVEL_THI] = {
            [1] = { -- huge island only
                -- act 3 only (ktq)
                {
                    id = id_bhvKoopa,
                    oBehParams2ndByte = KOOPA_BP_KOOPA_THE_QUICK_THI,
                    acts = ACT_3,
                },
                {
                    id = id_bhvKoopaFlag,
                    acts = ACT_3,
                },
            },
            [3] = {
                extra = { -- to get out of arena
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, 0, 1843, 0, 0, LEVEL_THI, 1, 11 },
                },
            },
        },
    },

    runner_victory = function(m)
        return m.action == ACT_JUMBO_STAR_CUTSCENE
    end,
}
