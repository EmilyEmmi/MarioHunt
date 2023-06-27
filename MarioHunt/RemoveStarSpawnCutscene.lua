-- name: Remove Star Spawn Cutscenes
-- description: Created by Sunk.

function remove_timestop()
    ---@type MarioState
    local m = gMarioStates[0]
    ---@type Camera
    local c = gMarioStates[0].area.camera

    if m == nil or c == nil then
        return
    end

    local sMario = gPlayerSyncTable[0]
    if (gGlobalSyncTable.ee ~= true or gNetworkPlayers[0].currLevelNum ~= LEVEL_SA) and ((c.cutscene == CUTSCENE_STAR_SPAWN) or (c.cutscene == CUTSCENE_RED_COIN_STAR_SPAWN) or (c.cutscene == CUTSCENE_ENTER_BOWSER_ARENA) or (c.cutscene == CUTSCENE_GRAND_STAR)) then
        print("disabled cutscene")
        disable_time_stop_including_mario()
        m.freeze = 0
        if c.cutscene == CUTSCENE_ENTER_BOWSER_ARENA then
          local bowser = obj_get_first_with_behavior_id(id_bhvBowser)
          if bowser ~= nil and bowser.oAction == 5 then
            local np = gNetworkPlayers[0]
            if np.currLevelNum == LEVEL_BOWSER_2 then
              bowser.oAction = 13
            else
              bowser.oAction = 0
            end
          end
        end
        c.cutscene = 0
    elseif m.invincTimer < 30 and c.cutscene ~= 0 and gGlobalSyncTable.mhState == 2 then
        m.invincTimer = 30
    end
end
hook_event(HOOK_UPDATE, remove_timestop)
