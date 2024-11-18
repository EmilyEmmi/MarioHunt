-- This file handles various MysteryHunt things, such as corpses, sabo objects, voice, player list, etc.
local stored_corpse_data = {}
local stored_sabo_obj_data = {}

-- shows the number of players (or corpses) in a course (not including self)
-- level and area only apply in b3313 (level also applies in some other scenarios)
-- act, if unset, allows for any act
-- used with radar
function get_player_and_corpse_count(course, level, area, act)
    local count = 0
    local isB3313 = (ROMHACK and ROMHACK.name == "B3313")
    local isHunter = gGlobalSyncTable.mhMode ~= 3 or (gPlayerSyncTable[0].team ~= 1 and (gGlobalSyncTable.anarchy ~= 3 or gPlayerSyncTable[0].spectator == 1)) -- if true, only show alive runners here

    for i = 1, MAX_PLAYERS - 1 do
        local np = gNetworkPlayers[i]
        local sMario = gPlayerSyncTable[i]
        if np.connected and sMario.spectator ~= 1 and (not sMario.dead) and np.currCourseNum == course and (act == nil or np.currActNum == act) then
            local valid = true
            if isB3313 and (level ~= np.currLevelNum or area ~= np.currAreaIndex) then
                valid = false
            elseif (level == LEVEL_BOWSER_1 or level == LEVEL_BOWSER_2 or level == LEVEL_BOWSER_3) and level ~= np.currLevelNum then
                valid = false
            elseif isHunter and sMario.team ~= 1 then
                valid = false
            end
            if valid then
                count = count + 1
            end
        end
    end
    if not isHunter then
        for gIndex, data in pairs(stored_corpse_data) do
            local index = network_local_index_from_global(gIndex)
            if index ~= 255 then
                local sMario = gPlayerSyncTable[index]
                if sMario.knownDead == false and sMario.spectator == 1 and data.course == course and (act == nil or data.act == act) then
                    local valid = true
                    if isB3313 and (level ~= data.level or area ~= data.area) then
                        valid = false
                    elseif (level == LEVEL_BOWSER_1 or level == LEVEL_BOWSER_2 or level == LEVEL_BOWSER_3) and level ~= data.level then
                        valid = false
                    end
                    if valid then
                        count = count + 1
                    end
                end
            end
        end
    end
    return count, isHunter
end

function on_character_sound(m, charSound)
    if gGlobalSyncTable.mhMode ~= 3 or m.playerIndex == 0 then return end
    return 0
end

hook_event(HOOK_CHARACTER_SOUND, on_character_sound)

function mystery_popup_off()
    return gGlobalSyncTable.mhMode == 3 and gPlayerSyncTable[0].spectator ~= 1 and gGlobalSyncTable.mhState ~= 0 and
        gGlobalSyncTable.mhState < 3
end

local player_model_table = {
    [CT_MARIO] = E_MODEL_MARIO,
    [CT_LUIGI] = E_MODEL_LUIGI,
    [CT_TOAD] = E_MODEL_TOAD_PLAYER,
    [CT_WALUIGI] = E_MODEL_WALUIGI,
    [CT_WARIO] = E_MODEL_WARIO,
}

