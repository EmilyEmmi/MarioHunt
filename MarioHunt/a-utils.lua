-- localize common functions
local djui_chat_message_create, network_send, tonumber = djui_chat_message_create, network_send, tonumber

-- main command
function mario_hunt_command(msg)
  if not has_mod_powers(0) and msg ~= "unmod" and msg ~= "" and msg ~= "menu" then
    djui_chat_message_create(trans("not_mod"))
    return true
  elseif not marioHuntCommands or #marioHuntCommands < 1 then
    setup_commands()
  end

  local args = split(msg, " ", 2)
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
      for i, cdata in ipairs(marioHuntCommands) do
        if cdata[1] == data or cdata[2] == data then
          local desc = trans(cdata[1] .. "_desc")
          local hidden = false
          if cdata[4] == true then
            if not has_mod_powers(0, true) then
              hidden = true
            else
              desc = trans("debug_" .. cdata[1] .. "_desc")
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
    if has_mod_powers(0, true) then maxPage = math.ceil(#marioHuntCommands / cmdPerPage) end

    if page > maxPage then
      page = maxPage
    elseif page < 1 then
      page = 1
    end

    djui_chat_message_create(trans("page", page, maxPage))
    for i, cdata in ipairs(marioHuntCommands) do
      if i > (page - 1) * cmdPerPage and i <= page * cmdPerPage then
        local desc = ""
        local hidden = false
        if cdata[4] == true then
          if not has_mod_powers(0, true) then
            hidden = true
          else
            desc = trans("debug_" .. cdata[1] .. "_desc")
          end
        else
          desc = trans(cdata[1] .. "_desc")
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
    for i, cdata in ipairs(marioHuntCommands) do
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
  local hunters = 0
  local nonSoloRunner = false
  for i = 0, (MAX_PLAYERS - 1) do
    if gNetworkPlayers[i].connected and not gPlayerSyncTable[i].forceSpectate then
      if gPlayerSyncTable[i].team == 1 then
        runners = runners + 1
        if i ~= 0 then
          nonSoloRunner = true
        end
      else
        hunters = hunters + 1
      end
    end
  end

  local challenge = false
  if (not nonSoloRunner) and gGlobalSyncTable.mhMode == 2 and not (gServerSettings.headlessServer and gServerSettings.headlessServer ~= 0) then
    local singlePlayer = true
    for i = 1, MAX_PLAYERS - 1 do
      local np = gNetworkPlayers[i]
      local sMario = gPlayerSyncTable[i]
      if np.connected and sMario.spectator ~= 1 then
        singlePlayer = false
        break
      end
    end
    if singlePlayer then
      if (msg == 1 or msg == "1") and gGlobalSyncTable.romhackFile == "vanilla" then
        challenge = true
      end
      become_runner(gPlayerSyncTable[0])
    elseif runners < 1 then
      djui_chat_message_create(trans("error_no_runners"))
      return true
    end
  elseif runners < 1 then
    djui_chat_message_create(trans("error_no_runners"))
    return true
  end

  if gGlobalSyncTable.mhMode == 3 and hunters <= 0 then
    if runners <= 1 and (not DEBUG_NO_VICTORY) then
      djui_chat_message_create(trans("must_have_one"))
      return true
    elseif not runner_randomize(gGlobalSyncTable.lastRandomRoles) then
      return true
    end
  end

  local cmd = msg
  if cmd == "" then cmd = "none" end
  network_send_include_self(true, {
    id = PACKET_MH_START,
    cmd = cmd,
    challenge = challenge,
  })
  return true
end

-- runs network_send and also the respective function for this user
function network_send_include_self(reliable, data)
  network_send(reliable, data)
  sPacketTable[data.id](data, true)
end

-- get who our current targetted runner is
function get_targetted_runner()
  local sMario0 = gPlayerSyncTable[0]
  --[[ target is ignored if:
    - The target index is not between 1 and MAX_PLAYERS (16)
    - We're not a Hunter
    - We're playing MiniHunt or MysteryHunt
  ]]
  if runnerTarget == nil or runnerTarget <= 0 or runnerTarget >= MAX_PLAYERS or gGlobalSyncTable.mhMode == 2 or gGlobalSyncTable.mhMode == 3 or sMario0.team == 1 then
    return -1
  end

  -- Target is also ignored if they are not connected, not a runner, or dead
  local np = gNetworkPlayers[runnerTarget]
  local sMario = gPlayerSyncTable[runnerTarget]
  if (not np.connected) or sMario.team ~= 1 or sMario.dead then
    return -1
  end
  return runnerTarget
end

-- match time with other runners in this level
function match_runner_time(index, neededRunTime_, localRunTime_)
  local sMario = gPlayerSyncTable[index]
  local np = gNetworkPlayers[index]
  local neededRunTime, localRunTime = neededRunTime_, localRunTime_
  for i = 1, (MAX_PLAYERS - 1) do
    if (gPlayerSyncTable[i].team == 1 or gGlobalSyncTable.mhMode == 3) and gPlayerSyncTable[i].spectator ~= 1 and gNetworkPlayers[i].connected then
      local theirNP = gNetworkPlayers[i] -- daft variable naming conventions
      local theirSMario = gPlayerSyncTable[i]
      if theirSMario.runTime and (theirNP.currLevelNum == np.currLevelNum) and (theirNP.currActNum == np.currActNum) and localRunTime < theirSMario.runTime then
        local prevRunTime = localRunTime
        localRunTime = theirSMario.runTime
        neededRunTime, localRunTime = calculate_leave_requirements(sMario, localRunTime)
        -- 30 seconds (or run time) minimum for bowser stages
        local minTime = math.min(30 * 30, gGlobalSyncTable.runTime)
        if (not gGlobalSyncTable.starMode) and neededRunTime - localRunTime < minTime
        and (np.currCourseNum == COURSE_BITDW or np.currCourseNum == COURSE_BITFS or np.currCourseNum == COURSE_BITS) then
          localRunTime = math.min(neededRunTime - minTime, prevRunTime)
        end
      end
    end
  end
  return neededRunTime, localRunTime
end

function change_team_command(msg)
  local playerID, np = get_specified_player(msg)
  if not playerID then return true end

  local sMario = gPlayerSyncTable[playerID]
  if sMario.team ~= 1 then
    become_runner(sMario)
  else
    become_hunter(sMario)
  end
  network_send_include_self(false, { id = PACKET_ROLE_CHANGE, index = np.globalIndex })
  return true
end

function set_life_command(msg)
  local args = split(msg, " ")
  local lookingFor = ""
  local lives = args[1]
  if args[2] then
    lookingFor = args[1]
    lives = args[2]
  end

  lives = tonumber(lives)
  if not lives or lives < 0 or lives > 100 or math.floor(lives) ~= lives then
    return false
  end

  local playerID, np = get_specified_player(lookingFor)
  if not playerID then return true end

  local sMario = gPlayerSyncTable[playerID]
  local name = remove_color(np.name)
  if gGlobalSyncTable.mhState == 0 then
    djui_chat_message_create(trans("not_started"))
  elseif sMario.runnerLives then
    sMario.runnerLives = lives
    djui_chat_message_create(trans_plural("set_lives", name, lives))
  else
    djui_chat_message_create(trans("not_runner", name))
  end
  return true
end

function allow_leave_command(msg)
  local playerID, np = get_specified_player(msg)
  if not playerID then return true end

  local sMario = gPlayerSyncTable[playerID]
  local name = remove_color(np.name)
  sMario.allowLeave = true
  djui_chat_message_create(trans("may_leave", name))
  return true
end

function add_runner(msg)
  local runners = tonumber(msg)
  if msg == "" or msg == -1 or msg == "auto" then
    runners = -1 -- TBD
  elseif not (runners and runners == math.floor(runners) and runners ~= 0) then
    return false
  end

  -- get current hunters
  local currHunterIDs = {}
  local goodHunterIDs = {}
  local runners_available = 0
  local currPlayers = 0
  local currRunners = 0
  for i = 0, (MAX_PLAYERS - 1) do
    local np = gNetworkPlayers[i]
    local sMario = gPlayerSyncTable[i]
    if np.connected and ((sMario.spectator ~= 1 and not sMario.forceSpectate) or sMario.team == 1) then
      if sMario.team ~= 1 then
        if gGlobalSyncTable.mhMode == 3 or sMario.beenRunner == 0 then
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

  if runners == -1 then
    runners = ideal_runners(currPlayers) - currRunners
  elseif runners < 0 then
    runners = currPlayers + runners + 2 - currRunners
  end

  if #currHunterIDs < runners or runners <= 0 then
    djui_chat_message_create(trans("no_runners_added"))
    return true
  elseif gGlobalSyncTable.mhMode == 3 and #currHunterIDs <= runners then
    djui_chat_message_create(trans("must_have_one"))
    return true
  elseif runners_available < runners then -- if everyone has been a runner before, ignore recent status
    print("Not enough recent runners! Ignoring recent status")
    goodHunterIDs = currHunterIDs
  end

  local runnerNames = {}
  for i = 1, runners do
    local selected = math.random(1, #goodHunterIDs)
    local lIndex = goodHunterIDs[selected]
    local sMario = gPlayerSyncTable[lIndex]
    local np = gNetworkPlayers[lIndex]
    become_runner(sMario)
    network_send_include_self(false, { id = PACKET_ROLE_CHANGE, index = np.globalIndex })
    table.insert(runnerNames, remove_color(np.name))
    table.remove(goodHunterIDs, selected)
    if #goodHunterIDs == 0 then return end
  end

  local text = ""
  if gGlobalSyncTable.mhMode ~= 3 then
    text = trans("added")
    for i = 1, #runnerNames do
      text = text .. runnerNames[i] .. ", "
    end
    text = text:sub(1, -3)
  else
    text = trans_plural("added_count", #runnerNames)
  end
  djui_chat_message_create(text)
  return true
end

function runner_randomize(msg)
  local runners = tonumber(msg)
  if (not msg) or msg == "" or msg == "auto" then
    runners = -1 -- TBD
  elseif not (runners and runners == math.floor(runners)) then
    return false
  end
  gGlobalSyncTable.lastRandomRoles = runners

  -- get current hunters
  local currPlayerIDs = {}
  local goodPlayerIDs = {}
  local runners_available = 0
  for i = 0, (MAX_PLAYERS - 1) do
    local np = gNetworkPlayers[i]
    local sMario = gPlayerSyncTable[i]
    become_hunter(sMario)
    if np.connected and (sMario.spectator ~= 1 and not sMario.forceSpectate) then
      if gGlobalSyncTable.mhMode == 3 or sMario.beenRunner == 0 then
        runners_available = runners_available + 1
        table.insert(goodPlayerIDs, np.localIndex)
      end
      table.insert(currPlayerIDs, np.localIndex)
    end
  end

  if runners == -1 then
    runners = ideal_runners(#currPlayerIDs)
  elseif runners == 0 then
    return true
  elseif runners < 0 then
    runners = #currPlayerIDs + runners + 2
  end

  if gGlobalSyncTable.mhMode == 3 and #currPlayerIDs <= runners then
    djui_chat_message_create(trans("must_have_one"))
    return (type(msg) ~= "number")
  elseif runners <= 0 or #currPlayerIDs <= 0 then
    djui_chat_message_create(trans("no_runners"))
    return (type(msg) ~= "number")
  elseif runners_available < runners then -- if everyone has been a runner before, ignore recent status
    print("Not enough recent runners! Ignoring recent status")
    goodPlayerIDs = currPlayerIDs
  end

  local runnerNames = {}
  for i = 1, runners do
    local selected = math.random(1, #goodPlayerIDs)
    local lIndex = goodPlayerIDs[selected]
    local sMario = gPlayerSyncTable[lIndex]
    local np = gNetworkPlayers[lIndex]
    become_runner(sMario)
    network_send_include_self(false, { id = PACKET_ROLE_CHANGE, index = np.globalIndex })
    table.insert(runnerNames, remove_color(np.name))
    table.remove(goodPlayerIDs, selected)
    if #goodPlayerIDs == 0 then break end
  end

  local text = ""
  if gGlobalSyncTable.mhMode ~= 3 then
    text = trans("runners_are")
    for i = 1, #runnerNames do
      text = text .. runnerNames[i] .. ", "
    end
    text = text:sub(1, -3)
  else
    text = trans_plural("hunters_set_count", runners_available - #runnerNames)
  end
  djui_chat_message_create(text)
  return true
end

-- calculate good amount of runners (40% except when there's 5)
function ideal_runners(num)
  local ideal = 0
  if gGlobalSyncTable.mhMode ~= 3 then
    if num ~= 5 then
      ideal = math.max(1, math.floor(num * 0.4))
    else
      ideal = 1
    end
  else -- different logic for mysteryhunt (more runners)
    ideal = math.min(num-1, math.ceil((num * 2 + 1) / 3))
  end
  return ideal
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
    local change = num - gGlobalSyncTable.runnerLives
    gGlobalSyncTable.runnerLives = num
    djui_chat_message_create(trans("set_lives_total", num))
    -- update lives for all runners
    for i = 0, MAX_PLAYERS - 1 do
      local np = gNetworkPlayers[i]
      local sMario = gPlayerSyncTable[i]
      if np.connected and sMario.team == 1 and sMario.runnerLives then
        sMario.runnerLives = math.max(sMario.runnerLives + change, 0)
      end
    end
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
      djui_chat_message_create(trans("need_time_feedback", num))
    else
      djui_chat_message_create(trans("game_time", num))
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
    djui_chat_message_create(trans("need_stars_feedback", num))
    return true
  end
  return false
end

function auto_command(msg)
  local num = tonumber(msg)
  if string.lower(msg) == "on" then
    num = -1
  elseif string.lower(msg) == "off" then
    num = 0
  elseif not num or math.floor(num) ~= num then
    return false
  elseif gGlobalSyncTable.mhMode == 3 and num > (MAX_PLAYERS - 1) then
    djui_chat_message_create(trans("must_have_one"))
    return true
  end

  if num == 0 then
    gGlobalSyncTable.gameAuto = 0
    djui_chat_message_create(trans("auto_off"))
    if gGlobalSyncTable.mhState == 0 then
      gGlobalSyncTable.mhTimer = 0 -- don't set
    end
  elseif num == -1 then
    gGlobalSyncTable.gameAuto = -1
    djui_chat_message_create(trans("auto_on"))
    if gGlobalSyncTable.mhState == 0 then
      gGlobalSyncTable.mhTimer = 20 * 30 -- 20 seconds
    end
  elseif num > 0 then
    gGlobalSyncTable.gameAuto = num
    local runners = trans("runners")
    if num == 1 then runners = trans("runner") end
    djui_chat_message_create(string.format("%s (%d %s)", trans("auto_on"), num, runners))
    if gGlobalSyncTable.mhState == 0 then
      gGlobalSyncTable.mhTimer = 20 * 30 -- 20 seconds
    end
  else
    gGlobalSyncTable.gameAuto = num
    local autoNum = -num - 2
    local hunters = trans("hunters")
    if gGlobalSyncTable.gameAuto == -3 then
      hunters = trans("hunter")
    end
    djui_chat_message_create(string.format("%s (%d %s)", trans("auto_on"), autoNum, hunters))
    if gGlobalSyncTable.mhState == 0 then
      gGlobalSyncTable.mhTimer = 20 * 30 -- 20 seconds
    end
  end
  return true
end

function star_count_command(msg)
  local num = tonumber(msg)
  if msg and (not num) and msg:lower() == "any" then num = -1 end
  if num and num >= -1 and num <= ROMHACK.max_stars and math.floor(num) == num then
    if gGlobalSyncTable.noBowser and num < 1 then
      return false
    elseif gGlobalSyncTable.gameArea ~= 0 and ROMHACK.gameAreaData then
      local data = ROMHACK.gameAreaData[gGlobalSyncTable.gameArea + 1]
      if data and num > data.max_stars then
        return false
      end
    end
    gGlobalSyncTable.starRun = num
    if num ~= -1 then
      djui_chat_message_create(trans("new_category", num))
    else
      djui_chat_message_create(trans("new_category_any"))
    end
    return true
  end
  return false
end

function change_game_mode(msg, mode, prevMode_)
  local prevMode = prevMode_ or gGlobalSyncTable.mhMode
  if prevMode == mode then return true end

  if mode == 0 or string.lower(msg) == "normal" then
    gGlobalSyncTable.mhMode = 0
  elseif mode == 1 or string.lower(msg) == "swap" or string.lower(msg) == "switch" then
    gGlobalSyncTable.mhMode = 1
  elseif mode == 2 or string.lower(msg) == "mini" then
    local np = gNetworkPlayers[0]
    gGlobalSyncTable.mhMode = 2
    gGlobalSyncTable.gameLevel = np.currLevelNum
    gGlobalSyncTable.getStar = np.currActNum
  elseif mode == 3 or string.lower(msg) == "mystery" or string.lower(msg) == "mys" then
    if disable_chat_hook then
      djui_chat_message_create(trans("mysteryhunt_disabled"))
      return true
    end
    gGlobalSyncTable.mhMode = 3
  else
    return false
  end

  omm_disable_mode_for_minihunt(mode == 2)

  -- only reload settings if we changed from mini to standard or vice versa
  load_settings(prevMode)
  return true
end

-- Freezes the screens of others
function pause_command(msg)
  if msg == "all" or not msg or msg == "" then
    if gGlobalSyncTable.pause then
      gGlobalSyncTable.pause = false
      for i = 0, (MAX_PLAYERS - 1) do
        gPlayerSyncTable[i].pause = false
      end
      djui_chat_message_create(trans("all_unpaused"))
    else
      gGlobalSyncTable.pause = true
      for i = 0, (MAX_PLAYERS - 1) do
        gPlayerSyncTable[i].pause = true
      end
      djui_chat_message_create(trans("all_paused"))
    end
    return true
  end

  local playerID, np = get_specified_player(msg)
  if not playerID then return true end

  local sMario = gPlayerSyncTable[playerID]
  local name = remove_color(np.name)
  if sMario.pause then
    sMario.pause = false
    djui_chat_message_create(trans("player_unpaused", name))
  else
    sMario.pause = true
    djui_chat_message_create(trans("player_paused", name))
  end
  return true
end

-- gets the name and color of the user's role (color is either a table or string)
function get_role_name_and_color(index)
  local sMario = gPlayerSyncTable[index]
  if not know_team(index) then
    color = { r = 169, g = 169, b = 169 } -- grey
    colorString = "\\#a9a9a9\\"
    if sMario.knownDead then
      roleName = trans("dead")
    else
      roleName = trans("menu_unknown")
    end
    return roleName, colorString, color
  end
  local roleName = ""
  local color = { r = 255, g = 92, b = 92 } -- red
  local colorString = "\\#ff5a5a\\"
  if sMario.team == 1 then
    if sMario.hard == 1 then
      color = { r = 255, g = 255, b = 92 } -- yellow
      colorString = "\\#ffff5a\\"
    elseif sMario.hard == 2 then
      color = { r = 180, g = 92, b = 255 } -- purple
      colorString = "\\#b45aff\\"
    else
      color = { r = 0, g = 255, b = 255 } -- cyan
      colorString = "\\#00ffff\\"
    end
    roleName = trans("runner")
  elseif not sMario.team then             -- joining
    color = { r = 169, g = 169, b = 169 } -- grey
    colorString = "\\#a9a9a9\\"
    roleName = trans("menu_unknown")
  else
    roleName = trans("hunter")
  end

  if sMario.dead or (sMario.spectator == 1 and sMario.team ~= 1) then
    if (not sMario.dead) or sMario.forceSpectate then
      color = { r = 169, g = 169, b = 169 } -- grey
      colorString = "\\#a9a9a9\\"
      roleName = trans("spectator")
    else
      color.r = color.r//2
      color.g = color.g//2
      color.b = color.b//2
      colorString = string.format("\\#%02x%02x%02x\\", color.r, color.g, color.b)
      roleName = trans("dead")
    end
  end

  return roleName, colorString, color
end

-- gets if the player should know this role; only FALSE in mysteryhunt
function know_team(index)
  return gGlobalSyncTable.mhState == nil or gGlobalSyncTable.mhState >= 3 or gGlobalSyncTable.mhMode ~= 3 or index == 0 or (gPlayerSyncTable[0].team ~= 1 and gGlobalSyncTable.anarchy ~= 3) or gPlayerSyncTable[0].dead or (gGlobalSyncTable.confirmHunter and gPlayerSyncTable[index].dead and gPlayerSyncTable[index].knownDead)
end

-- gets nearest alive runner to an object
function nearest_runner_to_object(o)
  local maxDist = -1
  local nearest
  for i=0,MAX_PLAYERS-1 do
    local m = gMarioStates[i]
    local sMario = gPlayerSyncTable[i]
    if is_player_active(m) ~= 0 and sMario.spectator ~= 1 and sMario.team == 1 then
      local dist = dist_between_objects(m.marioObj, o)
      if maxDist < dist then
        maxDist = dist
        nearest = m
      end
    end
  end
  return nearest
end

function set_lobby_music(month)
  if noSeason or (month ~= 10 and month ~= 12) then
    set_background_music(0, custom_seq, 0)
  elseif month == 10 then
    set_background_music(0, SEQ_LEVEL_SPOOKY, 0)
  else
    set_background_music(0, SEQ_LEVEL_SNOW, 0)
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
  return a * (1 - t) + b * t
end

-- reset_camera and soft_reset_camera have a bug that makes itt impossible to disable freecam when they are run.
-- This gets around that issue.
function soft_reset_camera_fix_bug(c)
  if camera_config_is_free_cam_enabled() then
    camera_config_enable_free_cam(false) -- temporarily disable
    local mode = gLakituState.mode
    local defMode = gLakituState.defMode
    soft_reset_camera(c)
    gLakituState.mode = mode
    gLakituState.defMode = defMode
    set_camera_mode(c, mode, 0)
    camera_reset_overrides()
  else
    soft_reset_camera(c)
  end
end
function reset_camera_fix_bug(c)
  if camera_config_is_free_cam_enabled() then
    camera_config_enable_free_cam(false) -- temporarily disable
    local mode = gLakituState.mode
    local defMode = gLakituState.defMode
    reset_camera(c)
    gLakituState.mode = mode
    gLakituState.defMode = defMode
    set_camera_mode(c, mode, 0)
    camera_reset_overrides()
  else
    reset_camera(c)
  end
end

function set_bubble_respawn_action(m)
  m.area.camera.cutscene = 0;
  m.statusForCamera.action = m.action;
  m.statusForCamera.cameraEvent = 0
  soft_reset_camera_fix_bug(m.area.camera)
  set_mario_action(m, ACT_MH_BUBBLE_RETURN, 0)
  fade_volume_scale(0, 127, 15)
end

-- custom bubble action, with some code from the base game bubble action
ACT_MH_BUBBLE_RETURN = allocate_mario_action(ACT_GROUP_CUTSCENE | ACT_FLAG_INTANGIBLE | ACT_FLAG_PAUSE_EXIT)
---@param m MarioState
function act_bubble_return(m)
  -- create bubble
  if (not m.bubbleObj and m.playerIndex == 0) then
    m.bubbleObj = spawn_non_sync_object(id_bhvStaticObject, E_MODEL_BUBBLE_PLAYER, m.pos.x, m.pos.y + 50, m.pos.z, nil)
    if m.bubbleObj then
      m.bubbleObj.heldByPlayerIndex = m.playerIndex
      obj_scale(m.bubbleObj, 1.5)
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
    m.vel.y = 0
    return
  elseif m.playerIndex ~= 0 then
    m.pos.x = m.pos.x + m.vel.x
    m.pos.y = m.pos.y + m.vel.y
    m.pos.z = m.pos.z + m.vel.z
    vec3f_copy(m.marioObj.header.gfx.pos, m.pos)
    vec3s_copy(m.marioObj.header.gfx.angle, m.faceAngle)
    return
  end

  -- place safe pos backwards from our last position so we don't spawn on the edge
  if prevSafePos.doWalkBack then
    local newX = prevSafePos.x - 300 * sins(prevSafePos.dir)
    local newZ = prevSafePos.z - 300 * coss(prevSafePos.dir)
    local newFloor = collision_find_floor(newX, prevSafePos.y + 30, newZ)
    local oldFloor = m.floor
    m.floor = newFloor
    if newFloor and (prevSafePos.y - newFloor.lowerY) <= 250 and mario_floor_is_slippery(m) == 0 and not is_hazard_floor(newFloor.type) then
      prevSafePos.x, prevSafePos.z = newX, newZ
      prevSafePos.obj = newFloor.object
    end
    m.floor = oldFloor
    prevSafePos.doWalkBack = false
  end

  local goToPos = { x = 0, y = 0, z = 0 }
  if prevSafePos.obj and (prevSafePos.obj.oVelX ~= 0 or prevSafePos.obj.oVelY ~= 0 or prevSafePos.obj.oVelZ ~= 0) then
    prevSafePos.x = prevSafePos.obj.oPosX
    prevSafePos.y = prevSafePos.obj.oPosY
    prevSafePos.z = prevSafePos.obj.oPosZ
  end
  vec3f_copy(goToPos, prevSafePos)
  goToPos.y = goToPos.y + 200
  if m.actionTimer < 45 then
    m.vel.x = (goToPos.x - m.pos.x) // 10
    m.vel.y = (goToPos.y - m.pos.y) // 10
    m.vel.z = (goToPos.z - m.pos.z) // 10
    m.pos.x = m.pos.x + m.vel.x
    m.pos.y = m.pos.y + m.vel.y
    m.pos.z = m.pos.z + m.vel.z
    vec3f_copy(gLakituState.goalPos, m.pos)
  else
    m.faceAngle.x = 0
    vec3f_copy(m.pos, goToPos)
    if m.actionTimer == 45 then
      vec3f_copy(gLakituState.goalPos, goToPos)
    end
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
    m.forwardVel, m.vel.x, m.vel.y, m.vel.z = 0, 0, -60, 0
    local floor = collision_find_floor(m.pos.x, m.pos.y, m.pos.z)
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

    -- emergency
    if floor == nil then
      m.pos.x = m.spawnInfo.startPos.x
      m.pos.y = m.spawnInfo.startPos.y
      m.pos.z = m.spawnInfo.startPos.z
      floor = collision_find_floor(m.pos.x, m.pos.y, m.pos.z)
    end

    if m.playerIndex == 0 and gGlobalSyncTable.mhMode == 3 and (gGlobalSyncTable.mhState == 1 or gGlobalSyncTable.mhState == 2) and gPlayerSyncTable[m.playerIndex].dead then
      spawn_my_corpse()
      set_mario_action(m, ACT_SOFT_BONK, 0)
    elseif m.waterLevel > m.pos.y then
      set_mario_action(m, ACT_WATER_IDLE, 0)
    elseif floor and is_hazard_floor(floor.type) then
      local np = gNetworkPlayers[m.playerIndex]
      if m.flags & MARIO_WING_CAP ~= 0 and np.currLevelNum == LEVEL_TOTWC then
        set_mario_action(m, ACT_FLYING_TRIPLE_JUMP, 0)
      else
        set_mario_action(m, ACT_TRIPLE_JUMP, 0)
      end
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

function is_hazard_floor(type)
  return (type == SURFACE_DEATH_PLANE or type == SURFACE_VERTICAL_WIND or type == SURFACE_INSTANT_QUICKSAND or type == SURFACE_BURNING or type == SURFACE_INSTANT_MOVING_QUICKSAND or type == SURFACE_DEEP_MOVING_QUICKSAND or type == SURFACE_SHALLOW_MOVING_QUICKSAND or type == SURFACE_MOVING_QUICKSAND)
end

function no_wall_between_points(pos1, pos2)
  local dir = {x = pos2.x - pos1.x, y = pos2.y - pos1.y, z = pos2.z - pos1.z}
  local intersect = collision_find_surface_on_ray(pos1.x, pos1.y, pos1.z, dir.x, dir.y, dir.z, 1)
  while intersect.surface do
    if intersect.surface.flags & SURFACE_FLAG_NO_CAM_COLLISION == 0 then
      return false
    end
    pos1 = intersect.hitPos
    local step = 0
    if (math.abs(dir.x) >= math.abs(dir.z)) then
      step = math.abs(dir.x) / 0x400
    else
      step = math.abs(dir.z) / 0x400
    end
    pos1.x = pos1.x + dir.x / step / 0x400
    pos1.z = pos1.z + dir.z / step / 0x400

    dir = {x = pos2.x - pos1.x, y = pos2.y - pos1.y, z = pos2.z - pos1.z}
    intersect = collision_find_surface_on_ray(pos1.x, pos1.y, pos1.z, dir.x, dir.y, dir.z, 1)
  end
  return true
end

-- creates popup even in mysteryhunt
function djui_popup_create_mystery(msg, lines)
  if mystery_popup_off() then
    djui_reset_popup_disabled_override()
    if djui_is_popup_disabled() then
      djui_chat_message_create(msg)
    else
      djui_popup_create(msg, lines)
    end
    djui_set_popup_disabled_override(true)
  else
    djui_popup_create(msg, lines)
  end
end

-- used to sync timers every second instead of on every frame
local currGlobalTimer = {}
local prevGlobalTimer = {}
local currPlayerTimer = {}
local prevPlayerTimer = {}
for i=0,MAX_PLAYERS-1 do
  currPlayerTimer[i] = {}
  prevPlayerTimer[i] = {}
end
function handle_synced_timer(table, key, index, change_, min_, max, syncTime_, doSync_)
  local currTimer = currGlobalTimer
  local prevTimer = prevGlobalTimer
  local doSync = network_is_server()
  local change = change_ or -1
  local min = min_ or 0
  local syncTime = syncTime_ or 30
  if table ~= gGlobalSyncTable then
    currTimer = currPlayerTimer[index or 0]
    prevTimer = prevPlayerTimer[index or 0]
    table = table[index or 0]
    doSync = (index == 0)
  end
  if doSync_ ~= nil then doSync = doSync_ end

  if not currTimer[key] then
    currTimer[key] = min
    prevTimer[key] = min
  end
  
  local prevValue = currTimer[key]
  currTimer[key] = currTimer[key] + change
  if currTimer[key] < min then
    currTimer[key] = min
  elseif max and currTimer[key] > max then
    currTimer[key] = max
  end

  -- sync with new value
  if table[key] and prevTimer[key] ~= table[key] then
    currTimer[key] = table[key]
    prevTimer[key] = table[key]
  end
  
  -- don't send value if it didn't change
  if prevValue == currTimer[key] then return currTimer[key] end

  -- put value in table every syncTime frames (usually 1 second)
  if doSync and currTimer[key] % syncTime == 0 then
    table[key] = currTimer[key]
    prevTimer[key] = currTimer[key]
  end
  return currTimer[key]
end

function get_synced_timer_value(table, key, index)
  local currTimer = currGlobalTimer
  local prevTimer = prevGlobalTimer
  if table ~= gGlobalSyncTable then
    currTimer = currPlayerTimer[index or 0]
    prevTimer = prevPlayerTimer[index or 0]
    table = table[index or 0]
  end

  if not currTimer[key] then
    currTimer[key] = 0
    prevTimer[key] = 0
  end

  -- sync with new value
  if table[key] and prevTimer[key] ~= table[key] then
    currTimer[key] = table[key]
    prevTimer[key] = table[key]
  end

  return currTimer[key] or 0
end

-- set the default values for player synced tables. Set on disconnect and for everyone when we join
function set_default_sync_values(sMario)
  -- unassign stats
  sMario.wins, sMario.hardWins, sMario.exWins, sMario.wins_standard, sMario.hardWins_standard, sMario.exWins_standard, sMario.wins_mys, sMario.hardWins_mys, sMario.exWins_mys, sMario.kills, sMario.maxStreak, sMario.maxStar, sMario.beenRunner, sMario.pRecordOmm, sMario.pRecordOther, sMario.parkourRecord, sMario.playtime =
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 599, 599, 599, 0
  
  sMario.totalStars = 0
  sMario.pause = false
  sMario.forceSpectate = false
  sMario.spectator = 0
  sMario.fasterActions = true
  sMario.choseToLeave = false
  sMario.inActSelect = false
  sMario.guardTime = 0
  sMario.killCooldown = 0
  sMario.rejoinID = "-1"
  sMario.placement = 9999
  sMario.placementASN = 9999
  sMario.fasterActions = true
  sMario.role = 0
  sMario.knownDead = true
  sMario.dead = true
  sMario.hard = 0
  sMario.mute = false
end