romhack_data["Ztar Attack 2"] = {
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
        [COURSE_CAKE_END] = { 0, 0, 8 },  -- The End
        [COURSE_NONE] = { 0, 0, 0, 8 },   -- has mips
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
        [191] = "Quizmaster",             -- The Super Quiz
        [251] = "Thanks For Playing!",    -- The End
        [253] = "The Princess's Present", -- The End
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
        {              -- default
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
}
