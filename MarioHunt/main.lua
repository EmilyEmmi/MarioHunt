-- name: Mariohunt (v1.8)
-- incompatible: gamemode
-- description: A gamemode based off of Beyond's concept.\n\nHunters stop Runners from clearing the game!\n\nProgramming by EmilyEmmi, TroopaParaKoopa, Blocky, Sunk, and Sprinter05.\n\nSpanish Translation made with help from KanHeaven and SonicDark.\nGerman Translation made by N64 Mario.\nBrazillian Portuguese translation made by PietroM.\nFrench translation made by Skeletan.\n\n\"Shooting Star Summit\" port by pieordie1

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
  start_game_command("continue")
  if msg == "hunter" then
    gGlobalSyncTable.mhMode = 1
    become_hunter(sMario)
    warp_to_level(LEVEL_BOB, 1, 1)
  elseif msg == "radar" then
    DEBUG_RADAR = true
    warp_to_level(LEVEL_BOB, 1, 1)
  elseif msg ~= "" then
    do_warp(msg)
  else
    warp_to_level(LEVEL_BOB, 1, 1)
  end

  return true
end

function combo_debug(msg)
  local np = gNetworkPlayers[0]
  local playerColor = network_get_player_text_color_string(0)
  network_send_include_self(false, {
    id = PACKET_KILL_COMBO,
    name = playerColor .. np.name,
    kills = tonumber(msg) or 0,
  })
  print(get_dialog_id())
  return true
end

function get_discord_ids(msg)
  for i=0,(MAX_PLAYERS-1) do
    local sMario = gPlayerSyncTable[i]
    local np = gNetworkPlayers[i]
    if np.connected then
      print(np.name..": ",(sMario.discordID or "NIL"))
      djui_chat_message_create(np.name..": "..(sMario.discordID or "NIL"))
    end
  end
  return true
end

-- TroopaParaKoopa's pause mod
ACT_PAUSE = allocate_mario_action(ACT_FLAG_IDLE)
gGlobalSyncTable.pause = false

-- TroopaParaKoopa's hns metal cap option
gGlobalSyncTable.metal = false

if network_is_server() then
  gGlobalSyncTable.runnerLives = 1 -- the lives runners get (0 is a life)
  gGlobalSyncTable.runTime = 7200 -- time runners must stay in stage to leave (default: 4 minutes)
  gGlobalSyncTable.starRun = 70 -- stars runners must get to face bowser; star doors and infinite stairs will be disabled accordingly
  gGlobalSyncTable.allowSpectate = true -- hunters can spectate
  gGlobalSyncTable.starMode = false -- use stars collected instead of timer
  gGlobalSyncTable.weak = false -- cut invincibility frames in half
  gGlobalSyncTable.mhState = 0 -- game state
  --[[
    0: not started
    1: timer
    2: game started
    3: game ended (hunters win)
    4: game ended (runners win)
  ]]
  gGlobalSyncTable.mhMode = 0 -- game modes, as follows:
  --[[
    0: Normal
    1: Switch
  ]]
  gGlobalSyncTable.mhTimer = 0 -- timer in frames (game is 30 FPS)
  gGlobalSyncTable.otherSave = false -- using other save file
  gGlobalSyncTable.bowserBeaten = false -- used for Star Road
  gGlobalSyncTable.ee = false -- used for SM74
  gGlobalSyncTable.omm = flase -- is true if using OMM Rebirth

  rejoin_timer = {} -- rejoin timer for runners
end

smlua_audio_utils_replace_sequence(0x41, 0x25, 65, "Shooting_Star_Summit") -- for lobby; hopefully there's no conflicts

-- force pvp, knockback, skip intro, and no bubble death
gServerSettings.playerInteractions = PLAYER_INTERACTIONS_PVP
gServerSettings.playerKnockbackStrength = 20
gServerSettings.bubbleDeath = 0
gServerSettings.skipIntro = 1

gotStar = nil -- what star we just got
died = false -- if we've died (because on_death runs every frame of death fsr)
didFirstJoinStuff = false -- if all of the initial code was run (rules message, etc.)
justEntered = false -- entered a course
desc_switch_timer = 60 -- to make the description for runners switch
cooldownCaps = 0 -- stores m.flags, to see what caps are on cooldown
regainCapTimer = 0 -- timer for being able to recollect a cap
-- campTimer for camping actions (such as reading text or being in the star menu), nil means it is inactive
killTimer = 0 -- timer for kills in quick succession
killCombo = 0 -- kills in quick succession
hitTimer = 0 -- timer for being hit by another player

-- main command
function mario_hunt_command(msg)
  local np = gNetworkPlayers[0]
  local isDev = (network_discord_id_from_local_index(0) == "409438020870078486") -- my discord id
  if not (network_is_server() or network_is_moderator() or isDev) then
    djui_chat_message_create(trans("not_mod"))
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
      local desc = trans(cmd .. "_desc")
      local hidden = false
      if cdata[2] == true then
        if not isDev then
          hidden = true
        end
      end

      if not hidden then
        djui_chat_message_create("/mh " .. cmd .. " " .. desc)
      end
    end
  else
    local cmd = marioHuntCommands[usedCmd]
    if cmd == nil and marioHuntAlias[usedCmd] ~= nil then
      cmd = marioHuntCommands[marioHuntAlias[usedCmd]]
    end
    if cmd ~= nil then
      local func = cmd[1]

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
function start_game_command(msg)
  -- count runners
  local runners = 0
  for i=0,(MAX_PLAYERS-1) do
    if gPlayerSyncTable[i].team == 1 and gNetworkPlayers[i].connected then
      runners = runners + 1
    end
  end
  if runners < 1 then
    djui_chat_message_create(trans("error_no_runners"))
    return true
  end

  if string.lower(msg) ~= "continue" then
    gGlobalSyncTable.mhState = 1
    gGlobalSyncTable.mhTimer = 15 * 30 -- 15 seconds
  else
    gGlobalSyncTable.mhState = 2
    gGlobalSyncTable.mhTimer = 0
  end

  local cmd = "none"
  if msg ~= nil and msg ~= "" then
    cmd = msg
  end
  network_send_include_self(true, {
    id = PACKET_MH_START,
    cmd = cmd,
  })
  return true
