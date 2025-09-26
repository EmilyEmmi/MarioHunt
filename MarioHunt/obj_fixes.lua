--
-- Various object changes
--

local m0 = gMarioStates[0]
local sMario0 = gPlayerSyncTable[0]
local np0 = gNetworkPlayers[0]

local function hook_behavior_custom(id, override, init, loop)
    return hook_behavior(id,
        get_object_list_from_behavior(get_behavior_from_id(id)), -- Automatically get the correct object list
        override, init, loop,
        "bhvMhCustom" ..
        get_behavior_name_from_id(id):sub(4) -- Give the behavior a consistent behavior name (for example, bhvTreasureChestsJrb will become bhvMhCustomTreasureChestsJrb)
    )
end

-- Prevent bowser bomb softlock
local function on_object_unload(o)
    if obj_has_behavior_id(o, id_bhvBowserBomb) == 1 then
        local bomb = obj_get_first_with_behavior_id(id_bhvBowserBomb)
        if not bomb and is_nearest_mario_state_to_object(m0, o) ~= 0 then
            spawn_sync_object(
                id_bhvBowserBomb,
                E_MODEL_BOWSER_BOMB,
                o.oPosX, o.oPosY, o.oPosZ,
                function(bomb)
                    bomb.oIntangibleTimer = 120
                end
            )
        end
    elseif obj_is_mushroom_1up(o) then
        if obj_check_if_collided_with_object(o, m0.marioObj) ~= 0 then
            m0.healCounter = m0.healCounter + 16 -- 4 hp
        end
    end
end

hook_event(HOOK_ON_OBJECT_UNLOAD, on_object_unload)

-- Prevent players from destroying bowser bombs
local function bhv_custom_bowser_bomb_init(o)
    o.oFlags = o.oFlags | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oIntangibleTimer = 0
    o.hitboxRadius, o.hitboxHeight, o.hitboxDownOffset = 40, 40, 40
end
local function bhv_custom_bowser_bomb_loop(o)
    o.oIntangibleTimer = 0
    o.numCollidedObjs = 0 -- prevent player collisions (bowser still works fine)
    bhv_bowser_bomb_loop()
end
hook_behavior_custom(id_bhvBowserBomb, true, bhv_custom_bowser_bomb_init, bhv_custom_bowser_bomb_loop)

-- Prevent hunters from interacting with chests
local function bhv_custom_chest_bottom_init(o)
    o.oFlags = o.oFlags | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    cur_obj_update_floor_height()
    bhv_treasure_chest_bottom_init()
    o.oIntangibleTimer = -1
end
---@param o Object
local function bhv_custom_chest_bottom_loop(o)
    local m = nearest_mario_state_to_object(o)

    -- Prevent opening the wrong chest in omm
    if OmmEnabled and o.parentObj.oTreasureChestIsLastInteractionIncorrect ~= 0 then
        o.parentObj.oTreasureChestCurrentAnswer = o.unused1
        o.oAction = bool_to_int(o.unused1 > o.oBehParams2ndByte)
        o.parentObj.oTreasureChestIsLastInteractionIncorrect = 0
    end

    if o.oAction == 1 or (o.oAction == 0 and m and (not treat_as_hunter(m.playerIndex)) and is_point_within_radius_of_mario(o.oPosX, o.oPosY, o.oPosZ, 150) and obj_check_if_facing_toward_angle(o.oMoveAngleYaw, m.marioObj.header.gfx.angle.y + 0x8000, 0x3000)) then
        bhv_treasure_chest_bottom_loop()
    elseif o.oAction == 2 then
        bhv_treasure_chest_bottom_loop()
        if m and treat_as_hunter(m.playerIndex) then
            o.oAction = 0
        end
    else
        cur_obj_push_mario_away_from_cylinder(150.0, 150.0)
        o.oInteractStatus = 0
    end

    o.unused1 = o.parentObj.oTreasureChestCurrentAnswer
end

hook_behavior_custom(id_bhvTreasureChestBottom, true, bhv_custom_chest_bottom_init, bhv_custom_chest_bottom_loop)

-- Replace all Hearts with 1Ups
local function bhv_replace_with_1up(o)
    if ROMHACK.heartReplace then -- some hacks require the use of hearts
        spawn_non_sync_object(
            id_bhv1Up,
            E_MODEL_1UP,
            o.oPosX, o.oPosY, o.oPosZ,
            nil
        )
        obj_mark_for_deletion(o)
    end
end
-- Fix extreme mode
local function bhv_recovery_heart_loop(o)
    local m = gMarioStates[0]
    local sMario = gPlayerSyncTable[0]
    if sMario.hard == 2 and sMario.team == 1 and (o.oSpinningHeartTotalSpin + o.oAngleVelYaw) >= 0x10000 and dist_between_objects(o, m.marioObj) < 1000 then
        m.capTimer = 60
        m.flags = m.flags | MARIO_METAL_CAP
    end
end

hook_behavior_custom(id_bhvRecoveryHeart, false, bhv_replace_with_1up, bhv_recovery_heart_loop)

