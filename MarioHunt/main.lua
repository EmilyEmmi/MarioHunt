-- name: .\\#00ffff\\Mario\\#ff5a5a\\Hun\\\\t (v2.2)\\#dcdcdc\\
-- incompatible: gamemode
-- description: A gamemode based off of Beyond's concept.\n\nHunters stop Runners from clearing the game!\n\nProgramming by EmilyEmmi, TroopaParaKoopa, Blocky, Sunk, and Sprinter05.\n\nSpanish Translation made with help from KanHeaven and SonicDark.\nGerman Translation made by N64 Mario.\nBrazillian Portuguese translation made by PietroM.\nFrench translation made by Skeltan.\n\n\"Shooting Star Summit\" port by pieordie1

menu = false
mhHideHud = false

-- this reduces lag apparently
local djui_chat_message_create,djui_popup_create,djui_hud_measure_text,djui_hud_print_text,djui_hud_set_color,djui_hud_set_font,djui_hud_set_resolution,network_player_set_description,network_get_player_text_color_string,network_is_server,is_game_paused,get_current_save_file_num,save_file_get_course_star_count,save_file_get_star_flags,save_file_get_flags,djui_hud_render_rect,warp_to_level,mod_storage_save,mod_storage_load = djui_chat_message_create,djui_popup_create,djui_hud_measure_text,djui_hud_print_text,djui_hud_set_color,djui_hud_set_font,djui_hud_set_resolution,network_player_set_description,network_get_player_text_color_string,network_is_server,is_game_paused,get_current_save_file_num,save_file_get_course_star_count,save_file_get_star_flags,save_file_get_flags,djui_hud_render_rect,warp_to_level,mod_storage_save_fix_bug,mod_storage_load

-- TroopaParaKoopa's pause mod
gGlobalSyncTable.pause = false

-- TroopaParaKoopa's hns metal cap option
gGlobalSyncTable.metal = false

local rejoin_timer = {} -- rejoin timer for runners (IsHost only)
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
  gGlobalSyncTable.blacklistData = "none" -- encrypted data for blacklist
  gGlobalSyncTable.campaignCourse = 0 -- campaign course for minihunt (64 tour)
  gGlobalSyncTable.gameAuto = 0 -- automatically start new games

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
  gGlobalSyncTable.mhTimer = 0 -- timer in frames (game is 30 FPS)
  gGlobalSyncTable.speedrunTimer = 0 -- the total amount of time we've played in frames
  gGlobalSyncTable.gameLevel = 0 -- level for MiniHunt
  gGlobalSyncTable.getStar = 0 -- what star must be collected (for MiniHunt)
  gGlobalSyncTable.votes = 0 -- amount of votes for skipping (MiniHunt)
  gGlobalSyncTable.otherSave = false -- using other save file
  gGlobalSyncTable.bowserBeaten = false -- used for some rom hacks as a two-part completion process
  gGlobalSyncTable.ee = false -- used for SM74
  gGlobalSyncTable.forceSpectate = false -- force all players to spectate unless otherwise stated
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
frameCounter = 120 -- frame counter over 4 seconds
local cooldownCaps = 0 -- stores m.flags, to see what caps are on cooldown
local regainCapTimer = 0 -- timer for being able to recollect a cap
local campTimer -- for camping actions (such as reading text or being in the star menu), nil means it is inactive
warpCooldown = 0 -- to avoid warp spam
warpCount = 0
local killTimer = 0 -- timer for kills in quick succession
local killCombo = 0 -- kills in quick succession
local hitTimer = 0 -- timer for being hit by another player
local localRunTime = 0 -- our run time is usually made local for less lag
local neededRunTime = 0 -- how long we need to wait to leave this course
local inHard = 0 -- what hard mode we started in (to prevent cheesy hard/extreme mode wins)
local deathTimer = 900 -- for extreme mode
OmmEnabled = false -- is true if using OMM Rebirth
local prevCoins = 0 -- highest coin count (OMM Rebirth)

-- Converts string into a table using a determiner (but stop splitting after a certain amount)
function split(s, delimiter, limit_)
    local limit = limit_ or 999
    local result = {}
    local finalmatch = ""
    local i = 0
    for match in (s):gmatch(string.format("[^%s]+", delimiter)) do
        --djui_chat_message_create(match)
        i = i + 1
        if i >= limit then
          finalmatch = finalmatch .. match .. delimiter
        else
          table.insert(result, match)
        end
    end
    if i >= limit then
      finalmatch = string.sub(finalmatch,1,string.len(finalmatch)-string.len(delimiter))
      table.insert(result, finalmatch)
    end
    return result
end

