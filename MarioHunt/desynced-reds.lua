
---@param star Object
---@param obj Object
---@param x integer
---@param y integer
---@param z integer
function spawn_star(star, obj, x, y, z)
    -- spawn in star
    star = spawn_non_sync_object(id_bhvStarSpawnCoordinates, E_MODEL_STAR, obj.oPosX, obj.oPosY, obj.oPosZ, function (obj2)
            obj2.oFaceAngleYaw = 0
            obj2.oFaceAnglePitch = 0
            obj2.oFaceAngleRoll = 0
        end)
    -- if the object failed to spawn, return nil
    if star == nil then return nil end
    -- set star params
    star.oBehParams = obj.oBehParams
    star.oStarSpawnExtCutsceneFlags = 0
    star.oHomeX = x
    star.oHomeY = y
    star.oHomeZ = z
    star.oFaceAnglePitch = 0
    star.oFaceAngleRoll = 0
    return star
end

---@param o Object
---@param x integer
---@param y integer
---@param z integer
function spawn_red_coin_star(o, x, y, z)
    local star = spawn_star(o, o, x, y, z) -- spawn star using above function
    if star ~= nil then
        -- set second behavior paramater
        star.oBehParams2ndByte = 1
    end
    return star
end

---@param o Object
function red_coin_init(o)

    -- generic object settings
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    obj_set_billboard(o)
    o.oIntangibleTimer = 0
    o.oAnimState = -1

    -- set the red coins to have a parent of the closest red coin star.
    local hiddenRedCoinStar = cur_obj_nearest_object_with_behavior(get_behavior_from_id(id_bhvHiddenRedCoinStar))
    -- if it's not a typical red coin star, it's a bowzer one.
    if hiddenRedCoinStar == nil then
        hiddenRedCoinStar = cur_obj_nearest_object_with_behavior(get_behavior_from_id(id_bhvBowserCourseRedCoinStar))
    end

    -- if we found a red coin star, its our parent
    if hiddenRedCoinStar ~= nil then
        o.parentObj = hiddenRedCoinStar
    else
        o.parentObj = nil
    end

    -- create hitbox
    local hitbox = get_temp_object_hitbox()
    hitbox.interactType = INTERACT_COIN
    hitbox.downOffset = 0
    hitbox.damageOrCoinValue = 2
    hitbox.health = 0
    hitbox.numLootCoins = 0
    hitbox.radius = 100
    hitbox.height = 64
    hitbox.hurtboxRadius = 0
    hitbox.hurtboxHeight = 0

    -- set hitbox
    obj_set_hitbox(o, hitbox)
end

---@param o Object
function red_coin_loop(o)
    -- if mario interacted with the object...
    if o.oInteractStatus & INT_STATUS_INTERACTED ~= 0 then
        -- ..and the mario is us, and we are a runner (or OMM is enabled), if the gamemode is minihunt..
        if gGlobalSyncTable.mhMode ~= 2 or (nearest_mario_state_to_object(o).playerIndex == 0 and (gPlayerSyncTable[0].team == 1 or OmmEnabled)) then
            -- get red coin count
            local redCoins = count_objects_with_behavior(get_behavior_from_id(id_bhvRedCoin)) - 1

            -- spawn the orange number counter
            spawn_orange_number(8 - redCoins, 0, 0, 0)

            -- set this red coin as collected in minihunt
            if gGlobalSyncTable.mhMode == 2 then
                miniRedCoinCollect = miniRedCoinCollect | (1 << o.unused1)
            end

            -- play higher noise when each coin is collected
            if (redCoins < 8) then
                play_sound(SOUND_MENU_COLLECT_RED_COIN + ((7 - redCoins) << 16), gGlobalSoundSource)
            else
                play_sound(SOUND_MENU_COLLECT_RED_COIN, gGlobalSoundSource)
            end

            -- set interact status
            o.oInteractStatus = 0
            -- spawn in sparkles
            spawn_non_sync_object(id_bhvGoldenCoinSparkles, E_MODEL_SPARKLES, o.oPosX, o.oPosY, o.oPosZ, nil)
            -- delete object
            o.activeFlags = ACTIVE_FLAG_DEACTIVATED
        else
            o.oInteractStatus = 0
        end
    end

    -- animate the coin
    o.oAnimState = o.oAnimState + 1
end

---@param o Object
function hidden_red_coin_star_init(o)
    if (gNetworkPlayers[0].currLevelNum ~= LEVEL_JRB) then
        -- spawn in the red coin marker if we aren't in jrb
        spawn_non_sync_object(id_bhvRedCoinStarMarker, E_MODEL_TRANSPARENT_STAR, o.oPosX, o.oPosY, o.oPosZ, nil)
    end

    -- set object flags
    o.oFlags = OBJ_FLAG_PERSISTENT_RESPAWN | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
end

