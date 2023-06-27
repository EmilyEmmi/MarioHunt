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

    -- allow leaving immediatly when grabbing these stars to avoid getting trapped
    area_stars = {
      [LEVEL_JRB] = {2, 1}, -- 1 star in ship
      [LEVEL_SSL] = {2, 1}, -- 1 star in pyramid (to avoid getting trapped in hand)
      [LEVEL_LLL] = {2, 2}, -- 2 stars in volcano
      [LEVEL_THI] = {3, 1}, -- 1 star inside island (for wiggler)
      [LEVEL_TOTWC] = {1, 0}, -- can get trapped in wing
      [LEVEL_VCUTM] = {1, 0}, -- can get trapped in vanish
      [LEVEL_PSS] = {1, 1}, -- you can fail time challenge
      [LEVEL_WMOTR] = {1, 0}, -- you can enter without wing cap
    },

    -- exclude some stars in MiniHunt
    mini_exclude = {
      [103] = 1, -- In The Deep Freeze (too easy)
      [124] = 1, -- Mysterious Mountainside (too easy)
      [84] = 1, -- Stand Tall On Four Pillars (too annoying)
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

    -- star count for secret courses (only ones with more than 1 star)
    starCount = {
      [LEVEL_PSS] = 2, -- this is the only one lol
    },
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
      [LEVEL_BITDW] = 20,
      [LEVEL_BITFS] = 40,
      [LEVEL_BITS] = 80,
      [LEVEL_WMOTR] = 120, -- hidden palace
    },

    area_stars = {
      [LEVEL_SA] = {1, 1}, -- you can fail time challenge
    },

    -- renumber some stars
    renumber_stars = {
      [5] = 0, -- There IS no second mips
      [162] = 4, -- Replica for Bowser's Slippery Swamp
      [172] = 5, -- Replica for Retro Remix Castle
      [182] = 6, -- Replica for Bowser's Rainbow Rumble
      [193] = 6, -- Replica for Mushroom Mountain Town
      [202] = 5, -- Replica for Creepy Cap Cave
      [212] = 6, -- Replica for Windy Wing Cap Well
      [222] = 6, -- Replica for Puzzle Of The Vanish Cap
      [232] = 6, -- Replica for Hidden Palace Finale
      [243] = 6, -- Replica for Sandy Slide Secret
      [251] = 2, -- ending star
    },
    -- exclude some stars in MiniHunt
    mini_exclude = {
      [46] = 1, -- The Other Entrance
      [205] = 1, -- Replica for Creepy Cap Cave
    },

    special_run = function(m,gotStar)
      deleteStarRoadStuff(m)
      local np = gNetworkPlayers[0]
      -- prevent getting trapped in cage star
      if m.action == ACT_TELEPORT_FADE_IN and m.playerIndex == 0 and np.currLevelNum == LEVEL_CCM
      and m.pos.x < -4000 and m.pos.z < -4700 then
        local sMario = gPlayerSyncTable[0]
        sMario.allowLeave = true
      end
    end,

    starCount = {
      [LEVEL_CASTLE_GROUNDS] = 4,
      [LEVEL_PSS] = 2, -- Mushroom Mountain Town
      [LEVEL_SA] = 2, -- Sandy Slide Secret
      [LEVEL_ENDING] = 1, -- Peach's Castle (Ending)
    },
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
      [216] = "Replica Of The Air Balloon",
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

    starCount = {
      [LEVEL_COTMC] = 5, -- Toxic-Switch of Danger
      [LEVEL_BITDW] = 4, -- Bowser's Badlands-Battlefield
      [LEVEL_WMOTR] = 6, -- Tower of the East
      [LEVEL_TOTWC] = 3, -- Lava-Switch of Eruption
      [LEVEL_VCUTM] = 6, -- Dust-Switch of Identity
      [LEVEL_PSS] = 4, -- Frozen Slide
      [LEVEL_BITFS] = 5, -- Bowser's Aquatic Castle
      [LEVEL_SA] = 1, -- Champion's Challenge (there's another star but it is hard to get so we ignore in the time)
      [LEVEL_BITS] = 6, -- Bowser's Crystal Palace
    },
    -- EE has some different counts
    starCount_ee = {
      [LEVEL_COTMC] = 6, -- Toxic Terrace
      [LEVEL_SA] = 7, -- Triarc-Bridge
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

    -- renumber final star
    renumber_stars = {
      [242] = 3,
      [243] = 2, -- make sure star 3 is still considered in ee
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
        if network_is_server() then
          gGlobalSyncTable.ee = (np.currAreaIndex ~= 1)
          return
        else
          if gGlobalSyncTable.ee then
            djui_chat_message_create(trans("using_ee"))
          else
            djui_chat_message_create(trans("not_using_ee"))
          end
          warp_to_level(np.currLevelNum, np.currAreaIndex ~ 3, np.currActNum)
          return
        end
      end
    end,
},

["sapphire"] = {
  name = "Super Mario 64 Sapphire",
  default_stars = 30,
  max_stars = 30,
  requirements = {
    [LEVEL_BITS] = 30,
    [LEVEL_BOWSER_3] = 30,
  },
  ommSupport = false, -- does not have default omm support

  -- since not all courses are modified here, exclude those
  starCount = {
    [LEVEL_CASTLE_GROUNDS] = 0,
    [LEVEL_BBH] = 0,
    [LEVEL_HMC] = 0,
    [LEVEL_LLL] = 0,
    [LEVEL_SSL] = 0,
    [LEVEL_DDD] = 0,
    [LEVEL_SL] = 0,
    [LEVEL_WDW] = 0,
    [LEVEL_TTM] = 0,
    [LEVEL_THI] = 0,
    [LEVEL_TTC] = 0,
    [LEVEL_RR] = 0,
    [LEVEL_BITDW] = 0,
    [LEVEL_BITFS] = 0,
    [LEVEL_BITS] = 0,
    [LEVEL_PSS] = 2, -- includes toad star
    [LEVEL_COTMC] = 0,
    [LEVEL_TOTWC] = 0,
    [LEVEL_VCUTM] = 0,
    [LEVEL_WMOTR] = 0,
    [LEVEL_SA] = 0,
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
    return m.action == ACT_JUMBO_STAR_CUTSCENE
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
  starCount = { -- in order
    -- World 1
    [LEVEL_BOB] = 2,
    [LEVEL_WF] = 2,
    [LEVEL_JRB] = 3,
    [LEVEL_BITDW] = 4,
    -- World 2
    [LEVEL_CCM] = 2,
    [LEVEL_BBH] = 4,
    [LEVEL_HMC] = 5,
    [LEVEL_BITFS] = 5,
    -- World 3
    [LEVEL_LLL] = 4,
    [LEVEL_SSL] = 3,
    [LEVEL_DDD] = 3,
    [LEVEL_COTMC] = 6,
    -- World 4
    [LEVEL_SL] = 2,
    [LEVEL_WDW] = 6,
    [LEVEL_TTM] = 3,
    [LEVEL_VCUTM] = 5,
    -- World 5
    [LEVEL_THI] = 4,
    [LEVEL_TTC] = 6,
    [LEVEL_RR] = 6,
    [LEVEL_BITS] = 6,
    [LEVEL_TOTWC] = 1,
    -- Extra
    [LEVEL_PSS] = 1, -- The Super Quiz
    [LEVEL_WMOTR] = 1, -- Negative Realm
    [LEVEL_SA] = 4, -- Gaell's Dream
    [LEVEL_ENDING] = 1, -- The End
    [LEVEL_CASTLE_GROUNDS] = 1, -- has mips
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

  -- this renumbers certains stars
  renumber_stars = {
    -- renumber mips star
    [1] = 4,
    -- renumber stars in Gaell's Dream
    [243] = 5,
    [244] = 6,
    -- renumber the ending star
    [251] = 3,
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

  starCount = {
    [LEVEL_CASTLE_GROUNDS] = 3, -- no mips
    [LEVEL_BITDW] = 3,
    [LEVEL_BITFS] = 4,
    [LEVEL_BITS] = 4,
    [LEVEL_PSS] = 4,
    [LEVEL_COTMC] = 3,
    [LEVEL_TOTWC] = 2,
    [LEVEL_VCUTM] = 0, -- does not exist
    [LEVEL_WMOTR] = 1,
    [LEVEL_SA] = 2,
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

default = {
    name = "Default",
    default_stars = -1,
    max_stars = 255,
    requirements = {[LEVEL_BOWSER_3] = 255}, -- block off Bowser 3 until needed stars are collected

    starCount = {}, -- assume every secret stage has 1 star

    runner_victory = function(m)
      return m.action == ACT_JUMBO_STAR_CUTSCENE
    end,
},

}

ROMHACK = {}
function setup_hack_data(settingRomHack,initial,usingOMM)
  local romhack_file = gGlobalSyncTable.romhackFile
  ROMHACK = romhack_data[romhack_file]
  if initial and usingOMM then
    gGlobalSyncTable.weak = true -- turn on half frames automatically
    djui_popup_create(trans("omm_detected"), 1)
  end

  if ROMHACK == nil and settingRomHack then
    if _G.mhApi == nil or _G.mhApi.romhackSetup == nil then
      romhack_file = "vanilla"
      for i,mod in pairs(gActiveMods) do
        if mod.enabled and mod.incompatible ~= nil then
          if string.find(mod.incompatible,"romhack") then -- is a romhack
            romhack_file = mod.relativePath
          elseif string.find(mod.incompatible,"gamemode") then -- is mariohunt
            if string.find(mod.basePath,"sm64ex/-coop") then
              djui_popup_create("WARNING: Mod installed in base directory; API may not function",2)
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

  if settingRomHack then
    gGlobalSyncTable.starRun = ROMHACK.default_stars
    gGlobalSyncTable.romhackFile = romhack_file
  end
  return romhack_file
end

-- exteme edition support, and sets minihunt level as beginning
function warp_beginning()
  warpCount = 0
  warpCooldown = 0
  if gGlobalSyncTable.mhMode == 2 and gGlobalSyncTable.mhState ~= 0 then
    local correctAct = gGlobalSyncTable.getStar
    local area = 1
    if gGlobalSyncTable.ee then area = 2 end
    if correctAct == 7 then correctAct = 6 end
    warp_to_level(gGlobalSyncTable.gameLevel, area, correctAct)
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
  [25] = LEVEL_ENDING, -- Course 25 (will not appear in MiniHunt)
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