end
function do_game_start(data)
  local msg = data.cmd or ""
  if string.lower(msg) ~= "continue" then
    local sMario = gPlayerSyncTable[0]
    local m = gMarioStates[0]
    if sMario.team == 1 then
      sMario.runnerLives = gGlobalSyncTable.runnerLives
      sMario.runTime = 0
      died = false
      m.numLives = sMario.runnerLives
    else -- save 'been runner' status
      print("Our 'Been Runner' status has been cleared")
      sMario.beenRunner = 0
      mod_storage_save("beenRunnner", "0")
    end
    killTimer = 0
    killCombo = 0

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
    -- false if timer going or game end
    if gGlobalSyncTable.mhState == 1 then return false end
    if gGlobalSyncTable.mhState >= 3 then return false end

    local npAttacker = gNetworkPlayers[attacker.playerIndex]
    local sAttacker = gPlayerSyncTable[attacker.playerIndex]

    -- check teams
    local success = global_index_hurts_mario_state(npAttacker.globalIndex, victim)
    if success and victim.playerIndex == 0 then
      attackedBy = npAttacker.globalIndex
      hitTimer = 300 -- 10 seconds
    end
    return success
end

-- code from arena
function global_index_hurts_mario_state(globalIndex, m)
    -- allow hurting each other in lobby
    if gGlobalSyncTable.mhState == 0 then return true end
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

