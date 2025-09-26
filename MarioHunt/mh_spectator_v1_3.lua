-- name: Spectator 1.3 (MarioHunt)
-- description: -- Made by Sprinter#0669

--E_MODEL_MARIO = smlua_model_util_get_id("mario_geo")

local Rmax = MAX_PLAYERS

spectateFocus = 1
local teamFocus = -1
local number = 0

local MSP = gMarioStates[0]
local MSI = gMarioStates[spectateFocus]

local NPP = gNetworkPlayers[0]
local NPI = gNetworkPlayers[spectateFocus]

local STP = gPlayerSyncTable[0]
local STI = gPlayerSyncTable[spectateFocus]

local GST = gGlobalSyncTable

local LLS = gLakituState

free_camera = 0
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

ACT_SPECTATE = ACT_BUBBLED--allocate_mario_action(ACT_GROUP_CUTSCENE)
---@param m MarioState
function act_spectate(m)                            -- doesn't do much other than set visibility
  m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags | GRAPH_RENDER_INVISIBLE
  local np = gNetworkPlayers[m.playerIndex]
  if np.currAreaSyncValid and (np.currLevelNum == LEVEL_BOWSER_1 or np.currLevelNum == LEVEL_BOWSER_2 or np.currLevelNum == LEVEL_BOWSER_3 or (np.currLevelNum == LEVEL_SSL and np.currAreaIndex == 3)) then
    m.pos.x, m.pos.y, m.pos.z = 0, 10000, 0 -- as far away as possible
  elseif m.playerIndex ~= 0 and voice_chat_enabled then -- don't hear spectators, or always hear spectators, depending on which
    if gPlayerSyncTable[0].spectator ~= 1 then
      m.pos.x, m.pos.y, m.pos.z = 0, 10000, 0      -- as far away as possible
    else
      vec3f_copy(m.pos, gMarioStates[0].pos)
    end
  end

  vec3f_copy(m.marioObj.header.gfx.pos, {x = 0, y = 10000, z = 0})

  if SVtp == 0 and m.playerIndex == 0 and gPlayerSyncTable[0].spectator ~= 1 then
    set_mario_action(m, ACT_IDLE, 0)
  end
end

hook_mario_action(ACT_SPECTATE, act_spectate)

for Ci = 0, (Rmax - 1) do
  local p = gPlayerSyncTable[Ci]
  p.spectator = 0
end

local cData = {
  pos = { x = 0, y = 0, z = 0 },
  focus = { x = 0, y = 0, z = 0 },
  pitch = 0,
  yaw = 0,
  dist = 1000,
  goalPitch = 0,
  goalYaw = 0,
  goalDist = 1000,
}

function get_focus_pos()
  return cData.focus
end

hook_event(HOOK_USE_ACT_SELECT, function() if STP.spectator == 1 then return false end end) -- fix act select

function mario_dfm(m)
  if STP.spectator == 1 and free_camera == 1 and not is_menu_open() then
    local speed = 0

    --set_mario_animation(m, MARIO_ANIM_A_POSE)

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
      pos.x = pos.x -
          0.5 * speed * (sins(cData.yaw) * m.controller.stickY + sins(cData.yaw - 16384) * m.controller.stickX)
      pos.z = pos.z -
          0.5 * speed * (coss(cData.yaw) * m.controller.stickY + coss(cData.yaw - 16384) * m.controller.stickX)
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

    if voice_chat_enabled then
      vec3f_copy(m.pos, cData.focus)
    end

    return pos
  end
end

