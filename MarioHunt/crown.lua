-- does the crown, which is rewarded for ASN semi-finalists and onwards
local alreadySpawnedCrown = {}

E_MODEL_CROWN = mod_file_exists("actors/crown_geo.bin") and smlua_model_util_get_id("crown_geo")
GOLD_CROWN_HUD = get_texture_info("gcrown_hud")
SILVER_CROWN_HUD = get_texture_info("scrown_hud")
BRONZE_CROWN_HUD = get_texture_info("bcrown")

---@param o Object
function crown_init(o)
    o.oFlags = o.oFlags | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    cur_obj_disable_rendering()
end

local stored_mat4 = {}
---@param o Object
function crown_loop(o)
    if o.oBehParams <= 0 or o.oBehParams > MAX_PLAYERS then return end
    ---@type MarioState
    local m = gMarioStates[o.oBehParams - 1]
    if is_player_active(m) == 0 or not (gPlayerSyncTable[m.playerIndex].role and gPlayerSyncTable[m.playerIndex].role & 128 ~= 0) then
        obj_mark_for_deletion(o)
        alreadySpawnedCrown[o.oBehParams] = nil
        return
    end

    -- hook to head; hookprocess value is based on which player
    do_for_mario_head(m.marioObj.header.gfx.sharedChild, function(graphNode)
        graphNode.hookProcess = 0xEA
    end)

    local oGFX = o.header.gfx
    local mGFX = m.marioObj.header.gfx
    o.oOpacity = 255
    if (m.marioBodyState.modelState & MODEL_STATE_NOISE_ALPHA) ~= 0 then
        o.oOpacity = 128
    end
    oGFX.node.flags = mGFX.node.flags

    if get_active_sabo() == 3 then -- hide during darkness
        cur_obj_disable_rendering()
    elseif m.playerIndex ~= 0 and (m.marioBodyState.updateHeadPosTime < get_global_timer() - 2) then -- disable rendering if not on screen
        cur_obj_disable_rendering()
    end
    o.hookRender = 1
end

-- Place crown
function on_obj_render(o)
    if LITE_MODE then return end
    if obj_has_behavior_id(o, id_bhvMHCrown) == 0 then return end
    if o.oBehParams <= 0 or o.oBehParams > MAX_PLAYERS then return end
    local m = gMarioStates[o.oBehParams-1]
    if not (m and m.marioObj) then return end
    if not stored_mat4[o.oBehParams] then return end
    local mat4 = stored_mat4[o.oBehParams]
    local mGFX = m.marioObj.header.gfx
    local oGFX = o.header.gfx
    oGFX.angle.x = -radians_to_sm64(math.asin(mat4.m21) * 4)
    oGFX.angle.z = -radians_to_sm64(math.atan(-mat4.m01, mat4.m11)) - 0x4000
    oGFX.angle.y = radians_to_sm64(-math.atan(-mat4.m20, mat4.m22))
    oGFX.angle.z = oGFX.angle.z - 1200

    if m.action == ACT_FIRST_PERSON then
        -- don't ask me why they're swapped
        oGFX.angle.x = oGFX.angle.x + m.statusForCamera.headRotation.z
        oGFX.angle.y = oGFX.angle.y + m.statusForCamera.headRotation.y
        oGFX.angle.z = oGFX.angle.z + m.statusForCamera.headRotation.x
    elseif (m.action & ACT_FLAG_WATER_OR_TEXT ~= 0 or m.marioBodyState.allowPartRotation ~= 0) then
        oGFX.angle.x = oGFX.angle.x + m.marioBodyState.headAngle.z
        oGFX.angle.y = oGFX.angle.y + m.marioBodyState.headAngle.y
        oGFX.angle.z = oGFX.angle.z + m.marioBodyState.headAngle.x
    end

    oGFX.scale.y = mGFX.scale.y
    if oGFX.scale.y <= 0 then oGFX.scale.y = 0.01 end
    
    local upBy = 45 * oGFX.scale.y
    local pitch, yaw, roll = oGFX.angle.x, oGFX.angle.y, oGFX.angle.z
    oGFX.pos.x = mat4.m30 + upBy * (sins(yaw) * sins(pitch) * coss(roll) - coss(yaw) * sins(roll))
    oGFX.pos.y = mat4.m31 + upBy * (coss(pitch) * coss(roll))
    oGFX.pos.z = mat4.m32 + upBy * (coss(yaw) * sins(pitch) * coss(roll) + sins(yaw) * sins(roll))
    
    o.oPosX = oGFX.pos.x
    o.oPosY = oGFX.pos.y
    o.oPosZ = oGFX.pos.z
    o.oFaceAnglePitch = oGFX.angle.x
    o.oFaceAngleYaw = oGFX.angle.y
    o.oFaceAngleRoll = oGFX.angle.z