-- make the key grabbable sooner
local function custom_key_loop(o)
    if o.oVelY > 0 then o.oVelY = 0 end

    local sBowserKeyHitbox = get_temp_object_hitbox()
    sBowserKeyHitbox.interactType = INTERACT_STAR_OR_KEY
    sBowserKeyHitbox.downOffset = 0
    sBowserKeyHitbox.damageOrCoinValue = 0
    sBowserKeyHitbox.health = 0
    sBowserKeyHitbox.numLootCoins = 0
    sBowserKeyHitbox.radius = 160
    sBowserKeyHitbox.height = 100
    sBowserKeyHitbox.hurtboxRadius = 160
    sBowserKeyHitbox.hurtboxHeight = 100
    obj_set_hitbox(o, sBowserKeyHitbox)

    if (o.oInteractStatus & INT_STATUS_INTERACTED) ~= 0 then
        obj_mark_for_deletion(o);
        o.oInteractStatus = 0;
    end

    if o.oAction == 0 and (o.oMoveFlags & OBJ_MOVE_LANDED) ~= 0 then
        o.oAction = 1
    end
end

hook_behavior_custom(id_bhvBowserKey, false, nil, custom_key_loop)

-- detect cap switches
local function custom_switch_loop(o)
    if o.oAction == 2 and o.oTimer == 0 and is_nearest_mario_state_to_object(m0, o) ~= 0 then
        -- send message
        network_send_include_self(false, {
            id = PACKET_RUNNER_COLLECT,
            runnerID = np0.globalIndex,
            level = np0.currLevelNum,
            course = np0.currCourseNum,
            area = np0.currAreaIndex,
            switch = o.oBehParams2ndByte,
        })
    elseif o.oAction == 2 and o.oTimer == 4 then -- disable dialog
        o.header.gfx.scale.y = 0.1
        o.oAction = 3
    end
end

hook_behavior_custom(id_bhvCapSwitch, false, nil, custom_switch_loop)

-- instantly open cannon
local function custom_bobomb_buddy_cannon_loop(o)
    if o.oBobombBuddyCannonStatus == BOBOMB_BUDDY_CANNON_OPENING then
        cur_obj_play_sound_1(SOUND_OBJ_CANNON3)
        local cannonClosed = cur_obj_nearest_object_with_behavior(get_behavior_from_id(id_bhvCannonClosed))
        if cannonClosed then
            obj_mark_for_deletion(cannonClosed)
        end
        o.oBobombBuddyCannonStatus = BOBOMB_BUDDY_CANNON_STOP_TALKING
    end
end
hook_behavior_custom(id_bhvBobombBuddyOpensCannon, false, nil, custom_bobomb_buddy_cannon_loop)

-- prevent elevator camping
local function custom_elevator_loop(o)
    -- check if there are any nearby players waiting at the bottom. If so, SEND THE ELEVATOR!
    -- note that oElevatorUnkF4 is the elevator's bottom y position. oElevatorUnkFC is... I think the middle point?
    local nearestM = nearest_mario_state_to_object(o)
    if nearestM and nearestM.playerIndex == 0 and (o.oAction == 0 or (o.oAction == 3 and o.oTimer > 60)) and o.oElevatorUnk100 ~= 2 and o.oPosY > o.oElevatorUnkF4 then
        for i=0,MAX_PLAYERS-1 do
            local m = gMarioStates[i]
            if is_player_active(m) ~= 0 and m.pos.y < o.oElevatorUnkFC and dist_between_object_and_point(m.marioObj, o.oPosX, o.oElevatorUnkF4, o.oPosZ) < 1000 then
                o.oAction = 2
                network_send_object(o, false)
                break
            end
        end
    end

    -- faster when going up
    if o.oVelY > 0 then
        bhv_elevator_loop()
    end
end
hook_behavior_custom(id_bhvHmcElevatorPlatform, false, nil, custom_elevator_loop)
hook_behavior_custom(id_bhvMeshElevator, false, nil, custom_elevator_loop)

