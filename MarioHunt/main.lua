-- name: ! \\#00ffff\\Mario\\#ff5a5a\\Hun\\\\t\\#dcdcdc\\ (v2.31) !
-- incompatible: gamemode
-- description: A gamemode based off of Beyond's concept.\n\nHunters stop Runners from clearing the game!\n\nProgramming by EmilyEmmi, TroopaParaKoopa, Blocky, Sunk, and Sprinter05.\n\nSpanish Translation made with help from KanHeaven and SonicDark.\nGerman Translation made by N64 Mario.\nBrazillian Portuguese translation made by PietroM.\nFrench translation made by Skeltan.\n\n\"Shooting Star Summit\" port by pieordie1

menu = false
mhHideHud = false
expectedHudState = false -- for custom huds

LEVEL_LOBBY = level_register('level_lobby_entry', COURSE_NONE, 'Lobby', 'lobby', 28000, 0x28, 0x28, 0x28)

-- this reduces lag apparently
local djui_chat_message_create, djui_popup_create, djui_hud_measure_text, djui_hud_print_text, djui_hud_set_color, djui_hud_set_font, djui_hud_set_resolution, network_player_set_description, network_get_player_text_color_string, network_is_server, is_game_paused, get_current_save_file_num, save_file_get_star_flags, save_file_get_flags, djui_hud_render_rect, warp_to_level, mod_storage_save, mod_storage_load =
    djui_chat_message_create, djui_popup_create, djui_hud_measure_text, djui_hud_print_text, djui_hud_set_color,
    djui_hud_set_font, djui_hud_set_resolution, network_player_set_description, network_get_player_text_color_string,
    network_is_server, is_game_paused, get_current_save_file_num, save_file_get_star_flags, save_file_get_flags,
    djui_hud_render_rect, warp_to_level, mod_storage_save_fix_bug, mod_storage_load

-- TroopaParaKoopa's pause mod
gGlobalSyncTable.pause = false

-- TroopaParaKoopa's hns metal cap option
gGlobalSyncTable.metal = false

local rejoin_timer = {} -- rejoin timer for runners (host only)
if network_is_server() then
  -- all settings here
  gGlobalSyncTable.runnerLives = 1      -- the lives runners get (0 is a life)
  gGlobalSyncTable.runTime = 7200       -- time runners must stay in stage to leave (default: 4 minutes)
  gGlobalSyncTable.starRun = 70         -- stars runners must get to face bowser; star doors and infinite stairs will be disabled accordingly
  gGlobalSyncTable.allowSpectate = true -- hunters can spectate
  gGlobalSyncTable.starMode = false     -- use stars collected instead of timer
  gGlobalSyncTable.weak = false         -- cut invincibility frames in half
  gGlobalSyncTable.mhMode = 0           -- game modes, as follows:
  --[[
    0: Normal
    1: Switch
    2: Mini
  ]]
  gGlobalSyncTable.blacklistData = "none" -- encrypted data for blacklist
  gGlobalSyncTable.campaignCourse = 0     -- campaign course for minihunt (64 tour)
  gGlobalSyncTable.gameAuto = 0           -- automatically start new games
  gGlobalSyncTable.anarchy = 0            -- team attack; comes with 4 options
  --[[
    0 - Neither team
    1 - Runners only
    2 - Hunters only
    3 - Everyone
  ]]
  gGlobalSyncTable.dmgAdd = 0        -- Adds additional damage to pvp attacks (0-8)
  gGlobalSyncTable.nerfVanish = true -- Changes vanish cap a bit
  gGlobalSyncTable.firstTimer = true -- First place player in MiniHunt gets death timer

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
  gGlobalSyncTable.mhTimer = 0           -- timer in frames (game is 30 FPS)
  gGlobalSyncTable.speedrunTimer = 0     -- the total amount of time we've played in frames
  gGlobalSyncTable.gameLevel = 0         -- level for MiniHunt
  gGlobalSyncTable.getStar = 0           -- what star must be collected (for MiniHunt)
  gGlobalSyncTable.votes = 0             -- amount of votes for skipping (MiniHunt)
  gGlobalSyncTable.otherSave = false     -- using other save file
  gGlobalSyncTable.bowserBeaten = false  -- used for some rom hacks as a two-part completion process
  gGlobalSyncTable.ee = false            -- used for SM74
  gGlobalSyncTable.forceSpectate = false -- force all players to spectate unless otherwise stated
end

smlua_audio_utils_replace_sequence(0x53, 0x25, 65, "Shooting_Star_Summit") -- for lobby; hopefully there's no conflicts

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

local gotStar = nil             -- what star we just got
local died = false              -- if we've died (because on_death runs every frame of death fsr)
local didFirstJoinStuff = false -- if all of the initial code was run (rules message, etc.)
frameCounter = 120              -- frame counter over 4 seconds
local cooldownCaps = 0          -- stores m.flags, to see what caps are on cooldown
local regainCapTimer = 0        -- timer for being able to recollect a cap
local storeVanish = false       -- temporarily stores the vanish cap for pvp purposes
local campTimer                 -- for camping actions (such as reading text or being in the star menu), nil means it is inactive
warpCooldown = 0                -- to avoid warp spam
warpCount = 0
local warpTree = {}
local killTimer = 0            -- timer for kills in quick succession
local killCombo = 0            -- kills in quick succession
local hitTimer = 0             -- timer for being hit by another player
local localRunTime = 0         -- our run time is usually made local for less lag
local neededRunTime = 0        -- how long we need to wait to leave this course
local inHard = 0               -- what hard mode we started in (to prevent cheesy hard/extreme mode wins)
local deathTimer = 900         -- for extreme mode
local localPrevCourse = 0      -- for entrance popups
local lastObtainable = -1      -- doesn't display if it's the same number
local leader = false           -- if we're winning in minihunt
local month = 0                -- the current month of the year, for holiday easter eggs
local parkourTimer = 0         -- timer for parkour

OmmEnabled = false             -- is true if using OMM Rebirth
ACT_OMM_GRAB_STAR = 1073746688 -- the grab star action in OMM Rebirth (might change with updates, idk)
local ommStarID = nil          -- the object id of the star we got; for OMM
local ommStar = nil            -- what star we just got; for omm (gotStar is set to nil earlier)
local ommRenameTimer = 0       -- after someone gets the same kind of star, there is a timer until someone can have their star renamed on their end

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
    finalmatch = string.sub(finalmatch, 1, string.len(finalmatch) - string.len(delimiter))
    table.insert(result, finalmatch)
  end
  return result
end

-- handle game starting (all players)
function do_game_start(data, self)
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
    deathTimer = 1830                  -- start with 60 seconds
    gGlobalSyncTable.mhState = 1
    gGlobalSyncTable.mhTimer = 15 * 30 -- 15 seconds
  else
    deathTimer = 900                   -- start with 30 seconds
    gGlobalSyncTable.mhState = 2
    gGlobalSyncTable.mhTimer = 0
  end

  if network_is_server() and gGlobalSyncTable.mhMode == 2 then
    if tonumber(msg) ~= nil and tonumber(msg) > 0 and (tonumber(msg) % 1 == 0) then
      gGlobalSyncTable.campaignCourse = tonumber(msg)
    else
      gGlobalSyncTable.campaignCourse = 0
    end
    random_star(nil, gGlobalSyncTable.campaignCourse)
  end

  if string.lower(msg) ~= "continue" then
    local m = gMarioStates[0]
    m.health = 0x880
    SVcln = nil
    set_lighting_dir(2, 0)

    gGlobalSyncTable.votes = 0
    iVoted = false
    gGlobalSyncTable.speedrunTimer = 0

    local sMario = gPlayerSyncTable[0]
    sMario.totalStars = 0
    leader = false
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

  -- allow hurting each other in lobby, except in parkour challenge
  if gGlobalSyncTable.mhState == 0 then
    local raceTimerOn = hud_get_value(HUD_DISPLAY_FLAGS) & HUD_DISPLAY_FLAGS_TIMER
    return (raceTimerOn == 0)
  end

  if attacker.playerIndex == victim.playerIndex then
    return false
  end

  local sAttacker = gPlayerSyncTable[attacker.playerIndex]
  local sVictim = gPlayerSyncTable[victim.playerIndex]

  -- sanitize
  local attackTeam = sAttacker.team or 0
  local victimTeam = sVictim.team or 0

  -- team attack setting
  if gGlobalSyncTable.anarchy == 0 then
    return attackTeam ~= victimTeam
  elseif (gGlobalSyncTable.anarchy == 3) then
    return true
  elseif (gGlobalSyncTable.anarchy == 1 and attackTeam == 1) then
    return true
  elseif (gGlobalSyncTable.anarchy == 2 and attackTeam ~= 1) then
    return true
  end

  return attackTeam ~= victimTeam
end

function on_pvp_attack(attacker, victim)
  local sVictim = gPlayerSyncTable[victim.playerIndex]
  local npAttacker = gNetworkPlayers[attacker.playerIndex]
  if sVictim.team == 1 then
    if gGlobalSyncTable.dmgAdd >= 8 then -- instant death
      victim.health = 0xFF
      victim.healCounter = 0
    else
      if (victim.flags & MARIO_METAL_CAP) ~= 0 then
        victim.hurtCounter = victim.hurtCounter + 4                         -- one unit
      end
      victim.hurtCounter = victim.hurtCounter + gGlobalSyncTable.dmgAdd * 4 -- hurtCounter goes by 4 for some reason
    end
  end
  if victim.playerIndex == 0 then
    attackedBy = npAttacker.globalIndex
    hitTimer = 300 -- 10 seconds
    if (victim.health - math.max((victim.hurtCounter - victim.healCounter) * 0x40, 0)) <= 0xFF then
      play_sound(SOUND_GENERAL_BOWSER_BOMB_EXPLOSION, victim.marioObj.header.gfx.cameraToObject)
      set_camera_shake_from_hit(SHAKE_LARGE_DAMAGE)
    end
  end
end

-- omm support
function omm_allow_attack(index, setting)
  if setting == 3 and index ~= 0 then
    return allow_pvp_attack(gMarioStates[index], gMarioStates[0])
  end
  return true
end

function omm_attack(index, setting)
  if setting == 3 and index ~= 0 then
    on_pvp_attack(gMarioStates[index], gMarioStates[0])
  end
end

-- sadly this no longer works for omm (while I CAN force the value, it prevents it from being changed)
function hide_both_hud(hide)
  if OmmEnabled then return end

  -- don't override custom huds
  if expectedHudState ~= hud_is_hidden() then
    return
  end
  if hide then
    hud_hide()
  else
    hud_show()
  end
  expectedHudState = hide
  hide_star_counters(hide)
end

