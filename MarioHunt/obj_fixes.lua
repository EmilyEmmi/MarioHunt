--
-- Various object changes
--

local m0 = gMarioStates[0]
local np0 = gNetworkPlayers[0]

local function hook_behavior_custom(id, override, init, loop)
    hook_behavior(id,
        get_object_list_from_behavior(get_behavior_from_id(id)), -- Automatically get the correct object list
        override, init, loop,
        "bhvMhCustom" ..
        get_behavior_name_from_id(id):sub(4)                     -- Give the behavior a consistent behavior name (for example, bhvTreasureChestsJrb will become bhvMhCustomTreasureChestsJrb)
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
    elseif o.oAction == 2 and o.oTimer == 4 then -- disable dialog
        o.header.gfx.scale.y = 0.1
        o.oAction = 3
    end
end

hook_behavior_custom(id_bhvCapSwitch, false, nil, custom_switch_loop)

-- fix boo cage for free roam
local function custom_cage_boo_init(o)
    if gGlobalSyncTable.freeRoam and gMarioStates[0].numStars < 12 then
        local cage = spawn_non_sync_object(id_bhvBooCage, E_MODEL_HAUNTED_CAGE, o.oPosX, o.oPosY, o.oPosZ, nil)
        if cage then
            cage.oBehParams = o.oBehParams
            cage.oAction = BOO_CAGE_ACT_FALLING
        end
    end
end
hook_behavior_custom(id_bhvBooWithCage, false, custom_cage_boo_init)

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

-- instant/faster cutscene, or radar
function do_star_stuff(radar)
    local didRadar = {}
    if gGlobalSyncTable.mhMode ~= 2 or gNetworkPlayers[0].currLevelNum == gGlobalSyncTable.gameLevel then
        for id, bhvName in pairs(star_ids) do
            local o = obj_get_first_with_behavior_id(id)
            while o do
                if not o.unused1 then o.unused1 = 0 end

                if id == id_bhvSpawnedStar or id == id_bhvSpawnedStarNoLevelExit then
                    if o.oAction == 0 then
                        o.oPosX, o.oPosY, o.oPosZ = o.oHomeX, o.oHomeY, o.oHomeZ
                        o.oVelX, o.oVelY, o.oVelZ = 0, 0, 0
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
                
                if radar and (o.header.gfx.node.flags & GRAPH_RENDER_ACTIVE ~= 0 or (o.oRoom ~= -1 and current_mario_room_check(o.oRoom) == 0)) then
                    local star = (o.oBehParams >> 24) + 1
                    if ((star > 0 and star < 8) or ROMHACK.isUnder) and not didRadar[star] then
                        if gGlobalSyncTable.mhMode ~= 2 then
                            local file = get_current_save_file_num() - 1
                            local course_star_flags = save_file_get_star_flags(file, gNetworkPlayers[0].currCourseNum - 1)

                            if course_star_flags & (1 << (star - 1)) == 0 then
                                if not star_radar[star] then
                                    star_radar[star] = { tex = TEX_STAR, prevX = 0, prevY = 0, prevScale = 0.6 }
                                    star_minimap[star] = { tex = gTextures.star, prevX = 0, prevY = 0 }
                                end
                                render_radar(o, star_radar[star], star_minimap[star], true)
                                didRadar[star] = 1
                            end
                        elseif star == gGlobalSyncTable.getStar then
                            if not star_radar[star] then
                                star_radar[star] = { tex = TEX_STAR, prevX = 0, prevY = 0, prevScale = 0.6 }
                                star_minimap[star] = { tex = gTextures.star, prevX = 0, prevY = 0 }
                            end
                            render_radar(o, star_radar[star], star_minimap[star], true)
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

-- Skip snowman dialog (Isaac)
hook_behavior_custom(id_bhvSnowmansBottom, false, nil, function(o)
    if o.oAction == 0 and m0.action == ACT_READING_NPC_DIALOG and is_point_within_radius_of_mario(o.oPosX, o.oPosY, o.oPosZ, 400) then
        o.oForwardVel = 10
        o.oAction = 1
        set_mario_action(m0, not m0.heldObj and ACT_IDLE or ACT_HOLD_IDLE, 0)
        if (o.coopFlags & COOP_OBJ_FLAG_NON_SYNC) == 0 then network_send_object(o, true) end
    end
end)

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

local MODEL_WALUIGI = 0xEC                   -- waluigi_geo
local MODEL_WALUIGIS_CAP = 0xED              -- waluigis_cap_geo
local MODEL_WALUIGIS_METAL_CAP = 0xEE        -- waluigis_metal_cap_geo
local MODEL_WALUIGIS_WING_CAP = 0xEF         -- waluigis_wing_cap_geo
local MODEL_WALUIGIS_WINGED_METAL_CAP = 0xF0 -- waluigis_winged_metal_cap_geo

local MODEL_WARIO = 0xF1                     -- wario_geo
local MODEL_WARIOS_CAP = 0xF2                -- warios_cap_geo
local MODEL_WARIOS_METAL_CAP = 0xF3          -- warios_metal_cap_geo
local MODEL_WARIOS_WING_CAP = 0xF4           -- warios_wing_cap_geo
local MODEL_WARIOS_WINGED_METAL_CAP = 0xF5   -- warios_winged_metal_cap_geo

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

local E_MODEL_CAKE = E_MODEL_BUBBLE_PLAYER-- cake model does not exist yet --((not LITE_MODE) and smlua_model_util_get_id("cake_geo"))

local sBehavior = get_behavior_from_id(id_bhvHiddenStarTrigger)
function on_obj_set_model(o, model)
    if obj_has_model_extended(o, E_MODEL_NONE) and o.behavior == sBehavior then
        obj_set_model_extended(o, E_MODEL_PURPLE_MARBLE)
    end
    if LITE_MODE then return end

    if model == 0x7A and month == 14 then -- star model changes on anniversary
        obj_set_model_extended(o, E_MODEL_CAKE)
    elseif (runnerAppearance == 3 or hunterAppearance == 3) and OUTLINE_MODEL[model] then
        local np = network_player_from_global_index(o.globalPlayerIndex)
        if not np then return end
        local sMario = gPlayerSyncTable[np.localIndex]
        local modelIndex = 1
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

hook_event(HOOK_OBJECT_SET_MODEL, on_obj_set_model)