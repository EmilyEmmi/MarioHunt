romhack_data["star-road"] = {
  name = "Star Road",
  default_stars = 80,
  max_stars = 130,
  ommColorStar = true,
  requirements = {
    [LEVEL_CCM] = 8,  -- Chuckya Harbor
    [LEVEL_BBH] = 8,  -- Gloomy Garden
    [LEVEL_BITDW] = 20,
    [LEVEL_DDD] = 30, -- Mad Musical Mess
    [LEVEL_BITFS] = 40,
    [LEVEL_BITS] = 80,
    [LEVEL_WMOTR] = 120, -- Hidden Palace Finale
  },
  heartReplace = true,   -- replaces all hearts with 1ups (doesn't affect the bubbles in the coral level, thankfully)
  lifeOverride = true,   -- prevent star road 0 life

  -- mostly defining replicas
  star_data = {
    [COURSE_NONE] = { 8, 8, 8, 8 },
    [COURSE_BOB] = { 8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8, 8, 8 },
    [COURSE_WF] = { 8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8, 8, 8 },
    [COURSE_JRB] = { 8, 8, 8, 8, 8, 8 | STAR_ACT_SPECIFIC, 8 },
    [COURSE_CCM] = { 8, 8, 8, 8, 8, 8 | STAR_IGNORE_STARMODE | STAR_EXIT | STAR_APPLY_NO_ACTS, 8 },                         -- don't get trapped in The Other Entrance
    [COURSE_BBH] = { 8 | STAR_ACT_SPECIFIC, 8, 8, 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8 | STAR_ACT_SPECIFIC, 8 }, -- wow, Gloomy Garden has a lot of act specifics
    [COURSE_HMC] = { 8, 8 | STAR_ACT_SPECIFIC, 8, 8 | STAR_ACT_SPECIFIC | STAR_EXIT, 8, 8, 8 },
    [COURSE_LLL] = { 8, 8 | STAR_ACT_SPECIFIC, 8 | STAR_NOT_BEFORE_THIS_ACT, 8, 8, 8, 8 },
    -- I decided to flag 100 coins here because I don't think there's enough coins without getting up the tree
    [COURSE_SSL] = { 8 | STAR_ACT_SPECIFIC | STAR_IGNORE_STARMODE, 8 | STAR_NOT_ACT_1, 8, 8 | STAR_NOT_ACT_1, 8 | STAR_NOT_ACT_1, 8, 8 | STAR_NOT_ACT_1 },
    [COURSE_SL] = { 8, 8 | STAR_NOT_ACT_1, 8, 8, 8, 8, 8 },
    [COURSE_TTM] = { 8, 8 | STAR_NOT_ACT_1, 8 | STAR_NOT_ACT_1, 8 | STAR_NOT_ACT_1, 8, 8, 8 },
    [COURSE_TTC] = { 8, 8, 8, 8, 8, 8 | STAR_ACT_SPECIFIC, 8 }, -- star 1 actually disappears in acts 5 and 6 (I could account for that but ehhh)
    [COURSE_WDW] = { 8 | STAR_ACT_SPECIFIC, 8, 8, 8, 8, 8, 8 },
    [COURSE_THI] = { 8, 8 | STAR_ACT_SPECIFIC, 8, 8, 8 | STAR_NOT_BEFORE_THIS_ACT, 8 | STAR_ACT_SPECIFIC | STAR_EXIT, 8 },
    [COURSE_RR] = { 8, 8, 8 | STAR_IGNORE_STARMODE | STAR_APPLY_NO_ACTS, 8, 8, 8 | STAR_EXIT | STAR_APPLY_NO_ACTS, 8 }, -- don't get trapped in In The Cage
    [COURSE_BITDW] = { 8, 0, 0, 8 | STAR_REPLICA },
    [COURSE_BITFS] = { 8, 0, 0, 0, 8 | STAR_REPLICA },
    [COURSE_BITS] = { 8, 0, 0, 0, 0, 8 | STAR_REPLICA },
    [COURSE_PSS] = { 8, 8, 0, 0, 0, 8 | STAR_REPLICA },
    [COURSE_COTMC] = { 8, 0, 0, 0, 8 | STAR_REPLICA },
    [COURSE_TOTWC] = { 8, 0, 0, 0, 0, 8 | STAR_REPLICA },
    [COURSE_VCUTM] = { 8, 0, 0, 0, 0, 8 | STAR_REPLICA },
    [COURSE_WMOTR] = { 8, 0, 0, 0, 0, 8 | STAR_REPLICA },
    [COURSE_SA] = { 8, 8 | STAR_IGNORE_STARMODE | STAR_APPLY_NO_ACTS, 0, 0, 0, 8 | STAR_REPLICA }, -- can fail time challenge
    [COURSE_CAKE_END] = { 0, 8 },
  },

  -- exclude some stars in MiniHunt
  mini_exclude = {
    [46] = 1,  -- The Other Entrance
    [205] = 1, -- Replica for Creepy Cap Cave
  },

  special_run = function(m, gotStar)
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
    [161] = "Across The Sinking Slabs",
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
    [216] = "Replica Of The Flying Ship",
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

  -- information for the Game Area setting
  gameAreaData = {
    {                -- default
      entryLevel = LEVEL_CASTLE_GROUNDS,
      entryNode = 0, -- uses default warp
      exitCastleLevel = LEVEL_CASTLE_GROUNDS,
      exitCastleWarpNode = 128,

      extraObject = {
        [261] = {
          { id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, -989, 3925, -1365, 0, LEVEL_CASTLE, 1 }, -- pipe over cannon to Star Haven
        },
        [61] = {
          { id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, 3400, 160, -2733, 0, LEVEL_CASTLE_COURTYARD, 1, 39 }, -- Star Haven pipe to Star Leap Tower
        },
      }
    },
    {
      name = "Courtyard",
      entryLevel = LEVEL_CASTLE_GROUNDS,
      entryNode = 0, -- uses default warp
      exitCastleLevel = LEVEL_CASTLE_GROUNDS,
      exitCastleWarpNode = 128,
      default_stars = 20,
      max_stars = 40,
      bannedAreas = {
        [261] = 1, -- Star-Leap Tower
        [61] = 1,  -- Star Haven
      },
      requirements = {
        [LEVEL_BITDW] = 20,
        [LEVEL_BOWSER_1] = 150,
      },
      runner_victory = function(m)
        return (save_file_get_flags() & (SAVE_FLAG_HAVE_KEY_1 | SAVE_FLAG_UNLOCKED_BASEMENT_DOOR)) ~= 0
      end,
      extraObject = {
        [241] = {
          { id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, 4023, 1744, -6491, 0, LEVEL_TOTWC, 1 }, -- pipe in SKR to wing cap
        },
      },
      warpNodeOverride = {
        [261] = {                                     -- warps from TOTWC
          [0x27] = { LEVEL_CASTLE_GROUNDS, 1, 0x24 }, -- star
          [0x28] = { LEVEL_CASTLE_GROUNDS, 1, 0x25 }, -- death
        },
      },
    },
    {
      name = "Lower Tower",
      entryLevel = LEVEL_CASTLE_COURTYARD,
      entryNode = 256,
      exitCastleLevel = LEVEL_CASTLE_COURTYARD,
      exitCastleWarpNode = 256,
      default_stars = 20,
      max_stars = 41,
      bannedAreas = {
        [161] = 1, -- Courtyard
        [61] = 1,  -- Star Haven
      },
      doorCost = {
        [30] = 8, -- only 8 because there is no 10 star door texture
        [40] = 20,
      },
      requirements = {
        [LEVEL_DDD] = 8, -- Mad Musical Mess
        [LEVEL_BITFS] = 20,
        [LEVEL_BOWSER_2] = 150,
      },
      runner_victory = function(m)
        return (save_file_get_flags() & (SAVE_FLAG_HAVE_KEY_2 | SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR)) ~= 0
      end,
      extraObject = {
        [71] = {
          { id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, 6305, 3374, 4200, 0, LEVEL_COTMC, 1 }, -- pipe in CCC to metal cap
        },
        [231] = {
          { id_bhvWarp, E_MODEL_NONE, 2007, 1800, 1258, 0x14000000, LEVEL_TOTWC, 1 }, -- warp in MMM to wing cap
        },
        [101] = {
          { id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, -1847, 285, -4682, 0, LEVEL_VCUTM, 1 }, -- pipe in MSP to vanish cap
        },
      },
      warpNodeOverride = {
        [161] = {                                       -- warps from VCUTM and COTMC
          [0x1B] = { LEVEL_CASTLE_COURTYARD, 1, 0x15 }, -- cotmc star
          [0x1C] = { LEVEL_CASTLE_COURTYARD, 1, 0x16 }, -- cotmc death
          [0x2A] = { LEVEL_CASTLE_COURTYARD, 1, 0x0C }, -- vcutm star
          [0x2B] = { LEVEL_CASTLE_COURTYARD, 1, 0x0D }, -- vcutm death
        },
        [261] = {                                       -- warps from TOTWC
          [0x27] = { LEVEL_CASTLE_COURTYARD, 1, 0x12 }, -- star
          [0x28] = { LEVEL_CASTLE_COURTYARD, 1, 0x13 }, -- death
        },
      },
    },
    {
      name = "Upper Tower",
      entryLevel = LEVEL_CASTLE_COURTYARD,
      entryNode = 8,
      exitCastleLevel = LEVEL_CASTLE_COURTYARD,
      exitCastleWarpNode = 8,
      default_stars = 20,
      max_stars = 36,
      bannedAreas = {
        [161] = 1, -- Courtyard
      },
      doorCost = {
        [65] = 10, -- only 8 because there is no 10 star door texture
        [80] = 20,
      },
      requirements = {
        [LEVEL_BITS] = 20,
      },
      extraObject = {
        [261] = {
          { id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, -989, 3925, -1365, 0, LEVEL_CASTLE, 1 }, -- pipe over cannon to Star Haven
        },
        [61] = {
          { id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, 3400, 160, -2733, 0, LEVEL_CASTLE_COURTYARD, 1, 39 }, -- Star Haven pipe to Star Leap Tower
        },
        [141] = {
          { id_bhvDoorWarp, E_MODEL_HMC_METAL_DOOR, -800, -774, 200, 0, LEVEL_VCUTM, 1 }, -- door in factory to vanish cap
        },
        [131] = {
          { id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, -4676, -464, -2729, 0, LEVEL_COTMC, 1 }, -- pipe in FFF to metal cap
        },
      },
      warpNodeOverride = {
        [161] = {                                       -- warps from VCUTM and COTMC
          [0x1B] = { LEVEL_CASTLE_COURTYARD, 1, 0x2A }, -- cotmc star
          [0x1C] = { LEVEL_CASTLE_COURTYARD, 1, 0x2B }, -- cotmc death
          [0x2A] = { LEVEL_CASTLE, 1, 0x06 },           -- vcutm star
          [0x2B] = { LEVEL_CASTLE, 1, 0x07 },           -- vcutm death
        },
      },
    },
  },

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

  -- UNFINISHED! (unsure now until officially confirmed)
  actlessData = {
    [LEVEL_BOB] = {{
      -- act 1
      {
        id = id_bhvKingBobomb,
        acts = ACT_1,
      },
      {
        id = id_bhvBobombBuddy,
        oBehParams = (DIALOG_001 << 16),
        acts = ACT_1,
      },

      -- other acts
      {
        id = id_bhvBobombBuddy,
        oBehParams = (DIALOG_158 << 16),
        acts = NOT_ACT_1,
      },
      {
        id = id_bhvBobomb,
        oSyncID = 1020,
        acts = NOT_ACT_1,
      },
    }},
    [LEVEL_WF] = {{
      -- act 1
      {
        id = id_bhvWhompKingBoss,
        acts = ACT_1,
      },
      {
        id = id_bhvBobombBuddy,
        oBehParams = (DIALOG_167 << 16),
        acts = ACT_1,
      },

      -- other acts
      {
        id = id_bhvEnemyLakitu,
        oSyncID = 380,
        acts = NOT_ACT_1,
      },
      {
        id = id_bhvBobombBuddy,
        oBehParams = (DIALOG_160 << 16),
        acts = NOT_ACT_1,
      },
      {
        id = id_bhvBobombBuddy,
        oBehParams = (DIALOG_166 << 16),
        acts = NOT_ACT_1,
      },

      -- all of the weird ones (WHYYYYY)
      {
        id = id_bhvBobombBuddy,
        oBehParams = (DIALOG_165 << 16),
        acts = ACT_6,
      },
      {
        id = id_bhvFlyGuy,
        oSyncID = 590,
        acts = (ACT_1 | ACT_3 | ACT_4 | ACT_6),
      },
      {
        id = id_bhvSmallWhomp,
        oSyncID = 740,
        acts = (ACT_2 | ACT_3 | ACT_5),
      },
      {
        id = id_bhvSmallWhomp,
        oSyncID = 750,
        acts = (ACT_2 | ACT_3 | ACT_4 | ACT_5),
      },
      {
        id = id_bhvSmallWhomp,
        oSyncID = 760,
        acts = (ACT_2 | ACT_3 | ACT_5),
      },
    }},
    [LEVEL_JRB] = {{
      {
        id = id_bhvHoot,
        acts = (ACT_5 | ACT_6),
      },
      -- the other two seem like mistakes, it's just a random plant and coin box
    }},
    [LEVEL_CCM] = {{
      {
        id = id_bhvPushableMetalBox,
        acts = (ACT_1 | ACT_2),
      },
      {
        id = id_bhvStar,
        oBehParams = 0,
        acts = ACT_1,
      },
      {
        id = id_bhvPoleGrabbing,
        oSyncID = 100,
        acts = ACT_1,
      },
      extra = { -- to get out of act 6 star area
        { id_bhvSparkleFadingWarp, E_MODEL_NONE, -3660, 1424, -3930, 0, LEVEL_CCM, 1, 3 },
      },
    }},
    [LEVEL_BBH] = {{
      -- act 1
      {
        id = id_bhvBalconyBigBoo,
        acts = ACT_1,
      },
      {
        id = "bhvSMSRRedOctagonalPlatform", -- custom objects need to be strings
        oSyncID = 50,
        acts = ACT_1,
      },

      -- act 4
      {
        id = "bhvSMSRRedOctagonalPlatform",
        oSyncID = {540, 560, 580, 590, 760, 770},
        acts = (ACT_4 | ACT_5 | ACT_6), -- they stay so you can get back
      },

      -- act 5
      {
        id = {id_bhvRedCoin, id_bhvHiddenRedCoinStar, id_bhvPlatformOnTrack},
        acts = ACT_5,
      },
      {
        id = {id_bhvRedCoin, id_bhvHiddenRedCoinStar, id_bhvPlatformOnTrack},
        acts = ACT_5,
      },
      {
        id = "bhvSMSRRedSinkingPlatform",
        oSyncID = {510, 880},
        acts = ACT_5,
      },

      -- act 6
      {
        id = id_bhvMrI,
        acts = ACT_6,
      },
      {
        id = "bhvSMSRRedSinkingPlatform",
        oSyncID = 150,
        acts = ACT_6,
      },

      -- use consistent wave platform (normally swaps between acts)
      {
        id = "bhvSMSRRedWavePlatform",
        oSyncID = {500, 710},
        acts = 0,
      },
    }},
    [LEVEL_HMC] = {{
      -- act 1-3, act 5-6
      {
        id = "bhvSMSRBreakableFloor",
        oSyncID = {1280, 1330, 1260, 1150},
        acts = (ACT_1 | ACT_2 | ACT_3), -- Stay open so you can get out of there
      },

      -- act 2
      {
        id = id_bhvFlyGuy,
        acts = ACT_2,
      },

      -- act 4
      {
        id = "bhvMhCustomBowserBomb",
        acts = ACT_4,
      },
      {
        id = id_bhvStar,
        oSyncID = 280,
        acts = ACT_4,
      },

      extra = {
        {id_bhvSparkleFadingWarp, E_MODEL_NONE, 987, 2874, -6565, 0, LEVEL_HMC, 1},
      },
    }},
    [LEVEL_LLL] = {{
      -- act 2
      {
        id = id_bhvKoopa,
        oBehParams2ndByte = KOOPA_BP_KOOPA_THE_QUICK_BASE,
        acts = ACT_2,
      },
      {
        id = id_bhvKoopaFlag,
        acts = ACT_2,
      },

      -- act 3+
      {
        id = id_bhvPushableMetalBox,
        oSyncID = {100, 90, 80, 70},
        acts = (ACT_1 | ACT_2),
      },
      {
        id = id_bhvCirclingAmp,
        oSyncID = {360, 60},
        acts = (ACT_3 | ACT_4 | ACT_5 | ACT_6),
      },
      {
        id = "bhvSMSRChainChomp",
        acts = (ACT_3 | ACT_4 | ACT_5 | ACT_6),
      },
      {
        id = id_bhvChainChompChainPart,
        acts = (ACT_3 | ACT_4 | ACT_5 | ACT_6),
      },
    }},
    [LEVEL_SSL] = {{
      {
        id = {"bhvSMSRWigglerHead", id_bhvWigglerBody, id_bhvWigglerHead},
        acts = ACT_1,
      },
      {
        id = {"bhvSMSRMovingMushroom", id_bhvChuckya, id_bhvJumpingBox, id_bhvEnemyLakitu},
        acts = NOT_ACT_1,
      },
    }},
    [LEVEL_SL] = {{
      -- act 1
      {
        id = id_bhvBigChillBully,
        acts = ACT_1,
      },

      -- act 2+
      {
        id = id_bhvMoneybagHidden,
        acts = NOT_ACT_1,
      },
      {
        id = id_bhvYellowCoin,
        oSyncID = {73, 72, 71, 76, 77, 74, 75, 78},
        acts = NOT_ACT_1,
      },
      {
        id = id_bhvCoinFormation,
        oSyncID = 70,
        acts = NOT_ACT_1,
      },
      {
        id = id_bhvTuxiesMother,
        acts = ACT_2,
      },
      {
        id = id_bhvSmallChillBully,
        acts = NOT_ACT_1,
      },
      {
        id = id_bhvSmallPenguin,
        acts = NOT_ACT_1,
      },

      extra = {
        {id_bhvSparkleFadingWarp, E_MODEL_NONE, 3405, 1979, 3660, 0, LEVEL_SL, 1},
        {id_bhvSparkleFadingWarp, E_MODEL_NONE, 6689, 1828, -6081, 0, LEVEL_SL, 1},
      },
    }},
    [LEVEL_WDW] = {{
      -- act 1
      {
        id = "bhvSMSRRacingPenguin",
        acts = ACT_1,
      },

      -- uhh is this penguin not mean't to be there..?
      {
        id = id_bhvSLWalkingPenguin,
        acts = NOT_ACT_1,
      },
    }},
    [LEVEL_TTM] = {{
      {
        id = id_bhvHiddenObject,
        acts = ALL_ACTS,
      },

      -- act 2+
      {
        id = {id_bhvExclamationBox, id_bhvRotatingExclamationMark},
        oSyncID = {710, 740, 700, 750, 1200, 1320, 1250, 1260, 1210, 1270, 1220, 1230, 1280, 1240, 1290, 1310, 1300, 690, 1250},
        acts = NOT_ACT_1,
      },
      {
        id = id_bhvCheckerboardPlatformSub,
        oSyncID = {580, 590, 600, 620, 630, 640, 1300, 1310, 660, 670, 680},
        acts = NOT_ACT_1,
      },
      {
        id = id_bhvStaticCheckeredPlatform,
        oSyncID = {610, 650, 1340, 1350},
        acts = NOT_ACT_1,
      },
      {
        id = "bhvSMSRSinkingDonut",
        oSyncID = {720, 730},
        acts = NOT_ACT_1,
      },

      extra = {
        {id_bhvSparkleFadingWarp, E_MODEL_NONE, -2415, 6442, 5207, 0, LEVEL_TTM, 1},
        {id_bhvSparkleFadingWarp, E_MODEL_NONE, -5725, 2380.2, -3521.2, 0, LEVEL_TTM, 1},
        {id_bhvSparkleFadingWarp, E_MODEL_NONE, 5856, 4714, 5555, 0, LEVEL_TTM, 1},
      },
    }},
    [LEVEL_THI] = {{
      -- act 2
      {
        id = "bhvSMSRPlatformLift",
        oSyncID = {600, 580, 590},
        acts = (ACT_2 | ACT_3 | ACT_4 | ACT_5),
      },
      {
        id = id_bhvYellowCoin,
        oSyncID = {1270, 1260, 1280},
        acts = (ACT_2 | ACT_3 | ACT_4 | ACT_5),
      },
      {
        id = id_bhvFireSpitter,
        oSyncID = {1040, 1060, 1050},
        acts = ACT_2,
      },
      {
        id = "bhvSMSRRisingTallPlatform",
        acts = ACT_2,
      },
      {
        id = id_bhvStar,
        oSyncID = 730,
        acts = ACT_2,
      },
      {
        id = "bhvSMSRTiltingPyramid",
        oSyncID = {650, 640},
        acts = ACT_2,
      },
      {
        id = id_bhvFlamethrower,
        oSyncID = 1100,
        acts = ACT_2,
      },

      -- act 4+
      {
        id = "bhvSMSRPlatformLift",
        oSyncID = {160, 270, 280, 290},
        acts = (ACT_4 | ACT_5),
      },

      -- act 6
      {
        id = "bhvMhCustomPlatformOnTrack",
        oSyncID = 850,
        acts = ACT_6,
      },
      {
        id = id_bhvFlamethrower,
        oSyncID = {1000, 990},
        acts = ACT_6,
      },

      extra = {
        {id_bhvSparkleFadingWarp, E_MODEL_NONE, -6098, -1304, -2420, 0, LEVEL_THI, 1},
        {id_bhvSparkleFadingWarp, E_MODEL_NONE, -4032, 2984, -3163, 0, LEVEL_THI, 1},
      },
    }},
    [LEVEL_TTC] = {{
      -- act 6
      {
        id = id_bhvExclamationBox,
        oSyncID = 70,
        acts = ACT_6,
      },
      {
        id = id_bhvFlamethrower,
        acts = ACT_6,
      },
    }},
    [LEVEL_RR] = {{
      -- act 2
      {
        id = "bhvSMSRSpaceBox",
        oSyncID = {790, 780},
        acts = ACT_2,
      },
      {
        id = "bhvSMSRSpaceOctagonPlatform",
        acts = ACT_2,
      },
      {
        id = id_bhvSslMovingPyramidWall,
        acts = ACT_2,
      },
      {
        id = id_bhvCoinFormation,
        oSyncID = 940,
        acts = ACT_2,
      },
      {
        id = id_bhvYellowCoin,
        oSyncID = {945, 942, 941, 944, 943},
        acts = ACT_2,
      },
      {
        id = id_bhvGoomba,
        oSyncID = {1163, 1161, 1162},
        acts = ACT_2,
      },
      {
        id = id_bhvGoombaTripletSpawner,
        oSyncID = 1160,
        acts = ACT_2,
      },
      {
        id = id_bhvStar,
        oSyncID = 910,
        acts = ACT_2,
      },

      extra = {
        {id_bhvSparkleFadingWarp, E_MODEL_NONE, 498, -5779.6, -6162, 0, LEVEL_RR, 1},
        {id_bhvSparkleFadingWarp, E_MODEL_NONE, -76, -3463, -748, 0, LEVEL_RR, 1},
      },
    }},
    [LEVEL_BITFS] = {{
      extra = {
        {id_bhvSparkleFadingWarp, E_MODEL_NONE, -5750, -215, -878, 0, LEVEL_BITFS, 1},
      },
    }},
    [LEVEL_BITS] = {{
      extra = {
        {id_bhvSparkleFadingWarp, E_MODEL_NONE, -1900, 1872, 6300, 0, LEVEL_BITS, 1},
      },
    }},
  },
}

-- Replica Comet
romhack_data["coop-romhacks-star-road"] = {
  name = "Star Road: The Replica Comet",
  inherit = "star-road",
  max_stars = 150,

  -- new replicas
  star_data = {
    [COURSE_NONE] = { 8, 8, 8, 8, 8 | STAR_REPLICA, 8 | STAR_REPLICA, 8 | STAR_REPLICA },
    [COURSE_BITDW] = { 8, 0, 0, 8 | STAR_REPLICA, 0, 8 | STAR_REPLICA },
    [COURSE_BITFS] = { 8, 0, 0, 0, 0, 8 | STAR_REPLICA | STAR_EXIT | STAR_APPLY_NO_ACTS },
    [COURSE_BITS] = { 8, 0, 0, 0, 8 | STAR_REPLICA, 8 | STAR_REPLICA },
    [COURSE_PSS] = { 8, 8, 0, 0, 8 | STAR_REPLICA | STAR_EXIT, 8 | STAR_REPLICA, 8 | STAR_REPLICA },
    [COURSE_COTMC] = { 8, 0, 0, 0, 8 | STAR_REPLICA, 8 | STAR_REPLICA | STAR_EXIT | STAR_APPLY_NO_ACTS },
    [COURSE_TOTWC] = { 8, 0, 0, 8 | STAR_REPLICA, 8 | STAR_REPLICA, 8 | STAR_REPLICA },
    [COURSE_VCUTM] = { 8, 0, 0, 8 | STAR_REPLICA | STAR_EXIT | STAR_APPLY_NO_ACTS, 8 | STAR_REPLICA | STAR_APPLY_NO_ACTS, 8 | STAR_REPLICA, 8 | STAR_REPLICA },
    [COURSE_WMOTR] = { 8, 0, 8 | STAR_REPLICA | STAR_EXIT | STAR_APPLY_NO_ACTS, 8 | STAR_REPLICA, 8 | STAR_REPLICA, 8 | STAR_REPLICA, 8 | STAR_REPLICA },
    [COURSE_SA] = { 8, 8 | STAR_IGNORE_STARMODE | STAR_APPLY_NO_ACTS, 0, 0, 8 | STAR_REPLICA, 8 | STAR_REPLICA, 8 | STAR_REPLICA }, -- can fail time challenge
    [COURSE_CAKE_END] = { 0, 8, 0, 8 | STAR_REPLICA },
  },

  -- contains the new replicas
  starNames = {
    [5] = "Replica Of The Blocked Moat",
    [6] = "Replica Of Star Leap's Peak",
    [7] = "Replica Of The Special World",
    [166] = "Replica Of The Steep Slope",
    [176] = "Replica Of The Bill Blasters",
    [185] = "Replica Of The Shining Star",
    [195] = "Replica Of The Shifting Saws",
    [197] = "Replica Of The Mountain Crate",
    [206] = "Replica Of The Flaming Flow",
    [214] = "Replica Of The Windy Mill",
    [215] = "Replica Of The Distant Hill",
    [224] = "Replica Of The Metal Box",
    [225] = "Replica Of The Perilous Pipe",
    [227] = "Replica Of The Hidden Entrance",
    [233] = "Replica Of The Slippery Roof",
    [234] = "Replica Of The World's End",
    [235] = "Replica Of The Hidden Window",
    [237] = "Replica Of The Palace Window",
    [245] = "Replica Of The Scenic Pipe",
    [247] = "Replica Of The Raceside Pipe",
    [254] = "Replica Of The Castle View",
  },

  mini_exclude = {
    [227] = 1, -- uses hidden entrance
  }
}
