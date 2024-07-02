-- does the crown, which is rewarded for ASN semi-finalists and onwards
local alreadySpawnedCrown = {}
local crownYPos = {}
local crownYOffset = {}

---@param o Object
function crown_init(o)
    o.oFlags = o.oFlags | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    cur_obj_disable_rendering()
end

---@param o Object
function crown_loop(o)
    if o.oBehParams == 0 then return end
    ---@type MarioState
    local m = gMarioStates[o.oBehParams - 1]
    if is_player_active(m) == 0 or not (gPlayerSyncTable[m.playerIndex].role and gPlayerSyncTable[m.playerIndex].role & 64 ~= 0) then
        obj_mark_for_deletion(o)
        alreadySpawnedCrown[o.oBehParams] = nil
        return
    end

    local oGFX = o.header.gfx
    local mGFX = m.marioObj.header.gfx
    o.oOpacity = 255
    o.oAnimState = 0
    if (m.marioBodyState.modelState & MODEL_STATE_NOISE_ALPHA) ~= 0 then
        o.oOpacity = 128
        o.oAnimState = 1
    end
    oGFX.node.flags = mGFX.node.flags
    o.hookRender = 1
end

-- This functions calculates where the crown should be placed
-- TODO: breaks with mirror mario
-- Try the "get angle from torso to head" method
function on_obj_render(o)
    if LITE_MODE then return end
    if get_behavior_from_id(id_bhvMario) == o.behavior then -- TODO: this line used to cause inconsistent crashes for some players, notably not me. Does it still? If it does, I can always remove this code for the tourney b/c its not actually doing anything right now
        local m = gMarioStates[o.oBehParams - 1]
        if not crownYPos[m.playerIndex] then return end
        crownYOffset[m.playerIndex] = math.floor(crownYPos[m.playerIndex] - m.marioBodyState.headPos.y)
        return
    end
    if get_behavior_from_id(id_bhvMHCrown) ~= o.behavior then return end
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
        local mHeadAngle = {x = m.faceAngle.x, y = m.faceAngle.y, z = m.faceAngle.z}
        if m.action & ACT_FLAG_WATER_OR_TEXT ~= 0 and mHeadAngle.x > 0 then
            mHeadAngle.x = mHeadAngle.x * 0.4
        end
        mHeadPos.y = mHeadPos.y + upBy * coss(mHeadAngle.x) * coss(mHeadAngle.z)

        mHeadPos.x = mHeadPos.x - upBy * sins(mHeadAngle.y) * sins(mHeadAngle.x) - upBy * coss(-mHeadAngle.y) * sins(mHeadAngle.z)    
        mHeadPos.z = mHeadPos.z - upBy * coss(mHeadAngle.y) * sins(mHeadAngle.x) - upBy * sins(-mHeadAngle.y) * sins(mHeadAngle.z)
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
        local angleDiff = abs_angle_diff(yaw,  m.marioObj.header.gfx.angle.y)
        if angleDiff >= 0x4000 then
            oGFX.angle.x = -oGFX.angle.x
        end
        if m.action == ACT_SIDE_FLIP then
            oGFX.angle.z = -pitch * sins(m.marioObj.header.gfx.angle.y - yaw)
        end

        oGFX.pos.x = oGFX.pos.x + upBy * sins(oGFX.angle.y) * sins(oGFX.angle.x) - upBy * coss(-oGFX.angle.y) * sins(oGFX.angle.z)
        oGFX.pos.y = oGFX.pos.y + upBy * coss(oGFX.angle.x) * coss(oGFX.angle.z)
        oGFX.pos.z = oGFX.pos.z + upBy * coss(oGFX.angle.y) * sins(oGFX.angle.x) - upBy* sins(-oGFX.angle.y) * sins(oGFX.angle.z)
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
    oGFX.shadowInvisible = true
    o.oPosX = oGFX.pos.x
    o.oPosY = oGFX.pos.y
    o.oPosZ = oGFX.pos.z
    o.oFaceAnglePitch = oGFX.angle.x
    o.oFaceAngleYaw = oGFX.angle.y
    o.oFaceAngleRoll = oGFX.angle.z
end

id_bhvMHCrown = hook_behavior(nil, OBJ_LIST_DEFAULT, true, crown_init, crown_loop)

function get_crown(i)
    if gPlayerSyncTable[i].role and gPlayerSyncTable[i].role & 64 ~= 0 and gPlayerSyncTable[i].placementASN and gPlayerSyncTable[i].placementASN <= 3 then
        return E_MODEL_TOADS_METAL_CAP
    end
end

function spawn_new_crowns()
    --gPlayerSyncTable[0].role = gPlayerSyncTable[0].role | 64
    --gPlayerSyncTable[0].placementASN = 2
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
