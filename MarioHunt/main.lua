-- name: ! \\#00ffff\\Mario\\#ff5a5a\\Hunt\\#dcdcdc\\ (v2.7.4) !
-- incompatible: gamemode nametags
-- description: A gamemode based off of Beyond's concept. Hunters stop Runners from clearing the game!\n\nProgramming: EmilyEmmi, Blocky, Sunk, EmeraldLockdown, Sprinter05, Squishy, Agent X\n\nTranslations: KanHeaven, SonicDark, EpikCool, green, N64 Mario, PietroM, Skeltan, Blocky, N64, Mr. L-Ore\n\nSome graphics: LeoHaha, Key's Artworks, AquarriusAlex, RoxasYTB\n\"Shooting Star Summit\" port: pieordie1\n\nAlso thanks to: ColbyRayz!, SilverOrigins
-- deluxe: true

LITE_MODE = false                        -- disables some features
MAX_PLAYERS = gServerSettings.maxPlayers -- don't really see any downsides

menu = false
mhHideHud = false
expectedHudState = false                     -- for custom huds
gGlobalSoundSource = { x = 0, y = 0, z = 0 } -- used for behaviors
levelSize = 8192

if not LITE_MODE then
  LEVEL_LOBBY = level_register('level_lobby_entry', COURSE_NONE, 'Lobby', 'lobby', 28000, 0x28, 0x28, 0x28)
end

-- this reduces lag apparently
local djui_chat_message_create, djui_popup_create, djui_hud_measure_text, djui_hud_print_text, djui_hud_set_color, djui_hud_set_font, djui_hud_set_resolution, network_player_set_description, network_get_player_text_color_string, network_is_server, is_game_paused, get_current_save_file_num, save_file_get_star_flags, save_file_get_flags, djui_hud_render_rect, warp_to_level, mod_storage_save, mod_storage_load =
    djui_chat_message_create, djui_popup_create, djui_hud_measure_text, djui_hud_print_text, djui_hud_set_color,
    djui_hud_set_font, djui_hud_set_resolution, network_player_set_description, network_get_player_text_color_string,
    network_is_server, is_game_paused, get_current_save_file_num, save_file_get_star_flags, save_file_get_flags,
    djui_hud_render_rect, warp_to_level, mod_storage_save, mod_storage_load
local GST = gGlobalSyncTable
local PST = gPlayerSyncTable
local NetP = gNetworkPlayers
local MST = gMarioStates
---@type MarioState
local m0, sMario0, np0 = MST[0], PST[0], NetP[0]

-- player settings
hunterAppearance = tonumber(mod_storage_load("hunterApp")) or 2
runnerAppearance = tonumber(mod_storage_load("runnerApp")) or 2
nerfVanishButton = tonumber(mod_storage_load("vanButton")) or 2
reportButton = tonumber(mod_storage_load("reportButton")) or 11
guardButton = tonumber(mod_storage_load("guardButton")) or 11
menuButton = tonumber(mod_storage_load("menuButton")) or 1
saboButton = tonumber(mod_storage_load("saboButton")) or 4

showMiniMap = true
if mod_storage_load("showMiniMap") == "false" then showMiniMap = false end
showRadar = true
if mod_storage_load("showRadar") == "false" then showRadar = false end
romhackCam = false
if mod_storage_load("romhackCam") == "true" then romhackCam = true end
showSpeedrunTimer = true
if mod_storage_load("showSpeedrunTimer") == "false" then showSpeedrunTimer = false end
showLastStarTime = false
if mod_storage_load("showLastStarTime") == "true" then showLastStarTime = true end
noSeason = false
if mod_storage_load("noSeason") == "true" then noSeason = true end
invincParticle = false
if mod_storage_load("invincParticle") == "true" then invincParticle = true end
showPaintingOverlays = true
if mod_storage_load("showPaintingOverlays") == "false" then showPaintingOverlays = false end

local rejoin_timer = {} -- rejoin timer for runners (host only)
local mute_storage = {}
if network_is_server() then
  -- all settings here
  GST.runnerLives = 1      -- the lives runners get (0 is a life)
  GST.runTime = 7200       -- time runners must stay in stage to leave (default: 4 minutes)
  GST.starRun = 70         -- stars runners must get to face bowser; star doors and infinite stairs will be disabled accordingly
  GST.noBowser = false     -- ignore bowser requirement; only stars are needed
  GST.allowSpectate = true -- hunters can spectate
  GST.allowStalk = false   -- players can use /stalk
  GST.starMode = false     -- use stars collected instead of timer
  GST.weak = false         -- cut invincibility frames in half
  GST.mhMode = 0           -- game modes, as follows:
  --[[
    0: Normal
    1: Swap
    2: Mini
  ]]
  GST.blacklistData = "none" -- encrypted data for blacklist
  GST.campaignCourse = 0     -- campaign course for minihunt (64 tour)
  GST.gameAuto = 0           -- automatically start new games (0: off; pos: that many runners; -1: auto; <-1: max+x+2)
  GST.anarchy = 0            -- team attack; comes with 4 options
  --[[
    0 - Neither team
    1 - Runners only
    2 - Hunters only
    3 - Everyone
  ]]
  GST.dmgAdd = 0            -- Adds additional damage to pvp attacks against runners (0-8; -1 for ohko)
  GST.nerfVanish = true     -- Changes vanish cap a bit
  GST.firstTimer = true     -- First place player in MiniHunt gets death timer
  GST.forceSpectate = false -- force all players to spectate unless otherwise stated
  GST.countdown = 300       -- countdown before hunters can move (normal/swap), default 300 (10 s)
  GST.doubleHealth = false  -- double runner health
  GST.voidDmg = 3           -- damage taken from void, in wedges (-1 for ohko)
  GST.freeRoam = false      -- disable star and key requirements (except for Bowser 3)
  GST.starHeal = false      -- star heal
  GST.stalkTimer = 150      -- frozen timer when using /stalk
  GST.starSetting = gServerSettings.stayInLevelAfterStar
  GST.starStayOld = true
  GST.spectateOnDeath = false
  GST.maxShuffleTime = 0      -- time between shuffles (0 is off)
  GST.maxGlobalTalk = 2700    -- time when all players can talk after reported a body in mysteryhunt (0 is always, -1 is off)
  GST.confirmHunter = true    -- display message when a hunter is killed in mysteryhunt
  GST.huntersWinEarly = false -- Victory for Hunters in MysteryHunt when matching runner count (like in among us)
  GST.showOnMap = 1           -- What team is visible on the minimap and has a radar (0: none 1: runners 2: hunters 3: opponents 4: all)

  -- now for other data
  GST.mhState = 0 -- game state
  --[[
    0: not started
    1: timer
    2: game started
    3: game ended (hunters win)
    4: game ended (runners win)
    5: game ended (minihunt)
  ]]
  GST.mhTimer = 0          -- timer in frames (game is 30 FPS)
  GST.speedrunTimer = 0    -- the total amount of time we've played in frames
  GST.gameLevel = 0        -- level for MiniHunt
  GST.getStar = 0          -- what star must be collected (for MiniHunt)
  GST.votes = 0            -- amount of votes for skipping (MiniHunt)
  GST.otherSave = false    -- using other save file
  GST.bowserBeaten = false -- used for some rom hacks as a two-part completion process
  GST.ee = false           -- used for SM74
  GST.pause = false        -- global pause
  GST.lastStarTime = 0     -- when the last star was collected
  GST.shuffleTimer = 0     -- time until next shuffle
  GST.globalTalkTimer = 0  -- time while all players can talk in mysteryhunt
  GST.saboActive = 0       -- which sabotage is active, from 0-3 (0 is none)
  GST.saboTimer = 0        -- how long a sabotage has been active, or cooldown
end

if LITE_MODE then
  custom_seq = 2
elseif get_os_name() ~= "Mac OSX" then                                             -- replacing sequnce past 0x47 crashes the game on mac
  custom_seq = 0x53
  smlua_audio_utils_replace_sequence(custom_seq, 0x25, 65, "Shooting_Star_Summit") -- for lobby; hopefully there's no conflicts
else
  custom_seq = 0x41
  smlua_audio_utils_replace_sequence(custom_seq, 0x25, 65, "Shooting_Star_Summit") -- for lobby; hopefully there's no conflicts
end


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
gLevelValues.mushroom1UpHeal = 0  -- edited to heal 4 instead of 8
gLevelValues.numCoinsToLife = 255 -- do NOT put this at 0.
gLevelValues.showStarNumber = 1

local gotStar = nil                                       -- what star we just got
local died = false                                        -- if we've died (because on_death runs every frame of death fsr)
local didFirstJoinStuff = false                           -- if all of the initial code was run (rules message, etc.)
local didHudHook = false                                  -- make sure hud hook is added last
frameCounter = 120                                        -- frame counter over 4 seconds
local cooldownCaps = 0                                    -- stores m.flags, to see what caps are on cooldown
local regainCapTimer = 0                                  -- timer for being able to recollect a cap
local storeVanish = false                                 -- temporarily stores the vanish cap for pvp purposes
local campTimer                                           -- for camping actions (such as reading text or being in the star menu), nil means it is inactive
warpCooldown = 0                                          -- to avoid warp spam
local warpTree = {}
local killTimer = 0                                       -- timer for kills in quick succession
local killCombo = 0                                       -- kills in quick succession
local attackedBy                                          -- global index of player that attacked last
local attackedByObj                                       -- object id that attacked last
local hitTimer = 0                                        -- timer for being hit by another player
local localRunTime = 0                                    -- our run time is usually made local for less lag
local neededRunTime = 0                                   -- how long we need to wait to leave this course
local inHard = 0                                          -- what hard mode we started in (to prevent cheesy hard/extreme mode wins)
local deathTimer = 900                                    -- for extreme mode
local guardCooldown = 0                                   -- mysteryhunt spectators can guard players
local localPrevCourse = 0                                 -- for entrance popups
local localPrevAct = 0
local lastObtainable = -1                                 -- doesn't display if it's the same number
local leader = false                                      -- if we're winning in minihunt
local scoreboard = {}                                     -- table of everyone's score
month = 0                                                 -- the current month of the year, for holiday easter eggs
local parkourTimer = 0                                    -- timer for parkour
noSettingDisp = true                                      -- disables setting change display temporarily
runnerTarget = -1                                         -- targetted runner with /target
local actualHealthBeforeRender = 0x880                    -- used for custom huds
local prevHealth = 0x880                                  -- used to fix issue with warps and double health
local halvedHealCounter = 0                               -- \
local halvedHurtCounter = 0                               -- | double health related
local prevCustomWedge = 0                                 -- /
prevSafePos = { x = 0, y = 0, z = 0, obj = nil }          -- used with voidDmg
local cheatLocal = false                                  -- used for races
local localPlayTime = 0                                   -- used for tracking playtime
miniRedCoinCollect = 0                                    -- tracks red coins in minihunt
miniSecretCollect = 0                                     -- tracks secrets in minihunt
local centerRulesTimer = 0                                -- important rules in center of screen
local campaignRecordValid = false                         -- for solo minihunt campaign
local hunterKickTimer = 0                                 -- prevent camping in bowser levels
local prevGameEnd = false                                 -- prevent winning multiple times
local expectedLocation = { level = 0, area = 0, act = 0 } -- get around level desync
local defaultTempo = 0                                    -- \ for mega bomb
local lastTempoMulti = 1                                  -- / for mega bomb
local MEGA_BOMB_LENGTH = 180                              -- total time the mega bomb lasts, in seconds

movesetEnabled = false                                    -- is true if using any other moveset
local ACT_OMM_STAR_DANCE = nil                            -- the grab star action in OMM Rebirth (set later)
local lastStarID = nil                                    -- the object id of the star we got; for OMM
local lastStar = nil                                      -- what star we just got; for omm (gotStar is set to nil earlier)
local ommRenameTimer = 0                                  -- after someone gets the same kind of star, there is a timer until someone can have their star renamed on their end

DEBUG_SAFE_SURFACE = false                                -- spawns sparkles at safe floor
DEBUG_NO_VICTORY = false                                  -- prevents winning
DEBUG_SHOW_PING = false                                   -- show ping in players list instead of role

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
  --save_settings()
  omm_disable_mode_for_minihunt(GST.mhMode == 2) -- change non stop mode setting for minihunt
  close_menu()
  showingStats = false
  showingRules = false
  campaignRecordValid = false
  local cmd = data.cmd or ""

  if GST.mhMode == 2 then
    GST.mhState = 2

    if data.challenge then
      campaignRecordValid = true
      GST.mhTimer = 0
    elseif string.lower(cmd) ~= "continue" then
      GST.mhTimer = GST.runTime or 0
    end
  elseif string.lower(cmd) ~= "continue" then
    deathTimer = 1830                    -- start with 60 seconds
    GST.mhState = 1
    GST.mhTimer = 9 * 30 + GST.countdown -- 9 seconds + countdown setting
  else
    deathTimer = 900                     -- start with 30 seconds
    GST.mhState = 2
    GST.mhTimer = 0
  end

  if network_is_server() and GST.mhMode == 2 then
    if tonumber(cmd) and tonumber(cmd) > 0 and (tonumber(cmd) % 1 == 0) then
      GST.campaignCourse = tonumber(cmd)
    else
      GST.campaignCourse = 0
    end
    random_star(nil, GST.campaignCourse)
  end

  if string.lower(cmd) ~= "continue" then
    m0.health = 0x880
    m0.specialTripleJump = 0
    SVcln = nil
    rejoin_timer = {}
    set_lighting_dir(2, 0)

    GST.votes = 0
    iVoted = false
    GST.speedrunTimer = 0
    GST.shuffleTimer = 0
    GST.globalTalkTimer = 0
    GST.lastStarTime = 0
    GST.saboActive = 0
    GST.saboTimer = GST.countdown + 60 * 30 -- 1 minute after grace period

    sMario0.totalStars = 0
    if not sMario0.forceSpectate then
      sMario0.knownDead = false
      sMario0.dead = false
    else
      become_runner(sMario0)
    end
    sMario0.guardTime = 0
    guardCooldown = 0
    prevGameEnd = false
    leader = false
    scoreboard = {}
    if sMario0.team == 1 then
      sMario0.runnerLives = GST.runnerLives
      sMario0.runTime = 0
      died = false
      m0.numLives = sMario0.runnerLives
    else -- save 'been runner' status
      print("Our 'Been Runner' status has been cleared")
      sMario0.beenRunner = 0
      mod_storage_save("beenRunnner", "0")
    end
    inHard = sMario0.hard or 0
    killTimer = 0
    killCombo = 0
    campTimer = nil
    warpCooldown = 0

    warp_beginning()

    if (string.lower(cmd) == "main") then
      GST.otherSave = false
    elseif (string.lower(cmd) == "alt") or (string.lower(cmd) == "reset") then
      GST.otherSave = true
    end
    GST.bowserBeaten = false
    save_file_set_using_backup_slot(GST.otherSave)
    if (string.lower(cmd) == "reset") then
      print("did reset")
      --save_file_erase_current_backup_save()
      local file = get_current_save_file_num() - 1
      for course = 0, 25 do
        save_file_remove_star_flags(file, course - 1, 0xFF)
        save_file_set_course_coin_score(file, course - 1, 0)
      end
      save_file_clear_flags(0xFFFFFFFF) -- ALL OF THEM
      save_file_do_save(file, 1)
    end

    if GST.mhMode == 3 then
      local huntersLeft = 0
      local hunterNames = {}
      for i = 0, (MAX_PLAYERS - 1) do
        if NetP[i].connected and PST[i].team ~= 1 and (not PST[i].forceSpectate) then
          huntersLeft = huntersLeft + 1
          if i ~= 0 and sMario0.team ~= 1 and GST.anarchy ~= 3 then
            local name = remove_color(NetP[i].name)
            table.insert(hunterNames, name)
          end
        end
      end

      if #hunterNames == 0 then
        djui_chat_message_create(trans_plural("hunters_set_count", huntersLeft))
      else
        local text = trans("other_hunters")
        for i = 1, #hunterNames do
          text = text .. hunterNames[i] .. ", "
        end
        text = text:sub(1, -3)
        djui_chat_message_create(text)
      end
    end
  end
end

-- code from arena
function allow_pvp_attack(attacker, victim)
  -- false if timer going or game end
  if GST.mhState == 1 then return false end
  if GST.mhState >= 3 then return false end

  -- allow hurting each other in lobby, except in parkour challenge
  if GST.mhState == 0 then
    local raceTimerOn = hud_get_value(HUD_DISPLAY_FLAGS) & HUD_DISPLAY_FLAGS_TIMER
    return (raceTimerOn == 0)
  end

  if attacker.playerIndex == victim.playerIndex then
    return false
  end

  local sAttacker = PST[attacker.playerIndex]
  local sVictim = PST[victim.playerIndex]

  -- sanitize
  local attackTeam = sAttacker.team or 0
  local victimTeam = sVictim.team or 0

  -- team attack setting
  if GST.anarchy == 0 then
    return attackTeam ~= victimTeam
  elseif (GST.anarchy == 3) then
    return true
  elseif (GST.anarchy == 1 and attackTeam == 1) then
    return true
  elseif (GST.anarchy == 2 and attackTeam ~= 1) then
    return true
  end

  return attackTeam ~= victimTeam
end

function on_pvp_attack(attacker, victim)
  local sVictim = PST[victim.playerIndex]
  local npAttacker = NetP[attacker.playerIndex]

  local testHurtCounter = victim.hurtCounter
  if apply_double_health(victim.playerIndex) and testHurtCounter > halvedHurtCounter then
    testHurtCounter = (victim.hurtCounter - halvedHurtCounter) // 2 + halvedHurtCounter
  end
  local remainingHealth = (victim.health - math.max((testHurtCounter - victim.healCounter) * 0x40, 0))

  if (GST.mhMode == 3 or sVictim.team == 1) and GST.mhState ~= 0 then
    if GST.dmgAdd == -1 then -- instant death
      victim.health = 0xFF
      victim.healCounter = 0
    else
      if (victim.flags & MARIO_METAL_CAP) ~= 0 then
        victim.hurtCounter = victim.hurtCounter + 4            -- one unit
      end
      victim.hurtCounter = victim.hurtCounter + GST.dmgAdd * 4 -- hurtCounter goes by 4 for some reason
    end

    testHurtCounter = victim.hurtCounter
    if apply_double_health(victim.playerIndex) and testHurtCounter > halvedHurtCounter then
      testHurtCounter = (victim.hurtCounter - halvedHurtCounter) // 2 + halvedHurtCounter
    end
    remainingHealth = (victim.health - math.max((testHurtCounter - victim.healCounter) * 0x40, 0))

    -- change the set action if killed
    if remainingHealth <= 0xFF then
      -- deal some damage now so that our health is low enough to trigger the death action
      victim.health = victim.health - 0x40 * math.floor(testHurtCounter * 0.75)
      testHurtCounter = math.ceil(testHurtCounter * 0.25)

      if victim.action == ACT_SOFT_BACKWARD_GROUND_KB or victim.action == ACT_BACKWARD_GROUND_KB then
        set_mario_action(victim, ACT_HARD_BACKWARD_GROUND_KB, victim.actionArg)
      elseif victim.action == ACT_BACKWARD_AIR_KB then
        set_mario_action(victim, ACT_HARD_BACKWARD_AIR_KB, victim.actionArg)
      elseif victim.action == ACT_SOFT_FORWARD_GROUND_KB or victim.action == ACT_FORWARD_GROUND_KB then
        set_mario_action(victim, ACT_HARD_FORWARD_GROUND_KB, victim.actionArg)
      elseif victim.action == ACT_FORWARD_AIR_KB then
        set_mario_action(victim, ACT_HARD_FORWARD_AIR_KB, victim.actionArg)
      end
    end
  end

  if victim.playerIndex == 0 then
    attackedBy = npAttacker.globalIndex
    hitTimer = 300 -- 10 seconds
    if remainingHealth <= 0xFF then
      play_sound(SOUND_GENERAL_BOWSER_BOMB_EXPLOSION, gGlobalSoundSource)
      set_camera_shake_from_hit(SHAKE_LARGE_DAMAGE)
      if gGlobalSyncTable.mhMode == 3 and OmmEnabled then -- fix omm in mysteryhunt
        OmmApi.omm_disable_feature("odysseyDeath", true)
      end
    end
  end
end

-- omm support
function omm_allow_attack(index, setting)
  if setting == 3 and index ~= 0 then
    return allow_pvp_attack(MST[index], m0)
  end
  return true
end

