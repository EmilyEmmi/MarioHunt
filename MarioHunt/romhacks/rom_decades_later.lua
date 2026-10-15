-- by Moldy64
-- Blue stars in the hack itself are not ported but the actual max in the hack is 333 stars
-- Study Guide for the Hack: https://youtu.be/3cOOkpr35EQ

local mposX = 0.0
local mposY = 429.0
local mposZ = 584.0
local mposX2 = 0.0
local mposY2 = 194.0
local mposZ2 = -596.0
local outofboundsx = -6558.0
local outofboundsy = 0.0
local outofboundsz = 6464.0
local mposX3 = 4.0
local mposY3 = 238.0
local mposZ3 = 0.0

local marioJumps = {
    [ACT_JUMP] = true,
    [ACT_RIDING_SHELL_JUMP] = true,
    [ACT_DOUBLE_JUMP] = true,
    [ACT_TRIPLE_JUMP] = true,
    [ACT_SPECIAL_TRIPLE_JUMP] = true,
    [ACT_STEEP_JUMP] = true,
    [ACT_SIDE_FLIP] = true,
    [ACT_BACKFLIP] = true,
    [ACT_LONG_JUMP] = true
}

-- this happens in the actual hack but its not implemented
function height_fix(m)
    if marioJumps[m.action] then
        if m.pos.y <= m.floorHeight -5 then
            m.vel.y = m.vel.y + 12.0
            m.pos.y = m.pos.y + 6
        end
    end
end

-- runs on load
if ROMHACK_FILE_LOADING ~= "sm64-dl-hack-mh-main" and ROMHACK_FILE_LOADING ~= "sm64-dl-hack-mh" then
    djui_popup_create("\\#ffff5a\\" .. trans("decades_later_popup"), 3)
    djui_chat_message_create("\\#dcdcdc\\" .. trans("decades_later_chat_1") .. trans("decades_later_chat_2") .. trans("decades_later_chat_3"))
end
change_setting_default("countdown", 20 * 30, true) -- 20 seconds for hunters

hook_event(HOOK_ON_SET_MARIO_ACTION, height_fix)

