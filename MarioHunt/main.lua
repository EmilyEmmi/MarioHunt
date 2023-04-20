-- name: Mariohunt (v1.2)
-- incompatible: gamemode, mariohunt
-- description: A gamemode based off of Beyond's concept.\n\nHunters stop Runners from clearing the game!\n\nProgramming by EmilyEmmi, TroopaParaKoopa, Blocky, Sunk, and Sprinter05.\n\nSpanish Translation made with help from TroopaParaKoopa.\nGerman Translation made with help from N64 Mario.

-- some debug stuff
function do_warp(msg)
  if msg == "random" then
    local worked = false
    local level,area,act,node = nil
    while not worked do
      level = math.random(4, 36)
      area = math.random(1, 4)
      act = math.random(0, 6)
      node = math.random(0, 64) -- obviously not the actual limit but whatever
      worked = warp_to_warpnode(level, area, act, node)
    end
    djui_chat_message_create("Warped to level "..level.." area "..area.." act "..act.." node "..node)
    return true
  end
  local args = {}
  local lastspace = 0
  while lastspace ~= nil do
    lastspace = msg:find(" ")
    if lastspace ~= nil then
      local arg = msg:sub(1,lastspace-1)
      table.insert(args, tonumber(arg))
      msg = msg:sub(lastspace+1)
    else
      local arg = msg
      table.insert(args, tonumber(arg))
    end
  end
  local level = args[1] or 16 -- castle grounds
  local area = args[2] or 1
  local act = args[3] or 0
  local node = args[4]
  if node == nil then
    djui_chat_message_create("Warping to level "..level.." area "..area.." act "..act)
    warp_to_level(level, area, act)
  else
    djui_chat_message_create("Warping to level "..level.." area "..area.." act "..act.." node "..node)
    warp_to_warpnode(level, area, act, node)
  end
  return true
end

DEBUG_RADAR = false
function radar_debug(msg)
  if string.lower(msg) == "on" then
    DEBUG_RADAR = true
    djui_chat_message_create("Radar debug on!")
    return true
  elseif string.lower(msg) == "off" then
    DEBUG_RADAR = false
    djui_chat_message_create("Radar debug off!")
    return true
  end
  return false
end

function quick_debug(msg)
  local sMario = gPlayerSyncTable[0]
  become_runner(sMario)
  DEBUG_RADAR = true
  start_game_command("continue")
  warp_to_level(LEVEL_BOB, 1, 1)
  return true
end

-- TroopaParaKoopa's pause mod
ACT_PAUSE = allocate_mario_action(ACT_FLAG_IDLE)
gGlobalSyncTable.pause = false

if network_is_server() then
  gGlobalSyncTable.runnerLives = 1 -- the lives runners get (0 is a life)
  gGlobalSyncTable.runTime = 7200 -- time runners must stay in stage to leave (default: 4 minutes)
  gGlobalSyncTable.starRun = 70 -- stars runners must get to face bowser; star doors and infinite stairs will be disabled accordingly
  gGlobalSyncTable.runnerSwitch = false -- pick new runners whenever one dies
  gGlobalSyncTable.allowSpectate = true -- hunters can spectate
  gGlobalSyncTable.starMode = false -- use stars collected instead of timer
  gGlobalSyncTable.mhState = 0 -- game state
  --[[
    0: not started
    1: timer
    2: game started
    3: game ended
  ]]
  gGlobalSyncTable.mhTimer = 0 -- timer in frames (game is 30 FPS)
  gGlobalSyncTable.otherSave = false -- using other save file
  gGlobalSyncTable.bowserBeaten = false -- used for Star Road
  gGlobalSyncTable.ee = false -- used for SM74

  rejoin_timer = {} -- rejoin timer for runners
  discordIDTable = {} -- table of ids to recall on rejoin
end

-- force pvp, knockback, and no bubble death
gServerSettings.playerInteractions = PLAYER_INTERACTIONS_PVP
gServerSettings.playerKnockbackStrength = 20
gServerSettings.bubbleDeath = 0

gotStar = false -- if we got the latest star
died = false -- if we've died (because on_death runs every frame of death fsr)
sawMessage = false -- if we've seen the rules message
justEntered = false -- entered a course
desc_switch_timer = 60 -- to make the description for runners switch

-- main command
function mario_hunt_command(msg)
  local np = gNetworkPlayers[0]
  local isDev = (network_discord_id_from_local_index(np.localIndex) == "409438020870078486") -- my discord id
  if not (network_is_server() or network_is_moderator() or isDev) then
    djui_chat_message_create("You don't have the AUTHORITY to run this command, you fool!")
    return true
  elseif marioHuntCommands == nil or #marioHuntCommands < 1 then
    setup_commands()
  end

  local dataStart = msg:find(" ")
  local usedCmd = msg
  local data = ""
  if dataStart ~= nil then
    usedCmd = msg:sub(1,dataStart-1)
    data = msg:sub(dataStart+1)
  end
  --print("!"..usedCmd.."!", "!"..data.."!")
  if usedCmd == "" then
    djui_chat_message_create("List of commands: ")
    for cmd,cdata in pairs(marioHuntCommands) do
      local desc = cdata[1]
      local hidden = false
      if cdata[3] == true then
        if not isDev then
          hidden = true
        end
      end

      if not hidden then
        djui_chat_message_create("/mh " .. cmd .. " " .. desc)
      end
    end
  elseif marioHuntCommands[usedCmd] ~= nil then
    local cmd = marioHuntCommands[usedCmd]
    local func = cmd[2]

    if (not func(data)) then
      djui_chat_message_create("Invalid parameters!")
    end
  else
    djui_chat_message_create("Invalid command!")
  end
  return true
end

-- start game
function start_game_command(msg)
  -- count runners
  local runners = 0
  for i=0,(MAX_PLAYERS-1) do
    if gPlayerSyncTable[i].team == 1 and gNetworkPlayers[i].connected then
      runners = runners + 1
    end
  end
  if runners < 1 then
    djui_chat_message_create("ERROR: No runners!")
    return true
  end

  if string.lower(msg) ~= "continue" then
    gGlobalSyncTable.mhState = 1
  else
    gGlobalSyncTable.mhState = 2
  end

  local cmd = "none"
  if msg ~= nil and msg ~= "" then
    cmd = msg
  end
  network_send(true, {
    id = PACKET_MH_START,
    cmd = cmd,
  })
  gGlobalSyncTable.mhTimer = 15 * 30 -- 15 seconds
  do_game_start(nil,msg)
  return true