-- spawns the local player's corpse object and sends a packet to other players (this way, they can leave the level and still find the corpse later)
function spawn_my_corpse()
    ---@type MarioState
    local m = gMarioStates[0]
    local sMario = gPlayerSyncTable[0]
    local np = gNetworkPlayers[0]
    local model = player_model_table[m.character.type] or E_MODEL_MARIO
    if charSelectExists then
        local charTable = charSelect.character_get_current_table()
        model = (charTable and charTable.model) or model
    end
    local pose = m.marioObj.header.gfx.animInfo.animID
    if pose == MARIO_ANIM_DROWNING_PART1 or pose == MARIO_ANIM_DROWNING_PART2 or pose == MARIO_ANIM_WATER_DYING then
        pose = MARIO_ANIM_DYING_ON_STOMACH
    elseif pose ~= MARIO_ANIM_DYING_ON_BACK and pose ~= MARIO_ANIM_DYING_ON_STOMACH and pose ~= MARIO_ANIM_SUFFOCATING and pose ~= MARIO_ANIM_DYING_FALL_OVER and pose ~= MARIO_ANIM_ELECTROCUTION then
        pose = MARIO_ANIM_DYING_ON_STOMACH
    end

    local corpseData = {
        id = PACKET_PERM_OBJ,
        obj_id = id_bhvMHCorpse,
        behParams = np.globalIndex + 1,
        x = math.floor(m.pos.x),
        y = math.floor(m.pos.y),
        z = math.floor(m.pos.z),
        yaw = m.faceAngle.y,
        extra = pose,
        model = model,
        course = np.currCourseNum,
        level = np.currLevelNum,
        area = np.currAreaIndex,
        act = np.currActNum
    }
    spawn_perm_obj(corpseData)
    sMario.knownDead = false
    if sMario.team == 1 then
        spectate_command("runner")
    else
        spectate_command("hunter")
    end
end

-- cause a sabotage; there are 3 types
function start_sabotage(type)
    if not sabo_valid() then return end
    gGlobalSyncTable.saboActive = type
    gGlobalSyncTable.saboTimer = 0
    local model = E_MODEL_WATER_MINE
    if type == 2 then
        model = E_MODEL_SNUFIT
    elseif type == 3 then
        model = E_MODEL_BOO
    end
    local m = gMarioStates[0]
    local np = gNetworkPlayers[0]
    local saboObjData = {
        id = PACKET_PERM_OBJ,
        obj_id = id_bhvSaboObj,
        behParams = type,
        x = math.floor(m.pos.x),
        y = math.floor(m.pos.y)+160,
        z = math.floor(m.pos.z),
        yaw = m.faceAngle.y,
        extra = 0,
        model = model,
        course = np.currCourseNum,
        level = np.currLevelNum,
        area = np.currAreaIndex,
        act = np.currActNum
    }
    spawn_perm_obj(saboObjData)
end

-- can do sabotage
function sabo_valid()
    return not (gGlobalSyncTable.saboActive ~= 0 or gGlobalSyncTable.saboTimer ~= 0 or gGlobalSyncTable.mhMode ~= 3 or (gGlobalSyncTable.mhState ~= 1 and gGlobalSyncTable.mhState ~= 2) or gPlayerSyncTable[0].team == 1 or gPlayerSyncTable[0].dead or gMarioStates[0].action & ACT_FLAG_AIR ~= 0 or (gMarioStates[0].floor and is_hazard_floor(gMarioStates[0].floor.type)))
end

-- get the active sabotage (not active for 10s)
function get_active_sabo()
    if (gGlobalSyncTable.mhMode == 3 and (gGlobalSyncTable.mhState == 1 or gGlobalSyncTable.mhState == 2) and gGlobalSyncTable.saboTimer >= 300) then
        return gGlobalSyncTable.saboActive
    end
    return 0
end

-- gets where the object is (as a string)
function get_sabo_location()
    if not stored_sabo_obj_data.level then return "INVALID" end
    local text = get_custom_level_name(stored_sabo_obj_data.course, stored_sabo_obj_data.level, stored_sabo_obj_data.area)
    if stored_sabo_obj_data.act ~= 0 then
        text = text .. " #" .. stored_sabo_obj_data.act
    end
    return text
end

-- used for both the sabotage objects or corpses
function spawn_perm_obj(data)
    network_send_include_self(true, data)
    local o = spawn_sync_object(data.obj_id, data.model, data.x, data.y, data.z, function(o)
        o.oBehParams = data.behParams
        o.globalPlayerIndex = data.behParams - 1
        o.oBobombBlinkTimer = data.extra
        o.oFaceAngleYaw = data.yaw
    end)
    if o then network_send_object(o, true) end
