romhack_data["coop-mods-green-stars"] = {
    name = "SM64: The Green Stars",
    default_stars = 80,
    max_stars = 131,
    ommColorStar = true,
    requirements = {
        [LEVEL_BBH] = 4, -- Fiery Factory
        [LEVEL_BITDW] = 15,
        [LEVEL_LLL] = 20, -- Giant Overgrown Garden
        [LEVEL_DDD] = 20, -- Sandy Seaside Bay
        [LEVEL_SL] = 30, -- Molten Magma Galaxy
        [LEVEL_BITFS] = 40,
        [LEVEL_TTM] = 50, -- Perilous Cliffs
        [LEVEL_RR] = 65, -- Rainbow Star Haven
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
}
