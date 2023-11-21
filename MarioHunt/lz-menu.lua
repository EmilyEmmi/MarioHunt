-- Thanks to blocky for making most of this

-- localize some functions
local djui_hud_set_font, djui_hud_set_color, djui_hud_print_text, djui_hud_render_rect, djui_hud_measure_text, djui_hud_render_texture, djui_hud_set_resolution, djui_chat_message_create, djui_hud_get_screen_width, djui_hud_get_screen_height, djui_hud_set_render_behind_hud, tonumber, play_sound, string_lower, network_get_player_text_color_string =
djui_hud_set_font, djui_hud_set_color, djui_hud_print_text, djui_hud_render_rect, djui_hud_measure_text,
    djui_hud_render_texture, djui_hud_set_resolution, djui_chat_message_create, djui_hud_get_screen_width,
    djui_hud_get_screen_height, djui_hud_set_render_behind_hud, tonumber, play_sound, string.lower,
    network_get_player_text_color_string

local m0                                                                                                                                                                                                                                                                                                                                     = gMarioStates
[0]

-- Constants for joystick input
local JOYSTICK_THRESHOLD                                                                                                                                                                                                                                                                                                                     = 32

-- Variables to keep track of current menu state
local currentOption                                                                                                                                                                                                                                                                                                                          = 1
local bottomOption                                                                                                                                                                                                                                                                                                                           = 0
local focusPlayerOrCourse                                                                                                                                                                                                                                                                                                                    = 0
local prevOption                                                                                                                                                                                                                                                                                                                             = 0
local hoveringOption                                                                                                                                                                                                                                                                                                                         = true

-- localize the menu
local mainMenu                                                                                                                                                                                                                                                                                                                               = {}
local marioHuntMenu                                                                                                                                                                                                                                                                                                                          = {}
local startMenu                                                                                                                                                                                                                                                                                                                              = {}
local startMenuMini                                                                                                                                                                                                                                                                                                                          = {}
local settingsMenu                                                                                                                                                                                                                                                                                                                           = {}
local playerMenu                                                                                                                                                                                                                                                                                                                             = {}
local onePlayerMenu                                                                                                                                                                                                                                                                                                                          = {}
local allPlayerMenu                                                                                                                                                                                                                                                                                                                          = {}
local playerSettingsMenu                                                                                                                                                                                                                                                                                                                     = {}
local miscMenu                                                                                                                                                                                                                                                                                                                               = {}
local blacklistMenu                                                                                                                                                                                                                                                                                                                          = {}
local blacklistCourseMenu                                                                                                                                                                                                                                                                                                                    = {}
blacklistMenu.name                                                                                                                                                                                                                                                                                                                           = "blacklistMenu"
blacklistCourseMenu.name                                                                                                                                                                                                                                                                                                                     = "blacklistCourseMenu"

-- Controller Inputs
local sMenuInputsPressed                                                                                                                                                                                                                                                                                                                     = 0
local sMenuInputsDown                                                                                                                                                                                                                                                                                                                        = 0

-- textures
local TEX_MENU_ARROW                                                                                                                                                                                                                                                                                                                         = get_texture_info(
"menu-arrow")
local TEX_MENU_ARROW_VERT                                                                                                                                                                                                                                                                                                                    = get_texture_info(
"menu-arrow-vert")

-- mouse stuff
local TEX_HAND                                                                                                                                                                                                                                                                                                                               = get_texture_info(
"gd_texture_hand_open")
local TEX_HAND_SELECT                                                                                                                                                                                                                                                                                                                        = get_texture_info(
"gd_texture_hand_closed")
local mouseX                                                                                                                                                                                                                                                                                                                                 = djui_hud_get_mouse_x()
local mouseY                                                                                                                                                                                                                                                                                                                                 = djui_hud_get_mouse_y()
local mouseData                                                                                                                                                                                                                                                                                                                              = { prevX =
mouseX, prevY = mouseY }
local mouseIdleTimer                                                                                                                                                                                                                                                                                                                         = 90
local mouseGrabbedScrollBar                                                                                                                                                                                                                                                                                                                  = false
local mouseScrollBarY                                                                                                                                                                                                                                                                                                                        = 0
local mouseArrowKey                                                                                                                                                                                                                                                                                                                          = 0

