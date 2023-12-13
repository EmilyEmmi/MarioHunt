--
-- Various object changes
--

local m0 = gMarioStates[0]
local np0 = gNetworkPlayers[0]

local function hook_behavior_custom(id, override, init, loop)
    hook_behavior(id,
        get_object_list_from_behavior(get_behavior_from_id(id)), -- Automatically get the correct object list
        override, init, loop,
        "bhvMhCustom" .. get_behavior_name_from_id(id):sub(4) -- Give the behavior a consistent behavior name (for example, bhvTreasureChestsJrb will become bhvMhCustomTreasureChestsJrb)
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
                nil
            )
        end
    end
end

hook_event(HOOK_ON_OBJECT_UNLOAD, on_object_unload)

-- Prevent hunters from interacting with chests
local function bhv_custom_chest_bottom_init(o)
    o.oFlags = o.oFlags | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    cur_obj_update_floor_height()
    bhv_treasure_chest_bottom_init()
    o.oIntangibleTimer = -1
end
---@param o Object
local function bhv_custom_chest_bottom_loop(o)
    local player = nearest_mario_state_to_object(o)

    -- Prevent opening the wrong chest in omm
    if OmmEnabled and o.parentObj.oTreasureChestIsLastInteractionIncorrect ~= 0 then
        o.parentObj.oTreasureChestCurrentAnswer = o.unused1
        o.oAction = (o.unused1 > o.oBehParams2ndByte and 1) or 0
        o.parentObj.oTreasureChestIsLastInteractionIncorrect = 0
    end

    if o.oAction == 1 or (o.oAction == 0 and player and gPlayerSyncTable[player.playerIndex].team == 1 and is_point_within_radius_of_mario(o.oPosX, o.oPosY, o.oPosZ, 150) and obj_check_if_facing_toward_angle(o.oMoveAngleYaw, player.marioObj.header.gfx.angle.y + 0x8000, 0x3000)) then
        bhv_treasure_chest_bottom_loop()
    elseif o.oAction == 2 then
        bhv_treasure_chest_bottom_loop()
        if player and gPlayerSyncTable[player.playerIndex].team ~= 1 then
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
    end
end

hook_behavior_custom(id_bhvCapSwitch, false, nil, custom_switch_loop)

-- instant/faster cutscene, or radar
function do_star_stuff(radar)
    local didRadar = {}
    if gGlobalSyncTable.mhMode ~= 2 or gNetworkPlayers[0].currLevelNum == gGlobalSyncTable.gameLevel then
        for id,bhvName in pairs(star_ids) do
            local o = obj_get_first_with_behavior_id(id)
            while o ~= nil do
                if o.unused1 == nil then o.unused1 = 0 end

                if id == id_bhvSpawnedStar or id == id_bhvSpawnedStarNoLevelExit then
                    if o.oAction == 0 then
                        o.oPosX,o.oPosY,o.oPosZ = o.oHomeX,o.oHomeY,o.oHomeZ
                        o.oVelX,o.oVelY,o.oVelZ = 0,0,0
                        o.oForwardVel = 0
                        o.oGravity = 0
                        o.oAction = 3
                        obj_become_tangible(o)
                    end
                elseif id == id_bhvStarSpawnCoordinates then
                    if o.oAction == 0 then
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

                if radar then
                    local star = (o.oBehParams >> 24) + 1
                    if ((star > 0 and star < 8) or ROMHACK.isUnder) and didRadar[star] == nil then
                        if gGlobalSyncTable.mhMode ~= 2 then
                            local file = get_current_save_file_num() - 1
                            local course_star_flags = save_file_get_star_flags(file, gNetworkPlayers[0].currCourseNum - 1)

                            if course_star_flags & (1 << (star - 1)) == 0 then
                                if star_radar[star] == nil then
                                    star_radar[star] = {tex = TEX_STAR, prevX = 0, prevY = 0, prevScale = 0.6}
                                end
                                render_radar(o, star_radar[star], true)
                                didRadar[star] = 1
                            end
                        elseif star == gGlobalSyncTable.getStar then
                            if star_radar[star] == nil then
                                star_radar[star] = {tex = TEX_STAR, prevX = 0, prevY = 0, prevScale = 0.6}
                            end
                            render_radar(o, star_radar[star], true)
                            didRadar[star] = 1

                            if o.unused1 ~= 5 then
                            obj_set_model_extended(o, E_MODEL_STAR)
                            o.unused1 = o.unused1 + 1 -- using this as a flag
                            end
                        elseif o.unused1 ~= 5 then
                            obj_set_model_extended(o, E_MODEL_TRANSPARENT_STAR)
                            o.unused1 = o.unused1 + 1 -- using this as a flag
                        end
                    end
                end
                o = obj_get_next_with_same_behavior_id(o)
            end
        end
    end
end

-- Fix the water ring hitbox (Isaac)
hook_behavior_custom(id_bhvMantaRayWaterRing, false, function(o)
    o.oWaterRingScalePhaseX = (random_u16() & 0xFFF) + 0x1000
    o.oWaterRingScalePhaseY = (random_u16() & 0xFFF) + 0x1000
    o.oWaterRingScalePhaseZ = (random_u16() & 0xFFF) + 0x1000
    local dest = vec3f_rotate_zxy({ x = 0, y = 1, z = 0 },
        {x = o.oFaceAnglePitch,
        y = o.oFaceAngleYaw,
        z = o.oFaceAngleRoll}
    )
    o.oWaterRingNormalX = dest.x
    o.oWaterRingNormalY = dest.y
    o.oWaterRingNormalZ = dest.z
end, nil)

-- Skip snowman dialog (Isaac)
hook_behavior_custom(id_bhvSnowmansBottom, false, nil, function(o)
    if o.oAction == 0 and m0.action == ACT_READING_NPC_DIALOG and is_point_within_radius_of_mario(o.oPosX, o.oPosY, o.oPosZ, 400) then
        o.oForwardVel = 10
        o.oAction = 1
        set_mario_action(m0, m0.heldObj == nil and ACT_IDLE or ACT_HOLD_IDLE, 0)
        if (o.coopFlags & COOP_OBJ_FLAG_NON_SYNC) == 0 then network_send_object(o, true) end
    end
end)
