-- Thanks to blocky for making most of this

-- localize some functions
local djui_hud_set_font, djui_hud_set_color, djui_hud_print_text, djui_hud_render_rect, djui_hud_measure_text, djui_hud_render_texture, djui_hud_set_resolution, djui_chat_message_create, djui_hud_get_screen_width, djui_hud_get_screen_height, tonumber, play_sound, string_lower, network_get_player_text_color_string =
    djui_hud_set_font, djui_hud_set_color, djui_hud_print_text, djui_hud_render_rect, djui_hud_measure_text,
    djui_hud_render_texture, djui_hud_set_resolution, djui_chat_message_create, djui_hud_get_screen_width,
    djui_hud_get_screen_height, tonumber, play_sound, string.lower,
    network_get_player_text_color_string

-- localize other stuff
local GST                                                                                                                                                                                                                                                                                                                  = gGlobalSyncTable
local m0                                                                                                                                                                                                                                                                                                                   = gMarioStates
    [0]

-- Constants for joystick input
local JOYSTICK_THRESHOLD                                                                                                                                                                                                                                                                                                   = 32

-- Variables to keep track of current menu state
local currentOption                                                                                                                                                                                                                                                                                                        = 1
local bottomOption                                                                                                                                                                                                                                                                                                         = 0
local focusPlayerOrCourse                                                                                                                                                                                                                                                                                                  = 0
local prevOption                                                                                                                                                                                                                                                                                                           = 0
local hoveringOption                                                                                                                                                                                                                                                                                                       = true

-- Controller Inputs
local sMenuInputsPressed                                                                                                                                                                                                                                                                                                   = 0
local sMenuInputsDown                                                                                                                                                                                                                                                                                                      = 0

-- textures
local TEX_MENU_ARROW                                                                                                                                                                                                                                                                                                       = get_texture_info(
  "menu-arrow")
local TEX_MENU_ARROW_UP                                                                                                                                                                                                                                                                                                    = gTextures
.arrow_up
local TEX_MENU_ARROW_DOWN                                                                                                                                                                                                                                                                                                  = gTextures
.arrow_down

-- mouse stuff
local TEX_HAND                                                                                                                                                                                                                                                                                                             = get_texture_info(
  "gd_texture_hand_open")
local TEX_HAND_SELECT                                                                                                                                                                                                                                                                                                      = get_texture_info(
  "gd_texture_hand_closed")
local mouseX                                                                                                                                                                                                                                                                                                               = djui_hud_get_mouse_x()
local mouseY                                                                                                                                                                                                                                                                                                               = djui_hud_get_mouse_y()
local mouseData                                                                                                                                                                                                                                                                                                            = {
  prevX =
      mouseX,
  prevY = mouseY
}
local mouseIdleTimer                                                                                                                                                                                                                                                                                                       = 90
local mouseGrabbedScrollBar                                                                                                                                                                                                                                                                                                = false
local mouseScrollBarY                                                                                                                                                                                                                                                                                                      = 0
local mouseArrowKey                                                                                                                                                                                                                                                                                                        = 0

-- limit for player names
local PLAYER_NAME_CUTOFF                                                                                                                                                                                                                                                                                                   = 16

-- build language menu
local menuList                                                                                                                                                                                                                                                                                                             = {}
menuList["LanguageMenu"]                                                                                                                                                                                                                                                                                                   = {}
local LanguageMenu                                                                                                                                                                                                                                                                                                         = menuList
    ["LanguageMenu"]
