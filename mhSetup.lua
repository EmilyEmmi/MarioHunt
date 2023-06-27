-- selectable: false

--[[ This file is a base for making your hack compatible with MarioHunt.
Be sure to read below.
]]

-- Most default values are based off of vanilla.
_G.mhApi.romhackSetup = function()
  return {
    name = "My Cool Rom Hack", -- The name of your rom hack

    -- How many stars are in a glitchless run (ex: 70 in vanilla).
    -- If your hack doesn't require ANY stars, set this to -1 (like in Ztar Attack 2)
    default_stars = 70,

    max_stars = 120, -- How many total stars there are (ex: 120 in vanilla)

    -- An extra star is added to all secret stages when a runner has this many stars
    -- If your hack doesn't have replicas, omit this
    replica_start = 121,

    -- This enforces star requirements for your rom hack (unless star run is lower) to prevent glitches
    requirements = {
      [LEVEL_BITDW] = 8,
      [LEVEL_BOWSER_1] = 8, -- In vanilla, Bowser 1 is IN BITDW, so this would not be necessary
      [LEVEL_DDD] = 30,
      [LEVEL_BITFS] = 31,
      [LEVEL_TTC] = 50,
      [LEVEL_RR] = 50,
      [LEVEL_WMOTR] = 50,
      [LEVEL_BITS] = 70,
      -- If runner victory occurs upon defeating Bowser, make sure this is set to whatever max_stars is
      -- to ensure runners don't fight Bowser early.
      -- Otherwise, just omit this or set it to whatever BITS is set to.
      [LEVEL_BOWSER_3] = 120,
    },

    ddd = true, -- This handles considering Board Bowser's Sub in runs. Omit this unless your hack is a vanilla edit.
    no_bowser = true, -- If your hack's goal doesn't involve beating Bowser, set this to true. Otherwise, omit this.
    ommSupport = false, -- If your hack doesn't support OMM (most likely it doesn't), set this to false. Otherwise, omit this. (only affects the radar)

    -- stars in certain sub areas, for star mode to avoid getting trapped
    -- Just omit this if their aren't any such areas.
    -- The first parameter is the area, the second is how many stars are *always* possible
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
    -- You should exclude ones that are too fast, ones that don't respawn (ex: toad stars)
    -- or ones that involve alternate level entrances (ex: The Other Entrance in Star Road)
    -- The first two digits are the course number (applies to secret stages too; check the table near bottom of romhack_data)
    -- and the last digit is the star number
    -- note that 7 (100 Coins Star) is excluded by default
    mini_exclude = {
      [103] = 1, -- This excludes star 3 of course 10 (Snowman's Land)
      [231] = 1, -- This excludes star 1 of course 23 (Wing Mario Over The Rainbow)
    },
    -- this renumbers stars if they are out of order (ex: course doesn't have star 2, but it does have star 6)
    -- use the last available star to order
    renumber_stars = {
      [161] = 2, -- this would make Star 2 of BITDW be inserted instead of Star 1
      [162] = 3, -- this makes Star 3 of BITDW be inserted instead of Star 2 (does not conflict with above)
      -- above only works if BITDW is marked as having 2 stars
      [3] = 0, -- This marks that Toad Star 3 not exist
    },

    -- If your hack has custom star objects, use this to mark them as such
    -- Otherwise, omit this
    otherStarIds = (function()
      return { -- table of other objects to be marked as stars
      [bhvSMSRStarReplica] = "bhvSMSRStarReplica",
      [bhvSMSRStarMoving] = "bhvSMSRStarMoving",
      }
    end),

    -- This is a function that runs every frame for all players.
    -- gotStar is nil, or the number of what star the local player got
    -- You can omit this unless your hack has some sort of special case (check romhack_data.lua for examples)
    -- This one in particular warps the player out of DDD and into BITFS if the star run is 0.
    special_run = function(m,gotStar)
      local np = gNetworkPlayers[m.playerIndex]
      if m.playerIndex == 0 and np.currLevelNum == LEVEL_DDD and gGlobalSyncTable.starRun == 0 and gGlobalSyncTable.mhMode ~= 2 then
        warp_to_level(LEVEL_BITFS, 1, 0)
      end
    end,

    -- This is how many stars are in the level.
    -- Don't set this for the castle or castle grounds. DO set this for ending stage, if applicable.
    -- If your hack doesn't contain a level, set it to 0.
    -- This is 7 by default for the main stages and 1 by default for secret stages
    -- It is also 5 by default for the castle (use LEVEL_CASTLE_GROUNDS) and 0 for the ending
    starCount = {
      [LEVEL_BOB] = 7, -- This is unnecessary because BOB has 7 by default
      [LEVEL_SA] = 1, -- This is also unnecessary because SA has 1 by default
      [LEVEL_PSS] = 2, -- 2 stars here
      [LEVEL_BBH] = 0, -- If our hack doesn't contain BBH, we set this to zero
    },
    -- extra hub stages (that aren't part of the castle)
    -- these stages are also excluded in MiniHunt
    hubStages = {
      [COURSE_WMOTR] = 1, -- like in SM74's Tower Of The East
    },
    -- starCount_ee overrides the count for some levels if Extreme Edition is enabled. Only SM74 will ever use it, most likely.

    -- This handles custom star names.
    -- The format is the same as in mini_exclude
    -- Generally, names start *every* word with a capital letter, including "the" and "of"
    starNames = {
      [161] = "Red Coins Of The Dark", -- BITDW's red coin star
      [231] = "The Rainbow's Red Coins", -- WMOTR's red coins star
      [11] = "The First Star!", -- BOB's first star; this overrides the standard name
    },
    -- again, starNames_ee exists too

    -- This function detects when runners have won. For a typical hack, this should work
    runner_victory = function(m)
      return m.action == ACT_JUMBO_STAR_CUTSCENE
    end,

    -- This is an example of an atypical victory condition; bowser is set to beaten when the ending level is accessed, but victory occurs after enough stars are colelcted
    --[[
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
    end,]]
  }
end
