-- name: Automatic Doors
-- description: By Sunk and Blocky. Makes doors open automatically (or get destroyed)

doorsCanClose = false
doorsClosing = false

function door_loop(o)
    local m = gMarioStates[0]
    if dist_between_objects(m.marioObj, o) <= 400 then
        local starsNeeded = (o.oBehParams >> 24) or 0 -- this gets the star count
        if gGlobalSyncTable.starRun ~= nil and gGlobalSyncTable.starRun ~= -1 and gGlobalSyncTable.starRun <= starsNeeded then
          starsNeeded = gGlobalSyncTable.starRun
        end
        if starsNeeded <= m.numStars then
          obj_mark_for_deletion(o)
          play_sound(SOUND_GENERAL_BREAK_BOX, m.marioObj.header.gfx.cameraToObject)
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

hook_behavior(id_bhvDoor, OBJ_LIST_SURFACE, false, nil, door_loop)
hook_behavior(id_bhvStarDoor, OBJ_LIST_SURFACE, false, nil, star_door_loop)
