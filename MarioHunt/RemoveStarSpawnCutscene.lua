-- name: Remove Star Spawn Cutscenes
-- description: Created by Sunk.

function remove_timestop()
    ---@type MarioState
    local m = gMarioStates[0]
    ---@type Camera
    local c = gMarioStates[0].area.camera

    if not m or not c then
        return
    end

    if ((c.cutscene == CUTSCENE_STAR_SPAWN) or (c.cutscene == CUTSCENE_RED_COIN_STAR_SPAWN) or (c.cutscene == CUTSCENE_ENTER_BOWSER_ARENA)) then
        print("disabled cutscene")
        disable_time_stop_including_mario()
        m.freeze = 0
        if m.action == ACT_READING_NPC_DIALOG then
          force_idle_state(m)
        end
        
        if c.cutscene == CUTSCENE_ENTER_BOWSER_ARENA then
          local bowser = obj_get_first_with_behavior_id(id_bhvBowser)
          if bowser and bowser.oAction == 5 then
            -- always give bowser 3 health when playing in other game areas
            if gGlobalSyncTable.gameArea ~= 0 then
              bowser.oHealth = 3
            end
            
            if bowser.oBehParams2ndByte == 0x01 then
              bowser.oAction = 13
            else
              bowser.oAction = 0
            end
          end
        elseif c.cutscene == CUTSCENE_STAR_SPAWN then -- done here because a lot of hacks hook to this object
          local grand = obj_get_first_with_behavior_id(id_bhvGrandStar)
          if grand then
            grand.oAction = 1
            m.invincTimer = 600 -- 20 seconds is long enough I think
            --obj_become_tangible(grand)
          end
        end
        c.cutscene = 0
        play_cutscene(c)
    elseif m.invincTimer < 30 and c.cutscene ~= 0 and c.cutscene ~= CUTSCENE_PALETTE_EDITOR and c.cutscene ~= 0xFA and gGlobalSyncTable.mhState == 2 then -- 0xFA is character select's cutscene
        m.invincTimer = 30
    end
end
hook_event(HOOK_UPDATE, remove_timestop)
