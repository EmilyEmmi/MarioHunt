romhack_data["luigis-mansion-64"] = { -- TODO: Make WMOTR accessible
    name = "Luigi's Mansion 64",
    inherit = "vanilla",              -- this actually causes the minimap to be inheritted too, which is... fine, I guess
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
}