end

-- sent to other players when someone dies or a sabotage is started
function on_packet_perm_obj(data, self)
    if data.obj_id == id_bhvMHCorpse then
        stored_corpse_data[data.behParams-1] = data
    else
        stored_sabo_obj_data = data
    end
end

function on_packet_request_perm_objs(data, self)
    if #stored_corpse_data then
        for gIndex, data2 in pairs(stored_corpse_data) do
            network_send_to(data.gIndex, true, data2)
        end
    end
    if gGlobalSyncTable.saboActive ~= 0 and stored_sabo_obj_data.obj_id then
        network_send_to(data.gIndex, true, stored_sabo_obj_data)
    end
end

---@param o Object
function mh_corpse_init(o)
    o.oFlags = o.oFlags | (OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_COMPUTE_DIST_TO_MARIO)
    o.oOpacity = 255
    o.oWallHitboxRadius, o.oGravity, o.oBounciness, o.oDragStrength, o.oFriction, o.oBuoyancy = 40, -4, 0, 10, 10, 8
    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0
    do_pose(o)
    network_init_object(o, true, { 'oBobombBlinkTimer' })
end

---@param o Object
function mh_corpse_loop(o)
    local np = network_player_from_global_index(o.globalPlayerIndex)
    if not (np and np.connected) or gPlayerSyncTable[np.localIndex].spectator ~= 1 or gPlayerSyncTable[np.localIndex].knownDead then
        if o.oTimer > 30 and is_nearest_mario_state_to_object(gMarioStates[0], o) ~= 0 then
            obj_mark_for_deletion(o)
        end
        return
    end

    local m0 = gMarioStates[0]
    if gPlayerSyncTable[0].spectator ~= 1 and (m0.controller.buttonPressed & (A_BUTTON >> (reportButton - 1))) ~= 0 and dist_between_objects(m0.marioObj, o) < 200 then
        network_send_include_self(true, {
            id = PACKET_REPORT_BODY,
            reported = network_global_index_from_local(0),
            dead = o.globalPlayerIndex,
        })
        obj_mark_for_deletion(o)
        return
    end

    cur_obj_update_floor_and_walls()
    cur_obj_move_standard(-78)
    do_pose(o)
end

function do_pose(o)
    local np = network_player_from_global_index(o.globalPlayerIndex)
    if not np then return end
    ---@type MarioState
    local m = gMarioStates[np.localIndex]
    local pose = o.oBobombBlinkTimer
    if pose == 0 then pose = MARIO_ANIM_AIR_FORWARD_KB end
    if o.oMoveFlags & OBJ_MOVE_MASK_IN_WATER ~= 0 then
        pose = MARIO_ANIM_DROWNING_PART2
    elseif o.oMoveFlags & OBJ_MOVE_IN_AIR ~= 0 then
        if o.oFloor == nil or is_hazard_floor(o.oFloorType) then
            pose = MARIO_ANIM_DROWNING_PART2
            o.oVelY = -o.oGravity
        elseif pose ~= MARIO_ANIM_DYING_ON_BACK then
            pose = MARIO_ANIM_AIR_FORWARD_KB
        else
            pose = MARIO_ANIM_BACKWARD_AIR_KB
        end
    end

    if o.header.gfx.animInfo.animID ~= pose then
        set_mario_animation(m, pose)
        set_anim_to_frame(m, m.marioObj.header.gfx.animInfo.curAnim.loopEnd)
    end
    m.marioBodyState.eyeState = MARIO_EYES_DEAD
    m.marioBodyState.modelState = 0
    m.fadeWarpOpacity = 255
    o.oOpacity = 255
    
    o.header.gfx.animInfo.animID = m.marioObj.header.gfx.animInfo.animID
    o.header.gfx.animInfo.curAnim = m.marioObj.header.gfx.animInfo.curAnim
    o.header.gfx.animInfo.animYTrans = m.unkB0
    o.header.gfx.animInfo.animAccel = m.marioObj.header.gfx.animInfo.animAccel
    o.header.gfx.animInfo.animFrame = m.marioObj.header.gfx.animInfo.curAnim.loopEnd
    o.header.gfx.animInfo.animTimer = m.marioObj.header.gfx.animInfo.animTimer
    o.header.gfx.animInfo.animFrameAccelAssist = m.marioObj.header.gfx.animInfo.animFrameAccelAssist
