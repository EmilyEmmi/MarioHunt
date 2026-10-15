romhack_data["moonshine"] = {
    name = "SM64 Moonshine",
    default_stars = 50, -- there is no end, really
    max_stars = 50,
    no_bowser = true,
    requirements = {
        [LEVEL_LLL] = 8,                     -- Sweet Sweet Rush
        [LEVEL_BITS] = 30,                   -- Down Street
    },
    starColor = { r = 92, g = 255, b = 92 }, -- all moons are green
    heartReplace = true,                     -- replaces all hearts with 1ups
    isMoonshine = true,                      -- changes hud elements
    coinColor = { r = 0, g = 255, b = 0 },   -- green coins

    star_data = {
        [COURSE_NONE] = { 0, 8 },             -- only toad star 2
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
        [COURSE_BITS] = { 8, 8 }, -- Moonshine
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
}
