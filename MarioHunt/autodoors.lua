-- name: Automatic Doors
-- description: By Sunk and Blocky. Makes doors open automatically (or get destroyed)

doorsCanClose = false
doorsClosing = false

---@param o Object
function door_loop(o)
  -- check if the door has enough stars to be opened
  local m = gMarioStates[0]
  local starsNeeded = (o.oBehParams >> 24) or 0 -- this gets the star count
  if gGlobalSyncTable.starRun ~= nil and gGlobalSyncTable.starRun ~= -1 and gGlobalSyncTable.starRun <= starsNeeded then
    local np = gNetworkPlayers[0]
    starsNeeded = gGlobalSyncTable.starRun
    if (np.currAreaIndex ~= 2) and ROMHACK.ddd == true then
      starsNeeded = starsNeeded - 1
    end
  end
  
  if m.numStars >= starsNeeded then
    -- completely remove collision and hitbox
    o.collisionData = nil
    o.hitboxRadius = 0
    o.hitboxHeight = 0
    if o.oAction == 0 then
      -- if mario is close enough, set action to the custom open door action, 5
      if dist_between_objects(o, gMarioStates[0].marioObj) <= 400 then
          o.oAction = 5
      end
    end
  end

  if o.oAction == 5 then
    if o.oTimer == 0 then
      -- when the object timer is 0 (when we first set the action to 5) play a sound and init the animation
      cur_obj_init_animation(1)

      cur_obj_play_sound_2(SOUND_GENERAL_OPEN_WOOD_DOOR)
    end

    if o.header.gfx.animInfo.animFrame < 5 then
      o.header.gfx.animInfo.animFrame = 5 -- make door opening feel snappier
    end

    -- 40 is the anim frame where the door is fully opened
    if o.header.gfx.animInfo.animFrame >= 40 then
      o.header.gfx.animInfo.animFrame = 40
      o.header.gfx.animInfo.prevAnimFrame = 40
    end

    -- if we are far from the door, go to the custom close door action, 6
    if dist_between_objects(o, gMarioStates[0].marioObj) > 400 then
      o.oAction = 6
    end
  end

  if o.oAction == 6 then
    -- since the action is no longer 5, the animation continues, 78 is the end of the animation (take 2 frames)
    if o.header.gfx.animInfo.animFrame >= 78 then
      -- play object sound, and set action to 0
      cur_obj_play_sound_2(SOUND_GENERAL_CLOSE_WOOD_DOOR)
      o.oAction = 0
    end
  end
end

function star_door_loop(o)
    local m = gMarioStates[0]
    local starsNeeded = (o.oBehParams >> 24) or 0 -- this gets the star count
    if gGlobalSyncTable.starRun ~= nil and gGlobalSyncTable.starRun ~= -1 and gGlobalSyncTable.starRun <= starsNeeded then
      local np = gNetworkPlayers[0]
      starsNeeded = gGlobalSyncTable.starRun
      if (np.currAreaIndex ~= 2) and ROMHACK.ddd == true then
        starsNeeded = starsNeeded - 1
      end
    end
    if starsNeeded <= m.numStars and dist_between_objects(m.marioObj, o) <= 800 then
        o.oIntangibleTimer = -1
        if o.oAction == 0 then
          o.oAction = 1
          doorsClosing = false
        elseif o.oAction == 3 and not doorsClosing then
          o.oAction = 2
        end
        doorsCanClose = false
    elseif o.oAction == 3 then
        if doorsCanClose == false and not doorsClosing then
          o.oAction = 2
          doorsCanClose = true
        else
          doorsClosing = true
        end
    end
end

hook_behavior(id_bhvDoor, OBJ_LIST_SURFACE, false, door_init, door_loop)
hook_behavior(id_bhvStarDoor, OBJ_LIST_SURFACE, false, nil, star_door_loop)
