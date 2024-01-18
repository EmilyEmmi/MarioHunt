-- localize common functions
local djui_chat_message_create,network_send,tonumber = djui_chat_message_create,network_send,tonumber

-- main command
function mario_hunt_command(msg)
  if not has_mod_powers(0) and msg ~= "unmod" and msg ~= "" and msg ~= "menu" then
    djui_chat_message_create(trans("not_mod"))
    return true
  elseif not marioHuntCommands or #marioHuntCommands < 1 then
    setup_commands()
  end

  local args = split(msg," ",2)
  local usedCmd = args[1] or ""
  local data = args[2] or ""
  --djui_chat_message_create("!"..usedCmd.."! !"..data.."!")
  if usedCmd == "" or usedCmd == "menu" then
    if not is_game_paused() then
      if menu then
        close_menu()
      else
        menu_reload()
        menu = true
        menu_enter()
      end
    end
    return true
  elseif usedCmd == "help" then
    local cmdPerPage = 3

    if not tonumber(data) and data ~= "" then
      local foundCommand = false
      for i,cdata in ipairs(marioHuntCommands) do
        if cdata[1] == data or cdata[2] == data then
          local desc = trans(cdata[1] .. "_desc")
          local hidden = false
          if cdata[4] == true then
            if not has_mod_powers(0,true) then
              hidden = true
            end
          end

          if not hidden then
            foundCommand = true
            djui_chat_message_create("/mh " .. cdata[1] .. " " .. desc)
          end
          break
        end
      end
      if not foundCommand then
        djui_chat_message_create(trans("bad_command"))
      end
      return true
    end
    local page = tonumber(usedCmd) or tonumber(data) or 1
    page = math.floor(page)
    local maxPage = 9
    if has_mod_powers(0,true) then maxPage = math.ceil(#marioHuntCommands / cmdPerPage) end

    if page > maxPage then
      page = maxPage
    elseif page < 1 then
      page = 1
    end

    djui_chat_message_create(trans("page",page,maxPage))
    for i,cdata in ipairs(marioHuntCommands) do
      if i > (page-1) * cmdPerPage and i <= page * cmdPerPage then
        local desc = trans(cdata[1] .. "_desc")
        local hidden = false
        if cdata[4] == true then
          if not has_mod_powers(0,true) then
            hidden = true
          end
        end

        if not hidden then
          djui_chat_message_create("/mh " .. cdata[1] .. " " .. desc)
        end
      elseif i > (page + 1) * 5 then
        break
      end
    end
  else
    local cmd = nil
    for i,cdata in ipairs(marioHuntCommands) do
      if cdata[1] == usedCmd or cdata[2] == usedCmd then
        cmd = cdata
        break
      end
    end
    if cmd then
      local func = cmd[3]

      if (not func(data)) then
        djui_chat_message_create(trans("bad_param"))
      end
    else
      djui_chat_message_create(trans("bad_command"))
      return true
    end
  end
  return true
end

-- start game
function start_game(msg)
  -- count runners
  local runners = 0
  for i=0,(MAX_PLAYERS-1) do
    if gPlayerSyncTable[i].team == 1 and gNetworkPlayers[i].connected then
      runners = runners + 1
    end
  end

  if runners < 1 then
    if gGlobalSyncTable.mhMode ~= 2 then
      djui_chat_message_create(trans("error_no_runners"))
      return true
    else
      local singlePlayer = true
      for i=1,MAX_PLAYERS-1 do
        local np = gNetworkPlayers[i]
        local sMario = gPlayerSyncTable[i]
        if np.connected and sMario.spectator ~= 1 then
          singlePlayer = false
          break
        end
      end
      if singlePlayer then
        become_runner(gPlayerSyncTable[0])
      else
        djui_chat_message_create(trans("error_no_runners"))
        return true
      end
    end
  end

  local cmd = msg
  if cmd == "" then cmd = "none" end
  network_send_include_self(true, {
    id = PACKET_MH_START,
    cmd = cmd,
  })
  return true
end

-- runs network_send and also the respective function for this user
function network_send_include_self(reliable, data)
    network_send(reliable, data)
    sPacketTable[data.id](data, true)
end

function change_team_command(msg)
  local playerID,np = get_specified_player(msg)
  if not playerID then return true end

  local sMario = gPlayerSyncTable[playerID]
  if sMario.team ~= 1 then
    become_runner(sMario)
  else
    become_hunter(sMario)
  end
  network_send_include_self(false, {id = PACKET_ROLE_CHANGE, index = np.globalIndex})
  return true
end

function set_life_command(msg)
  local args = split(msg, " ")
  local lookingFor = ""
  local lives = args[1] or "no"
  if args[2] then
    lookingFor = args[1]
    lives = args[2]
  end

  lives = tonumber(lives)
  if not lives or lives < 0 or lives > 100 or math.floor(lives) ~= lives then
    return false
  end

  local playerID,np = get_specified_player(lookingFor)
  if not playerID then return true end

  local sMario = gPlayerSyncTable[playerID]
  local name = remove_color(np.name)
  if gGlobalSyncTable.mhState == 0 then
    djui_chat_message_create(trans("not_started"))
  elseif sMario.runnerLives then
    sMario.runnerLives = lives
    djui_chat_message_create(trans_plural("set_lives",name,lives))
  else
    djui_chat_message_create(trans("not_runner",name))
  end
  return true
end

function allow_leave_command(msg)
  local playerID,np = get_specified_player(msg)
  if not playerID then return true end

  local sMario = gPlayerSyncTable[playerID]
  local name = remove_color(np.name)
  sMario.allowLeave = true
  djui_chat_message_create(trans("may_leave",name))
  return true
end

function add_runner(msg)
  local runners = tonumber(msg)
  if msg == "" or msg == 0 or msg == "auto" then
    runners = 0 -- TBD
  elseif not runners or runners ~= math.floor(runners) or runners < 1 then
    return false
  end

  -- get current hunters
  local currHunterIDs = {}
  local goodHunterIDs = {}
  local runners_available = 0
  local currPlayers = 0
  local currRunners = 0
  for i=0,(MAX_PLAYERS-1) do
    local np = gNetworkPlayers[i]
    local sMario = gPlayerSyncTable[i]
    if np.connected and (sMario.spectator ~= 1 or sMario.team == 1) then
      if sMario.team ~= 1 then
        if sMario.beenRunner == 0 then
          runners_available = runners_available + 1
          table.insert(goodHunterIDs, np.localIndex)
        end
        table.insert(currHunterIDs, np.localIndex)
      else
        currRunners = currRunners + 1
      end
      currPlayers = currPlayers + 1
    end
  end

  if runners == 0 then
    runners = ideal_runners(currPlayers)-currRunners
    if runners <= 0 then
      djui_chat_message_create(trans("no_runners_added"))
      return true
    end
  end

  if #currHunterIDs < (runners + 1) then
    djui_chat_message_create(trans("must_have_one"))
    return true
  elseif runners_available < runners then -- if everyone has been a runner before, ignore recent status
    print("Not enough recent runners! Ignoring recent status")
    goodHunterIDs = currHunterIDs
  end

  local runnerNames = {}
  for i=1,runners do
    local selected = math.random(1, #goodHunterIDs)
    local lIndex = goodHunterIDs[selected]
    local sMario = gPlayerSyncTable[lIndex]
    local np = gNetworkPlayers[lIndex]
    become_runner(sMario)
    network_send_include_self(false, {id = PACKET_ROLE_CHANGE, index = np.globalIndex})
    table.insert(runnerNames, remove_color(np.name))
    table.remove(goodHunterIDs, selected)
  end

  local text = trans("added")
  for i=1,#runnerNames do
    text = text .. runnerNames[i] .. ", "
  end
  text = text:sub(1,-3)
  djui_chat_message_create(text)
  return true
end

function runner_randomize(msg)
  local runners = tonumber(msg)
  if not msg or msg == "" or msg == 99 or msg == 0 or msg == "auto" then
    runners = 0 -- TBD
  elseif not (runners or runners ~= math.floor(runners) or runners < 1) then
    return false
  end

  -- get current hunters
  local currPlayerIDs = {}
  local goodPlayerIDs = {}
  local runners_available = 0
  for i=0,(MAX_PLAYERS-1) do
    local np = gNetworkPlayers[i]
    local sMario = gPlayerSyncTable[i]
    become_hunter(sMario)
    if np.connected and sMario.spectator ~= 1 then
      if sMario.beenRunner == 0 then
        runners_available = runners_available + 1
        table.insert(goodPlayerIDs, np.localIndex)
      end
      table.insert(currPlayerIDs, np.localIndex)
    end
  end

  if runners == 0 then
    runners = ideal_runners(#currPlayerIDs)
    if runners <= 0 then
      djui_chat_message_create(trans("must_have_one"))
      return true
    end
  end

  if #currPlayerIDs < (runners + 1) then
    djui_chat_message_create(trans("must_have_one"))
    return true
  elseif runners_available < runners then -- if everyone has been a runner before, ignore recent status
    print("Not enough recent runners! Ignoring recent status")
    goodPlayerIDs = currPlayerIDs
  end

  local runnerNames = {}
  for i=1,runners do
    local selected = math.random(1, #goodPlayerIDs)
    local lIndex = goodPlayerIDs[selected]
    local sMario = gPlayerSyncTable[lIndex]
    local np = gNetworkPlayers[lIndex]
    become_runner(sMario)
    network_send_include_self(false, {id = PACKET_ROLE_CHANGE, index = np.globalIndex})
    table.insert(runnerNames, remove_color(np.name))
    table.remove(goodPlayerIDs, selected)
  end

  local text = trans("runners_are")
  for i=1,#runnerNames do
    text = text .. runnerNames[i] .. ", "
  end
  text = text:sub(1,-3)
  djui_chat_message_create(text)
  return true
end

-- calculate good amount of runners (40% except when there's 5)
function ideal_runners(num)
  if num == 5 then return 1 end -- exception

  return math.max(1, math.floor(num * 0.4))
end

function become_runner(sMario)
  sMario.team = 1
  sMario.runnerLives = gGlobalSyncTable.runnerLives
  sMario.runTime = 0
  sMario.allowLeave = false
end

function become_hunter(sMario)
  sMario.team = 0
  sMario.runnerLives = nil
  sMario.runTime = nil
  sMario.allowLeave = false
end

function runner_lives(msg)
  local num = tonumber(msg)
  if num and num >= 0 and num <= 99 and math.floor(num) == num then
    gGlobalSyncTable.runnerLives = num
    djui_chat_message_create(trans("set_lives_total",num))
    return true
  end
  return false
end

function time_needed_command(msg)
  if gGlobalSyncTable.starMode and gGlobalSyncTable.mhMode ~= 2 then
    djui_chat_message_create(trans("wrong_mode"))
    return true
  end
  local num = tonumber(msg)
  if num then
    gGlobalSyncTable.runTime = math.floor(num * 30)
    if gGlobalSyncTable.mhMode ~= 2 then
      djui_chat_message_create(trans("need_time_feedback",num))
    else
      djui_chat_message_create(trans("game_time",num))
    end
    return true
  end
  return false
end

function stars_needed_command(msg)
  if not gGlobalSyncTable.starMode or gGlobalSyncTable.mhMode == 2 then
    djui_chat_message_create(trans("wrong_mode"))
    return true
  end
  local num = tonumber(msg)
  if num and num >= 0 and num < 8 then
    gGlobalSyncTable.runTime = num
    djui_chat_message_create(trans("need_stars_feedback",num))
    return true
  end
  return false
end

function auto_command(msg)
  local num = tonumber(msg)
  if string.lower(msg) == "on" then
    num = 99
  elseif string.lower(msg) == "off" then
    num = 0
  elseif not num or math.floor(num) ~= num then
    return false
  elseif num > (MAX_PLAYERS-1) then
    djui_chat_message_create(trans("must_have_one"))
    return true
  end

  if num == 99 then
    gGlobalSyncTable.gameAuto = 99
    djui_chat_message_create(trans("auto_on"))
    if gGlobalSyncTable.mhState == 0 then
      gGlobalSyncTable.mhTimer = 20 * 30 -- 20 seconds
    end
  elseif num > 0 then
    gGlobalSyncTable.gameAuto = num
    local runners = trans("runners")
    if num == 1 then runners = trans("runner") end
    djui_chat_message_create(string.format("%s (%d %s)",trans("auto_on"),num,runners))
    if gGlobalSyncTable.mhState == 0 then
      gGlobalSyncTable.mhTimer = 20 * 30 -- 20 seconds
    end
  else
    gGlobalSyncTable.gameAuto = 0
    djui_chat_message_create(trans("auto_off"))
    if gGlobalSyncTable.mhState == 0 then
      gGlobalSyncTable.mhTimer = 0 -- don't set
    end
  end
  return true
end

function star_count_command(msg)
  local num = tonumber(msg)
  if msg and not num and msg:lower() == "any" then num = -1 end
  if num and num >= -1 and num <= ROMHACK.max_stars and math.floor(num) == num then
    if gGlobalSyncTable.noBowser and num < 1 then
      return false
    end
    gGlobalSyncTable.starRun = num
    if num ~= -1 then
      djui_chat_message_create(trans("new_category",num))
    else
      djui_chat_message_create(trans("new_category_any"))
    end
    return true
  end
  return false
end

function change_game_mode(msg,mode)
  local prevMode = gGlobalSyncTable.mhMode
  local miniSwitch = false
  if prevMode == mode then return true end

  if mode == 0 or string.lower(msg) == "normal" then
    gGlobalSyncTable.mhMode = 0
    miniSwitch = (gGlobalSyncTable.mhMode == 2) ~= (prevMode == 2)

    -- defaults
    gGlobalSyncTable.runnerLives = 1
    if miniSwitch then
      gGlobalSyncTable.runTime = 7200 -- 4 minutes
      gGlobalSyncTable.anarchy = 0
      gGlobalSyncTable.dmgAdd = 0
      if gGlobalSyncTable.starMode then gGlobalSyncTable.runTime = 2 end
      gGlobalSyncTable.gameAuto = 0
    end
    
    omm_disable_mode_for_minihunt(false)
  elseif mode == 1 or string.lower(msg) == "swap" or string.lower(msg) == "switch" then
    gGlobalSyncTable.mhMode = 1
    miniSwitch = (gGlobalSyncTable.mhMode == 2) ~= (prevMode == 2)

    -- defaults
    gGlobalSyncTable.runnerLives = 0
    if miniSwitch then
      gGlobalSyncTable.runTime = 7200 -- 4 minutes
      gGlobalSyncTable.anarchy = 0
      gGlobalSyncTable.dmgAdd = 0
      if gGlobalSyncTable.starMode then gGlobalSyncTable.runTime = 2 end
      gGlobalSyncTable.gameAuto = 0
    end
    
    omm_disable_mode_for_minihunt(false)
  elseif mode == 2 or string.lower(msg) == "mini" then
    local np = gNetworkPlayers[0]
    gGlobalSyncTable.mhMode = 2
    miniSwitch = (gGlobalSyncTable.mhMode == 2) ~= (prevMode == 2)
    
    -- defaults
    gGlobalSyncTable.runnerLives = 0
    if miniSwitch then
      gGlobalSyncTable.runTime = 9000 -- 5 minutes
      gGlobalSyncTable.anarchy = 1
      gGlobalSyncTable.dmgAdd = 2
      gGlobalSyncTable.gameAuto = 0
    end

    gGlobalSyncTable.gameLevel = np.currLevelNum
    gGlobalSyncTable.getStar = np.currActNum
    omm_disable_mode_for_minihunt(true)
  else
    return false
  end

  -- only reload settings if we changed from mini to standard or vice versa
  if miniSwitch then
    load_settings(true)
  else -- load lives setting only
    load_settings(false, false, true)
  end
  return true
end

-- TroopaParaKoopa's pause mod
function pause_command(msg)
  if msg == "all" or not msg or msg == "" then
    if gGlobalSyncTable.pause then
      gGlobalSyncTable.pause = false
      for i=0,(MAX_PLAYERS-1) do
        gPlayerSyncTable[i].pause = false
      end
      djui_chat_message_create(trans("all_unpaused"))
    else
      gGlobalSyncTable.pause = true
      for i=0,(MAX_PLAYERS-1) do
        gPlayerSyncTable[i].pause = true
      end
      djui_chat_message_create(trans("all_paused"))
    end
    return true
  end

  local playerID,np = get_specified_player(msg)
  if not playerID then return true end

  local sMario = gPlayerSyncTable[playerID]
  local name = remove_color(np.name)
  if sMario.pause then
    sMario.pause = false
    djui_chat_message_create(trans("player_unpaused",name))
  else
    sMario.pause = true
    djui_chat_message_create(trans("player_paused",name))
  end
  return true
end

-- gets the name and color of the user's role (color is either a table or string)
function get_role_name_and_color(sMario)
  local roleName = ""
  local color = {r = 255, g = 92, b = 92} -- red
  local colorString = "\\#ff5a5a\\"
  if sMario.team == 1 then
    if sMario.hard == 1 then
      color = {r = 255, g = 255, b = 92} -- yellow
      colorString = "\\#ffff5a\\"
    elseif sMario.hard == 2 then
      color = {r = 180, g = 92, b = 255} -- purple
      colorString = "\\#b45aff\\"
    else
      color = {r = 0, g = 255, b = 255} -- cyan
      colorString = "\\#00ffff\\"
    end
    roleName = trans("runner")
  elseif not sMario.team then -- joining
    color = {r = 169, g = 169, b = 169} -- grey
    colorString = "\\#a9a9a9\\"
    roleName = trans("menu_unknown")
  elseif sMario.spectator ~= 1 then
    roleName = trans("hunter")
  else
    color = {r = 169, g = 169, b = 169} -- grey
    colorString = "\\#a9a9a9\\"
    roleName = trans("spectator")
  end
  return roleName,colorString,color
end

function set_lobby_music(month)
  if noSeason or (month ~= 10 and month ~= 12) then
    set_background_music(0,custom_seq,0)
  elseif month == 10 then
    set_background_music(0,SEQ_LEVEL_SPOOKY,0)
  else
    set_background_music(0,SEQ_LEVEL_SNOW,0)
  end
end

-- some minor conversion functions
function bool_to_int(bool)
  return (bool and 1) or 0
end

function is_zero(int)
  return (int == 0 and 1) or 0
end

-- linear interpolation
function lerp(a, b, t)
  return a * (1-t) + b * t
end

-- custom bubble action, with some code from the base game bubble action
ACT_MH_BUBBLE_RETURN = allocate_mario_action(ACT_GROUP_CUTSCENE | ACT_FLAG_PAUSE_EXIT)
---@param m MarioState
function act_bubble_return(m)
  -- create bubble
  if (not m.bubbleObj and m.playerIndex == 0) then
    m.bubbleObj = spawn_non_sync_object(id_bhvStaticObject, E_MODEL_BUBBLE_PLAYER, m.pos.x, m.pos.y + 50, m.pos.z, nil)
    if m.bubbleObj then
        m.bubbleObj.heldByPlayerIndex = m.playerIndex
    end
  end

  -- force inactive state
  if m.heldObj then mario_drop_held_object(m) end
  m.heldByObj = nil
  m.marioObj.oIntangibleTimer = -1
  m.squishTimer = 0
  m.bounceSquishTimer = 0
  m.quicksandDepth = 0
  set_mario_animation(m, MARIO_ANIM_BEING_GRABBED)

  m.actionTimer = m.actionTimer + 1
  m.faceAngle.x = 0
  if m.actionTimer < 15 or (m.playerIndex ~= 0 and m.actionTimer >= 45) then
    vec3f_copy(m.marioObj.header.gfx.pos, m.pos)
    vec3s_copy(m.marioObj.header.gfx.angle, m.faceAngle)
    return
  elseif m.playerIndex ~= 0 then
    m.pos.x = m.pos.x + m.vel.x
    m.pos.y = m.pos.y + m.vel.y
    m.pos.z = m.pos.z + m.vel.z
    vec3f_copy(m.marioObj.header.gfx.pos, m.pos)
    vec3s_copy(m.marioObj.header.gfx.angle, m.faceAngle)
    return
  end

  local goToPos = {x = 0, y = 0, z = 0}
  if prevSafePos.obj and (prevSafePos.obj.oVelX ~= 0 or prevSafePos.obj.oVelY ~= 0 or prevSafePos.obj.oVelZ ~= 0) then
    prevSafePos.x = prevSafePos.obj.oPosX
    prevSafePos.y = prevSafePos.obj.oPosY
    prevSafePos.z = prevSafePos.obj.oPosZ
  end
  vec3f_copy(goToPos, prevSafePos)
  goToPos.y = goToPos.y + 200
  if m.actionTimer < 45 then
    m.vel.x = (goToPos.x-m.pos.x)//10
    m.vel.y = (goToPos.y-m.pos.y)//10
    m.vel.z = (goToPos.z-m.pos.z)//10
    m.pos.x = m.pos.x + m.vel.x
    m.pos.y = m.pos.y + m.vel.y
    m.pos.z = m.pos.z + m.vel.z
  else
    m.faceAngle.x = 0
    vec3f_copy(m.pos, goToPos)
  end
  vec3f_copy(m.marioObj.header.gfx.pos, m.pos)
  vec3s_copy(m.marioObj.header.gfx.angle, m.faceAngle)
  bubbled_offset_visual(m)
  if m.bubbleObj then
    m.bubbleObj.oPosX = m.pos.x
    m.bubbleObj.oPosY = m.pos.y + 50
    m.bubbleObj.oPosZ = m.pos.z
  end

  if m.actionTimer > 60 then
    vec3f_copy(m.pos, goToPos)
    m.vel.x,m.vel.y,m.vel.z = 0,-60,0
    if m.input & INPUT_NONZERO_ANALOG ~= 0 then
      m.forwardVel = 5
      m.faceAngle.y = m.intendedYaw
    else
      m.forwardVel = 0
    end
    obj_mark_for_deletion(m.bubbleObj)
    m.bubbleObj = nil
    m.particleFlags = m.particleFlags | PARTICLE_MIST_CIRCLE
    play_sound(SOUND_OBJ_DIVING_IN_WATER, m.pos)
    m.invincTimer = 70
    m.marioObj.oIntangibleTimer = 0
    if m.waterLevel > m.pos.y then
      set_mario_action(m, ACT_WATER_IDLE, 0)
    elseif m.floor.type == SURFACE_DEATH_PLANE or m.floor.type == SURFACE_INSTANT_QUICKSAND then
      set_mario_action(m, ACT_TRIPLE_JUMP, 0)
    else
      set_mario_action(m, ACT_SOFT_BONK, 0)
    end
  end
end
hook_mario_action(ACT_MH_BUBBLE_RETURN, act_bubble_return)

-- from base code
function bubbled_offset_visual(m)
  if not m then return end
  -- scary 3d trig ahead

  local forwardOffset = 25;
  local upOffset = -35;

  -- figure out forward vector
  local forward = {
      x = sins(m.faceAngle.y) * coss(m.faceAngle.x),
      y = -sins(m.faceAngle.x),
      z = coss(m.faceAngle.y) * coss(m.faceAngle.x),
  };
  vec3f_normalize(forward);

  -- figure out right vector
  local globalUp = { x = 0, y = 1, z = 0 };
  local right = { x = 0, y = 0, z = 0 };
  vec3f_cross(right, forward, globalUp);
  vec3f_normalize(right);

  -- figure out up vector
  local up = { x = 0, y = 0, z = 0 };
  vec3f_cross(up, right, forward);
  vec3f_normalize(up);

  -- offset forward direction
  vec3f_mul(forward, forwardOffset);
  vec3f_add(m.marioObj.header.gfx.pos, forward);

  -- offset up direction
  vec3f_mul(up, upOffset);
  vec3f_add(m.marioObj.header.gfx.pos, up);

  -- offset global up direction
  m.marioObj.header.gfx.pos.y = m.marioObj.header.gfx.pos.y - upOffset;
end