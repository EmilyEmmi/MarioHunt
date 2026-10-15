romhack_data["B3313"] = {
    name = "B3313 v0.7",
    default_stars = 30, -- just a number
    max_stars = 120,    -- unknown how many stars there actually are (auto-generated)
    vagueName = true,   -- the names are all identical, just use course numbers
    -- no requirements
    parseStars = true,  -- automatically generate star list (this hack is too large I can't be bothered)
    stalk = true,       -- the hack is confusing, so let people warp
    final = -1,
    noCapDefault = true,
    checkAreaWarp = true,

    star_data = {}, -- filled when parsed

    -- overrides the generated information
    game_exclude = {
        [34] = 1, -- is area 3 meant to appear?
        [73] = 1, -- prevent lava death

        [122] = 0, -- unobtainable (can't enter act 2)... but you CAN get this star in OMM

        -- test rooms
        [212] = 0,
        [213] = 0,
        [214] = 0,
        [215] = 0,
        [216] = 0,

        -- I don't think area 3 is meant to appear
        [132] = 7,
        [133] = 2,

        [117] = 0, -- same for this area
        [231] = 1, -- instant death
    },

    mini_exclude = {
        [124] = 1, -- this is literally "Mysterious Mountainside" unchanged; as such, too easy

        -- too easy (some are "Checkerboard")
        [132] = 1,
        [213] = 1,
        [152] = 1,
        [153] = 1,
        [44] = 1,
        [45] = 1,
    },

    starNames = {
        [151] = "Star (1)",           -- Manta Ray is not possible
        [211] = "5 Hidden Secrets (1)", -- Same here
    },

    -- wip (from b3313 wiki)
    levelNames = {
        [41] = "Whomp's Kingdom",
        [42] = "Whomp's Prison",
        [43] = "Whomps Fortress (beta)?", -- no stars; is similar to the correct one
        [44] = "King Whomp's Battle Arena",
        [45] = "Flower Fields",
        [46] = "Vanish Cap Under The Moat (beta)",

        [51] = "Jolly Roger Lagoon",
        [52] = "Orange Hall",
        [53] = "Test Level",
        [54] = "Checkerboard (C4)",
        [55] = "Holy Yellow Switch Palace",
        [56] = "Holy Yellow Switch Palace?", -- duplicate with wdw diamonds for some reason

        [71] = "Hazy Maze Cave (empty)",
        [72] = "Tick Tock Blocks",
        [73] = "Midnight Meadow",
        [74] = "Lethal Cavern",
        [75] = "Plains", -- couldn't find on wiki; probably unused
        [76] = "Cave City",
        [77] = "Click Clock Climb",

        [81] = "Desert Maze",
        [82] = "Shifted Sand Land",
        [83] = "Scary Sewer Maze",
        [84] = "Eyerok's Tomb",
        [85] = "Sandy Skyloft",
        [86] = "Scary Sewer Maze", -- shadow mario encounter
        [87] = "Scary Sewer Maze", -- death

        [91] = "Crimson Hallway",
        [92] = "3rd Floor (beta)",
        [93] = "athletic",
        [94] = "Bowser's Castle",
        [95] = "Fake Lobby",
        [96] = "Crescent Castle",
        [97] = "Goomba Hills",

        [101] = "Floating Hotel",
        [102] = "Haunted Castle Grounds",
        [103] = "Wing Cap by the Rainbow Highway",
        [104] = "Tower of the Wing Cap (beta)",
        [105] = "Rainbow Ride (beta)",
        [106] = "Vanish Cap within the Plexus",

        [111] = "Snow Slide (B-Roll)?", -- duplicate (is accessible?)
        [112] = "Snowman's Darkness",
        [113] = "Frosty Highlands?",  -- duplicate?
        [114] = "Cool, Cool Mountain (beta)",
        [115] = "Chief Chilly's Ring",
        [116] = "Cold, Cold Crevasse",
        [117] = "Chroma Tundra",

        [121] = "Bob-Omb River",
        [122] = "Big Bob-Omb's Fortress?", -- duplicate with fog
        [123] = "Piranha Plant Garden",
        [124] = "Minion Base?",          -- duplicate with different skybox
        [125] = "Piranha's Igloo",

        [131] = "Castle Grounds",
        [132] = "Bob-Omb Tower",
        [133] = "Creepy Cove?", -- Seems to be a duplicate
        [134] = "Grassy Highlands",
        [135] = "Minion Base",
        [136] = "Peach's Cell",
        [137] = "Peach's Cell",

        [141] = "Big Boo's Haunted Forest",
        [142] = "Dark Lobby",
        [143] = "Plexal Lobby",
        [144] = "Clock Hall",
        [145] = "Big Boo's Fortress",
        [146] = "Plexal Hallway",
        [147] = "???'s Floor", -- both peach/bowser floor are here

        [151] = "Jolly Roger Bay (beta)",
        [152] = "Dead Fortress", -- empty wiggler's forest fortress; unused?
        [153] = "Checkerboard (C15)",
        [154] = "Bowser's Maze",
        [155] = "Balcony",

        [161] = "Castle Grounds?", -- not quite a duplicate
        [162] = "Beta Lobby C/D", -- both rooms are connected
        [163] = "Beta Lobby B",
        [164] = "Beta Lobby A",
        [165] = "Genesis Basement",
        [166] = "Bowser's Hallway/Prison", -- both are here
        [167] = "Plexal Upstairs",

        [171] = "Tiny Huge Island (beta)",
        [172] = "Red Courtyard", -- unknown
        [173] = "Creepy Cove",
        [174] = "Sunken Castle",
        [175] = "Mario's Maze",
        [176] = "Mario's Maze", -- get attacked by faceless marios (doesn't work in this port)

        [181] = "Battle Fort",
        [182] = "Floor 2B",
        [183] = "Randomized Realm",
        [184] = "Unknown Lobby",   -- unused lobby; doesn't lead anywhere good
        [185] = "Bob-omb Test Site", -- also called "test field"?
        [186] = "Big Bob-Omb's Fortress",

        [191] = "Aquatic Tunnel",
        [192] = "Cryptic Hideout",
        [193] = "Cryptic Hideout", -- faceless mario encounter (instant death)
        [194] = "Cryptic Hideout", -- ??? (instant death)
        [195] = "Funhouse",

        [201] = "Dry Town",
        [202] = "Wiggler's Forest Fortress",
        [203] = "Pleasant, Pleasant Falls",
        [204] = "Sky-High Pathway",
        [206] = "Ruins In The Blood Lake",

        [211] = "Wet-Dry World (beta)?", -- no pipe here
        [213] = "Ice-Cold Warzone",
        [214] = "Bob-omb Battlefield (beta)",

        [221] = "Blazing Bully Base", -- red version
        [222] = "Peaceful Sewer Maze",
        [223] = "Blazing Bully Base", -- blue version
        [224] = "Infernal Tower",
        [225] = "Fire Bubble (B-Roll)",

        [231] = "Dark Hallway",
        [232] = "Checkerboard (C9)",
        [233] = "Deadly Descent",
        [234] = "Delicious Cake",
        [235] = "Snow Slide (B-Roll)",
        [236] = "Snowman's Land (beta)",
        [237] = "Frosty Highlands",

        [241] = "Cryptic Hideout?",   -- possibly an early version
        [242] = "Dark Lobby?",        -- duplicate with different warps?
        [243] = "Plexal Basement",
        [244] = "Flooded Hallway",    -- unknown
        [245] = "Empty Flooded Hallway",
        [246] = "Lavish Lava Mountain", -- grass side
        [247] = "Lavish Lava Mountain", -- lava side

        [251] = "Flooded Town",
        [252] = "Underground Passageway",
        [256] = "Wet-Dry World (beta)",

        [261] = "Uncanny Courtyard",
        [262] = "Forest Maze",
        [263] = "The Star",
        [264] = "Purple Upstairs",
        [265] = "The Void",
        [266] = "Uncanny Courtyard", -- crimson state
        [267] = "Uncanny Courtyard", -- windy state

        [271] = "Dark Downtown",
        [272] = "castle2",
        [273] = "Cubic Greens",
        [274] = "Purple Cavern", -- probably unused
        [275] = "Bob-Omb Village",
        [276] = "Dead Village",
        [277] = "Dark Plexal Upstairs",

        [281] = "Mountain (B-Roll)",
        [282] = "Goomboss Battle",
        [283] = "Sinister Clockwork",
        [284] = "Whomp's Fortress (beta)",
        [285] = "Tall Floating Fortress",
        [286] = "Rocky Trek",

        [291] = "Eel Graveyard",
        [292] = "Empty Graveyard", -- unused?
        [293] = "Checkboard (WC)",
        [294] = "Plexal Upstairs?", -- somewhat different
        [295] = "Silent Hall",
        [296] = "Void?",          -- just like 34 area 2; idk
        [297] = "Void?",          -- another one? instant death this time

        [301] = "Bowser 1",

        [311] = "Water Land",
        [312] = "Castle1",     -- layout 2?
        [313] = "Castle1",
        [314] = "Forgotten Bay", -- couldn't find this one, so I made this name up
        [315] = "Castle Garden",
        [316] = "Water Land",  -- Unused duplicate?

        [331] = "Bowser's Checkered Madness",
        [332] = "Bowser In The Bully Battlefield",
        [333] = "Bowser 2",

        [341] = "Eternal Fort",
        [342] = "Void?", -- unused, perhaps? somewhat similar to void

        -- vanilla tall tall mountain
        [361] = "Tall, Tall Mountain",
        [362] = "Tall, Tall Mountain",
        [363] = "Tall, Tall Mountain",
        [364] = "Tall, Tall Mountain",
    },

    runner_victory = function(m)
        return m.action == ACT_JUMBO_STAR_CUTSCENE
    end,
}
