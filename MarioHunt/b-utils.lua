-- localize some functions
local djui_chat_message_create,warp_to_level,warp_to_warpnode,tonumber,string_lower,mod_storage_save,mod_storage_load = djui_chat_message_create,warp_to_level,warp_to_warpnode,tonumber,string.lower,mod_storage_save_fix_bug,mod_storage_load

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
    if gGlobalSyncTable.mhMode == 2 then
      gGlobalSyncTable.gameLevel = level
      gGlobalSyncTable.getStar = act
    end
    return true
  end
  local args = split(msg, " ")
  local level = tonumber(args[1])
  if string.sub(args[1],1,1) == "c" then
    level = course_to_level[tonumber(string.sub(args[1],2))]
  end
  if level == nil then
    level = string_to_level[args[1]] or 16
  end
  local area = tonumber(args[2]) or 1
  local act = tonumber(args[3]) or 0
  local node = tonumber(args[4])
  if node == nil then
    djui_chat_message_create("Warping to level "..level.." area "..area.." act "..act)
    if warp_to_level(level, area, act) then
      if gGlobalSyncTable.mhMode == 2 then
        gGlobalSyncTable.gameLevel = level
        gGlobalSyncTable.getStar = act
      end
    else
      djui_chat_message_create("Warp failed!")
    end
  else
    djui_chat_message_create("Warping to level "..level.." area "..area.." act "..act.." node "..node)
    if warp_to_warpnode(level, area, act, node) then
      if gGlobalSyncTable.mhMode == 2 then
        gGlobalSyncTable.gameLevel = level
        gGlobalSyncTable.getStar = act
      end
    else
      djui_chat_message_create("Warp failed!")
    end
  end
  return true
end

function quick_debug(msg)
  local sMario = gPlayerSyncTable[0]
  become_runner(sMario)
  start_game("continue")
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
  on_packet_kill_combo({
    id = PACKET_KILL_COMBO,
    name = playerColor .. np.name,
    kills = tonumber(msg) or 0,
  }, true)
  return true
end

function get_field(msg)
  for i=0,(MAX_PLAYERS-1) do
    local sMario = gPlayerSyncTable[i]
    local np = gNetworkPlayers[i]
    if np.connected then
      print(np.name..": ",(tostring(sMario[msg])))
      djui_chat_message_create(np.name..": "..(tostring(sMario[msg])))
    end
  end
  return true
end

function get_field_global(msg)
  print(tostring(gGlobalSyncTable[msg]))
  djui_chat_message_create(tostring(gGlobalSyncTable[msg]))
  return true
end