---@param o Object
function hidden_red_coin_star_loop(o)
    if o.oAction == 0 then
        -- if there are no more red coins, set action to 1/spawn star
        if count_objects_with_behavior(get_behavior_from_id(id_bhvRedCoin)) <= 0 then
            o.oAction = 1
        end
    elseif o.oAction == 1 then
        if o.oTimer == 3 then
            -- spawn star
            obj = spawn_red_coin_star(o, o.oPosX, o.oPosY, o.oPosZ)
            if obj ~= nil then
                -- spawn mist particles (obviously)
                spawn_mist_particles()
            end
        end
    end
end

---@param o Object
function bowser_course_red_coin_star_init(o)
    -- set object flags
    o.oFlags = OBJ_FLAG_PERSISTENT_RESPAWN | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
end

---@param o Object
function bowser_course_red_coin_star_loop(o)
    if o.oAction == 0 then
        -- if there are no more red coins, set action to 1/spawn star
        if count_objects_with_behavior(get_behavior_from_id(id_bhvRedCoin)) <= 0 then
            o.oAction = 1
        end
    elseif o.oAction == 1 then
        if o.oTimer == 3 then
            -- spawn star
            obj = spawn_no_exit_star(o.oPosX, o.oPosY, o.oPosZ)
            if obj ~= nil then
                -- spawn mist particles (obviously)
                spawn_mist_particles()
            end
        end
    end
end

-- hooks
id_bhvCusRedCoin = hook_behavior(id_bhvRedCoin, OBJ_LIST_LEVEL, true, red_coin_init, red_coin_loop, "redCoin")
hook_behavior(id_bhvHiddenRedCoinStar, OBJ_LIST_LEVEL, true, hidden_red_coin_star_init, hidden_red_coin_star_loop, "hiddenRedCoinStar")
hook_behavior(id_bhvBowserCourseRedCoinStar, OBJ_LIST_LEVEL, true, bowser_course_red_coin_star_init, bowser_course_red_coin_star_loop, "bowserCourseRedCoinStar")

-- desync secrets
---@param o Object
function secret_init(o)
    -- generic object flags
    o.oFlags = OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
    o.hitboxRadius = 100
    o.hitboxHeight = 100
    o.oIntangibleTimer = 0

    -- billboard (looks at camera)
    obj_set_billboard(o)
end

---@param o Object
function secret_loop(o)
    -- if we interacted with the object...
    if (o.oInteractStatus & INT_STATUS_INTERACTED ~= 0 or obj_check_if_collided_with_object(o, gMarioStates[0].marioObj) == 1) then
        -- ...and we're a runner, and our index is 0, if the gamemode is minihunt...
        local index = nearest_mario_state_to_object(o).playerIndex
        if gPlayerSyncTable[index].team == 1 and (gGlobalSyncTable.mhMode ~= 2 or index == 0) then
            -- get hidden star object (ignore since the last one won't do the sound otherwise, for whatever reason)
            --local hiddenStar = cur_obj_nearest_object_with_behavior(get_behavior_from_id(id_bhvHiddenStarTrigger))
            --if hiddenStar ~= nil then
                -- count amount of secrets and spawn orange number
                local count = (count_objects_with_behavior(get_behavior_from_id(id_bhvHiddenStarTrigger)) - 1)
                spawn_orange_number(5 - count, 0, 0, 0)
                if gGlobalSyncTable.mhMode == 2 then
                    miniSecretCollect = miniSecretCollect | (1 << o.unused1)
                end

                -- sound magic!
                if (count < 5) then
                    play_sound(SOUND_MENU_COLLECT_SECRET + ((4 - count) << 16), gGlobalSoundSource)
                else
                    play_sound(SOUND_MENU_COLLECT_SECRET, gGlobalSoundSource)
                end
            --end

            -- delete object
            o.activeFlags = ACTIVE_FLAG_DEACTIVATED
        else
            o.oInteractStatus = 0
        end
    end
end

---@param o Object
function hidden_star_init(o)
    o.oFlags = OBJ_FLAG_PERSISTENT_RESPAWN | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
end

---@param o Object
function hidden_star_loop(o)
    if o.oAction == 0 then
        -- if we have no secrets, set action to 1/spawn star
        if count_objects_with_behavior(get_behavior_from_id(id_bhvHiddenStarTrigger)) <= 0 then
            o.oAction = 1
        end
    elseif o.oAction == 1 then
        if o.oTimer > 2 then
            -- spawn star
            local obj = spawn_red_coin_star(o, o.oPosX, o.oPosY, o.oPosZ)
            if obj ~= nil then
                -- spawn mist particles
                spawn_mist_particles()
            end

            -- delete object
            o.activeFlags = ACTIVE_FLAG_DEACTIVATED
        end
    end
end

-- hidden star is secrets
id_bhvSecrets = hook_behavior(id_bhvHiddenStar, OBJ_LIST_LEVEL, true, hidden_star_init, hidden_star_loop, "secret star")
hook_behavior(id_bhvHiddenStarTrigger, OBJ_LIST_LEVEL, true, secret_init, secret_loop, "secret")