-- handle game starting (all players)
function do_game_start(data,self)
  save_settings()
  omm_disable_non_stop_mode(gGlobalSyncTable.mhMode == 2) -- change non stop mode setting for minihunt
  menu = false
  showingStats = false
  local msg = data.cmd or ""

  if gGlobalSyncTable.mhMode == 2 then
    gGlobalSyncTable.mhState = 2

    if string.lower(msg) ~= "continue" then
      gGlobalSyncTable.mhTimer = gGlobalSyncTable.runTime or 0
    end
  elseif string.lower(msg) ~= "continue" then
    deathTimer = 1830 -- start with 60 seconds
    gGlobalSyncTable.mhState = 1
    gGlobalSyncTable.mhTimer = 15 * 30 -- 15 seconds
  else
    deathTimer = 900 -- start with 30 seconds
    gGlobalSyncTable.mhState = 2
    gGlobalSyncTable.mhTimer = 0
  end

  if network_is_server() and gGlobalSyncTable.mhMode == 2 then
    if tonumber(msg) ~= nil and tonumber(msg) > 0 and (tonumber(msg) % 1 == 0) then
      gGlobalSyncTable.campaignCourse = tonumber(msg)
    else
      gGlobalSyncTable.campaignCourse = 0
    end
    random_star(nil,gGlobalSyncTable.campaignCourse)
  end

  if string.lower(msg) ~= "continue" then
    local m = gMarioStates[0]
    m.health = 0x880
    SVcln = nil

    gGlobalSyncTable.votes = 0
    iVoted = false
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
    inHard = sMario.hard or 0
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
function omm_allow_attack(index,setting) -- this only works when deleting omm-gamemode.lua (I was told this would be changed next OMM update)
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
--- @param obj Object
function omm_object_interact(m,cappy,obj) -- for the 1up and nothing else
  if get_id_from_behavior(obj.behavior) == id_bhvHidden1upInPole then
    on_interact(m, obj, obj.oInteractType, 0)
  end
