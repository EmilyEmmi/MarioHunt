-- does the crown, which is rewarded for ASN semi-finalists and onwards (and winners of Mo3)
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
    if is_player_active(m) == 0 then
        obj_mark_for_deletion(o)
        if alreadySpawnedCrown[o.oBehParams] and alreadySpawnedCrown[o.oBehParams] ~= 0 then
            alreadySpawnedCrown[o.oBehParams] = alreadySpawnedCrown[o.oBehParams] - 1
        end
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
    oGFX.angle.x = radians_to_sm64(math.atan(mat4.m01, mat4.m11)) - 0x4000
    oGFX.angle.y = radians_to_sm64(math.atan(mat4.m20, mat4.m22)) - 0x4000
    oGFX.angle.z = -radians_to_sm64(math.asin(-mat4.m21) * 4)

    --[[local butt = {x = 0, y = 0, z = 0}
    local torso = {x = 0, y = 0, z = 0}
    local head = {x = 0, y = 0, z = 0}
    get_mario_anim_part_rot(m, MARIO_ANIM_PART_BUTT, butt)
    get_mario_anim_part_rot(m, MARIO_ANIM_PART_TORSO, torso)
    get_mario_anim_part_rot(m, MARIO_ANIM_PART_HEAD, head)
    vec3f_zero(oGFX.angle)
    vec3f_add(oGFX.angle, butt)
    vec3f_add(oGFX.angle, torso)
    vec3f_add(oGFX.angle, head)
    oGFX.angle.x = oGFX.angle.x - 0x4000
    oGFX.angle.y = oGFX.angle.y + m.faceAngle.y]]
    --djui_chat_message_create(tostring(oGFX.angle.x)..", "..tostring(oGFX.angle.y)..", "..tostring(oGFX.angle.z))

    if m.action == ACT_FIRST_PERSON then
        oGFX.angle.x = oGFX.angle.x + m.statusForCamera.headRotation.x
        oGFX.angle.y = oGFX.angle.y + m.statusForCamera.headRotation.y
        oGFX.angle.z = oGFX.angle.z + m.statusForCamera.headRotation.z
    elseif (m.action & ACT_FLAG_WATER_OR_TEXT ~= 0 or m.marioBodyState.allowPartRotation ~= 0) then
        oGFX.angle.x = oGFX.angle.x + m.marioBodyState.headAngle.x
        oGFX.angle.y = oGFX.angle.y + m.marioBodyState.headAngle.y
        oGFX.angle.z = oGFX.angle.z + m.marioBodyState.headAngle.z
    end

    oGFX.scale.y = mGFX.scale.y
    if oGFX.scale.y <= 0 then oGFX.scale.y = 0.01 end

    get_mario_anim_part_pos(m, MARIO_ANIM_PART_HEAD, oGFX.pos)
    --oGFX.pos.x, oGFX.pos.y, oGFX.pos.z = mat4.m30, mat4.m31, mat4.m32
    local upBy = (45 + 20 * o.oBehParams2ndByte) * oGFX.scale.y
    local upVector = {x = 0, y = upBy, z = 0}
    vec3f_rotate_zxy(upVector, oGFX.angle)
    oGFX.pos.x = oGFX.pos.x + upVector.x
    oGFX.pos.y = oGFX.pos.y + upVector.y
    oGFX.pos.z = oGFX.pos.z + upVector.z
    oGFX.angle.x = oGFX.angle.x - 1200

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

id_bhvMHCrown = hook_behavior(nil, OBJ_LIST_DEFAULT, true, crown_init, crown_loop, "id_bhvMHCrown")

function get_all_crowns(i)
    local crowns = {}
    local vIndex = i
    if disguiseMod then
        vIndex = network_local_index_from_global(disguiseMod.getDisguisedIndex(network_global_index_from_local(i)))
    end

    local checkField = {"placementASN", "placementMo3"}
    local checkRole = {ROLE_CROWN_ASN, ROLE_CROWN_MO3}
    for i, field in ipairs(checkField) do
        local role = checkRole[i]
        if gPlayerSyncTable[vIndex].role & role ~= 0 and gPlayerSyncTable[vIndex][field] <= 3 then
            table.insert(crowns, gPlayerSyncTable[vIndex][field])
        end
    end
    table.sort(crowns) -- put gold ahead of silver, etc.
    return crowns
end

-- Note: This is reversed so that the better crowns are at the end
function get_all_crown_textures(i)
    local crowns = get_all_crowns(i)
    local ctex = {}
    if #crowns ~= 0 then
        for a=#crowns,1,-1 do
            local crownNum = crowns[a]
            if crownNum == 1 then
                table.insert(ctex, GOLD_CROWN_HUD)
            elseif crownNum == 2 then
                table.insert(ctex, SILVER_CROWN_HUD)
            else
                table.insert(ctex, BRONZE_CROWN_HUD)
            end
        end
    end
    return ctex
end

function spawn_new_crowns()
    --gPlayerSyncTable[0].role = gPlayerSyncTable[0].role | ROLE_CROWN_MO3
    --gPlayerSyncTable[0].placementMo3 = 2
    if LITE_MODE or get_global_timer() % 5 ~= 0 then return end -- Don't do this every frame
    for i = 0, MAX_PLAYERS - 1 do
        local m = gMarioStates[i]
        local crowns = get_all_crowns(i)

        if alreadySpawnedCrown[i + 1] == nil then alreadySpawnedCrown[i + 1] = 0 end
        if is_player_active(m) ~= 0 and alreadySpawnedCrown[i + 1] ~= #crowns then
            alreadySpawnedCrown[i + 1] = #crowns
            local o = obj_get_first_with_behavior_id_and_field_s32(id_bhvMHCrown, 0x40, i + 1) -- oBehParams
            while o do
                local prevObj = o
                o = obj_get_next_with_same_behavior_id_and_field_s32(o, 0x40, i + 1) -- oBehParams
                obj_mark_for_deletion(prevObj)
            end

            for a, crownNum in ipairs(crowns) do
                o = spawn_non_sync_object(id_bhvMHCrown, E_MODEL_CROWN, m.pos.x, m.pos.y, m.pos.z, nil)
                o.oBehParams = i + 1
                o.oBehParams2ndByte = #crowns - a
                o.oAnimState = crownNum - 1
                o.globalPlayerIndex = network_global_index_from_local(i)
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
