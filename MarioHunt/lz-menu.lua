-- Thanks to blocky for making most of this

-- localize some functions
local djui_hud_set_font,djui_hud_set_color,djui_hud_print_text,djui_hud_render_rect,djui_hud_measure_text,djui_hud_render_texture,djui_hud_set_resolution,djui_chat_message_create,djui_hud_get_screen_width,djui_hud_get_screen_height,djui_hud_set_render_behind_hud,tonumber,play_sound,string_lower,network_get_player_text_color_string = djui_hud_set_font,djui_hud_set_color,djui_hud_print_text,djui_hud_render_rect,djui_hud_measure_text,djui_hud_render_texture,djui_hud_set_resolution,djui_chat_message_create,djui_hud_get_screen_width,djui_hud_get_screen_height,djui_hud_set_render_behind_hud,tonumber,play_sound,string.lower,network_get_player_text_color_string

-- Constants for joystick input
local JOYSTICK_THRESHOLD = 32

-- Variables to keep track of current menu state
local currentOption = 1
local bottomOption = 0
local focusPlayerOrCourse = 0
local prevOption = 0

-- localize the menu
local mainMenu = {}
local marioHuntMenu = {}
local startMenu = {}
local startMenuMini = {}
local settingsMenu = {}
local playerMenu = {}
local onePlayerMenu = {}
local allPlayerMenu = {}
local playerSettingsMenu = {}
local miscMenu = {}
local blacklistMenu = {}
local blacklistCourseMenu = {}
blacklistMenu.name = "blacklistMenu"
blacklistCourseMenu.name = "blacklistCourseMenu"

-- build language menu
local LanguageMenu = {}
local langnum = 0
local lang_table = {}
for id,data in pairs(langdata) do
  langnum = langnum + 1
  table.insert(lang_table, {(data.name_menu or data.fullname), id})
end

-- sort alphabetically
table.sort(lang_table, function(a,b)
  return a[1]:lower() < b[1]:lower()
end)

for i,data in ipairs(lang_table) do
  table.insert(LanguageMenu, { name = data[1], lang = data[2] } )
end
table.insert(LanguageMenu, { name = trans("menu_back") })
LanguageMenu[1].title = trans("menu_lang")
LanguageMenu.name = "LanguageMenu"
LanguageMenu.back = langnum + 1