local langnum                                                                                                                                                                                                                                                                                                              = 0
local lang_table                                                                                                                                                                                                                                                                                                           = {}
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
    { name = ("menu_run_random"), currNum = 0,          minNum = 0, maxNum = MAX_PLAYERS - 1, desc = ("random_desc"),               format = { "auto" } },
    { name = ("menu_run_add"),    currNum = 0,          minNum = 0, maxNum = MAX_PLAYERS - 1, desc = ("add_desc"),                  format = { "auto" } },
    { name = ("menu_gamemode"),   currNum = GST.mhMode, maxNum = 2, desc = ("mode_desc"),     format = { "normal", "swap", "mini" } },
    { name = ("menu_settings") },
    { name = ("menu_stop"),       desc = ("stop_desc") },
    { name = ("menu_back") },
    name = "marioHuntMenu",
    back = 7,
  }

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
    { name = ("menu_default"), desc = "default_desc", title = ("menu_presets") },
    { name = ("preset_quick"), desc = "preset_quick_desc" },
    { name = ("preset_infection"), desc= "preset_infection_desc" },
    { name = ("preset_solo"), desc= "preset_solo_desc" },
    { name = ("preset_tag"), desc= "preset_tag_desc" },
    { name = ("preset_star_rush"), desc= "preset_star_rush_desc" },
    { name = ("menu_back") },
    { name = ("main_menu") },
    name = "presetMenu",
    back = 7,
  }

  LanguageMenu[1].title = ("menu_lang")

  local maxStars = 255
  local auto = gGlobalSyncTable.gameAuto
  if ROMHACK then maxStars = ROMHACK.max_stars end
  if auto == 99 then auto = -1 end
  menuList["settingsMenu"] = {
    { name = ("menu_run_lives"),      currNum = GST.runnerLives,      maxNum = 99,                                                            desc = ("lives_desc"),               title = ("menu_settings") },
    { name = ("menu_time"),           currNum = GST.runTime // 30,    maxNum = 3600,                                                          desc = ("time_desc"),                time = true },
    { name = ("menu_star_mode"),      option = GST.starMode,          desc = ("starmode_desc"),                                               invalid = (GST.mhMode == 2) },
    { name = ("menu_category"),       currNum = GST.starRun,          maxNum = maxStars,                                                      minNum = (GST.noBowser and 1) or -1, desc = ("category_desc"),             invalid = (GST.mhMode == 2) },
    { name = ("menu_defeat_bowser"),  option = not GST.noBowser,      invalid = (GST.mhMode == 2 or (ROMHACK and (ROMHACK.no_bowser ~= nil))) },
    { name = ("menu_free_roam"),      option = GST.freeRoam,          invalid = (GST.mhMode == 2),                                            desc = "menu_free_roam_desc" },
    { name = ("menu_auto"),           currNum = auto,                 minNum = -1,                                                            maxNum = MAX_PLAYERS - 1,            desc = ("auto_desc"),                 format = { "auto", "~" } },
    { name = ("menu_nerf_vanish"),    option = GST.nerfVanish,        desc = ("menu_nerf_vanish_desc") },
    { name = ("menu_allow_spectate"), option = GST.allowSpectate,     desc = ("spectator_desc") },
    { name = ("menu_allow_stalk"),    option = GST.allowStalk,        desc = ("stalking_desc"),                                               invalid = (GST.mhMode == 2) },
    { name = ("menu_stalk_timer"),    currNum = GST.stalkTimer // 30, maxNum = 600,                                                           desc = ("menu_stalk_timer_desc"),    time = true,                          invalid = (GST.mhMode == 2 or not GST.allowStalk) },
    { name = ("menu_weak"),           option = GST.weak,              desc = ("weak_desc") },
    { name = ("menu_anarchy"),        currNum = GST.anarchy,          minNum = 0,                                                             maxNum = 3,                          desc = ("menu_anarchy_desc"),         format = { "~", "lang_runners", "lang_hunters", "lang_all" } },
    { name = ("menu_dmgAdd"),         currNum = GST.dmgAdd,           minNum = -1,                                                            maxNum = 15,                         desc = ("menu_dmgAdd_desc"),          format = { "OHKO" } },
    { name = ("menu_countdown"),      currNum = GST.countdown // 30,  maxNum = 600,                                                           time = true,                         minNum = 0,                           desc = ("menu_countdown_desc"),                              invalid = (GST.mhMode == 2) },
    { name = ("menu_double_health"),  option = GST.doubleHealth,      desc = ("menu_double_health_desc") },
    { name = ("menu_star_heal"),      option = GST.starHeal },
    { name = ("menu_star_setting"),   currNum = GST.starSetting,      minNum = 0,                                                             maxNum = 2,                          format = { "lang_star_leave", "lang_star_stay", "lang_star_nonstop" }, invalid = (GST.mhMode == 2) },
    { name = ("menu_voidDmg"),        currNum = GST.voidDmg,          minNum = -1,                                                            maxNum = 15,                         desc = ("menu_voidDmg_desc"),         format = { "OHKO" } },
    { name = ("menu_blacklist"),      desc = ("blacklist_desc") },
    { name = ("menu_presets"), },
    { name = ("menu_back") },
    { name = ("main_menu") },
    name = "settingsMenu",
    back = 22,
  }
  local settingsMenu = menuList["settingsMenu"]
  if GST.starMode and GST.mhMode ~= 2 then
    settingsMenu[2] = { name = ("menu_stars"), currNum = GST.runTime, maxNum = 7, desc = ("stars_desc") }
  end
  if GST.mhMode == 2 then
    settingsMenu[3] = { name = ("menu_first_timer"), option = GST.firstTimer, desc = ("menu_first_timer_desc"), }
  end

  -- name gets overriden
  menuList["playerMenu"] = {}
  local playerMenu = menuList["playerMenu"]
  for i = 0, MAX_PLAYERS - 1 do
    table.insert(playerMenu, { name = "PLAYER_" .. i, color = true })
  end
  playerMenu[1].title = "players"
  playerMenu.name = "playerMenu"
  playerMenu.back = MAX_PLAYERS + 2
  table.insert(playerMenu, { name = ("menu_players_all"), invalid = not has_mod_powers(0) })
  table.insert(playerMenu, { name = ("menu_back") })

  one_player_reload()

  menuList["allPlayerMenu"] = {
    { name = ("menu_pause"),         option = GST.pause,         title = ("menu_players_all"), desc = ("pause_desc") },
    { name = ("menu_forcespectate"), option = GST.forceSpectate, desc = ("forcespectate_desc") },
    { name = ("menu_back") },
    { name = ("main_menu") },
    name = "allPlayerMenu",
    back = 3,
  }

  menuList["playerSettingsMenu"] = {
    { name = ("menu_runner_app"),      title = ("menu_settings_player"),                 currNum = runnerAppearance,        maxNum = 4,                                            format = { "~", "sparkle", "glow", "outline", "color" }, desc = ("runner_app_desc") },
    { name = ("menu_hunter_app"),      currNum = hunterAppearance,                       maxNum = 4,                        format = { "~", "metal", "glow", "outline", "color" }, desc = ("hunter_app_desc") },
    { name = ("menu_invinc_particle"), option = invincParticle,                          desc = "menu_invinc_particle_desc" },
    { name = ("menu_radar"),           option = showRadar,                               desc = ("menu_radar_desc") },
    { name = ("menu_minimap"),         option = showMiniMap,                             desc = ("menu_minimap_desc") },
    { name = ("menu_timer"),           option = showSpeedrunTimer,                       desc = ("menu_timer_desc") },
    { name = ("menu_fast"),            option = gPlayerSyncTable[0].fasterActions,       desc = ("menu_fast_desc") },
    { name = ("menu_romhack_cam"),     option = romhackCam,                              desc = ("menu_romhack_cam_desc") },
    { name = ("menu_popup_sound"),     option = playPopupSounds },
    { name = ("menu_season"),          option = not noSeason,                            desc = ("menu_season_desc") },
    { name = ("menu_hide_hud"),        option = mhHideHud,                               desc = ("hidehud_desc") },
    { name = ("menu_tc"),              option = (gPlayerSyncTable[0].teamChat or false), desc = ("menu_tc_desc"),           invalid = disable_chat_hook },
    { name = ("hard_mode"),            option = (gPlayerSyncTable[0].hard == 1),         desc = ("hard_info_short") },
    { name = ("extreme_mode"),         option = (gPlayerSyncTable[0].hard == 2),         desc = ("extreme_info_short") },
    { name = ("menu_unknown"),         option = demonOn,                                 invalid = true,                    desc = ("menu_secret") },
    { name = ("menu_hide_roles"),      invalid = (get_true_roles() == 0),                desc = ("menu_hide_roles_desc") },
    { name = ("menu_back") },
    name = "playerSettingsMenu",
    back = 17,
  }
  local playerSettingsMenu = menuList["playerSettingsMenu"]
  if demonOn or demonUnlocked then
    playerSettingsMenu[15].name = ("menu_demon")
    playerSettingsMenu[15].desc = ("menu_demon_desc")
    playerSettingsMenu[15].invalid = false
  end

  menuList["miscMenu"] = {
    { name = ("free_camera"),         title = ("menu_misc"),                                                                                            invalid = ((not GST.allowSpectate) or (gPlayerSyncTable[0].team == 1 and GST.mhState ~= 1 and GST.mhState ~= 2)), desc = ("menu_free_cam_desc") },
    { name = ("menu_spectate_run"),   invalid = ((not GST.allowSpectate) or (gPlayerSyncTable[0].team == 1 and GST.mhState ~= 1 and GST.mhState ~= 2)), desc = ("menu_spectate_run_desc") },
    { name = ("menu_exit_spectate"),  invalid = (gPlayerSyncTable[0].forceSpectate or gPlayerSyncTable[0].spectator ~= 1),                              desc = ("menu_exit_spectate_desc") },
    { name = ("menu_stalk_run"),      invalid = ((not gGlobalSyncTable.allowStalk) or GST.mhMode == 2 or GST.mhState ~= 2),                             desc = ("menu_stalk_run_desc") },
    { name = ("menu_skip"),           invalid = (GST.mhState ~= 2 or GST.mhMode ~= 2 or iVoted),                                                        desc = ("menu_skip_desc") },
    { name = ("menu_blacklist_list"), desc = ("menu_blacklist_list_desc") },
    { name = ("menu_back") },
    name = "miscMenu",
    back = 7,
  }

  local trueRoles = get_true_roles()
  local roles = gPlayerSyncTable[0].role
  menuList["hideRolesMenu"] = {
    { name = ("role_lead"),      title = ("menu_hide_roles"), option = (roles & 2 ~= 0),       invalid = (trueRoles & 2 == 0), color = true },
    { name = ("role_dev"),       option = (roles & 4 ~= 0),   invalid = (trueRoles & 4 == 0),  color = true },
    { name = ("role_trans"),     option = (roles & 8 ~= 0),   invalid = (trueRoles & 8 == 0),  color = true },
    { name = ("role_cont"),      option = (roles & 16 ~= 0),  invalid = (trueRoles & 16 == 0), color = true },
    { name = ("stat_placement"), option = (roles & 32 ~= 0),  invalid = (trueRoles & 32 == 0) },
    { name = ("menu_default") },
    { name = ("menu_back") },
    { name = ("main_menu") },
    name = "hideRolesMenu",
    back = 7,
  }
end

function one_player_reload()
  if focusPlayerOrCourse > (MAX_PLAYERS - 1) then focusPlayerOrCourse = 0 end
  local STP = gPlayerSyncTable[focusPlayerOrCourse]
  local GST = gGlobalSyncTable
  menuList["onePlayerMenu"] = {
    { name = ("menu_flip"),          title = "PLAYER_S",                                                                                                                           invalid = not has_mod_powers(0),              desc = ("flip_desc") },
    { name = ("menu_spectate"),      invalid = (focusPlayerOrCourse == 0 or (not GST.allowSpectate) or (gPlayerSyncTable[0].team == 1 and GST.mhState ~= 1 and GST.mhState ~= 2)), desc = ("menu_spectate_desc") },
    { name = ("menu_target"),        invalid = (focusPlayerOrCourse == 0 or STP.team ~= 1 or GST.mhMode == 2 or GST.mhState ~= 2),                                                 desc = ("target_desc") },
    { name = ("menu_stalk"),         invalid = (focusPlayerOrCourse == 0 or (not gGlobalSyncTable.allowStalk) or STP.team ~= 1 or GST.mhMode == 2 or GST.mhState ~= 2),            desc = ("menu_stalk_desc") },
    { name = ("menu_pause"),         option = STP.pause,                                                                                                                           invalid = not has_mod_powers(0),              desc = ("pause_desc") },
    { name = ("menu_mute"),          option = STP.mute,                                                                                                                            invalid = not has_mod_powers(0),              desc = ("mute_desc") },
    { name = ("menu_forcespectate"), option = STP.forceSpectate,                                                                                                                   invalid = not has_mod_powers(0),              desc = ("forcespectate_desc") },
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
      table.insert(blacklistMenu, { name = "COURSE", course = i })
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
  if menu == "onePlayerMenu" then
    one_player_reload()
  elseif menu == "blacklistMenu" then
    build_blacklist_menu()
  elseif menu == "blacklistCourseMenu" then
    build_blacklist_course_menu()
  else
    menu_reload()
  end

  currMenu = menuList[menu] or menuList["mainMenu"]
  currentOption = option or 1
  if bottomOption > currentOption + 7 then
    bottomOption = currentOption + 7
  end
  if bottomOption > #currMenu then
    bottomOption = #currMenu
  end

  if mouseIdleTimer and mouseIdleTimer < 90 then
    mouseIdleTimer = 0
    hoveringOption = false
  end
end

function close_menu()
  menu_enter()
  play_sound(SOUND_GENERAL_PAINTING_EJECT, gGlobalSoundSource)
  menu = false
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
      function() if gGlobalSyncTable.mhMode ~= 2 then menu_enter("startMenu") else menu_enter("startMenuMini") end end,
      function(option) runner_randomize(option.currNum) end,
      function(option) add_runner(option.currNum) end,
      function(option)
        change_game_mode("", option.currNum)
        menu_reload()
        menu_enter("marioHuntMenu", currentOption)
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
        if gGlobalSyncTable.mhMode ~= 2 and gGlobalSyncTable.starMode then
          stars_needed_command(option.currNum)
        else
          time_needed_command(option.currNum)
        end
      end,
      function(option)
        option.option = not option.option
        if gGlobalSyncTable.mhMode == 2 then
          gGlobalSyncTable.firstTimer = option.option
        else
          star_mode_command("", option.option)
          menu_reload()
          menu_enter("settingsMenu", currentOption)
        end
      end,
      function(option)
        star_count_command(option.currNum)
      end,
      function(option)
        option.option = not option.option
        gGlobalSyncTable.noBowser = not option.option
        if gGlobalSyncTable.noBowser and gGlobalSyncTable.starRun < 1 then
          gGlobalSyncTable.starRun = 1
        end
        menu_reload()
        menu_enter("settingsMenu", currentOption)
      end,
      function(option)
        option.option = not option.option
        gGlobalSyncTable.freeRoam = option.option
        menu_reload()
        menu_enter("settingsMenu", currentOption)
      end,
      function(option)
        if option.currNum < 0 then
          gGlobalSyncTable.gameAuto = 99,
              djui_chat_message_create(trans("auto_on"))
          if gGlobalSyncTable.mhState == 0 then
            gGlobalSyncTable.mhTimer = 20 * 30 -- 20 seconds
          end
        elseif option.currNum == 0 then
          gGlobalSyncTable.gameAuto = 0,
              djui_chat_message_create(trans("auto_off"))
          if gGlobalSyncTable.mhState == 0 then
            gGlobalSyncTable.mhTimer = 0 -- don't set
          end
        else
          gGlobalSyncTable.gameAuto = option.currNum
          local runners = trans("runners")
          if gGlobalSyncTable.gameAuto == 1 then
            runners = trans("runner")
          end
          djui_chat_message_create(string.format("%s (%d %s)", trans("auto_on"), gGlobalSyncTable.gameAuto, runners))
          if gGlobalSyncTable.mhState == 0 then
            gGlobalSyncTable.mhTimer = 20 * 30 -- 20 seconds
          end
        end
      end,
      function(option)
        option.option = not option.option
        gGlobalSyncTable.nerfVanish = option.option
      end,
      function(option)
        option.option = not option.option
        gGlobalSyncTable.allowSpectate = option.option
        if not option.option then
          djui_chat_message_create(trans("no_spectate"))
        else
          djui_chat_message_create(trans("can_spectate"))
        end
      end,
      function(option)
        option.option = not option.option
        gGlobalSyncTable.allowStalk = option.option
        currMenu[currentOption + 1].invalid = not option.option
      end,
      function(option)
        gGlobalSyncTable.stalkTimer = option.currNum * 30
      end,
      function(option)
        option.option = not option.option
        gGlobalSyncTable.weak = option.option
        if not option.option then
          djui_chat_message_create(trans("not_weak"))
        else
          djui_chat_message_create(trans("now_weak"))
        end
      end,
      function(option)
        gGlobalSyncTable.anarchy = option.currNum
        djui_chat_message_create(trans("anarchy_set_" .. gGlobalSyncTable.anarchy))
      end,
      function(option)
        gGlobalSyncTable.dmgAdd = option.currNum
        if option.currNum ~= -1 then
          djui_chat_message_create(trans("dmgAdd_set", gGlobalSyncTable.dmgAdd))
        else
          djui_chat_message_create(trans("dmgAdd_set_ohko"))
        end
      end,
      function(option)
        local old = gGlobalSyncTable.countdown
        gGlobalSyncTable.countdown = option.currNum * 30
        if gGlobalSyncTable.mhState == 1 then
          local diff = old - gGlobalSyncTable.countdown
          gGlobalSyncTable.mhTimer = math.max(1, gGlobalSyncTable.mhTimer - diff)
        end
      end,
      function(option)
        option.option = not option.option
        gGlobalSyncTable.doubleHealth = option.option
      end,
      function(option)
        option.option = not option.option
        gGlobalSyncTable.starHeal = option.option
      end,
      function(option)
        gGlobalSyncTable.starSetting = option.currNum
      end,
      function(option)
        gGlobalSyncTable.voidDmg = option.currNum
        if option.currNum ~= -1 then
          djui_chat_message_create(trans("voidDmg_set", gGlobalSyncTable.voidDmg))
        else
          djui_chat_message_create(trans("voidDmg_set_ohko"))
        end
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
        menu_enter("onePlayerMenu", currentOption)
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
    allPlayerMenu = {
      function(option)
        option.option = not option.option
        pause_command("all")
      end,
      function(option)
        option.option = not option.option
        force_spectate_command("all")
      end,
      function() menu_enter("playerMenu", MAX_PLAYERS + 1) end,
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
        if gGlobalSyncTable.mhState == 0 then
          set_lobby_music(month)
        end
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
      function() menu_enter("hideRolesMenu", 1) end,
      function() menu_enter(nil, 2) end,
    },
    miscMenu = {
      function()
        spectate_command("free")
        menu_reload()
        currMenu = menuList["miscMenu"]
      end,
      function()
        spectate_command("runner")
        menu_reload()
        currMenu = menuList["miscMenu"]
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
      function()
        gPlayerSyncTable[0].role = get_true_roles()
        menu_reload()
        menu_enter("hideRolesMenu", 6)
        mod_storage_save("showRoles", tostring(gPlayerSyncTable[0].role))
      end,
      function() menu_enter("playerSettingsMenu", 16) end,
      function() menu_enter(nil, 2) end,
    },
    presetMenu = {
      function()
        default_settings()
      end,
      function()
        if gGlobalSyncTable.mhMode == 2 then
          change_game_mode("normal", 0) -- normal mode if mini
        end
        runner_lives(tostring(0)) -- 0 lives
        local stars = 30
        if ROMHACK and ROMHACK.max_stars and ROMHACK.max_stars < 30 then
          stars = ROMHACK.max_stars
        end
        star_count_command(stars) -- 30/max stars
        if ROMHACK.no_bowser == nil then
          gGlobalSyncTable.noBowser = true -- no bowser mode
        end
        gGlobalSyncTable.freeRoam = true -- free roam
        runner_randomize() -- auto
      end,
      function()
        local players = 0 -- get total active players
        for i=0,MAX_PLAYERS-1 do
          if gNetworkPlayers[i].connected and gPlayerSyncTable[i].spectator ~= 1 then
            players = players + 1
          end
        end
        change_game_mode("normal", 0) -- normal mode
        runner_lives(tostring(0)) -- 0 lives
        gGlobalSyncTable.dmgAdd = -1 -- OHKO
        runner_randomize(players-1) -- one hunter only
      end,
      function()
        for i=1,MAX_PLAYERS-1 do
          become_hunter(gPlayerSyncTable[i])
        end
        change_team_command(network_global_index_from_local(i))
        change_game_mode("normal", 0) -- normal mode
        runner_lives(tostring(2)) -- 2 lives
        gGlobalSyncTable.dmgAdd = 0 -- No dmg add
        gGlobalSyncTable.doubleHealth = true -- double health
      end,
      function()
        if gGlobalSyncTable.mhMode == 0 then
          change_game_mode("swap", 1) -- swap mode if normal
        end
        runner_lives(tostring(0)) -- 0 lives
        gGlobalSyncTable.dmgAdd = -1 -- OHKO
        runner_randomize() -- auto
      end,
      function()
        for i=0,MAX_PLAYERS-1 do
          become_runner(gPlayerSyncTable[i])
        end
        change_game_mode("mini", 2) -- minihunt
      end,
      function() menu_enter("settingsMenu", 21) end,
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
      --menu_reload()
      menu_enter("LanguageMenu", currentOption)
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
      menu_enter("settingsMenu", 20)
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
    elseif option == currMenu.back then
      menu_enter(nil, 7)
    else
      focusPlayerOrCourse = option - 1
      menu_enter("allPlayerMenu")
    end
  elseif menuActions[currentMenuName] then
    local action = menuActions[currentMenuName][option]
    if action then
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
  djui_hud_set_font(FONT_HUD)
  local screenWidth = djui_hud_get_screen_width()
  local screenHeight = djui_hud_get_screen_height()
  djui_hud_set_color(255, 255, 255, 255)

  djui_hud_set_color(0, 0, 0, 200)
  djui_hud_render_rect(screenWidth * 0.1, 0, screenWidth * 0.8, screenHeight)

  local maxTextWidth = 0
  local textScale = 1.5

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
        if option.format then
          local min = option.minNum or 0

          choiceString = option.format[option.currNum - min + 1] or choiceString
          if choiceString:sub(1, 5) == "lang_" then
            choiceString = trans(choiceString:sub(6))
          end

          for a, text_ in pairs(option.format) do -- pairs is used because one of them does not have 1-7
            local text = text_
            if text:sub(1, 5) == "lang_" then
              text = trans(text:sub(6))
            end
            if measureString:len() < text:len() then
              measureString = text
            end
          end
        else
          if option.currNum == -1 then choiceString = "any%" end
          measureString = tostring("any%")
        end
      end
      option.choiceWidth = djui_hud_measure_text(measureString) * 3
      option.choiceString = choiceString
      textWidth = textWidth + option.choiceWidth + 80
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
  local titleScale = 6

  local titleText = tostring(currMenu[1].title)
  local titleCenter = 0
  djui_hud_set_color(255, 255, 255, 255)
  if titleText == "PLAYER_S" then
    djui_hud_set_font(FONT_NORMAL) -- extended hud font doesn't support every character that can be in a username yet
    local np = gNetworkPlayers[focusPlayerOrCourse]
    if np and np.connected then
      local playerColor = network_get_player_text_color_string(focusPlayerOrCourse)
      titleText = playerColor .. np.name
      titleText = cap_color_text(titleText, PLAYER_NAME_CUTOFF)
      --titleText = remove_color(np.name)
    else
      menu_enter("playerMenu", focusPlayerOrCourse + 1)
    end

    titleScale = 3
    titleCenter = (screenWidth - djui_hud_measure_text(remove_color(titleText)) * titleScale) / 2
    --titleCenter = (screenWidth - djui_hud_measure_text(titleText) * titleScale) / 2

    djui_hud_print_text_with_color(titleText, titleCenter, 0, titleScale)
    --print_text_ex_hud_font(titleText, titleCenter, screenHeight * 0.03, titleScale)
  else
    if titleText == "COURSE" then
      titleText = get_custom_level_name(focusPlayerOrCourse, course_to_level[focusPlayerOrCourse], 0)
    else
      titleText = trans(titleText)
    end

    if djui_hud_measure_text(titleText) * titleScale > screenWidth * 0.8 then -- shrink the title if it's too big
      titleScale = 3
    end

    titleCenter = (screenWidth - djui_hud_measure_text(titleText) * titleScale) / 2
    print_text_ex_hud_font(titleText, titleCenter, screenHeight * 0.03, titleScale)
  end
  djui_hud_set_font(FONT_HUD)

  for i, option in ipairs(currMenu) do
    local render = true
    if i > bottomOption then
      djui_hud_set_color(255, 255, 255, 255)
      djui_hud_render_texture(TEX_MENU_ARROW_DOWN, screenWidth / 2 - 23, screenHeight - 82, 4, 4)
      break
    elseif i <= (bottomOption - optionCount) then
      djui_hud_set_color(255, 255, 255, 255)
      djui_hud_render_texture(TEX_MENU_ARROW_UP, screenWidth / 2 - 23, screenHeight * 0.15, 4, 4)
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
          local sMario = gPlayerSyncTable[index]
          local roleName, colorString = get_role_name_and_color(sMario)
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

      if option.currNum then textX = (screenWidth - textWidth - option.choiceWidth - 80) / 2 end

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
        if option.option or roleText then
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

      djui_hud_set_font(FONT_HUD)

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
        local choiceWidth = (option.choiceWidth - djui_hud_measure_text(option.choiceString) * 3) / 2
        print_text_ex_hud_font(option.choiceString, textX + textWidth + choiceWidth + 45, optionY, 3)
        djui_hud_render_texture(TEX_MENU_ARROW, textX + textWidth + 40,
          optionY + 2 + 40, -5, -5)
        djui_hud_render_texture(TEX_MENU_ARROW, textX + textWidth + option.choiceWidth + 60,
          optionY + 2, 5, 5)

        -- mouse control
        if mouseIdleTimer < 90 and i == currentOption and hoveringOption then
          local relativeX = mouseX - textX - textWidth
          if relativeX <= 50 then
            mouseArrowKey = 3 -- left
          elseif relativeX >= option.choiceWidth + 50 then
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
        djui_hud_set_color(92, 255, 92, math.abs((frameCounter % 60) - 30) * 2)
        djui_hud_render_rect(rectX, rectY, rectWidth, rectHeight)
        djui_hud_set_color(255, 255, 255, 255)

        if currMenu[currentOption].desc then
          local desc = (trans(currMenu[currentOption].desc))
          local s, e = desc:find("- ")
          if s then
            desc = desc:sub(e + 1)
          end
          djui_hud_set_font(FONT_NORMAL)
          djui_hud_set_color(255, 255, 255, 255)
          local descWidth = djui_hud_measure_text(desc)
          local y = screenHeight - 50
          local descX = (screenWidth - descWidth) / 2
          if descWidth > screenWidth * 0.8 then
            local spaceLoc = desc:find(" ", desc:len() // 2) or desc:len() // 2
            local desc1 = desc:sub(1, spaceLoc)
            desc = desc:sub(spaceLoc)
            descWidth = djui_hud_measure_text(desc)
            descX = (screenWidth - descWidth) / 2
            y = y - 10
            djui_hud_print_text(desc1, descX, y, 1)
            y = y + 30
          end
          djui_hud_print_text(desc, descX, y, 1)
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
    local x = screenWidth * 0.9 - 40
    local y = 150
    djui_hud_set_color(0, 0, 0, 155)
    djui_hud_render_rect(x, y, 20, screenHeight - 210)
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
    djui_hud_render_rect(x + 2, y + 2 + farDown, 16, partportion)
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
local MAX_RULES_SLIDE = 5     -- the maximum rule slide (constant)
local mouseRulesDirection = 0 -- used for mouse buttons
ruleEgg = false               -- if the easter egg has appeared

local statOrder = { "wins_standard", "wins", "kills",
  "maxStreak", "maxStar", "placement", "parkourRecord", "playtime" }
local statOrder_alt1 = { "hardWins_standard", "hardWins", nil, nil, nil, nil, "pRecordOmm" }
local statOrder_alt2 = { "exWins_standard", "exWins", nil, nil, nil, nil, "pRecordOther" }

local descOrder = { "stat_wins_standard", "stat_wins", "stat_kills", "stat_combo", "stat_mini_stars",
  "stat_placement", "stat_parkour_time", "stat_playtime" }
local descOrder_alt1 = { "stat_wins_hard_standard", "stat_wins_hard", nil, nil, nil, nil, "stat_parkour_time_omm" }
local descOrder_alt2 = { "stat_wins_ex_standard", "stat_wins_ex", nil, nil, nil, nil, "stat_parkour_time_other" }

function stats_table_hud()
  djui_hud_set_resolution(RESOLUTION_DJUI)

  local text = ""

  local scale = 1
  local screenWidth = djui_hud_get_screen_width()
  local screenHeight = djui_hud_get_screen_height()
  local width = 0
  local x = 0
  local y = 180
  djui_hud_set_color(0, 0, 0, 200);
  djui_hud_render_rect(screenWidth * 0.1, 0, screenWidth * 0.8, screenHeight);

  -- title
  djui_hud_set_font(FONT_HUD)
  text = trans("menu_stats")
  width = djui_hud_measure_text(text) * 4
  x = (screenWidth - width) / 2
  djui_hud_set_color(255, 255, 255, 255);
  print_text_ex_hud_font(text, x, 10, 4);
  djui_hud_set_font(FONT_NORMAL)

  -- "player"
  text = trans("player")
  width = djui_hud_measure_text(text) * scale
  x = screenWidth * 0.1 + 150 - width / 2
  djui_hud_print_text(text, x, y - 64 * scale, scale);

  -- scores, icons, etc.
  x = screenWidth * 0.1 + 300
  space = (screenWidth * 0.8 - 420) / (#statOrder - 1)
  for i = 1, #stat_icon_data do
    local data = stat_icon_data[i]
    if altNum == 1 and stat_icon_data_alt1[i] then
      data = stat_icon_data_alt1[i]
    elseif altNum == 2 and stat_icon_data_alt2[i] then
      data = stat_icon_data_alt2[i]
    end

    if data.tex == TEX_FLAG then
      djui_hud_set_color(255, 255, 255, 255)
      djui_hud_render_texture(TEX_POLE, x - 1.5, y - 64 * scale, 1.5, 1.5)
    end
    djui_hud_set_color(data.r, data.g, data.b, 255)
    djui_hud_render_texture(data.tex, x - 1.5, y - 64 * scale, 1.5, 1.5)
    if math.abs(sortBy) == i then
      local sign = i / sortBy
      if sign == 1 then
        djui_hud_set_color(92, 255, 92, 255)
        djui_hud_render_texture(TEX_ARROW, x + 25, y - 35, 1.2, 1.2)
      else
        djui_hud_set_color(255, 92, 92, 255)
        djui_hud_render_texture(TEX_ARROW, x + 45, y - 15, -1.2, -1.2)
      end
    end

    -- selected option
    if mouseIdleTimer < 2 or (statDesc == i and hoveringOption) then
      local rectX = x + 20 * scale - space / 2
      local rectY = y - 64 * scale - 5
      local rectWidth = space
      local rectHeight = (16 * 32 + 64) * scale + 25
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
  if (MAX_PLAYERS > 16) and (network_player_connected_count() > 16) then
    local pcount = network_player_connected_count()
    local x = screenWidth * 0.9 - 40
    local y = 150
    local fullportion = screenHeight - 214
    local partportion = fullportion * 16 / pcount
    local farDown = 0
    djui_hud_set_color(0, 0, 0, 155)
    djui_hud_render_rect(x, y, 20, screenHeight - 210)

    -- handle scroll bar with mouse
    local scrolling = true
    if mouseGrabbedScrollBar then
      farDown = mouseScrollBarY + mouseY
      while scrolling do
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
      if menuY > pcount - 16 then
        menuY = pcount - 16
      end
      farDown = menuY * fullportion / pcount
    end

    djui_hud_set_color(255, 255, 255, 155)
    djui_hud_render_rect(x + 2, y + 2 + farDown, 16, partportion)
  end

  -- player names
  y = y - (menuY * 32 * scale)
  for a, i in ipairs(statTable) do
    if y > 170 and y < (screenHeight - 96 * scale) then
      x = 0
      local sMario = gPlayerSyncTable[i]
      local np = gNetworkPlayers[i]
      local playerColor = network_get_player_text_color_string(i)

      text = playerColor .. np.name .. "\\#ffffff\\"
      text = cap_color_text(text, PLAYER_NAME_CUTOFF)
      width = djui_hud_measure_text(remove_color(text)) * scale
      x = screenWidth * 0.1 + 150 - width / 2
      djui_hud_print_text_with_color(text, x, y, scale)

      x = screenWidth * 0.1 + 295
      space = (screenWidth * 0.8 - 420) / (#statOrder - 1)
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
          if text == "0000" or (text == "9999" and stat == "placement") then
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
  djui_hud_set_color(255, 255, 255, 255);
  if statDesc ~= 0 and hoveringOption then
    scale = 1.5

    local desc = descOrder[statDesc]
    if altNum == 1 and descOrder_alt1[statDesc] then
      desc = descOrder_alt1[statDesc]
    elseif altNum == 2 and descOrder_alt2[statDesc] then
      desc = descOrder_alt2[statDesc]
    end
    text = trans(desc)
    width = djui_hud_measure_text(text) * scale
    x = (screenWidth - width) / 2
    y = screenHeight - 32 * scale

    djui_hud_print_text(text, x, y, scale);
  end

  -- back button
  scale = 1.5
  x = screenWidth * 0.1 + 32
  y = screenHeight * 0.05
  djui_hud_render_texture(TEX_MENU_ARROW, x, y, -3, -3)
  if mouseIdleTimer < 2 or (statDesc == 0 and hoveringOption) then
    local rectX = x - 25
    local rectY = 10
    local rectWidth = 32
    local rectHeight = 32
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

function rules_menu_hud()
  djui_hud_set_resolution(RESOLUTION_DJUI)

  local text = ""

  local scale = 2
  local screenWidth = djui_hud_get_screen_width()
  local screenHeight = djui_hud_get_screen_height()
  local width = 0
  local x = 0
  local y = 100
  djui_hud_set_color(0, 0, 0, 200);
  djui_hud_render_rect(screenWidth * 0.1, 0, screenWidth * 0.8, screenHeight);

  -- title
  djui_hud_set_font(FONT_HUD)
  text = trans("menu_rules")
  width = djui_hud_measure_text(text) * 4
  x = (screenWidth - width) / 2
  djui_hud_set_color(255, 255, 255, 255);
  print_text_ex_hud_font(text, x, 10, 4);
  djui_hud_set_font(FONT_NORMAL)

  -- all text
  local sMario0 = gPlayerSyncTable[0]
  local runners = trans("runners")
  local hunters = trans("hunters")
  local tex = nil
  if ruleSlide == 0 then
    if GST.mhMode ~= 2 then
      if month == 13 or ruleEgg then
        text = (trans("welcome_egg"))
        tex = "mh_rules_01"
      else
        text = (trans("welcome"))
        tex = "mh_rules_00"
      end
    else
      text = (trans("welcome_mini"))
      tex = "mh_rules_00"
    end
  elseif ruleSlide == 1 then
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
    text = string.format("\\#00ffff\\%s\\#ffffff\\%s:\n%s",
      runners,
      extraRun,
      runGoal)
  elseif ruleSlide == 2 then
    tex = "mh_rules_04"
    local extraHunt = ""
    if GST.mhState ~= 0 and GST.mhState < 3 and sMario0.team ~= 1 then
      extraHunt = " " .. trans("thats_you")
    end
    local huntGoal = ""
    if GST.mhMode == 0 then
      huntGoal = trans("all_runners")
    else
      huntGoal = trans("any_runners")
    end
    text = string.format("\\#ff5a5a\\%s\\#ffffff\\%s:\n%s",
      hunters,
      extraHunt,
      huntGoal)
  elseif ruleSlide == 3 then
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
    if GST.mhMode == 0 then
      becomeHunter = "; " .. trans("become_hunter")
    end
    text = string.format("\\#00ffff\\%s\\#ffffff\\:\n%s%s%s.",
      runners,
      runLives,
      needed,
      becomeHunter)
  elseif ruleSlide == 4 then
    local becomeRunner = ""
    if GST.mhMode ~= 0 then
      becomeRunner = "; " .. trans("become_runner")
      tex = "mh_rules_09"
    else
      tex = "mh_rules_08"
    end
    local spectate = ""
    if GST.allowSpectate == true then
      spectate = "; " .. trans("spectate")
    end
    text = string.format("\\#ff5a5a\\%s\\#ffffff\\:\n%s%s%s.",
      hunters,
      trans("infinite_lives"),
      becomeRunner,
      spectate)
  elseif ruleSlide == 5 then
    local banned = ""
    if (GST.starRun) ~= -1 then
      banned = trans("banned_glitchless")
    else
      banned = trans("banned_general")
    end

    local goal = ""
    local fun = trans("fun")
    if GST.mhMode == 2 then
      goal = trans("mini_goal", GST.runTime // 1800, (GST.runTime % 1800) // 30) .. "\n"
    end

    text = string.format("%s\n\n%s%s",
      banned,
      goal,
      fun)
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
    y = y + 60 * scale
    local actualTex = get_texture_info(tex)
    x = (screenWidth - actualTex.width * 6) / 2
    djui_hud_render_texture(actualTex, x, y, 6, 6)
  end

  local olddir = mouseRulesDirection
  mouseRulesDirection = 0
  djui_hud_set_font(FONT_HUD)
  djui_hud_print_text("A", screenWidth * 0.8 - 30, screenHeight - 80, 4)
  if ruleSlide == MAX_RULES_SLIDE then
    djui_hud_render_texture(gTextures.no_camera, screenWidth * 0.8 + 30, screenHeight - 67, 3, 3)
  else
    djui_hud_render_texture(TEX_MENU_ARROW, screenWidth * 0.8 + 30, screenHeight - 67, 6, 6)
  end
  local rectX = screenWidth * 0.8 - 40
  local rectY = screenHeight - 85
  local rectWidth = 120
  local rectHeight = 80
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
  djui_hud_print_text("B", screenWidth * 0.2, screenHeight - 80, 4)
  if ruleSlide == 0 then
    djui_hud_render_texture(gTextures.no_camera, screenWidth * 0.2 - 50, screenHeight - 67, 3, 3)
  else
    djui_hud_render_texture(TEX_MENU_ARROW, screenWidth * 0.2 - 10, screenHeight - 20, -6, -6)
  end
  rectX = screenWidth * 0.2 - 60
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
  if sMenuInputsDown & A_BUTTON ~= 0 and mouseIdleTimer < 90 then
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
    if (m.controller.buttonDown & L_TRIG) ~= 0 and (m.controller.buttonPressed & START_BUTTON) ~= 0 and not is_game_paused() then
      menu_reload()
      menu = true
      menu_enter()

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

  if (sMenuInputsPressed & A_BUTTON) ~= 0 then
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
  if mouseIdleTimer < 90 and (sMenuInputsDown & A_BUTTON) ~= 0 and mouseArrowKey ~= 0 then
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
  if mouseIdleTimer < 90 and (#currMenu > 7 or (showingStats and MAX_PLAYERS > 16 and network_player_connected_count() > 16)) and (sMenuInputsDown & A_BUTTON) ~= 0 and (mouseGrabbedScrollBar or (mouseX >= screenWidth * 0.9 - 40 and mouseX <= screenWidth * 0.9 - 20)) then
    if (not mouseGrabbedScrollBar) then
      local screenHeight = djui_hud_get_screen_height()
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
      if ruleSlide + change > MAX_RULES_SLIDE or ruleSlide + change < 0 then
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
    elseif pressed[4] then
      currentOption = currentOption % #currMenu + 1
      play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
    end

    local option = currMenu[currentOption]
    local min = option.minNum or 0
    local countBy = 1
    if sMenuInputsDown & X_BUTTON ~= 0 and (option.currNum and (option.maxNum - min + 1) >= 10) then countBy = 10 end
    if pressed[3] and option.currNum then
      if countBy == 1 then
        option.currNum = (option.currNum - countBy - min) % (option.maxNum + 1 - min) + min
      else
        if option.currNum == min then option.currNum = 0 end
        option.currNum = (option.currNum - countBy)
        if option.currNum == -countBy then
          option.currNum = option.maxNum
        elseif option.currNum < 0 or option.currNum < min then
          option.currNum = option.maxNum + option.currNum
        end
      end
      play_sound(SOUND_MENU_CHANGE_SELECT, gGlobalSoundSource)
    elseif pressed[1] and option.currNum then
      if countBy == 1 then
        option.currNum = (option.currNum + countBy - min) % (option.maxNum + 1 - min) + min
      else
        if option.currNum == min then option.currNum = 0 end
        option.currNum = (option.currNum + countBy)
        if option.currNum == option.maxNum + countBy then
          option.currNum = 0
          if min > 0 then
            option.currNum = 10
          end
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
      if currMenu.name == "playerMenu" and currentOption < 17 then
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
      end
    end
  end
end

-- returns if a menu is open
function is_menu_open()
  return (menu or showingStats or showingRules)
end

-- custom text function that allows the HUD font to support more characters
local extra_chars = {
  ["ü"] = 00,
  ["Ü"] = 00, -- string_lower doesn't work for these, so we need both
  --["q"] = 01,
  --["v"] = 02,
  --["x"] = 03,
  --["z"] = 04,
  ["ä"] = 05,
  ["Ä"] = 05,
  ["ö"] = 06,
  ["Ö"] = 06,
  --["?"] = 07,
  --["."] = 08,
  ["á"] = 09,
  ["Á"] = 09,
  ["é"] = 10,
  ["É"] = 10,
  ["í"] = 11,
  ["Í"] = 11,
  ["ó"] = 12,
  ["Ó"] = 12,
  ["ú"] = 13,
  ["Ú"] = 13,
  ["à"] = 14,
  ["À"] = 14,
  ["è"] = 15,
  ["È"] = 15,
  ["ì"] = 16,
  ["Ì"] = 16,
  ["ò"] = 17,
  ["Ò"] = 17,
  ["ù"] = 18,
  ["Ù"] = 18,
  ["ë"] = 19,
  ["Ë"] = 19,
  ["ï"] = 20,
  ["Ï"] = 20,
  ["â"] = 21,
  ["Â"] = 21,
  ["ê"] = 22,
  ["Ê"] = 22,
  ["î"] = 23,
  ["Î"] = 23,
  ["ô"] = 24,
  ["Ô"] = 24,
  ["û"] = 25,
  ["Û"] = 25,
  ["å"] = 26,
  ["Å"] = 26,
  ["e̊"] = 27,
  ["̊E̊"] = 27,
  ["i̊"] = 28,
  ["I̊"] = 28,
  ["o̊"] = 29,
  ["O̊"] = 29,
  ["ů"] = 30,
  ["Ů"] = 30,
  ["ã"] = 31,
  ["Ã"] = 31,
  ["ẽ"] = 32,
  ["Ẽ"] = 32,
  ["ĩ"] = 33,
  ["Ĩ"] = 33,
  ["õ"] = 34,
  ["Õ"] = 34,
  ["ũ"] = 35,
  ["Ũ"] = 35,
  ["ñ"] = 36,
  ["Ñ"] = 36,
  ["ě"] = 37,
  ["Ě"] = 37,
  ["ç"] = 38,
  ["Ç"] = 38,
  --["!"] = 39,
  ["_"] = 40,
  --["-"] = 41,
  --[","] = 42,
  [":"] = 43,
  ["~"] = 44, -- use as "fixed camera"
}

local EX_HUD_FONT = get_texture_info("ex_hud_font")
function print_text_ex_hud_font(text, x, y, scale)
  djui_hud_set_font(FONT_HUD)
  local space = 0
  local render = ""
  local charSkip = 0
  for i = 1, string.len(text) do
    if charSkip > 0 then
      charSkip = charSkip - 1
    else
      local char = text:sub(i, i)

      if string.byte(text, i) > 122 then -- accent characters are actually two characters
        char = text:sub(i, i + 1)
        charSkip = 1
      end

      --djui_chat_message_create(char)
      local tex = extra_chars[string_lower(char)]
      if tex then
        djui_hud_print_text(render, x + space, y, scale);
        space = space + djui_hud_measure_text(render) * scale
        djui_hud_render_texture_tile(EX_HUD_FONT, x + space, y - (3 * scale), scale, scale, (tex % 8) * 32, (tex // 8) *
          32, 32, 32)
        space = space + djui_hud_measure_text(char) * scale
        render = ""
      elseif charSkip > 0 then -- prevent game crash
        render = render .. "x"
      else
        render = render .. char
      end
    end
  end
  djui_hud_print_text(render, x + space, y, scale);
end

--hook_event(HOOK_ON_HUD_RENDER, handleMenu)
hook_event(HOOK_BEFORE_MARIO_UPDATE, menu_controls)
hook_event(HOOK_UPDATE, function()
  if paused and ranMenuThisFrame == false then
    menu_controls(m0)
  end
  ranMenuThisFrame = false
end)