romhack_data["decades-later-coop-main"] = {
    name = "SM64: Decades Later",
    default_stars = 35,
    max_stars = 156,                -- blue stars are not ported so they are just non-existent
    ommColorStar = false,
    heartReplace = true,
    lifeOverride = true,
    parseStars = true,
    replica_start = 157,
    checkAreaWarp = false,
    stalk = true,                   -- pretty big hack with big levels and plus people who don't know or has zero experience with this hack can use /stalk, could be annoying
    noLobby = false,
    numRedCoins = 6,                -- spawns the star sooner thanks emily
    yellow_switch_message = "hit_switch_warp_box_dl",
    special_run = (function(m, gotStar)
        if m.playerIndex ~= 0 then return end
        local switch_message = nil
        local np = gNetworkPlayers[m.playerIndex]

        if (gNetworkPlayers[m.playerIndex].currLevelNum == LEVEL_TOTWC) then
            local o = obj_get_first_with_behavior_id(id_bhvCapSwitchBase)
            obj_set_model_extended(o, E_MODEL_CAP_SWITCH_BASE)
            obj_set_model_extended(obj_get_first_with_behavior_id(id_bhvCapSwitch), E_MODEL_CAP_SWITCH)
        end

        -- set king bob-omb's health to 1, and set king bob-omb's health to 3 otherwise this would be an easy win in 1st basement area
        if (gGlobalSyncTable.gameArea == 2) then gBehaviorValues.KingBobombHealth = 3 end
        if (gGlobalSyncTable.gameArea == 0) then gBehaviorValues.KingBobombHealth = 1 end
        -- set wiggler's health to 1, and set wiggler's health to 3 only in game area otherwise this would be an easy win in 1st floor area
        if (np.currLevelNum == LEVEL_BOWSER_1) then
            local o = obj_get_first_with_behavior_id(id_bhvWigglerHead)
            if (gGlobalSyncTable.gameArea == 0) and o.oHealth > 2 then o.oHealth = 2 elseif (gGlobalSyncTable.gameArea == 1) and o.oHealth > 4 then o.oHealth = 4 end
        end

        -- allow warping out of any of the 3 endings
        if (np.currLevelNum == LEVEL_BITDW and (np.currAreaIndex == 2 or np.currAreaIndex == 3)) or (np.currLevelNum == LEVEL_ENDING and np.currAreaIndex == 5) then
            gPlayerSyncTable[m.playerIndex].allowLeave = true
        end

        -- 1st basement
        if gGlobalSyncTable.gameArea ~= 1 and np.currLevelNum == LEVEL_CASTLE_COURTYARD and np.currAreaIndex == 1 then
            if m.pos.x == 0.0 and m.pos.y == -0.0 and m.pos.z == 0.0 or --[[oob]] m.pos.x == outofboundsx and m.pos.y == outofboundsy and m.pos.z == outofboundsz then
                vec3f_set(m.pos, mposX, mposY, mposZ)
                m.action = ACT_SPAWN_SPIN_AIRBORNE
            end
        end

        if gGlobalSyncTable.gameArea == 2 then
            if np.currLevelNum == LEVEL_CASTLE_COURTYARD and np.currAreaIndex == 2 then
                warp_to_level(LEVEL_CASTLE_COURTYARD, 1, 1)
            elseif ROMHACK.gameAreaData and np.currLevelNum == LEVEL_CASTLE and np.currAreaIndex == 1 then
                warp_to_level(LEVEL_CASTLE_COURTYARD, 1, 1)
            elseif gGlobalSyncTable.gameArea == 2 and np.currLevelNum == LEVEL_WMOTR and np.currAreaIndex >= 1 and np.currAreaIndex <= 6 then
                warp_to_level(LEVEL_CASTLE_COURTYARD, 1, 1)
            elseif gGlobalSyncTable.gameArea == 2 and np.currLevelNum == LEVEL_CASTLE_GROUNDS and np.currAreaIndex == 1 then
                warp_to_level(LEVEL_CASTLE_COURTYARD, 1, 1)
            end

            -- caps (1st basement - game area)
            -- local vcUnlockedDl1stBasement = gotStar and m.numStars >= 4 and (save_file_get_flags() & SAVE_FLAG_HAVE_VANISH_CAP) == 0
            -- local wcUnlockedDl1stBasement = gotStar and m.numStars >= 10 and (save_file_get_flags() & SAVE_FLAG_HAVE_WING_CAP) == 0

            -- if vcUnlockedDl1stBasement then
            --     switch_message = "hit_switch_blue_dl"
            --     save_file_set_flags(SAVE_FLAG_HAVE_VANISH_CAP)
            --     popup_sound(SOUND_GENERAL_ACTIVATE_CAP_SWITCH, true)
            --     djui_popup_create_global(trans(switch_message, (network_get_player_text_color_string(0) .. np.name)), 2)

            -- elseif wcUnlockedDl1stBasement then
            --     switch_message = "hit_switch_red_dl"
            --     save_file_set_flags(SAVE_FLAG_HAVE_WING_CAP)
            --     popup_sound(SOUND_GENERAL_ACTIVATE_CAP_SWITCH, true)
            --     djui_popup_create_global(trans(switch_message, (network_get_player_text_color_string(0) .. np.name)), 2)
            -- end
        elseif gGlobalSyncTable.gameArea == 4 then
            -- 2nd floor
            if np.currLevelNum == LEVEL_CASTLE_COURTYARD and np.currAreaIndex == 2 then
                if m.pos.x == 0.0 and m.pos.y == -0.0 and m.pos.z == -45.0 or m.pos.z == -90.0 then
                    vec3f_set(m.pos, mposX2, mposY2, mposZ2)
                    m.action = ACT_SPAWN_NO_SPIN_AIRBORNE
                end
            end
            if np.currLevelNum == LEVEL_CASTLE_COURTYARD and np.currAreaIndex == 1 then
                warp_to_level(LEVEL_CASTLE_COURTYARD, 2, 1)
            elseif np.currLevelNum == LEVEL_CASTLE and np.currAreaIndex == 1 then
                warp_to_level(LEVEL_CASTLE_COURTYARD, 2, 1)
            end

            -- caps (2nd floor - game area)
            -- local vcUnlockedDl2ndFloor = gotStar and m.numStars >= 3 and (save_file_get_flags() & SAVE_FLAG_HAVE_VANISH_CAP) == 0
            -- local wcUnlockedDl2ndFloor = gotStar and m.numStars >= 6 and (save_file_get_flags() & SAVE_FLAG_HAVE_WING_CAP) == 0
            -- local mcUnlockedDl2ndFloor = gotStar and m.numStars >= 12 and (save_file_get_flags() & SAVE_FLAG_HAVE_METAL_CAP) == 0
            -- if vcUnlockedDl2ndFloor then
            --     switch_message = "hit_switch_blue_dl"
            --     save_file_set_flags(SAVE_FLAG_HAVE_VANISH_CAP)
            --     popup_sound(SOUND_GENERAL_ACTIVATE_CAP_SWITCH, true)
            --     djui_popup_create_global(trans(switch_message, (network_get_player_text_color_string(0) .. np.name)), 2)
            -- elseif wcUnlockedDl2ndFloor then
            --     switch_message = "hit_switch_red_dl"
            --     save_file_set_flags(SAVE_FLAG_HAVE_WING_CAP)
            --     popup_sound(SOUND_GENERAL_ACTIVATE_CAP_SWITCH, true)
            --     djui_popup_create_global(trans(switch_message, (network_get_player_text_color_string(0) .. np.name)), 2)
            -- elseif mcUnlockedDl2ndFloor then
            --     switch_message = "hit_switch_green_dl"
            --     save_file_set_flags(SAVE_FLAG_HAVE_METAL_CAP)
            --     popup_sound(SOUND_GENERAL_ACTIVATE_CAP_SWITCH, true)
            --     djui_popup_create_global(trans(switch_message, (network_get_player_text_color_string(0) .. np.name)), 2)
            -- end
        elseif gGlobalSyncTable.gameArea == 1 then
            -- 1st floor
            if gGlobalSyncTable.gameArea == 1 and ROMHACK.gameAreaData and np.currLevelNum == LEVEL_CASTLE_COURTYARD and np.currAreaIndex == 1 then
                warp_to_level(LEVEL_CASTLE, 1, 1)
            elseif gGlobalSyncTable.gameArea == 1 and ROMHACK.gameAreaData and np.currLevelNum == LEVEL_CASTLE_COURTYARD and np.currAreaIndex == 2 then
                warp_to_level(LEVEL_CASTLE, 1, 1)
            end

            -- caps (1st floor - game area)
            -- local mcUnlockedDl1stFloor = gotStar and m.numStars >= 5 and (save_file_get_flags() & SAVE_FLAG_HAVE_METAL_CAP) == 0
            -- if mcUnlockedDl1stFloor then
            --     switch_message = "hit_switch_green_dl"
            --     save_file_set_flags(SAVE_FLAG_HAVE_METAL_CAP)
            --     popup_sound(SOUND_GENERAL_ACTIVATE_CAP_SWITCH, true)
            --     djui_popup_create_global(trans(switch_message, (network_get_player_text_color_string(0) .. np.name)), 2)
            -- end
        elseif gGlobalSyncTable.gameArea == 3 then
            -- 2nd basement
            if np.currLevelNum == LEVEL_CASTLE_GROUNDS and np.currAreaIndex == 3 then
                if m.pos.x == 2.0 and m.pos.y == -0.0 or m.pos.y == 8000.0 and m.pos.z == 0.0 then
                    vec3f_set(m.pos, mposX3, mposY3, mposZ3)
                    m.action = ACT_SPAWN_SPIN_AIRBORNE
                end
            end

            if np.currLevelNum == LEVEL_CASTLE_COURTYARD and np.currAreaIndex == 1 or gGlobalSyncTable.gameArea == 3 and ROMHACK.gameAreaData and np.currLevelNum == LEVEL_CASTLE_COURTYARD and np.currAreaIndex == 3 or gGlobalSyncTable.gameArea == 3 and ROMHACK.gameAreaData and np.currLevelNum == LEVEL_CASTLE_GROUNDS and np.currAreaIndex == 1 then
                warp_to_level(LEVEL_CASTLE_GROUNDS, 3, 1)
                -- m.health = 2048
            elseif np.currLevelNum == LEVEL_BITDW and np.currAreaIndex == 3 then
                warp_to_level(LEVEL_WMOTR, 1, 1)
            elseif m.numStars < gGlobalSyncTable.starRun and np.currLevelNum == LEVEL_ENDING and np.currAreaIndex == 4 then
                warp_to_level(LEVEL_ENDING, 3, 1)
            end
        end

        -- fix all cams for bowser 1, 2 and 3
        camera_set_romhack_override(RCO_ALL)
        camera_set_use_course_specific_settings(0)

        -- warps you back if you try to go to basement or upstairs too early
        if ((save_file_get_flags() & (SAVE_FLAG_HAVE_KEY_1 | SAVE_FLAG_UNLOCKED_BASEMENT_DOOR)) == 0 and gGlobalSyncTable.gameArea == 0 and ROMHACK.gameAreaData and np.currLevelNum == LEVEL_CASTLE_COURTYARD and np.currAreaIndex == 1) then
            warp_to_level(LEVEL_CASTLE, 1, 1)
        elseif ((save_file_get_flags() & (SAVE_FLAG_HAVE_KEY_2 | SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR)) == 0 and gGlobalSyncTable.gameArea == 0 and ROMHACK.gameAreaData and np.currLevelNum == LEVEL_CASTLE_COURTYARD and np.currAreaIndex == 2) then
            warp_to_level(LEVEL_CASTLE, 1, 1)
        end
    end),
    
    runner_victory = function(m)
        local np = gNetworkPlayers[0]
        -- literally copy and paste
        if gGlobalSyncTable.bowserBeaten and m.numStars >= gGlobalSyncTable.starRun then
            return true
        elseif np.currLevelNum == LEVEL_BITDW and np.currAreaIndex == 2 then
            gGlobalSyncTable.bowserBeaten = true
        elseif not gGlobalSyncTable.bowserBeaten then
            -- check for castle star 7
            local file = get_current_save_file_num() - 1
            gGlobalSyncTable.bowserBeaten = (save_file_get_star_flags(file, -1) & (1 << 6) ~= 0)
        end
        return false
    end,

    mini_exclude = {
        [16] = 1, -- reds in the cavern (infinite death loop)
        [12] = 1, -- koopa the quick's return
        [43] = 1, -- li'l penguin lost (obvious reason)
        [61] = 1, -- swimming beast in the cavern
        [86] = 1, -- the pyramid's guardian
        [85] = 1, -- floorless switch dungeon
        [133] = 1, -- rematch with koopa the quick
        [135] = 1, -- red, blue and green switches
        [77] = 1, -- lll 80s (starts at area 2 which you can't get out of)
        [124] = 1, -- secrets of the tunnel (infinite death loop)

        -- every f-zero level (except the 7th stars for each)
        [221] = 1,
        [222] = 1,
        [223] = 1,
        [224] = 1,
        [225] = 1,
        [226] = 1,
        [201] = 1,
        [202] = 1,
        [203] = 1,
        [204] = 1,
        [205] = 1,
        [206] = 1,
        [251] = 1,
        [252] = 1,
        [253] = 1,
        [254] = 1,
        [255] = 1,
        [256] = 1,
    },

    levelNames = {
        [161] = "Castle Grounds",
        [62] = "BroDute's Shed",
        [61] = "1st Floor",
        [162] = "Slide Select",
        [261] = "1st Basement",
        [262] = "2nd Floor",
        [163] = "2nd Basement",
        [151] = "Tranquil Moon",
        [101] = "Snowman's Island",
        [111] = "Wet-Dry City",
        [361] = "Seasonal Mountain",
        [131] = "Sweet Sweet Island",
        -- [201] = "Big Run",
        [141] = "Tick Tock Core",
        [291] = "Switch Palace: Wing Cap",
        [292] = "Switch Palace: Vanish Cap",
        [293] = "Switch Palace: Metal Cap",
        [294] = "Warp Switch Palace",
        [171] = "Mario in the Dark World",
        [191] = "Pandora Palace",
        [211] = "Dark Star Domain",
        [301] = "Mario in the Dark World: Boss #1",
        [331] = "Pandora Palace: Boss #2",
        [341] = "Dark Star Domain: Boss #3",
    },

    starNames = {
        -- pss
        [192] = "28 Second Challenge",

        -- ccm
        [42] = "Top Of The Mountain",

        -- wc
        [211] = "Fly For The Red Coins",
        [212] = "Secrets Of The Wing Cap",

        -- mc
        [213] = "Reds Of The Metal Cap",
        [214] = "Box In The Metal Cap",

        -- vc
        [215] = "Reds Of The Vanish Cap",
        [216] = "In The Middle Of The Vanish Cap",

        -- warp switch palace
        [217] = "Inside Of BroDute's Shed",

        -- bitdw
        [162] = "Reds In The Dark World",

        -- bitfs
        [172] = "Reds Inside The Palace",
        
        -- bits
        [182] = "Reds In The Domain",

        -- ttm
        [122] = "Poisonous Mountain Slide",

        -- silence
        [221] = "Silence (1)",
        [222] = "Silence (2)",
        [223] = "Silence (3)",
        [224] = "Silence (4)",
        [225] = "Silence (5)",
        [226] = "Silence (6)",
        [227] = "Silence (7)",

        -- death wind
        [201] = "Death Wind (1)",
        [202] = "Death Wind (2)",
        [203] = "Death Wind (3)",
        [204] = "Death Wind (4)",
        [205] = "Death Wind (5)",
        [206] = "Death Wind (6)",
        [207] = "Death Wind (7)",

        -- fire field
        [251] = "Fire Field (1)",
        [252] = "Fire Field (2)",
        [253] = "Fire Field (3)",
        [254] = "Fire Field (4)",
        [255] = "Fire Field (5)",
        [256] = "Fire Field (6)",
        [257] = "Fire Field (7)",

        -- others
        [01] = "Talking To BroDute",
        [03] = "Toad Star (1)",
        [04] = "Riding The Shell To Mips",
        [05] = "Riding The Shell To Mips Again",
        [06] = "Reds Outside Of The Castle",
    },

    gameAreaData = {
        {
            entryLevel = LEVEL_CASTLE_GROUNDS,
            entryNode = 0,
            exitCastleLevel = LEVEL_CASTLE,
            exitCastleWarpNode = 10,
            extraObject = {
                [LEVEL_BITDW * 10 + 1] = {
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, -10760, -8, 2942, 0 },
                },
                [LEVEL_BITFS * 10 + 1] = {
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, -7458, -8, -1, 0 },
                },
                [LEVEL_BITS * 10 + 1] = {
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, -1377, -5558, 3, 0 },
                },
            },
        },
        {
            name = "1st Floor",
            entryLevel = LEVEL_CASTLE_GROUNDS,
            entryNode = 0,
            exitCastleLevel = LEVEL_CASTLE,
            exitCastleWarpNode = 10,
            default_stars = 20,
            max_stars = 30,
            bannedAreas = {
                [63] = 1,
            },
            doorCost = {
                [94] = 12,
                [10] = 16,
            },
            requirements = {
                [LEVEL_TOTWC * 10 + 1] = 12,
                [LEVEL_BITDW] = 16,
                [LEVEL_BOWSER_1] = 333,
            },
            runner_victory = function(m)
                return (save_file_get_flags() & (SAVE_FLAG_HAVE_KEY_1 | SAVE_FLAG_UNLOCKED_BASEMENT_DOOR)) ~= 0
            end,
            extraObject = {
                [LEVEL_CASTLE * 10 + 1] = {
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, 5661, 450, -2403, 0, LEVEL_TOTWC, 3 }, -- metal cap warp
                },
                [LEVEL_BITDW * 10 + 1] = {
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, -10760, -8, 2942, 0 },
                },
                [LEVEL_CASTLE_GROUNDS * 10 + 2] = {
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, 5400, -305, 1055, 0 }, -- floor 2 blocked
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, 6600, -305, 1055, 0 }, -- 1st basement blocked
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, -5400, -305, 1055, 0 }, -- 1st basement blocked (death wind)
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, -6600, -305, 1055, 0 }, -- floor 2 blocked (death wind)
                },
            },
        },
        {
            name = "1st Basement",
            entryLevel = LEVEL_CASTLE_COURTYARD,
            entryNode = 2,
            exitCastleLevel = LEVEL_CASTLE_COURTYARD,
            exitCastleWarpNode = 0,
            exitCastleArea = 1,
            default_stars = 12,
            max_stars = 24,
            entryArea = 1,
            bannedAreas = {
                [61] = 1,
                -- [62] = 1,
                [91] = 1,
                -- [161] = 1,
            },
            requirements = {
                [LEVEL_TOTWC] = 0,
                -- [LEVEL_COTMC] = 0,
                [LEVEL_SSL] = 0,
                [LEVEL_LLL] = 0,
                [LEVEL_HMC] = 0,
                [LEVEL_DDD] = 0,
                [LEVEL_VCUTM] = 0,
                [LEVEL_BITFS] = 15,
                [LEVEL_BOWSER_2] = 333,
            },
            runner_victory = function(m)
                return (save_file_get_flags() & (SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR | SAVE_FLAG_HAVE_KEY_2)) ~= 0
            end,
            doorCost = {
                [10] = 0,
                [30] = 0,
                [35] = 10,
            },
            extraObject = {
                [LEVEL_CASTLE_COURTYARD * 10 + 1] = {
                    { id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, -1842.8, 600, -1008.5, 0, LEVEL_TOTWC, 1 }, -- wing cap warp
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, -3983, 832, 2782, 0, LEVEL_TOTWC, 2 }, -- vanish cap warp
                },
                [LEVEL_CASTLE_GROUNDS * 10 + 1] = {
                    { id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, -1659.8, 419.4, 11360.0, 0, LEVEL_CASTLE_COURTYARD, 1 },
                },
                -- [LEVEL_CASTLE_GROUNDS * 10 + 1] = {
                --     { id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, -4043, -600, 7000, 0, LEVEL_CASTLE_COURTYARD, 1 },
                -- },
                -- [LEVEL_CASTLE_GROUNDS * 10 + 1] = {
                --     { id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, -854, -0.0, 577.0, 0, LEVEL_CASTLE_COURTYARD, 1 },
                -- },
                [LEVEL_BITFS * 10 + 1] = {
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, -7458, -8, -1, 0 },
                },
                [LEVEL_CASTLE_GROUNDS * 10 + 2] = {
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, 6000, -305, 1055, 0 }, -- floor 1 blocked
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, 5400, -305, 1055, 0 }, -- floor 2 blocked
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, -6000, -305, 1055, 0 }, -- floor 1 blocked (death wind)
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, -6600, -305, 1055, 0 }, -- floor 2 blocked (death wind)
                },
            },
        },
        {
            name = "2nd Basement",
            entryLevel = LEVEL_CASTLE_GROUNDS,
            entryArea = 3,
            entryNode = 0,
            exitCastleLevel = LEVEL_CASTLE_COURTYARD,
            exitCastleWarpNode = 0,
            exitCastleArea = 3,
            default_stars = 6,
            max_stars = 15,
            requirements = {
                [LEVEL_VCUTM] = 0,
                [LEVEL_WMOTR] = 0,
                [LEVEL_BITFS] = 0,
                [LEVEL_ENDING] = 0,
            },
            doorCost = {
                [144] = 2,
                [156] = 3,
                [157] = 6,
                [169] = 4,
                [175] = 6,
                [176] = 6,
            },
            runner_victory = (function(m)
                local np = gNetworkPlayers[0]
                if gGlobalSyncTable.bowserBeaten and m.numStars >= gGlobalSyncTable.starRun then
                    return true
                elseif np.currLevelNum == LEVEL_ENDING and np.currAreaIndex == 5 or np.currLevelNum == LEVEL_BITDW and np.currAreaIndex == 3 then
                    gGlobalSyncTable.bowserBeaten = true
                end
                return false
            end),
            extraObject = {
                [LEVEL_CASTLE_GROUNDS * 10 + 1] = {
                    { id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, -1659.8, 419.4, 11360.0, 0, LEVEL_CASTLE_GROUNDS, 3 },
                },
                -- [LEVEL_CASTLE_GROUNDS * 10 + 1] = {
                --     { id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, -4043, -600, 7000, 0, LEVEL_CASTLE_GROUNDS, 3 },
                -- },
                -- [LEVEL_CASTLE_GROUNDS * 10 + 1] = {
                --     { id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, -854, -0.0, 577.0, 0, LEVEL_CASTLE_GROUNDS, 3 },
                -- },
                [LEVEL_CASTLE_GROUNDS * 10 + 2] = { -- lol
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, 6000, -305, 1055, 0 }, -- floor 1 blocked
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, 5400, -305, 1055, 0 }, -- floor 2 blocked
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, 6600, -305, 1055, 0 }, -- 1st basement blocked
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, -6000, -305, 1055, 0 }, -- floor 1 blocked (death wind)
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, -5400, -305, 1055, 0 }, -- 1st basement blocked (death wind)
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, -6600, -305, 1055, 0 }, -- floor 2 blocked (death wind)
                },
                [LEVEL_CASTLE_GROUNDS * 10 + 3] = {
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, -670, -8, -3, 0 },
                },
            },
        },
        {
            name = "2nd Floor",
            entryLevel = LEVEL_CASTLE_COURTYARD,
            entryNode = 2,
            exitCastleLevel = LEVEL_CASTLE_COURTYARD,
            exitCastleWarpNode = 2,
            entryArea = 2,
            default_stars = 22,
            max_stars = 36,
            exitCastleArea = 2,
            bannedAreas = {
                [61] = 1,
                -- [63] = 1,
                [91] = 1,
                [161] = 1,
            },
            requirements = {
                [LEVEL_THI] = 2,
                [LEVEL_TTC] = 6,
                [LEVEL_RR] = 9,
                [LEVEL_BITS] = 20,
                [LEVEL_BOWSER_3] = 333,
            },
            doorCost = {
                [50] = 2,
                [60] = 6,
                [70] = 9,
                [80] = 20,
            },
            extraObject = {
                [LEVEL_CASTLE_COURTYARD * 10 + 2] = {
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, 2094.8, 300, -3833, 0, LEVEL_TOTWC, 1 }, -- wing cap warp
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, 324, 321, 1312.5, 0, LEVEL_TOTWC, 3 }, -- metal cap warp
                    { id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, -5128.8, 450, 3105.7, 0, LEVEL_TOTWC, 2 }, -- vanish cap warp
                },
                [LEVEL_CASTLE_GROUNDS * 10 + 1] = {
                    { id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, -1659.8, 419.4, 11360.0, 0, LEVEL_CASTLE_COURTYARD, 2 },
                },
                -- [LEVEL_CASTLE_GROUNDS * 10 + 1] = {
                --     { id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, -4043, -600, 7000, 0, LEVEL_CASTLE_COURTYARD, 2 },
                -- },
                -- [LEVEL_CASTLE_GROUNDS * 10 + 1] = {
                --     { id_bhvWarpPipe, E_MODEL_BITS_WARP_PIPE, -854, -0.0, 577.0, 0, LEVEL_CASTLE_COURTYARD, 2 },
                -- },            extraObject = {
                [LEVEL_BITS * 10 + 1] = {
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, -1377, -5558, 3, 0 },
                },
                [LEVEL_CASTLE_GROUNDS * 10 + 2] = {
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, 6000, -305, 1055, 0 }, -- floor 1 blocked
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, 6600, -305, 1055, 0 }, -- 1st basement blocked
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, -6000, -305, 1055, 0 }, -- floor 1 blocked (death wind)
                    { id_bhvPushableMetalBox, E_MODEL_METAL_BOX_DL, -5400, -305, 1055, 0 }, -- 1st basement blocked (death wind)
                },
            },
        },
    },

    requirements = {
        [LEVEL_TOTWC * 10 + 2] = 0,
        [LEVEL_TOTWC * 10 + 3] = 0,
        [LEVEL_WF] = 3,
        [LEVEL_PSS] = 3,
        [LEVEL_JRB] = 5,
        [LEVEL_CCM] = 5,
        -- [LEVEL_VCUTM] = 5,
        [LEVEL_BITDW] = 10,
        [LEVEL_TOTWC * 10 + 1] = 12,
        [LEVEL_DDD] = 30,
        [LEVEL_BITFS] = 35,
        [LEVEL_THI] = 50,
        [LEVEL_TTC] = 60,
        [LEVEL_RR] = 70,
        [LEVEL_BITS] = 80,
        [LEVEL_TOTWC * 10 + 4] = 94,
        [LEVEL_WMOTR] = 144,
        [LEVEL_BOWSER_3] = 333,
    },

    -- all filled when parsed
    star_data = {
        [COURSE_BOB] = {},
        [COURSE_WF] = {},
        [COURSE_JRB] = {},
        [COURSE_CCM] = {},
        [COURSE_PSS] = {},
        [COURSE_BBH] = {},
        [COURSE_TOTWC] = {},
        [COURSE_VCUTM] = {},
        [COURSE_BITDW] = {},
        [COURSE_SSL] = {},
        [COURSE_LLL] = {},
        [COURSE_HMC] = {},
        [COURSE_COTMC] = {},
        [COURSE_DDD] = {},
        [COURSE_BITFS] = {},
        [COURSE_SL] = {},
        [COURSE_TTM] = {},
        [COURSE_WDW] = {},
        [COURSE_SA] = {},
        [COURSE_THI] = {},
        [COURSE_TTC] = {},
        [COURSE_RR] = {},
        [COURSE_BITS] = {},
        [COURSE_WMOTR] = {},
        [COURSE_END] = {},
        [COURSE_CAKE_END] = {},
        [COURSE_NONE] = {},
    },
    
    actlessData = {
        [LEVEL_BOB] = {
            [1] = {
                -- 1
                {
                    id = id_bhvBobombBuddy,
                    oBehParams = (DIALOG_001 << 16),
                    oBehParams2ndByte = 0x00300000,
                    acts = ACT_1,
                },
                {
                    id = id_bhvBobBowlingBallSpawner,
                    acts = (ACT_1 | ACT_2),
                },
                {
                    id = id_bhvWaterBombCannon,
                    oBehParams2ndByte = 1,
                    acts = ACT_1,
                },
                {
                    id = id_bhvBobombBuddy,
                    oBehParams = (DIALOG_004 << 16),
                    oBehParams2ndByte = 0x00000000,
                    acts = (ACT_4 | ACT_5 | ACT_6),
                },
                {
                    id = id_bhvStar,
                    oSyncID = 120,
                    acts = (ACT_1 | ACT_2 | ACT_3 | ACT_4),
                },
                {
                    id = id_bhvExclamationBox,
                    oSyncID = 130,
                    acts = NOT_ACT_6,
                },
                {
                    id = {id_bhvKoopaFlag, id_bhvKoopaRaceEndpoint},
                    acts = ALL_ACTS,
                },
                
                -- 2
                {
                    id = id_bhvKoopa,
                    oBehParams2ndByte = KOOPA_BP_KOOPA_THE_QUICK_BOB,
                    acts = ACT_2,
                },
                {
                    id = id_bhvPitBowlingBall,
                    oSyncID = 120,
                    acts = NOT_ACT_1,
                },
                {
                    id = {id_bhvBobombBuddyOpensCannon, id_bhvCannonClosed},
                    acts = ALL_ACTS,
                },
                {
                    id = id_bhvBobombBuddy,
                    oBehParams = (DIALOG_001 << 16),
                    oBehParams2ndByte = 0x00010000,
                    acts = (ACT_1 | ACT_2 | ACT_3 | ACT_4),
                },

                -- 3-6
                {
                    id = {id_bhvKoopa, id_bhvBobBowlingBallSpawner},
                    oBehParams2ndByte = KOOPA_BP_NORMAL,
                    acts = NOT_ACT_2,
                },

                -- 4+
                {
                    id = {id_bhvRotatingExclamationMark, id_bhvExclamationBox},
                    oSyncID = 150,
                    acts = (ACT_5 | ACT_6),
                },
                {
                    id = {id_bhvRotatingExclamationMark, id_bhvExclamationBox},
                    oSyncID = 0,
                    acts = (ACT_5 | ACT_6),
                },
                {
                    id = {id_bhvRotatingExclamationMark, id_bhvExclamationBox},
                    oSyncID = 160,
                    acts = (ACT_5 | ACT_6),
                },
                {
                    id = {id_bhvRotatingExclamationMark, id_bhvExclamationBox},
                    oSyncID = 200,
                    acts = (ACT_5 | ACT_6),
                },
                {
                    id = {id_bhvRotatingExclamationMark, id_bhvExclamationBox},
                    oSyncID = 210,
                    acts = (ACT_1 | ACT_2 | ACT_3 | ACT_4),
                },
            },
        },
        [LEVEL_WF] = {
            [1] = {
                -- 4+
                {
                    id = id_bhvPushableMetalBox,
                    acts = (ACT_4 | ACT_5 | ACT_6),
                },
            },
        },
        [LEVEL_JRB] = {
            [2] = {
                extra = {
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, -1161.5, -927, -1515.8, 0, LEVEL_JRB, 1 },
                },
            },
        },
        [LEVEL_BBH] = {
            [3] = {
                extra = {
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, -8.9, 75, 519.6, 0, LEVEL_BBH, 2 },
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, 6000, 1650, 2093, 0, LEVEL_BBH, 2 },
                },
            },
        },
        [LEVEL_LLL] = {
            [1] = {
                {
                    id = id_bhvExclamationBox,
                    oSyncID = 190,
                    acts = (ACT_5 | ACT_6),
                },
            },
            [2] = {
                extra = {
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, 0, 299, 400, 0, LEVEL_LLL, 1 },
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, 205, 4050, -2769, 0, LEVEL_LLL, 1 },
                },
            },
        },
        [LEVEL_SSL] = {
            [1] = {
                -- 1
                {
                    id = id_bhvKlepto,
                    oBehParams2ndByte = 1,
                    acts = ACT_1,
                },

                -- 2
                {
                    id = id_bhvKlepto,
                    oBehParams2ndByte = 0,
                    acts = NOT_ACT_1,
                },
            },
            [4] = {
                extra = {
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, -13418, -1349, -9218.5, 0, LEVEL_SSL, 1 },
                },
            },
        },
        [LEVEL_DDD] = {
            [1] = {
                -- door near switch
                {
                    id = id_bhvDoor,
                    oSyncID = 1130,
                    acts = NOT_ACT_1,
                },
                {
                    id = id_bhvDoor,
                    oSyncID = 1120,
                    acts = ACT_1,
                },

                -- Bobomb buddies
                {
                    id = id_bhvBobombBuddy,
                    oBehParams = (DIALOG_071 << 16),
                    acts = ACT_1,
                },
                {
                    id = id_bhvBobombBuddy,
                    oBehParams = (DIALOG_072 << 16),
                    acts = ACT_2,
                },
                {
                    id = id_bhvBobombBuddy,
                    oBehParams = (DIALOG_073 << 16),
                    acts = (ACT_3 | ACT_4 | ACT_5 | ACT_6),
                },

                -- 1-2
                {
                    id = id_bhvDoor,
                    oBehParams = 0xc8000000,
                    acts = (ACT_1 | ACT_2),
                },
                {
                    id = "bhvSpring_MOP",
                    oSyncID = 330,
                    acts = ACT_2,
                },

                -- 3+
                {
                    id = id_bhvPushableMetalBox, -- blocking path
                    acts = (ACT_1 | ACT_2),
                },
                {
                    id = id_bhvDoor,
                    oBehParams = 0,
                    acts = (ACT_3 | ACT_4 | ACT_5 | ACT_6),
                },
                {
                    id = id_bhvDoorWarp,
                    acts = (ACT_3 | ACT_4 | ACT_5 | ACT_6),
                },
            },
            [2] = { -- Star 5 is always there because there isn't much point in disabling it
                -- 1-2
                {
                    id = id_bhvDoor,
                    oBehParams = 0xc8000000,
                    acts = (ACT_1 | ACT_2),
                },

                -- 3+
                {
                    id = id_bhvDoorWarp,
                    oBehParams = 0x00320000,
                    acts = (ACT_3 | ACT_4 | ACT_5 | ACT_6),
                },
                {
                    id = id_bhvDoorWarp,
                    oBehParams = 0x003c0000,
                    acts = (ACT_3 | ACT_4 | ACT_5 | ACT_6),
                },
            },
        },
        [LEVEL_TTM] = {
            [1] = {
                extra = {
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, -2973.7, 71, 3069.9, 0, LEVEL_TTM, 1 },
                },
            },
        },
        [LEVEL_THI] = {
            [1] = {
                -- 1-6
                {
                    id = {id_bhvKoopaFlag, id_bhvKoopaRaceEndpoint},
                    acts = ALL_ACTS,
                },

                -- 3
                {
                    id = id_bhvKoopa,
                    oBehParams2ndByte = KOOPA_BP_KOOPA_THE_QUICK_THI,
                    acts = ACT_3,
                },

                extra = {
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, -3566, -3889, -8780, 0, LEVEL_THI, 1 },
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, -3566, -3889, -9580, 0, LEVEL_THI, 1 },
                },
            },
            [2] = {
                extra = {
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, 0, 1034, 116, 0, LEVEL_THI, 1 },
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, -813.3, 60, 813.8, 0, LEVEL_THI, 1 },
                },
            },
        },
        -- ttc is looking really good for non-stop
        [LEVEL_TTC] = {
            [1] = {{}},
            [2] = {{}},
        },
        [LEVEL_RR] = {
            [1] = {
                extra = {
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, -7650, 4949, -7050, 0, LEVEL_RR, 1 },
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, 5420, 1500, -7801.6, 0, LEVEL_RR, 1 },
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, 13975.4, 9560, -3918, 0, LEVEL_RR, 1 },
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, 14905.3, 7079, 9267, 0, LEVEL_RR, 1 },
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, -1210, 6299, 14150, 0, LEVEL_RR, 1 },
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, -5036, 4080, 6911, 0, LEVEL_RR, 1 },
                },
            },
        },
        [LEVEL_PSS] = {
            [1] = {
                extra = { -- the timer doesn't reset so i have it warp the player back to castle
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, -9753, 1199, -2704, 0, LEVEL_CASTLE, 1 },
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, 1920, -5399, -4781, 0, LEVEL_CASTLE, 1 },
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, 15820, -7799, 273.9, 0, LEVEL_CASTLE, 1 },
                },
            },
        },
        -- [LEVEL_WMOTR] = { -- I don't think this is needed anymore..?
        --     [6] = {
        --         extra = {
        --             { id_bhvSparkleFadingWarp, E_MODEL_NONE, -4206, 3575, -8530, 0, LEVEL_WMOTR, 1 },
        --         },
        --     },
        -- },
        [LEVEL_TOTWC] = {
            [2] = {
                extra = {
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, 602.8, 5399, 6777.3, 0, LEVEL_TOTWC, 2 },
                    { id_bhvSparkleFadingWarp, E_MODEL_NONE, 3497.8, 4199, 8594.9, 0, LEVEL_TOTWC, 2 },
                },
            },
        },
    },
}

romhack_data["decades-later-coop"] = {
    inherit = "decades-later-coop-main",
}

romhack_data["sm64-dl-hack-mh-main"] = {
    inherit = "decades-later-coop-main",
}

romhack_data["sm64-dl-hack-mh"] = {
    inherit = "decades-later-coop-main",
}
