-- name: .\\#00ffff\\Mario\\#ff5c5c\\Hun‎\\\\t (v2.0)
-- incompatible: gamemode
-- description: A gamemode based off of Beyond's concept.\n\nHunters stop Runners from clearing the game!\n\nProgramming by EmilyEmmi, TroopaParaKoopa, Blocky, Sunk, and Sprinter05.\n\nSpanish Translation made with help from KanHeaven and SonicDark.\nGerman Translation made by N64 Mario.\nBrazillian Portuguese translation made by PietroM.\nFrench translation made by Skeltan.\n\n\"Shooting Star Summit\" port by pieordie1

-- this reduces lag apparently
local djui_chat_message_create,djui_popup_create,djui_hud_measure_text,djui_hud_print_text,djui_hud_set_color,djui_hud_set_font,djui_hud_set_resolution,network_get_player_text_color_string,network_player_set_description,network_get_player_text_color_string,network_is_server,is_game_paused,djui_hud_render_texture,get_current_save_file_num,save_file_get_course_star_count,save_file_get_star_flags,save_file_get_flags,djui_hud_render_rect = djui_chat_message_create,djui_popup_create,djui_hud_measure_text,djui_hud_print_text,djui_hud_set_color,djui_hud_set_font,djui_hud_set_resolution,network_get_player_text_color_string,network_player_set_description,network_get_player_text_color_string,network_is_server,is_game_paused,djui_hud_render_texture,get_current_save_file_num,save_file_get_course_star_count,save_file_get_star_flags,save_file_get_flags,djui_hud_render_rect

-- some debug stuff
function do_warp(msg)
  warpCount = 0
  warpCooldown = 0
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
  local first = true
  while lastspace ~= nil do
    lastspace = msg:find(" ")
    if lastspace ~= nil then
      local arg = msg:sub(1,lastspace-1)
      if tonumber(arg) == nil and first then
        local courseNum = "no"
        if string.sub(arg,1,1) == "c" then
          courseNum = string.sub(arg,2)
        end
        if tonumber(courseNum) ~= nil then
          arg = course_to_level[tonumber(courseNum) or 0] or 16
        else
          arg = string_to_level[arg] or 16
        end
      end
      first = false
      table.insert(args, tonumber(arg))
      msg = msg:sub(lastspace+1)
    else
      local arg = msg
      if tonumber(arg) == nil and first then
        local courseNum = "no"
        if string.sub(arg,1,1) == "c" then
          courseNum = string.sub(arg,2)
        end
        if tonumber(courseNum) ~= nil then
          arg = course_to_level[tonumber(courseNum) or 0] or 16
        else
          arg = string_to_level[arg] or 16
        end
      end
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

function quick_debug(msg)
  local sMario = gPlayerSyncTable[0]
  become_runner(sMario)
  start_game_command("continue")
  if msg == "hunter" then
    gGlobalSyncTable.mhMode = 1
    become_hunter(sMario)
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

function get_field(msg)
  for i=0,(MAX_PLAYERS-1) do
    local sMario = gPlayerSyncTable[i]
    local np = gNetworkPlayers[i]
    if np.connected then
      print(np.name..": ",(sMario[msg] or "NIL"))
      djui_chat_message_create(np.name..": "..(sMario[msg] or "NIL"))
    end
  end
  return true
end