--- @param m MarioState
function mario_update_local(m)
  STP = gPlayerSyncTable[0]
  STI = gPlayerSyncTable[spectateFocus]
  GST = gGlobalSyncTable

  MSP = gMarioStates[0]
  MSI = gMarioStates[spectateFocus]

  LLS = gLakituState

  NPP = gNetworkPlayers[0]
  NPI = gNetworkPlayers[spectateFocus]

  NPM = gNetworkPlayers[m.playerIndex]

  if STP.spectator == 1 then
    if MSP.action ~= ACT_IN_CANNON and (MSP.action & ACT_GROUP_MASK ~= ACT_GROUP_CUTSCENE or MSP.action == ACT_SPAWN_SPIN_AIRBORNE or MSP.action == ACT_SPAWN_NO_SPIN_AIRBORNE) then
      set_mario_action(MSP, ACT_SPECTATE, 0)
    end

    MSP.marioObj.oIntangibleTimer = -1

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

    if not_spectating() then
      STP.spectator = 0
      free_camera = 0

      SVtp = 1
      reset_camera_fix_bug(MSP.area.camera)
    end

    if free_camera == 0 then
      if STI and ((teamFocus ~= -1 and STI.team ~= teamFocus) or STI.spectator == 1) then
        for a = 1, (Rmax - 1) do
          local sMario = gPlayerSyncTable[a]
          if sMario.team == teamFocus and sMario.spectator ~= 1 then
            spectateFocus = a
            STI = sMario
            break
          end
        end
      end

      if (MSP.controller.buttonPressed & L_JPAD) ~= 0 then
        spectateFocus = (spectateFocus + (Rmax - 1) - 2) % (Rmax - 1) + 1
        if (not gNetworkPlayers[spectateFocus].connected) or gPlayerSyncTable[spectateFocus].spectator == 1 then
          local oldI = spectateFocus
          spectateFocus = (spectateFocus + (Rmax - 1) - 2) % (Rmax - 1) + 1
          while oldI ~= spectateFocus do
            if gNetworkPlayers[spectateFocus].connected and gPlayerSyncTable[spectateFocus].spectator ~= 1 then break end
            spectateFocus = (spectateFocus + (Rmax - 1) - 2) % (Rmax - 1) + 1
          end
        end
        teamFocus = -1
        number = 0
      end

      if (MSP.controller.buttonPressed & R_JPAD) ~= 0 then
        spectateFocus = (spectateFocus + (Rmax - 1)) % (Rmax - 1) + 1
        if (not gNetworkPlayers[spectateFocus].connected) or gPlayerSyncTable[spectateFocus].spectator == 1 then
          local oldI = spectateFocus
          spectateFocus = (spectateFocus + (Rmax - 1)) % (Rmax - 1) + 1
          while oldI ~= spectateFocus do
            if gNetworkPlayers[spectateFocus].connected and gPlayerSyncTable[spectateFocus].spectator ~= 1 then break end
            spectateFocus = (spectateFocus + (Rmax - 1)) % (Rmax - 1) + 1
          end
        end
        teamFocus = -1
        number = 0
      end
    end

    if free_camera == 1 then
      number = 0
      if not is_game_paused() then
        mario_dfm(m)
      end
    elseif STI.spectator ~= 1 then
      vec3f_copy(cData.focus, MSI.pos)
      cData.focus.y = cData.focus.y + 120
    end

    update_spectator_camera(MSP, MSI)

    if free_camera == 0 and (number < 25 or not (STP.inActSelect or STI.inActSelect)) and (NPI.currLevelNum ~= NPP.currLevelNum or NPI.currAreaIndex ~= NPP.currAreaIndex or NPI.currActNum ~= NPP.currActNum) then
      number = number + 1
      if number >= 35 then
        number = 25

        if not warp_to_level(NPI.currLevelNum, NPI.currAreaIndex, NPI.currActNum) then -- these areas don't have an entrance node, so use their death nodes as the entrance
          warp_to_warpnode(NPI.currLevelNum, NPI.currAreaIndex, NPI.currActNum, 0xF0)
        end
      end
    elseif free_camera == 1 then
      number = 0
    end
  elseif SVtp == 3 then
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
  elseif SVtp == 2 then
    MSP.pos.x = SVposX
    MSP.pos.y = SVposY
    MSP.pos.z = SVposZ
    MSP.forwardVel = 0
    MSP.vel.x, MSP.vel.y, MSP.vel.z = 0, 0, 0
    MSP.peakHeight = SVposY -- to prevent fall damage death
    if (SVprevA & ACT_GROUP_SUBMERGED) ~= 0 then
      print("set to water")
      set_mario_action(MSP, ACT_WATER_IDLE, 0)
    elseif SVprevA & ACT_FLAG_AIR ~= 0 then
      print("set to fall")
      set_mario_action(MSP, ACT_FREEFALL, 0)
    else
      set_mario_action(MSP, ACT_IDLE, 0)
    end
    SVprevA = 0

    SVtp = 3
  elseif SVtp == 1 then
    if (GST.mhState ~= 1 and GST.mhState ~= 2) or GST.mhMode == 3 then
      MSP.health = 0x880
    else
      MSP.health = Shealth or 0x880
    end

    if not SVcln then
      MSP.health = 0x880
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

function mario_update(m)
  if m.playerIndex == 0 then
    mario_update_local(m)
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

  vec3f_copy(cData.focus, MSP.pos)
  cData.focus.y = cData.focus.y + 120
  if m.area.camera then
    cData.yaw = m.area.camera.yaw
  else
    cData.yaw = 0
  end
  Shealth = MSP.health
  STP.spectator = 1
  hide_hud = 0
  number = 0
  spectate = not (STP.forceSpectate or STP.dead)
  djui_chat_message_create(trans("spectator_controls"))
end

