-- name: Automatic Doors
-- description: By Sunk and Blocky. Makes doors open automatically (or get destroyed)

doorsCanClose = false
doorsClosing = false

---@param m MarioState
---@param o Object
function should_push_or_pull_door(m, o)
  local dx = o.oPosX - m.pos.x
  local dz = o.oPosZ - m.pos.z

  local dYaw = o.oMoveAngleYaw - atan2s(dz, dx)

  if dYaw >= -0x4000 and dYaw <= 0x4000 then
      return 1
  else
      return 0
  end
end

---@param o Object
function door_init(o)
  -- completely remove collision and hitbox
  o.collisionData = nil
  o.hitboxRadius = 0
  o.hitboxHeight = 0
end

---@param o Object
function door_loop(o)
  if o.oAction == 0 then
    -- if mario is close enough, set action to the custom open door action, 5
    if dist_between_objects(o, gMarioStates[0].marioObj) <= 400 then
        o.oAction = 5
    end
  end

  if o.oAction == 5 then
    if o.oTimer == 0 then
      -- when the object timer is 0 (when we first set the action to 5) play a soudn and init the animation based off of if we are pulling or pushing the door
      if should_push_or_pull_door(gMarioStates[0], o) == 1 then
        -- push
        cur_obj_init_animation(1)
      else
        -- pull
        cur_obj_init_animation(2)
      end

      cur_obj_play_sound_2(SOUND_GENERAL_OPEN_WOOD_DOOR)
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
    -- since the action is no longer 5, the animation continues, 78 is the end of the animation
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
