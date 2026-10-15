-- Used for any unsupported romhacks
romhack_data.default = {
    name = "Default",
    default_stars = -1,
    max_stars = 255,
    requirements = { [LEVEL_BOWSER_3] = 255, [LEVEL_ENDING] = 255 }, -- block off Bowser 3 until needed stars are collected
    parseStars = true,                                               -- automatically generate star list
    checkAreaWarp = true,

    star_data = {}, -- assume every secret stage has 1 star

    runner_victory = function(m)
        local np = gNetworkPlayers[m.playerIndex]
        return m.action == ACT_JUMBO_STAR_CUTSCENE or np.currCourseNum == COURSE_CAKE_END
    end,
}
