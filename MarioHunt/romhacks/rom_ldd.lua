romhack_data["ldd"] = {
    name = "Lug's Delightful Dioramas",
    default_stars = 64,
    max_stars = 74,

    starColor = { r = 255, g = 255, b = 255 }, -- stars are white
    disableNonStop = true,                     -- omm actually disables non stop for this hack
    no_bowser = true,                          -- no bowser.
    final = -1,

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
        [LEVEL_HMC] = 30, -- Scorching Jaws
        [LEVEL_CASTLE_COURTYARD] = 8,
        [LEVEL_BITFS] = 50, -- Spectral Spectacle
        [LEVEL_BITS] = 51, -- A Sweet Delight
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
}

-- Comet
romhack_data["ldd_green_comet"] = {
    name = "LDD - Green Comet",
    inherit = "ldd",
    default_stars = 42,
    max_stars = 80,
    requirements = {
        [LEVEL_HMC] = 0, -- Scorching Jaws
        [LEVEL_CASTLE_COURTYARD] = 0,
        [LEVEL_BITFS] = 0, -- Spectral Spectacle
        [LEVEL_BITS] = 0, -- A Sweet Delight
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
}