end
function do_game_start(data,msg)
  if msg == nil and data ~= nil and data.cmd ~= nil then
    msg = data.cmd
  elseif msg == nil then
    msg = ""
  end
  if string.lower(msg) ~= "continue" then
    local sMario = gPlayerSyncTable[0]
    local m = gMarioStates[0]
    if sMario.team == 1 then
      sMario.runnerLives = gGlobalSyncTable.runnerLives
      sMario.runTime = 0
      died = false
      m.numLives = sMario.runnerLives
    end

    warp_beginning()

    if (string.lower(msg) == "main") then
      gGlobalSyncTable.otherSave = false
    elseif (string.lower(msg) == "alt") then
      gGlobalSyncTable.otherSave = true
    end
    gGlobalSyncTable.bowserBeaten = false
    save_file_set_using_backup_slot(gGlobalSyncTable.otherSave)
    gMarioStates[0].numStars = save_file_get_total_star_count(get_current_save_file_num()-1,COURSE_MIN-1,COURSE_MAX-1)
    --[[if msg == "reset" then
      m.prevNumStarsForDialog = 0
      save_file_erase_current_backup_save()
    end]]
    save_file_reload(1)
  end
end

-- code from arena
function allow_pvp_attack(attacker, victim)
    -- false if timer going
    if gGlobalSyncTable.mhState == 1 then return false end
    -- ignore if game isn't active
    if gGlobalSyncTable.mhState ~= 2 then return true end

    local npAttacker = gNetworkPlayers[attacker.playerIndex]
    local sAttacker = gPlayerSyncTable[attacker.playerIndex]

    -- check teams
    local success = global_index_hurts_mario_state(npAttacker.globalIndex, victim)
    if success and victim.playerIndex == 0 then
      attackedBy = npAttacker.globalIndex
    end
    return success
end

-- code from arena
function global_index_hurts_mario_state(globalIndex, m)
    if globalIndex == gNetworkPlayers[m.playerIndex].globalIndex then
        return false
    end

    local npAttacker = network_player_from_global_index(globalIndex)
    if npAttacker == nil then
        return false
    end
    local sAttacker = gPlayerSyncTable[npAttacker.localIndex]
    local sVictim = gPlayerSyncTable[m.playerIndex]

    -- sanitize
    local attackTeam = sAttacker.team or 0
    local victimTeam = sVictim.team or 0

    return attackTeam ~= victimTeam
end

-- from hide and seek
function on_player_connected(m)
    -- host's end only
    if not network_is_server() then return end

    local np = gNetworkPlayers[m.playerIndex]
    local discordID = network_discord_id_from_local_index(np.localIndex)
    for id,data in pairs(rejoin_timer) do
      print(id,discordID)
      if id == discordID and data.timer > 0 then
        -- become runner again
        local s = gPlayerSyncTable[m.playerIndex]
        become_runner(s)
        s.pause = false
        s.runnerLives = data.lives
        djui_popup_create(trans("rejoin_success",data.name), 2)
        rejoin_timer[id] = nil
        return true
      end
    end
    discordIDTable[m.playerIndex] = discordID

    -- start out as hunter
    local s = gPlayerSyncTable[m.playerIndex]
    become_hunter(s)
    s.pause = false
end

function get_leave_requirements(sMario)
  local np = gNetworkPlayers[0]
  local available_stars = 7
  -- in castle
  if np.currCourseNum == 0 then
    return 0,trans("in_castle")
  end

  -- for leave command
  if sMario.runTime == "done" then
    return 0
  end

  -- allow leaving bowser stages if done
  if np.currLevelNum == LEVEL_BITDW and ((save_file_get_flags() & SAVE_FLAG_HAVE_KEY_1) ~= 0 or (save_file_get_flags() & SAVE_FLAG_UNLOCKED_BASEMENT_DOOR) ~= 0) then
    return 0
  elseif np.currLevelNum == LEVEL_BITFS and ((save_file_get_flags() & SAVE_FLAG_HAVE_KEY_2) ~= 0 or (save_file_get_flags() & SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR) ~= 0) then
    return 0
  end

  -- less time for secret courses
  local total_time = gGlobalSyncTable.runTime
  if ROMHACK.starCount[np.currLevelNum] ~= nil then
    available_stars = ROMHACK.starCount[np.currLevelNum]
    -- for EE
    if gGlobalSyncTable.ee and ROMHACK.starCount_ee ~= nil and ROMHACK.starCount_ee[np.currLevelNum] ~= nil then
      available_stars = ROMHACK.starCount_ee[np.currLevelNum]
    end
  elseif np.currCourseNum > 15 or (np.currLevelNum == LEVEL_DDD and ROMHACK.ddd and np.currActNum == 1) then
    available_stars = 1
  end

  -- for star road
  local m = gMarioStates[0]
  if ROMHACK.replica_start ~= nil and m.numStars >= ROMHACK.replica_start then
    available_stars = available_stars + 1
  end

  local file = get_current_save_file_num() - 1
  local starCount = save_file_get_course_star_count(file, np.currCourseNum - 1)
  available_stars = available_stars - starCount

  if available_stars == 0 then return 0 end

  if gGlobalSyncTable.starMode then
    if (total_time - sMario.runTime) > available_stars then
      sMario.runTime = total_time - available_stars
    end
  elseif (total_time - sMario.runTime) > available_stars * 2700 then
    sMario.runTime = total_time - available_stars * 2700
  end
  return (total_time - sMario.runTime)
end

function on_pause_exit(exitToCastle)
  local m = gMarioStates[0]
  local sMario = gPlayerSyncTable[0]
  if m.health <= 0xFF then return false end
  if sMario.spectator == 1 then return false end
  if sMario.team ~= 1 then return true end
  if get_leave_requirements(sMario) > 0 then return false end
end

function on_death(m,dont_warp)
  if m.playerIndex ~= 0 then return true end
  local sMario = gPlayerSyncTable[0]
  if gGlobalSyncTable.mhState == 2 and died == false then
    local lost = false
    local newID = nil
    died = true

    -- change to hunter
    if sMario.team == 1 and sMario.runnerLives <= 0 then
      m.numLives = 100
      m.health = 0x880
      become_hunter(sMario)
      lost = true
      if not dont_warp then
        warp_beginning()
      end

      -- pick new runner
      if gGlobalSyncTable.runnerSwitch then
        newID = new_runner()
      end
    end

    if attackedBy == nil and sMario.team ~= 1 then return true end -- no one cares about hunters dying

    local np = gNetworkPlayers[0]
    network_send(true, {
        id = PACKET_KILL,
        killed = np.globalIndex,
        killer = attackedBy,
        death = lost,
        newRunnerID = newID,
    })
    on_packet_kill({killed = np.globalIndex, killer = attackedBy, death = lost, newRunnerID = newID})
    if newID ~= nil then
      local np = network_player_from_global_index(newID)
      local playerColor = network_get_player_text_color_string(np.localIndex)
      djui_popup_create(trans("now_runner",(playerColor .. np.name)), 2)
    end
    if sMario.runnerLives ~= nil then
      sMario.runnerLives = sMario.runnerLives - 1
    end
  end
  return true
end