function render_spectated_power_meter()
  if STP.spectator == 1 and (not is_menu_open()) and free_camera == 0 and MSI and (gGlobalSyncTable.tagDist == 0 or not showHealth) then
    djui_hud_set_resolution(RESOLUTION_N64)
    local screenWidth = djui_hud_get_screen_width()
    local xposh = screenWidth * 0.5 - 51
    local yposh = 8

    render_power_meter_mariohunt(MSI.health, xposh, yposh, 64, 64, spectateFocus)
    djui_hud_set_resolution(RESOLUTION_DJUI)
  end
end

function spectated()
  if hide_hud == 0 then
    local n = spectateFocus

    djui_hud_set_font(FONT_MENU)
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_set_color(255, 255, 255, 255)

    local xlength = djui_hud_get_screen_width()
    local ylength = djui_hud_get_screen_height()

    local text

    if free_camera == 1 then
      text = trans("free_camera")
    elseif gNetworkPlayers[n].connected and gPlayerSyncTable[spectateFocus].spectator ~= 1 then
      text = remove_color(gNetworkPlayers[n].name)
    else
      local oldI = n
      n = (n + (Rmax - 1)) % (Rmax - 1) + 1
      while oldI ~= n do
        if gNetworkPlayers[spectateFocus].connected and gPlayerSyncTable[spectateFocus].spectator ~= 1 then break end
        n = (n + (Rmax - 1)) % (Rmax - 1) + 1
      end
      if oldI ~= n then
        spectateFocus = n
        text = remove_color(gNetworkPlayers[n].name)
      elseif not gNetworkPlayers[spectateFocus].connected then
        text = trans("empty", spectateFocus)
      else
        text = remove_color(gNetworkPlayers[n].name)
      end
    end

    local msglength = djui_hud_measure_text(text) / 2
    local xpos = xlength / 2 - msglength
    local ypos = ylength - ylength / 6

    djui_hud_print_text(text, xpos, ypos, 1)

    local text2 = trans("spectate_mode")

    local msglength2 = djui_hud_measure_text(text2) / 2 * 0.5
    local xpos2 = xlength / 2 - msglength2
    local ypos2 = ylength - ylength / 10

    djui_hud_print_text(text2, xpos2, ypos2, 0.5)

    MSP.health = 0x880
    STI = gPlayerSyncTable[spectateFocus]
    if STI.spectator == 1 and free_camera == 0 then
      djui_hud_set_color(255, 0, 0, 255)

      local text3 = trans("is_spectator")

      local msglength3 = djui_hud_measure_text(text3) / 2 * 0.5
      local xpos3 = xlength / 2 - msglength3
      local ypos3 = ylength - ylength / 5

      djui_hud_print_text(text3, xpos3, ypos3, 0.5)
    else
      teamFocus = STI.team or 0
    end
  end
end

function not_spectating()
  if STP.forceSpectate or STP.dead then
    return false
  end
  return (STP.team == 1 and (GST.mhState == 1 or GST.mhState == 2)) or not (spectate and GST.allowSpectate)
end

function spectate_valid_for_guard()
  if GST.mhMode ~= 3 or STP.spectator ~= 1 then return false end

  local valid = (free_camera ~= 1)
  local sMario = gPlayerSyncTable[spectateFocus]
  if valid and ((not gNetworkPlayers[spectateFocus].connected) or sMario.spectator == 1 or sMario.dead or sMario.team ~= STP.team) then
    valid = false
  end

  -- get closest to focus
  if not valid then
    local maxDist = 10000
    local guard = 0
    for i = 1, MAX_PLAYERS - 1 do
      local m = gMarioStates[i]
      local sMario = gPlayerSyncTable[i]
      local dist = dist_between_object_and_point(m.marioObj, cData.focus.x, cData.focus.y, cData.focus.z)
      if is_player_active(m) == 0 or sMario.spectator == 1 or sMario.dead or sMario.team ~= STP.team or get_synced_timer_value(gPlayerSyncTable, "guardTime", i) ~= 0 then
        -- nothing
      elseif dist < maxDist then
        guard = i
        maxDist = dist
      end
    end
    if guard == 0 then return false end
    return guard
  end

  return spectateFocus
end

function spectated_update()
  if STP.spectator == 1 and not is_menu_open() then
    spectated()
  end
end

