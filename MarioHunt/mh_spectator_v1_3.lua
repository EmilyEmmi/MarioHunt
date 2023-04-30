-- name: Spectator 1.3 (MarioHunt)
-- description: -- SPECTATOR 1.3 (MarioHunt) --\n\n- Hunters can press DPAD-UP to enter Spectator\n\n[Inside Spectator]\n- DPAD-UP to turn Spectator HUD on/off\n- DPAD-DOWN to switch from Free Camera to Player Focus mode\n  (Player Focus is default)\n- DPAD-LEFT and DPAD-RIGHT to change between players\n  (Only in Player Focus mode)\n- DPAD-UP and B-BUTTON to exit spectator\n\nMade by Sprinter#0669\nModified by EmilyEmmi#9099

E_MODEL_MARIO = smlua_model_util_get_id("mario_geo")
ACT_MY_DEBUG_FREE_MOVE = allocate_mario_action(ACT_GROUP_CUTSCENE)

local Rmax = MAX_PLAYERS

local i = 1
local number = 0

local MSP = gMarioStates[0]
local MSI = gMarioStates[i]

local NPP = gNetworkPlayers[0]
local NPI = gNetworkPlayers[i]

local STP = gPlayerSyncTable[0]
local STI = gPlayerSyncTable[i]

local GST = gGlobalSyncTable

local LLS = gLakituState

local free_camera = 0
local hide_hud = 0

local Shealth

local SVposX = 0
local SVposY = 0
local SVposZ = 0

--[[local SVlsP = { x = 0, y = 0, z = 0 }
local SVlsF = { x = 0, y = 0, z = 0 }
local SVlsCP = { x = 0, y = 0, z = 0 }
local SVlsCF = { x = 0, y = 0, z = 0 }
local SVlsGP = { x = 0, y = 0, z = 0 }
local SVlsGF = { x = 0, y = 0, z = 0 }]]
local SVprevA = 0

local SVcln
local SVcai
local SVcan

local SVtp = 0

for Ci=0,(Rmax-1) do
    local p = gPlayerSyncTable[Ci]
    p.spectator = 0
end

local cData = {
    pos = {x = 0, y = 0, z = 0},
    focus = {x = 0, y = 0, z = 0},
    pitch = 0,
    yaw = 0,
    dist = 1000,
}

function mario_dfm(m)
    if STP.spectator == 1 and free_camera == 1 then
        local speed = 0
        local floorHeight = 0

        set_mario_animation(m, MARIO_ANIM_A_POSE)

        if (m.controller.buttonDown & B_BUTTON) ~= 0 then
            speed = 1
        else
            speed = 3
        end

        local pos = cData.focus

        if (m.controller.buttonDown & A_BUTTON) ~= 0 then
            pos.y = pos.y + 16.0 * speed
        end

        if (m.controller.buttonDown & Z_TRIG) ~= 0 then
            pos.y = pos.y - 16.0 * speed
        end

        if (m.intendedMag > 0) then
            pos.x = pos.x - 0.5 * speed * (sins(cData.yaw) * m.controller.stickY + sins(cData.yaw - 16384) * m.controller.stickX)
            pos.z = pos.z - 0.5 * speed * (coss(cData.yaw) * m.controller.stickY + coss(cData.yaw - 16384) * m.controller.stickX)
        end

        --resolve_and_return_wall_collisions(m.pos, 60.0, 50.0)
        --floorHeight = find_floor_height(m.pos.x, m.pos.y, m.pos.z)

        --[[if floorHeight > -11000 then
            if MSP.pos.y < floorHeight then
                posY = floorHeight
            end
        end]]

        --[[m.faceAngle.y = m.intendedYaw
        vec3f_copy(m.marioObj.header.gfx.pos, m.pos)
        vec3s_set(m.marioObj.header.gfx.angle, 0, m.faceAngle.y, 0)]]

        return pos
    end

end

