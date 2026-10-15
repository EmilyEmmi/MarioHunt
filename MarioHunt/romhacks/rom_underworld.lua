romhack_data["underworld"] = {
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
}
