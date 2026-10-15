romhack_data["sapphire"] = {
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
}

romhack_data["SM64 Sapphire Green Comet"] = {
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
}