function mario_update_local(m)

    STP = gPlayerSyncTable[0]
    STI = gPlayerSyncTable[i]
    GST = gGlobalSyncTable

    MSP = gMarioStates[0]
    MSI = gMarioStates[i]

    LLS = gLakituState

    NPP = gNetworkPlayers[0]
    NPI = gNetworkPlayers[i]

    NPM = gNetworkPlayers[m.playerIndex]

    if STP.spectator == 1 then

        if (MSP.action == ACT_START_SLEEPING) then
            set_mario_action(MSP, ACT_WAKING_UP, 0)
        end

        obj_set_model_extended(MSP.marioObj, E_MODEL_NONE)
        MSP.marioObj.oIntangibleTimer = -1
        MSP.health = 0x880

        set_mario_action(MSP, ACT_PAUSE, 0)

        if free_camera == 0 then
            MSP.freeze = -1
        else
            MSP.freeze = 0
        end

        if (MSP.controller.buttonPressed & D_JPAD) ~= 0 then
            if free_camera == 1 then
                free_camera = 0
            else
                free_camera = 1
            end
        end

        if (MSP.controller.buttonPressed & U_JPAD) ~= 0 then
            if hide_hud == 0 then
                hide_hud = 1
            else
                hide_hud = 0
            end
        end

        if STP.team == 1 or GST.mhState == 1 or GST.allowSpectate == false or spectate == false then
          STP.spectator = 0
          MSP.health = Shealth
          free_camera = 0

          if GST.mhState ~= 1 then
            SVtp = 1
          else
            SVtp = 3 -- don't warp if the game is restarting
          end
        end

        if free_camera == 0 then

            if (MSP.controller.buttonPressed & L_JPAD) ~= 0 then
                if i > 1 and i <= (Rmax - 1) then
                    i = i - 1
                end
            end

            if (MSP.controller.buttonPressed & R_JPAD) ~= 0 then
                if i < (Rmax - 1) and i >= 1 then
                    i = i + 1
                end
            end
        end

        if STI.spectator == 0 then

            if free_camera == 1 then
              if not is_game_paused() then
                mario_dfm(m)
              end
            else
              vec3f_copy(cData.focus,MSI.pos)
              cData.focus.y = cData.focus.y + 120
            end

            update_spectator_camera(MSP, MSI)

            if free_camera == 0 and obj_get_first_with_behavior_id(id_bhvActSelector) == nil and (NPI.currLevelNum ~= NPP.currLevelNum or NPI.currAreaIndex ~= NPP.currAreaIndex or NPI.currActNum ~= NPP.currActNum) then
                number = number + 1
                if number == 35 then
                    number = 0
                    warp_to_level(NPI.currLevelNum, NPI.currAreaIndex, NPI.currActNum)
                end
            end
        end

    else

        if SVtp == 3 then
            -- Unused due to Free Camera overriding Vanilla values
            --vec3f_set(LLS.pos, SVlsP.x, SVlsP.y, SVlsP.z)
            --vec3f_set(LLS.focus, SVlsF.x, SVlsF.y, SVlsF.z)
            --vec3f_set(LLS.curPos, SVlsCP.x, SVlsCP.y, SVlsCP.z)
            --vec3f_set(LLS.curFocus, SVlsCF.x, SVlsCF.y, SVlsCF.z)
            --vec3f_set(LLS.goalPos, SVlsGP.x, SVlsGP.y, SVlsGP.z)
            --vec3f_set(LLS.goalFocus, SVlsGF.x, SVlsGF.y, SVlsGF.z)

            MSP.marioObj.oIntangibleTimer = 0
            MSP.freeze = 0x1E -- 1 seconds (30 frames)
            MSP.invincTimer = 0x1E
            SVtp = 0
        end

        if SVtp == 2 then
            MSP.pos.x = SVposX
            MSP.pos.y = SVposY
            MSP.pos.z = SVposZ
            MSP.peakHeight = SVposY -- to prevent fall damage death
            if (SVprevA & ACT_GROUP_SUBMERGED) ~= 0 then
              print("set to water")
              set_mario_action(MSP, ACT_WATER_IDLE, 0)
            end
            SVprevA = 0

            SVtp = 3
        end

        if SVtp == 1 then
            if SVcln ~= NPP.currLevelNum or SVcai ~= NPP.currAreaIndex or SVcan ~= NPP.currActNum then
                warp_to_level(SVcln, SVcai, SVcan)
            end

            SVtp = 2
        end

    end
