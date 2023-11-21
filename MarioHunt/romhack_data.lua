-- constants
STAR_EXIT = 0x10 -- player can leave when grabbing this star
STAR_IGNORE_STARMODE = 0x20 -- star is not counted in star mode
STAR_ACT_SPECIFIC = 0x40 -- star can only be gotten in this act
STAR_NOT_ACT_1 = 0x80 -- star cannot be gotten in act 1
STAR_APPLY_NO_ACTS = 0x100 -- applies even if disable acts is on (like in OMM)
STAR_NOT_BEFORE_THIS_ACT = 0x200 -- star cannot be gotten before this act
STAR_MULTIPLE_AREAS = 0x400 -- only needed if your star can be obtained in only certain areas
STAR_AREA_MASK = 0xF -- 1-15

local romhack_data = { -- supported rom hack data

["vanilla"] = {
    name = "Super Mario 64",
    default_stars = 70, -- stars in a glitchless run
    max_stars = 120, -- maximum stars collectible
    requirements = {
      [LEVEL_BITDW] = 8,
      [LEVEL_DDD] = 30,
      [LEVEL_BITFS] = 31,
      [LEVEL_TTC] = 50,
      [LEVEL_RR] = 50,
      [LEVEL_WMOTR] = 50,
      [LEVEL_BITS] = 70,
      [LEVEL_BOWSER_3] = 120, -- NOTE: This is overridden by the default star run
    },
    ddd = true, -- pretty much only relevant for vanilla
    heartReplace = true, -- replaces all hearts with 1ups

    -- all one table now!
    star_data = {
      [COURSE_BOB] = {8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8, 8},
      [COURSE_WF] = {8 | STAR_ACT_SPECIFIC, 8 | STAR_NOT_ACT_1, 8, 8, 8, 8, 8},
      [COURSE_JRB] = {8 | STAR_ACT_SPECIFIC, 1, 1, 1, 1, 1 | STAR_NOT_ACT_1, 1},
      [COURSE_CCM] = {8 | STAR_ACT_SPECIFIC, 8, 8 | STAR_NOT_ACT_1, 8, 8, 8, 8},
      [COURSE_BBH] = {8 | STAR_ACT_SPECIFIC, 8 | STAR_NOT_ACT_1, 8, 8, 8, 8, 8},
      [COURSE_LLL] = {1, 1, 1, 1, 8, 8, 1},
      [COURSE_SSL] = {1 | STAR_ACT_SPECIFIC, 1, 8, 8 | STAR_EXIT, 1, 8, 1},
      [COURSE_DDD] = {8, 8, 8, 8, 8 | STAR_ACT_SPECIFIC, 8 | STAR_EXIT, 8},
      [COURSE_WDW] = {1, 1, 1, 1, 8, 8, 1},
      [COURSE_TTM] = {8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8, 8},
      [COURSE_THI] = {8, 8, 8 | STAR_ACT_SPECIFIC, 8, 8, 8 | STAR_EXIT, 8},
      [COURSE_TOTWC] = {8 | STAR_IGNORE_STARMODE},
      [COURSE_VCUTM] = {8 | STAR_IGNORE_STARMODE},
      [COURSE_PSS] = {8 | STAR_EXIT | STAR_APPLY_NO_ACTS, 8},
      [COURSE_WMOTR] = {8 | STAR_IGNORE_STARMODE | STAR_APPLY_NO_ACTS}
    },

    -- exclude some stars in MiniHunt
    mini_exclude = {
      [103] = 1, -- In The Deep Freeze (too easy)
      [124] = 1, -- Mysterious Mountainside (too easy)
      [84] = 1, -- Stand Tall On Four Pillars (too annoying)
      [45] = 1, -- Snowman's Lost His Head (inconsistant)
    },

    -- this is a function run every frame for all players. This one in particular handles 0 star runs and minihunts in ttc
    special_run = function(m,gotStar)
      local np = gNetworkPlayers[m.playerIndex]
      if m.playerIndex == 0 and np.currLevelNum == LEVEL_DDD and gGlobalSyncTable.starRun == 0 and gGlobalSyncTable.mhMode ~= 2 then
        warp_to_level(LEVEL_BITFS, 1, 0)
      end
      if gGlobalSyncTable.mhMode == 2 and gGlobalSyncTable.gameLevel == LEVEL_TTC then
        if gGlobalSyncTable.getStar == 6 then
          set_ttc_speed_setting(3)
        else
          set_ttc_speed_setting(1)
        end
      end
    end,

    -- custom star names!
    starNames = {
      [161] = "Red Coins Of The Dark",
      [171] = "8 Flaming Coins",
      [181] = "Skybound Red Coins",
      [191] = "The Slide's Secret",
      [192] = "Speedy Sliding",
      [201] = "Coins In The Cavern",
      [211] = "Flight For 8 Red Coins",
      [221] = "Red Coin Acrobatics",
      [231] = "The Rainbow's Red Coins",
      [241] = "Swimming With The Coins",
    },

    runner_victory = function(m)
      return m.action == ACT_JUMBO_STAR_CUTSCENE
    end,
},

["star-road"] = {
    name = "Star Road",
    default_stars = 80,
    max_stars = 130,
    requirements = {
      [LEVEL_CCM] = 8, -- Chuckya Harbor
      [LEVEL_BBH] = 8, -- Gloomy Garden
      [LEVEL_BITDW] = 20,
      [LEVEL_DDD] = 30, -- Mad Musical Mess
      [LEVEL_BITFS] = 40,
      [LEVEL_BITS] = 80,
      [LEVEL_WMOTR] = 120, -- Hidden Palace Finale
    },
    heartReplace = true, -- replaces all hearts with 1ups (doesn't affect the bubbles, thankfully)

    -- mostly defining replicas
    star_data = {
      [COURSE_NONE] = {8, 8, 8, 8},
      [COURSE_BOB] = {8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8, 8, 8},
      [COURSE_WF] = {8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8, 8, 8},
      [COURSE_JRB] = {8, 8, 8, 8, 8, 8 | STAR_ACT_SPECIFIC, 8},
      [COURSE_CCM] = {8, 8, 8, 8, 8, 8 | STAR_EXIT | STAR_APPLY_NO_ACTS, 8}, -- don't get trapped in The Other Entrance
      [COURSE_BBH] = {8 | STAR_ACT_SPECIFIC, 8, 8, 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8}, -- wow, Gloomy Garden has a lot of act specifics
      [COURSE_HMC] = {8, 8 | STAR_ACT_SPECIFIC, 8, 8 | STAR_ACT_SPECIFIC, 8, 8, 8},
      [COURSE_LLL] = {8, 8 | STAR_ACT_SPECIFIC, 8 | STAR_NOT_BEFORE_THIS_ACT, 8, 8, 8, 8},
      -- I decided to flag 100 coins here because I don't think there's enough coins without getting up the tree
      [COURSE_SSL] = {8 | STAR_ACT_SPECIFIC | STAR_IGNORE_STARMODE, 8 | STAR_NOT_ACT_1, 8, 8 | STAR_NOT_ACT_1, 8 | STAR_NOT_ACT_1, 8, 8 | STAR_NOT_ACT_1},
      [COURSE_SL] = {8, 8 | STAR_NOT_ACT_1, 8, 8, 8, 8, 8},
      [COURSE_TTM] = {8, 8 | STAR_NOT_ACT_1, 8 | STAR_NOT_ACT_1, 8 | STAR_NOT_ACT_1, 8, 8, 8},
      [COURSE_TTC] = {8, 8, 8, 8, 8, 8 | STAR_ACT_SPECIFIC, 8}, -- star 1 actually disappears in acts 5 and 6 (I could account for that but ehhh)
      [COURSE_WDW] = {8 | STAR_ACT_SPECIFIC | STAR_IGNORE_STARMODE, 8, 8, 8, 8, 8, 8}, -- ignored in star mode because it's glitchy
      [COURSE_THI] = {8, 8 | STAR_ACT_SPECIFIC, 8, 8, 8 | STAR_NOT_BEFORE_THIS_ACT, 8 | STAR_ACT_SPECIFIC | STAR_EXIT, 8},
      [COURSE_RR] = {8, 8, 8 | STAR_IGNORE_STARMODE | STAR_APPLY_NO_ACTS, 8, 8, 8 | STAR_EXIT | STAR_APPLY_NO_ACTS, 8}, -- don't get trapped in In The Cage
      [COURSE_BITDW] = {8, 0, 0, 8},
      [COURSE_BITFS] = {8, 0, 0, 0, 8},
      [COURSE_BITS] = {8, 0, 0, 0, 0, 8},
      [COURSE_PSS] = {8, 8, 0, 0, 0, 8},
      [COURSE_COTMC] = {8, 0, 0, 0, 8},
      [COURSE_TOTWC] = {8, 0, 0, 0, 0, 8},
      [COURSE_VCUTM] = {8, 0, 0, 0, 0, 8},
      [COURSE_WMOTR] = {8, 0, 0, 0, 0, 8},
      [COURSE_SA] = {8, 8 | STAR_IGNORE_STARMODE | STAR_APPLY_NO_ACTS, 0, 0, 0, 8}, -- can fail time challenge
      [COURSE_CAKE_END] = {0, 8},
    },

    -- exclude some stars in MiniHunt
    mini_exclude = {
      [46] = 1, -- The Other Entrance
      [205] = 1, -- Replica for Creepy Cap Cave
      [111] = 1, -- Tuxie Race Down The Slide (glitchy)
    },

    special_run = function(m,gotStar)
      deleteStarRoadStuff(m)
      local np = gNetworkPlayers[0]
      -- prevent getting trapped in cage star
      if m.action == ACT_TELEPORT_FADE_IN and m.playerIndex == 0 and np.currLevelNum == LEVEL_CCM
      and m.pos.x < -3200 and m.pos.z < -4600 then
        local sMario = gPlayerSyncTable[0]
        sMario.allowLeave = true
      end
    end,

    -- custom star names!
    starNames = {
      [161] = "Across The Sinking Logs",
      [164] = "Replica Of The Tall Logs",
      [171] = "Castle Detour",
      [175] = "Replica Of The Fire Statue",
      [181] = "Atop The Twisted Planet",
      [186] = "Replica Of The Flaming Spiral",
      [191] = "Climb With Koopa The Quick",
      [192] = "Red Coins 'Round Town",
      [196] = "Replica Of The Village Hermit",
      [201] = "Coins In The Cave",
      [205] = "Replica Of The Cave Entrance",
      [211] = "Windy Red Coin Search",
      [216] = "Replica Of The Airship",
      [221] = "Hidden In The Light",
      [226] = "Replica Of The Cogs",
      [231] = "On Top Of The World",
      [236] = "Replica Of The Palace Ledge",
      [241] = "Slip Slidin' For Red Coins",
      [242] = "Sand Slide Speedrun",
      [246] = "Replica Of The Steel Beams",
      [252] = "Bowser's Power Star",
    },
    replica_start = 121, -- replicas are considered at this star count

    otherStarIds = (function()
      return { -- table of other objects to be marked as stars
      [bhvSMSRStarReplica] = "bhvSMSRStarReplica",
      [bhvSMSRStarMoving] = "bhvSMSRStarMoving",
      }
    end),

    runner_victory = function(m)
      if gGlobalSyncTable.bowserBeaten and m.numStars >= gGlobalSyncTable.starRun then
        return true
      elseif m.playerIndex == 0 then
        local np = gNetworkPlayers[0]
        if np.currLevelNum == LEVEL_ENDING then
          gGlobalSyncTable.bowserBeaten = true
        end
      end
      return false
    end,
},

["sm74"] = {
    name = "Super Mario 74 (+EE)",
    default_stars = 110,
    max_stars = 157, -- only one version, sorry
    requirements = {
      [LEVEL_BITDW] = 10,
      [LEVEL_BITFS] = 50,
      [LEVEL_BITS] = 110,
      [LEVEL_BOWSER_3] = 157,
      [LEVEL_SA] = 150,
    },
    noLobby = true,

    star_data = {
      [COURSE_COTMC] = {8, 8, 8, 8, 8}, -- Toxic-Switch of Danger
      [COURSE_BITDW] = {8, 8, 8, 8}, -- Bowser's Badlands-Battlefield
      [COURSE_WMOTR] = {8, 8, 8, 8, 8, 8}, -- Tower of the East
      [COURSE_TOTWC] = {8, 8, 8}, -- Lava-Switch of Eruption
      [COURSE_VCUTM] = {8, 8, 8, 8, 8, 8}, -- Dust-Switch of Identity
      [COURSE_PSS] = {8, 8, 8, 8}, -- Frozen Slide
      [COURSE_BITFS] = {8, 8, 8, 8, 8}, -- Bowser's Aquatic Castle
      [COURSE_SA] = {8}, -- Champion's Challenge (there's another star but it is hard to get so we ignore in the time)
      [COURSE_BITS] = {8, 8, 8, 8, 8, 8}, -- Bowser's Crystal Palace
    },
    
    -- EE has some different counts
    star_data_ee = {
      [COURSE_COTMC] = {8, 8, 8, 8, 8, 8}, -- Toxic Terrace
      [COURSE_SA] = {8, 8, 8, 8, 8, 8, 8}, -- Triarc-Bridge
    },
    -- custom star names!
    starNames = {
      [161] = "The Tower's Top",
      [162] = "Hidden In The Towers",
      [163] = "Climbing The Scaffold",
      [164] = "Red Coins In Battle",
      [171] = "The Central Mountain",
      [172] = "Bowels Of The Castle",
      [173] = "Rush Along The Cliffside",
      [174] = "Cliffside Hike",
      [175] = "Diving For Red Coins",
      [181] = "Don't Look Down",
      [182] = "The Palace's Side Tower",
      [183] = "Slip Through The Cracks",
      [184] = "Among The Palace Rooftops",
      [185] = "The Thin Walkway",
      [186] = "16 Sinister Coins",
      [191] = "Steady Sliding Wins The Race",
      [192] = "Slippery Platforming!",
      [193] = "Off The Slide, Onto The Ledge",
      [194] = "Red Coins in The Frost",
      [201] = "Wheezing Wall Kicks",
      [202] = "Bright Down Low",
      [203] = "Secret In The Toxins",
      [204] = "A Breathtaking View",
      [205] = "Toxic Red Coins",
      [211] = "Tower Flight for Red Coins",
      [212] = "Secret Tower Storage",
      [213] = "Low, But Not Too Low",
      [221] = "Sunken In The Dust",
      [222] = "Tip-Toe Through The Dust",
      [223] = "8 Coins Of Identity",
      [224] = "Quick As A Hare",
      [225] = "Light As A Feather",
      [226] = "Highest of All",
      [231] = "Alcove Of The East",
      [232] = "Roof Of The Slide",
      [233] = "Bowser's Secret Treat",
      [234] = "East And West For Red Coins",
      [235] = "A Quick Climb",
      [236] = "The Central Tower's Loot",
      [241] = "A Super Champion",
      [243] = "The Champion Of All",
    },
    starNames_ee = {
      [161] = "Peeking Out The Tower",
      [162] = "Off In The Distance",
      [163] = "Trapped In The Towers",
      [164] = "Flowering Red Coins",
      [171] = "Breaking And Entering",
      [172] = "Surfin' On Sand Mountain",
      [173] = "Wall Kicks In The Pit",
      [174] = "Timed Jumps And Tricky Platforms",
      [175] = "The Pit's Crimson Coins",
      [181] = "Broken Burning Walkway",
      [182] = "Leaps O'er The Void",
      [183] = "THIRTY ????ING RED COINS",
      [184] = "Hole In The Wall",
      [185] = "Thin Wall Ledges",
      [186] = "Down The Deadly Slide",
      [191] = "End Of The Supply Chain",
      [192] = "Another Star In The Wall",
      [193] = "Tight Jumps Needed!",
      [194] = "8 Red Deliveries",
      [201] = "Tiny Platforms, Huge Jumps",
      [202] = "Scaling The Lava",
      [203] = "In The Terrace Depths",
      [204] = "Thread The Needle",
      [205] = "Atop The Terrace",
      [206] = "Coin Search In The Terrace",
      [211] = "How Low Can You Go?",
      [212] = "The Height Of Hell",
      [213] = "Devilish Red Coins",
      [221] = "Under The Arches",
      [222] = "Fast-Paced Delivery",
      [223] = "Slip Under The Mist",
      [224] = "Final Destination",
      [225] = "Dive Through The Dust",
      [226] = "Red Coins in The Fog",
      [231] = "The Lord's Red Coins",
      [232] = "Top Of The Broken Tower",
      [233] = "Corner In the Sky",
      [234] = "Long Leaps Above The Lake",
      [235] = "Sloped Triple Jumps",
      [236] = "Hidden Corner Of The Cave",
      [241] = "Red Coin Stroll",
      [242] = "Below The Hanging Floor",
      [243] = "Troll Under The Bridge",
      [244] = "Hidden in The Tower",
      [245] = "Towers Over The Void",
      [246] = "Under The Castle Wall",
      [247] = "Literally Under Ground",
    },
    mini_exclude = {
      [221] = 1, -- also excludes its equivalent in ee, unintentionally (I don't care that much)
    },

    -- extra hub stages (that aren't part of the castle)
    hubStages = {
      [COURSE_WMOTR] = 1, -- Tower Of The East
    },

    runner_victory = function(m)
      return m.action == ACT_JUMBO_STAR_CUTSCENE
    end,

    -- prevent swap except by host
    special_run = function(m,gotStar)
      if m.playerIndex ~= 0 then return end
      local np = gNetworkPlayers[m.playerIndex]
      if gotStar and gGlobalSyncTable.ee and np.currLevelNum == LEVEL_SA then
        m.pos.x,m.pos.y,m.pos.z = 6044,136,-5564 -- make this level possible without dying
        set_mario_action(m, ACT_SPAWN_NO_SPIN_AIRBORNE, 0)
      end
      if (np.currAreaIndex == 1) == gGlobalSyncTable.ee then
        if has_mod_powers(0) then
          gGlobalSyncTable.ee = (np.currAreaIndex ~= 1)
          close_menu()
          return
        else
          if gGlobalSyncTable.ee then
            djui_chat_message_create(trans("using_ee"))
          else
            djui_chat_message_create(trans("not_using_ee"))
          end
          close_menu()
          warp_to_level(np.currLevelNum, np.currAreaIndex ~ 3, np.currActNum)
          return
        end
      end
    end,
},

["sapphire"] = {
  name = "SM64 Sapphire",
  default_stars = 30,
  max_stars = 30,
  requirements = {
    [LEVEL_BITS] = 30,
    [LEVEL_BOWSER_3] = 30,
  },
  ommSupport = false, -- does not have default omm support
  heartReplace = true, -- replaces all hearts with 1ups

  -- since not all courses are modified here, exclude those
  star_data = {
    [COURSE_NONE] = {},
    [COURSE_BOB] = {8, 8, 8, 8, 8, 8 | STAR_ACT_SPECIFIC, 8},
    [COURSE_CCM] = {8, 8, 8, 8, 8, 8 | STAR_ACT_SPECIFIC, 8},
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
    [COURSE_PSS] = {8 | STAR_EXIT, 8}, -- includes toad star
    [COURSE_COTMC] = {},
    [COURSE_TOTWC] = {},
    [COURSE_VCUTM] = {},
    [COURSE_WMOTR] = {},
    [COURSE_SA] = {},

    [COURSE_WF] = {8, 8, 8 | STAR_EXIT, 8, 8, 8 | STAR_EXIT, 8}, -- prevent getting stuck
    [COURSE_JRB] = {8, 8 | STAR_EXIT, 8, 8, 8, 8, 8}, -- prevent getting stuck
    [COURSE_CCM] = {8, 8, 8, 8, 8, 8 | STAR_EXIT, 8}, -- prevent getting stuck
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
},

["Ztar Attack 2"] = {
  name = "\\#0c33c2\\Ztar Attack \\#c20c0c\\2",
  default_stars = -1, -- no stars required!
  max_stars = 90,
  -- no requirements!
  stalk = true, -- makes this hack less annoying
  starColor = {r = 145,g = 207,b = 187}, -- stars are light green
  ommSupport = false, -- does not have default omm support

  -- cancel visible secrets (so they so show up as stars)
  special_run = function(m,gotStar)
    gLevelValues.visibleSecrets = 0
  end,

  -- gotta define almost every level in the game, yay
  star_data = { -- in order
    -- World 1
    [COURSE_BOB] = {8, 8},
    [COURSE_WF] = {8, 8},
    [COURSE_JRB] = {8, 8, 8},
    [COURSE_BITDW] = {8, 8, 8, 8},
    -- World 2
    [COURSE_CCM] = {8, 8},
    [COURSE_BBH] = {8, 8, 8, 8},
    [COURSE_HMC] = {8, 8, 8, 8, 8},
    [COURSE_BITFS] = {8, 8, 8, 8, 8},
    -- World 3
    [COURSE_LLL] = {8, 8, 8, 8},
    [COURSE_SSL] = {8, 8, 8},
    [COURSE_DDD] = {8, 8, 8},
    [COURSE_COTMC] = {8, 8, 8, 8, 8, 8},
    -- World 4
    [COURSE_SL] = {8, 8},
    [COURSE_WDW] = {8, 8, 8, 8, 8, 8},
    [COURSE_TTM] = {8, 8, 8},
    [COURSE_VCUTM] = {8, 8, 8, 8, 8},
    -- World 5
    [COURSE_THI] = {8, 8, 8, 8},
    [COURSE_TTC] = {8, 8, 8, 8, 8, 8},
    [COURSE_RR] = {8, 8, 8, 8, 8, 8},
    [COURSE_BITS] = {8, 8, 8, 8, 8, 8},
    [COURSE_TOTWC] = {8},
    -- Extra
    -- [COURSE_PSS] = {8}, -- The Super Quiz
    -- [COURSE_WMOTR] = {8}, -- Negative Realm
    [COURSE_SA] = {8, 8, 0, 0, 8, 8}, -- Gaell's Dream
    [COURSE_CAKE_END] = {0, 0, 8}, -- The End
    [COURSE_NONE] = {0, 0, 0, 8}, -- has mips
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
    [225] = "A Brainwashed King",
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
    [191] = "Quizmaster", -- The Super Quiz
    [253] = "Thanks For Playing!", -- The End
    -- Gaell's Dream
    [241] = "Stars Across Time And Space",
    [242] = "The End Of Time",
    [245] = "Timeless Red Coins",
    [246] = "A Bout With Gaell",
  },

  hubStages = {
    [COURSE_PSS] = 1, -- The Super Quiz
  },

  runner_victory = function(m) -- red switch is after bowser
    if (save_file_get_flags() & SAVE_FLAG_HAVE_WING_CAP) ~= 0 and m.numStars >= gGlobalSyncTable.starRun then
      return true
    end
    return false
  end,
},

["coop-mods-green-stars"] = {
  name = "SM64: The Green Stars",
  default_stars = 80,
  max_stars = 131,
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
  starColor = {r = 92,g = 255,b = 92}, -- stars are green (duh)
  heartReplace = true, -- replaces all hearts with 1ups

  star_data = {
    [COURSE_NONE] = {8, 8, 8}, -- no mips
    [COURSE_BOB] = {8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8, 8, 8},
    [COURSE_WF] = {8 | STAR_ACT_SPECIFIC, 8, 8 | STAR_EXIT, 8, 8, 8, 8},
    [COURSE_BBH] = {8, 8, 8, 8, 8 | STAR_NOT_BEFORE_THIS_ACT, 8, 8},
    [COURSE_HMC] = {8, 8 | STAR_NOT_BEFORE_THIS_ACT, 8, 8, 8 | STAR_ACT_SPECIFIC, 8, 8},
    [COURSE_SSL] = {8, 8, 8, 8, 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8},
    [COURSE_DDD] = {8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8, 8, 8},
    [COURSE_SL] = {8, 8, 8, 8 | STAR_ACT_SPECIFIC, 8, 8 | STAR_NOT_ACT_1, 8}, -- the act 6 star is obtainable in acts 4-6, so this was the best solution I could think of
    [COURSE_DDD] = {8, 8 | STAR_ACT_SPECIFIC | STAR_EXIT, 8 | STAR_ACT_SPECIFIC, 8, 8, 8 | STAR_ACT_SPECIFIC, 8},
    [COURSE_THI] = {8, 8, 8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8},
    [COURSE_TTC] = {8, 8 | STAR_NOT_BEFORE_THIS_ACT, 8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8}, -- star 2 isn't actually available in acts 5 and 6 :/
    [COURSE_BITDW] = {8, 8, 8},
    [COURSE_BITFS] = {8, 8, 8, 8},
    [COURSE_BITS] = {8, 8, 8, 8},
    [COURSE_PSS] = {8 | STAR_IGNORE_STARMODE | STAR_APPLY_NO_ACTS, 8, 8, 8 | STAR_EXIT | STAR_APPLY_NO_ACTS},
    [COURSE_COTMC] = {8, 8 | STAR_EXIT | STAR_APPLY_NO_ACTS, 8},
    [COURSE_TOTWC] = {8, 8},
    [COURSE_VCUTM] = {}, -- does not exist
    [COURSE_WMOTR] = {8},
    [COURSE_SA] = {8, 8},
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
},

["underworld"] = {
  name = "SM64: The Underworld",
  default_stars = 30,
  max_stars = 30,
  ommSupport = false, -- does not have default omm support
  badGuy = "The Shitilizer", -- this will display in the rules
  badGuy_es = "El Shitilizer",
  badGuy_de = "Den Shitilizer",
  badGuy_fr = "Le Shitilizer",
  isUnder = true, -- activates special star detection
  noLobby = true,
  starColor = {r = 0, g = 255, b = 255}, -- light blue

  -- prevents moving at start, disables some things
  special_run = function(m,gotStar)
    if gGlobalSyncTable.mhMode == 2 then
      change_game_mode(nil,0)
      djui_popup_create(trans("wrong_mode"),1)
    end
    if gGlobalSyncTable.starRun ~= 30 then
      gGlobalSyncTable.starRun = 30
      djui_popup_create(trans("wrong_mode"),1)
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

  ["badGuy_pt-br"] = "O Shitilizer",
},

["B3313"] = {
  name = "B3313",
  default_stars = 30, -- just a number
  max_stars = 120, -- unknown how many stars there actually are
  vagueName = true, -- the names are all identical, just use course numbers
  -- no requirements
  parseStars = true, -- automatically generate star list (this hack is too large I can't be bothered)
  stalk = true, -- the hack is confusing, so let people warp
  no_bowser = true, -- don't display killing bowser as win condition
  ommSupport = false,

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
    [151] = "Star (1)", -- Manta Ray is not possible
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
    [113] = "Frosty Highlands?", -- duplicate?
    [114] = "Cool, Cool Mountain (beta)",
    [115] = "Chief Chilly's Ring",
    [116] = "Cold, Cold Crevasse",
    [117] = "Chroma Tundra",

    [121] = "Bob-Omb River",
    [122] = "Big Bob-Omb's Fortress?", -- duplicate with fog
    [123] = "Piranha Plant Garden",
    [124] = "Minion Base?", -- duplicate with different skybox
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
    [184] = "Unknown Lobby", -- unused lobby; doesn't lead anywhere good
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

    [241] = "Cryptic Hideout?", -- possibly an early version
    [242] = "Dark Lobby?", -- duplicate with different warps?
    [243] = "Plexal Basement",
    [244] = "Flooded Hallway", -- unknown
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
    [296] = "Void?", -- just like 34 area 2; idk
    [297] = "Void?", -- another one? instant death this time

    [301] = "Bowser 1",

    [311] = "Water Land",
    [312] = "Castle1", -- layout 2?
    [313] = "Castle1",
    [314] = "Forgotten Bay", -- couldn't find this one, so I made this name up
    [315] = "Castle Garden",
    [316] = "Water Land", -- Unused duplicate?

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

  -- warp to ruins in the blood lake
  special_run = function(m,gotStar)
    if m.playerIndex == 0 and gotStar == 2 and gNetworkPlayers[0].currLevelNum == LEVEL_THI and gNetworkPlayers[0].currAreaIndex == 7 then
      warp_to_level(LEVEL_SA, 6, 0)
    end
  end,

  -- condition is "kill bowser" if any%, or simply "get X stars" otherwise
  runner_victory = function(m)
    if gGlobalSyncTable.starRun == -1 then
      return m.action == ACT_JUMBO_STAR_CUTSCENE
    else
      return m.numStars >= gGlobalSyncTable.starRun
    end
  end,
},

["moonshine"] = {
  name = "SM64 Moonshine",
  default_stars = 50, -- there is no end, really
  max_stars = 50,
  no_bowser = true,
  requirements = {
    [LEVEL_LLL] = 8, -- Sweet Sweet Rush
    [LEVEL_BITS] = 30, -- Down Street
  },
  ommSupport = false, -- not true, but this only affected the colored radar
  starColor = {r = 92,g = 255,b = 92}, -- all moons are green
  heartReplace = true, -- replaces all hearts with 1ups
  isMoonshine = true, -- changes hud elements

  star_data = {
    [COURSE_NONE] = {0, 8}, -- only toad star 2
    [COURSE_JRB] = {},
    [COURSE_LLL] = {8, 8, 0, 0, 0, 0, 8}, -- Sweet Sweet Rush
    [COURSE_SSL] = {},
    [COURSE_DDD] = {},
    [COURSE_SL] = {},
    [COURSE_WDW] = {8, 8, 8, 8, 0, 0, 8}, -- Green Plains
    [COURSE_TTM] = {},
    [COURSE_THI] = {},
    [COURSE_TTC] = {},
    [COURSE_RR] = {},
    [COURSE_BITDW] = {},
    [COURSE_BITFS] = {8, 8}, -- Purple Swampy Swamp
    [COURSE_BITS] = {8, 8}, -- Moonshine
    [COURSE_PSS] = {},
    [COURSE_COTMC] = {},
    [COURSE_TOTWC] = {},
    [COURSE_VCUTM] = {},
    [COURSE_WMOTR] = {},
    [COURSE_PSS] = {8, 8}, -- Forest Valley
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

  runner_victory = function(m)
    return m.numStars >= gGlobalSyncTable.starRun
  end,
},

default = {
    name = "Default",
    default_stars = -1,
    max_stars = 255,
    requirements = {[LEVEL_BOWSER_3] = 255}, -- block off Bowser 3 until needed stars are collected
    parseStars = true, -- automatically generate star list

    star_data = {}, -- assume every secret stage has 1 star

    runner_victory = function(m)
      return m.action == ACT_JUMBO_STAR_CUTSCENE
    end,
},

}

ROMHACK = {} -- table containing the romhack data we're using
PARSE_COURSE = 0 -- what course we're parsing in level_script_parse
PARSE_AREA = 0 -- what area we're parsing in level_script_parse
PARSE_LEVEL = 0 -- what level we're parsing in level_script_parse
PARSE_PRINT = false -- used in debug command; displays information about found stars
PARSE_FOUND_STARS = {} -- stars we've found in the level we're parsing
PARSE_MINI_EXCLUDE = {} -- stars we've found to exclude in minihunt
PARSE_STAR_NAMES = {} -- the name of the stars we've found

disable_chat_hook = false -- disabled if a mod uses it (swear filter, for example)

function setup_hack_data(settingRomHack,initial,usingOMM)
  local romhack_file = gGlobalSyncTable.romhackFile
  ROMHACK = romhack_data[romhack_file]
  if initial and usingOMM then
    djui_popup_create(trans("omm_detected"), 1)
  end

  local found_121 = false
  if ROMHACK == nil and settingRomHack then
    if _G.mhApi == nil or _G.mhApi.romhackSetup == nil then
      romhack_file = "vanilla"
      for i,mod in pairs(gActiveMods) do
        if mod.enabled then
          if mod.incompatible and string.find(mod.incompatible,"romhack") then -- is a romhack
            romhack_file = mod.relativePath
            found_121 = false
          elseif mod.incompatible and string.find(mod.incompatible,"gamemode") then -- is mariohunt
            if string.find(mod.basePath,"sm64ex/-coop") then
              djui_popup_create("WARNING: Mod installed in base directory; API may not function",2)
            end
          elseif (romhack_file == "vanilla") and (not found_121) and string.find(mod.name,"121rst star") then -- 121rst star support
            found_121 = true
          elseif not disable_chat_hook then -- disable hook for some mods
            local name = mod.name:lower()
            if (not (_G.mhApi.chatValidFunction or _G.mhApi.chatModifyFunction)) and (name:find("mute") or name:find("swear filter") or name:find("nicknames")) then
              disable_chat_hook = true
            end
          end
        end
      end
      print("Romhack is",romhack_file)
      ROMHACK = romhack_data[romhack_file]
    else
      romhack_file = "custom"
    end
  end
  if romhack_file == "custom" and (_G.mhApi ~= nil and _G.mhApi.romhackSetup ~= nil) then
    ROMHACK = _G.mhApi.romhackSetup()
    print("Romhack is",ROMHACK.name,"custom")
  end

  if initial and romhack_file == "vanilla" then
    dialog_replace()
    omm_replace(usingOMM)
  end

  if found_121 then
    ROMHACK.star_data[COURSE_NONE] = {8, 8, 8, 8, 8, 8}
    ROMHACK.starNames[6] = "Red Coins at Midnight"
  end

  if ROMHACK == nil then
    romhack_file = "default"
    ROMHACK = romhack_data["default"]
    print("Not compatible!")
    djui_popup_create(trans("incompatible_hack"),1)
    gGlobalSyncTable.romhackFile = "default"
  elseif romhack_file ~= "vanilla" then
    djui_popup_create(trans("set_hack",ROMHACK.name), 1)
  end

  if ROMHACK.starColor ~= nil then
    defaultStarColor = ROMHACK.starColor
  else
    defaultStarColor = {r = 255,g = 255,b = 92} -- yellow
  end

  if initial and ROMHACK.otherStarIds ~= nil then
    local otherStarIds = ROMHACK.otherStarIds() or {}
    for id,name in pairs(otherStarIds) do
      star_ids[id] = name
    end
  end
  if initial and ROMHACK.otherStarSources ~= nil then
    local otherStarSources = ROMHACK.otherStarSources() or {}
    for id,data in pairs(otherStarSources) do
      star_sources[id] = data
    end
  end

  -- support for old format
  if ROMHACK.star_data == nil then
    ROMHACK.star_data = {}
    for level,course in pairs(level_to_course) do
      if ROMHACK.starCount[level] then
        if ROMHACK.star_data[course] == nil then ROMHACK.star_data[course] = {} end
        if ROMHACK.starCount[level] > 0 then
          for i=1,ROMHACK.starCount[level] do
            local starNum = i
            if ROMHACK.renumber_stars and ROMHACK.renumber_stars[course * 10 + i] then
              starNum = ROMHACK.renumber_stars[course * 10 + i]
            end
            if starNum ~= 0 then
              ROMHACK.star_data[course][starNum] = 8
            end
          end
        end
      end
    end
  end

  if ROMHACK.parseStars then
    for course=COURSE_MIN,COURSE_MAX-1 do
      parse_course_stars(course, course_to_level[course] or 0)
    end
  end

  if (ROMHACK ~= nil and ROMHACK.stalk == nil) then
    update_chat_command_description("stalk", "- " .. trans("wrong_mode"))
  else
    update_chat_command_description("stalk", trans("stalk_desc"))
  end

  if settingRomHack then
    gGlobalSyncTable.starRun = ROMHACK.default_stars
    gGlobalSyncTable.romhackFile = romhack_file
  end
  return romhack_file
end

-- uses level_script_parse to setup romhack data
function parse_course_stars(course, level)
  PARSE_COURSE = course
  PARSE_LEVEL = level
  PARSE_AREA = 1
  PARSE_FOUND_STARS = {}
  PARSE_MINI_EXCLUDE = {}
  PARSE_STAR_NAMES = {}

  if ROMHACK.mini_exclude == nil then ROMHACK.mini_exclude = {} end
  if ROMHACK.starNames == nil then ROMHACK.starNames = {} end
  if ROMHACK.star_data[course] == nil then ROMHACK.star_data[course] = {} end

  local exText = ""
  local renumText = ""

  print(PARSE_LEVEL)
  level_script_parse(PARSE_LEVEL, parse_stars)
  if course == 0 then
    PARSE_LEVEL = LEVEL_CASTLE
    level_script_parse(PARSE_LEVEL, parse_stars)
    PARSE_LEVEL = LEVEL_CASTLE_COURTYARD
    level_script_parse(PARSE_LEVEL, parse_stars)
  end
  local starCount = 0
  for i=1,7 do
    if (PARSE_FOUND_STARS[i] or (i==7 and course <= 15 and course > 0)) then
      ROMHACK.star_data[course][i] = PARSE_FOUND_STARS[i] or 1 -- 100 coin star is always area 1

      if ROMHACK.starNames == nil or ROMHACK.starNames[course*10+i] == nil then
        ROMHACK.starNames[course*10+i] = PARSE_STAR_NAMES[course*10+i]
      end

      if course ~= 0 and course ~= 25 then
        if PARSE_MINI_EXCLUDE[i] == 1 then
          exText = exText .. (string.format("[%d%d] = 1,",course,i)) .. "\n"
          ROMHACK.mini_exclude[course*10+i] = 1
        elseif PARSE_MINI_EXCLUDE[i] and PARSE_MINI_EXCLUDE[i] ~= 0 then
          exText = exText .. (string.format("[%d%d] = %d,",course,i,PARSE_MINI_EXCLUDE[i])) .. "\n"
          ROMHACK.mini_exclude[course*10+i] = PARSE_MINI_EXCLUDE[i]
        end
      end
    else
      ROMHACK.star_data[course][i] = 0
    end
  end
  if PARSE_PRINT then
    print(string.format("[%d] = %d,\n",level,starCount))
  end
  if PARSE_PRINT then
    print(renumText)
    print(exText)
  end
end

-- gets all stars (and star sources, such as King Bob-omb); used with level_script_parse
function parse_stars(area, bhvData, macroBhvIds, macroBhvArgs)
  if macroBhvIds then
    for i,id in pairs(macroBhvIds) do
      parse_stars(nil, {behavior = id, behaviorArg = macroBhvArgs[i]}) -- parse for each macro object
    end
  elseif area and area ~= 0 then
    PARSE_AREA = area
  elseif bhvData then
    local starNum = 0
    local obj_id = bhvData.behavior
    local byte1 = bhvData.behaviorArg >> 24 -- first byte
    local byte2 = (bhvData.behaviorArg >> 16 & 0x00FF) -- second byte

    local neededByte2
    local custom_name
    if star_sources[obj_id] ~= nil then
      neededByte2 = star_sources[obj_id][1] or 0
      custom_name = star_sources[obj_id][2]
    end

    local mini_invalid = false

    if star_ids[obj_id] then
      custom_name = "Star"
      starNum = (byte1) + 1
    elseif neededByte2 == true then
      starNum = (byte1) + 1
    elseif neededByte2 == 0xFF then
      if byte2 ~= 0 then
        starNum = (byte1) + 1
      end
    elseif neededByte2 then
      if byte2 == neededByte2 then
        starNum = (byte1) + 1
      end
    elseif obj_id == id_bhvKoopa then -- koopa the quick special case
      if byte2 > 0x01 then
        custom_name = "Race with Koopa The Quick"
        starNum = (byte1) + 1
      end
    elseif obj_id == id_bhvExclamationBox then -- exclamation box special case
      if exclamation_box_valid[byte2] then
        custom_name = "Box Star"
        
        if byte2 == 8 then
          starNum = (byte1) + 1
        else
          starNum = byte2 - 8
        end
      end
    elseif obj_id == id_bhvToadMessage then -- toad special case
      mini_invalid = true
      custom_name = "Toad Star"
      if byte1 == gBehaviorValues.dialogs.ToadStar1Dialog then
        starNum = 1
      elseif byte1 == gBehaviorValues.dialogs.ToadStar2Dialog then
        starNum = 2
      elseif byte1 == gBehaviorValues.dialogs.ToadStar3Dialog then
        starNum = 3
      end
    elseif obj_id == id_bhvMips then -- mips special case
      mini_invalid = true
      custom_name = "Mips Star"
      if area then -- if the area was set, we're doing mip's second star
        starNum = 5
      else
        -- two stars from mips, perhaps (check if star 2 is disabled)
        if gBehaviorValues.MipsStar2Requirement ~= 255 then
          parse_stars(0, bhvData) -- call again with area set to 0; this normally doesn't happen
        end
        starNum = 4
      end
    end

    if (starNum > 0 and starNum < 8) and (
    ROMHACK.game_exclude == nil or ROMHACK.game_exclude[PARSE_COURSE*10+starNum] == nil or
    ROMHACK.game_exclude[PARSE_COURSE*10+starNum] == PARSE_AREA
    ) then
      custom_name = custom_name .. " (" .. starNum ..")"

      if PARSE_PRINT then
        djui_chat_message_create(string.format("%s (C%d, L%d, A%d)",custom_name,PARSE_COURSE,PARSE_LEVEL,PARSE_AREA))
        print(custom_name, PARSE_COURSE, PARSE_AREA)
      end
      
      if PARSE_FOUND_STARS[starNum] == nil then
        PARSE_FOUND_STARS[starNum] = PARSE_AREA | STAR_APPLY_NO_ACTS
      else
        PARSE_FOUND_STARS[starNum] = PARSE_FOUND_STARS[starNum] & ~STAR_AREA_MASK
        PARSE_FOUND_STARS[starNum] = PARSE_FOUND_STARS[starNum] | (STAR_MULTIPLE_AREAS << (PARSE_AREA-1))
      end

      if mini_invalid and PARSE_MINI_EXCLUDE[starNum] == nil then
        PARSE_MINI_EXCLUDE[starNum] = 1
      elseif PARSE_AREA ~= 1 and (not mini_invalid) then
        PARSE_MINI_EXCLUDE[starNum] = PARSE_AREA
      else
        PARSE_MINI_EXCLUDE[starNum] = 0
      end

      if ROMHACK.vagueName or PARSE_COURSE > 15 or PARSE_COURSE == 0 then
        PARSE_STAR_NAMES[PARSE_COURSE*10+starNum] = custom_name
      end
    end
  end
end

-- exteme edition support, and sets minihunt level as beginning
function warp_beginning()
  warpCount = 0
  warpPrevArea = 0
  warpCooldown = 0
  if gGlobalSyncTable.mhMode == 2 and gGlobalSyncTable.mhState ~= 0 then
    local correctAct = gGlobalSyncTable.getStar

    local course = level_to_course[gGlobalSyncTable.gameLevel] or 0
    local area = (ROMHACK.mini_exclude and ROMHACK.mini_exclude[course*10+correctAct]) or 1
    if gGlobalSyncTable.ee then area = 2 end

    if correctAct == 7 then correctAct = 6 end
    if course == 0 then correctAct = 0 end
    warp_to_level(gGlobalSyncTable.gameLevel, area, correctAct)
  elseif gGlobalSyncTable.mhState == 0 and LEVEL_LOBBY and not ROMHACK.noLobby then
    warp_to_level(LEVEL_LOBBY, 1, 0) -- go to custom lobby!
  elseif gGlobalSyncTable.ee then
    warp_to_level(gLevelValues.entryLevel, 2, 0)
  else
    warp_to_start_level()
  end
end

-- deletes all surfaces with certain values in hub worlds, to erase star doors and the cannon grate
-- it probably also erases some other stuff but oh well
function deleteStarRoadStuff(m)
    local starsNeeded = gGlobalSyncTable.starRun
    if starsNeeded == nil or starsNeeded == -1 or starsNeeded > m.numStars then return end -- only if have enough for run
    local np = gNetworkPlayers[0]
    if m.playerIndex ~= 0 or np.currCourseNum ~= COURSE_NONE then return end -- only for local and in castle

    local obj = obj_get_first(OBJ_LIST_SURFACE)

    while obj ~= nil do
        local objID = get_id_from_behavior(obj.behavior)
        if objID > id_bhv_max_count then
          print("deleted",objID,(obj.oBehParams >> 24))
          obj_mark_for_deletion(obj)
          return
        end
        obj = obj_get_next(obj)
    end
end

-- sets up the minihunt blacklist using an encrypted value and mini_exclude
function setup_mini_blacklist(blacklistData)
  mini_blacklist = {}
  if blacklistData and blacklistData ~= "none" then
    decrypt_black(blacklistData)
  elseif ROMHACK.mini_exclude ~= nil then
    for id,value in pairs(ROMHACK.mini_exclude) do
      if value == 1 then
        mini_blacklist[id] = 1
      end
    end
  end
end

-- takes the encrypted data and returns the blacklist
function decrypt_black(blacklistData)
  mini_blacklist = {}
  local i = 0
  for course=1,24 do -- exclude ending
    if string.len(blacklistData) <= i-1 then break end

    local courseData = tonumber("0x"..string.sub(blacklistData,i+1,i+2)) or 0
    --print(courseData)
    for act=1,7 do
      if (courseData & 2^(act-1)) ~= 0 then
        mini_blacklist[course*10+act] = 1
        --djui_chat_message_create(tostring(courseData))
      end
    end
    -- unused because we don't store course 0
    --[[if (courseData & 128) ~= 0 then -- use star 8 of other courses as course 0
      mini_blacklist[course] = 1
      --print(0,course)
    end]]
    i = i + 2
  end
end
-- encrypts the blacklist into one number value
function encrypt_black()
  local fullEncrypt = ""
  local encrypted = "00"
  for course=1,24 do -- exclude ending
    local courseData = 0
    for act=1,7 do
      local doCourse = course
      local doAct = act
      -- unused because we don't store course 0
      --[[if act == 8 then -- use act 8 for course 0
        if course > 7 then break end
        doAct = course
        doCourse = 0
      end]]
      if mini_blacklist[doCourse*10+doAct] ~= nil then
        courseData = courseData + 2^(act-1)
      end
    end
    --djui_chat_message_create(string.format("%02x",courseData))
    fullEncrypt = fullEncrypt .. string.format("%02x",courseData)
    if courseData ~= 0 then
      encrypted = fullEncrypt
    end
  end
  return encrypted
end
-- runs for all players unless dontReload is true
function on_black_changed(tag, oldVal, newVal)
  if oldVal ~= newVal and (not dontReload) then
    setup_mini_blacklist(newVal)
  elseif dontReload then
    dontReload = false
  end
end
hook_on_sync_table_change(gGlobalSyncTable, "blacklistData", "blacklist_change", on_black_changed)

-- stars to track (replicas and such are in romhack_data)
star_ids = {
  [id_bhvStar] = "bhvStar",
  [id_bhvSpawnedStar] = "bhvSpawnedStar",
  [id_bhvSpawnedStarNoLevelExit] = "bhvSpawnedStarNoLevelExit",
  [id_bhvStarSpawnCoordinates] = "bhvStarSpawnCoordinates",
}

-- other sources for stars (again, more in romhack_data)
-- The second argument is:
-- TRUE if the 2nd byte doesn't matter
-- 0xFF for any non-zero value for the second byte
-- some other number value for the second byte being equal to such
-- exclamation boxes, KTQ, toad, mips, and piranha plants are special cases
star_sources = {
  [id_bhvKingBobomb] = {true, "Big Battle with King Bob-Omb"},
  [id_bhvWhompKingBoss] = {true, "Chip Off Whomp's Block"},
  [id_bhvHiddenRedCoinStar] = {true, "Find The Red Coins"},
  [id_bhvBowserCourseRedCoinStar] = {true, "Find The Red Coins"},
  [id_bhvHiddenStar] = {true, "5 Hidden Secrets"},
  [id_bhvTuxiesMother] = {true, "Li'l Penguin Lost"},
  [id_bhvWigglerHead] = {true, "Make Wiggler Squirm"},
  [id_bhvEyerokBoss] = {true, "Hand to Hand with Eyerok"},
  [id_bhvBalconyBigBoo] = {true, "Bout with Big Boo"},
  [id_bhvGhostHuntBigBoo] = {true, "Go On A Ghost Hunt"},
  [id_bhvMerryGoRoundBooManager] = {true, "Merry Go Round"},
  [id_bhvTreasureChests] = {true, "Puzzle of the Chests"},
  [id_bhvTreasureChestsJrb] = {true, "Puzzle of the Chests"},
  [id_bhvRacingPenguin] = {true, "Penguin Race"},
  [id_bhvUnagi] = {0x01, "Can The Eel Come Out To Play?"}, -- Is this correct?
  [id_bhvSnowmansHead] = {true, "Snowman's Lost His Head"},
  [id_bhvBigBully] = {true, "Battle the Big Bully"},
  [id_bhvBigChillBully] = {true, "Chill With The Bully"},
  [id_bhvBigBullyWithMinions] = {true, "Bully The Bullies"},
  [id_bhvCcmTouchedStarSpawn] = {true, "Sliding Star"},
  [id_bhvMrI] = {0xFF, "Eye To Eye"}, -- any set byte
  [id_bhvMantaRay] = {true, "The Manta Ray's Reward"},
  [id_bhvJetStreamRingSpawner] = {true, "Through The Jet Stream"},
  [id_bhvKlepto] = {0xFF, "In The Talons Of The Big Bird"}, -- any set byte
  [id_bhvUkikiCage] = {true, "Mystery Of The Monkey Cage"},
  [id_bhvFirePiranhaPlant] = {0xFF, "Pluck The Piranha Plants"}, -- any set byte
}

-- thank you sunk
exclamation_box_valid = {
  [8] = true,
  [10] = true,
  [11] = true,
  [12] = true,
  [13] = true,
  [14] = true
}

-- I wish there was a better way to do this
course_to_level = {
  [COURSE_NONE] = LEVEL_CASTLE_GROUNDS, -- Course 0 (note that courtyard and inside are also course 0); won't appear in minihunt
  [COURSE_BOB] = LEVEL_BOB, -- Course 1
  [COURSE_WF] = LEVEL_WF, -- Course 2
  [COURSE_JRB] = LEVEL_JRB, -- Course 3
  [COURSE_CCM] = LEVEL_CCM, -- Course 4
  [COURSE_BBH] = LEVEL_BBH, -- Course 5
  [COURSE_HMC] = LEVEL_HMC, -- Course 6
  [COURSE_LLL] = LEVEL_LLL, -- Course 7
  [COURSE_SSL] = LEVEL_SSL, -- Course 8
  [COURSE_DDD] = LEVEL_DDD, -- Course 9
  [COURSE_SL] = LEVEL_SL, -- Course 10
  [COURSE_WDW] = LEVEL_WDW, -- Course 11
  [COURSE_TTM] = LEVEL_TTM, -- Course 12
  [COURSE_THI] = LEVEL_THI, -- Course 13
  [COURSE_TTC] = LEVEL_TTC, -- Course 14
  [COURSE_RR] = LEVEL_RR, -- Course 15
  [COURSE_BITDW] = LEVEL_BITDW, -- Course 16 (also bowser 1)
  [COURSE_BITFS] = LEVEL_BITFS, -- Course 17 (also bowser 2)
  [COURSE_BITS] = LEVEL_BITS, -- Course 18 (also bowser 3)
  [COURSE_PSS] = LEVEL_PSS, -- Course 19
  [COURSE_COTMC] = LEVEL_COTMC, -- Course 20
  [COURSE_TOTWC] = LEVEL_TOTWC, -- Course 21
  [COURSE_VCUTM] = LEVEL_VCUTM, -- Course 22
  [COURSE_WMOTR] = LEVEL_WMOTR, -- Course 23
  [COURSE_SA] = LEVEL_SA, -- Course 24
  [COURSE_CAKE_END] = LEVEL_ENDING, -- Course 25 (will not appear in MiniHunt)
}
string_to_level = {
  ["grounds"] = LEVEL_CASTLE_GROUNDS,
  ["castle"] = LEVEL_CASTLE,
  ["courtyard"] = LEVEL_CASTLE_COURTYARD,
  ["bob"] = LEVEL_BOB, -- Course 1
  ["wf"] = LEVEL_WF, -- Course 2
  ["jrb"] = LEVEL_JRB, -- Course 3
  ["ccm"] = LEVEL_CCM, -- Course 4
  ["bbh"] = LEVEL_BBH, -- Course 5
  ["hmc"] = LEVEL_HMC, -- Course 6
  ["lll"] = LEVEL_LLL, -- Course 7
  ["ssl"] = LEVEL_SSL, -- Course 8
  ["ddd"] = LEVEL_DDD, -- Course 9
  ["sl"] = LEVEL_SL, -- Course 10
  ["wdw"] = LEVEL_WDW, -- Course 11
  ["ttm"] = LEVEL_TTM, -- Course 12
  ["thi"] = LEVEL_THI, -- Course 13
  ["ttc"] = LEVEL_TTC, -- Course 14
  ["rr"] = LEVEL_RR, -- Course 15
  ["bitdw"] = LEVEL_BITDW, -- Course 16
  ["b1"] = LEVEL_BOWSER_1,
  ["bitfs"] = LEVEL_BITFS, -- Course 17
  ["b2"] = LEVEL_BOWSER_2,
  ["bits"] = LEVEL_BITS, -- Course 18
  ["b3"] = LEVEL_BOWSER_3,
  ["pss"] = LEVEL_PSS, -- Course 19
  ["cotmc"] = LEVEL_COTMC, -- Course 20
  ["totwc"] = LEVEL_TOTWC, -- Course 21
  ["vcutm"] = LEVEL_VCUTM, -- Course 22
  ["wmotr"] = LEVEL_WMOTR, -- Course 23
  ["sa"] = LEVEL_SA, -- Course 24
  ["end"] = LEVEL_ENDING, -- Course 25
}
string_to_course = {
  ["grounds"] = COURSE_NONE,
  ["castle"] = COURSE_NONE,
  ["courtyard"] = COURSE_NONE,
  ["bob"] = COURSE_BOB, -- Course 1
  ["wf"] = COURSE_WF, -- Course 2
  ["jrb"] = COURSE_JRB, -- Course 3
  ["ccm"] = COURSE_CCM, -- Course 4
  ["bbh"] = COURSE_BBH, -- Course 5
  ["hmc"] = COURSE_HMC, -- Course 6
  ["lll"] = COURSE_LLL, -- Course 7
  ["ssl"] = COURSE_SSL, -- Course 8
  ["ddd"] = COURSE_DDD, -- Course 9
  ["sl"] = COURSE_SL, -- Course 10
  ["wdw"] = COURSE_WDW, -- Course 11
  ["ttm"] = COURSE_TTM, -- Course 12
  ["thi"] = COURSE_THI, -- Course 13
  ["ttc"] = COURSE_TTC, -- Course 14
  ["rr"] = COURSE_RR, -- Course 15
  ["bitdw"] = COURSE_BITDW, -- Course 16
  ["b1"] = COURSE_BOWSER_1,
  ["bitfs"] = COURSE_BITFS, -- Course 17
  ["b2"] = COURSE_BOWSER_2,
  ["bits"] = COURSE_BITS, -- Course 18
  ["b3"] = COURSE_BOWSER_3,
  ["pss"] = COURSE_PSS, -- Course 19
  ["cotmc"] = COURSE_COTMC, -- Course 20
  ["totwc"] = COURSE_TOTWC, -- Course 21
  ["vcutm"] = COURSE_VCUTM, -- Course 22
  ["wmotr"] = COURSE_WMOTR, -- Course 23
  ["sa"] = COURSE_SA, -- Course 24
  ["end"] = COURSE_CAKE_END, -- Course 25
}
level_to_course = {
  [LEVEL_CASTLE_GROUNDS] = COURSE_NONE, -- Course 0
  [LEVEL_CASTLE] = COURSE_NONE, -- Course 0
  [LEVEL_CASTLE_COURTYARD] = COURSE_NONE, -- Course 0
  [LEVEL_BOB] = COURSE_BOB, -- Course 1
  [LEVEL_WF] = COURSE_WF, -- Course 2
  [LEVEL_JRB] = COURSE_JRB, -- Course 3
  [LEVEL_CCM] = COURSE_CCM, -- Course 4
  [LEVEL_BBH] = COURSE_BBH, -- Course 5
  [LEVEL_HMC] = COURSE_HMC, -- Course 6
  [LEVEL_LLL] = COURSE_LLL, -- Course 7
  [LEVEL_SSL] = COURSE_SSL, -- Course 8
  [LEVEL_DDD] = COURSE_DDD, -- Course 9
  [LEVEL_SL] = COURSE_SL, -- Course 10
  [LEVEL_WDW] = COURSE_WDW, -- Course 11
  [LEVEL_TTM] = COURSE_TTM, -- Course 12
  [LEVEL_THI] = COURSE_THI, -- Course 13
  [LEVEL_TTC] = COURSE_TTC, -- Course 14
  [LEVEL_RR] = COURSE_RR, -- Course 15
  [LEVEL_BITDW] = COURSE_BITDW, -- Course 16
  [LEVEL_BOWSER_1] = COURSE_BITDW, -- Course 16
  [LEVEL_BITFS] = COURSE_BITFS, -- Course 17
  [LEVEL_BOWSER_2] = COURSE_BITFS, -- Course 17
  [LEVEL_BITS] = COURSE_BITS, -- Course 18
  [LEVEL_BOWSER_3] = COURSE_BITS, -- Course 18
  [LEVEL_PSS] = COURSE_PSS, -- Course 19
  [LEVEL_COTMC] = COURSE_COTMC, -- Course 20
  [LEVEL_TOTWC] = COURSE_TOTWC, -- Course 21
  [LEVEL_VCUTM] = COURSE_VCUTM, -- Course 22
  [LEVEL_WMOTR] = COURSE_WMOTR, -- Course 23
  [LEVEL_SA] = COURSE_SA, -- Course 24
  [LEVEL_ENDING] = COURSE_CAKE_END, -- Course 25 (will not appear in MiniHunt)
}