function get_all_stars(msg)
  local valid_star_table = generate_star_table(tonumber(msg),(msg ~= "mini"),(msg=="replica"))
  print("")
  for i,star in ipairs(valid_star_table) do
    local act = star % 10
    local course = math.floor(star / 10)
    local starString = string.format("%s - %s (%d) (ID: %d)",get_level_name(course, course_to_level[course], 1),get_custom_star_name(course,act),act,star)
    djui_chat_message_create(starString)
    print(string.format("%-31s%-31s%-5s%-5s",get_level_name(course, course_to_level[course], 1),get_custom_star_name(course,act),act,star))
  end
  djui_chat_message_create(#valid_star_table.." stars total")
  print("")
  print(#valid_star_table,"stars total")
  return true
end

-- TroopaParaKoopa's pause mod
gGlobalSyncTable.pause = false

-- TroopaParaKoopa's hns metal cap option
gGlobalSyncTable.metal = false

if network_is_server() then
  -- all settings here
  gGlobalSyncTable.runnerLives = 1 -- the lives runners get (0 is a life)
  gGlobalSyncTable.runTime = 7200 -- time runners must stay in stage to leave (default: 4 minutes)
  gGlobalSyncTable.starRun = 70 -- stars runners must get to face bowser; star doors and infinite stairs will be disabled accordingly
  gGlobalSyncTable.allowSpectate = true -- hunters can spectate
  gGlobalSyncTable.starMode = false -- use stars collected instead of timer
  gGlobalSyncTable.weak = false -- cut invincibility frames in half
  gGlobalSyncTable.mhMode = 0 -- game modes, as follows:
  --[[
    0: Normal
    1: Switch
    2: Mini
  ]]

  -- now for other data
  gGlobalSyncTable.mhState = 0 -- game state
  --[[
    0: not started
    1: timer
    2: game started
    3: game ended (hunters win)
    4: game ended (runners win)
    5: game ended (minihunt)
  ]]
  gGlobalSyncTable.mhTimer = -1 -- timer in frames (game is 30 FPS)
  gGlobalSyncTable.speedrunTimer = -1 -- the total amount of time we've played in frames
  gGlobalSyncTable.gameLevel = 0 -- level for MiniHunt
  gGlobalSyncTable.getStar = 0 -- what star must be collected (for MiniHunt)
  gGlobalSyncTable.votes = 0 -- amount of votes for skipping (MiniHunt)
  gGlobalSyncTable.otherSave = false -- using other save file
  gGlobalSyncTable.bowserBeaten = false -- used for some rom hacks as a two-part completion process
  gGlobalSyncTable.ee = false -- used for SM74
  gGlobalSyncTable.forceSpectate = false -- force all players to spectate unless otherwise stated

  rejoin_timer = {} -- rejoin timer for runners
end

smlua_audio_utils_replace_sequence(0x41, 0x25, 65, "Shooting_Star_Summit") -- for lobby; hopefully there's no conflicts

-- force pvp, knockback, skip intro, and no bubble death
gServerSettings.playerInteractions = PLAYER_INTERACTIONS_PVP
gServerSettings.bubbleDeath = 0
gServerSettings.skipIntro = 1
gServerSettings.playerKnockbackStrength = 20
-- level settings for better experience
gLevelValues.visibleSecrets = 1
gLevelValues.previewBlueCoins = 1
gLevelValues.respawnBlueCoinsSwitch = 1
gLevelValues.extendedPauseDisplay = 1
gLevelValues.hudCapTimer = 1
gLevelValues.mushroom1UpHeal = 1
gLevelValues.showStarNumber = 1

local gotStar = nil -- what star we just got
local died = false -- if we've died (because on_death runs every frame of death fsr)
local didFirstJoinStuff = false -- if all of the initial code was run (rules message, etc.)
local frameCounter = 120 -- frame counter over 4 seconds
local cooldownCaps = 0 -- stores m.flags, to see what caps are on cooldown
local regainCapTimer = 0 -- timer for being able to recollect a cap
local campTimer -- for camping actions (such as reading text or being in the star menu), nil means it is inactive
warpCooldown = 0 -- to avoid warp spam
warpCount = 0
local killTimer = 0 -- timer for kills in quick succession
local killCombo = 0 -- kills in quick succession
local hitTimer = 0 -- timer for being hit by another player
local gameAuto = 0 -- automatically start new games of MiniHunt
local localRunTime = 0 -- our run time is usually made local for less lag
local neededRunTime = 0 -- how long we need to wait to leave this course
local localMHTimer = -1 -- the game timer on the local end (only update for others every second)
local localSpeedrunTimer = 0 -- total run time on the local end (only update for others every second)
local inHard = false -- if we started the game in hard mode (to prevent cheesy hard mode wins)
local OmmEnabled = false -- is true if using OMM Rebirth
local prevCoins = 0 -- highest coin count (OMM Rebirth)

-- stat table stuff
local showingStats = false -- showing the stats table
local statDesc = 1 -- which stat we're looking at the description for
local sortBy = 0 -- what we're sorting by. 0 is none, and negative is descending
local holdTimeRight = 0 -- time holding right
local holdTimeLeft = 0 -- time holding left

-- main command
function mario_hunt_command(msg)
  local np = gNetworkPlayers[0]
  local sMario = gPlayerSyncTable[0]
  if not (network_is_server() or network_is_moderator() or sMario.placement == 0) then
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
  if usedCmd == "" or usedCmd == "help" or tonumber(usedCmd) ~= nil then
    local cmdPerPage = 3

    local page = tonumber(usedCmd) or tonumber(data) or 1
    page = math.floor(page)
    local maxPage = math.ceil(#marioHuntCommands / cmdPerPage)
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
          if sMario.placement ~= 0 then
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
    if cmd ~= nil then
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

  if gGlobalSyncTable.mhMode == 2 then
    gGlobalSyncTable.mhState = 2

    if tonumber(msg) ~= nil and tonumber(msg) > 0 and (tonumber(msg) % 1 == 0) then
      gGlobalSyncTable.campaignCourse = tonumber(msg)
      random_star(nil,tonumber(msg))
    else
      gGlobalSyncTable.campaignCourse = 0
      random_star()
    end

    if string.lower(msg) ~= "continue" then
      localMHTimer = gGlobalSyncTable.runTime or 0
    end
  elseif string.lower(msg) ~= "continue" then
    gGlobalSyncTable.mhState = 1
    localMHTimer = 15 * 30 -- 15 seconds
  else
    gGlobalSyncTable.mhState = 2
    localMHTimer = -1
  end
  gGlobalSyncTable.mhTimer = localMHTimer

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
  save_settings()
  local msg = data.cmd or ""
  showingStats = false
  omm_disable_non_stop_mode(gGlobalSyncTable.mhMode == 2)
  localMHTimer = gGlobalSyncTable.mhTimer or 0
  if string.lower(msg) ~= "continue" then
    local m = gMarioStates[0]
    m.health = 0x880
    SVcln = nil

    gGlobalSyncTable.votes = 0
    iVoted = false
    localSpeedrunTimer = 0
    gGlobalSyncTable.speedrunTimer = 0

    local sMario = gPlayerSyncTable[0]
    sMario.totalStars = 0
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
    inHard = sMario.hard or false
    killTimer = 0
    killCombo = 0
    campTimer = nil
    warpCount = 0
    warpCooldown = 0

    warp_beginning()

    local wasOtherSave = gGlobalSyncTable.otherSave
    if (string.lower(msg) == "main") then
      gGlobalSyncTable.otherSave = false
    elseif (string.lower(msg) == "alt") or (string.lower(msg) == "reset") then
      gGlobalSyncTable.otherSave = true
    end
    gGlobalSyncTable.bowserBeaten = false
    save_file_set_using_backup_slot(gGlobalSyncTable.otherSave)
    if (string.lower(msg) == "reset") then -- buggy
      print("did reset")
      save_file_erase_current_backup_save()
      save_file_reload(1)
    elseif wasOtherSave ~= gGlobalSyncTable.otherSave then
      save_file_reload(1)
    end
  end
end

-- code from arena
function allow_pvp_attack(attacker, victim)
    -- false if timer going or game end
    if gGlobalSyncTable.mhState == 1 then return false end
    if gGlobalSyncTable.mhState >= 3 then return false end

    local npAttacker = gNetworkPlayers[attacker.playerIndex]

    -- check teams
    return global_index_hurts_mario_state(npAttacker.globalIndex, victim)
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

    -- runners can attack each other in MiniHunt
    if (gGlobalSyncTable.mhMode == 2 and attackTeam == 1) then return true end

    return attackTeam ~= victimTeam
end

function on_pvp_attack(attacker,victim,nonPhysical)
  local sVictim = gPlayerSyncTable[victim.playerIndex]
  local npAttacker = gNetworkPlayers[attacker.playerIndex]
  if sVictim.team == 1 then
    if (victim.flags & MARIO_METAL_CAP) ~= 0 then
      victim.health = victim.health - 0x100 -- one unit
      if victim.health < 0xFF then victim.health = 0xFF end
    end
    if gGlobalSyncTable.mhMode == 2 then
      victim.hurtCounter = victim.hurtCounter + 0x8 -- 2 extra hitpoints
    end
  end
  if victim.playerIndex == 0 then
    attackedBy = npAttacker.globalIndex
    hitTimer = 300 -- 10 seconds
  end
end

-- omm support
function omm_allow_attack(index,setting) -- this only works when deleting omm-gamemode.lua
  if setting == 3 and index ~= 0 then
    return allow_pvp_attack(gMarioStates[index], gMarioStates[0], true)
  end
  return true
end
function omm_attack(index,setting)
  if setting == 3 and index ~= 0 then
    on_pvp_attack(gMarioStates[index], gMarioStates[0], true)
  end
end

function get_leave_requirements(sMario)
  -- for leave command
  if sMario.allowLeave then
    return 0
  end

  -- in castle
  local np = gNetworkPlayers[0]
  if np.currCourseNum == 0 or (ROMHACK ~= nil and ROMHACK.hubStages ~= nil and ROMHACK.hubStages[np.currCourseNum] ~= nil) then
    return 0,trans("in_castle")
  end

  -- allow leaving bowser stages if done
  if np.currCourseNum == COURSE_BITDW and ((save_file_get_flags() & SAVE_FLAG_HAVE_KEY_1) ~= 0 or (save_file_get_flags() & SAVE_FLAG_UNLOCKED_BASEMENT_DOOR) ~= 0) then
    return 0
  elseif np.currCourseNum == COURSE_BITFS and ((save_file_get_flags() & SAVE_FLAG_HAVE_KEY_2) ~= 0 or (save_file_get_flags() & SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR) ~= 0) then
    return 0
  end

  -- can't leave some stages in star mode
  if neededRunTime == -1 then
    return 1,trans("cant_leave")
  end

  return (neededRunTime - localRunTime)
end

-- only do this sometimes to reduce lag
function calculate_leave_requirements(sMario,runTime)
  local np = gNetworkPlayers[0]
  local available_stars = 7

  -- less time for secret courses
  local total_time = gGlobalSyncTable.runTime
  if ROMHACK.starCount ~= nil and ROMHACK.starCount[np.currLevelNum] ~= nil then
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
  if ROMHACK.replica_start ~= nil and m.numStars >= ROMHACK.replica_start and np.currCourseNum > 15 and np.currCourseNum ~= 25 then
    available_stars = available_stars + 1
  end

  -- if there aren't any in this stage, treat as a 1 star stage
  if available_stars <= 0 then
    available_stars = 1
    if gGlobalSyncTable.starMode then return -1,0 end -- impossible to leave in star mode
  end

  -- subtract obtained stars (excluding inside bowser areas)
  if np.currLevelNum ~= LEVEL_BOWSER_1 and np.currLevelNum ~= LEVEL_BOWSER_2 and np.currLevelNum ~= LEVEL_BOWSER_3 then
    local file = get_current_save_file_num() - 1
    local starCount = save_file_get_course_star_count(file, np.currCourseNum - 1)
    available_stars = available_stars - starCount
  elseif gGlobalSyncTable.starMode then
    return -1,0 -- impossible to leave in star mode
  end

  if gGlobalSyncTable.starMode then
    if ROMHACK ~= nil and ROMHACK.area_stars ~= nil
    and ROMHACK.area_stars[np.currLevelNum] ~= nil
    and ROMHACK.area_stars[np.currLevelNum][1] == np.currAreaIndex then
      available_stars = ROMHACK.area_stars[np.currLevelNum][2]
    end
    if (total_time - runTime) > available_stars then
      runTime = total_time - available_stars
    end
  elseif (total_time - runTime) > available_stars * 2700 then
    runTime = total_time - available_stars * 2700
  end
  return total_time,runTime
end

-- random star for MiniHunt
function random_star(prevCourse,campaignCourse_)
  local campaignCourse = campaignCourse_ or 0
  local selectedStar = nil
  if campaignCourse > 0 and campaignCourse < 26 then
    -- the campaign from the 64 tour!
    local starorder = {15,22,33,44,54,64,75,85,94,101,113,121,137,144,154,171,221,14,47,62,77,93,161,181,231}
    selectedStar = starorder[campaignCourse]
  elseif selectedStar == nil then
    local replicas = false
    if ROMHACK.replica_start ~= nil then
      local courseMax = 25
      local courseMin = 1
      local totalStars = save_file_get_total_star_count(get_current_save_file_num() - 1, courseMin - 1, courseMax - 1)
      if ROMHACK.replica_start <= totalStars then
        replicas = true
      end
    end

    local valid_star_table = generate_star_table(prevCourse,false,replicas)
    selectedStar = valid_star_table[math.random(1, #valid_star_table)]
  end

  gGlobalSyncTable.getStar = selectedStar % 10
  gGlobalSyncTable.gameLevel = course_to_level[math.floor(selectedStar / 10)]
  print("Selected",gGlobalSyncTable.gameLevel,gGlobalSyncTable.getStar)
end

-- generate table of valid stars
function generate_star_table(exCourse,standard,replicas)
  local valid_star_table = {}
  for course,level in pairs(course_to_level) do
    if (standard or (course ~= 0 and course ~= 25 and (ROMHACK.hubStages == nil or ROMHACK.hubStages[course] == nil))) and (course ~= exCourse) then
      local starMax = (standard and 7) or 6
      if course == 25 and ROMHACK.starCount[level] == nil then
        starMax = 0
      elseif course > 15 or ROMHACK.starCount[level] ~= nil then
        starMax = ROMHACK.starCount[level] or 1
        if gGlobalSyncTable.ee and ROMHACK.starCount_ee ~= nil and ROMHACK.starCount_ee[level] ~= nil then
          starMax = ROMHACK.starCount_ee[level]
        end
      elseif course == 0 then
        starMax = 5
      end
      if starMax > 0 then
        if replicas and course > 15 and course ~= 25 then starMax = starMax + 1 end
        for i=1,starMax do
          local starNum = i
          if ROMHACK.renumber_stars ~= nil then
            starNum = ROMHACK.renumber_stars[course * 10 + i] or i
          end
          if starNum ~= 0 and (standard or ROMHACK.mini_exclude == nil or ROMHACK.mini_exclude[course * 10 + starNum] == nil) then
            table.insert(valid_star_table, course * 10 + starNum)
          end
        end
      end
    end
  end
  return valid_star_table
end

function on_pause_exit(exitToCastle)
  local m = gMarioStates[0]
  local sMario = gPlayerSyncTable[0]
  if gGlobalSyncTable.mhMode == 2 then return false end
  if m.health <= 0xFF then return false end
  if sMario.spectator == 1 then return false end
  if sMario.team ~= 1 then return true end
  if get_leave_requirements(sMario) > 0 then return false end
  m.health = 0x880 -- full health
  m.hurtCounter = 0x0
end

function on_death(m)
  if m.playerIndex ~= 0 then return true end
  if died == false then
    local sMario = gPlayerSyncTable[0]
    local lost = false
    local newID = nil
    local runner = false
    local time = localRunTime or 0
    m.health = 0xFF -- Mario's health is used to see if he has respawned
    died = true
    warpCount = 0
    warpCooldown = 0

    -- change to hunter
    if gGlobalSyncTable.mhState == 2 and sMario.team == 1 and sMario.runnerLives <= 0 then
      runner = true
      m.numLives = 100
      become_hunter(sMario)
      local localRunTime = 0
      lost = true

      -- pick new runner
      if gGlobalSyncTable.mhMode ~= 0 then
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

function omm_disable_non_stop_mode(disable)
  if OmmEnabled then
    _G.OmmApi.omm_disable_non_stop_mode(disable)
  end
end

function update()
  do_pause()
  if obj_get_first_with_behavior_id(id_bhvActSelector) ~= nil then
    camp_timer(gMarioStates[0],true)
  end
  if warpCooldown > 0 then warpCooldown = warpCooldown - 1 end
  if gGlobalSyncTable.votes == 0 then iVoted = false end -- undo vote

  local m = gMarioStates[0]
  local sMario = gPlayerSyncTable[0]

  -- fix save file
  --[[if justEntered and gGlobalSyncTable.otherSave ~= nil then
    save_file_set_using_backup_slot(gGlobalSyncTable.otherSave)
    save_file_reload(1)
    justEntered = false
  end]]

  if not gGlobalSyncTable.pause then
    -- handle timers (server end updates global to local, other players update local to global)
    if frameCounter < 1 then
      frameCounter = 121
    end
    frameCounter = frameCounter - 1

    if frameCounter % 30 == 0 and didFirstJoinStuff then
      if network_is_server() then
        gGlobalSyncTable.mhTimer = localMHTimer or -1
        gGlobalSyncTable.speedrunTimer = localSpeedrunTimer or 0
      else
        localMHTimer = gGlobalSyncTable.mhTimer or -1
        localSpeedrunTimer = gGlobalSyncTable.speedrunTimer or 0
      end
    end
    if didFirstJoinStuff then
      if localMHTimer > 0 then
        localMHTimer = localMHTimer - 1
      end
      if gGlobalSyncTable.mhMode ~= 2 and (gGlobalSyncTable.mhState ~= 0 and (gGlobalSyncTable.mhState == 2 or (gGlobalSyncTable.mhState < 3 and localMHTimer < 300))) then
        localSpeedrunTimer = localSpeedrunTimer + 1
      end
    end
    if localMHTimer == 0 then
      localMHTimer = -1
      gGlobalSyncTable.mhTimer = -1
      if gGlobalSyncTable.mhState == 1 then
        gGlobalSyncTable.mhState = 2
      elseif gGlobalSyncTable.mhState >= 3 or gGlobalSyncTable.mhState == 0 then
        if gameAuto ~= 0 then
          print("New game started")

          randomize_command(gameAuto)
          if gGlobalSyncTable.campaignCourse > 0 then
            start_game_command("1") -- stay in campaign mode
          else
            start_game_command("")
          end
          if localMHTimer == 0 then
            localMHTimer = 20 * 30 -- 20 seconds (in case start doesnt work)
            gGlobalSyncTable.mhTimer = localMHTimer
          end
        else
          gGlobalSyncTable.mhState = 0
        end
      else
        gGlobalSyncTable.mhState = 5
        network_send_include_self(true, {
          id = PACKET_GAME_END,
        })
        localMHTimer = 20 * 30 -- 20 seconds
        gGlobalSyncTable.mhTimer = localMHTimer
      end
    end

    if network_is_server() then
      for id,data in pairs(rejoin_timer) do
      data.timer = data.timer - 1
      if data.timer <= 0 then
        djui_popup_create(trans("rejoin_fail",data.name), 1)
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
  end

  -- kill combo stuff
  if killTimer > 0 then
    killTimer = killTimer - 1
  end
  if killTimer == 0 then killCombo = 0 end
  if hitTimer > 0 then
    hitTimer = hitTimer - 1
  end
  if hitTimer == 0 and (m.action & ACT_FLAG_AIR) == 0 then attackedBy = nil end -- only reset on ground
end

-- do first join setup
function on_course_sync()
  if not didFirstJoinStuff then
    local m = gMarioStates[0]
    local sMario = gPlayerSyncTable[0]

    OmmEnabled = _G.OmmEnabled or false -- set up OMM support
    if OmmEnabled then
      _G.OmmApi.omm_resolve_cappy_mario_interaction = omm_attack
      _G.OmmApi.omm_allow_cappy_mario_interaction = omm_allow_attack
    end
    if gGlobalSyncTable.romhackFile == "vanilla" then
      omm_replace(OmmEnabled)
    end

    setup_hack_data(network_is_server(), true, OmmEnabled)
    if network_is_server() then
      load_settings()
    end
    show_rules()
    print(get_time())
    math.randomseed(get_time())
    gLevelValues.starHeal = false

    djui_chat_message_create(trans("to_switch",lang_list))

    save_file_set_using_backup_slot(gGlobalSyncTable.otherSave)
    save_file_reload(1)
    if ROMHACK.stalk then
      stalk_command("",true)
      djui_popup_create(trans("stalk"), 1)
    elseif gGlobalSyncTable.otherSave then
      warp_beginning()
    end

    -- display and set stats
    local wins = tonumber(mod_storage_load("wins")) or 0
    local kills = tonumber(mod_storage_load("kills")) or 0
    local maxStreak = tonumber(mod_storage_load("maxStreak")) or 0
    local hardWins = tonumber(mod_storage_load("hardWins")) or 0
    local maxStar = tonumber(mod_storage_load("maxStar")) or 0

    sMario.wins = math.floor(wins)
    sMario.kills = math.floor(kills)
    sMario.maxStreak = math.floor(maxStreak)
    sMario.hardWins = math.floor(hardWins)
    sMario.maxStar = math.floor(maxStar)

    local np = gNetworkPlayers[0]
    local playerColor = network_get_player_text_color_string(0)
    if wins >= 1 then
      network_send(false, {
        id = PACKET_STATS,
        stat = "disp_wins",
        value = math.floor(wins),
        name = playerColor .. np.name,
      })
      if wins >= 5 and hardWins <= 0 then
        djui_chat_message_create(trans("hard_notice"))
      end
    end
    if hardWins >= 1 then
      network_send(false, {
        id = PACKET_STATS,
        stat = "disp_wins_hard",
        value = math.floor(hardWins),
        name = playerColor .. np.name,
      })
      if wins >= 5 and hardWins <= 0 then
        djui_chat_message_create(trans("hard_notice"))
      end
    end
    if kills >= 50 then
      network_send(false, {
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
    discordID = tonumber(discordID) or 0
    print("My discord ID is",discordID)
    sMario.discordID = discordID
    if discordID ~= 0 then
      -- reward for competition
      local placement = {
        [409438020870078486] = 0, -- 0 is dev role
        [984667169738600479] = 0,
        [727325076696989857] = -1, -- for the meme

        [452585486389870592] = 1,
        [451375514977042432] = 2,
        [590250114606432304] = 3,
        [376426041788465173] = 4,
        [541396312608866305] = 5,
        [698849755274543204] = 6,
        [361984642590441474] = 7,
        [207244001575698432] = 8,
        -- [???] = 8, -- ClassicMario64 (missing discord id)
        [249651355889696768] = 10,
      }
      if placement[discordID] ~= nil then
        sMario.placement = placement[discordID]
      else
        sMario.placement = 999
      end
    else
      sMario.placement = 999
    end

    -- start out as hunter
    become_hunter(sMario)
    sMario.totalStars = 0
    sMario.pause = gGlobalSyncTable.pause or false
    sMario.forceSpectate = gGlobalSyncTable.forceSpectate or false

    if gGlobalSyncTable.mhState == 0 then
      set_background_music(0,0x41,0)
      --play_music(0, 0x41, 1)
    end

    -- ???
    local wip = false
    if wip and network_is_server() and sMario.placement ~= 0 then
      xxx = true
    end

    didFirstJoinStuff = true
  end
end

-- load saved settings for host
function load_settings()
  if gServerSettings.headlessServer == 1 then
    gameAuto = 99
    gGlobalSyncTable.mhMode = 2
    gGlobalSyncTable.runTime = 9000
    localMHTimer = 30 * 30
    gGlobalSyncTable.mhTimer = localMHTimer
    return
  end

  local settings = {"runnerLives","runTime","allowSpectate","starMode","weak","mhMode","metal","campaignCourse"}
  for i,setting in ipairs(settings) do
    if setting == "weak" and OmmEnabled then setting = "ommWeak" end
    local option = mod_storage_load(setting)
    if option ~= nil then
      if option == "true" then
        gGlobalSyncTable[setting] = true
      elseif option == "false" then
        gGlobalSyncTable[setting] = false
      elseif tonumber(option) ~= nil then
        gGlobalSyncTable[setting] = math.floor(tonumber(option))
      end
    end
  end
  -- special cases
  local option = mod_storage_load("auto")
  if gGlobalSyncTable.mhMode == 2 and option ~= nil and tonumber(option) ~= nil then
    gameAuto = tonumber(option)
    if gameAuto ~= 0 then
      localMHTimer = 30 * 30
      gGlobalSyncTable.mhTimer = localMHTimer
    end
  end
  local fileName = string.gsub(gGlobalSyncTable.romhackFile," ","_")
  option = mod_storage_load(fileName)
  if option ~= nil and tonumber(option) ~= nil then
    gGlobalSyncTable.starRun = tonumber(option)
  end
end
-- save settings for host
function save_settings()
  if not network_is_server() then return end

  local settings = {"runnerLives","runTime","allowSpectate","starMode","weak","mhMode","metal","campaignCourse"}
  for i,setting in ipairs(settings) do
    if setting == "weak" and OmmEnabled then setting = "ommWeak" end
    local option = gGlobalSyncTable[setting]
    if option ~= nil then
      if option == true then
        mod_storage_save(setting,"true")
      elseif option == false then
        mod_storage_save(setting,"false")
      elseif tonumber(option) ~= nil then
        mod_storage_save(setting,tostring(math.floor(option)))
      end
    end
  end
  -- special cases
  local option = gameAuto
  if option ~= nil then
    mod_storage_save("auto",tostring(gameAuto))
  end
  option = gGlobalSyncTable.starRun
  local fileName = string.gsub(gGlobalSyncTable.romhackFile," ","_")
  if fileName ~= "custom" and option ~= nil then
    mod_storage_save(fileName,tostring(option))
  end
end
-- loads default settings for host
function default_settings()
  if not network_is_server() then
    djui_chat_message_create(trans("not_mod"))
    return true
  end
  gGlobalSyncTable.runnerLives = 1
  gGlobalSyncTable.runTime = 7200
  gGlobalSyncTable.allowSpectate = true
  gGlobalSyncTable.starMode = false
  gGlobalSyncTable.weak = false
  gGlobalSyncTable.mhMode = 0
  gGlobalSyncTable.metal = false
  setup_hack_data(true,false,OmmEnabled)
  show_rules()
  return true
end

function camp_timer(m,inSelect)
  if m.playerIndex ~= 0 then return end
  local sMario = gPlayerSyncTable[0]
  local c = m.area.camera
  if sMario.team == 1 then
    if m.freeze == true or (m.freeze ~= false and m.freeze > 2) then
      if campTimer == nil then
        campTimer = 600 -- 20 seconds
      end
      m.invincTimer = 60 -- 2 seconds
    elseif campTimer == nil and inSelect then
      campTimer = 300 -- 10 seconds
    end
  end
  if campTimer ~= nil and not sMario.pause then
    campTimer = campTimer - 1
    if campTimer % 30 == 0 then
      play_sound(SOUND_MENU_CAMERA_BUZZ, m.marioObj.header.gfx.cameraToObject)
    end
    if campTimer <= 0 then
      campTimer = -1
      if not inSelect then
        m.controller.buttonPressed = m.controller.buttonPressed | A_BUTTON -- mash a to get out of menu
      else
        campTimer = nil
        sMario.runnerLives = 0
        died = false
        on_death(m)
      end
      return
    end
  end
end

function show_rules()
-- how to play message
  if gGlobalSyncTable.mhMode ~= 2 then
    if math.random(1,100) == 1 then
      djui_chat_message_create(trans("welcome_egg"))
    else
      djui_chat_message_create(trans("welcome"))
    end
  else
    djui_chat_message_create(trans("welcome_mini"))
  end

  local runners = trans("runners")
  local hunters = trans("hunters")

  local sMario = gPlayerSyncTable[0]
  local extraRun = ""
  if gGlobalSyncTable.mhState ~= 0 and gGlobalSyncTable.mhState < 3 then
    if sMario.team ~= 1 then
      extraRun = " " .. trans("shown_above")
    else
      extraRun = " " .. trans("thats_you")
    end
  end
  local runGoal = ""
  if gGlobalSyncTable.mhMode == 2 then
    runGoal = trans("mini_collect")
  elseif (gGlobalSyncTable.starRun) == -1 then
    runGoal = trans("any_bowser")
  elseif ROMHACK == nil or ROMHACK.no_bowser ~= true then
    runGoal = trans("collect_bowser",gGlobalSyncTable.starRun)
  else
    runGoal = trans("collect_only",gGlobalSyncTable.starRun)
  end

  local extraHunt = ""
  if gGlobalSyncTable.mhState ~= 0 and gGlobalSyncTable.mhState < 3 and sMario.team ~= 1 then
    extraHunt = " " .. trans("thats_you")
  end
  local huntGoal = ""
  if gGlobalSyncTable.mhMode == 0 then
    huntGoal = trans("all_runners")
  else
    huntGoal = trans("any_runners")
  end

  local runLives = trans_plural("lives",(gGlobalSyncTable.runnerLives+1))
  local needed = ""
  if gGlobalSyncTable.mhMode == 2 then
    -- nothing
  elseif (gGlobalSyncTable.starMode) then
    needed = "; " .. trans("stars_needed",gGlobalSyncTable.runTime)
  else
    local seconds = math.floor(gGlobalSyncTable.runTime/30) % 60
    local minutes = math.floor(gGlobalSyncTable.runTime / 1800)
    needed = "; " .. trans("time_needed",minutes,seconds)
  end
  local becomeHunter = ""
  local becomeRunner = ""
  if gGlobalSyncTable.mhMode == 0 then
    becomeHunter = "; " .. trans("become_hunter")
  else
    becomeRunner = "; " .. trans("become_runner")
  end

  local spectate = ""
  if gGlobalSyncTable.allowSpectate == true then
    spectate = "; " .. trans("spectate")
  end
  local banned = ""
  if (gGlobalSyncTable.starRun) ~= -1 then
    banned = trans("banned_glitchless")
  else
    banned = trans("banned_general")
  end

  local fun = trans("fun")
  if gGlobalSyncTable.mhMode == 2 then
    fun = trans("mini_goal",math.floor(gGlobalSyncTable.runTime/1800),math.floor((gGlobalSyncTable.runTime%1800)/30)) .. " " .. fun
  end

  local text = string.format("\\#00ffff\\%s\\#ffffff\\%s: %s"..
  "\n\\#ff5c5c\\%s\\#ffffff\\%s: %s"..
  "\n\\#00ffff\\%s\\#ffffff\\: %s%s%s."..
  "\n\\#ff5c5c\\%s\\#ffffff\\: %s%s%s."..
  "\n%s\n%s",
  runners,
  extraRun,
  runGoal,
  hunters,
  extraHunt,
  huntGoal,
  runners,
  runLives,
  needed,
  becomeHunter,
  hunters,
  trans("infinite_lives"),
  spectate,
  becomeRunner,
  banned,
  fun
  )
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
  -- render to N64 screen space, with the NORMAL font
  djui_hud_set_render_behind_hud(false)
  djui_hud_set_resolution(RESOLUTION_N64)
  djui_hud_set_font(FONT_NORMAL)

  if not didFirstJoinStuff then return end
  if xxx then return xxxxx() end

  -- stats hud
  if showingStats then
    return stats_table_hud()
  end

  local text = ""
  local sMario = gPlayerSyncTable[0]
  -- yay long if statement
  if gGlobalSyncTable.mhState == 1 then -- game start timer
    text = timer_hud()
  elseif gGlobalSyncTable.mhState == 0 then
    text = unstarted_hud(sMario)
  elseif campTimer ~= nil then -- camp timer has top priority
    text = camp_hud(sMario)
  elseif gGlobalSyncTable.mhState ~= nil and gGlobalSyncTable.mhState >= 3 then -- game end
    text = victory_hud()
  elseif sMario.team == 1 then -- do runner hud
    text = runner_hud(sMario)
  else -- do hunter hud
    text = hunter_hud(sMario)
  end

  -- player radar
  if sMario.team ~= 1 then
    for i=0,(MAX_PLAYERS-1) do
      if gPlayerSyncTable[i].team == 1 then
        local theirNP = gNetworkPlayers[i]
        local np = gNetworkPlayers[0]
        if theirNP.connected then
          if (theirNP.currLevelNum == np.currLevelNum) and (theirNP.currAreaIndex == np.currAreaIndex) and (theirNP.currActNum == np.currActNum) then
            local rm = gMarioStates[theirNP.localIndex]
            render_radar(rm, icon_radar[i])
          end
        end
      end
    end
  end

  -- star radar
  if gGlobalSyncTable.mhMode ~= 2 or gNetworkPlayers[0].currLevelNum == gGlobalSyncTable.gameLevel then
    for id,bhvName in pairs(star_ids) do
      local obj = obj_get_first_with_behavior_id(id)
      while obj ~= nil do
        if obj.unused1 == nil then obj.unused1 = 0 end
        local star = (obj.oBehParams >> 24) + 1
        if gGlobalSyncTable.mhMode ~= 2 then
          local file = get_current_save_file_num() - 1
          local course_star_flags = save_file_get_star_flags(file, gNetworkPlayers[0].currCourseNum - 1)
          if course_star_flags & (1 << (star - 1)) == 0 then
            render_radar(obj, star_radar[star], true)
          end
        elseif star == gGlobalSyncTable.getStar then
          render_radar(obj, star_radar[star], true)
          if obj.unused1 ~= 5 then
            obj_set_model_extended(obj, E_MODEL_STAR)
            obj.unused1 = obj.unused1 + 1 -- using this as a flag
          end
        elseif obj.unused1 ~= 5 then
          obj_set_model_extended(obj, E_MODEL_TRANSPARENT_STAR)
          obj.unused1 = obj.unused1 + 1 -- using this as a flag
        end
        obj = obj_get_next_with_same_behavior_id(obj)
      end
    end
    -- work with boxes
    local obj = obj_get_first_with_behavior_id(id_bhvExclamationBox)
    while obj ~= nil do
      if exclamation_box_valid[obj.oBehParams2ndByte] and obj.oAction ~= 6 then
        local star = (obj.oBehParams >> 24) + 1
        if obj.oBehParams2ndByte ~= 8 then
          star = obj.oBehParams2ndByte - 8
        end
        if star == 0 then print("ERROR!") end
        if gGlobalSyncTable.mhMode ~= 2 then
          local file = get_current_save_file_num() - 1
          local course_star_flags = save_file_get_star_flags(file, gNetworkPlayers[0].currCourseNum - 1)
          if course_star_flags & (1 << (star - 1)) == 0 then
            render_radar(obj, box_radar[star], true, true)
          end
        elseif star == gGlobalSyncTable.getStar then
          render_radar(obj, box_radar[star], true, true)
        end
      end
      obj = obj_get_next_with_same_behavior_id(obj)
    end
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
  local space = 0
  local color = ""
  text,color,render = remove_color(text,true)
  local LIMIT = 0
  while render ~= nil do
    local r,g,b,a = convert_color(color)
    djui_hud_print_text(render, x+space, y, scale);
    djui_hud_set_color(r, g, b, a);
    space = space + djui_hud_measure_text(render) * scale
    text,color,render = remove_color(text,true)
  end
  djui_hud_print_text(text, x+space, y, scale);

  -- star name for minihunt
  if gGlobalSyncTable.mhMode == 2 and gGlobalSyncTable.mhState == 2 then
    local np = gNetworkPlayers[0]
    text = get_custom_star_name(np.currCourseNum, gGlobalSyncTable.getStar)
    width = djui_hud_measure_text(text) * scale
    local screenHeight = djui_hud_get_screen_height()
    x = (screenWidth - width) / 2.0
    y = screenHeight - 16

    djui_hud_set_color(0, 0, 0, 128);
    djui_hud_render_rect(x - 6, y, width + 12, 32*scale);

    djui_hud_set_color(255, 255, 255, 255);
    djui_hud_print_text(text, x, y, scale);
  elseif showSpeedrunTimer and gGlobalSyncTable.mhMode ~= 2 then
    local miliseconds = math.floor(localSpeedrunTimer/30%1*100)
    local seconds = math.floor(localSpeedrunTimer/30) % 60
    local minutes = math.floor(localSpeedrunTimer/30/60) % 60
    local hours = math.floor(localSpeedrunTimer/30/60/60)
    text = string.format("%d:%02d:%02d.%02d", hours, minutes, seconds, miliseconds)
    width = 118 * scale
    local screenHeight = djui_hud_get_screen_height()
    x = (screenWidth - width) / 2.0
    y = screenHeight - 16

    djui_hud_set_color(0, 0, 0, 128);
    djui_hud_render_rect(x - 6, y, width + 12, 32*scale);

    djui_hud_set_color(255, 255, 255, 255);
    djui_hud_print_text(text, x, y, scale);
  end

  -- timer
  scale = 0.5
  if localMHTimer ~= nil and localMHTimer > 0 then
    local seconds = math.floor(localMHTimer/30) % 60
    local minutes = math.floor(localMHTimer / 1800)
    text = string.format("%d:%02d",minutes,seconds)
    width = djui_hud_measure_text(text) * scale
    x = 6
    y = 0

    djui_hud_set_color(0, 0, 0, 128);
    djui_hud_render_rect(x - 6, y, width + 12, 16);

    djui_hud_set_color(255, 255, 255, 255);
    djui_hud_print_text(text, x, y, scale);
  end
end

function runner_hud(sMario)
  local text = ""
  if gGlobalSyncTable.mhMode ~= 2 then
    -- set star text
    local timeLeft,special = get_leave_requirements(sMario)
    if special ~= nil then
      text = special
    elseif timeLeft <= 0 then
      text = trans("can_leave")
    elseif gGlobalSyncTable.starMode then
      text = trans("stars_left",timeLeft)
    else
      local seconds = math.floor(timeLeft/30) % 60
      local minutes = math.floor(timeLeft / 1800)
      text = trans("time_left",minutes,seconds)
    end
  else
    return unstarted_hud(sMario)
  end
  return text
end

function hunter_hud(sMario)
  -- set player text
  local default = "\\#00ffff\\" .. trans("runners")..": "
  local text = default
  for i=0,(MAX_PLAYERS-1) do
    if gPlayerSyncTable[i].team == 1 then
      local np = gNetworkPlayers[i]
      if np.connected then
        local playerColor = network_get_player_text_color_string(np.localIndex)
        text = text .. playerColor .. np.name .. ", "
      end
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
  local seconds = math.ceil(localMHTimer/30)
  local text = trans("until_hunters",seconds)
  if seconds > 10 then
    text = trans("until_runners",(seconds-10))
  end

  return text
end

function victory_hud()
  -- set win text
  local text = trans("win","\\#ff5c5c\\"..trans("hunters"))
  if gGlobalSyncTable.mhState == 5 then
    text = trans("game_over")
  elseif gGlobalSyncTable.mhState > 3 then
    text = trans("win","\\#00ffff\\"..trans("runners"))
  end
  return text
end

function unstarted_hud(sMario)
  -- display role
  local text = ""
  if sMario.team == 1 then
    text = trans("runner")
    if sMario.hard then
      text = "\\#ffff5a\\" .. text
    else
      text = "\\#00ffff\\" .. text
    end
  else
    text = "\\#ff5c5c\\" .. trans("hunter")
  end
  return text
end

function camp_hud(sMario)
  return trans("camp_timer",math.floor(campTimer / 30))
end

-- this code is kind of bad
function stats_table_hud()
  local text = ""

  local scale = 0.3
  local screenWidth = djui_hud_get_screen_width()
  local screenHeight = djui_hud_get_screen_height()
  local width = 0
  local x = 0
  local y = 60
  djui_hud_set_color(0, 0, 0, 200);
  djui_hud_render_rect(screenWidth/9, 0, 7*screenWidth/9, screenHeight);
  local statOrder = {"wins","kills","maxStreak","hardWins","maxStar","placement"}
  local descOrder = {"stat_wins","stat_kills","stat_combo","stat_wins_hard","stat_mini_stars","stat_placement"}

  djui_hud_set_font(FONT_HUD)
  text = "Stats"
  width = djui_hud_measure_text(text)
  x = (screenWidth-width) / 2
  djui_hud_set_color(255, 255, 255, 255);
  djui_hud_print_text(text, x, 10, 1);
  djui_hud_set_font(FONT_NORMAL)

  text = trans("player")
  width = djui_hud_measure_text(text)*scale
  x = screenWidth/9+50-width/2
  djui_hud_print_text(text, x, y - 64 * scale, scale);

  x = screenWidth/9+110
  space = (7*screenWidth/9-140)/(#statOrder-1)
  for i=1,#stat_icon_data do
    local data = stat_icon_data[i]
    djui_hud_set_color(data.r, data.g, data.b, 255)
    djui_hud_render_texture(data.tex,x-1.5,y - 64 * scale,0.5,0.5)
    if math.abs(sortBy) == i then
      local sign = i / sortBy
      if sign == 1 then
        djui_hud_set_color(92, 255, 92, 255)
        djui_hud_render_texture(TEX_ARROW,x+8,y-10,0.4,0.4)
      else
        djui_hud_set_color(255, 92, 92, 255)
        djui_hud_render_texture(TEX_ARROW,x+15,y-3,-0.4,-0.4)
      end
    end
    if statDesc == i then
      djui_hud_set_color(92, 255, 92, math.abs((frameCounter%60)-30)*2)
      djui_hud_render_rect(x+20*scale-space/2, y - 64 * scale - 5, space, screenHeight - 16 * scale - y + 5);
    end
    x = x + space
  end

  local statTable = {}
  for i=0,(MAX_PLAYERS-1) do
    local np = gNetworkPlayers[i]
    if i == 0 or np.connected then
      table.insert(statTable, i)
    end
  end

  if sortBy ~= 0 and #statTable > 1 then
    table.sort(statTable, function (a, b)
      local actSortBy = math.abs(sortBy)
      local aSMario = gPlayerSyncTable[a]
      local bSMario = gPlayerSyncTable[b]
      if sortBy < 0 then
        return (aSMario[statOrder[actSortBy]] or 0) < (bSMario[statOrder[actSortBy]] or 0)
      else
        return (aSMario[statOrder[actSortBy]] or 0) > (bSMario[statOrder[actSortBy]] or 0)
      end
    end)
  end

  for a,i in ipairs(statTable) do
    x = 0
    local sMario = gPlayerSyncTable[i]
    local np = gNetworkPlayers[i]
    local playerColor = network_get_player_text_color_string(i)

    text = playerColor .. np.name .. "\\#ffffff\\"
    width = djui_hud_measure_text(remove_color(text))*scale
    x = screenWidth/9+50-width/2
    djui_hud_set_color(255, 255, 255, 255);
    local space = 0
    local color = ""
    text,color,render = remove_color(text,true)
    local LIMIT = 0
    while render ~= nil do
      local r,g,b,a = convert_color(color)
      djui_hud_print_text(render, x+space, y, scale)
      djui_hud_set_color(r, g, b, a);
      space = space + djui_hud_measure_text(render) * scale
      text,color,render = remove_color(text,true)
    end
    djui_hud_print_text(text, x+space, y, scale)
    djui_hud_set_color(255, 255, 255, 255)

    x = screenWidth/9+110
    space = (7*screenWidth/9-140)/(#statOrder-1)
    for i=1,#statOrder do
      text = string.format("%03d",(sMario[statOrder[i]] or 0))
      djui_hud_print_text(text, x, y, scale)
      x = x + space
    end
    y = y + 32 * scale
  end

  scale = 0.5

  text = trans(descOrder[statDesc])
  width = djui_hud_measure_text(text) * scale
  x = (screenWidth - width) / 2.0
  y = screenHeight - 32 * scale

  djui_hud_set_color(255, 255, 255, 255);
  djui_hud_print_text(text, x, y, scale);
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
  local astring = text:sub(7,8) or "ff"
  local r = tonumber("0x"..rstring) or 255
  local g = tonumber("0x"..gstring) or 255
  local b = tonumber("0x"..bstring) or 255
  local a = tonumber("0x"..astring) or 255
  return r,g,b,a
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
  sPacketTable[data.id](data,true)
end

-- uses custom star names if aplicable
function get_custom_star_name(course, starNum)
  if ROMHACK.starNames ~= nil then
    if gGlobalSyncTable.ee then
      if ROMHACK.starNames_ee ~= nil and ROMHACK.starNames_ee[course*10+starNum] ~= nil then
        return ROMHACK.starNames_ee[course*10+starNum]
      end
    elseif ROMHACK.starNames[course*10+starNum] ~= nil then
      return ROMHACK.starNames[course*10+starNum]
    end
    return get_star_name(course, starNum)
  end
  return get_star_name(course, starNum)
end

function change_team_command(msg)
  local playerID,np = get_specified_player(msg)
  if playerID == nil then return true end

  local sMario = gPlayerSyncTable[playerID]
  local playerColor = network_get_player_text_color_string(np.localIndex)
  local name = playerColor .. np.name
  if sMario.team ~= 1 then
    become_runner(sMario)
    djui_popup_create_global(trans("now_runner",name), 1)
  else
    become_hunter(sMario)
    djui_popup_create_global(trans("now_hunter",name), 1)
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
    if np.connected and sMario.team ~= 1 and sMario.spectator ~= 1 then
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
    local playerColor = network_get_player_text_color_string(np.localIndex)
    become_runner(sMario)
    djui_popup_create_global(trans("now_runner",playerColor..np.name), 1)
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
  if msg == nil or msg == "" or msg == 99 then
    runners = 0 -- TBD
  elseif (runners == nil or runners ~= math.floor(runners) or runners < 1) then
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

  if runners == 0 then -- calculate good amount of runners
    runners = math.floor((#currPlayerIDs+2)/4) -- 3 hunters per runner (4 max with 16 player lobby)
    if runners == 0 then
      djui_chat_message_create(trans("must_have_one"))
      return treu
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
    local playerColor = network_get_player_text_color_string(np.localIndex)
    become_runner(sMario)
    djui_popup_create_global(trans("now_runner",playerColor..np.name), 1)
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
  if gGlobalSyncTable.starMode and gGlobalSyncTable.mhMode ~= 2 then
    djui_chat_message_create(trans("wrong_mode"))
    return true
  end
  local num = tonumber(msg)
  if num ~= nil then
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
  if num ~= nil and num > 0 and num < 8 then
    gGlobalSyncTable.runTime = num
    djui_chat_message_create(trans("need_stars_feedback",num))
    return true
  end
  return false
end

function auto_command(msg)
  if gGlobalSyncTable.mhMode ~= 2 then
    djui_chat_message_create(trans("wrong_mode"))
    return true
  elseif not network_is_server() then -- host only
    djui_chat_message_create(trans("not_mod"))
    return true
  end

  local num = tonumber(msg)
  if string.lower(msg) == "on" then
    num = 99
  elseif string.lower(msg) == "off" then
    num = 0
  elseif num == nil or math.floor(num) ~= num then
    return false
  elseif num > (MAX_PLAYERS-1) then
    djui_chat_message_create(trans("must_have_one"))
    return true
  end

  if num == 99 then
    gameAuto = 99
    djui_chat_message_create(trans("auto_on"))
    if gGlobalSyncTable.mhState == 0 then
      localMHTimer = 20 * 30 -- 20 seconds
      gGlobalSyncTable.mhTimer = localMHTimer
    end
  elseif num > 0 then
    gameAuto = num
    local runners = trans("runners")
    if num == 1 then runners = trans("runner") end
    djui_chat_message_create(string.format("%s (%d %s)",trans("auto_on"),num,runners))
    if gGlobalSyncTable.mhState == 0 then
      localMHTimer = 20 * 30 -- 20 seconds
      gGlobalSyncTable.mhTimer = localMHTimer
    end
  else
    gameAuto = 0
    djui_chat_message_create(trans("auto_off"))
    if gGlobalSyncTable.mhState == 0 then
      localMHTimer = -1 -- don't set
      gGlobalSyncTable.mhTimer = localMHTimer
    end
  end
  return true
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
    gGlobalSyncTable.runnerLives = 1
    gGlobalSyncTable.runTime = 7200 -- 4 minutes
    if gGlobalSyncTable.starMode then gGlobalSyncTable.runTime = 2 end
    return true
  elseif string.lower(msg) == "switch" then
    gGlobalSyncTable.mhMode = 1
    gGlobalSyncTable.runnerLives = 0
    gGlobalSyncTable.runTime = 7200 -- 4 minutes
    if gGlobalSyncTable.starMode then gGlobalSyncTable.runTime = 2 end
    return true
  elseif string.lower(msg) == "mini" then
    local np = gNetworkPlayers[0]
    gGlobalSyncTable.mhMode = 2
    gGlobalSyncTable.runnerLives = 0
    gGlobalSyncTable.runTime = 9000 -- 5 minutes
    gGlobalSyncTable.gameLevel = np.currLevelNum
    gGlobalSyncTable.getStar = np.currActNum
    if gGlobalSyncTable.getStar == 0 then gGlobalSyncTable.getStar = 1 end
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

function force_spectate_command(msg)
  if msg == "all" then
    if gGlobalSyncTable.forceSpectate then
      gGlobalSyncTable.forceSpectate = false
      for i=0,(MAX_PLAYERS-1) do
        gPlayerSyncTable[i].forceSpectate = false
      end
      djui_chat_message_create(trans("force_spectate_off"))
    else
      gGlobalSyncTable.forceSpectate = true
      for i=0,(MAX_PLAYERS-1) do
        gPlayerSyncTable[i].forceSpectate = true
      end
      djui_chat_message_create(trans("force_spectate"))
    end
    return true
  end

  local playerID,np = get_specified_player(msg)
  if playerID == nil then return true end

  local sMario = gPlayerSyncTable[playerID]
  local name = remove_color(np.name)
  if sMario.forceSpectate then
    sMario.forceSpectate = false
    djui_chat_message_create(trans("force_spectate_one_off",name))
  else
    sMario.forceSpectate = true
    djui_chat_message_create(trans("force_spectate_one",name))
  end
  return true
end

function desync_fix_command(msg)
  local oldLevel = gGlobalSyncTable.gameLevel
  local oldStar = gGlobalSyncTable.getStar
  gGlobalSyncTable.gameLevel = -1
  gGlobalSyncTable.getStar = -1
  gGlobalSyncTable.gameLevel = oldLevel
  gGlobalSyncTable.getStar = oldStar
  for i=1,(MAX_PLAYERS-1) do
    local sMario = gPlayerSyncTable[i]
    local oldTeam = sMario.team or 0
    sMario.team = -1
    sMario.team = oldTeam
  end
  return true
end

function halt_command(msg)
  gGlobalSyncTable.mhState = 5
  network_send_include_self(true, {
    id = PACKET_GAME_END,
    winner = -1,
  })
  localMHTimer = 20 * 30 -- 20 seconds
  gGlobalSyncTable.mhTimer = localMHTimer
  return true
end

-- TroopaParaKoopa's pause mod
function pause_command(msg)
  if msg == "all" then
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
      if gPlayerSyncTable[0].spectator ~= 1 then
         gMarioStates[0].invincTimer = 100

         if warpCooldown == 0 then
            warpCount = 0
         elseif warpCount >= 4 then
            gMarioStates[0].hurtCounter = gMarioStates[0].hurtCounter + (warpCount * 4)
            djui_popup_create(trans("warp_spam"), 1)
            warpCount = warpCount + 1
         else
            warpCount = warpCount + 1
         end
         warpCooldown = 300 -- 5 seconds
         if gGlobalSyncTable.mhState == 0 then -- and background music
            set_background_music(0,0x41,0)
            --play_music(0, 0x41, 1)
         end
      end
   end
)

function on_player_disconnected(m)
  local np = gNetworkPlayers[m.playerIndex]
  -- unassign attack
  if np.globalIndex == attackedBy then attackedBy = nil end


  -- for host only
  if network_is_server() then -- rejoin handling
    local sMario = gPlayerSyncTable[m.playerIndex]
    sMario.wins,sMario.kills,sMario.maxStreak,sMario.hardWins,sMario.maxStar,sMario.beenRunner = 0,0,0,0,0,0 -- unassign stats

    local runner = (sMario.team == 1)
    local discordID = sMario.discordID or 0
    sMario.discordID = 0
    sMario.placement = 999
    if runner or gGlobalSyncTable.mhMode == 2 then
      local grantRunner = (sMario.team == 1 and gGlobalSyncTable.mhMode ~= 2)
      local runtime = sMario.runTime or 0

      print(tostring(discordID),"left")

      become_hunter(sMario) -- be hunter by default
      if discordID ~= 0 then
        local playerColor = network_get_player_text_color_string(np.localIndex)
        local name = playerColor .. np.name
        rejoin_timer[discordID] = {name = name, timer = 3600, runner = grantRunner, lives = sMario.runnerLives, stars = sMario.totalStars} -- 2 minutes
        djui_popup_create(trans("rejoin_start",name), 1)
      end
      if runner and gGlobalSyncTable.mhMode ~= 0 and (discordID == 0 or gGlobalSyncTable.mhMode == 2) then
        local newID = new_runner(true)
        if newID ~= nil then
          network_send_include_self(true, {
              id = PACKET_KILL,
              newRunnerID = newID,
              time = runtime or 0,
          })
        end
      end
    end
  end
end

-- based off of example
function mario_update(m)
  if not didFirstJoinStuff then return end

  -- force spectate
  local sMario = gPlayerSyncTable[m.playerIndex]
  if m.playerIndex == 0 and sMario.spectator ~= 1 and sMario.forceSpectate
  and sMario.team ~= 1 and gGlobalSyncTable.allowSpectate then
    spectate_command("runner")
  end

  -- stats table controls
  if m.playerIndex == 0 and showingStats then
    if m.freeze < 1 then m.freeze = 1 end
    if (m.controller.buttonPressed & START_BUTTON) ~= 0 then
      showingStats = false
      m.controller.buttonPressed = m.controller.buttonPressed - START_BUTTON
      play_sound(SOUND_MENU_CAMERA_ZOOM_OUT, m.marioObj.header.gfx.cameraToObject)
    else
      if (m.controller.buttonDown & L_JPAD) ~= 0 or (m.controller.rawStickX < -64) then
        if holdTimeLeft == 0 then
          statDesc = (statDesc + #stat_icon_data - 2) % (#stat_icon_data) + 1
          play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
          holdTimeLeft = 5
        else
          holdTimeLeft = holdTimeLeft - 1
        end
      else
        holdTimeLeft = 0
      end
      if (m.controller.buttonDown & R_JPAD) ~= 0 or (m.controller.rawStickX > 64) then
        if holdTimeRight == 0 then
          statDesc = (statDesc + #stat_icon_data) % (#stat_icon_data) + 1
          play_sound(SOUND_MENU_CHANGE_SELECT, m.marioObj.header.gfx.cameraToObject)
          holdTimeRight = 5
        else
          holdTimeRight = holdTimeRight - 1
        end
      else
        holdTimeRight = 0
      end
      if holdTimeLeft == 0 and holdTimeRight == 0 then
        if (m.controller.buttonPressed & A_BUTTON) ~= 0 then
          play_sound(SOUND_MENU_CLICK_FILE_SELECT, m.marioObj.header.gfx.cameraToObject)
          if sortBy == statDesc then
            sortBy = 0
          else
            sortBy = statDesc
          end
        elseif (m.controller.buttonPressed & B_BUTTON) ~= 0 then
          play_sound(SOUND_MENU_CLICK_FILE_SELECT, m.marioObj.header.gfx.cameraToObject)
          if sortBy == -statDesc then
            sortBy = 0
          else
            sortBy = -statDesc
          end
        end
      end
    end
  end

  if m.cap ~= 0 then m.cap = 0 end -- return cap


  -- set and decrement regain cap timer
  if m.playerIndex == 0 then
    if m.capTimer > 0 then
      cooldownCaps = m.flags
      regainCapTimer = 60
    elseif regainCapTimer > 0 then
      regainCapTimer = regainCapTimer - 1
    end
  end

  -- run death if health is 0, or reset death status
  if m.health <= 0xFF then
    on_death(m)
  elseif m.playerIndex == 0 then
    if died and m.invincTimer < 100 then m.invincTimer = 100 end -- start invincibility
    died = false
    -- prevent coin loss in OMM... unless it's ztar attack
    if OmmEnabled and ROMHACK.stalk == nil then
      if prevCoins < m.numCoins then
        prevCoins = m.numCoins
      elseif prevCoins > m.numCoins then
        m.numCoins = prevCoins
      end
    end
    -- match life counter to actual lives
    if sMario.team == 1 and m.numLives ~= sMario.runnerLives and sMario.runnerLives ~= nil then
      m.numLives = sMario.runnerLives
    end
  end

  -- update star counter in MiniHunt mode
  if gGlobalSyncTable.mhMode == 2 then
    m.numStars = sMario.totalStars or 0
    m.prevNumStarsForDialog = m.numStars
  end

  -- cut invincibility frames
  if gGlobalSyncTable.weak and m.invincTimer > 0 then
    m.invincTimer = m.invincTimer - 1
  end

  -- handle rejoining
  local np = gNetworkPlayers[m.playerIndex]
  if rejoin_timer ~= nil and m.playerIndex ~= 0 and np.connected then
    local discordID = sMario.discordID or 0
    if discordID ~= 0 and rejoin_timer[discordID] ~= nil then
      -- become runner again
      local data = rejoin_timer[discordID]
      if data.runner then
        become_runner(sMario)
        sMario.runnerLives = data.lives
      end
      sMario.totalStars = data.stars or 0
      djui_popup_create(trans("rejoin_success",data.name), 1)
      rejoin_timer[discordID] = nil
    end
  end

  -- display as paused
  if sMario.pause then
    m.marioBodyState.modelState = MODEL_STATE_NOISE_ALPHA
    m.invincTimer = 60
  end
  -- display metal particles
  if (m.flags & MARIO_METAL_CAP) ~= 0 then
    set_mario_particle_flags(m, PARTICLE_SPARKLES, 0)
  end

  if ROMHACK.special_run ~= nil then
    ROMHACK.special_run(m,gotStar)
  end

  -- set descriptions
  local color = {r = 255, g = 92, b = 92}
  if sMario.team == 1 then
    color.g = 255
    if sMario.hard then
      color.r = 255
    else
      color.r = 0
      color.b = 255
    end
  end
  if gGlobalSyncTable.mhMode == 2 and frameCounter > 60 then
    network_player_set_description(np, trans_plural("stars",sMario.totalStars or 0), color.r, color.g, color.b, 255)
  elseif sMario.team == 1 then
    if frameCounter > 60 then
      network_player_set_description(np, trans("runner"), color.r, color.g, color.b, 255)
    else
      -- fix stupid desync bug
      if sMario.runnerLives == nil then
        sMario.runnerLives = gGlobalSyncTable.runnerLives
      elseif sMario.runnerLives < 0 then
        sMario.team = 0
      end
      network_player_set_description(np, trans_plural("lives",sMario.runnerLives), color.r, color.g, color.b, 255)
    end
  else
    network_player_set_description(np, trans("hunter"), color.r, color.g, color.b, 255)
  end

  -- keep player in certain levels
  if sMario.spectator ~= 1 then
    local correctAct = gGlobalSyncTable.getStar
    local area = 1
    if gGlobalSyncTable.ee then area = 2 end
    if correctAct == 7 then correctAct = 6 end
    if didFirstJoinStuff and ROMHACK ~= nil and m.playerIndex == 0 and gGlobalSyncTable.mhState == 0 and np.currLevelNum ~= gLevelValues.entryLevel then
      warp_beginning()
    elseif m.playerIndex == 0 and gGlobalSyncTable.mhState == 2 and gGlobalSyncTable.mhMode == 2 and (np.currLevelNum ~= gGlobalSyncTable.gameLevel or np.currActNum ~= correctAct) then
      m.health = 0x880
      warp_beginning()
    end
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
  if sMario.spectator ~= 1 and m.playerIndex == 0 and gGlobalSyncTable.starRun ~= -1 and ROMHACK.requirements ~= nil and gGlobalSyncTable.mhMode ~= 2 then
    local requirements = ROMHACK.requirements[np.currLevelNum] or 0
    if requirements >= gGlobalSyncTable.starRun then
      requirements = gGlobalSyncTable.starRun
      if ROMHACK.ddd and (np.currLevelNum == LEVEL_BITDW or np.currLevelNum == LEVEL_DDD) then
        requirements = requirements - 1
      end
    end
    if m.numStars < requirements then
      warp_beginning()
    end
  end

  -- hunter update
  if sMario.team ~= 1 then return hunter_update(m,sMario) end
  -- runner update
  return runner_update(m,sMario)
end

function runner_update(m,sMario)
  -- fix stupid desync bug
  if sMario.runnerLives == nil then
    sMario.runnerLives = gGlobalSyncTable.runnerLives
  elseif sMario.runnerLives < 0 then
    sMario.team = 0
  end
  local np = gNetworkPlayers[m.playerIndex]

  -- detect victory
  if m.playerIndex == 0 and gGlobalSyncTable.mhState < 3 and gGlobalSyncTable.mhMode ~= 2 and ROMHACK ~= nil and ROMHACK.runner_victory ~= nil and ROMHACK.runner_victory(m) and gGlobalSyncTable.mhState < 3 then
    network_send_include_self(true, {
      id = PACKET_GAME_END,
      winner = 1,
    })
    rejoin_timer = {}
    gGlobalSyncTable.mhState = 4
    localMHTimer = 20 * 30 -- 20 seconds
    gGlobalSyncTable.mhTimer = localMHTimer
  end

  if m.playerIndex == 0 then
    -- set 'been runner' status
    if sMario.beenRunner == 0 then
      print("Our 'Been Runner' status has been set")
      sMario.beenRunner = 1
      mod_storage_save("beenRunnner", "1")
    end

    -- reduce level timer
    if (not sMario.allowLeave) and gGlobalSyncTable.mhMode ~= 2 then
      if not gGlobalSyncTable.starMode then
        localRunTime = localRunTime + 1
      end

      -- match run time with other runners in level
      if frameCounter % 30 == 0 then -- only every second for less lag maybe
        for i=1,(MAX_PLAYERS-1) do
          if gPlayerSyncTable[i].team == 1 and gNetworkPlayers[i].connected then
            local theirNP = gNetworkPlayers[i] -- daft variable naming conventions
            local theirSMario = gPlayerSyncTable[i]
            if theirSMario.runTime ~= nil and (np.currLevelNum == theirNP.currLevelNum) and (np.currActNum == theirNP.currActNum) and localRunTime < theirSMario.runTime then
              localRunTime = theirSMario.runTime
              neededRunTime,localRunTime = calculate_leave_requirements(sMario,localRunTime)
            end
          end
        end
        sMario.runTime = localRunTime
      end
    elseif gGlobalSyncTable.mhMode == 2 and frameCounter % 60 == 0 then -- resend to avoid desync
      gGlobalSyncTable.gameLevel = gGlobalSyncTable.gameLevel
      gGlobalSyncTable.getStar = gGlobalSyncTable.getStar
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
    [ACT_STAR_DANCE_WATER] = 30, -- 1 second
    [ACT_WAITING_FOR_DIALOG] = 10,
    [ACT_DEATH_EXIT_LAND] = 10,
    [ACT_SPAWN_SPIN_LANDING] = 100,
    [ACT_SPAWN_NO_SPIN_LANDING] = 100,
    [ACT_IN_CANNON] = 10,
    [ACT_PICKING_UP] = 10, -- can't differentiate if this is a heavy object
  }
  local runner_camping = {
    [ACT_READING_NPC_DIALOG] = 1,
    [ACT_READING_AUTOMATIC_DIALOG] = 1,
    [ACT_WAITING_FOR_DIALOG] = 1,
    [ACT_STAR_DANCE_NO_EXIT] = 1,
    [ACT_STAR_DANCE_WATER] = 1,
    [ACT_READING_SIGN] = 1,
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
  if m.playerIndex == 0 and runner_camping[m.action] == nil and (m.freeze == false or (m.freeze ~= true and m.freeze < 1)) then
    campTimer = nil
  end

  -- reduces water heal and boosts invincibility frames after getting hit in water
  if (m.action & ACT_FLAG_SWIMMING) ~= 0 and m.healCounter <= 0 and m.hurtCounter <= 0 then
    if m.pos.y >= m.waterLevel - 140 and (m.area.terrainType & TERRAIN_MASK) ~= TERRAIN_SNOW then
      -- water heal is 26 (decimal) per frame
      m.health = m.health - 22
      if sMario.hard then m.health = m.health - 4 end -- no water heal in hard mode
    elseif m.prevAction == ACT_FORWARD_WATER_KB or m.prevAction == ACT_BACKWARD_WATER_KB then
      m.invincTimer = 60 -- 2 seconds
      m.prevAction = m.action
    elseif sMario.hard and frameCounter % 2 == 0 then -- half speed drowning
      m.health = m.health + 1 -- water drain is 1 (decimal) per frame
    end
  end

  -- hard mode
  if sMario.hard and m.health > 0x400 then
    m.health = 0x400
  end
  if (sMario.hard and sMario.runnerLives > 0) then sMario.runnerLives = 0 end

  -- add stars
  if gGlobalSyncTable.mhMode == 2 or m.prevNumStarsForDialog < m.numStars then
    if m.playerIndex == 0 and gotStar ~= nil then
      if gGlobalSyncTable.mhMode == 2 then
        if gotStar == gGlobalSyncTable.getStar then
          gGlobalSyncTable.votes = 0
          if gGlobalSyncTable.campaignCourse > 0 then
            gGlobalSyncTable.campaignCourse = gGlobalSyncTable.campaignCourse + 1
          end

          -- send message
          network_send_include_self(false, {
            id = PACKET_RUNNER_STAR,
            runnerID = np.globalIndex,
            star = gotStar,
            course = np.currCourseNum,
            area = np.currAreaIndex,
          })

          sMario.totalStars = sMario.totalStars + 1
          random_star(np.currCourseNum,gGlobalSyncTable.campaignCourse)
        end
      else
        if gGlobalSyncTable.starMode then
          localRunTime = localRunTime + 1 -- 1 star
        else
          localRunTime = localRunTime + 1800 -- 1 minute
        end
        neededRunTime,localRunTime = calculate_leave_requirements(sMario,localRunTime)
        -- send message
        network_send_include_self(false, {
          id = PACKET_RUNNER_STAR,
          runnerID = np.globalIndex,
          star = gotStar,
          course = np.currCourseNum,
          area = np.currAreaIndex,
        })
      end
    end

    m.prevNumStarsForDialog = m.numStars -- this also disables some dialogue, which helps with the fast pace
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
    m.marioBodyState.modelState = m.marioBodyState.modelState | MODEL_STATE_METAL
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
        if data.timer > 0 and data.runner then
          stillrunners = true
          break
        end
      end
      if stillrunners == false then
        network_send_include_self(true, {
          id = PACKET_GAME_END,
          winner = 0,
        })
        rejoin_timer = {}
        gGlobalSyncTable.mhState = 3
        localMHTimer = 20 * 30 -- 20 seconds
        gGlobalSyncTable.mhTimer = localMHTimer
      end
    end
  end
end

function before_set_mario_action(m, action)
  local sMario = gPlayerSyncTable[m.playerIndex]
  if action == ACT_EXIT_LAND_SAVE_DIALOG or action == ACT_DEATH_EXIT_LAND then
    m.area.camera.cutscene = 0
    set_camera_mode(m.area.camera, m.area.camera.defMode, 1)
    m.forwardVel = 0
    return ACT_IDLE
  elseif action == ACT_FALL_AFTER_STAR_GRAB then
    return ACT_STAR_DANCE_WATER
  elseif action == ACT_READING_SIGN and m.invincTimer > 0 then
    return 1
  end
  -- don't do the ending cutscene for hunters
  if action == ACT_JUMBO_STAR_CUTSCENE and sMario.team ~= 1 then
    m.flags = m.flags | MARIO_WING_CAP
    return 1
  end
end

-- disable some interactions
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
    elseif type == INTERACT_STAR_OR_KEY or banned_hunter[obj_id] ~= nil then
      if OmmEnabled and obj_id == id_bhvRedCoin then return true end -- to fix a bug, simply let hunters collect red coins
      return sMario.team == 1
    end
end
-- handle collecting stars
function on_interact(m, o, type, value)
  local obj_id = get_id_from_behavior(o.behavior)
  local sMario = gPlayerSyncTable[m.playerIndex]
  -- reverted red coins not healing
  --[[if obj_id == id_bhvRedCoin then
    m.healCounter = m.healCounter - 0x8 -- two units
  end
  if m.healCounter < 0 then m.healCounter = 0 end]]

  if type == INTERACT_STAR_OR_KEY then
    if (OmmEnabled and gServerSettings.stayInLevelAfterStar == 1) then
      m.invincTimer = 120
      if gGlobalSyncTable.weak then m.invincTimer = 240 end -- 4 seconds, even in weak mode
    end

    if m.playerIndex ~= 0 then return true end -- only local player

    if obj_id == id_bhvBowserKey then -- is a key
      sMario.allowLeave = true
      local np = gNetworkPlayers[m.playerIndex]

      -- send message
      network_send_include_self(false, {
        id = PACKET_RUNNER_STAR,
        runnerID = np.globalIndex,
        course = np.currCourseNum,
        area = np.currAreaIndex,
      })
    elseif obj_id ~= id_bhvGrandStar then -- this isn't a star, really
      gotStar = (o.oBehParams >> 24) + 1 -- set what star we got
    end
  end
  return true
end

-- FINALLY prevent chest answers from resetting (still a bit buggy but it's better)
function bhv_custom_chest_loop(obj)
  if obj.oTreasureChestIsLastInteractionIncorrect == 1 then
    obj.oTreasureChestIsLastInteractionIncorrect = 0
    obj.oTreasureChestCurrentAnswer = obj.unused1
  else
    obj.unused1 = obj.oTreasureChestCurrentAnswer
  end
end
function bhv_custom_chest_bottom_loop(obj)
  if obj.oAction == 2 then
    if obj.oPrevAction == 1 then
      cur_obj_change_action(1)
    elseif obj.oTimer > 100 then
      cur_obj_change_action(0)
    end
  end
end
id_bhvTreasureChestsJrb = hook_behavior(id_bhvTreasureChestsJrb, OBJ_LIST_DEFAULT, false, nil, bhv_custom_chest_loop, "bhvTreasureChestsJrb")
id_bhvTreasureChestsShip = hook_behavior(id_bhvTreasureChestsShip, OBJ_LIST_DEFAULT, false, nil, bhv_custom_chest_loop, "bhvTreasureChestsShip")
id_bhvTreasureChests = hook_behavior(id_bhvTreasureChests, OBJ_LIST_DEFAULT, false, nil, bhv_custom_chest_loop, "bhvTreasureChests")
id_bhvTreasureChestBottom = hook_behavior(id_bhvTreasureChestBottom, OBJ_LIST_DEFAULT, false, nil, bhv_custom_chest_bottom_loop, "bhvTreasureChestBottom")

-- Replace all Hearts with 1Ups
function bhv_replace_with_1up(o)
  if ROMHACK.ddd then -- only in vanilla because hacks require the use of hearts
    spawn_non_sync_object(
    id_bhv1Up,
    E_MODEL_1UP,
    o.oPosX, o.oPosY, o.oPosZ,
    nil)
    obj_mark_for_deletion(o)
  end
end
id_bhvRecoveryHeart = hook_behavior(id_bhvRecoveryHeart, OBJ_LIST_LEVEL, false, bhv_replace_with_1up, nil, "bhvRecoveryHeart")

-- stars to track (replicas and such are in romhack_data)
star_ids = {
  [id_bhvStar] = "bhvStar",
  [id_bhvSpawnedStar] = "bhvSpawnedStar",
  [id_bhvSpawnedStarNoLevelExit] = "bhvSpawnedStarNoLevelExit",
  [id_bhvStarSpawnCoordinates] = "bhvStarSpawnCoordinates",
}
-- thank you sunk
exclamation_box_valid = {
  [8] = true,
  [10] = true,
  [11] = true,
  [12] = true,
  [13] = true,
  [14] = true
}

-- hard mode
function hard_mode_command(msg)
  if string.lower(msg) == "on" then
    gPlayerSyncTable[0].hard = true
    play_sound(SOUND_OBJ_BOWSER_LAUGH, gMarioStates[0].marioObj.header.gfx.cameraToObject)
    djui_chat_message_create(trans("hard_on"))
    if gGlobalSyncTable.mhState ~= 2 then
      inHard = true
    elseif not inHard then
      djui_chat_message_create(trans("no_hard_win"))
    end
  elseif string.lower(msg) == "off" then
    gPlayerSyncTable[0].hard = false
    inHard = false
    djui_chat_message_create(trans("hard_off"))
  else
    djui_chat_message_create(trans("hard_info"))
  end
  return true
end
hook_chat_command("hard","[ON|OFF] - Toggle hard mode for runners", hard_mode_command)

-- disable bowser bomb softlock
function on_object_unload(o)
  if obj_has_behavior_id(o, id_bhvBowserBomb) == 1 then
    local bomb = obj_get_first_with_behavior_id(id_bhvBowserBomb)
    if bomb == nil and is_nearest_mario_state_to_object(gMarioStates[0], o) ~= 0 then
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
  if sMario.pause
  or (gGlobalSyncTable.mhState == 1
  and sMario.spectator ~= 1 and (sMario.team ~= 1 or localMHTimer > 10 * 30)) then -- runners get 10 second head start
    if not paused then
      djui_popup_create(trans("paused"), 1)
      paused = true
    end

    enable_time_stop_including_mario()
    if localMHTimer > 0 then
      m.health = 0x880
    end
  elseif paused then
    djui_popup_create(trans("unpaused"), 1)
    m.invincTimer = 60 -- 1 second
    paused = false
    disable_time_stop_including_mario()
    print("disabled pause")
  end
end

function rom_hack_command(msg)
  gGlobalSyncTable.romhackFile = msg
  return true
end

-- chat related stuff
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
  if _G.mhApi.chatValidFunction ~= nil and (_G.mhApi.chatValidFunction(gMarioStates[0], msg) == false) then
    return false
  end

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
function on_packet_tc(data,self)
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
      play_sound(SOUND_MENU_MESSAGE_APPEAR, m.marioObj.header.gfx.cameraToObject)
    end
  end
end
function on_chat_message(m, msg)
  if _G.mhApi.chatValidFunction ~= nil and (_G.mhApi.chatValidFunction(m, msg) == false) then
    return false
  end

  local sMario = gPlayerSyncTable[m.playerIndex]
  if sMario.teamChat == true then
    if m.playerIndex == 0 then
      send_tc(msg)
    end
    return false
  elseif m.playerIndex == 0 then
    local testmsg = string.lower(msg)
    local testmsg2 = testmsg
    local testmsg3 = testmsg
    testmsg = string.gsub(testmsg,"como hac","") -- start of "how do..."; hopefully this catches all verb forms
    testmsg = string.gsub(testmsg,"how do","")
    testmsg = string.gsub(testmsg,"collect star","")
    testmsg2 = string.gsub(testmsg2,"ingl","") -- for spanish speakers asking if this is an english (inglés) server; covers both with and without accent
    testmsg3 = string.gsub(testmsg3,"impossible","")
    if testmsg ~= string.lower(msg) then
      djui_popup_create(trans("rule_command"), 1)
    end
    if testmsg2 ~= string.lower(msg) then
      djui_popup_create(trans("to_switch",lang_list,nil,"es"), 1)
    end
    if testmsg3 ~= string.lower(msg) and gGlobalSyncTable.mhMode == 2 then
      djui_popup_create(trans("vote_info"), 1)
    end
  end
  if sMario.placement ~= nil and sMario.placement <= 10 then
    local np = gNetworkPlayers[m.playerIndex]
    local playerColor = network_get_player_text_color_string(m.playerIndex)
    local name = playerColor .. np.name

    local placestring = ""
    if sMario.placement <= 3 then
      placestring = trans("place_"..sMario.placement)
    else
      placestring = trans("place",sMario.placement)
    end
    djui_chat_message_create(name.." "..placestring..": \\#dcdcdc\\"..msg)

    if m.playerIndex == 0 then
      play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, m.marioObj.header.gfx.cameraToObject)
    else
      local myM = gMarioStates[0]
      play_sound(SOUND_MENU_MESSAGE_APPEAR, myM.marioObj.header.gfx.cameraToObject)
    end
    return false
  end
end
hook_chat_command("tc", "[ON|OFF|MSG] - Send message to team only; turn ON to apply to all messages", tc_command)
hook_event(HOOK_ON_CHAT_MESSAGE, on_chat_message)

-- stats
function stats_command(msg)
  if not is_game_paused() then
    showingStats = not showingStats
  end
  return true
end
hook_chat_command("stats", "- Show/hide stat table", stats_command)

-- speedrun timer
showSpeedrunTimer = true -- show speedrun timer
if mod_storage_load("showSpeedrunTimer") == "false" then
  showSpeedrunTimer = false
end
function show_timer(msg)
  if string.lower(msg) == "on" then
    showSpeedrunTimer = true
    mod_storage_save("showSpeedrunTimer","true")
    return true
  elseif string.lower(msg) == "off" then
    showSpeedrunTimer = false
    mod_storage_save("showSpeedrunTimer","false")
    return true
  end
  return false
end
hook_chat_command("timer", "- Show/hide speedrun timer", show_timer)

-- for Ztar Attack 2
function stalk_command(msg,noFeedback)
  local m = gMarioStates[0]
  local sMario = gPlayerSyncTable[0]
  if gGlobalSyncTable.mhMode == 2 then
    if not noFeedback then djui_chat_message_create(trans("wrong_mode")) end
    return true
  elseif (ROMHACK == nil or ROMHACK.stalk == nil) then
    if not noFeedback then djui_chat_message_create(trans("wrong_mode")) end
    return true
  elseif gGlobalSyncTable.mhState ~= 2 then
    if not noFeedback then djui_chat_message_create(trans("not_started")) end
    return true
  end

  local playerID,np = nil
  if msg == "" then
    for i=1,(MAX_PLAYERS-1) do
      local sMario = gPlayerSyncTable[i]
      if sMario.team == 1 then
        playerID = i
        np = gNetworkPlayers[i]
        break
      end
    end
    if playerID == nil then
      if not noFeedback then djui_chat_message_create(trans("no_runners")) end
      return true
    end
  else
    playerID,np = get_specified_player(msg)
  end

  if playerID == 0 then
    return false
  elseif playerID == nil then
    return true
  end

  local theirSMario = gPlayerSyncTable[playerID]
  if sMario.placement ~= 0 and theirSMario.team ~= 1 then
    local name = remove_color(np.name)
    djui_chat_message_create(trans("not_runner",name))
    return true
  end

  local myNP = gNetworkPlayers[0]
  if obj_get_first_with_behavior_id(id_bhvActSelector) == nil and (np.currLevelNum ~= myNP.currLevelNum or np.currAreaIndex ~= myNP.currAreaIndex or np.currActNum ~= myNP.currActNum) then
    warp_to_level(np.currLevelNum, np.currAreaIndex, np.currActNum)
  end
  return true
end
hook_chat_command("stalk","[NAME|ID] - Warps to the level the specified player is in, or the first Runner; only some rom hacks",stalk_command)

function on_course_enter()
  prevCoins = 0
  local sMario = gPlayerSyncTable[0]
  attackedBy = nil
  if sMario.team == 1 and gGlobalSyncTable.mhMode ~= 2 then
    sMario.runTime = 0
    localRunTime = 0
    sMario.allowLeave = false
    neededRunTime,localRunTime = calculate_leave_requirements(sMario,0)
  end

  -- justEntered = true

  if gGlobalSyncTable.romhackFile == "vanilla" then
    omm_replace(OmmEnabled)
  end
  if gGlobalSyncTable.mhState == 0 then -- and background music
     set_background_music(0,0x41,0)
     --play_music(0, 0x41, 1)
  end
  if gGlobalSyncTable.mhMode == 2 then -- unlock cannon and caps in minihunt
    local file = get_current_save_file_num() - 1
    local np = gNetworkPlayers[0]
    save_file_set_flags(SAVE_FLAG_HAVE_METAL_CAP)
    save_file_set_flags(SAVE_FLAG_HAVE_VANISH_CAP)
    save_file_set_flags(SAVE_FLAG_HAVE_WING_CAP)
    save_file_set_star_flags(file, np.currCourseNum, save_file_get_star_flags(file, np.currCourseNum) | 0x80)
  end
end

function on_packet_runner_star(data,self)
  runnerID = data.runnerID
  if runnerID ~= nil then
    local np = network_player_from_global_index(runnerID)
    local playerColor = network_get_player_text_color_string(np.localIndex)
    local place = get_level_name(data.course, course_to_level[data.course], data.area)
    if data.star ~= nil then
      if gGlobalSyncTable.mhMode == 2 or not (OmmEnabled and gServerSettings.stayInLevelAfterStar == 1) then -- OMM shows its own progress, so don't show this
        local name = get_custom_star_name(data.course, data.star)
        djui_popup_create(trans("got_star",(playerColor .. np.name)) .. "\\#ffffff\\\n" .. place .. "\n" .. name, 2)
      end
    else
      djui_popup_create(trans("got_key",(playerColor .. np.name)) .. "\\#ffffff\\\n" .. place, 2)
    end
  end
end

function on_packet_kill(data,self)
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
        m.healCounter = 0x32 -- full health
        m.hurtCounter = 0x0
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
        if killCombo > 1 then
          network_send_include_self(false, {
            id = PACKET_KILL_COMBO,
            name = kPlayerColor .. killerNP.name,
            kills = killCombo,
          })
        end
        if gGlobalSyncTable.mhState ~= 0 then
          local maxStreak = tonumber(mod_storage_load("maxStreak"))
          if maxStreak == nil or killCombo > maxStreak then
            mod_storage_save("maxStreak",tostring(math.floor(killCombo)))
            kSMario.maxStreak = killCombo
          end
        end
        killTimer = 300 -- 10 seconds
      elseif data.runner then -- play sound if runner dies
        play_sound(SOUND_OBJ_BOWSER_LAUGH, m.marioObj.header.gfx.cameraToObject)
      end

      -- sidelined if this was their last life
      if data.death ~= true then
        djui_popup_create(trans("killed",(kPlayerColor .. killerNP.name),(playerColor .. np.name)), 1)
      else
        djui_popup_create(trans("sidelined",(kPlayerColor .. killerNP.name),(playerColor .. np.name)), 1)
      end
    else
      if data.death ~= true then -- runner only lost one life
        djui_popup_create(trans("lost_life",(playerColor .. np.name)), 1)
      else -- runner lost all lives
        djui_popup_create(trans("lost_all",(playerColor .. np.name)), 1)
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
    djui_popup_create(trans("now_runner",(playerColor .. np.name)), 1)
    if np.localIndex == 0 then
      localRunTime = data.time or 0
      neededRunTime,localRunTime = calculate_leave_requirements(sMario,localRunTime)
      play_sound(SOUND_GENERAL_SHORT_STAR, m.marioObj.header.gfx.cameraToObject)
      print("new time:",data.time)
    end
  end

  _G.mhApi.onKill(killer,killed,data.runner,data.death,data.time,newRunnerID)
end

-- part of the API
function get_kill_combo()
  return killCombo
end

function on_game_end(data)
  if gGlobalSyncTable.mhMode == 2 and data.winner ~= -1 then
    play_race_fanfare()
    local winCount = 1
    local winners = {}
    local weWon = true
    for i=0,(MAX_PLAYERS-1) do
      local sMario = gPlayerSyncTable[i]
      local np = gNetworkPlayers[i]

      if i == 0 then
        local maxStar = tonumber(mod_storage_load("maxStar"))
        if maxStar == nil then
          maxStar = 0
        end
        if sMario.totalStars > maxStar then
          mod_storage_save("maxStar",tostring(sMario.totalStars))
          sMario.maxStar = sMario.totalStars
        end
      end

      if np.connected and sMario.totalStars ~= nil and sMario.totalStars >= winCount then
        local playerColor = network_get_player_text_color_string(np.localIndex)
        local name = playerColor .. np.name
        if sMario.totalStars == winCount then
          table.insert(winners, name)
        else
          winners = {name}
          winCount = sMario.totalStars
          if i ~= 0 then weWon = false end
        end
      end
    end
    if #winners > 0 then
      djui_chat_message_create(trans("winners"))
      for i,name in ipairs(winners) do
        djui_chat_message_create(name)
      end
      if weWon then
        local sMario = gPlayerSyncTable[0]
        add_win(sMario)
      end
    else
      djui_chat_message_create(trans("no_winners"))
    end
  elseif data.winner == 1 then
    play_star_fanfare()
    local sMario = gPlayerSyncTable[0]
    if sMario.team == 1 then
      add_win(sMario)
    end
  else
    play_dialog_sound(21) -- bowser intro
    --play_secondary_music(SEQ_EVENT_KOOPA_MESSAGE, 0, 80, 60)
  end
end

function on_packet_stats(data,self)
  djui_chat_message_create(trans_plural(data.stat,data.name,data.value))
end

function add_win(sMario)
  if network_player_connected_count() <= 1 then return end -- don't increment wins in solo
  if inHard then
    local hardWins = tonumber(mod_storage_load("hardWins"))
    if hardWins == nil then
      hardWins = 0
    end
    mod_storage_save("hardWins",tostring(math.floor(hardWins)+1))
    sMario.hardWins = sMario.hardWins + 1
  else
    local wins = tonumber(mod_storage_load("wins"))
    if wins == nil then
      wins = 0
    end
    mod_storage_save("wins",tostring(math.floor(wins)+1))
    sMario.wins = sMario.wins + 1
  end
end

function on_packet_kill_combo(data,self)
  if data.kills > 5 then
    local m = gMarioStates[0]
    djui_popup_create(trans("kill_combo_large",data.name,data.kills), 1)
    play_sound(SOUND_MARIO_YAHOO_WAHA_YIPPEE, m.marioObj.header.gfx.cameraToObject)
  else
    djui_popup_create(trans("kill_combo_"..tostring(data.kills),data.name), 1)
  end
end

-- vote skip
iVoted = false
function skip_command(msg)
  if gGlobalSyncTable.mhMode ~= 2 then
    djui_chat_message_create(trans("wrong_mode"))
    return true
  elseif gGlobalSyncTable.mhState ~= 2 then
    djui_chat_message_create(trans("not_started"))
    return true
  elseif iVoted then
    djui_chat_message_create(trans("already_voted"))
    return true
  end

  local np = gNetworkPlayers[0]
  local playercolor = network_get_player_text_color_string(0)
  gGlobalSyncTable.votes = gGlobalSyncTable.votes + 1
  iVoted = true
  network_send_include_self(true, {
    id = PACKET_VOTE,
    votes = gGlobalSyncTable.votes,
    voted = playercolor..np.name,
  })
  return true
end
hook_chat_command("skip","- Vote to skip this star; MiniHunt only",skip_command)
function on_packet_vote(data,self)
  local count = network_player_connected_count()
  local maxVotes = count
  if count > 2 then
    maxVotes = math.ceil(count/2) -- half the lobby
  elseif count == 1 then
    iVoted = false
    local np = gNetworkPlayers[0]
    if gGlobalSyncTable.campaignCourse ~= 0 then
      gGlobalSyncTable.campaignCourse = gGlobalSyncTable.campaignCourse + 1
    end
    random_star(np.currCourseNum,gGlobalSyncTable.campaignCourse)
    gGlobalSyncTable.votes = 0
    return
  end

  djui_chat_message_create(string.format("%s (%d/%d)",trans("vote_skip",data.voted),data.votes,maxVotes))
  if maxVotes <= data.votes then
    djui_chat_message_create(trans("vote_pass"))
    iVoted = false
    if self == true then
      local np = gNetworkPlayers[0]
      if gGlobalSyncTable.campaignCourse ~= 0 then
        gGlobalSyncTable.campaignCourse = gGlobalSyncTable.campaignCourse + 1
      end
      random_star(np.currCourseNum,gGlobalSyncTable.campaignCourse)
      gGlobalSyncTable.votes = 0
    end
  else
    djui_chat_message_create(trans("vote_info"))
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
PACKET_VOTE = 7
sPacketTable = {
    [PACKET_RUNNER_STAR] = on_packet_runner_star,
    [PACKET_KILL] = on_packet_kill,
    [PACKET_MH_START] = do_game_start,
    [PACKET_TC] = on_packet_tc,
    [PACKET_GAME_END] = on_game_end,
    [PACKET_STATS] = on_packet_stats,
    [PACKET_KILL_COMBO] = on_packet_kill_combo,
    [PACKET_VOTE] = on_packet_vote,
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
        djui_popup_create(trans("vanilla"), 1)
      end
    end
end

-- display the change in mode
function on_mode_changed(tag, oldVal, newVal)
    if oldVal ~= nil and oldVal ~= newVal then
      if newVal == 0 then
        if network_is_server() and gameAuto ~= 0 then
          gameAuto = 0
          if gGlobalSyncTable.mhState == 0 then
            localMHTimer = -1
            gGlobalSyncTable.mhTimer = -1
          end
          djui_chat_message_create(trans("auto_off"))
        end
        if gGlobalSyncTable.mhState == 2 then
          localMHTimer = -1
          gGlobalSyncTable.mhTimer = -1
        end
        djui_popup_create(trans("mode_normal"), 1)
      elseif newVal == 1 then
        if network_is_server() and gameAuto ~= 0 then
          gameAuto = 0
          if gGlobalSyncTable.mhState == 0 then
            localMHTimer = -1
            gGlobalSyncTable.mhTimer = -1
          end
          djui_chat_message_create(trans("auto_off"))
        end
        if gGlobalSyncTable.mhState == 2 then
          localMHTimer = -1
          gGlobalSyncTable.mhTimer = -1
        end
        djui_popup_create(trans("mode_switch"), 1)
      else
        djui_popup_create(trans("mode_mini"), 1)
      end
    end
end

-- starts background music again in state 0
function on_state_changed(tag, oldVal, newVal)
  if oldVal ~= newVal and newVal == 0 then
    set_background_music(0,0x41,0)
  end
end

-- updates local timers for all players
function timer_update(tag, oldVal, newVal)
    localMHTimer = newVal
end

-- main command
hook_chat_command("mh", "[COMMAND] - Commands for MarioHunt; type nothing or a number to list; host or moderator only", mario_hunt_command)
function setup_commands()
  -- commands for main command
  marioHuntCommands = {}
  -- format is: command, alias, function, debug
  table.insert(marioHuntCommands, {"start", nil, start_game_command})
  table.insert(marioHuntCommands, {"add", "addrunner", add_runner_command})
  table.insert(marioHuntCommands, {"random", "randomize", randomize_command})
  table.insert(marioHuntCommands, {"lives", "runnerlives", runner_lives_command})
  table.insert(marioHuntCommands, {"time", "timeneeded", time_needed_command})
  table.insert(marioHuntCommands, {"stars", "starsneeded", stars_needed_command})
  table.insert(marioHuntCommands, {"category", "starrun", star_count_command})
  table.insert(marioHuntCommands, {"flip", "changeteam", change_team_command})
  table.insert(marioHuntCommands, {"setlife", nil, set_life_command})
  table.insert(marioHuntCommands, {"leave", "allowleave", allow_leave_command})
  table.insert(marioHuntCommands, {"mode", nil, mode_command})
  table.insert(marioHuntCommands, {"starmode", nil, star_mode_command})
  table.insert(marioHuntCommands, {"spectator", nil, allow_spectate_command})
  table.insert(marioHuntCommands, {"pause", "freeze", pause_command})
  table.insert(marioHuntCommands, {"metal", "seeker", metal_command})
  table.insert(marioHuntCommands, {"hack", "romhack", rom_hack_command})
  table.insert(marioHuntCommands, {"weak", nil, weak_command})
  table.insert(marioHuntCommands, {"auto", nil, auto_command})
  table.insert(marioHuntCommands, {"forcespectate", nil, force_spectate_command})
  table.insert(marioHuntCommands, {"desync", nil, desync_fix_command})
  table.insert(marioHuntCommands, {"stop", "halt", halt_command})
  table.insert(marioHuntCommands, {"default", nil, default_settings})

  -- debug
  table.insert(marioHuntCommands, {"print", nil, print, true})
  table.insert(marioHuntCommands, {"warp", nil, do_warp, true})
  table.insert(marioHuntCommands, {"quick", nil, quick_debug, true})
  table.insert(marioHuntCommands, {"combo", nil, combo_debug, true})
  table.insert(marioHuntCommands, {"field", nil, get_field,true})
  table.insert(marioHuntCommands, {"allstars", nil, get_all_stars, true})
  table.insert(marioHuntCommands, {"langtest", nil, lang_test, true})
end

-- hooks
hook_event(HOOK_UPDATE, update)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_BEFORE_MARIO_UPDATE, camp_timer)
hook_event(HOOK_BEFORE_SET_MARIO_ACTION, before_set_mario_action)
hook_event(HOOK_ALLOW_PVP_ATTACK, allow_pvp_attack)
hook_event(HOOK_ON_PVP_ATTACK, on_pvp_attack)
hook_event(HOOK_ON_PLAYER_DISCONNECTED, on_player_disconnected)
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
hook_event(HOOK_ON_PAUSE_EXIT, on_pause_exit)
hook_event(HOOK_ON_LEVEL_INIT, on_course_enter)
hook_event(HOOK_ON_SYNC_VALID, on_course_sync)
hook_event(HOOK_ON_PACKET_RECEIVE, on_packet_receive)
hook_event(HOOK_ON_DEATH, on_death)
hook_event(HOOK_ALLOW_INTERACT, on_allow_interact)
hook_event(HOOK_ON_INTERACT, on_interact)
hook_event(HOOK_ON_OBJECT_UNLOAD, on_object_unload)
hook_on_sync_table_change(gGlobalSyncTable, "romhackFile", "change_hack", on_rom_hack_changed)
hook_on_sync_table_change(gGlobalSyncTable, "mhMode", "change_mode", on_mode_changed)
hook_on_sync_table_change(gGlobalSyncTable, "mhTimer", "timer_update", timer_update)
hook_on_sync_table_change(gGlobalSyncTable, "mhState", "change_state", on_state_changed)

-- prevent constant error stream
if trans == nil then
trans = function(id,format1,format2_,lang)
  return "LANGUAGE MODULE DID NOT LOAD"
end
trans_plural = trans
end
