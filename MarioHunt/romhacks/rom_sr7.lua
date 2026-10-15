romhack_data["sr7-coop-port"] = {
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

    -- warps for ktq
    special_run = function(m, gotStar)
        if m.playerIndex ~= 0 then return end
        if gotStar == 2 and gNetworkPlayers[0].currLevelNum == LEVEL_WMOTR then
            warp_to_warpnode(LEVEL_WMOTR, 1, 0, 0xf0)
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
}