-- we reload all of this whenever we change languages
function menu_reload()
  local GST = gGlobalSyncTable

  mainMenu = {
      { name = trans("menu_mh"),          title = trans("main_menu"), invalid = not has_mod_powers(0) },
      { name = trans("menu_settings_player"), },
      { name = trans("menu_rules") },
      { name = trans("menu_lang") },
      { name = trans("menu_misc") },
      { name = trans("players") },
      { name = trans("menu_stats") },
      { name = trans("menu_exit") },
      name = "mainMenu",
      back = 8,
  }

  marioHuntMenu = {
      { name = "Start",             title = trans("menu_mh")},
      { name = trans("menu_run_random"), currNum = 1,   minNum = 1, maxNum = MAX_PLAYERS - 1, description = trans("random_desc")  },
      { name = trans("menu_run_add"),       currNum = 1,   minNum = 1, maxNum = MAX_PLAYERS - 1, description = trans("add_desc") },
      { name = trans("menu_run_lives"),      currNum = GST.runnerLives, maxNum = 99,              description = trans("lives_desc") },
      { name = trans("menu_settings") },
      { name = "Stop", description = trans("stop_desc")},
      { name = trans("menu_back") },
      name = "marioHuntMenu",
      back = 7,
  }

  startMenu = {
      { name = "Main", title = "Start"  },
      { name = "Alt Save (buggy)" },
      { name = "Reset Alt Save (buggy)" },
      { name = "Continue (no warping back)"},
      { name = trans("menu_back") },
      { name = trans("main_menu") },
      name = "startMenu",
      back = 5,
  }

  startMenuMini = {
      { name = "Random", title = "Start" },
      { name = "Campaign", currNum = 1, minNum = 1, maxNum = 25 },
      { name = trans("menu_back") },
      { name = trans("main_menu") },
      name = "startMenuMini",
      back = 3,
  }

  LanguageMenu[1].title = trans("menu_lang")

  local maxStars = 255
  local auto = gGlobalSyncTable.gameAuto
  if ROMHACK then maxStars = ROMHACK.max_stars end
  if auto == 99 then auto = -1 end
  settingsMenu = {
      { name = trans("menu_gamemode"), currNum = GST.mhMode, maxNum = 2,      description = trans("mode_desc"), title = trans("menu_settings") },
      { name = "Seeker Appearence", option = GST.metal,           description = trans("metal_desc") },
      { name = "Weak Mode",         option = GST.weak,            description = trans("weak_desc") },
      { name = "Allow Spectating",  option = GST.allowSpectate,   description = trans("spectator_desc") },
      { name = "Star Mode",         option = GST.starMode,        description = trans("starmode_desc"), invalid = (GST.mhMode == 2) },
      { name = "Category", currNum = GST.starRun, maxNum = maxStars, minNum = -1, description = trans("category_desc"), invalid = (GST.mhMode == 2) },
      { name = "Time",  currNum = GST.runTime//30, maxNum = 3600,  description = trans("time_desc")},
      { name = "Auto Game", invalid = (GST.mhMode ~= 2), currNum = auto, minNum = -1, maxNum = MAX_PLAYERS-1, description = trans("auto_desc")},
      { name = "MiniHunt Blacklist", description = "Control what stars may appear in MiniHunt." },
      { name = "Reset to Defaults",                               description = trans("default_desc") },
      { name = trans("menu_back") },
      { name = trans("main_menu") },
      name = "settingsMenu",
      back = 11,
  }
  if GST.starMode and GST.mhMode ~= 2 then
    settingsMenu[7] = { name = "Stars", currNum = GST.runTime, maxNum = 7, description = trans("stars_desc") }
  end

  -- name gets overriden
  playerMenu = {
      { name = "PLAYER_0",  color = true, title = trans("players") },
      { name = "PLAYER_1",  color = true },
      { name = "PLAYER_2",  color = true },
      { name = "PLAYER_3",  color = true },
      { name = "PLAYER_4",  color = true },
      { name = "PLAYER_5",  color = true },
      { name = "PLAYER_6",  color = true },
      { name = "PLAYER_7",  color = true },
      { name = "PLAYER_8",  color = true },
      { name = "PLAYER_9",  color = true },
      { name = "PLAYER_10", color = true },
      { name = "PLAYER_11", color = true },
      { name = "PLAYER_12", color = true },
      { name = "PLAYER_13", color = true },
      { name = "PLAYER_14", color = true },
      { name = "PLAYER_15", color = true },
      { name = "All Players", invalid = not has_mod_powers(0) },
      { name = trans("menu_back") },
      name = "playerMenu",
      back = 18,
  }

  one_player_reload()

  allPlayerMenu = {
    { name = "Pause", option = GST.pause, title = "All Players", description = trans("pause_desc") },
    { name = "Force to Spectate", option = GST.forceSpectate, description = trans("forcespectate_desc") },
    { name = trans("menu_back") },
    { name = trans("main_menu") },
    name = "allPlayerMenu",
    back = 3,
  }

  playerSettingsMenu = {
    { name = trans("hard_mode"), title = trans("menu_settings_player"), option = (gPlayerSyncTable[0].hard == 1), description = trans("hard_info_short")},
    { name = trans("extreme_mode"), option = (gPlayerSyncTable[0].hard == 2), description = trans("extreme_info_short")},
    { name = trans("menu_timer"), option = showSpeedrunTimer, invalid = (GST.mode == 2), description = "Show a timer at the bottom of the screen." },
    { name = "Team Chat", option = (gPlayerSyncTable[0].teamChat or false), description = "Chat only with your team."},
    { name = "???", option = demonOn, invalid = true, description = "This is a secret. How do you unlock it?" },
    { name = trans("menu_back") },
    name = "playerSettingsMenu",
    back = 6,
  }
  if demonOn or demonUnlocked then
    playerSettingsMenu[5].name = "Green Demon"
    playerSettingsMenu[5].description = "Have a 1up chase you as Runner."
    playerSettingsMenu[5].invalid = false
  end

  miscMenu = {
    { name = trans("free_camera"), title = trans("menu_misc"), invalid = ((not GST.allowSpectate) or (gPlayerSyncTable[0].team == 1 and GST.mhState ~= 1 and GST.mhState ~= 2)), description = "Enter Free Camera in Spectator Mode."},
    { name = "Spectate Runner", invalid = ((not GST.allowSpectate) or (gPlayerSyncTable[0].team == 1 and GST.mhState ~= 1 and GST.mhState ~= 2)), description = "Automatically spectate the first Runner."},
    { name = "Exit Spectate", invalid = (gPlayerSyncTable[0].forceSpectate or gPlayerSyncTable[0].spectator ~= 1), description = "Exit spectator mode."},
    { name = "Warp to Runner Level", invalid = ((not ROMHACK.stalk) or GST.mhMode == 2 or GST.mhState ~= 2), description = "Warp to the level the first Runner is in."},
    { name = "Skip", invalid = (GST.mhState ~= 2 or GST.mhMode ~= 2 or iVoted), description = "Vote to skip this star in MiniHunt."},
    { name = "List Blacklist", description = "Lists all blacklisted stars in MiniHunt for this server."},
    { name = trans("menu_back") },
    name = "miscMenu",
    back = 7,
  }

end

function one_player_reload()
  if focusPlayerOrCourse > (MAX_PLAYERS - 1) then focusPlayerOrCourse = 0 end
  local STP = gPlayerSyncTable[focusPlayerOrCourse]
  local GST = gGlobalSyncTable
  onePlayerMenu = {
      { name = "Flip Team", title = "PLAYER_S", invalid = not has_mod_powers(0), description = trans("flip_desc") },
      { name = "Spectate", invalid = (focusPlayerOrCourse == 0 or (not GST.allowSpectate) or (gPlayerSyncTable[0].team == 1 and GST.mhState ~= 1 and GST.mhState ~= 2)), description = "Spectate this player." },
      { name = "Warp To Level", invalid = (focusPlayerOrCourse == 0 or (not ROMHACK.stalk) or STP.team == 1 or GST.mhMode == 2 or GST.mhState ~= 2), description = "Warp to this player's level." },
      { name = "Pause", option = STP.pause, invalid = not has_mod_powers(0), description = trans("pause_desc") },
      { name = "Force to Spectate", option = STP.forceSpectate, invalid = not has_mod_powers(0), description = trans("forcespectate_desc") },
      { name = "Allow to Leave", invalid = (not has_mod_powers(0)) or (GST.mhMode == 2), description = trans("leave_desc") },
      { name = "Set Lives", invalid = (not has_mod_powers(0) or STP.team ~= 1 or GST.mhState == 0), currNum = STP.runnerLives or GST.runnerLives, maxNum = 99, description = trans("setlife_desc") },
      { name = trans("menu_back") },
      { name = trans("main_menu") },
      name = "onePlayerMenu",
      back = 8,
  }
end

function build_blacklist_menu()
  blacklistMenu = {}
  for i=1,24 do
    if ROMHACK.starCount and course_to_level and ROMHACK.starCount[course_to_level[i]] ~= 0 and (ROMHACK.hubStages == nil or ROMHACK.hubStages[i] == nil) then
      table.insert(blacklistMenu, {name = get_level_name(i, course_to_level[i], 1), course = i } )
    end
  end
  table.insert(blacklistMenu, { name = "List All Blacklisted", action = "list" } )
  table.insert(blacklistMenu, { name = "Save Blacklist", action = "save", description = "Save this blacklist on your end." } )
  table.insert(blacklistMenu, { name = "Load Blacklist", action = "load", description = "Load your saved blacklist." } )
  table.insert(blacklistMenu, { name = "Reset Blacklist", action = "reset", description = "Reset the blacklist to the default." } )
  table.insert(blacklistMenu, { name = trans("menu_back")} )
  blacklistMenu.back = #blacklistMenu
  table.insert(blacklistMenu, { name = trans("main_menu")} )
  blacklistMenu[1].title = "MiniHunt Blacklist"
  blacklistMenu.name = "blacklistMenu"
end

function build_blacklist_course_menu()
  blacklistCourseMenu = {}
  local oneValid = false
  for i=1,7 do
    if valid_star(focusPlayerOrCourse,i,true,(ROMHACK.replica_start ~= nil)) and (i ~= 7 or focusPlayerOrCourse > 15) then
      local valid = (mini_blacklist[focusPlayerOrCourse*10+i] == nil)
      table.insert(blacklistCourseMenu, { name = get_custom_star_name(focusPlayerOrCourse,i), option = valid, star = i } )
      if valid then oneValid = true end
    end
  end
  if #blacklistCourseMenu > 1 then
    table.insert(blacklistCourseMenu, { name = "Toggle All", option = oneValid, star = "all" } )
  end
  table.insert(blacklistCourseMenu, { name = trans("menu_back")} )
  blacklistCourseMenu.back = #blacklistCourseMenu
  table.insert(blacklistCourseMenu, { name = trans("main_menu")} )
  blacklistCourseMenu[1].title = get_level_name(focusPlayerOrCourse,course_to_level[focusPlayerOrCourse],1)
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
    bottomOption = 0
end

function close_menu()
    -- doesn't have to be a function but just in case you want to add something here.
    menu_enter()
    play_sound(SOUND_GENERAL_PAINTING_EJECT, gMarioStates[0].marioObj.header.gfx.cameraToObject)
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
          [3] = function() show_rules() end,
          [4] = function() menu_enter(LanguageMenu) end,
          [5] = function() menu_enter(miscMenu) end,
          [6] = function() menu_enter(playerMenu) end,
          [7] = function() showingStats = true end,
          [8] = close_menu,
      },
      marioHuntMenu = {
          [1] = function() if gGlobalSyncTable.mhMode ~= 2 then menu_enter(startMenu) else menu_enter(startMenuMini) end end,
          [2] = function(option) runner_randomize(tostring(option.currNum)) end,
          [3] = function(option) add_runner(tostring(option.currNum)) end,
          [4] = function(option) runner_lives(tostring(option.currNum)) end,
          [5] = function(option) menu_enter(settingsMenu) end,
          [6] = function() halt_command() close_menu() end,
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
      playerMenu = {
          [1] = function() focusPlayerOrCourse = 0 menu_enter(onePlayerMenu) end,
          [2] = function() focusPlayerOrCourse = 1 menu_enter(onePlayerMenu) end,
          [3] = function() focusPlayerOrCourse = 2 menu_enter(onePlayerMenu) end,
          [4] = function() focusPlayerOrCourse = 3 menu_enter(onePlayerMenu) end,
          [5] = function() focusPlayerOrCourse = 4 menu_enter(onePlayerMenu) end,
          [6] = function() focusPlayerOrCourse = 5 menu_enter(onePlayerMenu) end,
          [7] = function() focusPlayerOrCourse = 6 menu_enter(onePlayerMenu) end,
          [8] = function() focusPlayerOrCourse = 7 menu_enter(onePlayerMenu) end,
          [9] = function() focusPlayerOrCourse = 8 menu_enter(onePlayerMenu) end,
          [10] = function() focusPlayerOrCourse = 9 menu_enter(onePlayerMenu) end,
          [11] = function() focusPlayerOrCourse = 10 menu_enter(onePlayerMenu) end,
          [12] = function() focusPlayerOrCourse = 11 menu_enter(onePlayerMenu) end,
          [13] = function() focusPlayerOrCourse = 12 menu_enter(onePlayerMenu) end,
          [14] = function() focusPlayerOrCourse = 13 menu_enter(onePlayerMenu) end,
          [15] = function() focusPlayerOrCourse = 14 menu_enter(onePlayerMenu) end,
          [16] = function() focusPlayerOrCourse = 15 menu_enter(onePlayerMenu) end,
          [17] = function() menu_enter(allPlayerMenu) end,
          [18] = function() focusPlayerOrCourse = 0 menu_enter(nil, 6) end,
      },
      -- language is a special case
      settingsMenu = {
          [1] = function(option)
              change_game_mode("",option.currNum)
              menu_reload()
              menu_enter(settingsMenu, currentOption)
          end,
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
              star_mode_command("",option.option)
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
                djui_chat_message_create(string.format("%s (%d %s)",trans("auto_on"),gGlobalSyncTable.gameAuto,runners))
                if gGlobalSyncTable.mhState == 0 then
                  gGlobalSyncTable.mhTimer = 20 * 30 -- 20 seconds
                end
              end
          end,
          [9] = function()
              menu_enter(blacklistMenu)
          end,
          [10] = function()
              default_settings()
              menu_reload()
              menu_enter(settingsMenu, currentOption)
          end,
          [11] = function() menu_enter(marioHuntMenu,5) end,
          [12] = function() menu_enter() end,
      },
      onePlayerMenu = {
          [1] = function() change_team_command(focusPlayerOrCourse) end,
          [2] = function() spectate_command(focusPlayerOrCourse) end,
          [3] = function() stalk_command(focusPlayerOrCourse) end,
          [4] = function(option) option.option = not option.option pause_command(focusPlayerOrCourse) end,
          [5] = function(option) option.option = not option.option force_spectate_command(focusPlayerOrCourse) end,
          [6] = function() allow_leave_command(focusPlayerOrCourse) end,
          [7] = function(option) set_life_command(focusPlayerOrCourse.." "..option.currNum) end,
          [8] = function() menu_enter(playerMenu, focusPlayerOrCourse + 1) end,
          [9] = function() menu_enter(nil, 6) end,
      },
      allPlayerMenu = {
          [1] = function(option) option.option = not option.option pause_command("all") end,
          [2] = function(option) option.option = not option.option force_spectate_command("all") end,
          [3] = function() menu_enter(playerMenu, 17) end,
          [4] = function() menu_enter(nil, 6) end,
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
            mod_storage_save_fix_bug("showSpeedrunTimer",tostring(option.option))
          end,
          [4] = function(option)
            option.option = not option.option
            gPlayerSyncTable[0].teamChat = option.option
            if option.option then
              djui_chat_message_create(trans("tc_on"))
            else
              djui_chat_message_create(trans("tc_off"))
            end
          end,
          [5] = function(option)
            option.option = not option.option
            demonOn = option.option
          end,
          [6] = function() menu_enter(nil, 2) end,
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
          [3] = function(option) spectate_command("off") option.invalid = true end,
          [4] = function() stalk_command("") end,
          [5] = function() skip_command("") close_menu() end,
          [6] = function() blacklist_command("list") end,
          [7] = function() menu_enter(nil, 5) end,
      }
      -- blacklistMenu is another special case
      -- same for the course menu
  }