function new_runner(includeLocal)
  local startingI = 1
  if includeLocal then
    startingI = 0
  end

  local currHunterIDs = {}

  -- get current hunters
  for i=startingI,(MAX_PLAYERS-1) do
    local np = gNetworkPlayers[i]
    local sMario = gPlayerSyncTable[i]
    if np.connected and sMario.team ~= 1 then
      table.insert(currHunterIDs, np.localIndex)
    end
  end
  if #currHunterIDs < 1 then
    if not includeLocal then
      local sMario = gPlayerSyncTable[0] -- just make them runner again
      local np = gNetworkPlayers[0]
      become_runner(sMario)
      sMario.campTimer = nil
      return np.globalIndex
    else
      return nil
    end
  end

  local lIndex = currHunterIDs[math.random(1, #currHunterIDs)]
  local sMario = gPlayerSyncTable[lIndex]
  local np = gNetworkPlayers[lIndex]
  become_runner(sMario)
  return np.globalIndex
end

function update()
  if (not sawMessage) and gGlobalSyncTable.mhState ~= nil and gGlobalSyncTable.starRun ~= nil
   and gGlobalSyncTable.otherSave ~= nil and gGlobalSyncTable.runTime ~= nil and gGlobalSyncTable.ee ~= nil then
    setup_hack_data()
    show_rules()
    print(get_time())
    math.randomseed(get_time())

    djui_chat_message_create(trans("to_switch"))

    save_file_set_using_backup_slot(gGlobalSyncTable.otherSave)
    save_file_reload(1)
    if gGlobalSyncTable.otherSave then
      warp_beginning()
    end

    local m = gMarioStates[0]
    m.numStars = save_file_get_total_star_count(get_current_save_file_num()-1,COURSE_MIN-1,COURSE_MAX-1)
    m.prevNumStarsForDialog = m.numStars

    local wins = tonumber(mod_storage_load("wins"))
    if wins ~= nil and math.floor(wins) > 0 then
      local np = gNetworkPlayers[0]
      local playerColor = network_get_player_text_color_string(np.localIndex)
      network_send(true, {
        id = PACKET_WINS,
        wins = math.floor(wins),
        name = playerColor .. np.name,
      })
      on_packet_wins({wins = math.floor(wins), name = playerColor .. np.name})
    end

    sawMessage = true
  end

  -- fix save file
  if justEntered and gGlobalSyncTable.otherSave ~= nil then
    save_file_set_using_backup_slot(gGlobalSyncTable.otherSave)
    --save_file_reload(1)
    local m = gMarioStates[0]
    m.numStars = save_file_get_total_star_count(get_current_save_file_num()-1,COURSE_MIN-1,COURSE_MAX-1)
    m.prevNumStarsForDialog = m.numStars
    justEntered = false
  end

  -- decrement timers from server end
  if network_is_server() then
    if gGlobalSyncTable.mhTimer > 0 then
      gGlobalSyncTable.mhTimer = gGlobalSyncTable.mhTimer - 1
      if gGlobalSyncTable.mhTimer == 0 then
        gGlobalSyncTable.mhState = 2
      end
    end
    for id,data in pairs(rejoin_timer) do
      data.timer = data.timer - 1
      if data.timer <= 0 then
        djui_popup_create(trans("rejoin_fail",data.name), 2)
        rejoin_timer[id] = nil -- times up

        if gGlobalSyncTable.runnerSwitch then
          local newID = new_runner(true)
          if newID ~= nil then
            network_send(true, {
                id = PACKET_KILL,
                runnerID = nil,
                death = false,
                newRunnerID = newID
            })
            if newID ~= nil then
              local np = network_player_from_global_index(newID)
              local playerColor = network_get_player_text_color_string(np.localIndex)
              djui_popup_create(trans("now_runner",(playerColor .. np.name)), 2)
            end
          end
        end
      end
    end
  end
  local sMario = gPlayerSyncTable[0]
  if sMario.team == 1 then
    camp_timer(sMario)
  end
end

function camp_timer(sMario)
  local m = gMarioStates[0]
  local c = m.area.camera
  if sMario.campTimer == nil and obj_get_first_with_behavior_id(id_bhvActSelector) ~= nil then
    sMario.campTimer = 300 -- 10 seconds
  end
  if sMario.campTimer ~= nil then
    sMario.campTimer = sMario.campTimer - 1
    if sMario.campTimer % 30 == 0 then
      play_sound(SOUND_MENU_CAMERA_BUZZ, m.marioObj.header.gfx.cameraToObject)
    end
    if sMario.campTimer <= 0 then
      sMario.runnerLives = 0
      died = false
      on_death(m,true)
      return
    end
    if (c == nil or c.cutscene == 0) and obj_get_first_with_behavior_id(id_bhvActSelector) == nil then
      sMario.campTimer = nil
    end
  end
end

function show_rules()
-- how to play message
  djui_chat_message_create(trans("welcome"))
  local text = "\\#00ffff\\"..trans("runners").."\\#ffffff\\"
  local sMario = gPlayerSyncTable[0]
  if gGlobalSyncTable.mhState ~= 0 and gGlobalSyncTable.mhState < 3 then
    if sMario.team ~= 1 then
      text = text .. trans("shown_above")
    else
      text = text .. trans("thats_you")
    end
  end
  if (gGlobalSyncTable.starRun) == -1 then
    text = text .. trans("any_bowser")
  else
    text = text .. trans("collect_bowser",gGlobalSyncTable.starRun)
  end
  text = text .. "\n\\#ff5c5c\\"..trans("hunters").."\\#ffffff\\"
  if gGlobalSyncTable.mhState ~= 0 and gGlobalSyncTable.mhState < 3 and sMario.team ~= 1 then
    text = text .. trans("thats_you")
  end
  if gGlobalSyncTable.runnerSwitch == false then
    text = text .. trans("all_runners")
  else
    text = text .. trans("any_runners")
  end
  if (gGlobalSyncTable.runnerLives) == 0 then
    text = text .. trans("single_life")
  else
    text = text .. trans("multi_life",(gGlobalSyncTable.runnerLives+1))
  end
  if (gGlobalSyncTable.starMode) then
    text = text .. trans("stars_needed",gGlobalSyncTable.runTime)
  else
    text = text .. trans("time_needed",math.floor(gGlobalSyncTable.runTime/1800),math.floor((gGlobalSyncTable.runTime%1800)/30))
  end
  if gGlobalSyncTable.runnerSwitch == false then
    text = text .. trans("become_hunter")
  else
    text = text .. trans("switch_runner")
  end
  text = text .. "\n" .. trans("infinite_lives")
  if gGlobalSyncTable.allowSpectate == true then
    text = text .. trans("spectate")
  else
    text = text .. "."
  end
  text = text .. "\n"
  if (gGlobalSyncTable.starRun) ~= -1 then
    text = text .. trans("banned_glitchless")
  else
    text = text .. trans("banned_general")
  end
  text = text .. trans("fun")
  djui_chat_message_create(text)
  djui_chat_message_create(trans("rule_command"))
end
function rule_command()
  show_rules()
  return true
end
hook_chat_command("rules", "- Shows MarioHunt rules", rule_command)

-- from hide and seek
function on_hud_render()
  -- not if game isn't started
  if gGlobalSyncTable.mhState == 0 then return end

  -- render to N64 screen space, with the HUD font
  djui_hud_set_resolution(RESOLUTION_N64)
  djui_hud_set_font(FONT_NORMAL)

  local text = ""
  local sMario = gPlayerSyncTable[0]
  -- yay long if statement
  if sMario.campTimer ~= nil then -- camp timer has top priority
    text = camp_hud(sMario)
  elseif gGlobalSyncTable.mhState == 1 then -- game start timer
    text = timer_hud()
  elseif gGlobalSyncTable.mhState ~= nil and gGlobalSyncTable.mhState >= 3 then -- game end
    text = victory_hud()
  elseif sMario.team == 1 and (not DEBUG_RADAR) then -- do runner hud
    text = runner_hud(sMario)
  else -- do hunter hud
    text = hunter_hud(sMario)
  end

  local scale = 0.5

  -- get width of screen and text
  local screenWidth = djui_hud_get_screen_width()
  local width = djui_hud_measure_text(text) * scale

  local x = (screenWidth - width) / 2.0
  local y = 0

  djui_hud_set_color(0, 0, 0, 128);
  djui_hud_render_rect(x - 6, y, width + 12, 16);

  djui_hud_set_color(255, 255, 255, 255);
  djui_hud_print_text(text, x, y, scale);
end

function runner_hud(sMario)
  local text = ""
  -- set star text
  local timeLeft,special = get_leave_requirements(sMario)
  if special ~= nil then
    text = special
  elseif timeLeft <= 0 then
    text = trans("can_leave")
  elseif gGlobalSyncTable.starMode then
    text = trans("stars_left",timeLeft)
  else
    text = trans("time_left",math.floor(timeLeft / 1800),math.floor((timeLeft%1800)/30))
  end
  return text
end

function hunter_hud(sMario)
  -- set player text
  local default = trans("runners")..": "
  local text = default
  for i=0,(MAX_PLAYERS-1) do
    if gPlayerSyncTable[i].team == 1 then
      local theirNP = gNetworkPlayers[i]
      local np = gNetworkPlayers[0]
      if theirNP.connected then
        if sMario.spectator == 0 and (np.currLevelNum == theirNP.currLevelNum) and (np.currActNum == theirNP.currActNum) and (np.currAreaIndex == theirNP.currAreaIndex) then
          local rm = gMarioStates[theirNP.localIndex]
          render_radar(rm, icon_radar[i])
        end
        local name = remove_color(theirNP.name)
        text = text .. name .. ", "
      end
    end
  end

  -- debug for me
  local np = gNetworkPlayers[0]
  if DEBUG_RADAR then
    local obj = obj_get_first_with_behavior_id(id_bhvStar)
    local i = 0
    while obj ~= nil do
      render_radar(obj, icon_radar[i], true)
      obj = obj_get_next_with_same_behavior_id(obj)
      i = i + 1
    end
  end

  if text == default then
    text = trans("no_runners")
  else
    text = text:sub(1,-3)
  end

  return text
end

function timer_hud()
  -- set timer text
  local seconds = math.ceil(gGlobalSyncTable.mhTimer/30)
  local text = trans("until_hunters",seconds)
  if seconds > 10 then
    text = trans("until_runners",(seconds-10))
  end

  return text
end

function victory_hud()
  -- set win text
  local text = trans("win",trans("hunters"))
  if gGlobalSyncTable.mhState > 3 then
    text = trans("win",trans("runners"))
  end
  return text
end

function camp_hud(sMario)
  return trans("camp_timer",math.floor(sMario.campTimer / 30))
end

-- removes color string
function remove_color(text)
  local start = text:find("\\")
  local next = 1
  while (next ~= nil) and (start ~= nil) do
    start = text:find("\\")
    if start ~= nil then
      next = text:find("\\",start+1)
      if next == nil then
        next = text:len() + 1
      end
      --local color = text:sub(start+1,next-1)
      text = text:sub(1,start-1) .. text:sub(next+1)
    end
  end
  return text
end

-- converts hex string to RGB values
function convert_color(text)
  text = text:sub(3,-2)
  local rstring = text:sub(1,2) or "ff"
  local gstring = text:sub(3,4) or "ff"
  local bstring = text:sub(5,6) or "ff"
  local r = 0
  local g = 0
  local b = 0
  for i=1,rstring:len() do
    local char = rstring:sub(i,i)
    local value = tonumber(char)
    if value == nil then
      value = char:byte() - 87
    end
    if i == 1 then
      r = r + value * 16
    else
      r = r + value
    end
  end
  for i=1,gstring:len() do
    local char = gstring:sub(i,i)
    local value = tonumber(char)
    if value == nil then
      value = char:byte() - 87
    end
    if i == 1 then
      g = g + value * 16
    else
      g = g + value
    end
  end
  for i=1,bstring:len() do
    local char = bstring:sub(i,i)
    local value = tonumber(char)
    if value == nil then
      value = char:byte() - 87
    end
    if i == 1 then
      b = b + value * 16
    else
      b = b + value
    end
  end
  -- print(tostring(r) .. "; " .. tostring(g) .. "; " .. tostring(b))
  -- print(rstring .. "; " .. gstring .. "; " .. bstring)
  return r,g,b
end

-- used in many commands
function get_specified_player(msg)
  local playerID = tonumber(msg)
  if msg == "" then
    playerID = 0
  end

  local np = nil
  if playerID == nil then
    for i=0,(MAX_PLAYERS-1) do
      np = gNetworkPlayers[i]
      if remove_color(np.name) == msg then
        playerID = i
        break
      end
    end
    if playerID == nil then
      djui_chat_message_create(trans("no_such_player"))
      return nil
    end
  elseif playerID ~= math.floor(playerID) or playerID < 0 or playerID > (MAX_PLAYERS-1) then
    djui_chat_message_create(trans("bad_id"))
    return nil
  else
    np = gNetworkPlayers[playerID]
  end
  if not np.connected then
    djui_chat_message_create(trans("no_such_player"))
    return nil
  end

  return playerID,np
end

function change_team_command(msg)
  local playerID,np = get_specified_player(msg)
  if playerID == nil then return true end

  local sMario = gPlayerSyncTable[playerID]
  local name = remove_color(np.name)
  if sMario.team ~= 1 then
    become_runner(sMario)
    djui_chat_message_create(name .. "'s team has been set to 'Runner'")
  else
    become_hunter(sMario)
    djui_chat_message_create(name .. "'s team has been set to 'Hunter'")
  end
  return true
end

function add_life_command(msg)
  local playerID,np = get_specified_player(msg)
  if playerID == nil then return true end

  local sMario = gPlayerSyncTable[playerID]
  local name = remove_color(np.name)
  if sMario.runnerLives ~= nil then
    sMario.runnerLives = sMario.runnerLives + 1
    djui_chat_message_create(name.." has been granted an extra life")
  elseif gGlobalSyncTable.mhState == 0 then
    djui_chat_message_create("Game hasn't been started yet")
  else
    djui_chat_message_create(name.." isn't a Runner")
  end
  return true
end

function allow_leave_command(msg)
  local playerID,np = get_specified_player(msg)
  if playerID == nil then return true end

  local sMario = gPlayerSyncTable[playerID]
  local name = remove_color(np.name)
  sMario.runTime = "done"
  djui_chat_message_create(name.." may leave")
  return true
end

function add_runner_command(msg)
  local runners = tonumber(msg)
  if runners == nil then return false end
  if runners ~= math.floor(runners) then return false end
  if runners < 1 then
    djui_chat_message_create("Can't add zero or negative runners")
    return true
  end

  -- get current hunters
  local currHunterIDs = {}
  for i=0,(MAX_PLAYERS-1) do
    local np = gNetworkPlayers[i]
    local sMario = gPlayerSyncTable[i]
    if np.connected and sMario.team ~= 1 then
      table.insert(currHunterIDs, np.localIndex)
    end
  end
  if #currHunterIDs < (runners + 1) then
    djui_chat_message_create("Not enough hunters to add that many")
    return true
  end

  local runnerNames = {}
  for i=1,runners do
    local selected = math.random(1, #currHunterIDs)
    local lIndex = currHunterIDs[selected]
    local sMario = gPlayerSyncTable[lIndex]
    local np = gNetworkPlayers[lIndex]
    become_runner(sMario)
    table.insert(runnerNames, np.name)
    table.remove(currHunterIDs,selected)
  end

  local text = "Added runners: "
  for i=1,#runnerNames do
    text = text .. runnerNames[i] .. "\\#ffffff\\, "
  end
  text = text:sub(1,-3)
  djui_chat_message_create(text)
  return true
end

function randomize_command(msg)
  local runners = tonumber(msg)
  if runners == nil then return false end
  if runners ~= math.floor(runners) then return false end
  if runners < 1 then
    djui_chat_message_create("ERROR: Must have at least 1 runner")
    return true
  end

  local total_online = 0
  local max_online_id = 0
  -- get total online
  for i=0,(MAX_PLAYERS-1) do
    local np = gNetworkPlayers[i]
    if np.connected then
      total_online = total_online + 1
      max_online_id = i
    end
  end
  if runners >= total_online or runners >= MAX_PLAYERS then
    djui_chat_message_create("ERROR: Maximum runners is currently "..(total_online-1))
    return true
  end

  local runnerNames = {}
  local runnerIDs = {}

  local limit = 0
  while runners > 0 and limit < 5000 do
    local playerID = math.random(0, max_online_id)
    if runnerIDs[playerID] == nil then
      local np = gNetworkPlayers[playerID]
      if np.connected then
        local sMario = gPlayerSyncTable[playerID]
        become_runner(sMario)
        table.insert(runnerNames, np.name)
        runnerIDs[playerID] = 1
        runners = runners - 1
      end
    end
    limit = limit + 1
  end
  if limit >= 5000 then
    djui_chat_message_create("ERROR RANDOMIZING PLAYERS!")
    return true
  end
  for i=0,(max_online_id) do
    local sMario = gPlayerSyncTable[i]
    local np = gNetworkPlayers[i]
    if runnerIDs[i] == nil then
      become_hunter(sMario)
    end
  end
  local text = "Runners are: "
  for i=1,#runnerNames do
    text = text .. runnerNames[i] .. "\\#ffffff\\, "
  end
  text = text:sub(1,-3)
  djui_chat_message_create(text)
  return true
end

function become_runner(sMario)
  sMario.team = 1
  sMario.runnerLives = gGlobalSyncTable.runnerLives
  sMario.runTime = 0
end

function become_hunter(sMario)
  sMario.team = 0
  sMario.runnerLives = nil
  sMario.runTime = nil
  sMario.campTimer = nil
end

function runner_lives_command(msg)
  local num = tonumber(msg)
  if num ~= nil and num >= 0 and num <= 99 and math.floor(num) == num then
    gGlobalSyncTable.runnerLives = num
    djui_chat_message_create("Runner lives set to "..num)
    return true
  end
  return false
end

function time_needed_command(msg)
  if gGlobalSyncTable.starMode then
    djui_chat_message_create("Disable star mode first!")
    return true
  end
  local num = tonumber(msg)
  if num ~= nil then
    gGlobalSyncTable.runTime = math.floor(num * 30)
    djui_chat_message_create("Runners can leave in "..num.." seconds now")
    return true
  end
  return false
end

function stars_needed_command(msg)
  if not gGlobalSyncTable.starMode then
    djui_chat_message_create("Enable star mode first!")
    return true
  end
  local num = tonumber(msg)
  if num ~= nil and num > 0 and num < 8 then
    gGlobalSyncTable.runTime = num
    djui_chat_message_create("Runners need "..num.." stars now")
    return true
  end
  return false
end

function star_count_command(msg)
  local num = tonumber(msg)
  if num ~= nil and num >= -1 and num <= ROMHACK.max_stars and math.floor(num) == num then
    gGlobalSyncTable.starRun = num
    if num ~= -1 then
      djui_chat_message_create("This is now a "..num.." star run")
    else
      djui_chat_message_create("This is now an any% run")
    end
    return true
  end
  return false
end

function runner_switch_command(msg)
  if string.lower(msg) == "on" then
    gGlobalSyncTable.runnerSwitch = true
    djui_chat_message_create("Runners will now switch")
    return true
  elseif string.lower(msg) == "off" then
    gGlobalSyncTable.runnerSwitch = false
    djui_chat_message_create("Runners will no longer switch")
    return true
  end
  return false
end

function star_mode_command(msg)
  if string.lower(msg) == "on" then
    gGlobalSyncTable.starMode = true
    gGlobalSyncTable.runTime = 2
    djui_chat_message_create("Using stars collected")
    return true
  elseif string.lower(msg) == "off" then
    gGlobalSyncTable.starMode = false
    gGlobalSyncTable.runTime = 7200
    djui_chat_message_create("Using timer")
    return true
  end
  return false
end

function spectate_command(msg)
  if string.lower(msg) == "on" then
    gGlobalSyncTable.allowSpectate = true
    djui_chat_message_create("Hunters can now spectate")
    return true
  elseif string.lower(msg) == "off" then
    gGlobalSyncTable.allowSpectate = false
    djui_chat_message_create("Hunters can no longer spectate")
    return true
  end
  return false
end

-- TroopaParaKoopa's pause mod
function pause_command(msg)
  if msg == "all" then
    if gGlobalSyncTable.pause then
      gGlobalSyncTable.pause = false
      djui_chat_message_create("All players unpaused")
    else
      gGlobalSyncTable.pause = true
      djui_chat_message_create("All players paused")
    end
    return true
  end

  local playerID,np = get_specified_player(msg)
  if playerID == nil then return true end

  local sMario = gPlayerSyncTable[playerID]
  local name = remove_color(np.name)
  if sMario.pause then
    sMario.pause = false
    djui_chat_message_create(name .. " has been unpaused")
  else
    sMario.pause = true
    djui_chat_message_create(name .. " has been paused")
  end
  return true
end
-- TroopaParaKoopa's Level Cooldown
hook_event(HOOK_ON_WARP,
   function()
       gMarioStates[0].invincTimer = 100
       died = false
   end
)

-- based off of example
function mario_update(m)
  lock_place(m)
  if ROMHACK.special_run ~= nil then
    ROMHACK.special_run(m)
  end

  local sMario = gPlayerSyncTable[m.playerIndex]
  local np = gNetworkPlayers[m.playerIndex]
  -- set descriptions
  if sMario.team == 1 then
    if desc_switch_timer > 30 then
      network_player_set_description(np, trans("runner"), 0, 255, 255, 255)
    else
      if sMario.runnerLives ~= 1 then
        network_player_set_description(np, trans("show_lives",sMario.runnerLives), 0, 255, 255, 255)
      else
        network_player_set_description(np, trans("show_lives_one"), 0, 255, 255, 255)
      end
    end
  else
    network_player_set_description(np, trans("hunter"), 255, 92, 92, 255)
  end
  if m.playerIndex == 0 then
    if desc_switch_timer < 1 then
      desc_switch_timer = 61
    end
    desc_switch_timer = desc_switch_timer - 1
  end

  -- don't do the ending cutscene for hunters
  if m.action == ACT_JUMBO_STAR_CUTSCENE and sMario.team ~= 1 then
    if m.prevAction ~= ACT_JUMBO_STAR_CUTSCENE then
      m.action = m.prevAction
    else
      m.action = ACT_IDLE
    end
  end

  -- not if game isn't started
  if gGlobalSyncTable.mhState ~= nil and (gGlobalSyncTable.mhState == 0 or gGlobalSyncTable.mhState >= 3) then return end

  -- for all players: disable endless stairs if there's enough stars
  local surface = m.floor
  if gGlobalSyncTable.starRun ~= -1 and surface ~= nil and surface.type == 27 and m.numStars >= gGlobalSyncTable.starRun then
    surface.type = 0
    m.floor = surface
  end

  -- enforce star requirements
  if m.playerIndex == 0 and gGlobalSyncTable.starRun ~= -1 and ROMHACK.requirements ~= nil then
    local requirements = ROMHACK.requirements[np.currLevelNum] or 0
    if requirements > gGlobalSyncTable.starRun then
      requirements = gGlobalSyncTable.starRun
    end
    if ROMHACK.ddd and np.currLevelNum == LEVEL_DDD then
      requirements = requirements - 1
    end
    if m.numStars < requirements then
      warp_to_castle(np.currLevelNum)
    end
  end

  -- hunter update
  if sMario.team ~= 1 then return hunter_update(m,sMario) end
  -- runner update
  return runner_update(m,sMario)
end

function on_player_disconnected(m)
  -- for host only
  if network_is_server() then
    -- detect if there are not enough runners in switch mode
    local sMario = gPlayerSyncTable[m.playerIndex]
    if sMario.team == 1 then
      local np = gNetworkPlayers[m.playerIndex]
      local discordID = discordIDTable[m.playerIndex]
      if discordID ~= nil then
        print(discordID,"left")
        local playerColor = network_get_player_text_color_string(np.localIndex)
        local name = playerColor .. np.name
        rejoin_timer[discordID] = {name = name, timer = 3600, lives = sMario.runnerLives } -- 2 minutes
        djui_popup_create(trans("rejoin_start",name), 2)
      elseif gGlobalSyncTable.runnerSwitch then
        local newID = new_runner(true)
        if newID ~= nil then
          network_send(true, {
              id = PACKET_KILL,
              runnerID = nil,
              death = false,
              newRunnerID = newID
          })
          if newID ~= nil then
            local np = network_player_from_global_index(newID)
            local playerColor = network_get_player_text_color_string(np.localIndex)
            djui_popup_create(trans("now_runner",(playerColor .. np.name)), 2)
          end
        end
      end
    end
  end
end



function runner_update(m,sMario)
  local np = gNetworkPlayers[m.playerIndex]

  -- detect victory
  if m.playerIndex == 0 and ROMHACK ~= nil and ROMHACK.runner_victory ~= nil and ROMHACK.runner_victory(m) and gGlobalSyncTable.mhState < 3 then
    gGlobalSyncTable.mhState = 4
    network_send(true, {
      id = PACKET_GAME_END,
      winner = 1,
    })
    game_end_sfx({winner = 1})
    local wins = tonumber(mod_storage_load("wins"))
    if wins == nil then
      wins = 0
    end
    mod_storage_save("wins",tostring(math.floor(wins)+1))
  end

  -- match life counter to actual lives
  if m.playerIndex == 0 and m.numLives ~= sMario.runnerLives then
    m.numLives = sMario.runnerLives
  end

  -- reduce timer
  if m.playerIndex == 0 and sMario.runTime ~= "done" then
    if not gGlobalSyncTable.starMode then
      sMario.runTime = sMario.runTime + 1
    end

    -- match run time with other runners in level
    for i=1,(MAX_PLAYERS-1) do
      if gPlayerSyncTable[i].team == 1 and gNetworkPlayers[i].connected then
        local theirNP = gNetworkPlayers[i] -- daft variable naming conventions
        local theirSMario = gPlayerSyncTable[i]
        if (np.currLevelNum == theirNP.currLevelNum) and (np.currActNum == theirNP.currActNum) and sMario.runTime ~= "done" and theirSMario.runTime ~= "done" and sMario.runTime < theirSMario.runTime then
          sMario.runTime = theirSMario.runTime
        end
      end
    end
  end

  -- invincibility timers for certain actions
  local runner_invincible = {
    [ACT_PICKING_UP_BOWSER] = 90, -- 3 seconds
    [ACT_RELEASING_BOWSER] = 10,
    [ACT_READING_NPC_DIALOG] = 30,
    [ACT_READING_AUTOMATIC_DIALOG] = 30,
    [ACT_HEAVY_THROW] = 10,
    [ACT_PUTTING_ON_CAP] = 10,
    [ACT_STAR_DANCE_NO_EXIT] = 30, -- 1 second
    [ACT_WAITING_FOR_DIALOG] = 10,
    [ACT_DEATH_EXIT_LAND] = 10,
  }
  local newInvincTimer = runner_invincible[m.action]
  if newInvincTimer ~= nil and m.invincTimer < newInvincTimer then
    m.invincTimer = newInvincTimer
  end

  -- reduces water heal
  if (m.action & ACT_FLAG_SWIMMING) ~= 0 and m.pos.y >= m.waterLevel - 140 and np.currLevelNum ~= LEVEL_SL then
    -- water heal is 26 (decimal) per frame
    m.health = m.health - 22
  end

  -- add stars
  if m.prevNumStarsForDialog < m.numStars then
    m.prevNumStarsForDialog = m.numStars -- this also disables some dialogue, which helps with the fast pace
    if m.playerIndex == 0 and gotStar then
      if sMario.runTime ~= "done" then
        if gGlobalSyncTable.starMode then
          sMario.runTime = sMario.runTime + 1 -- 1 star
        else
          sMario.runTime = sMario.runTime + 1800 -- 1 minute
        end
      end
      -- send message
      network_send(true, {
        id = PACKET_RUNNER_STAR,
        runnerID = np.globalIndex,
        star = true,
      })
    end
  end
  if m.playerIndex == 0 then
    gotStar = false
  end
end

function hunter_update(m,sMario)
  -- infinite lives
  m.numLives = 100

  -- only local mario at this point
  if m.playerIndex ~= 0 then return end

  -- check for runners
  local stillrunners = false
  for i=0,(MAX_PLAYERS-1) do
    if gPlayerSyncTable[i].team == 1 and gNetworkPlayers[i].connected then
      stillrunners = true
      break
    end
  end

  -- detect victory for hunters (only host to avoid disconnect bugs)
  if network_is_server() then
    if stillrunners == false and gGlobalSyncTable.mhState < 3 and gGlobalSyncTable.runnerSwitch == false then
      for id,data in pairs(rejoin_timer) do
        if data.timer > 0 then
          stillrunners = true
          break
        end
      end
      if stillrunners == false then
        gGlobalSyncTable.mhState = 3
        network_send(true, {
          id = PACKET_GAME_END,
          winner = 0,
        })
        game_end_sfx({winner = 0})
      end
    end
  end
end

function on_allow_interact(m, o, type)
    -- disable during game start or end
    if gGlobalSyncTable.mhState ~= nil and (gGlobalSyncTable.mhState == 0 or gGlobalSyncTable.mhState >= 3) then return false end

    local sMario = gPlayerSyncTable[m.playerIndex]
    -- disable for spectators
    if sMario.spectator == 1 then return false end

    -- prevent hunters from interacting with certain things that help or softlock the runner
    local banned_hunter = {
      [id_bhvRedCoin] = 1, -- no!! you cant get the red coins you're helping the runner!!!!!! - troopa
      [id_bhvKingBobomb] = 1,
    }

    local obj_id = get_id_from_behavior(o.behavior)
    if type == INTERACT_STAR_OR_KEY or banned_hunter[obj_id] ~= nil then
      if sMario.team ~= 1 then
        return false
      elseif m.playerIndex ~= 0 then
        return true -- ignore if not local player
      elseif obj_id == id_bhvBowserKey then -- is a key
        local np = gNetworkPlayers[m.playerIndex]
        if np.currLevelNum == LEVEL_BOWSER_1 then
          if ((save_file_get_flags() & SAVE_FLAG_HAVE_KEY_1) ~= 0 or (save_file_get_flags() & SAVE_FLAG_UNLOCKED_BASEMENT_DOOR) ~= 0) then
            return true
          end
        elseif np.currLevelNum == LEVEL_BOWSER_2 then
          if ((save_file_get_flags() & SAVE_FLAG_HAVE_KEY_2) ~= 0 or (save_file_get_flags() & SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR) ~= 0) then
            return true
          end
        end

        -- send message
        network_send(true, {
          id = PACKET_RUNNER_STAR,
          runnerID = np.globalIndex,
          star = false,
        })
      elseif obj_id ~= id_bhvGrandStar then -- this isn't a star, really
        gotStar = true -- set flag that we're the ones who got the star
      end
      return true
    end
end

function lock_place(m)
  local sMario = gPlayerSyncTable[m.playerIndex]
  -- only during timer or pause
  if sMario.pause or gGlobalSyncTable.pause or gGlobalSyncTable.mhState == 1 then
    -- runners get 10 second head start
    if sMario.pause or gGlobalSyncTable.pause or sMario.team ~= 1 or gGlobalSyncTable.mhTimer > (10 * 30) then
      m.freeze = true
      m.invincTimer = 30
      m.marioBodyState.modelState = MODEL_STATE_NOISE_ALPHA
      set_mario_action(m, ACT_PAUSE, 0)
      if gGlobalSyncTable.mhTimer > 0 then
        m.health = 0x880
      end
    end
  end
end

-- team chat stuff
function tc_command(msg)
  local sMario = gPlayerSyncTable[0]
  if string.lower(msg) == "on" then
    sMario.teamChat = true
    djui_chat_message_create(trans("tc_on"))
  elseif string.lower(msg) == "off" then
    sMario.teamChat = false
    djui_chat_message_create(trans("tc_off"))
  else
    send_tc(msg)
  end
  return true
end
function send_tc(msg)
  local myGlobalIndex = gNetworkPlayers[0].globalIndex
  local sMario = gPlayerSyncTable[0]
  network_send(true, {
    id = PACKET_TC,
    sender = myGlobalIndex,
    receiverteam = sMario.team,
    msg = msg,
  })
  djui_chat_message_create(trans("to_team")..msg)
  local m = gMarioStates[0]
  play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, m.marioObj.header.gfx.cameraToObject)

  return true
end
function on_packet_tc(data)
  local sender = data.sender
  local receiverteam = data.receiverteam
  local msg = data.msg
  local sMario = gPlayerSyncTable[0]
  if sMario.team == receiverteam then
    local np = network_player_from_global_index(data.sender)
    if np ~= nil then
      local playerColor = network_get_player_text_color_string(np.localIndex)
      djui_chat_message_create(playerColor .. np.name .. trans("from_team") ..data.msg)
      local m = gMarioStates[0]
      play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, m.marioObj.header.gfx.cameraToObject)
    end
  end
end
function on_chat_message(m, msg)
  local sMario = gPlayerSyncTable[m.playerIndex]
  if sMario.teamChat == true then
    if m.playerIndex == 0 then
      send_tc(msg)
    end
    return false
  end
  return true
end
hook_chat_command("tc", "[ON|OFF|MSG] - Send message to team only; turn ON to apply to all messages", tc_command)
hook_event(HOOK_ON_CHAT_MESSAGE, on_chat_message)

function on_course_enter()
  local sMario = gPlayerSyncTable[0]
  attackedBy = nil
  if sMario.team == 1 then
    sMario.runTime = 0
    died = false
  end
  justEntered = true
end

function on_packet_runner_star(data)
  runnerID = data.runnerID
  if runnerID ~= nil then
    local np = network_player_from_global_index(runnerID)
    local playerColor = network_get_player_text_color_string(np.localIndex)
    if data.star == true then
      djui_popup_create(trans("got_star",(playerColor .. np.name)), 2)
    elseif np.currLevelNum ~= LEVEL_BOWSER_3 then
      djui_popup_create(trans("got_key",(playerColor .. np.name)), 2)
    end
  end
end

function on_packet_kill(data)
  local killed = data.killed
  local killer = data.killer
  local newRunnerID = data.newRunnerID
  local m = gMarioStates[0]
  if killed ~= nil then
    local np = network_player_from_global_index(killed)
    local playerColor = network_get_player_text_color_string(np.localIndex)
    if data.death ~= true then
      if killer ~= nil then
        local killerNP = network_player_from_global_index(killer)
        local kPlayerColor = network_get_player_text_color_string(killerNP.localIndex)
        if killerNP.localIndex == 0 then
          m.healCounter = 0x781 -- full health minus death amount
          play_sound(SOUND_GENERAL_STAR_APPEARS, m.marioObj.header.gfx.cameraToObject)
        end
        djui_popup_create(trans("killed",(kPlayerColor .. killerNP.name),(playerColor .. np.name)), 2)
      else
        djui_popup_create(trans("lost_life",(playerColor .. np.name)), 2)
        play_sound(SOUND_OBJ_BOWSER_LAUGH, m.marioObj.header.gfx.cameraToObject)
      end
    else
      if killer ~= nil then
        local killerNP = network_player_from_global_index(killer)
        local kPlayerColor = network_get_player_text_color_string(killerNP.localIndex)
        if killerNP.localIndex == 0 then
          m.healCounter = 0x78A -- full health minus death amount
          play_character_sound(m, CHAR_SOUND_HERE_WE_GO)
        end
        djui_popup_create(trans("sidelined",(kPlayerColor .. killerNP.name),(playerColor .. np.name)), 2)
      else
        djui_popup_create(trans("lost_all",(playerColor .. np.name)), 2)
        play_sound(SOUND_OBJ_BOWSER_LAUGH, m.marioObj.header.gfx.cameraToObject)
      end
    end
  end
  if newRunnerID ~= nil then
    local np = network_player_from_global_index(newRunnerID)
    local playerColor = network_get_player_text_color_string(np.localIndex)
    djui_popup_create(trans("now_runner",(playerColor .. np.name)), 2)
    if np.localIndex == 0 then
      play_sound(SOUND_GENERAL_SHORT_STAR, m.marioObj.header.gfx.cameraToObject)
    end
  end
end

function game_end_sfx(data)
  if data.winner == 1 then
    play_race_fanfare()
  else
    play_secondary_music(SEQ_EVENT_KOOPA_MESSAGE, 0, 100, 60)
  end
end

function on_packet_wins(data)
  if data.wins ~= 1 then
    djui_chat_message_create(trans("total_wins",data.name,data.wins))
  else
    djui_chat_message_create(trans("total_wins_one",data.name))
  end
end

-- packets
PACKET_RUNNER_STAR = 0
PACKET_KILL = 1
PACKET_MH_START = 2
PACKET_TC = 3
PACKET_GAME_END = 4
PACKET_WINS = 5
sPacketTable = {
    [PACKET_RUNNER_STAR] = on_packet_runner_star,
    [PACKET_KILL] = on_packet_kill,
    [PACKET_MH_START] = do_game_start,
    [PACKET_TC] = on_packet_tc,
    [PACKET_GAME_END] = game_end_sfx,
    [PACKET_WINS] = on_packet_wins,
}

-- from arena
function on_packet_receive(dataTable)
    if sPacketTable[dataTable.id] ~= nil then
        sPacketTable[dataTable.id](dataTable)
    end
end

-- main command
hook_chat_command("mh", "[COMMAND] - Commands for MarioHunt; type nothing to list; host or moderator only", mario_hunt_command)
function setup_commands()
  -- commands for main command
  marioHuntCommands = {}
  marioHuntCommands.start = {"[CONTINUE|MAIN|ALT] - Starts the game; add \"continue\" to not warp to start; add \"alt\" for alt save file; add \"main\" for main save file", start_game_command}
  marioHuntCommands.addrunner = {"[INT] - Adds the specified amount of runners at random", add_runner_command}
  marioHuntCommands.randomize = {"[INT] - Picks the specified amount of runners at random", randomize_command}
  marioHuntCommands.runnerlives = {"[INT] - Sets the amount of lives Runners have, from 0 to 99 (note: 0 lives is still 1 life)", runner_lives_command}
  marioHuntCommands.timeneeded = {"[NUM] - Sets the maximum amount of time Runners have to wait to leave, in seconds", time_needed_command}
  marioHuntCommands.starsneeded = {"[INT] - Sets the maximum amount of stars Runners must collect to leave, from 1 to 7 (only in star mode)", stars_needed_command}
  marioHuntCommands.starrun = {"[INT] - Sets the amount of stars Runners must have to face Bowser. Set to -1 for any%.", star_count_command}
  marioHuntCommands.changeteam = {"[NAME|ID] - Flips the team of the specified player, or your own if none entered", change_team_command}
  marioHuntCommands.addlife = {"[NAME|ID] - Adds another runner life to the specified player or yourself if none entered", add_life_command}
  marioHuntCommands.allowleave = {"[NAME|ID] - Allows the specified player, or yourself if none entered, to leave the level if they are a runner", allow_leave_command}
  marioHuntCommands.runnerswitch = {"[ON|OFF] - Toggles runner switch; switches runners when one dies; off by default", runner_switch_command}
  marioHuntCommands.starmode = {"[ON|OFF] - Toggles using stars collected instead of timer; off by default", star_mode_command}
  marioHuntCommands.spectator = {"[ON|OFF] - Toggles Hunters' ability to spectate; on by default", spectate_command}
  marioHuntCommands.pause = {"[NAME|ID|ALL] - Toggles pause status for specified players, self if not specified, or all", pause_command}

  -- debug
  marioHuntCommands.print = {"[STRING] - Outputs message to console", print, true}
  marioHuntCommands.warp = {"[INT,INT,INT,INT] - warp to level", do_warp, true}
  marioHuntCommands.radar_debug = {"[ON|OFF] - Sets radar debug", radar_debug, true}
  marioHuntCommands.quick = {"- Makes you runner and warps you to BOB with the game active and radar debug on", quick_debug, true}
end

--[[function disable_hunter_interact(obj)
  local sMario = gPlayerSyncTable[0]
  if sMario.team ~= 1 then
    obj.oCollisionDistance = 0
  else
    obj.oCollisionDistance = 1000
  end
  return true
end]]

-- hooks
hook_event(HOOK_UPDATE, update)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ALLOW_PVP_ATTACK, allow_pvp_attack)
hook_event(HOOK_ON_PLAYER_CONNECTED, on_player_connected)
hook_event(HOOK_ON_PLAYER_DISCONNECTED, on_player_disconnected)
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
hook_event(HOOK_ON_PAUSE_EXIT, on_pause_exit)
hook_event(HOOK_ON_LEVEL_INIT, on_course_enter)
hook_event(HOOK_ON_PACKET_RECEIVE, on_packet_receive)
hook_event(HOOK_ON_DEATH, on_death)
hook_event(HOOK_ALLOW_INTERACT, on_allow_interact)
--[[hook_behavior(id_bhvTreasureChestsJrb, OBJ_LIST_DEFAULT, false, nil, disable_hunter_interact)
hook_behavior(id_bhvWhompKingBoss, OBJ_LIST_SURFACE, false, nil, disable_hunter_interact)
hook_behavior(id_bhvHiddenStarTrigger, OBJ_LIST_LEVEL, false, nil, disable_hunter_interact)
hook_chat_command("count_level","a",function()
  local obj = obj_get_first(OBJ_LIST_LEVEL)
  while obj ~= nil do
    djui_chat_message_create(get_behavior_name_from_id(get_id_from_behavior(obj.behavior)) or "none!")
    obj = obj_get_next(obj)
  end
  return true
end)]]
