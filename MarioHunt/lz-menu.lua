-- Thanks to blocky for making most of this

-- localize some functions
local djui_hud_set_font, djui_hud_set_color, djui_hud_print_text, djui_hud_render_rect, djui_hud_measure_text,
djui_hud_render_texture, djui_hud_set_resolution, djui_chat_message_create, djui_hud_get_screen_width, djui_hud_get_screen_height, tonumber, play_sound, string_lower, network_get_player_text_color_string =
    djui_hud_set_font, djui_hud_set_color, djui_hud_print_text, djui_hud_render_rect, djui_hud_measure_text,
    djui_hud_render_texture, djui_hud_set_resolution, djui_chat_message_create, djui_hud_get_screen_width,
    djui_hud_get_screen_height, tonumber, play_sound, string.lower,
    network_get_player_text_color_string

-- localize other stuff
local GST = gGlobalSyncTable
local m0 = gMarioStates[0]

-- Constants for joystick input
local JOYSTICK_THRESHOLD = 32

-- Variables to keep track of current menu state
local currentOption = 1
local bottomOption = 0
local focusPlayerOrCourse = 0
local prevOption = 0
local hoveringOption = true

-- Controller Inputs
local sMenuInputsPressed = 0
local sMenuInputsDown = 0

-- used for displaying binds
buttonString = { "A", "B", "Z", "START", "U-DPAD", "D-DPAD", "L-DPAD", "R-DPAD", "Y", "X", "L", "R" }
menuButtonString = { "L+START", "R+START", "U-DPAD", "D-DPAD", "L-DPAD", "R-DPAD" }

-- textures
local TEX_MENU_ARROW = get_texture_info("menu-arrow")
local TEX_MENU_ARROW_UP = gTextures.arrow_up
local TEX_MENU_ARROW_DOWN = gTextures.arrow_down

-- mouse stuff
local TEX_HAND = get_texture_info("gd_texture_hand_open")
local TEX_HAND_SELECT = get_texture_info("gd_texture_hand_closed")
local mouseX = djui_hud_get_mouse_x()
local mouseY = djui_hud_get_mouse_y()
local mouseData = {
  prevX = mouseX,
  prevY = mouseY
}
local mouseIdleTimer = 90
local mouseGrabbedScrollBar = false
local mouseScrollBarY = 0
local mouseArrowKey = 0
local validBack = true

-- limit for player names
local PLAYER_NAME_CUTOFF = 16

-- build language menu
local menuList = {}
menuList["LanguageMenu"] = {}
local LanguageMenu = menuList["LanguageMenu"]
local langnum = 0
local lang_table = {}
for id, data in pairs(langdata) do
  langnum = langnum + 1
  table.insert(lang_table, { (data.name_menu or data.fullname), id })
end

-- sort alphabetically
table.sort(lang_table, function(a, b)
  return a[1]:lower() < b[1]:lower()
end)

for i, data in ipairs(lang_table) do
  table.insert(LanguageMenu, { name = data[1], lang = data[2] })
end
table.insert(LanguageMenu, { name = ("menu_back") })
LanguageMenu[1].title = ("menu_lang")
LanguageMenu.name = "LanguageMenu"
LanguageMenu.back = langnum + 1