end

-- Variables to keep track of frame cooldown
local frameDelay = 0
local delayFrames = 5

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
        menu_reload()
        menu_enter(LanguageMenu, currentOption)
      else -- back
        menu_enter(nil, 4)
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
        menu_enter(settingsMenu, 9)
      else
        menu_enter()
      end
    elseif currentMenuName == "blacklistCourseMenu" then
      if currMenu.back == option then
        menu_enter(blacklistMenu, prevOption)
      elseif currMenu[option].star == "all" then
        currMenu[option].option = not currMenu[option].option
        if currMenu[option].option then
          blacklist_command("remove "..focusPlayerOrCourse)
        else
          blacklist_command("add "..focusPlayerOrCourse)
        end
        menu_enter(blacklistCourseMenu, option)
      elseif currMenu[option].star then
        currMenu[option].option = not currMenu[option].option
        if currMenu[option].option then
          blacklist_command("remove "..focusPlayerOrCourse.." "..currMenu[option].star)
        else
          blacklist_command("add "..focusPlayerOrCourse.." "..currMenu[option].star)
        end
        menu_enter(blacklistCourseMenu, option)
      else
        menu_enter()
      end
    elseif menuActions[currentMenuName] then
      local action = menuActions[currentMenuName][option]
      if action then
          action(currMenu[option])
      end
    end