end
-- sadly this no longer works (while I CAN force the value, it prevents it from being changed)
function hide_both_hud(hide)
  if hide then
    hud_hide()
  else
    hud_show()
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
    if gGlobalSyncTable.starMode or ROMHACK.isUnder then return -1,0 end -- impossible to leave in star mode
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
    if #valid_star_table < 1 then
      valid_star_table = generate_star_table(prevCourse,false,replicas,gGlobalSyncTable.getStar)
      if #valid_star_table < 1 then
        global_popup_lang("no_valid_star", nil, nil, 1)
        gGlobalSyncTable.mhTimer = 1 -- end game
        return
      end
      selectedStar = valid_star_table[math.random(1, #valid_star_table)]
    else
      selectedStar = valid_star_table[math.random(1, #valid_star_table)]
    end
  end

  gGlobalSyncTable.getStar = selectedStar % 10
  gGlobalSyncTable.gameLevel = course_to_level[selectedStar // 10]
  print("Selected",gGlobalSyncTable.gameLevel,gGlobalSyncTable.getStar)
end

-- generate table of valid stars
function generate_star_table(exCourse,standard,replicas,recentAct)
  local valid_star_table = {}
  for course,level in pairs(course_to_level) do
    if course ~= exCourse or recentAct ~= nil then
      for act=1,7 do
        if recentAct ~= act and valid_star(course,act,standard,replicas) then
          table.insert(valid_star_table, course * 10 + act)
        end
      end
    end
  end
  return valid_star_table
end

-- gets if the star is valid for minihunt
function valid_star(course,act,standard,replicas)
  if course < 0 or course > 25 or (course % 1 ~= 0) then return false end

  if (standard or (course ~= 0 and course ~= 25 and (ROMHACK.hubStages == nil or ROMHACK.hubStages[course] == nil))) then
    local level = course_to_level[course]
    local starMax = (standard and 7) or 6
    if course == 25 and ROMHACK.starCount[level] == nil then
      return false
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
        if starNum ~= 0 and starNum == act and (standard or mini_blacklist == nil or mini_blacklist[course * 10 + act] == nil) then
          return true
        end
      end
      return false
    else
      return false
    end
  end
  return false
end

function on_pause_exit(exitToCastle)
  local m = gMarioStates[0]
  local sMario = gPlayerSyncTable[0]
  if m.health <= 0xFF then return false end
  if sMario.spectator == 1 then return false end
  if gGlobalSyncTable.mhMode == 2 then
    if m.invincTimer <= 0 and (m.action & ACT_FLAG_AIR) == 0 then
      warp_beginning()
    end
    return false
  end
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
    gLevelValues.disableActs = disable
    return _G.OmmApi.omm_disable_feature("trueNonStop", disable)
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

  -- handle timers
  if not gGlobalSyncTable.pause then
    if frameCounter < 1 then
      frameCounter = 121
    end
    frameCounter = frameCounter - 1

    if network_is_server() and didFirstJoinStuff then
      if gGlobalSyncTable.mhTimer > 0 then
        gGlobalSyncTable.mhTimer = gGlobalSyncTable.mhTimer - 1
        if gGlobalSyncTable.mhTimer == 0 then
          if gGlobalSyncTable.mhState == 1 then
            gGlobalSyncTable.mhState = 2
          elseif gGlobalSyncTable.mhState >= 3 or gGlobalSyncTable.mhState == 0 then
            if gGlobalSyncTable.gameAuto ~= 0 then
              print("New game started")

              runner_randomize(gGlobalSyncTable.gameAuto)
              if gGlobalSyncTable.campaignCourse > 0 then
                start_game("1") -- stay in campaign mode
              else
                start_game("")
              end
              if gGlobalSyncTable.mhTimer == 0 then
                gGlobalSyncTable.mhTimer = 20 * 30 -- 20 seconds (in case start doesnt work)
              end
            else
              gGlobalSyncTable.mhState = 0
            end
          else
            gGlobalSyncTable.mhState = 5
            network_send_include_self(true, {
              id = PACKET_GAME_END,
            })
            gGlobalSyncTable.mhTimer = 20 * 30 -- 20 seconds
          end
        end
      end

      if gGlobalSyncTable.mhMode ~= 2 and (gGlobalSyncTable.mhState ~= 0 and (gGlobalSyncTable.mhState == 2 or (gGlobalSyncTable.mhState < 3 and gGlobalSyncTable.mhTimer < 300))) then
        gGlobalSyncTable.speedrunTimer = gGlobalSyncTable.speedrunTimer + 1
      end

      for id,data in pairs(rejoin_timer) do
        data.timer = data.timer - 1
        if data.timer <= 0 then
          global_popup_lang("rejoin_fail", data.name, nil, 1)
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
      _G.OmmApi.omm_resolve_cappy_object_interaction = omm_object_interact
      _G.OmmApi.omm_disable_feature("lostCoins",true)
      _G.OmmApi.omm_force_setting_value("player",2)
      _G.OmmApi.omm_force_setting_value("damage",20)
      _G.OmmApi.omm_force_setting_value("bubble",0)
    end
    if gGlobalSyncTable.romhackFile == "vanilla" then
      omm_replace(OmmEnabled)
    end

    setup_hack_data(network_is_server(), true, OmmEnabled)
    if network_is_server() then
      load_settings()

      local fileName = string.gsub(gGlobalSyncTable.romhackFile," ","_")
      local option = mod_storage_load(fileName.."_black") or "none"
      gGlobalSyncTable.blacklistData = option
      setup_mini_blacklist(option)

      if gGlobalSyncTable.gameAuto ~= 0 then
        gGlobalSyncTable.mhTimer = 20*30
      end
      menu = true
    else
      show_rules()
      djui_chat_message_create(trans("to_switch",lang_list))

      setup_mini_blacklist(gGlobalSyncTable.blacklistData)
    end
    menu_reload()
    action_setup()
    menu_enter()

    print(get_time())
    math.randomseed(get_time())
    gLevelValues.starHeal = false

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
    local exWins = tonumber(mod_storage_load("exWins")) or 0

    sMario.wins = math.floor(wins)
    sMario.kills = math.floor(kills)
    sMario.maxStreak = math.floor(maxStreak)
    sMario.hardWins = math.floor(hardWins)
    sMario.maxStar = math.floor(maxStar)
    sMario.exWins = math.floor(exWins)
    sMario.hard = 0

    local np = gNetworkPlayers[0]
    local playerColor = network_get_player_text_color_string(0)
    if wins >= 1 then
      network_send(false, {
        id = PACKET_STATS,
        stat = "disp_wins",
        value = math.floor(wins),
        name = playerColor .. np.name,
      })
      if (wins >= 100 or hardWins >= 5) and exWins <= 0 then
        djui_chat_message_create(trans("extreme_notice"))
      elseif wins >= 5 and hardWins <= 0 then
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
    if exWins >= 1 then
      network_send(false, {
        id = PACKET_STATS,
        stat = "disp_wins_ex",
        value = math.floor(exWins),
        name = playerColor .. np.name,
      })
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
    sMario.placement = assign_place(discordID)
    check_for_dev()

    -- start out as hunter
    become_hunter(sMario)
    sMario.totalStars = 0
    sMario.pause = gGlobalSyncTable.pause or false
    sMario.forceSpectate = gGlobalSyncTable.forceSpectate or false

    if gGlobalSyncTable.mhState == 0 then
      set_background_music(0,0x41,0)
      --play_music(0, 0x41, 1)
    end
    omm_disable_non_stop_mode(gGlobalSyncTable.mhMode == 2) -- change non stop mode setting for minihunt

    didFirstJoinStuff = true
  end
end

-- load saved settings for IsHost
function load_settings()
  if not network_is_server() then return end

  if gServerSettings.headlessServer == 1 then
    gGlobalSyncTable.gameAuto = 99
    gGlobalSyncTable.mhMode = 2
    gGlobalSyncTable.runTime = 30 * 300
    gGlobalSyncTable.mhTimer = 30 * 30
    return
  end

  local settings = {"runnerLives","runTime","allowSpectate","starMode","weak","mhMode","metal","campaignCourse","gameAuto"}
  for i,setting in ipairs(settings) do
    local option = mod_storage_load(setting)
    if setting == "weak" and OmmEnabled then option = mod_storage_load("ommWeak") end
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
  -- special case
  local fileName = string.gsub(gGlobalSyncTable.romhackFile," ","_")
  option = mod_storage_load(fileName)
  if option ~= nil and tonumber(option) ~= nil then
    gGlobalSyncTable.starRun = tonumber(option)
  end
end
-- save settings for IsHost
function save_settings()
  if not network_is_server() then return end

  local settings = {"runnerLives","runTime","allowSpectate","starMode","weak","mhMode","metal","campaignCourse","gameAuto"}
  for i,setting in ipairs(settings) do
    local option = gGlobalSyncTable[setting]
    if setting == "weak" and OmmEnabled then setting = "ommWeak" end
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
  -- special case
  option = gGlobalSyncTable.starRun
  local fileName = string.gsub(gGlobalSyncTable.romhackFile," ","_")
  if fileName ~= "custom" and option ~= nil then
    mod_storage_save(fileName,tostring(option))
  end
end
-- loads default settings for IsHost
function default_settings()
  setup_hack_data(true,false,OmmEnabled)
  gGlobalSyncTable.runnerLives = 1
  gGlobalSyncTable.runTime = 7200
  gGlobalSyncTable.allowSpectate = true
  gGlobalSyncTable.starMode = false
  gGlobalSyncTable.weak = OmmEnabled
  gGlobalSyncTable.mhMode = 0
  gGlobalSyncTable.metal = false
  gGlobalSyncTable.gameAuto = 0
  gGlobalSyncTable.campaignCourse = 0
  save_settings()
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
    local seconds = gGlobalSyncTable.runTime//30 % 60
    local minutes = gGlobalSyncTable.runTime//1800
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
    fun = trans("mini_goal",gGlobalSyncTable.runTime//1800,(gGlobalSyncTable.runTime%1800)//30) .. " " .. fun
  end

  local text = string.format("\\#00ffff\\%s\\#ffffff\\%s: %s"..
  "\n\\#ff5a5a\\%s\\#ffffff\\%s: %s"..
  "\n\\#00ffff\\%s\\#ffffff\\: %s%s%s."..
  "\n\\#ff5a5a\\%s\\#ffffff\\: %s%s%s."..
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
  becomeRunner,
  spectate,
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

  local sMario = gPlayerSyncTable[0]
  -- stats hud
  if showingStats then
    hide_both_hud(true)
    return stats_table_hud()
  elseif menu or mhHideHud then-- Blocky's menu
    hide_both_hud(true)
    return
  elseif sMario.spectator == 1 then
    hide_both_hud(true)
  else
    hide_both_hud(false)
  end

  local text = ""
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
            if star_radar[star] == nil then
              star_radar[star] = {tex = TEX_STAR, prevX = 0, prevY = 0}
            end
            render_radar(obj, star_radar[star], true)
          end
        elseif star == gGlobalSyncTable.getStar then
          if star_radar[star] == nil then
            star_radar[star] = {tex = TEX_STAR, prevX = 0, prevY = 0}
          end
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
            render_radar(obj, box_radar[star], true, "box")
          end
        elseif star == gGlobalSyncTable.getStar then
          render_radar(obj, box_radar[star], true, "box")
        end
      end
      obj = obj_get_next_with_same_behavior_id(obj)
    end
    -- red coins
    obj = obj_get_nearest_object_with_behavior_id(gMarioStates[0].marioObj, id_bhvRedCoin)
    if obj ~= nil then
      render_radar(obj, ex_radar[1], true, "coin")
    end
    -- secrets
    obj = obj_get_nearest_object_with_behavior_id(gMarioStates[0].marioObj, id_bhvHiddenStarTrigger)
    if obj ~= nil then
      render_radar(obj, ex_radar[2], true, "secret")
    end
    -- green demon
    if demonOn then
      obj = obj_get_first_with_behavior_id(id_bhvHidden1upInPole)
      while obj ~= nil do
        if obj.oBehParams <= 255 then
          render_radar(obj, ex_radar[3], true, "demon")
          break
        end
        obj = obj_get_next_with_same_behavior_id(obj)
      end
    end
  end

  local scale = 0.5

  -- get width of screen and text
  local screenWidth = djui_hud_get_screen_width()
  local width = djui_hud_measure_text(remove_color(text)) * scale

  local x = (screenWidth - width) * 0.5
  local y = 0

  djui_hud_set_color(0, 0, 0, 128);
  djui_hud_render_rect(x - 6, y, width + 12, 16);

  djui_hud_print_text_with_color(text, x, y, scale)

  -- death timer (extreme mode)
  scale = 0.5
  if sMario.hard == 2 and sMario.team == 1 and (gGlobalSyncTable.mhState == 2 or gGlobalSyncTable.mhState == 1) then
    djui_hud_set_font(FONT_HUD)
    djui_hud_set_color(255, 255, 255, 255);

    local seconds = deathTimer//30
    local screenHeight = djui_hud_get_screen_height()
    text = trans("death_timer")

    -- sorta based on personal star count
    local scale = 1
    local xOffset = -23
    local yOffset = 0
    y = screenHeight - 200
    if not (OmmEnabled and hud_is_hidden()) then
      local raceTimerOn = hud_get_value(HUD_DISPLAY_FLAGS) & HUD_DISPLAY_FLAGS_TIMER
      --djui_chat_message_create(tostring(raceTimerValue))
      if raceTimerOn ~= 0 then
        yOffset = 20
      end
    else -- omm hud is enabled
      OmmHud = true
      yOffset = -25
      xOffset = -60
    end
    width = djui_hud_measure_text(text) * scale
    x = (screenWidth - width)

    if deathTimer <= 180 then
      xOffset = xOffset + math.random(-2,2)
      yOffset = yOffset + math.random(-2,2)
    end

    print_text_ex_hud_font(text, x+xOffset, y+yOffset, scale)
    width = djui_hud_measure_text(tostring(seconds)) * scale
    x = (screenWidth - width)
    y = y + 17
    djui_hud_print_text(tostring(seconds), x+xOffset, y+yOffset, scale)

    djui_hud_set_font(FONT_NORMAL)
  end

  -- star name for minihunt
  if gGlobalSyncTable.mhMode == 2 and gGlobalSyncTable.mhState == 2 then
    local np = gNetworkPlayers[0]
    text = get_custom_star_name(np.currCourseNum, gGlobalSyncTable.getStar)
    width = djui_hud_measure_text(text) * scale
    local screenHeight = djui_hud_get_screen_height()
    x = (screenWidth - width) * 0.5
    y = screenHeight - 16

    djui_hud_set_color(0, 0, 0, 128);
    djui_hud_render_rect(x - 6, y, width + 12, 32*scale);

    djui_hud_set_color(255, 255, 255, 255);
    djui_hud_print_text(text, x, y, scale);
  elseif showSpeedrunTimer and gGlobalSyncTable.mhMode ~= 2 then
    local miliseconds = math.floor(gGlobalSyncTable.speedrunTimer/30%1*100)
    local seconds = gGlobalSyncTable.speedrunTimer//30 % 60
    local minutes = gGlobalSyncTable.speedrunTimer//30//60 % 60
    local hours = gGlobalSyncTable.speedrunTimer//30//60//60
    text = string.format("%d:%02d:%02d.%02d", hours, minutes, seconds, miliseconds)
    width = 118 * scale
    local screenHeight = djui_hud_get_screen_height()
    x = (screenWidth - width) * 0.5
    y = screenHeight - 16

    djui_hud_set_color(0, 0, 0, 128);
    djui_hud_render_rect(x - 6, y, width + 12, 32*scale);

    djui_hud_set_color(255, 255, 255, 255);
    djui_hud_print_text(text, x, y, scale);
  end

  -- timer
  scale = 0.5
  if gGlobalSyncTable.mhTimer ~= nil and gGlobalSyncTable.mhTimer > 0 then
    local seconds = gGlobalSyncTable.mhTimer//30 % 60
    local minutes = gGlobalSyncTable.mhTimer // 1800
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
      local seconds = timeLeft//30 % 60
      local minutes = (timeLeft // 1800)
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
  local seconds = math.ceil(gGlobalSyncTable.mhTimer/30)
  local text = trans("until_hunters",seconds)
  if seconds > 10 then
    text = trans("until_runners",(seconds-10))
  end

  return text
end

function victory_hud()
  -- set win text
  local text = trans("win","\\#ff5a5a\\"..trans("hunters"))
  if gGlobalSyncTable.mhState == 5 then
    text = trans("game_over")
  elseif gGlobalSyncTable.mhState > 3 then
    text = trans("win","\\#00ffff\\"..trans("runners"))
  end
  return text
end

function unstarted_hud(sMario)
  -- display role
  local roleName,colorString = get_role_name_and_color(sMario)
  return colorString..roleName
end

function camp_hud(sMario)
  return trans("camp_timer",campTimer // 30)
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
  if text:sub(2,2) ~= "#" then
    return nil
  end
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

-- prints text on the screen... with color!
function djui_hud_print_text_with_color(text, x, y, scale)
  djui_hud_set_color(255, 255, 255, 255)
  local space = 0
  local color = ""
  text,color,render = remove_color(text,true)
  while render ~= nil do
    local r,g,b,a = convert_color(color)
    djui_hud_print_text(render, x+space, y, scale);
    if r then djui_hud_set_color(r, g, b, a) end
    space = space + djui_hud_measure_text(render) * scale
    text,color,render = remove_color(text,true)
  end
  djui_hud_print_text(text, x+space, y, scale);
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

-- TroopaParaKoopa's Level Cooldown (and other stuff)
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


  -- for IsHost only
  if network_is_server() then -- rejoin handling
    local sMario = gPlayerSyncTable[m.playerIndex]
    sMario.wins,sMario.kills,sMario.maxStreak,sMario.hardWins,sMario.maxStar,sMario.exWins,sMario.beenRunner = 0,0,0,0,0,0,0 -- unassign stats

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
        global_popup_lang("rejoin_start", name, nil, 1)
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

-- speed up these actions (troopa)
local faster_actions = {
  [ACT_GROUND_BONK] = true,
  [ACT_SPECIAL_DEATH_EXIT] = true,
  [ACT_FORWARD_GROUND_KB] = true,
  [ACT_BACKWARD_GROUND_KB] = true,
  [ACT_BACKFLIP_LAND] = true,
  [ACT_TRIPLE_JUMP_LAND] = true,
  [ACT_STAR_DANCE_EXIT] = true,
  [ACT_STAR_DANCE_WATER] = true,
  [ACT_STAR_DANCE_NO_EXIT] = true,
  [ACT_DIVE_PICKING_UP] = true,
  [ACT_PICKING_UP] = true,
  [ACT_PICKING_UP_BOWSER] = true,
  [ACT_HARD_FORWARD_GROUND_KB] = true,
  [ACT_SOFT_FORWARD_GROUND_KB] = true,
  [ACT_HARD_BACKWARD_GROUND_KB] = true,
  [ACT_SOFT_BACKWARD_GROUND_KB] = true,
  [ACT_LEDGE_GRAB] = true,
  [ACT_LEDGE_CLIMB_SLOW_1] = true,
  [ACT_LEDGE_CLIMB_SLOW_2] = true,
  [ACT_LEDGE_CLIMB_FAST] = true,
  [ACT_ENTERING_STAR_DOOR] = true,
  [ACT_PUSHING_DOOR] = true,
  [ACT_PULLING_DOOR] = true,
  [ACT_UNLOCKING_KEY_DOOR] = true,
  [ACT_UNLOCKING_STAR_DOOR] = true,
  [ACT_BACKWARD_WATER_KB] = true,
  [ACT_FORWARD_WATER_KB] = true,
}

-- based off of example
function mario_update(m)
  if not didFirstJoinStuff then return end

  -- fast actions by troopa
  if faster_actions[m.action] then
    m.marioObj.header.gfx.animInfo.animFrame = m.marioObj.header.gfx.animInfo.animFrame + 1
  end

  -- force spectate
  local sMario = gPlayerSyncTable[m.playerIndex]
  if m.playerIndex == 0 and sMario.spectator ~= 1 and sMario.forceSpectate
  and sMario.team ~= 1 and gGlobalSyncTable.allowSpectate then
    spectate_command("runner")
  end

  if m.cap ~= 0 then m.cap = 0 end -- return cap

  -- handle unlocking Green Demon mode
  if (not demonUnlocked) and m.playerIndex == 0 then
    local demon = obj_get_nearest_object_with_behavior_id(m.marioObj, id_bhvHidden1upInPole)
    if demon and nearest_player_to_object(demon) == m.marioObj and demon.oAction ~= 0 then
      demonTimer = demonTimer + 1
      if demonTimer > 300 then
        demonUnlocked = true
        mod_storage_save("demon_unlocked","true")
        djui_popup_create("Unlocked Green Demon mode!",1)
      end
    else
      demonTimer = 0
    end
  end

  -- set and decrement regain cap timer
  if m.playerIndex == 0 then
    if m.capTimer > 0 then
      cooldownCaps = m.flags
      regainCapTimer = 60
    elseif regainCapTimer > 0 then
      regainCapTimer = regainCapTimer - 1
    end
  end

  -- spawn 1up if it does not exist
  if m.playerIndex == 0 and demonOn then
    local demonExists = false
    local demonOkay = (sMario.team == 1 and m.health > 0xFF and m.invincTimer <= 0 and gGlobalSyncTable.mhState == 2)
    local obj = obj_get_first_with_behavior_id(id_bhvHidden1upInPole)
    while obj ~= nil do
      if obj.oBehParams <= 255 then
        demonExists = true
        break
      end
      obj_get_next_with_save_behavior_id(id_bhvHidden1upInPole)
    end
    if (not demonExists) and demonOkay then
      spawn_non_sync_object(
      id_bhvHidden1upInPole,
      E_MODEL_1UP,
      m.pos.x, m.pos.y, m.pos.z,
      function(obj) obj.oBehParams = 0xFF end)
    elseif demonExists and ((not demonOkay) or dist_between_objects(obj, m.marioObj) > 10000) then
      obj_mark_for_deletion(obj)
    end
  end

  -- run death if health is 0, or reset death status
  if m.health <= 0xFF then
    on_death(m)
  elseif m.playerIndex == 0 then
    if died and m.invincTimer < 100 then m.invincTimer = 100 end -- start invincibility

    died = false

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
      global_popup_lang("rejoin_success", data.name, nil, 1)
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
  local rolename,_,color = get_role_name_and_color(sMario)
  if gGlobalSyncTable.mhMode == 2 and frameCounter > 60 then
    network_player_set_description(np, trans_plural("stars",sMario.totalStars or 0), color.r, color.g, color.b, 255)
  elseif sMario.team == 1 then
    if frameCounter > 60 then
      network_player_set_description(np, rolename, color.r, color.g, color.b, 255)
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
    network_player_set_description(np, rolename, color.r, color.g, color.b, 255)
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
    gGlobalSyncTable.mhTimer = 20 * 30 -- 20 seconds
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
      if (sMario.hard ~= 0) then m.health = m.health - 4 end -- no water heal in hard mode
    elseif m.prevAction == ACT_FORWARD_WATER_KB or m.prevAction == ACT_BACKWARD_WATER_KB then
      m.invincTimer = 60 -- 2 seconds
      m.prevAction = m.action
    elseif (sMario.hard ~= 0) and frameCounter % 2 == 0 then -- half speed drowning
      m.health = m.health + 1 -- water drain is 1 (decimal) per frame
    end
  end

  -- hard mode
  if (sMario.hard == 1) and m.health > 0x400 then
    m.health = 0x400
    if m.playerIndex == 0 then deathTimer = 900 end
  elseif (sMario.hard == 2) then -- extreme mode
    if m.health > 0xFF and m.hurtCounter <= 0 and m.action ~= ACT_BURNING_FALL and m.action ~= ACT_BURNING_GROUND and m.action ~= ACT_BURNING_JUMP then
      m.health = 0x120
    elseif m.action ~= ACT_LAVA_BOOST then
      m.health = 0xFF
    end
    if m.playerIndex == 0 and deathTimer > 0 then
      deathTimer = deathTimer - 1
      if m.healCounter > 0 and m.health > 0xFF and deathTimer <= 1800 then
        deathTimer = deathTimer + 8
        if not OmmEnabled then deathTimer = deathTimer + 8 end -- double gain without OMM
      elseif deathTimer > 1800 then
        deathTimer = 1800
      end
      if deathTimer % 30 == 0 and deathTimer <= 330 then
        play_sound(SOUND_GENERAL2_SWITCH_TICK_FAST, m.marioObj.header.gfx.cameraToObject)
      end
    elseif m.playerIndex == 0 and m.health > 0xFF then
      -- explode code
      m.freeze = 60
      set_mario_action(m, ACT_BACKWARD_AIR_KB, 0)
      spawn_non_sync_object(id_bhvExplosion, E_MODEL_EXPLOSION, m.pos.x, m.pos.y,
      m.pos.z, nil)
      m.health = 0xFF
      m.hurtCounter = 0x8
      if m.playerIndex == 0 then deathTimer = 900 end
    end
  elseif m.playerIndex == 0 then
    deathTimer = 900
  end
  if ((sMario.hard ~= 0) and sMario.runnerLives > 0) then sMario.runnerLives = 0 end

  -- add stars
  if gGlobalSyncTable.mhMode == 2 or m.prevNumStarsForDialog < m.numStars or ROMHACK.isUnder then
    if m.playerIndex == 0 and gotStar ~= nil then
      if gGlobalSyncTable.mhMode == 2 then
        if gotStar == gGlobalSyncTable.getStar then
          gGlobalSyncTable.votes = 0

          -- send message
          network_send_include_self(false, {
            id = PACKET_RUNNER_STAR,
            runnerID = np.globalIndex,
            star = gotStar,
            course = np.currCourseNum,
            area = np.currAreaIndex,
          })

          sMario.totalStars = sMario.totalStars + 1
          if sMario.hard == 2 then deathTimer = deathTimer + 300 end

          -- new star for minihunt
          if gGlobalSyncTable.mhMode == 2 then
            if gGlobalSyncTable.campaignCourse ~= 0 then
              gGlobalSyncTable.campaignCourse = gGlobalSyncTable.campaignCourse + 1
            end
            random_star(np.currCourseNum,gGlobalSyncTable.campaignCourse)
          end
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
        if sMario.hard == 2 then deathTimer = deathTimer + 300 end
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

  -- buff underwater punch
  local waterPunchVel = 20
  if OmmEnabled then waterPunchVel = waterPunchVel * 2 end -- omm has fast swim
  if m.forwardVel < waterPunchVel and m.action == ACT_WATER_PUNCH then
    m.forwardVel = waterPunchVel
  end

  -- slight speed boost for hunters
  if m.action & ACT_GROUP_MASK == ACT_GROUP_MOVING and m.forwardVel > 30 and m.forwardVel < 40 then
    m.forwardVel = m.forwardVel + 2
  end

  -- only local mario at this point
  if m.playerIndex ~= 0 then return end

  deathTimer = 900

  -- camp timer for hunters!?
  if campTimer == nil and m.action == ACT_IN_CANNON then
    campTimer = 600 -- 20 seconds
  elseif m.action ~= ACT_IN_CANNON then
    campTimer = nil
  end

  -- detect victory for hunters (only IsHost to avoid disconnect bugs)
  if network_is_server() then
    -- check for runners
    local stillrunners = false
    for i=0,(MAX_PLAYERS-1) do
      if gPlayerSyncTable[i].team == 1 and gNetworkPlayers[i].connected then
        stillrunners = true
        break
      end
    end

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
        gGlobalSyncTable.mhTimer = 20 * 30 -- 20 seconds
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
    if m.playerIndex == 0 and type == INTERACT_STAR_OR_KEY and ROMHACK.isUnder then -- star detection is silly
      local obj_id = get_id_from_behavior(o.behavior)
      if obj_id ~= id_bhvGrandStar then
        gotStar = (o.oBehParams >> 24) + 1
      end
    end

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

  if obj_id == id_bhvHidden1upInPole and m.playerIndex == 0 then
    if o.oBehParams <= 255 and sMario.team == 1 then
      m.healCounter = 0x0
      m.health = 0xFF -- die
    end
  end

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
  if ROMHACK.heartReplace then -- some hacks require the use of hearts
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
  local args = split(msg," ")
  local toggle = args[1]
  local mode = "hard"
  if args[2] ~= nil or string.lower(toggle) == "ex" then
    mode = args[1]
    toggle = args[2] or ""
  end

  if string.lower(toggle) == "on" then
    if string.lower(mode) ~= "ex" then
      gPlayerSyncTable[0].hard = 1
    else
      gPlayerSyncTable[0].hard = 2
    end
    play_sound(SOUND_OBJ_BOWSER_LAUGH, gMarioStates[0].marioObj.header.gfx.cameraToObject)
    if string.lower(mode) ~= "ex" then
      djui_chat_message_create(trans("hard_on"))
    else
      djui_chat_message_create(trans("extreme_on"))
    end
    if gGlobalSyncTable.mhState ~= 2 then
      inHard = gPlayerSyncTable[0].hard
    elseif inHard ~= gPlayerSyncTable[0].hard then
      inHard = 0
      djui_chat_message_create(trans("no_hard_win"))
    end
  elseif string.lower(toggle) == "off" then
    if gPlayerSyncTable[0].hard ~= 2 then
      djui_chat_message_create(trans("hard_off"))
    else
      djui_chat_message_create(trans("extreme_off"))
    end
    gPlayerSyncTable[0].hard = 0
    inHard = 0
  else
    if string.lower(mode) ~= "ex" then
      djui_chat_message_create(trans("hard_info"))
    else
      djui_chat_message_create(trans("extreme_info"))
    end
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
  elseif (o.header.gfx.node.flags & GRAPH_RENDER_INVISIBLE) == 0 and obj_has_behavior_id(o, id_bhvHidden1upInPole) == 1 and o.oBehParams <= 255 and gPlayerSyncTable[0].team == 1 and obj_check_hitbox_overlap(o, gMarioStates[0].marioObj) then -- from flood
    local m = gMarioStates[0]
    m.healCounter = 0x0
    m.health = 0xFF -- die
  end
end

paused = false
function do_pause()
  local m = gMarioStates[0]
  local sMario = gPlayerSyncTable[m.playerIndex]
  -- only during timer or pause
  if sMario.pause
  or (gGlobalSyncTable.mhState == 1
  and sMario.spectator ~= 1 and (sMario.team ~= 1 or gGlobalSyncTable.mhTimer > 10 * 30)) then -- runners get 10 second head start
    if not paused then
      djui_popup_create(trans("paused"), 1)
      paused = true
    end

    enable_time_stop_including_mario()
    if gGlobalSyncTable.mhTimer > 0 then
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
    testmsg = string.gsub(testmsg,"como se","") -- start of "how do..." I think
    testmsg = string.gsub(testmsg,"how do","")
    testmsg = string.gsub(testmsg,"collect star","")
    testmsg2 = string.gsub(testmsg2,"ingl","") -- for spanish speakers asking if this is an english (inglés) server; covers both with and without accent
    testmsg3 = string.gsub(testmsg3,"impossible","")
    if testmsg ~= string.lower(msg) then
      djui_popup_create(trans("rule_command"), 1)
    end
    if testmsg2 ~= string.lower(msg) then
      djui_popup_create(trans("to_switch","ES",nil,"es"), 1)
    end
    if testmsg3 ~= string.lower(msg) and gGlobalSyncTable.mhMode == 2 then
      djui_popup_create(trans("vote_info"), 1)
    end
  end
  local tag = get_tag(m.playerIndex)
  if tag then
    local np = gNetworkPlayers[m.playerIndex]
    local playerColor = network_get_player_text_color_string(m.playerIndex)
    local name = playerColor .. np.name

    djui_chat_message_create(name.." "..tag..": \\#dcdcdc\\"..msg)

    if m.playerIndex == 0 then
      play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, m.marioObj.header.gfx.cameraToObject)
    else
      play_sound(SOUND_MENU_MESSAGE_APPEAR, gMarioStates[0].marioObj.header.gfx.cameraToObject)
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
demonOn = false
demonUnlocked = mod_storage_load("demon_unlocked") or false
local demonTimer = 0
if mod_storage_load("showSpeedrunTimer") == "false" then showSpeedrunTimer = false end

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
  if theirSMario.team ~= 1 then
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

  omm_disable_non_stop_mode(gGlobalSyncTable.mhMode == 2) -- change non stop mode setting for minihunt
  if gGlobalSyncTable.mhMode == 2 and gGlobalSyncTable.mhState == 2 then -- unlock cannon and caps in minihunt
    local file = get_current_save_file_num() - 1
    local np = gNetworkPlayers[0]
    save_file_set_flags(SAVE_FLAG_HAVE_METAL_CAP)
    save_file_set_flags(SAVE_FLAG_HAVE_VANISH_CAP)
    save_file_set_flags(SAVE_FLAG_HAVE_WING_CAP)
    save_file_set_star_flags(file, np.currCourseNum, save_file_get_star_flags(file, np.currCourseNum) | 0x80)
  else -- fix star count
    local m = gMarioStates[0]
    local courseMax = 25
    local courseMin = 1
    m.numStars = save_file_get_total_star_count(get_current_save_file_num() - 1, courseMin - 1, courseMax - 1)
    m.prevNumStarsForDialog = m.numStars
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
    localRunTime = data.time or 0
    neededRunTime,localRunTime = calculate_leave_requirements(sMario,localRunTime)
    print("new time:",data.time)
    on_packet_role_change({id = PACKET_ROLE_CHANGE, index = newRunnerID},true)
  end

  _G.mhApi.onKill(killer,killed,data.runner,data.death,data.time,newRunnerID)
end

-- part of the API
function get_kill_combo()
  return killCombo
end

function on_game_end(data,self)
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
  if inHard == 1 then
    local hardWins = tonumber(mod_storage_load("hardWins"))
    if hardWins == nil then
      hardWins = 0
    end
    mod_storage_save("hardWins",tostring(math.floor(hardWins)+1))
    sMario.hardWins = sMario.hardWins + 1
  elseif inHard == 2 then
    local exWins = tonumber(mod_storage_load("exWins"))
    if exWins == nil then
      exWins = 0
    end
    mod_storage_save("exWins",tostring(math.floor(exWins)+1))
    sMario.exWins = sMario.exWins + 1
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
    if self then
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

-- for global popups, so it appears in their language
function global_popup_lang(langID,format,format2_,lines)
  network_send_include_self(false, {
    id = PACKET_LANG_POPUP,
    langID = langID,
    format = format,
    format2 = format2_,
    lines = lines,
  })
end
function on_packet_lang_popup(data,self)
  djui_popup_create(trans(data.langID,data.format,data.format2), data.lines)
end

-- popup for this player's role changing
function on_packet_role_change(data,self)
  local np = network_player_from_global_index(data.index)
  local playerColor = network_get_player_text_color_string(np.globalIndex)
  local sMario = gPlayerSyncTable[np.localIndex]
  local roleName,color = get_role_name_and_color(sMario)
  djui_popup_create(trans("now_role",playerColor..np.name,color..roleName),1)
  if np.localIndex == 0 and sMario.team == 1 then
    play_sound(SOUND_GENERAL_SHORT_STAR, gMarioStates[0].marioObj.header.gfx.cameraToObject)
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
PACKET_LANG_POPUP = 8
PACKET_ROLE_CHANGE = 9
sPacketTable = {
    [PACKET_RUNNER_STAR] = on_packet_runner_star,
    [PACKET_KILL] = on_packet_kill,
    [PACKET_MH_START] = do_game_start,
    [PACKET_TC] = on_packet_tc,
    [PACKET_GAME_END] = on_game_end,
    [PACKET_STATS] = on_packet_stats,
    [PACKET_KILL_COMBO] = on_packet_kill_combo,
    [PACKET_VOTE] = on_packet_vote,
    [PACKET_LANG_POPUP] = on_packet_lang_popup,
    [PACKET_ROLE_CHANGE] = on_packet_role_change,
}

-- from arena
function on_packet_receive(dataTable)
    if sPacketTable[dataTable.id] ~= nil then
        sPacketTable[dataTable.id](dataTable, false)
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
        djui_popup_create(trans("mode_normal"), 1)
      elseif newVal == 1 then
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
hook_on_sync_table_change(gGlobalSyncTable, "mhState", "change_state", on_state_changed)

-- prevent constant error stream
if trans == nil then
trans = function(id,format1,format2_,lang)
  return "LANGUAGE MODULE DID NOT LOAD"
end
trans_plural = trans
end