-- personal star counter support (even though it's set to incompatible anyway)
function hide_star_counters(hide)
  return
end

function get_leave_requirements(sMario)
  -- for leave command
  if sMario.allowLeave then
    return 0
  end

  -- in castle
  local np = gNetworkPlayers[0]
  if np.currCourseNum == 0 or (ROMHACK ~= nil and ROMHACK.hubStages ~= nil and ROMHACK.hubStages[np.currCourseNum] ~= nil) then
    return 0, trans("in_castle")
  end

  -- allow leaving bowser stages if done
  if np.currCourseNum == COURSE_BITDW and ((save_file_get_flags() & (SAVE_FLAG_HAVE_KEY_1 | SAVE_FLAG_UNLOCKED_BASEMENT_DOOR)) ~= 0) then
    return 0
  elseif np.currCourseNum == COURSE_BITFS and ((save_file_get_flags() & (SAVE_FLAG_HAVE_KEY_2 | SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR)) ~= 0) then
    return 0
  elseif np.currCourseNum == COURSE_BITS and gGlobalSyncTable.bowserBeaten then -- star road and such
    return 0
  end

  -- can't leave some stages in star mode
  if neededRunTime == -1 then
    return 1, trans("cant_leave")
  end

  return (neededRunTime - localRunTime)
end

-- only do this sometimes to reduce lag
function calculate_leave_requirements(sMario, runTime, gotStar)
  local np = gNetworkPlayers[0]

  -- skip calculation if we're in a hub stage, and prevent leaving bowser areas
  if np.currCourseNum == 0 or (ROMHACK ~= nil and ROMHACK.hubStages ~= nil and ROMHACK.hubStages[np.currCourseNum] ~= nil) then
    return 0, 0
  elseif np.currLevelNum == LEVEL_BOWSER_1 or np.currLevelNum == LEVEL_BOWSER_2 or np.currLevelNum == LEVEL_BOWSER_3 then
    return -1, 0 -- -1 means no leaving
  end

  -- less time for secret courses
  local total_time = gGlobalSyncTable.runTime
  local star_data_table = { 8, 8, 8, 8, 8, 8, 8 }
  if ROMHACK.star_data and ROMHACK.star_data[np.currCourseNum] then
    star_data_table = ROMHACK.star_data[np.currCourseNum]
    -- for EE
    if gGlobalSyncTable.ee and ROMHACK.star_data_ee and ROMHACK.star_data_ee[np.currCourseNum] then
      star_data_table = ROMHACK.star_data_ee[np.currCourseNum]
    end
  elseif np.currCourseNum > 15 then
    star_data_table = { 8 }
  end
  if (np.currCourseNum == COURSE_DDD and ROMHACK.ddd and ((save_file_get_flags() & (SAVE_FLAG_HAVE_KEY_2 | SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR)) == 0)) then
    star_data_table = { 8 } -- treat DDD as only having star 1
  end

  -- if a "exit" star was obtained, allow leaving immediatly
  if gotStar and star_data_table[gotStar] and star_data_table[gotStar] & STAR_EXIT ~= 0 then
    local skip_rule = (gLevelValues.disableActs and star_data_table[gotStar] & STAR_APPLY_NO_ACTS == 0)
    if not skip_rule then
      sMario.allowLeave = true
      return 0, 0
    end
  end

  -- calculate what stars can still be obtained
  local counting_stars = 0
  local obtainable_stars = 0
  local file = get_current_save_file_num() - 1
  local course_star_flags = save_file_get_star_flags(file, np.currCourseNum - 1)
  for i = 1, #star_data_table do
    if star_data_table[i] and (course_star_flags & (1 << (i - 1)) == 0) then
      local data = star_data_table[i]
      local areaValid = false
      local area = data & STAR_AREA_MASK
      if star_data_table[i] < STAR_MULTIPLE_AREAS then
        if area == 8 or np.currAreaIndex == area then
          areaValid = true
        end
      else
        local areas = (data & ~(STAR_MULTIPLE_AREAS - 1))
        if areas & (np.currAreaIndex) ~= 0 then
          areaValid = true
        end
      end

      -- for star road
      if i == #star_data_table and ROMHACK.replica_start ~= nil and gMarioStates[0].numStars < ROMHACK.replica_start and np.currCourseNum > 15 and np.currCourseNum ~= 25 then
        area = 0
      end

      local act = math.max(np.currActNum, 1) -- anything below act 1 is still act 1
      local skip_rule = (gLevelValues.disableActs and data & STAR_APPLY_NO_ACTS == 0)
      if (skip_rule and area ~= 0)
          or (areaValid
            and (data & STAR_ACT_SPECIFIC == 0 or act == i)
            and (data & STAR_NOT_ACT_1 == 0 or act > 1)
            and (data & STAR_NOT_BEFORE_THIS_ACT == 0 or act >= i)) then
        obtainable_stars = obtainable_stars + 1
        if skip_rule or (not gGlobalSyncTable.starMode) or data & STAR_IGNORE_STARMODE == 0 then
          counting_stars = counting_stars + 1
        end
      end
    end
  end

  -- if there aren't any in this stage, treat as a 1 star stage
  if #star_data_table <= 0 then
    counting_stars = 1
    if gGlobalSyncTable.starMode or ROMHACK.isUnder then return -1, 0 end -- impossible to leave in star mode
  end

  if lastObtainable ~= obtainable_stars then
    djui_popup_create(trans("stars_in_area", obtainable_stars), 1)
    lastObtainable = obtainable_stars
  end

  if gGlobalSyncTable.starMode then
    if (total_time - runTime) > counting_stars then
      runTime = total_time - counting_stars
    end
  elseif (total_time - runTime) > counting_stars * 2700 then
    runTime = total_time - counting_stars * 2700
  end
  return total_time, runTime
end

-- random star for MiniHunt
function random_star(prevCourse, campaignCourse_)
  local campaignCourse = campaignCourse_ or 0
  local selectedStar = nil
  if campaignCourse > 0 and campaignCourse < 26 then
    -- the campaign from the 64 tour!
    local starorder = { 15, 22, 33, 44, 54, 64, 75, 85, 94, 101, 113, 121, 137, 144, 154, 171, 221, 14, 47, 62, 77, 93, 161, 181, 231 }
    selectedStar = starorder[campaignCourse]
  elseif selectedStar == nil then
    local replicas = true
    if ROMHACK.replica_start ~= nil then
      local courseMax = 25
      local courseMin = 1
      local totalStars = save_file_get_total_star_count(get_current_save_file_num() - 1, courseMin - 1, courseMax - 1)
      if ROMHACK.replica_start > totalStars then
        replicas = false
      end
    end

    local valid_star_table = generate_star_table(prevCourse, false, replicas)
    if #valid_star_table < 1 then
      valid_star_table = generate_star_table(prevCourse, false, replicas, gGlobalSyncTable.getStar)
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
  print("Selected", gGlobalSyncTable.gameLevel, gGlobalSyncTable.getStar)
end

-- generate table of valid stars
function generate_star_table(exCourse, standard, replicas, recentAct)
  local valid_star_table = {}
  for course, level in pairs(course_to_level) do
    if course ~= exCourse or recentAct ~= nil then
      for act = 1, 7 do
        if recentAct ~= act and valid_star(course, act, standard, replicas) then
          table.insert(valid_star_table, course * 10 + act)
        end
      end
    end
  end
  return valid_star_table
end

-- gets if the star is valid for minihunt
function valid_star(course, act, standard, replicas)
  if course < 0 or course > 25 or (course % 1 ~= 0) then return false end

  if (standard or (course ~= 0 and course ~= 25 and (ROMHACK.hubStages == nil or ROMHACK.hubStages[course] == nil))) then
    local star_data_table = { 8, 8, 8, 8, 8, 8, 8 }
    if course == 25 and not ROMHACK.star_data[course] then
      return false
    elseif course > 15 or ROMHACK.star_data[course] then
      star_data_table = ROMHACK.star_data[course] or { 8 }
      if gGlobalSyncTable.ee and ROMHACK.star_data_ee and ROMHACK.star_data_ee[course] then
        star_data_table = ROMHACK.star_data_ee[course]
      end
    elseif course == 0 then
      star_data_table = { 8, 8, 8, 8, 8 }
    end

    if star_data_table[act] then
      if (not replicas) and act == #star_data_table then
        return false
      elseif star_data_table[act] ~= 0 and (standard or mini_blacklist == nil or mini_blacklist[course * 10 + act] == nil) and (standard or act ~= 7 or course > 15) then
        return true
      end
      return false
    else
      return false
    end
  end
  return false
end

function on_pause_exit(exitToCastle)
  if gGlobalSyncTable.mhState == 0 then return false end
  local m = gMarioStates[0]
  local sMario = gPlayerSyncTable[0]
  if (m.health - math.max((m.hurtCounter - m.healCounter) * 0x40, 0)) <= 0xFF then return false end -- prevent leaving in death
  if sMario.spectator == 1 then return false end
  if gGlobalSyncTable.mhMode == 2 then
    if m.invincTimer <= 0 and (m.action & ACT_FLAG_AIR) == 0 then
      warp_beginning()
    end
    return false
  end
  if sMario.team == 1 and get_leave_requirements(sMario) > 0 then return false end
  m.health = 0x880 -- full health
  m.hurtCounter = 0x0
end

function on_death(m, nonStandard)
  if m.playerIndex ~= 0 then return true end
  if ROMHACK.isUnder and (not nonStandard) and m.health <= 0xFF and gNetworkPlayers[0].currLevelNum == LEVEL_CASTLE_COURTYARD then
    m.health = 0x880
    m.hurtCounter = 0
    force_idle_state(m)
    reset_camera(m.area.camera)
    return false
  elseif not nonStandard and gGlobalSyncTable.mhMode ~= 2 and gGlobalSyncTable.mhState ~= 0 and gNetworkPlayers[0].currCourseNum == 0 then -- for star road (and also 121rst star)
    m.numLives = 101
    died = true
    return true
  end

  if died == false then
    local sMario = gPlayerSyncTable[0]
    local lost = false
    local newID = nil
    local runner = false
    local time = localRunTime or 0
    m.health = 0xFF  -- Mario's health is used to see if he has respawned
    m.numLives = 100 -- prevent star road 0 life
    died = true
    warpCount = 0
    warpCooldown = 0
    killTimer = 0
    killCombo = 0

    -- change to hunter
    if gGlobalSyncTable.mhState == 2 and sMario.team == 1 and sMario.runnerLives <= 0 then
      runner = true
      m.numLives = 100
      become_hunter(sMario)
      localRunTime = 0
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

  if (not nonStandard) and (gGlobalSyncTable.mhState == 0 or gGlobalSyncTable.mhMode == 2) then
    if m.playerIndex == 0 then warp_beginning() end
    m.health = 0x880
    return false
  end

  return true
end

function new_runner(includeLocal)
  local startingI = 1
  if includeLocal then
    startingI = 0
  end

  local currHunterIDs = {}
  local closest = -1
  local closestDist = 0

  -- get current hunters
  for i = startingI, (MAX_PLAYERS - 1) do
    local np = gNetworkPlayers[i]
    local sMario = gPlayerSyncTable[i]
    if np.connected and sMario.team ~= 1 and sMario.spectator ~= 1 then
      table.insert(currHunterIDs, np.localIndex)
      if (not includeLocal) and is_player_active(gMarioStates[i]) ~= 0 then -- give to closest mario
        local dist = dist_between_objects(gMarioStates[i].marioObj, gMarioStates[0].marioObj)
        if closest == -1 or dist < closestDist then
          closestDist = dist
          closest = i
        end
      end
    end
  end
  if #currHunterIDs < 1 then
    if not includeLocal then
      if gGlobalSyncTable.mhMode == 2 then -- singleplayer minihunt
        gGlobalSyncTable.mhTimer = 1       -- end game
        return nil
      else
        return gNetworkPlayers[0].globalIndex
      end
    else
      return nil
    end
  end

  local lIndex = 0
  if closest == -1 then
    lIndex = currHunterIDs[math.random(1, #currHunterIDs)]
  else
    lIndex = closest
  end
  local np = gNetworkPlayers[lIndex]
  return np.globalIndex
end

function omm_disable_non_stop_mode(disable)
  if OmmEnabled then
    gLevelValues.disableActs = not disable
    return _G.OmmApi.omm_disable_feature("trueNonStop", disable)
  end
end

function update()
  do_pause()
  if obj_get_first_with_behavior_id(id_bhvActSelector) ~= nil then
    before_mario_update(gMarioStates[0], true)
  end

  -- detect victory for runners
  if gGlobalSyncTable.mhState == 2 and gGlobalSyncTable.mhMode ~= 2 and ROMHACK and ROMHACK.runner_victory and ROMHACK.runner_victory(gMarioStates[0]) then
    network_send_include_self(true, {
      id = PACKET_GAME_END,
      winner = 1,
    })
    rejoin_timer = {}
    gGlobalSyncTable.mhState = 4
    gGlobalSyncTable.mhTimer = 20 * 30 -- 20 seconds
  end

  if warpCooldown > 0 then warpCooldown = warpCooldown - 1 end
  if gGlobalSyncTable.votes == 0 then iVoted = false end -- undo vote

  local m = gMarioStates[0]
  local sMario = gPlayerSyncTable[0]

  -- handle timers
  if not (gGlobalSyncTable.pause and sMario.pause) then
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

              local singlePlayer = true
              for i = 1, MAX_PLAYERS - 1 do
                local np = gNetworkPlayers[i]
                local sMario = gPlayerSyncTable[i]
                if np.connected and sMario.spectator ~= 1 then
                  singlePlayer = false
                  break
                end
              end
              if not singlePlayer then
                runner_randomize(gGlobalSyncTable.gameAuto)
              end

              if gGlobalSyncTable.campaignCourse > 0 then
                start_game("1") -- stay in campaign mode
              else
                start_game("")
              end
              if gGlobalSyncTable.mhTimer == 0 then
                gGlobalSyncTable.mhTimer = 20 * 30 -- 20 seconds (in elseif o.oAction == start doesnt work)
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

      for id, data in pairs(rejoin_timer) do
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
    local sMario = gPlayerSyncTable[0]

    OmmEnabled = _G.OmmEnabled or false -- set up OMM support
    if OmmEnabled then
      _G.OmmApi.omm_resolve_cappy_mario_interaction = omm_attack
      _G.OmmApi.omm_allow_cappy_mario_interaction = omm_allow_attack
      _G.OmmApi.omm_disable_feature("lostCoins", true)
      _G.OmmApi.omm_force_setting_value("player", 2)
      _G.OmmApi.omm_force_setting_value("damage", 20)
      _G.OmmApi.omm_force_setting_value("bubble", 0)
    end
    if gGlobalSyncTable.romhackFile == "vanilla" then
      omm_replace(OmmEnabled)
    end
    if _G.PersonalStarCounter then
      hide_star_counters = _G.PersonalStarCounter.hide_star_counters
    end

    setup_hack_data(network_is_server(), true, OmmEnabled)
    if network_is_server() then
      load_settings()

      local fileName = string.gsub(gGlobalSyncTable.romhackFile, " ", "_")
      local option = mod_storage_load(fileName .. "_black") or "none"
      gGlobalSyncTable.blacklistData = option
      setup_mini_blacklist(option)

      if gGlobalSyncTable.gameAuto ~= 0 then
        gGlobalSyncTable.mhTimer = 20 * 30
      end
    else
      setup_mini_blacklist(gGlobalSyncTable.blacklistData)
    end

    -- holiday detection (it's a bit complex)
    local time = get_time() - 3600 * 4 -- EST (-4 hours)
    --local hours = time%(3600*24)//3600
    local days = (time // 60 // 60 // 24) + 1
    local years = (days // 365.25)
    local year = 1970 + years
    days = days - years * 365 - years // 4 + years // 100 - years // 400
    while month <= 12 do
      month = month + 1
      local DaysInMonth = 30
      if month == 2 then
        DaysInMonth = 28 + is_zero(year % 4) - is_zero(year % 100)
            + is_zero(year % 400)
      else
        DaysInMonth = 30 + (month + bool_to_int(month > 7)) % 2
      end
      if days > DaysInMonth then
        --djui_popup_create(tostring(DaysInMonth), 1)
        days = days - DaysInMonth
      else
        break
      end
    end
    if month == 4 and days == 1 then -- april fools
      month = 13
    end
    --djui_popup_create(string.format("%d/%d/%d, %d",month,days,year,hours), 1)

    print(time)
    math.randomseed(time)
    gLevelValues.starHeal = false

    save_file_set_using_backup_slot(gGlobalSyncTable.otherSave)
    save_file_reload(1)
    if ROMHACK.stalk then
      stalk_command("", true)
      popup_sound(SOUND_GENERAL2_RIGHT_ANSWER)
      djui_popup_create(trans("stalk"), 1)
    else
      warp_beginning()
    end

    -- display and set stats
    local stats = {
      "wins",
      "hardWins",
      "exWins",
      "wins_standard",
      "hardWins_standard",
      "exWins_standard",
      "kills",
      "maxStreak",
      "maxStar",
    }
    for i, stat in ipairs(stats) do
      local value = tonumber(mod_storage_load(stat)) or 0
      sMario[stat] = math.floor(value)
    end
    sMario.hard = 0

    local wins = sMario.wins + sMario.wins_standard
    local hardWins = sMario.hardWins + sMario.hardWins_standard
    local exWins = sMario.exWins + sMario.exWins_standard

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
    if sMario.kills >= 50 then
      network_send(false, {
        id = PACKET_STATS,
        stat = "disp_kills",
        value = math.floor(sMario.kills),
        name = playerColor .. np.name,
      })
    end
    local beenRunner = mod_storage_load("beenRunnner")
    sMario.beenRunner = tonumber(beenRunner) or 0
    print("Our 'Been Runner' status is ", sMario.beenRunner)

    local discordID = network_discord_id_from_local_index(0)
    discordID = tonumber(discordID) or 0
    print("My discord ID is", discordID)
    sMario.discordID = discordID
    sMario.placement = assign_place(discordID)
    check_for_roles()

    -- start out as hunter
    become_hunter(sMario)
    sMario.totalStars = 0
    sMario.pause = gGlobalSyncTable.pause or false
    sMario.forceSpectate = gGlobalSyncTable.forceSpectate or false
    sMario.fasterActions = (mod_storage_load("fasterActions") ~= "false")

    show_rules()
    djui_chat_message_create(trans("open_menu"))
    djui_chat_message_create(trans("to_switch", lang_list))

    if gGlobalSyncTable.mhState == 0 then
      set_lobby_music(month)
      --play_music(0, custom_seq, 1)
    end
    omm_disable_non_stop_mode(gGlobalSyncTable.mhMode == 2) -- change non stop mode setting for minihunt

    menu_reload()
    action_setup()
    menu_enter()

    -- this works, surprisingly (runs last)
    hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
    hook_event(HOOK_ALLOW_INTERACT, on_allow_interact)

    didFirstJoinStuff = true
    return
  end

  -- completely ruins the save file apparently :/
  --[[if justEntered and gGlobalSyncTable.otherSave ~= nil then
    save_file_set_using_backup_slot(gGlobalSyncTable.otherSave)
    save_file_reload(1)
    justEntered = false
  end]]

  -- prevent softlock if hunters kill bowser (vanilla only)
  local np = gNetworkPlayers[0]
  local sMario = gPlayerSyncTable[0]
  if sMario.team == 1 and (np.currLevelNum == LEVEL_BOWSER_1 or np.currLevelNum == LEVEL_BOWSER_2) and gGlobalSyncTable.romhackFile == "vanilla" then
    local bowser = obj_get_first_with_behavior_id(id_bhvBowser)
    local key = obj_get_first_with_behavior_id(id_bhvBowserKey)
    if bowser and bowser.oAction == 4 and (not key) then
      local m = gMarioStates[0]
      spawn_non_sync_object(
        id_bhvBowserKey,
        E_MODEL_BOWSER_KEY,
        m.pos.x, m.pos.y, m.pos.z,
        nil
      )
    end
  end
end

-- load saved settings for host
function load_settings(miniOnly, starOnly)
  if not network_is_server() then return end

  if gServerSettings.headlessServer == 1 then
    gGlobalSyncTable.gameAuto = 99
    gGlobalSyncTable.mhMode = 2
    gGlobalSyncTable.runTime = 30 * 300
    gGlobalSyncTable.mhTimer = 30 * 30
    return
  end

  local settings = { "mhMode", "runnerLives", "starMode", "runTime", "allowSpectate", "weak", "metal", "campaignCourse",
    "gameAuto", "dmgAdd", "anarchy", "nerfVanish", "firstTimer" }
  for i, setting in ipairs(settings) do
    local option = mod_storage_load(setting)

    if starOnly then
      if (setting == "runTime") then
        if gGlobalSyncTable.starMode then
          option = mod_storage_load("neededStars")
        end
      else
        option = nil
      end
    elseif (setting == "dmgAdd" or setting == "anarchy" or setting == "runTime" or setting == "runnerLives") then
      if gGlobalSyncTable.mhMode == 2 then
        option = mod_storage_load("mini_" .. setting)
      elseif setting == "runTime" and gGlobalSyncTable.starMode then
        option = mod_storage_load("neededStars")
      elseif setting == "runnerLives" and gGlobalSyncTable.mhMode == 1 then
        option = mod_storage_load("switch_runnerLives")
      end
    elseif miniOnly then
      option = nil -- only load settings that change with minihunt
    end

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
  if not (miniOnly or starOnly) then
    local fileName = string.gsub(gGlobalSyncTable.romhackFile, " ", "_")
    option = mod_storage_load(fileName)
    if option ~= nil and tonumber(option) ~= nil then
      gGlobalSyncTable.starRun = tonumber(option)
    end
  end
end

-- save settings for host
function save_settings()
  if not network_is_server() then return end

  local settings = { "runnerLives", "starMode", "runTime", "allowSpectate", "weak", "mhMode", "metal", "campaignCourse",
    "gameAuto", "dmgAdd", "anarchy", "nerfVanish", "firstTimer" }
  for i, setting in ipairs(settings) do
    local option = gGlobalSyncTable[setting]

    if (setting == "dmgAdd" or setting == "anarchy" or setting == "runTime" or setting == "runnerLives") and gGlobalSyncTable.mhMode == 2 then
      setting = "mini_" .. setting
    elseif setting == "runTime" and gGlobalSyncTable.starMode then
      setting = "neededStars"
    elseif setting == "runnerLives" and gGlobalSyncTable.mhMode == 1 then
      setting = "switch_runnerLives"
    end

    if option ~= nil then
      if option == true then
        mod_storage_save(setting, "true")
      elseif option == false then
        mod_storage_save(setting, "false")
      elseif tonumber(option) ~= nil then
        mod_storage_save(setting, tostring(math.floor(option)))
      end
    end
  end
  -- special case
  option = gGlobalSyncTable.starRun
  local fileName = string.gsub(gGlobalSyncTable.romhackFile, " ", "_")
  if fileName ~= "custom" and option ~= nil then
    mod_storage_save(fileName, tostring(option))
  end
end

-- loads default settings for host
function default_settings()
  setup_hack_data(true, false, OmmEnabled)

  if gGlobalSyncTable.mhMode == 1 then
    gGlobalSyncTable.runnerLives = 0
    gGlobalSyncTable.runTime = 7200
    gGlobalSyncTable.anarchy = 0
    gGlobalSyncTable.dmgAdd = 0
  elseif gGlobalSyncTable.mhMode == 2 then
    gGlobalSyncTable.runnerLives = 0
    gGlobalSyncTable.runTime = 9000
    gGlobalSyncTable.anarchy = 1
    gGlobalSyncTable.dmgAdd = 2
  else
    gGlobalSyncTable.runnerLives = 1
    gGlobalSyncTable.runTime = 7200
    gGlobalSyncTable.anarchy = 0
    gGlobalSyncTable.dmgAdd = 0
  end

  gGlobalSyncTable.allowSpectate = true
  gGlobalSyncTable.starMode = false
  gGlobalSyncTable.weak = false
  gGlobalSyncTable.metal = false
  gGlobalSyncTable.gameAuto = 0
  gGlobalSyncTable.campaignCourse = 0
  gGlobalSyncTable.nerfVanish = true
  gGlobalSyncTable.firstTimer = true
  save_settings()
  return true
end

-- lists every setting
function list_settings()
  local settings = { "gameAuto", "campaignCourse", "mhMode", "starRun", "runnerLives", "runTime", "nerfVanish",
    "firstTimer", "weak", "metal", "dmgAdd", "anarchy", "allowSpectate" }
  local settingName = { "menu_auto", "menu_campaign", "menu_gamemode", "menu_category", "menu_run_lives", "menu_time",
    "menu_nerf_vanish", "menu_first_timer", "menu_weak", "menu_metal", "menu_dmgAdd", "menu_anarchy",
    "menu_allow_spectate" }
  for i, setting in ipairs(settings) do
    --- @type any
    local name = settingName[i]
    local value = nil

    if name == "menu_gamemode" then -- gamemode
      value = gGlobalSyncTable[setting]
      if value == 0 then
        value = "\\#00ffff\\" .. "Normal"
      elseif value == 1 then
        value = "\\#5aff5a\\" .. "Switch"
      elseif value == 2 then
        value = "\\#ffff5a\\" .. "Mini"
      end
    elseif name == "menu_time" then -- run time or stars needed
      name = nil
      local timeLeft = gGlobalSyncTable[setting]
      if gGlobalSyncTable.mhMode == 2 then
        name = "menu_time"
        local seconds = timeLeft // 30 % 60
        local minutes = (timeLeft // 1800)
        value = "\\#ffff5a\\" .. string.format("%d:%02d", minutes, seconds)
      elseif gGlobalSyncTable.starMode then
        value = trans("stars_left", timeLeft)
      else
        local seconds = timeLeft // 30 % 60
        local minutes = (timeLeft // 1800)
        value = trans("time_left", minutes, seconds)
      end
    elseif name == "menu_anarchy" then -- team attack
      value = gGlobalSyncTable[setting]
      if value == 3 then
        value = true
      elseif value == 1 then
        value = "\\#00ffff\\" .. trans("runners")
      elseif value == 2 then
        value = "\\#ff5a5a\\" .. trans("hunters")
      else
        value = false
      end
    elseif name == "menu_auto" then -- auto game
      if gGlobalSyncTable.mhMode == 2 then
        value = gGlobalSyncTable[setting]
        if value == 0 then
          value = false
        elseif value == 99 then
          value = "\\#5aff5a\\" .. "Auto"
        end
      end
    elseif name == "menu_category" then -- category
      if gGlobalSyncTable.mhMode ~= 2 then
        value = gGlobalSyncTable[setting]
        if value == -1 then
          value = "\\#5aff5a\\Any%"
        end
      end
    elseif (name == "menu_campaign") then -- minihunt campaign
      if gGlobalSyncTable.mhMode == 2 then
        value = gGlobalSyncTable[setting]
        if value == 0 then value = false end
      end
    elseif name == "menu_first_timer" then -- leader death timer
      if gGlobalSyncTable.mhMode == 2 then
        value = gGlobalSyncTable[setting]
      end
    elseif name == "menu_dmgAdd" then
      value = gGlobalSyncTable[setting]
      if value == 8 then
        value = "\\#ff5a5a\\OHKO"
      end
    else
      value = gGlobalSyncTable[setting]
    end

    if value == true then
      value = trans("on")
    elseif value == false then
      value = trans("off")
    elseif tonumber(value) then
      value = "\\#ffff5a\\" .. value
    end

    if value then
      if name then
        djui_chat_message_create(trans(name) .. ": " .. value)
      else
        djui_chat_message_create(value)
      end
    end
  end
end

-- camp timer + other stuff
function before_mario_update(m, inSelect)
  -- funny new vanish cap code
  if gGlobalSyncTable.nerfVanish then
    if m.playerIndex == 0 then
      if m.capTimer <= 1 then
        storeVanish = false
      elseif storeVanish == false and m.flags & MARIO_VANISH_CAP ~= 0 then
        storeVanish = true
        m.flags = m.flags & ~MARIO_VANISH_CAP
        popup_sound(SOUND_GENERAL2_RIGHT_ANSWER)
        djui_popup_create(trans("vanish_custom"), 1)
      elseif storeVanish and (m.controller.buttonDown & B_BUTTON) ~= 0 then
        m.flags = m.flags | MARIO_VANISH_CAP
        m.capTimer = m.capTimer - 2
        if m.capTimer < 1 then m.capTimer = 1 end
      else
        m.flags = m.flags & ~MARIO_VANISH_CAP
      end
    elseif m.flags & MARIO_VANISH_CAP ~= 0 and (m.controller.buttonDown & B_BUTTON) == 0 then
      m.flags = m.flags & ~MARIO_VANISH_CAP
    end
  end

  if m.playerIndex ~= 0 then return end

  -- prevent oob (this works for ssl area 3- I don't care about rom hacks for this
  if m.floor == nil then
    print("correcting oob")
    m.pos.x = 0
    m.pos.y = 0
    m.pos.z = -2000
  end

  local sMario = gPlayerSyncTable[0]
  if sMario.team == 1 then
    if m.freeze == true or (m.freeze ~= false and m.freeze > 2) then
      if campTimer == nil then
        campTimer = 600  -- 20 seconds
      end
      m.invincTimer = 60 -- 2 seconds
    elseif campTimer == nil and inSelect then
      campTimer = 300    -- 10 seconds
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
        on_death(m, true)
      end
      return
    end
  end
end

function show_rules()
  -- how to play message
  if gGlobalSyncTable.mhMode ~= 2 then
    if month == 13 or math.random(1, 100) == 1 then
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
    local bad = ROMHACK["badGuy_" .. lang] or ROMHACK.badGuy or "Bowser"
    runGoal = trans("any_bowser", bad)
  elseif ROMHACK == nil or ROMHACK.no_bowser ~= true then
    local bad = ROMHACK["badGuy_" .. lang] or ROMHACK.badGuy or "Bowser"
    runGoal = trans("collect_bowser", gGlobalSyncTable.starRun, bad)
  else
    runGoal = trans("collect_only", gGlobalSyncTable.starRun)
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

  local runLives = trans_plural("lives", (gGlobalSyncTable.runnerLives + 1))
  local needed = ""
  if gGlobalSyncTable.mhMode == 2 then
    -- nothing
  elseif (gGlobalSyncTable.starMode) then
    needed = "; " .. trans("stars_needed", gGlobalSyncTable.runTime)
  else
    local seconds = gGlobalSyncTable.runTime // 30 % 60
    local minutes = gGlobalSyncTable.runTime // 1800
    needed = "; " .. trans("time_needed", minutes, seconds)
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
    fun = trans("mini_goal", gGlobalSyncTable.runTime // 1800, (gGlobalSyncTable.runTime % 1800) // 30) .. " " .. fun
  end

  local text = string.format("\\#00ffff\\%s\\#ffffff\\%s: %s" ..
    "\n\\#ff5a5a\\%s\\#ffffff\\%s: %s" ..
    "\n\\#00ffff\\%s\\#ffffff\\: %s%s%s." ..
    "\n\\#ff5a5a\\%s\\#ffffff\\: %s%s%s." ..
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
end

function rule_command()
  show_rules()
  return true
end

hook_chat_command("rules", trans("rules_desc"), rule_command)

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
    do_star_stuff(false)
    return stats_table_hud()
  elseif menu or mhHideHud then -- Blocky's menu
    hide_both_hud(true)
    do_star_stuff(false)
    return handleMenu()
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
  elseif campTimer ~= nil then                                                  -- camp timer has top priority
    text = camp_hud(sMario)
  elseif gGlobalSyncTable.mhState ~= nil and gGlobalSyncTable.mhState >= 3 then -- game end
    text = victory_hud()
  elseif sMario.team == 1 then                                                  -- do runner hud
    text = runner_hud(sMario)
  else                                                                          -- do hunter hud
    text = hunter_hud(sMario)
  end

  -- player radar
  if sMario.team ~= 1 then
    for i = 0, (MAX_PLAYERS - 1) do
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

  do_star_stuff(true)

  -- work with boxes
  local o = obj_get_first_with_behavior_id(id_bhvExclamationBox)
  while o ~= nil do
    if exclamation_box_valid[o.oBehParams2ndByte] and o.oAction ~= 6 then
      local star = (o.oBehParams >> 24) + 1
      if o.oBehParams2ndByte ~= 8 then
        star = o.oBehParams2ndByte - 8
      end
      if star == 0 then print("ERROR!") end
      if gGlobalSyncTable.mhMode ~= 2 then
        local file = get_current_save_file_num() - 1
        local course_star_flags = save_file_get_star_flags(file, gNetworkPlayers[0].currCourseNum - 1)
        if course_star_flags & (1 << (star - 1)) == 0 then
          render_radar(o, box_radar[star], true, "box")
        end
      elseif star == gGlobalSyncTable.getStar then
        render_radar(o, box_radar[star], true, "box")
      end
    end
    o = obj_get_next_with_same_behavior_id(o)
  end

  -- red coins
  o = obj_get_nearest_object_with_behavior_id(gMarioStates[0].marioObj, id_bhvRedCoin)
  if o ~= nil then
    render_radar(o, ex_radar[1], true, "coin")
  end
  -- secrets
  o = obj_get_nearest_object_with_behavior_id(gMarioStates[0].marioObj, id_bhvHiddenStarTrigger)
  if o ~= nil then
    render_radar(o, ex_radar[2], true, "secret")
  end
  -- green demon
  if demonOn then
    o = obj_get_first_with_behavior_id(id_bhvGreenDemon)
    if o then
      render_radar(o, ex_radar[3], true, "demon")
    end
  end

  local scale = 0.5

  -- get width of screen and text
  local screenWidth = djui_hud_get_screen_width()
  local width = djui_hud_measure_text(remove_color(text)) * scale
  if width > screenWidth - 10 then -- shrink to fit
    scale = scale / (width / (screenWidth - 10))
    width = screenWidth - 10
  end

  local x = (screenWidth - width) * 0.5
  local y = 0

  djui_hud_set_color(0, 0, 0, 128);
  djui_hud_render_rect(x - 6, y, width + 12, 32 * scale);

  djui_hud_print_text_with_color(text, x, y, scale)

  -- death timer (extreme mode)
  scale = 0.5
  if (sMario.hard == 2 or leader) and sMario.team == 1 and (gGlobalSyncTable.mhState == 2 or gGlobalSyncTable.mhState == 1) then
    djui_hud_set_font(FONT_HUD)
    djui_hud_set_color(255, 255, 255, 255);

    local seconds = deathTimer // 30
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
      if _G.PersonalStarCounter then
        yOffset = 40
      elseif raceTimerOn ~= 0 then
        yOffset = 20
      end
    else -- omm hud is enabled
      yOffset = -25
      xOffset = -60
    end
    width = djui_hud_measure_text(text) * scale
    x = (screenWidth - width)

    if deathTimer <= 180 then
      xOffset = xOffset + math.random(-2, 2)
      yOffset = yOffset + math.random(-2, 2)
    end

    print_text_ex_hud_font(text, x + xOffset, y + yOffset, scale)
    width = djui_hud_measure_text(tostring(seconds)) * scale
    x = (screenWidth - width)
    y = y + 17
    djui_hud_print_text(tostring(seconds), x + xOffset, y + yOffset, scale)

    djui_hud_set_font(FONT_NORMAL)
  end

  -- makes the cap timer appear
  if storeVanish and gMarioStates[0].capTimer ~= 0 then
    if not hud_is_hidden() then
      djui_hud_set_font(FONT_HUD)
      djui_hud_set_color(255, 255, 255, 255);
      text = tostring(gMarioStates[0].capTimer // 30 + 1)
      width = djui_hud_measure_text(text)
      x = (screenWidth - width) * 0.5
      local screenHeight = djui_hud_get_screen_height()
      y = screenHeight - 32
      djui_hud_print_text(text, x, y, 1);
      djui_hud_set_font(FONT_NORMAL)
    end
  end

  -- star name for minihunt
  if gGlobalSyncTable.mhMode == 2 and gGlobalSyncTable.mhState == 2 then
    local np = gNetworkPlayers[0]
    text = get_custom_star_name(level_to_course[gGlobalSyncTable.gameLevel] or 0, gGlobalSyncTable.getStar)
    width = djui_hud_measure_text(text) * scale
    local screenHeight = djui_hud_get_screen_height()
    x = (screenWidth - width) * 0.5
    y = screenHeight - 16

    djui_hud_set_color(0, 0, 0, 128);
    djui_hud_render_rect(x - 6, y, width + 12, 32 * scale);

    djui_hud_set_color(255, 255, 255, 255);
    djui_hud_print_text(text, x, y, scale);
  elseif showSpeedrunTimer and gGlobalSyncTable.mhMode ~= 2 then
    local miliseconds = math.floor(gGlobalSyncTable.speedrunTimer / 30 % 1 * 100)
    local seconds = gGlobalSyncTable.speedrunTimer // 30 % 60
    local minutes = gGlobalSyncTable.speedrunTimer // 30 // 60 % 60
    local hours = gGlobalSyncTable.speedrunTimer // 30 // 60 // 60
    text = string.format("%d:%02d:%02d.%02d", hours, minutes, seconds, miliseconds)
    width = 118 * scale
    local screenHeight = djui_hud_get_screen_height()
    x = (screenWidth - width) * 0.5
    y = screenHeight - 16

    djui_hud_set_color(0, 0, 0, 128);
    djui_hud_render_rect(x - 6, y, width + 12, 32 * scale);

    djui_hud_set_color(255, 255, 255, 255);
    djui_hud_print_text(text, x, y, scale);
  end

  -- timer
  scale = 0.5
  if gGlobalSyncTable.mhTimer ~= nil and gGlobalSyncTable.mhTimer > 0 then
    local seconds = gGlobalSyncTable.mhTimer // 30 % 60
    local minutes = gGlobalSyncTable.mhTimer // 1800
    text = string.format("%d:%02d", minutes, seconds)
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
    local timeLeft, special = get_leave_requirements(sMario)
    if special ~= nil then
      text = special
    elseif timeLeft <= 0 then
      text = trans("can_leave")
    elseif gGlobalSyncTable.starMode then
      text = trans("stars_left", timeLeft)
    else
      local seconds = timeLeft // 30 % 60
      local minutes = (timeLeft // 1800)
      text = trans("time_left", minutes, seconds)
    end
  else
    return unstarted_hud(sMario)
  end
  return text
end

function hunter_hud(sMario)
  -- set player text
  local default = "\\#00ffff\\" .. trans("runners") .. ": "
  local text = default
  for i = 0, (MAX_PLAYERS - 1) do
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
    text = text:sub(1, -3)
  end

  return text
end

function timer_hud()
  -- set timer text
  local seconds = math.ceil(gGlobalSyncTable.mhTimer / 30)
  local text = trans("until_hunters", seconds)
  if seconds > 10 then
    text = trans("until_runners", (seconds - 10))
  end

  return text
end

function victory_hud()
  -- set win text
  local text = trans("win", "\\#ff5a5a\\" .. trans("hunters"))
  if gGlobalSyncTable.mhState == 5 then
    text = trans("game_over")
  elseif gGlobalSyncTable.mhState > 3 then
    text = trans("win", "\\#00ffff\\" .. trans("runners"))
  end
  return text
end

function unstarted_hud(sMario)
  -- display role
  local roleName, colorString = get_role_name_and_color(sMario)
  return colorString .. roleName
end

function camp_hud(sMario)
  return trans("camp_timer", campTimer // 30)
end

-- removes color string
function remove_color(text, get_color)
  local start = text:find("\\")
  local next = 1
  while (next ~= nil) and (start ~= nil) do
    start = text:find("\\")
    if start ~= nil then
      next = text:find("\\", start + 1)
      if next == nil then
        next = text:len() + 1
      end

      if get_color then
        local color = text:sub(start, next)
        local render = text:sub(1, start - 1)
        text = text:sub(next + 1)
        return text, color, render
      else
        text = text:sub(1, start - 1) .. text:sub(next + 1)
      end
    end
  end
  return text
end

-- converts hex string to RGB values
function convert_color(text)
  if text:sub(2, 2) ~= "#" then
    return nil
  end
  text = text:sub(3, -2)
  local rstring = text:sub(1, 2) or "ff"
  local gstring = text:sub(3, 4) or "ff"
  local bstring = text:sub(5, 6) or "ff"
  local astring = text:sub(7, 8) or "ff"
  local r = tonumber("0x" .. rstring) or 255
  local g = tonumber("0x" .. gstring) or 255
  local b = tonumber("0x" .. bstring) or 255
  local a = tonumber("0x" .. astring) or 255
  return r, g, b, a
end

-- prints text on the screen... with color!
function djui_hud_print_text_with_color(text, x, y, scale, alpha)
  djui_hud_set_color(255, 255, 255, alpha or 255)
  local space = 0
  local color = ""
  local render = ""
  text, color, render = remove_color(text, true)
  while render ~= nil do
    local r, g, b, a = convert_color(color)
    djui_hud_print_text(render, x + space, y, scale);
    if r then djui_hud_set_color(r, g, b, alpha or a) end
    space = space + djui_hud_measure_text(render) * scale
    text, color, render = remove_color(text, true)
  end
  djui_hud_print_text(text, x + space, y, scale);
end

-- used in many commands
function get_specified_player(msg)
  local playerID = tonumber(msg)
  if msg == "" then
    playerID = 0
  end

  local np = nil
  if playerID == nil then
    for i = 0, (MAX_PLAYERS - 1) do
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
  elseif playerID ~= math.floor(playerID) or playerID < 0 or playerID > (MAX_PLAYERS - 1) then
    djui_chat_message_create(trans("bad_id"))
    return nil
  else
    np = gNetworkPlayers[playerID]
  end
  if not np.connected then
    djui_chat_message_create(trans("no_such_player"))
    return nil
  end

  return playerID, np
end

-- uses custom star names if aplicable
function get_custom_star_name(course, starNum)
  if ROMHACK.starNames ~= nil then
    if gGlobalSyncTable.ee then
      if ROMHACK.starNames_ee ~= nil and ROMHACK.starNames_ee[course * 10 + starNum] ~= nil then
        return ROMHACK.starNames_ee[course * 10 + starNum]
      end
    elseif ROMHACK.starNames[course * 10 + starNum] ~= nil then
      return ROMHACK.starNames[course * 10 + starNum]
    end
  end
  if ROMHACK.vagueName then
    return ("Star " .. starNum)
  end
  return get_star_name(course, starNum)
end

-- uses custom level names if applicable
function get_custom_level_name(course, level, area)
  if ROMHACK.levelNames and ROMHACK.levelNames[level * 10 + area] then
    return ROMHACK.levelNames[level * 10 + area]
  elseif ROMHACK.vagueName then
    return ("Course " .. course)
  end
  return get_level_name(course, level, area)
end

-- TroopaParaKoopa's Level Cooldown (and other stuff)
function on_warp()
  local sMario = gPlayerSyncTable[0]
  local np = gNetworkPlayers[0]
  if sMario.spectator ~= 1 then
    gMarioStates[0].invincTimer = 150 -- 5 seconds

    if sMario.team == 1 and gGlobalSyncTable.mhMode ~= 2 then
      if localPrevCourse ~= np.currCourseNum then
        sMario.runTime = 0
        localRunTime = 0
        sMario.allowLeave = false
        lastObtainable = -1
      end
      neededRunTime, localRunTime = calculate_leave_requirements(sMario, localRunTime)
    end

    if warpCooldown == 0 then
      warpCount = 0
    elseif warpTree[1] == nil or warpTree[1] ~= (np.currLevelNum * 10 + np.currAreaIndex) then
      warpCount = 0
    elseif warpCount >= 3 then
      gMarioStates[0].hurtCounter = gMarioStates[0].hurtCounter + (warpCount * 4)
      djui_popup_create(trans("warp_spam"), 1)
      warpCount = warpCount + 1
    else
      warpCount = warpCount + 1
    end
    warpCooldown = 300 -- 5 seconds
    table.insert(warpTree, (np.currLevelNum * 10 + np.currAreaIndex))
    if #warpTree > 2 then table.remove(warpTree, 1) end
  end

  local cname = ROMHACK.levelNames and ROMHACK.levelNames[np.currLevelNum * 10 + np.currAreaIndex]
  if cname and np.currCourseNum ~= 0 then -- replace the name of the course
    local course = np.currCourseNum
    if course < 16 then                   -- replace act names with.. themselves (there's no replace course function)
      local num = " " .. tostring(course) .. " "
      if course > 9 then num = tostring(course) .. " " end
      smlua_text_utils_course_acts_replace(course, num .. cname:upper(), get_star_name_ascii(course, 1, 1),
        get_star_name_ascii(course, 1, 2), get_star_name_ascii(course, 1, 3), get_star_name_ascii(course, 1, 4),
        get_star_name_ascii(course, 1, 5), get_star_name_ascii(course, 1, 6))
    elseif course ~= 0 then
      smlua_text_utils_secret_star_replace(course, "   " .. cname:upper())
    end
  end

  -- set lighting
  if month == 10 then
    set_override_skybox(BACKGROUND_HAUNTED)
    set_lighting_dir(2, 500)   -- dark?
    set_lighting_color(1, 100) -- purple tint
    set_lighting_color(0, 100)
  elseif month == 12 then
    set_override_skybox(BACKGROUND_SNOW_MOUNTAINS)
    set_lighting_color(0, 200) -- blue tint
    set_override_envfx(ENVFX_SNOW_NORMAL)
  elseif np.currLevelNum == LEVEL_LOBBY then
    set_lighting_dir(2, 300) -- dark?
  else
    set_lighting_dir(2, 0)
  end

  if gGlobalSyncTable.mhState == 0 then -- and background music
    set_lobby_music(month)
    --play_music(0, custom_seq, 1)
  end

  if gGlobalSyncTable.mhMode ~= 2 and gGlobalSyncTable.mhState ~= 0 then
    local data = {
      id = PACKET_OTHER_WARP,
      index = np.globalIndex,
      level = np.currLevelNum,
      course = np.currCourseNum,
      area = np.currAreaIndex,
      act = np.currActNum,
      prevCourse = localPrevCourse,
    }

    if on_packet_other_warp(data, true) then
      network_send(false, data)
    end
  end
  localPrevCourse = np.currCourseNum
end

function on_player_disconnected(m)
  local np = gNetworkPlayers[m.playerIndex]
  -- unassign attack
  if np.globalIndex == attackedBy then attackedBy = nil end


  -- for host only
  if network_is_server() then -- rejoin handling
    local sMario = gPlayerSyncTable[m.playerIndex]
    sMario.wins, sMario.kills, sMario.maxStreak, sMario.hardWins, sMario.maxStar, sMario.exWins, sMario.beenRunner = 0, 0,
        0, 0, 0, 0,
        0 -- unassign stats

    local runner = (sMario.team == 1)
    local discordID = sMario.discordID or 0
    sMario.discordID = 0
    sMario.placement = 999
    sMario.fasterActions = true
    if runner or gGlobalSyncTable.mhMode == 2 then
      local grantRunner = (sMario.team == 1 and gGlobalSyncTable.mhMode ~= 2)
      local runtime = sMario.runTime or 0
      local lives = sMario.runnerLives or gGlobalSyncTable.runnerLives

      print(tostring(discordID), "left")

      become_hunter(sMario) -- be hunter by default
      if discordID ~= 0 then
        local playerColor = network_get_player_text_color_string(np.localIndex)
        local name = playerColor .. np.name
        rejoin_timer[discordID] = {
          name = name,
          timer = 3600,
          runner = grantRunner,
          lives = lives,
          stars = sMario
              .totalStars
        } -- 2 minutes
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

-- create the Green Demon object (built from 1up, obviously)
E_MODEL_DEMON = smlua_model_util_get_id("demon_geo") or E_MODEL_1UP
--- @param o Object
function demon_init(o)
  o.oFlags = o.oFlags | OBJ_FLAG_COMPUTE_ANGLE_TO_MARIO | OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE
  obj_set_billboard(o)

  cur_obj_set_hitbox_radius_and_height(30, 30)
  o.oGraphYOffset = 30
  bhv_1up_common_init()
end

--- @param o Object
function demon_loop(o)
  o.oIntangibleTimer = 0

  if o.oAction == 1 then
    local demonStop = (gMarioStates[0].invincTimer > 0)
    local demonDespawn = ((not demonOn) or gPlayerSyncTable[0].team ~= 1 or gGlobalSyncTable.mhState ~= 2)
    demon_move_towards_mario(o)
    if demonDespawn then
      o.activeFlags = ACTIVE_FLAG_DEACTIVATED
    elseif demonStop then
      -- nothing
    elseif dist_between_objects(o, gMarioStates[0].marioObj) > 5000 then -- clip at far distances
      o.oVelX = o.oForwardVel * sins(o.oMoveAngleYaw);
      o.oVelZ = o.oForwardVel * coss(o.oMoveAngleYaw);
      obj_update_pos_vel_xz()
      o.oPosY = o.oPosY + o.oVelY
    else
      object_step()
    end
  else
    bhv_1up_hidden_in_pole_loop()
  end
end

--- @param o Object
function demon_move_towards_mario(o)
  local player = gMarioStates[0].marioObj
  if (player) then
    local sp34 = player.header.gfx.pos.x - o.oPosX;
    local sp30 = player.header.gfx.pos.y + 120 - o.oPosY;
    local sp2C = player.header.gfx.pos.z - o.oPosZ;
    local sp2A = atan2s(math.sqrt(sqr(sp34) + sqr(sp2C)), sp30);

    obj_turn_toward_object(o, player, 16, 0x1000);
    o.oMoveAnglePitch = approach_s16_symmetric(o.oMoveAnglePitch, sp2A, 0x1000);

    if obj_check_if_collided_with_object(o, player) == 1 then
      play_sound(SOUND_GENERAL_COLLECT_1UP, player.header.gfx.cameraToObject) -- replace?
      o.activeFlags = ACTIVE_FLAG_DEACTIVATED
      gMarioStates[0].health = 0xFF                                           -- die
    end
  end
  local vel = 30
  if gMarioStates[0].waterLevel >= gMarioStates[0].pos.y then
    vel = 15 -- half speed if mario is underwater
  end
  o.oVelY = sins(o.oMoveAnglePitch) * vel
  o.oForwardVel = coss(o.oMoveAnglePitch) * vel
end

id_bhvGreenDemon = hook_behavior(nil, OBJ_LIST_LEVEL, false, demon_init, demon_loop)

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
  [ACT_ENTERING_STAR_DOOR] = true,
  [ACT_PUSHING_DOOR] = true,
  [ACT_PULLING_DOOR] = true,
  [ACT_UNLOCKING_STAR_DOOR] = true,
  [ACT_BACKWARD_WATER_KB] = true,
  [ACT_FORWARD_WATER_KB] = true,
  [ACT_RELEASING_BOWSER] = true,
  [ACT_HEAVY_THROW] = true,
  [ACT_BUTT_STUCK_IN_GROUND] = true,
  [ACT_FEET_STUCK_IN_GROUND] = true,
  [ACT_HEAD_STUCK_IN_GROUND] = true,
}

-- based off of example
function mario_update(m)
  if not didFirstJoinStuff then return end

  local sMario = gPlayerSyncTable[m.playerIndex]
  local np = gNetworkPlayers[m.playerIndex]

  -- for b3313; prevents quick travel
  if ROMHACK and ROMHACK.name == "B3313" then
    if is_game_paused() and m.controller.buttonPressed & Y_BUTTON ~= 0 then
      if on_pause_exit() == false then
        m.controller.buttonPressed = m.controller.buttonPressed & ~Y_BUTTON
        play_sound(SOUND_MENU_CAMERA_BUZZ, m.marioObj.header.gfx.cameraToObject)
      end
    end
  end

  -- fast actions by troopa
  if faster_actions[m.action] and sMario.fasterActions then
    m.marioObj.header.gfx.animInfo.animFrame = m.marioObj.header.gfx.animInfo.animFrame + 1
  elseif m.action == ACT_UNLOCKING_KEY_DOOR then                                                                       -- nobody wants you we want a dancing floating key (edit) we dont have dancing key anymore
    set_anim_to_frame(m, m.marioObj.header.gfx.animInfo.curAnim.loopEnd)
  elseif m.action == ACT_WARP_DOOR_SPAWN then                                                                          -- the real (torpa)
    set_mario_action(m, ACT_IDLE, 0)
  elseif (m.action == ACT_SPAWN_NO_SPIN_AIRBORNE or m.action == ACT_SPAWN_SPIN_AIRBORNE) and sMario.fasterActions then -- dawg wtf??!?!? (torpa again)
    if m.floor and m.floor.type ~= SURFACE_DEATH_PLANE and m.floor.type ~= SURFACE_VERTICAL_WIND then
      m.pos.y = math.max(m.waterLevel, m.floorHeight)                                                                  -- go to floor to prevent fall damage
      set_mario_action(m, ACT_IDLE, 0)
    else
      set_mario_action(m, ACT_TRIPLE_JUMP, 0) -- if we spawn in the void, do a triple jump (prevents softlock with omm + ztar attack 2)
    end
  end

  -- force spectate
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
        mod_storage_save("demon_unlocked", "true")
        djui_popup_create(trans("demon_unlock"), 1)
      end
    else
      demonTimer = 0
    end
  end

  -- set and decrement regain cap timer
  if m.playerIndex == 0 then
    if m.capTimer > 0 then
      cooldownCaps = m.flags & MARIO_SPECIAL_CAPS
      if storeVanish then cooldownCaps = cooldownCaps | MARIO_VANISH_CAP end
      regainCapTimer = 60
    elseif regainCapTimer > 0 then
      regainCapTimer = regainCapTimer - 1
    end
  end

  -- spawn 1up if it does not exist
  if m.playerIndex == 0 and demonOn then
    local demonOkay = (sMario.team == 1 and m.health > 0xFF and m.invincTimer <= 0 and gGlobalSyncTable.mhState == 2)
    local o = obj_get_first_with_behavior_id(id_bhvGreenDemon)

    if (not o) and demonOkay then
      spawn_non_sync_object(
        id_bhvGreenDemon,
        E_MODEL_DEMON,
        m.pos.x, m.pos.y, m.pos.z,
        nil)
    end
  end

  -- run death if health is 0, or reset death status
  if m.health <= 0xFF then
    on_death(m, true)
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
      leader = calculate_leader()
      global_popup_lang("rejoin_success", data.name, nil, 1)
      rejoin_timer[discordID] = nil
    end
  end

  if month == 13 then np.overrideModelIndex = CT_LUIGI end -- april fools

  -- parkour stuff
  if np.currLevelNum == LEVEL_LOBBY and m.playerIndex == 0 then
    local dflags = hud_get_value(HUD_DISPLAY_FLAGS)
    local raceTimerOn = dflags & HUD_DISPLAY_FLAGS_TIMER
    if raceTimerOn ~= 0 then
      parkourTimer = parkourTimer + 1
      m.invincTimer = 2                                     -- prevent interaction
      hud_set_value(HUD_DISPLAY_TIMER, parkourTimer)
      if m.floor and m.floor.type == SURFACE_TIMER_END then -- finish
        local time = parkourTimer
        local miliseconds = math.floor(time / 30 % 1 * 100)
        local seconds = time // 30 % 60
        local minutes = time // 30 // 60 % 60
        local text = string.format("%02d:%02d.%02d", minutes, seconds, miliseconds)
        hud_set_value(HUD_DISPLAY_FLAGS, dflags & ~HUD_DISPLAY_FLAGS_TIMER)
        djui_chat_message_create(text)

        local ref = "parkourRecord"
        if OmmEnabled then ref = "parkourRecordOmm" end
        local record = mod_storage_load(ref)
        if tonumber(record) == nil or tonumber(record) > time then
          play_star_fanfare()
          djui_chat_message_create(trans("new_record"))
          mod_storage_save(ref, tostring(time))
        else
          play_race_fanfare()
        end
      elseif m.pos.y < 200 and m.floor and m.floor.type ~= SURFACE_HARD and m.pos.y == m.floorHeight then
        parkourTimer = 0
        hud_set_value(HUD_DISPLAY_FLAGS, dflags & ~HUD_DISPLAY_FLAGS_TIMER)
        hud_set_value(HUD_DISPLAY_TIMER, 0)
      end
    elseif m.floor and m.floor.type == SURFACE_HARD then -- back on starting platform
      parkourTimer = 0
      hud_set_value(HUD_DISPLAY_FLAGS, dflags | HUD_DISPLAY_FLAGS_TIMER)
      if m.pos.y > 2000 then
        m.pos.y = m.floorHeight
      end
    elseif m.floorHeight > 200 and raceTimerOn == 0 and parkourTimer == 0 then -- prevent cheese by jumping over starting platform (omm)
      m.pos.x, m.pos.y, m.pos.z = -12, 63, -2476
    end

    if m.invincTimer > 2 then m.invincTimer = 2 end -- prevent flashing
    if m.pos.y < -1500 then                         -- falling effect like in mk wii
      set_mario_particle_flags(m, ACTIVE_PARTICLE_FIRE, 0)
    end
  end

  -- display as paused
  if sMario.pause and not mhHideHud then -- I need this for screenshots!
    m.marioBodyState.modelState = MODEL_STATE_NOISE_ALPHA
    m.invincTimer = 60
  end
  -- display metal particles
  if (m.flags & MARIO_METAL_CAP) ~= 0 then
    set_mario_particle_flags(m, PARTICLE_SPARKLES, 0)
  end

  if ROMHACK.special_run ~= nil then
    ROMHACK.special_run(m, gotStar)
  end

  -- set descriptions
  local rolename, _, color = get_role_name_and_color(sMario)
  if gGlobalSyncTable.mhMode == 2 and frameCounter > 60 then
    network_player_set_description(np, trans_plural("stars", sMario.totalStars or 0), color.r, color.g, color.b, 255)
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
      network_player_set_description(np, trans_plural("lives", sMario.runnerLives), color.r, color.g, color.b, 255)
    end
  else
    network_player_set_description(np, rolename, color.r, color.g, color.b, 255)
  end

  -- keep player in certain levels
  if sMario.spectator ~= 1 then
    local correctAct = gGlobalSyncTable.getStar
    if correctAct == 7 then correctAct = 6 end
    if np.currCourseNum == 0 then correctAct = 0 end
    if didFirstJoinStuff and ROMHACK ~= nil and m.playerIndex == 0 and gGlobalSyncTable.mhState == 0 and np.currLevelNum ~= (((not ROMHACK.noLobby) and LEVEL_LOBBY) or gLevelValues.entryLevel) then
      warp_beginning()
    elseif m.playerIndex == 0 and gGlobalSyncTable.mhState == 2 and gGlobalSyncTable.mhMode == 2 and (np.currLevelNum ~= gGlobalSyncTable.gameLevel or np.currActNum ~= correctAct) then
      m.health = 0x880
      warp_beginning()
    end
  end

  -- if the game is inactive, disable the camp timer
  if gGlobalSyncTable.mhState ~= nil and (gGlobalSyncTable.mhState == 0 or gGlobalSyncTable.mhState >= 3) then
    campTimer = nil
    return
  end

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

  -- Rename stars in OMM (I'm trying my best to correct desync issues)
  if OmmEnabled and m.playerIndex == 0 and ommStarID then
    if (m.action == ACT_OMM_GRAB_STAR and m.actionTimer == 35) then
      network_send(true, {
        id = PACKET_OMM_STAR_RENAME,
        act = ommStar,
        course = np.currCourseNum,
        obj_id = ommStarID,
      })
      if ommRenameTimer == 0 then
        local name = get_custom_star_name(np.currCourseNum, ommStar)
        _G.OmmApi.omm_register_star_behavior(ommStarID, name, string.upper(name))
      end
    elseif ommRenameTimer > 0 then
      ommRenameTimer = ommRenameTimer - 1
      if ommRenameTimer == 0 then
        local name = get_custom_star_name(np.currCourseNum, ommStar)
        _G.OmmApi.omm_register_star_behavior(ommStarID, name, string.upper(name))
      end
    end
  end

  -- hunter update
  if sMario.team ~= 1 then return hunter_update(m) end
  -- runner update
  return runner_update(m, sMario)
end

function runner_update(m, sMario)
  -- fix stupid desync bug
  if sMario.runnerLives == nil then
    sMario.runnerLives = gGlobalSyncTable.runnerLives
  elseif sMario.runnerLives < 0 then
    sMario.team = 0
  end
  local np = gNetworkPlayers[m.playerIndex]

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
        for i = 1, (MAX_PLAYERS - 1) do
          if gPlayerSyncTable[i].team == 1 and gNetworkPlayers[i].connected then
            local theirNP = gNetworkPlayers[i] -- daft variable naming conventions
            local theirSMario = gPlayerSyncTable[i]
            if theirSMario.runTime ~= nil and (np.currLevelNum == theirNP.currLevelNum) and (np.currActNum == theirNP.currActNum) and localRunTime < theirSMario.runTime then
              localRunTime = theirSMario.runTime
              neededRunTime, localRunTime = calculate_leave_requirements(sMario, localRunTime)
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
    [ACT_STAR_DANCE_WATER] = 30,   -- 1 second
    [ACT_WAITING_FOR_DIALOG] = 10,
    [ACT_DEATH_EXIT_LAND] = 10,
    [ACT_SPAWN_SPIN_LANDING] = 100,
    [ACT_SPAWN_NO_SPIN_LANDING] = 100,
    [ACT_IN_CANNON] = 10,
    [ACT_PICKING_UP] = 10,    -- can't differentiate if this is a heavy object
    [ACT_OMM_GRAB_STAR] = 40, -- the action is 80 frames long
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
      m.invincTimer = 60                                     -- 2 seconds
      m.prevAction = m.action
    elseif (sMario.hard ~= 0) and frameCounter % 2 == 0 then -- half speed drowning
      m.health = m.health + 1                                -- water drain is 1 (decimal) per frame
    end
  end

  -- hard mode
  if (sMario.hard == 1) and m.health > 0x400 then
    m.health = 0x400
    if m.playerIndex == 0 then deathTimer = 900 end
  elseif (sMario.hard == 2) or leader then -- extreme mode
    if (sMario.hard == 2) then
      if m.health > 0xFF and ((m.hurtCounter <= 0 and m.action ~= ACT_BURNING_FALL and m.action ~= ACT_BURNING_GROUND and m.action ~= ACT_BURNING_JUMP) or (m.healCounter > 0 and m.action == ACT_LAVA_BOOST)) then
        m.health = 500
      elseif m.action ~= ACT_LAVA_BOOST then
        m.health = 0xFF
      end
    end
    if m.playerIndex == 0 and deathTimer > 0 then
      if m.healCounter > 0 and m.health > 0xFF and deathTimer <= 1800 then
        deathTimer = deathTimer + 8
        if not OmmEnabled then deathTimer = deathTimer + 8 end -- double gain without OMM
      elseif deathTimer > 1800 then
        deathTimer = 1800
      end

      if not runner_invincible[m.action] then
        deathTimer = deathTimer - 1
        if deathTimer % 30 == 0 and deathTimer <= 330 then
          play_sound(SOUND_GENERAL2_SWITCH_TICK_FAST, m.marioObj.header.gfx.cameraToObject)
        end
      end
    elseif m.playerIndex == 0 and m.health > 0xFF then
      -- explode code
      m.freeze = 60
      local o = spawn_non_sync_object(id_bhvExplosion, E_MODEL_EXPLOSION, m.pos.x, m.pos.y,
        m.pos.z, nil)
      if (m.action & ACT_FLAG_ON_POLE) ~= 0 then -- prevent soft lock
        set_mario_action(m, ACT_STANDING_DEATH, 0)
      else
        take_damage_and_knock_back(m, o)
      end
      m.health = 0xFF
      m.hurtCounter = 0x8
      if m.playerIndex == 0 then deathTimer = 900 end
    end
  elseif m.playerIndex == 0 then
    deathTimer = 900
  end
  if ((sMario.hard and sMario.hard ~= 0) and sMario.runnerLives > 0) then sMario.runnerLives = 0 end

  -- add stars
  if m.playerIndex == 0 and gotStar ~= nil then
    if gGlobalSyncTable.mhMode == 2 then
      if gotStar == gGlobalSyncTable.getStar then
        gGlobalSyncTable.votes = 0
        sMario.totalStars = sMario.totalStars + 1

        -- send message
        network_send_include_self(false, {
          id = PACKET_RUNNER_COLLECT,
          runnerID = np.globalIndex,
          star = gotStar,
          level = np.currLevelNum,
          course = np.currCourseNum,
          area = np.currAreaIndex,
        })

        if (sMario.hard == 2 or leader) then deathTimer = deathTimer + 300 end

        -- new star for minihunt
        if gGlobalSyncTable.mhMode == 2 then
          if gGlobalSyncTable.campaignCourse ~= 0 then
            gGlobalSyncTable.campaignCourse = gGlobalSyncTable.campaignCourse + 1
          end
          random_star(np.currCourseNum, gGlobalSyncTable.campaignCourse)
        end
      end
    else
      if gGlobalSyncTable.starMode then
        localRunTime = localRunTime + 1    -- 1 star
      else
        localRunTime = localRunTime + 1800 -- 1 minute
      end

      neededRunTime, localRunTime = calculate_leave_requirements(sMario, localRunTime, gotStar)
      -- send message
      if m.prevNumStarsForDialog < m.numStars or ROMHACK.isUnder then
        local unlocked = (gGlobalSyncTable.starRun ~= -1 and m.numStars >= gGlobalSyncTable.starRun and m.prevNumStarsForDialog < gGlobalSyncTable.starRun)
        network_send_include_self(false, {
          id = PACKET_RUNNER_COLLECT,
          runnerID = np.globalIndex,
          star = gotStar,
          level = np.currLevelNum,
          course = np.currCourseNum,
          area = np.currAreaIndex,
          unlocked = unlocked,
        })
      end
      if sMario.hard == 2 then deathTimer = deathTimer + 300 end
    end
  end

  m.prevNumStarsForDialog = m.numStars -- this also disables some dialogue, which helps with the fast pace
  if m.playerIndex == 0 then
    gotStar = nil
  end
end

function hunter_update(m)
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

  -- only local mario at this point
  if m.playerIndex ~= 0 then return end

  deathTimer = 900

  -- camp timer for hunters!?
  if campTimer == nil and m.action == ACT_IN_CANNON then
    campTimer = 600 -- 20 seconds
  elseif m.action ~= ACT_IN_CANNON then
    campTimer = nil
  end

  -- detect victory for hunters (only host to avoid disconnect bugs)
  if network_is_server() then
    -- check for runners
    local stillrunners = false
    for i = 0, (MAX_PLAYERS - 1) do
      if gPlayerSyncTable[i].team == 1 and gNetworkPlayers[i].connected then
        stillrunners = true
        break
      end
    end

    if stillrunners == false and gGlobalSyncTable.mhState < 3 and gGlobalSyncTable.mhMode == 0 then
      for id, data in pairs(rejoin_timer) do
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
  if action == ACT_EXIT_LAND_SAVE_DIALOG or action == ACT_DEATH_EXIT_LAND or (action == ACT_HARD_BACKWARD_GROUND_KB and m.action == ACT_SPECIAL_DEATH_EXIT) then
    m.area.camera.cutscene = 0
    play_cutscene(m.area.camera) -- needed to fix toad bug
    set_camera_mode(m.area.camera, m.area.camera.defMode, 1)
    m.forwardVel = 0
    if action == ACT_EXIT_LAND_SAVE_DIALOG then
      m.faceAngle.y = m.faceAngle.y + 0x8000
    end
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
--- @param o Object
function on_allow_interact(m, o, type)
  if m.playerIndex == 0 and type == INTERACT_STAR_OR_KEY and ROMHACK.isUnder then -- star detection is silly
    local obj_id = get_id_from_behavior(o.behavior)
    if (o.oInteractionSubtype & INT_SUBTYPE_GRAND_STAR) == 0 then
      gotStar = (o.oBehParams >> 24) + 1
      ommStar = gotStar
      ommStarID = obj_id
    end
  end

  if type == INTERACT_DOOR and not ROMHACK.isUnder then
    local starsNeeded = (o.oBehParams >> 24) or 0 -- this gets the star count
    if gGlobalSyncTable.starRun ~= nil and gGlobalSyncTable.starRun ~= -1 and gGlobalSyncTable.starRun <= starsNeeded then
      local np = gNetworkPlayers[0]
      starsNeeded = gGlobalSyncTable.starRun
      if (np.currAreaIndex ~= 2) and ROMHACK.ddd == true then
        starsNeeded = starsNeeded - 1
      end
    end

    if m.numStars >= starsNeeded then
      return false
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

  if type == INTERACT_STAR_OR_KEY then
    if m.playerIndex ~= 0 then return true end -- only local player

    local np = gNetworkPlayers[m.playerIndex]
    if (np.currLevelNum == LEVEL_BOWSER_1 or np.currLevelNum == LEVEL_BOWSER_2) then -- is a key (stars in bowser levels are technically keys)
      sMario.allowLeave = true

      -- send message
      network_send_include_self(false, {
        id = PACKET_RUNNER_COLLECT,
        runnerID = np.globalIndex,
        level = np.currLevelNum,
        course = np.currCourseNum,
        area = np.currAreaIndex,
      })
    elseif (o.oInteractionSubtype & INT_SUBTYPE_GRAND_STAR) ~= 0 then -- handle grand star
      -- send message
      network_send_include_self(false, {
        id = PACKET_RUNNER_COLLECT,
        runnerID = np.globalIndex,
        level = np.currLevelNum,
        course = np.currCourseNum,
        area = np.currAreaIndex,
        grand = true
      })
    else
      gotStar = (o.oBehParams >> 24) + 1 -- set what star we got
      ommStar = gotStar
      ommStarID = obj_id
    end
  end
  return true
end

-- hard mode
function hard_mode_command(msg_)
  local msg = msg_ or ""
  local args = split(msg, " ")
  local toggle = args[1] or ""
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
      djui_chat_message_create(trans("hard_toggle", trans("on")))
    else
      djui_chat_message_create(trans("extreme_toggle", trans("on")))
    end
    if gGlobalSyncTable.mhState ~= 2 then
      inHard = gPlayerSyncTable[0].hard
    elseif inHard ~= gPlayerSyncTable[0].hard then
      inHard = 0
      djui_chat_message_create(trans("no_hard_win"))
    end
  elseif string.lower(toggle) == "off" then
    if gPlayerSyncTable[0].hard ~= 2 then
      djui_chat_message_create(trans("hard_toggle", trans("off")))
    else
      djui_chat_message_create(trans("extreme_toggle", trans("off")))
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

hook_chat_command("hard", trans("hard_desc"), hard_mode_command)

paused = false
function do_pause()
  local m = gMarioStates[0]
  local sMario = gPlayerSyncTable[0]
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

-- plays local sound unless popup sounds are turned off
function popup_sound(sound)
  if playPopupSounds then
    play_sound(sound, gMarioStates[0].marioObj.header.gfx.cameraToObject)
  end
end

-- chat related stuff
function tc_command(msg)
  local sMario = gPlayerSyncTable[0]
  if string.lower(msg) == "on" then
    if disable_chat_hook then
      djui_chat_message_create(trans("wrong_mode"))
      return true
    end
    sMario.teamChat = true
    djui_chat_message_create(trans("tc_toggle", trans("on")))
  elseif string.lower(msg) == "off" then
    if disable_chat_hook then
      djui_chat_message_create(trans("wrong_mode"))
      return true
    end
    sMario.teamChat = false
    djui_chat_message_create(trans("tc_toggle", trans("off")))
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
  djui_chat_message_create(trans("to_team") .. msg)
  local m = gMarioStates[0]
  play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, m.marioObj.header.gfx.cameraToObject)

  return true
end

function on_packet_tc(data, self)
  local sender = data.sender
  local receiverteam = data.receiverteam
  local msg = data.msg
  local sMario = gPlayerSyncTable[0]
  if sMario.team == receiverteam then
    local np = network_player_from_global_index(sender)
    if np ~= nil then
      local playerColor = network_get_player_text_color_string(np.localIndex)
      djui_chat_message_create(playerColor .. np.name .. trans("from_team") .. msg)
      local m = gMarioStates[0]
      play_sound(SOUND_MENU_MESSAGE_APPEAR, m.marioObj.header.gfx.cameraToObject)
    end
  end
end

function on_chat_message(m, msg)
  if disable_chat_hook then return end
  local np = gNetworkPlayers[m.playerIndex]
  local playerColor = network_get_player_text_color_string(m.playerIndex)
  local name = playerColor .. np.name

  if _G.mhApi.chatValidFunction ~= nil and (_G.mhApi.chatValidFunction(m, msg) == false) then
    return false
  elseif _G.mhApi.chatModifyFunction ~= nil then
    local msg_, name_ = _G.mhApi.chatModifyFunction(m, msg)
    if name_ then name = name_ end
    if msg_ then msg = msg_ end
  end

  local sMario = gPlayerSyncTable[m.playerIndex]
  if sMario.teamChat == true then
    local sMario = gPlayerSyncTable[m.playerIndex]
    local mySMario = gPlayerSyncTable[0]

    if m.playerIndex == 0 then
      djui_chat_message_create(trans("to_team") .. msg)
      play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, m.marioObj.header.gfx.cameraToObject)
    elseif mySMario.team == sMario.team then
      djui_chat_message_create(playerColor .. np.name .. trans("from_team") .. msg)
      play_sound(SOUND_MENU_MESSAGE_APPEAR, gMarioStates[0].marioObj.header.gfx.cameraToObject)
    end

    return false
  elseif m.playerIndex == 0 then
    local lowerMsg = string.lower(msg)

    local dispRules = string.find(lowerMsg, "como se") -- start of "how do..." I think
        or string.find(lowerMsg, "how do")
        or string.find(lowerMsg, "collect star")
    local dispLang = string.find(lowerMsg, "ingl") -- for spanish speakers asking if this is an english (inglés) server; covers both with and without accent
    local dispSkip = gGlobalSyncTable.mhMode == 2 and (string.find(lowerMsg, "impossible"))
    local dispFix = m.input & INPUT_OFF_FLOOR == 0 and
        (string.find(lowerMsg, "stuck") or string.find(lowerMsg, "softlock"))
    local dispMenu = string.find(lowerMsg, "menu") -- is this too broad?

    if dispMenu then
      popup_sound(SOUND_GENERAL2_RIGHT_ANSWER)
      djui_popup_create(trans("open_menu"), 1)
    elseif dispLang then
      popup_sound(SOUND_GENERAL2_RIGHT_ANSWER)
      djui_popup_create(trans("to_switch", "ES", nil, "es"), 1)
    elseif dispSkip then
      popup_sound(SOUND_GENERAL2_RIGHT_ANSWER)
      djui_popup_create(trans("vote_info"), 1)
    elseif dispFix then
      force_idle_state(m)
      reset_camera(m.area.camera)
      m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags & ~GRAPH_RENDER_INVISIBLE
      popup_sound(SOUND_GENERAL2_RIGHT_ANSWER)
      djui_popup_create(trans("unstuck"), 1)
    elseif dispRules then
      popup_sound(SOUND_GENERAL2_RIGHT_ANSWER)
      djui_popup_create(trans("rule_command"), 1)
    end
  end
  if network_is_server() then
    local desync = string.find(msg:lower(), "desync")
    if desync then
      popup_sound(SOUND_GENERAL2_RIGHT_ANSWER)
      djui_popup_create(trans("unstuck"), 1)
      desync_fix_command()
    end
  end
  local tag = get_tag(m.playerIndex)
  if tag and tag ~= "" then
    djui_chat_message_create(name .. " " .. tag .. ": \\#dcdcdc\\" .. msg)

    if m.playerIndex == 0 then
      play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, m.marioObj.header.gfx.cameraToObject)
    else
      play_sound(SOUND_MENU_MESSAGE_APPEAR, gMarioStates[0].marioObj.header.gfx.cameraToObject)
    end
    return false
  end
end

hook_chat_command("tc", trans("tc_desc"), tc_command)
hook_event(HOOK_ON_CHAT_MESSAGE, on_chat_message)

-- stats
function stats_command(msg)
  if not is_game_paused() then
    showingStats = not showingStats
  end
  return true
end

hook_chat_command("stats", trans("stats_desc"), stats_command)

-- speedrun timer
showSpeedrunTimer = true -- show speedrun timer
demonOn = false
demonUnlocked = mod_storage_load("demon_unlocked") or false
demonTimer = 0
if mod_storage_load("showSpeedrunTimer") == "false" then showSpeedrunTimer = false end

-- chat popup sound setting
playPopupSounds = true
if mod_storage_load("playPopupSounds") == "false" then playPopupSounds = false end

function show_timer(msg)
  if string.lower(msg) == "on" then
    showSpeedrunTimer = true
    mod_storage_save("showSpeedrunTimer", "true")
    return true
  elseif string.lower(msg) == "off" then
    showSpeedrunTimer = false
    mod_storage_save("showSpeedrunTimer", "false")
    return true
  end
  return false
end

hook_chat_command("timer", trans("menu_timer_desc"), show_timer)

-- for Ztar Attack 2
function stalk_command(msg, noFeedback)
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

  local playerID, np
  if msg == "" then
    for i = 1, (MAX_PLAYERS - 1) do
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
    playerID, np = get_specified_player(msg)
  end

  if playerID == 0 then
    return false
  elseif playerID == nil then
    return true
  end

  local theirSMario = gPlayerSyncTable[playerID]
  if theirSMario.team ~= 1 then
    local name = remove_color(np.name)
    djui_chat_message_create(trans("not_runner", name))
    return true
  end

  local myNP = gNetworkPlayers[0]
  if obj_get_first_with_behavior_id(id_bhvActSelector) == nil and (np.currLevelNum ~= myNP.currLevelNum or np.currAreaIndex ~= myNP.currAreaIndex or np.currActNum ~= myNP.currActNum) then
    warp_to_level(np.currLevelNum, np.currAreaIndex, np.currActNum)
  end
  return true
end

hook_chat_command("stalk", trans("stalk_desc"), stalk_command)

function on_course_enter()
  attackedBy = nil

  -- justEntered = true

  if gGlobalSyncTable.romhackFile == "vanilla" then
    omm_replace(OmmEnabled)
  elseif gNetworkPlayers[0].currLevelNum == LEVEL_LOBBY then -- erase signs when not in vanilla
    local sign = obj_get_first_with_behavior_id(id_bhvMessagePanel)
    while sign do
      obj_mark_for_deletion(sign)
      sign = obj_get_next_with_same_behavior_id(sign)
    end
  end
  if gGlobalSyncTable.mhState == 0 then -- and background music
    set_lobby_music(month)
    --play_music(0, custom_seq, 1)
  end

  omm_disable_non_stop_mode(gGlobalSyncTable.mhMode == 2)                -- change non stop mode setting for minihunt
  if gGlobalSyncTable.mhMode == 2 and gGlobalSyncTable.mhState == 2 then -- unlock cannon and caps in minihunt
    local file = get_current_save_file_num() - 1
    local np = gNetworkPlayers[0]
    save_file_set_flags(SAVE_FLAG_HAVE_METAL_CAP)
    save_file_set_flags(SAVE_FLAG_HAVE_VANISH_CAP)
    save_file_set_flags(SAVE_FLAG_HAVE_WING_CAP)
    save_file_set_star_flags(file, np.currCourseNum, 0x80)

    -- for Board Bowser's Sub
    if ROMHACK.ddd and gGlobalSyncTable.gameLevel == LEVEL_DDD then
      save_file_clear_flags(SAVE_FLAG_HAVE_KEY_2)
      if gGlobalSyncTable.getStar == 1 then
        save_file_clear_flags(SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR)
      else
        save_file_set_flags(SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR)
      end
    end
  else -- fix star count
    local m = gMarioStates[0]
    local courseMax = 25
    local courseMin = 1
    m.numStars = save_file_get_total_star_count(get_current_save_file_num() - 1, courseMin - 1, courseMax - 1)
    m.prevNumStarsForDialog = m.numStars
  end
end

-- recalculate leader in minihunt
function calculate_leader()
  if gGlobalSyncTable.mhMode ~= 2 or gGlobalSyncTable.firstTimer == false then
    return false
  end
  local toBeat = gPlayerSyncTable[0].totalStars
  if toBeat < 1 then return false end
  for i = 1, MAX_PLAYERS - 1 do
    if gNetworkPlayers[i].connected and gPlayerSyncTable[i].totalStars and gPlayerSyncTable[i].totalStars > toBeat then
      return false
    end
  end
  return true
end

function on_packet_runner_collect(data, self)
  runnerID = data.runnerID
  if runnerID ~= nil then
    leader = calculate_leader()
    local np = network_player_from_global_index(runnerID)
    local playerColor = network_get_player_text_color_string(np.localIndex)
    local place = get_custom_level_name(data.course, data.level, data.area)
    if data.star ~= nil then -- star
      local name = get_custom_star_name(data.course, data.star)

      if not self then
        popup_sound(SOUND_MENU_STAR_SOUND)
      end

      if gGlobalSyncTable.mhMode == 2 or not (OmmEnabled and gServerSettings.stayInLevelAfterStar == 1) then -- OMM shows its own progress, so don't show this
        djui_popup_create(trans("got_star", (playerColor .. np.name)) .. "\\#ffffff\\\n" .. place .. "\n" .. name, 2)
      end
    elseif data.switch ~= nil then -- switch
      if not self then
        popup_sound(SOUND_GENERAL_ACTIVATE_CAP_SWITCH)
      end

      local switch_message = "hit_switch_yellow" -- used in b3313
      if data.switch == 0 then
        switch_message = "hit_switch_red"
      elseif data.switch == 1 then
        switch_message = "hit_switch_green"
      elseif data.switch == 2 then
        switch_message = "hit_switch_blue"
      end
      djui_popup_create(trans(switch_message, (playerColor .. np.name)), 2)
    elseif data.grand ~= nil then -- grand star
      if not self then
        popup_sound(SOUND_GENERAL_GRAND_STAR)
      end

      djui_popup_create(trans("got_star", (playerColor .. np.name)) .. "\\#ffffff\\\nGrand Star", 2)
    else -- key
      if not self then
        popup_sound(SOUND_GENERAL_UNKNOWN3_LOWPRIO)
      end

      djui_popup_create(trans("got_key", (playerColor .. np.name)) .. "\\#ffffff\\\n" .. place, 2)
    end
  end

  if data.unlocked then
    if playPopupSounds then
      play_peachs_jingle()
    end
    djui_popup_create(trans("got_all_stars"), 1)
  end
end

function on_packet_kill(data, self)
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
        m.healCounter = 0x32           -- full health
        m.hurtCounter = 0x0
        popup_sound(SOUND_GENERAL_STAR_APPEARS)
        -- save kill, but only in-game
        local kSMario = gPlayerSyncTable[0]
        if gGlobalSyncTable.mhState ~= 0 then
          local kills = tonumber(mod_storage_load("kills"))
          if kills == nil then
            kills = 0
          end
          mod_storage_save("kills", tostring(math.floor(kills) + 1))
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
            mod_storage_save("maxStreak", tostring(math.floor(killCombo)))
            kSMario.maxStreak = killCombo
          end
        end
        killTimer = 300       -- 10 seconds
      elseif data.runner then -- play sound if runner dies
        popup_sound(SOUND_OBJ_BOWSER_LAUGH)
      end

      -- sidelined if this was their last life
      if data.death ~= true then
        djui_popup_create(trans("killed", (kPlayerColor .. killerNP.name), (playerColor .. np.name)), 1)
      else
        djui_popup_create(trans("sidelined", (kPlayerColor .. killerNP.name), (playerColor .. np.name)), 1)
      end
    else
      if data.death ~= true then -- runner only lost one life
        djui_popup_create(trans("lost_life", (playerColor .. np.name)), 1)
      else                       -- runner lost all lives
        djui_popup_create(trans("lost_all", (playerColor .. np.name)), 1)
      end
      if data.runner then -- play sound if runner dies
        popup_sound(SOUND_OBJ_BOWSER_LAUGH)
      end
    end
  end

  -- new runner for switch mode
  if newRunnerID ~= nil then
    local np = network_player_from_global_index(newRunnerID)
    local sMario = gPlayerSyncTable[np.localIndex]
    become_runner(sMario)
    if np.localIndex == 0 and gGlobalSyncTable.mhMode ~= 2 then
      sMario.runTime = data.time or 0
      localRunTime = data.time or 0
      neededRunTime, localRunTime = calculate_leave_requirements(sMario, localRunTime)
      print("new time:", data.time)
    end
    on_packet_role_change({ id = PACKET_ROLE_CHANGE, index = newRunnerID }, true)
  end

  _G.mhApi.onKill(killer, killed, data.runner, data.death, data.time, newRunnerID)
end

-- part of the API
function get_kill_combo()
  return killCombo
end

function on_game_end(data, self)
  if gGlobalSyncTable.mhMode == 2 and data.winner ~= -1 then
    local winCount = 1
    local winners = {}
    local weWon = true
    local singlePlayer = true
    local record = false
    for i = 0, (MAX_PLAYERS - 1) do
      local sMario = gPlayerSyncTable[i]
      local np = gNetworkPlayers[i]

      if i == 0 then
        local maxStar = tonumber(mod_storage_load("maxStar"))
        if maxStar == nil then
          maxStar = 0
        end
        if sMario.totalStars > maxStar then
          mod_storage_save("maxStar", tostring(sMario.totalStars))
          sMario.maxStar = sMario.totalStars
          record = true
        end
      elseif np.connected and sMario.spectator ~= 1 then
        singlePlayer = false
      end

      if np.connected and sMario.totalStars ~= nil and sMario.totalStars >= winCount then
        local playerColor = network_get_player_text_color_string(np.localIndex)
        local name = playerColor .. np.name
        if sMario.totalStars == winCount then
          table.insert(winners, name)
        else
          winners = { name }
          winCount = sMario.totalStars
          if i ~= 0 then weWon = false end
        end
      end
    end

    if singlePlayer then
      djui_chat_message_create(trans("mini_score", gPlayerSyncTable[0].totalStars))
    elseif #winners > 0 then
      djui_chat_message_create(trans("winners"))
      for i, name in ipairs(winners) do
        djui_chat_message_create(name)
      end
      if weWon then
        local sMario = gPlayerSyncTable[0]
        add_win(sMario)
      end
    else
      djui_chat_message_create(trans("no_winners"))
    end

    if record then
      play_star_fanfare()
      djui_chat_message_create(trans("new_record"))
    else
      play_race_fanfare()
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

function on_packet_stats(data, self)
  djui_chat_message_create(trans_plural(data.stat, data.name, data.value))
end

function add_win(sMario)
  if network_player_connected_count() <= 1 then return end -- don't increment wins in solo
  local winType = "wins"
  if inHard == 1 then
    winType = "hardWins"
  elseif inHard == 2 then
    winType = "exWins"
  end
  if gGlobalSyncTable.mhMode ~= 2 then
    winType = winType .. "_standard"
  end
  local wins = tonumber(mod_storage_load(winType))
  if wins == nil then
    wins = 0
  end
  mod_storage_save(winType, tostring(math.floor(wins) + 1))
  sMario[winType] = sMario[winType] + 1
end

function on_packet_kill_combo(data, self)
  if data.kills > 5 then
    djui_popup_create(trans("kill_combo_large", data.name, data.kills), 1)
    popup_sound(SOUND_MARIO_YAHOO_WAHA_YIPPEE)
  else
    djui_popup_create(trans("kill_combo_" .. tostring(data.kills), data.name), 1)
  end
end

-- vote skip
iVoted = false
function skip_command(msg)
  local totalVotes = gGlobalSyncTable.votes
  if gGlobalSyncTable.mhMode ~= 2 then
    djui_chat_message_create(trans("wrong_mode"))
    return true
  elseif gGlobalSyncTable.mhState ~= 2 then
    djui_chat_message_create(trans("not_started"))
    return true
  elseif msg:lower() == "force" and has_mod_powers(0) then
    totalVotes = 98 -- force skip
  elseif iVoted then
    djui_chat_message_create(trans("already_voted"))
    return true
  end

  local np = gNetworkPlayers[0]
  local playercolor = network_get_player_text_color_string(0)
  totalVotes = totalVotes + 1
  gGlobalSyncTable.votes = totalVotes
  iVoted = true
  network_send_include_self(true, {
    id = PACKET_VOTE,
    votes = totalVotes,
    voted = playercolor .. np.name,
  })
  return true
end

hook_chat_command("skip", trans("menu_skip_desc"), skip_command)
function on_packet_vote(data, self)
  local count = network_player_connected_count() -- this includes spectators
  local maxVotes = count
  if count > 2 then
    maxVotes = math.ceil(count / 2) -- half the lobby
  elseif count == 1 then
    iVoted = false
    local np = gNetworkPlayers[0]
    if gGlobalSyncTable.campaignCourse ~= 0 then
      gGlobalSyncTable.campaignCourse = gGlobalSyncTable.campaignCourse + 1
    end
    random_star(np.currCourseNum, gGlobalSyncTable.campaignCourse)
    gGlobalSyncTable.votes = 0
    return
  end

  djui_chat_message_create(string.format("%s (%d/%d)", trans("vote_skip", data.voted), data.votes, maxVotes))
  if maxVotes <= data.votes then
    djui_chat_message_create(trans("vote_pass"))
    iVoted = false
    if self then
      local np = gNetworkPlayers[0]
      if gGlobalSyncTable.campaignCourse ~= 0 then
        gGlobalSyncTable.campaignCourse = gGlobalSyncTable.campaignCourse + 1
      end
      random_star(np.currCourseNum, gGlobalSyncTable.campaignCourse)
      gGlobalSyncTable.votes = 0
    end
  else
    djui_chat_message_create(trans("vote_info"))
  end
end

-- for global popups, so it appears in their language
function global_popup_lang(langID, format, format2_, lines)
  network_send_include_self(false, {
    id = PACKET_LANG_POPUP,
    langID = langID,
    format = format,
    format2 = format2_,
    lines = lines,
  })
end

function on_packet_lang_popup(data, self)
  djui_popup_create(trans(data.langID, data.format, data.format2), data.lines)
  leader = calculate_leader()
end

-- popup for this player's role changing
function on_packet_role_change(data, self)
  local np = network_player_from_global_index(data.index)
  local playerColor = network_get_player_text_color_string(np.localIndex)
  local sMario = gPlayerSyncTable[np.localIndex]
  local roleName, color = get_role_name_and_color(sMario)
  djui_popup_create(trans("now_role", playerColor .. np.name, color .. roleName), 1)
  if np.localIndex == 0 and sMario.team == 1 then
    popup_sound(SOUND_GENERAL_SHORT_STAR)
  end
end

-- change name of this star for all players
function on_packet_omm_star_rename(data, self)
  local name = get_custom_star_name(data.course, data.act)
  _G.OmmApi.omm_register_star_behavior(data.obj_id, name, string.upper(name))
  popup_sound(SOUND_MENU_STAR_SOUND)
  if ommStarID == data.obj_id then
    ommRenameTimer = 10
  end
end

function on_packet_other_warp(data, self)
  local name = ROMHACK.levelNames and ROMHACK.levelNames[data.level * 10 + data.area]
  local np = network_player_from_global_index(data.index)
  local playerColor = network_get_player_text_color_string(np.localIndex)
  local sMario = gPlayerSyncTable[np.localIndex]

  local send = false
  --[[if name then
    djui_popup_create(trans("custom_enter",playerColor..np.name,name),1)
    send = true
  end]]
  local sound = nil
  local bowserFight = false
  if (data.course == COURSE_BITDW or data.course == COURSE_BITFS or data.course == COURSE_BITS) then
    local playSound = (data.course ~= data.prevCourse)

    if (data.level == LEVEL_BOWSER_1 or data.level == LEVEL_BOWSER_2 or data.level == LEVEL_BOWSER_3) then
      if name == nil then
        name = "Bowser 3"
        if data.level == LEVEL_BOWSER_1 then
          name = "Bowser 1"
        elseif data.level == LEVEL_BOWSER_2 then
          name = "Bowser 2"
        end
        if not self then
          djui_popup_create(trans("custom_enter", playerColor .. np.name, name), 1)
        end
      end
      bowserFight = true
      playSound = true
    end

    send = playSound
    if sMario.team == 1 and playSound then sound = SOUND_MOVING_ALMOST_DROWNING end
  end
  if ((data.course ~= data.prevCourse) or (bowserFight and sMario.team ~= 1)) then
    local mySMario = gPlayerSyncTable[0]
    local myNP = gNetworkPlayers[0]
    send = true
    if (not self) and (sMario.team ~= mySMario.team or sMario.team == 1) and sMario.spectator ~= 1 then
      if sMario.team == 1 then
        if data.course ~= 0 and (ROMHACK.hubStages == nil or ROMHACK.hubStages[data.course] == nil) and (data.course == myNP.currCourseNum and data.act == myNP.currActNum) then
          sound = SOUND_MENU_REVERSE_PAUSE + 61569 -- interesting unused sound
        elseif data.prevCourse ~= 0 and (ROMHACK.hubStages == nil or ROMHACK.hubStages[data.prevCourse] == nil) and data.prevCourse == myNP.currCourseNum then
          sound = SOUND_MENU_MARIO_CASTLE_WARP2
        end
      elseif data.course ~= 0 and (ROMHACK.hubStages == nil or ROMHACK.hubStages[data.course] == nil) and (data.course == myNP.currCourseNum and data.act == myNP.currActNum) then
        sound = SOUND_OBJ_BOO_LAUGH_SHORT
      end
    end
  end
  if sound and not self then popup_sound(sound) end
  return send
end

-- packets
PACKET_RUNNER_COLLECT = 0
PACKET_KILL = 1
PACKET_MH_START = 2
PACKET_TC = 3
PACKET_GAME_END = 4
PACKET_STATS = 5
PACKET_KILL_COMBO = 6
PACKET_VOTE = 7
PACKET_LANG_POPUP = 8
PACKET_ROLE_CHANGE = 9
PACKET_OMM_STAR_RENAME = 10
PACKET_OTHER_WARP = 11
sPacketTable = {
  [PACKET_RUNNER_COLLECT] = on_packet_runner_collect,
  [PACKET_KILL] = on_packet_kill,
  [PACKET_MH_START] = do_game_start,
  [PACKET_TC] = on_packet_tc,
  [PACKET_GAME_END] = on_game_end,
  [PACKET_STATS] = on_packet_stats,
  [PACKET_KILL_COMBO] = on_packet_kill_combo,
  [PACKET_VOTE] = on_packet_vote,
  [PACKET_LANG_POPUP] = on_packet_lang_popup,
  [PACKET_ROLE_CHANGE] = on_packet_role_change,
  [PACKET_OMM_STAR_RENAME] = on_packet_omm_star_rename,
  [PACKET_OTHER_WARP] = on_packet_other_warp,
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
    print("Hack set to " .. newVal)
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
    set_lobby_music(month)
  end
end

-- hooks
hook_event(HOOK_UPDATE, update)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)
hook_event(HOOK_BEFORE_SET_MARIO_ACTION, before_set_mario_action)
hook_event(HOOK_ALLOW_PVP_ATTACK, allow_pvp_attack)
hook_event(HOOK_ON_PVP_ATTACK, on_pvp_attack)
hook_event(HOOK_ON_PLAYER_DISCONNECTED, on_player_disconnected)
hook_event(HOOK_ON_PAUSE_EXIT, on_pause_exit)
hook_event(HOOK_ON_LEVEL_INIT, on_course_enter)
hook_event(HOOK_ON_WARP, on_warp)
hook_event(HOOK_ON_SYNC_VALID, on_course_sync)
hook_event(HOOK_ON_PACKET_RECEIVE, on_packet_receive)
hook_event(HOOK_ON_DEATH, on_death)
hook_event(HOOK_ON_INTERACT, on_interact)
hook_on_sync_table_change(gGlobalSyncTable, "romhackFile", "change_hack", on_rom_hack_changed)
hook_on_sync_table_change(gGlobalSyncTable, "mhMode", "change_mode", on_mode_changed)
hook_on_sync_table_change(gGlobalSyncTable, "mhState", "change_state", on_state_changed)

-- prevent constant error stream
if not trans then
  trans = function(_, _, _, _)
    return "LANGUAGE MODULE DID NOT LOAD"
  end
  trans_plural = trans
end