end

-- Function to handle menu input
function handleMenu()
    if (not menu) or showingStats then
        return
    end

    djui_hud_set_render_behind_hud(false)
    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_font(FONT_HUD)
    local screenWidth = djui_hud_get_screen_width()
    local screenHeight = djui_hud_get_screen_height()
    djui_hud_set_color(255, 255, 255, 255)

    djui_hud_set_color(0, 0, 0, 200)
    djui_hud_render_rect(screenWidth*0.1, 0, screenWidth*0.8, screenHeight)

    local maxTextWidth = 0
    local textScale = 0.5

    for i, option in ipairs(currMenu) do
        local optionText = option.name

        local textWidth = 0
        if option.name:sub(1,7) == "PLAYER_" then
          textWidth = screenWidth*0.4
        elseif option.color then
          textWidth = djui_hud_measure_text(remove_color(optionText)) * textScale
        else
          textWidth = djui_hud_measure_text(optionText) * textScale
        end
        maxTextWidth = math.max(maxTextWidth, textWidth)
    end
    maxTextWidth = maxTextWidth + 30

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
    local titleScale = 1.5

    local titleText = tostring(currMenu[1].title)
    local titleCenter = 0
    djui_hud_set_color(255, 255, 255, 255)
    if titleText == "PLAYER_S" then
      djui_hud_set_font(FONT_NORMAL) -- extended hud font doesn't support every character that can be in a username yet
      local index = focusPlayerOrCourse
      local np = gNetworkPlayers[focusPlayerOrCourse]
      if np and np.connected then
        local playerColor = network_get_player_text_color_string(focusPlayerOrCourse)
        titleText = playerColor .. np.name
        --titleText = remove_color(np.name)
      else
        menu_enter(playerMenu, focusPlayerOrCourse + 1)
      end

      titleScale = 1
      titleCenter = (screenWidth - djui_hud_measure_text(remove_color(titleText)) * titleScale) * 0.5
      --titleCenter = (screenWidth - djui_hud_measure_text(titleText) * titleScale) * 0.5

      djui_hud_print_text_with_color(titleText, titleCenter, 0, titleScale)
      --print_text_ex_hud_font(titleText, titleCenter, screenHeight * 0.03, titleScale)
    else
      if djui_hud_measure_text(titleText) * titleScale > screenWidth*0.8 then -- shrink the title if it's too big
        titleScale = 1
      end

      titleCenter = (screenWidth - djui_hud_measure_text(titleText) * titleScale) * 0.5
      print_text_ex_hud_font(titleText, titleCenter, screenHeight * 0.03, titleScale)
    end
    djui_hud_set_font(FONT_HUD)

    for i, option in ipairs(currMenu) do
        local render = true
        if i > bottomOption then
          djui_hud_set_color(255, 255, 255, 255)
          djui_hud_render_texture(get_texture_info("menu-arrow-vert"), screenWidth / 2 + 8, screenHeight - 15, -1.5, -1.5)
          break
        elseif i <= (bottomOption - optionCount) then
          djui_hud_set_color(255, 255, 255, 255)
          djui_hud_render_texture(get_texture_info("menu-arrow-vert"), screenWidth / 2 - 6, screenHeight * 0.13, 1.5, 1.5)
          render = false
        end

        if render then

          local textColor = {255, 255, 255, 255} -- Default text color

          if option.option ~= nil then
              if option.option then
                  textColor = {92, 255, 92, 255} -- Green text color
              else
                  textColor = {255, 92, 92, 255} -- Red text color
              end
          end

          djui_hud_set_font(FONT_NORMAL)
          local optionText = option.name
          local roleText = nil
          if option.name:sub(1,7) == "PLAYER_" then
            local index = tonumber(option.name:sub(8)) or 0
            local np = gNetworkPlayers[index]
            if np and np.connected then
              local playerColor = network_get_player_text_color_string(index)
              local sMario = gPlayerSyncTable[index]
              local roleName,colorString = get_role_name_and_color(sMario)
              roleText = colorString..roleName
              optionText = playerColor .. np.name
            else
              roleText = ""
              optionText = trans("empty",index)
            end
          end

          local textWidth = 0
          if option.color then
            textWidth = djui_hud_measure_text(remove_color(optionText)) * textScale
          else
            textWidth = djui_hud_measure_text(optionText) * textScale
          end
          local textX = (screenWidth - textWidth) * 0.5

          if roleText ~= nil then textX = screenWidth * 0.2 end

          if option.currNum ~= nil then textX = textX - 25 end

          if roleText == "" then
            option.invalid = true
          elseif roleText ~= nil then
            option.invalid = false
          end

          -- special case for course menu
          if option.course then
            local allValid = true
            local oneValid = false
            for i=1,7 do
              if (i ~= 7 or option.course > 15) and valid_star(option.course,i,true,(ROMHACK.replica_start ~= nil)) then
                if mini_blacklist[option.course*10+i] == nil then
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
              textColor = {92, 255, 92, 255} -- Green text color
            elseif oneValid then
              textColor = {255, 255, 92, 255} -- Yellow text color
            else
              textColor = {255, 92, 92, 255} -- Red text color
            end
          end

          -- darken unselectable options
          if option.invalid then
            textColor[4] = 100 -- set alpha to 100
          end
          djui_hud_set_color(table.unpack(textColor))

          if option.color and not option.invalid then
            djui_hud_print_text_with_color(optionText, textX, optionY, textScale)
          else
            djui_hud_print_text(optionText, textX, optionY, textScale)
          end
          if roleText ~= nil then
            textX = screenWidth * 0.8 - djui_hud_measure_text(remove_color(roleText)) * textScale
            djui_hud_print_text_with_color(roleText, textX, optionY, textScale)
          end

          djui_hud_set_font(FONT_HUD)

          if option.currNum ~= nil then
              local optString = tostring(option.currNum)
              if option.currNum == -1 then optString = "any" end
              djui_hud_print_text(optString, textX + textWidth + 25, optionY, 1)
              djui_hud_render_texture(get_texture_info("menu-arrow"), textX + textWidth + 25 - 13,
                  optionY + 2, 1.5, 1.5)
          end

          optionY = optionY + (screenHeight * 0.2) * textScale

          if i == currentOption then
              local rectX = optionX - maxTextWidth * 0.2
              local rectY = optionY - screenHeight * 0.1
              local rectWidth = maxTextWidth * 1.4
              local rectHeight = screenHeight * 0.07
              djui_hud_set_color(92, 255, 92, math.abs((frameCounter%60)-30)*2)
              djui_hud_render_rect(rectX, rectY, rectWidth, rectHeight)
              djui_hud_set_color(255, 255, 255, 255)

              if currMenu[currentOption].description then
                djui_hud_set_font(FONT_NORMAL)
                djui_hud_set_color(255, 255, 255, 255)
                local desc = (tostring(currMenu[currentOption].description))
                local descWidth = djui_hud_measure_text(desc) * 0.3
                local descX = (screenWidth - descWidth) * 0.5
                djui_hud_print_text(desc, descX, screenHeight - 15, 0.3)
              end
          end

        end
    end
