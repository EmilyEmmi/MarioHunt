--[[
Hello! For those who are looking to translate:
- PLEASE PLEASE PLEASE have more than a basic understanding of whatever language you're translating
- Scroll down and copy one of the language tables (I would copy English, as it's always complete)
- Translate all of the things. Make sure you don't miss anything, unless stated.
- Send the table (don't need the whole file) to me in some text style format (or do a pull request)
- Let me know who worked on it so I can provide proper credit
- Also note that I may ask for more translations in the future

Use "/mh langtest [ID,EXTRA1,EXTRA2,LANG]" for testing.
- ID is the phrase's id (ex: "to_switch")
- EXTRA1 is the first "blank" (ex: in "collect_bowser", this is the amount of stars)
- EXTRA2 is the second "blank" (ex: in "killed", this is the victim's name)
- LANG is what language, which is otherwise whichever one you have selected (ex: "fr" is french)
- add "plural" at the end for phrases that change based on the entered data
"/mh langtest all [LANG]" lists every id that doesn't have a translation (this does not include incomplete translations)

IF something you want to translate does not use this table, you can add it to your table and let me know
]]

-- this is the translate command, it supports up to two blanks
function trans(id,format,format2_,lang_)
  local usingLang = lang_ or lang or "en"
  local format2 = format2_ or 10
  if not id then
    return "INVALID"
  elseif month == 13 and not noSeason then
    if id == "menu_mh" or id == "rules_desc" or id == "up_to_date" or id == "has_update" then
      id = id .. "_egg"
    end
  end
  if not langdata then return id end

  if not langdata[usingLang] then
    usingLang = "en"
  end

  local translation = langdata[usingLang][id] or langdata["en"][id] or id
  if format then
    translation = string.format(translation,format,format2)
  end
  return translation
end
-- this is for scenarios where a word needs to be plural or not plural (usually "life/lives")
function trans_plural(id,format,format2_,lang_)
  local num = tonumber(format2_) or tonumber(format) or 0
  if num ~= 1 or not id then
    return trans(id,format,format2_,lang_)
  else
    return trans(id.."_one",format,format2_,lang_)
  end
end

langdata = {}

-- below is where all of the language data starts

langdata["en"] = -- the letters here will be what you type for the command (ex: to switch to this language, type "/lang en")
{
  -- fullname for auto select (make sure this matches in-game under Misc -> Languages)
  fullname = "English",

  -- name in the built-in menu
  name_menu = "English",

  -- global command info
  to_switch = "Type \"/lang %s\" to switch languages",
  switched = "Switched to English!", -- Replace "English" with the name of this language
  rule_command = "Type /rules to show this message again",
  open_menu = "Type /mh or press L + Start to open the menu",
  stalk = "Use /stalk to warp to runners!",
  rules_desc = "- Shows MarioHunt rules",
  rules_desc_egg = "- Shows LuigiHunt rules",
  mh_desc = "[COMMAND,ARGS] - Runs commands; type nothing or \"menu\" to open the menu",
  lang_desc = "%s - Switch language",
  hard_desc = "[EX|ON|OFF,ON|OFF] - Toggle hard mode for yourself",
  tc_desc = "[ON|OFF|MSG] - Send message to team only; turn ON to apply to all messages",
  stats_desc = "- Show/hide stat table",
  stalk_desc = "[NAME|ID] - Warps to the level the specified player is in, or the first Runner",
  spectate_desc = "[NAME|ID|OFF] - Spectate the specified player, free camera if not specified, or OFF to turn off", -- not to be confused with spectator_desc
  target_desc = "[NAME|ID] - Set this Runner as your target, which displays their location at all times.",
  unsaved_changes = "\\#ff5a5a\\You have unsaved changes! Press again if you're sure.", -- needs translation

  -- roles
  runner = "Runner",
  runners = "Runners",
  short_runner = "Run", -- unused
  hunters = "Hunters",
  hunter = "Hunter",
  spectator = "Spectator",
  player = "Player",
  players = "Players",
  all = "All",

  -- rules
  --[[
    This is laid out as follows:
    {welcome|welcome_mini}
    {runners}{shown_above|thats_you}{any_bowser|collect_bowser|mini_collect}
    {hunters}{thats_you}{all_runners|any_runners}
    {rule_lives_one|rule_lives}{time_needed|stars_needed}{become_hunter|become_runner}
    {infinite_lives}{spectate}
    {banned_glitchless|banned_general}{fun}

    I highly recommend testing this in-game
    Also:
    \\#ffffff\\ = white (default)
    \\#00ffff\\ = cyan (for Runner team name)
    \\#ff5a5a\\ = red (for Hunter team name and popups)
    \\#ffff5a\\ = yellow
    \\#5aff5a\\ = green
    \\#b45aff\\ = purple (for Extreme Mode)
  ]]
  welcome = "Welcome to \\#00ffff\\Mario\\#ff5a5a\\Hunt\\#ffffff\\! HOW TO PLAY:",
  welcome_mini = "Welcome to \\#ffff5a\\Mini\\#ff5a5a\\Hunt\\#ffffff\\! HOW TO PLAY:",
  welcome_egg = "Welcome to \\#5aff5a\\Luigi\\#ff5a5a\\Hunt\\#ffffff\\! HOW TO PLAY:",
  all_runners = "Defeat all \\#00ffff\\Runners\\#ffffff\\.",
  any_runners = "Defeat any \\#00ffff\\Runners\\#ffffff\\.",
  shown_above = "(shown above)",
  any_bowser = "Defeat %s through \\#ffff5a\\any\\#ffffff\\ means necessary.",
  collect_bowser = "Collect \\#ffff5a\\%d star(s)\\#ffffff\\ and defeat %s.",
  mini_collect = "Be the first to \\#ffff5a\\collect the star\\#ffffff\\.",
  collect_only = "Collect \\#ffff5a\\%d star(s)\\#ffffff\\.",
  thats_you = "(that's you!)",
  banned_glitchless = "NO: Cross teaming, BLJs, wall clipping, stalling, camping.",
  banned_general = "NO: Cross teaming, stalling, camping.",
  time_needed = "%d:%02d to leave any main stage; collect stars to decrease",
  stars_needed = "%d star(s) to leave any main stage",
  become_hunter = "become \\#ff5a5a\\Hunters\\#ffffff\\ when defeated",
  become_runner = "defeat a \\#00ffff\\Runner\\#ffffff\\ to become one",
  infinite_lives = "Infinite lives",
  spectate = "type \"/spectate\" to spectate",
  mini_goal = "\\#ffff5a\\Whoever collects the most stars in %d:%02d wins!\\#ffffff\\",
  fun = "Have fun!",

  -- hud, extra desc, and results text (%s is a placeholder for names, and %d is a placeholder for a number)
  win = "%s\\#ffffff\\ win!", -- team name is placed here
  can_leave = "\\#5aff5a\\Can leave course",
  cant_leave = "\\#ff5a5a\\Can't leave course",
  time_left = "Can leave in \\#ffff5a\\%d:%02d",
  stars_left = "Need \\#ffff5a\\%d star(s)\\#ffffff\\ to leave",
  in_castle = "In castle",
  until_hunters = "%d second(s) until \\#ff5a5a\\Hunters\\#ffffff\\ begin",
  until_runners = "%d second(s) until \\#00ffff\\Runners\\#ffffff\\ begin",
  lives_one = "1 life",
  lives = "%d lives",
  stars_one = "1 star",
  stars = "%d stars",
  no_runners = "No \\#00ffff\\Runners!",
  camp_timer = "Keep moving! \\#ff5a5a\\(%d)",
  game_over = "The game is over!",
  winners = "Winners: ",
  no_winners = "\\#ff5a5a\\No winners!",
  death_timer = "Death",
  mini_score = "Score: %d",
  new_record = "\\#ffff5a\\NEW RECORD!!!",
  on = "\\#5aff5a\\ON",
  off = "\\#ff5a5a\\OFF",
  frozen = "Frozen for %d",

  -- popups
  lost_life = "%s\\#ffa0a0\\ lost a life!",
  lost_all = "%s\\#ffa0a0\\ lost all of their lives!",
  now_role = "%s\\#ffa0a0\\ is now a %s\\#ffa0a0\\.",
  got_star = "%s\\#ffa0a0\\ got a star!",
  got_key = "%s\\#ffa0a0\\ got a key!",
  rejoin_start = "%s\\#ffa0a0\\ has two minutes to rejoin.",
  rejoin_success = "%s\\#ffa0a0\\ rejoined in time!",
  rejoin_fail = "%s\\#ffa0a0\\ did not reconnect in time.",
  leave_error = "%s\\#ffa0a0\\ left due to an error.",
  using_ee = "This is using Extreme Edition only.",
  not_using_ee = "This is using Standard Edition only.",
  killed = "%s\\#ffa0a0\\ killed %s!",
  sidelined = "%s\\#ffa0a0\\ finished off %s!",
  paused = "You have been paused.",
  unpaused = "You are no longer paused.",
  kill_combo_2 = "%s\\#ffa0a0\\ got a \\#ffff5a\\double\\#ffa0a0\\ kill!",
  kill_combo_3 = "%s\\#ffa0a0\\ got a \\#ffff5a\\triple\\#ffa0a0\\ kill!",
  kill_combo_4 = "%s\\#ffa0a0\\ got a \\#ffff5a\\quadruple\\#ffa0a0\\ kill!",
  kill_combo_5 = "%s\\#ffa0a0\\ got a \\#ffff5a\\quintuple\\#ffa0a0\\ kill!",
  kill_combo_large = "\\#ffa0a0\\Wow! %s\\#ffa0a0\\ got \\#ffff5a\\%d\\#ffa0a0\\ kills in a row!",
  set_hack = "Hack set to %s",
  incompatible_hack = "WARNING: Hack does not have compatibility!",
  vanilla = "Using vanilla game",
  omm_detected = "OMM Rebirth detected!",
  omm_bad_version = "\\#ff5a5a\\OMM Rebirth is outdated!\\#ffffff\\\nMinimum version: %s\nYour version: %s",
  warp_spam = "Slow down with the warps!",
  no_valid_star = "Could not find a valid star!",
  custom_enter = "%s\\#ffffff\\ entered\n%s", -- same as coop
  vanish_custom = "Hold \\#ffff5a\\B\\#ffffff\\ to vanish!",
  got_all_stars = "You have enough stars!",
  unstuck = "Attempted to fix state",
  use_out = "Use /mh out to warp everyone out of this level",
  stars_in_area = "%d star(s) available here!",
  demon_unlock = "Unlocked Green Demon mode!",
  hit_switch_red = "%s\\#ffa0a0\\ hit the\n\\#df5050\\Red Switch!", -- dark red (unique)
  hit_switch_green = "%s\\#ffa0a0\\ hit the\n\\#50b05a\\Green Switch!", -- dark green (unique)
  hit_switch_blue = "%s\\#ffa0a0\\ hit the\n\\#5050e3\\Blue Switch!", -- dark blue (unique)
  hit_switch_yellow = "%s\\#ffa0a0\\ hit the\n\\#e3b050\\Yellow Switch...", -- orangeish (unique)

  -- command feedback
  not_mod = "You don't have the AUTHORITY to run this command, you fool!",
  no_such_player = "No such player exists",
  bad_id = "Invalid player ID!",
  command_disabled = "This command is disabled.",
  change_setting = "Setting change:",
  you_are_muted = "You are muted.",

  -- more command feedback
  bad_param = "Invalid parameters!",
  bad_command = "Invalid command!",
  error_no_runners = "Can't start game with 0 runners!",
  set_team = "%s's team has been set to '%s'", -- First %s is player name, second is team name (now unused)
  not_started = "Game hasn't been started yet",
  set_lives_one = "%s now has 1 life",
  set_lives = "%s now has %d lives",
  not_runner = "%s isn't a Runner",
  may_leave = "%s may leave",
  must_have_one = "Must have at least 1 hunter",
  added = "Added runners: ", -- list comes afterward
  no_runners_added = "No Runners added",
  runners_are = "Runners are: ",
  set_lives_total = "Runner lives set to %d",
  wrong_mode = "Not available in this mode",
  need_time_feedback = "Runners can leave in %d second(s) now",
  game_time = "Game now lasts %d second(s)",
  need_stars_feedback = "Runners need %d star(s) now",
  new_category = "This is now a %d star run",
  new_category_any = "This is now an any% run",
  mode_normal = "In Normal mode",
  mode_swap = "In Swap mode",
  mode_mini = "In MiniHunt mode",
  using_stars = "Using stars collected",
  using_timer = "Using timer",
  can_spectate = "Hunters can now spectate",
  no_spectate = "Hunters can no longer spectate",
  all_paused = "All players paused",
  all_unpaused = "All players unpaused",
  player_paused = "%s has been paused",
  player_unpaused = "%s has been unpaused",
  hunter_metal = "All hunters are metal",
  hunter_normal = "All hunters appear normal",
  hunter_glow = "All hunters glow red",
  hunter_outline = "All hunters have an outline",
  hunter_color = "All hunters have the Burgundy palette", -- (check official lang for palette name)
  runner_sparkle = "All runners now sparkle",
  runner_normal = "All runners appear normal",
  runner_glow = "All runners now glow",
  runner_outline = "All runners have an outline",
  runner_color = "All runners have the Azure palette", -- (check official lang for palette name)
  now_weak = "All players have half invincibility frames",
  not_weak = "All players have normal invincibility frames",
  auto_on = "Games will start automatically",
  auto_off = "Games will not start automatically",
  force_spectate = "Everyone must spectate",
  force_spectate_off = "Spectate is no longer forced",
  force_spectate_one = "%s must spectate",
  force_spectate_one_off = "%s does not have to spectate anymore",
  blacklist_add = "Blacklisted %s",
  blacklist_remove = "Whitelisted %s",
  blacklist_add_already = "That star or level is already blacklisted.",
  blacklist_remove_already = "That star or level isn't blacklisted.",
  blacklist_remove_invalid = "Can't whitelist this star or level.",
  blacklist_list = "Blacklisted:",
  blacklist_reset = "Reset the blacklist!",
  blacklist_save = "Blacklist saved!",
  blacklist_load = "Blacklist loaded!",
  anarchy_set_0 = "Players cannot attack their teammates",
  anarchy_set_1 = "Runners can attack their teammates",
  anarchy_set_2 = "Hunters can attack their teammates",
  anarchy_set_3 = "Players can attack their teammates",
  dmgAdd_set = "Runners will now take %d extra damage from PVP attacks.",
  dmgAdd_set_ohko = "Runners will now die in one hit",
  voidDmg_set = "Players will take %d damage from falling into the void or quicksand.",
  voidDmg_set_ohko = "Players will instantly die from falling into the void or quicksand.",
  target_hunters_only = "Only Hunters can set a target.",
  muted = "\\#ffff00\\%s\\#ffffff\\ was muted by \\#ffff00\\%s\\#ffffff\\.",
  unmuted = "\\#ffff00\\%s\\#ffffff\\ was unmuted by \\#ffff00\\%s\\#ffffff\\.",
  you_muted = "You muted \\#ffff00\\%s\\#ffffff\\.",
  you_unmuted = "You unmuted \\#ffff00\\%s\\#ffffff\\.",
  mute_auto = "\\#ffff00\\%s\\#ffffff\\ was muted automatically.",

  -- team chat
  tc_toggle = "Team chat is %s!",
  to_team = "\\#8a8a8a\\To team: ",
  from_team = "\\#8a8a8a\\ (team): ",

  -- vote skip
  vote_skip = "%s\\#dcdcdc\\ voted to skip this star",
  vote_info = "Type /skip to vote",
  vote_pass = "The vote passed!",
  already_voted = "You've already voted.",

  -- hard mode
  hard_notice = "Psst, try typing /hard...",
  extreme_notice = "Psst, try typing /hard ex...",
  hard_toggle = "\\#ff5a5a\\Hard Mode\\#ffffff\\ is %s!",
  extreme_toggle = "\\#b45aff\\Extreme Mode\\#ffffff\\ is %s!",
  hard_info = "Interested in \\#ff5a5a\\Hard Mode\\#ffffff\\?"..
  "\n- Half health"..
  "\n- No water heal"..
  "\n- \\#ff5a5a\\One life"..
  "\n\\#ffffff\\Type /hard ON if you're up for the challenge.",
  extreme_info = "Are you drawn to \\#b45aff\\Extreme Mode\\#ffffff\\? How foolish."..
  "\n- One life"..
  "\n- One health"..
  "\n- \\#b45aff\\Death Timer\\#ffffff\\; collect coins and stars to increase"..
  "\nIf this doesn't scare you, type /hard ex ON.",
  no_hard_win = "Your Hard Wins or Extreme Wins score will not be updated for this game.",
  hard_mode = "Hard Mode",
  extreme_mode = "Extreme Mode",
  hard_info_short = "Half health, no water heal, and one life.",
  extreme_info_short = "One health, one life, and death timer.",

  -- spectator
  hunters_only = "Only Hunters can spectate!",
  spectate_disabled = "Spectate is disabled!",
  timer_going = "Can't spectate during timer!", -- now unused
  spectate_self = "Can't spectate yourself!",
  spectator_controls = "Controls:"..
  "\nDPAD-UP: Turn off hud"..
  "\nDPAD-DOWN: Swap freecam/player view"..
  "\nDPAD-LEFT / DPAD-RIGHT: Switch player"..
  "\nJOYSTICK: Move"..
  "\nA: Go up"..
  "\nZ: Go down"..
  "\nType \"/spectate OFF\" to cancel",
  spectate_off = "No longer spectating.",
  empty = "EMPTY (%d )",
  free_camera = "FREE CAMERA",
  spectate_mode = "- SPECTATOR MODE -",
  is_spectator = '* PLAYER IS A SPECTATOR  *',

  -- stats
  disp_wins_one = "%s\\#ffffff\\ has won 1 time as \\#00ffff\\Runner\\#ffffff\\!",
  disp_wins = "%s\\#ffffff\\ has won %d times as \\#00ffff\\Runner\\#ffffff\\!",
  disp_kills_one = "%s\\#ffffff\\ has killed 1 player!", -- unused
  disp_kills = "%s\\#ffffff\\ has killed %d players!",
  disp_wins_hard_one = "%s\\#ffffff\\ has won 1 time as \\#ffff5a\\Runner\\#ffffff\\ in \\#ff5a5a\\Hard Mode!\\#ffffff\\",
  disp_wins_hard = "%s\\#ffffff\\ has won %d times as \\#ffff5a\\Runner\\#ffffff\\ in \\#ff5a5a\\Hard Mode!\\#ffffff\\",
  disp_wins_ex_one = "%s\\#ffffff\\ has won 1 time as \\#b45aff\\Runner\\#ffffff\\ in \\#b45aff\\Extreme Mode!\\#ffffff\\",
  disp_wins_ex = "%s\\#ffffff\\ has won %d times as \\#b45aff\\Runner\\#ffffff\\ in \\#b45aff\\Extreme Mode!\\#ffffff\\",
  disp_asn_quarter = "%s\\#ffffff\\ reached the \\#70ff94\\quarter-finals\\#ffffff\\ in the ASN Tourney!", -- needs translation
  disp_asn_semi = "%s\\#ffffff\\ reached the \\#b38752\\semi-finals\\#ffffff\\ in the ASN Tourney!", -- needs translation
  disp_asn_final = "%s\\#ffffff\\ reached the \\#c5d8de\\finals\\#ffffff\\ in the ASN Tourney!", -- needs translation
  disp_asn_win = "%s \\#e3bc2d\\won\\#ffffff\\ the ASN Tourney!", -- needs translation
  -- for stats table
  stat_wins_standard = "Wins",
  stat_wins = "Wins (Minihunt/pre v2.3)",
  stat_kills = "Kills",
  stat_combo = "Max Kill Streak",
  stat_wins_hard_standard = "Wins (Hard Mode)",
  stat_wins_hard = "Wins (Hard Mode, MiniHunt/pre v2.3)",
  stat_mini_stars = "Maximum Stars in one game of MiniHunt",
  stat_placement = "64 Tour Placement",
  stat_wins_ex_standard = "Wins (Extreme Mode)",
  stat_wins_ex = "Wins (Extreme Mode, MiniHunt/pre v2.3)",
  stat_playtime = "Playtime (Hours)",
  stat_parkour_time = "Fastest Parkour Time",
  stat_parkour_time_omm = "Fastest Parkour Time (OMM)",
  stat_parkour_time_other = "Fastest Parkour Time (Moveset)",
  stat_placement_asn = "ASN Tourney Placement",

  -- placements
  place_1 = "\\#e3bc2d\\[64T: 1st Place]",
  place_2 = "\\#c5d8de\\[64T: 2nd Place]",
  place_3 = "\\#b38752\\[64T: 3rd Place]",
  place = "\\#e7a1ff\\[64T: %dth Place]", -- thankfully we don't go up to 21
  place_asn_1 = "\\#e3bc2d\\[ASN Winner]", -- needs translation
  place_asn_2 = "\\#c5d8de\\[ASN Finalist]", -- needs translation
  place_asn_3 = "\\#b38752\\[ASN Semi-Finalist]", -- needs translation
  place_asn_4 = "\\#70ff94\\[ASN Quarter-Finalist]", -- needs translation
  place_asn = "\\#e7a1ff\\[ASN Participant]", -- needs translation
  place_score_1 = "%dst",
  place_score_2 = "%dnd",
  place_score_3 = "%drd",
  place_score = "%dth",

  -- chat roles
  role_lead = "\\#9a96ff\\[Lead MH Dev]",
  role_dev = "\\#96ecff\\[MH Dev]",
  role_cont = "\\#ff9696\\[MH Contributor]",
  role_trans = "\\#ffd996\\[MH Translator]",

  -- command descriptions
  page = "\\#ffff5a\\Page %d/%d", -- page for mariohunt command
  start_desc = "[CONTINUE|MAIN|ALT|RESET] - Starts the game; add \"continue\" to not warp to start; add \"alt\" for alt save file; add \"main\" for main save file; add \"reset\" to reset file",
  add_desc = "[INT] - Adds the specified amount of runners at random",
  random_desc = "[INT] - Picks the specified amount of runners at random",
  lives_desc = "[INT] - Sets the amount of lives Runners have, from 0 to 99 (note: 0 lives is still 1 life)",
  time_desc = "[NUM] - Sets the amount of time Runners have to wait to leave, in seconds, or the length of the game in MiniHunt.",
  stars_desc = "[INT] - Sets the amount of stars Runners must collect to leave, from 0 to 7 (only in star mode)",
  category_desc = "[INT] - Sets the amount of stars Runners must have to face Bowser.",
  flip_desc = "[NAME|ID] - Flips the team of the specified player",
  setlife_desc = "[NAME|ID|INT,INT] - Sets the specified lives for the specified runner",
  leave_desc = "[NAME|ID] - Allows the specified player to leave the level if they are a runner",
  mode_desc = "[NORMAL|SWAP|MINI] - Changes game mode; Swap switches runners when one dies",
  starmode_desc = "[ON|OFF] - Toggles using stars collected instead of time",
  spectator_desc = "[ON|OFF] - Toggles Hunters' ability to spectate",
  pause_desc = "[NAME|ID|ALL] - Toggles pause status for specified players, or all if not specified",
  hunter_app_desc = "Changes the appearance of Hunters.",
  runner_app_desc = "Changes the appearance of Runners.",
  hack_desc = "[STRING] - Sets current rom hack",
  weak_desc = "[ON|OFF] - Cuts invincibility frames in half for all players",
  auto_desc = "[ON|OFF|NUM] - Start games automatically",
  forcespectate_desc = "[NAME|ID|ALL] - Toggle forcing spectate for this player or all players",
  desync_desc = "- Attempts to fix desync errors",
  stop_desc = "- Stop the game",
  default_desc = "- Set settings to default",
  blacklist_desc = "[ADD|REMOVE|LIST|RESET|SAVE|LOAD,COURSE,ACT] - Blacklist stars in MiniHunt",
  stalking_desc = "[ON|OFF] - Allow warping to a Runner's level with /stalk",
  mute_desc = "[NAME|ID] - Mutes a player, preventing them from chatting",
  unmute_desc = "[NAME|ID] - Unmutes a player, allowing them to chat again",
  out_desc = "- Kicks everyone out of this level",

  -- Blocky's menu
  main_menu = "Main Menu",
  menu_mh = "MarioHunt",
  menu_mh_egg = "LuigiHunt",
  menu_settings_player = "Settings",
  menu_rules = "Rules",
  menu_list_settings = "List Settings",
  menu_list_settings_desc = "Lists all settings for this lobby.",
  menu_lang = "Language",
  menu_misc = "Misc.",
  menu_stats = "Stats",
  menu_back = "Back",
  menu_exit = "Exit",

  menu_run_random = "Randomize Runners",
  menu_run_add = "Add Runners",
  menu_run_lives = "Runner Lives",
  menu_settings = "Game Settings",

  menu_start = "Start",
  menu_stop = "Stop",
  menu_save_main = "Main",
  menu_save_alt = "Alt Save",
  menu_save_reset = "Reset Alt Save",
  menu_save_continue = "Continue (no warping back)",
  menu_random = "Random",
  menu_campaign = "Campaign",
  menu_coop = "Coop",

  menu_gamemode = "Gamemode",
  menu_hunter_app = "Hunter Appearance",
  menu_runner_app = "Runner Appearance",
  menu_weak = "Weak Mode",
  menu_allow_spectate = "Allow Spectating",
  menu_star_mode = "Star Mode",
  menu_category = "Category",
  menu_time = "Time",
  menu_stars = "Stars",
  menu_auto = "Auto Game",
  menu_blacklist = "MiniHunt Blacklist",
  menu_default = "Reset to Defaults",
  menu_anarchy = "Friendly Fire",
  menu_anarchy_desc = "Allows the specified teams to attack their teammates.",
  menu_dmgAdd = "Runner PVP DMG Up", -- DMG is "damage"
  menu_dmgAdd_desc = "Add this much damage to attacks against Runners.",
  menu_nerf_vanish = "Nerf Vanish Cap", -- Nerf, as in to reduce power for balancing
  menu_nerf_vanish_desc = "Nerfs vanish cap by making it toggleable and drain faster when used.",
  menu_first_timer = "Leader Death Timer",
  menu_first_timer_desc = "Gives the leader in MiniHunt a death timer.",
  menu_defeat_bowser = "Defeat %s",
  menu_allow_stalk = "Allow 'Stalking'",
  menu_countdown = "Countdown",
  menu_countdown_desc = "How long Hunters must wait before starting.",
  menu_voidDmg = "Void DMG",
  menu_voidDmg_desc = "Damage dealt to players falling into the void or quicksand.",
  menu_double_health = "Double Runner Health",
  menu_double_health_desc = "Runners get 16 points of health instead of 8.",
  menu_free_roam = "Free Roam",
  menu_free_roam_desc = "Disables Star and Key requirements for doors and most levels.",
  menu_star_heal = "Star Heal",
  menu_stalk_timer = "Stalk Cooldown", -- needs translation
  menu_stalk_timer_desc = "Time the player is frozen for after using /stalk.", -- needs translation
  menu_star_setting = "On star collection",
  menu_star_stay_old = "Stay If Already Collected", -- needs translation
  menu_star_stay_old_desc = "Collecting a star that has already been collected will not eject you from the level.", -- needs translation
  star_leave = "Leave",
  star_stay = "Stay",
  star_nonstop = "Non-Stop",
  menu_presets = "Presets",

  menu_flip = "Flip Team",
  menu_spectate = "Spectate",
  menu_stalk = "Warp To Level",
  menu_stalk_desc = "Warp to this player's level.",
  menu_pause = "Pause",
  menu_forcespectate = "Force to Spectate",
  menu_allowleave = "Allow to Leave",
  menu_setlife = "Set Lives",
  menu_players_all = "All Players",
  menu_target = "Set as Target",
  menu_mute = "Mute",

  menu_timer = "Speedrun Timer",
  menu_timer_desc = "[ON|OFF] - Show a timer at the bottom of the screen in Standard modes.",
  menu_tc = "Team Chat",
  menu_tc_desc = "Chat only with your team.",
  menu_demon = "Green Demon", -- referring to the 1-Up
  menu_demon_desc = "Have a 1-Up chase you as Runner.",
  menu_unknown = "???",
  menu_secret = "This is a secret. How do you unlock it?",
  menu_hide_roles = "Hide My Roles",
  menu_hide_roles_desc = "Hide your roles from displaying in chat.",
  menu_hide_hud = "Hide HUD",
  hidehud_desc = "- Hide all HUD elements.",
  menu_fast = "Faster Actions",
  menu_fast_desc = "You will recover, throw objects, and open doors faster.",
  menu_popup_sound = "Popup Sounds",
  menu_season = "Seasonal Changes",
  menu_season_desc = "Fun visual changes depending on the date.",
  menu_radar = "Radar",
  menu_radar_desc = "Shows where Runners and important objects are.",
  menu_minimap = "Minimap",
  menu_minimap_desc = "Shows a map of the whole level.",
  menu_romhack_cam = "Romhack Cam", -- (cam is short for camera)
  menu_romhack_cam_desc = "Enables romhack camera at all times.", -- (cam is short for camera)
  menu_invinc_particle = "Sparkle I-Frames", -- (I-Frames is short for invincibility/invulnerability frames)
  menu_invinc_particle_desc = "Replaces the \"blinking\" effect when Mario takes damage with sparkle particles.",
  menu_star_timer = "Last Star Time",
  menu_star_timer_desc = "- Shows when the last star was collected on the bottom of the screen.",

  menu_free_cam_desc = "Enter Free Camera in Spectator Mode.",
  menu_spectate_run = "Spectate Runner",
  menu_spectate_run_desc = "Automatically spectate the first Runner.",
  menu_exit_spectate = "Exit Spectate",
  menu_exit_spectate_desc = "Exit spectator mode.",
  menu_stalk_run = "Warp to Runner Level",
  menu_stalk_run_desc = "Warp to the level the first Runner is in.",
  menu_skip = "Skip",
  menu_skip_desc = "- Vote to skip this star in MiniHunt.",

  menu_spectate_desc = "Spectate this player.",

  menu_blacklist_list = "List All Blacklisted",
  menu_blacklist_list_desc = "Lists all blacklisted stars in MiniHunt for this server.",
  menu_blacklist_save = "Save Blacklist",
  menu_blacklist_save_desc = "Save this blacklist on your end.",
  menu_blacklist_load = "Load Blacklist",
  menu_blacklist_load_desc = "Load your saved blacklist.",
  menu_blacklist_reset = "Reset Blacklist",
  menu_blacklist_reset_desc = "Reset the blacklist to the default.",
  menu_toggle_all = "Toggle All",
  
  -- presets (needs translation)
  preset_quick = "Quick Game",
  preset_quick_desc = "30 Star, Free Roam, No Bowser run.",
  preset_infection = "Infection",
  preset_infection_desc = "1 Hunter that can one-shot! Can the Runners survive?",
  preset_solo = "Solo",
  preset_solo_desc = "You're on your own! 3 lives and double health.",
  preset_tag = "Tag",
  preset_tag_desc = "Hit a Runner to instantly become one!",
  preset_star_rush = "Star Rush",
  preset_star_rush_desc = "Minihunt, but everyone's a Runner!",
  preset_classic = "Classic",
  preset_classic_desc = "Changes settings to match old versions of MarioHunt.",

  -- updater (now obsolete)
  up_to_date = "\\#00ffff\\Mario\\#ff5a5a\\Hunt\\#ffffff\\ is up to date!",
  up_to_date_egg = "\\#5aff5a\\Luigi\\#ff5a5a\\Hunt\\#ffffff\\ is up to date!",
  has_update = "An update is availible for \\#00ffff\\Mario\\#ff5a5a\\Hunt\\#ffffff\\!",
  has_update_egg = "An update is availible for \\#5aff5a\\Luigi\\#ff5a5a\\Hunt\\#ffffff\\!",

  -- tips (needs translation)
  -- I totally understand if you don't want to translate all of these.
  tip = "Tip: ",
  tip_1 = "Press L + Start, or type /mh, to open the menu. You can configure settings here!",
  tip_2 = "Ground pounds deal 3 damage to other players.",
  tip_3 = "A kick will deal 2 damage and send players flying!",
  tip_4 = "For commands such as /spectate and /target, you can enter partial names and they'll still work (ex: entering \"Emily\" will refer to EmilyEmmi)",
  tip_5 = "You can change settings mid-game in the menu.",
  tip_6 = "If something goes wrong, type /mh pause to pause all players. Type it again to unpause.",
  tip_7 = "Is someone spamming or using slurs? Use /mh mute to mute them!",
  tip_8 = "You can pause the game before collecting a star or key and Exit Course to skip the animation.",
  tip_9 = "You can target a Runner with /target. This will display their location at the top of the screen.",
  tip_10 = "You can configure personal settings in the menu (L + Start).",
  tip_11 = "No need to restart the server! Select \"Reset Alt Save\" in \"Start\" to reset all progress.",
  tip_12 = "You can obtain Runner role by defeating a Runner.",
  tip_13 = "Like in vanilla Mario 64, 0 lives still counts as a life.",
  tip_14 = "Major glitches, such as LBLJ, are useless outside of Any%.",
  tip_15 = "In-game signs may contain more helpful tips!",
  tip_16 = "Dire Dire Docks may be entered at one less star than the actual category.",
  tip_17 = "Set Cappy to \"Damage\" to use him as a ranged weapon. He deals 1 damage.",
  tip_18 = "Cappy can pick up objects, such as Coins and Secrets.",
  tip_19 = "Use the D-Pad to throw Cappy in different directions.",
  tip_20 = "Check out Key's Artwork's video on YouTube to learn about OMM tech!",
  tip_21 = "If objects in a level start to disappear or warps stop working, use /mh out in that level to force that level to reload.",
  tip_22 = "Use /mh desync if you think a desync error has occured.",
  tip_23 = "Killing another player will restore all of your health.",
  tip_24 = "You can see progress on keys, caps, and secret stages in the Pause menu in the castle.",
  tip_25 = "Runners can hurt each other in this mode!",
  tip_26 = "Falling off in cap stages counts as losing a life.",
  tip_27 = "Blue coin switches will respawn.",
  tip_28 = "You can pick another act to throw off Hunters.",
  tip_29 = "It's a holiday! If you don't like the effects, turn off \"Seasonal Changes\" in the menu.",
  tip_30 = "You can spy on Runners with /spectate.",
  tip_31 = "Use /stalk to warp to a level another Runner is in!",
  tip_32 = "Learning speedrunning techniques is a good way to improve your game.",
  tip_33 = "You can phase through Whomps by ground-pounding or kicking as they fall.",
  tip_34 = "The fastest way to perform a Triple Jump is by kicking for the first jump.",
  tip_35 = "Metal form deals double damage to opponents.",
  tip_36 = "The Vanish Cap will only take effect when holding B.",
  tip_37 = "Cap timers don't drain inside of cannons.",
  tip_38 = "Don't linger on the Act Select for too long!",
  tip_39 = "Dives are fast, and diving into another player can help you evade attacks.",
  tip_40 = "Falling off will deal damage instead of instantly killing you.",
  tip_41 = "1-Ups will restore all of your health.",
  tip_42 = "Use the Players menu for commands that target a specific player, such as flipping teams.",
  tip_43 = "The MarioHunt menu allows for starting games and configuring game settings.",
  tip_44 = "You can hide your chat role in Settings.",
  tip_45 = "Runners wearing the Metal Cap can still be hurt by Hunters.",
  tip_46 = "In the menu, be sure to press A to save your changed settings!",

  -- These commands only appear to me, so I wouldn't bother translating them. You can delete these lines and everything should still work.
  print_desc = "[STRING] - Outputs message to console",
  warp_desc = "[LEVEL|COURSE,AREA,ACT,NODE] - Warp to level",
  quick_desc = "[LEVEL|COURSE|HUNTER,AREA,ACT,NODE] - Quick game testing",
  combo_desc = "[NUM] - Test combo message",
  field_desc = "[STRING] - Get specified field for all players",
  gfield_desc = "[STRING] - Get specified global field",
  allstars_desc = "- Lists all stars",
  langtest_desc = "- Do language testing stuff",
  unmod_desc = "- Toggle off mod for yourself for testing",
  location_desc = "[NAME|ID] - Get your location, or whoever is specified",
  complete_desc = "- 100%s the save file",
  djui_desc = "- Opens djui menu",
  swarp_desc = "- Does special warp (-1, -2, -3, -8, or -9)",
  ["set-fov_desc"] = "[NUM] - Sets your fov; leave blank to reset",
  ["wing-cap_desc"] = "- Grants wing cap",
  ["kill-bowser_desc"] = "- Kills Bowser, if he exists",
}

langdata["es"] = -- By Kanheaven and SonicDark, with newer lines by EpikCool and corrected errors by green
{
  -- fullname for auto select
  fullname = "Spanish",

  -- name in the built-in menu
  name_menu = "Español (US)", -- I wanted to keep the name shorter

  -- global command info
  to_switch = "Escribe \"/lang %s\" para cambiar idioma",
  switched = "¡Cambiaste a Español!",
  rule_command = "Escribe /rules para mostrar este mensaje otra vez",
  stalk = "¡Escribe /stalk para teletransportarte a los corredores!",

  -- roles
  runner = "Corredor",
  runners = "Corredores",
  short_runner = "Corre",
  hunter = "Cazador",
  hunters = "Cazadores",
  spectator = "Espectador",
  player = "Jugador",
  players = "Jugadores",
  all = "Todos",
  demon_unlock = "¡Has desbloqueado el modo Green Demon!",
  hit_switch_red = "¡%s\\#ffa0a0\\ presionó el\n\\#df5050\\Interruptor Rojo!", -- dark red (unique)
  hit_switch_green = "¡%s\\#ffa0a0\\ presionó el\n\\#50b05a\\Interruptor Verde!", -- dark green (unique)
  hit_switch_blue = "¡%s\\#ffa0a0\\ presionó el\n\\#5050e3\\Interruptor Azul!", -- dark blue (unique)
  hit_switch_yellow = "%s\\#ffa0a0\\ presionó el\n\\#e3b050\\Interruptor Amarillo...", -- orangeish (unique)

  -- rules (%d:%02d is time in minutes:seconds format)
  welcome = "¡Bienvenido a \\#00ffff\\Mario\\#ff5a5a\\Hunt\\#ffffff\\! CÓMO JUGAR:",
  welcome_mini = "¡Bienvenido a \\#ffff5a\\Mini\\#ff5a5a\\Hunt\\#ffffff\\! CÓMO JUGAR:",
  welcome_egg = "¡Bienvenido a \\#5aff5a\\Luigi\\#ff5a5a\\Hunt\\#ffffff\\! CÓMO JUGAR:",
  all_runners = "Eliminen a todos los \\#00ffff\\Corredores\\#ffffff\\.",
  any_runners = "Eiminen a cualquiera de los \\#00ffff\\Corredores\\#ffffff\\.",
  shown_above = "(mostrado arriba)",
  any_bowser = "Derroten a %s de \\#ffff5a\\cualquier\\#ffffff\\ manera.",
  collect_bowser = "Recolecten \\#ffff5a\\%d estrella(s)\\#ffffff\\ y derroten a %s.",
  mini_collect = "Sé el primero en \\#ffff5a\\recolectar la estrella\\#ffffff\\.",
  collect_only = "Recolecten \\#ffff5a\\%d estrella(s)\\#ffff5a\\.",
  thats_you = "(¡ese eres tú!)",
  banned_glitchless = "NO: traicionar a tu equipo, BLJs, atravesar paredes, frenar el avance del juego, campear.",
  banned_general = "NO: traicionar a tu equipo, frenar el avance del juego, campear.",
  time_needed = "%d:%02d para salir de cualquier nivel; recolecta estrellas para reducir este tiempo",
  stars_needed = "%d estrella(s) para salir de cualquier nivel",
  become_hunter = "únete a los \\#ff5a5a\\Cazadores\\#ffffff\\ cuando hayas sido eliminado",
  become_runner = "elimina a un \\#00ffff\\Corredor\\#ffffff\\ para volverte uno", -- this was changed
  infinite_lives = "Vidas infinitas",
  spectate = "escribe \"/spectate\" para ser un espectador",
  mini_goal = "\\#ffff5a\\¡Quien recolecte la mayor cantidad de estrellas en %d:%02d, gana!\\#ffffff\\",
  fun = "¡Diviértete!",

  -- hud, extra desc, and results text
  win = "¡%s\\#ffffff\\ ganan!",
  can_leave = "\\#5aff5a\\Puedes salir del nivel",
  cant_leave = "\\#ff5a5a\\No puedes salir del nivel", -- is this correct?
  time_left = "Puedes salir en \\#ffff5a\\%d:%02d",
  stars_left = "Necesitas \\#ffff5a\\%d estrella(s)\\#ffffff\\ para salir del nivel",
  in_castle = "En el Castillo",
  until_hunters = "Los \\#ff5a5a\\Cazadores\\#ffffff\\ empiezan en: %d segundo(s)",
  until_runners = "Los \\#00ffff\\Corredores\\#ffffff\\ empiezan en: %d segundo(s)",
  lives_one = "1 vida",
  lives = "%d vidas",
  stars_one = "1 estrella",
  stars = "%d estrellas",
  no_runners = "¡No hay \\#00ffff\\Corredores!",
  camp_timer = "¡Muévete! \\#ff5a5a\\(%d)",
  game_over = "¡La partida terminó!",
  winners = "Ganadores: ",
  no_winners = "\\#ff5a5a\\¡No hay ganadores!",
  death_timer = "Muerte",
  on = "\\#5aff5a\\ACTIVADO",
  off = "\\#ff5a5a\\DESACTIVADO",
  frozen = "Congelado por %d",

  -- popups
  lost_life = "¡%s\\#ffa0a0\\ perdió una vida!",
  lost_all = "¡%s\\#ffa0a0\\ perdió todas sus vidas!",
  now_role = "%s\\#ffa0a0\\ ahora es un %s\\#ffa0a0\\.",
  got_star = "¡%s\\#ffa0a0\\ consiguió una estrella!",
  got_key = "¡%s\\#ffa0a0\\ consiguió una llave!",
  rejoin_start = "%s\\#ffa0a0\\ tiene dos minutos para volver a unirse.",
  rejoin_success = "¡%s\\#ffa0a0\\ regresó a tiempo!",
  rejoin_fail = "%s\\#ffa0a0\\ no regresó a tiempo.",
  leave_error = "%s\\#ffa0a0\\ se desconecto por un error.",
  using_ee = "\\#ffa0a0\\La partida está teniendo lugar en Modo Extremo.",
  not_using_ee = "\\#ffa0a0\\La partida está teniendo lugar en Modo Normal.",
  killed = "¡%s\\#ffa0a0\\ mató a %s!",
  sidelined = "¡%s\\#ffa0a0\\ acabó con %s!",
  paused = "Has sido pausado.",
  unpaused = "Ya no estás pausado.",
  kill_combo_2 = "¡%s\\#ffa0a0\\ hizo una \\#ffff5a\\doble\\#ffa0a0\\ muerte!",
  kill_combo_3 = "¡%s\\#ffa0a0\\ hizo una \\#ffff5a\\triple\\#ffa0a0\\ muerte!",
  kill_combo_4 = "¡%s\\#ffa0a0\\ hizo una \\#ffff5a\\cuádruple\\#ffa0a0\\ muerte!",
  kill_combo_5 = "¡%s\\#ffa0a0\\ hizo una \\#ffff5a\\quíntuple\\#ffa0a0\\ muerte!",
  kill_combo_large = "\\#ffa0a0\\¡Wow! ¡%s\\#ffa0a0\\ hizo \\#ffff5a\\%d\\#ffa0a0\\ muertes consecutivas!",
  set_hack = "Romhack seleccionado: %s",
  incompatible_hack = "ADVERTENCIA: ¡Este romhack no es compatible!",
  vanilla = "Usando el juego original",
  omm_detected = "¡Se Detecto El OMM Rebirth!",
  omm_bad_version = "\\#ff5a5a\\¡OMM Rebirth está desactualizado!\\#ffffff\\\nVersión mínima: %s\nTu versión: %s",
  warp_spam = "¡No te teletransportes tan rápido!",
  no_valid_star = "¡No se ha podido encontrar una estrella válida!",
  custom_enter = "%s\\#ffffff\\ ha entrado a\n%s", -- same as coop

  -- command feedback
  not_mod = "No tienes la AUTORIDAD para usar este comando, ¡Tonto!",
  no_such_player = "Ese jugador no existe",
  bad_id = "¡ID de jugador inválido!",
  command_disabled = "Este comando está desactivado.",
  change_setting = "Ajuste modificado:",

  -- more command feedback
  bad_param = "¡Parámetros inválidos!",
  bad_command = "¡Comando inválido!",
  error_no_runners = "¡No se puede iniciar la partida con 0 corredores!",
  set_team = "%s ahora es un '%s'", -- First %s is player name, second is team name (now unused)
  not_started = "La partida aún no ha iniciado",
  set_lives_one = "%s ahora tiene 1 vida",
  set_lives = "%s ahora tiene %d vidas",
  not_runner = "%s no es un Corredor",
  may_leave = "%s puede salir del nivel",
  must_have_one = "Debes tener al menos un cazador",
  added = "Se agregó a los corredores: ", -- list comes afterward
  runners_are = "Los corredores son: ",
  set_lives_total = "Vidas de los corredores ajustadas a %d",
  wrong_mode = "No disponible en este modo",
  need_time_feedback = "Los corredores podrán salir del nivel en %d segundo(s) ahora",
  game_time = "La partida ahora durará %d segundo(s)",
  need_stars_feedback = "Los corredores ahora necesitan %d estrella(s)",
  new_category = "Ahora esto es una %d star run",
  new_category_any = "Ahora esto es una any% run",
  mode_normal = "En modo Normal",
  mode_swap = "En modo Swap",
  mode_mini = "En modo MiniHunt",
  using_stars = "Usando estrellas recolectadas",
  using_timer = "Usando tiempo",
  can_spectate = "Los Cazadores ahora pueden ser espectadores",
  no_spectate = "Los Cazadores ya no pueden ser espectadores",
  all_paused = "Todos los jugadores han sido pausados",
  all_unpaused = "Todos los jugadores ya no están pausados",
  player_paused = "%s ha sido pausado",
  player_unpaused = "%s ya no está pausado",
  hunter_metal = "Todos los Cazadores son de metal",
  hunter_normal = "Todos los Cazadores se verán normales",
  hunter_glow = "Todos los Cazadores brillarán rojo",
  hunter_outline = "Ahora Todos los Cazadores tienen el aspecto Outline",
  hunter_color = "Todos los Cazadores tendran un aspecto con color Borgoña",
  runner_normal = "Todos los Corredores se verán normales",
  runner_sparkle = "Ahora todos los Corredores tendran el aspecto Brillante",
  runner_glow = "Ahora todos los Corredores tendran glow",
  runner_outline = "Ahora Todos los Corredores tienen el aspecto Outline",
  runner_color = "Ahora Todos los Corredores tender un aspecto de color Celeste",
  now_weak = "Todos los jugadores tienen la mitad de Invincibility Frames",
  not_weak = "Todos los jugadores tienen Invincibility Frames normales",
  auto_on = "Las partidas iniciarán automáticamente",
  auto_off = "Las partidas no iniciarán automáticamente",
  force_spectate = "Todos serán forzados al modo Espectador",
  force_spectate_off = "El modo Espectador ya no es forzado",
  force_spectate_one = "%s será un Espectador",
  force_spectate_one_off = "%s ya no es forzado a ser un Espectador",
  blacklist_add = "%s agregado a la Lista Negra",
  blacklist_remove = "%s removido de la Lista Negra",
  blacklist_add_already = "Esa estrella o nivel ya está en la Lista Negra.",
  blacklist_remove_already = "Esa estrella o nivel no está en la Lista Negra.",
  blacklist_remove_invalid = "No puedes agregar a esa estrella o nivel a la Lista Negra .",
  blacklist_list = "Lista Negra:",
  blacklist_reset = "¡La Lista Negra ha sido reiniciada!",
  blacklist_save = "¡La Lista Negra ha sido guardada!",
  blacklist_load = "¡La Lista negra ha sido cargada!",

  -- team chat
  tc_toggle = "¡El chat de equipo está %s!",
  to_team = "\\#8a8a8a\\Para tu equipo: ",
  from_team = "\\#8a8a8a\\ (equipo): ",

  -- vote skip
  vote_skip = "%s\\#dcdcdc\\ votó para saltar esta estrella",
  vote_info = "Escribe /skip para saltarla",
  vote_pass = "¡La votación terminó!",
  already_voted = "Ya has votado.",

  -- hard mode
  hard_notice = "Psst, intenta escribir /hard info...",
  extreme_notice = "Psst, intenta escribir /hard ex...",
  hard_toggle = "¡\\#ff5a5a\\Modo Difícil\\#ffffff\\ %s!",
  extreme_toggle = "¡\\#b45aff\\Modo Extremo\\#ffffff\\ %s!",
  hard_info = "¿Interesado en el\\#ff5a5a\\Modo Difícil\\#ffffff\\?"..
  "\n- Sólo tienes la mitad de salud"..
  "\n- No te puedes curar usando el agua"..
  "\n- \\#ff5a5a\\Sólo tienes una vida"..
  "\n\\#ffffff\\Escribe /hard ON si aceptas el desafío.",
  extreme_info = "¿Acaso te interesa el \\#b45aff\\Modo Extremo\\#ffffff\\? Que tonto."..
  "\n- Una vida"..
  "\n- Un punto de salud"..
  "\n- \\#b45aff\\Temporizador de Muerte\\#ffffff\\; recolecta monedas y estrellas para aumentarlo"..
  "\nSi esto no te asusta, escribe /hard ex ON.",
  no_hard_win = "Tus victorias en Modo Difícil o Modo Extremo no contarán en esta partida.",
  hard_mode = "Modo Difícil",
  extreme_mode = "Modo Extremo",
  hard_info_short = "Sólo tienes la mitad de salud, una vida, y no te puedes curar usando el agua.",
  extreme_info_short = "Un punto de salud, una vida, y Temporizador de Muerte.",

  -- spectator
  hunters_only = "¡Sólo los Cazadores pueden ser espectadores!",
  spectate_disabled = "¡Modo Espectador desactivado!",
  timer_going = "¡No puedes ser Espectador cuando el tiempo corre!", -- now unused
  spectate_self = "¡No puedes ser Espectador de ti mismo!",
  spectator_controls = "Controles:"..
  "\nDPAD-UP: Desactiva la interfaz"..
  "\nDPAD-DOWN: Cambia la vista entre cámara libre/punto de vista del jugador"..
  "\nDPAD-LEFT / DPAD-RIGHT: Cambia jugador"..
  "\nJOYSTICK: Moverse"..
  "\nA: Moverse hacia arriba"..
  "\nZ: Moverse hacia abajo"..
  "\nType \"/spectate OFF\" para cancelar",
  spectate_off = "Dejaste de ser Espectador.",
  empty = "VACÍO (%d )",
  free_camera = "CÁMARA LIBRE",
  spectate_mode = "- MODO ESPECTADOR -",
  is_spectator = '* EL JUGADOR ES UN ESPECTADOR  *', -- is this correct?

  -- stats
  disp_wins_one = "¡%s\\#ffffff\\ ganó 1 vez como \\#00ffff\\Corredor\\#ffffff\\!",
  disp_wins = "¡%s\\#ffffff\\ ganó %d veces como \\#00ffff\\Corredor\\#ffffff\\!",
  disp_kills_one = "¡%s\\#ffffff\\ mató a 1 jugador!", -- unused
  disp_kills = "¡%s\\#ffffff\\ mató a %d jugadores!",
  disp_wins_hard_one = "¡%s\\#ffffff\\ ganó 1 vez como \\#ffff5a\\Corredor\\#ffffff\\ en \\#ff5a5a\\Modo Difícil\\#ffffff\\!",
  disp_wins_hard = "¡%s\\#ffffff\\ ganó %d veces como \\#ffff5a\\Corredor\\#ffffff\\ en \\#ff5a5a\\Modo Difícil\\#ffffff\\!",
  disp_wins_ex_one = "¡%s\\#ffffff\\ ganó 1 vez como \\#b45aff\\Corredor\\#ffffff\\ en \\#b45aff\\Modo Extremo\\#ffffff\\!",
  disp_wins_ex = "¡%s\\#ffffff\\ ganó %d veces como \\#b45aff\\Corredor\\#ffffff\\ en \\#b45aff\\Modo Extremo\\#ffffff\\!",
  -- for stats table
  stat_wins_standard = "Victorias",
  stat_wins = "Victorias (Minihunt/pre v2.3)",
  stat_kills = "Muertes",
  stat_combo = "Racha de muertes más alta",
  stat_wins_hard_standard = "Victorias (Modo Difícil)",
  stat_wins_hard = "Victorias (Modo Difícil, MiniHunt/pre v2.3)",
  stat_mini_stars = "Récord de estrellas en MiniHunt",
  stat_wins_ex_standard = "Victorias (Modo Extremo)",
  stat_wins_ex = "Victorias (Modo Extremo, MiniHunt/pre v2.3)",
  stat_playtime = "Jugado (Horas)",
  stat_parkour_time = "Tiempo Mas Rápido En Parkour",
  stat_parkour_time_omm = "Tiempo Mas Rápido En Parkour (OMM)",
  stat_parkour_time_other = "Tiempo Mas Rápido En Parkour (Moveset)",

  -- placements
  place_1 = "\\#e3bc2d\\[64T: 1er Lugar]",
  place_2 = "\\#c5d8de\\[64T: 2do Lugar]",
  place_3 = "\\#b38752\\[64T: 3er Lugar]",
  place = "\\#e7a1ff\\[64T: %do Lugar]", -- thankfully we don't go up to 21
  place_score_1 = "%der",
  place_score_2 = "%ddo",
  place_score_3 = "%der",
  place_score = "%do",

  -- command descriptions
  page = "\\#ffff5a\\Página %d/%d", -- page for mariohunt command
  start_desc = "[CONTINUE|MAIN|ALT|RESET] - Inicia la partida; agrega \"continue\" para no ser enviado al principio; agrega \"alt\" para usar una ranura de guardado alternativa; agrega \"main\" para usar la ranura de guardado principal; agrega \"reset\" para reiniciar la ranura de guardado",
  add_desc = "[INT] - Agrega la cantidad especificada de Corredores de manera aleatoria",
  random_desc = "[INT] - Escoge la cantidad de Corredores",
  lives_desc = "[INT] - Ajusta la cantidad de vidas de los Corredores, de 0 a 99 (nota: 0 vidas es aún 1 vida)",
  time_desc = "[NUM] - Ajusta la cantidad de tiempo que deben esperar los Corredores para salir del nivel, en segundos",
  stars_desc = "[INT] - Ajusta la cantidad de estrellas que los Corredores deben recolectar para salir del nivel, de 0 a 7 (sólo en star mode)",
  category_desc = "[INT] - Ajusta la cantidad de estrellas que los Corredores deben recolectar para enfrentarse a Bowser.",
  flip_desc = "[NAME|ID] - Cambia el equipo del jugador especificado",
  setlife_desc = "[NAME|ID|INT,INT] - Ajusta las vidas especificadas para el Corredor especificado",
  leave_desc = "[NAME|ID] - Permite al jugador especificado, o a ti mismo, si no especificas a uno, abandonar el nivel si es un corredor.",
  mode_desc = "[NORMAL|SWAP|MINI] - Cambia el modo de juego; Swap cambia a los corredores cuando uno es eliminado",
  starmode_desc = "[ON|OFF] - Utiliza las estrellas recogidas en lugar del tiempo para que los Corredores puedan abandonar el nivel",
  spectator_desc = "[ON|OFF] - Permite a los Cazadores ser espectadores",
  pause_desc = "[NAME|ID|ALL] - Pausa a los jugadores especificados, o a todos si no especificas uno",
  hunter_app_desc = "Cambia la apariencia de los Cazadores.",
  runner_app_desc = "Cambia la apariencia de los Corredores.",
  hack_desc = "[STRING] - Selecciona el romhack actual",
  weak_desc = "[ON|OFF] - Reduce los Invincibility Frames a la mitad a todos los jugadores",
  auto_desc = "[ON|OFF|NUM] - Inicia la partida automaticamente",
  forcespectate_desc = "[NAME|ID|ALL] - Fuerza el modo espectador para este jugador o todos los jugadores",
  desync_desc = "- Intenta arreglar los errores causados por desync",
  stop_desc = "- Detén la partida",
  default_desc = "- Restablece la configuración a la predeterminada",
  blacklist_desc = "[ADD|REMOVE|LIST|RESET|SAVE|LOAD,COURSE,ACT] - Agrega estrellas a la Lista Negra en MiniHunt",
  stalking_desc = "[ON|OFF] - Permite ir al nivel en el que se encuentra un Corredor con /stalk",

  -- Blocky's menu
  main_menu = "Menu Principal",
  menu_mh = "MarioHunt",
  menu_mh_egg = "LuigiHunt",
  menu_settings_player = "Ajustes",
  menu_rules = "Reglas",
  menu_lang = "Idioma",
  menu_misc = "Otros",
  menu_stats = "Estadísticas",
  menu_back = "Volver",
  menu_exit = "Salir",

  menu_run_random = "Cantidad de Corredores",
  menu_run_add = "Agregar Corredores",
  menu_run_lives = "Vidas de los Corredores",
  menu_settings = "Ajustes del Juego",

  menu_start = "Iniciar",
  menu_stop = "Detener",
  menu_save_main = "Ranura de Guardado Principal",
  menu_save_alt = "Ranura Alternativa",
  menu_save_reset = "Reiniciar ranura alternativa",
  menu_save_continue = "Continuar (no eres enviado al principio)",
  menu_random = "Aleatoria",
  menu_campaign = "Campaña",

  menu_gamemode = "Modo de juego",
  menu_hunter_app = "Apariencia de los Cazadores",
  menu_runner_app = "Apariencia de los Corredores",
  menu_weak = "Modo débil",
  menu_allow_spectate = "Permitir Espectadores",
  menu_star_mode = "Modo de estrellas",
  menu_category = "Categoría",
  menu_time = "Tiempo",
  menu_stars = "Estrellas",
  menu_auto = "Juego automático",
  menu_blacklist = "Lista Negra de MiniHunt",
  menu_default = "Reiniciar",
  menu_defeat_bowser = "Derrota a %s",
  menu_allow_stalk = "Permitir 'Stalking'",

  menu_players_all = "Todos los jugadores",
  menu_flip = "Cambiar Equipo",
  menu_spectate = "Observar",
  menu_stalk = "Ir al nivel",
  menu_stalk_desc = "Ve al nivel de este jugador.",
  menu_pause = "Pausa",
  menu_forcespectate = "Forzar modo Espectador",
  menu_allowleave = "Permitir que salga del nivel",
  menu_setlife = "Ajustar vidas",

  menu_timer = "Cronómetro de Speedrun",
  menu_timer_desc = "[ON|OFF] - Muestra un cronómetro en la parte inferior de la pantalla en los modos estándar.",
  menu_tc = "Chat de equipo",
  menu_tc_desc = "Chatea sólo con tu equipo.",
  menu_demon = "Green Demon", -- referring to the 1-Up
  menu_demon_desc = "Un 1-Up te perseguirá cuando seas Corredor.",
  menu_unknown = "???",
  menu_secret = "Esto es un secreto. ¿Cómo se desbloquea?",
  menu_season = "Cambios de estación",
  menu_season_desc = "Divertidos cambios visuales según la fecha.",
  menu_radar = "Radar",
  menu_radar_desc = "Muestra adonde Corredores y objetos están en el mapa.",
  menu_minimap = "Mapa",
  menu_minimap_desc = "Muestra el mapa completo.",
  menu_romhack_cam = "Cámara romhack", -- -- (cam is short for camera)
  menu_romhack_cam_desc = "Activa la 'Cámara romhack' en todo momento.", -- -- (cam is short for camera)

  menu_free_cam_desc = "Usa la Cámara Libre en el modo Espectador.",
  menu_spectate_run = "Observar Corredor",
  menu_spectate_run_desc = "Automáticamente observarás al primer Corredor.",
  menu_exit_spectate = "Salir del modo Espectador",
  menu_exit_spectate_desc = "Saldrás del modo Espectador.",
  menu_stalk_run = "Ir al nivel del Corredor",
  menu_stalk_run_desc = "Ve al nivel en el que está el primer Corredor.",
  menu_skip = "Saltar",
  menu_skip_desc = "- Vota para saltar esta estrella en MiniHunt.",

  menu_spectate_desc = "Observa a este jugador.",

  menu_blacklist_list = "Lista Negra",
  menu_blacklist_list_desc = "Muestra todas las estrellas en la Lista Negra en MiniHunt de esta partida.",
  menu_blacklist_save = "Guardar Lista Negra",
  menu_blacklist_save_desc = "Guarda la Lista Negra sólo para ti.",
  menu_blacklist_load = "Cargar Lista Negra",
  menu_blacklist_load_desc = "Carga la Lista Negra guardada.",
  menu_blacklist_reset = "Reiniciar Lista Negra",
  menu_blacklist_reset_desc = "Reinicia la Lista Negra a los valores predeterminados.",
  menu_toggle_all = "Alternar todos",

  -- updater (difference for "_egg" is Luigi instead of Mario)
  up_to_date = "\\#00ffff\\Mario\\#ff5a5a\\Hunt\\#ffffff\\ está actualizado!",
  up_to_date_egg = "\\#5aff5a\\Luigi\\#ff5a5a\\Hunt\\#ffffff\\ está Actualizado!!",
  has_update = "Hay una actualización para \\#00ffff\\Mario\\#ff5a5a\\Hunt\\#ffffff\\!",
  has_update_egg = "Hay una actualización para \\#5aff5a\\Luigi\\#ff5a5a\\Hunt\\#ffffff\\!",

  -- unorganized
  lang_desc = "%s - Ajusta el lenguaje",
  got_all_stars = "¡Tienes las estrellas suficientes!",
  menu_hide_roles_desc = "Esconder tus Roles en el chat.",
  spectate_desc = "[NAME|ID|OFF] - Sé espectador del jugador especificado, cámara libre si no es especificado, o OFF para salir",
  tc_desc = "[ON|OFF|MSG] - Envía un mensaje únicamente a tu equipo; ON para aplicar a todos los mensajes",
  stars_in_area = "¡Hay %d estrella(s) sin recolectar(se) aquí!",
  role_cont = "\\#ff9696\\[Colaborador/a de MH]",
  role_trans = "\\#ffd996\\[Traductor/a de MH]",
  role_lead = "\\#9a96ff\\[Programadora Líder de MH]",
  menu_first_timer = "Temporizador de Muerte del Líder",
  menu_popup_sound = "Sonidos de mensajes emergentes",
  stalk_desc = "[NAME|ID] - Viaja al nivel del jugador que está especificado, o en el que se encuentra el primer corredor",
  menu_hide_roles = "Ocultar mis roles",
  open_menu = "Escribe /mh o presiona L + Start para abrir el menú",
  menu_nerf_vanish = "Nerfear Gorra de Invisibilidad",
  stat_placement = "Puesto en 64 Tour",
  menu_fast = "Acciones más rápidas",
  new_record = "\\#ffff5a\\¡¡¡LOGRASTE UN NUEVO RÉCORD!!!",
  anarchy_set_2 = "Los Cazadores ahora pueden atacar a sus compañeros de equipo",
  no_runners_added = "No se agregaron Corredores",
  menu_first_timer_desc = "Agrega al líder, en MiniHunt, un temporizador de muerte.",
  role_dev = "\\#96ecff\\[Programador/a de MH]",
  menu_nerf_vanish_desc = "Nerfea la gorra de invisibilidad haciéndola activable (con B) y se acaba más rápido cuando se usa.",
  unstuck = "Se reparó el nivel",
  menu_list_settings = "Lista de Ajustes",
  anarchy_set_3 = "Los jugadores ahora pueden atacar a sus compañeros de equipo",
  menu_fast_desc = "Te recuperarás, lanzarás objetos, y abrirás puertas más rápido.",
  menu_hide_hud = "Esconder la HUD",
  hidehud_desc = "- Esconde todos los elementos de la HUD.",
  dmgAdd_set = "Los corredores ahora tomarán %d daño extra de los ataques PVP.",
  hard_desc = "[EX|ON|OFF,ON|OFF] - Se activara el Modo Difícil para a ti",
  menu_dmgAdd = "Aumentar el daño hacia Corredor",
  menu_anarchy_desc = "Permite que el equipo especificado pueda atacarse entre sí.",
  rules_desc = "- Muestra las reglas de MarioHunt",
  rules_desc_egg = "Muestra las reglas de LuigiHunt!",
  menu_anarchy = "Fuego Amigo",
  mh_desc = "[COMMAND,ARGS] - Ejecuta comandos; escribe nada o \"menu\" para abrir el menú",
  vanish_custom = "¡Mantiene el botón \\#ffff5a\\B\\#ffffff\\ para volverte invisible!",
  menu_list_settings_desc = "Lista todos los ajustes para esta partida.",
  anarchy_set_1 = "Los Corredores ahora pueden atacar a sus compañeros de equipo",
  anarchy_set_0 = "Los jugadores ya no pueden atacar a sus compañeros de equipo",
  menu_dmgAdd_desc = "Agrega la cantidad de daño especificada contra los corredores.",
  mini_score = "Puntaje: %d",
  stats_desc = "- Muestra/Oculta la tabla de estadísticas",

  -- v2.5
  target_desc = "[NAME|ID] - Coloca a este Corredor como tu objetivo, lo que revela su posición en todo momento.",
  use_out = "Usa /mh out para expulsar a todos fuera de este nivel",

  you_are_muted = "Estas silenciado",

  dmgAdd_set_ohko = "Ahora todos los corredores moriran de un solo golpe",
  voidDmg_set = "los jugadores tomaran %d daño cayendo al vacio o a arenas movedizas.",
  voidDmg_set_ohko = "Los jugadores seran instantaneamente muertos al vacio o a las arenas movedizas.",
  target_hunters_only = "Sólo los cazadores puede los corredores como objetivo.",

  muted = "\\#ffff00\\%s\\#ffffff\\ fue silenciado por \\#ffff00\\%s\\#ffffff\\.",
  unmuted = "\\#ffff00\\%s\\#ffffff\\ fue desilenciado por \\#ffff00\\%s\\#ffffff\\.",
  you_muted = "Fuiste silenciado \\#ffff00\\%s\\#ffffff\\.",
  you_unmuted = "Fuiste desilenciado \\#ffff00\\%s\\#ffffff\\.",
  mute_auto = "\\#ffff00\\%s\\#ffffff\\ fue silenciado automaticamente",

  mute_desc = "[NAME|ID] - Silencia a un jugador, impidiendole poder chatear",
  unmute_desc = "[NAME|ID] - Desilencia a un jugador, permitiendole chatear de nuevo",
  out_desc = "- Expulsa a todos los jugadores de este nivel",

  menu_countdown = "Temporizador",
  menu_countdown_desc = "Que tanto deben esperar los Corredores antes de comenzar.",
  menu_voidDmg = "Daño del Vacío",
  menu_voidDmg_desc = "Daño infligido a los jugadores que caen al vacío o arenas movedizas.",
  menu_double_health = "Multiplicar la Barra de Vida del Corredor",
  menu_double_health_desc = "El Corredor obtiene 16 puntos de vida, en vez de 8.",

  -- v2.6
  menu_free_roam = "Movimiento Libre",
  menu_free_roam_desc = "Desactiva el requisito de estrellas y llaves para ciertas puertas y los demás niveles.",

  menu_target = "Colocar como Objetivo",
  menu_mute = "Silenciar",

  menu_invinc_particle = "I-Frames Brillantes", -- (I-Frames is short for invincibility/invulnerability frames) 
  menu_invinc_particle_desc = "Reemplaza el efecto \"parpadeante\" cuando Mario recibe daño con partículas Brillantes.",
  menu_stalk_timer = "Cooldown para 'Stalk'",
  menu_stalk_timer_desc = "Tiempo que el jugador es congelado luego de usar /stalk.",
  menu_star_heal = "Curación de Estrellas",

  -- v2.6.1
  menu_star_setting = "Al conseguir una estrella", -- from base coop
  star_leave = "Salir",
  star_stay = "Seguir",
  star_nonstop = "Sin Parar",

  -- tips
  tip = "Consejo: ",
  tip_1 = "¡Presiona L + Start, o escribe /mh, para abrir el menú. Puedes configurar opciones aquí!",
  tip_2 = "Los Ground pounds hacen 3 de daño a los otros jugadores.",
  tip_3 = "¡Una patada puede hacer 2 de daño y sacar a jugadores volando!",
  tip_4 = "Para ciertos comandos como /spectate y /target, puedes escribir los nombres parcialmente y seguiran funcionando. (ej: colocando \"Emily\" se referirá a EmilyEmmi)",
  tip_5 = "Puedes cambiar configuraciones en mitad de una partida desde el menú.",
  tip_6 = "Si algo sale mal, escribe /mh pause para pausar a todos los jugadores. Escribelo de nuevo para despausar a todos.",
  tip_7 = "¿Hay alguien saturando el chat o siendo grosero? ¡Utiliza /mh mute para silenciarlos!",
  tip_8 = "Puedes pausar el juego antes de recolectar una estrella o llave y darle a Exit Course para saltar la animación.",
  tip_9 = "Puedes seleccionar a un corredor como tu objetivo con /target. Esto revelará su ubicación en la parte superior de tu pantalla.",
  tip_10 = "Puedes configurar opciones personales en el menú (L + Start).",
  tip_11 = "¡No necesitas reiniciar el servidor! Selecciona \"Reiniciar ranura alternativa\" en \"Inicio\" para reiniciar todo el progreso.",
  tip_12 = "Puedes obtener el rol de Corredor al eliminar un Corredor.",
  tip_13 = "Como en Mario 64 vanilla, 0 vidas todavía cuentan como una vida.",
  tip_14 = "Muchos glitches, tales como el LBLJ, son inútiles fuera de Any%.",
  tip_15 = "¡Los carteles en juego pueden contener consejos útiles!",
  tip_16 = "Dire Dire Docks puede ser ingresado con una estrella menos que la categoria actual.",
  tip_17 = "Pon a Cappy en \"Damage\" para usarlo como un arma de rango. Él quita 1 de daño.",
  tip_18 = "Cappy puede recoger objetos, tales como Monedas y Secretos.",
  tip_19 = "Usa el D-Pad para lanzar a Cappy en diferentes direcciones.",
  tip_20 = "¡Mira el video de Key's Artwork en YouTube para aprender acerca de tecnología OMM!",
  tip_21 = "Si los objetos en un nivel empiezan a desaparecer o los teletransportes no funcionan, utiliza /mh out en ese nivel para forcar al nivel a recargarse.",
  tip_22 = "Utiliza /mh desync si tu piensas que ocurrió un error de desincronización.",
  tip_23 = "Matar a otro jugador puede restaurar toda tu vida.",
  tip_24 = "Puedes ver el progreso en llaves, gorros, y escenarios secretos en el menú de Pausa en el castillo.",
  tip_25 = "¡Los Corredores se pueden lastimar uno al otro en este modo!",
  tip_26 = "Caerse en los escenarios de gorros cuenta como perder una vida.",
  tip_27 = "Los interruptores de monedas Azules reaparecen.",
  tip_28 = "Puedes escoger otro acto para escabullirte de los Cazadores.",
  tip_29 = "¡Es una Celebración! Si no te gustan los efectos, deshabilitalos con \"Cambios de estación\" en el menú.",
  tip_30 = "Puedes espiar a los Corredores con /spectate.",
  tip_31 = "¡Utiliza /stalk para teletransportarte al nivel en el que se encuentra otro Corredor!",
  tip_32 = "Aprender técnicas de speedrunning es una buena manera para mejorar tu juego.",
  tip_33 = "Puedes atravesar Whomps mediante ground-pounding o patear mientras caen.",
  tip_34 = "La mejor manera de realizar un Salto Triple es mediante patear para el primer salto.",
  tip_35 = "La forma Metal hace el doble de daño a tus oponentes.",
  tip_36 = "La Gorra de Invisibilidad solo tendrá efecto cuando se mantiene el botón B.",
  tip_37 = "Los temporizadores de gorros no se gastan mientras estés en un cañón.",
  tip_38 = "¡No te quedes demasiado tiempo en el Selector de Actos!",
  tip_39 = "Las Zambullidas son rápidas, y zambullirse hacía otro jugador puede ayudarte a evadir ataques.",
  tip_40 = "Caerte de lugares altos puede quitarte vida en vez de matarte instantaneamente.",
  tip_41 = "Los 1-Ups van a restaurar toda tu vida.",
  tip_42 = "Utiliza el menú de Jugadores para comandos que se centran en un jugador específico, como cambiar equipos.",
  tip_43 = "El menú de MarioHunt te permite comenzar partidas y configurar ajustes del juego.",
  tip_44 = "Puedes esconder tu rol de chat en Ajustes.",
  tip_45 = "Los Corredores que visten el Gorro de Metal pueden aún ser dañados por los Cazadores.",
  tip_46 = "¡En el menú, asegurate de presionar A para guardar tus ajustes cambiados!",
}

langdata["de"] = -- by N64 Mario
{
  -- fullname for auto select
  fullname = "German",

  -- name in the built-in menu
  name_menu = "Deutsch",

  -- global command info
  to_switch = "Gebe \"/lang %s\" ein, um die Sprache zu wechseln",
  switched = "Auf Deutsch umgestellt!",
  rule_command = "Gebe /rules ein, um diese Nachricht erneut anzuzeigen",

  -- roles
  runner = "Läufer",
  runners = "Läufer",
  short_runner = "Run",
  hunters = "Jäger",
  hunter = "Jäger",
  spectator = "Zuschauer",
  player = "Spieler",
  players = "Spieler", -- Is this correct?

  -- rules
  welcome = "Wilkommen zu \\#00ffff\\Mario\\#ff5a5a\\Hunt\\#ffffff\\! WIE MAN SPIELT:",
  welcome_mini = "Wilkommen zu \\#ffff5a\\Mini\\#ff5a5a\\Hunt\\#ffffff\\! WIE MAN SPIELT:",
  welcome_egg = "Wilkommen zu \\#5aff5a\\Luigi\\#ff5a5a\\Hunt\\#ffffff\\! WIE MAN SPIELT:",
  all_runners = "Besiege alle \\#00ffff\\Läufer\\#ffffff\\.",
  any_runners = "Besiege alle \\#00ffff\\Läufer\\#ffffff\\.",
  shown_above = "(oben gezeigt)",
  any_bowser = "Besiege %s, \\#ffff5a\\egal durch welcher Art und Weise.\\#ffffff\\",
  collect_bowser = "Sammle \\#ffff5a\\%d Stern(e)\\#ffffff\\ und besiege %s.",
  mini_collect = "Sei der Erste, der \\#ffff5a\\einen Stern sammelt\\#ffffff\\.",
  collect_only = "Sammle \\#ffff5a\\%d Stern(e)\\#ffffff\\.",
  thats_you = "(das bist du!)",
  banned_glitchless = "NEIN: Cross-Teaming, BLJs, durch Wände clippen, hinhalten, camping.",
  banned_general = "NEIN: Cross-Teaming, stalling, camping.",
  time_needed = "%d:%02d um jeden Hauptkurs zu verlassen; Sammle Sterne zum Verringern",
  stars_needed = "%d Stern(e) werden benötigt, um jeden Hauptkurs zu verlassen",
  become_hunter = "werde \\#ff5a5a\\Jäger\\#ffffff\\, wenn du besiegt wirst",
  become_runner = "Besiege einen \\#00ffff\\Läufer\\#ffffff\\, um einer zu werden",
  infinite_lives = "Unendlich viele Leben",
  spectate = "gebe \"/spectate\" ein, um zuzuschauen",
  mini_goal = "\\#ffff5a\\Wer auch immer die meisten Sterne in %d:%02d sammelt, gewinnt\\#ffffff\\",
  fun = "Viel Spaß!",

  -- hud, extra desc, and results text
  win = "%s\\#ffffff\\ haben gewonnen!",
  can_leave = "\\#5aff5a\\Kurs kann verlassen werden",
  cant_leave = "\\#ff5a5a\\Kurs kann nicht verlassen werden",
  time_left = "Kannst in \\#ffff5a\\%d:%02d\\#ffffff\\ verlassen",
  stars_left = "Brauchst \\#ffff5a\\%d Stern(e)\\#ffffff\\ um zu verlassen",
  in_castle = "Im Schloss",
  until_hunters = "%d Sekunde(n) bis die \\#ff5a5a\\Jäger\\#ffffff\\ beginnen",
  until_runners = "%d Sekunde(n) bis die \\#00ffff\\Läufer\\#ffffff\\ beginnen",
  lives_one = "1 Leben",
  lives = "%d Leben",
  stars_one = "1 Stern",
  stars = "%d Sterne",
  no_runners = "Keine \\#00ffff\\Läufer!",
  camp_timer = "Weiter bewegen! \\#ff5a5a\\(%d)",
  game_over = "Das Spiel ist vorbei!",
  winners = "Gewinner: ",
  no_winners = "\\#ff5a5a\\Keine Gewinner!",
  on = "\\#5aff5a\\AN",
  off = "\\#ff5a5a\\AUS",
  frozen = "Eingefroren für %d",

  -- popups
  lost_life = "%s\\#ffa0a0\\ hat einen Leben verloren!",
  lost_all = "%s\\#ffa0a0\\ hat ihr ganzes Leben verloren!",
  now_role = "%s\\#ffa0a0\\ ist jetzt ein %s\\#ffa0a0\\.",
  got_star = "%s\\#ffa0a0\\ hat einen Stern bekommen!",
  got_key = "%s\\#ffa0a0\\ hat einen Schlüssel bekommen!",
  rejoin_start = "%s\\#ffa0a0\\ hat zwei Minuten um erneut beizutreten.",
  rejoin_success = "%s\\#ffa0a0\\ ist das Spiel pünktlich erneut beigetreten!",
  rejoin_fail = "%s\\#ffa0a0\\ ist nicht in Zeit beigetreten.",
  using_ee = "Dies verwendet nur die Extreme Edition.",
  not_using_ee = "Dies verwendet nur die Standard Version.",
  killed = "%s\\#ffa0a0\\ hat %s getötet!",
  sidelined = "%s\\#ffa0a0\\ hat %s erledigt!",
  paused = "Du wurdest pausiert.",
  unpaused = "Du bist nicht mehr pausiert.",
  kill_combo_2 = "%s\\#ffa0a0\\ hat einen \\#ffff5a\\doppelten\\#ffa0a0\\ Kill!",
  kill_combo_3 = "%s\\#ffa0a0\\ hat einen \\#ffff5a\\dreifachen\\#ffa0a0\\ Kill!",
  kill_combo_4 = "%s\\#ffa0a0\\ hat einen \\#ffff5a\\vierfachen\\#ffa0a0\\ Kill!",
  kill_combo_5 = "%s\\#ffa0a0\\ hat einen \\#ffff5a\\fünffachen\\#ffa0a0\\ Kill!",
  kill_combo_large = "\\#ffa0a0\\Wow! %s\\#ffa0a0\\ hat \\#ffff5a\\%d\\#ffa0a0\\ Kills in Folge!",
  set_hack = "Hack auf %s eingestellt",
  incompatible_hack = "WARNUNG: Dieser Hack ist nicht kompatibel!",
  vanilla = "Das Vanilla-Spiel wird verwendet",
  omm_detected = "OMM Rebirth wurde detektiert!",
  omm_bad_version = "\\#ff5a5a\\OMM Rebirth ist veraltet!\\#ffffff\\nMindestversion: %s\nDeine Version: %s",
  custom_enter = "%s\\#ffffff\\ ist beigetreten bei\n%s", -- same as coop
  hit_switch_red = "%s drückte den\n\\#df5050\\Roten Schalter!",
  hit_switch_green = "%s drückte den\n\\#50b05a\\Grünen Schalter!",
  hit_switch_blue = "%s drückte den\n\\#5050e3\\Blauen Schalter!",
  hit_switch_yellow = "%s drückte den\n\\#e3b050\\Gelben Schalter...",
  use_out = "Benutze /mh out, um alle aus diesem Level zu warpen",

  -- command feedback
  not_mod = "Du hast nicht die BERECHTIGUNG diesen Befehl auszuführen.",
  no_such_player = "Es gibt nicht so einen Spieler",
  bad_id = "Ungültige Spieler ID!",
  command_disabled = "Dieser Befehl ist deaktiviert.",
  change_setting = "Einstellungsänderung:",
  you_are_muted = "Du bist stummgeschaltet.",

  -- more command feedback
  bad_param = "Ungültige Parameter!",
  bad_command = "Ungültiger Command!",
  error_no_runners = "Spiel kann nicht mit 0 Läufer gestartet werden!",
  set_team = "%s's Team wurde auf '%s' eingestellt", -- First %s is player name, second is team name
  not_started = "Das Spiel hat noch nicht begonnen",
  set_lives_one = "%s hat nun einen Leben",
  set_lives = "%s hat nun %d Leben",
  not_runner = "%s ist kein Läufer",
  may_leave = "%s darf verlassen",
  must_have_one = "Es muss mindestens ein Jäger vorhanden sein",
  added = "Hinzugefügte Läufer: ", -- list comes afterward
  runners_are = "Die Läufer sind: ",
  set_lives_total = "Die Leben des Läufers ist eingestellt zu %d",
  wrong_mode = "Nicht verfügbar in diesem Modus",
  need_time_feedback = "Läufer können jetzt in %d Sekunden(n) verlassen",
  game_time = "Spiel dauert jetzt %d Sekunde(n)",
  need_stars_feedback = "Läufer brauchen jetzt %d Stern(e)",
  new_category = "Das ist jetzt ein %d Sterne run",
  new_category_any =  " Das ist jetzt ein any% run",
  mode_normal = "Im Normalmodus",
  mode_swap = "Im Swap-Modus",
  mode_mini = "Im MiniHunt-Modus",
  using_stars = "Sterne erforderlich wird verwendet",
  using_timer = "Timer wird verwendet",
  can_spectate = "Jäger können jetzt zuschauen",
  no_spectate = "Jäger können nicht mehr zuschauen",
  all_paused = "Alle Spieler sind pausiert",
  all_unpaused = "Alle Spieler sind nicht mehr pausiert",
  player_paused = "%s wurde pausiert",
  player_unpaused = "%s ist nicht mehr pausiert",
  hunter_metal = "Alle Jäger sind Metall",
  hunter_normal = "Alle Jäger sehen normal aus",
  hunter_glow = "All Jäger glühen rot",
  runner_normal = "Alle Läufer sehen normal aus",
  now_weak = "Alle Spieler haben Halbunbesiegbarkeitsrahmen",
  not_weak = "Alle Spieler haben normale Unbesiegbarkeitsrahmen",
  auto_on = "Spiele werden automatisch starten",
  auto_off = "Spiele werden nicht automatisch starten",

  -- team chat
  tc_toggle = "Team chat ist %s!",
  to_team = "\\#8a8a8a\\zu Team: ",
  from_team = "\\#8a8a8a\\ (Team): ",

  -- hard mode
  hard_notice = "Psst, tippe /hard...",
  extreme_notice = "Psst, tippe /hard ex...",
  hard_toggle = "\\#ff5a5a\\Harter Modus\\#ffffff\\ ist %s!",
  extreme_toggle = "\\#b45aff\\Extrem Modus\\#ffffff\\ ist %s!",
  hard_info = "Interessiert am \\#ff5a5a\\Harten Modus\\#ffffff\\?"..
  "\n- Hälfte des Lebens"..
  "\n- Wasser heilt nicht"..
  "\n- \\#ff5a5a\\Ein Leben"..
  "\n\\#ffffff\\Tippe /hard ON wenn sie für die Herausforderungen bereit sind.",
  hard_mode = "Harter Modus",
  extreme_mode = "Extrem Modus",
  hard_info_short = "Hälfte des Powermeters, Wasser heilt nicht und nur ein Leben.",
  extreme_info_short = "Einen Schadenspunkt, einen Leben und Todestimer.",

  -- spectator
  hunters_only = "Nur Jäger können zuschauen!",
  spectate_disabled = "Zuschauermodus ist deaktiviert!",
  timer_going = "Kann während des Timers nicht zuschauen!", -- now unused
  spectate_self = "Du kannst dich nicht selber zuschauen!",
  spectator_controls = "Steuerung:"..
  "\nDPAD-UP: HUD ausschalten"..
  "\nDPAD-DOWN: Freecam/Spieleransicht tauschen"..
  "\nDPAD-LEFT / DPAD-RIGHT: Spieler wechseln"..
  "\nJOYSTICK: Bewegen"..
  "\nA: Geh hoch"..
  "\nZ: geh runter"..
  "\nType \"/spectate OFF\" um abzubrechen",
  spectate_off = "Nicht mehr am zuschauen.",
  empty = "LEER (%d )",
  free_camera = "FREIE KAMERA",

  -- stats
  disp_wins_one = "%s\\#ffffff\\ hat 1 mal als \\#ffff5a\\Läufer\\#ffffff\\ gewonnen!",
  disp_wins = "%s\\#ffffff\\ hat %d mal als \\#ffff5a\\Läufer\\#ffffff\\ gewonnen!",
  disp_kills_one = "%s\\#ffffff\\ hat einen Spieler getötet!", -- unused
  disp_kills = "%s\\#ffffff\\ hat %d Spieler getötet!",
  -- for stats table
  stat_wins_standard = "Siege",
  stat_wins = "Siege (Minihunt/vor v2.3)",
  stat_kills = "Kills",
  stat_combo = "Max Kill Streak",
  stat_wins_hard_standard = "Siege (Harter Modus)",
  stat_wins_hard = "Siege (Harter Modus, Minihunt/vor v2.3)",
  stat_mini_stars = "Maximale Sterne in einem Minihunt",
  stat_wins_ex_standard = "Siege (Extrem Modus)",
  stat_wins_ex = "Siege (Extrem Modus, Minihunt/vor v2.3)",

  -- placements
  place_1 = "\\#e3bc2d\\[64T: Platz 1]",
  place_2 = "\\#c5d8de\\[64T: Platz 2]",
  place_3 = "\\#b38752\\[64T: Platz 3]",
  place = "\\#e7a1ff\\[64T: Platz %d]", -- thankfully we don't go up to 21
  place_score_1 = "%d",
  place_score_2 = "%d",
  place_score_3 = "%d",
  place_score = "%d",

  -- command descriptions
  start_desc = "[CONTINUE|MAIN|ALT|RESET] - Startet das Spiel; Fügen sie \"continue\" hinzu, um um nicht zum Anfang teleportiert zu werden; Fügen sie \"alt\" hinzu, für einen Alternativen Speicherstand; Fügen sie \"main\" hinzu, für die Hauptspeicher Datei füge \"reset\" hinzu, um den Speicherstand zurückzusetzen",
  add_desc = "[INT] - fügt die spezifische Anzahl an Läufern nach dem Zufallsprinzip hinzu",
  random_desc = "[INT] - wählt zufällig eine bestimmte Anzahl an Läufern aus",
  lives_desc = "[INT] - Legt die Anzahl der Leben fest, die Läufer haben, von 0 zu 99 (Notiz: 0 Leben ist immer noch 1 Leben)",
  time_desc = "[NUM] - Legt fest, wie lange Läufer maximal warten müssen, bis sie verlassen können, in Sekunden",
  stars_desc = "[INT] - Legt die maximale Anzahl an Sternen fest, die Läufer sammeln müssen, um verlassen zu können, from 0 to 7 (only in star mode)",
  category_desc = "[INT] - Legt die Anzahl der Sterne fest, die Läufer haben müssen, um gegen Bowser anzutreten.",
  flip_desc = "[NAME|ID] - Dreht das Team des angegebenen Spielers um",
  setlife_desc = "[NAME|ID|INT,INT] - Legt die angegebenen Leben für den angegebenen Läufer",
  leave_desc = "[NAME|ID] - Ermöglicht dem angegebenen Spieler, das Level zu verlassen, wenn die Person ein Läufer ist",
  mode_desc = "[NORMAL|SWAP|MINI] - Ändert den Spielmodus; swap ändert den Läufer wenn einer stirbt",
  starmode_desc = "[ON|OFF] - Schaltet die gesammelten Sterne anstelle der Zeit um",
  spectator_desc = "[ON|OFF] - Schaltet die Fähigkeit von Jägern, zuzuschauen",
  pause_desc = "[NAME|ID|ALL] - Schaltet den Pausenstatus für bestimmte Spieler um, oder für alle, wenn nicht angegeben",
  hunter_app_desc = "Verändert das Aussehen von Jägern.",
  runner_app_desc = "Verändert das Aussehen von Läufern.",
  hack_desc = "[STRING] - Legt den aktuellen Rom Hack fest",
  weak_desc = "[ON|OFF] - Halbiert die Unbesiegbarkeitsrahmen für alle Spieler",
  auto_desc = "[ON|OFF] - Startet Spiele automatisch",
  stalking_desc = "[ON|OFF] - Erlaube auf das Level, bei dem sich der Läufer befindet mit /stalk zu warpen",
  hidehud_desc = "- Verstecke alle HUD Elemente.",
  mute_desc = "[NAME|ID] - Mutes a player, preventing them from chatting",
  unmute_desc = "[NAME|ID] - Unmutes a player, allowing them to chat again",
  out_desc = "- Kicks everyone out of this level",

  -- mute
  muted = "\\#ffff00\\%s\\#ffffff\\ wurde von \\#ffff00\\%s\\#ffffff\\ stummgeschaltet.",
  unmuted = "Die Stummschaltung von \\#ffff00\\%s\\#ffffff\\ wurde von \\#ffff00\\%s\\#ffffff\\ aufgehoben.",
  you_muted = "Du hast \\#ffff00\\%s\\#ffffff\\ stummgeschaltet.",
  you_unmuted = "Du hast die Stummschaltung von \\#ffff00\\%s\\#ffffff\\ aufgehoben.",
  mute_auto = "\\#ffff00\\%s\\#ffffff\\ wurde automatisch stummgeschaltet.",

  -- Blocky's menu
  main_menu = "Hauptmenü",
  menu_settings = "Spieleinstellungen",
  menu_settings_player = "Einstellungen",
  menu_rules = "Regeln",
  menu_lang = "Sprache",
  menu_misc = "Sonstiges",
  menu_exit = "Verlassen",
  menu_back = "Zurück",
  menu_stats = "Statistiken",
  menu_timer = "Speedrun-Timer",
  menu_run_random = "Läufer zufällig auswählen",
  menu_run_add = "Läufer hinzufügen",
  menu_run_lives = "Läuferleben",
  menu_mh = "MarioHunt",
  menu_mh_egg = "LuigiHunt",
  menu_gamemode = "Spielmodus",
  menu_stars = "Sterne",
  menu_defeat_bowser = "Besiege %s",
  menu_allow_stalk = "'Stalking' erlauben",
  menu_season = "Ändert die Jahreszeit",
  menu_season_desc = "Lustige visuelle Veränderungen je nach Datum.",
  menu_countdown = "Countdown",
  menu_countdown_desc = "Wie lange Jäger warten müssen, bevor sie beginnen können.",
  menu_voidDmg = "Abgrund Schaden",
  menu_voidDmg_desc = "Schaden, der Spielern zugefügt wird, die in den Abgrund oder Treibsand fallen.",
  menu_double_health = "Doppel Läufer Leben",
  menu_double_health_desc = "Läufer erhalten 16 statt 8 Schadenspunkte.",
  menu_target = "Als Ziel festlegen",
  menu_mute = "Stummschalten",

  -- updater (difference for "_egg" is Luigi instead of Mario)
  up_to_date = "\\#00ffff\\Mario\\#ff5a5a\\Hunt\\#ffffff\\ ist auf dem neuesten Stand!",
  up_to_date_egg = "\\#5aff5a\\Luigi\\#ff5a5a\\Hunt\\#ffffff\\ ist auf dem neuesten Stand!",
  has_update = "Ein Update ist verfügbar für \\#00ffff\\Mario\\#ff5a5a\\Hunt\\#ffffff\\!",
  has_update_egg = "Ein Update ist verfügbar für \\#5aff5a\\Luigi\\#ff5a5a\\Hunt\\#ffffff\\!",

  -- unsorted
  lang_desc = "%s - Sprache wechseln",
  got_all_stars = "Du hast genug Sterne!",
  spectate_mode = "- ZUSCHAUER MODUS -",
  menu_allow_spectate = "Zuschauen Erlauben",
  menu_hide_roles_desc = "Versteck deine Rolle vom Anzeigen im Chat.",
  menu_stop = "Stopp",
  spectate_desc = "[NAME|ID|OFF] - Schaue den angegeben Spieler zu, freie Kamera falls nicht angegeben, oder OFF um es auszuschalten",
  menu_stalk_run = "Warp zum Läufer Level",
  stop_desc = "- Stoppe das Spiel",
  menu_star_mode = "Stern Modus",
  tc_desc = "[ON|OFF|MSG] - Sende eine Nachricht nur zum Team; Anmachen mit \"ON\" um es auf alle Nachrichten anzuwenden",
  stars_in_area = "%d Stern(e) sind hier verfügbar!",
  force_spectate_one = "%s muss zuschauen",
  role_cont = "\\#ff9696\\[MH Mitwerkender]",
  menu_demon_desc = "Lass dich als Läufer von einem 1-Up gejagt werden.",
  vote_pass = "Die Abstimmung hat bestanden!",
  extreme_info = "Fühlst du dich vom \\#b45aff\\Extrem Modus\\#ffffff\\ angezogen? Wie albern.\
  - Ein Leben\
  - Einen Powermeter\
  - \\#b45aff\\Todestimer\\#ffffff\\; sammle Münzen und Sterne um es zu steigern\
  Wenn dir das keine Angst macht, tippe /hard ex ON ein.",
  role_trans = "\\#ffd996\\[MH Übersetzer]",
  desync_desc = "- Versucht Desynchonisierungsfehler zu beheben",
  role_lead = "\\#9a96ff\\[Leitender MH Entwickler]",
  menu_first_timer = "Führer Todestimer",
  menu_popup_sound = "Popup-Sounds",
  stalk_desc = "[NAME|ID] - Warpt dich zu das Level, in dem sich der angegebene Spieler ist, oder zum ersten Läufer",
  blacklist_add = "%s wurde zur schwarzen Liste hinzugefügt",
  menu_hide_roles = "Verstecke meine Rollen",
  open_menu = "Geben Sie /mh ein oder drücke L + Start um das Menü zu öffnen",
  menu_nerf_vanish = "Schwächere die Unsichbarkeits Kappe",
  forcespectate_desc = "[NAME|ID|ALL] - Schalte das Erzwingen des Zuschauens für diesen Spieler oder für alle Spieler um",
  stalk = "Benutze /stalk um zum Läufer zu warpen!",
  menu_category = "Kategorie",
  stat_placement = "64 Tour Platzierung",
  menu_fast = "Schnellere Aktionen",
  default_desc = "- Einstellungen zurücksetzen",
  new_record = "\\#ffff5a\\NEUER REKORD!!!",
  anarchy_set_2 = "Jäger können ihre Mitspieler attackieren",
  menu_skip = "Überspringen",
  menu_stalk_run_desc = "Warp auf das Level, in dem sich der erste Läufer befindet.",
  no_runners_added = "Keine Läufer hinzugefügt",
  menu_exit_spectate_desc = "Zuschauermodus verlassen.",
  menu_flip = "Team wechseln",
  menu_first_timer_desc = "Gibt den Führer in MiniHunt einen Todestimer.",
  menu_save_continue = "Fortsetzen (kein zurück warpen)",
  menu_start = "Start",
  role_dev = "\\#96ecff\\[MH Entwickler]",
  menu_nerf_vanish_desc = "Verschlechtert die Unsichtbarkeits Kappe, indem sie umschaltbar gemacht wird und bei Verwendung schneller entleert wird.",
  menu_blacklist_list_desc = "Listet alle auf der schwarzen Liste stehenden Sterne in MiniHunt für diesen Server auf.",
  menu_pause = "Pause",
  menu_players_all = "Alle Spieler",
  menu_hunter_app = "Aussehen von Jägern",
  menu_runner_app = "Aussehen von Läufern",
  menu_toggle_all = "Alles umschalten",
  menu_blacklist_reset_desc = "Setzt die schwarze Liste auf den Standard zurück.",
  unstuck = "Es wurde versucht den aktuellen Zustand zu beheben",
  menu_blacklist_load = "Schwarze Liste laden",
  menu_blacklist_load_desc = "Laden Sie ihre gespeicherte schwarze Liste.",
  menu_blacklist_reset = "Schwarze Liste zurücksetzen",
  menu_blacklist_save_desc = "Speicher diese schwarze Liste auf ihrer Seite.",
  menu_blacklist_save = "Schwarze Liste speichern",
  menu_blacklist_list = "Alles auf der schwarze Liste auflisten",
  menu_spectate_desc = "Diesen Spieler zuschauen",
  menu_skip_desc = "- Stimme ab, um diesen Stern in MiniHunt zu überspringen.",
  menu_exit_spectate = "Zuschauen Verlassen",
  menu_spectate_run_desc = "Der erste Läufer wird automatisch zugeschaut.",
  menu_list_settings = "Einstellungen auflisten",
  menu_spectate_run = "Läufer zuschauen",
  anarchy_set_3 = "Spieler können ihre Mitspieler attackieren",
  menu_free_cam_desc = "Aktiviere die freie Kamera im Zuschauermodus.",
  menu_fast_desc = "Man wirft Gegenstände und öffnet Türen schneller.",
  menu_secret = "Das ist ein Geheimnis. Wie schaltet man es frei?",
  menu_hide_hud = "Verstecke alle HUD Elemente",
  menu_stalk = "Warpe zum Level",
  dmgAdd_set = "Läufer nehmen jetzt %d zusätzlichen Schaden durch PvP-Angriffe.",
  hard_desc = "[EX|ON|OFF,ON|OFF] - Schalte den Harter Modus für Sie selbst um",
  menu_tc = "Team-Chat",
  is_spectator = "* SPIELER IST EIN ZUSCHAUER  *",
  menu_setlife = "Leben setzen",
  menu_allowleave = "Erlauben zu verlassen",
  menu_forcespectate = "Zuschauen erzwingen",
  menu_stalk_desc = "Warp auf das Level dieses Spielers.",
  menu_demon = "Green Demon",
  menu_spectate = "Zuschauen",
  force_spectate_off = "Zuschauen ist nicht mehr erzwungen",
  menu_dmgAdd = "Läufer MVP Schaden erhöht",
  menu_anarchy_desc = "Ermöglicht den angegebenen Teams, ihre Mitspieler anzugreifen.",
  rules_desc = "- Zeigt MarioHunt Regeln",
  rules_desc_egg = "- Zeigt LuigiHunt Regeln",
  menu_anarchy = "Teamangriff",
  menu_blacklist = "MiniHunt schwarze Liste",
  mh_desc = "[COMMAND,ARGS] - Führt Befehle aus; Geben Sie nichts oder „Menü“ ein, um das Menü zu öffnen",
  blacklist_list = "Schwarze Liste:",
  menu_auto = "Auto Spiel",
  menu_weak = "Schwacher Modus",
  menu_campaign = "Kampagne",
  menu_random = "Zufällig",
  menu_save_reset = "Alternativen Speicherstand zurücksetzen",
  vanish_custom = "Halte \\#ffff5a\\B\\#ffffff\\ um Unsichtbar zu werden!",
  menu_save_main = "Haupt",
  menu_timer_desc = "[ON|OFF] - In den Standardmodi wird unten auf dem Bildschirm ein Timer angezeigt.",
  menu_list_settings_desc = "Listet alle Einstellungen für diese Lobby auf.",
  blacklist_reset = "Die schwarze Liste zurücksetzen!",
  all = "Alle",
  blacklist_desc = "[ADD|REMOVE|LIST|RESET|SAVE|LOAD,COURSE,ACT] - Sterne auf die schwarze Liste setzen in MiniHunt",
  blacklist_remove = "%s steht auf der weißen Liste",
  page = "\\#ffff5a\\Seite %d/%d",
  menu_default = "Auf Standardeinstellung zurücksetzen",
  anarchy_set_1 = "Läufer können ihre Mitspieler attackieren",
  blacklist_remove_already = "Dieser Stern oder dieses Level steht nicht auf der schwarzen Liste.",
  force_spectate = "Jeder muss zuschauen",
  menu_save_alt = "Alternativer Speicherstand",
  menu_tc_desc = "Rede nur mit deinem Team.",
  already_voted = "Du hast bereits abgestimmt.",
  vote_info = "Geben Sie /skip ein, um abzustimmen",
  vote_skip = "%s\\#dcdcdc\\ hat dafür gestimmt, diesen Stern zu überspringen",
  blacklist_remove_invalid = "Dieser Stern oder dieses Level kann nicht auf die weiße Liste gesetzt werden.",
  no_hard_win = "Ihr Punktestand für Harte Siege oder Extrem Siege wird für dieses Spiel nicht aktualisiert.",
  death_timer = "Tod",
  blacklist_add_already = "Dieser Stern oder dieses Level ist bereits auf der schwarze Liste.",
  anarchy_set_0 = "Spieler können nicht ihre Mitspieler attackieren",
  menu_dmgAdd_desc = "Füge so viel Schaden zum Angriff gegen Läufer hinzu.",
  no_valid_star = "Konnte nicht einen gültigen Stern finden!",
  warp_spam = "Langsam mit den Warps!",
  mini_score = "Punktzahl: %d",
  stats_desc = "- Statistiktabelle ein-/ausblenden",
  force_spectate_one_off = "%s muss nicht mehr zuschauen",
  menu_time = "Zeit",
  blacklist_save = "Schwarze Liste gespeichert!",
  blacklist_load = "Schwarze Liste geladen!",
  demon_unlock = "Green Demon Modus freigeschaltet!",
  target_desc = "[NAME|ID] - Lege diesen Läufer als Ihr Ziel fest, das jederzeit seinen Standort anzeigt.",

  -- v2.6
  leave_error = "%s\\#ffa0a0\\ hat aufgrund eines Fehlers verlassen.",
  hunter_color = "Alle Jäger haben die Burgund Farbpalette", -- (check official lang for palette name)
  runner_color = "Alle Jäger haben die Azureblau Farbpalette", -- (check official lang for palette name)
  stat_playtime = "Spielzeit (Stunden)",
  stat_parkour_time = "Schnellste Parkour Zeit",
  stat_parkour_time_omm = "Schnellste Parkour Zeit (OMM)",
  stat_parkour_time_other = "Schnellste Parkour Zeit (Moveset)",
  menu_free_roam = "Frei Herumlaufen",
  menu_free_roam_desc = "Deaktiviert die Stern- und Schlüsselanforderungen für Türen und die meisten Level.",
  menu_radar = "Radar",
  menu_radar_desc = "Zeigt an, wo sich Läufer und wichtige Objekte befinden.",
  menu_minimap = "Minikarte",
  menu_minimap_desc = "Zeigt eine Karte des gesamten Levels.",
  menu_romhack_cam = "Romhack-Kamera", -- (cam is short for camera)
  menu_romhack_cam_desc = "Aktiviert die Romhack-Kamera in allen Zeiten.", -- (cam is short for camera)
  menu_star_heal = "Sternenheilung",
  
  -- v2.6.1
  menu_star_setting = "Beim Stern sammeln", -- from base
  star_leave = "Verlassen", -- is this correct?
  star_stay = "Bleiben", -- is this correct?
  star_nonstop = "Durchgehend",
}

langdata["pt-br"] = -- Made by PietroM (PietroM#4782)
{
  -- fullname for auto select (make sure this matches in-game under Misc -> Languages)
  fullname = "Portuguese",

  -- name in the built-in menu
  name_menu = "Português",

  -- global command info
  to_switch = "Type \"/lang %s\" para trocar a linguagem.",
  switched = "Trocou para Português do Brasil!",
  rule_command = "Use o comando /rules para mostrar as regras novamente.",

  -- roles
  runner = "Corredor",
  runners = "Corredores",
  short_runner = "Corre",
  hunters = "Caçadores",
  hunter = "Caçador",
  spectator = "Observador",
  player = "Jogador",
  players = "Jogadores", -- is this correct?

  -- rules
  --[[
    This is laid out as follows:
    {welcome}
    {runners}{shown_above|thats_you}{any_bowser|collect_bowser}
    {hunters}{thats_you}{all_runners|any_runners}
    {rule_lives_one|rule_lives}{time_needed|stars_needed}{become_hunter|become_runner}
    {infinite_lives}{spectate}
    {banned_glitchless|banned_general}{fun}
    I highly recommend testing this in-game
    Also:
    \\#ffffff\\ = white (default)
    \\#00ffff\\ = cyan (for Runner team name)
    \\#ff5a5a\\ = red (for Hunter team name and popups)
    \\#ffff5a\\ = yellow
    \\#5aff5a\\ = green
    \\#b45aff\\ = purple (for Extreme Mode)
  ]]
  welcome = "Bem vindo à \\#ff5a5a\\Caça-\\#00ffff\\Mario\\#ffffff\\! INSTRUÇÕES:",
  welcome_mini = "Bem vindo à \\#ffff5a\\Mini-\\#ff5a5a\\Caça\\#ffffff\\! INSTRUÇÕES:",
  welcome_egg = "Bem vindo à \\#ff5a5a\\Caça-\\#5aff5a\\Luigi\\#ffffff\\! INSTRUÇÕES:",
  all_runners = "Derrote todos os \\#00ffff\\Corredores\\#ffffff\\.",
  any_runners = "Derrote quaisquer \\#00ffff\\Corredores\\#ffffff\\.",
  shown_above = "(demonstrado acima)",
  any_bowser = "Derrote %s de \\#ffff5a\\qualquer\\#ffffff\\ maneira.",
  collect_bowser = "Colete \\#ffff5a\\%d estrela(s)\\#ffffff\\ e derrote %s.",
  mini_collect = "Seja o primeiro a \\#ffff5a\\coletar a estrela\\#ffffff\\.",
  collect_only = "Colete \\#ffff5a\\%d estrela(s)\\#ffffff\\.",
  thats_you = "(este é você!)",
  banned_glitchless = "NÃO DEVE: Ajudar a equipe oposta, BLJs, cruzar paredes com glitches, enrolar, guardar caixão.",
  banned_general = "NÃO DEVE: Ajudar a equipe oposta, enrolar, guardar caixão.",
  time_needed = "%d:%02d para sair de qualquer fase; coletar estrelas para diminuir o cronômetro",
  stars_needed = "%d estrela(s) para sair de qualquer fase",
  become_hunter = "você virará um dos \\#ff5a5a\\Caçadores\\#ffffff\\ quando derrotado",
  become_runner = "derrote um \\#00ffff\\Corredor\\#ffffff\\ para virar um",
  infinite_lives = "Vidas infinitas",
  spectate = "use o comando \"/spectate\" para observar a partida",
  mini_goal = "\\#ffff5a\\Quem coletar mais estrelas em %d:%02d ganha!\\#ffffff\\",
  fun = "Se divirta!",

  -- hud, extra desc, and results text (%s is a placeholder for names, and %d is a placeholder for a number)
  win = "%s\\#ffffff\\ Ganham!", -- team name is placed here
  can_leave = "\\#5aff5a\\Pode sair do nível.",
  cant_leave = "\\#ff5a5a\\Não pode sair do nível.",
  time_left = "Poderá sair em \\#ffff5a\\%d:%02d",
  stars_left = "Precisa-se de \\#ffff5a\\%d estrela(s)\\#ffffff\\ para sair.",
  in_castle = "Dentro do Castelo",
  until_hunters = "%d segundo(s) até que os \\#ff5a5a\\Caçadores\\#ffffff\\ comecem.",
  until_runners = "%d segundo(s) até que os \\#00ffff\\Corredores\\#ffffff\\ comecem.",
  lives_one = "1 vida",
  lives = "%d vidas",
  stars_one = "1 estrela",
  stars = "%d estrelas",
  no_runners = "Não há \\#00ffff\\Corredores!",
  camp_timer = "Continue se mexendo! \\#ff5a5a\\(%d)",
  game_over = "A partida acabou!",
  winners = "Vencedores: ",
  no_winners = "\\#ff5a5a\\Não há vencedores!",
  on = "\\#5aff5a\\LIGADO",
  off = "\\#ff5a5a\\DESLIGADO",
  frozen = "Congelado por %d",

  -- popups
  lost_life = "%s\\#ffa0a0\\ perdeu uma vida!",
  lost_all = "%s\\#ffa0a0\\ perdeu todas as suas vidas!",
  now_role = "%s\\#ffa0a0\\ agora é um %s\\#ffa0a0\\.",
  got_star = "%s\\#ffa0a0\\ conseguiu uma estrela!",
  got_key = "%s\\#ffa0a0\\ pegou uma das chaves!",
  rejoin_start = "%s\\#ffa0a0\\ tem dois minutos para entrar novamente na partida.",
  rejoin_success = "%s\\#ffa0a0\\ entrou à tempo!",
  rejoin_fail = "%s\\#ffa0a0\\ Não reconectou a tempo.",
  using_ee = "Este servidor está usando a versão Extrema.",
  not_using_ee = "Este servidor usa a versão normal.",
  killed = "%s\\#ffa0a0\\ derrotou %s!",
  sidelined = "%s\\#ffa0a0\\ acabou de vez com %s!",
  paused = "Você está sob efeito de pausa.",
  unpaused = "Você não está mais sob o efeito de pausa.",
  kill_combo_2 = "%s\\#ffa0a0\\ já derrotou \\#ffff5a\\dois\\#ffa0a0\\ jogadores!",
  kill_combo_3 = "%s\\#ffa0a0\\ já derrotou \\#ffff5a\\três\\#ffa0a0\\ jogadores!",
  kill_combo_4 = "%s\\#ffa0a0\\ já derrotou \\#ffff5a\\quatro \\#ffa0a0\\ jogadores!",
  kill_combo_5 = "%s\\#ffa0a0\\ já derrotou \\#ffff5a\\cinco\\#ffa0a0\\ jogadores!",
  kill_combo_large = "\\#ffa0a0\\Uau! %s\\#ffa0a0\\ já consegiu\\#ffff5a\\%d\\#ffa0a0\\ baixas em uma única tacada!",
  set_hack = "A hack selecionada foi %s",
  incompatible_hack = "AVISO: Essa hack não é compatível!",
  vanilla = "Usando o jogo original",
  omm_detected = "OMM Rebirth está em uso!",
  omm_bad_version = "\\#ff5a5a\\Moveset do OMM está desatualizado!\\#ffffff\\\nVersão mínima: %s\nSua versão: %s",
  custom_enter = "%s\\#ffffff\\ entrou\n%s", -- same as coop
  demon_unlock = "O modo Demônio Verde foi desbloqueado!",
  hit_switch_red = "%s\\#ffa0a0\\ pressione o\n\\#df5050\\botão Vermelho!", -- dark red (unique)
  hit_switch_green = "%s\\#ffa0a0\\ pressione o\n\\#50b05a\\botão Verde!", -- dark green (unique)
  hit_switch_blue = "%s\\#ffa0a0\\ pressione o\n\\#5050e3\\botão Azul!", -- dark blue (unique)
  hit_switch_yellow = "%s\\#ffa0a0\\ pressione o\n\\#e3b050\\botão Amarelo...", -- orangeish (unique)

  -- command feedback
  not_mod = "Você não tem AUTORIDADE para usar esse comando, seu tolo!",
  no_such_player = "Esse jogador não existe.",
  bad_id = "ID de jogador inválido!",
  command_disabled = "Esse comando está deshabilitado.",
  change_setting = "Configuração Alterada:",

  -- more command feedback
  bad_param = "Parâmetros inválidos!",
  bad_command = "Comando inválido!",
  error_no_runners = "Não se pode começar o jogo sem corredores!",
  set_team = "O time de %s's foi mudado para '%s'",
  not_started = "A Rodada não começou ainda",
  set_lives_one = "%s agora tem apenas 1 vida extra",
  set_lives = "%s agora tem %d vida(s) extra(s)",
  not_runner = "%s Não é um Corredor",
  may_leave = "%s pode sair.",
  must_have_one = "Deve ter no mínimo 1 caçador!",
  added = "Corredores adicionados: ",
  runners_are = "Os Corredores são: ",
  set_lives_total = "Vidas dos corredores definidas para %d",
  wrong_mode = "Não está disponível neste modo.",
  need_time_feedback = "Corredores poderão sair em %d segundos(s) a partir de agora.",
  game_time = "O jogo durará %d segundo(s)",
  need_stars_feedback = "Corredores precisam de %d star(s) agora",
  new_category = "Agora é uma speedrun de %d estrelas.",
  new_category_any = "Agora a partida é uma speedrun any%",
  mode_normal = "Está no Modo Normal",
  mode_swap = "Está no Modo Swap",
  --mode_swap = "Mudando o Modo de jogo", -- I think there was a miscommunication here
  mode_mini = "Está no modo Mini-Caça",
  using_stars = "Usando estrelas coletadas",
  using_timer = "Usando Cronômetro",
  can_spectate = "Caçadores podem agora observar a partida",
  no_spectate = "Caçadores não poderão mais observar.",
  all_paused = "Todos os jogadores estão pausados",
  all_unpaused = "Todos os jogadores estão despausads",
  player_paused = "%s foi pausado",
  player_unpaused = "%s foi despausado",
  hunter_metal = "Todos os Caçadores serão metálicos",
  hunter_normal = "Todos os Caçadores estão com aparência normal.",
  hunter_glow = "Todos os Caçadores brilham em vermelho",
  hunter_outline = "Todos os Caçadores têm um contorno.",
  runner_normal = "Todos os Corredores estão com aparência normal.",
  runner_sparkle = "Todos os Corredores emitem um efeito.",
  runner_glow = "Todos os Corredores brilham",
  runner_outline = "Todos os Corredores têm um contorno",
  now_weak = "Todos os jogadores têm meio-frame (quadro) de invencibilidade.",
  not_weak = "Todos os jogadores têm frames (quadros) de invencibilidade.",
  auto_on = "A rodada vai iniciar automaticamente",
  auto_off = "Rodadas não vão iniciar automaticamente.",

  -- team chat
  tc_toggle = "Chat de time está %s!",
  to_team = "\\#8a8a8a\\Para time: ",
  from_team = "\\#8a8a8a\\ (time): ",

  -- hard mode
  hard_notice = "Psiu, tente usar o modo /hard...",
  extreme_notice = "Psiu, tente usar o modo /hard ex...",
  hard_toggle = "\\#ff5a5a\\Modo Difícil\\#ffffff\\ está %s!",
  extreme_toggle = "\\#b45aff\\Modo Extremo\\#ffffff\\ está %s!",
  hard_info = "Interessado em usar o \\#ff5a5a\\Modo Difícil\\#ffffff\\?"..
  "\n- Barra de vida pela metade."..
  "\n- A água não recupera sua vida"..
  "\n- \\#ff5a5a\\Uma vida"..
  "\n\\#ffffff\\Use o comando /hard ON se você topa tentar o desafio.",
  hard_mode = "Modo Difícil",
  extreme_mode = "Modo Extremo",
  hard_info_short = "Barra de vida pela metade, uma vida, e a água não te faz recuperar a vida.",
  extreme_info_short = "Um pedaço na barra de vida, uma vida extra e o Cronômetro Mortal.",

  -- spectator
  hunters_only = "Apenas os caçadores podem observar a partida!",
  spectate_disabled = "Modo de observação desligado!",
  timer_going = "Você não pode observar durante o temporizador!", -- now unused
  spectate_self = "Você não pode observar a si mesmo!",
  spectator_controls = "Controles:"..
  "\nDPAD-UP: Desligar a barra de status"..
  "\nDPAD-DOWN: Trocar entre câmera livre/visão do jogador"..
  "\nDPAD-LEFT / DPAD-RIGHT: Trocar de jogador"..
  "\nJOYSTICK: Movimentar"..
  "\nA: Ir para cima"..
  "\nZ: Ir para baixo"..
  "\nType \"/spectate OFF\" para cancelar.",
  spectate_off = "Não está mais observando.",
  empty = "VAZIO (%d )",
  free_camera = "CÂMERA LIVRE",

  -- stats
  disp_wins_one = "%s\\#ffffff\\ ganhou uma vez como \\#00ffff\\Corredor\\#ffffff\\!",
  disp_wins = "%s\\#ffffff\\ ganhou %d vezes como \\#00ffff\\Corredor\\#ffffff\\!",
  disp_kills_one = "%s\\#ffffff\\ matou um jogador!",
  disp_kills = "%s\\#ffffff\\ matou %d jogadores!",
  disp_wins_hard_one = "%s\\#ffffff\\ ganhou uma vez como \\#ffff5a\\Corredor\\#ffffff\\ no \\#ff5a5a\\Modo Difícil!\\#ffffff\\",
  disp_wins_hard = "%s\\#ffffff\\ ganhou %d vezes como \\#ffff5a\\Corredor\\#ffffff\\ no \\#ff5a5a\\Modo Difícil!\\#ffffff\\",
  disp_wins_ex_one = "%s\\#ffffff\\ ganhou uma vez como \\#b45aff\\Corredor\\#ffffff\\ no \\#b45aff\\Modo Extremo!\\#ffffff\\",
  disp_wins_ex = "%s\\#ffffff\\ ganhou %d vezes como \\#b45aff\\Corredor\\#ffffff\\ no \\#b45aff\\Modo Extremo!\\#ffffff\\",
  -- for stats table
  stat_wins_standard = "Vitórias",
  stat_wins = "Vitórias (Mini-Caça/pré v2.3)", -- probably wrong
  stat_kills = "Já Matou",
  stat_combo = "Combo Máx. de Assassinatos",
  stat_wins_hard_standard = "Vitórias no Modo Difícil",
  stat_wins_hard = "Vitórias no Modo Difícil (Mini-Caça/pré v2.3)",
  stat_mini_stars = "Máximo de Estrelas em uma rodada de Mini-Caça",
  stat_wins_ex_standard = "Vitórias no Modo Extremo",
  stat_wins_ex = "Vitórias no Modo Extremo (Mini-Caça/pré v2.3)",

  -- placements
  place_1 = "\\#e3bc2d\\[64T: 1ro Lugar]",
  place_2 = "\\#c5d8de\\[64T: 2ndo Lugar]",
  place_3 = "\\#b38752\\[64T: 3ro Lugar]",
  place = "\\#e7a1ff\\[64T: %do Lugar]", -- thankfully we don't go up to 21
  place_score_1 = "%dro",
  place_score_2 = "%dndo",
  place_score_3 = "%dro",
  place_score = "%do",

  -- command descriptions
  start_desc = "[CONTINUE|MAIN|ALT|RESET] - Inicia a rodada; adicione \"continue\" para que não seja teleportado para o início; adicione \"alt\" para uma save file alternativa (bugado); adicione \"main\" para a save file principal; adicione \"reset\" para resetar a sua save file (bugado)",
  add_desc = "[INT] - Os corredores virão em número aleatório.",
  random_desc = "[INT] - Seleciona os Corredores de forma aleatória com o número dado",
  lives_desc = "[INT] - Seleciona o máximo de vidas dos corredores, de 0 até 99 (Não esqueça: 0 vidas ainda contam como 1!)",
  time_desc = "[NUM] - Define o tempo que os Corredores tem que aguardar para sair, em segundos, ou o tempo total do jogo na Mini-Caça.",
  stars_desc = "[INT] - Define quantas estrelas os Corredores devem coletar para sair, de 0 a 7 (apenas no Modo Estrela)",
  category_desc = "[INT] - Define quantas estrelas o jogador deve ter para enfrentar o Bowser.",
  flip_desc = "[NAME|ID] - Troca o jogador especificado de equipe",
  setlife_desc = "[NAME|ID|INT,INT] - Muda o número de vidas com o selecionado para os Corredores",
  leave_desc = "[NAME|ID] - Permitir que um jogador em específico saia da fase.",
  mode_desc = "[NORMAL|SWAP|MINI] - Muda o tipo de jogo; swap troca o jogador assim que ele morre.",
  starmode_desc = "[ON|OFF] - Define que sejam utilizadas estrelas coletadas e não um cronômetro",
  spectator_desc = "[ON|OFF] - Liga para os Caçadores a habilidade de observar a partida",
  pause_desc = "[NAME|ID|ALL] - Aciona o modo pausa para o(s) jogador(es), todos se não for especificado",
  hunter_app_desc = "Muda a aparência dos Caçadores.",
  runner_app_desc = "Muda a aparência dos Corredores.",
  hack_desc = "[STRING] - Seleciona a Rom-Hack atual.",
  weak_desc = "[ON|OFF] - Cortar os quadros de invencibilidade no meio para todos os jogadores",
  auto_desc = "[ON|OFF|NUM] - Inicia partidas automaticamente.",
  stalking_desc = "[ON|OFF] - Permite teleportar para o nível de um caçador com /stalk",

  -- mute
  muted = "\\#ffff00\\%s\\#ffffff\\ foi silenciado por \\#ffff00\\%s\\#ffffff\\.",
  unmuted = "\\#ffff00\\%s\\#ffffff\\ permitiu \\#ffff00\\%s\\#ffffff\\ falar novamente.",
  you_muted = "Você silenciou \\#ffff00\\%s\\#ffffff\\.",
  you_unmuted = "Você permitiu \\#ffff00\\%s\\#ffffff\\ falar novamente.",
  mute_auto = "\\#ffff00\\%s\\#ffffff\\ foi silenciado automaticamente.",

  -- Blocky's menu
  main_menu = "Menu Principal",
  menu_settings = "Configurações do jogo", -- translate verified
  menu_settings_player = "Configurações",
  menu_rules = "Regras",
  menu_lang = "Idioma",
  menu_misc = "Outros",
  menu_exit = "Sair",
  menu_back = "Voltar",
  menu_mh = "Caça-Mario",
  menu_mh_egg = "Caça-Luigi",
  menu_stars = "Estrelas",
  menu_tc = "Chat de time",
  menu_defeat_bowser = "Derrote %s",
  menu_hunter_app = "Aparência do Caçador",
  menu_runner_app = "Aparência do Corredor",
  menu_allow_stalk = "Permitir 'Perseguição'",
  menu_season = "Mudanças Temáticas",
  menu_season_desc = "Mudanças visuais divertidas podem acontecer dependendo da data.",

  -- updater (difference for "_egg" is Luigi instead of Mario)
  up_to_date = "\\#ff5a5a\\Caça\\#00ffff\\Mario\\#ffffff\\ está na versão mais recente!",
  up_to_date_egg = "\\#ff5a5a\\Caça\\#5aff5a\\Luigi\\#ffffff\\ está na versão mais recente!",
  has_update = "Uma versão nova de \\#ff5a5a\\Caça\\#00ffff\\Mario\\#ffffff\\ está disponível!",
  has_update_egg = "Uma versão nova de \\#ff5a5a\\Caça\\#5aff5a\\Luigi\\#ffffff\\ está disponível!",

  -- not really organized
  lang_desc = "%s - Trocar linguagem",
  got_all_stars = "Você possui estrelas suficientes!",
  spectate_mode = "- MODO ESPECTADOR -",
  menu_allow_spectate = "Permitir Observar",
  menu_hide_roles_desc = "Esconder sua função no chat.",
  menu_stop = "Parar",
  spectate_desc = "[NAME|ID|OFF] - Observar um jogador, ativa a câmera livre se não for especificado o jogador, ou OFF para desligar.",
  menu_stalk_run = "Teleportar para a fase de um Corredor",
  stop_desc = "- Parar o jogo",
  menu_star_mode = "Modo Estrela",
  tc_desc = "[ON|OFF|MSG] - Mandar mensagem para seu time apenas; Ative o ON para aplicar em todas as mensagens.",
  stars_in_area = "%d estrela(s) disponível(is) aqui!",
  force_spectate_one = "%s precisam observar.",
  menu_demon_desc = "Permitir que um Cogumelo Vida Extra persiga você quando for corredor.",
  vote_pass = "Passou a vez de votar!",
  menu_stats = "Estatísticas",
  extreme_info = "Certeza que tem chances com o \\#b45aff\\Modo Extremo\\#ffffff\\? Que tolice.\
  - Uma vida\
  - Um pedaço de vida na barra\
  - \\#b45aff\\Temporizador mortal\\#ffffff\\; colete moedas para aumentar\
  Se isso não te faz ter medo, digite /hard ex ON.",
  role_trans = "\\#ffd996\\[Tradutor MH]",
  role_lead = "\\#9a96ff\\[Desenvolv. Líder MH]",
  warp_desc = "[LEVEL|COURSE,AREA,ACT,NODE] - Teleportar para a fase",
  menu_timer = "Cronômetro de Speedrun",
  menu_first_timer = "Cronômetro de Liderança Mortal",
  menu_popup_sound = "Sons dos Pop-ups",
  stalk_desc = "[NAME|ID] - Teleportar para a fase de um Corredor específico, ou o primeiro Corredor.",
  menu_run_random = "Corredores aleatórios",
  blacklist_add = "Listou %s",
  menu_hide_roles = "Esconder minhas funções",
  open_menu = "Digite /mh ou pressione L + Start para abrir o menu",
  menu_nerf_vanish = "Nerfar a Boina invisível",
  forcespectate_desc = "[NAME|ID|ALL] - Forçar que um jogador em específico fique observando ou todos se nenhum for especificado.",
  stalk = "Use /stalk para ir até a fase de um Corredor!",
  menu_category = "Categoria",
  stat_placement = "Posição no Tour 64",
  menu_fast = "Ações Ágeis",
  default_desc = "- Resetou as opções.",
  new_record = "\\#ffff5a\\NOVO RÉCORDE!!!",
  anarchy_set_2 = "Caçadores podem bater nos seus companheiros",
  menu_skip = "Pular",
  menu_stalk_run_desc = "Ir para a fase que se localiza o primeiro Corredor.",
  no_runners_added = "Nenhum Corredor adicionado",
  menu_exit_spectate_desc = "Sair do modo Espectador.",
  menu_flip = "Trocar de Equipe",
  quick_desc = "[LEVEL|COURSE|HUNTER,AREA,ACT,NODE] Teste rápido de jogo",
  menu_first_timer_desc = "Dá ao Corredor em primeiro um Cronômetro Mortal.",
  menu_save_continue = "Continuar (Não há teleporte para voltar)",
  menu_start = "Começar",
  role_dev = "\\#96ecff\\[Desenvolv. MH]",
  menu_nerf_vanish_desc = "Nerfa a Boina da invisibilidade e drena ela mais rápido quando usada.",
  menu_blacklist_list_desc = "Lista todas as estrelas na lista negra..",
  menu_pause = "Pausa",
  menu_players_all = "Todos os jogadores",
  menu_toggle_all = "Ligar tudo",
  menu_blacklist_reset_desc = "Resetar a lista negra para os padrões.",
  unstuck = "Tentando voltar ao padrão",
  menu_blacklist_load = "Carregar Lista Negra",
  menu_blacklist_load_desc = "Carregar sua Lista Negra salva.",
  menu_blacklist_reset = "Resetar a Lista Negra",
  menu_blacklist_save_desc = "Salvar sua Lista Negra ao final.",
  menu_blacklist_save = "Salvar Lista Negra",
  menu_blacklist_list = "Listar todas na Lista Negra",
  menu_spectate_desc = "Observar este jogador.",
  menu_skip_desc = "- Votar para pular essa estrela na Mini-Caça.",
  menu_exit_spectate = "Sair do modo de Observação",
  menu_spectate_run_desc = "Automaticamente Observar o primeiro Corredor.",
  menu_list_settings = "Listar as Opções",
  menu_spectate_run = "Observar Corredor",
  anarchy_set_3 = "Jogadores podem atingir seus companheiros de equipe.",
  menu_free_cam_desc = "Entrar no modo Câmera Livre quando estiver Observando.",
  menu_fast_desc = "Você vai se recuperar, arremesar objetos e abrir portas rapidamente.",
  menu_secret = "Isto é um segredo. Como você pode descubrir?",
  menu_hide_hud = "Esconder o HUD",
  hidehud_desc = "- Esconder todos os elementos do HUD.",
  menu_stalk = "Teleportar para a fase",
  dmgAdd_set = "Corredores agora tomarão %d de dano extra por ataques PvP.",
  dmgAdd_set_ohko = "Os Corredores morrerão após um único dano",
  voidDmg_set = "Jogadores tomarão um dano de %d por cair em buracos ou em areia movediça.",
  voidDmg_set_ohko = "Jogadores morrerão instantaneamente após cair em um buraco ou em areia movediça.",
  target_hunters_only = "Apenas Caçadores podem selecionar um alvo.",
  hard_desc = "[EX|ON|OFF,ON|OFF] - Ligar o Modo Difícil apenas para você",
  is_spectator = "* ESSE JOGADOR ESTÁ OBSERVANDO  *",
  menu_setlife = "Definir vidas extras",
  menu_allowleave = "Permitir saída",
  menu_forcespectate = "Forçar Observação",
  menu_stalk_desc = "Teleportar para a fase desse jogador.",
  menu_demon = "Demônio Verde",
  menu_spectate = "Observar",
  force_spectate_off = "Spectar não é mais obrigatório",
  menu_dmgAdd = "Corredor PVP DMG",
  menu_anarchy_desc = "Permite que os jogadores específicos possam atacar os jogadores da mesma equipe.",
  rules_desc = "- Mostrar as regras da Caça-Mario",
  rules_desc_egg = "- Mostrar as regras da Caça-Luigi",
  menu_anarchy = "Ataque de Times",
  menu_blacklist = "Lista Negra da Mini-Caça",
  mh_desc = "[COMMAND,ARGS] - Usa comandos; digite nada, ou \"menu\" para abrir o menu",
  blacklist_list = "Lista Negra:",
  menu_auto = "Jogo Automático",
  menu_weak = "Modo Fraqueza",
  menu_gamemode = "Modo de jogo",
  menu_campaign = "Campanha",
  menu_random = "Aleatório",
  menu_save_reset = "Resetar Save File Alternativa",
  vanish_custom = "Segure \\#ffff5a\\B\\#ffffff\\ para desaparecer!",
  menu_save_main = "Principal",
  menu_run_lives = "Vidas Extras dos Corredores",
  menu_timer_desc = "[ON|OFF] - Mostrar um cronômetro no canto da tela no modo Padrão.",
  menu_list_settings_desc = "Lista todas as opções deste servidor.",
  blacklist_reset = "Resetar a Lista Negra!",
  blacklist_save = "A Lista Negra foi salva!",
  blacklist_load = "A Lista Negra foi carregada!",
  all = "Tudo",
  blacklist_desc = "[ADD|REMOVE|LIST|RESET|SAVE|LOAD,COURSE,ACT] - Adicionar a Lista Negra estrelas na Mini-Caça",
  blacklist_remove = "Aprovou %s",
  page = "\\#ffff5a\\Página %d/%d",
  menu_default = "Restaurar para o Padrão",
  anarchy_set_1 = "Corredores podem atacar seus companheiros de equipe",
  menu_run_add = "Adicionar Corredores",
  blacklist_remove_already = "Essa estrela e(ou) fase não está na Lista Negra.",
  force_spectate = "Todos devem observar",
  menu_save_alt = "Save file alternativa",
  menu_tc_desc = "Converse apenas com sua equipe.",
  already_voted = "Você já votou.",
  vote_info = "Digite /skip para votar",
  vote_skip = "%s\\#dcdcdc\\ votou para pular essa estrela",
  blacklist_remove_invalid = "Não é possível aprovar essas fases.",
  no_hard_win = "Suas vitórias e pontuações no modo Extremo e Difícil não serão atualizados nessa rodada.",
  death_timer = "Morte",
  blacklist_add_already = "Essa estrela e(ou) fase já está na Lista Negra.",
  anarchy_set_0 = "Jogadores não podem atacar seus companheiros de equipe.",
  menu_dmgAdd_desc = "Definir este número de dano aos Corredores.",
  no_valid_star = "Não foram achadas estrelas válidas!",
  warp_spam = "Devagar aí com os teleportes!",
  mini_score = "Pontuação: %d",
  stats_desc = "- Mostrar/Esconder a tabela de estatísticas",
  force_spectate_one_off = "%s não precisa observar ninguém mais",
  menu_time = "Tempo",
  desync_desc = "- Tenta arrumar problemas de dessincronizacão",
  role_cont = "\\#ff9696\\[Contribuidor MH]",
  target_desc = "[NAME|ID] - Selecionar este Corredor como seu alvo. Ele estará em destaque na tela a todo tempo.",
  use_out = "Use /mh out para expulsar todos de um mundo.",
  you_are_muted = "Você está silenciado.",
  out_desc = "- Expulsa todos de um mundo",
  menu_countdown = "Contagem Regressiva",
  menu_countdown_desc = "Quanto um Caçador deve esperar até começar.",
  menu_voidDmg = "DN. de Buraco",
  menu_voidDmg_desc = "Dano que um jogador recebe ao cair num buraco sem fundo ou areia movediça.",
  menu_double_health = "Dobro da Barra de Vida do Corredor",
  menu_double_health_desc = "Caçadores têm direito à 16 pontos de vida ao invés de 8.",
  menu_target = "Selecionar como Alvo",
  menu_mute = "Silenciar",
  mute_desc = "[NAME|ID] - Silencia um jogador, fazendo com que ele não fale mais no chat",
  unmute_desc = "[NAME|ID] - Permite que um jogador silenciado volte a falar no chat",
  
  -- v2.6
  leave_error = "%s\\#ffa0a0\\ saiu devido um erro.",
  hunter_color = "Todos os Corredores têm a paleta Burgundy.", -- (check official lang for palette name)
  runner_color = "Todos os Corredores têm a paleta Azure.", -- (check official lang for palette name)
  stat_playtime = "Tempo de jogo (em horas)",
  stat_parkour_time = "Tempo mais rápido no Parkour",
  stat_parkour_time_omm = "Tempo mais rápido no Parkour (OMM)",
  stat_parkour_time_other = "Tempo mais rápido no Parkour (Moveset)",
  menu_free_roam = "Andar Livremente",
  menu_free_roam_desc = "Desabilita qualquer requerimento de Estrelas e Chaves em portas e níveis.",
  menu_radar = "Radar",
  menu_radar_desc = "Mostra onde Corredores e objetos importantes estão.",
  menu_minimap = "Mini-mapa",
  menu_minimap_desc = "Exibe um mapa do nível inteiro.",
  menu_romhack_cam = "Câmera de Rom Hack", -- (cam is short for camera)
  menu_romhack_cam_desc = "Habilita câmera de Rom Hack.", -- (cam is short for camera)
  menu_star_heal = "Recuperação por Estrela",

  menu_star_setting = "Na Coleção de Estrelas", -- from base
  star_leave = "Sair",
  star_stay = "Ficar",
  star_nonstop = "Sem-Parar",

  ["set-fov_desc"] = "[NUM] - Modifica o campo de visão; deixe em branco para resetar.", -- I accidently added a dev command to be translated, oops
}

langdata["fr"] = -- By Skeltan
{
  -- fullname for auto select (make sure this matches in-game under Misc -> Languages)
  fullname = "French",

  -- name in the built-in menu
  name_menu = "Français",

  -- global command info
  to_switch = "Faites \"/lang %s\" pour changer de langue",
  switched = "La langue a été changée en français!", -- Replace "English" with the name of this language
  rule_command = "Faites /rules pour faire apparaître ce message de nouveau",

  -- roles
  runner = "Coureur",
  runners = "Coureurs",
  short_runner = "Cours", -- unused
  hunters = "Chasseurs",
  hunter = "Chasseur",
  spectator = "Spectateur",
  player = "Joueur",
  players = "Joueurs", -- is this correct?
  all = "Tous",

  -- rules
  --[[
    This is laid out as follows:
    {welcome}
    {runners}{shown_above|thats_you}{any_bowser|collect_bowser}
    {hunters}{thats_you}{all_runners|any_runners}
    {rule_lives_one|rule_lives}{time_needed|stars_needed}{become_hunter|become_runner}
    {infinite_lives}{spectate}
    {banned_glitchless|banned_general}{fun}

    I highly recommend testing this in-game
    Also:
    \\#ffffff\\ = white (default)
    \\#00ffff\\ = cyan (for Runner team name)
    \\#ff5a5a\\ = red (for Hunter team name and popups)
    \\#ffff5a\\ = yellow
    \\#5aff5a\\ = green
    \\#b45aff\\ = purple (for Extreme Mode)
  ]]
  welcome = "Bienvenue dans \\#00ffff\\Mario\\#ff5a5a\\Hunt\\#ffffff\\! COMMENT JOUER:",
  welcome_mini = "Bienvenue dans \\#ffff5a\\Mini\\#ff5a5a\\Hunt\\#ffffff\\! COMMENT JOUER:",
  welcome_egg = "Bienvenue dans \\#5aff5a\\Luigi\\#ff5a5a\\Hunt\\#ffffff\\! COMMENT JOUER:",
  all_runners = "Éliminez tous les \\#00ffff\\Coureurs\\#ffffff\\.",
  any_runners = "Éliminez n'importe quel \\#00ffff\\Coureur\\#ffffff\\.",
  shown_above = "(montré çi-dessus)",
  any_bowser = "Battez %s par \\#ffff5a\\tous les moyens nécessaires.\\#ffffff\\",
  collect_bowser = "Collectez \\#ffff5a\\%d étoile(s)\\#ffffff\\ et battez %s.",
  mini_collect = "Soyez le premier à \\#ffff5a\\obtenir l'étoile\\#ffffff\\.",
  collect_only = "Collectez \\#ffff5a\\%d étoile(s)\\#ffffff\\.",
  thats_you = "(c'est vous!)",
  banned_glitchless = "INTERDICTION DE: Faire des Alliances, faire des BLJs, passer à travers les murs, freiner l'avancée du jeu, camper.",
  banned_general = "INTERDICTION DE: Faire des Alliances, freiner l'avancée du jeu, camper.",
  time_needed = "%d:%02d pour sortir de n'importe quel niveau; collectez des étoiles pour réduire le compte à rebours",
  stars_needed = "%d étoile(s) pour sortir de n'importe quel niveau",
  become_hunter = "devenez \\#ff5a5a\\Chasseurs\\#ffffff\\ une fois vaincu",
  become_runner = "éliminez un \\#00ffff\\Coureur\\#ffffff\\ pour en devenir un",
  infinite_lives = "Vies Illimités",
  spectate = "faites \"/spectate\" pour devenir spectateur",
  mini_goal = "\\#ffff5a\\Celui qui collecte le plus d'étoiles en %d:%02d gagne!\\#ffffff\\",
  fun = "Amusez-vous bien!",

  -- hud, extra desc, and results text (%s is a placeholder for names, and %d is a placeholder for a number)
  win = "%s\\#ffffff\\ ont gagné!", -- team name is placed here
  can_leave = "\\#5aff5a\\Peut sortir du niveau",
  cant_leave = "\\#ff5a5a\\Ne peut pas sortir du niveau",
  time_left = "Peut sortir dans \\#ffff5a\\%d:%02d",
  stars_left = "\\#ffff5a\\%d étoile(s)\\#ffffff\\ nécessaires pour sortir",
  in_castle = "Dans le château",
  until_hunters = "%d seconde(s) avant que les \\#ff5a5a\\Chasseurs\\#ffffff\\ commencent",
  until_runners = "%d seconde(s) avant que les \\#00ffff\\Coureurs\\#ffffff\\ commencent",
  lives_one = "1 vie",
  lives = "%d vies",
  stars_one = "1 étoile",
  stars = "%d étoiles",
  no_runners = "Pas de \\#00ffff\\Coureurs!",
  camp_timer = "Restez en mouvement! \\#ff5a5a\\(%d)",
  game_over = "La partie est terminée!",
  winners = "Gagnants: ",
  no_winners = "\\#ff5a5a\\Pas de gagnants!",
  death_timer = "Mort",
  on = "\\#5aff5a\\ACTIVÉ",
  off = "\\#ff5a5a\\DÉSACTIVÉ",
  frozen = "Gelé pour %d",

  -- popups
  lost_life = "%s\\#ffa0a0\\ a perdu une vie!",
  lost_all = "%s\\#ffa0a0\\ a perdu toute ses vies!",
  now_role = "%s\\#ffa0a0\\ est désormais un %s\\#ffa0a0\\.",
  got_star = "%s\\#ffa0a0\\ a obtenu une étoile!",
  got_key = "%s\\#ffa0a0\\ a obtenu une clé!",
  rejoin_start = "%s\\#ffa0a0\\ a 2 minutes pour se reconnecter.",
  rejoin_success = "%s\\#ffa0a0\\ est revenu à temps!",
  rejoin_fail = "%s\\#ffa0a0\\ ne s'est pas reconnecté à temps.",
  using_ee = "Ceci utilise le mode extrême uniquement.",
  not_using_ee = "Ceci utilise le mode standard uniquement.",
  killed = "%s\\#ffa0a0\\ a tué %s!",
  sidelined = "%s\\#ffa0a0\\ a vaincu %s!",
  paused = "Vous avez été mis en pause.",
  unpaused = "Vous n'êtes plus en pause.",
  kill_combo_2 = "%s\\#ffa0a0\\ a tué \\#ffff5a\\deux\\#ffa0a0\\ personnes à la suite!",
  kill_combo_3 = "%s\\#ffa0a0\\ a tué \\#ffff5a\\trois\\#ffa0a0\\ personnes à la suite!",
  kill_combo_4 = "%s\\#ffa0a0\\ a tué \\#ffff5a\\quatre\\#ffa0a0\\ personnes à la suite!",
  kill_combo_5 = "%s\\#ffa0a0\\ a tué \\#ffff5a\\cinq\\#ffa0a0\\ personnes à la suite!",
  kill_combo_large = "\\#ffa0a0\\Wow! %s\\#ffa0a0\\ a tué \\#ffff5a\\%d\\#ffa0a0\\ personnes à la suite!",
  set_hack = "Rom-Hack définie sur %s",
  incompatible_hack = "ATTENTION: Rom-Hack incompatible!",
  vanilla = "Utilisation du jeu Vanilla",
  omm_detected = "OMM Rebirth a été détecté!",
  omm_bad_version = "\\#ff5a5a\\OMM Rebirth est obsolète!\\#ffffff\\\nVersion Minimum: %s\nVotre version: %s",
  warp_spam = "Doucement avec les téléportations!",
  no_valid_star = "Impossible de trouver une étoile valide!",
  custom_enter = "%s\\#ffffff\\ est entré dans\n%s", -- same as coop
  demon_unlock = "Mode Green Demon débloqué!",
  hit_switch_red = "%s\\#ffa0a0\\ a activé le\n\\#df5050\\Bouton Rouge!", -- dark red (unique)
  hit_switch_green = "%s\\#ffa0a0\\ a activé le\n\\#50b05a\\Bouton Vert!", -- dark green (unique)
  hit_switch_blue = "%s\\#ffa0a0\\ a activé le\n\\#5050e3\\Bouton Bleu!", -- dark blue (unique)
  hit_switch_yellow = "%s\\#ffa0a0\\ a activé le\n\\#e3b050\\Bouton Jaune...", -- orangeish (unique)

  -- command feedback
  not_mod = "Vous n'avez pas la permission d'utiliser cette commande, pauvre fou!",
  no_such_player = "Ce joueur n'existe pas",
  bad_id = "ID de joueur invalide!",
  command_disabled = "Cette commande est désactivée.",
  change_setting = "Paramètre changé:",
  you_are_muted = "Vous êtes muet.",

  -- more command feedback
  bad_param = "Paramètres Invalides!",
  bad_command = "Commande Invalide!",
  error_no_runners = "Impossible de commencer avec 0 Coureur!",
  set_team = "L'équipe de %s a été défini sur '%s'", -- First %s is player name, second is team name (now unused)
  not_started = "La partie n'a pas encore commencé",
  set_lives_one = "%s à désormais 1 vie",
  set_lives = "%s à désormais %d vies",
  not_runner = "%s n'est pas un Coureur",
  may_leave = "%s est autorisé à sortir",
  must_have_one = "Il faut au moins 1 Chasseur",
  added = "Coureurs ajoutés: ", -- list comes afterward
  runners_are = "Les Coureurs sont: ",
  set_lives_total = "Nombre de vies de Coureur défini à %d",
  wrong_mode = "Indisponible dans ce mode",
  need_time_feedback = "Les Coureurs peuvent désormais sortir après %d seconde(s)",
  game_time = "La partie dure désoarmais %d seconde(s)",
  need_stars_feedback = "Les Coureurs ont désormais besoin de %d étoile(s)",
  new_category = "Il s'agit désormais d'un speedrun %d étoile(s)",
  new_category_any = "Il s'agit désormais d'un speedrun Any%",
  mode_normal = "En mode Normal",
  mode_swap = "En mode Inversion de Rôles",
  mode_mini = "En mode MiniHunt",
  using_stars = "Mode: Étoiles Ramassées",
  using_timer = "Mode: Compte à Rebours",
  can_spectate = "Les Chasseurs peuvent désormais être spectateurs",
  no_spectate = "Les Chasseurs ne peuvent plus être spectateurs",
  all_paused = "Tous les joueurs ont été mit en pause",
  all_unpaused = "Tous les joueurs ne sont plus en pause",
  player_paused = "%s a été mit en pause",
  player_unpaused = "%s n'est plus en pause",
  hunter_metal = "Tous les Chasseurs sont en métal",
  hunter_normal = "Tous les Chasseurs apparaissent normalement",
  hunter_glow = "Tous les Chasseurs brillent en rouge",
  runner_normal = "Tous les Coureurs apparaissent normalement",
  now_weak = "Tous les joueurs n'ont plus que la moitié de leurs frames d'invincibilité",
  not_weak = "Tous les joueurs ont leurs frames d'invincibilité par défaut",
  auto_on = "La partie commencera automatiquement",
  auto_off = "La partie ne commencera pas automatiquement",
  force_spectate = "Tous le monde doit être spectateur",
  force_spectate_off = "Le mode spectateur n'est désormais plus forcé",
  force_spectate_one = "%s doit être en mode spectateur",
  force_spectate_one_off = "%s n'est plus obligé d'être en mode spectateur",
  blacklist_add = "%s ajouté à la liste noire",
  blacklist_remove = "%s ajouté à la liste blanche",
  blacklist_add_already = "Cette étoile ou ce niveau est déjà sur la liste noire.",
  blacklist_remove_already = "Cette étoile ou ce niveau n'est pas sur la liste noire.",
  blacklist_remove_invalid = "Impossible d'ajouter cette étoile ou ce niveau sur la liste blanche.",
  blacklist_list = "Liste Noire:",
  blacklist_reset = "Réinitialise la liste noire!",
  blacklist_save = "Liste noire sauvegardée!",
  blacklist_load = "Liste noire chargée!",

  -- team chat
  tc_toggle = "Le tchat d'équipe est %s!",
  to_team = "\\#8a8a8a\\Pour ton équipe: ",
  from_team = "\\#8a8a8a\\ (équipe): ",

  -- vote skip
  vote_skip = "%s\\#dcdcdc\\ a voté pour passer cette étoile",
  vote_info = "Tapez /skip dans le tchat pour voter",
  vote_pass = "Le vote est passé!",
  already_voted = "Vous avez déja voté.",

  -- hard mode
  hard_notice = "Psst, essaye de faire /hard dans le tchat...",
  extreme_notice = "Psst, essaye de faire /hard ex dans le tchat...",
  hard_toggle = "Le \\#ff5a5a\\Mode Difficile\\#ffffff\\ est %s!",
  extreme_toggle = "Le \\#b45aff\\Mode Extrême\\#ffffff\\ est %s!",
  "\n- 2x moins de vie"..
  "\n- L'eau ne regénère pas la vie"..
  "\n- \\#ff5a5a\\Une Seule Vie"..
  "\n\\#ffffff\\Tapez /hard ON dans le tchat si vous êtes prêt à relever le défi.",
  extreme_info = "Êtes-vous attirez par le \\#b45aff\\Mode Extrême\\#ffffff\\? Quelle folie."..
  "\n- Une Seule Vie"..
  "\n- Un unique Point de Vie"..
  "\n- \\#b45aff\\Compte à Rebourd Mortel\\#ffffff\\; ramassez des pièces ou des étoiles pour l'augmenter"..
  "\nSi cela ne vous fait pas peur, alors tapez /hard ex ON dans le tchat.",
  no_hard_win = "Vos Victoires Difficiles ou Extrêmes ne seront pas sauvegardés pour cette partie.",
  hard_mode = "Mode Difficile",
  extreme_mode = "Mode Extrême",
  hard_info_short = "2x moins de PV, l'eau ne régen pas, et une seule vie.",
  extreme_info_short = "Un seul PV, une seule vie, et compte à rebours mortel.",

  -- spectator
  hunters_only = "Seuls les Chasseurs peuvent être spectateurs!",
  spectate_disabled = "Le mode spectateur est désactivé!",
  timer_going = "Vous ne pouvez pas être spectateur durant le compte à rebours!", -- now unused
  spectate_self = "Vous ne pouvez être votre propre spectateur!",
  spectator_controls = "Contrôles:"..
  "\nDPAD-UP: Désactiver le HUD"..
  "\nDPAD-DOWN: Alterner Caméra Libre/Suivre Joueur"..
  "\nDPAD-LEFT / DPAD-RIGHT: Changer de joueur"..
  "\nJOYSTICK: Se déplacer"..
  "\nA: Aller vers le haut"..
  "\nZ: Aller vers le bas"..
  "\nFaites \"/spectate OFF\" pour annuler",
  spectate_off = "Vous n'êtes plus en mode spectateur.",
  empty = "Vide (%d )",
  free_camera = "CAMÉRA LIBRE",
  spectate_mode = "- MODE SPECTATEUR -",
  is_spectator = '* LE JOUEUR EST UN SPECTATEUR  *', -- is this correct?

  -- stats
  disp_wins_one = "%s\\#ffffff\\ a gagné 1 fois en tant que \\#00ffff\\Coureur\\#ffffff\\!",
  disp_wins = "%s\\#ffffff\\ a gagné %d fois en tant que \\#00ffff\\Coureur\\#ffffff\\!",
  disp_kills_one = "%s\\#ffffff\\ a tué 1 joueur!", -- unused
  disp_kills = "%s\\#ffffff\\ a tué %d joueurs!",
  disp_wins_hard_one = "%s\\#ffffff\\ a gagné 1 fois en tant que \\#ffff5a\\Coureur\\#ffffff\\ en \\#ff5a5a\\Mode Difficile!\\#ffffff\\",
  disp_wins_hard = "%s\\#ffffff\\ a gagné %d fois en tant que \\#ffff5a\\Coureur\\#ffffff\\ en \\#ff5a5a\\Mode Difficile!\\#ffffff\\",
  disp_wins_ex_one = "%s\\#ffffff\\ a gagné 1 fois en tant que \\#b45aff\\Coureur\\#ffffff\\ en \\#b45aff\\Mode Extrême!\\#ffffff\\",
  disp_wins_ex = "%s\\#ffffff\\ a gagné %d fois en tant que \\#b45aff\\Coureur\\#ffffff\\ en \\#b45aff\\Mode Extrême!\\#ffffff\\",
  -- for stats table
  stat_wins_standard = "Victoires",
  stat_wins = "Victoires (Minihunt/pré v2.3)",
  stat_kills = "Kills",
  stat_combo = "Record de Kills",
  stat_wins_hard_standard = "Victoires (Mode Difficile)",
  stat_wins_hard = "Victoires (Mode Difficile, Minihunt/pré v2.3)",
  stat_mini_stars = "Maximum d'étoiles en une partie de MiniHunt",
  stat_placement = "Placement du 64 Tour",
  stat_wins_ex_standard = "Victoires (Mode Extrême)",
  stat_wins_ex = "Victoires (Mode Extrême, Minihunt/pré v2.3)",

  -- placements
  place_1 = "\\#e3bc2d\\[64T: 1ère Place]",
  place_2 = "\\#c5d8de\\[64T: 2ème Place]",
  place_3 = "\\#b38752\\[64T: 3ème Place]",
  place = "\\#e7a1ff\\[64T: %dème Place]", -- thankfully we don't go up to 21
  place_score_1 = "%dère",
  place_score_2 = "%dème",
  place_score_3 = "%dème",
  place_score = "%dème",

  -- chat roles
  role_lead = "\\#9a96ff\\[Dev Principal MH]",
  role_dev = "\\#96ecff\\[Dev MH]",
  role_cont = "\\#ff9696\\[Contributeur MH]",
  role_trans = "\\#ffd996\\[Traducteur MH]",

  -- command descriptions
  start_desc = "[CONTINUE|MAIN|ALT|RESET] - Lancez la partie; ajoutez \"continue\" pour ne pas être téléporté au début; ajoutez \"alt\" pour utiliser la sauvegarde alternative; ajoutez \"main\" pour utiliser la sauvegarde principale; ajoutez \"reset\" pour effacer la sauvegarde",
  add_desc = "[INT] - Ajoute aléatoirement le nombre indiqué de Coureur",
  random_desc = "[INT] - Sélectionne aléatoirement les Coureurs selon le nombre indiqué",
  lives_desc = "[INT] - Défini le nombre de vies que les Coureurs ont, de 0 à 99 (note: 0 vies équivaut toujours à 1 vie)",
  time_desc = "[NUM] - Défini le temps que les Coureurs doivent attendre pour sortir, en secondes",
  stars_desc = "[INT] - Défini le nombre d'étoiles que les Coureurs doivent ramasser pour sortir, de 0 à 7 (seulement en mode Étoiles Ramassées)",
  category_desc = "[INT] - Défini le nombre d'étoiles que les Coureurs doivent ramasser pour faire face à Bowser.",
  flip_desc = "[NAME|ID] - Inverse l'équipe du joueur spécifié",
  setlife_desc = "[NAME|ID|INT,INT] - Défini le nombre de vies spécifié pour le Coureur spécifié",
  leave_desc = "[NAME|ID] - Autorise le joueur spécifié à sortir du niveau si il est Coureur",
  mode_desc = "[NORMAL|SWAP|MINI] - Change le mode de jeu; swap inverse le rôle du Coureur mort avec celui du Chasseur qui l'a tué",
  starmode_desc = "[ON|OFF] - Active le Mode Étoiles Ramassées à la place du Mode Compte à Rebours",
  spectator_desc = "[ON|OFF] - Active la capacité des Chasseurs à devenir spectateurs",
  pause_desc = "[NAME|ID|ALL] - Met en pause le joueur spécifié, ou tous les joueurs si rien n'est spécifié",
  hunter_app_desc = "Change l'apparence des Chasseurs.",
  runner_app_desc = "Change l'apparence des Coureurs.",
  hack_desc = "[STRING] - Défini la Rom-Hack actuelle",
  weak_desc = "[ON|OFF] - Divise les frames d'invincibilités par 2 pour tous les joueurs",
  auto_desc = "[ON|OFF|NUM] - Lance la partie automatiquement",
  forcespectate_desc = "[NAME|ID|ALL] - Force le mode specatateur pour ce joueur ou tous les joueurs",
  desync_desc = "- Essaye de régler les erreurs de désyncronisation",
  stop_desc = "- Arrête la partie",
  default_desc = "- Défini les paramètres à ceux par défaut",
  blacklist_desc = "[ADD|REMOVE|LIST|RESET|SAVE|LOAD,COURSE,ACT] - Ajoute des étoiles à la liste noire pour MiniHunt",
  stalking_desc = "[ON|OFF] - Autorise la téléportation dans le niveau d'un Coureur avec /stalk",

  -- Blocky's menu
  main_menu = "Menu Principal",
  menu_mh = "MarioHunt",
  menu_mh_egg = "LuigiHunt",
  menu_settings_player = "Paramètres",
  menu_rules = "Règles",
  menu_lang = "Langue",
  menu_misc = "Autres",
  menu_stats = "Statistiques",
  menu_back = "Retour",
  menu_exit = "Fermer",

  menu_run_random = "Séléction Aléatoire des Coureurs",
  menu_run_add = "Ajouter des Coureurs",
  menu_run_lives = "Vies des Coureurs",
  menu_settings = "Paramètres de la Partie",

  menu_start = "Démarrer",
  menu_stop = "Arrêter",
  menu_save_main = "Suavegarde Principale",
  menu_save_alt = "Sauvegarde Alternative",
  menu_save_reset = "Effacer Sauvegarde Alternative",
  menu_save_continue = "Continuer (sans téléportation au départ)",
  menu_random = "Aléatoire",
  menu_campaign = "Campagne",

  menu_gamemode = "Mode de Jeu",
  menu_hunter_app = "Apparence des Chasseurs",
  menu_runner_app = "Apparence des Coureurs",
  menu_weak = "Mode Faible",
  menu_allow_spectate = "Autoriser le mode Spectateur",
  menu_star_mode = "Mode Étoiles Ramassées",
  menu_category = "Catégorie",
  menu_time = "Temps",
  menu_stars = "Étoiles",
  menu_auto = "Partie Auto",
  menu_blacklist = "Liste Noire MiniHunt",
  menu_default = "Réinitialiser par défaut",
  menu_defeat_bowser = "Battez %s",
  menu_allow_stalk = "Autoriser le 'Stalking'",
  menu_countdown = "Compte à rebours",
  menu_countdown_desc = "Combien de temps les Chasseurs doivent attendre",
  menu_voidDmg = "Dégâts du vide",
  menu_voidDmg_desc = "Dégâts infligés aux joueurs tombant dans le vide ou les sables mouvants.",
  menu_double_health = "Doubler la vie des Coureurs",
  menu_double_health_desc = "Les Coureurs ont 16 points de vie au lieu de 8.",

  menu_flip = "Inverser l'équipe",
  menu_spectate = "Passer en Mode Spectateur",
  menu_stalk = "Se téléporter au niveau",
  menu_stalk_desc = "Vous téléporte dans le niveau de ce joueur.",
  menu_pause = "Mettre en Pause",
  menu_forcespectate = "Forcer le Mode Spectateur",
  menu_allowleave = "Autoriser à sortir",
  menu_setlife = "Définir les vies",
  menu_players_all = "Tous les Joueurs",
  menu_target = "Mettre en tant que cible",
  menu_mute = "Muter",

  menu_timer = "Chronomètre de Speedrun",
  menu_timer_desc = "[ON|OFF] - Affiche un chronomètre en bas de l'écran dans les modes Standards.",
  menu_tc = "Tchat d'Équipe",
  menu_tc_desc = "Discutez seulement avec votre équipe.",
  menu_demon = "Green Demon", -- referring to the 1-Up
  menu_demon_desc = "Un 1-Up mortel vous poursuit en tant que Coureur.",
  menu_unknown = "???",
  menu_secret = "C'est un secret. Comment l'avez vous débloqué?",
  menu_hide_roles = "Cacher mes Rôles",
  menu_hide_roles_desc = "Cache vos rôles dans le tchat.",
  menu_hide_hud = "Cacher le HUD",
  hidehud_desc = "- Cache tous les éléments du HUD.",
  menu_season = "Changements Saisonniers",
  menu_season_desc = "Changements visuels amusants en fonction de la date.",

  menu_free_cam_desc = "Entrer en Caméra Libre en mode Spectateur.",
  menu_spectate_run = "Regarder le Coureur",
  menu_spectate_run_desc = "Regarde automatiquement le premier Coureur.",
  menu_exit_spectate = "Sortir du mode Spectateur",
  menu_exit_spectate_desc = "Vous fait sortir du mode spectateur.",
  menu_stalk_run = "Se téléporter au niveau du Coureur",
  menu_stalk_run_desc = "Vous téléporte dans le niveau dans lequel le 1er Coureur se situe.",
  menu_skip = "Passer",
  menu_skip_desc = "- Vote pour passer cette étoile en mode MiniHunt.",

  menu_spectate_desc = "Regarder ce joueur.",

  menu_blacklist_list = "Afficher Liste Noire",
  menu_blacklist_list_desc = "Liste la liste noire des étoiles en MiniHunt pour ce serveur.",
  menu_blacklist_save = "Sauvegarder la liste noire",
  menu_blacklist_save_desc = "Sauvegarde la liste noire pour les prochaines fois.",
  menu_blacklist_load = "Charger la liste noire",
  menu_blacklist_load_desc = "Charge la liste noire que vous avez sauvegardé.",
  menu_blacklist_reset = "Réinitialiser la liste noire",
  menu_blacklist_reset_desc = "Réinitialise la liste noire par celle par défaut.",
  menu_toggle_all = "Tout activer",
  
  -- unorganized
  lang_desc = "%s - Changer de langue",
  got_all_stars = "Vous avez assez d'étoiles !",
  spectate_desc = "[NAME|ID|OFF] - Devenez spectateur du joueur spécifié, en caméra libre si rien n'est spécifié ou désactivée si OFF est spécifié",
  tc_desc = "[ON|OFF|MSG] - Envoie les messages seulement à votre équipe; spécifiez ON pour l'appliquer à tous les messages",
  stars_in_area = "%d étoile(s) disponible(s) ici !",
  hard_info = "Intéressé par le \\#ff5a5a\\Mode Difficile \\#ffffff\\?\
  - 2x moins de PV\
  - L'eau ne régen pas\
  - \\#ff5a5a\\Une seule vie\
  \\#ffffff\\Tapez /hard ON dans le tchat si vous êtes prêt à relever le défi.",
  menu_first_timer = "Timer de mort pour le Leader",
  menu_popup_sound = "Sons de popups",
  stalk_desc = "[NAME|ID] - Vous téléporte dans le niveau du joueur spécifié, ou du premier Coureur",
  open_menu = "Tapez /mh ou appuyez sur L + Start pour ouvrir le menu",
  menu_nerf_vanish = "Nerf la casquette d'invisibilité",
  stalk = "Utilisez /stalk pour vous téléporter aux Coureurs!",
  menu_fast = "Actions plus rapides",
  new_record = "\\#ffff5a\\NOUVEAU RECORD!!!",
  anarchy_set_2 = "Les Chasseurs peuvent attaquer leurs coéquipiers",
  no_runners_added = "Aucun Coureur n'a été ajouté",
  menu_first_timer_desc = "Donne au leader un timer de mort dans Minihunt.",
  menu_nerf_vanish_desc = "Nerf la casquette d'invisibilité en la rendant commutable et en réduisant sa durée d'utilisation.",
  unstuck = "Tentative de réparer l'État",
  use_out = "Faites /mh out pour faire sortir tout le monde de ce niveau",
  menu_list_settings = "Paramètre des Listes",
  anarchy_set_3 = "Les joueurs peuvent attaquer leurs coéquipiers",
  menu_fast_desc = "Vous allez régénerer votre vie, lancer des objets et ouvrir les portes plus rapidement.",
  dmgAdd_set = "Les Coureurs font maintenant prendre %d de dégats supplémentaires lors du PVP.",
  hard_desc = "[EX|ON|OFF,ON|OFF] - Active le mode difficile pour vous-même",
  menu_dmgAdd = "Coureur Dégâts PVP +",
  menu_anarchy_desc = "Permet aux équipes spécifiées d'attaquer leurs coéquipiers.",
  rules_desc = "- Affiche les règles de MarioHunt",
  rules_desc_egg = "- Affiche les règles de LuigiHunt",
  menu_anarchy = "Dégâts alliés",
  mh_desc = "[COMMAND,ARGS] - Exécute des commandes; Tapez rien ou \"menu\" pour ouvrir le menu",
  vanish_custom = "Maintenez \\#ffff5a\\B\\#ffffff\\ pour devenir invisible!",
  menu_list_settings_desc = "Liste tous les paramètres pour ce lobby.",
  page = "\\#ffff5a\\Page %d/%d", -- no translation needed for this one
  anarchy_set_1 = "Les Coureurs peuvent attaquer leurs coéquipiers",
  anarchy_set_0 = "Les joueurs ne peuvent pas attaquer leurs coéquipiers",
  menu_dmgAdd_desc = "Ajoute cette quantité de dégâts supplémentaires aux attaques contre les Coureurs.",
  mini_score = "Score: %d", -- no translation needed for this one
  stats_desc = "- Afficher/Cacher la liste des stats",
  target_desc = "[NAME|ID] - Défini ce Coureur en tant que cible, ce qui affiche sa position tout le temps.",
  hunter_outline = "Tous les Chasseurs ont un contour",
  runner_sparkle = "Tous les Coureurs scintillent",
  runner_glow = "Tous les Coureurs brillent",
  runner_outline = "Tous les Coureurs ont un contour",
  dmgAdd_set_ohko = "Les Coureurs mourront en un coup",
  voidDmg_set = "Les joueurs prendront %d dégâts s'ils tombent dans le vide ou les sables mouvants.",
  voidDmg_set_ohko = "Les joueurs mourront instantanément s'ils tombent dans le vide ou les sables mouvants.",
  target_hunters_only = "Seuls les Chasseurs peuvent mettre une cible.",

  -- mute
  muted = "\\#ffff00\\%s\\#ffffff\\ a été rendu muet par \\#ffff00\\%s\\#ffffff\\.",
  unmuted = "\\#ffff00\\%s\\#ffffff\\ a retrouvé la parole grâce à \\#ffff00\\%s\\#ffffff\\.",
  you_muted = "Vous avez rendu muet \\#ffff00\\%s\\#ffffff\\.",
  you_unmuted = "Vous avez redonné la parole à \\#ffff00\\%s\\#ffffff\\.",
  mute_auto = "\\#ffff00\\%s\\#ffffff\\ a été rendu muet automatiquement.",

  mute_desc = "[NAME|ID] - Rend muet un joueur, les empêchant de parler",
  unmute_desc = "[NAME|ID] - Rétablit la parole d'un joueur",
  out_desc = "- Fait sortir tout le monde du niveau",

  -- updater
  up_to_date = "\\#00ffff\\Mario\\#ff5a5a\\Hunt\\#ffffff\\ est à jour!",
  up_to_date_egg = "\\#5aff5a\\Luigi\\#ff5a5a\\Hunt\\#ffffff\\ est à jour!",
  has_update = "Une mise à jour est disponible pour \\#00ffff\\Mario\\#ff5a5a\\Hunt\\#ffffff\\!",
  has_update_egg = "Une mise à jour est disponible pour \\#5aff5a\\Luigi\\#ff5a5a\\Hunt\\#ffffff\\!",

  -- version 2.6 stuff I don't feel like sorting
  leave_error = "%s\\#ffa0a0\\ est parti à cause d'une erreur.",
  hunter_color = "Tous les chasseurs ont la palette Bordeaux",
  runner_color = "Tous les coureurs ont la palette Azur",
  stat_playtime = "Temps de jeu (Heures)",
  stat_parkour_time = "Meilleur Temps Parcours",
  stat_parkour_time_omm = "Meilleur Temps Parcours (OMM)",
  stat_parkour_time_other = "Meilleur Temps Parcours (Moveset)",
  menu_free_roam = "Accès Libre",
  menu_free_roam_desc = "Désactive le nombre d'étoile nécessaire pour accéder à la plupart des niveaux et ouvre toutes les portes à clés.",
  menu_radar = "Radar",
  menu_radar_desc = "Affiche à l'écran l'emplacement des Coureurs et des objets importants.",
  menu_minimap = "Minimap",
  menu_minimap_desc = "Affiche la carte de tout le niveau.",
  menu_romhack_cam = "Romhack Cam",
  menu_romhack_cam_desc = "Active la Romhack Cam partout.",
  menu_star_heal = "Soin Étoile",

  -- v2.6.1
  menu_star_setting = "Obtention d'étoile", -- from base
  star_leave = "Sortir",
  star_stay = "Rester",
  star_nonstop = "Non-Stop",
}

langdata["it"] = -- by Mr. L-ore
{
  -- fullname for auto select (make sure this matches in-game under Misc -> Languages)
  fullname = "Italian",

  -- name in the built-in menu
  name_menu = "Italiano",

  -- global command info
  to_switch = "Scrvi \"/lang %s\" per cambiare lingua",
  switched = "Cambiata ad Italiano!", -- Replace "English" with the name of this language
  rule_command = "Scrivi /rules per mostrare di nuovo questo messaggio",
  open_menu = "Scrivi /mh o premi L + Start per aprire il menu",
  stalk = "Usa /stalk per teletrasportarti dai Corridori!",
  rules_desc = "- Mostra le regole di MarioHunt",
  rules_desc_egg = "- Mostra le regole di LuigiHunt",
  mh_desc = "[COMMAND,ARGS] - Esegue i comandi; scrivi \"menu\" o lascia vuoto per aprire il menu",
  lang_desc = "%s - Cambia lingua",
  hard_desc = "[EX|ON|OFF,ON|OFF] - Imposta la difficolta difficile per te stesso",
  tc_desc = "[ON|OFF|MSG] - Manda messaggi solo alla tua squadra; attivalo per influenzare tutti i messaggi",
  stats_desc = "- Mostra/nascondi tavola delle statistiche",
  stalk_desc = "[NAME|ID] - Teletrasportati al livello spegificato, o a quello del Corridore in prima posizione",
  spectate_desc = "[NAME|ID|OFF] - Guarda il giocatore specificato, muoviti in giro liberamente, o disattiva quest'opzione", -- not to be confused with spectator_desc
  target_desc = "[NAME|ID] - Imposta questo Corridore come tuo bersaglio, e vedi dove si trova in tempo reale.",

  -- roles
  runner = "Corridore",
  runners = "Corridori",
  short_runner = "Corr.", -- unused
  hunters = "Cacciatori",
  hunter = "Cacciatore",
  spectator = "Spettatore",
  player = "Giocatore",
  players = "Giocatori",
  all = "Tutti",

  -- rules
  --[[
    This is laid out as follows:
    {welcome|welcome_mini}
    {runners}{shown_above|thats_you}{any_bowser|collect_bowser|mini_collect}
    {hunters}{thats_you}{all_runners|any_runners}
    {rule_lives_one|rule_lives}{time_needed|stars_needed}{become_hunter|become_runner}
    {infinite_lives}{spectate}
    {banned_glitchless|banned_general}{fun}

    I highly recommend testing this in-game
    Also:
    \\#ffffff\\ = white (default)
    \\#00ffff\\ = cyan (for Runner team name)
    \\#ff5a5a\\ = red (for Hunter team name and popups)
    \\#ffff5a\\ = yellow
    \\#5aff5a\\ = green
    \\#b45aff\\ = purple (for Extreme Mode)
  ]]
  welcome = "Benvenuto alla \\#00ffff\\Mario\\#ff5a5a\\Hunt\\#ffffff\\! COME GIOCARE:",
  welcome_mini = "Benvenuto alla \\#ffff5a\\Mini\\#ff5a5a\\Hunt\\#ffffff\\! COME GIOCARE:",
  welcome_egg = "Benvenuto alla \\#5aff5a\\Luigi\\#ff5a5a\\Hunt\\#ffffff\\! COME GIOCARE:",
  all_runners = "Sconfiggi tutti i \\#00ffff\\Corridori\\#ffffff\\.",
  any_runners = "Sconfiggi dei \\#00ffff\\Corridori\\#ffffff\\.",
  shown_above = "(mostrato sopra)",
  any_bowser = "Sconfiggi %s in \\#ffff5a\\qualsiasi\\#ffffff\\ modo sia necessario.",
  collect_bowser = "Ottieni \\#ffff5a\\%d stella/e\\#ffffff\\ e sconfiggi %s.",
  mini_collect = "Sii il primo ad \\#ffff5a\\ottenere la stella\\#ffffff\\.",
  collect_only = "Ottieni \\#ffff5a\\%d stella/e\\#ffffff\\.",
  thats_you = "(sei tu!)",
  banned_glitchless = "VIETATO: Il cross teaming, il BLJ, l'attraversamento dei muri, perdere tempo, camperare.",
  banned_general = "VIETATO: Il cross teaming, perdere tempo, camperare.",
  time_needed = "%d:%02d per abbandonare un'area; ottieni le stelle per diminuire",
  stars_needed = "%d stella/e necessarie per abbandonare un'area",
  become_hunter = "Diventi un \\#ff5a5a\\Cacciatore\\#ffffff\\ quando vieni sconfitto",
  become_runner = "Sconfiggi un \\#00ffff\\Corridore\\#ffffff\\ per diventarne uno",
  infinite_lives = "Vite infinite",
  spectate = "scrivi \"/spectate\" per assistere alla partita",
  mini_goal = "\\#ffff5a\\Chi tiesce a prendere più stelle in %d:%02d vince!\\#ffffff\\",
  fun = "Divertiti!",

  -- hud, extra desc, and results text (%s is a placeholder for names, and %d is a placeholder for a number)
  win = "%s\\#ffffff\\ Vince!", -- team name is placed here
  can_leave = "\\#5aff5a\\Puoi uscire",
  cant_leave = "\\#ff5a5a\\Non puoi uscire",
  time_left = "Potrai uscire tra \\#ffff5a\\%d:%02d",
  stars_left = "Ti servono \\#ffff5a\\%d stella/e\\#ffffff\\ per uscire",
  in_castle = "Nel Castello",
  until_hunters = "%d secondo/i prima che i \\#ff5a5a\\Cacciatori\\#ffffff\\ inizino",
  until_runners = "%d secondo/i prima che i \\#00ffff\\Corridori\\#ffffff\\ inizino",
  lives_one = "1 vita",
  lives = "%d vite",
  stars_one = "1 stella",
  stars = "%d stelle",
  no_runners = "Nessun \\#00ffff\\Corridore!",
  camp_timer = "Continua a muoverti! \\#ff5a5a\\(%d)",
  game_over = "La partita è finita!",
  winners = "Vincitori: ",
  no_winners = "\\#ff5a5a\\Nessun vincitore!",
  death_timer = "Morte",
  mini_score = "Punteggio: %d",
  new_record = "\\#ffff5a\\NUOVO RECORD!!!",
  on = "\\#5aff5a\\ON",
  off = "\\#ff5a5a\\OFF",
  frozen = "Congelato per %d",

  -- popups
  lost_life = "%s\\#ffa0a0\\ ha perso una vita!",
  lost_all = "%s\\#ffa0a0\\ ha perso tutte le vite!",
  now_role = "%s\\#ffa0a0\\ è ora un %s\\#ffa0a0\\.",
  got_star = "%s\\#ffa0a0\\ ha ottenuto una stella!",
  got_key = "%s\\#ffa0a0\\ ha ottenuto una chiave!",
  rejoin_start = "%s\\#ffa0a0\\ ha due minuti per rientrare.",
  rejoin_success = "%s\\#ffa0a0\\ è rientrato in tempo!",
  rejoin_fail = "%s\\#ffa0a0\\ non è rientrato in tempo.",
  using_ee = "Questa è solo la Modalità Estrema.",
  not_using_ee = "Questa è solo la Versione Standard.",
  killed = "%s\\#ffa0a0\\ ha ucciso %s!",
  sidelined = "%s\\#ffa0a0\\ ha dato il colpo di grazia a %s!",
  paused = "Sei stato messo in pausa.",
  unpaused = "Non sei più in pausa.",
  kill_combo_2 = "%s\\#ffa0a0\\ ha effettuato una \\#ffff5a\\doppia\\#ffa0a0\\ uccisione!",
  kill_combo_3 = "%s\\#ffa0a0\\ ha effettuato una \\#ffff5a\\tripla\\#ffa0a0\\ uccisione!",
  kill_combo_4 = "%s\\#ffa0a0\\ ha effettuato una \\#ffff5a\\quadrupla\\#ffa0a0\\ uccisione!",
  kill_combo_5 = "%s\\#ffa0a0\\ ha effettuato una \\#ffff5a\\quintupla\\#ffa0a0\\ uccisione!",
  kill_combo_large = "\\#ffa0a0\\Wow! %s\\#ffa0a0\\ ha effettuato \\#ffff5a\\%d\\#ffa0a0\\ uccisioni di fila!",
  set_hack = "Hack impostata a %s",
  incompatible_hack = "ATTENZIONE: l'Hack non è compatibile!",
  vanilla = "Usando il gioco base",
  omm_detected = "OMM Rebirth rilevato!",
  omm_bad_version = "\\#ff5a5a\\OMM Rebirth è datato!\\#ffffff\\\nVersione richiesta: %s\nLa tua versione: %s",
  warp_spam = "Rallenta coi teletrasporti!",
  no_valid_star = "Impossibile trovare una stella corrispondente!",
  custom_enter = "%s\\#ffffff\\ è entrato in\n%s", -- same as coop
  vanish_custom = "Tieni premuto \\#ffff5a\\B\\#ffffff\\ per scomparire!",
  got_all_stars = "Hai abbastanza stelle!",
  unstuck = "Tentativo di sistemare lo stato",
  use_out = "Usa /mh out per teletrasportare tutti fuori dall'area",
  stars_in_area = "%d stella/e disponibili qui!",
  demon_unlock = "Modalità demone verde sbloccata!",
  hit_switch_red = "%s\\#ffa0a0\\ ha colpito il\n\\#df5050\\Bottone Rosso!", -- dark red (unique)
  hit_switch_green = "%s\\#ffa0a0\\ ha colppito il\n\\#50b05a\\Bottone Verde!", -- dark green (unique)
  hit_switch_blue = "%s\\#ffa0a0\\ ha colpito il\n\\#5050e3\\Bottone Blu!", -- dark blue (unique)
  hit_switch_yellow = "%s\\#ffa0a0\\ ha colpito il\n\\#e3b050\\Bottone Giallo...", -- orangeish (unique)

  -- command feedback
  not_mod = "Sciocco, non hai l'AUTORITÀ di eseguire questo comando!",
  no_such_player = "Non esiste un giocatore con quel nome",
  bad_id = "ID giocatore invalido!",
  command_disabled = "questo comando è disabilitato.",
  change_setting = "cambiamento delle opzioni:",
  you_are_muted = "Sei stato silenziato.",

  -- more command feedback
  bad_param = "Parametri non validi!",
  bad_command = "Comando non valido!",
  error_no_runners = "Impossibile partire con 0 Corridori!",
  set_team = "la squadra di %s è stata impostata a '%s'", -- First %s is player name, second is team name (now unused)
  not_started = "La partita non è ancora iniziata",
  set_lives_one = "%s ha 1 vita",
  set_lives = "%s ha %d vite",
  not_runner = "%s non è un Corridore",
  may_leave = "%s può abbandonare",
  must_have_one = "Deve esserci almeno 1 Cacciatore",
  added = "Aggiunti i Corridori: ", -- list comes afterward
  no_runners_added = "Nessun Corridore aggiunto",
  runners_are = "I Corridori sono: ",
  set_lives_total = "Vite dei corridori impostate a %d",
  wrong_mode = "Non disponibile in questa modalità",
  need_time_feedback = "I corridori possono andarsene tra %d secondo/i",
  game_time = "La partita durerà %d secondo/i",
  need_stars_feedback = "I corridori hanno bisogno di %d stella/e",
  new_category = "Ora questa è una %d star run",
  new_category_any = "Ora questa è una any%",
  mode_normal = "In modalità Normale",
  mode_swap = "In modalità Invertita",
  mode_mini = "In modalità MiniHunt",
  using_stars = "Usando le stelle ottenute",
  using_timer = "Usando il timer",
  can_spectate = "Adesso i Cacciatori potranno assistere alla partita",
  no_spectate = "Adesso i Cacciatori non potranno più assistere",
  all_paused = "Tutti i giocatori messi in pausa",
  all_unpaused = "Tutti i giocatori non sono più in pausa",
  player_paused = "%s è stato messo in pausa",
  player_unpaused = "%s non è più in pausa",
  hunter_metal = "Tutti i cacciatori sono metallici",
  hunter_normal = "Tutti i cacciatori sono normali",
  hunter_glow = "Tutti i cacciatori si illuminano di rosso",
  hunter_outline = "Tutti i cacciatori sono evidenziati",
  runner_sparkle = "Tutti i corridori brillano",
  runner_normal = "Tutti i corridori sono normali",
  runner_glow = "Tutti i corridori si illuminano",
  runner_outline = "Tutti i corridori sono evidenziati",
  now_weak = "Tutti i giocatori hanno metà dei fotogrammi di invincibilità",
  not_weak = "Tutti i giocatori hanno i fotogrammi di invincibilità normali",
  auto_on = "Le partite inizieranno automaticamente",
  auto_off = "Le partite non inizieranno automaticamente",
  force_spectate = "Tutti dovranno assistere",
  force_spectate_off = "Non si è più forzati ad assistere",
  force_spectate_one = "%s deve assistere",
  force_spectate_one_off = "%s non deve più assistere",
  blacklist_add = "%s è stata bloccata",
  blacklist_remove = "%s è stata sbloccata",
  blacklist_add_already = "Quella stella è già stata bloccata.",
  blacklist_remove_already = "Quella stella o area non è bloccata.",
  blacklist_remove_invalid = "Impossibile bloccare quellala stella del livello.",
  blacklist_list = "Bloccate:",
  blacklist_reset = "Lista delle stelle bloccate reimpostata!",
  blacklist_save = "Lista delle stelle bloccate salvata!",
  blacklist_load = "Lista delle stelle bloccate caricata!",
  anarchy_set_0 = "I Giocatori non possonno attaccare i loro compagni di squadra",
  anarchy_set_1 = "I Corridori possonno attaccare i loro compagni di squadra",
  anarchy_set_2 = "I Cacciatori possonno attaccare i loro compagni di squadra",
  anarchy_set_3 = "I Giocatori possonno attaccare i loro compagni di squadra",
  dmgAdd_set = "I Corridori prenderanno %d danni extra dagli attacchi avversari.",
  dmgAdd_set_ohko = "I Corridori moriranno in un solo colpo",
  voidDmg_set = "I giocatori prenderanno %d danni se cadono nel vuoto o nelle sabbie mobili.",
  voidDmg_set_ohko = "I giocatori moriranno istantaneamente se cadono nel vuoto o nelle sabbie mobili.",
  target_hunters_only = "Solo i Cacciatori possono impostare un bersaglio.",
  muted = "\\#ffff00\\%s\\#ffffff\\ è stato mutato da \\#ffff00\\%s\\#ffffff\\.",
  unmuted = "\\#ffff00\\%s\\#ffffff\\ è stato smutato da\\#ffff00\\%s\\#ffffff\\.",
  you_muted = "Hai mutato \\#ffff00\\%s\\#ffffff\\.",
  you_unmuted = "Hai smutato \\#ffff00\\%s\\#ffffff\\.",
  mute_auto = "\\#ffff00\\%s\\#ffffff\\ è stato mutato automaticamente.",

  -- team chat
  tc_toggle = "La chat di squadra è %s!",
  to_team = "\\#8a8a8a\\Squadra: ",
  from_team = "\\#8a8a8a\\ (squadra): ",

  -- vote skip
  vote_skip = "%s\\#dcdcdc\\ Ha votato per saltare questa stella",
  vote_info = "Scrivi /skip per votare",
  vote_pass = "Il voto è stato approvato!",
  already_voted = "Hai già votato.",

  -- hard mode
  hard_notice = "Psst, prova a scrivere /hard...",
  extreme_notice = "Psst, prova a scrivere /hard ex...",
  hard_toggle = "La \\#ff5a5a\\Modalità Difficile\\#ffffff\\ è %s!",
  extreme_toggle = "La \\#b45aff\\Modalità Estrema\\#ffffff\\ è %s!",
  hard_info = "Ti interessa la \\#ff5a5a\\Modalità Difficile\\#ffffff\\?"..
  "\n- Metà energia"..
  "\n- Niente cura dall'acqua"..
  "\n- \\#ff5a5a\\Una vita"..
  "\n\\#ffffff\\Scrivi /hard ON se sei pronto per la sfida.",
  extreme_info = "Ti interessa la \\#b45aff\\Modalità Estrema\\#ffffff\\? Che sciocco."..
  "\n- Una vita"..
  "\n- Un'energia"..
  "\n- \\#b45aff\\Cronometro della Morte\\#ffffff\\; Raccogli monete per aumentare"..
  "\nSe non ti spaventa, scrivi /hard ex ON.",
  no_hard_win = "Le tue vittorie in Difficile o Estrema non saranno contate per questa partita.",
  hard_mode = "Modalità Difficile",
  extreme_mode = "Modalità Estrema",
  hard_info_short = "Metà energia, niente cura dall'acqua, e una vita.",
  extreme_info_short = "Un'energia, una vita, ed un Cronometro della Morte.",

  -- spectator
  hunters_only = "Solo i cacciatori possono assistere!",
  spectate_disabled = "Opzione assisti disattivata!",
  timer_going = "Can't spectate during timer!", -- now unused
  spectate_self = "Non puoi assistere a te stesso!",
  spectator_controls = "Controlli:"..
  "\nDPAD-UP: Nascondi la HUD"..
  "\nDPAD-DOWN: Vista giocatore/Telecamera libera"..
  "\nDPAD-LEFT / DPAD-RIGHT: Cambia giocatore"..
  "\nJOYSTICK: Muoviti"..
  "\nA: vai su"..
  "\nZ: vai giu"..
  "\nScrivi \"/spectate OFF\" per annullare",
  spectate_off = "Non stai più assistendo.",
  empty = "VUOTO (%d )",
  free_camera = "TELECAMERA LIBERA",
  spectate_mode = "- MODALITÀ SPETTATORE -",
  is_spectator = '* IL GIOCATORE È UNO SPETTATORE  *',

  -- stats
  disp_wins_one = "%s\\#ffffff\\ Ha vinto 1 volta come \\#00ffff\\Corridore\\#ffffff\\!",
  disp_wins = "%s\\#ffffff\\ ha vinto %d volte come \\#00ffff\\Corridore\\#ffffff\\!",
  disp_kills_one = "%s\\#ffffff\\ has killed 1 player!", -- unused
  disp_kills = "%s\\#ffffff\\ ha ucciso %d giocatori!",
  disp_wins_hard_one = "%s\\#ffffff\\ Ha vinto 1 volta come \\#ffff5a\\Corridore\\#ffffff\\ in \\#ff5a5a\\Modalità Difficile!\\#ffffff\\",
  disp_wins_hard = "%s\\#ffffff\\ ha vinto %d volte come \\#ffff5a\\Corridore\\#ffffff\\ in \\#ff5a5a\\Modalità Difficile!\\#ffffff\\",
  disp_wins_ex_one = "%s\\#ffffff\\ Ha vinto 1 volta come \\#b45aff\\Corridore\\#ffffff\\ in \\#b45aff\\Modalità Estrema!\\#ffffff\\",
  disp_wins_ex = "%s\\#ffffff\\ ha vinto %d volte come \\#b45aff\\Corridore\\#ffffff\\ in \\#b45aff\\Modalità Estrema!\\#ffffff\\",
  -- for stats table
  stat_wins_standard = "Vittorie",
  stat_wins = "Vittorie (Minihunt/pre v2.3)",
  stat_kills = "Uccisioni",
  stat_combo = "Serie di uccisioni maggiore",
  stat_wins_hard_standard = "Vittorie (Hard Mode)",
  stat_wins_hard = "Vittorie (Modalità Difficile, MiniHunt/pre v2.3)",
  stat_mini_stars = "Stelle massime in una pasrtita di MiniHunt",
  stat_placement = "Piazzamento 64 Tour",
  stat_wins_ex_standard = "Vittorie (Modalità Estrema)",
  stat_wins_ex = "Vittorie (Modalità Estrema, MiniHunt/pre v2.3)",

  -- placements
  place_1 = "\\#e3bc2d\\[64T: 1o Posto]",
  place_2 = "\\#c5d8de\\[64T: 2o Posto]",
  place_3 = "\\#b38752\\[64T: 3o Posto]",
  place = "\\#e7a1ff\\[64T: %do Posto]", -- thankfully we don't go up to 21
  place_score_1 = "%do",
  place_score_2 = "%do",
  place_score_3 = "%do",
  place_score = "%do",

  -- chat roles
  role_lead = "\\#9a96ff\\[Lead MH Dev]",
  role_dev = "\\#96ecff\\[MH Dev]",
  role_cont = "\\#ff9696\\[Contributore a MH]",
  role_trans = "\\#ffd996\\[Traduttore di MH]",

  -- command descriptions
  page = "\\#ffff5a\\Pagina %d/%d", -- page for mariohunt command
  start_desc = "[CONTINUE|MAIN|ALT|RESET] - Inizia la partita; aggiungi \"continue\" per non partire dall'inizio; aggungi \"alt\" per un file di salvataggio alternativo; aggiungi \"main\" per il file di salvataggio principale; aggiungi \"reset\" per ripristinare il file",
  add_desc = "[INT] - Aggiungi il numero di corridori casuali specificato",
  random_desc = "[INT] - Sceglie casualmente il numero di corridori specificato",
  lives_desc = "[INT] - Imposta il numero di vite dei Corridori, da 0 a 99 (n.b.: 0 vite equivale ad 1 vita)",
  time_desc = "[NUM] - Imposta il tempo entro cui i Corridori devono scappare, in secondi, o per la durata della partita in MiniHunt.",
  stars_desc = "[INT] - Imposta il numero di stelle che il Corridore deve aver per scappare, da 1 a 7 (solo per la modalità stelle)",
  category_desc = "[INT] - Imposta il numero di stelle che i Corridori devono avere per affrontare Bowser.",
  flip_desc = "[NAME|ID] - Cambia la squadra di un giocatore",
  setlife_desc = "[NAME|ID|INT,INT] - Imposta il numero di vite per un corridore in particolare",
  leave_desc = "[NAME|ID] - Permetti ad un giocatore specifico di abbandonare il livello in caso fosse un corridore",
  mode_desc = "[NORMAL|SWAP|MINI] - Cambia modalità; Swap converte i corridori quando muoiono",
  starmode_desc = "[ON|OFF] - Attiva o disattiva l'utilizzo delle stelle piuttosto che del tempo",
  spectator_desc = "[ON|OFF] - Attiva o disattiva l'abilità dei cacciatori di assistere",
  pause_desc = "[NAME|ID|ALL] - Attiva o disattiva lo stato di pasua per un giocatore specificato, o tutti se non specificato",
  hunter_app_desc = "Cambia l'Aspetto dei Cacciatori.",
  runner_app_desc = "Cambia l'Aspetto dei Corridori.",
  hack_desc = "[STRING] - Imposta l'attuale rom hack",
  weak_desc = "[ON|OFF] - Dimezza i fotogrammi di invincibilità per tutti",
  auto_desc = "[ON|OFF|NUM] - Inizia automaticamente",
  forcespectate_desc = "[NAME|ID|ALL] - Attiva o disattica la modalità spettatore forzata per uno o tutti i giocatori",
  desync_desc = "- Prova a sistemare gli errori di desinc.",
  stop_desc = "- Ferma il gioco",
  default_desc = "- Ripristina le impostazioni",
  blacklist_desc = "[ADD|REMOVE|LIST|RESET|SAVE|LOAD,COURSE,ACT] - Blocca stelle in MiniHunt",
  stalking_desc = "[ON|OFF] - Permetti il teletrasporto al livello di un Corridore con /stalk",
  mute_desc = "[NAME|ID] - Muta un giocatore, impedendogli di scrivere",
  unmute_desc = "[NAME|ID] - Smuta un giocatore, permettendogli di scrivere",
  out_desc = "- Butta tutti fuori da un'area",

  -- Blocky's menu
  main_menu = "Menu Principale",
  menu_mh = "MarioHunt",
  menu_mh_egg = "LuigiHunt",
  menu_settings_player = "Impostazioni",
  menu_rules = "Regole",
  menu_list_settings = "Lista delle impostazioni",
  menu_list_settings_desc = "Mostra la lista delle impostazioni per la stanza.",
  menu_lang = "Lingua",
  menu_misc = "Altro",
  menu_stats = "Statistiche",
  menu_back = "Indietro",
  menu_exit = "Esci",

  menu_run_random = "Corridori Casuali",
  menu_run_add = "Aggiungi Corridori",
  menu_run_lives = "Vite dei Corridori",
  menu_settings = "Impostazioni della partita",

  menu_start = "Inizia",
  menu_stop = "Ferma",
  menu_save_main = "Principale",
  menu_save_alt = "File Alternativo",
  menu_save_reset = "Ripristina File Alternativo",
  menu_save_continue = "Continua (non teletraspora indietro)",
  menu_random = "Casuale",
  menu_campaign = "Storia",
  menu_coop = "Cooperativa",

  menu_gamemode = "Modalità",
  menu_hunter_app = "Aspetto del Cacciatore",
  menu_runner_app = "Aspetto del Corridore",
  menu_weak = "Modalità Debole",
  menu_allow_spectate = "Permetti Spettatori",
  menu_star_mode = "Modalità Stella",
  menu_category = "Categoria",
  menu_time = "Tempo",
  menu_stars = "Stelle",
  menu_auto = "Auto Game",
  menu_blacklist = "MiniHunt Bloccate",
  menu_default = "Ripristina",
  menu_anarchy = "Fuoco Amico",
  menu_anarchy_desc = "Permette ai giocatori di attaccare i compagni di squadra.",
  menu_dmgAdd = "Danno ai Corridori Aumentato", -- DMG is "damage"
  menu_dmgAdd_desc = "Agguinge il quantitativo al danno inflitto ai Corridori",
  menu_nerf_vanish = "Depotenzia Cappello Invisibile", -- Nerf, as in to reduce power for balancing
  menu_nerf_vanish_desc = "Depotenzia il cappello invisibile rendendolo disattivabile e diminuendo la durata.",
  menu_first_timer = "Cronometro della Morte per il 1o",
  menu_first_timer_desc = "Da' al giocatore in prima posizione nella MiniHunt un cronometro della morte.",
  menu_defeat_bowser = "Sconfiggi %s",
  menu_allow_stalk = "Permetti lo 'Stalking'",
  menu_countdown = "Conto alla rovescia",
  menu_countdown_desc = "Tempo di attesa per i Cacciatori.",
  menu_voidDmg = "danno del Vuoto",
  menu_voidDmg_desc = "danno inflitto ai giocatori che cadono nel vuoto o nelle sabbie mobili.",
  menu_double_health = "Energia dei Corridori Doppia",
  menu_double_health_desc = "I Corridoi hanno 16 di energia piuttosto che 8.",

  menu_flip = "Cambia Squadra",
  menu_spectate = "Assisti",
  menu_stalk = "Teletrasporto all'Area",
  menu_stalk_desc = "Teletraspotati all'area di un giocatore.",
  menu_pause = "Pausa",
  menu_forcespectate = "Forza Modalità Spettatore",
  menu_allowleave = "Permetti di Uscire",
  menu_setlife = "Imposta Vite",
  menu_players_all = "Tutti i Giocatori",
  menu_target = "Imposta come Bersaglio",
  menu_mute = "Muta",

  menu_timer = "Cronometro Speedrun",
  menu_timer_desc = "[ON|OFF] - Mostra un cronometro speedrun in basso nelle Modalità Standard.",
  menu_tc = "Chat di Squadra",
  menu_tc_desc = "Chat con solo la tua squadra.",
  menu_demon = "Demone Verde", -- referring to the 1-Up
  menu_demon_desc = "Una 1-Up inseguirà i Corridori.",
  menu_unknown = "???",
  menu_secret = "È un segreto. Come lo sblocchi?",
  menu_hide_roles = "Nascondi il Mio Ruolo",
  menu_hide_roles_desc = "Impedisci che il to ruolo vega mostrato in chat.",
  menu_hide_hud = "Nascondi HUD",
  hidehud_desc = "- Nascondi gli elementi della HUD.",
  menu_fast = "Azioni Più Veloci",
  menu_fast_desc = "Ti rialzerai, lancerai, ed aprirai le porte più velocemente.",
  menu_popup_sound = "Suoni dei Popup",
  menu_season = "Cambiamenti Stagionali",
  menu_season_desc = "Piccoli dettagli che dipendono dalla data.",

  menu_free_cam_desc = "Attiva la telecamera libera in modalità spettatore.",
  menu_spectate_run = "Assisti ad un Corridore",
  menu_spectate_run_desc = "Assisti automaticamente al corridore in prima posizione.",
  menu_exit_spectate = "Esci dalla Modalità Spettatore",
  menu_exit_spectate_desc = "Abbastanza esplicito.",
  menu_stalk_run = "Teletrasporto al Livello del corridore",
  menu_stalk_run_desc = "Teletrasportati al livello del corridore in prima posizione.",
  menu_skip = "Salta",
  menu_skip_desc = "- Vota per saltare una stella in MiniHunt.",

  menu_spectate_desc = "Assisti a questo giocatore.",

  menu_blacklist_list = "Lista Stelle Bloccate",
  menu_blacklist_list_desc = "Lista delle stelle bloccate in MiniHunt per questo server.",
  menu_blacklist_save = "Salva Lista",
  menu_blacklist_save_desc = "Salva la tua lista delle stelle bloccate.",
  menu_blacklist_load = "Carica Lista",
  menu_blacklist_load_desc = "Carica la tua lista delle stelle bloccate.",
  menu_blacklist_reset = "Ripristina Lista",
  menu_blacklist_reset_desc = "Ripristina la lista delle stelle bloccate.",
  menu_toggle_all = "Attiva tutte",

  -- updater
  up_to_date = "\\#00ffff\\Mario\\#ff5a5a\\Hunt\\#ffffff\\ è aggiornata!",
  up_to_date_egg = "\\#5aff5a\\Luigi\\#ff5a5a\\Hunt\\#ffffff\\ è aggiornata!",
  has_update = "Aggiornamento disponibile per \\#00ffff\\Mario\\#ff5a5a\\Hunt\\#ffffff\\!",
  has_update_egg = "Aggiornamento disponibile per \\#5aff5a\\Luigi\\#ff5a5a\\Hunt\\#ffffff\\!",

  -- v2.6 stuff I don't feel like sorting
  leave_error = "%s\\#ffa0a0\\ è uscito a causa di un errore.",
  hunter_color = "Tutti i cacciatori useranno la palette Borgogna", -- (check official lang for palette name)
  runner_color = "Tutti i corridori useranno la palette Azzurra", -- (check official lang for palette name)
  stat_playtime = "Tempo di gioco totale (ore)",
  stat_parkour_time = "Record nel Parkour",
  stat_parkour_time_omm = "Record nel Parkour (OMM)",
  stat_parkour_time_other = "Record nel Parkour (Moveset)",
  menu_free_roam = "Esplorazione Libera",
  menu_free_roam_desc = "Rimuove la necessità di stelle o chiavi per la maggior parte delle porte.",
  menu_radar = "Radar",
  menu_radar_desc = "Mostra la posizione dei corridori e degli oggetti importanti.",
  menu_minimap = "Minimappa",
  menu_minimap_desc = "Mostra una mappa di tutto il livello.",
  menu_romhack_cam = "Telecamera Romhack", -- (cam is short for camera)
  menu_romhack_cam_desc = "Abilita permanentemente la telecamera della romhack.", -- (cam is short for camera)
  menu_star_heal = "Stelle Curative",

  -- v2.6.1
  menu_star_setting = "A stella collezzionata", -- from base
  star_leave = "Lascia",
  star_stay = "Rimani",
  star_nonstop = "Non-Stop",
}

-- Had to replace the characters that didn't exist
langdata["ro"] = -- by N64 (not to be mistaken for N64-Mario)
{
  -- fullname for auto select (make sure this matches in-game under Misc -> Languages)
  fullname = "Romanian",

  -- name in the built-in menu
  name_menu = "Româna",

  -- global command info
  to_switch = "Schrie \"/lang %s\" pentru a schimba limba",
  switched = "Schimbare în Româna!", -- Replace "English" with the name of this language
  rules_command = "Schimbare /rules pentru a arata din nou mesajul",
  open_menu = "Apasa /mh sau apasa L + Porneste in meniu",
  stalk = "Foloseste /stalk a deforma la alergatori!",
  rules_desc = "- Arata MarioHunt reguli",
  rules_desc_egg = "- Arata LuigiHunt reguli",
  mh_desc = "[COMMAND,ARGS] - Executa comenzile; Scrie nimic sau \"menu\" pentru a dischide meniul",
  lang_desc = "%s - Schimba limba",
  hard_desc = "[EX|ON|OFF,ON|OFF] - Comutati modul greu pentru dvs",
  tc_desc = "[ON|OFF|MSG] - Trimite mesaj numai echipei; activati pentru a se aplica tuturor mesajelor",
  stats_desc = "- Afisati/ascundeti tabelul cu statistici",
  stalk_desc = "[NAME|ID] - Se deformeaza la nivelul in care se afla jucatorul specificat sau primul alergator",
  spectate_desc = "[NAME|ID|STOP] - Vizionati playerul specificat, camera libera daca nu este specificata sau OFF pentru a dezactiva", -- not to be confused 
  target_desc = "[NAME|ID] - Setati acest Alergator ca tinta, care afiseaza locatia lui in orice moment.",

  -- roluri
  runner = "Alergator",
  runners = "Alergatori",
  short_runner = "Alergator scurt", -- unused
  hunters = "Vânator",
  hunter = "Vânatori",
  spectator = "Spectator",
  player = "Jucator",
  players = "Jucatori",
  all = "Toti",

  -- rules
  welcome = "Bine ai venit la \\#00ffff\\Mario\\#ff5a5a\\Hunt\\#ffffff\\! CUM Sa JOCI:",
  welcome_mini = "Bine ai venit la \\#ffff5a\\Mini\\#ff5a5a\\Hunt\\#ffffff\\! CUM Sa JOCI:",
  welcome_egg = "Bine ai venit la \\#5aff5a\\Luigi\\#ff5a5a\\Hunt\\#ffffff\\! CUM Sa JOCI:",
  all_runners = "Morti toti \\#00ffff\\Alergatori\\#ffffff\\.",
  any_runners = "Învinge orice \\#00ffff\\Alergatori\\#ffffff\\.",
  shown_above = "(arata de mai sus)",
  any_bowser = "Înfrângere %s prin \\#ffff5a\\orice\\#ffffff\\ inseamna necesar.",
  collect_bowser = "Colectare \\#ffff5a\\%d stele(s)\\#ffffff\\ si înfrângere %s.",
  mini_collect =  "Fi primul la \\#ffff5a\\aduna steaua\\#ffffff\\.",
  collect_only = "Colectare \\#ffff5a\\%d stele(s)\\#ffffff\\.",
  thats_you = "(asta esti tu!)",
  banned_glitchless = "NU: Echipe încrucisate, BLJs, taierea de perete, blocare, campare.",
  banned_general = "NU: Echipe încrucisate, blocare, campare.",
  time_needed = "%d:%02d a parasi orice etapa principala; aduna stele pentru a reduce",
  stars_needed = "%d stele(s) a parasi orice etapa principala",
  become_hunter = "deveni \\#ff5a5a\\Vânatori\\#ffffff\\ când este învins",
  become_runner = "învinge \\#00ffff\\Alergatori\\#ffffff\\ a devenit unul", -- is this correct?
  infinite_lives = "Vieti infinite",
  spectate = "Schrie \"/spectate\" pentru a te uita",
  mini_goal = "\\#ffff5a\\Cine aduna cele mai multe stele in %d:%02d castiga!\\#ffffff\\",
  fun = "Distractie placuta!",

  -- hud, extra desc, and results text (%s is a placeholder for names, and %d is a placeholder for a number)
  win = "%s\\#ffffff\\ câstigat!", -- team name is placed here
  can_leave = "\\#5aff5a\\Poti iesi din curs",
  cant_leave = "\\#ff5a5a\\Nu poti iesi din curs",
  time_left = "Poti pleca în \\#ffff5a\\%d:%02d",
  stars_left = "Nevoie \\#ffff5a\\%d star(s)\\#ffffff\\ to leave",
  in_castle = "În castel",
  until_hunters = "%d secunde(s) pâna \\#ff5a5a\\Vânatori\\#ffffff\\ încep",
  until_runners = "%d secunde(s) pâna \\#00ffff\\Alergatori\\#ffffff\\ încep",
  lives_one = "1 viata",
  lives = "%d vieti",
  stars_one = "1 stea",
  stars = "%d stele",
  no_runners = "Nu \\#00ffff\\Alergatori!",
  camp_timer = "Continua sa the misti! \\#ff5a5a\\(%d)",
  game_over = "Jocul s-a terminat!",
  winners = "Câstigatori: ",
  no_winners = "\\#ff5a5a\\Nici un câstigator!",
  death_timer = "Mort",
  mini_score = "Scor: %d",
  new_record = "\\#ffff5a\\NOU RECORD!!!",
  on = "\\#5aff5a\\PORNIT",
  off = "\\#ff5a5a\\OPRIT",
  frozen = "Înghetat pentru %d",

  -- popups
  lost_life = "%s\\#ffa0a0\\ pierdut o viata!",
  lost_all = "%s\\#ffa0a0\\ pierdut toate vietile!",
  now_role = "%s\\#ffa0a0\\ acum e %s\\#ffa0a0\\.",
  got_star = "%s\\#ffa0a0\\ ai luat steaua!",
  got_key = "%s\\#ffa0a0\\ ai luat cheia!",
  rejoin_start = "%s\\#ffa0a0\\ are doua minute pentru a reveni.",
  rejoin_success = "%s\\#ffa0a0\\ a intrat la timp!",
  rejoin_fail = "%s\\#ffa0a0\\ nu sa conectat la timp.",
  using_ee = "Aceasta foloseste numai Extreme Edition.",
  not_using_ee = "Aceasta utilizeaza numai editia standard.",
  killed = "%s\\#ffa0a0\\ omorât %s!",
  sidelined = "%s\\#ffa0a0\\ terminat %s!",
  paused = "Ai pus pauza.",
  unpaused = "Nu mai ai pauza.",
  kill_combo_2 = "%s\\#ffa0a0\\ a fost \\#ffff5a\\de doua ori\\#ffa0a0\\ mort!",
  kill_combo_3 = "%s\\#ffa0a0\\ a fost \\#ffff5a\\de trei ori\\#ffa0a0\\ mort!",
  kill_combo_4 = "%s\\#ffa0a0\\ a fost \\#ffff5a\\de patru ori\\#ffa0a0\\ mort!",
  kill_combo_5 = "%s\\#ffa0a0\\ a fost \\#ffff5a\\de cinci ori\\#ffa0a0\\ mort!",
  kill_combo_large = "\\#ffa0a0\\Wow! %s\\#ffa0a0\\ a facut \\#ffff5a\\%d\\#ffa0a0\\ a omorât la rând!",
  set_hack = "Hack pus la %s",
  incompatible_hack = "AVERTIZMANT: Hackul nu este compatibil!",
  vanilla = "Folosind jocul vanila",
  omm_detected = "OMM Rebirth detectat!",
  omm_bad_version = "\\#ff5a5a\\OMM Rebirth este depasit!\\#ffffff\\\nMinimum version: %s\nYour version: %s",
  warp_spam = "Iao mai încet cu urzeala!",
  no_valid_star = "Nu s-a putut gasi o stea valida!",
  custom_enter = "%s\\#ffffff\\ intrat\n%s", -- same as coop
  vanish_custom = "tine \\#ffff5a\\B\\#ffffff\\ pentru a fi invisibil!",
  got_all_stars = "Ai destule stele!",
  unstuck = "Încercarea de a remedia starea",
  use_out = "Foloseste /mh pentru a deforma pe toata lumea din acest nivel",
  stars_in_area = "%d stele(s) valabile aici!",
  demon_unlock = "Modul Green Demon deblocat!",
  hit_switch_red = "%s\\#ffa0a0\\ a activat\n\\#df5050\\Comutatorul Rosu!", -- dark red (unique)
  hit_switch_green = "%s\\#ffa0a0\\ a activat\n\\#50b05a\\Comutatorul Verde!", -- dark green (unique)
  hit_switch_blue = "%s\\#ffa0a0\\ a activat\n\\#5050e3\\Comutatorul Albastru!", -- dark blue (unique)
  hit_switch_yellow = "%s\\#ffa0a0\\ a activat\n\\#e3b050\\Comutatorul Galben...", -- orangeish (unique)

  -- command feedback
  not_mod = "Tu nu ai permisiune de a folosi comanda, prostule!",
  no_such_player = "Nu exista un asemena de jucator",
  bad_id = "ID jucatorului nu este!",
  command_disabled = "Comanda aceasta este dezacrivata.",
  change_setting = "Setari schimbate:",
  you_are_muted = "Tu esti acum mut.",

  -- more command feedback
  bad_param = "Parametri invalidi!",
  bad_command = "Comanda invalida!",
  error_no_runners = "Nu poti începe jocul cu 0 alergatori!",
  set_team = "%s's echipele au fost setate la '%s'", -- First %s is player name, second is team name (now unused)
  not_started = "Jocul nu a început înca",
  set_lives_one = "%s acum ai 1 viata",
  set_lives = "%s acum are %d vieti",
  not_runner = "%s nu este un Alergator",
  may_leave = "%s poate pleca",
  must_have_one = "Trebuie cel puti un Vânator",
  added = "Alergatori adaugati: ", -- list comes afterward
  no_runners_added = "Nici un Alergator nu a fost adaugat",
  runners_are = "Alergatori sunt: ",
  set_lives_total = "Viata alergatorilor setata la %d",
  wrong_mode = "Nu este disponibil în acest mod",
  need_time_feedback = "Alergatori pot iesi în %d secunde(s) acum",
  game_time = "Jocul dureaza acum %d secunde(s)",
  need_stars_feedback = "Alergatori au nevoie %d stele(s) acum",
  new_category = "Acum este un %d stea alergatoare",
  new_category_any = "Acum este any% alerga",
  mode_normal = "În modul Normal",
  mode_swap = "În modul Schimbator",
  mode_mini = "În modul Minivânatoare",
  using_stars = "Folosind stelele colectate",
  using_timer = "Folosind und cronometru",
  can_spectate = "Vînîtori pot acum privi",
  no_spectate = "Vânatorii nu mai pot privi",
  all_paused = "Toti jucatori au luat o pauza",
  all_unpaused = "Toti jucatorii au reluat pauza",
  player_paused = "%s a fost întrerupta",
  player_unpaused = "%s a fost întrerupta",
  hunter_metal = "Toti vânatorii sunt din metal",
  hunter_normal = "Toti vânatorii par normali",
  hunter_glow = "Toti vânatorii stralucesc rosu",
  hunter_outline = "Toti vânatorii au un contur",
  runner_sparkle = "Toti alergatorii stralucesc acum",
  runner_normal = "Toti alergAll runners have an outlineatorii par normalil",
  runner_glow = "Toti alergatorii stralucesc acum",
  runner_outline = "Toti alergatorii au un contur",
  now_weak = "Toti jucatorii au jumatate de cadre de invincibilitate",
  not_weak = "Toti jucatorii au cadre de invincibilitate normale",
  auto_on = "Jocurile vor începe automat",
  auto_off = "Jocurile nu vor porni automat",
  force_spectate = "Toata lumea trebuie sa priveasca",
  force_spectate_off = "Spectacolul nu mai este fortat",
  force_spectate_one = "%s trebuie sa priveasca",
  force_spectate_one_off = "%s nu mai trebuie sa priveasca",
  blacklist_add = "Pe lista neagra %s",
  blacklist_remove = "Pe lista alba %s",
  blacklist_add_already = "Acea stea sau nivel este deja pe lista neagra.",
  blacklist_remove_already = "Acea stea sau nivel nu este pe lista neagra.",
  blacklist_remove_invalid = "Nu pot fi listata în alb aceasta stea sau nivel.",
  blacklist_list = "Pe lista neagra:",
  blacklist_reset = "Resetati lista neagra!",
  blacklist_save = "Lista neagra a fost salvata!",
  blacklist_load = "Lista neagra a fost încarcata!",
  anarchy_set_0 = "Alergatorul poate sa îsi atace echipa",
  anarchy_set_1 = "Alergatorii îsi pot ataca colegii",
  anarchy_set_2 = "Vânatorii îsi pot ataca colegii de echipa",
  anarchy_set_3 = "Jucatorii îsi pot ataca colegii",
  dmgAdd_set = "Alergatorii vor primi acum %d daune suplimentare din atacurile PVP.",
  dmgAdd_set_ohko = "Alergatorii vor muri acum dintr-o lovitura",
  voidDmg_set = "Jucatorii vor primi %d daune din caderea în gol sau nisipuri miscatoare.",
  voidDmg_set_ohko = "Jucatorii vor muri instantaneu din cauza caderii în gol sau în nisipuri miscatoare.",
  target_hunters_only = "Doar vânatorii pot stabili o tinta.",
  muted = "\\#ffff00\\%s\\#ffffff\\ a fost dezactivat de \\#ffff00\\%s\\#ffffff\\.",
  unmuted = "\\#ffff00\\%s\\#ffffff\\ a fost activat de \\#ffff00\\%s\\#ffffff\\.",
  you_muted = "Tu ai dezactivat \\#ffff00\\%s\\#ffffff\\.",
  you_unmuted = "Tu ai dezactivat\\#ffff00\\%s\\#ffffff\\.",
  mute_auto = "\\#ffff00\\%s\\#ffffff\\ a fost dezactivat automat.",

  -- team chat
  tc_toggle = "Chatul în echipa este %s!",
  to_team = "\\#8a8a8a\\La echipa: ",
  from_team = "\\#8a8a8a\\ (echipa): ",

  -- vote skip
  vote_skip = "%s\\#dcdcdc\\ a votat pentru a omite aceasta stea",
  vote_info = "Tastati /skip pentru a vota",
  vote_pass = "Votul a trecut!",
  already_voted = "Ai votat deja.",

  -- hard mode
  hard_notice = "Psst, încearca sa tastezi /hard...",
  extreme_notice = "Psst, încearca sa tastezi /hard ex...",
  hard_toggle = "\\#ff5a5a\\Modul Greu\\#ffffff\\ este %s!",
  extreme_toggle = "\\#b45aff\\Modul Extrem\\#ffffff\\ este %s!",
  hard_info = "Interesat în \\#ff5a5a\\Hard Mode\\#ffffff\\?"..
  "\n- Jumate de viata"..
  "\n- Fara regen de la apa"..
  "\n- \\#ff5a5a\\O viata"..
  "\n\\#ffffff\\Tastati /hard ON daca sunteti pregatit pentru provocare.",
  extreme_info = "Esti atras de \\#b45aff\\Modul Extrem\\#ffffff\\? Ce prostie."..
  "\n- O viata"..
  "\n- O sanatate"..
  "\n- \\#b45aff\\Cronometrul mortii\\#ffffff\\; aduna monede si stele pentru a creste"..
  "\nIf asta nu te sperie, tastati /hard ex ON.",
  no_hard_win = "Scorul dvs. de câstiguri dure sau extreme nu va fi actualizat pentru acest joc.",
  hard_mode = "Modul Greu",
  extreme_mode = "Modul Extrem",
  hard_info_short = "Jumatate de sanatate, fara apa vindecare si o viata.",
  extreme_info_short = "Un singur cronometru pentru sanatate, viata si moarte.",

  -- spectator
  hunters_only = "Numai vânatorii pot privi!",
  spectate_disabled = "Spectatia este dezactivata!",
  timer_going = "Nu pot privi în timpul cronometrului!", -- now unused
  spectate_self = "Nu te poti privi!",
  spectator_controls = "Controale:"..
  "\nDPAD-UP: Opriti hud-ul"..
  "\nDPAD-DOWN: Schimbati vizualizarea freecam/player"..
  "\nDPAD-LEFT / DPAD-RIGHT: Schimbati jucatorul"..
  "\nJOYSTICK: Misca"..
  "\nA: Dute sus"..
  "\nZ: Dute jos"..
  "\nType \"/spectate OFF\" pentru a anula",
  spectate_off = "Nu mai privesc.",
  empty = "GOL (%d )",
  free_camera = "CAMERA GRATUITA",
  spectate_mode = "- MOD SPECTATOR -",
  is_spectator = '* JUCATORUL ESTE UN SPECTATOR  *',

  -- stats
  disp_wins_one = "%s\\#ffffff\\ a câstigat 1 data ca \\#00ffff\\Alergator\\#ffffff\\!",
  disp_wins = "%s\\#ffffff\\ a câstigat de %d ori ca \\#00ffff\\Alergator\\#ffffff\\!",
  disp_kills_one = "%s\\#ffffff\\ a ucis 1 jucator!", -- unused
  disp_kills = "%s\\#ffffff\\ a ucis %d jucatori!",
  disp_wins_hard_one = "%s\\#ffffff\\ a câstigat 1 data ca \\#ffff5a\\Runner\\#ffffff\\ în \\#ff5a5a\\Modul Greu!\\#ffffff\\",
  disp_wins_hard = "%s\\#ffffff\\ a câstigat de %d ori ca \\#ffff5a\\Runner\\#ffffff\\ în \\#ff5a5a\\Modul Greu!\\#ffffff\\",
  disp_wins_ex_one = "%s\\#ffffff\\ a câstigat 1 data ca \\#b45aff\\Runner\\#ffffff\\ în \\#b45aff\\Modul Extrem!\\#ffffff\\",
  disp_wins_ex = "%s\\#ffffff\\ a câstigat de %d ori ca \\#b45aff\\Runner\\#ffffff\\ în \\#b45aff\\Modul Extrem!\\#ffffff\\",
  -- for stats table
  stat_wins_standard = "Învingeri",
  stat_wins = "Învingeri (Minihunt/pre v2.3)",
  stat_kills = "Ucideri",
  stat_combo = "Maximul de Ucideri Strike",
  stat_wins_hard_standard = "Învingeri (Modul Greu)",
  stat_wins_hard = "Învingeri (Modul Greu, MiniHunt/pre v2.3)",
  stat_mini_stars = "Maximum de stele într-un singur joc de MiniHunt",
  stat_placement = "64 Plasare în tur",
  stat_wins_ex_standard = "Învingeri (Modul Extrem)",
  stat_wins_ex = "Învingeri (Modul Extrem, MiniHunt/pre v2.3)",

  -- placements
  place_1 = "\\#e3bc2d\\[64T: Primul Loc]",
  place_2 = "\\#c5d8de\\[64T: Doilea Loc]",
  place_3 = "\\#b38752\\[64T: Treilea Loc]",
  place = "\\#e7a1ff\\[64T: %dPatrulea Loc]", -- thankfully we don't go up to 21
  place_score_1 = "%dprimul",
  place_score_2 = "%ddoilea",
  place_score_3 = "%dtrilea",
  place_score = "%dpatrulea",

  -- chat roles
  role_lead = "\\#9a96ff\\[Conducator MH Dev]",
  role_dev = "\\#96ecff\\[MH Dev]",
  role_cont = "\\#ff9696\\[Colaborator MH]",
  role_trans = "\\#ffd996\\[MH Traducator]",

  -- command descriptions
  page = "\\#ffff5a\\Pagina %d/%d", -- page for mariohunt command
  start_desc = "[CONTINUE|MAIN|ALT|RESET] - Începe jocul; adauga \"continue\" a nu deforma pentru a începe; adauga \"alt\" pentru alt fisier de salvare; adauga \"main\" pentru fisierul de salvare principal; adauga \"reset\" prentru a reseta fisierele",
  add_desc = "[INT] - Adauga aleatoriu cantitatea specificata de alergatorim",
  random_desc = "[INT] - Alege aleatoriu numarul specificat de alergatori",
  lives_desc = "[INT] - Seteaza numarul de vieti pe care le au alergatorii, de la 0 la 99 (nota: 0 vieti este înca 1 viata)",
  time_desc = "[NUM] - Seteaza timpul pe care alergatorii trebuie sa astepte pentru a pleca, în secunde, sau durata jocului în MiniHunt.",
  stars_desc = "[INT] - Seteaza cantitatea de stele pe care alergatorii trebuie sa le colecteze pentru a pleca, de la 0 la 7 (doar în modul stea)",
  category_desc = "[INT] - Stabileste numarul de stele pe care alergatorii trebuie sa le aiba pentru a se confrunta cu Bowser.",
  flip_desc = "[NAME|ID] - Întoarce echipa jucatorului specificat",
  setlife_desc = "[NAME|ID|INT,INT] - Seteaza durata de viata specificata pentru alergatorul specificat",
  leave_desc = "[NAME|ID] - Permite jucatorului specificat sa paraseasca nivelul daca este un alergator",
  mode_desc = "[NORMAL|SWAP|MINI] - Changes game mode; Swap switches runners when one dies",
  starmode_desc = "[ON|OFF] - Comuta utilizarea stelelor colectate în loc de timp",
  spectator_desc = "[ON|OFF] - Comuta capacitatea vânatorilor de a privi",
  pause_desc = "[NAME|ID|ALL] - Comuta starea de pauza pentru jucatorii specificati sau pentru toti daca nu este specificat",
  hunter_app_desc = "Schimba aspectul vânatorilor.",
  runner_app_desc = "Schimba aspectul alergatorilor.",
  hack_desc = "[STRING] - Seteaza hack-ul actual al romului",
  weak_desc = "[ON|OFF] - Reduce cadrele de invincibilitate la jumatate pentru toti jucatorii",
  auto_desc = "[ON|OFF|NUM] - Porniti jocurile automat",
  forcespectate_desc = "[NAME|ID|ALL] - Comutati fortarea spectatorului pentru acest jucator sau pentru toti jucatorii",
  desync_desc = "- Încercari de a remedia erorile de desincronizare",
  stop_desc = "- Opreste jocul",
  default_desc = "- Setati setarile la început",
  blacklist_desc = "[ADD|REMOVE|LIST|RESET|SAVE|LOAD,COURSE,ACT] -Lista neagra a vedetelor din MiniHunt",
  stalking_desc = "[ON|OFF] - Permite deformarea la nivelul unui alergator cu /stalk",
  mute_desc = "[NAME|ID] - Dezactiveaza un jucator, împiedicându-l sa converseze",
  unmute_desc = "[NAME|ID] - Activeaza sunetul unui jucator, permitându-i sa discute din nou",
  out_desc = "- Scoate pe toti din acest nivel",

  -- Blocky's menu
  main_menu = "Meniu principal",
  menu_mh = "MarioHunt",
  menu_mh_egg = "LuigiHunt",
  menu_settings_player = "Setari",
  menu_rules = "Reguli",
  menu_list_settings = "Setari lista",
  menu_list_settings_desc = "Listeaza toate setarile pentru acest lobby.",
  menu_lang = "Limba",
  menu_misc = "Muzica",
  menu_stats = "Statistici",
  menu_back = "Înapoi",
  menu_exit = "Iesi",

  menu_run_random = "Randomizati alergatorii",
  menu_run_add = "Adaugati alergatori",
  menu_run_lives = "Vietile alergatorului",
  menu_settings = "Setarile jocului",

  menu_start = "Porneste",
  menu_stop = "Opreste",
  menu_save_main = "Principal",
  menu_save_alt = "Alt Salvare",
  menu_save_reset = "Resetati Alt Salvare",
  menu_save_continue = "Continua (fara deformare înapoi)",
  menu_random = "Aleatoriu",
  menu_campaign = "Campanie",
  menu_coop = "Înpreuna",

  menu_gamemode = "Mod de joc",
  menu_hunter_app = "Aspectul vânatorului",
  menu_runner_app = "Aspectul alergatorilor",
  menu_weak = "Modul Slab",
  menu_allow_spectate = "Permite Spectating",
  menu_star_mode = "Modul Stea",
  menu_category = "Categorie",
  menu_time = "Timp",
  menu_stars = "Stele",
  menu_auto = "Joc Auto",
  menu_blacklist = "Lista neagra MiniHunt",
  menu_default = "Reseteaza la Început",
  menu_anarchy = "Bataie prieteneasca",
  menu_anarchy_desc = "Permite echipelor specificate sa-si atace colegii.",
  menu_dmgAdd = "Alergatorul în PVP LOVITURA MARE", -- DMG is "damage"
  menu_dmgAdd_desc = "Adaugati atât de mult daune la atacurile împotriva alergatorilor.",
  menu_nerf_vanish = "sapca Nerf de Invisibilitate", -- Nerf, as in to reduce power for balancing
  menu_nerf_vanish_desc = "Capacul Nerfs dispare facându-l comutabil si se scurge mai repede atunci când este utilizat.",
  menu_first_timer = "Lider Mort Timp",
  menu_first_timer_desc = "Ofera liderului din MiniHunt un cronometru al mortii.",
  menu_defeat_bowser = "Înfrângere %s",
  menu_allow_stalk = "Permite ,,Stalking\"",
  menu_countdown = "Numaratoare inversa",
  menu_countdown_desc = "Cât timp trebuie sa astepte vânatorii înainte de a începe.",
  menu_voidDmg = "LOVITURA din Void",
  menu_voidDmg_desc = "Daunele aduse jucatorilor care cad în gol sau nisipuri miscatoare.",
  menu_double_health = "Sanatate dublu alergator",
  menu_double_health_desc = "Alergatorii primesc 16 puncte de sanatate în loc de 8.",
  menu_star_heal = "Viata stelelor",

  menu_flip = "Schimba echipa",
  menu_spectate = "Spectator",
  menu_stalk = "Teleporteazate la un Nivel",
  menu_stalk_desc = "Teleporteazate la nivelul acestui jucator.",
  menu_pause = "Pauza",
  menu_forcespectate = "Forzeaza pe Spectator",
  menu_allowleave = "Permite pentru a Iesi",
  menu_setlife = "Seteaza Vieatile",
  menu_players_all = "Toti Jucatori",
  menu_target = "Pune ca si o tinta",
  menu_mute = "Mut",

  menu_timer = "Cronometru de Rulare Rapida",
  menu_timer_desc = "[ON|OFF] - Afisati un cronometru în partea de jos a ecranului în modurile Standard.",
  menu_tc = "Chat în echipa",
  menu_tc_desc = "Chat numai cu echipa ta.",
  menu_demon = "Demonul Verde", -- referr
  menu_demon_desc = "Ai un 1-Up sa te urmareasca ca alergator.",
  menu_unknown = "???",
  menu_secret = "Este un secret. Cum îl deblochezi?",
  menu_hide_roles = "Ascundemi rolul meu",
  menu_hide_roles_desc = "Ascundeti-va rolurile pentru a nu se afisa în chat.",
  menu_hide_hud = "Ascunde HUD",
  hidehud_desc = "- Ascunde toate elementele HUD.",
  menu_fast = "Actiuni mai rapide",
  menu_fast_desc = "Va veti recupera, aruncati obiecte si deschideti usi mai repede.",
  menu_popup_sound = "Sunetul pop-up",
  menu_season = "Schimbari sezoniere",
  menu_season_desc = "Schimbari vizuale distractive în functie de data.",

  menu_free_cam_desc = "Introduceti Camera gratuita în modul Spectator.",
  menu_spectate_run = "Spectator pe Alergatori",
  menu_spectate_run_desc = "Priveste automat primul alergator.",
  menu_exit_spectate = "Iesi din Spectator",
  menu_exit_spectate_desc = "Iesi din modul Spectator.",
  menu_stalk_run = "Teleporteazate la Nivelul alergatorului",
  menu_stalk_run_desc = "Deformati pâna la nivelul în care se afla primul alergator.",
  menu_skip = "Omite",
  menu_skip_desc = "- Votati pentru a omite aceasta stea în MiniHunt.",

  menu_spectate_desc = "Priveste acest jucator.",

  menu_blacklist_list = "Listati toate pe lista neagra",
  menu_blacklist_list_desc = "Listeaza toate vedetele aflate pe lista neagra din MiniHunt pentru acest server.",
  menu_blacklist_save = "Salveaza lista Neagra",
  menu_blacklist_save_desc = "Salvati aceasta lista neagra de la capatul vostru.",
  menu_blacklist_load = "Încarcati lista neagra",
  menu_blacklist_load_desc = "Încarcati lista neagra salvata.",
  menu_blacklist_reset = "Resetati lista neagra",
  menu_blacklist_reset_desc = "Resetati lista neagra la valoarea implicita.",
  menu_toggle_all = "Comutati toate",

  -- updater
  up_to_date = "\\#00ffff\\Mario\\#ff5a5a\\Vânatoare\\#ffffff\\ este la zi!",
  up_to_date_egg = "\\#5aff5a\\Luigi\\#ff5a5a\\Vânatoare\\#ffffff\\ este la zi!",
  has_update = "O actualizare este disponibila pentru \\#00ffff\\Mario\\#ff5a5a\\Vânatoare\\#ffffff\\!",
  has_update_egg = "O actualizare este disponibila pentru \\#5aff5a\\Luigi\\#ff5a5a\\Vânatoare\\#ffffff\\!",

  -- 2.6 stuff that I don't feel like sorting
  leave_error = "%s\\#ffa0a0\\ lasat din cauza unei erori.",
  hunter_color = "Toti vânatorii au paleta Burgundy",
  runner_color = "Toti alergatorii au paleta Azure",
  stat_playtime = "Timp de joaca (Ore)",
  stat_parkour_time = "Cel mai rapid timp de parkour",
  stat_parkour_time_omm = "Cel mai rapid timp de parkour (OMM)",
  stat_parkour_time_other = "Cel mai rapid timp de parkour (Moveset)",
  menu_free_roam = "Roam liber",
  menu_free_roam_desc = "Dezactiveaza cerintele Star si Key pentru usi si majoritatea nivelurilor.",
  menu_radar = "Radarul",
  menu_radar_desc = "Arata unde sunt alergatorii si obiectele importante.",
  menu_minimap = "Miniharta",
  menu_minimap_desc = "Afiseaza o harta a întregului nivel.",
  menu_romhack_cam = "Camera de la Romhack",
  menu_romhack_cam_desc = "Activeaza camera rom hack in orice moment.",
}

-- language data ends here

-- this generates a list of available languages for the command description
lang = "en"
local lang_table = {}
for lang,data in pairs(langdata) do
  table.insert(lang_table, string.upper(lang))
end
table.sort(lang_table)
lang_list = "["
for i,name in ipairs(lang_table) do
  lang_list = lang_list .. name .. "|"
end
lang_list = lang_list:sub(1,-2) .. "]"

-- this allows players to switch languages
function switch_lang(msg)
  if langdata[string.lower(msg)] then
    lang = string.lower(msg)
    djui_chat_message_create(trans("switched"))
    update_chat_command_description("mh", trans("mh_desc"))
    update_chat_command_description("rules", trans("rules_desc"))
    update_chat_command_description("lang", trans("lang_desc",lang_list))
    update_chat_command_description("stats", trans("stats_desc"))
    update_chat_command_description("hard", trans("hard_desc"))
    update_chat_command_description("tc", trans("tc_desc"))
    if (gGlobalSyncTable.allowStalk) then
      update_chat_command_description("stalk", trans("stalk_desc"))
    else
      update_chat_command_description("stalk", "- " .. trans("command_disabled"))
    end
    update_chat_command_description("timer", trans("menu_timer_desc"))
    update_chat_command_description("skip", trans("menu_skip_desc"))
    update_chat_command_description("target", trans("target_desc"))
    if (gGlobalSyncTable.allowSpectate) then
      update_chat_command_description("spectate", trans("spectate_desc"))
    else
      update_chat_command_description("spectate", "- " .. trans("command_disabled"))
    end
    --show_rules()
    return true
  end
  return false
end
hook_chat_command("lang", trans("lang_desc",lang_list), switch_lang)

update_chat_command_description("mh", trans("mh_desc")) -- this is the only chat command that gets defined before lang does

-- this handles auto select
for langname,data in pairs(langdata) do
  if data.fullname == smlua_text_utils_get_language() or (data.fullname == "Spanish" and data.fullname == smlua_text_utils_get_language():sub(1,-3)) then
    lang = langname
    break
  end
end

-- debug command
function lang_test(msg)
  local args = split(msg or "", " ")
  if args[1] == "all" then
    local allLang = {}
    for lang,data in pairs(langdata) do
      if ((not args[2]) or lang == args[2]) and lang ~= "en" then
        table.insert(allLang, lang)
      end
    end
    if #allLang == 0 then
      djui_chat_message_create("Invalid language!")
      return true
    end
    print("Missing translation:")
    for id,phrase in pairs(langdata["en"]) do
      local translated_en = trans(id,nil,1,"en")
      for i,lang in ipairs(allLang) do
        local translated = trans(id,nil,10,lang)

        local noline = ""
        if not langdata[lang][id] then noline = " (no line)" end

        if translated == translated_en then
          djui_chat_message_create(id.." lacks translation for "..langdata[lang].fullname.."!"..noline)
          print(string.format("%s = %q,",id, translated))
        end
      end
    end
    return true
  end
  local id = args[1]
  local extra1 = args[2]
  local extra2 = args[3]
  local lang = args[4]
  local translated = trans(id, extra1, extra2)
  if args[5] ~= "plural" then
    djui_chat_message_create(trans(id, extra1, extra2, lang))
  else
    djui_chat_message_create(trans_plural(id, extra1, extra2, lang))
  end

  return true
end
