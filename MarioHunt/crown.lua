-- does the crown, which is rewarded for ASN semi-finalists and onwards
local alreadySpawnedCrown = {}

E_MODEL_GOLD_CROWN = (not LITE_MODE) and smlua_model_util_get_id("gcrown_geo")
E_MODEL_SILVER_CROWN = (not LITE_MODE) and smlua_model_util_get_id("scrown_geo")
E_MODEL_BRONZE_CROWN = (not LITE_MODE) and smlua_model_util_get_id("bcrown_geo")

---@param o Object
function crown_init(o)
    o.oFlags = o.oFlags | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.oTimer = gMarioStates[0].marioBodyState.updateTorsoTime + 1
    cur_obj_disable_rendering()
end

---@param o Object
function crown_loop(o)
    if o.oBehParams == 0 then return end
    ---@type MarioState
    local m = gMarioStates[o.oBehParams - 1]
    if is_player_active(m) == 0 or not (gPlayerSyncTable[m.playerIndex].role and gPlayerSyncTable[m.playerIndex].role & 128 ~= 0) then
        obj_mark_for_deletion(o)
        alreadySpawnedCrown[o.oBehParams] = nil
        return
    end

    local oGFX = o.header.gfx
    local mGFX = m.marioObj.header.gfx
    o.oOpacity = 255
    o.oAnimState = 1
    if (m.marioBodyState.modelState & MODEL_STATE_NOISE_ALPHA) ~= 0 then
        o.oOpacity = 128
        o.oAnimState = 1
    end
    oGFX.node.flags = mGFX.node.flags

    if get_active_sabo() == 3 then -- hide during darkness
        cur_obj_disable_rendering()
    elseif m.playerIndex ~= 0 then
        -- check if on screen
        local pos = { x = m.pos.x, y = m.pos.y, z = m.pos.z }
        local out = { x = 0, y = 0, z = 0 }
        local screenWidth = djui_hud_get_screen_width()
        local screenHeight = djui_hud_get_screen_height()
        djui_hud_world_pos_to_screen_pos(pos, out)

        if (o.oTimer > m.marioBodyState.updateTorsoTime + 1) or out.z > -400 or out.x > screenWidth + 100 or out.x < -100 or out.y > screenHeight + 100 or out.y < -100 then
            o.oTimer = m.marioBodyState.updateTorsoTime + 1
            cur_obj_disable_rendering()
        end
    end
    o.hookRender = 1
end

-- This functions calculates where the crown should be placed
function on_obj_render(o)
    if LITE_MODE then return end
    if obj_has_behavior_id(o, id_bhvMHCrown) == 0 then return end
    if o.oBehParams == 0 then return end
    ---@type MarioState
    local m = gMarioStates[o.oBehParams - 1]
    local oGFX = o.header.gfx
    local mGFX = m.marioObj.header.gfx
    vec3f_copy(oGFX.scale, mGFX.scale)
    if mGFX.scale.y < 0.1 then
        vec3f_copy(oGFX.pos, mGFX.pos)
        oGFX.pos.y = oGFX.pos.y + 10
        vec3s_copy(oGFX.angle, mGFX.angle)
        return
    end

    local upBy = 40
    local mHeadPos = { x = m.marioBodyState.headPos.x, y = m.marioBodyState.headPos.y, z = m.marioBodyState.headPos.z }
    if (m.marioBodyState.capState & MARIO_HAS_DEFAULT_CAP_OFF) ~= 0 then
        upBy = upBy - 10
    end
    if (m.action & (ACT_FLAG_SWIMMING_OR_FLYING | ACT_FLAG_DIVING) ~= 0) and m.action & ACT_FLAG_INVULNERABLE == 0 then
        local mHeadAngle = { x = m.faceAngle.x, y = m.faceAngle.y, z = m.faceAngle.z }
        if m.action & ACT_FLAG_WATER_OR_TEXT ~= 0 and mHeadAngle.x > 0 then
            mHeadAngle.x = mHeadAngle.x * 0.4
        end
        mHeadPos.y = mHeadPos.y + upBy * coss(mHeadAngle.x) * coss(mHeadAngle.z)

        mHeadPos.x = mHeadPos.x - upBy * sins(mHeadAngle.y) * sins(mHeadAngle.x) -
        upBy * coss(-mHeadAngle.y) * sins(mHeadAngle.z)
        mHeadPos.z = mHeadPos.z - upBy * coss(mHeadAngle.y) * sins(mHeadAngle.x) -
        upBy * sins(-mHeadAngle.y) * sins(mHeadAngle.z)
        upBy = 0
    elseif (m.action & (ACT_FLAG_AIR | ACT_FLAG_SWIMMING_OR_FLYING) == 0) then
        upBy = upBy - 20
        mHeadPos.y = mHeadPos.y + 20 * mGFX.scale.y
    end
    vec3f_copy(oGFX.pos, mHeadPos)

    if upBy ~= 0 then
        local mTorsoPos = m.marioBodyState.torsoPos
        local dist, pitch, yaw = vec3f_get_dist_and_angle_lua(mTorsoPos, mHeadPos)
        pitch = -pitch + 0x4000

        oGFX.angle.x = pitch
        oGFX.angle.y = m.marioObj.header.gfx.angle.y
        oGFX.angle.z = m.marioBodyState.torsoAngle.z
        local angleDiff = abs_angle_diff(yaw, m.marioObj.header.gfx.angle.y)
        if angleDiff >= 0x4000 then
            oGFX.angle.x = -oGFX.angle.x
        end
        if m.action == ACT_SIDE_FLIP then
            oGFX.angle.z = -pitch * sins(m.marioObj.header.gfx.angle.y - yaw)
        end

        oGFX.pos.x = oGFX.pos.x + upBy * sins(oGFX.angle.y) * sins(oGFX.angle.x) -
        upBy * coss(-oGFX.angle.y) * sins(oGFX.angle.z)
        oGFX.pos.y = oGFX.pos.y + upBy * coss(oGFX.angle.x) * coss(oGFX.angle.z)
        oGFX.pos.z = oGFX.pos.z + upBy * coss(oGFX.angle.y) * sins(oGFX.angle.x) -
        upBy * sins(-oGFX.angle.y) * sins(oGFX.angle.z)
        oGFX.angle.x = oGFX.angle.x - 0x1000
    else
        oGFX.angle.x = -m.faceAngle.x
        oGFX.angle.y = m.faceAngle.y
        oGFX.angle.z = m.faceAngle.z
    end

    --djui_chat_message_create(tostring(abs_angle_diff(yaw, m.faceAngle.y))..tostring(abs_angle_diff(yaw, m.faceAngle.y) > 0x6000))
    --[[oGFX.areaIndex = mGFX.areaIndex
    vec3s_copy(oGFX.angle, mGFX.angle);
    vec3f_copy(oGFX.pos, mGFX.pos);
    vec3f_copy(oGFX.scale, mGFX.scale);
    oGFX.animInfo.animAccel = mGFX.animInfo.animAccel
    oGFX.animInfo.animFrame = mGFX.animInfo.animFrame
    oGFX.animInfo.animFrameAccelAssist = mGFX.animInfo.animFrameAccelAssist
    oGFX.animInfo.animID = mGFX.animInfo.animID
    oGFX.animInfo.animTimer = mGFX.animInfo.animTimer
    oGFX.animInfo.animYTrans = mGFX.animInfo.animYTrans
    oGFX.animInfo.curAnim = mGFX.animInfo.curAnim
    oGFX.animInfo.prevAnimFrame = mGFX.animInfo.prevAnimFrame
    oGFX.animInfo.prevAnimFrameTimestamp = mGFX.animInfo.prevAnimFrameTimestamp
    oGFX.animInfo.prevAnimID = mGFX.animInfo.prevAnimID
    oGFX.animInfo.prevAnimPtr = mGFX.animInfo.prevAnimPtr
    oGFX.sharedChild.flags = mGFX.sharedChild.flags
    oGFX.sharedChild.extraFlags = mGFX.sharedChild.extraFlags]]
    o.oPosX = oGFX.pos.x
    o.oPosY = oGFX.pos.y
    o.oPosZ = oGFX.pos.z
    o.oFaceAnglePitch = oGFX.angle.x
    o.oFaceAngleYaw = oGFX.angle.y
    o.oFaceAngleRoll = oGFX.angle.z