end

-- stat table stuff; this part is my code
showingStats = false -- showing the stats table
local statDesc = 1 -- which stat we're looking at the description for
local sortBy = 0 -- what we're sorting by. 0 is none, and negative is descending
function stats_table_hud()
  local text = ""

  local scale = 0.3
  local screenWidth = djui_hud_get_screen_width()
  local screenHeight = djui_hud_get_screen_height()
  local width = 0
  local x = 0
  local y = 60
  djui_hud_set_color(0, 0, 0, 200);
  djui_hud_render_rect(screenWidth*0.1, 0, screenWidth*0.8, screenHeight);
  local statOrder = {"wins","hardWins","exWins","kills","maxStreak","maxStar","placement"}
  local descOrder = {"stat_wins","stat_wins_hard","stat_wins_ex","stat_kills","stat_combo","stat_mini_stars","stat_placement"}

  djui_hud_set_font(FONT_HUD)
  text = trans("menu_stats")
  width = djui_hud_measure_text(text)
  x = (screenWidth-width) / 2
  djui_hud_set_color(255, 255, 255, 255);
  djui_hud_print_text(text, x, 10, 1);
  djui_hud_set_font(FONT_NORMAL)

  text = trans("player")
  width = djui_hud_measure_text(text)*scale
  x = screenWidth*0.1+50-width/2
  djui_hud_print_text(text, x, y - 64 * scale, scale);

  x = screenWidth*0.1+110
  space = (screenWidth*0.8-140)/(#statOrder-1)
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
    x = screenWidth*0.1+50-width/2
    djui_hud_print_text_with_color(text, x, y, scale)
    djui_hud_set_color(255, 255, 255, 255)

    x = screenWidth*0.1+110
    space = (screenWidth*0.8-140)/(#statOrder-1)
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
  x = (screenWidth - width) * 0.5
  y = screenHeight - 32 * scale

  djui_hud_set_color(255, 255, 255, 255);
  djui_hud_print_text(text, x, y, scale);
end

-- menu controls
function menu_controls(m)
  ranMenuThisFrame = true
  if m.playerIndex ~= 0 then return end

  if (menu or showingStats) and (m.controller.buttonPressed & START_BUTTON) ~= 0 then
    close_menu()
    m.controller.buttonPressed = m.controller.buttonPressed - START_BUTTON
  elseif not menu and (m.controller.buttonDown & L_TRIG) ~= 0 and (m.controller.buttonPressed & START_BUTTON) ~= 0 and not is_game_paused() then
    m.controller.buttonPressed = m.controller.buttonPressed - START_BUTTON
    menu_reload()
    menu = true
    menu_enter()
  elseif showingStats then -- stats table controls
    if m.freeze < 1 then m.freeze = 1 end

    local joystickX = m.controller.stickX
    if (m.controller.buttonDown & L_JPAD) ~= 0 then
      joystickX = joystickX - JOYSTICK_THRESHOLD
    end
    if (m.controller.buttonDown & R_JPAD) ~= 0 then
      joystickX = joystickX + JOYSTICK_THRESHOLD
    end

    if joystickX <= -JOYSTICK_THRESHOLD and frameDelay == 0 then
      statDesc = (statDesc + #stat_icon_data - 2) % (#stat_icon_data) + 1
      play_sound(SOUND_MENU_CHANGE_SELECT, gMarioStates[0].marioObj.header.gfx.cameraToObject)
      frameDelay = delayFrames
    end
    if joystickX >= JOYSTICK_THRESHOLD and frameDelay == 0 then
      statDesc = (statDesc + #stat_icon_data) % (#stat_icon_data) + 1
      play_sound(SOUND_MENU_CHANGE_SELECT, gMarioStates[0].marioObj.header.gfx.cameraToObject)
      frameDelay = delayFrames
    end
    if (m.controller.buttonPressed & A_BUTTON) ~= 0 then
      play_sound(SOUND_MENU_CLICK_FILE_SELECT, gMarioStates[0].marioObj.header.gfx.cameraToObject)
      if sortBy == statDesc then
        sortBy = -statDesc
      elseif sortBy == -statDesc then
        sortBy = 0
      else
        sortBy = statDesc
      end
    elseif (m.controller.buttonPressed & B_BUTTON) ~= 0 then
      showingStats = false
      if menu then
        menu_enter(nil, 7)
        m.controller.buttonPressed = m.controller.buttonPressed - B_BUTTON
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gMarioStates[0].marioObj.header.gfx.cameraToObject)
      else
        play_sound(SOUND_GENERAL_PAINTING_EJECT, gMarioStates[0].marioObj.header.gfx.cameraToObject)
      end
    end
  elseif menu then
    if m.freeze < 1 then m.freeze = 1 end

    local joystickX = m.controller.stickX
    local joystickY = m.controller.stickY
    if (m.controller.buttonDown & L_JPAD) ~= 0 then
      joystickX = joystickX - JOYSTICK_THRESHOLD
    end
    if (m.controller.buttonDown & R_JPAD) ~= 0 then
      joystickX = joystickX + JOYSTICK_THRESHOLD
    end
    if (m.controller.buttonDown & D_JPAD) ~= 0 then
      joystickY = joystickY - JOYSTICK_THRESHOLD
    end
    if (m.controller.buttonDown & U_JPAD) ~= 0 then
      joystickY = joystickY + JOYSTICK_THRESHOLD
    end

    if frameDelay == 0 then
        if joystickY >= JOYSTICK_THRESHOLD then
            currentOption = (currentOption - 2 + #currMenu) % #currMenu + 1
            play_sound(SOUND_MENU_CHANGE_SELECT, gMarioStates[0].marioObj.header.gfx.cameraToObject)
            frameDelay = delayFrames
        elseif joystickY <= -JOYSTICK_THRESHOLD then
            currentOption = currentOption % #currMenu + 1
            play_sound(SOUND_MENU_CHANGE_SELECT, gMarioStates[0].marioObj.header.gfx.cameraToObject)
            frameDelay = delayFrames
        end

        local option = currMenu[currentOption]
        local min = option.minNum or 0
        local countBy = 1
        if m.controller.buttonDown & X_BUTTON ~= 0 then countBy = 10 end
        if joystickX <= -JOYSTICK_THRESHOLD and option.currNum then
            option.currNum = (option.currNum - countBy - min) % (option.maxNum + 1 - min) + min
            if option.currNum < min then
                option.currNum = option.maxNum
            end
            play_sound(SOUND_MENU_CHANGE_SELECT, gMarioStates[0].marioObj.header.gfx.cameraToObject)
            frameDelay = delayFrames
        elseif joystickX >= JOYSTICK_THRESHOLD and option.currNum then
            option.currNum = (option.currNum + countBy - min) % (option.maxNum + 1 - min) + min
            if option.currNum > option.maxNum then
                option.currNum = min
            end
            play_sound(SOUND_MENU_CHANGE_SELECT, gMarioStates[0].marioObj.header.gfx.cameraToObject)
            frameDelay = delayFrames
        end
    end

    local option = currMenu[currentOption]
    if m.controller.buttonPressed & A_BUTTON ~= 0 then
        if option.invalid then
          play_sound(SOUND_MENU_CAMERA_BUZZ, gMarioStates[0].marioObj.header.gfx.cameraToObject)
        else
          play_sound(SOUND_MENU_CLICK_FILE_SELECT, gMarioStates[0].marioObj.header.gfx.cameraToObject)
          selectOption(currentOption)
        end
    elseif m.controller.buttonPressed & B_BUTTON ~= 0 and currMenu.back then
        play_sound(SOUND_MENU_CLICK_FILE_SELECT, gMarioStates[0].marioObj.header.gfx.cameraToObject)
        selectOption(currMenu.back)
    end
  end

  if frameDelay > 0 then frameDelay = frameDelay - 1 end
end

-- custom text function that allows the HUD font to support more characters
-- TODO: a bunch of these characters are actually the wrong ones (potentially 26-38?)
local extra_chars = {
  ["ü"] = "font_00", ["Ü"] = "font_00", -- string_lower doesn't work for these, so we need both
  ["q"] = "font_01",
  ["v"] = "font_02",
  ["x"] = "font_03",
  ["z"] = "font_04",
  ["ä"] = "font_05", ["Ä"] = "font_05",
  ["ö"] = "font_06", ["Ö"] = "font_06",
  ["?"] = "font_07",
  ["."] = "font_08",
  ["á"] = "font_09", ["Á"] = "font_09",
  ["é"] = "font_10", ["É"] = "font_10",
  ["í"] = "font_11", ["Í"] = "font_11",
  ["ó"] = "font_12", ["Ó"] = "font_12",
  ["ú"] = "font_13", ["Ú"] = "font_13",
  ["à"] = "font_14", ["À"] = "font_14",
  ["è"] = "font_15", ["È"] = "font_15",
  ["ì"] = "font_16", ["Ì"] = "font_16",
  ["ò"] = "font_17", ["Ò"] = "font_17",
  ["ù"] = "font_18", ["Ù"] = "font_18",
  ["ë"] = "font_19", ["Ë"] = "font_19",
  ["ï"] = "font_20", ["Ï"] = "font_20",
  ["â"] = "font_21", ["Â"] = "font_21",
  ["ê"] = "font_22", ["Ê"] = "font_22",
  ["î"] = "font_23", ["Î"] = "font_23",
  ["ô"] = "font_24", ["Ô"] = "font_24",
  ["û"] = "font_25", ["Û"] = "font_25",
  ["å"] = "font_26", ["Å"] = "font_26",
  ["e̊"] = "font_27", ["̊E̊"] = "font_27",
  ["i̊"] = "font_28", ["I̊"] = "font_28",
  ["o̊"] = "font_29", ["O̊"] = "font_29",
  ["ů"] = "font_30", ["Ů"] = "font_30",
  ["ã"] = "font_31", ["Ã"] = "font_31",
  ["ẽ"] = "font_32", ["Ẽ"] = "font_32",
  ["ĩ"] = "font_33", ["Ĩ"] = "font_33",
  ["õ"] = "font_34", ["Õ"] = "font_34",
  ["ũ"] = "font_35", ["Ũ"] = "font_35",
  ["ñ"] = "font_36", ["Ñ"] = "font_36",
  ["ě"] = "font_37", ["Ě"] = "font_37",
  ["ç"] = "font_38", ["Ç"] = "font_38",
  ["!"] = "font_39",
  ["_"] = "font_40",
  ["-"] = "font_41",
  [","] = "font_42",
}
function print_text_ex_hud_font(text, x, y, scale)
  djui_hud_set_font(FONT_HUD)
  local space = 0
  local render = ""
  local charSkip = false
  for i=1,string.len(text) do
    if charSkip then
      charSkip = false
    else
      local char = text:sub(i,i)
      if string.byte(text, i) > 122 then -- accent characters are actually two characters
        char = text:sub(i,i+1)
        charSkip = true
      end
      --djui_chat_message_create(char)
      local tex = extra_chars[string_lower(char)]
      if tex ~= nil then
        djui_hud_print_text(render, x+space, y, scale);
        space = space + djui_hud_measure_text(render) * scale
        djui_hud_render_texture(get_texture_info(tex), x+space, y-(3*scale), scale, scale)
        space = space + djui_hud_measure_text(char) * scale
        render = ""
      else
        render = render .. char
      end
    end
  end
  djui_hud_print_text(render, x+space, y, scale);
end

hook_event(HOOK_ON_HUD_RENDER, handleMenu)
hook_event(HOOK_BEFORE_MARIO_UPDATE, menu_controls)
hook_event(HOOK_UPDATE, function()
  if gPlayerSyncTable[0].pause and ranMenuThisFrame == false then
    menu_controls(gMarioStates[0])
  end
  ranMenuThisFrame = false
end)
