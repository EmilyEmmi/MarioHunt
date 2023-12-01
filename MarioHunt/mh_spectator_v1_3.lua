-- name: Spectator 1.3 (MarioHunt)
-- description: -- Made by Sprinter#0669

--E_MODEL_MARIO = smlua_model_util_get_id("mario_geo")

ACT_SPECTATE = allocate_mario_action(ACT_GROUP_CUTSCENE)
function nothing(m) -- guess what this does
end
hook_mario_action(ACT_SPECTATE, nothing)

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

--SVcln -- not local because reasons
local SVcai
local SVcan

local SVtp = 0

local runnerFocus = 0

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
    goalPitch = 0,
    goalYaw = 0,
    goalDist = 1000,
}

function mario_dfm(m)
    if STP.spectator == 1 and free_camera == 1 and not (menu or showingStats) then
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

--- @param m MarioState
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

        MSP.marioObj.header.gfx.node.flags = MSP.marioObj.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE
        MSP.marioObj.oIntangibleTimer = -1
        MSP.health = 0x880

        set_mario_action(MSP, ACT_SPECTATE, 0)

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

        if (STP.team == 1 and (GST.mhState == 1 or GST.mhState == 2)) or GST.allowSpectate == false or (spectate == false and STP.forceSpectate == false) then
          STP.spectator = 0
          MSP.health = Shealth
          free_camera = 0

          SVtp = 1
        end

        if free_camera == 0 then
            if runnerFocus ~= 0 then
              if STI ~= nil and STI.team == 1 then
                runnerFocus = i
              else
                local focusSMario = gPlayerSyncTable[runnerFocus]
                if focusSMario == nil or focusSMario.team ~= 1 then
                  for a=1,(Rmax-1) do
                    local sMario = gPlayerSyncTable[a]
                    if sMario.team == 1 then
                      i = a
                      runnerFocus = a
                      STI = sMario
                      break
                    end
                  end
                end
              end
            end

            if (MSP.controller.buttonPressed & L_JPAD) ~= 0 then
                i = (i + (Rmax - 1) - 2) % (Rmax - 1) + 1
                if gNetworkPlayers[i].connected ~= true then
                    local oldI = i
                    i = (i + (Rmax - 1) - 2) % (Rmax - 1) + 1
                    while oldI ~= i do
                        if gNetworkPlayers[i].connected == true then break end
                        i = (i + (Rmax - 1) - 2) % (Rmax - 1) + 1
                    end
                end
                number = 0
            end

            if (MSP.controller.buttonPressed & R_JPAD) ~= 0 then
                i = (i + (Rmax - 1)) % (Rmax - 1) + 1
                if gNetworkPlayers[i].connected ~= true then
                    local oldI = i
                    i = (i + (Rmax - 1)) % (Rmax - 1) + 1
                    while oldI ~= i do
                        if gNetworkPlayers[i].connected == true then break end
                        i = (i + (Rmax - 1)) % (Rmax - 1) + 1
                    end
                end
                number = 0
            end
        end

        if STI.spectator == 0 then

            if free_camera == 1 then
              number = 0
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
                if number >= 35 then
                  number = 30

                    if not warp_to_level(NPI.currLevelNum, NPI.currAreaIndex, NPI.currActNum) then -- these areas don't have an entrance node, so use their death nodes as the entrance
                      warp_to_warpnode(NPI.currLevelNum, NPI.currAreaIndex, NPI.currActNum, 0xF0)
                    end
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
            else
              set_mario_action(MSP, ACT_IDLE, 0)
            end
            SVprevA = 0

            SVtp = 3
        end

        if SVtp == 1 then
            if SVcln == nil then
                warp_beginning()
                SVtp = 3
                return
            elseif SVcln ~= NPP.currLevelNum or SVcai ~= NPP.currAreaIndex or SVcan ~= NPP.currActNum then
                if not warp_to_level(SVcln, SVcai, SVcan) then -- these areas don't have an entrance node, so use their death nodes as the entrance
                  warp_to_warpnode(SVcln, SVcai, SVcan, 0xF0)
                end
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
            m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE
        end
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
  SVprevA = m.action or ACT_IDLE

  -- Unused due to Free Camera overriding Vanilla values
  --vec3f_copy(SVlsP, LLS.pos)
  --vec3f_copy(SVlsF, LLS.focus)
  --vec3f_copy(SVlsCP, LLS.curPos)
  --vec3f_copy(SVlsCF, LLS.curFocus)
  --vec3f_copy(SVlsGP, LLS.goalPos)
  --vec3f_copy(SVlsGF, LLS.goalFocus)

  vec3f_copy(cData.focus,MSP.pos)
  cData.focus.y = cData.focus.y + 120
  if m.area.camera ~= nil then
    cData.yaw = m.area.camera.yaw
  else
    cData.yaw = 0
  end
  Shealth = MSP.health
  STP.spectator = 1
  hide_hud = 0
  number = 0
  spectate = not STP.forceSpectate
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
            elseif gNetworkPlayers[n].connected == true then
                text = remove_color(gNetworkPlayers[n].name)
            else
                local oldI = n
                n = (n + (Rmax - 1)) % (Rmax - 1) + 1
                while oldI ~= n do
                    if gNetworkPlayers[i].connected == true then break end
                    n = (n + (Rmax - 1)) % (Rmax - 1) + 1
                end
                if oldI ~= n then
                    i = n
                    text = remove_color(gNetworkPlayers[n].name)
                else
                    text = trans("empty",i)
                end
            end

            local msglength = djui_hud_measure_text(text) /2
            local xpos = xlength /2 - msglength
            local ypos = ylength /24

            djui_hud_print_text(text, xpos, ypos, 1)

            local text2 = trans("spectate_mode")

            local msglength2 = djui_hud_measure_text(text2) / 2 * 0.5
            local xpos2 = xlength /2 - msglength2
            local ypos2 = ylength - ylength /10

            djui_hud_print_text(text2, xpos2, ypos2, 0.5)

            if STI.spectator == 1 and free_camera == 0 then
                djui_hud_set_color(255, 0, 0, 255)

                local text3 = trans("is_spectator")

                local msglength3 = djui_hud_measure_text(text3) / 2 * 0.5
                local xpos3 = xlength /2 - msglength3
                local ypos3 = ylength /10

                djui_hud_print_text(text3, xpos3, ypos3, 0.5)
            end

            if MSI.health ~= nil and free_camera == 0 then
              local screenWidth = djui_hud_get_screen_width()
              local screenHeight = djui_hud_get_screen_height()

              local xposH = screenWidth - 170
              local yposH = screenHeight - 170
              hud_render_power_meter(MSI.health,xposH,yposH,180,180)
            end
        end
    end
