--[[ This file is a base for making your hack compatible with MarioHunt.
Be sure to read below.
]]

-- various flags used for star_data (see below)
STAR_EXIT = 0x10 -- player can leave when grabbing this star (use this to avoid getting stuck)
STAR_IGNORE_STARMODE = 0x20 -- star is not counted in star mode (use this for stars that require caps?)
STAR_ACT_SPECIFIC = 0x40 -- star can only be gotten in this act (use for situations like KTQ)
STAR_NOT_ACT_1 = 0x80 -- star cannot be gotten in act 1 (useful for situations like the tower in WF)
STAR_APPLY_NO_ACTS = 0x100 -- applies even if disable acts is on (like in OMM)
STAR_NOT_BEFORE_THIS_ACT = 0x200 -- star cannot be gotten before this act (so if this is on star 3, it cannot be obtained in acts 1 and 2)
STAR_MULTIPLE_AREAS = 0x400 -- only needed if your star can be obtained in multiple areas (contact me if this is the case, this is sort of advanced)
STAR_AREA_MASK = 0xF -- 1-15

if not _G.mhExists then return end -- don't load if MarioHunt isn't enabled

-- Most default values are based off of vanilla.
_G.mhApi.romhackSetup = function()
  return {
    name = "My Cool Rom Hack", -- The name of your rom hack
    badGuy = "The Eggman", -- This will display instead of "Bowser" in the rules if set
    badGuy_es = "El Eggman", -- For other languages, add _ followed by the languages abbreviation (Useful for when articles are used)
    -- for portuguese, you have to place this at the end due to the - in pt-br (see bottom)

    -- How many stars are in a glitchless run (ex: 70 in vanilla).
    -- If your hack doesn't require ANY stars, set this to -1 (like in Ztar Attack 2)
    default_stars = 70,

    max_stars = 120, -- How many total stars there are (ex: 120 in vanilla)

    -- Setting this removes the rightmost star from all secret levels until reaching this amount of stars
    -- If your hack doesn't have replicas, omit this
    replica_start = 121,

    -- This enforces star requirements for your rom hack (unless star run is lower) to prevent glitches
    requirements = {
      [LEVEL_BITDW] = 8,
      [LEVEL_BOWSER_1] = 10, -- Works seperately from BITDW (so you could enter BITDW but not the bowser boss fight)
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
    heartReplace = true, -- replaces all hearts with 1ups (some hacks require the hearts for lava boosting, so omit this if that's the case)
    stalk = true, -- Enables a feature that lets anyone warp to a runner's level (used in Ztar Attack 2 due to linear nature of hack). Omit this to disable (recommended for most hacks)
    starColor = {r = 92,g = 255,b = 92}, -- this sets the color of the stars for your hack (yellow if omitted). This example makes stars green
    noLobby = true, -- disables the lobby (but why would you want that? :( )

    -- This is a complex table that controls when certain stars are obtainable
    -- Each entry is a table with the following format for each entry, with up to 7 entries (1 for each star)
      -- A number specifying the area. Set this to 0 to flag the star as unobtainable, and 8 for being obtainable from all areas
        -- Set this to 8 for the lowermost area (ex: the ship in JRB) because you can't get back
      -- Use the | operator on this number to add flags, as shown at the top of the file
    -- For any base game stages where all stars can be obtained in all acts, and its impossible to get stuck, you don't need to set anything
    -- Secret stages will have 1 star by default and the castle (COURSE_NONE) will have 5 by default
    star_data = {
      [COURSE_BOB] = {8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8, 8}, -- This sets stars 1 and 2 as act specific
      [COURSE_WF] = {8 | STAR_ACT_SPECIFIC, 8 | STAR_NOT_ACT_1, 8, 8, 8, 8, 8}, -- Star 1 is act specific, star 2 is exclusive to not act 1
      [COURSE_SSL] = {1 | STAR_ACT_SPECIFIC, 1, 8, 8 | STAR_EXIT, 1, 8, 1}, -- Any stars outside are the pyramid are set as only being obtainable in area 1 to avoid getting stuck
      -- (pyramid stars are set to 8 because area 2 can be reached from area 1)
      [COURSE_WMOTR] = {8 | STAR_IGNORE_STARMODE | STAR_APPLY_NO_ACTS} -- Only star 1 is available, and will be ignored if star mode is enabled even in OMM
    },
    -- use star_data_ee to override counts for extreme edition (probably not needed for any other hacks)

    -- exclude some stars in MiniHunt
    -- You should exclude ones that are too fast, ones that don't respawn (ex: toad stars)
    -- or ones that involve alternate level entrances (ex: The Other Entrance in Star Road)
    -- The first two digits are the course number (applies to secret stages too; check the table near bottom of romhack_data)
    -- and the last digit is the star number
    -- note that 7 (100 Coins Star) is excluded by default for courses 1-15
    mini_exclude = {
      [103] = 1, -- This excludes star 3 of course 10 (Snowman's Land)
      [231] = 1, -- This excludes star 1 of course 23 (Wing Mario Over The Rainbow)
    },

    -- This is a function that runs every frame for all players.
    -- gotStar is nil, or the number of what star the *local* player got
    -- You can omit this unless your hack has some sort of special case (check romhack_data.lua for examples)
    -- This one in particular warps the player out of DDD and into BITFS if the star run is 0.
    special_run = function(m,gotStar)
      local np = gNetworkPlayers[m.playerIndex]
      if m.playerIndex == 0 and np.currLevelNum == LEVEL_DDD and gGlobalSyncTable.starRun == 0 and gGlobalSyncTable.mhMode ~= 2 then
        warp_to_level(LEVEL_BITFS, 1, 0)
      end
    end,

    -- extra hub stages (that aren't part of the castle)
    -- these stages are also excluded in MiniHunt
    hubStages = {
      [COURSE_WMOTR] = 1, -- like in SM74's Tower Of The East
    },

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

    -- This is another example, which wins as soon as a runner enters the cake screen
    --[[
    runner_victory = function(m)
      local np = gNetworkPlayers[m.playerIndex]
      if np.currLevelNum == LEVEL_ENDING then
        return true
      end
      return false
    end,
    ]]

    ["badguy_pt-br"] = "O Eggman", -- how you would specify for pt-br
  }
end