end

id_bhvMHCrown = hook_behavior(nil, OBJ_LIST_DEFAULT, true, crown_init, crown_loop)

function get_crown(i)
    if LITE_MODE then return end
    local vIndex = i
    if disguiseMod then
        vIndex = network_local_index_from_global(disguiseMod.getDisguisedIndex(network_global_index_from_local(i)))
    end
    if gPlayerSyncTable[vIndex].role and gPlayerSyncTable[vIndex].role & 128 ~= 0 and gPlayerSyncTable[vIndex].placementASN and gPlayerSyncTable[vIndex].placementASN <= 3 then
        if gPlayerSyncTable[vIndex].placementASN == 1 then
            return E_MODEL_GOLD_CROWN
        elseif gPlayerSyncTable[vIndex].placementASN == 2 then
            return E_MODEL_SILVER_CROWN
        else
            return E_MODEL_BRONZE_CROWN
        end
    end
end

function get_crown_tex(i)
    if gPlayerSyncTable[i].role and gPlayerSyncTable[i].role & 128 ~= 0 and gPlayerSyncTable[i].placementASN and gPlayerSyncTable[i].placementASN <= 3 then
        if gPlayerSyncTable[i].placementASN == 1 then
            return GOLD_CROWN_HUD
        elseif gPlayerSyncTable[i].placementASN == 2 then
            return SILVER_CROWN_HUD
        end
        return BRONZE_CROWN_HUD
    end
end

function spawn_new_crowns()
    --gPlayerSyncTable[0].role = gPlayerSyncTable[0].role | 64
    --gPlayerSyncTable[0].placementASN = 1
    if LITE_MODE then return end
    for i = 0, MAX_PLAYERS - 1 do
        local m = gMarioStates[i]
        local crownModel = get_crown(i)

        if (not alreadySpawnedCrown[i + 1]) and is_player_active(m) ~= 0 and crownModel then
            local o = obj_get_first_with_behavior_id_and_field_f32(id_bhvMHCrown, 0x40, i + 1) -- oBehParams
            if not o then
                o = spawn_non_sync_object(id_bhvMHCrown, crownModel, m.pos.x, m.pos.y, m.pos.z, nil)
                o.oBehParams = i + 1
                o.globalPlayerIndex = network_global_index_from_local(i)
                alreadySpawnedCrown[i + 1] = 1
            end
        end
    end
end

function reset_spawned()
    alreadySpawnedCrown = {}
end

hook_event(HOOK_UPDATE, spawn_new_crowns)
hook_event(HOOK_ON_SYNC_VALID, reset_spawned)
hook_event(HOOK_ON_OBJECT_RENDER, on_obj_render)

-- gets distance, pitch, and yaw between two points
function vec3f_get_dist_and_angle_lua(from, to)
    local x = to.x - from.x
    local y = to.y - from.y
    local z = to.z - from.z

    dist = math.sqrt(x * x + y * y + z * z)
    pitch = atan2s(math.sqrt(x * x + z * z), y)
    yaw = atan2s(z, x)
    return dist, pitch, yaw
end