end

id_bhvMHCorpse = hook_behavior(nil, OBJ_LIST_GENACTOR, true, mh_corpse_init, mh_corpse_loop, "bhvMHCorpse")

---@param o Object
function sabo_obj_init(o)
    o.oFlags = o.oFlags | (OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE | OBJ_FLAG_COMPUTE_DIST_TO_MARIO)
    o.oOpacity = 255
    o.oFaceAnglePitch = 0
    o.oFaceAngleRoll = 0
    o.oFaceAngleYaw = 0
    o.header.gfx.scale.z = 0.1
    network_init_object(o, true, {})
end

---@param o Object
function sabo_obj_loop(o)
    if gGlobalSyncTable.saboActive == 0 then
        if o.oTimer > 30 and is_nearest_mario_state_to_object(gMarioStates[0], o) ~= 0 then
            obj_mark_for_deletion(o)
        end
        return
    end
    o.oFaceAngleYaw = o.oFaceAngleYaw + 0x200
    cur_obj_enable_rendering()

    local m0 = gMarioStates[0]
    if gPlayerSyncTable[0].spectator ~= 1 and (m0.controller.buttonPressed & (A_BUTTON >> (reportButton - 1)) ~= 0) and dist_between_objects(m0.marioObj, o) < 200 then
        gGlobalSyncTable.saboActive = 0
        gPlayerSyncTable[0].allowLeave = true -- let the player leave
        -- apply to teammates as well
        for b = 1, (MAX_PLAYERS - 1) do
            local sMario = gPlayerSyncTable[b]
            local np = gNetworkPlayers[b]
            if np.connected and (not sMario.dead) and sMario.team == 1 and is_player_active(gMarioStates[b]) ~= 0 then
                sMario.allowLeave = true
            end
        end
        --gGlobalSyncTable.saboTimer = 1800 -- gets overwritten by host instead
        obj_mark_for_deletion(o)
        return
    end
end

id_bhvSaboObj = hook_behavior(nil, OBJ_LIST_GENACTOR, true, sabo_obj_init, sabo_obj_loop, "bhvSaboObj")

-- respawn corpses/sabo objs on enter
function on_sync_valid()
    if gGlobalSyncTable.mhMode ~= 3 or (gGlobalSyncTable.mhState ~= 1 and gGlobalSyncTable.mhState ~= 2) then
        stored_corpse_data = {}
        stored_sabo_obj_data = {}
        return
    end

    local np0 = gNetworkPlayers[0]
    for gIndex, data in pairs(stored_corpse_data) do
        local index = network_local_index_from_global(gIndex)
        if index ~= 255 then
            local sMario = gPlayerSyncTable[index]
            if sMario.knownDead == false and sMario.spectator == 1 and data.level == np0.currLevelNum and data.area == np0.currAreaIndex and data.act == np0.currActNum then
                if (not obj_get_first_with_behavior_id_and_field_s32(data.obj_id, 0x40, gIndex + 1)) and get_network_player_smallest_global() == np0 then
                    local o = spawn_sync_object(data.obj_id, data.model, data.x, data.y, data.z, function(o)
                        o.oBehParams = gIndex + 1
                        o.globalPlayerIndex = gIndex
                        o.oBobombBlinkTimer = data.extra
                        o.oFaceAngleYaw = data.yaw
                    end)
                    if o then network_send_object(o, true) end
                end
            end
        end
    end
    if gGlobalSyncTable.saboActive ~= 0 and stored_sabo_obj_data.obj_id then
        local data = stored_sabo_obj_data
        if data.level == np0.currLevelNum and data.area == np0.currAreaIndex and data.act == np0.currActNum then
            if (not obj_get_first_with_behavior_id(data.obj_id)) and get_network_player_smallest_global() == np0 then
                local o = spawn_sync_object(data.obj_id, data.model, data.x, data.y, data.z, nil)
                if o then
                    o.oBehParams = data.behParams
                    network_send_object(o, true)
                end
            end
        end
    end