-- we reload all of this sometimes
function menu_reload()
  menuList["mainMenu"] = {
    { name = ("menu_mh"),              title = ("main_menu"),           invalid = not has_mod_powers(0) },
    { name = ("menu_settings_player"), },
    { name = ("menu_rules"),           desc = "rules_desc" },
    { name = ("menu_list_settings"),   desc = "menu_list_settings_desc" },
    { name = ("menu_lang"),            desc = "lang_desc" },
    { name = ("menu_misc") },
    { name = ("players") },
    { name = ("menu_stats") },
    { name = ("menu_exit") },
    name = "mainMenu",
    back = 9,
  }

  menuList["marioHuntMenu"] = {
    { name = ("menu_start"),      title = ("menu_mh") },
    { name = ("menu_run_random"), currNum = -1,         minNum = -MAX_PLAYERS - 1, maxNum = MAX_PLAYERS - 1, desc = ("random_desc"),                          formatAuto = true },
    { name = ("menu_run_add"),    currNum = -1,         minNum = -MAX_PLAYERS - 1, maxNum = MAX_PLAYERS - 1, desc = ("add_desc"),                             formatAuto = true },
    { name = ("menu_gamemode"),   currNum = GST.mhMode, maxNum = 3,                desc = ("mode_desc"),     format = { "Normal", "Swap", "Mini", "Mystery" } },
    { name = ("menu_settings") },
    { name = ("menu_stop"),       desc = ("stop_desc") },
    { name = ("menu_back") },
    name = "marioHuntMenu",
    back = 7,
  }
  if GST.mhMode == 3 then
    menuList["marioHuntMenu"][2].name = "menu_hunt_random"
    menuList["marioHuntMenu"][2].desc = "random_desc_hunt"
  end

  menuList["startMenu"] = {
    { name = ("menu_save_main"),    title = ("menu_start") },
    { name = ("menu_save_alt") },
    { name = ("menu_save_reset") },
    { name = ("menu_save_continue") },
    { name = ("menu_back") },
    { name = ("main_menu") },
    name = "startMenu",
    back = 5,
  }

  menuList["startMenuMini"] = {
    { name = ("menu_random"),   title = ("menu_start") },
    { name = ("menu_campaign"), currNum = 1,           minNum = 1, maxNum = 25 },
    { name = ("menu_back") },
    { name = ("main_menu") },
    name = "startMenuMini",
    back = 3,
  }

  menuList["presetMenu"] = {
    { name = ("menu_default"),     desc = "default_desc",         title = ("menu_presets") },
    { name = ("preset_quick"),     desc = "preset_quick_desc" },
    { name = ("preset_infection"), desc = "preset_infection_desc" },
    { name = ("preset_solo"),      desc = "preset_solo_desc" },
    { name = ("preset_tag"),       desc = "preset_tag_desc" },
    { name = ("preset_star_rush"), desc = "preset_star_rush_desc" },
    { name = ("preset_classic"),   desc = "preset_classic_desc" },
    { name = ("preset_asn"),       desc = "preset_asn_desc" },
    { name = ("menu_back") },
    { name = ("main_menu") },
    name = "presetMenu",
    back = 9,
  }

  menuList["saboMenu"] = {
    { name = ("sabo_bomb"), desc = "sabo_bomb_desc", color = true, title = ("menu_sabo") },
    { name = ("sabo_gas"),  desc = "sabo_gas_desc",  color = true },
    { name = ("sabo_dark"), desc = "sabo_dark_desc", color = true },
    { name = ("menu_exit") },
    name = "saboMenu",
    back = 4,
  }

  local autoRun = 0
  local autoHunt = 0
  local playerCount = 0
  for i = 0, MAX_PLAYERS - 1 do
    if gNetworkPlayers[i].connected and gPlayerSyncTable[i].spectator ~= 1 then
      playerCount = playerCount + 1
    end
  end
  if GST.gameAuto == -1 then
    autoRun = -1
    autoHunt = -1
  elseif GST.gameAuto == -2 then
    autoRun = -2
    autoHunt = 0
  elseif GST.gameAuto > 0 then
    autoRun = GST.gameAuto
    autoHunt = math.max(playerCount - autoRun, 0)
  elseif GST.gameAuto < 0 then
    autoHunt = -GST.gameAuto - 2
    autoRun = math.max(playerCount - autoHunt, 0)
  end

  menuList["autoMenu"] = {
    { name = ("off"),      desc = "auto_desc", option = (GST.gameAuto ~= 0), title = ("menu_auto"), color = true },
    { name = ("runners"),  currNum = autoRun,  maxNum = MAX_PLAYERS,         minNum = -2,           formatAuto = true, invalid = (GST.gameAuto == 0) },
    { name = ("hunters"),  currNum = autoHunt, maxNum = MAX_PLAYERS,         minNum = -1,           formatAuto = true, invalid = (GST.gameAuto == 0) },
    { name = ("menu_back") },
    { name = ("main_menu") },
    name = "autoMenu",
    back = 4,
  }
  if menuList["autoMenu"][1].option then
    menuList["autoMenu"][1].name = "on"
  end

  LanguageMenu[1].title = ("menu_lang")

  local auto = GST.gameAuto
  local maxStars = 255
  if ROMHACK then maxStars = ROMHACK.max_stars end
  menuList["settingsMenu"] = {
    { name = ("menu_run_lives"),         currNum = GST.runnerLives,          maxNum = 99,                                                            desc = ("lives_desc"),                              title = ("menu_settings") },
    { name = ("menu_time"),              currNum = GST.runTime // 30,        maxNum = 3600,                                                          desc = ("time_desc"),                               time = true },
    { name = ("menu_star_mode"),         option = GST.starMode,              desc = ("starmode_desc"),                                               invalid = (GST.mhMode == 2) },
    { name = ("menu_category"),          currNum = GST.starRun,              maxNum = maxStars,                                                      minNum = (GST.noBowser and 1) or -1,                desc = ("category_desc"),                                              invalid = (GST.mhMode == 2) },
    { name = ("menu_defeat_bowser"),     option = not GST.noBowser,          invalid = (GST.mhMode == 2 or (ROMHACK and (ROMHACK.no_bowser ~= nil))) },
    { name = ("menu_free_roam"),         option = GST.freeRoam,              invalid = (GST.mhMode == 2),                                            desc = "menu_free_roam_desc" },
    { name = ("menu_auto"),              option = (auto ~= 0),               desc = "auto_desc",                                                     xOption = true },
    { name = ("menu_shuffle"),           currNum = GST.maxShuffleTime // 30, minNum = 0,                                                             maxNum = 600,                                       time = true,                                                           desc = ("menu_shuffle_desc"),                                                  format = { "~" } },
    { name = ("menu_nerf_vanish"),       option = GST.nerfVanish,            desc = ("menu_nerf_vanish_desc") },
    { name = ("menu_allow_spectate"),    option = GST.allowSpectate,         desc = ("spectator_desc"), },
    { name = ("menu_allow_stalk"),       option = GST.allowStalk,            desc = ("stalking_desc"),                                               invalid = (GST.mhMode == 2) },
    { name = ("menu_stalk_timer"),       currNum = GST.stalkTimer // 30,     maxNum = 600,                                                           desc = ("menu_stalk_timer_desc"),                   time = true,                                                           invalid = (GST.mhMode == 2 or not GST.allowStalk) },
    { name = ("menu_weak"),              option = GST.weak,                  desc = ("weak_desc") },
    { name = ("menu_anarchy"),           currNum = GST.anarchy,              minNum = 0,                                                             maxNum = 3,                                         desc = ("menu_anarchy_desc"),                                          format = { "~", "lang_runners", "lang_hunters", "lang_all" } },
    { name = ("menu_dmgAdd"),            currNum = GST.dmgAdd,               minNum = -1,                                                            maxNum = 15,                                        desc = ("menu_dmgAdd_desc"),                                           format = { "OHKO" } },
    { name = ("menu_countdown"),         currNum = GST.countdown // 30,      maxNum = 600,                                                           time = true,                                        minNum = 0,                                                            desc = ("menu_countdown_desc"),                                                invalid = (GST.mhMode == 2) },
    { name = ("menu_double_health"),     option = GST.doubleHealth,          desc = ("menu_double_health_desc"), },
    { name = ("menu_star_heal"),         option = GST.starHeal },
    { name = ("menu_star_setting"),      currNum = GST.starSetting,          minNum = 0,                                                             maxNum = 2,                                         format = { "lang_star_leave", "lang_star_stay", "lang_star_nonstop" }, invalid = (GST.mhMode == 2) },
    { name = ("menu_star_stay_old"),     option = GST.starStayOld,           desc = ("menu_star_stay_old_desc"),                                     invalid = (GST.mhMode == 2 or GST.starSetting ~= 0) },
    { name = ("menu_voidDmg"),           currNum = GST.voidDmg,              minNum = -1,                                                            maxNum = 15,                                        desc = ("menu_voidDmg_desc"),                                          format = { "OHKO" } },
    { name = ("menu_spectate_on_death"), option = GST.spectateOnDeath },
    { name = ("menu_show_on_map"),       currNum = GST.showOnMap,            maxNum = 4,                                                             desc = ("menu_show_on_map_desc"),                   invalid = (GST.mhMode == 3),                                           format = { "~", "lang_runners", "lang_hunters", "lang_opponents", "lang_all" } },
    { name = ("menu_blacklist"),         desc = ("blacklist_desc") },
    { name = ("menu_presets"), },
    { name = ("menu_back") },
    { name = ("main_menu") },
    name = "settingsMenu",
    back = 26,
  }
  local settingsMenu = menuList["settingsMenu"]
  if GST.starMode and GST.mhMode ~= 2 then
    settingsMenu[2] = { name = ("menu_stars"), currNum = GST.runTime, maxNum = 7, desc = ("stars_desc") }
  end
  if GST.mhMode == 2 then
    settingsMenu[3] = { name = ("menu_first_timer"), option = GST.firstTimer, desc = ("menu_first_timer_desc"), }
  elseif GST.mhMode == 3 then
    settingsMenu[10] = { name = ("menu_confirm_hunter"), option = GST.confirmHunter, desc = ("menu_confirm_hunter_desc"), }
    settingsMenu[11] = { name = ("menu_hunters_win_early"), option = GST.huntersWinEarly, desc = ("menu_hunters_win_early_desc"), }
    settingsMenu[12] = { name = ("menu_global_chat"), currNum = GST.maxGlobalTalk // 30, maxNum = 600, minNum = -1, time = true, format = { "~", "Always" }, desc = ("menu_global_chat_desc"), }
    settingsMenu[14] = { name = ("menu_know_team"), option = (GST.anarchy ~= 3), desc = ("menu_know_team_desc"), }
    settingsMenu[16].name = "menu_grace_period"
    settingsMenu[16].desc = "menu_grace_period_desc"
  end

  -- name gets overriden
  menuList["playerMenu"] = {}
  local playerMenu = menuList["playerMenu"]
  for i = 0, MAX_PLAYERS - 1 do
    table.insert(playerMenu, { name = "PLAYER_" .. i, color = true, xOption = has_mod_powers(0) })
  end
  playerMenu[1].title = "players"
  playerMenu.name = "playerMenu"
  playerMenu.back = MAX_PLAYERS + 2
  table.insert(playerMenu, { name = ("menu_back") })

  one_player_reload()

  menuList["playerSettingsMenu"] = {
    { name = ("menu_runner_app"),      title = ("menu_settings_player"),                 currNum = runnerAppearance,        maxNum = 4,                                            format = { "~", "Sparkle", "Glow", "Outline", "Color" }, desc = ("runner_app_desc") },
    { name = ("menu_hunter_app"),      currNum = hunterAppearance,                       maxNum = 4,                        format = { "~", "Metal", "Glow", "Outline", "Color" }, desc = ("hunter_app_desc") },
    { name = ("menu_invinc_particle"), option = invincParticle,                          desc = "menu_invinc_particle_desc" },
    { name = ("menu_radar"),           option = showRadar,                               desc = ("menu_radar_desc") },
    { name = ("menu_minimap"),         option = showMiniMap,                             desc = ("menu_minimap_desc") },
    { name = ("menu_overlay"),         option = showPaintingOverlays,                    desc = ("menu_overlay_desc") },
    { name = ("menu_timer"),           option = showSpeedrunTimer,                       desc = ("menu_timer_desc") },
    { name = ("menu_fast"),            option = gPlayerSyncTable[0].fasterActions,       desc = ("menu_fast_desc") },
    { name = ("menu_romhack_cam"),     option = romhackCam,                              desc = ("menu_romhack_cam_desc") },
    { name = ("menu_popup_sound"),     option = playPopupSounds },
    { name = ("menu_season"),          option = not noSeason,                            desc = ("menu_season_desc") },
    { name = ("menu_star_timer"),      option = showLastStarTime,                        desc = ("menu_star_timer_desc") },
    { name = ("menu_hide_hud"),        option = mhHideHud,                               desc = ("hidehud_desc") },
    { name = ("menu_tc"),              option = (gPlayerSyncTable[0].teamChat or false), desc = ("menu_tc_desc"),           invalid = disable_chat_hook },
    { name = ("hard_mode"),            option = (gPlayerSyncTable[0].hard == 1),         desc = ("hard_info_short") },
    { name = ("extreme_mode"),         option = (gPlayerSyncTable[0].hard == 2),         desc = ("extreme_info_short") },
    { name = ("menu_unknown"),         option = demonOn,                                 invalid = true,                    desc = ("menu_secret") },
    { name = ("menu_binds"),           desc = ("menu_binds_desc") },
    { name = ("menu_hide_roles"),      invalid = (get_true_roles() == 0),                desc = ("menu_hide_roles_desc") },
    { name = ("menu_back") },
    name = "playerSettingsMenu",
    back = 20,
  }
  local playerSettingsMenu = menuList["playerSettingsMenu"]
  if demonOn or demonUnlocked then
    playerSettingsMenu[17].name = ("menu_demon")
    playerSettingsMenu[17].desc = ("menu_demon_desc")
    playerSettingsMenu[17].invalid = false
  end

  menuList["miscMenu"] = {
    { name = ("free_camera"),         title = ("menu_misc"),                                                                                            invalid = ((not GST.allowSpectate) or (gPlayerSyncTable[0].team == 1 and GST.mhState ~= 1 and GST.mhState ~= 2)), desc = ("menu_free_cam_desc") },
    { name = ("menu_spectate_run"),   invalid = ((not GST.allowSpectate) or (gPlayerSyncTable[0].team == 1 and GST.mhState ~= 1 and GST.mhState ~= 2)), desc = ("menu_spectate_run_desc") },
    { name = ("menu_exit_spectate"),  invalid = (gPlayerSyncTable[0].forceSpectate or gPlayerSyncTable[0].dead or gPlayerSyncTable[0].spectator ~= 1),  desc = ("menu_exit_spectate_desc") },
    { name = ("menu_stalk_run"),      invalid = ((not GST.allowStalk) or GST.mhMode == 2 or GST.mhState ~= 2),                                          desc = ("menu_stalk_run_desc") },
    { name = ("menu_skip"),           invalid = (GST.mhState ~= 2 or GST.mhMode ~= 2 or iVoted),                                                        desc = ("menu_skip_desc") },
    { name = ("menu_blacklist_list"), desc = ("menu_blacklist_list_desc") },
    { name = ("menu_pause"),          option = GST.pause,                                                                                               desc = "pause_desc",                                                                                              invalid = not has_mod_powers(0) },
    { name = ("menu_forcespectate"),  option = GST.forceSpectate,                                                                                       desc = "forcespectate_desc",                                                                                      invalid = not has_mod_powers(0) },
    { name = ("menu_back") },
    name = "miscMenu",
    back = 9,
  }

  local trueRoles = get_true_roles()
  local roles = gPlayerSyncTable[0].role
  menuList["hideRolesMenu"] = {
    { name = ("role_lead"),          title = ("menu_hide_roles"), option = (roles & 2 ~= 0),       invalid = (trueRoles & 2 == 0), color = true },
    { name = ("role_dev"),           option = (roles & 4 ~= 0),   invalid = (trueRoles & 4 == 0),  color = true },
    { name = ("role_trans"),         option = (roles & 8 ~= 0),   invalid = (trueRoles & 8 == 0),  color = true },
    { name = ("role_cont"),          option = (roles & 16 ~= 0),  invalid = (trueRoles & 16 == 0), color = true },
    { name = ("stat_placement"),     option = (roles & 32 ~= 0),  invalid = (trueRoles & 32 == 0) },
    { name = ("stat_placement_asn"), option = (roles & 64 ~= 0),  invalid = (trueRoles & 64 == 0) },
    { name = ("stat_crown"),         option = (roles & 128 ~= 0), invalid = (trueRoles & 128 == 0) },
    { name = ("menu_default") },
    { name = ("menu_back") },
    { name = ("main_menu") },
    name = "hideRolesMenu",
    back = 9,
  }

  menuList["bindsMenu"] = {
    { name = ("menu_vanish_button"), title = ("menu_binds"), currNum = nerfVanishButton, minNum = 1,  maxNum = 12,                      desc = "menu_vanish_button_desc", format = buttonString },
    { name = ("menu_menu_button"),   currNum = menuButton,   minNum = 1,                 maxNum = 6,  desc = "menu_menu_button_desc",   format = menuButtonString },
    { name = ("menu_report_button"), currNum = reportButton, minNum = 1,                 maxNum = 12, desc = "menu_report_button_desc", format = buttonString },
    { name = ("menu_guard_button"),  currNum = guardButton,  minNum = 1,                 maxNum = 12, desc = "menu_guard_button_desc",  format = buttonString },
    { name = ("menu_sabo_button"),   currNum = saboButton,   minNum = 1,                 maxNum = 6,  desc = "menu_sabo_button_desc",   format = menuButtonString },
    { name = ("menu_default") },
    { name = ("menu_back") },
    { name = ("main_menu") },
    name = "bindsMenu",
    back = 7,
  }

  if currMenu then
    menu_enter(currMenu.name, currentOption)
  end
end

function one_player_reload()
  if focusPlayerOrCourse > (MAX_PLAYERS - 1) then focusPlayerOrCourse = 0 end
  local STP = gPlayerSyncTable[focusPlayerOrCourse]
  menuList["onePlayerMenu"] = {
    { name = ("menu_flip"),          title = "PLAYER_S",                                                                                                                           invalid = not has_mod_powers(0),              desc = ("flip_desc") },
    { name = ("menu_spectate"),      invalid = (focusPlayerOrCourse == 0 or (not GST.allowSpectate) or (gPlayerSyncTable[0].team == 1 and GST.mhState ~= 1 and GST.mhState ~= 2)), desc = ("menu_spectate_desc") },
    { name = ("menu_target"),        invalid = (focusPlayerOrCourse == 0 or STP.team ~= 1 or GST.mhMode == 2 or GST.mhMode == 3 or GST.mhState ~= 2),                              desc = ("target_desc") },
    { name = ("menu_stalk"),         invalid = (focusPlayerOrCourse == 0 or (not GST.allowStalk) or STP.team ~= 1 or GST.mhMode == 2 or GST.mhState ~= 2),                         desc = ("menu_stalk_desc") },
    { name = ("menu_pause"),         option = STP.pause,                                                                                                                           invalid = not has_mod_powers(0),              desc = ("pause_desc") },
    { name = ("menu_mute"),          option = STP.mute,                                                                                                                            invalid = not has_mod_powers(0),              desc = ("mute_desc") },
    { name = ("menu_forcespectate"), option = ((STP.forceSpectate or STP.dead) and has_mod_powers(0)),                                                                             invalid = not has_mod_powers(0),              desc = ("forcespectate_desc") },
    { name = ("menu_allowleave"),    invalid = (not has_mod_powers(0)) or (GST.mhMode == 2),                                                                                       desc = ("leave_desc") },
    { name = ("menu_setlife"),       invalid = (not has_mod_powers(0) or STP.team ~= 1 or GST.mhState == 0),                                                                       currNum = STP.runnerLives or GST.runnerLives, maxNum = 99,                  desc = ("setlife_desc") },
    { name = ("menu_back") },
    { name = ("main_menu") },
    name = "onePlayerMenu",
    back = 10,
  }
end

function build_blacklist_menu()
  menuList["blacklistMenu"] = {}
  local blacklistMenu = menuList["blacklistMenu"]
  for i = COURSE_MIN, COURSE_MAX - 1 do
    if ROMHACK.star_data and (not ROMHACK.star_data[i] or #ROMHACK.star_data[i] > 0) and (not ROMHACK.hubStages or not ROMHACK.hubStages[i]) then
      table.insert(blacklistMenu, { name = "COURSE", course = i, xOption = true })
    end
  end
  table.insert(blacklistMenu, { name = ("menu_blacklist_list"), action = "list", desc = ("menu_blacklist_list_desc") })
  table.insert(blacklistMenu, { name = ("menu_blacklist_save"), action = "save", desc = ("menu_blacklist_save_desc") })
  table.insert(blacklistMenu, { name = ("menu_blacklist_load"), action = "load", desc = ("menu_blacklist_load_desc") })
  table.insert(blacklistMenu, { name = ("menu_blacklist_reset"), action = "reset", desc = ("menu_blacklist_reset_desc") })
  table.insert(blacklistMenu, { name = ("menu_back") })
  blacklistMenu.back = #blacklistMenu
  table.insert(blacklistMenu, { name = ("main_menu") })
  blacklistMenu[1].title = ("menu_blacklist")
  blacklistMenu.name = "blacklistMenu"
end

function build_blacklist_course_menu()
  menuList["blacklistCourseMenu"] = {}
  local blacklistCourseMenu = menuList["blacklistCourseMenu"]
  local oneValid = false
  for i = 1, 7 do
    if valid_star(focusPlayerOrCourse, i, true, true) and (i ~= 7 or focusPlayerOrCourse > 15) then
      local valid = not (mini_blacklist[focusPlayerOrCourse * 10 + i])
      table.insert(blacklistCourseMenu, { name = get_custom_star_name(focusPlayerOrCourse, i), option = valid, star = i })
      if valid then oneValid = true end
    end
  end
  if #blacklistCourseMenu > 1 then
    table.insert(blacklistCourseMenu, { name = ("menu_toggle_all"), option = oneValid, star = "all" })
  end
  table.insert(blacklistCourseMenu, { name = ("menu_back") })
  blacklistCourseMenu.back = #blacklistCourseMenu
  table.insert(blacklistCourseMenu, { name = ("main_menu") })
  blacklistCourseMenu[1].title = "COURSE"
  blacklistCourseMenu.name = "blacklistCourseMenu"
end

function menu_enter(menu, option)
  if currMenu and (currMenu.name == "settingsMenu" or currMenu.name == "presetMenu" or currMenu.name == "autoMenu" or currMenu.name == "blacklistMenu" or currMenu.name == "blacklistCourseMenu") and (menu == nil or menu == "mainMenu" or menu == "marioHuntMenu") then
    save_settings()
  end

  if menu == "onePlayerMenu" then
    one_player_reload()
  elseif menu == "blacklistMenu" then
    build_blacklist_menu()
  elseif menu == "blacklistCourseMenu" then
    build_blacklist_course_menu()
  elseif currMenu and currMenu.name ~= menu then
    menu_reload()
  end

  currMenu = menuList[menu] or menuList["mainMenu"]
  currentOption = option or 1
  if bottomOption > currentOption + 7 then
    bottomOption = currentOption + 7
  end
  if currMenu and bottomOption > #currMenu then
    bottomOption = #currMenu
  end

  if mouseIdleTimer and mouseIdleTimer < 90 then
    mouseIdleTimer = 0
    hoveringOption = false
  end
end

function close_menu()
  menu_enter()
  if menu then
    play_sound(SOUND_GENERAL_PAINTING_EJECT, gGlobalSoundSource)
    menu = false
  end
  showingStats = false
  showingRules = false
  focusPlayerOrCourse = 0
end

local menuActions = {}
function action_setup()
  menuActions = {
    mainMenu = {
      function() menu_enter("marioHuntMenu") end,
      function() menu_enter("playerSettingsMenu") end,
      show_rules,
      list_settings,
      function() menu_enter("LanguageMenu") end,
      function() menu_enter("miscMenu") end,
      function() menu_enter("playerMenu") end,
      function() showingStats = true end,
      close_menu,
    },
    marioHuntMenu = {
      function() if GST.mhMode ~= 2 then menu_enter("startMenu") else menu_enter("startMenuMini") end end,
      function(option)
        if GST.mhMode ~= 3 then
          runner_randomize(option.currNum)
        else
          runner_randomize(-option.currNum - 2)
        end
      end,
      function(option) add_runner(option.currNum) end,
      function(option)
        change_game_mode("", option.currNum)
        menu_reload()
      end,
      function() menu_enter("settingsMenu") end,
      function()
        halt_command()
        close_menu()
      end,
      function() menu_enter() end,
    },
    startMenu = {
      function() start_game("main") end,
      function() start_game("alt") end,
      function() start_game("reset") end,
      function() start_game("continue") end,
      function() menu_enter("marioHuntMenu") end,
      function() menu_enter() end,
    },
    startMenuMini = {
      function() start_game("") end,
      function(option) start_game(tostring(option.currNum)) end,
      function() menu_enter("marioHuntMenu") end,
      function() menu_enter() end,
    },
    -- player menu is special case

    -- language is a special case
    settingsMenu = {
      function(option) runner_lives(tostring(option.currNum)) end,
      function(option)
        if GST.mhMode ~= 2 and GST.starMode then
          stars_needed_command(option.currNum)
        else
          time_needed_command(option.currNum)
        end
      end,
      function(option)
        option.option = not option.option
        if GST.mhMode == 2 then
          GST.firstTimer = option.option
        else
          star_mode_command("", option.option)
          menu_reload()
        end
      end,
      function(option)
        star_count_command(option.currNum)
      end,
      function(option)
        option.option = not option.option
        GST.noBowser = not option.option
        if GST.noBowser and GST.starRun < 1 then
          GST.starRun = 1
        end
        menu_reload()
      end,
      function(option)
        option.option = not option.option
        GST.freeRoam = option.option
        menu_reload()
      end,
      function()
        menu_enter("autoMenu")
      end,
      function(option)
        GST.maxShuffleTime = option.currNum * 30
      end,
      function(option)
        option.option = not option.option
        GST.nerfVanish = option.option
      end,
      function(option)
        option.option = not option.option
        if GST.mhMode ~= 3 then
          GST.allowSpectate = option.option
          if not option.option then
            djui_chat_message_create(trans("no_spectate"))
          else
            djui_chat_message_create(trans("can_spectate"))
          end
        else
          GST.confirmHunter = option.option
        end
      end,
      function(option)
        option.option = not option.option
        if GST.mhMode ~= 3 then
          GST.allowStalk = option.option
          currMenu[currentOption + 1].invalid = not option.option
        else
          GST.huntersWinEarly = option.option
        end
      end,
      function(option)
        if GST.mhMode ~= 3 then
          GST.stalkTimer = option.currNum * 30
        else
          GST.maxGlobalTalk = option.currNum * 30
        end
      end,
      function(option)
        option.option = not option.option
        GST.weak = option.option
        if not option.option then
          djui_chat_message_create(trans("not_weak"))
        else
          djui_chat_message_create(trans("now_weak"))
        end
      end,
      function(option)
        if GST.mhMode ~= 3 then
          GST.anarchy = option.currNum
          djui_chat_message_create(trans("anarchy_set_" .. GST.anarchy))
        else
          option.option = not option.option
          GST.anarchy = (option.option and 1) or 3
        end
      end,
      function(option)
        GST.dmgAdd = option.currNum
        if option.currNum ~= -1 then
          djui_chat_message_create(trans("dmgAdd_set", GST.dmgAdd))
        else
          djui_chat_message_create(trans("dmgAdd_set_ohko"))
        end
      end,
      function(option)
        local old = GST.countdown
        GST.countdown = option.currNum * 30
        if GST.mhState == 1 then
          local diff = old - GST.countdown
          GST.mhTimer = math.max(1, GST.mhTimer - diff)
        end
      end,
      function(option)
        option.option = not option.option
        GST.doubleHealth = option.option
      end,
      function(option)
        option.option = not option.option
        GST.starHeal = option.option
      end,
      function(option)
        GST.starSetting = option.currNum
        currMenu[currentOption + 1].invalid = (option.currNum ~= 0)
      end,
      function(option)
        option.option = not option.option
        GST.starStayOld = option.option
      end,
      function(option)
        GST.voidDmg = option.currNum
        if option.currNum ~= -1 then
          djui_chat_message_create(trans("voidDmg_set", GST.voidDmg))
        else
          djui_chat_message_create(trans("voidDmg_set_ohko"))
        end
      end,
      function(option)
        option.option = not option.option
        GST.spectateOnDeath = option.option
      end,
      function(option)
        GST.showOnMap = option.currNum
      end,
      function()
        menu_enter("blacklistMenu")
      end,
      function()
        menu_enter("presetMenu")
      end,
      function() menu_enter("marioHuntMenu", 5) end,
      function() menu_enter() end,
    },
    onePlayerMenu = {
      function()
        local global = network_global_index_from_local(focusPlayerOrCourse) or -1
        change_team_command(global)
        menu_reload()
      end,
      function()
        local global = network_global_index_from_local(focusPlayerOrCourse) or -1
        spectate_command(global)
      end,
      function()
        local global = network_global_index_from_local(focusPlayerOrCourse) or -1
        target_command(global)
      end,
      function()
        local global = network_global_index_from_local(focusPlayerOrCourse) or -1
        stalk_command(global)
      end,
      function(option)
        option.option = not option.option
        local global = network_global_index_from_local(focusPlayerOrCourse) or -1
        pause_command(global)
      end,
      function(option)
        option.option = not option.option
        local global = network_global_index_from_local(focusPlayerOrCourse) or -1
        if option.option then
          mute_command(global)
        else
          unmute_command(global)
        end
      end,
      function(option)
        option.option = not option.option
        local global = network_global_index_from_local(focusPlayerOrCourse) or -1
        force_spectate_command(global)
      end,
      function()
        local global = network_global_index_from_local(focusPlayerOrCourse) or -1
        allow_leave_command(global)
      end,
      function(option)
        local global = network_global_index_from_local(focusPlayerOrCourse) or -1
        set_life_command(global .. " " .. option.currNum)
      end,
      function() menu_enter("playerMenu", focusPlayerOrCourse + 1) end,
      function() menu_enter(nil, 7) end,
    },
    playerSettingsMenu = {
      function(option)
        runnerAppearance = option.currNum
        if runnerAppearance == 1 then
          djui_chat_message_create(trans("runner_sparkle"))
        elseif runnerAppearance == 2 then
          djui_chat_message_create(trans("runner_glow"))
        elseif runnerAppearance == 3 then
          djui_chat_message_create(trans("runner_outline"))
        elseif runnerAppearance == 4 then
          djui_chat_message_create(trans("runner_color"))
        else
          djui_chat_message_create(trans("runner_normal"))
        end
        mod_storage_save("runnerApp", tostring(option.currNum))
      end,
      function(option)
        hunterAppearance = option.currNum
        if hunterAppearance == 1 then
          djui_chat_message_create(trans("hunter_metal"))
        elseif hunterAppearance == 2 then
          djui_chat_message_create(trans("hunter_glow"))
        elseif hunterAppearance == 3 then
          djui_chat_message_create(trans("hunter_outline"))
        elseif hunterAppearance == 4 then
          djui_chat_message_create(trans("hunter_color"))
        else
          djui_chat_message_create(trans("hunter_normal"))
        end
        mod_storage_save("hunterApp", tostring(option.currNum))
      end,
      function(option)
        option.option = not option.option
        invincParticle = option.option
        mod_storage_save("invincParticle", tostring(option.option))
      end,
      function(option)
        option.option = not option.option
        showRadar = option.option
        mod_storage_save("showRadar", tostring(option.option))
      end,
      function(option)
        option.option = not option.option
        showMiniMap = option.option
        mod_storage_save("showMiniMap", tostring(option.option))
      end,
      function(option)
        option.option = not option.option
        showPaintingOverlays = option.option
        mod_storage_save("showPaintingOverlays", tostring(option.option))
      end,
      function(option)
        option.option = not option.option
        showSpeedrunTimer = option.option
        mod_storage_save("showSpeedrunTimer", tostring(option.option))
      end,
      function(option)
        option.option = not option.option
        gPlayerSyncTable[0].fasterActions = option.option
        mod_storage_save("fasterActions", tostring(option.option))
      end,
      function(option)
        option.option = not option.option
        romhackCam = option.option
        mod_storage_save("romhackCam", tostring(option.option))
        local c = gMarioStates[0].area.camera
        if romhackCam then
          set_camera_mode(c, CAMERA_MODE_ROM_HACK, 0)
        elseif c.mode == CAMERA_MODE_ROM_HACK then
          c.mode = CAMERA_MODE_NONE -- required, otherwise it doesn't work
          set_camera_mode(c, c.defMode or CAMERA_MODE_NONE, 0)
        end
      end,
      function(option)
        option.option = not option.option
        playPopupSounds = option.option
        mod_storage_save("playPopupSounds", tostring(option.option))
      end,
      function(option)
        option.option = not option.option
        noSeason = not option.option
        mod_storage_save("noSeason", tostring(not option.option))
        set_season_lighting(month, gNetworkPlayers[0].currLevelNum)
        if GST.mhState == 0 then
          set_lobby_music(month)
        end
      end,
      function(option)
        option.option = not option.option
        showLastStarTime = option.option
        mod_storage_save("showLastStarTime", tostring(option.option))
      end,
      function(option)
        option.option = not option.option
        mhHideHud = option.option
      end,
      function(option)
        option.option = not option.option
        gPlayerSyncTable[0].teamChat = option.option
        if option.option then
          djui_chat_message_create(trans("tc_toggle", trans("on")))
        else
          djui_chat_message_create(trans("tc_toggle", trans("off")))
        end
      end,
      function(option)
        option.option = not option.option
        if option.option then
          hard_mode_command("on")
        else
          hard_mode_command("off")
        end
        currMenu[currentOption + 1].option = false
      end,
      function(option)
        option.option = not option.option
        if option.option then
          hard_mode_command("ex on")
        else
          hard_mode_command("off")
        end
        currMenu[currentOption - 1].option = false
      end,
      function(option)
        option.option = not option.option
        demonOn = option.option
      end,
      function()
        menu_enter("bindsMenu", 1)
      end,
      function() menu_enter("hideRolesMenu", 1) end,
      function() menu_enter(nil, 2) end,
    },
    miscMenu = {
      function()
        spectate_command("free")
        menu_reload()
      end,
      function()
        spectate_command("runner")
        menu_reload()
      end,
      function(option)
        spectate_command("off")
        option.invalid = true
      end,
      function() stalk_command("") end,
      function()
        skip_command("")
        close_menu()
      end,
      function() blacklist_command("list") end,
      function(option)
        option.option = not option.option
        pause_command("all")
      end,
      function(option)
        option.option = not option.option
        force_spectate_command("all")
      end,
      function() menu_enter(nil, 6) end,
    },
    -- blacklistMenu is another special case
    -- same for the course menu
    hideRolesMenu = {
      function(option)
        option.option = not option.option
        if option.option then
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role | 2
        else
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role & ~2
        end
        mod_storage_save("showRoles", tostring(gPlayerSyncTable[0].role))
      end,
      function(option)
        option.option = not option.option
        if option.option then
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role | 4
        else
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role & ~4
        end
        mod_storage_save("showRoles", tostring(gPlayerSyncTable[0].role))
      end,
      function(option)
        option.option = not option.option
        if option.option then
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role | 8
        else
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role & ~8
        end
        mod_storage_save("showRoles", tostring(gPlayerSyncTable[0].role))
      end,
      function(option)
        option.option = not option.option
        if option.option then
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role | 16
        else
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role & ~16
        end
        mod_storage_save("showRoles", tostring(gPlayerSyncTable[0].role))
      end,
      function(option)
        option.option = not option.option
        if option.option then
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role | 32
        else
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role & ~32
        end
        mod_storage_save("showRoles", tostring(gPlayerSyncTable[0].role))
      end,
      function(option)
        option.option = not option.option
        if option.option then
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role | 64
        else
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role & ~64
        end
        mod_storage_save("showRoles", tostring(gPlayerSyncTable[0].role))
      end,
      function(option)
        option.option = not option.option
        if option.option then
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role | 128
        else
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role & ~128
        end
        mod_storage_save("showRoles", tostring(gPlayerSyncTable[0].role))
      end,
      function()
        gPlayerSyncTable[0].role = get_true_roles()
        menu_reload()
        mod_storage_save("showRoles", tostring(gPlayerSyncTable[0].role))
      end,
      function() menu_enter("playerSettingsMenu", 19) end,
      function() menu_enter(nil, 2) end,
    },
    presetMenu = {
      function()
        default_settings()
      end,
      function()
        if GST.mhMode == 2 then
          change_game_mode("normal", 0) -- normal mode if mini
        end
        runner_lives(tostring(0))       -- 0 lives
        local stars = 30
        if ROMHACK and ROMHACK.max_stars and ROMHACK.max_stars < 30 then
          stars = ROMHACK.max_stars
        end
        star_count_command(stars) -- 30/max stars
        if ROMHACK.no_bowser == nil then
          GST.noBowser = true     -- no bowser mode
        end
        GST.freeRoam = true       -- free roam
        runner_randomize()        -- auto
      end,
      function()
        if GST.mhMode ~= 0 and GST.mhMode ~= 3 then
          change_game_mode("normal", 0) -- normal mode
        end
        runner_lives(tostring(0))       -- 0 lives
        GST.dmgAdd = -1                 -- OHKO
        GST.spectateOnDeath = false
        runner_randomize(-3)            -- one hunter only
      end,
      function()
        for i = 1, MAX_PLAYERS - 1 do
          become_hunter(gPlayerSyncTable[i])
        end
        gPlayerSyncTable[0].team = 0
        change_team_command(network_global_index_from_local(0))
        change_game_mode("normal", 0) -- normal mode
        runner_lives(tostring(2))     -- 2 lives
        GST.dmgAdd = 0                -- No dmg add
        GST.doubleHealth = true       -- double health
      end,
      function()
        if GST.mhMode == 0 or GST.mhMode == 3 then
          change_game_mode("swap", 1) -- swap mode if normal or mystery
        end
        runner_lives(tostring(0))     -- 0 lives
        GST.dmgAdd = -1               -- OHKO
        runner_randomize()            -- auto
      end,
      function()
        for i = 0, MAX_PLAYERS - 1 do
          become_runner(gPlayerSyncTable[i])
        end
        change_game_mode("mini", 2) -- minihunt
        GST.runnerLives = 99
      end,
      function()
        GST.noBowser = false
        GST.allowStalk = false
        GST.starMode = true
        GST.runTime = 2
        GST.weak = false
        GST.anarchy = 0
        GST.dmgAdd = 0
        if GST.mhMode == 2 then
          GST.dmgAdd = 2
        elseif GST.mhMode == 3 then
          GST.dmgAdd = -1
        end
        GST.nerfVanish = false
        GST.countdown = 300
        GST.doubleHealth = false
        GST.voidDmg = -1
        GST.freeRoam = false
        GST.starHeal = false
        GST.starStayOld = false
        GST.spectateOnDeath = false
        GST.maxShuffleTime = 0
        GST.showOnMap = 1
      end,
      function()
        change_game_mode("normal", 0) -- normal mode
        GST.runnerLives = 1
        GST.noBowser = true
        GST.freeRoam = true
        GST.starRun = 120
        GST.allowStalk = false
        GST.allowSpectate = false
        GST.starMode = false
        GST.runTime = 7200
        GST.weak = false
        GST.anarchy = 0
        GST.dmgAdd = 0
        GST.nerfVanish = true
        GST.countdown = 600
        GST.doubleHealth = false
        GST.voidDmg = 3
        GST.starHeal = false
        GST.spectateOnDeath = true
        GST.maxShuffleTime = 0
        GST.starSetting = 2
      end,
      function() menu_enter("settingsMenu", 25) end,
      function() menu_enter(nil, 2) end,
    },
    saboMenu = {
      function()
        start_sabotage(1)
        close_menu()
      end,
      function()
        start_sabotage(2)
        close_menu()
      end,
      function()
        start_sabotage(3)
        close_menu()
      end,
      close_menu,
    },
    bindsMenu = {
      function(option)
        nerfVanishButton = option.currNum
        mod_storage_save("vanButton", tostring(option.currNum))
      end,
      function(option)
        menuButton = option.currNum
        mod_storage_save("menuButton", tostring(option.currNum))
      end,
      function(option)
        reportButton = option.currNum
        mod_storage_save("reportButton", tostring(option.currNum))
      end,
      function(option)
        guardButton = option.currNum
        mod_storage_save("guardButton", tostring(option.currNum))
      end,
      function(option)
        saboButton = option.currNum
        mod_storage_save("saboButton", tostring(option.currNum))
      end,
      function()
        nerfVanishButton = 2
        reportButton = 11
        guardButton = 11
        menuButton = 1
        saboButton = 4
        mod_storage_save("nerfVanishButton", tostring(nerfVanishButton))
        mod_storage_save("reportButton", tostring(reportButton))
        mod_storage_save("guardButton", tostring(guardButton))
        mod_storage_save("menuButton", tostring(menuButton))
        mod_storage_save("saboButton", tostring(saboButton))
        menu_reload()
      end,
      function() menu_enter("playerSettingsMenu", 18) end,
      function() menu_enter(nil, 2) end,
    },
    autoMenu = {
      function(option)
        if option.option then
          auto_command(0)
        else
          auto_command(-1)
        end
        menu_reload()
      end,
      function(option)
        auto_command(option.currNum)
        menu_reload()
      end,
      function(option)
        auto_command(-option.currNum - 2)
        menu_reload()
      end,
      function() menu_enter("settingsMenu", 7) end,
      function() menu_enter(nil, 2) end,
    },
  }
end

-- Variables to keep track of frame cooldown
local frameDelay = 0
local delayFrames = 60

-- To allow the menu when paused
local ranMenuThisFrame = false

function selectOption(option)
  if not menu then
    return
  end

  djui_hud_set_color(255, 255, 255, 255)

  if not marioHuntCommands or #marioHuntCommands < 1 then
    setup_commands()
  end

  local currentMenuName = currMenu.name
  if currentMenuName == "LanguageMenu" then
    if currMenu[option].lang then
      switch_lang(currMenu[option].lang)
    else -- back
      menu_enter(nil, 5)
    end
  elseif currentMenuName == "blacklistMenu" then
    if currMenu[option].course then
      focusPlayerOrCourse = currMenu[option].course
      prevOption = option
      menu_enter("blacklistCourseMenu")
    elseif currMenu[option].action then
      blacklist_command(currMenu[option].action)
      menu_enter("blacklistMenu", option)
    elseif currMenu.back == option then
      menu_enter("settingsMenu", 24)
    else
      menu_enter()
    end
  elseif currentMenuName == "blacklistCourseMenu" then
    if currMenu.back == option then
      menu_enter("blacklistMenu", prevOption)
    elseif currMenu[option].star == "all" then
      currMenu[option].option = not currMenu[option].option
      if currMenu[option].option then
        blacklist_command("remove " .. focusPlayerOrCourse)
      else
        blacklist_command("add " .. focusPlayerOrCourse)
      end
      menu_enter("blacklistCourseMenu", option)
    elseif currMenu[option].star then
      currMenu[option].option = not currMenu[option].option
      if currMenu[option].option then
        blacklist_command("remove " .. focusPlayerOrCourse .. " " .. currMenu[option].star)
      else
        blacklist_command("add " .. focusPlayerOrCourse .. " " .. currMenu[option].star)
      end
      menu_enter("blacklistCourseMenu", option)
    else
      menu_enter()
    end
  elseif currentMenuName == "playerMenu" then
    if option <= MAX_PLAYERS then
      focusPlayerOrCourse = option - 1
      menu_enter("onePlayerMenu")
    else
      menu_enter(nil, 7)
    end
  elseif menuActions[currentMenuName] then
    local action = menuActions[currentMenuName][option]
    if action then
      if validBack and currMenu[option].currNum == nil and (currentMenuName == "settingsMenu" or currentMenuName == "playerSettingsMenu" or currentMenuName == "onePlayerMenu" or currentMenuName == "bindsMenu") then
        for i, button in ipairs(currMenu) do
          if (not button.invalid) and button.savedNum and button.currNum and button.savedNum ~= button.currNum then
            djui_chat_message_create(trans("unsaved_changes"))
            validBack = false
            return
          end
        end
      end
      validBack = true

      action(currMenu[option])
      if currMenu[option] and currMenu[option].currNum then
        currMenu[option].savedNum = currMenu[option].currNum
      end
    end
  end
end

-- Function to handle menu rendering
function handleMenu()
  if (not menu) or showingStats or showingRules then
    return
  end

  djui_hud_set_resolution(RESOLUTION_DJUI)
  djui_hud_set_font(FONT_CUSTOM_HUD)
  local screenWidth = djui_hud_get_screen_width()
  local screenHeight = djui_hud_get_screen_height()
  -- apparently I designed this whole menu for 720p. Detect if this is greater than that and if so, adjust scale
  local adjustScale = screenHeight / 768
  djui_hud_set_color(255, 255, 255, 255)

  djui_hud_set_color(0, 0, 0, 200)
  djui_hud_render_rect(screenWidth * 0.1, 0, screenWidth * 0.8, screenHeight)

  local maxTextWidth = 0
  local textScale = 1.5 * adjustScale
  local optionScale = 2 * textScale

  for i, option in ipairs(currMenu) do
    local optionText = option.name
    if optionText ~= "menu_defeat_bowser" then
      optionText = trans(optionText)
    else
      local bad = ROMHACK["badGuy_" .. lang] or ROMHACK.badGuy or "Bowser"
      optionText = trans(optionText, bad)
    end

    local textWidth = 0
    if option.name:sub(1, 7) == "PLAYER_" then
      textWidth = screenWidth * 0.7
    elseif option.course then
      textWidth = djui_hud_measure_text(get_custom_level_name(option.course, course_to_level[option.course], 0)) *
          textScale
    elseif option.color then
      textWidth = djui_hud_measure_text(remove_color(optionText)) * textScale
    else
      textWidth = djui_hud_measure_text(optionText) * textScale
    end
    if option.currNum then
      local choiceString = ""
      local measureString = ""
      if option.time then -- time format
        choiceString = string.format("%d:%02d", option.currNum // 60, option.currNum % 60)
        measureString = string.format("%d:%02d", option.maxNum // 60, option.maxNum % 60)
      else
        choiceString = tostring(option.currNum)
      end

      if option.format then
        local min = option.minNum or 0

        choiceString = option.format[option.currNum - min + 1] or choiceString
        if choiceString:sub(1, 5) == "lang_" then
          choiceString = trans(choiceString:sub(6))
        end

        for a, text_ in ipairs(option.format) do
          local text = text_
          if text:sub(1, 5) == "lang_" then
            text = trans(text:sub(6))
          end
          if measureString:len() < text:len() then
            measureString = text
          end
        end
      elseif option.formatAuto then
        local allString = trans("all")
        if option.currNum == -1 then
          choiceString = "Auto"
        elseif option.currNum == -2 then
          choiceString = allString
        elseif option.currNum < 0 then
          choiceString = allString .. tostring(option.currNum + 2)
        end

        measureString = allString .. tostring(-MAX_PLAYERS)
      else
        if option.currNum == -1 then choiceString = "Any%" end
        if option.minNum and option.minNum < 0 then
          measureString = tostring("Any%")
        else
          measureString = tostring(option.maxNum)
        end
      end
      option.choiceWidth = djui_hud_measure_text(measureString)
      option.choiceString = choiceString
      textWidth = textWidth + (option.choiceWidth + 47) * optionScale
      if textWidth > screenWidth * 0.6 then
        local prevScale = textScale
        textScale = textScale * (screenWidth * 0.6) / textWidth
        optionScale = 2 * textScale
        textWidth = textWidth * textScale / prevScale
      end
    end
    maxTextWidth = math.max(maxTextWidth, textWidth)
  end
  maxTextWidth = maxTextWidth + 10

  local optionCount = #currMenu
  if optionCount > 7 then
    optionCount = 7
  end
  if optionCount > bottomOption then bottomOption = optionCount end

  if currentOption > bottomOption then
    bottomOption = currentOption
  elseif currentOption <= (bottomOption - optionCount) then
    bottomOption = currentOption + optionCount - 1
  end

  local optionX = screenWidth / 2 - maxTextWidth / 2
  local optionY = (screenHeight / 2 - (screenHeight * 0.1 * (optionCount - 1)) / 2)
  local titleScale = 4 * adjustScale

  local titleText = tostring(currMenu[1].title)
  local titleCenter = 0
  djui_hud_set_color(255, 255, 255, 255)
  if titleText == "PLAYER_S" then
    djui_hud_set_font(FONT_RECOLOR_HUD) -- DX exclusive
    local np = gNetworkPlayers[focusPlayerOrCourse]
    if np and np.connected then
      local playerColor = network_get_player_text_color_string(focusPlayerOrCourse)
      titleText = playerColor .. np.name
      titleText = cap_color_text(titleText, PLAYER_NAME_CUTOFF)
      --titleText = remove_color(np.name)
    else
      menu_enter("playerMenu", focusPlayerOrCourse + 1)
    end

    local titleWidth = djui_hud_measure_text(remove_color(titleText))
    local y = screenHeight * 0.03 - 10 * titleScale
    if titleWidth * titleScale > screenWidth * 0.8 then
      titleScale = screenWidth * 0.8 / (titleWidth + 20)
    end

    titleCenter = (screenWidth - titleWidth * titleScale) / 2

    djui_hud_print_text_with_color(titleText, titleCenter, y, titleScale)
    --print_text_ex_hud_font(titleText, titleCenter, screenHeight * 0.03, titleScale)
  else
    if titleText == "COURSE" then
      titleText = get_custom_level_name(focusPlayerOrCourse, course_to_level[focusPlayerOrCourse], 0)
    else
      titleText = trans(titleText)
    end

    local titleWidth = djui_hud_measure_text(titleText)
    if titleWidth * titleScale > screenWidth * 0.8 then -- shrink the title if it's too big
      titleScale = screenWidth * 0.8 / (titleWidth + 20)
    end

    titleCenter = (screenWidth - titleWidth * titleScale) / 2
    print_text_ex_hud_font(titleText, titleCenter, screenHeight * 0.03, titleScale)
  end
  djui_hud_set_font(FONT_CUSTOM_HUD)

  for i, option in ipairs(currMenu) do
    local render = true
    local menuArrowScale = (4 * adjustScale)
    if i > bottomOption then
      djui_hud_set_color(255, 255, 255, 255)
      djui_hud_render_texture(TEX_MENU_ARROW_DOWN, screenWidth / 2 - 23, screenHeight - 20 * menuArrowScale,
        menuArrowScale, menuArrowScale)
      break
    elseif i <= (bottomOption - optionCount) then
      djui_hud_set_color(255, 255, 255, 255)
      djui_hud_render_texture(TEX_MENU_ARROW_UP, screenWidth / 2 - 23, screenHeight * 0.15, menuArrowScale,
        menuArrowScale)
      render = false
    end

    if render then
      local textColor = { 255, 255, 255, 255 } -- Default text color

      if option.option ~= nil then
        if option.option then
          textColor = { 92, 255, 92, 255 } -- Green text color
        else
          textColor = { 255, 92, 92, 255 } -- Red text color
        end
      end

      djui_hud_set_font(FONT_NORMAL)
      local optionText = option.name
      if optionText ~= "menu_defeat_bowser" then
        optionText = trans(optionText)
      else
        local bad = ROMHACK["badGuy_" .. lang] or ROMHACK.badGuy or "Bowser"
        optionText = trans(optionText, bad)
      end
      local roleText = nil
      if option.name:sub(1, 7) == "PLAYER_" then
        local index = tonumber(option.name:sub(8)) or 0
        local np = gNetworkPlayers[index]
        if np and np.connected then
          local playerColor = network_get_player_text_color_string(index)
          local roleName, colorString = get_role_name_and_color(index)
          roleText = colorString .. roleName
          optionText = playerColor .. np.name
          optionText = cap_color_text(optionText, PLAYER_NAME_CUTOFF)
        else
          roleText = ""
          optionText = trans("empty", index)
        end
      elseif option.course then
        optionText = get_custom_level_name(option.course, course_to_level[option.course], 0)
      else
        optionText = trans(optionText)
      end

      local textWidth = 0
      if option.color then
        textWidth = djui_hud_measure_text(remove_color(optionText)) * textScale
      else
        textWidth = djui_hud_measure_text(optionText) * textScale
      end
      local textX = (screenWidth - textWidth) / 2

      if roleText then textX = screenWidth * 0.2 end

      if option.currNum then textX = (screenWidth - textWidth - option.choiceWidth * optionScale - 80) / 2 end

      if roleText == "" then
        option.invalid = true
      elseif roleText then
        option.invalid = (option.name == "PLAYER_0" and not has_mod_powers(0))
      end

      -- special case for course menu
      if option.course then
        local allValid = true
        local oneValid = false

        for i = 1, 7 do
          if (i ~= 7 or option.course > 15) and valid_star(option.course, i, true, true) then
            if not mini_blacklist[option.course * 10 + i] then
              oneValid = true
            else
              allValid = false
            end
          end
          if oneValid and not allValid then
            break
          end
        end
        if allValid then
          textColor = { 92, 255, 92, 255 }  -- Green text color
        elseif oneValid then
          textColor = { 255, 255, 92, 255 } -- Yellow text color
        else
          textColor = { 255, 92, 92, 255 }  -- Red text color
        end
      end

      -- darken unselectable options
      if option.invalid then
        textColor[4] = 100 -- set alpha to 100
      end
      djui_hud_set_color(table.unpack(textColor))

      if option.color then
        if option.option ~= false or roleText then
          djui_hud_print_text_with_color(optionText, textX, optionY, textScale, textColor[4])
        else
          djui_hud_print_text(remove_color(optionText), textX, optionY, textScale)
        end
      else
        djui_hud_print_text(optionText, textX, optionY, textScale)
      end
      if roleText then
        textX = screenWidth * 0.8 - djui_hud_measure_text(remove_color(roleText)) * textScale
        djui_hud_print_text_with_color(roleText, textX, optionY, textScale)
      end

      djui_hud_set_font(FONT_CUSTOM_HUD)
      -- print "x"
      if option.xOption and currentOption == i and (not option.invalid) and mouseIdleTimer >= 90 then
        local x = textX + textWidth
        if option.name:sub(1, 7) == "PLAYER_" then
          x = textX + 30 * optionScale
        end
        local y = optionY - 5 * optionScale
        djui_hud_set_color(255, 255, 255, 255)
        djui_hud_print_text("X", x, y, optionScale / 2)
      end

      -- allows selecting an option with the mouse
      if mouseIdleTimer < 2 then
        local rectX = optionX
        local rectY = optionY
        local rectWidth = maxTextWidth
        local rectHeight = screenHeight * 0.07
        --djui_hud_set_resolution(RESOLUTION_DJUI)
        --djui_hud_render_rect(rectX, rectY, rectWidth, rectHeight)
        if mouseX >= rectX and mouseX <= rectX + rectWidth
            and mouseY >= rectY and mouseY <= rectY + rectHeight then
          if currentOption ~= i then
            currentOption = i
            play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
          end
          hoveringOption = true
        end
      end

      if option.currNum then
        local arrowScale = (5 * optionScale) / 3
        local choiceWidth = (option.choiceWidth * optionScale - djui_hud_measure_text(option.choiceString) * optionScale) /
            2
        print_text_ex_hud_font(option.choiceString, textX + textWidth + choiceWidth + 15 * optionScale, optionY,
          optionScale)
        djui_hud_render_texture(TEX_MENU_ARROW, textX + textWidth + 8 * arrowScale,
          optionY + 2 + 8 * arrowScale, -arrowScale, -arrowScale)
        djui_hud_render_texture(TEX_MENU_ARROW, textX + textWidth + (option.choiceWidth + 20) * optionScale,
          optionY + 2, arrowScale, arrowScale)

        -- mouse control
        if mouseIdleTimer < 90 and i == currentOption and hoveringOption then
          local relativeX = mouseX - textX - textWidth
          if relativeX <= 16 * optionScale then
            mouseArrowKey = 3 -- left
          elseif relativeX >= (option.choiceWidth + 16) * optionScale then
            mouseArrowKey = 1 -- right
          else
            mouseArrowKey = 0 -- none
          end
        elseif i == currentOption then
          mouseArrowKey = 0 -- none
        end
      end

      if i == currentOption and hoveringOption then
        local rectX = optionX          -- maxTextWidth * 0.2
        local rectY = optionY
        local rectWidth = maxTextWidth -- * 1.4
        local rectHeight = screenHeight * 0.07
        if option.currNum and option.maxNum >= 10 and sMenuInputsDown & X_BUTTON ~= 0 then
          djui_hud_set_color(92, 92, 255, math.abs((frameCounter % 60) - 30) * 2) -- blue
        else
          djui_hud_set_color(92, 255, 92, math.abs((frameCounter % 60) - 30) * 2) -- green
        end
        djui_hud_render_rect(rectX, rectY, rectWidth, rectHeight)
        djui_hud_set_color(255, 255, 255, 255)

        if option.currNum and not option.savedNum then
          option.savedNum = option.currNum
        end

        if currMenu[currentOption].desc then
          local descScale = adjustScale
          local desc = (trans(currMenu[currentOption].desc))
          local s, e = desc:find("- ")
          if s then
            desc = desc:sub(e + 1)
          end
          djui_hud_set_font(FONT_NORMAL)
          djui_hud_set_color(255, 255, 255, 255)
          local descWidth = djui_hud_measure_text(desc) * descScale
          local y = screenHeight - 50 * descScale
          local descX = (screenWidth - descWidth) / 2
          if descWidth > screenWidth * 0.7 then
            local spaceLoc = desc:find(" ", desc:len() // 2) or desc:len() // 2
            local desc1 = desc:sub(1, spaceLoc)
            desc = desc:sub(spaceLoc)
            descWidth = djui_hud_measure_text(desc1) * descScale
            descX = (screenWidth - descWidth) / 2
            y = y - 10 * descScale
            djui_hud_print_text(desc1, descX, y, descScale)
            descWidth = djui_hud_measure_text(desc) * descScale
            descX = (screenWidth - descWidth) / 2
            y = y + 30 * descScale
          end
          djui_hud_print_text(desc, descX, y, descScale)
        end
      elseif option.currNum and option.savedNum ~= option.currNum then
        if not option.savedNum then
          option.savedNum = option.currNum
        elseif not option.invalid then
          local rectX = optionX          -- maxTextWidth * 0.2
          local rectY = optionY
          local rectWidth = maxTextWidth -- * 1.4
          local rectHeight = screenHeight * 0.07
          djui_hud_set_color(255, 255, 92, 80)
          djui_hud_render_rect(rectX, rectY, rectWidth, rectHeight)
          djui_hud_set_color(255, 255, 255, 255)
        end
      end

      optionY = optionY + (screenHeight * 0.1)
    end
  end

  -- render scroll bar
  if #currMenu > optionCount then
    local x = screenWidth * 0.9 - 40 * adjustScale
    local y = 150
    djui_hud_set_color(0, 0, 0, 155)
    djui_hud_render_rect(x, y, 20 * adjustScale, screenHeight - 210)
    local farDown = 0
    local fullportion = screenHeight - 214
    local partportion = fullportion * 7 / #currMenu

    -- handle scroll bar with mouse
    if mouseGrabbedScrollBar then
      local scrolling = true
      farDown = mouseScrollBarY + mouseY
      while scrolling do
        scrolling = false
        local shiftUp = (bottomOption - optionCount - 0.5) * fullportion / #currMenu
        local shiftDown = (bottomOption - optionCount + 0.5) * fullportion / #currMenu
        --djui_chat_message_create(string.format("%d<%d<%d",shiftUp,farDown,shiftDown))
        if farDown < 0 then
          farDown = 0
        elseif farDown + partportion > fullportion then
          farDown = fullportion - partportion
        end
        if farDown < shiftUp then
          bottomOption = bottomOption - 1
          currentOption = bottomOption - optionCount + 1
          scrolling = true
        elseif farDown > shiftDown then
          bottomOption = bottomOption + 1
          currentOption = bottomOption
          scrolling = true
        end
      end
    else
      farDown = (bottomOption - optionCount) * fullportion / #currMenu
    end

    djui_hud_set_color(255, 255, 255, 155)
    djui_hud_render_rect(x + 2, y + 2 + farDown, 16 * adjustScale, partportion)
  end

  handle_mouse()
end

-- stat table stuff; this part is my code
showingStats = false -- showing the stats table
local statDesc = 1   -- which stat we're looking at the description for
local sortBy = 0     -- what we're sorting by. 0 is none, and negative is descending
local menuY = 0      -- used with scroll bar
local altNum = 0     -- used with alt1 and alt2

-- rules menu stuff; also my code
showingRules = false          -- showing the rules menu
ruleSlide = 0                 -- which part of this menu is being shown
local mouseRulesDirection = 0 -- used for mouse buttons
ruleEgg = false               -- if the easter egg has appeared

local statOrder = { "wins_standard", "wins", "wins_mys", "kills",
  "maxStreak", "maxStar", "placement", "parkourRecord", "playtime" }
local statOrder_alt1 = { "hardWins_standard", "hardWins", "hardWins_mys", nil, nil, nil, "placementASN", "pRecordOmm" }
local statOrder_alt2 = { "exWins_standard", "exWins", "exWins_mys", nil, nil, nil, "placement", "pRecordOther" }

local descOrder = { "stat_wins_standard", "stat_wins", "stat_wins_mys", "stat_kills", "stat_combo", "stat_mini_stars",
  "stat_placement", "stat_parkour_time", "stat_playtime" }
local descOrder_alt1 = { "stat_wins_hard_standard", "stat_wins_hard", "stat_wins_hard_mys", nil, nil, nil,
  "stat_placement_asn",
  "stat_parkour_time_omm" }
local descOrder_alt2 = { "stat_wins_ex_standard", "stat_wins_ex", "stat_wins_ex_mys", nil, nil, nil, nil,
  "stat_parkour_time_other" }

function stats_table_hud()
  djui_hud_set_resolution(RESOLUTION_DJUI)

  local text = ""

  local screenWidth = djui_hud_get_screen_width()
  local screenHeight = djui_hud_get_screen_height()
  -- apparently I designed this whole menu for 720p. Detect if this is greater than that and if so, adjust scale
  local scale = screenHeight / 768
  local width = 0
  local x = 0
  local y = 180 * scale
  djui_hud_set_color(0, 0, 0, 200);
  djui_hud_render_rect(screenWidth * 0.1, 0, screenWidth * 0.8, screenHeight);

  -- title
  djui_hud_set_font(FONT_CUSTOM_HUD)
  text = trans("menu_stats")
  width = djui_hud_measure_text(text) * 4 * scale
  x = (screenWidth - width) / 2
  djui_hud_set_color(255, 255, 255, 255);
  print_text_ex_hud_font(text, x, 10, 4 * scale);
  djui_hud_set_font(FONT_NORMAL)

  -- "player"
  text = trans("player")
  width = djui_hud_measure_text(text) * scale
  x = screenWidth * 0.1 + 150 * scale - width / 2
  djui_hud_print_text(text, x, y - 64 * scale, scale);

  -- scores, icons, etc.
  x = screenWidth * 0.1 + 300 * scale
  space = (screenWidth * 0.8 - 420 * scale) / (#statOrder - 1)
  for i = 1, #stat_icon_data do
    local data = stat_icon_data[i]
    local iconScale = scale * 1.5
    if altNum == 1 and stat_icon_data_alt1[i] then
      data = stat_icon_data_alt1[i]
    elseif altNum == 2 and stat_icon_data_alt2[i] then
      data = stat_icon_data_alt2[i]
    end

    if data.tex == TEX_FLAG then
      djui_hud_set_color(255, 255, 255, 255)
      djui_hud_render_texture(TEX_POLE, x - iconScale, y - 64 * scale, iconScale, iconScale)
    end
    djui_hud_set_color(data.r, data.g, data.b, 255)
    djui_hud_render_texture(data.tex, x - iconScale, y - 64 * scale, iconScale, iconScale)
    if math.abs(sortBy) == i then
      local sign = i / sortBy
      local arrowScale = scale * 1.2
      if sign == 1 then
        djui_hud_set_color(92, 255, 92, 255)
        djui_hud_render_texture(TEX_ARROW, x + 20 * arrowScale, y - 30 * arrowScale, arrowScale, arrowScale)
      else
        djui_hud_set_color(255, 92, 92, 255)
        djui_hud_render_texture(TEX_ARROW, x + 37.5 * arrowScale, y - 12.5 * arrowScale, -arrowScale, -arrowScale)
      end
    end

    -- selected option
    if mouseIdleTimer < 2 or (statDesc == i and hoveringOption) then
      local rectX = x + 20 * scale - space / 2
      local rectY = y - 69 * scale
      local rectWidth = space
      local rectHeight = screenHeight - 56 * scale - rectY
      --djui_hud_set_resolution(RESOLUTION_DJUI)
      --djui_hud_render_rect(rectX, rectY, rectWidth, rectHeight)
      if mouseX >= rectX and mouseX <= rectX + rectWidth
          and mouseY >= rectY and mouseY <= rectY + rectHeight then
        if statDesc ~= i then
          statDesc = i
          play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
        end
        hoveringOption = true
      end

      if statDesc == i and hoveringOption then
        djui_hud_set_color(92, 255, 92, math.abs((frameCounter % 60) - 30) * 2)
        djui_hud_render_rect(rectX, rectY, rectWidth, rectHeight)
      end
    end

    x = x + space
  end

  local actSortBy = math.abs(sortBy)
  local stat = statOrder[actSortBy]
  if altNum == 1 and statOrder_alt1[actSortBy] then
    stat = statOrder_alt1[actSortBy]
  elseif altNum == 2 and statOrder_alt2[actSortBy] then
    stat = statOrder_alt2[actSortBy]
  end

  local statTable = {}
  for i = 0, (MAX_PLAYERS - 1) do
    local np = gNetworkPlayers[i]
    if i == 0 or np.connected then
      table.insert(statTable, i)
    end
  end

  if sortBy ~= 0 and #statTable > 1 then
    table.sort(statTable, function(a, b)
      local aSMario = gPlayerSyncTable[a]
      local bSMario = gPlayerSyncTable[b]
      if sortBy < 0 then
        return (aSMario[stat] or 0) < (bSMario[stat] or 0)
      else
        return (aSMario[stat] or 0) > (bSMario[stat] or 0)
      end
    end)
  end

  -- render scroll bar
  local maxStatsNames = (screenHeight / scale - 240) // 32
  if (MAX_PLAYERS > maxStatsNames) and (network_player_connected_count() > maxStatsNames) then
    local pcount = network_player_connected_count()
    local x = screenWidth * 0.9 - 40 * scale
    local y = 150
    local fullportion = screenHeight - 214
    local partportion = fullportion * maxStatsNames / pcount
    local farDown = 0
    djui_hud_set_color(0, 0, 0, 155)
    djui_hud_render_rect(x, y, 20 * scale, screenHeight - 210)

    -- handle scroll bar with mouse
    local scrolling = true
    if mouseGrabbedScrollBar then
      farDown = mouseScrollBarY + mouseY
      local LIMIT = pcount - maxStatsNames
      while scrolling and LIMIT > 0 do
        LIMIT = LIMIT - 1
        scrolling = false
        local shiftUp = (menuY - 0.5) * fullportion / pcount
        local shiftDown = (menuY + 0.5) * fullportion / pcount
        --djui_chat_message_create(string.format("%d<%d<%d",shiftUp,farDown,shiftDown))
        if farDown < 0 then
          farDown = 0
        elseif farDown + partportion > fullportion then
          farDown = fullportion - partportion
        end
        if farDown < shiftUp then
          menuY = menuY - 1
          scrolling = true
        elseif farDown > shiftDown then
          menuY = menuY + 1
          scrolling = true
        end
      end
    else
      if menuY > pcount - maxStatsNames then
        menuY = pcount - maxStatsNames
      end
      farDown = menuY * fullportion / pcount
    end

    djui_hud_set_color(255, 255, 255, 155)
    djui_hud_render_rect(x + 2, y + 2 + farDown, 16 * scale, partportion)
  end

  -- player names
  y = y - (menuY * 32 * scale)
  for a, i in ipairs(statTable) do
    if y >= 180 * scale and y < (screenHeight - 80 * scale) then
      local sMario = gPlayerSyncTable[i]
      local np = gNetworkPlayers[i]
      local playerColor = network_get_player_text_color_string(i)

      text = playerColor .. np.name .. "\\#ffffff\\"
      text = cap_color_text(text, PLAYER_NAME_CUTOFF)
      width = djui_hud_measure_text(remove_color(text)) * scale
      x = screenWidth * 0.1 + 150 * scale - width / 2
      djui_hud_print_text_with_color(text, x, y, scale)

      x = screenWidth * 0.1 + 295 * scale
      space = (screenWidth * 0.8 - 420 * scale) / (#statOrder - 1)
      for i = 1, #statOrder do
        local stat = statOrder[i]
        if altNum == 1 and statOrder_alt1[i] then
          stat = statOrder_alt1[i]
        elseif altNum == 2 and statOrder_alt2[i] then
          stat = statOrder_alt2[i]
        end

        text = string.format("%04d", (sMario[stat] or 0))
        if stat == "parkourRecord" or stat == "pRecordOmm" or stat == "pRecordOther" then
          local time = sMario[stat] or 599
          if time == 599 then
            djui_hud_set_color(100, 100, 100, 255)
          else
            djui_hud_set_color(255, 255, 255, 255)
          end
          local seconds = time % 60
          local minutes = time // 60 % 60
          text = string.format("%01d:%02d", minutes, seconds)
        else
          if text == "0000" or (text == "9999" and (stat == "placement" or stat == "placementASN")) then
            djui_hud_set_color(100, 100, 100, 255)
          else
            djui_hud_set_color(255, 255, 255, 255)
          end
        end
        djui_hud_print_text(text, x, y, scale)
        x = x + space
      end
    end
    y = y + 32 * scale
  end

  -- desc
  local newScale = scale * 1.5
  djui_hud_set_color(255, 255, 255, 255);
  if statDesc ~= 0 and hoveringOption then
    local desc = descOrder[statDesc]
    if altNum == 1 and descOrder_alt1[statDesc] then
      desc = descOrder_alt1[statDesc]
    elseif altNum == 2 and descOrder_alt2[statDesc] then
      desc = descOrder_alt2[statDesc]
    end
    text = trans(desc)
    width = djui_hud_measure_text(text) * newScale
    x = (screenWidth - width) / 2
    y = screenHeight - 32 * newScale

    djui_hud_print_text(text, x, y, newScale);
  end

  -- back button
  x = screenWidth * 0.1 + 21 * newScale
  y = screenHeight * 0.05
  djui_hud_render_texture(TEX_MENU_ARROW, x, y, -newScale * 2, -newScale * 2)
  if mouseIdleTimer < 2 or (statDesc == 0 and hoveringOption) then
    local rectX = x - 16 * newScale
    local rectY = y - 18 * newScale
    local rectWidth = 21 * newScale
    local rectHeight = 21 * newScale
    --djui_hud_set_resolution(RESOLUTION_DJUI)
    --djui_hud_render_rect(rectX, rectY, rectWidth, rectHeight)
    if mouseX >= rectX and mouseX <= rectX + rectWidth
        and mouseY >= rectY and mouseY <= rectY + rectHeight then
      if statDesc ~= 0 then
        statDesc = 0
        play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
      end
      hoveringOption = true
    end

    if statDesc == 0 and hoveringOption then
      djui_hud_set_color(92, 255, 92, math.abs((frameCounter % 60) - 30) * 2)
      djui_hud_render_rect(rectX, rectY, rectWidth, rectHeight)
    end
  end

  handle_mouse()
end

function rules_menu_hud(forceSlide)
  djui_hud_set_resolution(RESOLUTION_DJUI)

  local text = ""

  local screenWidth = djui_hud_get_screen_width()
  local screenHeight = djui_hud_get_screen_height()
  -- apparently I designed this whole menu for 720p. Detect if this is greater than that and if so, adjust scale
  local scale = screenHeight / 384
  local width = 0
  local x = 0
  local y = 50 * scale
  djui_hud_set_color(0, 0, 0, 200);
  djui_hud_render_rect(screenWidth * 0.1, 0, screenWidth * 0.8, screenHeight);

  -- title
  djui_hud_set_font(FONT_CUSTOM_HUD)
  text = trans("menu_rules")
  width = djui_hud_measure_text(text) * 2 * scale
  x = (screenWidth - width) / 2
  djui_hud_set_color(255, 255, 255, 255);
  print_text_ex_hud_font(text, x, 5 * scale, 2 * scale);
  djui_hud_set_font(FONT_NORMAL)

  -- all text
  local sMario0 = gPlayerSyncTable[0]
  local runners = trans("runners")
  local hunters = trans("hunters")
  local tex = nil
  local imgScale = 2 * scale
  local finalSlide = 5
  local currSlide = forceSlide or ruleSlide
  if GST.mhMode == 3 then
    finalSlide = 8
  end

  if currSlide == 0 then
    if GST.mhMode == 2 then
      text = (trans("welcome_mini"))
      tex = "mh_rules_00"
    elseif GST.mhMode == 3 then
      text = (trans("welcome_mys"))
      tex = "mh_rules_00"
    else
      if month == 13 or ruleEgg then
        text = (trans("welcome_egg"))
        tex = "mh_rules_01"
      else
        text = (trans("welcome"))
        tex = "mh_rules_00"
      end
    end
  elseif currSlide == 1 then
    local extraRun = ""
    if GST.mhState ~= 0 and GST.mhState < 3 then
      if sMario0.team ~= 1 then
        extraRun = " " .. trans("shown_above")
      else
        extraRun = " " .. trans("thats_you")
      end
    end
    local runGoal = ""
    if GST.mhMode == 2 then
      runGoal = trans("mini_collect")
      tex = "mh_rules_03"
    elseif (GST.starRun) == -1 then
      local bad = ROMHACK["badGuy_" .. lang] or ROMHACK.badGuy or "Bowser"
      runGoal = trans("any_bowser", bad)
      tex = "mh_rules_02"
    elseif GST.noBowser ~= true then
      local bad = ROMHACK["badGuy_" .. lang] or ROMHACK.badGuy or "Bowser"
      runGoal = trans("collect_bowser", GST.starRun, bad)
      tex = "mh_rules_02"
    else
      runGoal = trans("collect_only", GST.starRun)
      tex = "mh_rules_03"
    end
    if GST.mhMode == 3 then
      runGoal = runGoal .. "\n" .. trans("mystery_altgoal")
    end
    text = string.format("\\#00ffff\\%s\\#ffffff\\%s:\n%s",
      runners,
      extraRun,
      runGoal)
  elseif currSlide == 2 then
    tex = "mh_rules_04"
    local extraHunt = ""
    if GST.mhState ~= 0 and GST.mhState < 3 and sMario0.team ~= 1 then
      extraHunt = " " .. trans("thats_you")
    end
    local huntGoal = ""
    if GST.mhMode == 0 then
      huntGoal = trans("all_runners")
    elseif GST.mhMode == 3 then
      huntGoal = trans("all_runners") .. "\n" .. trans("keep_secret")
    else
      huntGoal = trans("any_runners")
    end
    text = string.format("\\#ff5a5a\\%s\\#ffffff\\%s:\n%s",
      hunters,
      extraHunt,
      huntGoal)
  elseif currSlide == 3 then
    local runLives = trans_plural("lives", (GST.runnerLives + 1))
    local needed = ""
    if GST.mhMode == 2 then
      tex = "mh_rules_07"
    elseif (GST.starMode) then
      needed = "; " .. trans("stars_needed", GST.runTime)
      tex = "mh_rules_06"
    else
      local seconds = GST.runTime // 30 % 60
      local minutes = GST.runTime // 1800
      needed = "; " .. trans("time_needed", minutes, seconds)
      tex = "mh_rules_05"
    end
    local becomeHunter = ""
    if not GST.spectateOnDeath then
      becomeHunter = "; " .. trans("become_hunter")
    else
      becomeHunter = "; " .. trans("become_spectator")
    end
    text = string.format("\\#00ffff\\%s\\#ffffff\\:\n%s%s%s.",
      runners,
      runLives,
      needed,
      becomeHunter)
  elseif currSlide == 4 then
    local becomeRunner = ""
    if GST.mhMode ~= 0 and GST.mhMode ~= 3 then
      becomeRunner = "; " .. trans("become_runner")
      tex = "mh_rules_09"
    else
      tex = "mh_rules_08"
    end
    local spectate = ""
    if GST.mhMode == 3 then
      spectate = "... " .. trans("unless_defeated")
    elseif GST.allowSpectate == true then
      spectate = "; " .. trans("spectate")
    end
    text = string.format("\\#ff5a5a\\%s\\#ffffff\\:\n%s%s%s.",
      hunters,
      trans("infinite_lives"),
      becomeRunner,
      spectate)
  elseif currSlide == finalSlide then -- for mysteryhunt, there's three slides before this
    tex = "mh_rules_10"
    local banned = trans("banned_general")

    local goal = ""
    local fun = trans("fun")
    if GST.mhMode == 2 then
      goal = trans("mini_goal", GST.runTime // 1800, (GST.runTime % 1800) // 30) .. "\n"
    end

    text = string.format("%s\n\n%s%s",
      banned,
      goal,
      fun)
  elseif currSlide == 5 then -- mysteryhunt exclusive slide
    tex = "mh_rules_13"

    text = trans("runners_can_kill")
  elseif currSlide == 6 then -- mysteryhunt exclusive slide
    tex = "mh_rules_14"

    local deadBecome = ""
    if not GST.confirmHunter then
      deadBecome = trans("dead_become_noconfirm")
    elseif GST.spectateOnDeath then
      deadBecome = trans("dead_become")
    else
      deadBecome = trans("dead_become_infection")
    end
    local reportInfo = trans("report_info_rules", buttonString[reportButton])
    local guardInfo = trans("guard_info_rules", buttonString[guardButton])

    text = string.format("%s\n%s\n%s",
      deadBecome,
      reportInfo,
      guardInfo)
  elseif currSlide == 7 then -- mysteryhunt exclusive slide
    tex = "mh_rules_12"

    text = trans("sabo_info_rules", buttonString[reportButton])
  end

  local newline = text:find("\n") or (text:len() + 1)
  local LIMIT = 0
  while newline and LIMIT < 100 do
    local render = text:sub(1, newline - 1)
    width = djui_hud_measure_text(remove_color(render)) * scale
    while width > screenWidth * 0.8 and LIMIT < 100 do
      local spaceLoc = render:find(" ", 40) or 45
      local subrender = render:sub(1, spaceLoc - 1)
      width = djui_hud_measure_text(remove_color(subrender)) * scale
      x = (screenWidth - width) / 2
      djui_hud_print_text_with_color(subrender, x, y, scale)
      y = y + 30 * scale

      render = render:sub(spaceLoc + 1)
      width = djui_hud_measure_text(remove_color(render)) * scale
      LIMIT = LIMIT + 1
    end
    x = (screenWidth - width) / 2
    djui_hud_print_text_with_color(render, x, y, scale)

    if newline == text:len() + 1 then break end
    text = text:sub(newline + 1)
    y = y + 30 * scale
    newline = text:find("\n") or (text:len() + 1)
  end

  if tex then
    if currSlide == 0 or currSlide == 7 then
      y = y - 120 * scale
    elseif currSlide == 4 and GST.mhMode ~= 0 and GST.mhMode ~= 3 then
      y = y + 30 * scale
    end
    local actualTex = get_texture_info(tex)
    x = (screenWidth - actualTex.width * imgScale) / 2
    djui_hud_render_texture(actualTex, x, y, imgScale, imgScale)
  end

  if forceSlide then return end

  local dirTextScale = 2 * scale
  local olddir = mouseRulesDirection
  mouseRulesDirection = 0
  djui_hud_set_font(FONT_HUD)
  djui_hud_print_text("A", screenWidth * 0.8 - 8 * dirTextScale, screenHeight - 20 * dirTextScale, dirTextScale)
  if currSlide == finalSlide then
    djui_hud_render_texture(gTextures.no_camera, screenWidth * 0.8 + 6 * dirTextScale, screenHeight - 17 * dirTextScale,
      0.75 * dirTextScale, 0.75 * dirTextScale)
  else
    djui_hud_render_texture(TEX_MENU_ARROW, screenWidth * 0.8 + 8 * dirTextScale, screenHeight - 17 * dirTextScale,
      1.5 * dirTextScale, 1.5 * dirTextScale)
  end
  local rectX = screenWidth * 0.8 - 10 * dirTextScale
  local rectY = screenHeight - 21 * dirTextScale
  local rectWidth = 30 * dirTextScale
  local rectHeight = 20 * dirTextScale
  if mouseX >= rectX and mouseX <= rectX + rectWidth
      and mouseY >= rectY and mouseY <= rectY + rectHeight then
    mouseRulesDirection = 1
    djui_hud_set_color(92, 255, 92, math.abs((frameCounter % 60) - 30) * 2)
    djui_hud_render_rect(rectX, rectY, rectWidth, rectHeight)
    if olddir ~= mouseRulesDirection then
      play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
    end
    hoveringOption = true
  end

  djui_hud_set_color(255, 255, 255, 255)
  djui_hud_print_text("B", screenWidth * 0.2, screenHeight - 20 * dirTextScale, dirTextScale)
  if currSlide == 0 then
    djui_hud_render_texture(gTextures.no_camera, screenWidth * 0.2 - 14 * dirTextScale, screenHeight - 17 * dirTextScale,
      0.75 * dirTextScale, 0.75 * dirTextScale)
  else
    djui_hud_render_texture(TEX_MENU_ARROW, screenWidth * 0.2 - 2 * dirTextScale, screenHeight - 5 * dirTextScale,
      -1.5 * dirTextScale, -1.5 * dirTextScale)
  end
  rectX = screenWidth * 0.2 - 15 * dirTextScale
  if mouseX >= rectX and mouseX <= rectX + rectWidth
      and mouseY >= rectY and mouseY <= rectY + rectHeight then
    mouseRulesDirection = -1
    djui_hud_set_color(92, 255, 92, math.abs((frameCounter % 60) - 30) * 2)
    djui_hud_render_rect(rectX, rectY, rectWidth, rectHeight)
    if olddir ~= mouseRulesDirection then
      play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
    end
    hoveringOption = true
  end

  handle_mouse()
end

-- renders the mouse and sets mouse location
function handle_mouse()
  mouseX = djui_hud_get_mouse_x()
  mouseY = djui_hud_get_mouse_y()
  local tex = TEX_HAND
  if sMenuInputsDown & (A_BUTTON | B_BUTTON) ~= 0 and mouseIdleTimer < 90 then
    tex = TEX_HAND_SELECT
    mouseIdleTimer = 0
  end
  if mouseX ~= mouseData.prevX or mouseY ~= mouseData.prevY then
    mouseIdleTimer = 0
    mouseArrowKey = 0
    hoveringOption = false
  end
  if mouseIdleTimer < 90 then
    djui_hud_set_color(255, 255, 255, 255)
    djui_hud_set_resolution(RESOLUTION_DJUI)
    djui_hud_render_texture_interpolated(tex, mouseData.prevX - 10, mouseY - 10, 2, 2, mouseX - 10, mouseY - 10, 2, 2)
    mouseIdleTimer = mouseIdleTimer + 1
    mouseData.prevX = mouseX
    mouseData.prevY = mouseY
  end
end

-- menu controls
function menu_controls(m)
  ranMenuThisFrame = true
  if m.playerIndex ~= 0 then return end
  if not is_menu_open() then
    sMenuInputsPressed = 0
    sMenuInputsDown = 0

    local menuEntered = false
    local saboEntered = false
    if menuButton <= 2 then
      local key = (menuButton ~= 2 and L_TRIG) or R_TRIG
      if (m.controller.buttonDown & key) ~= 0 and (m.controller.buttonPressed & START_BUTTON) ~= 0 then
        menuEntered = true
      end
    elseif (m.controller.buttonPressed & (U_JPAD >> (menuButton - 3))) ~= 0 then
      menuEntered = true
      frameDelay = 15
    end
    if sabo_valid() then
      if saboButton <= 2 then
        local key = (saboButton ~= 2 and L_TRIG) or R_TRIG
        if (m.controller.buttonDown & key) ~= 0 and (m.controller.buttonPressed & START_BUTTON) ~= 0 then
          saboEntered = true
        end
      elseif (m.controller.buttonPressed & (U_JPAD >> (saboButton - 3))) ~= 0 then
        saboEntered = true
        frameDelay = 15
      end
    end

    if (menuEntered or saboEntered) and not is_game_paused() then
      menu_reload()
      menu = true
      if (not saboEntered) then
        menu_enter()
      else
        menu_enter("saboMenu")
      end

      -- Disable controls for everything but the menu
      sMenuInputsPressed = m.controller.buttonDown & (m.controller.buttonDown ~ sMenuInputsDown)
      sMenuInputsDown = m.controller.buttonDown
      m.controller.buttonDown = 0
      m.controller.buttonPressed = 0
    end
    return
  end

  -- Disable controls for everything but the menu
  sMenuInputsPressed = m.controller.buttonDown & (m.controller.buttonDown ~ sMenuInputsDown)
  sMenuInputsDown = m.controller.buttonDown
  m.controller.buttonDown = 0
  m.controller.buttonPressed = 0

  -- right, up, left, down, a, b, x
  local pressed = { false, false, false, false, false, false, false }

  djui_hud_set_resolution(RESOLUTION_DJUI)
  local screenWidth = djui_hud_get_screen_width()
  local screenHeight = djui_hud_get_screen_height()
  -- apparently I designed this whole menu for 720p. Detect if this is greater than that and if so, adjust scale
  local adjustScale = screenHeight / 768

  if (sMenuInputsPressed & A_BUTTON) ~= 0 or (mouseIdleTimer < 90 and (sMenuInputsPressed & B_BUTTON) ~= 0) then
    if mouseIdleTimer < 90 and currMenu.name == "playerMenu" and currentOption < 17 and mouseX > screenWidth * 0.7 then
      pressed[7] = true
    elseif mouseIdleTimer < 90 and showingStats and statDesc ~= 0 and mouseY < 180 then
      pressed[7] = true
    else
      pressed[5] = true
    end
  elseif (sMenuInputsPressed & X_BUTTON) ~= 0 then
    pressed[7] = true
  elseif (sMenuInputsPressed & B_BUTTON) ~= 0 then
    pressed[6] = true
  end

  local joystickX = m.controller.stickX
  local joystickY = m.controller.stickY
  if (sMenuInputsDown & L_JPAD) ~= 0 then
    joystickX = joystickX - JOYSTICK_THRESHOLD
  end
  if (sMenuInputsDown & R_JPAD) ~= 0 then
    joystickX = joystickX + JOYSTICK_THRESHOLD
  end
  if (sMenuInputsDown & D_JPAD) ~= 0 then
    joystickY = joystickY - JOYSTICK_THRESHOLD
  end
  if (sMenuInputsDown & U_JPAD) ~= 0 then
    joystickY = joystickY + JOYSTICK_THRESHOLD
  end

  -- arrow key controls for mouse
  local joystickMoved = true
  if mouseIdleTimer < 90 and (sMenuInputsDown & (A_BUTTON | B_BUTTON)) ~= 0 and mouseArrowKey ~= 0 then
    pressed[5] = false
    pressed[mouseArrowKey] = true
    mouseIdleTimer = 0
    joystickMoved = false
  else
    pressed[1] = joystickX >= JOYSTICK_THRESHOLD
    pressed[2] = joystickY >= JOYSTICK_THRESHOLD
    pressed[3] = joystickX <= -JOYSTICK_THRESHOLD
    pressed[4] = joystickY <= -JOYSTICK_THRESHOLD
  end

  if frameDelay > 0 then frameDelay = frameDelay - 1 else frameDelay = 0 end

  if pressed[1] or pressed[2] or pressed[3] or pressed[4] then
    if frameDelay == 0 then
      frameDelay = delayFrames // 10
      delayFrames = delayFrames - 1
      if joystickMoved then
        hoveringOption = true
        mouseIdleTimer = 90
      end
    else
      pressed[1] = false
      pressed[2] = false
      pressed[3] = false
      pressed[4] = false
    end
  else
    frameDelay = 0
    delayFrames = 60
  end

  -- scroll bar controls for mouse
  local maxStatsNames = (screenHeight / adjustScale - 240) // 32
  if mouseIdleTimer < 90 and (((not showingStats) and #currMenu > 7) or (showingStats and MAX_PLAYERS > maxStatsNames and network_player_connected_count() > maxStatsNames)) and (sMenuInputsDown & (A_BUTTON | B_BUTTON)) ~= 0 and (mouseGrabbedScrollBar or (mouseX >= screenWidth * 0.9 - 40 * adjustScale and mouseX <= screenWidth * 0.9 - 20 * adjustScale)) then
    if (not mouseGrabbedScrollBar) then
      mouseGrabbedScrollBar = true
      local fullportion = screenHeight - 214
      local farDown = 0
      if showingStats then
        farDown = (menuY) * fullportion / network_player_connected_count()
      else
        farDown = (bottomOption - 7) * fullportion / #currMenu
      end
      mouseScrollBarY = farDown - mouseData.prevY
    end
  else
    mouseGrabbedScrollBar = false
  end

  if (sMenuInputsPressed & START_BUTTON) ~= 0 then
    close_menu()
    m.controller.buttonDown = START_BUTTON
  elseif showingRules then -- rules menu controls
    if m.freeze < 1 then m.freeze = 1 end

    local change = 0
    if (mouseIdleTimer and mouseIdleTimer >= 90) then
      if pressed[5] then
        change = 1
      elseif pressed[6] then
        change = -1
      end
    elseif pressed[5] then
      change = mouseRulesDirection
    end

    if change ~= 0 then
      local finalSlide = (GST.mhMode == 3 and 8) or 5
      if ruleSlide + change > finalSlide or ruleSlide + change < 0 then
        showingRules = false
        if menu then
          menu_enter(nil, 3)
          play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
        else
          play_sound(SOUND_GENERAL_PAINTING_EJECT, gGlobalSoundSource)
        end
      else
        ruleSlide = ruleSlide + change
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
      end
    end
  elseif showingStats then -- stats table controls
    if m.freeze < 1 then m.freeze = 1 end

    if statDesc ~= 0 then
      if pressed[1] or pressed[2] or pressed[3] or pressed[4] then
        if pressed[1] then
          statDesc = (statDesc + #stat_icon_data) % (#stat_icon_data) + 1
          play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
        elseif pressed[2] then
          if MAX_PLAYERS <= 16 or network_player_connected_count() <= 16 then
            statDesc = 0
          elseif menuY > 0 then
            menuY = menuY - 1
          else
            statDesc = 0
          end
          play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
        elseif pressed[3] then
          statDesc = (statDesc + #stat_icon_data - 2) % (#stat_icon_data) + 1
          play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
        elseif MAX_PLAYERS > 16 and network_player_connected_count() > 16 then
          if menuY < network_player_connected_count() - 16 then
            menuY = menuY + 1
            play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
          end
        end
      end
    elseif pressed[4] then
      statDesc = 1
      play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
    end

    if hoveringOption and pressed[5] then
      play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
      if statDesc ~= 0 then
        if sortBy == statDesc then
          sortBy = -statDesc
        elseif sortBy == -statDesc then
          sortBy = 0
        else
          sortBy = statDesc
        end
      else
        showingStats = false
        if menu then
          menu_enter(nil, 8)
          play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
        else
          play_sound(SOUND_GENERAL_PAINTING_EJECT, gGlobalSoundSource)
        end
      end
    elseif pressed[6] then
      showingStats = false
      if menu then
        menu_enter(nil, 8)
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
      else
        play_sound(SOUND_GENERAL_PAINTING_EJECT, gGlobalSoundSource)
      end
    elseif pressed[7] then
      play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
      altNum = (altNum + 1) % 3
    end
  elseif menu then
    if m.freeze < 1 then m.freeze = 1 end

    if pressed[2] then
      currentOption = (currentOption - 2 + #currMenu) % #currMenu + 1
      play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
      validBack = true
    elseif pressed[4] then
      currentOption = currentOption % #currMenu + 1
      play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
      validBack = true
    end

    local option = currMenu[currentOption]
    local min = option.minNum or 0
    local countBy = 1
    if sMenuInputsDown & X_BUTTON ~= 0 and (option.currNum and (option.maxNum - min + 1) >= 10) then countBy = 10 end
    if pressed[3] and option.currNum then
      if countBy == 1 then
        option.currNum = (option.currNum - countBy - min) % (option.maxNum + 1 - min) + min
      else
        local prevNum = option.currNum
        option.currNum = (option.currNum - countBy)
        if option.currNum == -countBy then
          option.currNum = option.maxNum
        elseif (option.currNum < 0 and prevNum >= 0) then
          option.currNum = option.maxNum
        elseif option.currNum < min then
          option.currNum = min
        end
      end
      play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
    elseif pressed[1] and option.currNum then
      if countBy == 1 then
        option.currNum = (option.currNum + countBy - min) % (option.maxNum + 1 - min) + min
      else
        local prevNum = option.currNum
        option.currNum = (option.currNum + countBy)
        if option.currNum == option.maxNum + countBy then
          option.currNum = 0
          if min > 0 then
            option.currNum = countBy
          end
        elseif (option.currNum >= 0 and prevNum < 0) then
          option.currNum = 0
        elseif option.currNum > option.maxNum then
          option.currNum = option.maxNum
        end
      end
      play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
    end

    local option = currMenu[currentOption]
    if hoveringOption and pressed[5] then
      if option.invalid then
        play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
      else
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
        selectOption(currentOption)
      end
    elseif pressed[6] and currMenu.back then
      play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
      selectOption(currMenu.back)
    elseif hoveringOption and pressed[7] then
      if currMenu.name == "playerMenu" and currentOption < #currMenu then
        if (not has_mod_powers(0)) or option.invalid then
          play_sound(SOUND_MENU_CAMERA_BUZZ, gGlobalSoundSource)
        else
          play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
          local global = network_global_index_from_local(currentOption - 1) or -1
          change_team_command(global)
        end
      elseif currMenu.name == "blacklistMenu" and option.course then -- toggle all
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
        local oneValid = false

        for i = 1, 7 do
          if (i ~= 7 or option.course > 15) and valid_star(option.course, i, true, true) then
            if not mini_blacklist[option.course * 10 + i] then
              oneValid = true
              break
            end
          end
        end
        if oneValid then
          blacklist_command("add " .. currentOption)
        else
          blacklist_command("remove " .. currentOption)
        end
      elseif currMenu.name == "settingsMenu" and option.name == "menu_auto" then -- flip auto
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gGlobalSoundSource)
        option.option = not option.option
        if option.option then
          auto_command(-1)
        else
          auto_command(0)
        end
      end
    end
  end
end

-- returns if a menu is open
function is_menu_open()
  return (menu or showingStats or showingRules)
end

function print_text_ex_hud_font(text, x, y, scale)
  if text == "~" then
    djui_hud_render_texture(gTextures.no_camera, x, y, scale, scale)
    return
  else
    djui_hud_set_font(FONT_CUSTOM_HUD)
    djui_hud_print_text(text, x, y - scale * 10, scale)
    return
  end
end

--hook_event(HOOK_ON_HUD_RENDER, handleMenu)
hook_event(HOOK_BEFORE_MARIO_UPDATE, menu_controls)
hook_event(HOOK_UPDATE, function()
  if paused and ranMenuThisFrame == false then
    menu_controls(m0)
  end
  ranMenuThisFrame = false
end)