-- build language menu
local LanguageMenu                                                                                                                                                                                                                                                                                                                           = {}
local langnum                                                                                                                                                                                                                                                                                                                                = 0
local lang_table                                                                                                                                                                                                                                                                                                                             = {}
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
  local GST = gGlobalSyncTable

  mainMenu = {
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

  marioHuntMenu = {
    { name = ("menu_start"),      title = ("menu_mh") },
    { name = ("menu_run_random"), currNum = 0,          minNum = 0, maxNum = MAX_PLAYERS - 1, desc = ("random_desc"),             format = { "auto" } },
    { name = ("menu_run_add"),    currNum = 0,          minNum = 0, maxNum = MAX_PLAYERS - 1, desc = ("add_desc"),                format = { "auto" } },
    { name = ("menu_gamemode"),   currNum = GST.mhMode, maxNum = 2, desc = ("mode_desc"),     format = { "normal", "switch", "mini" } },
    { name = ("menu_settings") },
    { name = ("menu_stop"),       desc = ("stop_desc") },
    { name = ("menu_back") },
    name = "marioHuntMenu",
    back = 7,
  }

  startMenu = {
    { name = ("menu_save_main"),    title = ("menu_start") },
    { name = ("menu_save_alt") },
    { name = ("menu_save_reset") },
    { name = ("menu_save_continue") },
    { name = ("menu_back") },
    { name = ("main_menu") },
    name = "startMenu",
    back = 5,
  }

  startMenuMini = {
    { name = ("menu_random"),   title = ("menu_start") },
    { name = ("menu_campaign"), currNum = 1,           minNum = 1, maxNum = 25 },
    { name = ("menu_back") },
    { name = ("main_menu") },
    name = "startMenuMini",
    back = 3,
  }

  LanguageMenu[1].title = ("menu_lang")

  local maxStars = 255
  local auto = gGlobalSyncTable.gameAuto
  if ROMHACK then maxStars = ROMHACK.max_stars end
  if auto == 99 then auto = -1 end
  settingsMenu = {
    { name = ("menu_run_lives"),      currNum = GST.runnerLives,   maxNum = 99,                      desc = ("lives_desc"),      title = ("menu_settings") },
    { name = ("menu_metal"),          option = GST.metal,          desc = ("metal_desc") },
    { name = ("menu_weak"),           option = GST.weak,           desc = ("weak_desc") },
    { name = ("menu_allow_spectate"), option = GST.allowSpectate,  desc = ("spectator_desc") },
    { name = ("menu_star_mode"),      option = GST.starMode,       desc = ("starmode_desc"),         invalid = (GST.mhMode == 2) },
    { name = ("menu_category"),       currNum = GST.starRun,       maxNum = maxStars,                minNum = -1,                desc = ("category_desc"),     invalid = (GST.mhMode == 2) },
    { name = ("menu_time"),           currNum = GST.runTime // 30, maxNum = 3600,                    desc = ("time_desc"),       time = true },
    { name = ("menu_auto"),           invalid = (GST.mhMode ~= 2), currNum = auto,                   minNum = -1,                maxNum = MAX_PLAYERS - 1,     desc = ("auto_desc"),                                   format = { "auto", "~" } },
    { name = ("menu_anarchy"),        currNum = GST.anarchy,       minNum = 0,                       maxNum = 3,                 desc = ("menu_anarchy_desc"), format = { "~", "lang_runners", "lang_hunters", "lang_all" } },
    { name = ("menu_dmgAdd"),         currNum = GST.dmgAdd,        minNum = 0,                       maxNum = 8,                 desc = ("menu_dmgAdd_desc"),  format = { [9] = "OHKO" } },
    { name = ("menu_nerf_vanish"),    option = GST.nerfVanish,     desc = ("menu_nerf_vanish_desc") },
    { name = ("menu_first_timer"),    option = GST.firstTimer,     desc = ("menu_first_timer_desc"), invalid = (GST.mhMode ~= 2) },
    { name = ("menu_blacklist"),      desc = ("blacklist_desc") },
    { name = ("menu_default"),        desc = ("default_desc") },
    { name = ("menu_back") },
    { name = ("main_menu") },
    name = "settingsMenu",
    back = 15,
  }
  if GST.starMode and GST.mhMode ~= 2 then
    settingsMenu[7] = { name = ("menu_stars"), currNum = GST.runTime, maxNum = 7, desc = ("stars_desc") }
  end

  -- name gets overriden
  playerMenu = {}
  for i = 0, MAX_PLAYERS - 1 do
    table.insert(playerMenu, { name = "PLAYER_" .. i, color = true })
  end
  playerMenu[1].title = "players"
  playerMenu.name = "playerMenu"
  playerMenu.back = MAX_PLAYERS + 2
  table.insert(playerMenu, { name = ("menu_players_all"), invalid = not has_mod_powers(0) })
  table.insert(playerMenu, { name = ("menu_back") })

  one_player_reload()

  allPlayerMenu = {
    { name = ("menu_pause"),         option = GST.pause,         title = ("menu_players_all"), desc = ("pause_desc") },
    { name = ("menu_forcespectate"), option = GST.forceSpectate, desc = ("forcespectate_desc") },
    { name = ("menu_back") },
    { name = ("main_menu") },
    name = "allPlayerMenu",
    back = 3,
  }

  playerSettingsMenu = {
    { name = ("hard_mode"),        title = ("menu_settings_player"),                 option = (gPlayerSyncTable[0].hard == 1), desc = ("hard_info_short") },
    { name = ("extreme_mode"),     option = (gPlayerSyncTable[0].hard == 2),         desc = ("extreme_info_short") },
    { name = ("menu_timer"),       option = showSpeedrunTimer,                       invalid = (GST.mode == 2),                desc = ("menu_timer_desc") },
    { name = ("menu_tc"),          option = (gPlayerSyncTable[0].teamChat or false), desc = ("menu_tc_desc"),                  invalid = disable_chat_hook },
    { name = ("menu_unknown"),     option = demonOn,                                 invalid = true,                           desc = ("menu_secret") },
    { name = ("menu_hide_hud"),    option = mhHideHud,                               desc = ("hidehud_desc") },
    { name = ("menu_fast"),        option = gPlayerSyncTable[0].fasterActions,       desc = ("menu_fast_desc") },
    { name = ("menu_popup_sound"), option = playPopupSounds },
    { name = ("menu_hide_roles"),  invalid = (get_true_roles() == 0),                desc = ("menu_hide_roles_desc") },
    { name = ("menu_back") },
    name = "playerSettingsMenu",
    back = 10,
  }
  if demonOn or demonUnlocked then
    playerSettingsMenu[5].name = ("menu_demon")
    playerSettingsMenu[5].desc = ("menu_demon_desc")
    playerSettingsMenu[5].invalid = false
  end

  miscMenu = {
    { name = ("free_camera"),         title = ("menu_misc"),                                                                                            invalid = ((not GST.allowSpectate) or (gPlayerSyncTable[0].team == 1 and GST.mhState ~= 1 and GST.mhState ~= 2)), desc = ("menu_free_cam_desc") },
    { name = ("menu_spectate_run"),   invalid = ((not GST.allowSpectate) or (gPlayerSyncTable[0].team == 1 and GST.mhState ~= 1 and GST.mhState ~= 2)), desc = ("menu_spectate_run_desc") },
    { name = ("menu_exit_spectate"),  invalid = (gPlayerSyncTable[0].forceSpectate or gPlayerSyncTable[0].spectator ~= 1),                              desc = ("menu_exit_spectate_desc") },
    { name = ("menu_stalk_run"),      invalid = ((not ROMHACK.stalk) or GST.mhMode == 2 or GST.mhState ~= 2),                                           desc = ("menu_stalk_run_desc") },
    { name = ("menu_skip"),           invalid = (GST.mhState ~= 2 or GST.mhMode ~= 2 or iVoted),                                                        desc = ("menu_skip_desc") },
    { name = ("menu_blacklist_list"), desc = ("menu_blacklist_list_desc") },
    { name = ("menu_back") },
    name = "miscMenu",
    back = 7,
  }

  local trueRoles = get_true_roles()
  local roles = gPlayerSyncTable[0].role
  hideRolesMenu = {
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
  onePlayerMenu = {
    { name = ("menu_flip"),          title = "PLAYER_S",                                                                                                                           invalid = not has_mod_powers(0),              desc = ("flip_desc") },
    { name = ("menu_spectate"),      invalid = (focusPlayerOrCourse == 0 or (not GST.allowSpectate) or (gPlayerSyncTable[0].team == 1 and GST.mhState ~= 1 and GST.mhState ~= 2)), desc = ("menu_spectate_desc") },
    { name = ("menu_stalk"),         invalid = (focusPlayerOrCourse == 0 or (not ROMHACK.stalk) or STP.team ~= 1 or GST.mhMode == 2 or GST.mhState ~= 2),                          desc = ("menu_stalk_desc") },
    { name = ("menu_pause"),         option = STP.pause,                                                                                                                           invalid = not has_mod_powers(0),              desc = ("pause_desc") },
    { name = ("menu_forcespectate"), option = STP.forceSpectate,                                                                                                                   invalid = not has_mod_powers(0),              desc = ("forcespectate_desc") },
    { name = ("menu_allowleave"),    invalid = (not has_mod_powers(0)) or (GST.mhMode == 2),                                                                                       desc = ("leave_desc") },
    { name = ("menu_setlife"),       invalid = (not has_mod_powers(0) or STP.team ~= 1 or GST.mhState == 0),                                                                       currNum = STP.runnerLives or GST.runnerLives, maxNum = 99,                  desc = ("setlife_desc") },
    { name = ("menu_back") },
    { name = ("main_menu") },
    name = "onePlayerMenu",
    back = 8,
  }
end

function build_blacklist_menu()
  blacklistMenu = {}
  for i = COURSE_MIN, COURSE_MAX - 1 do
    if ROMHACK.star_data and (not ROMHACK.star_data[i] or #ROMHACK.star_data[i] > 0) and (ROMHACK.hubStages == nil or ROMHACK.hubStages[i] == nil) then
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
  blacklistCourseMenu = {}
  local oneValid = false
  for i = 1, 7 do
    if valid_star(focusPlayerOrCourse, i, true, true) and (i ~= 7 or focusPlayerOrCourse > 15) then
      local valid = (mini_blacklist[focusPlayerOrCourse * 10 + i] == nil)
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
  if menu and menu.name == "onePlayerMenu" then
    one_player_reload()
    menu = onePlayerMenu
  elseif menu and menu.name == "blacklistMenu" then
    build_blacklist_menu()
    menu = blacklistMenu
  elseif menu and menu.name == "blacklistCourseMenu" then
    build_blacklist_course_menu()
    menu = blacklistCourseMenu
  end
  currMenu = menu or mainMenu
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
  -- doesn't have to be a function but just in case you want to add something here.
  menu_enter()
  play_sound(SOUND_GENERAL_PAINTING_EJECT, m0.marioObj.header.gfx.cameraToObject)
  menu = false
  showingStats = false
  focusPlayerOrCourse = 0
end

local menuActions = {}
function action_setup()
  menuActions = {
    mainMenu = {
      [1] = function() menu_enter(marioHuntMenu) end,
      [2] = function() menu_enter(playerSettingsMenu) end,
      [3] = show_rules,
      [4] = list_settings,
      [5] = function() menu_enter(LanguageMenu) end,
      [6] = function() menu_enter(miscMenu) end,
      [7] = function() menu_enter(playerMenu) end,
      [8] = function() showingStats = true end,
      [9] = close_menu,
    },
    marioHuntMenu = {
      [1] = function() if gGlobalSyncTable.mhMode ~= 2 then menu_enter(startMenu) else menu_enter(startMenuMini) end end,
      [2] = function(option) runner_randomize(option.currNum) end,
      [3] = function(option) add_runner(option.currNum) end,
      [4] = function(option)
        change_game_mode("", option.currNum)
        menu_reload()
        menu_enter(marioHuntMenu, currentOption)
      end,
      [5] = function(option) menu_enter(settingsMenu) end,
      [6] = function()
        halt_command()
        close_menu()
      end,
      [7] = function() menu_enter() end,
    },
    startMenu = {
      [1] = function() start_game("main") end,
      [2] = function() start_game("alt") end,
      [3] = function() start_game("reset") end,
      [4] = function() start_game("continue") end,
      [5] = function() menu_enter(marioHuntMenu) end,
      [6] = function() menu_enter() end,
    },
    startMenuMini = {
      [1] = function() start_game("") end,
      [2] = function(option) start_game(tostring(option.currNum)) end,
      [3] = function() menu_enter(marioHuntMenu) end,
      [4] = function() menu_enter() end,
    },
    -- player menu is special case

    -- language is a special case
    settingsMenu = {
      [1] = function(option) runner_lives(tostring(option.currNum)) end,
      [2] = function(option)
        option.option = not option.option
        gGlobalSyncTable.metal = option.option
        if not option.option then
          djui_chat_message_create(trans("not_metal"))
        else
          djui_chat_message_create(trans("now_metal"))
        end
      end,
      [3] = function(option)
        option.option = not option.option
        gGlobalSyncTable.weak = option.option
        if not option.option then
          djui_chat_message_create(trans("not_weak"))
        else
          djui_chat_message_create(trans("now_weak"))
        end
      end,
      [4] = function(option)
        option.option = not option.option
        gGlobalSyncTable.allowSpectate = option.option
        if not option.option then
          djui_chat_message_create(trans("no_spectate"))
        else
          djui_chat_message_create(trans("can_spectate"))
        end
      end,
      [5] = function(option)
        option.option = not option.option
        star_mode_command("", option.option)
        menu_reload()
        menu_enter(settingsMenu, currentOption)
      end,
      [6] = function(option)
        star_count_command(option.currNum)
      end,
      [7] = function(option)
        if gGlobalSyncTable.mhMode ~= 2 and gGlobalSyncTable.starMode then
          stars_needed_command(option.currNum)
        else
          time_needed_command(option.currNum)
        end
      end,
      [8] = function(option)
        if option.currNum < 0 then
          gGlobalSyncTable.gameAuto = 99,
              djui_chat_message_create(trans("auto_on"))
          if gGlobalSyncTable.mhState == 0 then
            gGlobalSyncTable.mhTimer = 20 * 30       -- 20 seconds
          end
        elseif option.currNum == 0 then
          gGlobalSyncTable.gameAuto = 0,
              djui_chat_message_create(trans("auto_off"))
          if gGlobalSyncTable.mhState == 0 then
            gGlobalSyncTable.mhTimer = 0       -- don't set
          end
        else
          gGlobalSyncTable.gameAuto = option.currNum
          local runners = trans("runners")
          if gGlobalSyncTable.gameAuto == 1 then
            runners = trans("runner")
          end
          djui_chat_message_create(string.format("%s (%d %s)", trans("auto_on"), gGlobalSyncTable.gameAuto, runners))
          if gGlobalSyncTable.mhState == 0 then
            gGlobalSyncTable.mhTimer = 20 * 30       -- 20 seconds
          end
        end
      end,
      [9] = function(option)
        gGlobalSyncTable.anarchy = option.currNum
        djui_chat_message_create(trans("anarchy_set_" .. gGlobalSyncTable.anarchy))
      end,
      [10] = function(option)
        gGlobalSyncTable.dmgAdd = option.currNum
        djui_chat_message_create(trans("dmgAdd_set", gGlobalSyncTable.dmgAdd))
      end,
      [11] = function(option)
        option.option = not option.option
        gGlobalSyncTable.nerfVanish = option.option
      end,
      [12] = function(option)
        option.option = not option.option
        gGlobalSyncTable.firstTimer = option.option
      end,
      [13] = function()
        menu_enter(blacklistMenu)
      end,
      [14] = function()
        default_settings()
        menu_reload()
        menu_enter(settingsMenu, currentOption)
      end,
      [15] = function() menu_enter(marioHuntMenu, 5) end,
      [16] = function() menu_enter() end,
    },
    onePlayerMenu = {
      [1] = function()
        change_team_command(focusPlayerOrCourse)
        menu_reload()
        menu_enter(onePlayerMenu, currentOption)
      end,
      [2] = function() spectate_command(focusPlayerOrCourse) end,
      [3] = function() stalk_command(focusPlayerOrCourse) end,
      [4] = function(option)
        option.option = not option.option
        pause_command(focusPlayerOrCourse)
      end,
      [5] = function(option)
        option.option = not option.option
        force_spectate_command(focusPlayerOrCourse)
      end,
      [6] = function() allow_leave_command(focusPlayerOrCourse) end,
      [7] = function(option) set_life_command(focusPlayerOrCourse .. " " .. option.currNum) end,
      [8] = function() menu_enter(playerMenu, focusPlayerOrCourse + 1) end,
      [9] = function() menu_enter(nil, 7) end,
    },
    allPlayerMenu = {
      [1] = function(option)
        option.option = not option.option
        pause_command("all")
      end,
      [2] = function(option)
        option.option = not option.option
        force_spectate_command("all")
      end,
      [3] = function() menu_enter(playerMenu, MAX_PLAYERS + 1) end,
      [4] = function() menu_enter(nil, 7) end,
    },
    playerSettingsMenu = {
      [1] = function(option)
        option.option = not option.option
        if option.option then
          hard_mode_command("on")
        else
          hard_mode_command("off")
        end
        currMenu[2].option = false
      end,
      [2] = function(option)
        option.option = not option.option
        if option.option then
          hard_mode_command("ex on")
        else
          hard_mode_command("off")
        end
        currMenu[1].option = false
      end,
      [3] = function(option)
        option.option = not option.option
        showSpeedrunTimer = option.option
        mod_storage_save_fix_bug("showSpeedrunTimer", tostring(option.option))
      end,
      [4] = function(option)
        option.option = not option.option
        gPlayerSyncTable[0].teamChat = option.option
        if option.option then
          djui_chat_message_create(trans("tc_toggle", trans("on")))
        else
          djui_chat_message_create(trans("tc_toggle", trans("off")))
        end
      end,
      [5] = function(option)
        option.option = not option.option
        demonOn = option.option
      end,
      [6] = function(option)
        option.option = not option.option
        mhHideHud = option.option
      end,
      [7] = function(option)
        option.option = not option.option
        gPlayerSyncTable[0].fasterActions = option.option
        mod_storage_save_fix_bug("fasterActions", tostring(option.option))
      end,
      [8] = function(option)
        option.option = not option.option
        playPopupSounds = option.option
        mod_storage_save_fix_bug("playPopupSounds", tostring(option.option))
      end,
      [9] = function() menu_enter(hideRolesMenu, 1) end,
      [10] = function() menu_enter(nil, 2) end,
    },
    miscMenu = {
      [1] = function()
        spectate_command("")
        menu_reload()
        currMenu = miscMenu
      end,
      [2] = function()
        spectate_command("runner")
        menu_reload()
        currMenu = miscMenu
      end,
      [3] = function(option)
        spectate_command("off")
        option.invalid = true
      end,
      [4] = function() stalk_command("") end,
      [5] = function()
        skip_command("")
        close_menu()
      end,
      [6] = function() blacklist_command("list") end,
      [7] = function() menu_enter(nil, 6) end,
    },
    -- blacklistMenu is another special case
    -- same for the course menu
    hideRolesMenu = {
      [1] = function(option)
        option.option = not option.option
        if option.option then
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role | 2
        else
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role & ~2
        end
        mod_storage_save_fix_bug("showRoles", tostring(gPlayerSyncTable[0].role))
      end,
      [2] = function(option)
        option.option = not option.option
        if option.option then
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role | 4
        else
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role & ~4
        end
        mod_storage_save_fix_bug("showRoles", tostring(gPlayerSyncTable[0].role))
      end,
      [3] = function(option)
        option.option = not option.option
        if option.option then
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role | 8
        else
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role & ~8
        end
        mod_storage_save_fix_bug("showRoles", tostring(gPlayerSyncTable[0].role))
      end,
      [4] = function(option)
        option.option = not option.option
        if option.option then
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role | 16
        else
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role & ~16
        end
        mod_storage_save_fix_bug("showRoles", tostring(gPlayerSyncTable[0].role))
      end,
      [5] = function(option)
        option.option = not option.option
        if option.option then
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role | 32
        else
          gPlayerSyncTable[0].role = gPlayerSyncTable[0].role & ~32
        end
        mod_storage_save_fix_bug("showRoles", tostring(gPlayerSyncTable[0].role))
      end,
      [6] = function()
        gPlayerSyncTable[0].role = get_true_roles()
        menu_reload()
        menu_enter(hideRolesMenu, 6)
        mod_storage_save_fix_bug("showRoles", tostring(gPlayerSyncTable[0].role))
      end,
      [7] = function() menu_enter(playerSettingsMenu, 9) end,
      [8] = function() menu_enter(nil, 2) end,
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

  if marioHuntCommands == nil or #marioHuntCommands < 1 then
    setup_commands()
  end

  local currentMenuName = currMenu.name
  if currentMenuName == "LanguageMenu" then
    if currMenu[option].lang then
      switch_lang(currMenu[option].lang)
      --menu_reload()
      menu_enter(LanguageMenu, currentOption)
    else   -- back
      menu_enter(nil, 5)
    end
  elseif currentMenuName == "blacklistMenu" then
    if currMenu[option].course then
      focusPlayerOrCourse = currMenu[option].course
      prevOption = option
      menu_enter(blacklistCourseMenu)
    elseif currMenu[option].action then
      blacklist_command(currMenu[option].action)
      menu_enter(blacklistMenu, option)
    elseif currMenu.back == option then
      menu_enter(settingsMenu, 13)
    else
      menu_enter()
    end
  elseif currentMenuName == "blacklistCourseMenu" then
    if currMenu.back == option then
      menu_enter(blacklistMenu, prevOption)
    elseif currMenu[option].star == "all" then
      currMenu[option].option = not currMenu[option].option
      if currMenu[option].option then
        blacklist_command("remove " .. focusPlayerOrCourse)
      else
        blacklist_command("add " .. focusPlayerOrCourse)
      end
      menu_enter(blacklistCourseMenu, option)
    elseif currMenu[option].star then
      currMenu[option].option = not currMenu[option].option
      if currMenu[option].option then
        blacklist_command("remove " .. focusPlayerOrCourse .. " " .. currMenu[option].star)
      else
        blacklist_command("add " .. focusPlayerOrCourse .. " " .. currMenu[option].star)
      end
      menu_enter(blacklistCourseMenu, option)
    else
      menu_enter()
    end
  elseif currentMenuName == "playerMenu" then
    if option <= MAX_PLAYERS then
      focusPlayerOrCourse = option - 1
      menu_enter(onePlayerMenu)
    elseif option == currMenu.back then
      menu_enter(nil, 7)
    else
      focusPlayerOrCourse = option - 1
      menu_enter(allPlayerMenu)
    end
  elseif menuActions[currentMenuName] then
    local action = menuActions[currentMenuName][option]
    if action then
      action(currMenu[option])
    end
  end
end

-- Function to handle menu rendering
function handleMenu()
  if (not menu) or showingStats then
    return
  end

  djui_hud_set_render_behind_hud(false)
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
    optionText = trans(optionText)

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
      if option.time then     -- time format
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

          for a, text_ in pairs(option.format) do    -- pairs is used because one of them does not have 1-7
            local text = text_
            if text:sub(1, 5) == "lang_" then
              text = trans(text:sub(6))
            end
            if measureString:len() < text:len() then
              measureString = text
            end
          end
        else
          if option.currNum == -1 then choiceString = "any" end
          measureString = tostring(option.maxNum)
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

  local optionX = screenWidth * 0.5 - maxTextWidth * 0.5
  local optionY = (screenHeight * 0.5 - (screenHeight * 0.1 * (optionCount - 1)) * 0.5)
  local titleScale = 6

  local titleText = tostring(currMenu[1].title)
  local titleCenter = 0
  djui_hud_set_color(255, 255, 255, 255)
  if titleText == "PLAYER_S" then
    djui_hud_set_font(FONT_NORMAL)   -- extended hud font doesn't support every character that can be in a username yet
    local np = gNetworkPlayers[focusPlayerOrCourse]
    if np and np.connected then
      local playerColor = network_get_player_text_color_string(focusPlayerOrCourse)
      titleText = playerColor .. np.name
      --titleText = remove_color(np.name)
    else
      menu_enter(playerMenu, focusPlayerOrCourse + 1)
    end

    titleScale = 3
    titleCenter = (screenWidth - djui_hud_measure_text(remove_color(titleText)) * titleScale) * 0.5
    --titleCenter = (screenWidth - djui_hud_measure_text(titleText) * titleScale) * 0.5

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

    titleCenter = (screenWidth - djui_hud_measure_text(titleText) * titleScale) * 0.5
    print_text_ex_hud_font(titleText, titleCenter, screenHeight * 0.03, titleScale)
  end
  djui_hud_set_font(FONT_HUD)

  for i, option in ipairs(currMenu) do
    local render = true
    if i > bottomOption then
      djui_hud_set_color(255, 255, 255, 255)
      djui_hud_render_texture(TEX_MENU_ARROW_VERT, screenWidth / 2 + 20, screenHeight - 50, -4, -4)
      break
    elseif i <= (bottomOption - optionCount) then
      djui_hud_set_color(255, 255, 255, 255)
      djui_hud_render_texture(TEX_MENU_ARROW_VERT, screenWidth / 2 - 23, screenHeight * 0.15, 4, 4)
      render = false
    end

    if render then
      local textColor = { 255, 255, 255, 255 }   -- Default text color

      if option.option ~= nil then
        if option.option then
          textColor = { 92, 255, 92, 255 }       -- Green text color
        else
          textColor = { 255, 92, 92, 255 }       -- Red text color
        end
      end

      djui_hud_set_font(FONT_NORMAL)
      local optionText = option.name
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
      local textX = (screenWidth - textWidth) * 0.5

      if roleText ~= nil then textX = screenWidth * 0.2 end

      if option.currNum ~= nil then textX = (screenWidth - textWidth - option.choiceWidth - 80) * 0.5 end

      if roleText == "" then
        option.invalid = true
      elseif roleText ~= nil then
        option.invalid = (option.name == "PLAYER_0" and not has_mod_powers(0))
      end

      -- special case for course menu
      if option.course then
        local allValid = true
        local oneValid = false

        for i = 1, 7 do
          if (i ~= 7 or option.course > 15) and valid_star(option.course, i, true, true) then
            if mini_blacklist[option.course * 10 + i] == nil then
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
          textColor = { 92, 255, 92, 255 }    -- Green text color
        elseif oneValid then
          textColor = { 255, 255, 92, 255 }   -- Yellow text color
        else
          textColor = { 255, 92, 92, 255 }    -- Red text color
        end
      end

      -- darken unselectable options
      if option.invalid then
        textColor[4] = 100     -- set alpha to 100
      end
      djui_hud_set_color(table.unpack(textColor))

      if option.color then
        if option.option or roleText ~= nil then
          djui_hud_print_text_with_color(optionText, textX, optionY, textScale, textColor[4])
        else
          djui_hud_print_text(remove_color(optionText), textX, optionY, textScale)
        end
      else
        djui_hud_print_text(optionText, textX, optionY, textScale)
      end
      if roleText ~= nil then
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
            play_sound(SOUND_MENU_CHANGE_SELECT, m0.marioObj.header.gfx.cameraToObject)
          end
          hoveringOption = true
        end
      end

      if option.currNum ~= nil then
        local choiceWidth = (option.choiceWidth - djui_hud_measure_text(option.choiceString) * 3) * 0.5
        print_text_ex_hud_font(option.choiceString, textX + textWidth + choiceWidth + 45, optionY, 3)
        djui_hud_render_texture(TEX_MENU_ARROW, textX + textWidth + 40,
          optionY + 2 + 40, -5, -5)
        djui_hud_render_texture(TEX_MENU_ARROW, textX + textWidth + option.choiceWidth + 60,
          optionY + 2, 5, 5)

        -- mouse control
        if mouseIdleTimer < 90 and i == currentOption and hoveringOption then
          local relativeX = mouseX - textX - textWidth
          if relativeX <= 50 then
            mouseArrowKey = 3     -- left
          elseif relativeX >= option.choiceWidth + 50 then
            mouseArrowKey = 1     -- right
          else
            mouseArrowKey = 0     -- none
          end
        elseif i == currentOption then
          mouseArrowKey = 0     -- none
        end
      end

      if i == currentOption and hoveringOption then
        local rectX = optionX              -- maxTextWidth * 0.2
        local rectY = optionY
        local rectWidth = maxTextWidth     -- * 1.4
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
          local descX = (screenWidth - descWidth) * 0.5
          djui_hud_print_text(desc, descX, screenHeight - 50, 1)
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
  local statOrder = { "wins_standard", "wins", "hardWins_standard", "hardWins", "exWins_standard", "exWins", "kills", "maxStreak", "maxStar", "placement" }
  local descOrder = { "stat_wins_standard", "stat_wins", "stat_wins_hard_standard", "stat_wins_hard", "stat_wins_ex_standard", "stat_wins_ex", "stat_kills", "stat_combo", "stat_mini_stars",
    "stat_placement" }

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
          play_sound(SOUND_MENU_CHANGE_SELECT, m0.marioObj.header.gfx.cameraToObject)
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

  local statTable = {}
  for i = 0, (MAX_PLAYERS - 1) do
    local np = gNetworkPlayers[i]
    if i == 0 or np.connected then
      table.insert(statTable, i)
    end
  end

  if sortBy ~= 0 and #statTable > 1 then
    table.sort(statTable, function(a, b)
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
      if menuY > pcount-16 then
        menuY = pcount-16
      end
      farDown = menuY * fullportion / pcount
    end

    djui_hud_set_color(255, 255, 255, 155)
    djui_hud_render_rect(x + 2, y + 2 + farDown, 16, partportion)
  end

  -- player names
  y = y - (menuY*32*scale)
  for a, i in ipairs(statTable) do
    if y > 170 and y < (screenHeight-96*scale) then
      x = 0
      local sMario = gPlayerSyncTable[i]
      local np = gNetworkPlayers[i]
      local playerColor = network_get_player_text_color_string(i)

      text = playerColor .. np.name .. "\\#ffffff\\"
      width = djui_hud_measure_text(remove_color(text)) * scale
      x = screenWidth * 0.1 + 150 - width / 2
      djui_hud_print_text_with_color(text, x, y, scale)

      x = screenWidth * 0.1 + 300
      space = (screenWidth * 0.8 - 420) / (#statOrder - 1)
      for i = 1, #statOrder do
        text = string.format("%03d", (sMario[statOrder[i]] or 0))
        if text == "000" or (text == "999" and statOrder[i] == "placement") then
          djui_hud_set_color(100, 100, 100, 255)
        else
          djui_hud_set_color(255, 255, 255, 255)
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

    text = trans(descOrder[statDesc])
    width = djui_hud_measure_text(text) * scale
    x = (screenWidth - width) * 0.5
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
        play_sound(SOUND_MENU_CHANGE_SELECT, m0.marioObj.header.gfx.cameraToObject)
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
  if not (menu or showingStats) then
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

  local mCamToObj = m0.marioObj.header.gfx.cameraToObject

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
  elseif showingStats then -- stats table controls
    if m.freeze < 1 then m.freeze = 1 end

    if statDesc ~= 0 then
      if pressed[1] or pressed[2] or pressed[3] or pressed[4] then
        if pressed[1] then
          statDesc = (statDesc + #stat_icon_data) % (#stat_icon_data) + 1
          play_sound(SOUND_MENU_CHANGE_SELECT, mCamToObj)
        elseif pressed[2] then
          if MAX_PLAYERS <= 16 or network_player_connected_count() <= 16 then
            statDesc = 0
          elseif menuY > 0 then
            menuY = menuY - 1
          else
            statDesc = 0
          end
          play_sound(SOUND_MENU_CHANGE_SELECT, mCamToObj)
        elseif pressed[3] then
          statDesc = (statDesc + #stat_icon_data - 2) % (#stat_icon_data) + 1
          play_sound(SOUND_MENU_CHANGE_SELECT, mCamToObj)
        elseif MAX_PLAYERS > 16 and network_player_connected_count() > 16 then
          if menuY < network_player_connected_count()-16 then
            menuY = menuY + 1
            play_sound(SOUND_MENU_CHANGE_SELECT, mCamToObj)
          end
        end
      end
    elseif pressed[4] then
      statDesc = 1
      play_sound(SOUND_MENU_CHANGE_SELECT, mCamToObj)
    end

    if hoveringOption and (sMenuInputsPressed & A_BUTTON) ~= 0 then
      play_sound(SOUND_MENU_CLICK_FILE_SELECT, mCamToObj)
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
          play_sound(SOUND_MENU_CLICK_FILE_SELECT, mCamToObj)
        else
          play_sound(SOUND_GENERAL_PAINTING_EJECT, mCamToObj)
        end
      end
    elseif (sMenuInputsPressed & B_BUTTON) ~= 0 then
      showingStats = false
      if menu then
        menu_enter(nil, 8)
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, mCamToObj)
      else
        play_sound(SOUND_GENERAL_PAINTING_EJECT, mCamToObj)
      end
    end
  elseif menu then
    if m.freeze < 1 then m.freeze = 1 end

    if pressed[2] then
      currentOption = (currentOption - 2 + #currMenu) % #currMenu + 1
      play_sound(SOUND_MENU_CHANGE_SELECT, mCamToObj)
    elseif pressed[4] then
      currentOption = currentOption % #currMenu + 1
      play_sound(SOUND_MENU_CHANGE_SELECT, mCamToObj)
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
        elseif option.currNum < 0 then
          option.currNum = option.maxNum + option.currNum
        end
      end
      play_sound(SOUND_MENU_CHANGE_SELECT, mCamToObj)
    elseif pressed[1] and option.currNum then
      if countBy == 1 then
        option.currNum = (option.currNum + countBy - min) % (option.maxNum + 1 - min) + min
      else
        if option.currNum == min then option.currNum = 0 end
        option.currNum = (option.currNum + countBy)
        if option.currNum == option.maxNum + countBy then
          option.currNum = 0
        elseif option.currNum > option.maxNum then
          option.currNum = option.maxNum
        end
      end
      play_sound(SOUND_MENU_CHANGE_SELECT, mCamToObj)
    end

    local option = currMenu[currentOption]
    if hoveringOption and pressed[5] then
      if option.invalid then
        play_sound(SOUND_MENU_CAMERA_BUZZ, mCamToObj)
      else
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, mCamToObj)
        selectOption(currentOption)
      end
    elseif pressed[6] and currMenu.back then
      play_sound(SOUND_MENU_CLICK_FILE_SELECT, mCamToObj)
      selectOption(currMenu.back)
    elseif hoveringOption and pressed[7] then
      if currMenu.name == "playerMenu" and currentOption < 17 then
        if (not has_mod_powers(0)) or option.invalid then
          play_sound(SOUND_MENU_CAMERA_BUZZ, mCamToObj)
        else
          play_sound(SOUND_MENU_CLICK_FILE_SELECT, mCamToObj)
          change_team_command(currentOption - 1)
        end
      elseif currMenu.name == "blacklistMenu" and option.course then -- toggle all
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, mCamToObj)
        local oneValid = false

        for i = 1, 7 do
          if (i ~= 7 or option.course > 15) and valid_star(option.course, i, true, true) then
            if mini_blacklist[option.course * 10 + i] == nil then
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

-- custom text function that allows the HUD font to support more characters
-- TODO: a bunch of these characters are actually the wrong ones
local extra_chars = {
  ["ü"] = 00,
  ["Ü"] = 00,             -- string_lower doesn't work for these, so we need both
  ["q"] = 01,
  ["v"] = 02,
  ["x"] = 03,
  ["z"] = 04,
  ["ä"] = 05,
  ["Ä"] = 05,
  ["ö"] = 06,
  ["Ö"] = 06,
  ["?"] = 07,
  ["."] = 08,
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
  ["!"] = 39,
  ["_"] = 40,
  ["-"] = 41,
  [","] = 42,
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
      if tex ~= nil then
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
  if gPlayerSyncTable[0].pause and ranMenuThisFrame == false then
    menu_controls(m0)
  end
  ranMenuThisFrame = false
end)