end

function spectated_update()

    if STP.spectator == 1 and not (menu or showingStats) then
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
      local stickX = m.controller.extStickX
      local stickY = m.controller.extStickY
      if m.controller.extStickX == 0 then
        if (m.controller.buttonDown & R_CBUTTONS) ~= 0 then
          stickX = clamp(stickX + 128,-128,128)
        end
        if (m.controller.buttonDown & L_CBUTTONS) ~= 0 then
          stickX = clamp(stickX - 128,-128,128)
        end
      end
      if m.controller.extStickY == 0 then
        if (m.controller.buttonDown & U_CBUTTONS) ~= 0 then
          stickY = clamp(stickY + 128,-128,128)
        end
        if (m.controller.buttonDown & D_CBUTTONS) ~= 0 then
          stickY = clamp(stickY - 128,-128,128)
        end
      end

      if cData.goalDist == 1 and free_camera == 0 and s.faceAngle.y then -- first person
        cData.goalYaw = limit_angle(s.faceAngle.y + 0x8000)
        if (s.action & ACT_FLAG_SWIMMING_OR_FLYING) ~= 0 then
          cData.goalPitch = -s.faceAngle.x
        else
          cData.goalPitch = 0
        end
        if cData.dist < 50 then
          obj_set_model_extended(s.marioObj, E_MODEL_NONE)
          --s.marioObj.header.gfx.node.flags = s.marioObj.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE
        end
      else
        cData.goalYaw = limit_angle(cData.goalYaw - (0.6 * stickX + mouseX) * (x_invert * camera_config_get_x_sensitivity()))
        cData.goalPitch = clamp(cData.goalPitch + (0.6 * stickY + mouseY) * (y_invert * camera_config_get_y_sensitivity()), -0x3E00, 0x3E00)

        if (m.controller.buttonDown & L_TRIG) ~= 0 and free_camera == 0 and s.faceAngle.y then
          cData.goalYaw = limit_angle(s.faceAngle.y + 0x8000)
          cData.goalPitch = 0
        end
      end

      if (m.controller.buttonPressed & R_TRIG) ~= 0 then
        cData.goalDist = cData.goalDist + 500
        if cData.goalDist == 501 then
          cData.goalDist = 500
        elseif cData.goalDist > 2000 then
          cData.goalDist = 1
        end
      end
    end
    cData.yaw = approach_s16_symmetric(cData.yaw, cData.goalYaw, math.min(0x500,math.abs(limit_angle(cData.goalYaw-cData.yaw))/5)) -- limit rotation to 0x500 for possibly less motion sickness
    cData.pitch = approach_s16_symmetric(cData.pitch, cData.goalPitch, math.abs(limit_angle(cData.goalPitch-cData.pitch))/5)
    if math.abs(cData.goalYaw-cData.yaw) < 10 then
      cData.yaw = cData.goalYaw
    end
    if math.abs(cData.goalPitch-cData.pitch) < 10 then
      cData.pitch = cData.goalPitch
    end
    cData.dist = cData.dist + (cData.goalDist-cData.dist)/5
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
  elseif sMario.team == 1 and (gGlobalSyncTable.mhState == 1 or gGlobalSyncTable.mhState == 2) then
    djui_chat_message_create(trans("hunters_only"))
    return true
  end

  if msg == "" then
    runnerFocus = 0
    free_camera = 1
    enable_spectator(m)
    djui_chat_message_create(trans("spectator_controls"))
    return true
  elseif string.lower(msg) == "off" then
    if sMario.forceSpectate then
      djui_chat_message_create(trans("not_mod"))
      return true
    end
    runnerFocus = 0
    spectate = false
    djui_chat_message_create(trans("spectate_off"))
    return true
  end

  if string.lower(msg) == "runner" then
    runnerFocus = 1
    i = 1
    for a=1,(Rmax-1) do
      local sMario = gPlayerSyncTable[a]
      if sMario.team == 1 then
        i = a
        runnerFocus = a
        break
      end
    end
    free_camera = 0
    enable_spectator(m)
    djui_chat_message_create(trans("spectator_controls"))
    return true
  end

  local playerID,np = get_specified_player(msg)

  if playerID == 0 then
    djui_chat_message_create(trans("spectate_self"))
    return true
  end

  runnerFocus = 0
  if playerID == nil then
    return true
  end
  free_camera = 0
  i = playerID
  enable_spectator(m)
  djui_chat_message_create(trans("spectator_controls"))
  return true
end
hook_chat_command("spectate",trans("spectate_desc"),spectate_command)

hook_event(HOOK_ON_HUD_RENDER, spectated_update)
hook_event(HOOK_MARIO_UPDATE, mario_update)