function omm_attack(index, setting)
  if setting == 3 and index ~= 0 then
    on_pvp_attack(MST[index], m0)
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
  -- in castle
  if np0.currCourseNum == 0 or (ROMHACK and ROMHACK.hubStages and ROMHACK.hubStages[np0.currCourseNum]) then
    return 0, trans("in_castle")
  end

  local leaveTime = (neededRunTime - localRunTime)
  if GST.mhMode == 3 and attackedBy and hitTimer and hitTimer ~= 0 and (sMario.team ~= 1 or leaveTime == 0 or ((not GST.starMode) and hitTimer > leaveTime)) then
    local text
    if GST.starMode then -- overwrite text with timer
      local timeLeft = hitTimer + 29
      local seconds = timeLeft // 30 % 60
      local minutes = (timeLeft // 1800)
      text = trans("time_left", minutes, seconds)
    end
    return hitTimer, text
  end

  -- for leave command
  if sMario.team ~= 1 or sMario.allowLeave then
    return 0
  end

  -- allow leaving bowser stages if done (not in free roam)
  if GST.freeRoam then
    -- nothing
  elseif np0.currCourseNum == COURSE_BITDW and ((save_file_get_flags() & (SAVE_FLAG_HAVE_KEY_1 | SAVE_FLAG_UNLOCKED_BASEMENT_DOOR)) ~= 0) then
    return 0
  elseif np0.currCourseNum == COURSE_BITFS and ((save_file_get_flags() & (SAVE_FLAG_HAVE_KEY_2 | SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR)) ~= 0) then
    return 0
  elseif np0.currCourseNum == COURSE_BITS and GST.bowserBeaten then -- star road and such
    return 0
  end

  -- can't leave some stages
  if neededRunTime == -1 then
    return 1, trans("cant_leave")
  end
  return leaveTime
end

-- only do this sometimes to reduce lag
function calculate_leave_requirements(sMario, runTime, gotStar)
  -- skip calculation if we're in a hub stage, and prevent leaving bowser areas
  if np0.currCourseNum == 0 or (ROMHACK and ROMHACK.hubStages and ROMHACK.hubStages[np0.currCourseNum]) then
    return 0, 0
  elseif np0.currLevelNum == LEVEL_BOWSER_1 or np0.currLevelNum == LEVEL_BOWSER_2 or np0.currLevelNum == LEVEL_BOWSER_3 then
    if (GST.noBowser and np0.currLevelNum == LEVEL_BOWSER_3) or (GST.freeRoam and np0.currLevelNum ~= LEVEL_BOWSER_3) then
      return 0, 0  -- this stage is useless, in theory
    else
      return -1, 0 -- -1 means no leaving
    end
  end

  -- less time for secret courses
  local total_time = GST.runTime
  local star_data_table = { 8, 8, 8, 8, 8, 8, 8 }
  if ROMHACK.star_data and ROMHACK.star_data[np0.currCourseNum] then
    star_data_table = ROMHACK.star_data[np0.currCourseNum]
    -- for EE
    if GST.ee and ROMHACK.star_data_ee and ROMHACK.star_data_ee[np0.currCourseNum] then
      star_data_table = ROMHACK.star_data_ee[np0.currCourseNum]
    end
  elseif np0.currCourseNum > 15 then
    star_data_table = { 8 }
  end
  if (np0.currCourseNum == COURSE_DDD and ROMHACK.ddd and ((save_file_get_flags() & (SAVE_FLAG_HAVE_KEY_2 | SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR)) == 0)) then
    star_data_table = { 8 } -- treat DDD as only having star 1
  end

  -- if a "exit" star was obtained, allow leaving immediately
  if gotStar and star_data_table[gotStar] and star_data_table[gotStar] & STAR_EXIT ~= 0 then
    local skip_rule = ((gLevelValues.disableActs and gLevelValues.disableActs ~= 0) and star_data_table[gotStar] & STAR_APPLY_NO_ACTS == 0)
    if not skip_rule then
      sMario.allowLeave = true
      -- apply to teammates as well
      for b = 1, (MAX_PLAYERS - 1) do
        if (PST[b].team == 1) and PST[b].spectator ~= 1 and is_player_active(MST[b]) ~= 0 then
          PST[b].allowLeave = true
        end
      end
      return 0, 0
    end
  end

  -- calculate what stars can still be obtained
  local counting_stars = 0
  local obtainable_stars = 0
  local file = get_current_save_file_num() - 1
  local course_star_flags = (ROMHACK and ROMHACK.getStarFlagsFunc and ROMHACK.getStarFlagsFunc(file, np0.currCourseNum - 1, true)) or
      save_file_get_star_flags(file, np0.currCourseNum - 1)
  for i = 1, #star_data_table do
    if star_data_table[i] and (course_star_flags & (1 << (i - 1)) == 0) then
      local data = star_data_table[i]
      local areaValid = false
      local area = data & STAR_AREA_MASK
      if star_data_table[i] < STAR_MULTIPLE_AREAS then
        if area == 8 or np0.currAreaIndex == area then
          areaValid = true
        end
      else
        local areas = (data & ~(STAR_MULTIPLE_AREAS - 1))
        if areas & (STAR_MULTIPLE_AREAS << (np0.currAreaIndex - 1)) ~= 0 then
          areaValid = true
        end
      end

      -- for star road (and possibly project reimagined)
      if data & STAR_REPLICA ~= 0 and ((ROMHACK.replica_start and m0.numStars < ROMHACK.replica_start) or (ROMHACK.replica_func and not ROMHACK.replica_func(m0.numStars))) then
        areaValid = false
      end

      local act = np0.currActNum -- anything below act 1 USED TO BE act 1, but that's not true anymore
      if act > 1 and ROMHACK and ROMHACK.ddd and np0.currCourseNum == COURSE_WF and obj_get_first_with_behavior_id(id_bhvTower) == nil then
        act = 1                  -- exception for whomp's fortress; if whomp king hasn't been defeated, it's still act 1
      end

      local skip_rule = ((gLevelValues.disableActs and gLevelValues.disableActs ~= 0) and data & STAR_APPLY_NO_ACTS == 0)
      if areaValid and (skip_rule or
            ((data & STAR_ACT_SPECIFIC == 0 or act == i)
              and (data & STAR_NOT_ACT_1 == 0 or act > 1)
              and (data & STAR_NOT_BEFORE_THIS_ACT == 0 or act >= i))) then
        obtainable_stars = obtainable_stars + 1
        if skip_rule or (not GST.starMode) or data & STAR_IGNORE_STARMODE == 0 then
          counting_stars = counting_stars + 1
        end
      end
    end
  end

  -- if there aren't any in this stage, treat as a 1 star stage
  if #star_data_table <= 0 then
    counting_stars = 1
    if GST.starMode or ROMHACK.isUnder then return -1, 0 end -- impossible to leave in star mode
  end

  if lastObtainable ~= obtainable_stars then
    djui_popup_create(trans("stars_in_area", obtainable_stars), 1)
    lastObtainable = obtainable_stars
  end

  if GST.starMode then
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
  elseif not selectedStar then
    local replicas = true
    if ROMHACK.replica_start or ROMHACK.replica_func then
      local courseMax = 25
      local courseMin = 1
      local totalStars = (ROMHACK and ROMHACK.totalStarCountFunc and ROMHACK.totalStarCountFunc(get_current_save_file_num() - 1, courseMin - 1, courseMax - 1)) or
          (save_file_get_total_star_count(get_current_save_file_num() - 1, courseMin - 1, courseMax - 1))
      if (ROMHACK.replica_start and ROMHACK.replica_start > totalStars) or (ROMHACK.replica_func and not ROMHACK.replica_func(totalStars)) then
        replicas = false
      end
    end

    local valid_star_table = generate_star_table(prevCourse, false, replicas)
    if #valid_star_table < 1 then
      valid_star_table = generate_star_table(prevCourse, false, replicas, GST.getStar)
      if #valid_star_table < 1 then
        global_popup_lang("no_valid_star", nil, nil, 1)
        GST.mhTimer = 1 -- end game
        return
      end
      selectedStar = valid_star_table[math.random(1, #valid_star_table)]
    else
      selectedStar = valid_star_table[math.random(1, #valid_star_table)]
    end
  end

  GST.getStar = selectedStar % 10
  GST.gameLevel = course_to_level[selectedStar // 10]
  print("Selected", GST.gameLevel, GST.getStar)
end

-- generate table of valid stars
function generate_star_table(exCourse, standard, replicas, recentAct)
  local valid_star_table = {}
  for course, level in pairs(course_to_level) do
    if course ~= exCourse or recentAct then
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

  if (standard or (course ~= 0 and course ~= 25 and (not ROMHACK.hubStages or not ROMHACK.hubStages[course]))) then
    local star_data_table = { 8, 8, 8, 8, 8, 8, 8 }
    if course == 25 and not ROMHACK.star_data[course] then
      return false
    elseif course > 15 or ROMHACK.star_data[course] then
      star_data_table = ROMHACK.star_data[course] or { 8 }
      if GST.ee and ROMHACK.star_data_ee and ROMHACK.star_data_ee[course] then
        star_data_table = ROMHACK.star_data_ee[course]
      end
    elseif course == 0 then
      star_data_table = { 8, 8, 8, 8, 8 }
    end

    if star_data_table[act] then
      if (not replicas) and star_data_table[act] & STAR_REPLICA ~= 0 then
        return false
      elseif star_data_table[act] ~= 0 and not (not standard and mini_blacklist and mini_blacklist[course * 10 + act]) and (standard or act ~= 7 or course > 15) then
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
  if GST.mhState == 0 or m0.action == ACT_QUICKSAND_DEATH then return false end
  if (not died) and (m0.health - math.max((m0.hurtCounter - m0.healCounter) * 0x40, 0)) <= 0xFF then
    m0.health = 0xFF -- kill if trying to cheat death
  end
  if sMario0.spectator == 1 or sMario0.dead then return false end
  if GST.mhMode == 2 then
    if m0.invincTimer <= 0 and (m0.action & ACT_FLAG_PAUSE_EXIT) ~= 0 then
      warp_beginning()
    end
    return false
  end

  -- allow exiting if collecting an exit star or key
  if (m0.action == ACT_STAR_DANCE_WATER or m0.action == ACT_STAR_DANCE_NO_EXIT or m0.action == ACT_STAR_DANCE_EXIT) and m0.actionArg & 1 == 0 then
    if exitToCastle then
      m0.health = 0x880 -- full health
      prevHealth = 0x880
      actualHealthBeforeRender = 0x880
      m0.hurtCounter = 0x0
    end
    return true
  end

  if (not died) and get_leave_requirements(sMario0) > 0 then
    djui_chat_message_create(runner_hud(sMario0))
    return false
  end

  if exitToCastle then
    m0.health = 0x880 -- full health
    prevHealth = 0x880
    actualHealthBeforeRender = 0x880
    m0.hurtCounter = 0x0
  else
    enable_time_stop_including_mario()
  end
end

function on_death(m, nonStandard)
  if m.playerIndex ~= 0 then return true end
  if ROMHACK and ROMHACK.lifeOverride then
    m.numLives = 101 -- prevent star road 0 life
  end

  if ROMHACK.isUnder and died and (not nonStandard) and np0.currLevelNum == LEVEL_CASTLE_COURTYARD then
    m.health = 0x880
    prevHealth = 0x880
    actualHealthBeforeRender = 0x880
    m.hurtCounter = 0
    force_idle_state(m)
    reset_camera_fix_bug(m.area.camera)
    return false
  elseif not (nonStandard or died) and GST.voidDmg ~= -1 then
    local voidHurtCounter = GST.voidDmg * 4
    if apply_double_health(0) then voidHurtCounter = voidHurtCounter // 2 end
    if m.health - math.max((m.hurtCounter + voidHurtCounter - m.healCounter) * 0x40, 0) > 0xFF then
      m.hurtCounter = m.hurtCounter + GST.voidDmg * 4
      soft_reset_camera_fix_bug(m.area.camera)
      set_mario_action(m, ACT_MH_BUBBLE_RETURN, 0)
      fade_volume_scale(0, 127, 15)
      return false
    end
  end

  if not (nonStandard or died) and GST.mhMode ~= 2 and GST.mhState ~= 0 and np0.currCourseNum == 0 and m.floor.type ~= SURFACE_INSTANT_QUICKSAND and m.floor.type ~= SURFACE_INSTANT_MOVING_QUICKSAND then -- for star road (and also 121rst star)
    m.health = 0xFF
    prevHealth = 0xFF
    actualHealthBeforeRender = 0xFF
    m.hurtCounter = 0
    died = true
    return true
  end

  if not died then
    -- ghost guard
    if GST.mhMode == 3 and sMario0.guardTime and sMario0.guardTime ~= 0 and not sMario0.dead then
      sMario0.guardTime = 0
      m.health = 0x180
      prevHealth = 0x180
      actualHealthBeforeRender = 0x180
      m.hurtCounter = 0
      m.invincTimer = math.max(m.invincTimer, 100)
      if not nonStandard then
        soft_reset_camera_fix_bug(m.area.camera)
        set_mario_action(m, ACT_MH_BUBBLE_RETURN, 0)
        fade_volume_scale(0, 127, 15)
      end
      djui_chat_message_create(trans("guard_save"))
      return false
    end

    local lost = false
    local newID = nil
    local runner = false
    local time = localRunTime or 0
    m.health = 0xFF -- Mario's health is used to see if he has respawned
    died = true
    warpCooldown = 0
    killTimer = 0
    killCombo = 0

    -- change to hunter (not in mystery)
    if (GST.mhState == 1 or GST.mhState == 2) then
      if sMario0.team == 1 and (sMario0.runnerLives <= 0 or (GST.mhMode == 3 and attackedBy)) then
        runner = true
        m.numLives = 100
        local attackIndex = attackedBy and network_local_index_from_global(attackedBy)
        if (not GST.spectateOnDeath) and (GST.mhMode ~= 3 or (attackIndex and PST[attackIndex].team ~= 1)) then
          become_hunter(sMario0)
        else
          sMario0.dead = true
        end
        localRunTime = 0
        lost = true

        if GST.mhMode ~= 0 and GST.mhMode ~= 3 then -- pick new runner
          if attackIndex then
            local kSMario = PST[attackIndex]
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
      elseif sMario0.team == 1 and sMario0.runnerLives then
        sMario0.runnerLives = sMario0.runnerLives - 1
        runner = true
      elseif GST.mhMode == 3 and sMario0.team ~= 1 and attackedBy then
        sMario0.dead = true
        if GST.confirmHunter then
          sMario0.knownDead = true
          spectate_command("hunter")
        end
      end
    end

    if not (attackedBy or runner) then return true end -- no one cares about hunters dying

    network_send_include_self(true, {
      id = PACKET_KILL,
      killed = np0.globalIndex,
      killer = attackedBy,
      killerObj = attackedByObj,
      death = lost,
      newRunnerID = newID,
      time = time,
      runner = runner,
    })
  end

  if (not nonStandard) and (GST.mhState == 0 or GST.mhMode == 2) then
    m.health = 0x880
    if m.playerIndex == 0 then
      prevHealth = 0x880
      actualHealthBeforeRender = 0x880
      warp_beginning()
    end
    return false
  elseif (not nonStandard) and GST.mhMode == 3 and (GST.mhState == 1 or GST.mhState == 2) and sMario0.dead then
    force_idle_state(m)
    soft_reset_camera_fix_bug(m.area.camera)
    if is_hazard_floor(m.floor.type) then
      set_mario_action(m, ACT_MH_BUBBLE_RETURN, 0)
      fade_volume_scale(0, 127, 15)
    else
      spawn_my_corpse()
    end
    return false
  end

  -- call custom death hooks
  local result = true
  for i, func in ipairs(on_death_hooks) do
    result = func(m) or result
  end
  return result
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
  local runnerCount = 0
  for i = startingI, (MAX_PLAYERS - 1) do
    local np = NetP[i]
    local sMario = PST[i]
    if np.connected and (not sMario.dead) then
      if sMario.team ~= 1 then
        table.insert(currHunterIDs, np.localIndex)
        if (not includeLocal) and is_player_active(MST[i]) ~= 0 then -- give to closest mario
          local dist = dist_between_objects(MST[i].marioObj, m0.marioObj)
          if closest == -1 or dist < closestDist then
            closestDist = dist
            closest = i
          end
        end
      else
        runnerCount = runnerCount + 1
      end
    end
  end
  if #currHunterIDs < 1 then
    if not includeLocal then
      if GST.mhMode == 2 and runnerCount == 0 then -- singleplayer minihunt
        GST.mhTimer = 1                            -- end game
        return nil
      else
        return np0.globalIndex
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
  local np = NetP[lIndex]
  return np.globalIndex
end

function omm_disable_mode_for_minihunt(disable)
  if OmmEnabled and ROMHACK and ROMHACK.disableNonStop ~= true then
    gLevelValues.disableActs = bool_to_int(disable)
    OmmApi.omm_disable_feature("trueNonStop", disable)
  end
end

local gasFade = 1
local darknessFade = 1
function update()
  local unknownString = trans("menu_unknown")
  local censorNames = false
  if not didFirstJoinStuff then
    djui_set_popup_disabled_override(true)
    if m0.area.localAreaTimer > 90 then
      on_course_sync()
    end
  elseif mystery_popup_off() then
    djui_set_popup_disabled_override(true)
    censorNames = true
  else
    djui_reset_popup_disabled_override()
  end

  -- set location names
  for i = 0, MAX_PLAYERS - 1 do
    local np = NetP[i]
    local customName = get_custom_level_name(np.currCourseNum, np.currLevelNum, np.currAreaIndex)
    local trueName = real_get_level_name(np.currCourseNum, np.currLevelNum, np.currAreaIndex)
    if censorNames and i ~= 0 then
      network_player_set_override_location(NetP[i], unknownString)
    elseif customName == trueName then
      network_player_set_override_location(np, "")
    else
      network_player_set_override_location(np, customName)
    end
  end
  
  -- gas sabo
  local gasOn = (get_active_sabo() == 2 and (not sMario0.dead))
  if gasFade < 1 or gasOn then
    if gasOn then
      gasFade = math.max(gasFade - 0.01, 0)
    else
      gasFade = math.min(gasFade + 0.01, 1)
    end
    defaultLight = get_season_lighting(month, np0.currLevelNum)
    set_lighting_color(0, lerp(255, defaultLight.lightColorR, gasFade))
    set_lighting_color(1, lerp(255, defaultLight.lightColorG, gasFade))
    set_lighting_color(2, lerp(50, defaultLight.lightColorB, gasFade))
    set_skybox_color(0, lerp(255, defaultLight.skyboxColorR, gasFade))
    set_skybox_color(1, lerp(255, defaultLight.skyboxColorG, gasFade))
    set_skybox_color(2, lerp(50, defaultLight.skyboxColorB, gasFade))
    set_fog_color(0, lerp(255, defaultLight.fogColorR, gasFade))
    set_fog_color(1, lerp(255, defaultLight.fogColorG, gasFade))
    set_fog_color(2, lerp(50, defaultLight.fogColorB, gasFade))
    set_fog_intensity(lerp(1.05, defaultLight.fogIntensity, gasFade))
    set_vertex_color(0, lerp(255, defaultLight.vertexColorR, gasFade))
    set_vertex_color(1, lerp(255, defaultLight.vertexColorG, gasFade))
    set_vertex_color(2, lerp(50, defaultLight.vertexColorB, gasFade))
  end

  -- darkness sabo
  local darknessOn = (get_active_sabo() == 3 and sMario0.team == 1 and (not sMario0.dead))
  if darknessFade < 1 or darknessOn then
    if darknessOn then
      if darknessFade == 1 then
        play_sound(SOUND_GENERAL_MOVING_PLATFORM_SWITCH, gGlobalSoundSource)
      end
      darknessFade = math.max(darknessFade - 0.04, 0)
    else
      if darknessFade == 0 then
        play_sound(SOUND_GENERAL_MOVING_PLATFORM_SWITCH, gGlobalSoundSource)
      end
      darknessFade = math.min(darknessFade + 0.02, 1)
    end
    local defaultLight = get_season_lighting(month, np0.currLevelNum)
    set_lighting_color(0, lerp(40, defaultLight.lightColorR, darknessFade))
    set_lighting_color(1, lerp(40, defaultLight.lightColorG, darknessFade))
    set_lighting_color(2, lerp(60, defaultLight.lightColorB, darknessFade))
    set_skybox_color(0, lerp(0, defaultLight.skyboxColorR, darknessFade))
    set_skybox_color(1, lerp(0, defaultLight.skyboxColorG, darknessFade))
    set_skybox_color(2, lerp(0, defaultLight.skyboxColorB, darknessFade))
    set_fog_color(0, lerp(0, defaultLight.fogColorR, darknessFade))
    set_fog_color(1, lerp(0, defaultLight.fogColorG, darknessFade))
    set_fog_color(2, lerp(0, defaultLight.fogColorB, darknessFade))
    set_fog_intensity(lerp(1.03, defaultLight.fogIntensity, darknessFade))
    set_vertex_color(0, lerp(40, defaultLight.vertexColorR, darknessFade))
    set_vertex_color(1, lerp(40, defaultLight.vertexColorG, darknessFade))
    set_vertex_color(2, lerp(60, defaultLight.vertexColorB, darknessFade))
  end

  noSettingDisp = (not didFirstJoinStuff)
  local actSelect = false
  do_pause()
  if obj_get_first_with_behavior_id(id_bhvActSelector) then
    actSelect = true
    before_mario_update(m0, true)
  end

  if not didHudHook then
    hook_event(HOOK_OBJECT_SET_MODEL, on_obj_set_model)
    didHudHook = true
  end

  if not actSelect then
    star_update(showRadar or showMiniMap)
  end

  -- detect victory for runners
  if didFirstJoinStuff and m0.area.localAreaTimer > 10 and GST.mhMode ~= 2 and sMario0.team == 1 and (not sMario0.dead) and ((GST.mhState == 1 and GST.countdown and GST.mhTimer and GST.countdown > GST.mhTimer) or GST.mhState == 2) then
    local win = false
    if GST.noBowser then
      win = (np0.currAreaSyncValid and np0.currLevelSyncValid) and m0.numStars >= GST.starRun
    else
      win = ROMHACK and ROMHACK.runner_victory and ROMHACK.runner_victory(m0)
    end
    if win then
      network_send_include_self(true, {
        id = PACKET_GAME_END,
        winner = 1,
      })
      rejoin_timer = {}
      GST.mhState = 4
      GST.mhTimer = 20 * 30 -- 20 seconds
    end
  end

  if warpCooldown > 0 then warpCooldown = warpCooldown - 1 end

  -- handle timers
  if not (GST.pause and sMario0.pause) then
    if frameCounter < 1 then
      frameCounter = 120
      localPlayTime = localPlayTime + 4
    end
    frameCounter = frameCounter - 1

    if network_is_server() and didFirstJoinStuff then
      if GST.mhTimer > 0 then
        GST.mhTimer = GST.mhTimer - 1
        if GST.mhTimer == 0 then
          if GST.mhState == 1 then
            GST.mhState = 2
          elseif GST.mhState >= 3 or GST.mhState == 0 then
            if GST.gameAuto ~= 0 then
              print("New game started")

              local singlePlayer = true
              for i = 1, MAX_PLAYERS - 1 do
                local np = NetP[i]
                local sMario = PST[i]
                if np.connected and sMario.spectator ~= 1 then
                  singlePlayer = false
                  break
                end
              end
              if not singlePlayer then
                runner_randomize(GST.gameAuto)
              end

              if GST.mhMode ~= 2 then
                start_game("reset")
              elseif GST.campaignCourse > 0 then
                start_game("1") -- stay in campaign mode
              else
                start_game("")
              end
              if GST.mhState ~= 1 and GST.mhState ~= 2 then
                GST.mhTimer = 20 * 30 -- 20 seconds (when the game doesnt start)
              end
            else
              GST.mhState = 0
            end
          else
            GST.mhState = 5
            network_send_include_self(true, {
              id = PACKET_GAME_END,
            })
            GST.mhTimer = 20 * 30 -- 20 seconds
          end
        end
      end

      if (GST.mhMode ~= 2 or campaignRecordValid or GST.maxShuffleTime ~= 0) and (GST.mhState ~= 0 and (GST.mhState == 2 or (GST.mhState < 3 and GST.mhTimer < GST.countdown))) then
        local valid = true
        if GST.pause then
          valid = false
          for i = 0, MAX_PLAYERS - 1 do
            if not gPlayerSyncTable[i].pause then
              valid = true
              break
            end
          end
        end
        if valid then
          if (GST.mhMode ~= 2 or campaignRecordValid) then
            GST.speedrunTimer = GST.speedrunTimer + 1
          end
          if GST.maxShuffleTime ~= 0 then
            GST.shuffleTimer = GST.shuffleTimer + 1
            if GST.shuffleTimer >= GST.maxShuffleTime then
              GST.shuffleTimer = 0

              -- store runner information (lives and time)
              local runnerLives = {}
              local storedTime = {}
              local flippedRunners = false -- flip runners at end to prevent timer from resetting
              for i = 0, (MAX_PLAYERS - 1) do
                local sMario = PST[i]
                if (not sMario.dead) and NetP[i].connected and sMario.team == 1 then
                  table.insert(runnerLives, sMario.runnerLives)
                  storedTime[i] = sMario.runTime
                end
              end

              -- assign information to new players
              for a, lives in ipairs(runnerLives) do
                local newID = new_runner(true)
                if not newID then
                  flippedRunners = true
                  for index, time in pairs(storedTime) do
                    local sMario = PST[index]
                    become_hunter(sMario)
                  end
                  newID = new_runner(true)
                end
                local np = network_player_from_global_index(newID)
                local sMario = PST[np.localIndex]

                if storedTime[np.localIndex] then
                  localRunTime = storedTime[np.localIndex] -- use time from when we were still a runner
                else
                  -- match time with other runners in level
                  for b = 1, (MAX_PLAYERS - 1) do
                    if (PST[b].team == 1 or GST.mhMode == 3) and PST[b].spectator ~= 1 and NetP[b].connected then
                      local theirNP = NetP[b] -- daft variable naming conventions
                      local theirSMario = PST[b]
                      if theirSMario.runTime and (theirNP.currLevelNum == np.currLevelNum) and (theirNP.currActNum == np.currActNum) and localRunTime < theirSMario.runTime then
                        localRunTime = theirSMario.runTime
                        neededRunTime, localRunTime = calculate_leave_requirements(sMario, localRunTime)
                      end
                    end
                  end
                end

                network_send_include_self(true, {
                  id = PACKET_KILL,
                  newRunnerID = newID,
                  time = localRunTime
                })
                sMario.runnerLives = lives
              end

              -- if we havent flipped the old runners yet, do so
              if not flippedRunners then
                for index, time in pairs(storedTime) do
                  local sMario = PST[index]
                  become_hunter(sMario)
                end
              end
            end
          end
          if GST.globalTalkTimer ~= 0 then
            GST.globalTalkTimer = GST.globalTalkTimer - 1
            if GST.globalTalkTimer == 0 then
              global_popup_lang("global_talk_end", nil, nil, 1)
            end
          end
        end
      end

      for id, data in pairs(rejoin_timer) do
        data.timer = data.timer - 1
        if data.timer <= 0 then
          global_popup_lang("rejoin_fail", data.name, nil, 1)
          rejoin_timer[id] = nil -- times up

          if GST.mhMode == 1 and data.team == 1 and not (data.dead) then
            local newID = new_runner(true)
            if newID then
              network_send_include_self(true, {
                id = PACKET_KILL,
                newRunnerID = newID,
                time = 0,
              })
            end
          end
        end
      end

      if GST.mhMode == 3 and (GST.saboActive ~= 0 or GST.saboTimer ~= 0) and (GST.mhState == 1 or GST.mhState == 2) then
        if GST.saboActive ~= 0 then
          GST.saboTimer = GST.saboTimer + 1
          if GST.saboActive == 1 and GST.saboTimer >= (MEGA_BOMB_LENGTH + 10) * 30 then
            network_send_include_self(true, { id = PACKET_MEGA_BOMB })
          end
        else
          GST.saboTimer = GST.saboTimer - 1
        end
      end
    end

    if GST.mhMode == 2 and not actSelect then
      -- desync red coins (TODO: replace w/ mm2 system?)
      if not OmmEnabled then
        local redCoinNum = 0
        local redCoin = obj_get_first_with_behavior_id(id_bhvRedCoin)
        while redCoin ~= nil do
          if redCoin.coopFlags & COOP_OBJ_FLAG_NON_SYNC == 0 then
            -- spawn clone of object
            if miniRedCoinCollect & (1 << redCoinNum) == 0 then
              spawn_non_sync_object(id_bhvRedCoin, E_MODEL_RED_COIN, redCoin.oPosX, redCoin.oPosY, redCoin.oPosZ,
                function(o)
                  -- set generic params
                  o.oFaceAnglePitch = redCoin.oFaceAnglePitch
                  o.oFaceAngleYaw = redCoin.oFaceAngleYaw
                  o.oFaceAngleRoll = redCoin.oFaceAngleRoll
                  o.oBehParams = redCoin.oBehParams
                  o.oBehParams2ndByte = redCoin.oBehParams2ndByte
                  o.unused1 = redCoinNum -- used for keeping track of what red coin this is
                end)
            end

            -- delete synced object
            redCoin.activeFlags = ACTIVE_FLAG_DEACTIVATED
            redCoinNum = redCoinNum + 1
          end

          redCoin = obj_get_next_with_same_behavior_id(redCoin)
        end
      end

      -- desync secrets
      local secretNum = 0
      local secret = obj_get_first_with_behavior_id(id_bhvHiddenStarTrigger)
      while secret ~= nil do
        if secret.coopFlags & COOP_OBJ_FLAG_NON_SYNC == 0 then
          -- spawn desynced secret
          if miniSecretCollect & (1 << secretNum) == 0 then
            spawn_non_sync_object(id_bhvHiddenStarTrigger, E_MODEL_PURPLE_MARBLE, secret.oPosX, secret.oPosY,
              secret.oPosZ,
              function(o)
                -- set generic params
                o.oFaceAnglePitch = secret.oFaceAnglePitch
                o.oFaceAngleYaw = secret.oFaceAngleYaw
                o.oFaceAngleRoll = secret.oFaceAngleRoll
                o.oBehParams = secret.oBehParams
                o.oBehParams2ndByte = secret.oBehParams2ndByte
                o.unused1 = secretNum -- used for keeping track of what secret this is
              end)
          end

          -- delete synced object
          secret.activeFlags = ACTIVE_FLAG_DEACTIVATED
          secretNum = secretNum + 1
        end

        secret = obj_get_next_with_same_behavior_id(secret)
      end
    end
  end

  -- set intentional flag when djui menu is open
  if djui_hud_is_pause_menu_created() ~= sMario0.choseToLeave then
    sMario0.choseToLeave = djui_hud_is_pause_menu_created()
    -- save playtime
    local oldPlayTime = tonumber(mod_storage_load("playtime")) or 0
    if localPlayTime ~= 0 then
      mod_storage_save("playtime", tostring(oldPlayTime + localPlayTime))
      if sMario0.playtime then
        sMario0.playtime = sMario0.playtime + localPlayTime // 3600
      else
        sMario0.playtime = localPlayTime // 3600
      end
      localPlayTime = 0
    end
  end

  -- detect victory for hunters (only host to avoid disconnect bugs) (+ runners in mystery)
  if (not DEBUG_NO_VICTORY) and network_is_server() and ((GST.mhState == 1 and GST.countdown > GST.mhTimer) or GST.mhState == 2) and (GST.mhMode == 0 or GST.mhMode == 3) then
    -- check for runners
    local runnerCount = 0
    local hunterCount = bool_to_int(GST.mhMode ~= 3)
    local hunterDC = (GST.mhMode ~= 3)
    for i = 0, (MAX_PLAYERS - 1) do
      if NetP[i].connected and not (PST[i].dead) then
        if PST[i].team == 1 then
          runnerCount = runnerCount + 1
        else
          hunterCount = hunterCount + 1
        end
      end
      if runnerCount ~= 0 and hunterCount ~= 0 and not (GST.mhMode == 3 and GST.huntersWinEarly) then break end
    end

    if hunterCount == 0 or runnerCount == 0 or (GST.mhMode == 3 and GST.huntersWinEarly and runnerCount <= hunterCount) then
      for id, data in pairs(rejoin_timer) do
        if data.timer > 0 and not (data.dead or data.forceSpec) then
          if data.team == 1 then
            runnerCount = runnerCount + 1
          else
            hunterDC = true
          end
          if runnerCount ~= 0 and hunterDC then break end
        end
      end
    end

    if runnerCount == 0 or (GST.mhMode == 3 and GST.huntersWinEarly and runnerCount <= hunterCount) then
      network_send_include_self(true, {
        id = PACKET_GAME_END,
        winner = 0,
      })
      rejoin_timer = {}
      GST.mhState = 3
      GST.mhTimer = 20 * 30 -- 20 seconds
    elseif runnerCount ~= 0 and hunterCount == 0 and (not hunterDC) then
      network_send_include_self(true, {
        id = PACKET_GAME_END,
        winner = 1,
      })
      rejoin_timer = {}
      GST.mhState = 4
      GST.mhTimer = 20 * 30 -- 20 seconds
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
  -- only reset on ground
  if hitTimer == 0 and (m0.action & ACT_FLAG_AIR) == 0 then
    attackedBy = nil
    attackedByObj = nil
  end
end

-- do first join setup
function on_course_sync()
  if (not didFirstJoinStuff) and GST.otherSave ~= nil then
    djui_reset_popup_disabled_override()
    if OmmEnabled then
      OmmApi.omm_resolve_cappy_mario_interaction = omm_attack
      OmmApi.omm_allow_cappy_mario_interaction = omm_allow_attack
      OmmApi.omm_disable_feature("lostCoins", true)
      OmmApi.omm_force_setting("player", 2)
      OmmApi.omm_force_setting("damage", 20)
      OmmApi.omm_force_setting("bubble", 0)
      gLevelValues.mushroom1UpHeal = 0
      ACT_OMM_STAR_DANCE = OmmApi.ACT_OMM_STAR_DANCE
    end
    if GST.romhackFile == "vanilla" then
      omm_replace(OmmEnabled)
    end
    if PersonalStarCounter then
      hide_star_counters = PersonalStarCounter.hide_star_counters
    end

    setup_hack_data(network_is_server(), true, OmmEnabled)
    if network_is_server() then
      load_settings()
      if GST.mhMode ~= 0 then
        load_settings(0)
      end

      local fileName = string.gsub(GST.romhackFile, " ", "_")
      local option = mod_storage_load(fileName .. "_black") or "none"
      if option == "" then option = "none" end
      GST.blacklistData = option
      setup_mini_blacklist(option)

      if GST.gameAuto ~= 0 then
        GST.mhTimer = 20 * 30
      end
    else
      setup_mini_blacklist(GST.blacklistData)
    end

    -- holiday detection (it's not complex anymore)
    local dateTime = get_date_and_time()
    month = dateTime.month + 1 -- apparently this is from 0-11 instead of 1-12 for whatever reason...
    local days = dateTime.day
    if month == 4 then
      if days == 1 then      -- april fools
        month = 13
      elseif days == 18 then -- anniversary
        month = 14
      end
    end
    -- special codes to access october and december
    if m0.controller.rawStickX > 100 and m0.controller.buttonDown & R_TRIG ~= 0 and m0.controller.buttonDown & Y_BUTTON ~= 0 then -- D, E, C on keyboard
      month = 12
    elseif m0.controller.rawStickY > 100 and m0.controller.buttonDown & R_TRIG ~= 0 and m0.controller.rawStickX < 100 then        -- W, E, A on keyboard
      month = 10
    end
    --month = 14
    --djui_popup_create(string.format("%d/%d/%d, %d",month,days,dateTime.year+1900,dateTime.hour), 1)

    local time = get_time()
    print(time)
    math.randomseed(time, np0.globalIndex)
    gLevelValues.starHeal = GST.starHeal or false

    save_file_set_using_backup_slot(GST.otherSave)
    update_all_mario_stars()
    --save_file_reload(1)
    if GST.allowStalk and GST.mhState == 2 and GST.mhMode ~= 2 then
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
      "wins_mys",
      "hardWins_mys",
      "exWins_mys",
      "kills",
      "maxStreak",
      "maxStar",
      "parkourRecord",
      "pRecordOmm",
      "pRecordOther",
      "playtime",
    }
    for i, stat in ipairs(stats) do
      local value = tonumber(mod_storage_load(stat)) or 0
      if stat == "playtime" then
        value = value // 3600
      elseif stat == "pRecordOmm" and value == 0 then
        value = tonumber(mod_storage_load("parkourRecordOmm")) or 599 * 30
        value = value // 30
      elseif stat == "parkourRecord" or stat == "pRecordOmm" or stat == "pRecordOther" then
        value = value // 30
        if value == 0 then value = 599 end
      end
      sMario0[stat] = math.floor(value)
    end
    sMario0.hard = 0
    sMario0.mute = false

    local wins = sMario0.wins + sMario0.wins_standard
    local hardWins = sMario0.hardWins + sMario0.hardWins_standard
    local exWins = sMario0.exWins + sMario0.exWins_standard

    local playerColor = network_get_player_text_color_string(0)
    if wins >= 1 then
      network_send(false, {
        id = PACKET_STATS,
        stat = "disp_wins",
        value = math.floor(wins),
        name = playerColor .. np0.name,
      })
      if (wins >= 100 or hardWins >= 5) and exWins <= 0 then
        djui_popup_create(trans("extreme_notice"), 1)
      elseif wins >= 5 and hardWins <= 0 then
        djui_popup_create(trans("hard_notice"), 1)
      end
    end
    if hardWins >= 1 then
      network_send(false, {
        id = PACKET_STATS,
        stat = "disp_wins_hard",
        value = math.floor(hardWins),
        name = playerColor .. np0.name,
      })
      if wins >= 5 and hardWins <= 0 then
        djui_popup_create(trans("hard_notice"), 1)
      end
    end
    if exWins >= 1 then
      network_send(false, {
        id = PACKET_STATS,
        stat = "disp_wins_ex",
        value = math.floor(exWins),
        name = playerColor .. np0.name,
      })
    end
    if sMario0.kills >= 50 then
      network_send(false, {
        id = PACKET_STATS,
        stat = "disp_kills",
        value = math.floor(sMario0.kills),
        name = playerColor .. np0.name,
      })
    end
    local beenRunner = mod_storage_load("beenRunnner")
    sMario0.beenRunner = tonumber(beenRunner) or 0
    print("Our 'Been Runner' status is ", sMario0.beenRunner)
    local discordID = get_local_discord_id()
    discordID = tonumber(discordID) or 0

    sMario0.placement = assign_place(discordID)
    sMario0.placementASN = assign_place_asn(discordID)

    -- use coopnet id instead
    if discordID == 0 and get_coopnet_id then
      discordID = tonumber(get_coopnet_id(0)) or 0
      if discordID == -1 then discordID = 0 end
    end

    -- only use our saved ID if we've not passed 8 hours since our last join
    -- (only used when direct connection is enabled as of v1.0.4 of coopdx)
    local lastJoined = tonumber(mod_storage_load("lastJoined")) or 0
    if discordID == 0 and time - lastJoined <= (8 * 60 * 60) then
      discordID = tonumber(mod_storage_load("mhID")) or 0
    end
    if discordID == 0 then
      -- generate an id based on our username, the time, and our global index
      local gen = "999"
      math.randomseed(math.random(0, 0xFFFFFFFF), np0.name)
      gen = gen .. tostring(math.random(0, 0xFFFFFFFF))
      discordID = tonumber(gen)
      mod_storage_save("mhID", gen)
    end
    mod_storage_save("lastJoined", tostring(time))

    print("My discord/mh ID is", discordID)
    sMario0.discordID = discordID

    check_for_roles()
    if sMario0.placementASN and sMario0.placementASN <= 4 and sMario0.role and sMario0.role & 64 ~= 0 then
      network_send(false, {
        id = PACKET_STATS,
        stat = "disp_asn",
        value = sMario0.placementASN,
        name = playerColor .. np0.name,
      })
    end

    -- start out as hunter
    become_hunter(sMario0)
    sMario0.totalStars = 0
    leader, scoreboard = calculate_placement()
    sMario0.pause = GST.pause or false
    sMario0.forceSpectate = GST.forceSpectate or false
    sMario0.spectator = bool_to_int(sMario0.forceSpectate)
    sMario0.fasterActions = (mod_storage_load("fasterActions") ~= "false")
    sMario0.choseToLeave = false
    sMario0.inActSelect = false
    sMario0.knownDead = false
    sMario0.dead = false
    sMario0.guardTime = 0

    if GST.mhMode == 3 and (GST.mhState == 1 or GST.mhState == 2) then
      become_runner(sMario0)
      sMario0.dead = true
      sMario0.knownDead = true
      djui_chat_message_create(trans("mysteryhunt_spectate"))
    elseif network_is_server() and gServerSettings.headlessServer and gServerSettings.headlessServer ~= 0 then
      sMario0.spectator = 1
      sMario0.forceSpectate = true
      sMario0.dead = true
      sMario0.knownDead = true
    elseif (GST.mhState == 1 or GST.mhState == 2) and (GST.mhMode ~= 0 or GST.spectateOnDeath) then
      local hunterExists = false
      for i = 1, MAX_PLAYERS - 1 do
        if NetP[i].connected and PST[i].team ~= 1 and PST[i].spectator ~= 1 then
          hunterExists = true
          break
        end
      end
      if not hunterExists then
        become_runner(sMario0)
      end
    end

    -- if anyone else has our id, it means we've disconnected but the other person hasn't updated yet
    if discordID ~= 0 and not network_is_server() then
      for i = 2, MAX_PLAYERS - 1 do -- first is host, and the host will never disconnect
        local sMario = PST[i]
        if NetP[i].connected and sMario.discordID == discordID and NetP[i].ping == 50 then
          if sMario.team == 1 then
            -- become runner again
            become_runner(sMario0)
            sMario0.runnerLives = sMario.runnerLives
          else
            become_hunter(sMario0)
          end
          sMario0.forceSpectate = sMario.forceSpectate or false
          sMario0.dead = sMario.dead or false
          sMario0.knownDead = sMario0.dead
          sMario0.totalStars = sMario.totalStars or 0

          sMario.dead = true
          sMario.knownDead = true
          sMario.spectator = 1
          sMario.totalStars = 0
          sMario.team = bool_to_int(GST.mhMode == 3)
          sMario.discordID = 0
          sMario.choseToLeave = true
          local name = playerColor .. np0.name
          global_popup_lang("rejoin_success", name, nil, 1)
          break
        end
      end
    end

    if (not network_is_server()) and GST.mhMode == 3 and (GST.mhState == 1 or GST.mhState == 2) then
      network_send_to(1, true, { id = PACKET_REQUEST_PERM_OBJS, gIndex = np0.globalIndex })
    end

    -- only show rules for players with zero kills (basically, whoever hasn't played before)
    if sMario0.kills == 0 then
      show_rules()
      djui_chat_message_create(trans("to_switch", lang_list))
    else
      centerRulesTimer = 90
    end
    djui_popup_create("\\#ffff50\\" .. trans("open_menu", menuButtonString[menuButton]), 3)

    set_season_lighting(month, np0.currLevelNum)
    if GST.mhState == 0 then
      set_lobby_music(month)
      --play_music(0, custom_seq, 1)
    end
    omm_disable_mode_for_minihunt(GST.mhMode == 2) -- change non stop mode setting for minihunt

    menu_reload()
    action_setup()
    menu_enter()

    -- this works, surprisingly (runs last)
    hook_event(HOOK_ALLOW_INTERACT, on_allow_interact)

    didFirstJoinStuff = true
    return
  end

  if obj_get_first_with_behavior_id(id_bhvActSelector) == nil and expectedLocation.level ~= 0 then
    if (np0.currAreaIndex ~= expectedLocation.area or (np0.currCourseNum ~= 0 and np0.currActNum ~= expectedLocation.act) or np0.currLevelNum ~= expectedLocation.level) then
      djui_chat_message_create("Attempting to correct level desync...")
      if m0.action & ACT_GROUP_CUTSCENE ~= 0 then
        m0.health = 0x880
        actualHealthBeforeRender = 0x880
        prevHealth = 0x880
      end
      warp_to_level(expectedLocation.level, expectedLocation.area, expectedLocation.act)
    else
      expectedLocation.level = 0
    end
  end

  -- prevent softlock if hunters kill bowser (vanilla only)
  if sMario0.team == 1 and (np0.currLevelNum == LEVEL_BOWSER_1 or np0.currLevelNum == LEVEL_BOWSER_2) and GST.romhackFile == "vanilla" then
    local bowser = obj_get_first_with_behavior_id(id_bhvBowser)
    local key = obj_get_first_with_behavior_id(id_bhvBowserKey)
    if bowser and bowser.oAction == 4 and (not key) then
      spawn_non_sync_object(
        id_bhvBowserKey,
        E_MODEL_BOWSER_KEY,
        m0.pos.x, m0.pos.y, m0.pos.z,
        nil
      )
    end
  end
end

-- camp timer + other stuff
function before_mario_update(m, actSelect)
  -- fix start looking weird
  local sMario = gPlayerSyncTable[m.playerIndex]
  if GST.mhState == 1 and sMario.spectator ~= 1 and ((sMario.team ~= 1 and GST.mhMode ~= 3) or GST.countdown < GST.mhTimer) then
    m.freeze = 1
    set_character_animation(m, CHAR_ANIM_FIRST_PERSON)
  end

  -- funny new vanish cap code
  if GST.nerfVanish and m.playerIndex == 0 then
    if m.capTimer <= 1 then
      storeVanish = false
    elseif storeVanish == false and m.flags & MARIO_VANISH_CAP ~= 0 then
      storeVanish = true
      m.capTimer = m.capTimer + 150 -- additional 5 seconds
      m.flags = m.flags & ~MARIO_VANISH_CAP
      popup_sound(SOUND_GENERAL2_RIGHT_ANSWER)
      djui_popup_create(trans("vanish_custom", buttonString[nerfVanishButton]), 1)
    elseif storeVanish and (m.controller.buttonDown & (A_BUTTON >> (nerfVanishButton - 1))) ~= 0 then
      m.flags = m.flags | MARIO_VANISH_CAP
      m.capTimer = m.capTimer - 2
      if m.capTimer < 1 then m.capTimer = 1 end
    else
      m.flags = m.flags & ~MARIO_VANISH_CAP
    end
  end

  -- Put mario in spectate action to prevent "died" popup
  if m.playerIndex ~= 0 and sMario.spectator == 1 and m.action ~= ACT_SPECTATE then
    m.action = ACT_SPECTATE
  end

  if m.playerIndex ~= 0 then return end
  prevHealth = m.health

  -- warp to lobby if in act select
  if actSelect and (GST.mhState ~= 1 and GST.mhState ~= 2) then
    warp_beginning()
  end

  -- prevent oob in ssl area 3 (grounds is weird)
  if not m.floor and np0.currLevelNum == LEVEL_SSL and np0.currAreaIndex == 3 then
    print("correcting oob")
    m.pos.x = 0
    m.pos.y = 0
    m.pos.z = -2000
  end

  -- camp timer stuff
  if sMario.team == 1 and sMario.spectator ~= 1 then
    if m.freeze > 2 then
      if not campTimer then
        campTimer = 600  -- 20 seconds
      end
      m.invincTimer = 60 -- 2 seconds
    elseif not (campTimer or sMario.dead) and actSelect then
      campTimer = 300    -- 10 seconds
    end
  end
  if campTimer and not sMario.pause then
    campTimer = campTimer - 1
    if campTimer < 330 and campTimer ~= 0 and campTimer % 30 == 0 then
      play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
    end
    if campTimer <= 1 then
      campTimer = 0
      if m.action == ACT_VERTICAL_WIND then
        m.vel.y = m.vel.y - 5
      elseif not actSelect then
        m.controller.buttonPressed = m.controller.buttonPressed | A_BUTTON -- mash a to get out of menu
      else
        campTimer = nil
        died = false
        on_death(m, true)
      end
    end
  end
end

function show_rules()
  showingRules = true
  showingStats = false
  ruleSlide = 0
  ruleEgg = (math.random(1, 100) == 1)
end

function rule_command()
  if not is_game_paused() then
    show_rules()
  end
  return true
end

hook_chat_command("rules", trans("rules_desc"), rule_command)

-- from hide and seek
local tipTimer = 0
function on_hud_render()
  -- render to N64 screen space, with the NORMAL font
  djui_hud_set_resolution(RESOLUTION_N64)
  djui_hud_set_font(FONT_NORMAL)
  m0.health = actualHealthBeforeRender

  if not didFirstJoinStuff then return end

  if storeVanish and m0.capTimer > 1 and (m0.controller.buttonDown & (A_BUTTON >> (nerfVanishButton - 1))) == 0 then
    m0.flags = m0.flags & ~MARIO_VANISH_CAP
  end

  local actSelect = (obj_get_first_with_behavior_id(id_bhvActSelector) ~= nil)
  if sMario0.inActSelect ~= actSelect then
    sMario0.inActSelect = actSelect
  end

  if charSelectExists and charSelect.is_menu_open() then
    return
  end

  -- stats hud
  if showingStats then
    hide_both_hud(true)
    return stats_table_hud()
  elseif showingRules then
    hide_both_hud(true)
    return rules_menu_hud()
  elseif menu or mhHideHud then -- Blocky's menu
    hide_both_hud(true)
    return handleMenu()
  else
    hide_both_hud(false)
  end

  -- show important settings at start
  if GST.mhState == 1 and ((sMario0.team ~= 1 and GST.mhMode ~= 3) or GST.countdown < GST.mhTimer) then
    centerRulesTimer = 30
  end
  if centerRulesTimer > 0 then
    if GST.mhState == 1 and GST.countdown < GST.mhTimer - 120 then -- display rules page for 4 seconds
      rules_menu_hud(((sMario0.team == 1) and 1) or 2)
      if m0.area.localAreaTimer == 1 then                          -- play sound depending on team
        if sMario0.team == 1 then
          play_toads_jingle()
        else
          play_secondary_music(SEQ_LEVEL_KOOPA_ROAD, 0, 100, 0)
          stop_secondary_music(600) -- play only the first part (what is this number supposed to be, exactly? it's not frames...)
        end
      end
      return
    else
      djui_hud_set_font(FONT_NORMAL)
      local scale = 0.5
      local x = 0
      local y = djui_hud_get_screen_height() * 0.5 - 64 * scale
      local screenWidth = djui_hud_get_screen_width()
      local width = 0

      if GST.mhMode == 3 then
        y = y - 64 * scale
      end
      --[[if GST.mhState == 1 or GST.mhState == 2 then
        local text = unstarted_hud() -- team name
        width = djui_hud_measure_text(remove_color(text)) * scale
        x = (screenWidth - width) * 0.5
        y = y - 32 * scale
        djui_hud_set_color(0, 0, 0, math.min(128, centerRulesTimer * 4 + 8));
        djui_hud_render_rect(x - 6, y, width + 12, 32 * scale);

        djui_hud_print_text_with_color(text, x, y, scale, math.min(255, centerRulesTimer * 10))
        y = y + 32 * scale
      end]]

      for i, settingData in ipairs(settingsData) do
        if settingData.showStart then
          local setting = settingData.name
          local name, value = get_setting_as_string(i, GST[setting], true)
          if value and type(GST[setting]) == "boolean" then
            if GST[setting] then
              value = "\\#5aff5a\\" .. name
            else
              value = "\\#ff5a5a\\" .. name
            end
          elseif name and value then
            value = name .. ": " .. value
          end

          if value then
            local text = tostring(value)
            width = djui_hud_measure_text(remove_color(text)) * scale

            x = (screenWidth - width) * 0.5

            djui_hud_set_color(0, 0, 0, math.min(128, centerRulesTimer * 4 + 8));
            djui_hud_render_rect(x - 6, y, width + 12, 32 * scale);

            djui_hud_print_text_with_color(text, x, y, scale, math.min(255, centerRulesTimer * 10))
            y = y + 32 * scale
          end
        end
      end
    end
    centerRulesTimer = centerRulesTimer - 1
  end

  -- tips!
  if actSelect or is_game_paused() or GST.mhState ~= 2 then
    if tipTimer == 0 then
      render_tip(true)
      tipTimer = 300
    else
      render_tip()
      tipTimer = tipTimer - 1
    end
  elseif tipTimer ~= 0 then
    tipTimer = tipTimer - 1
  end

  local text = ""
  local guard = spectate_valid_for_guard()
  -- yay long if statement
  if tonumber(sMario0.pause) then
    text = timer_hud(sMario0)
  elseif GST.mhState == 0 then
    text = unstarted_hud()
  elseif campTimer and campTimer < 330 then               -- camp timer has top priority
    text = camp_hud()
  elseif GST.mhState and GST.mhState >= 3 then            -- game end
    text = victory_hud()
  elseif GST.mhState == 1 and np0.currCourseNum == 0 then -- game start timer
    text = timer_hud()
  elseif GST.maxShuffleTime ~= 0 and GST.maxShuffleTime - GST.shuffleTimer <= 300 and GST.shuffleTimer >= 150 then
    text = shuffle_hud()
  elseif sMario0.team == 1 and sMario0.spectator ~= 1 then -- do runner hud
    text = runner_hud(sMario0)
  elseif guard then
    text = guard_hud(guard)
  else -- do hunter hud
    text = hunter_hud()
  end

  -- first create minimap
  if not (is_game_paused() or actSelect) and showMiniMap then
    render_minimap()
  end

  -- radars
  if (not actSelect) and (showRadar or (showMiniMap and not is_game_paused())) then
    -- stars (table is filled from obj-fixes)
    for i, data in ipairs(radar_store) do
      local o = data[1]
      local star = (o.oBehParams >> 24) + 1
      render_radar(o, star_radar[star], star_minimap[star], true, data[2])
    end

    -- work with boxes
    local o = obj_get_first_with_behavior_id(id_bhvExclamationBox)
    while o do
      if exclamation_box_valid[o.oBehParams2ndByte] and o.oAction ~= 6 and o.header.gfx.node.flags & GRAPH_RENDER_ACTIVE ~= 0 then
        local star = (o.oBehParams >> 24) + 1
        if o.oBehParams2ndByte ~= 8 then
          star = o.oBehParams2ndByte - 8
        end
        if star > 0 and star < 8 then
          if GST.mhMode ~= 2 then
            local file = get_current_save_file_num() - 1
            local course_star_flags = (ROMHACK and ROMHACK.getStarFlagsFunc and ROMHACK.getStarFlagsFunc(file, np0.currCourseNum - 1)) or
                save_file_get_star_flags(file, np0.currCourseNum - 1)
            if course_star_flags & (1 << (star - 1)) == 0 then
              render_radar(o, box_radar[star], box_minimap[star], true, "box")
            end
          elseif star == GST.getStar then
            render_radar(o, box_radar[star], box_minimap[star], true, "box")
          end
        end
      end
      o = obj_get_next_with_same_behavior_id(o)
    end

    -- red coins
    o = obj_get_nearest_object_with_behavior_id(m0.marioObj, id_bhvRedCoin)
    if o then
      render_radar(o, ex_radar[1], ex_minimap[1], true, "coin")
    end
    -- secrets
    o = obj_get_nearest_object_with_behavior_id(m0.marioObj, id_bhvHiddenStarTrigger)
    if o then
      render_radar(o, ex_radar[2], ex_minimap[2], true, "secret")
    end
    -- green demon
    if demonOn then
      o = obj_get_first_with_behavior_id(id_bhvGreenDemon)
      if o then
        render_radar(o, ex_radar[3], ex_minimap[3], true, "demon")
      end
    end

    -- painting overlays
    if (showPaintingOverlays or GST.mhMode == 3) and not (GST.mhMode == 2 or is_game_paused() or actSelect) then
      painting_overlays_and_mystery_misc(showPaintingOverlays)
    end

    -- player radar + minimap
    local showOnMap = GST.showOnMap
    if sMario0.spectator == 1 or (GST.mhState ~= 1 and GST.mhState ~= 2) then
      showOnMap = 4
    end
    if (showOnMap ~= 0) then
      for i = 1, (MAX_PLAYERS - 1) do
        local np = NetP[i]
        local sMario = PST[i]
        if np.connected and (sMario.spectator ~= 1) and (np.currLevelNum == np0.currLevelNum) and (np.currAreaIndex == np0.currAreaIndex) and (np.currActNum == np0.currActNum) then
          local validForMapShow = true
          local isOpponent = (sMario0.spectator ~= 1 and ((sMario0.team == 1) ~= (sMario.team == 1))) -- only do radar for opponents
          if showOnMap == 3 then                                                                      -- opponent
            validForMapShow = isOpponent
          elseif showOnMap ~= 4 then
            validForMapShow = ((sMario.team == 1) == (showOnMap == 1))
          end

          if invisibleMod and invisibleMod.isInvisible(i) then
            validForMapShow = false
          end

          if validForMapShow then
            local rm = MST[np.localIndex]
            if disguiseMod then
              local gIndex = disguiseMod.getDisguisedIndex(np.globalIndex)
              rm = MST[network_local_index_from_global(gIndex)]
            end
            render_radar(rm, icon_radar[i], icon_minimap[i], false, nil, (not isOpponent))
          end
        end
      end
    end
    if not (is_game_paused() or actSelect) and showMiniMap and sMario0.spectator ~= 1 then
      render_player_minimap() -- myself
    end

    -- sabotage object
    if get_active_sabo() ~= 0 then
      o = obj_get_first_with_behavior_id(id_bhvSaboObj)
      if o then
        render_radar(o, ex_radar[4], ex_minimap[4], true, "sabo")
      end
    end
  elseif (showPaintingOverlays or GST.mhMode == 3) and not (GST.mhMode == 2 or is_game_paused() or actSelect) then
    painting_overlays_and_mystery_misc(showPaintingOverlays)
  end

  djui_hud_set_font(FONT_NORMAL)
  local scale = 0.5

  -- get width of screen and text
  local screenWidth = djui_hud_get_screen_width()
  local width = djui_hud_measure_text(remove_color(text)) * scale
  if width > screenWidth - 100 then -- shrink to fit
    scale = scale * (screenWidth - 100) / width
    width = screenWidth - 100
  end

  local x = (screenWidth - width) * 0.5
  local y = 0

  djui_hud_set_color(0, 0, 0, 128);
  djui_hud_render_rect(x - 6, y, width + 12, 32 * scale);

  djui_hud_print_text_with_color(text, x, y, scale)

  -- death timer (extreme mode)
  scale = 0.5
  if sMario0.spectator ~= 1 and (sMario0.hard == 2 or (leader and GST.firstTimer)) and (sMario0.team == 1 or GST.mhMode == 3) and (GST.mhState == 2) then
    djui_hud_set_font(FONT_CUSTOM_HUD)
    djui_hud_set_color(255, 255, 255, 255);

    local seconds = deathTimer // 30
    local screenHeight = djui_hud_get_screen_height()
    text = trans("death_timer")

    -- sorta based on personal star count
    local scale = 1
    local xOffset = -23
    local yOffset = 0
    y = screenHeight - 200
    local ommHud = (OmmEnabled and OmmApi.omm_get_setting(m0, "hud"))
    if ommHud ~= 1 and ommHud ~= 2 then
      local raceTimerOn = hud_get_value(HUD_DISPLAY_FLAGS) & HUD_DISPLAY_FLAGS_TIMER
      --djui_chat_message_create(tostring(raceTimerValue))
      if PersonalStarCounter then
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
    djui_hud_set_font(FONT_HUD)
    width = djui_hud_measure_text(tostring(seconds)) * scale
    x = (screenWidth - width)
    y = y + 17
    djui_hud_print_text(tostring(seconds), x + xOffset, y + yOffset, scale)

    djui_hud_set_font(FONT_NORMAL)
  end

  -- star name + scoreboard for minihunt
  if GST.mhMode == 2 and GST.mhState == 2 then
    text = get_custom_star_name(level_to_course[GST.gameLevel] or 0, GST.getStar)
    width = djui_hud_measure_text(text) * scale
    local screenHeight = djui_hud_get_screen_height()
    x = (screenWidth - width) * 0.5
    y = screenHeight - 16

    djui_hud_set_color(0, 0, 0, 128);
    djui_hud_render_rect(x - 6, y, width + 12, 32 * scale);

    djui_hud_set_color(255, 255, 255, 255);
    djui_hud_print_text(text, x, y, scale);

    -- render the scoreboard
    --[[scoreboard = {}
    for i=1,16 do
      table.insert(scoreboard, {0, 2})
    end
    table.insert(scoreboard, {0, 1})]]
    if #scoreboard > 0 then
      local place = 0
      local scores = {}
      local maxWidthTable = { 0, 0, 0 }
      local lastScore = 0
      local sameScoreCounter = 1

      for i, scoreTable in ipairs(scoreboard) do
        local index = scoreTable[1]
        local score = scoreTable[2]
        local placeText = ""
        local nameText = ""

        local np = NetP[index]
        if np.connected then
          if score == lastScore then
            sameScoreCounter = sameScoreCounter + 1
          else
            place = place + sameScoreCounter
            sameScoreCounter = 1
            lastScore = score
          end
          local playerColor = network_get_player_text_color_string(np.localIndex)
          nameText = nameText .. playerColor .. np.name
          nameText = cap_color_text(nameText, 16)

          nameText = nameText .. ":  "

          -- Generate place text (ordinal number rules)
          local digit = place % 10
          -- for German, we can skip this whole check because it's just the number
          -- for French, every number other than 1st follows the same pattern
          if lang == "de" or (place > 10 and (place < 20 or lang == "fr")) then
            placeText = trans("place_score", place)
          elseif digit == 1 then
            placeText = trans("place_score_1", place)
          elseif digit == 2 then
            placeText = trans("place_score_2", place)
          elseif digit == 3 then
            placeText = trans("place_score_3", place)
          else
            placeText = trans("place_score", place)
          end

          -- Gold, silver, and bronze
          if place == 1 then
            placeText = "\\#e3bc2d\\" .. placeText .. "\\ffffff\\"
          elseif place == 2 then
            placeText = "\\#c5d8de\\" .. placeText .. "\\ffffff\\"
          elseif place == 3 then
            placeText = "\\#b38752\\" .. placeText .. "\\ffffff\\"
          end

          placeText = placeText .. ": "

          local scoreText = tostring(score)
          if index == 0 then
            scoreText = "\\#ffff5a\\" .. scoreText
          end

          table.insert(scores, { placeText, nameText, scoreText })
          for i, text in ipairs(scores[#scores]) do
            local tWidth = djui_hud_measure_text(remove_color(text))
            if tWidth > maxWidthTable[i] then
              maxWidthTable[i] = tWidth
            end
          end
        end
      end

      scale = 0.25
      x = 5
      y = (screenHeight - 32 * #scores * scale) * 0.5
      if y < 32 then -- shrink to fit
        scale = (screenHeight - 64) / (32 * #scores)
        y = 32
      end
      width = (maxWidthTable[1] + maxWidthTable[2] + maxWidthTable[3]) * scale
      djui_hud_set_color(0, 0, 0, 128);
      djui_hud_render_rect(x - 5, y, width + 10, #scores * 32 * scale);

      for a, textTable in ipairs(scores) do
        for b, text in ipairs(textTable) do
          djui_hud_set_color(255, 255, 255, 255)
          djui_hud_print_text_with_color(text, x, y, scale)
          x = x + maxWidthTable[b] * scale
        end
        y = y + 32 * scale
        x = 5
      end
    end
    scale = 0.5
  elseif get_active_sabo() ~= 0 or (GST.mhMode == 3 and (GST.mhState == 1 or GST.mhState == 2) and (sMario0.team ~= 1 or sMario0.dead)) then
    local lines = {}
    local sabo = get_active_sabo()
    if sabo ~= 0 then
      table.insert(lines, trans("sabo_active"))
      table.insert(lines, get_sabo_location())
      if sabo == 2 then
        table.insert(lines, trans("sabo_gas"))
      elseif sabo == 3 then
        table.insert(lines, trans("sabo_dark"))
      else
        table.insert(lines, trans("sabo_bomb"))
        local seconds = math.ceil((MEGA_BOMB_LENGTH + 10) - GST.saboTimer / 30)
        local minutes = seconds // 60
        seconds = seconds % 60
        table.insert(lines, trans("sabo_bomb_timer", minutes, seconds))
        if minutes == 0 and seconds <= 30 and GST.saboTimer % 30 == 0 then
          play_sound(SOUND_GENERAL2_SWITCH_TICK_FAST, gGlobalSoundSource)
        end
      end
    elseif GST.saboActive ~= 0 then
      if GST.saboActive == 2 then
        table.insert(lines, trans("sabo_gas"))
      elseif GST.saboActive == 3 then
        table.insert(lines, trans("sabo_dark"))
      else
        table.insert(lines, trans("sabo_bomb"))
      end
      local seconds = 10 - GST.saboTimer // 30
      table.insert(lines, trans("sabo_activate_timer", seconds))
    elseif GST.saboTimer ~= 0 and sMario0.team ~= 1 and (not sMario0.dead) then
      local seconds = math.ceil(GST.saboTimer / 30)
      local minutes = seconds // 60
      seconds = seconds % 60
      table.insert(lines, trans("sabo_cooldown", minutes, seconds))
    elseif sabo_valid() then
      table.insert(lines, trans("sabo_info", menuButtonString[saboButton]))
    elseif sMario0.team ~= 1 and (not sMario0.dead) then
      table.insert(lines, "\\#ff5a5a\\" .. trans("sabo_info", menuButtonString[saboButton]))
    end
    width = 0
    scale = 0.25
    for a, line in ipairs(lines) do
      local thisWidth = djui_hud_measure_text(remove_color(line)) * scale
      if thisWidth > width then width = thisWidth end
    end
    local screenHeight = djui_hud_get_screen_height()
    x = 5
    y = (screenHeight - 32 * #lines * scale) * 0.5

    djui_hud_set_color(0, 0, 0, 128)
    djui_hud_render_rect(x - 5, y, width + 10, #lines * 32 * scale)
    for a, line in ipairs(lines) do
      if a == 4 and ((MEGA_BOMB_LENGTH + 10) - GST.saboTimer / 30) <= 10 then
        x = x + math.random(-1, 1)
        y = y + math.random(-1, 1)
      end
      djui_hud_set_color(255, 255, 255, 255)
      djui_hud_print_text_with_color(line, x, y, scale)
      y = y + 32 * scale
    end
    scale = 0.5
  end
  if (showSpeedrunTimer or showLastStarTime) and GST.mhMode ~= 2 then
    width = 0
    text = ""
    if showSpeedrunTimer then
      local miliseconds = math.floor(GST.speedrunTimer / 30 % 1 * 100)
      local seconds = GST.speedrunTimer // 30 % 60
      local minutes = GST.speedrunTimer // 30 // 60 % 60
      local hours = GST.speedrunTimer // 30 // 60 // 60
      text = string.format("%d:%02d:%02d.%02d", hours, minutes, seconds, miliseconds)
      width = 118 * scale
    end
    if showLastStarTime then
      local miliseconds = math.floor(GST.lastStarTime / 30 % 1 * 100)
      local seconds = GST.lastStarTime // 30 % 60
      local minutes = GST.lastStarTime // 30 // 60 % 60
      local hours = GST.lastStarTime // 30 // 60 // 60
      text = text .. string.format(" \\#5aff5a\\(%d:%02d:%02d.%02d)", hours, minutes, seconds, miliseconds)
      width = width + 160 * scale
    end

    local screenHeight = djui_hud_get_screen_height()
    x = (screenWidth - width) * 0.5
    y = screenHeight - 16

    djui_hud_set_color(0, 0, 0, 128);
    djui_hud_render_rect(x - 6, y, width + 12, 32 * scale);

    djui_hud_set_color(255, 255, 255, 255);
    djui_hud_set_font(FONT_NORMAL)
    djui_hud_print_text_with_color(text, x, y, scale);
  end

  -- timer
  scale = 0.5
  if (GST.mhMode == 2 and campaignRecordValid) then
    local time = GST.speedrunTimer
    local miliseconds = math.floor(time / 30 % 1 * 100)
    local seconds = time // 30 % 60
    local minutes = time // 30 // 60 % 60
    text = string.format("%02d:%02d.%02d", minutes, seconds, miliseconds)
    width = djui_hud_measure_text(text) * scale
    x = 6
    y = 0

    djui_hud_set_color(0, 0, 0, 128);
    djui_hud_render_rect(x - 6, y, width + 12, 16);

    djui_hud_set_color(255, 255, 255, 255);
    djui_hud_print_text(text, x, y, scale);
  elseif (GST.mhTimer and GST.mhTimer > 0) then
    local seconds = GST.mhTimer // 30 % 60
    local minutes = GST.mhTimer // 1800
    text = string.format("%d:%02d", minutes, seconds)
    width = djui_hud_measure_text(text) * scale
    x = 6
    y = 0

    djui_hud_set_color(0, 0, 0, 128);
    djui_hud_render_rect(x - 6, y, width + 12, 16);

    djui_hud_set_color(255, 255, 255, 255);
    djui_hud_print_text(text, x, y, scale);
  end

  -- pause menu secrets
  if is_game_paused() and not djui_hud_is_pause_menu_created() then
    x = 22
    y = djui_hud_get_screen_height() - 35
    if m0.area.numRedCoins ~= 0 and m0.area.numRedCoins ~= 8 then
      y = y - 20
    end
    if m0.area.numSecrets ~= 0 then
      local collected = m0.area.numSecrets - count_objects_with_behavior(get_behavior_from_id(id_bhvHiddenStarTrigger))

      djui_hud_set_font(FONT_HUD)
      local ctext = tostring(collected)
      local ttext = tostring(m0.area.numSecrets)
      while ttext:len() > ctext:len() do
        ctext = " " .. ctext
      end
      local twidth = 16 * ctext:len()
      width = 32 + twidth * 2
      --djui_hud_set_color(20, 20, 20, 255)
      --djui_hud_render_rect(x - 2, y - 2, 18 + width, 20)

      djui_hud_set_color(255, 255, 255, 255)
      djui_hud_print_text("S", x, y, 1)
      x = x + 16
      djui_hud_print_text("@", x, y, 1)
      x = x + 16
      djui_hud_print_text(ctext, x, y, 1)
      x = x + twidth
      djui_hud_print_text("/", x, y, 1)
      x = x + 16
      djui_hud_print_text(ttext, x, y, 1)
    end
  end
end

-- double health mode
local ommVanish = 255
-- darkness sabo vars for interpolation
local darknessPrevX = nil
local darknessPrevY = nil
local darknessPrevRectSize = nil
function behind_hud_render()
  djui_hud_set_resolution(RESOLUTION_N64)
  djui_hud_set_font(FONT_HUD)
  djui_hud_set_color(255, 255, 255, 255)
  local screenWidth = djui_hud_get_screen_width()
  local x, y = 0, 0
  local actSelect = obj_get_first_with_behavior_id(id_bhvActSelector)
  actualHealthBeforeRender = m0.health
  if ROMHACK and ROMHACK.lifeOverride and sMario0.team == 1 then
    m0.numLives = sMario0.runnerLives
  end

  if storeVanish and m0.capTimer > 1 then
    m0.flags = m0.flags | MARIO_VANISH_CAP
  end

  -- darkness/poison gas sabo (visual)
  local sabo = get_active_sabo()
  if sabo == 2 then
    local screenHeight = djui_hud_get_screen_height()
    djui_hud_set_color(255, 255, 50, 50*-(gasFade-1))
    djui_hud_render_rect(0, 0, screenWidth + 10, screenHeight + 10)
    djui_hud_set_color(255, 255, 255, 255)
  elseif (sabo == 3 and sMario0.team == 1 and (not sMario0.dead) and (not actSelect)) or darknessFade < 1 then
    local screenHeight = djui_hud_get_screen_height()
    local pos = { x = m0.pos.x, y = m0.pos.y + 80, z = m0.pos.z }
    local out = { x = 0, y = 0, z = 0 }
    djui_hud_world_pos_to_screen_pos(pos, out)
    --djui_chat_message_create(tostring(out.z))
    local rectSize = 400
    if m0.particleFlags & ACTIVE_PARTICLE_FIRE ~= 0 then -- increased size when burning
      rectSize = rectSize * 2
    end
    if out.z ~= 0 then
      rectSize = rectSize / out.z * -200
    end
    if darknessFade then
      rectSize = rectSize + 400 * darknessFade
    end
    djui_hud_set_color(0, 0, 0, 255)
    if darknessPrevX == nil then
      darknessPrevX = out.x
      darknessPrevY = out.y
      darknessPrevRectSize = rectSize
    end
    local tex = TEX_SPOTLIGHT
    local spotCornerX = out.x - rectSize
    local spotCornerY = out.y - rectSize
    local spotCornerBX = out.x + rectSize
    local spotCornerBY = out.y + rectSize
    -- interp
    local prevSpotCornerX = darknessPrevX - darknessPrevRectSize
    local prevSpotCornerY = darknessPrevY - darknessPrevRectSize
    local prevSpotCornerBX = darknessPrevX + darknessPrevRectSize
    local prevSpotCornerBY = darknessPrevY + darknessPrevRectSize
    djui_hud_render_texture_interpolated(tex, prevSpotCornerX, prevSpotCornerY, darknessPrevRectSize / tex.width * 2,
      darknessPrevRectSize / tex.height * 2, spotCornerX, spotCornerY, rectSize / tex.width * 2, rectSize / tex.height *
      2)
    djui_hud_render_rect_interpolated(0, 0, screenWidth + 10, prevSpotCornerY, 0, 0, screenWidth + 10, spotCornerY)
    djui_hud_render_rect_interpolated(0, darknessPrevY + darknessPrevRectSize, screenWidth + 10,
      screenHeight + 10 - prevSpotCornerBY, 0, out.y + rectSize, screenWidth + 10, screenHeight + 10 - spotCornerBY)
    djui_hud_render_rect_interpolated(0, prevSpotCornerY, prevSpotCornerX, darknessPrevRectSize * 2, 0, spotCornerY,
      spotCornerX, rectSize * 2)
    djui_hud_render_rect_interpolated(prevSpotCornerBX, prevSpotCornerY, screenWidth + 10 - prevSpotCornerBX,
      darknessPrevRectSize * 2, spotCornerBX, spotCornerY, screenWidth + 10 - spotCornerBX, rectSize * 2)
    djui_hud_set_color(255, 255, 255, 255)

    darknessPrevX = out.x
    darknessPrevY = out.y
    darknessPrevRectSize = rectSize
  end

  local dispFlags = hud_get_value(HUD_DISPLAY_FLAGS)
  if sMario0.team ~= 1 or sMario0.spectator == 1 then
    dispFlags = dispFlags & ~HUD_DISPLAY_FLAG_LIVES
  elseif not (charSelectExists or actSelect) then
    dispFlags = dispFlags | HUD_DISPLAY_FLAG_LIVES
  end
  hud_set_value(HUD_DISPLAY_FLAGS, dispFlags)

  -- move star counter
  if not (actSelect or charSelectExists or PersonalStarCounter or hud_is_hidden()) then
    dispFlags = dispFlags & ~HUD_DISPLAY_FLAG_STAR_COUNT
    hud_set_value(HUD_DISPLAY_FLAGS, dispFlags)
    x = 22
    y = 15
    if dispFlags & HUD_DISPLAY_FLAG_LIVES ~= 0 then
      y = y + 20
      if m0.flags & MARIO_SPECIAL_CAPS ~= 0 and m0.capTimer ~= 0 then
        y = y + 20
      end
    end
    djui_hud_render_texture(gTextures.star, x, y, 1, 1)
    x = x + 16
    if GST.mhMode == 2 or GST.starRun == -1 then
      if m0.numStars < 100 then
        djui_hud_print_text("@", x, y, 1)
        x = x + 16
      end
      djui_hud_print_text(tostring(m0.numStars), x, y, 1)
    else
      local text = tostring(m0.numStars)
      local totalString = tostring(GST.starRun)
      while #text < #totalString do
        text = "0" .. text
      end
      text = text .. "/" .. totalString
      djui_hud_print_text(text, x, y, 1)
    end
  end

  if actSelect then
    if actSelect.oTimer > 5 and (GST.mhMode == 3 or (sMario0.team ~= 1 and showRadar)) then
      render_radar_act_select()
    end
  else
    local ommHud = (OmmEnabled and OmmApi.omm_get_setting(m0, "hud"))
    if apply_double_health(0) then
      if not (hud_is_hidden()) then
        dispFlags = dispFlags & ~HUD_DISPLAY_FLAG_POWER
        hud_set_value(HUD_DISPLAY_FLAGS, dispFlags)
        x = screenWidth * 0.5 - 51
        y = 8

        render_power_meter_mariohunt(m0.health, x, y, 64, 64)
      else
        local doubleHealth = 2 * m0.health - 0xFF
        if m0.health >= 0x500 then
          local trueHealth = m0.health
          m0.health = doubleHealth - 0x801
          if ommHud and ommHud ~= 3 then
            if ommHud == 2 then -- vanishing (not perfect but oh well)
              local showHudAction = (m0.action & ACT_FLAG_IDLE ~= 0) or
                  (m0.action & ACT_FLAG_PAUSE_EXIT ~= 0 and m0.action & ACT_FLAG_ON_POLE ~= 0)
              if (m0.input & INPUT_ZERO_MOVEMENT == 0 or m0.input & INPUT_Z_DOWN ~= 0 or ommVanish > 255 or (not showHudAction and ommVanish < 255)) and m0.freeze == 0 and trueHealth == prevHealth then
                ommVanish = ommVanish - 16
                if ommVanish <= 80 then
                  ommVanish = 0
                end
              elseif trueHealth == prevHealth and showHudAction then
                if ommVanish < 255 then
                  ommVanish = math.min(ommVanish + 16, 255)
                end
              elseif trueHealth ~= prevHealth then
                ommVanish = 255 + 60 * 16
              end
              djui_hud_set_color(255, 255, 255, clamp(ommVanish, 80, 255))
            end

            x = screenWidth - 32
            y = 48
            djui_hud_print_text("+8", x, y, 1)
          elseif not expectedHudState then
            x = screenWidth - 64
            y = djui_hud_get_screen_height() - 16
            djui_hud_print_text("HP+8", x, y, 1)
          end
        else
          m0.health = doubleHealth
        end
      end
    else
      dispFlags = dispFlags | HUD_DISPLAY_FLAG_POWER
      hud_set_value(HUD_DISPLAY_FLAGS, dispFlags)
    end
    if dispFlags & HUD_DISPLAY_FLAG_LIVES ~= 0 and ommHud and ommHud ~= 3 and ommHud ~= 0 and sMario0.team == 1 and sMario0.runnerLives and not sMario0.dead then -- omm lives counter
      x = 16
      y = 2
      render_player_head(0, x, y, 0.75, 0.75, true)
      x = x + 14
      djui_hud_print_text(tostring(sMario0.runnerLives), x, y, 0.75)
    end
  end
end

function runner_hud(sMario)
  local text = ""
  if GST.mhMode ~= 2 then
    -- set star text
    local timeLeft, special = get_leave_requirements(sMario)
    if special then
      text = special
    elseif timeLeft <= 0 then
      text = trans("can_leave")
    elseif GST.starMode then
      text = trans("stars_left", timeLeft)
    else
      timeLeft = timeLeft + 29
      local seconds = timeLeft // 30 % 60
      local minutes = (timeLeft // 1800)
      text = trans("time_left", minutes, seconds)
    end
  else
    return unstarted_hud()
  end
  return text
end

function hunter_hud()
  -- kick out timer in bowser levels
  if hunterKickTimer ~= 0 and GST.mhMode ~= 3 then
    local text = string.format("%s \\#ff5a5a\\(%d)", trans("no_runners_here"), 31 - hunterKickTimer)
    return text
  elseif GST.mhMode == 3 and not (np0.currCourseNum == 0 or (ROMHACK and ROMHACK.hubStages and ROMHACK.hubStages[np0.currCourseNum])) then
    local playerCount, isHunter = get_player_and_corpse_count(np0.currCourseNum, np0.currLevelNum, np0.currAreaIndex,
      np0.currActNum)
    if playerCount == 0 then
      local text = ""
      if isHunter then
        text = trans("no_runners_here")
      else
        text = trans("no_players_here")
      end
      return text
    end
  end

  local text = ""
  local runnerCount = 0
  local lastRunner = 0
  if runnerTarget and runnerTarget ~= -1 and GST.mhMode ~= 2 and GST.mhMode ~= 3 then
    local np = NetP[runnerTarget]
    local sMario = PST[runnerTarget]
    if np and sMario and np.connected and sMario.team == 1 then
      lastRunner = runnerTarget
      runnerCount = 1
    end
  end
  if runnerCount == 0 then
    for i = 0, (MAX_PLAYERS - 1) do
      local np = NetP[i]
      if np.connected and PST[i].team == 1 and (not PST[i].dead) then
        local playerColor = network_get_player_text_color_string(np.localIndex)
        text = text .. playerColor .. np.name .. ", "
        runnerCount = runnerCount + 1
        lastRunner = i
      end
    end
  end

  if GST.mhMode == 3 and GST.anarchy == 3 and (not sMario0.dead) then
    return trans_plural("runners_remain", runnerCount)
  end

  -- set player text
  if lastRunner ~= 0 and runnerCount == 1 and GST.mhMode ~= 2 then
    local np = NetP[lastRunner]
    local playerColor = network_get_player_text_color_string(np.localIndex)
    local text = playerColor .. np.name .. "\\#ffffff\\: "

    local course = np.currCourseNum
    local level = np.currLevelNum
    local area = np.currAreaIndex
    local act = np.currActNum
    local name = np.overrideLocation
    if np.overrideLocation == nil or np.overrideLocation == "" then
      name = get_custom_level_name(course, level, area)
    end

    text = text .. name
    if act ~= 0 then
      text = text .. " #" .. act
    end

    return text
  end

  if text == "" then
    text = trans("no_runners")
  else
    local default = "\\#00ffff\\" .. trans("runners") .. ": "
    text = default .. text:sub(1, -3)
  end

  return text
end

function timer_hud(sMario)
  -- set timer text
  local frames = (sMario and sMario.pause) or (GST.mhTimer)
  local seconds = math.ceil(frames / 30)
  local text = ""
  if not sMario then
    if frames > GST.countdown then
      text = trans("until_runners", (seconds - GST.countdown // 30))
    elseif GST.mhMode == 3 then
      text = trans("until_grace", seconds)
    else
      text = trans("until_hunters", seconds)
    end
  else
    text = trans("frozen", seconds)
  end

  return text
end

function victory_hud()
  -- set win text
  local text = trans("win", "\\#ff5a5a\\" .. trans("hunters"))
  if GST.mhState == 5 then
    text = trans("game_over")
  elseif GST.mhState > 3 then
    text = trans("win", "\\#00ffff\\" .. trans("runners"))
  end
  return text
end

function unstarted_hud()
  -- display role
  local roleName, colorString = get_role_name_and_color(0)
  return colorString .. roleName
end

function camp_hud()
  return trans("camp_timer", campTimer // 30)
end

function shuffle_hud()
  local timer = GST.maxShuffleTime - GST.shuffleTimer
  if timer % 30 == 0 then
    play_sound(SOUND_GENERAL2_SWITCH_TICK_FAST, gGlobalSoundSource)
  end
  return trans("shuffle_timer", math.ceil(timer / 30))
end

function guard_hud(guard)
  local np = NetP[guard]
  local timer = PST[guard].guardTime
  local playerColor = network_get_player_text_color_string(guard)
  local name = playerColor .. np.name
  if timer ~= 0 then
    return trans("guard_timer", name, math.ceil(timer / 30))
  elseif guardCooldown == 0 then
    return trans("guard_info", buttonString[guardButton], name)
  else
    local timer = guardCooldown
    return trans("guard_cooldown", math.ceil(timer / 30))
  end
end

-- removes color string
function remove_color(text, get_color)
  local start = text:find("\\")
  local next = 1
  while (next) and (start) do
    start = text:find("\\")
    if start then
      next = text:find("\\", start + 1)
      if not next then
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

-- stops color text at the limit selected
function cap_color_text(text, limit)
  local slash = false
  local capped_text = ""
  local chars = 0
  local luaPoint = 0
  while luaPoint < text:len() do
    luaPoint = luaPoint + 1
    local char = text:sub(luaPoint, luaPoint)

    -- special characters are treated as multiple by lua: not doing this WILL cause game crashes!
    if string.byte(char) >= 128 then
      local foundEndChar = true
      while string.byte(char, char:len()) >= 128 do
        if luaPoint >= text:len() or char:len() >= 3 then -- 3 is the max, because the japanese characters are 3 lua characters long
          foundEndChar = false
          break
        end
        luaPoint = luaPoint + 1
        char = char .. text:sub(luaPoint, luaPoint)
      end
      if foundEndChar then
        luaPoint = luaPoint - 1
        char = char:sub(1, -2)
      end
    end

    if char == "\\" then
      slash = not slash
    elseif not slash then
      chars = chars + 1
      if chars > limit then break end
    end
    capped_text = capped_text .. char
  end
  return capped_text
end

-- converts hex string to RGB values
function convert_color(text)
  if text:sub(2, 2) ~= "#" then
    return nil
  end
  text = text:sub(3, -2)
  local rstring, gstring, bstring = "", "", ""
  if text:len() ~= 3 and text:len() ~= 6 then return 255, 255, 255, 255 end
  if text:len() == 6 then
    rstring = text:sub(1, 2) or "ff"
    gstring = text:sub(3, 4) or "ff"
    bstring = text:sub(5, 6) or "ff"
  else
    rstring = text:sub(1, 1) .. text:sub(1, 1)
    gstring = text:sub(2, 2) .. text:sub(2, 2)
    bstring = text:sub(3, 3) .. text:sub(3, 3)
  end
  local r = tonumber("0x" .. rstring) or 255
  local g = tonumber("0x" .. gstring) or 255
  local b = tonumber("0x" .. bstring) or 255
  return r, g, b, 255 -- alpha is no longer writeable
end

-- prints text on the screen... with color!
function djui_hud_print_text_with_color(text, x, y, scale, alpha)
  djui_hud_set_color(255, 255, 255, alpha or 255)
  local space = 0
  local color = ""
  local render = ""
  text, color, render = remove_color(text, true)
  while render do
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
    return 0, np0
  end

  local np = nil
  if not playerID then
    for i = 0, (MAX_PLAYERS - 1) do
      np = NetP[i]
      if remove_color(np.name) == remove_color(msg) then
        playerID = i
        break
      end
    end

    if not playerID then
      local subname = remove_color(msg):lower()
      for i = 0, (MAX_PLAYERS - 1) do -- try sub name
        np = NetP[i]
        local name = remove_color(np.name):lower()
        if name:find(subname) then
          playerID = i
          break
        end
      end

      if not playerID then
        djui_chat_message_create(trans("no_such_player"))
        return nil
      end
    end
  elseif playerID ~= math.floor(playerID) or playerID < 0 or playerID > (MAX_PLAYERS - 1) then
    djui_chat_message_create(trans("bad_id"))
    return nil
  else
    np = network_player_from_global_index(playerID)
    playerID = (np and np.localIndex)
  end
  if not (np and np.connected) then
    djui_chat_message_create(trans("no_such_player"))
    return nil
  end

  return playerID, np
end

-- uses custom star names if aplicable
real_get_star_name = get_star_name
function get_custom_star_name(course, starNum)
  if ROMHACK.starNames then
    if GST.ee then
      if ROMHACK.starNames_ee and ROMHACK.starNames_ee[course * 10 + starNum] then
        return ROMHACK.starNames_ee[course * 10 + starNum]
      end
    elseif ROMHACK.starNames[course * 10 + starNum] then
      return ROMHACK.starNames[course * 10 + starNum]
    end
  end
  if ROMHACK.vagueName then
    return ("Star " .. starNum)
  end

  return real_get_star_name(course, starNum)
end

_G.get_star_name = get_custom_star_name -- This makes other mods use this function instead. Pretty cool!

-- uses custom level names if applicable
real_get_level_name = get_level_name
function get_custom_level_name(course, level, area)
  if ROMHACK.levelNames and ROMHACK.levelNames[level * 10 + area] then
    return ROMHACK.levelNames[level * 10 + area]
  elseif ROMHACK.vagueName then
    return ("Course " .. course)
  elseif level == LEVEL_BOWSER_1 then
    return "Bowser 1"
  elseif level == LEVEL_BOWSER_2 then
    return "Bowser 2"
  elseif level == LEVEL_BOWSER_3 then
    return "Bowser 3"
  end
  return real_get_level_name(course, level, area)
end

_G.get_level_name = get_custom_level_name -- This makes other mods use this function instead. Pretty cool!

-- forces player out of invalid areas (lobby, star req, or minihunt star)
function warp_player_if_invalid_area()
  if sMario0.spectator ~= 1 or free_camera == 1 and didFirstJoinStuff then
    if ROMHACK and GST.mhState == 0 and np0.currLevelNum ~= (((not ROMHACK.noLobby) and LEVEL_LOBBY) or gLevelValues.entryLevel) then
      return warp_beginning()
    elseif GST.mhState == 1 or GST.mhState == 2 then
      if GST.mhMode == 2 then
        local correctAct = GST.getStar
        if correctAct == 7 then correctAct = 6 end
        if np0.currCourseNum == 0 then correctAct = 0 end
        if (np0.currLevelNum ~= GST.gameLevel or np0.currActNum ~= correctAct) then
          m0.health = 0x880
          prevHealth = 0x880
          actualHealthBeforeRender = 0x880
          return warp_beginning()
        end
      elseif (not (GST.freeRoam and (np0.currLevelNum ~= LEVEL_BOWSER_3 or GST.noBowser))) and GST.starRun ~= -1 and ROMHACK.requirements and GST.mhMode ~= 2 then -- enforce star requirements
        local requirements = ROMHACK.requirements[np0.currLevelNum] or 0
        if requirements >= GST.starRun then
          requirements = GST.starRun
          if ROMHACK.ddd and (np0.currLevelNum == LEVEL_BITDW or np0.currLevelNum == LEVEL_DDD) then
            requirements = requirements - 1
          end
        end
        if m0.numStars < requirements then
          return warp_beginning()
        end
      end
    end
  end
end

-- Warp cooldown and such
function on_warp()
  levelSize = 8192
  if prevHealth <= 0x110 and prevHealth > 0xFF then -- prevent full heal when warping at low health
    m0.health = prevHealth
  end
  storeVanish = false
  prevSafePos = { x = m0.pos.x, y = m0.pos.y, z = m0.pos.z }
  if romhackCam then
    set_camera_mode(m0.area.camera, CAMERA_MODE_ROM_HACK, 0)
  end

  unset_max_star()
  if warp_player_if_invalid_area() then
    expectedLocation.level = 0
    return
  end

  if not (np0.currAreaSyncValid and np0.currLevelSyncValid) then
    expectedLocation.level = np0.currLevelNum
    expectedLocation.area = np0.currAreaIndex
    expectedLocation.act = np0.currActNum
  end

  if sMario0.spectator ~= 1 then
    m0.invincTimer = 150 -- 5 seconds
    if localPrevCourse ~= np0.currCourseNum or localPrevAct ~= np0.currActNum then
      if GST.mhMode == 2 then
        miniRedCoinCollect = 0
        miniSecretCollect = 0
        iVoted = false
      elseif sMario0.team ~= 1 and GST.mhMode ~= 3
          and ((np0.currCourseNum == COURSE_BITDW and ((save_file_get_flags() & (SAVE_FLAG_HAVE_KEY_1 | SAVE_FLAG_UNLOCKED_BASEMENT_DOOR)) == 0))
            or (np0.currCourseNum == COURSE_BITFS and ((save_file_get_flags() & (SAVE_FLAG_HAVE_KEY_2 | SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR)) == 0))
            or (np0.currCourseNum == COURSE_BITS and not (GST.bowserBeaten or GST.no_bowser))) then
        local runnerHere = false
        for i = 1, (MAX_PLAYERS - 1) do
          if PST[i].team == 1 then
            local np = NetP[i]
            if np.connected and np.currCourseNum == np0.currCourseNum then
              runnerHere = true
              break
            end
          end
        end

        if (not runnerHere) and sMario0.pause ~= true and (sMario0.pause == false or sMario0.pause < 300) then
          sMario0.pause = 300
          hunterKickTimer = 20
        end
      end
    end

    if (sMario0.team == 1 or GST.mhMode == 3) and GST.mhMode ~= 2 then
      if localPrevCourse ~= np0.currCourseNum or localPrevAct ~= np0.currActNum then
        sMario0.runTime = 0
        localRunTime = 0
        sMario0.allowLeave = false
        lastObtainable = -1
      end
      neededRunTime, localRunTime = calculate_leave_requirements(sMario0, localRunTime)
    end

    table.insert(warpTree, (np0.currLevelNum * 10 + np0.currAreaIndex))
    if #warpTree > 4 then table.remove(warpTree, 1) end
    if warpCooldown == 0 then
      warpTree = {}
    elseif #warpTree >= 4 and (warpTree[1] == warpTree[3] or warpTree[2] == warpTree[4]) and sMario0.team == 1 then
      m0.hurtCounter = m0.hurtCounter + (#warpTree * 4)
      djui_popup_create(trans("warp_spam"), 1)
    end
    warpCooldown = 300 -- 5 seconds
  end

  local cname = ROMHACK.levelNames and ROMHACK.levelNames[np0.currLevelNum * 10 + np0.currAreaIndex]
  if cname and np0.currCourseNum ~= 0 then -- replace the name of the course
    local course = np0.currCourseNum
    if course < 16 then
      smlua_text_utils_course_name_replace(course, cname:upper())
    elseif course ~= 0 then
      smlua_text_utils_secret_star_replace(course, "   " .. cname:upper())
    end
  end

  set_season_lighting(month, np0.currLevelNum)

  if GST.mhState == 0 then -- and background music
    set_lobby_music(month)
    --play_music(0, custom_seq, 1)
  end

  if GST.mhMode ~= 2 and GST.mhMode ~= 3 and GST.mhState ~= 0 then
    local data = {
      id = PACKET_OTHER_WARP,
      index = np0.globalIndex,
      level = np0.currLevelNum,
      course = np0.currCourseNum,
      area = np0.currAreaIndex,
      act = np0.currActNum,
      prevCourse = localPrevCourse,
    }

    if on_packet_other_warp(data, true) then
      network_send(false, data)
    end
  end

  localPrevCourse = np0.currCourseNum
  localPrevAct = np0.currActNum
end

-- get lighting
function get_season_lighting(month, level)
  -- Default Lighting
  local lightDir = 0
  local overrideSkybox = -1
  local overrideEnvfx = -1
  local lightColorR = 255
  local lightColorG = 255
  local lightColorB = 255
  local vertexColorR = 255
  local vertexColorG = 255
  local vertexColorB = 255
  local skyboxColorR = 255
  local skyboxColorG = 255
  local skyboxColorB = 255
  local fogColorR = 255
  local fogColorG = 255
  local fogColorB = 255
  local fogIntensity = 1

  if noSeason or (month ~= 10 and month ~= 12) then
    if level == LEVEL_LOBBY then
      lightDir = 300 -- dark?
    end
  elseif month == 10 then
    lightDir = 500    -- dark?
    overrideSkybox = BACKGROUND_HAUNTED
    lightColorR = 100 -- purple tint
    lightColorG = 100 -- purple tint
    vertexColorR = 100
    vertexColorG = 100
    fogColorR = 100
    fogColorG = 100
    fogIntensity = 1.02
  elseif month == 12 then
    overrideEnvfx = ENVFX_SNOW_NORMAL
    overrideSkybox = BACKGROUND_SNOW_MOUNTAINS
    lightColorR = 200 -- blue tint
    vertexColorR = 200
    fogColorR = 200
  end

  return {
    lightDir = lightDir,
    overrideSkybox = overrideSkybox,
    overrideEnvfx = overrideEnvfx,
    lightColorR = lightColorR,
    lightColorG = lightColorG,
    lightColorB = lightColorB,
    vertexColorR = vertexColorR,
    vertexColorG = vertexColorG,
    vertexColorB = vertexColorB,
    skyboxColorR = skyboxColorR,
    skyboxColorG = skyboxColorG,
    skyboxColorB = skyboxColorB,
    fogColorR = fogColorR,
    fogColorG = fogColorG,
    fogColorB = fogColorB,
    fogIntensity = fogIntensity,
  }
end

function set_season_lighting(month, level)
  local lighting = get_season_lighting(month, level)
  set_override_skybox(lighting.overrideSkybox)
  set_override_envfx(lighting.overrideEnvfx)
  set_lighting_dir(2, lighting.lightDir)
  set_lighting_color(0, lighting.lightColorR) -- blue tint
  set_lighting_color(1, lighting.lightColorG)
  set_lighting_color(2, lighting.lightColorB)
  set_vertex_color(0, lighting.vertexColorR)
  set_vertex_color(1, lighting.vertexColorG)
  set_vertex_color(2, lighting.vertexColorB)
  set_skybox_color(0, lighting.skyboxColorR)
  set_skybox_color(1, lighting.skyboxColorG)
  set_skybox_color(2, lighting.skyboxColorB)
  set_fog_color(0, lighting.fogColorR)
  set_fog_color(1, lighting.fogColorG)
  set_fog_color(2, lighting.fogColorB)
  set_fog_intensity(lighting.fogIntensity)
end

-- replaces parts of a string with ".", and also removes color
function corrupt_string(text, portion_)
  local portion = math.min(portion_, 1)
  local colorlessText = remove_color(text)
  local corruptChars = math.ceil(colorlessText:len() * portion)
  if corruptChars == 0 then return text end
  local validToCorrupt = {}
  for i = 1, colorlessText:len() do
    table.insert(validToCorrupt, i)
  end

  local corrupted = 0
  while #validToCorrupt ~= 0 and corrupted < corruptChars do
    local spot = math.random(1, #validToCorrupt)
    local toCorrupt = validToCorrupt[spot]
    colorlessText = colorlessText:sub(1, toCorrupt - 1) .. "." .. colorlessText:sub(toCorrupt + 1)
    table.remove(validToCorrupt, spot)
    corrupted = corrupted + 1
  end
  return colorlessText
end

function on_player_connected(m)
  if mystery_popup_off() then
    local np = NetP[m.playerIndex]
    local playerColor = network_get_player_text_color_string(np.localIndex)
    local name = playerColor .. np.name
    djui_chat_message_create(trans("connected", name))
    network_player_set_override_location(np, trans("menu_unknown"))

    if playPopupSounds then
      play_sound(SOUND_GENERAL_COIN, gGlobalSoundSource)
    end
  end
  if network_is_server() and GST.mhMode == 3 then -- prevent from counting towards hunters
    local sMario = gPlayerSyncTable[m.playerIndex]
    become_runner(sMario)
    sMario.dead = true
    sMario.knownDead = true
  end
end

function on_player_disconnected(m)
  if m.playerIndex == 0 then
    set_season_lighting(0, 0) -- otherwise, the skybox color doesn't reset
    djui_reset_popup_disabled_override()
    return
  end

  leader, scoreboard = calculate_placement()
  local np = NetP[m.playerIndex]
  local sMario = PST[m.playerIndex]
  -- unassign attack
  if np.globalIndex == attackedBy then attackedBy = nil end
  -- display message if left due to crash or disconnect
  if sMario.choseToLeave == false or mystery_popup_off() then
    local playerColor = network_get_player_text_color_string(np.localIndex)
    local name = playerColor .. np.name
    if sMario.choseToLeave == false then
      djui_chat_message_create(trans("leave_error", name))
    else
      djui_chat_message_create(trans("disconnected", name))
    end
  end

  -- for host only; rejoin handling
  if network_is_server() then
    -- unassign stats
    sMario.wins, sMario.hardWins, sMario.exWins, sMario.wins_standard, sMario.hardWins_standard, sMario.exWins_standard, sMario.wins_mys, sMario.hardWins_mys, sMario.exWins_mys, sMario.kills, sMario.maxStreak, sMario.maxStar, sMario.beenRunner, sMario.pRecordOmm, sMario.pRecordOther, sMario.parkourRecord, sMario.playtime =
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 599, 599, 599, 0

    local doRejoinHandle = (sMario.team == 1 or GST.mhMode == 2 or GST.mhMode == 3 or sMario.forceSpectate)
    local discordID = sMario.discordID or 0
    local dead = sMario.dead
    sMario.discordID = 0
    sMario.placement = 9999
    sMario.placementASN = 9999
    sMario.fasterActions = true
    sMario.role = 0
    sMario.knownDead = true
    sMario.dead = true

    -- assign mute status to name, to prevent getting around
    if sMario.mute then
      mute_storage[remove_color(np.name)] = 1
      sMario.mute = false
    end
    if doRejoinHandle then
      local team = sMario.team or 0
      local runtime = sMario.runTime or 0
      local lives = sMario.runnerLives or GST.runnerLives

      print(tostring(discordID), "left")

      become_hunter(sMario) -- be hunter by default
      if discordID ~= 0 then
        local playerColor = network_get_player_text_color_string(np.localIndex)
        local name = playerColor .. np.name
        rejoin_timer[discordID] = {
          name = name,
          timer = 3600, -- 2 minutes
          team = (GST.mhMode ~= 2 and team) or 0,
          lives = lives,
          stars = sMario.totalStars,
          forceSpec = sMario.forceSpectate,
          dead = dead,
        }
        global_popup_lang("rejoin_start", name, nil, 1)
      end
      if team == 1 and (not dead) and GST.mhMode ~= 0 and GST.mhMode ~= 3 and (discordID == 0 or GST.mhMode == 2) then
        local newID = new_runner(true)
        if newID then
          network_send_include_self(true, {
            id = PACKET_KILL,
            newRunnerID = newID,
            time = runtime or 0,
          })
        elseif GST.mhMode == 2 then
          rejoin_timer[discordID].team = 1
        end
      end
    end
  end
end

function on_game_exit()
  sMario0.choseToLeave = true
end

-- create the Green Demon object (built from 1up, obviously)
E_MODEL_DEMON = ((not LITE_MODE) and smlua_model_util_get_id("demon_geo")) or E_MODEL_1UP
E_MODEL_MH_SPARKLE = ((not LITE_MODE) and smlua_model_util_get_id("mh_sparkle_geo")) or E_MODEL_SPARKLES
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
    local demonStop = (m0.invincTimer > 0)
    local demonDespawn = ((not demonOn) or sMario0.team ~= 1 or GST.mhState ~= 2)
    demon_move_towards_mario(o)
    if demonDespawn then
      o.activeFlags = ACTIVE_FLAG_DEACTIVATED
    elseif demonStop then
      -- nothing
    elseif dist_between_objects(o, m0.marioObj) > 5000 then -- clip at far distances
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
  local player = m0.marioObj
  if (player) then
    local sp34 = player.header.gfx.pos.x - o.oPosX;
    local sp30 = player.header.gfx.pos.y + 120 - o.oPosY;
    local sp2C = player.header.gfx.pos.z - o.oPosZ;
    local sp2A = atan2s(math.sqrt(sqr(sp34) + sqr(sp2C)), sp30);

    obj_turn_toward_object(o, player, 16, 0x1000);
    o.oMoveAnglePitch = approach_s16_symmetric(o.oMoveAnglePitch, sp2A, 0x1000);

    if obj_check_if_collided_with_object(o, player) ~= 0 then
      play_sound(SOUND_GENERAL_COLLECT_1UP, gGlobalSoundSource) -- replace?
      o.activeFlags = ACTIVE_FLAG_DEACTIVATED
      m0.health = 0xFF                                          -- die
    end
  end
  local vel = 30
  if m0.waterLevel >= m0.pos.y then
    vel = 15 -- half speed if mario is underwater
  end
  o.oVelY = sins(o.oMoveAnglePitch) * vel
  o.oForwardVel = coss(o.oMoveAnglePitch) * vel
end

id_bhvGreenDemon = hook_behavior(nil, OBJ_LIST_LEVEL, false, demon_init, demon_loop)

-- speeds up these actions; increases by this amount each frame
-- -1 is a special case for the stuck actions
local faster_actions = {
  [ACT_GROUND_BONK] = 1,
  [ACT_FORWARD_GROUND_KB] = 1,
  [ACT_BACKWARD_GROUND_KB] = 1,
  [ACT_DIVE_PICKING_UP] = 3,
  [ACT_PICKING_UP_BOWSER] = 1,
  [ACT_HARD_FORWARD_GROUND_KB] = 1,
  [ACT_SOFT_FORWARD_GROUND_KB] = 1,
  [ACT_HARD_BACKWARD_GROUND_KB] = 1,
  [ACT_SOFT_BACKWARD_GROUND_KB] = 1,
  [ACT_BACKWARD_WATER_KB] = 2,
  [ACT_FORWARD_WATER_KB] = 2,
  [ACT_RELEASING_BOWSER] = 2,
  [ACT_HEAVY_THROW] = 1,
  [ACT_STOMACH_SLIDE_STOP] = 1,
  [ACT_BUTT_STUCK_IN_GROUND] = -1,
  [ACT_FEET_STUCK_IN_GROUND] = -1,
  [ACT_HEAD_STUCK_IN_GROUND] = -1,
}

-- based off of example
---@param m MarioState
function mario_update(m)
  if not didFirstJoinStuff then
    if charSelectExists then
      charSelect.restrict_palettes(false)
    end
    return
  end

  local sMario = PST[m.playerIndex]
  local np = NetP[m.playerIndex]

  -- for b3313; prevents quick travel
  if ROMHACK and ROMHACK.name == "B3313" then
    if is_game_paused() and m.controller.buttonPressed & Y_BUTTON ~= 0 then
      if on_pause_exit(true) == false then
        m.controller.buttonPressed = m.controller.buttonPressed & ~Y_BUTTON
        play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
      end
    end
  end

  if faster_actions[m.action] and sMario.fasterActions then
    if faster_actions[m.action] == -1 then
      if m.actionTimer >= 5 and m.actionTimer <= 7 then
        m.actionTimer = m.actionTimer + 1
      else
        set_anim_to_frame(m, m.marioObj.header.gfx.animInfo.animFrame + 3)
      end
    elseif m.action ~= ACT_HARD_FORWARD_GROUND_KB or m.action ~= ACT_HARD_BACKWARD_GROUND_KB or (m.health - 0x40 * m.hurtCounter) > 0xFF then
      -- new animation system seems to make this not update immediately or something? add an additional 1 so this does something
      set_anim_to_frame(m, m.marioObj.header.gfx.animInfo.animFrame + faster_actions[m.action] + 1)
    end
  elseif m.action == ACT_WARP_DOOR_SPAWN then
    m.freeze = math.max(m.freeze, 1) -- to avoid input bug
    set_mario_action(m, ACT_IDLE, 0)
  elseif m.action == ACT_UNLOCKING_KEY_DOOR and m.marioObj.header.gfx.animInfo.curAnim then
    set_anim_to_frame(m, m.marioObj.header.gfx.animInfo.curAnim.loopEnd)
  elseif m.prevAction == ACT_STAR_DANCE_WATER then
    m.prevAction = m.action
    if m.intendedMag ~= 0 then
      m.faceAngle.y = m.intendedYaw
      m.forwardVel = 10
    end
  elseif (m.action == ACT_SPAWN_NO_SPIN_AIRBORNE or m.action == ACT_SPAWN_SPIN_AIRBORNE) and sMario.fasterActions and ((np.currLevelNum ~= LEVEL_WDW or (np.currLevelNum == LEVEL_SSL and np.currAreaIndex == 2)) or np.currAreaSyncValid or not (ROMHACK and ROMHACK.ddd)) then
    if m.floor and not is_hazard_floor(m.floor.type) then
      m.pos.y = math.max(m.waterLevel, m.floorHeight) + 100 -- go to floor to prevent fall damage
      set_mario_action(m, ACT_IDLE, 0)
    end
  end

  -- force spectate
  if m.playerIndex == 0 and sMario.dead and (not sMario.forceSpectate) and GST.mhState ~= 1 and GST.mhState ~= 2 then
    sMario.dead = false
    sMario.knownDead = false
  elseif m.playerIndex == 0 and sMario.spectator ~= 1 and (sMario.forceSpectate or ((sMario.knownDead or GST.mhMode ~= 3) and sMario.dead)) then
    reset_camera_fix_bug(m.area.camera)
    if sMario.team == 1 then
      spectate_command("runner")
    else
      spectate_command("hunter")
    end
  elseif m.playerIndex == 0 and sMario.spectator ~= 1 and GST.mhMode == 3 and sMario.dead then
    m.health = 0xFF
  end

  -- guard feature for spectators
  ---@type integer|boolean
  local guardPlayer = (m.playerIndex == 0 and spectate_valid_for_guard())
  if guardPlayer and PST[guardPlayer].guardTime == 0 and guardCooldown == 0 and (m.controller.buttonPressed & (A_BUTTON >> (guardButton - 1))) ~= 0 then
    -- set guard cooldown based on amount of spectators
    local specCount = 1
    for i = 1, MAX_PLAYERS - 1 do
      if NetP[i].connected and PST[i].dead and PST[i].team == sMario0.team then
        specCount = specCount + 1
      end
    end
    specCount = math.max(2, specCount) -- minimum of 2, so its not instant
    if sMario0.team == 1 then
      guardCooldown = 450 * specCount  -- 15s per spectator (runner)
    else
      guardCooldown = 900 * specCount  -- 30s per spectator (hunter)
    end

    PST[guardPlayer].guardTime = 150 -- guard only lasts 5 sec
    play_sound(SOUND_MENU_POWER_METER, gGlobalSoundSource)
  elseif m.playerIndex == 0 then
    if sMario.guardTime and sMario.guardTime ~= 0 then
      sMario.guardTime = sMario.guardTime - 1
    end
    if guardCooldown ~= 0 then
      guardCooldown = guardCooldown - 1
    end
  end

  -- particles for guard
  if is_player_active(m) ~= 0 and sMario.guardTime and sMario.guardTime ~= 0 and sMario0.spectator == 1 and m.marioObj.oTimer % 5 == 0 then
    local o = spawn_non_sync_object(
      id_bhvTreeLeaf,
      E_MODEL_BUBBLE_PLAYER,
      m.pos.x, m.pos.y + 80, m.pos.z,
      nil)
    if o then
      obj_translate_xyz_random(o, 90)
      obj_scale_random(o, 0.5, 0)
    end
  end

  -- speed up music when mega bomb is close to going off
  if m.playerIndex == 0 and (GST.saboActive == 1 or lastTempoMulti ~= 1) then
    local seconds = math.ceil((MEGA_BOMB_LENGTH + 10) - GST.saboTimer / 30)
    local multiplier = 1
    if GST.saboActive == 1 and seconds < 30 then
      if seconds <= 5 then
        multiplier = 6
      else
        multiplier = 30 / seconds
      end
    end
    local currTempo = sequence_player_get_tempo(SEQ_PLAYER_LEVEL)
    if currTempo ~= math.floor(defaultTempo * lastTempoMulti) then
      defaultTempo = currTempo
      lastTempoMulti = 1
    end
    if lastTempoMulti ~= multiplier then
      lastTempoMulti = multiplier
      currTempo = math.floor(defaultTempo * multiplier)
      --djui_chat_message_create(tostring(currTempo))
      sequence_player_set_tempo(SEQ_PLAYER_LEVEL, currTempo)
    end
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

  -- skip star dialog
  if m.playerIndex == 0 and (m.action == ACT_STAR_DANCE_WATER or m.action == ACT_STAR_DANCE_NO_EXIT) and m.actionArg & 1 ~= 0 and m.actionState == 0 and m.actionTimer >= 75 then
    m.actionState = 2
  end

  -- make vertical wind less annoying + prevent camping
  if m.action == ACT_VERTICAL_WIND then
    if m.floor.type ~= SURFACE_VERTICAL_WIND then
      set_mario_action(m, ACT_FREEFALL, 0)
    elseif m.vel.y < 20 and m.pos.y < -2000 and campTimer ~= 0 then
      m.vel.y = 20
    end
  end

  -- buff water punch for hunters/all players in mysteryhunt
  if GST.mhMode == 3 or sMario.team ~= 1 then
    local waterPunchVel = 20
    if OmmEnabled then waterPunchVel = waterPunchVel * 2 end -- omm has fast swim
    if m.forwardVel < waterPunchVel and m.action == ACT_WATER_PUNCH then
      m.forwardVel = waterPunchVel
    end
  end

  -- spawn 1up if it does not exist
  if m.playerIndex == 0 and demonOn then
    local demonOkay = (sMario.team == 1 and m.health > 0xFF and m.invincTimer <= 0 and GST.mhState == 2)
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
    if sMario.team == 1 and m.numLives ~= sMario.runnerLives and sMario.runnerLives then
      m.numLives = sMario.runnerLives
    end
  end

  -- update last floor position
  local floorClass = mario_get_floor_class(m)
  if m.playerIndex == 0 and (GST.voidDMG ~= -1 or GST.mhMode == 3) and m.action ~= ACT_MH_BUBBLE_RETURN and m.floor and (m.pos.y - m.floorHeight < 1000) and (m.action & ACT_FLAG_SWIMMING ~= 0 or m.floor.normal.y > 0.99 or (floorClass ~= SURFACE_CLASS_SLIPPERY and floorClass ~= SURFACE_CLASS_VERY_SLIPPERY and m.floor.normal.y > 0.9))
      and not is_hazard_floor(m.floor.type) then
    if m.floor.object then
      local o = m.floor.object
      if (o.oVelX == 0 and o.oVelY == 0 and o.oVelZ == 0) and obj_has_behavior_id(o, id_bhvHiddenObject) ~= 0 and obj_has_behavior_id(o, id_bhvAnimatesOnFloorSwitchPress) ~= 0 then
        prevSafePos.obj = o
        prevSafePos.x = m.pos.x
        prevSafePos.y = o.oPosY + 200
        if prevSafePos.y > m.floorHeight + 400 then
          prevSafePos.y = m.floorHeight
        end
        prevSafePos.z = m.pos.z
        if obj_has_behavior_id(o, id_bhvSeesawPlatform) ~= 0 then
          prevSafePos.x = o.oPosX
          prevSafePos.z = o.oPosZ
        end
      end
    else
      prevSafePos.obj = nil
      prevSafePos.x = m.pos.x
      prevSafePos.y = m.floorHeight
      prevSafePos.z = m.pos.z
      if m.action == ACT_CAUGHT_IN_WHIRLPOOL then
        prevSafePos.y = prevSafePos.y + 1000
      end
    end
  end

  if m.playerIndex == 0 and DEBUG_SAFE_SURFACE then
    spawn_non_sync_object(
      id_bhvSparkleSpawn,
      E_MODEL_NONE,
      prevSafePos.x, prevSafePos.y, prevSafePos.z,
      nil
    )
  end

  if OmmEnabled and m.playerIndex == 0 then
    -- make voiddmg work with omm
    if (m.action & ACT_GROUP_CUTSCENE == 0) and (not died) and m.health > 0xFF and m.floor and (m.floor.type == SURFACE_DEATH_PLANE or m.floor.type == SURFACE_VERTICAL_WIND) and m.pos.y - m.floorHeight <= 2048 then
      on_death(m)
      m.health = math.max(m.health, 0x100)
    end

    -- make mysteryhunt death work with omm
    if gGlobalSyncTable.mhMode == 3 and (sMario.dead or (sMario.team == 1 and sMario.runnerLives == 0)) then
      OmmApi.omm_disable_feature("odysseyDeath", true)
    elseif m.hurtCounter == 0 then
      OmmApi.omm_disable_feature("odysseyDeath", false)
    end
  end

  -- update star counter in MiniHunt mode / handle challenge
  if GST.mhMode == 2 then
    m.numStars = sMario.totalStars or 0
    m.prevNumStarsForDialog = m.numStars

    -- invalid if there is another player
    if campaignRecordValid then
      if m.playerIndex == 0 and m.controller.buttonPressed & L_TRIG ~= 0 and m.controller.buttonDown & R_TRIG ~= 0 and GST.speedrunTimer > 30 then
        start_game(1) -- restart
        m.controller.buttonPressed = m.controller.buttonPressed & ~L_TRIG
        m.controller.buttonDown = m.controller.buttonDown & ~L_TRIG
      elseif m.playerIndex ~= 0 and np.connected and sMario.team == 1 then
        campaignRecordValid = false
      end
    end
  end

  if m.invincTimer > 2 then
    -- cut invincibility frames
    if GST.weak then
      m.invincTimer = m.invincTimer - 1
    end
    -- sparkle invulnerability frames
    if invincParticle and is_player_active(m) ~= 0 and sMario.spectator ~= 1 then
      m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags & ~GRAPH_RENDER_INVISIBLE
      local o = spawn_non_sync_object(
        id_bhvSparkle,
        E_MODEL_MH_SPARKLE,
        m.pos.x, m.pos.y + 80, m.pos.z,
        nil)
      if o then
        obj_translate_xyz_random(o, 90)
        obj_scale_random(o, 1, 0)
      end
    end
  end

  -- handle rejoining
  if m.playerIndex ~= 0 and network_is_server() and np.currAreaSyncValid and np.currLevelSyncValid and m.area.localAreaTimer >= 30 then
    local discordID = sMario.discordID or 0
    local name = remove_color(np.name)
    if mute_storage and mute_storage[name] then
      mute_storage[name] = nil
      sMario.mute = true
      djui_popup_create(trans("mute_auto", name), 1)
    end

    if rejoin_timer and discordID ~= 0 and rejoin_timer[discordID] then
      local data = rejoin_timer[discordID]
      if data.team == 1 then
        -- become runner again
        become_runner(sMario)
        sMario.runnerLives = data.lives
      else
        become_hunter(sMario)
      end
      sMario.forceSpectate = data.forceSpec or false
      sMario.dead = data.dead or false
      sMario.knownDead = sMario.dead
      --sMario.spectator = bool_to_int(sMario.forceSpectate or sMario.dead)
      sMario.totalStars = data.stars or 0
      global_popup_lang("rejoin_success", data.name, nil, 1)
      rejoin_timer[discordID] = nil
    end
  end

  if (not noSeason) and month == 13 then np.overrideModelIndex = CT_LUIGI end -- april fools

  -- parkour and race timer stuff
  if m.playerIndex == 0 then
    local dflags = hud_get_value(HUD_DISPLAY_FLAGS)
    local raceTimerOn = dflags & HUD_DISPLAY_FLAGS_TIMER
    if np.currLevelNum == LEVEL_LOBBY then
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
          if OmmEnabled then
            ref = "pRecordOmm"
          elseif movesetEnabled then
            ref = "pRecordOther"
          end
          local record = mod_storage_load(ref)

          if (not record) and OmmEnabled then
            record = mod_storage_load("parkourRecordOmm")
          end

          if not tonumber(record) or tonumber(record) > time then
            play_star_fanfare()
            djui_chat_message_create(trans("new_record"))
            mod_storage_save(ref, tostring(time))
            sMario0[ref] = time // 30
          else
            play_race_fanfare()
          end
        elseif m.pos.y < 200 and m.floor and m.floor.type ~= SURFACE_HARD and m.pos.y == m.floorHeight then
          parkourTimer = 0
          hud_set_value(HUD_DISPLAY_FLAGS, dflags & ~HUD_DISPLAY_FLAGS_TIMER)
          hud_set_value(HUD_DISPLAY_TIMER, 0)
        elseif m.controller.buttonDown & L_TRIG ~= 0 and m.controller.buttonDown & R_TRIG ~= 0 then
          m.health = 0x880
          actualHealthBeforeRender = 0x880
          prevHealth = 0x880
          warp_beginning()
        end
      elseif m.floor and m.floor.type == SURFACE_HARD then -- back on starting platform
        parkourTimer = 0
        prevSafePos = { x = m.pos.x, y = m.pos.y, z = m.pos.z }
        hud_set_value(HUD_DISPLAY_FLAGS, dflags | HUD_DISPLAY_FLAGS_TIMER)
        if m.pos.y > 2000 then
          m.pos.y = m.floorHeight
        end
      elseif m.floorHeight > 200 and raceTimerOn == 0 and parkourTimer == 0 then -- prevent cheese by jumping over starting platform (omm)
        m.pos.x, m.pos.y, m.pos.z = -12, 63, -2476
      end

      if m.invincTimer > 2 then m.invincTimer = 2 end -- prevent flashing
      if m.pos.y < -1500 and m.vel.y < 0 then         -- falling effect like in mk wii
        set_mario_particle_flags(m, ACTIVE_PARTICLE_FIRE, 0)
        play_sound(SOUND_MOVING_LAVA_BURN, gGlobalSoundSource)
      end
    elseif not cheatLocal then -- cheat local only (koopa and penguin)
      local o = obj_get_first_with_behavior_id(id_bhvKoopaRaceEndpoint)
      local peng = false
      if (not o) then
        o = obj_get_first_with_behavior_id(id_bhvPenguinRaceShortcutCheck)
        peng = true
      end

      if o and (peng or raceTimerOn ~= 0) then
        if peng and o.parentObj then
          -- check distance to shortcut
          if dist_between_objects(o, m.marioObj) < 500 and sMario.team == 1 then
            cheatLocal = true
          elseif cheatLocal and o.parentObj.oRacingPenguinMarioCheated == 0 then
            o.parentObj.oRacingPenguinMarioCheated = 1
          elseif (not cheatLocal) and o.parentObj.oRacingPenguinMarioCheated ~= 0 then
            o.parentObj.oRacingPenguinMarioCheated = 0
          end
        elseif (not peng) then
          -- check cannon (TODO: check if this works)
          if m.action == ACT_SHOT_FROM_CANNON and sMario.team == 1 then
            cheatLocal = true
          elseif cheatLocal and o.oKoopaRaceEndpointRaceStatus == 1 then
            o.oKoopaRaceEndpointRaceStatus = -1
          elseif (not cheatLocal) and o.oKoopaRaceEndpointRaceStatus == -1 then
            o.oKoopaRaceEndpointRaceStatus = 1
          end
        end
      end
    end
  end

  -- display as paused
  if sMario.pause and not mhHideHud then -- I need this for screenshots!
    m.marioBodyState.modelState = MODEL_STATE_NOISE_ALPHA
    m.invincTimer = 60
  end
  -- display metal particles
  if is_player_active(m) ~= 0 and (m.flags & MARIO_METAL_CAP) ~= 0 then
    set_mario_particle_flags(m, PARTICLE_SPARKLES, 0)
  end

  if ROMHACK.special_run then
    ROMHACK.special_run(m, gotStar)
  end

  -- set descriptions
  local rolename, _, color = get_role_name_and_color(m.playerIndex)
  if DEBUG_SHOW_PING then
    network_player_set_description(np, "Ping: " .. tostring(np.ping), color.r, color.g, color.b, 255)
  elseif GST.mhMode == 2 and frameCounter > 60 then
    network_player_set_description(np, trans_plural("stars", sMario.totalStars or 0), color.r, color.g, color.b, 255)
  elseif sMario.team == 1 and sMario.spectator ~= 1 and know_team(m.playerIndex) and frameCounter <= 60 then
    -- fix stupid desync bug
    if not sMario.runnerLives then
      sMario.runnerLives = GST.runnerLives
    elseif sMario.runnerLives < 0 then
      sMario.team = 0
    end
    network_player_set_description(np, trans_plural("lives", sMario.runnerLives), color.r, color.g, color.b, 255)
  else
    network_player_set_description(np, rolename, color.r, color.g, color.b, 255)
  end

  if m.playerIndex == 0 then
    warp_player_if_invalid_area()
  end

  -- appearance change
  if m.playerIndex == 0 or GST.mhMode == 3 or is_player_active(m) ~= 0 then
    local team = sMario.team
    local vIndex = m.playerIndex
    local vSMario = sMario
    if disguiseMod then
      local gIndex = disguiseMod.getDisguisedIndex(np.globalIndex)
      vSMario = PST[network_local_index_from_global(gIndex)]
      team = vSMario.team or 0
    end
    set_override_team_colors(np, team)

    if not know_team(vIndex) then
      m.marioBodyState.shadeR = 127
      m.marioBodyState.shadeG = 127
      m.marioBodyState.shadeB = 127
    elseif team == 1 then
      if runnerAppearance ~= 2 then
        m.marioBodyState.shadeR = 127
        m.marioBodyState.shadeG = 127
        m.marioBodyState.shadeB = 127
      end

      if runnerAppearance == 1 then -- sparkle
        spawn_non_sync_object(
          id_bhvSparkleSpawn,
          E_MODEL_NONE,
          m.pos.x, m.pos.y, m.pos.z,
          nil
        )
      elseif runnerAppearance == 2 then -- glow
        if m.marioBodyState.modelState & MODEL_STATE_METAL == 0 then
          local t = math.abs((frameCounter % 30) - 15) / 15
          if vSMario.hard == 1 then
            m.marioBodyState.shadeR = 255
            m.marioBodyState.shadeG = 255
            m.marioBodyState.shadeB = lerp(100, 0, t)
          elseif vSMario.hard == 2 then
            m.marioBodyState.shadeR = lerp(100, 0xb4, t)
            m.marioBodyState.shadeG = lerp(50, 0x5a, t)
            m.marioBodyState.shadeB = 255
          else
            m.marioBodyState.shadeR = lerp(150, 50, t)
            m.marioBodyState.shadeG = 255
            m.marioBodyState.shadeB = 255
          end
        else -- glow doesn't work for metal cap on mario and luigi, so change palette instead (in b-utils)
          m.marioBodyState.shadeR = 127
          m.marioBodyState.shadeG = 127
          m.marioBodyState.shadeB = 127
        end
      end
    else
      if hunterAppearance ~= 2 then
        m.marioBodyState.shadeR = 127
        m.marioBodyState.shadeG = 127
        m.marioBodyState.shadeB = 127
      end

      if hunterAppearance == 1 then     -- metal
        m.marioBodyState.modelState = m.marioBodyState.modelState | MODEL_STATE_METAL
      elseif hunterAppearance == 2 then -- glow
        if m.marioBodyState.modelState & MODEL_STATE_METAL == 0 then
          local t = math.abs((frameCounter % 30) - 15) / 15
          m.marioBodyState.shadeR = 255
          m.marioBodyState.shadeG = lerp(100, 0, t)
          m.marioBodyState.shadeB = lerp(100, 0, t)
        else
          m.marioBodyState.shadeR = 127
          m.marioBodyState.shadeG = 127
          m.marioBodyState.shadeB = 127
        end
      end
    end
  end

  -- if the game is inactive, disable the camp timer
  if GST.mhState and (GST.mhState == 0 or GST.mhState >= 3) then
    campTimer = nil
    return
  end

  -- for all players: disable endless stairs if there's enough stars or in free roam
  local surface = m.floor
  if ((GST.starRun ~= -1 and m.numStars >= GST.starRun) or GST.freeRoam) and surface and surface.type == 27 then
    surface.type = 0
    m.floor = surface
  end

  -- Rename stars in OMM (I'm trying my best to correct desync issues)
  if OmmEnabled and m.playerIndex == 0 and lastStarID then
    if (m.action == ACT_OMM_STAR_DANCE and m.actionTimer == 35) then
      network_send(true, {
        id = PACKET_OMM_STAR_RENAME,
        act = lastStar,
        course = np.currCourseNum,
        obj_id = lastStarID,
      })
      if ommRenameTimer == 0 then
        local name = get_custom_star_name(np.currCourseNum, lastStar)
        OmmApi.omm_register_star_behavior(lastStarID, name, string.upper(name))
      end
    elseif ommRenameTimer > 0 then
      ommRenameTimer = ommRenameTimer - 1
      if ommRenameTimer == 0 then
        local name = get_custom_star_name(np.currCourseNum, lastStar)
        OmmApi.omm_register_star_behavior(lastStarID, name, string.upper(name))
      end
    end
  end

  -- hunter update (not in mysteryhunt)
  if GST.mhMode ~= 3 and sMario.team ~= 1 then return hunter_update(m) end
  -- runner update
  return runner_update(m, sMario)
end

function runner_update(m, sMario)
  if sMario.team ~= 1 then
    m.numLives = 100                     -- applies in mysteryhunt
  elseif not sMario.runnerLives then
    sMario.runnerLives = GST.runnerLives -- fix stupid desync bug
  elseif sMario.runnerLives < 0 then
    sMario.team = 0
  end
  local np = NetP[m.playerIndex]

  if m.playerIndex == 0 then
    -- set 'been runner' status
    if sMario.beenRunner == 0 then
      print("Our 'Been Runner' status has been set")
      sMario.beenRunner = 1
      mod_storage_save("beenRunnner", "1")
    end

    -- reduce level timer
    if (not sMario.allowLeave) and GST.mhMode ~= 2 then
      if not (GST.starMode or neededRunTime <= localRunTime) then
        localRunTime = localRunTime + 1
      end

      -- match run time with other runners in level
      if frameCounter % 30 == 0 then -- only every second for less lag maybe
        for i = 1, (MAX_PLAYERS - 1) do
          if (PST[i].team == 1 or GST.mhMode == 3) and PST[i].spectator ~= 1 and NetP[i].connected then
            local theirNP = NetP[i] -- daft variable naming conventions
            local theirSMario = PST[i]
            if theirSMario.runTime and (theirNP.currLevelNum == np.currLevelNum) and (theirNP.currActNum == np.currActNum) and localRunTime < theirSMario.runTime then
              localRunTime = theirSMario.runTime
              neededRunTime, localRunTime = calculate_leave_requirements(sMario, localRunTime)
            end
          end
        end
        sMario.runTime = localRunTime
      end
    elseif network_is_server() and GST.mhMode == 2 and frameCounter % 60 == 0 then -- resend to avoid desync
      GST.gameLevel = GST.gameLevel
      GST.getStar = GST.getStar
    end
  end

  -- invincibility timers for certain actions
  local runner_invincible = {
    [ACT_PICKING_UP_BOWSER] = 120, -- 4 seconds
    [ACT_RELEASING_BOWSER] = 45,
    [ACT_READING_NPC_DIALOG] = 15,
    [ACT_READING_AUTOMATIC_DIALOG] = 30,
    [ACT_READING_SIGN] = 15,
    [ACT_HEAVY_THROW] = 20,
    [ACT_PUTTING_ON_CAP] = 10,
    [ACT_STAR_DANCE_NO_EXIT] = 60, -- 2 seconds
    [ACT_STAR_DANCE_WATER] = 60,   -- 2 seconds
    [ACT_STAR_DANCE_EXIT] = 60,    -- 2 seconds
    [ACT_WAITING_FOR_DIALOG] = 10,
    [ACT_DEATH_EXIT_LAND] = 10,
    [ACT_SPAWN_SPIN_LANDING] = 100,
    [ACT_SPAWN_NO_SPIN_LANDING] = 100,
    [ACT_IN_CANNON] = 10,
    [ACT_PICKING_UP] = 10,
  }
  if ACT_OMM_STAR_DANCE then
    runner_invincible[ACT_OMM_STAR_DANCE] = 40 -- the action is 80 frames long
  end

  local runner_camping = {
    [ACT_READING_NPC_DIALOG] = 1,
    [ACT_READING_AUTOMATIC_DIALOG] = 1,
    [ACT_WAITING_FOR_DIALOG] = 1,
    [ACT_STAR_DANCE_NO_EXIT] = 1,
    [ACT_STAR_DANCE_WATER] = 1,
    [ACT_READING_SIGN] = 1,
    [ACT_IN_CANNON] = 1,
    [ACT_VERTICAL_WIND] = 1,
  }

  local newInvincTimer = runner_invincible[m.action]

  if newInvincTimer and GST.weak then newInvincTimer = newInvincTimer * 2 end -- same amount in weak mode

  if newInvincTimer and m.invincTimer < newInvincTimer then
    m.invincTimer = newInvincTimer
  end
  if m.playerIndex == 0 then
    -- prevent castle BLJs unless Any% is enabled
    if np.currCourseNum == 0 and GST.starRun ~= -1 and m.action == ACT_LONG_JUMP and m.forwardVel < -100 then
      m.forwardVel = -100
    end

    -- prevent accessing PUs unless Any% is enabled
    if GST.starRun ~= -1 then
      if m.pos.x > 32768 or m.pos.x < -32768 then
        m.pos.x = (m.pos.x + 32768) % 65536 - 32768
      end
      if m.pos.z > 32768 or m.pos.z < -32768 then
        m.pos.z = (m.pos.z + 32768) % 65536 - 32768
      end
    end

    -- hardcoded OOB for mysteryhunt
    if GST.mhMode == 3 and ROMHACK.ddd then
      if np.currLevelNum == LEVEL_CASTLE_GROUNDS and (m.action & ACT_GROUP_MASK ~= ACT_GROUP_CUTSCENE) and (not is_transition_playing()) and m.pos.y < 1000 and m.pos.z < -3207 and m.pos.x > -512 and m.pos.x < 512 then
        warp_beginning()
      end
    end

    local camping = runner_camping[m.action]
    if (not campTimer) and camping then
      campTimer = 600 -- 20 seconds
    elseif campTimer and (not camping) and m.freeze == 0 then
      campTimer = nil
    end
  end

  -- adjust health loss for burning and toxic gas in double health mode
  if apply_double_health(m.playerIndex) then
    if (m.action == ACT_BURNING_FALL or m.action == ACT_BURNING_GROUND or m.action == ACT_BURNING_JUMP) then
      m.health = m.health + 5 -- burn is -10 per frame
    elseif m.input & INPUT_IN_POISON_GAS ~= 0 and m.health > 0xFF and m.healCounter == 0 and m.hurtCounter == 0 and (m.action & ACT_FLAG_INTANGIBLE == 0) and (m.flags & MARIO_METAL_CAP == 0) then
      m.health = m.health + 2 -- gas is -4 per frame
    end
  end

  -- reduces water heal and boosts invincibility frames after getting hit in water
  if (m.action & ACT_FLAG_SWIMMING) ~= 0 and m.healCounter == 0 and m.hurtCounter == 0 then
    if m.pos.y >= m.waterLevel - 140 and (m.area.terrainType & TERRAIN_MASK) ~= TERRAIN_SNOW then
      -- water heal is 26 (decimal) per frame
      if m.health ~= 0x880 then
        m.health = m.health - 22
        if (sMario.hard ~= 0) then -- no water heal in hard mode
          m.health = m.health - 4
        elseif apply_double_health(m.playerIndex) then
          m.health = m.health - 2 -- half the slow heal
        end
      end
    elseif m.prevAction == ACT_FORWARD_WATER_KB or m.prevAction == ACT_BACKWARD_WATER_KB then
      m.invincTimer = math.max(m.invincTimer, 75)                                                         -- 2.5 seconds
      m.prevAction = m.action
    elseif m.health ~= 0xFF and ((sMario.hard == 1) ~= (GST.doubleHealth)) and frameCounter % 2 == 0 then -- half speed drowning
      m.health = m.health +
          1                                                                                               -- water drain is 1 per frame
    end
  end

  -- poison gas sabotage (hunters aren't affected)
  if get_active_sabo() == 2 and sMario.team == 1 and sMario.spectator ~= 1 then
    if m.health > 0xFF and m.healCounter == 0 and m.hurtCounter == 0 and (m.action & ACT_FLAG_INTANGIBLE == 0) and (m.flags & MARIO_METAL_CAP == 0) then
      if apply_double_health(m.playerIndex) then
        m.health = m.health - 1 -- half for double health players
      else
        m.health = m.health - 2 -- poison gas is typically -4, but that's WAY too op
      end
    end

    if (m.action == ACT_IDLE or m.action == ACT_PANTING) and m.marioObj.collidedObjInteractTypes & INTERACT_WARP == 0 then
      set_mario_action(m, ACT_COUGHING, 0)
    elseif m.action == ACT_STANDING_DEATH then
      set_mario_action(m, ACT_SUFFOCATION, 0)
    end
  end

  -- hard mode
  if (sMario.hard == 1 and not GST.doubleHealth) and m.health > 0x480 and sMario.spectator ~= 1 then
    m.health = 0x480
    if m.playerIndex == 0 then deathTimer = 900 end
  end
  if sMario.spectator ~= 1 and ((sMario.hard == 2) or (leader and GST.firstTimer)) then -- extreme mode
    if (sMario.hard == 2) then
      if m.health > 0xFF and ((m.hurtCounter == 0 and m.action ~= ACT_BURNING_FALL and m.action ~= ACT_BURNING_GROUND and m.action ~= ACT_BURNING_JUMP)) then
        m.health = 0x1FF
      end
    end
    if m.playerIndex == 0 and deathTimer > 0 then
      if m.healCounter ~= 0 and m.health > 0xFF and deathTimer <= 1800 then
        deathTimer = deathTimer + 8
        if not OmmEnabled then deathTimer = deathTimer + 8 end -- double gain without OMM
      elseif deathTimer > 1800 then
        deathTimer = 1800
      end

      if not runner_invincible[m.action] then
        deathTimer = deathTimer - 1
        if deathTimer % 30 == 0 and deathTimer <= 330 then
          play_sound(SOUND_GENERAL2_SWITCH_TICK_FAST, gGlobalSoundSource)
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
  if m.playerIndex == 0 and ((sMario.hard and sMario.hard ~= 0) and sMario.runnerLives and sMario.runnerLives > 0) then sMario.runnerLives = 0 end

  -- handle double health mode (the whole thing is faked basically)
  if apply_double_health(0) and m.playerIndex == 0 then
    hud_set_value(HUD_DISPLAY_WEDGES, 8) -- disable default heal sound
    local doubleHealth = 2 * m.health - 0xFF
    local customWedge = 0
    if m.health >= 0x500 then
      doubleHealth = doubleHealth - 0x801
      customWedge = 8
    end
    customWedge = customWedge + math.min(math.max(doubleHealth >> 8, 0), 8)
    --djui_chat_message_create(tostring(customWedge))
    hud_set_value(HUD_DISPLAY_WEDGES, customWedge)
    if prevCustomWedge < customWedge then
      play_sound(SOUND_MENU_POWER_METER, gGlobalSoundSource)
    end
    prevCustomWedge = customWedge

    if halvedHurtCounter ~= 0 then halvedHurtCounter = halvedHurtCounter - 1 end
    if m.hurtCounter > halvedHurtCounter then
      halvedHurtCounter = (m.hurtCounter - halvedHurtCounter) // 2 + halvedHurtCounter
      m.hurtCounter = halvedHurtCounter
    end
    if halvedHealCounter ~= 0 then halvedHealCounter = halvedHealCounter - 1 end
    if m.healCounter > halvedHealCounter then
      halvedHealCounter = (m.healCounter - halvedHealCounter) // 2 + halvedHealCounter
      m.healCounter = halvedHealCounter
    end
  end

  -- add stars
  if m.playerIndex == 0 and gotStar then
    if GST.mhMode == 2 then
      if gotStar == GST.getStar then
        GST.votes = 0
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
        if GST.mhMode == 2 then
          if GST.campaignCourse ~= 0 and GST.campaignCourse < 26 then
            GST.campaignCourse = GST.campaignCourse + 1
            if GST.campaignCourse > 25 then
              local singlePlayer = true
              for i = 0, (MAX_PLAYERS - 1) do
                local sMario = PST[i]
                local np = NetP[i]

                if np.connected and sMario.spectator ~= 1 then
                  singlePlayer = false
                  break
                end
              end

              if singlePlayer then
                local record = GST.speedrunTimer
                local ref = "campaignRecord"
                if OmmEnabled then
                  ref = "cRecordOmm"
                elseif movesetEnabled then
                  ref = "cRecordOther"
                end
                local prevRecord = tonumber(mod_storage_load(ref)) or 0

                local miliseconds = math.floor(record / 30 % 1 * 100)
                local seconds = record // 30 % 60
                local minutes = record // 30 // 60 % 60
                local text = string.format("%02d:%02d.%02d", minutes, seconds, miliseconds)
                djui_chat_message_create(text)

                -- end game
                if prevRecord == 0 or record < prevRecord then
                  mod_storage_save(ref, tostring(record))
                  play_star_fanfare()
                  djui_chat_message_create(trans("new_record"))
                else
                  play_race_fanfare()
                end
                rejoin_timer = {}
                GST.mhState = 4
                GST.mhTimer = 20 * 30 -- 20 seconds
              end
            end
          end
          random_star(np.currCourseNum, GST.campaignCourse)
        end
      end
    else
      if m.prevNumStarsForDialog < m.numStars or ROMHACK.isUnder then
        if GST.starMode then
          localRunTime = localRunTime + 1    -- 1 star
        else
          localRunTime = localRunTime + 1800 -- 1 minute
        end
        local gotDDDstar = (not (ROMHACK and ROMHACK.ddd)) or GST.noBowser or GST.freeRoam
        if gotStar == 1 and np.currCourseNum == COURSE_DDD and GST.starRun < 32 then -- prevent displaying message twice when getting 15, then getting ddd star
          -- nothing
        elseif not gotDDDstar then
          local file = get_current_save_file_num() - 1
          local course_star_flags = save_file_get_star_flags(file, COURSE_DDD - 1)
          gotDDDstar = (course_star_flags & 1) ~= 0
        end

        -- send message
        local totalForMessage = GST.starRun
        if not gotDDDstar then totalForMessage = totalForMessage - 1 end
        local unlocked = (totalForMessage ~= -1 and m.numStars >= totalForMessage and m.prevNumStarsForDialog < totalForMessage)
        network_send_include_self(false, {
          id = PACKET_RUNNER_COLLECT,
          runnerID = np.globalIndex,
          star = gotStar,
          level = np.currLevelNum,
          course = np.currCourseNum,
          area = np.currAreaIndex,
          unlocked = unlocked,
          noSound = (m.action == ACT_OMM_STAR_DANCE),
        })
      end
      if sMario.hard == 2 then deathTimer = deathTimer + 300 end

      neededRunTime, localRunTime = calculate_leave_requirements(sMario, localRunTime, gotStar)
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

  -- only local mario at this point
  if m.playerIndex ~= 0 then return end

  deathTimer = 900

  -- kick out hunters in bowser level with no runners
  if frameCounter % 30 == 0 then
    if GST.mhMode ~= 2 and GST.mhMode ~= 3 and (np0.currCourseNum == COURSE_BITDW or np0.currCourseNum == COURSE_BITFS or np0.currCourseNum == COURSE_BITS) then
      local runnerHere = false
      for i = 1, (MAX_PLAYERS - 1) do
        if PST[i].team == 1 then
          local np = NetP[i]
          if np.connected and np.currCourseNum == np0.currCourseNum then
            runnerHere = true
            break
          end
        end
      end

      if runnerHere then
        hunterKickTimer = 0
      else
        hunterKickTimer = hunterKickTimer + 1
        play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)

        if hunterKickTimer > 30 then -- 30 sec
          SVcln = nil
          on_packet_get_outta_here()
          hunterKickTimer = 0
        end
      end
    else
      hunterKickTimer = 0
    end
  end

  -- prevent hunters from being in dead state (this won't run if mysteryhunt is enabled)
  if sMario0.dead then
    sMario0.dead = false
    sMario0.knownDead = false
  end

  -- camp timer for hunters!?
  if not campTimer and m.action == ACT_IN_CANNON then
    campTimer = 600 -- 20 seconds
  elseif m.action ~= ACT_IN_CANNON then
    campTimer = nil
  end
end

function before_set_mario_action(m, action)
  local sMario = PST[m.playerIndex]
  if action == ACT_EXIT_LAND_SAVE_DIALOG or action == ACT_DEATH_EXIT_LAND or (action == ACT_HARD_BACKWARD_GROUND_KB and m.action == ACT_SPECIAL_DEATH_EXIT) then
    m.area.camera.cutscene = 0
    play_cutscene(m.area.camera) -- needed to fix toad bug
    set_camera_mode(m.area.camera, m.area.camera.defMode, 1)
    m.forwardVel = 0
    m.healCounter = 0x20
    if m.playerIndex == 0 then
      halvedHealCounter = m.healCounter
    end

    if action == ACT_EXIT_LAND_SAVE_DIALOG then
      m.faceAngle.y = m.faceAngle.y + 0x8000
    end
    return ACT_IDLE
  elseif action == ACT_READING_SIGN and m.invincTimer > 0 then
    return 1
  elseif action == ACT_FALL_AFTER_STAR_GRAB then
    m.forwardVel, m.vel.y = 0, 0
    return ACT_STAR_DANCE_WATER
  end
  -- don't do the ending cutscene for hunters (or runners in no bowser mode)
  if action == ACT_JUMBO_STAR_CUTSCENE and (sMario.team ~= 1 or GST.noBowser) then
    m.flags = m.flags | MARIO_WING_CAP
    return 1
  end

  if (action == ACT_STANDING_DEATH or action == ACT_SUFFOCATION) and not on_death(m, true) then
    return 1
  end
end

-- forces rom hack camera if option is set
local romhack_no_override = {
  [CAMERA_MODE_NONE] = 1,
  [CAMERA_MODE_BEHIND_MARIO] = 1,
  [CAMERA_MODE_C_UP] = 1,
  [CAMERA_MODE_WATER_SURFACE] = 1,
  [CAMERA_MODE_INSIDE_CANNON] = 1,
  [CAMERA_MODE_BOSS_FIGHT] = 1,
  [CAMERA_MODE_NEWCAM] = 1,
  [CAMERA_MODE_ROM_HACK] = 1,
}
function on_set_camera_mode(c, mode, frames)
  if romhackCam and not romhack_no_override[mode] then
    set_camera_mode(c, CAMERA_MODE_ROM_HACK, 0)
    return false
  end
end

-- disable some interactions
--- @param o Object
function on_allow_interact(m, o, type)
  local sMario = PST[m.playerIndex]
  if sMario.spectator == 1 then return false end                                  -- disable for spectators

  if m.playerIndex == 0 and type == INTERACT_STAR_OR_KEY and ROMHACK.isUnder then -- star detection is silly
    local obj_id = get_id_from_behavior(o.behavior)
    if (o.oInteractionSubtype & INT_SUBTYPE_GRAND_STAR) == 0 then
      gotStar = (o.oBehParams >> 24) + 1
      lastStarID = obj_id
    end
  end

  if type == INTERACT_DOOR and o.collisionData == nil then return false end

  -- don't interact with doors while invincibility timer is active if they can't be opened
  if (m.invincTimer ~= 0 or m.skipWarpInteractionsTimer ~= 0) and (type == INTERACT_WARP_DOOR or type == INTERACT_DOOR) and not gGlobalSyncTable.freeRoam then
    m.skipWarpInteractionsTimer = math.max(m.skipWarpInteractionsTimer, 30)
    if type == INTERACT_WARP_DOOR then
      local warpDoorID = (o.oBehParams >> 24) or 0
      if warpDoorID == 1 and ((save_file_get_flags() & (SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR | SAVE_FLAG_HAVE_KEY_2)) == 0) then
        return false
      elseif warpDoorID == 2 and ((save_file_get_flags() & (SAVE_FLAG_UNLOCKED_BASEMENT_DOOR | SAVE_FLAG_HAVE_KEY_1)) == 0) then
        return false
      end
    else
      local stars = (o.oBehParams >> 24) or 0
      if m.numStars < stars then
        return false
      end
    end
  end

  -- disable stars and warps during game start or end
  if (type == INTERACT_WARP or type == INTERACT_STAR_OR_KEY or type == INTERACT_WARP_DOOR)
      and GST.mhState and (GST.mhState == 0 or GST.mhState >= 3) then
    return false
  end

  -- prevent hunters from interacting with certain things that help or softlock the runner
  local banned_hunter = {
    [id_bhvCusRedCoin] = 1,
    [id_bhvSecrets] = 1,
    [id_bhvKingBobomb] = 1,
    [id_bhvBowser] = 1,
  }

  local obj_id = get_id_from_behavior(o.behavior)
  --djui_chat_message_create(tostring(get_behavior_name_from_id(obj_id)))
  -- cap timer
  if type == INTERACT_CAP and regainCapTimer > 0 then
    if obj_id == id_bhvMetalCap and (cooldownCaps & MARIO_METAL_CAP) ~= 0 then return false end
    if obj_id == id_bhvVanishCap and (cooldownCaps & MARIO_VANISH_CAP) ~= 0 then return false end
  elseif type == INTERACT_STAR_OR_KEY then
    if sMario.team ~= 1 and GST.mhMode ~= 3 then return false end
    if gServerSettings.stayInLevelAfterStar == 0 and gGlobalSyncTable.starStayOld and o.oInteractionSubtype & INT_SUBTYPE_NO_EXIT == 0 then -- do star stay old setting
      local np = NetP[m.playerIndex]
      if np.currLevelNum ~= LEVEL_BOWSER_1 and np.currLevelNum ~= LEVEL_BOWSER_2 and np.currLevelNum ~= LEVEL_BOWSER_3 then
        local file = get_current_save_file_num() - 1
        local course_star_flags = (ROMHACK and ROMHACK.getStarFlagsFunc and ROMHACK.getStarFlagsFunc(file, np.currCourseNum - 1)) or
            save_file_get_star_flags(file, np.currCourseNum - 1)
        if course_star_flags & 1 << (o.oBehParams >> 24) ~= 0 then
          o.oInteractionSubtype = o.oInteractionSubtype | INT_SUBTYPE_NO_EXIT
        end
      end
    end
  elseif banned_hunter[obj_id] and GST.mhMode ~= 3 then
    if OmmEnabled and obj_id == id_bhvCusRedCoin then return true end -- to fix a bug, simply let hunters collect red coins
    if sMario.team ~= 1 then return false end
  end
end

-- handle collecting stars
function on_interact(m, o, type, value)
  local obj_id = get_id_from_behavior(o.behavior)
  local sMario = PST[m.playerIndex]
  -- reverted red coins not healing
  --[[if obj_id == id_bhvRedCoin then
    m.healCounter = m.healCounter - 0x8 -- two units
  end
  if m.healCounter < 0 then m.healCounter = 0 end]]

  if type == INTERACT_PLAYER then -- prevent janky comboing by bouncing off of another player
    if m.knockbackTimer ~= 0 and m.action == ACT_JUMP then
      m.invincTimer = 60
    end
  elseif type == INTERACT_STAR_OR_KEY then
    if m.playerIndex ~= 0 then return true end -- only local player

    local np = NetP[m.playerIndex]
    if (np.currLevelNum == LEVEL_BOWSER_1 or np.currLevelNum == LEVEL_BOWSER_2) then -- is a key (stars in bowser levels are technically keys)
      sMario.allowLeave = true

      -- don't display message if the door is unlocked (doesn't apply when key is held because the flag gets set before this runs)
      if np.currCourseNum == COURSE_BITDW and ((save_file_get_flags() & (SAVE_FLAG_UNLOCKED_BASEMENT_DOOR)) ~= 0) then
        return 0
      elseif np.currCourseNum == COURSE_BITFS and ((save_file_get_flags() & (SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR)) ~= 0) then
        return 0
      end

      -- send message if we don't already have this key
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
      lastStar = gotStar
      lastStarID = obj_id
    end
  elseif m.playerIndex == 0 and obj_kill_names[obj_id] then
    attackedByObj = obj_id
    if hitTimer == 0 then hitTimer = 300 end
  end
  return true
end

-- hard mode
function hard_mode_command(msg_)
  local msg = msg_ or ""
  local args = split(msg, " ")
  local toggle = args[1] or ""
  local mode = "hard"
  if args[2] or string.lower(toggle) == "ex" then
    mode = args[1]
    toggle = args[2] or ""
  end

  if string.lower(toggle) == "on" then
    if string.lower(mode) ~= "ex" then
      sMario0.hard = 1
    else
      sMario0.hard = 2
    end
    play_sound(SOUND_OBJ_BOWSER_LAUGH, gGlobalSoundSource)
    if string.lower(mode) ~= "ex" then
      djui_chat_message_create(trans("hard_toggle", trans("on")))
    else
      djui_chat_message_create(trans("extreme_toggle", trans("on")))
    end
    if GST.mhState ~= 2 then
      inHard = sMario0.hard
    elseif inHard ~= sMario0.hard then
      inHard = 0
      djui_chat_message_create(trans("no_hard_win"))
    end
  elseif string.lower(toggle) == "off" then
    if sMario0.hard ~= 2 then
      djui_chat_message_create(trans("hard_toggle", trans("off")))
    else
      djui_chat_message_create(trans("extreme_toggle", trans("off")))
    end
    sMario0.hard = 0
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
  -- only during timer or pause
  if sMario0.pause
      or (GST.mhState == 1 and sMario0.spectator ~= 1 and
        ((sMario0.team ~= 1 and GST.mhMode ~= 3) or GST.countdown < GST.mhTimer)) then -- runners get 10 second head start (not in mystery)
    if not paused then
      djui_popup_create(trans("paused"), 1)
      paused = true
    end

    enable_time_stop_including_mario()
    if GST.mhState == 1 then
      m0.health = 0x880
    end

    if tonumber(sMario0.pause) then
      sMario0.pause = sMario0.pause - 1
      if sMario0.pause < 1 then
        sMario0.pause = false
      end
    end
  elseif paused then
    djui_popup_create(trans("unpaused"), 1)
    m0.invincTimer = 60 -- 1 second
    paused = false
    disable_time_stop_including_mario()
    print("disabled pause")
  end
end

-- plays local sound unless popups or popup sounds are turned off
function popup_sound(sound, mysteryIgnore)
  if playPopupSounds and ((not djui_is_popup_disabled()) or (mysteryIgnore and mystery_popup_off())) then
    play_sound(sound, gGlobalSoundSource)
  end
end

-- chat related stuff
function tc_command(msg)
  if GST.mhMode == 3 then
    if GST.anarchy == 3 then
      djui_chat_message_create(trans("command_disabled"))
      return true
    elseif sMario0.team == 1 or sMario0.dead then
      djui_chat_message_create(trans("tc_only_hunter"))
      return true
    end
  end

  if string.lower(msg) == "on" then
    if disable_chat_hook then
      djui_chat_message_create(trans("command_disabled"))
      return true
    end
    sMario0.teamChat = true
    djui_chat_message_create(trans("tc_toggle", trans("on")))
  elseif string.lower(msg) == "off" then
    if disable_chat_hook then
      djui_chat_message_create(trans("command_disabled"))
      return true
    end
    sMario0.teamChat = false
    djui_chat_message_create(trans("tc_toggle", trans("off")))
  else
    send_tc(msg)
  end
  return true
end

function send_tc(msg)
  if mhApi.chatValidFunction and (mhApi.chatValidFunction(m0, msg) == false) then
    return false
  end

  local myGlobalIndex = np0.globalIndex
  network_send(false, {
    id = PACKET_TC,
    sender = myGlobalIndex,
    receiverteam = sMario0.team,
    msg = msg,
  })
  djui_chat_message_create(trans("to_team") .. msg)
  play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)

  return true
end

function on_packet_tc(data, self)
  local sender = data.sender
  local receiverteam = data.receiverteam
  local msg = data.msg
  if sMario0.team == receiverteam then
    local np = network_player_from_global_index(sender)
    if np then
      local playerColor = network_get_player_text_color_string(np.localIndex)
      djui_chat_message_create(playerColor .. np.name .. trans("from_team") .. msg)
      play_sound(SOUND_MENU_MESSAGE_APPEAR, gGlobalSoundSource)
    end
  end
end

function on_chat_message(m, msg)
  if disable_chat_hook then return end
  local np = NetP[m.playerIndex]
  local playerColor = network_get_player_text_color_string(m.playerIndex)
  local name = playerColor .. np.name
  local sMario = PST[m.playerIndex]

  if sMario.mute then
    if m.playerIndex == 0 then djui_chat_message_create(trans("you_are_muted")) end
    return false
  elseif mhApi.chatValidFunction and (mhApi.chatValidFunction(m, msg) == false) then
    return false
  elseif m.playerIndex ~= 0 and GST.mhMode == 3 and (GST.mhState == 1 or GST.mhState == 2) and sMario.dead and (not sMario0.dead) then
    return false
  elseif mhApi.chatModifyFunction then
    local msg_, name_ = mhApi.chatModifyFunction(m, msg)
    if name_ then name = name_ end
    if msg_ then msg = msg_ end
  end

  if sMario.teamChat and (GST.mhMode ~= 3 or (sMario.team ~= 1 and not sMario.dead)) then
    if m.playerIndex == 0 then
      djui_chat_message_create(trans("to_team") .. msg)
      play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
    elseif sMario0.team == sMario.team then
      djui_chat_message_create(playerColor .. np.name .. trans("from_team") .. msg)
      play_sound(SOUND_MENU_MESSAGE_APPEAR, gGlobalSoundSource)
    end

    return false
  elseif m.playerIndex == 0 then
    local lowerMsg = string.lower(msg)

    -- prompts rules message for following phrases:
    -- "*how do* I *play*?"
    -- "why *can't* I *(get/grab/collect) star*s?" (when hunter)
    -- "¿como se juega?" (how to play?)
    -- "¿cómo juego/juegas?" (how do I/you play?)
    local dispRules = (sMario.team ~= 1 and (string.find(lowerMsg, "can't") or string.find(lowerMsg, "cant") or string.find(lowerMsg, "cannot")) and string.find(lowerMsg, "star")
          and (string.find(lowerMsg, "get") or string.find(lowerMsg, "grab") or string.find(lowerMsg, "collect")))
        or ((string.find(lowerMsg, "como se") or string.find(lowerMsg, "how do") or string.find(lowerMsg, "cómo"))
          and (string.find(lowerMsg, "play") or string.find(lowerMsg, "jueg")))

    local dispLang = string.find(lowerMsg, " ingles") or
        string.find(lowerMsg, " inglés") -- for spanish speakers asking if this is an english (inglés) server; covers both with and without accent
    local dispSkip = GST.mhMode == 2 and (string.find(lowerMsg, "impossible"))
    local dispFix = m.action & ACT_FLAG_AIR == 0 and m.action ~= ACT_BURNING_GROUND and m.action ~= ACT_SPECTATE and
        (string.find(lowerMsg, "stuck") or string.find(lowerMsg, "softlock"))
    local dispMenu = string.find(lowerMsg, "menu") -- is this too broad?
    local pauseGame = network_is_server() and (not GST.pause) and lowerMsg:sub(1, 5) == "pause"
    local unPauseGame = network_is_server() and GST.pause and lowerMsg:sub(1, 7) == "unpause"

    if dispMenu then
      popup_sound(SOUND_GENERAL2_RIGHT_ANSWER)
      djui_popup_create("\\#ffff50\\" .. trans("open_menu", menuButtonString[menuButton]), 3)
    elseif dispLang then
      popup_sound(SOUND_GENERAL2_RIGHT_ANSWER)
      djui_popup_create(trans("to_switch", "ES", nil, "es"), 1)
    elseif dispSkip then
      popup_sound(SOUND_GENERAL2_RIGHT_ANSWER)
      djui_popup_create(trans("vote_info"), 1)
    elseif dispFix then
      force_idle_state(m)
      reset_camera_fix_bug(m.area.camera)
      m.marioObj.header.gfx.node.flags = m.marioObj.header.gfx.node.flags & ~GRAPH_RENDER_INVISIBLE
      popup_sound(SOUND_GENERAL2_RIGHT_ANSWER)
      djui_popup_create(trans("unstuck"), 1)
    elseif dispRules then
      popup_sound(SOUND_GENERAL2_RIGHT_ANSWER)
      djui_popup_create(trans("rule_command"), 1)
    elseif pauseGame or unPauseGame then
      pause_command("all")
    end
  end
  if network_is_server() then
    local lowerMsg = string.lower(msg)
    local desync = string.find(lowerMsg, "desync")
    local out = string.find(lowerMsg, "door") and (string.find(lowerMsg, "gone") or string.find(lowerMsg, "broke"))
    local pauseGame = (not GST.pause) and lowerMsg:sub(1, 5) == "pause"
    local unPauseGame = GST.pause and lowerMsg:sub(1, 7) == "unpause"

    if out then
      popup_sound(SOUND_GENERAL2_RIGHT_ANSWER)
      djui_popup_create(trans("use_out"), 1)
    elseif desync then
      popup_sound(SOUND_GENERAL2_RIGHT_ANSWER)
      djui_popup_create(trans("unstuck"), 1)
      desync_fix_command()
    elseif (pauseGame or unPauseGame) and m.playerIndex ~= 0 then
      popup_sound(SOUND_GENERAL2_RIGHT_ANSWER)
      djui_chat_message_create("/mh pause " .. trans("pause_desc"))
    end
  end

  local tag = get_tag(m.playerIndex)
  if GST.mhMode == 3 and (GST.mhState == 1 or GST.mhState == 2) then
    if sMario.dead then
      if tag and tag ~= "" then
        tag = tag .. " " .. trans("role_dead")
      else
        tag = trans("role_dead")
      end
    elseif GST.maxGlobalTalk ~= 0 and GST.globalTalkTimer == 0 and GST.mhState == 2 and not sMario0.dead then
      if m.playerIndex ~= 0 then
        local dist = dist_between_objects(m.marioObj, m0.marioObj)
        if is_player_active(m) == 0 or dist >= 8000 then
          return false
        end

        if dist > 3000 then -- corrupt message when far away
          if tag and tag ~= "" then
            tag = tag .. " " .. trans("far")
          else
            tag = trans("far")
          end

          msg = corrupt_string(msg, (dist - 3000) / 5000)
        elseif tag and tag ~= "" then
          tag = tag .. " " .. trans("nearby")
        else
          tag = trans("nearby")
        end
      elseif tag and tag ~= "" then
        tag = tag .. " " .. trans("nearby")
      else
        tag = trans("nearby")
      end
    end
  end

  if tag and tag ~= "" then
    djui_chat_message_create(name .. " " .. tag .. ": \\#dcdcdc\\" .. msg)

    if m.playerIndex == 0 then
      play_sound(SOUND_MENU_MESSAGE_DISAPPEAR, gGlobalSoundSource)
    else
      play_sound(SOUND_MENU_MESSAGE_APPEAR, gGlobalSoundSource)
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
    showingRules = false
  end
  return true
end

hook_chat_command("stats", trans("stats_desc"), stats_command)

demonOn = false
demonUnlocked = mod_storage_load("demon_unlocked") or false
demonTimer = 0

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

function stalk_command(msg, noFeedback)
  if GST.mhMode == 2 then
    if not noFeedback then djui_chat_message_create(trans("wrong_mode")) end
    return true
  elseif not (GST.allowStalk) then
    if not noFeedback then djui_chat_message_create(trans("command_disabled")) end
    return true
  elseif GST.mhState ~= 2 then
    if not noFeedback then djui_chat_message_create(trans("not_started")) end
    return true
  elseif on_pause_exit() == false then
    if (not noFeedback) then
      if get_leave_requirements(sMario0) > 0 then
        djui_chat_message_create(runner_hud(sMario0))
      end
      play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
    end
    return true
  end

  local playerID, np
  if msg == "" then
    if runnerTarget ~= -1 then
      playerID = runnerTarget
      np = NetP[runnerTarget]
    else
      for i = 1, (MAX_PLAYERS - 1) do
        local sMario = PST[i]
        if sMario.team == 1 then
          playerID = i
          np = NetP[i]
          break
        end
      end
    end
    if not playerID then
      if not noFeedback then djui_chat_message_create(trans("no_runners")) end
      return true
    end
  else
    playerID, np = get_specified_player(msg)
  end

  if playerID == 0 then
    return false
  elseif not playerID then
    return true
  end

  local sMario = PST[playerID]
  if sMario.team ~= 1 then
    local name = remove_color(np.name)
    djui_chat_message_create(trans("not_runner", name))
    return true
  end

  local level = np.currLevelNum
  -- prevent warping to boss arenas (unless this is b3313 which is silly and weird)
  if GST.romhackFile ~= "B3313" then
    if level == LEVEL_BOWSER_1 then
      level = LEVEL_BITDW
    elseif level == LEVEL_BOWSER_2 then
      level = LEVEL_BITFS
    elseif level == LEVEL_BOWSER_3 then
      level = LEVEL_BITS
    end
  end
  if not (sMario0.inActSelect or sMario.inActSelect) and ((np.currLevelNum ~= np0.currLevelNum and level ~= np0.currLevelNum) or np.currAreaIndex ~= np0.currAreaIndex or np.currActNum ~= np0.currActNum) then
    local success = warp_to_level(level, np.currAreaIndex, np.currActNum) or warp_to_level(level, 1, np.currActNum)
    if success and sMario0.pause ~= true and (sMario0.pause == false or sMario0.pause < (GST.stalkTimer or 150)) then
      sMario0.pause = GST.stalkTimer or 150
    end
  end
  return true
end

hook_chat_command("stalk", trans("stalk_desc"), stalk_command)

function target_command(msg)
  if GST.mhMode == 2 or GST.mhMode == 3 then
    djui_chat_message_create(trans("wrong_mode"))
    return true
  elseif sMario0.team == 1 then
    djui_chat_message_create(trans("target_hunters_only"))
    return true
  end

  local playerID, np
  if msg == "" then
    for i = 1, (MAX_PLAYERS - 1) do
      if NetP[i].connected and PST[i].team == 1 then
        if is_player_active(MST[i]) ~= 0 then
          playerID = i
          break
        elseif not playerID then
          playerID = i
        end
      end
    end
    if playerID then
      np = NetP[playerID]
    else
      djui_chat_message_create(trans("no_runners"))
      return true
    end
  elseif msg and tostring(msg):lower() == "off" then
    runnerTarget = -1
    return true
  else
    playerID, np = get_specified_player(msg)
  end

  if playerID == 0 then
    runnerTarget = -1
    return true
  elseif not playerID then
    return true
  end

  local sMario = PST[playerID]
  if sMario.team ~= 1 then
    local name = remove_color(np.name)
    djui_chat_message_create(trans("not_runner", name))
    return true
  end

  runnerTarget = playerID
  return true
end

hook_chat_command("target", trans("target_desc"), target_command)

function on_course_enter()
  attackedBy = nil
  attackedByObj = nil
  cheatLocal = false
  parkourTimer = 0

  -- justEntered = true

  if GST.romhackFile ~= "vanilla" and np0.currLevelNum == LEVEL_LOBBY then -- erase signs when not in vanilla
    local sign = obj_get_first_with_behavior_id(id_bhvMessagePanel)
    while sign do
      obj_mark_for_deletion(sign)
      sign = obj_get_next_with_same_behavior_id(sign)
    end
  end
  if GST.mhState == 0 then -- and background music
    set_lobby_music(month)
    --play_music(0, custom_seq, 1)
  end

  if GST.mhState == 0 or GST.mhState == 3 then return end

  local grateStarReq = gBehaviorValues.GrateStarRequirement
  if grateStarReq >= 32768 then -- treat as negative
    grateStarReq = grateStarReq - 65536
  end
  omm_disable_mode_for_minihunt(GST.mhMode == 2) -- change non stop mode setting for minihunt
  if GST.mhMode ~= 2 and GST.freeRoam then       -- unlock key doors and other stuff
    save_file_set_flags(SAVE_FLAG_UNLOCKED_BASEMENT_DOOR | SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR |
      SAVE_FLAG_MOAT_DRAINED)
    if gLevelValues.wingCapLookUpReq > 0 then
      gLevelValues.wingCapLookUpReq = -gLevelValues.wingCapLookUpReq
    end
    if gBehaviorValues.CourtyardBoosRequirement > 0 then
      gBehaviorValues.CourtyardBoosRequirement = -gBehaviorValues.CourtyardBoosRequirement
    end
  else
    if gLevelValues.wingCapLookUpReq < 0 then
      gLevelValues.wingCapLookUpReq = -gLevelValues.wingCapLookUpReq
    end
    if gBehaviorValues.CourtyardBoosRequirement < 0 then
      gBehaviorValues.CourtyardBoosRequirement = -gBehaviorValues.CourtyardBoosRequirement
    end
  end

  if GST.mhMode == 2 then -- unlock cannon and caps in minihunt
    runnerTarget = -1
    local file = get_current_save_file_num() - 1
    save_file_set_flags(SAVE_FLAG_HAVE_METAL_CAP | SAVE_FLAG_HAVE_VANISH_CAP | SAVE_FLAG_HAVE_WING_CAP)
    save_file_set_star_flags(file, np0.currCourseNum, 0x80)

    -- for Board Bowser's Sub
    if ROMHACK.ddd and GST.gameLevel == LEVEL_DDD then
      save_file_clear_flags(SAVE_FLAG_HAVE_KEY_2)
      if GST.getStar == 1 then
        save_file_clear_flags(SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR)
      else
        save_file_set_flags(SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR)
      end
    end
  else -- fix star count
    local courseMax = 25
    local courseMin = 1
    m0.numStars = (ROMHACK and ROMHACK.totalStarCountFunc and ROMHACK.totalStarCountFunc(get_current_save_file_num() - 1, courseMin - 1, courseMax - 1)) or
        (save_file_get_total_star_count(get_current_save_file_num() - 1, courseMin - 1, courseMax - 1))
    m0.prevNumStarsForDialog = m0.numStars
  end
end

-- calculates all player's placements in minihunt
function calculate_placement()
  local leader = false
  local foundOne = false
  local scoreboard = {}

  if GST.mhMode ~= 2 then
    return false, scoreboard
  end

  local toBeat = sMario0.totalStars
  if toBeat > 0 then
    leader = true
    table.insert(scoreboard, { 0, toBeat })
  end

  for i = 1, MAX_PLAYERS - 1 do
    if NetP[i].connected then
      if PST[i].spectator ~= 1 then
        foundOne = true
      end
      if PST[i].totalStars and PST[i].totalStars ~= 0 then
        if PST[i].totalStars > toBeat then
          leader = false
        end
        table.insert(scoreboard, { i, PST[i].totalStars })
      end
    end
  end

  if not foundOne then
    return false, {}
  end

  -- sort
  if #scoreboard > 1 then
    table.sort(scoreboard, function(a, b)
      return a[2] > b[2]
    end)
  end

  return leader, scoreboard
end

function on_packet_runner_collect(data, self)
  runnerID = data.runnerID
  if runnerID then
    leader, scoreboard = calculate_placement()
    local np = network_player_from_global_index(runnerID)
    local playerColor = network_get_player_text_color_string(np.localIndex)
    local place = np.overrideLocation
    if np.overrideLocation == nil or np.overrideLocation == "" then
      place = get_custom_level_name(data.course, data.level, data.area)
    end

    if data.star then -- star
      local name = get_custom_star_name(data.course, data.star)

      if not (self or data.noSound) then
        popup_sound(SOUND_MENU_STAR_SOUND, true)
      end

      if GST.mhMode == 2 or (not data.noSound) then -- OMM shows its own progress, so don't show this
        djui_popup_create_mystery(
          trans("got_star", (playerColor .. np.name)) .. "\\#ffffff\\\n" .. place .. "\n" .. name, 2)
      end

      if network_is_server() and GST.mhMode ~= 2 then
        GST.lastStarTime = GST.speedrunTimer
      end

      -- update time
      if (not self) and GST.mhMode ~= 2 and sMario0.team == 1 and data.course == np0.currCourseNum then
        neededRunTime, localRunTime = calculate_leave_requirements(sMario0, localRunTime)
      end
    elseif data.switch then -- switch
      if not self then
        popup_sound(SOUND_GENERAL_ACTIVATE_CAP_SWITCH, true)
      end

      local switch_message = "hit_switch_yellow" -- used in b3313
      if data.switch == 0 then
        switch_message = "hit_switch_red"
      elseif data.switch == 1 then
        switch_message = "hit_switch_green"
      elseif data.switch == 2 then
        switch_message = "hit_switch_blue"
      end
      djui_popup_create_mystery(trans(switch_message, (playerColor .. np.name)), 2)
    elseif data.grand then -- grand star
      if not self then
        popup_sound(SOUND_GENERAL_GRAND_STAR, true)
      end

      djui_popup_create_mystery(trans("got_star", (playerColor .. np.name)) .. "\\#ffffff\\\nGrand Star", 2)
    else -- key
      if not self then
        popup_sound(SOUND_GENERAL_UNKNOWN3_LOWPRIO, true)
      end

      djui_popup_create_mystery(trans("got_key", (playerColor .. np.name)) .. "\\#ffffff\\\n" .. place, 2)
    end
  end

  if data.unlocked then
    if playPopupSounds then
      play_peachs_jingle()
    end
    djui_popup_create_mystery(trans("got_all_stars"), 1)
    local final = (ROMHACK and ROMHACK.final) or COURSE_BITS
    if final ~= -1 and np0.currCourseNum ~= final then
      sMario0.allowLeave = true
    end
  end
end

function on_packet_kill(data, self)
  local killed = data.killed
  local killer = data.killer
  local newRunnerID = data.newRunnerID

  local killedNP

  if killed then
    killedNP = network_player_from_global_index(killed)
    local playerColor = network_get_player_text_color_string(killedNP.localIndex)

    if killer then -- died from kill (most common)
      local killerNP = network_player_from_global_index(killer)
      local kPlayerColor = network_get_player_text_color_string(killerNP.localIndex)

      if killerNP.localIndex == 0 then -- is our kill
        m0.healCounter = 0x32          -- full health
        m0.hurtCounter = 0x0
        popup_sound(SOUND_GENERAL_STAR_APPEARS)
        -- save kill, but only in-game
        if GST.mhState ~= 0 then
          local kills = tonumber(mod_storage_load("kills"))
          if not kills then
            kills = 0
          end
          mod_storage_save("kills", tostring(math.floor(kills) + 1))
          sMario0.kills = sMario0.kills + 1
          if GST.mhMode == 3 and sMario0.team == 1 and data.runner then -- kill if innocent
            died = false
            sMario0.runnerLives = 0
            sMario0.dead = true
            on_death(m0, true)
            djui_chat_message_create(trans("mysteryhunt_innocent"))
          end
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
        if GST.mhState ~= 0 then
          local maxStreak = tonumber(mod_storage_load("maxStreak"))
          if not maxStreak or killCombo > maxStreak then
            mod_storage_save("maxStreak", tostring(math.floor(killCombo)))
            sMario0.maxStreak = killCombo
          end
        end
        killTimer = 300       -- 10 seconds
      elseif data.runner then -- play sound if runner dies
        popup_sound(SOUND_OBJ_BOWSER_LAUGH)
      end

      -- sidelined if this was their last life
      if not data.death then
        djui_popup_create(trans("killed", (kPlayerColor .. killerNP.name), (playerColor .. killedNP.name)), 1)
      else
        djui_popup_create(trans("sidelined", (kPlayerColor .. killerNP.name), (playerColor .. killedNP.name)), 1)
        -- another easter egg
        if data.runner and killerNP.localIndex == 0 and sMario0.team ~= 1 and killerNP.name == "Chara" then
          local runnerCount = 0
          for i = 1, (MAX_PLAYERS - 1) do
            local np = NetP[i]
            local sMario = PST[i]
            if np.connected and (not sMario.dead) and sMario.team == 1 then
              runnerCount = runnerCount + 1
            end
          end
          if runnerCount ~= 0 then
            djui_chat_message_create(trans_plural("chara_left", runnerCount))
          end
        end
      end
    elseif data.killerObj and obj_kill_names[data.killerObj] then
      -- sidelined if this was their last life
      local killName = obj_kill_names[data.killerObj]
      if data.death ~= true then
        djui_popup_create(trans("killed", killName, (playerColor .. killedNP.name)), 1)
      else
        djui_popup_create(trans("sidelined", killName, (playerColor .. killedNP.name)), 1)
      end
      if data.runner then -- play sound if runner dies
        popup_sound(SOUND_OBJ_BOWSER_LAUGH)
      end
    else
      if data.death ~= true then -- runner only lost one life
        djui_popup_create(trans("lost_life", (playerColor .. killedNP.name)), 1)
      else                       -- runner lost all lives
        djui_popup_create(trans("lost_all", (playerColor .. killedNP.name)), 1)
      end
      if data.runner then -- play sound if runner dies
        popup_sound(SOUND_OBJ_BOWSER_LAUGH)
      end
    end

    if GST.mhMode == 3 and (GST.mhState == 1 or GST.mhState == 2) and GST.confirmHunter and PST[killedNP.localIndex].team ~= 1 and data.death ~= true then
      local huntersLeft = 0
      for i = 0, (MAX_PLAYERS - 1) do
        if NetP[i].connected and not (PST[i].dead) and PST[i].team ~= 1 then
          huntersLeft = huntersLeft + 1
        end
      end
      if killer then -- I don't believe it's actually possible for this to be nil, but just in case
        local killerNP = network_player_from_global_index(killer)
        local kPlayerColor = network_get_player_text_color_string(killerNP.localIndex)
        djui_chat_message_create(trans("killed", (kPlayerColor .. killerNP.name), (playerColor .. killedNP.name)))
      end
      djui_chat_message_create(trans_plural("hunters_remain", huntersLeft))
      popup_sound(SOUND_GENERAL_RACE_GUN_SHOT, true)
    end
  end

  -- new runner for swap mode
  if newRunnerID then
    local np = network_player_from_global_index(newRunnerID)
    if np then
      local sMario = PST[np.localIndex]
      become_runner(sMario)
      if np.localIndex == 0 and GST.mhMode ~= 2 then
        sMario.runTime = data.time or 0
        localRunTime = data.time or 0
        neededRunTime, localRunTime = calculate_leave_requirements(sMario, localRunTime)
        print("new time:", data.time)
      end
      on_packet_role_change({ id = PACKET_ROLE_CHANGE, index = newRunnerID }, true)

      if killedNP and killedNP.localIndex == runnerTarget then
        runnerTarget = np.localIndex
      end
    else
      newRunnerID = nil
    end
  end

  mhApi.onKill(killer, killed, data.runner, data.death, data.time, newRunnerID)
end

-- part of the API
function get_kill_combo()
  return killCombo
end

prevGameEnd = false
function on_game_end(data, self)
  if prevGameEnd then return end
  prevGameEnd = true
  if GST.mhMode == 2 and data.winner ~= -1 then
    local winCount = 1
    local winners = {}
    local weWon = true
    local singlePlayer = true
    local record = false
    local totalStarsAcrossAll = 0
    for i = 0, (MAX_PLAYERS - 1) do
      local sMario = PST[i]
      local np = NetP[i]

      if i == 0 then
        local maxStar = tonumber(mod_storage_load("maxStar"))
        if not maxStar then
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

      if np.connected and sMario.totalStars then
        totalStarsAcrossAll = totalStarsAcrossAll + sMario.totalStars
        if sMario.totalStars >= winCount then
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
    end

    if singlePlayer then
      djui_chat_message_create(trans("mini_score", sMario0.totalStars))
    elseif #winners > 0 then
      djui_chat_message_create(trans("winners"))
      for i, name in ipairs(winners) do
        djui_chat_message_create(name)
      end
      if weWon then
        add_win(sMario0)
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
    if sMario0.team == 1 then
      add_win(sMario0)
    end
  else
    play_dialog_sound(21) -- bowser intro
    if GST.mhMode == 3 and sMario0.team ~= 1 then
      add_win(sMario0)
    end
    --play_secondary_music(SEQ_EVENT_KOOPA_MESSAGE, 0, 80, 60)
  end

  -- display who the hunters were
  if GST.mhMode == 3 then
    local hunterNames = {}
    for i = 0, (MAX_PLAYERS - 1) do
      if NetP[i].connected and PST[i].team ~= 1 and (not PST[i].forceSpectate) then
        local name = remove_color(NetP[i].name)
        table.insert(hunterNames, name)
      end
    end
    if #hunterNames ~= 0 then
      local text = trans("hunters_were")
      for i = 1, #hunterNames do
        text = text .. hunterNames[i] .. ", "
      end
      text = text:sub(1, -3)
      djui_chat_message_create(text)
    end
  end
end

function on_packet_stats(data, self)
  if data.stat == "disp_asn" then
    if data.value == 1 then
      djui_chat_message_create(trans("disp_asn_win", data.name))
    elseif data.value == 2 then
      djui_chat_message_create(trans("disp_asn_silver", data.name))
    elseif data.value == 3 then
      djui_chat_message_create(trans("disp_asn_bronze", data.name))
    else
      djui_chat_message_create(trans("disp_asn_quarter", data.name))
    end
    return
  end
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
  if GST.mhMode == 3 then
    winType = winType .. "_mys"
  elseif GST.mhMode ~= 2 then
    winType = winType .. "_standard"
  end
  local wins = tonumber(mod_storage_load(winType))
  if not wins then
    wins = 0
  end
  mod_storage_save(winType, tostring(math.floor(wins) + 1))
  if sMario[winType] then
    sMario[winType] = sMario[winType] + 1
  end
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
  local force = false
  if GST.mhMode ~= 2 then
    djui_chat_message_create(trans("wrong_mode"))
    return true
  elseif GST.mhState ~= 2 then
    djui_chat_message_create(trans("not_started"))
    return true
  elseif msg:lower() == "force" and has_mod_powers(0) then
    force = true -- force skip
  elseif iVoted then
    djui_chat_message_create(trans("already_voted"))
    return true
  end

  local playercolor = network_get_player_text_color_string(0)
  iVoted = true
  if network_is_server() then
    on_packet_vote({
      id = PACKET_VOTE,
      force = force,
      host = true,
      voted = playercolor .. np0.name,
    })
  else
    local hostIndex = network_local_index_from_global(0) or 1
    network_send_to(hostIndex, true, {
      id = PACKET_VOTE,
      force = force,
      host = true,
      voted = playercolor .. np0.name,
    })
  end
  return true
end

hook_chat_command("skip", trans("menu_skip_desc"), skip_command)
function on_packet_vote(data, self)
  if data.host then
    if not network_is_server() then return end

    local count = network_player_connected_count() -- this includes spectators
    local maxVotes = count
    if count > 2 then
      maxVotes = math.ceil(count * 0.5) -- half the lobby
    elseif count == 1 then
      iVoted = false
      campaignRecordValid = false
      if GST.campaignCourse ~= 0 then
        GST.campaignCourse = GST.campaignCourse + 1
      end
      random_star(np0.currCourseNum, GST.campaignCourse)
      GST.votes = 0
      return
    end

    GST.votes = GST.votes + 1
    if data.force then
      GST.votes = 99
    end

    local pass = false
    if maxVotes <= GST.votes then
      pass = true
    end

    network_send_include_self(true, {
      id = PACKET_VOTE,
      force = data.force,
      votes = GST.votes,
      voted = data.voted,
      maxVotes = maxVotes,
      pass = pass,
    })
  else
    djui_chat_message_create(string.format("%s (%d/%d)", trans("vote_skip", data.voted), data.votes, data.maxVotes))
    if data.pass then
      djui_chat_message_create(trans("vote_pass"))
      iVoted = false
      if network_is_server() then
        campaignRecordValid = false
        if GST.campaignCourse ~= 0 then
          GST.campaignCourse = GST.campaignCourse + 1
        end
        random_star(np0.currCourseNum, GST.campaignCourse)
        GST.votes = 0
      end
    else
      djui_chat_message_create(trans("vote_info"))
    end
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
  if GST.mhMode == 3 then
    djui_chat_message_create(trans(data.langID, data.format, data.format2))
  else
    djui_popup_create(trans(data.langID, data.format, data.format2), data.lines)
  end
  if data.langID == "rejoin_success" then
    leader, scoreboard = calculate_placement()
  end
end

-- popup for this player's role changing
function on_packet_role_change(data, self)
  if GST.mhMode == 3 then return end
  local np = network_player_from_global_index(data.index)
  local playerColor = network_get_player_text_color_string(np.localIndex)
  local sMario = PST[np.localIndex]
  local roleName, color = get_role_name_and_color(np.localIndex)
  djui_popup_create(trans("now_role", playerColor .. np.name, color .. roleName), 1)
  if np.localIndex == 0 and (sMario.team == 1) == (GST.mhMode ~= 3) then
    popup_sound(SOUND_GENERAL_SHORT_STAR)
  end
end

-- change name of this star for all players
function on_packet_omm_star_rename(data, self)
  local name = get_custom_star_name(data.course, data.act)
  OmmApi.omm_register_star_behavior(data.obj_id, name, string.upper(name))
  popup_sound(SOUND_MENU_STAR_SOUND)
  if lastStarID == data.obj_id then
    ommRenameTimer = 10
  end
end

function on_packet_other_warp(data, self)
  local name = get_custom_level_name(data.course, data.level, data.area)
  local np = network_player_from_global_index(data.index)
  local playerColor = network_get_player_text_color_string(np.localIndex)
  local sMario = PST[np.localIndex]

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
      if not self then
        djui_popup_create(trans("custom_enter", playerColor .. np.name, name), 1)
      end
      bowserFight = true
      playSound = true
    end

    send = playSound
    if sMario.team == 1 and playSound then sound = SOUND_MOVING_ALMOST_DROWNING end
  end
  if ((data.course ~= data.prevCourse) or (bowserFight and sMario.team ~= 1)) then
    send = true
    if (not self) and (sMario.team ~= sMario0.team or sMario.team == 1) and sMario.spectator ~= 1 then
      if sMario.team == 1 then
        if data.course ~= 0 and (not ROMHACK.hubStages or not ROMHACK.hubStages[data.course]) and (data.course == np0.currCourseNum and data.act == np0.currActNum) then
          sound = SOUND_MENU_REVERSE_PAUSE + 61569 -- interesting unused sound
        elseif data.prevCourse ~= 0 and (not ROMHACK.hubStages or not ROMHACK.hubStages[data.prevCourse]) and data.prevCourse == np0.currCourseNum then
          sound = SOUND_MENU_MARIO_CASTLE_WARP2
        end
      elseif data.course ~= 0 and (not ROMHACK.hubStages or not ROMHACK.hubStages[data.course]) and (data.course == np0.currCourseNum and data.act == np0.currActNum) then
        sound = SOUND_OBJ_BOO_LAUGH_SHORT
      end
    end
  end
  if sound and not self then popup_sound(sound) end
  return send
end

function on_packet_mute_player(data, self)
  local np = network_player_from_global_index(data.playerIndex)
  local muterNP = network_player_from_global_index(data.muter)
  local name = remove_color(np.name)
  local muterName = remove_color(muterNP.name)
  if data.mute then
    gPlayerSyncTable[np.localIndex].mute = true
    if self then
      djui_popup_create(trans("you_muted", name), 1)
    else
      djui_popup_create(trans("muted", name, muterName), 1)
    end
  else
    gPlayerSyncTable[np.localIndex].mute = false
    if self then
      djui_popup_create(trans("you_unmuted", name), 1)
    else
      djui_popup_create(trans("unmuted", name, muterName), 1)
    end
  end
end

function on_packet_get_outta_here()
  warpCooldown = 0
  local oNode = area_get_warp_node(0xf1)
  local node = oNode and oNode.node
  if node and np0.currLevelNum ~= node.destLevel then
    warp_to_warpnode(node.destLevel, node.destArea, np0.currActNum, node.destNode)
  elseif np0.currCourseNum ~= 0 then
    warp_to_castle(np0.currLevelNum)
  elseif np0.currLevelNum ~= gLevelValues.entryLevel then
    warp_beginning()
  elseif ROMHACK.ddd then
    warp_to_level(LEVEL_CASTLE, 1, 0)
  else
    warp_to_level(LEVEL_BOB, 1, 1)
  end
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
PACKET_MUTE_PLAYER = 12
PACKET_GET_OUTTA_HERE = 13
PACKET_PERM_OBJ = 14
PACKET_REQUEST_PERM_OBJS = 15
PACKET_REPORT_BODY = 16
PACKET_MEGA_BOMB = 17
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
  [PACKET_MUTE_PLAYER] = on_packet_mute_player,
  [PACKET_GET_OUTTA_HERE] = on_packet_get_outta_here,
  [PACKET_PERM_OBJ] = on_packet_perm_obj,
  [PACKET_REQUEST_PERM_OBJS] = on_packet_request_perm_objs,
  [PACKET_REPORT_BODY] = on_packet_report_body,
  [PACKET_MEGA_BOMB] = on_packet_mega_bomb,
}

-- from arena
function on_packet_receive(dataTable)
  if sPacketTable[dataTable.id] then
    sPacketTable[dataTable.id](dataTable, false)
  end
end

-- to update rom hack
function on_rom_hack_changed(tag, oldVal, newVal)
  if oldVal and oldVal ~= newVal then
    print("Hack set to " .. newVal)
    local result = setup_hack_data()
    if result == "vanilla" then
      djui_popup_create(trans("vanilla"), 1)
    end
  end
end

-- starts background music again in state 0
function on_state_changed(tag, oldVal, newVal)
  if oldVal == newVal then return end
  if newVal == 0 then
    set_lobby_music(month)
  elseif np0.currLevelNum == LEVEL_LOBBY then
    warp_beginning()
    set_season_lighting(month, 0)
  end
end

-- hooks
hook_event(HOOK_UPDATE, update)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)
hook_event(HOOK_BEFORE_SET_MARIO_ACTION, before_set_mario_action)
hook_event(HOOK_ALLOW_PVP_ATTACK, allow_pvp_attack)
hook_event(HOOK_ON_PVP_ATTACK, on_pvp_attack)
hook_event(HOOK_ON_PLAYER_CONNECTED, on_player_connected)
hook_event(HOOK_ON_PLAYER_DISCONNECTED, on_player_disconnected)
hook_event(HOOK_ON_EXIT, on_game_exit)
hook_event(HOOK_ON_PAUSE_EXIT, on_pause_exit)
hook_event(HOOK_ON_LEVEL_INIT, on_course_enter)
hook_event(HOOK_ON_WARP, on_warp)
hook_event(HOOK_ON_SYNC_VALID, on_course_sync)
hook_event(HOOK_ON_PACKET_RECEIVE, on_packet_receive)
hook_event(HOOK_ON_DEATH, on_death)
hook_event(HOOK_ON_INTERACT, on_interact)
hook_event(HOOK_ON_SET_CAMERA_MODE, on_set_camera_mode)
hook_event(HOOK_ON_HUD_RENDER_BEHIND, behind_hud_render)
hook_event(HOOK_ON_HUD_RENDER, on_hud_render)
hook_on_sync_table_change(GST, "romhackFile", "change_hack", on_rom_hack_changed)
hook_on_sync_table_change(GST, "mhState", "change_state", on_state_changed)

-- prevent constant error stream
if not trans then
  trans = function(_, _, _, _)
    return "LANGUAGE MODULE DID NOT LOAD"
  end
  trans_plural = trans
end