-- screw it I'm writing my own camera code
function update_spectator_camera(m, s)
  vec3f_copy(LLS.focus, cData.focus)
  vec3f_copy(LLS.curFocus, cData.focus)
  vec3f_copy(LLS.goalFocus, cData.focus)
  vec3f_copy(m.area.camera.focus, cData.focus)
  if s and (m.currentRoom ~= s.currentRoom or voice_chat_enabled) and free_camera == 0 and m.area.localAreaTimer > 30 and (s.action ~= ACT_DEATH_EXIT) then
    vec3f_copy(m.pos, s.pos)
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
  if m.area.camera and m.area.camera.pos then
    vec3f_copy(m.area.camera.pos, cData.pos)
    m.area.camera.yaw = cData.yaw
  end

  if not is_game_paused() then
    local x_invert = 1
    local y_invert = -1
    if camera_config_is_free_cam_enabled() == camera_config_is_x_inverted() then
      x_invert = -1
    end
    if camera_config_is_free_cam_enabled() and camera_config_is_y_inverted() then
      y_invert = 1
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
        stickX = clamp(stickX + 128, -128, 128)
      end
      if (m.controller.buttonDown & L_CBUTTONS) ~= 0 then
        stickX = clamp(stickX - 128, -128, 128)
      end
    end
    if m.controller.extStickY == 0 then
      if (m.controller.buttonDown & U_CBUTTONS) ~= 0 then
        stickY = clamp(stickY + 128, -128, 128)
      end
      if (m.controller.buttonDown & D_CBUTTONS) ~= 0 then
        stickY = clamp(stickY - 128, -128, 128)
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
      cData.goalYaw = limit_angle(cData.goalYaw -
        (0.6 * stickX - mouseX) * (x_invert * camera_config_get_x_sensitivity()))
      cData.goalPitch = clamp(cData.goalPitch - (0.6 * stickY + mouseY) * (y_invert * camera_config_get_y_sensitivity()),
        -0x3E00, 0x3E00)

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
  cData.yaw = approach_s16_symmetric(cData.yaw, cData.goalYaw,
    math.min(0x500, math.abs(limit_angle(cData.goalYaw - cData.yaw)) / 5)) -- limit rotation to 0x500 for possibly less motion sickness
  cData.pitch = approach_s16_symmetric(cData.pitch, cData.goalPitch,
    math.abs(limit_angle(cData.goalPitch - cData.pitch)) /
    5)
  if math.abs(cData.goalYaw - cData.yaw) < 10 then
    cData.yaw = cData.goalYaw
  end
  if math.abs(cData.goalPitch - cData.pitch) < 10 then
    cData.pitch = cData.goalPitch
  end
  cData.dist = cData.dist + (cData.goalDist - cData.dist) / 5
end

-- from extended moveset
function limit_angle(a)
  return (a + 0x8000) % 0x10000 - 0x8000
end

-- the command
function spectate_command(msg)
  local m = gMarioStates[0]
  local sMario = gPlayerSyncTable[0]
  if not (gGlobalSyncTable.allowSpectate or sMario.forceSpectate or sMario.dead) then
    djui_chat_message_create(trans("spectate_disabled"))
    return true
  elseif sMario.team == 1 and sMario.spectator ~= 1 and (not sMario.dead) and (gGlobalSyncTable.mhState == 1 or gGlobalSyncTable.mhState == 2) then
    djui_chat_message_create(trans("hunters_only"))
    return true
  end

  teamFocus = -1
  if msg == "free" then
    free_camera = 1
    enable_spectator(m)
    return true
  elseif msg == "" then
    local validRunnerTarget = get_targetted_runner()
    if validRunnerTarget == -1 then
      free_camera = 1
    else
      teamFocus = 1
      spectateFocus = validRunnerTarget
      free_camera = 0
    end
    enable_spectator(m)
    return true
  elseif string.lower(msg) == "off" then
    if GST.mhMode == 3 then
      djui_chat_message_create(trans("wrong_mode"))
      return true
    elseif sMario.forceSpectate or sMario.dead then
      djui_chat_message_create(trans("not_mod"))
      return true
    end
    spectate = false
    djui_chat_message_create(trans("spectate_off"))
    return true
  end

  if string.lower(msg) == "runner" or string.lower(msg) == "hunter" then
    teamFocus = bool_to_int(string.lower(msg) == "runner")
    spectateFocus = 1
    for a = 1, (Rmax - 1) do
      local sMario = gPlayerSyncTable[a]
      if sMario.team == teamFocus and sMario.spectator ~= 1 then
        spectateFocus = a
        break
      end
    end
    free_camera = 0
    enable_spectator(m)
    return true
  end

  local playerID, np = get_specified_player(msg)

  if playerID == 0 then
    djui_chat_message_create(trans("spectate_self"))
    return true
  end

  if not playerID then
    return true
  end
  free_camera = 0
  spectateFocus = playerID
  enable_spectator(m)
  return true
end

hook_chat_command("spectate", trans("spectate_desc"), spectate_command)

hook_event(HOOK_ON_HUD_RENDER, spectated_update)
hook_event(HOOK_ON_HUD_RENDER_BEHIND, render_spectated_power_meter)
hook_event(HOOK_MARIO_UPDATE, mario_update)