-- instant/faster cutscene, or radar
function star_update(radar)
    if radar then
        radar_store = {}
    end
    local didRadar = {}
    if gGlobalSyncTable.mhMode ~= 2 or gNetworkPlayers[0].currLevelNum == gGlobalSyncTable.gameLevel then
        local o = obj_get_first(OBJ_LIST_LEVEL)
        while o do
            if o.oInteractType == INTERACT_STAR_OR_KEY or obj_has_behavior_id_in_list(o, star_ids) then
                if obj_has_behavior_id(o, id_bhvSpawnedStar) ~= 0 or obj_has_behavior_id(o, id_bhvSpawnedStarNoLevelExit) ~= 0 then
                    if o.oAction == 0 then
                        o.oPosX, o.oPosY, o.oPosZ = o.oHomeX, o.oHomeY, o.oHomeZ
                        o.oVelX, o.oVelY, o.oVelZ = 0, 0, 0
                        o.oForwardVel = 0
                        o.oGravity = 0
                        o.oAction = 3
                        obj_become_tangible(o)
                    end
                elseif obj_has_behavior_id(o, id_bhvStarSpawnCoordinates) ~= 0 then
                    if o.oAction == 0 then
                        -- give star if this is minihunt and this is the star we need to get
                        if o.oStarSpawnDisFromHome >= 1 and gGlobalSyncTable.mhMode == 2 and gGlobalSyncTable.mhState == 2 and (o.oBehParams >> 24) + 1 == gGlobalSyncTable.getStar then
                            local m = gMarioStates[0]
                            if nearest_runner_to_object(o) == m then
                                on_interact(m, o, INTERACT_STAR_OR_KEY, 1)
                            end
                        end
                        
                        o.oAction = 1
                    elseif o.oAction == 1 then
                        if o.oForwardVel < 1 then
                            obj_become_tangible(o)
                        end
                        if (o.oInteractStatus & INT_STATUS_INTERACTED) ~= 0 then -- in case of early interaction
                            obj_mark_for_deletion(o)
                            o.oInteractStatus = 0
                        end
                    elseif (o.oAction == 2) then
                        o.oTimer = 20
                        o.oPosY = o.oHomeY - 1
                    end
                end

                if radar and (o.activeFlags & ACTIVE_FLAG_DORMANT == 0) then
                    local star = (o.oBehParams >> 24) + 1
                    if ((star > 0 and star < 8) or ROMHACK.isUnder) and not didRadar[star] then
                        local np = gNetworkPlayers[0]
                        if o.oInteractionSubtype & INT_SUBTYPE_GRAND_STAR ~= 0 then
                            if not star_radar[star] then
                                star_radar[star] = { tex = TEX_STAR, prevX = 0, prevY = 0, prevScale = 0.6 }
                                star_minimap[star] = { tex = gTextures.star, prevX = 0, prevY = 0 }
                            end
                            table.insert(radar_store, { o })
                            didRadar[star] = 1
                        elseif np.currLevelNum == LEVEL_BOWSER_1 or np.currLevelNum == LEVEL_BOWSER_2 then
                            local valid = true
                            local save_flags = save_file_get_flags()
                            if np.currLevelNum == LEVEL_BOWSER_1 and save_flags & (SAVE_FLAG_HAVE_KEY_1 | SAVE_FLAG_UNLOCKED_BASEMENT_DOOR) ~= 0 then
                                valid = false
                            elseif np.currLevelNum == LEVEL_BOWSER_2 and save_flags & (SAVE_FLAG_HAVE_KEY_2 | SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR) ~= 0 then
                                valid = false
                            end
                            if valid then
                                if not star_radar[star] then
                                    star_radar[star] = { tex = TEX_STAR, prevX = 0, prevY = 0, prevScale = 0.6 }
                                    star_minimap[star] = { tex = gTextures.star, prevX = 0, prevY = 0 }
                                end
                                table.insert(radar_store, { o, "key" })
                                didRadar[star] = 1
                            end
                        elseif gGlobalSyncTable.mhMode ~= 2 then
                            local file = get_current_save_file_num() - 1
                            local course_star_flags = save_file_get_star_flags(file, np.currCourseNum - 1)

                            if course_star_flags & (1 << (star - 1)) == 0 then
                                if not star_radar[star] then
                                    star_radar[star] = { tex = TEX_STAR, prevX = 0, prevY = 0, prevScale = 0.6 }
                                    star_minimap[star] = { tex = gTextures.star, prevX = 0, prevY = 0 }
                                end
                                table.insert(radar_store, { o })
                                didRadar[star] = 1
                            end
                        elseif star == gGlobalSyncTable.getStar then
                            if not star_radar[star] then
                                star_radar[star] = { tex = TEX_STAR, prevX = 0, prevY = 0, prevScale = 0.6 }
                                star_minimap[star] = { tex = gTextures.star, prevX = 0, prevY = 0 }
                            end
                            table.insert(radar_store, { o })
                            didRadar[star] = 1
                        end
                    end
                end
            end
            o = obj_get_next(o)
        end
    end
end

-- Fix the water ring hitbox (Isaac)
hook_behavior_custom(id_bhvMantaRayWaterRing, false, function(o)
    o.oWaterRingScalePhaseX = (random_u16() & 0xFFF) + 0x1000
    o.oWaterRingScalePhaseY = (random_u16() & 0xFFF) + 0x1000
    o.oWaterRingScalePhaseZ = (random_u16() & 0xFFF) + 0x1000
    local dest = vec3f_rotate_zxy({ x = 0, y = 1, z = 0 },
        {
            x = o.oFaceAnglePitch,
            y = o.oFaceAngleYaw,
            z = o.oFaceAngleRoll
        }
    )
    o.oWaterRingNormalX = dest.x
    o.oWaterRingNormalY = dest.y
    o.oWaterRingNormalZ = dest.z
end, nil)