end

function mario_update(m)
    if m.playerIndex == 0 then
        mario_update_local(m)
    else
        if gPlayerSyncTable[m.playerIndex].spectator == 1 then
            obj_set_model_extended(m.marioObj, E_MODEL_NONE)
        end
    end

    NPM = gNetworkPlayers[m.playerIndex]

    if gPlayerSyncTable[m.playerIndex].spectator == 1 then
        network_player_set_description(NPM, trans("spectator"), 169, 169, 169, 255)
    end
end

function enable_spectator(m)
  local sMario = gPlayerSyncTable[m.playerIndex]
  if sMario.spectator == 1 then return end
  SVcln = NPP.currLevelNum
  SVcai = NPP.currAreaIndex
  SVcan = NPP.currActNum

  SVposX = MSP.pos.x
  SVposY = MSP.pos.y
  SVposZ = MSP.pos.z
  SVprevA = m.action or 0

  -- Unused due to Free Camera overriding Vanilla values
  --vec3f_copy(SVlsP, LLS.pos)
  --vec3f_copy(SVlsF, LLS.focus)
  --vec3f_copy(SVlsCP, LLS.curPos)
  --vec3f_copy(SVlsCF, LLS.curFocus)
  --vec3f_copy(SVlsGP, LLS.goalPos)
  --vec3f_copy(SVlsGF, LLS.goalFocus)

  vec3f_copy(cData.focus,MSP.pos)
  cData.focus.y = cData.focus.y + 120
  cData.yaw = m.area.camera.yaw
  Shealth = MSP.health
  STP.spectator = 1
  hide_hud = 0
  spectate = true
end

function spectated()
    if STP.spectator == 1 then
        if hide_hud == 0 then
            local n = i

            djui_hud_set_font(FONT_MENU)
            djui_hud_set_resolution(RESOLUTION_DJUI)
            djui_hud_set_color(255, 255, 255, 255)

            local xlength = djui_hud_get_screen_width()
            local ylength = djui_hud_get_screen_height()

            local text

            if free_camera == 1 then
                text = trans("free_camera")
            else
                if gNetworkPlayers[n].name == '' then
                    text = trans("empty",i)
                else
                    if gNetworkPlayers[n].connected == true then
                        text = remove_color(gNetworkPlayers[n].name)
                    else
                        text = trans("empty",i)
                    end
                end
            end

            local msglength = djui_hud_measure_text(text) /2
            local xpos = xlength /2 - msglength
            local ypos = ylength /24

            djui_hud_print_text(text, xpos, ypos, 1)

            local text2 = '- SPECTATOR MODE -'

            local msglength2 = djui_hud_measure_text(text2) / 2 * 0.5
            local xpos2 = xlength /2 - msglength2
            local ypos2 = ylength - ylength /20

            djui_hud_print_text(text2, xpos2, ypos2, 0.5)

            if STI.spectator == 1 and free_camera == 0 then
                djui_hud_set_color(255, 0, 0, 255)

                local text3 = '* PLAYER IS A SPECTATOR  *'

                local msglength3 = djui_hud_measure_text(text3) / 2 * 0.5
                local xpos3 = xlength /2 - msglength3
                local ypos3 = ylength /10

                djui_hud_print_text(text3, xpos3, ypos3, 0.5)
            end
        end
    end
end

function spectated_update()

    if STP.spectator == 1 then
        spectated()
    end

end