function get_all_stars(msg)
  local valid_star_table = generate_star_table(tonumber(msg),(msg ~= "mini"),(msg=="replica"))
  print("")
  for i,star in ipairs(valid_star_table) do
    local act = star % 10
    local course = star // 10
    local starString = string.format("%s - %s (%d) (ID: %d)",get_level_name(course, course_to_level[course], 1),get_custom_star_name(course,act),act,star)
    djui_chat_message_create(starString)
    print(string.format("%-31s%-31s%-5s%-5s",get_level_name(course, course_to_level[course], 1),get_custom_star_name(course,act),act,star))
  end
  djui_chat_message_create(#valid_star_table.." stars total")
  print("")
  print(#valid_star_table,"stars total")
  return true
end

function star_mode_command(msg,bool)
  if gGlobalSyncTable.mhMode == 2 then
    djui_chat_message_create(trans("wrong_mode"))
    return true
  end
  if bool == true or string_lower(msg) == "on" then
    gGlobalSyncTable.starMode = true
    gGlobalSyncTable.runTime = 2
    djui_chat_message_create(trans("using_stars"))
    return true
  elseif bool == false or string_lower(msg) == "off" then
    gGlobalSyncTable.starMode = false
    gGlobalSyncTable.runTime = 7200
    djui_chat_message_create(trans("using_timer"))
    return true
  end
  return false
end

function allow_spectate_command(msg)
  if string_lower(msg) == "on" then
    gGlobalSyncTable.allowSpectate = true
    djui_chat_message_create(trans("can_spectate"))
    return true
  elseif string_lower(msg) == "off" then
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
        become_hunter(gPlayerSyncTable[i])
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
    become_hunter(sMario)
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
  gGlobalSyncTable.mhTimer = 20 * 30 -- 20 seconds
  return true
end

-- TroopaParaKoopa's metal command
function metal_command(msg)
  if string_lower(msg) == "on" then
      gGlobalSyncTable.metal = true
      djui_chat_message_create(trans("now_metal"))
      return true
  end
  if string_lower(msg) == "off" then
      gGlobalSyncTable.metal = false
      djui_chat_message_create(trans("not_metal"))
      return true
  end
end

function weak_command(msg)
  if string_lower(msg) == "on" then
      gGlobalSyncTable.weak = true
      djui_chat_message_create(trans("now_weak"))
      return true
  end
  if string_lower(msg) == "off" then
      gGlobalSyncTable.weak = false
      djui_chat_message_create(trans("not_weak"))
      return true
  end
end

-- handles the blacklist
dontReload = false -- if we just changed the blacklist, don't reload the table because it's updated for us
function blacklist_command(msg)
  local args = split(msg, " ")
  if args[1] == nil then return false end
  local action = string_lower(args[1])
  if action == "list" then
    djui_chat_message_create(trans("blacklist_list"))
    for id,value in pairs(mini_blacklist) do
      local course = id // 10
      local act = id % 10
      if not valid_star(course, act, false, (ROMHACK.replica_start ~= nil)) then
        local starString = string.format("%s - %s (Course %d, Star %d)",get_level_name(course, course_to_level[course], 1),get_custom_star_name(course,act),course,act)
        djui_chat_message_create(starString)
      end
    end
  elseif action == "add" then
    local stringCourse = ""
    if args[2] ~= nil then stringCourse = string_lower(args[2]) end
    local course = tonumber(args[2]) or string_to_course[stringCourse]
    local act = tonumber(args[3])
    if course == nil then return false end
    if course < 1 or course > 24 then return false end

    if act ~= nil then
      if act < 1 or act > 7 then
        return false
      elseif not valid_star(course, act, false, (ROMHACK.replica_start ~= nil)) then
        djui_chat_message_create(trans("blacklist_add_already"))
        return true
      end
      local starID = course*10+act
      mini_blacklist[starID] = 1
    else
      local allblacklist = true
      for act=1,7 do
        if valid_star(course, act, false, (ROMHACK.replica_start ~= nil)) then
          local starID = course*10+act
          mini_blacklist[starID] = 1
          allblacklist = false
        end
      end
      if allblacklist then
        djui_chat_message_create(trans("blacklist_add_already"))
        return true
      end
    end
    dontReload = true
    gGlobalSyncTable.blacklistData = encrypt_black()

    local starString = ""
    if act ~= nil then
      starString = string.format("%s - %s (Course %d, Star %d)",get_level_name(course, course_to_level[course], 1),get_custom_star_name(course,act),course,act)
    else
      starString = string.format("%s (Course %d)",get_level_name(course, course_to_level[course], 1), course)
    end
    djui_chat_message_create(trans("blacklist_add",starString))
  elseif action == "remove" then
    local stringCourse = ""
    if args[2] ~= nil then stringCourse = string_lower(args[2]) end
    local course = tonumber(args[2]) or string_to_course[stringCourse]
    local act = tonumber(args[3])
    if course == nil then return false end
    if course < 1 or course > 24 then return false end

    if act ~= nil then
      local starID = course*10+act
      if act < 1 or act > 7 then
        return false
      elseif valid_star(course, act, false, (ROMHACK.replica_start ~= nil)) then
        djui_chat_message_create(trans("blacklist_remove_already"))
        return true
      elseif mini_blacklist[starID] == nil then
        djui_chat_message_create(trans("blacklist_remove_invalid"))
        return true
      end
      mini_blacklist[starID] = nil
    else
      local allwhitelist = true
      local invalid = true
      for act=1,7 do
        local starID = course*10+act
        local valid = valid_star(course, act, false, (ROMHACK.replica_start ~= nil))
        if (not valid) and mini_blacklist[starID] ~= nil then
          mini_blacklist[starID] = nil
          allwhitelist = false
          invalid = false
        elseif valid then
          invalid = false
        end
      end
      if invalid then
        djui_chat_message_create(trans("blacklist_remove_invalid"))
        return true
      elseif allwhitelist then
        djui_chat_message_create(trans("blacklist_remove_already"))
        return true
      end
    end
    dontReload = true
    gGlobalSyncTable.blacklistData = encrypt_black()

    local starString = ""
    if act ~= nil then
      starString = string.format("%s - %s (Course %d, Star %d)",get_level_name(course, course_to_level[course], 1),get_custom_star_name(course,act),course,act)
    else
      starString = string.format("%s (Course %d)",get_level_name(course, course_to_level[course], 1), course)
    end
    djui_chat_message_create(trans("blacklist_remove",starString))
  elseif action == "reset" then
    -- we actually want to reload on our end here
    gGlobalSyncTable.blacklistData = "none"
    djui_chat_message_create(trans("blacklist_reset"))
  elseif action == "save" then
    -- (TODO: This breaks for some reason when resetting?)
    local fileName = string.gsub(gGlobalSyncTable.romhackFile," ","_")
    if gGlobalSyncTable.blacklistData ~= "none" then
      mod_storage_save(fileName.."_black",gGlobalSyncTable.blacklistData)
    else
      mod_storage_save(fileName.."_black","none")
    end
    djui_chat_message_create("Blacklist saved!")
  elseif action == "load" then
    local fileName = string.gsub(gGlobalSyncTable.romhackFile," ","_")
    local option = mod_storage_load(fileName.."_black") or "none"
    gGlobalSyncTable.blacklistData = option
    djui_chat_message_create("Blacklist loaded!")
  else
    return false
  end

  return true
end

function rom_hack_command(msg)
  gGlobalSyncTable.romhackFile = msg
  return true
end

-- main command
hook_chat_command("mh", "[COMMAND,ARGS] - Runs commands; type nothing or \"menu\" to open the menu", mario_hunt_command)
function setup_commands()
  -- commands for main command
  marioHuntCommands = {}
  -- format is: command, alias, function, debug
  table.insert(marioHuntCommands, {"start", nil, start_game})
  table.insert(marioHuntCommands, {"add", "addrunner", add_runner})
  table.insert(marioHuntCommands, {"random", "randomize", runner_randomize})
  table.insert(marioHuntCommands, {"lives", "runnerlives", runner_lives})
  table.insert(marioHuntCommands, {"time", "timeneeded", time_needed_command})
  table.insert(marioHuntCommands, {"stars", "starsneeded", stars_needed_command})
  table.insert(marioHuntCommands, {"category", "starrun", star_count_command})
  table.insert(marioHuntCommands, {"flip", "changeteam", change_team_command})
  table.insert(marioHuntCommands, {"setlife", nil, set_life_command})
  table.insert(marioHuntCommands, {"leave", "allowleave", allow_leave_command})
  table.insert(marioHuntCommands, {"mode", nil, change_game_mode})
  table.insert(marioHuntCommands, {"starmode", nil, star_mode_command})
  table.insert(marioHuntCommands, {"spectator", nil, allow_spectate_command})
  table.insert(marioHuntCommands, {"pause", "freeze", pause_command})
  table.insert(marioHuntCommands, {"metal", "seeker", metal_command})
  table.insert(marioHuntCommands, {"hack", "romhack", rom_hack_command})
  table.insert(marioHuntCommands, {"weak", nil, weak_command})
  table.insert(marioHuntCommands, {"auto", nil, auto_command})
  table.insert(marioHuntCommands, {"forcespectate", nil, force_spectate_command})
  table.insert(marioHuntCommands, {"desync", "fixdesync", desync_fix_command})
  table.insert(marioHuntCommands, {"stop", "halt", halt_command})
  table.insert(marioHuntCommands, {"default", nil, default_settings})
  table.insert(marioHuntCommands, {"blacklist", "black", blacklist_command})

  -- debug
  table.insert(marioHuntCommands, {"print", nil, print, true})
  table.insert(marioHuntCommands, {"warp", nil, do_warp, true})
  table.insert(marioHuntCommands, {"quick", nil, quick_debug, true})
  table.insert(marioHuntCommands, {"combo", nil, combo_debug, true})
  table.insert(marioHuntCommands, {"field", nil, get_field,true})
  table.insert(marioHuntCommands, {"allstars", nil, get_all_stars, true})
  table.insert(marioHuntCommands, {"langtest", nil, lang_test, true})
  table.insert(marioHuntCommands, {"unmod", nil, unmod, true})
  table.insert(marioHuntCommands, {"gfield", nil, get_field_global, true})
  table.insert(marioHuntCommands, {"hidehud", nil, (function() mhHideHud = not mhHideHud return true end), true})
  table.insert(marioHuntCommands, {"debug-move", nil, (function() gMarioStates[0].action = ACT_DEBUG_FREE_MOVE return true end), true})
  table.insert(marioHuntCommands, {"wing-cap", nil, (function() gMarioStates[0].flags = gMarioStates[0].flags | MARIO_WING_CAP play_sound(SOUND_GENERAL_SHORT_STAR, gMarioStates[0].marioObj.header.gfx.cameraToObject) play_cap_music(SEQ_EVENT_POWERUP) play_character_sound(gMarioStates[0], CHAR_SOUND_HERE_WE_GO) return true end), true})
  table.insert(marioHuntCommands, {"set-fov", nil, (function(msg) set_override_fov(tonumber(msg) or 45) return true end), true})
end