end
hook_event(HOOK_ON_SYNC_VALID, on_sync_valid)

function on_packet_report_body(data, self)
    play_sound(SOUND_OBJ_BOWSER_LAUGH, gGlobalSoundSource)
    local np = network_player_from_global_index(data.reported)
    local np2 = network_player_from_global_index(data.dead)
    local playerColor = network_get_player_text_color_string(np.localIndex)
    local playerColor2 = network_get_player_text_color_string(np2.localIndex)
    local name = playerColor .. np.name
    local name2 = playerColor2 .. np2.name

    local text = trans("report_body", name, name2)
    text = text .. get_custom_level_name(np.currCourseNum, np.currLevelNum, np.currAreaIndex)
    if np.currActNum ~= 0 then
        text = text .. " #" .. tostring(np.currActNum)
    end
    text = text .. "!"
    djui_chat_message_create(text)

    local playerCount = 0
    for i = 0, (MAX_PLAYERS - 1) do
        local np = gNetworkPlayers[i]
        if np.connected and (not gPlayerSyncTable[i].dead) then
            playerCount = playerCount + 1
        end
    end
    text = trans_plural("players_remain", playerCount)
    djui_chat_message_create(text)

    gPlayerSyncTable[np2.localIndex].knownDead = true
    if gGlobalSyncTable.maxGlobalTalk ~= 0 and gGlobalSyncTable.maxGlobalTalk ~= -1 then
        djui_chat_message_create(trans("global_talk_start", gGlobalSyncTable.maxGlobalTalk//30))
        if network_is_server() then
            gGlobalSyncTable.globalTalkTimer = gGlobalSyncTable.maxGlobalTalk
        end
    end
end

function on_packet_mega_bomb(data, self)
    gGlobalSyncTable.saboActive = 0 
    gGlobalSyncTable.saboTimer = 90 * 30
    -- explode code
    local m = gMarioStates[0]
    local sMario = gPlayerSyncTable[0]
    play_sound(SOUND_GENERAL2_BOBOMB_EXPLOSION, gGlobalSoundSource)
    set_camera_shake_from_hit(SHAKE_LARGE_DAMAGE)
    if sMario.dead or sMario.team ~= 1 then return end
    sMario.runnerLives = 0
    sMario.dead = true
    m.freeze = 60
    m.marioObj.oDamageOrCoinValue = 8
    if (m.action & ACT_FLAG_ON_POLE) ~= 0 then -- prevent soft lock
      set_mario_action(m, ACT_STANDING_DEATH, 0)
    else
      take_damage_and_knock_back(m, m.marioObj)
    end
    m.health = 0xFF
    m.hurtCounter = 0x8
end

-- reset sabotage timer
function on_sabo_changed(tag, oldVal, newVal)
    if (not (oldVal and newVal)) or oldVal == newVal then return end
    if not (network_is_server() and gGlobalSyncTable.mhMode == 3) then return end
    local hunterCount = 0
    for i=0,MAX_PLAYERS-1 do
        local sMario = gPlayerSyncTable[i]
        if (i == 0 or gNetworkPlayers[i].connected) and sMario.team ~= 1 and not sMario.dead then
            hunterCount = hunterCount + 1
        end
    end
    gGlobalSyncTable.saboTimer = math.max(1800, hunterCount * 900) -- 30s per hunter, min 1 minute
end

hook_on_sync_table_change(gGlobalSyncTable, "saboActive", "saboChange", on_sabo_changed)