function get_leave_requirements(sMario)
  local np = gNetworkPlayers[0]
  local available_stars = 7
  -- in castle
  if np.currCourseNum == 0 then
    return 0,trans("in_castle")
  end

  -- for leave command
  if sMario.allowLeave then
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
    if ROMHACK ~= nil and ROMHACK.area_stars ~= nil
    and ROMHACK.area_stars[np.currLevelNum] ~= nil
    and ROMHACK.area_stars[np.currLevelNum][1] == np.currAreaIndex then
      available_stars = ROMHACK.area_stars[np.currLevelNum][2]
    end
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
  if died == false then
    local sMario = gPlayerSyncTable[0]
    local lost = false
    local newID = nil
    local runner = false
    local time = sMario.runTime or 0
    m.health = 0xFF -- Mario's health is used to see if he has respawned
    died = true

    -- change to hunter
    if gGlobalSyncTable.mhState == 2 and sMario.team == 1 and sMario.runnerLives <= 0 then
      runner = true
      m.numLives = 100
      m.health = 0x880
      become_hunter(sMario)
      lost = true
      if not dont_warp then
        warp_beginning()
      end

      -- pick new runner
      if gGlobalSyncTable.mhMode == 1 then
        if attackedBy ~= nil then
          local killerNP = network_player_from_global_index(attackedBy)
          local kSMario = gPlayerSyncTable[killerNP.localIndex]
          if kSMario.team ~= 1 then
            become_runner(kSMario)
            newID = attackedBy
          else
            newID = new_runner()
          end
        else
          newID = new_runner()
        end
      end
    end

    if sMario.runnerLives ~= nil and gGlobalSyncTable.mhState == 2 then
      sMario.runnerLives = sMario.runnerLives - 1
      runner = true
    end

    if attackedBy == nil and (not runner) then return true end -- no one cares about hunters dying

    local np = gNetworkPlayers[0]
    network_send_include_self(true, {
        id = PACKET_KILL,
        killed = np.globalIndex,
        killer = attackedBy,
        death = lost,
        newRunnerID = newID,
        time = time,
        runner = runner,
    })
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
    if np.connected and sMario.team ~= 1 and sMario.spectator ~= 1 then
      table.insert(currHunterIDs, np.localIndex)
    end
  end
  if #currHunterIDs < 1 then
    if not includeLocal then
      local sMario = gPlayerSyncTable[0] -- just make them runner again
      local np = gNetworkPlayers[0]
      return np.globalIndex
    else
      return nil
    end
  end

  local lIndex = currHunterIDs[math.random(1, #currHunterIDs)]
  local np = gNetworkPlayers[lIndex]
  return np.globalIndex
end

function update()
  do_pause()
  local sMario = gPlayerSyncTable[0]

  if (not didFirstJoinStuff) and gGlobalSyncTable.mhState ~= nil and gGlobalSyncTable.starRun ~= nil
  and gGlobalSyncTable.otherSave ~= nil and gGlobalSyncTable.runTime ~= nil and gGlobalSyncTable.ee ~= nil then
    setup_hack_data(network_is_server(), true)
    show_rules()
    print(get_time())
    math.randomseed(get_time())

    djui_chat_message_create(trans("to_switch",lang_list))

    save_file_set_using_backup_slot(gGlobalSyncTable.otherSave)
    save_file_reload(1)
    if gGlobalSyncTable.otherSave then
      warp_beginning()
    end

    local m = gMarioStates[0]
    m.numStars = save_file_get_total_star_count(get_current_save_file_num()-1,COURSE_MIN-1,COURSE_MAX-1)
    m.prevNumStarsForDialog = m.numStars

    -- display and set stats
    local wins = tonumber(mod_storage_load("wins")) or 0
    local kills = tonumber(mod_storage_load("kills")) or 0
    local maxStreak = tonumber(mod_storage_load("maxStreak")) or 0
    sMario.wins = math.floor(wins)
    sMario.kills = math.floor(kills)
    sMario.maxStreak = math.floor(maxStreak)
    if wins >= 1 then
      local np = gNetworkPlayers[0]
      local playerColor = network_get_player_text_color_string(0)
      network_send_include_self(false, {
        id = PACKET_STATS,
        stat = "disp_wins",
        value = math.floor(wins),
        name = playerColor .. np.name,
      })
    end
    if kills >= 50 then
      local np = gNetworkPlayers[0]
      local playerColor = network_get_player_text_color_string(0)
      network_send_include_self(false, {
        id = PACKET_STATS,
        stat = "disp_kills",
        value = math.floor(kills),
        name = playerColor .. np.name,
      })
    end
    local beenRunner = mod_storage_load("beenRunnner")
    sMario.beenRunner = tonumber(beenRunner) or 0
    print("Our 'Been Runner' status is ",sMario.beenRunner)

    local sMario = gPlayerSyncTable[0]
    local discordID = network_discord_id_from_local_index(0)
    print("My discord ID is",tostring(discordID))
    if discordID ~= nil and discordID ~= "0" then
      sMario.discordID = discordID
    end

    -- start out as hunter
    become_hunter(sMario)
    sMario.pause = nil

    if gGlobalSyncTable.mhState == 0 then
      set_background_music(0,0,0)
      play_music(0, 0x41, 1)
    end

    didFirstJoinStuff = true
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
        if gGlobalSyncTable.mhState == 1 then
          gGlobalSyncTable.mhState = 2
        else
          gGlobalSyncTable.mhState = 0
        end
      end
    end
    for id,data in pairs(rejoin_timer) do
      data.timer = data.timer - 1
      if data.timer <= 0 then
        djui_popup_create(trans("rejoin_fail",data.name), 2)
        rejoin_timer[id] = nil -- times up

        if gGlobalSyncTable.mhMode == 1 then
          local newID = new_runner(true)
          if newID ~= nil then
            network_send_include_self(true, {
                id = PACKET_KILL,
                newRunnerID = newID,
                time = 0,
            })
          end
        end
      end
    end
  end
  camp_timer(sMario) -- camping timer
  -- kill combo stuff
  if killTimer > 0 then
    killTimer = killTimer - 1
    if killTimer == 0 then
      if killCombo > 1 then
        local np = gNetworkPlayers[0]
        local playerColor = network_get_player_text_color_string(np.localIndex)
        network_send_include_self(false, {
          id = PACKET_KILL_COMBO,
          name = playerColor .. np.name,
          kills = killCombo,
        })
      end
      if gGlobalSyncTable.mhState ~= 0 then
        local maxStreak = tonumber(mod_storage_load("maxStreak"))
        if maxStreak == nil or killCombo > maxStreak then
          mod_storage_save("maxStreak",tostring(math.floor(killCombo)))
          sMario.maxStreak = killCombo
        end
      end
      killCombo = 0
    end
  end
  if hitTimer > 0 then
    hitTimer = hitTimer - 1
    if hitTimer == 0 then attackedBy = nil end
  end
end

function camp_timer(sMario)
  local m = gMarioStates[0]
  local c = m.area.camera
  if sMario.team == 1 then
    if m.freeze == true or (m.freeze ~= false and m.freeze > 0) and not is_game_paused() then
      if campTimer == nil then
        campTimer = 600 -- 20 seconds
      end
      m.invincTimer = 60 -- 2 seconds
    elseif campTimer == nil and obj_get_first_with_behavior_id(id_bhvActSelector) ~= nil then
      campTimer = 300 -- 10 seconds
    end
  end
  if campTimer ~= nil and not (sMario.pause or gGlobalSyncTable.pause) then
    campTimer = campTimer - 1
    if campTimer % 30 == 0 then
      play_sound(SOUND_MENU_CAMERA_BUZZ, m.marioObj.header.gfx.cameraToObject)
    end
    if campTimer <= 0 then
      campTimer = nil
      if sMario.team == 1 then
        sMario.runnerLives = 0
        died = false
        on_death(m,true)
      else
        warp_beginning()
      end
      return
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
  if gGlobalSyncTable.mhMode == 0 then
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
  if gGlobalSyncTable.mhMode == 0 then
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
  -- render to N64 screen space, with the HUD font
  djui_hud_set_resolution(RESOLUTION_N64)
  djui_hud_set_font(FONT_NORMAL)

  local text = ""
  local sMario = gPlayerSyncTable[0]
  -- yay long if statement
  if gGlobalSyncTable.mhState == 0 then
    text = unstarted_hud(sMario)
  elseif campTimer ~= nil then -- camp timer has top priority
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
  local width = djui_hud_measure_text(remove_color(text)) * scale

  local x = (screenWidth - width) / 2.0
  local y = 0

  djui_hud_set_color(0, 0, 0, 128);
  djui_hud_render_rect(x - 6, y, width + 12, 16);

  djui_hud_set_color(255, 255, 255, 255);
  local more = false
  local space = 0
  local color = ""
  text,color,render = remove_color(text,true)
  local LIMIT = 0
  while render ~= nil do
    local r,g,b = convert_color(color)
    djui_hud_print_text(render, x+space, y, scale);
    djui_hud_set_color(r, g, b, 255);
    space = space + djui_hud_measure_text(render) * scale
    text,color,render = remove_color(text,true)
  end
  djui_hud_print_text(text, x+space, y, scale);
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
  local default = "\\#00ffff\\" .. trans("runners")..": "
  local text = default
  for i=0,(MAX_PLAYERS-1) do
    if gPlayerSyncTable[i].team == 1 then
      local theirNP = gNetworkPlayers[i]
      local np = gNetworkPlayers[0]
      if theirNP.connected then
        if sMario.spectator == 0 and (theirNP.currLevelNum == np.currLevelNum) and (theirNP.currAreaIndex == np.currAreaIndex) and (theirNP.currActNum == np.currActNum) then
          local rm = gMarioStates[theirNP.localIndex]
          render_radar(rm, icon_radar[i])
        end
        local playerColor = network_get_player_text_color_string(theirNP.localIndex)
        text = text .. playerColor .. theirNP.name .. ", "
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
  local text = trans("win","\\#ff5c5c\\"..trans("hunters"))
  if gGlobalSyncTable.mhState > 3 then
    text = trans("win","\\#00ffff\\"..trans("runners"))
  end
  return text
end

function unstarted_hud(sMario)
  -- display role
  local text = ""
  if sMario.team == 1 then
    text = "\\#00ffff\\" .. trans("runner")
  else
    text = "\\#ff5c5c\\" .. trans("hunter")
  end
  return text
end

function camp_hud(sMario)
  return trans("camp_timer",math.floor(campTimer / 30))
end

-- removes color string
function remove_color(text,get_color)
  local start = text:find("\\")
  local next = 1
  while (next ~= nil) and (start ~= nil) do
    start = text:find("\\")
    if start ~= nil then
      next = text:find("\\",start+1)
      if next == nil then
        next = text:len() + 1
      end

      if get_color then
        local color = text:sub(start,next)
        local render = text:sub(1,start-1)
        text = text:sub(next+1)
        return text,color,render
      else
        text = text:sub(1,start-1) .. text:sub(next+1)
      end
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

-- runs network_send and also the respective function for this user
function network_send_include_self(reliable,data)
  network_send(reliable, data)
  sPacketTable[data.id](data)
end

function change_team_command(msg)
  local playerID,np = get_specified_player(msg)
  if playerID == nil then return true end

  local sMario = gPlayerSyncTable[playerID]
  local name = remove_color(np.name)
  if sMario.team ~= 1 then
    become_runner(sMario)
    djui_chat_message_create(trans("set_team",name,trans("runner")))
  else
    become_hunter(sMario)
    djui_chat_message_create(trans("set_team",name,trans("hunter")))
  end
  return true
end

function set_life_command(msg)
  local dataStart = msg:find(" ")
  local lookingFor = ""
  local lives = msg
  if dataStart ~= nil then
    lookingFor = msg:sub(1,dataStart-1)
    lives = msg:sub(dataStart+1)
  end
  lives = tonumber(lives)
  if lives == nil or lives < 0 or lives > 100 or math.floor(lives) ~= lives then
    return false
  end

  local playerID,np = get_specified_player(lookingFor)
  if playerID == nil then return true end

  local sMario = gPlayerSyncTable[playerID]
  local name = remove_color(np.name)
  if gGlobalSyncTable.mhState == 0 then
    djui_chat_message_create(trans("not_started"))
  elseif sMario.runnerLives ~= nil then
    sMario.runnerLives = lives
    djui_chat_message_create(trans_plural("set_lives",name,lives))
  else
    djui_chat_message_create(trans("not_runner",name))
  end
  return true
end

function allow_leave_command(msg)
  local playerID,np = get_specified_player(msg)
  if playerID == nil then return true end

  local sMario = gPlayerSyncTable[playerID]
  local name = remove_color(np.name)
  sMario.allowLeave = true
  djui_chat_message_create(trans("may_leave",name))
  return true
end

function add_runner_command(msg)
  local runners = tonumber(msg)
  if runners == nil or runners ~= math.floor(runners) or runners < 1 then return false end

  -- get current hunters
  local currHunterIDs = {}
  local goodHunterIDs = {}
  local runners_available = 0
  for i=0,(MAX_PLAYERS-1) do
    local np = gNetworkPlayers[i]
    local sMario = gPlayerSyncTable[i]
    if np.connected and sMario.team ~= 1 then
      if sMario.beenRunner == 0 then
        runners_available = runners_available + 1
        table.insert(goodHunterIDs, np.localIndex)
      end
      table.insert(currHunterIDs, np.localIndex)
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

function randomize_command(msg)
  local runners = tonumber(msg)
  if runners == nil or runners ~= math.floor(runners) or runners < 1 then return false end

  local total_online = 0
  local max_online_id = 0
  local blacklistIDs = {}
  local runnerIDs = {}
  local runners_available = 0
  -- get total online
  for i=0,(MAX_PLAYERS-1) do
    local np = gNetworkPlayers[i]
    if np.connected then
      local sMario = gPlayerSyncTable[i]
      if sMario.beenRunner == 1 then
        blacklistIDs[i] = 1
      else
        runners_available = runners_available + 1
      end
      total_online = total_online + 1
      max_online_id = i
    end
  end
  if runners >= total_online or runners >= MAX_PLAYERS then
    djui_chat_message_create(trans("must_have_one"))
    return true
  end
  if runners > runners_available then -- if everyone has been a runner before, ignore recent status
    print("Not enough recent runners! Ignoring recent status")
    blacklistIDs = {}
  end


  local runnerNames = {}
  local limit = 0
  while runners > 0 and limit < 5000 do
    local playerID = math.random(0, max_online_id)
    if runnerIDs[playerID] == nil and blacklistIDs[playerID] == nil then
      local np = gNetworkPlayers[playerID]
      if np.connected then
        local sMario = gPlayerSyncTable[playerID]
        become_runner(sMario)
        table.insert(runnerNames, remove_color(np.name))
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
    if runnerIDs[i] == nil then
      become_hunter(sMario)
    end
  end
  local text = trans("runners_are")
  for i=1,#runnerNames do
    text = text .. runnerNames[i] .. ", "
  end
  text = text:sub(1,-3)
  djui_chat_message_create(text)
  return true
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

function runner_lives_command(msg)
  local num = tonumber(msg)
  if num ~= nil and num >= 0 and num <= 99 and math.floor(num) == num then
    gGlobalSyncTable.runnerLives = num
    djui_chat_message_create(trans("set_lives_total",num))
    return true
  end
  return false
end

function time_needed_command(msg)
  if gGlobalSyncTable.starMode then
    djui_chat_message_create(trans("wrong_mode"))
    return true
  end
  local num = tonumber(msg)
  if num ~= nil then
    gGlobalSyncTable.runTime = math.floor(num * 30)
    djui_chat_message_create(trans("need_time_feedback"))
    return true
  end
  return false
end

function stars_needed_command(msg)
  if not gGlobalSyncTable.starMode then
    djui_chat_message_create(trans("wrong_mode"))
    return true
  end
  local num = tonumber(msg)
  if num ~= nil and num > 0 and num < 8 then
    gGlobalSyncTable.runTime = num
    djui_chat_message_create(trans("need_stars_feedback"))
    return true
  end
  return false
end

function star_count_command(msg)
  local num = tonumber(msg)
  if num ~= nil and num >= -1 and num <= ROMHACK.max_stars and math.floor(num) == num then
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

function mode_command(msg)
  if string.lower(msg) == "normal" then
    gGlobalSyncTable.mhMode = 0
    djui_chat_message_create(trans("mode_normal"))
    return true
  elseif string.lower(msg) == "switch" then
    gGlobalSyncTable.mhMode = 1
    djui_chat_message_create(trans("mode_switch"))
    return true
  end
  return false
end

function star_mode_command(msg)
  if string.lower(msg) == "on" then
    gGlobalSyncTable.starMode = true
    gGlobalSyncTable.runTime = 2
    djui_chat_message_create(trans("using_stars"))
    return true
  elseif string.lower(msg) == "off" then
    gGlobalSyncTable.starMode = false
    gGlobalSyncTable.runTime = 7200
    djui_chat_message_create(trans("using_timer"))
    return true
  end
  return false
end

function allow_spectate_command(msg)
  if string.lower(msg) == "on" then
    gGlobalSyncTable.allowSpectate = true
    djui_chat_message_create(trans("can_spectate"))
    return true
  elseif string.lower(msg) == "off" then
    gGlobalSyncTable.allowSpectate = false
    djui_chat_message_create(trans("no_spectate"))
    return true
  end
  return false
end

-- TroopaParaKoopa's pause mod
function pause_command(msg)
  if msg == "all" then
    if gGlobalSyncTable.pause then
      gGlobalSyncTable.pause = false
      djui_chat_message_create(trans("all_unpaused"))
    else
      gGlobalSyncTable.pause = true
      djui_chat_message_create(trans("all_paused"))
    end
    return true
  end

  local playerID,np = get_specified_player(msg)
  if playerID == nil then return true end

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

-- TroopaParaKoopa's metal command
function metal_command(msg)
  if string.lower(msg) == "on" then
      gGlobalSyncTable.metal = true
      djui_chat_message_create(trans("now_metal"))
      return true
  end
  if string.lower(msg) == "off" then
      gGlobalSyncTable.metal = false
      djui_chat_message_create(trans("not_metal"))
      return true
  end
end

function weak_command(msg)
  if string.lower(msg) == "on" then
      gGlobalSyncTable.weak = true
      djui_chat_message_create(trans("now_weak"))
      return true
  end
  if string.lower(msg) == "off" then
      gGlobalSyncTable.weak = false
      djui_chat_message_create(trans("not_weak"))
      return true
  end
end

-- TroopaParaKoopa's Level Cooldown
hook_event(HOOK_ON_WARP,
   function()
       gMarioStates[0].invincTimer = 100
   end
)

-- based off of example
function mario_update(m)
  -- run death if health is 0, or reset death status
  local sMario = gPlayerSyncTable[m.playerIndex]
  if m.health <= 0xFF then
    on_death(m)
  elseif m.playerIndex == 0 then
    if died and m.invincTimer < 100 then m.invincTimer = 100 end -- start invincibility
    died = false
    -- match life counter to actual lives
    if sMario.team == 1 and m.numLives ~= sMario.runnerLives then
      m.numLives = sMario.runnerLives
    end
  end

  -- cut invincibility frames
  if gGlobalSyncTable.weak and m.invincTimer > 0 then
    m.invincTimer = m.invincTimer - 1
  end

  -- handle rejoining
  local np = gNetworkPlayers[m.playerIndex]
  if rejoin_timer ~= nil and m.playerIndex ~= 0 and np.connected then
    local discordID = sMario.discordID
    if discordID ~= nil and rejoin_timer[discordID] ~= nil then
      -- become runner again
      local data = rejoin_timer[discordID]
      become_runner(sMario)
      sMario.pause = false
      sMario.runnerLives = data.lives
      djui_popup_create(trans("rejoin_success",data.name), 2)
      rejoin_timer[discordID] = nil
    end
  end

  -- display as paused
  if sMario.pause then
    m.marioBodyState.modelState = MODEL_STATE_NOISE_ALPHA
    m.invincTimer = 60
  end

  if ROMHACK.special_run ~= nil then
    ROMHACK.special_run(m)
  end

  -- set descriptions
  if sMario.team == 1 then
    if desc_switch_timer > 30 then
      network_player_set_description(np, trans("runner"), 0, 255, 255, 255)
    else
      -- fix stupid desync bug
      if sMario.runnerLives == nil then sMario.runnerLives = gGlobalSyncTable.runnerLives end
      network_player_set_description(np, trans_plural("show_lives",sMario.runnerLives), 0, 255, 255, 255)
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

  -- keep player in beginning if game is not started
  if didFirstJoinStuff and ROMHACK ~= nil and m.playerIndex == 0 and gGlobalSyncTable.mhState == 0 and np.currLevelNum ~= ROMHACK.start_level then
    warp_beginning()
  end

  -- if the game is inactive, disable the camp timer
  if gGlobalSyncTable.mhState ~= nil and (gGlobalSyncTable.mhState == 0 or gGlobalSyncTable.mhState >= 3) then campTimer = nil return end

  -- for all players: disable endless stairs if there's enough stars
  local surface = m.floor
  if gGlobalSyncTable.starRun ~= -1 and surface ~= nil and surface.type == 27 and m.numStars >= gGlobalSyncTable.starRun then
    surface.type = 0
    m.floor = surface
  end

  -- enforce star requirements
  if m.playerIndex == 0 and gGlobalSyncTable.starRun ~= -1 and ROMHACK.requirements ~= nil then
    local requirements = ROMHACK.requirements[np.currLevelNum] or 0
    if requirements >= gGlobalSyncTable.starRun then
      requirements = gGlobalSyncTable.starRun
      if ROMHACK.ddd and (np.currLevelNum == LEVEL_BITDW or np.currLevelNum == LEVEL_DDD) then
        requirements = requirements - 1
      end
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
  local np = gNetworkPlayers[m.playerIndex]
  -- unassign attack
  if np.globalIndex == attackedBy then attackedBy = nil end

  -- for host only
  if network_is_server() then -- rejoin handling
    local sMario = gPlayerSyncTable[m.playerIndex]
    if sMario.team == 1 then
      local discordID = sMario.discordID
      print(tostring(discordID),"left")
      become_hunter(sMario) -- be hunter by default
      sMario.discordID = nil
      if discordID ~= nil and discordID ~= "0" then
        local playerColor = network_get_player_text_color_string(np.localIndex)
        local name = playerColor .. np.name
        rejoin_timer[discordID] = {name = name, timer = 3600, lives = sMario.runnerLives } -- 2 minutes
        djui_popup_create(trans("rejoin_start",name), 2)
      elseif gGlobalSyncTable.mhMode == 1 then
        local newID = new_runner(true)
        if newID ~= nil then
          network_send_include_self(true, {
              id = PACKET_KILL,
              newRunnerID = newID,
              time = sMario.runTime or 0,
          })
        end
      end
    end
  end
end



function runner_update(m,sMario)
  -- fix stupid desync bug
  if sMario.runnerLives == nil then sMario.runnerLives = gGlobalSyncTable.runnerLives end
  local np = gNetworkPlayers[m.playerIndex]

  -- detect victory
  if m.playerIndex == 0 and gGlobalSyncTable.mhState < 3 and ROMHACK ~= nil and ROMHACK.runner_victory ~= nil and ROMHACK.runner_victory(m) and gGlobalSyncTable.mhState < 3 then
    network_send_include_self(true, {
      id = PACKET_GAME_END,
      winner = 1,
    })
    gGlobalSyncTable.mhState = 4
    gGlobalSyncTable.mhTimer = 20 * 30 -- 20 seconds
  end

  if m.playerIndex == 0 then
    -- set 'been runner' status
    if sMario.beenRunner == 0 then
      print("Our 'Been Runner' status has been set")
      sMario.beenRunner = 1
      mod_storage_save("beenRunnner", "1")
    end

    -- set and decrement regain cap timer
    if m.capTimer > 0 then
      cooldownCaps = m.flags
      regainCapTimer = 60
    elseif regainCapTimer > 0 then
      regainCapTimer = regainCapTimer - 1
    end

    -- reduce level timer
    if not sMario.allowLeave then
      if not gGlobalSyncTable.starMode then
        sMario.runTime = sMario.runTime + 1
      end

      -- match run time with other runners in level
      for i=1,(MAX_PLAYERS-1) do
        if gPlayerSyncTable[i].team == 1 and gNetworkPlayers[i].connected then
          local theirNP = gNetworkPlayers[i] -- daft variable naming conventions
          local theirSMario = gPlayerSyncTable[i]
          if (np.currLevelNum == theirNP.currLevelNum) and (np.currActNum == theirNP.currActNum) and sMario.runTime < theirSMario.runTime then
            sMario.runTime = theirSMario.runTime
          end
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
    [ACT_READING_SIGN] = 20,
    [ACT_HEAVY_THROW] = 10,
    [ACT_PUTTING_ON_CAP] = 10,
    [ACT_STAR_DANCE_NO_EXIT] = 30, -- 1 second
    [ACT_WAITING_FOR_DIALOG] = 10,
    [ACT_DEATH_EXIT_LAND] = 10,
    [ACT_SPAWN_SPIN_LANDING] = 100,
    [ACT_SPAWN_NO_SPIN_LANDING] = 100,
    [ACT_IN_CANNON] = 10,
  }
  local runner_camping = {
    [ACT_READING_NPC_DIALOG] = 1,
    [ACT_READING_AUTOMATIC_DIALOG] = 1,
    [ACT_WAITING_FOR_DIALOG] = 1,
    [ACT_READING_SIGN] = 1,
    [ACT_STAR_DANCE_NO_EXIT] = 1,
    [ACT_IN_CANNON] = 1,
  }

  local newInvincTimer = runner_invincible[m.action]
  if newInvincTimer ~= nil and gGlobalSyncTable.weak then newInvincTimer = newInvincTimer * 2 end -- same amount in weak mode
  if newInvincTimer ~= nil and m.invincTimer < newInvincTimer then
    m.invincTimer = newInvincTimer
    if m.playerIndex == 0 and campTimer == nil and runner_camping[m.action] ~= nil then
      campTimer = 600 -- 20 seconds
    end
  end
  if m.playerIndex == 0 and runner_camping[m.action] == nil and obj_get_first_with_behavior_id(id_bhvActSelector) == nil and (m.freeze == false or (m.freeze ~= true and m.freeze < 1)) then
    campTimer = nil
  end

  -- reduces water heal and boosts invincibility frames after getting hit in water
  if (m.action & ACT_FLAG_SWIMMING) ~= 0 then
    if m.prevAction == ACT_FORWARD_WATER_KB or m.prevAction == ACT_BACKWARD_WATER_KB then
      m.invincTimer = 60 -- 2 seconds
      m.prevAction = m.action
    end
    if m.pos.y >= m.waterLevel - 140 and (m.area.terrainType & TERRAIN_MASK) ~= TERRAIN_SNOW then
      -- water heal is 26 (decimal) per frame
      m.health = m.health - 22
    end
  end

  -- add stars
  if m.prevNumStarsForDialog < m.numStars then
    m.prevNumStarsForDialog = m.numStars -- this also disables some dialogue, which helps with the fast pace
    if m.playerIndex == 0 and gotStar ~= nil then
      if gGlobalSyncTable.starMode then
        sMario.runTime = sMario.runTime + 1 -- 1 star
      else
        sMario.runTime = sMario.runTime + 1800 -- 1 minute
      end
      -- send message
      network_send(false, {
        id = PACKET_RUNNER_STAR,
        runnerID = np.globalIndex,
        star = true,
        name = get_star_name(np.currCourseNum, gotStar),
        place = get_level_name(np.currCourseNum, np.currLevelNum, np.currAreaIndex),
      })
    end
  end
  if m.playerIndex == 0 then
    gotStar = nil
  end
end

function hunter_update(m,sMario)
  -- infinite lives
  m.numLives = 100

  -- hns hunters become metal cap - troopa
  if gGlobalSyncTable.metal == true then
    m.marioBodyState.modelState = MODEL_STATE_METAL
  end

  -- only local mario at this point
  if m.playerIndex ~= 0 then return end

  -- camp timer for hunters!?
  if campTimer == nil and m.action == ACT_IN_CANNON then
    campTimer = 600 -- 20 seconds
  elseif m.action ~= ACT_IN_CANNON then
    campTimer = nil
  end

  -- check for runners
  local stillrunners = false
  for i=0,(MAX_PLAYERS-1) do
    if gPlayerSyncTable[i].team == 1 and gNetworkPlayers[i].connected then
      stillrunners = true
      break
    end
  end

  -- buff underwater punch
  if m.forwardVel < 25 and m.action == ACT_WATER_PUNCH then
    m.forwardVel = 25
  end

  -- detect victory for hunters (only host to avoid disconnect bugs)
  if network_is_server() then
    if stillrunners == false and gGlobalSyncTable.mhState < 3 and gGlobalSyncTable.mhMode == 0 then
      for id,data in pairs(rejoin_timer) do
        if data.timer > 0 then
          stillrunners = true
          break
        end
      end
      if stillrunners == false and gGlobalSyncTable.mhState < 3 then
        network_send_include_self(true, {
          id = PACKET_GAME_END,
          winner = 0,
        })
        gGlobalSyncTable.mhState = 3
        gGlobalSyncTable.mhTimer = 20 * 30 -- 20 seconds
      end
    end
  end
end

function on_allow_interact(m, o, type)
    local sMario = gPlayerSyncTable[m.playerIndex]
    -- disable for spectators
    if sMario.spectator == 1 then return false end

    -- disable stars and warps during game start or end
    if (type == INTERACT_WARP or type == INTERACT_STAR_OR_KEY or type == INTERACT_WARP_DOOR)
    and gGlobalSyncTable.mhState ~= nil and (gGlobalSyncTable.mhState == 0 or gGlobalSyncTable.mhState >= 3) then
      return false
    end

    -- prevent hunters from interacting with certain things that help or softlock the runner
    local banned_hunter = {
      [id_bhvRedCoin] = 1, -- no!! you cant get the red coins you're helping the runner!!!!!! - troopa
      [id_bhvKingBobomb] = 1,
    }

    local obj_id = get_id_from_behavior(o.behavior)
    --print(get_behavior_name_from_id(obj_id))
    -- cap timer
    if type == INTERACT_CAP and regainCapTimer > 0 then
      if obj_id == id_bhvMetalCap and (cooldownCaps & MARIO_METAL_CAP) ~= 0 then return false end
      if obj_id == id_bhvVanishCap and (cooldownCaps & MARIO_VANISH_CAP) ~= 0 then return false end
    elseif obj_id == id_bhv1Up then
      m.healCounter = 0x880
      return true
    elseif type == INTERACT_STAR_OR_KEY or banned_hunter[obj_id] ~= nil then
      if sMario.team ~= 1 then
        return false
      else
        if type == INTERACT_STAR_OR_KEY and gGlobalSyncTable.omm and gServerSettings.stayInLevelAfterStar == 1 then
          m.invincTimer = 240 -- this is actually 4 seconds since weak is usually on
        end
        if m.playerIndex ~= 0 then
          return true -- ignore if not local player
        elseif obj_id == id_bhvBowserKey then -- is a key
          sMario.allowLeave = true
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
          network_send_include_self(false, {
            id = PACKET_RUNNER_STAR,
            runnerID = np.globalIndex,
            star = false,
            place = get_level_name(np.currCourseNum, np.currLevelNum, np.currAreaIndex),
          })
        elseif obj_id ~= id_bhvGrandStar then -- this isn't a star, really
          gotStar = (o.oBehParams >> 24) + 1 -- set what star we got
        end
      end
      return true
    end
end
-- disable red coin heal
function on_interact(m, o, type, value)
  local obj_id = get_id_from_behavior(o.behavior)
  if obj_id == id_bhvRedCoin then
    m.healCounter = 0
  end
  return true
end

function on_object_unload(o)
  if obj_has_behavior_id(o, id_bhvBowserBomb) == 1 then
    local bomb = obj_get_first_with_behavior_id(id_bhvBowserBomb)
    if bomb == nil then
      spawn_sync_object(
      id_bhvBowserBomb,
      E_MODEL_BOWSER_BOMB,
      o.oPosX, o.oPosY, o.oPosZ,
      nil)
    end
  end
end

paused = false
function do_pause()
  local m = gMarioStates[0]
  local sMario = gPlayerSyncTable[m.playerIndex]
  -- only during timer or pause
  if sMario.pause or gGlobalSyncTable.pause
  or (gGlobalSyncTable.mhState == 1
  and (sMario.team ~= 1 or gGlobalSyncTable.mhTimer > 10 * 30)) then -- runners get 10 second head start
    if not paused then
      djui_popup_create(trans("paused"),2)
      paused = true
    end

    enable_time_stop_including_mario()
    if gGlobalSyncTable.mhTimer > 0 then
      m.health = 0x880
    end
  elseif paused then
    djui_popup_create(trans("unpaused"),2)
    m.invincTimer = 60 -- 1 second
    paused = false
    disable_time_stop_including_mario()
    print("disabled pause")
  end
end

function rom_hack_command(msg)
  gGlobalSyncTable.romhackName = msg
  return true
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
  network_send(false, {
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

-- stats
function stats_command(msg)
  for i=0,(MAX_PLAYERS-1) do
    local np = gNetworkPlayers[i]
    if i == 0 or np.connected then
      local sMario = gPlayerSyncTable[i]
      local playerColor = network_get_player_text_color_string(np.localIndex)
      local text = playerColor .. np.name .. "\\#ffffff\\: "
      text = text .. trans("stat_wins") .. " " .. (sMario.wins or 0) .. " "
      text = text .. trans("stat_kills") .. " " .. (sMario.kills or 0) .. " "
      text = text .. trans("stat_combo") .. " " .. (sMario.maxStreak or 0)
      djui_chat_message_create(text)
    end
  end
  return true
end
hook_chat_command("stats", " - Get player stats", stats_command)

function on_course_enter()
  local sMario = gPlayerSyncTable[0]
  attackedBy = nil
  if sMario.team == 1 then
    sMario.runTime = 0
    sMario.allowLeave = false
  end
  justEntered = true
  if gGlobalSyncTable.mhState == 0 then
   set_background_music(0,0,0)
   play_music(0, 0x41, 1)
  end
end

function on_packet_runner_star(data)
  runnerID = data.runnerID
  if runnerID ~= nil then
    local np = network_player_from_global_index(runnerID)
    local playerColor = network_get_player_text_color_string(np.localIndex)
    if data.star == true then
      if not (gGlobalSyncTable.omm and gServerSettings.stayInLevelAfterStar == 1) then -- OMM shows its own progress, so don't show this
        djui_popup_create(trans("got_star",(playerColor .. np.name)) .. "\\#ffffff\\\n" .. data.place .. "\n" .. data.name, 2)
      end
    elseif np.currLevelNum ~= LEVEL_BOWSER_3 then
      djui_popup_create(trans("got_key",(playerColor .. np.name)) .. "\\#ffffff\\\n" .. data.place, 2)
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

    if killer ~= nil then -- died from kill (most common)
      local killerNP = network_player_from_global_index(killer)
      local kPlayerColor = network_get_player_text_color_string(killerNP.localIndex)

      if killerNP.localIndex == 0 then -- is our kill
        m.healCounter = 0x781 -- full health minus death amount
        play_sound(SOUND_GENERAL_STAR_APPEARS, m.marioObj.header.gfx.cameraToObject)
        -- save kill, but only in-game
        local kSMario = gPlayerSyncTable[0]
        if gGlobalSyncTable.mhState ~= 0 then
          local kills = tonumber(mod_storage_load("kills"))
          if kills == nil then
            kills = 0
          end
          mod_storage_save("kills",tostring(math.floor(kills)+1))
          kSMario.kills = kSMario.kills + 1
        end
        -- kill combo
        killCombo = killCombo + 1
        killTimer = 300 -- 10 seconds
      elseif data.runner then -- play sound if runner dies
        play_sound(SOUND_OBJ_BOWSER_LAUGH, m.marioObj.header.gfx.cameraToObject)
      end

      -- sidelined if this was their last life
      if data.death ~= true then
        djui_popup_create(trans("killed",(kPlayerColor .. killerNP.name),(playerColor .. np.name)), 2)
      else
        djui_popup_create(trans("sidelined",(kPlayerColor .. killerNP.name),(playerColor .. np.name)), 2)
      end
    else
      if data.death ~= true then -- runner only lost one life
        djui_popup_create(trans("lost_life",(playerColor .. np.name)), 2)
      else -- runner lost all lives
        djui_popup_create(trans("lost_all",(playerColor .. np.name)), 2)
      end
      if data.runner then -- play sound if runner dies
        play_sound(SOUND_OBJ_BOWSER_LAUGH, m.marioObj.header.gfx.cameraToObject)
      end
    end
  end

  -- new runner for switch mode
  if newRunnerID ~= nil then
    local np = network_player_from_global_index(newRunnerID)
    local playerColor = network_get_player_text_color_string(np.localIndex)
    local sMario = gPlayerSyncTable[np.localIndex]
    become_runner(sMario)
    sMario.runTime = data.time or 0
    djui_popup_create(trans("now_runner",(playerColor .. np.name)), 2)
    if np.localIndex == 0 then
      play_sound(SOUND_GENERAL_SHORT_STAR, m.marioObj.header.gfx.cameraToObject)
      print("new time:",data.time)
    end
  end
end

function on_game_end(data)
  if data.winner == 1 then
    play_race_fanfare()
    local sMario = gPlayerSyncTable[0]
    if sMario.team == 1 then
      local wins = tonumber(mod_storage_load("wins"))
      if wins == nil then
        wins = 0
      end
      mod_storage_save("wins",tostring(math.floor(wins)+1))
      sMario.wins = sMario.wins + 1
    end
  else
    play_secondary_music(SEQ_EVENT_KOOPA_MESSAGE, 0, 100, 60)
  end
end

function on_packet_stats(data)
  djui_chat_message_create(trans_plural(data.stat,data.name,data.value))
end

function on_packet_kill_combo(data)
  if data.kills > 5 then
    local m = gMarioStates[0]
    djui_popup_create(trans("kill_combo_large",data.name,data.kills),2)
    play_sound(SOUND_MARIO_YAHOO_WAHA_YIPPEE, m.marioObj.header.gfx.cameraToObject)
  else
    djui_popup_create(trans("kill_combo_"..tostring(data.kills),data.name),2)
  end
end

-- packets
PACKET_RUNNER_STAR = 0
PACKET_KILL = 1
PACKET_MH_START = 2
PACKET_TC = 3
PACKET_GAME_END = 4
PACKET_STATS = 5
PACKET_KILL_COMBO = 6
sPacketTable = {
    [PACKET_RUNNER_STAR] = on_packet_runner_star,
    [PACKET_KILL] = on_packet_kill,
    [PACKET_MH_START] = do_game_start,
    [PACKET_TC] = on_packet_tc,
    [PACKET_GAME_END] = on_game_end,
    [PACKET_STATS] = on_packet_stats,
    [PACKET_KILL_COMBO] = on_packet_kill_combo,
}

-- from arena
function on_packet_receive(dataTable)
    if sPacketTable[dataTable.id] ~= nil then
        sPacketTable[dataTable.id](dataTable)
    end
end

-- to update rom hack
function on_rom_hack_changed(tag, oldVal, newVal)
    if oldVal ~= nil and oldVal ~= newVal then
      print("Hack set to "..newVal)
      local result = setup_hack_data()
      if result == "vanilla" then
        djui_popup_create(trans("vanilla"),2)
      end
    end
end


-- main command
hook_chat_command("mh", "[COMMAND] - Commands for MarioHunt; type nothing to list; host or moderator only", mario_hunt_command)
function setup_commands()
  -- commands for main command
  marioHuntCommands = {}
  marioHuntAlias = {} -- these can also mean the same command
  marioHuntCommands.start = {start_game_command}
  marioHuntCommands.add = {add_runner_command}
    marioHuntAlias.addrunner = "add"
  marioHuntCommands.random = {randomize_command}
    marioHuntAlias.randomize = "random"
  marioHuntCommands.lives = {runner_lives_command}
    marioHuntAlias.runnerlives = "lives"
  marioHuntCommands.time = {time_needed_command}
    marioHuntAlias.timeneeded = "time"
  marioHuntCommands.stars = {stars_needed_command}
    marioHuntAlias.starsneeded = "stars"
  marioHuntCommands.category = {star_count_command}
    marioHuntAlias.starrun = "category"
  marioHuntCommands.flip = {change_team_command}
    marioHuntAlias.changeteam = "flip"
  marioHuntCommands.setlife = {set_life_command}
  marioHuntCommands.leave = {allow_leave_command}
    marioHuntAlias.allowleave = "leave"
  marioHuntCommands.mode = {mode_command}
  marioHuntCommands.starmode = {star_mode_command}
  marioHuntCommands.spectator = {allow_spectate_command}
  marioHuntCommands.pause = {pause_command}
  marioHuntCommands.metal = {metal_command}
  marioHuntCommands.hack = {rom_hack_command}
  marioHuntCommands.weak = {weak_command}

  -- debug
  marioHuntCommands.print = {print, true}
  marioHuntCommands.warp = {do_warp, true}
  marioHuntCommands.radar = {radar_debug, true}
  marioHuntCommands.quick = {quick_debug, true}
  marioHuntCommands.combo = {combo_debug, true}
  marioHuntCommands.discord = {get_discord_ids,true}
end

-- hooks
hook_event(HOOK_UPDATE, update)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ALLOW_PVP_ATTACK, allow_pvp_attack)
hook_event(HOOK_ON_PLAYER_DISCONNECTED, on_player_disconnected)
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
hook_event(HOOK_ON_PAUSE_EXIT, on_pause_exit)
hook_event(HOOK_ON_LEVEL_INIT, on_course_enter)
hook_event(HOOK_ON_PACKET_RECEIVE, on_packet_receive)
hook_event(HOOK_ON_DEATH, on_death)
hook_event(HOOK_ALLOW_INTERACT, on_allow_interact)
hook_event(HOOK_ON_INTERACT, on_interact)
hook_event(HOOK_ON_OBJECT_UNLOAD, on_object_unload)
hook_on_sync_table_change(gGlobalSyncTable, "romhackName", "change_hack", on_rom_hack_changed)