-- screw it I'm writing my own camera code
function update_spectator_camera(m, s)
    vec3f_copy(LLS.focus, cData.focus)
    vec3f_copy(LLS.curFocus, cData.focus)
    vec3f_copy(LLS.goalFocus, cData.focus)
    vec3f_copy(m.area.camera.focus, cData.focus)
    if m.currentRoom ~= s.currentRoom and free_camera == 0 then
        vec3f_copy(m.pos,s.pos)
    end
    LLS.posHSpeed = 0
    LLS.posVSpeed = 0
    LLS.focHSpeed = 0
    LLS.focVSpeed = 0
    cData.pos.x = cData.focus.x + cData.dist * sins(cData.yaw) * coss(cData.pitch)
    cData.pos.y = cData.focus.y + cData.dist * sins(cData.pitch)
    cData.pos.z = cData.focus.z + cData.dist * coss(cData.yaw) * coss(cData.pitch)
    vec3f_copy(LLS.pos, cData.pos)
    vec3f_copy(LLS.curPos, cData.pos)
    vec3f_copy(LLS.goalPos, cData.pos)
    vec3f_copy(m.area.camera.pos, cData.pos)
    m.area.camera.yaw = cData.yaw

    if not is_game_paused() then
      local x_invert = 1
      local y_invert = 1
      if camera_config_is_x_inverted() then
        x_invert = -1
      end
      if camera_config_is_y_inverted() then
        y_invert = -1
      end

      local mouseX = 0
      local mouseY = 0
      if camera_config_is_mouse_look_enabled() then
        mouseX = djui_hud_get_raw_mouse_x()
        mouseY = djui_hud_get_raw_mouse_y()
      end

      cData.yaw = limit_angle(cData.yaw - (0.5 * m.controller.extStickX + mouseX) * (x_invert * camera_config_get_x_sensitivity()))
      cData.pitch = clamp(cData.pitch + (0.5 * m.controller.extStickY + mouseY) * (y_invert * camera_config_get_y_sensitivity()),-16300,16300)

      if (m.controller.buttonPressed & R_TRIG) ~= 0 then
        cData.dist = cData.dist + 500
        if cData.dist > 2000 then
          cData.dist = 1000
        end
      end
      if (m.controller.buttonDown & L_TRIG) ~= 0 and free_camera == 0 and s.faceAngle.y then
        cData.yaw = limit_angle(s.faceAngle.y - 0x8000)
      end
    end
end

-- from extended moveset
function limit_angle(a)
    return (a + 0x8000) % 0x10000 - 0x8000
end

-- the command
function spectate_command(msg)
  local m = gMarioStates[0]
  local sMario = gPlayerSyncTable[0]
  if not gGlobalSyncTable.allowSpectate then
    djui_chat_message_create(trans("spectate_disabled"))
    return true
  elseif sMario.team == 1 and gGlobalSyncTable.mhState == 2 then
    djui_chat_message_create(trans("hunters_only"))
    return true
  elseif gGlobalSyncTable.mhState == 1 then
    djui_chat_message_create(trans("timer_going"))
    return true
  end

  if msg == "" then
    free_camera = 1
    enable_spectator(m)
    djui_chat_message_create(trans("spectator_controls"))
    return true
  elseif string.lower(msg) == "off" then
    spectate = false
    djui_chat_message_create(trans("spectate_off"))
    return true
  end

  local playerID,np = get_specified_player(msg)

  if playerID == 0 then
    djui_chat_message_create(trans("spectate_self"))
    return true
  end

  if np == nil or (not np.connected) then
    djui_chat_message_create(trans("no_such_player"))
    return true
  end
  free_camera = 0
  i = playerID
  enable_spectator(m)
  djui_chat_message_create(trans("spectator_controls"))
  return true
end
hook_chat_command("spectate","[NAME|ID|OFF] - Spectate the specified player, free camera if not specified, or OFF to turn off",spectate_command)

hook_event(HOOK_ON_HUD_RENDER, spectated_update)
hook_event(HOOK_MARIO_UPDATE, mario_update)