end

-- This functions calculates where the crown should be placed
---@param graphNode GraphNode
function on_geo_process(graphNode, matStackIndex)
    if LITE_MODE then return end
    if graphNode.hookProcess ~= 0xEA then return end
    local m = geo_get_mario_state()
    if m.marioBodyState.mirrorMario then return end
    local camera = gMarioStates[0].area.camera.mtx
    local mat4 = gMat4Zero()
    local camInv = gMat4Zero()
    mtxf_inverse(camInv, camera)
    mtxf_mul(mat4, gMatStack[matStackIndex], camInv)
    stored_mat4[m.playerIndex + 1] = mat4
    --graphNode.hookProcess = 0
end

---@param graphNode GraphNode
function do_for_mario_head(graphNode, func)
    local stopNode = graphNode
    while graphNode do
        -- head is identified by a rotation node, followed by two animated parts
        if graphNode.type == GRAPH_NODE_TYPE_ROTATION then
            if graphNode.children and graphNode.children.type == GRAPH_NODE_TYPE_ANIMATED_PART then
                local checkNode = graphNode.children.children
                if checkNode and checkNode.type == GRAPH_NODE_TYPE_DISPLAY_LIST then
                    -- required for CS characters that wear something around their neck, like a scarf
                    checkNode = checkNode.next
                end
                if checkNode and checkNode.type == GRAPH_NODE_TYPE_ANIMATED_PART then
                    func(checkNode)
                    return
                end
            end
        end
        
        if graphNode.children then
            do_for_mario_head(graphNode.children, func)
        end
        graphNode = graphNode.next
        if graphNode == stopNode then break end
    end
end

id_bhvMHCrown = hook_behavior(nil, OBJ_LIST_DEFAULT, true, crown_init, crown_loop)

function get_crown_anim_state(i)
    if LITE_MODE then return end
    local vIndex = i
    if disguiseMod then
        vIndex = network_local_index_from_global(disguiseMod.getDisguisedIndex(network_global_index_from_local(i)))
    end
    if gPlayerSyncTable[vIndex].role and gPlayerSyncTable[vIndex].role & 128 ~= 0 and gPlayerSyncTable[vIndex].placementASN and gPlayerSyncTable[vIndex].placementASN <= 3 then
        if gPlayerSyncTable[vIndex].placementASN == 1 then
            return 0
        elseif gPlayerSyncTable[vIndex].placementASN == 2 then
            return 1
        else
            return 2
        end
    end
end

function get_crown_tex(i)
    local vIndex = i
    if disguiseMod then
        vIndex = network_local_index_from_global(disguiseMod.getDisguisedIndex(network_global_index_from_local(i)))
    end
    if gPlayerSyncTable[vIndex].role and gPlayerSyncTable[vIndex].role & 128 ~= 0 and gPlayerSyncTable[vIndex].placementASN and gPlayerSyncTable[vIndex].placementASN <= 3 then
        if gPlayerSyncTable[vIndex].placementASN == 1 then
            return GOLD_CROWN_HUD
        elseif gPlayerSyncTable[vIndex].placementASN == 2 then
            return SILVER_CROWN_HUD
        end
        return BRONZE_CROWN_HUD
    end
end

function spawn_new_crowns()
    --gPlayerSyncTable[0].role = gPlayerSyncTable[0].role | 64
    --gPlayerSyncTable[0].placementASN = 2
    if LITE_MODE then return end
    for i = 0, MAX_PLAYERS - 1 do
        local m = gMarioStates[i]
        local crownAnimState = get_crown_anim_state(i)

        if (not alreadySpawnedCrown[i + 1]) and is_player_active(m) ~= 0 and crownAnimState then
            local o = obj_get_first_with_behavior_id_and_field_f32(id_bhvMHCrown, 0x40, i + 1) -- oBehParams
            if not o then
                o = spawn_non_sync_object(id_bhvMHCrown, E_MODEL_CROWN, m.pos.x, m.pos.y, m.pos.z, nil)
                o.oBehParams = i + 1
                o.oAnimState = crownAnimState
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
hook_event(HOOK_ON_GEO_PROCESS, on_geo_process)

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