-- Skip snowman dialog (Isaac) (Removed because it doesn't work anymore)
--[[hook_behavior_custom(id_bhvSnowmansBottom, false, nil, function(o)
    if o.oAction == 0 and m0.action == ACT_READING_NPC_DIALOG and is_point_within_radius_of_mario(o.oPosX, o.oPosY, o.oPosZ, 400) ~= 0 then
        o.oForwardVel = 10
        cur_obj_change_action(1)
        set_mario_action(m0, not m0.heldObj and ACT_IDLE or ACT_HOLD_IDLE, 0)
        print("disabled cutscene")
        disable_time_stop_including_mario()
        m0.freeze = 0
        m0.area.camera.cutscene = 0
        play_cutscene(m0.area.camera)
        if (o.coopFlags & COOP_OBJ_FLAG_NON_SYNC) == 0 then network_send_object(o, true) end
    end
end)]]

-- Prevents the tilting platform in Bowser 2 from moving erratically, preventing cheesy deaths
---@param o Object
function custom_tilt_platform_loop(o)
    -- reset orientation action
    if o.oAction == 2 then
        o.oAngleVelPitch = approach_s16_symmetric(o.oFaceAnglePitch, 0, 0x100) - o.oFaceAnglePitch
        o.oAngleVelRoll = approach_s16_symmetric(o.oFaceAngleRoll, 0, 0x100) - o.oFaceAngleRoll
        if o.oFaceAnglePitch == 0 and o.oFaceAngleRoll == 0 then
            o.oAngleVelPitch = 0
            o.oAngleVelRoll = 0
            o.oAction = 0
        end
        return
    end

    
    local bowser = obj_get_first_with_behavior_id(id_bhvBowser)
    if bowser and bowser.oAction == 19 then -- if the platform is moving...
        o.oAction = 1
        -- store previous in unrelated variables
        o.oBobombBuddyBlinkTimer = o.oFaceAnglePitch
        o.oBobombBuddyCannonStatus = o.oFaceAngleRoll
        if abs_angle_diff(0, o.oFaceAnglePitch) > 0x2000 or abs_angle_diff(0, o.oFaceAngleRoll) > 0x2000 then
            -- end tilt early
            bowser.oAction = 0
            o.oAction = 2
            if bowser.oSyncID ~= 0 then
                network_send_object(bowser, true)
            end
        end
    elseif o.oAction == 1 then
        -- load previous and switch to custom action if they are really different
        local prevPitch, prevRoll = o.oBobombBuddyBlinkTimer, o.oBobombBuddyCannonStatus
        if abs_angle_diff(0, prevPitch) > 0x100 or abs_angle_diff(0, prevRoll) > 0x100 then
            o.oFaceAnglePitch = prevPitch
            o.oFaceAngleRoll = prevRoll
            o.oAction = 2
            load_object_collision_model() -- dunno if this should be called
        else
            o.oAction = 0
        end
    end
    
    if gMarioStates[0].controller.buttonPressed & L_TRIG ~= 0 then
        o.oFaceAnglePitch = o.oFaceAnglePitch + 0x2000
    end
end

hook_behavior_custom(id_bhvTiltingBowserLavaPlatform, false, nil, custom_tilt_platform_loop)

-- speeds up the arrow platform in BITS and the elevator and BITFS (same object, funnily enough)
function custom_back_and_forth_platform_loop(o)
    if o.oActivatedBackAndForthPlatformVel ~= 0 then
        local platformType = ((o.oBehParams >> 16) & 0x0300) >> 8
        local sign = 1
        if o.oActivatedBackAndForthPlatformVel < 0 then sign = -1 end
        if platformType == ACTIVATED_BF_PLAT_TYPE_BITS_ARROW_PLAT then
            -- arrow platform travels backwards quickly if no one is on it
            if sign == -1 and cur_obj_is_any_player_on_platform() == 0 then
                o.oActivatedBackAndForthPlatformVel = 80 * sign
            else
                o.oActivatedBackAndForthPlatformVel = 15 * sign -- slightly faster than normal
            end
        elseif sign == 1 then
            -- elevator travels up quickly at a certain point..
            if o.oActivatedBackAndForthPlatformOffset > 600 then
                if o.oActivatedBackAndForthPlatformVel * sign < 40 then
                    o.oActivatedBackAndForthPlatformVel = o.oActivatedBackAndForthPlatformVel + 3 * sign
                else
                    o.oActivatedBackAndForthPlatformVel = 40 * sign
                end
            else
                o.oActivatedBackAndForthPlatformVel = 10 * sign
            end
        elseif cur_obj_is_any_player_on_platform() == 0 then
            -- ... and travels down even faster as long as no one is on it
            o.oActivatedBackAndForthPlatformVel = 80 * sign
        else
            o.oActivatedBackAndForthPlatformVel = 10 * sign
        end
    end
end

hook_behavior_custom(id_bhvActivatedBackAndForthPlatform, false, nil, custom_back_and_forth_platform_loop)

-- spawn extra carpets and track platforms for other players
---@param o Object
function custom_platform_on_track_loop(o)
    if o.oPlatformOnTrackIsNotSkiLift == 0 or (o.oBehParams >> 16) & PLATFORM_ON_TRACK_BP_RETURN_TO_START ~= 0 then return end

    -- sanity checks to prevent game crash (prevWaypoint becomes nil for newly spawned carpets when a player enters)
    if o.oPlatformOnTrackStartWaypoint == nil then
        bhv_platform_on_track_init()
    end
    if o.oPlatformOnTrackPrevWaypoint == nil then
        o.oPlatformOnTrackPrevWaypoint = o.oPlatformOnTrackStartWaypoint
    end

    if o.oAction == PLATFORM_ON_TRACK_ACT_MOVE_ALONG_TRACK then
        if o.oPlatformOnTrackSkiLiftRollVel ~= 999 then
            if o.oPlatformOnTrackSkiLiftRollVel < 150 then
                o.oPlatformOnTrackSkiLiftRollVel = o.oPlatformOnTrackSkiLiftRollVel + 1 -- unused for non-ski lifts
            elseif sync_object_is_owned_locally(o.oSyncID) then
                local new = spawn_sync_object(id_bhvPlatformOnTrack, obj_get_model_id_extended(o), o.oHomeX, o.oHomeY, o.oHomeZ, function(new)
                    new.oBehParams = o.oBehParams
                    new.oPlatformOnTrackType = o.oPlatformOnTrackType
                    new.oPlatformOnTrackIsNotSkiLift = o.oPlatformOnTrackIsNotSkiLift
                    new.oMoveAngleYaw = o.oBehParams2ndByte -- why is this stored here???
                    new.oFaceAnglePitch = 0
                    new.oFaceAngleRoll = 0
                    new.oPlatformOnTrackStartWaypoint = o.oPlatformOnTrackStartWaypoint
                    new.oPlatformOnTrackPrevWaypoint = new.oPlatformOnTrackStartWaypoint
                    new.oPlatformOnTrackBaseBallIndex = 0
                end)
                if new then
                    o.oPlatformOnTrackSkiLiftRollVel = 999
                    network_send_object(o, false)
                end
            end
        end
    elseif o.oAction == PLATFORM_ON_TRACK_ACT_INIT then
        if o.oPlatformOnTrackSkiLiftRollVel == 999 then
            obj_mark_for_deletion(o)
        end
    end
end

hook_behavior_custom(id_bhvPlatformOnTrack, false, nil, custom_platform_on_track_loop)

-- outline stuff

local MODEL_MARIO = 0x01                     -- mario_geo
local MODEL_MARIOS_WINGED_METAL_CAP = 0x85   -- marios_winged_metal_cap_geo
local MODEL_MARIOS_METAL_CAP = 0x86          -- marios_metal_cap_geo
local MODEL_MARIOS_WING_CAP = 0x87           -- marios_wing_cap_geo
local MODEL_MARIOS_CAP = 0x88                -- marios_cap_geo

local MODEL_LUIGI = 0xE3                     -- luigi_geo
local MODEL_LUIGIS_CAP = 0xE4                -- luigis_cap_geo
local MODEL_LUIGIS_METAL_CAP = 0xE5          -- luigis_metal_cap_geo
local MODEL_LUIGIS_WING_CAP = 0xE6           -- luigis_wing_cap_geo
local MODEL_LUIGIS_WINGED_METAL_CAP = 0xE7   -- luigis_winged_metal_cap_geo

local MODEL_TOAD_PLAYER = 0xE8               -- toad_player_geo
local MODEL_TOADS_CAP = 0xE9                 -- toads_cap_geo
local MODEL_TOADS_METAL_CAP = 0xEA           -- toads_metal_cap_geo
local MODEL_TOADS_WING_CAP = 0xEB            -- toads_wing_cap_geo
local MODEL_TOADS_WINGED_METAL_CAP = 0xEC    -- toads_winged_metal_cap_geo

local MODEL_WALUIGI = 0xED                   -- waluigi_geo
local MODEL_WALUIGIS_CAP = 0xEE1             -- waluigis_cap_geo
local MODEL_WALUIGIS_METAL_CAP = 0xEF        -- waluigis_metal_cap_geo
local MODEL_WALUIGIS_WING_CAP = 0xF0         -- waluigis_wing_cap_geo
local MODEL_WALUIGIS_WINGED_METAL_CAP = 0xF1 -- waluigis_winged_metal_cap_geo

local MODEL_WARIO = 0xF2                     -- wario_geo
local MODEL_WARIOS_CAP = 0xF3                -- warios_cap_geo
local MODEL_WARIOS_METAL_CAP = 0xF4          -- warios_metal_cap_geo
local MODEL_WARIOS_WING_CAP = 0xF5           -- warios_wing_cap_geo
local MODEL_WARIOS_WINGED_METAL_CAP = 0xF6   -- warios_winged_metal_cap_geo

-- outline models for each character and caps - order is Red, Blue, Yellow, Purple
local OUTLINE_MODEL = {}
if not LITE_MODE then
    OUTLINE_MODEL = {
        [MODEL_MARIO] = { smlua_model_util_get_id("h_mario_geo"), smlua_model_util_get_id("r_mario_geo"), smlua_model_util_get_id("rh_mario_geo"), smlua_model_util_get_id("re_mario_geo") },
        [MODEL_MARIOS_CAP] = { smlua_model_util_get_id("h_marios_cap_geo"), smlua_model_util_get_id("r_marios_cap_geo"), smlua_model_util_get_id("rh_marios_cap_geo"), smlua_model_util_get_id("re_marios_cap_geo") },
        [MODEL_MARIOS_WING_CAP] = { smlua_model_util_get_id("h_marios_wing_cap_geo"), smlua_model_util_get_id("r_marios_wing_cap_geo"), smlua_model_util_get_id("rh_marios_wing_cap_geo"), smlua_model_util_get_id("re_marios_wing_cap_geo") },
        [MODEL_MARIOS_METAL_CAP] = { smlua_model_util_get_id("h_marios_metal_cap_geo"), smlua_model_util_get_id("r_marios_metal_cap_geo"), smlua_model_util_get_id("rh_marios_metal_cap_geo"), smlua_model_util_get_id("re_marios_metal_cap_geo") },
        [MODEL_MARIOS_WINGED_METAL_CAP] = { smlua_model_util_get_id("h_marios_winged_metal_cap_geo"), smlua_model_util_get_id("r_marios_winged_metal_cap_geo"), smlua_model_util_get_id("rh_marios_winged_metal_cap_geo"), smlua_model_util_get_id("re_marios_winged_metal_cap_geo") },
    }
end

E_MODEL_CAKE = ((not LITE_MODE) and smlua_model_util_get_id("mh_star_geo")) -- no more waiting for cake, just do logo star

local dontLoop = false
function on_obj_set_model(o, model)
    if dontLoop then return end
    if model == 0 and obj_has_behavior_id(o, id_bhvHiddenStarTrigger) ~= 0 then
        obj_set_model_extended(o, E_MODEL_PURPLE_MARBLE)
    end

    if (model == 0x79 or model == 0x7A) and obj_has_behavior_id_in_list(o, star_ids) then -- star model changes on anniversary
        local star = (o.oBehParams >> 24) + 1
        local starModel = (month == 14 and E_MODEL_CAKE) or E_MODEL_STAR
        if gGlobalSyncTable.mhMode == 2 then
            if (star == gGlobalSyncTable.getStar) ~= (model == 0x7A) then
                if model == 0x7A then
                    obj_set_model_extended(o, E_MODEL_TRANSPARENT_STAR)
                else
                    obj_set_model_extended(o, starModel)
                end
            end
        elseif month == 14 and E_MODEL_CAKE and model == 0x7A then
            dontLoop = true
            obj_set_model_extended(o, starModel)
            dontLoop = false
        end
    elseif (not (LITE_MODE or charSelectExists)) and (runnerAppearance == 3 or hunterAppearance == 3) and OUTLINE_MODEL[model] then
        local np = network_player_from_global_index(o.globalPlayerIndex)
        if not np then return end
        local sMario = gPlayerSyncTable[np.localIndex]
        local modelIndex = 1
        if not know_team(np.localIndex) then return end

        if disguiseMod then
            local gIndex = disguiseMod.getDisguisedIndex(np.globalIndex)
            sMario = gPlayerSyncTable[network_local_index_from_global(gIndex)]
        end
        
        if sMario.team == 1 then
            if runnerAppearance ~= 3 then return end
            modelIndex = (sMario.hard or 0) + 2
        elseif hunterAppearance ~= 3 then
            return
        end
        if OUTLINE_MODEL[model][modelIndex] then
            obj_set_model_extended(o, OUTLINE_MODEL[model][modelIndex])
        end
    end
end

--hook_event(HOOK_OBJECT_SET_MODEL, on_obj_set_model) -- done in main.lua

-- definitely a necessary feature
obj_kill_names = {
    [id_bhvBowser] = "\\#ff1f1f\\Bowser",
    [id_bhvBowserBodyAnchor] = "\\#ff1f1f\\Bowser",
    [id_bhvBlueBowserFlame] = "\\#ff1f1f\\Bowser",
    [id_bhvFlameBowser] = "\\#ff1f1f\\Bowser",
    [id_bhvFlameLargeBurningOut] = "\\#ff1f1f\\Bowser",
    [id_bhvGoomba] = "\\#bf9c50\\Goomba",
    [id_bhvBobomb] = "\\#707070\\Bob-Omb",
    [id_bhvKingBobomb] = "\\#707070\\King Bob-Omb",
    [id_bhvPiranhaPlant] = "\\#2eab2e\\Piranha Plant",
    [id_bhvFirePiranhaPlant] = "\\#ff1f1f\\Fire Piranha Plant",
    [id_bhvFlamethrowerFlame] = "\\#ff1f1f\\Flamethrower",
    [id_bhvBoo] = "Boo",
    [id_bhvMerryGoRoundBoo] = "Boo",
    [id_bhvGhostHuntBoo] = "Boo",
    [id_bhvBooWithCage] = "Big Boo",
    [id_bhvBalconyBigBoo] = "Big Boo",
    [id_bhvGhostHuntBigBoo] = "Big Boo",
    [id_bhvMerryGoRoundBigBoo] = "Big Boo",
    [id_bhvMrI] = "Mr. I",
    [id_bhvMrIParticle] = "Mr. I",
    [id_bhvMrBlizzard] = "Mr. Blizzard",
    [id_bhvMrBlizzardSnowball] = "Mr. Blizzard",
    [id_bhvMrBlizzardSnowball] = "Mr. Blizzard",
    [id_bhvBulletBill] = "\\#707070\\Bullet Bill",
    [id_bhvChainChomp] = "\\#707070\\Chain Chomp",
    [id_bhvBigBully] = "\\#707070\\Big Bully",
    [id_bhvBigBullyWithMinions] = "\\#707070\\Big Bully",
    [id_bhvSmallBully] = "\\#707070\\Bully",
    [id_bhvSmallChillBully] = "\\#91fff2\\Chill Bully",
    [id_bhvBigChillBully] = "\\#91fff2\\Big Chill Bully",
    [id_bhvUnagiSubobject] = "\\#ab2e56\\Unagi",
    [id_bhvFlyingBookend] = "\\#2eab2e\\Flying Book",
    [id_bhvHauntedChair] = "\\#bf9c50\\Flying Chair",
    [id_bhvMadPiano] = "\\#707070\\Mad Piano",
    [id_bhvFlyGuy] = "\\#ff5050\\Fly Guy",
    [id_bhvFlyguyFlame] = "\\#ff5050\\Fly Guy",
    [id_bhvScuttlebug] = "\\#f5d142\\Scuttlebug",
    [id_bhvWigglerHead] = "\\#f5d142\\Wiggler",
    [id_bhvWigglerBody] = "\\#f5d142\\Wiggler",
    [id_bhvChuckya] = "\\#e642f5\\Chuckya",
    [id_bhvSnufit] = "\\#ff5050\\Snufit",
    [id_bhvSnufitBalls] = "\\#ff5050\\Snufit",
    [id_bhvMontyMole] = "\\#bf9c50\\Monty Mole",
    [id_bhvMontyMoleRock] = "\\#bf9c50\\Monty Mole",
    [id_bhvBigBoulder] = "\\#bf9c50\\Rolling Rock",
    [id_bhvBowlingBall] = "\\#707070\\Bowling Ball",
    [id_bhvPitBowlingBall] = "\\#707070\\Bowling Ball",
    [id_bhvFreeBowlingBall] = "\\#707070\\Bowling Ball",
    [id_bhvHomingAmp] = "\\#707070\\Amp",
    [id_bhvCirclingAmp] = "\\#707070\\Amp",
    [id_bhvSushiShark] = "\\#5050ff\\Sushi",
    [id_bhvHeaveHo] = "\\#ff5050\\Heave-Ho",
    [id_bhvSkeeter] = "\\#5050ff\\Skeeter",
    [id_bhvClamShell] = "\\#e642f5\\Clam",
    [id_bhvSmallWhomp] = "\\#A0A0A0\\Whomp",
    [id_bhvWhompKingBoss] = "\\#A0A0A0\\Whomp King",
    [id_bhvThwomp] = "\\#0d41ff\\Thwomp",
    [id_bhvThwomp2] = "\\#0d41ff\\Thwomp",
    [id_bhvGrindel] = "\\#A0A0A0\\Grindel",
    [id_bhvHorizontalGrindel] = "\\#A0A0A0\\Grindel",
    [id_bhvSpindel] = "\\#A0A0A0\\Spindel",
    [id_bhvEyerokHand] = "\\#f5d142\\Eyerok",
    [id_bhvToxBox] = "\\#ab2e56\\Tox Box",
    [id_bhvPokey] = "\\#f5d142\\Pokey",
    [id_bhvPokeyBodyPart] = "\\#f5d142\\Pokey",
    [id_bhvEnemyLakitu] = "\\#f5d142\\Lakitu",
    [id_bhvSpiny] = "\\#ff1f1f\\Spiny",
}

-- all DDD stuff
---@param o Object
function custom_ddd_sub_init(o)
    o.oFlags = o.oFlags | (OBJ_FLAG_ACTIVE_FROM_AFAR | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE)
    o.oCollisionDistance = 20000
    o.collisionData = smlua_collision_util_get('ddd_seg7_collision_submarine')
end

---@param o Object
function custom_ddd_door_init(o)
    o.oFlags = o.oFlags | (OBJ_FLAG_ACTIVE_FROM_AFAR | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE)
    o.oCollisionDistance = 20000
    o.collisionData = smlua_collision_util_get('ddd_seg7_collision_bowser_sub_door')
end

---@param o Object
function custom_ddd_loop(o)
    if (not gGlobalSyncTable.freeRoam) or (gGlobalSyncTable.mhMode == 2) then
        bhv_bowsers_sub_loop()
        load_object_collision_model()
        return
    end
    local file = get_current_save_file_num() - 1
    if save_file_get_star_flags(file, COURSE_DDD - 1) & 1 ~= 0 then
        cur_obj_disable_rendering()
    else
        cur_obj_enable_rendering()
        load_object_collision_model()
    end
end

hook_behavior_custom(id_bhvBowsersSub, true, custom_ddd_sub_init, custom_ddd_loop)
hook_behavior_custom(id_bhvBowserSubDoor, true, custom_ddd_door_init, custom_ddd_loop)

---@param o Object
function custom_ddd_warp_init(o)
    o.oFlags = o.oFlags | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oCollisionDistance = 30000
end

---@param o Object
function custom_ddd_warp_loop(o)
    if not gGlobalSyncTable.freeRoam then
        gPaintingValues.ddd_painting.posZ = 1587.1999511719
        bhv_ddd_warp_loop()
        load_object_collision_model()
        return
    end
    local paintingShift = 0
    local file = get_current_save_file_num() - 1
    if save_file_get_star_flags(file, COURSE_DDD - 1) & 1 == 0 then
        local m = gMarioStates[0]
        paintingShift = 600
        if m.pos.z > 1587.1999511719 + paintingShift and m.pos.x <= 3556 then
            o.collisionData = smlua_collision_util_get('inside_castle_seg7_collision_ddd_warp')
        else
            o.collisionData = smlua_collision_util_get('inside_castle_seg7_collision_ddd_warp_2')
        end
        if m.pos.x > 5000 then
            o.oPosX = 5000
        else
            o.oPosX = 0
        end
    else
        o.oPosX = 0
        o.collisionData = smlua_collision_util_get('inside_castle_seg7_collision_ddd_warp_2')
    end
    gPaintingValues.ddd_painting.posZ = 1587.1999511719 + paintingShift
    load_object_collision_model()
end

hook_behavior_custom(id_bhvDddWarp, true, custom_ddd_warp_init, custom_ddd_warp_loop)

--- actual custom objects ---

E_MODEL_MH_SPARKLE = ((not LITE_MODE) and smlua_model_util_get_id("mh_sparkle_geo")) or E_MODEL_SPARKLES

-- create the Green Demon object (built from 1up, obviously)
E_MODEL_DEMON = ((not LITE_MODE) and smlua_model_util_get_id("demon_geo")) or E_MODEL_1UP
--- @param o Object
function demon_init(o)
  o.oFlags = o.oFlags | OBJ_FLAG_COMPUTE_ANGLE_TO_MARIO | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
  obj_set_billboard(o)

  cur_obj_set_hitbox_radius_and_height(30, 30)
  o.oGraphYOffset = 30
  bhv_1up_common_init()
end

--- @param o Object
function demon_loop(o)
  o.oIntangibleTimer = 0

  if o.oAction == 1 then
    local demonStop = (m0.invincTimer > 0)
    local demonDespawn = ((not demonOn) or sMario0.team ~= 1 or gGlobalSyncTable.mhState ~= 2)
    demon_move_towards_mario(o)
    if demonDespawn then
      o.activeFlags = ACTIVE_FLAG_DEACTIVATED
    elseif demonStop then
      -- nothing
    elseif dist_between_objects(o, m0.marioObj) > 5000 then -- clip at far distances
      o.oVelX = o.oForwardVel * sins(o.oMoveAngleYaw);
      o.oVelZ = o.oForwardVel * coss(o.oMoveAngleYaw);
      obj_update_pos_vel_xz()
      o.oPosY = o.oPosY + o.oVelY
    else
      object_step()
    end
  else
    bhv_1up_hidden_in_pole_loop()
  end
end

--- @param o Object
function demon_move_towards_mario(o)
  local player = m0.marioObj
  if (player) then
    local sp34 = player.header.gfx.pos.x - o.oPosX;
    local sp30 = player.header.gfx.pos.y + 120 - o.oPosY;
    local sp2C = player.header.gfx.pos.z - o.oPosZ;
    local sp2A = atan2s(math.sqrt(sqr(sp34) + sqr(sp2C)), sp30);

    obj_turn_toward_object(o, player, 16, 0x1000);
    o.oMoveAnglePitch = approach_s16_symmetric(o.oMoveAnglePitch, sp2A, 0x1000);

    if obj_check_if_collided_with_object(o, player) ~= 0 then
      play_sound(SOUND_GENERAL_COLLECT_1UP, gGlobalSoundSource) -- replace?
      o.activeFlags = ACTIVE_FLAG_DEACTIVATED
      m0.health = 0xFF                                          -- die
    end
  end
  local vel = 30
  if m0.waterLevel >= m0.pos.y then
    vel = 15 -- half speed if mario is underwater
  end
  o.oVelY = sins(o.oMoveAnglePitch) * vel
  o.oForwardVel = coss(o.oMoveAnglePitch) * vel
end

id_bhvGreenDemon = hook_behavior(nil, OBJ_LIST_LEVEL, false, demon_init, demon_loop)

-- Wing cap warp that is only tangible when we meet the wing cap requirements
E_MODEL_TOTWC_ENTRANCE = smlua_model_util_get_id("totwc_entrance_geo")
function wing_cap_warp_init(o)
    o.oFlags = o.oFlags | (OBJ_FLAG_SET_FACE_YAW_TO_MOVE_YAW | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE)

    o.oInteractionSubtype = INT_SUBTYPE_FADING_WARP
    o.oInteractType = INTERACT_WARP
    o.hitboxRadius = 150
    o.oIntangibleTimer = 0
end

function wing_cap_warp_loop(o)
    if m0.numStars >= gLevelValues.wingCapLookUpReq then
        if save_file_get_flags() & SAVE_FLAG_HAVE_WING_CAP ~= 0 then
            o.oAnimState = 1
        else
            o.oAnimState = 0
        end
        cur_obj_become_tangible()
        bhv_fading_warp_loop()
    else
        o.oAnimState = 1
        cur_obj_become_intangible()
    end
end
id_bhvMHWingCapWarp = hook_behavior(nil, OBJ_LIST_LEVEL, false, wing_cap_warp_init, wing_cap_warp_loop)