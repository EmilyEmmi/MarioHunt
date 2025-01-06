-- Math
local math_min, math_max, math_floor, math_ceil, math_abs, math_sqrt, coss, sins, atan2s, vec3f_copy, vec3f_normalize, vec3f_dot, vec3f_mul, vec3f_dif, vec3f_length =
    math.min, math.max, math.floor, math.ceil, math.abs, math.sqrt, coss, sins, atan2s, vec3f_copy, vec3f_normalize,
    vec3f_dot, vec3f_mul, vec3f_dif, vec3f_length

function u16(x)
  x = (math_floor(x) & 0xFFFF)
  if x < 0 then return x + 65536 end
  return x
end

local r0 = 0
function random_u16()
  local r1 = 0
  r1 = u16((r0 & 255) << 8 ~ r0)
  r0 = u16(((r1 & 255) << 8) + ((r1 & 65280) >> 8))
  r1 = u16((r1 & 255) << 1 ~ r0)
  r0 = u16(r1 >> 1 ~ 65408 ~ (r1 & 1 ~= 0 and 33152 or 8180))
  if (r0 == 22026) then r0 = 0 end
  return r0
end

-- localize some functions
local djui_chat_message_create, warp_to_warpnode, tonumber, string_lower, mod_storage_save, mod_storage_load =
    djui_chat_message_create, warp_to_warpnode, tonumber, string.lower, mod_storage_save, mod_storage_load

function if_then_else(cond, if_true, if_false)
  if cond then return if_true end
  return if_false
end

-- temp fix for castle grounds warp bug
real_warp_to_level = warp_to_level
_G.warp_to_level = function(level, area, act)
  if level == gLevelValues.entryLevel and area == 1 then
    return warp_to_start_level() -- prevent instant death
  end
  return real_warp_to_level(level, area, act) -- prevent instant death
end

-- some debug stuff
function do_warp(msg)
  warpCooldown = 0
  if msg == "random" then
    local worked = false
    local level, area, act, node
    while not worked do
      level = math.random(4, 36)
      area = math.random(1, 4)
      act = math.random(0, 6)
      node = math.random(0, 64) -- obviously not the actual limit but whatever
      worked = warp_to_warpnode(level, area, act, node)
    end
    djui_chat_message_create("Warped to level " .. level .. " area " .. area .. " act " .. act .. " node " .. node)
    if gGlobalSyncTable.mhMode == 2 then
      gGlobalSyncTable.gameLevel = level
      gGlobalSyncTable.getStar = act
    end
    return true
  end
  local args = split(msg, " ")
  local level = tonumber(args[1])
  if args[1] and string.sub(args[1], 1, 1) == "c" then
    level = course_to_level[tonumber(string.sub(args[1], 2))]
  end
  if not level then
    level = string_to_level[args[1]] or 16
  end
  local area = tonumber(args[2]) or 1
  local act = tonumber(args[3]) or
      bool_to_int(gLevelValues.disableActs == 0 and level_to_course[level] and level_to_course[level] < 16 and
        level_to_course[level] > 0)
  local node = tonumber(args[4])
  if not node then
    djui_chat_message_create("Warping to level " .. level .. " area " .. area .. " act " .. act)
    if warp_to_level(level, area, act) or warp_to_warpnode(level, area, act, 0xF0) then
      if gGlobalSyncTable.mhMode == 2 then
        gGlobalSyncTable.gameLevel = level
        gGlobalSyncTable.getStar = act
      end
    else
      djui_chat_message_create("Warp failed!")
    end
  else
    djui_chat_message_create("Warping to level " .. level .. " area " .. area .. " act " .. act .. " node " .. node)
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
  if msg == "reset" then
    start_game("reset")
    gGlobalSyncTable.mhState = 2
    gGlobalSyncTable.mhTimer = 0
  else
    start_game("continue")
  end

  if msg == "hunter" then
    DEBUG_NO_VICTORY = true
    become_hunter(sMario)
    warp_to_level(LEVEL_BOB, 1, 1)
  elseif msg ~= "" and msg ~= "reset" then
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
  for i = 0, (MAX_PLAYERS - 1) do
    local sMario = gPlayerSyncTable[i]
    local np = gNetworkPlayers[i]
    if np.connected then
      print(np.name .. ": ", (tostring(sMario[msg])))
      djui_chat_message_create(np.name .. ": " .. (tostring(sMario[msg])))
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
  if msg == "parse" then
    ROMHACK.parseStars = true
    PARSE_PRINT = true
    setup_hack_data(false, false, gGlobalSyncTable.romhackFile)
    PARSE_PRINT = false
    return true
  end
  local valid_star_table = generate_star_table(tonumber(msg), (msg ~= "mini"), (msg ~= "noreplica"))
  print("")
  for i, star in ipairs(valid_star_table) do
    local act = star % 10
    local course = star // 10
    local starString = string.format("%s - %s (%d) (ID: %d)", get_custom_level_name(course, course_to_level[course], 1),
      get_custom_star_name(course, act), act, star)
    djui_chat_message_create(starString)
    print(string.format("%-31s%-31s%-5s%-5s", get_custom_level_name(course, course_to_level[course], 1),
      get_custom_star_name(course, act), act, star))
  end
  djui_chat_message_create(#valid_star_table .. " stars total")
  print("")
  print(#valid_star_table, "stars total")
  return true
end

function kill_bowser(msg)
  local bowser = obj_get_first_with_behavior_id(id_bhvBowser)
  if bowser then
    bowser.oAction = 4
    bowser.oSubAction = 10
    djui_chat_message_create("oh he ded")
  else
    djui_chat_message_create("There ain't no Bowser bro")
  end
  return true
end

function get_location(msg)
  local playerID, np = get_specified_player(msg)
  if playerID then
    local course = np.currCourseNum
    local level = np.currLevelNum
    local area = np.currAreaIndex
    local name = get_custom_level_name(course, level, area)
    djui_chat_message_create(string.format("%s (C%d, L%d, A%d)", name, course, level, area))
    print(name, course, level, area)
  end
  return true
end

function mute_command(msg)
  local player, np = get_specified_player(msg)
  if not np then return true end
  network_send_include_self(true,
    { id = PACKET_MUTE_PLAYER, playerIndex = np.globalIndex, muter = gNetworkPlayers[0].globalIndex, mute = true })
  return true
end

function unmute_command(msg)
  local player, np = get_specified_player(msg)
  if not np then return true end
  network_send_include_self(true,
    { id = PACKET_MUTE_PLAYER, playerIndex = np.globalIndex, muter = gNetworkPlayers[0].globalIndex, mute = false })
  return true
end

function star_mode_command(msg, bool)
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

function allow_stalk_command(msg)
  if string_lower(msg) == "on" then
    gGlobalSyncTable.allowStalk = true
    return true
  elseif string_lower(msg) == "off" then
    gGlobalSyncTable.allowStalk = false
    return true
  end
  return false
end

function force_spectate_command(msg)
  if msg == "all" then
    if gGlobalSyncTable.forceSpectate then
      gGlobalSyncTable.forceSpectate = false
      for i = 0, (MAX_PLAYERS - 1) do
        gPlayerSyncTable[i].forceSpectate = false
        gPlayerSyncTable[i].dead = false
        gPlayerSyncTable[i].knownDead = false
      end
      djui_chat_message_create(trans("force_spectate_off"))
    else
      gGlobalSyncTable.forceSpectate = true
      for i = 0, (MAX_PLAYERS - 1) do
        gPlayerSyncTable[i].forceSpectate = true
        gPlayerSyncTable[i].dead = true
        gPlayerSyncTable[i].knownDead = true
      end
      djui_chat_message_create(trans("force_spectate"))
    end
    return true
  end

  local playerID, np = get_specified_player(msg)
  if not playerID then return true end

  local sMario = gPlayerSyncTable[playerID]
  local name = remove_color(np.name)
  if sMario.forceSpectate or sMario.dead then
    sMario.forceSpectate = false
    sMario.dead = false
    sMario.knownDead = false
    djui_chat_message_create(trans("force_spectate_one_off", name))
  else
    sMario.forceSpectate = true
    sMario.dead = true
    sMario.knownDead = true
    djui_chat_message_create(trans("force_spectate_one", name))
  end
  return true
end

function desync_fix_command(msg)
  local oldLevel = gGlobalSyncTable.gameLevel
  local oldStar = gGlobalSyncTable.getStar
  local oldMode = gGlobalSyncTable.mhMode
  local oldState = gGlobalSyncTable.mhState
  gGlobalSyncTable.gameLevel = -1
  gGlobalSyncTable.getStar = -1
  gGlobalSyncTable.mhMode = -1
  gGlobalSyncTable.mhState = -1
  gGlobalSyncTable.gameLevel = oldLevel
  gGlobalSyncTable.getStar = oldStar
  gGlobalSyncTable.mhMode = oldMode
  gGlobalSyncTable.mhState = oldState
  for i = 1, (MAX_PLAYERS - 1) do
    local sMario = gPlayerSyncTable[i]
    local oldTeam = sMario.team or 0
    local oldSpectator = sMario.spectator or 0
    local oldDead = sMario.dead or false
    local oldStars = sMario.totalStars or 0
    if oldTeam == 1 then
      local oldLives = sMario.runnerLives -- I wrote "runnerlives" instead before smh
      sMario.runnerLives = 100 -- No longer -1, because if it's -1, then it can make random people hunter...
      sMario.runnerLives = oldLives
    end
    sMario.team = -1
    sMario.team = oldTeam
    sMario.totalStars = -1
    sMario.totalStars = oldStars
    sMario.spectator = 0
    sMario.spectator = oldSpectator
    sMario.dead = false
    sMario.dead = oldDead
  end
  return true
end

function out_command(msg)
  for i = 1, MAX_PLAYERS - 1 do
    local m = gMarioStates[i]
    if is_player_in_local_area(m) ~= 0 then
      network_send_to(i, true, {
        id = PACKET_GET_OUTTA_HERE,
      })
    end
  end
  on_packet_get_outta_here({id = PACKET_GET_OUTTA_HERE}, true)
  return true
end

function halt_command(msg)
  gGlobalSyncTable.mhState = 5
  network_send_include_self(true, {
    id = PACKET_GAME_END,
    winner = -1,
  })
  if gGlobalSyncTable.gameAuto ~= 0 then
    gGlobalSyncTable.mhTimer = 20 * 30 -- 20 seconds
  else
    gGlobalSyncTable.mhTimer = 0
  end
  return true
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
  if not args[1] then return false end
  local action = string_lower(args[1])
  if action == "list" then
    djui_chat_message_create(trans("blacklist_list"))
    for id, value in pairs(mini_blacklist) do
      local course = id // 10
      local act = id % 10
      if not valid_star(course, act, false, true) then
        local starString = string.format("%s - %s (Course %d, Star %d)",
          get_custom_level_name(course, course_to_level[course], 1), get_custom_star_name(course, act), course, act)
        djui_chat_message_create(starString)
      end
    end
  elseif action == "add" then
    local stringCourse = ""
    if args[2] then stringCourse = string_lower(args[2]) end
    local course = tonumber(args[2]) or string_to_course[stringCourse]
    local act = tonumber(args[3])
    if not course then return false end
    if course < 1 or course > 24 then return false end

    if act then
      if act < 1 or act > 7 then
        return false
      elseif not valid_star(course, act, false, true) then
        djui_chat_message_create(trans("blacklist_add_already"))
        return true
      end
      local starID = course * 10 + act
      mini_blacklist[starID] = 1
    else
      local allblacklist = true
      for act = 1, 7 do
        if valid_star(course, act, false, true) then
          local starID = course * 10 + act
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
    if act then
      starString = string.format("%s - %s (Course %d, Star %d)",
        get_custom_level_name(course, course_to_level[course], 1), get_custom_star_name(course, act), course, act)
    else
      starString = string.format("%s (Course %d)", get_custom_level_name(course, course_to_level[course], 1), course)
    end
    djui_chat_message_create(trans("blacklist_add", starString))
  elseif action == "remove" then
    local stringCourse = ""
    if args[2] then stringCourse = string_lower(args[2]) end
    local course = tonumber(args[2]) or string_to_course[stringCourse]
    local act = tonumber(args[3])
    if not course then return false end
    if course < 1 or course > 24 then return false end

    if act then
      local starID = course * 10 + act
      if act < 1 or act > 7 then
        return false
      elseif valid_star(course, act, false, true) then
        djui_chat_message_create(trans("blacklist_remove_already"))
        return true
      elseif not mini_blacklist[starID] then
        djui_chat_message_create(trans("blacklist_remove_invalid"))
        return true
      end
      mini_blacklist[starID] = nil
    else
      local allwhitelist = true
      local invalid = true
      for act = 1, 7 do
        local starID = course * 10 + act
        local valid = valid_star(course, act, false, true)
        if (not valid) and mini_blacklist[starID] then
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
    if act then
      starString = string.format("%s - %s (Course %d, Star %d)",
        get_custom_level_name(course, course_to_level[course], 1), get_custom_star_name(course, act), course, act)
    else
      starString = string.format("%s (Course %d)", get_custom_level_name(course, course_to_level[course], 1), course)
    end
    djui_chat_message_create(trans("blacklist_remove", starString))
  elseif action == "reset" then
    -- we actually want to reload on our end here
    gGlobalSyncTable.blacklistData = "none"
    djui_chat_message_create(trans("blacklist_reset"))
  elseif action == "save" then
    local fileName = string.gsub(gGlobalSyncTable.romhackFile, " ", "_")
    if gGlobalSyncTable.blacklistData ~= "none" then
      mod_storage_save(fileName .. "_black", gGlobalSyncTable.blacklistData)
    else
      mod_storage_save(fileName .. "_black", "none")
    end
    djui_chat_message_create(trans("blacklist_save"))
  elseif action == "load" then
    local fileName = string.gsub(gGlobalSyncTable.romhackFile, " ", "_")
    local option = mod_storage_load(fileName .. "_black") or "none"
    gGlobalSyncTable.blacklistData = option
    djui_chat_message_create(trans("blacklist_load"))
  else
    return false
  end

  return true
end

function rom_hack_command(msg)
  gGlobalSyncTable.romhackFile = msg
  return true
end

function complete_command(msg)
  local file = get_current_save_file_num() - 1
  for course = 0, 25 do
    local data = { 8, 8, 8, 8, 8, 8, 8 }
    if gGlobalSyncTable.ee and ROMHACK.star_data_ee[course] then
      data = ROMHACK.star_data_ee[course]
    elseif ROMHACK.star_data[course] then
      data = ROMHACK.star_data[course]
    elseif course == 25 then
      break
    elseif course > 15 then
      data = { 8 }
    elseif course == 0 then
      data = { 8, 8, 8, 8, 8 }
    end
    for star = 1, 7 do
      if data[star] and data[star] ~= 0 then
        if course ~= 0 then
          save_file_set_star_flags(file, course - 1, (1 << (star - 1)))
        else
          save_file_set_flags((SAVE_FLAG_COLLECTED_TOAD_STAR_1 << (star - 1)))
        end
      end
    end
    save_file_set_star_flags(file, course, 0x80)
  end
  --[[save_file_set_flags(SAVE_FLAG_COLLECTED_TOAD_STAR_2)
  save_file_set_flags(SAVE_FLAG_COLLECTED_TOAD_STAR_3)
  save_file_set_flags(SAVE_FLAG_COLLECTED_MIPS_STAR_1)
  save_file_set_flags(SAVE_FLAG_COLLECTED_MIPS_STAR_2)]]
  save_file_clear_flags(SAVE_FLAG_HAVE_KEY_1)
  save_file_clear_flags(SAVE_FLAG_HAVE_KEY_1)
  save_file_set_flags(SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR)
  save_file_set_flags(SAVE_FLAG_UNLOCKED_BASEMENT_DOOR)
  save_file_set_flags(SAVE_FLAG_HAVE_METAL_CAP)
  save_file_set_flags(SAVE_FLAG_HAVE_VANISH_CAP)
  save_file_set_flags(SAVE_FLAG_HAVE_WING_CAP)
  save_file_set_flags(SAVE_FLAG_UNLOCKED_WF_DOOR)
  save_file_set_flags(SAVE_FLAG_UNLOCKED_CCM_DOOR)
  save_file_set_flags(SAVE_FLAG_UNLOCKED_JRB_DOOR)
  save_file_set_flags(SAVE_FLAG_UNLOCKED_PSS_DOOR)
  save_file_set_flags(SAVE_FLAG_UNLOCKED_BITDW_DOOR)
  save_file_set_flags(SAVE_FLAG_UNLOCKED_BITFS_DOOR)
  save_file_set_flags(SAVE_FLAG_UNLOCKED_50_STAR_DOOR)
  djui_chat_message_create("The save has been completed!")
  return true
end

function render_power_meter_mariohunt(health, x, y, width, height, index)
  if not apply_double_health(index or 0) then return hud_render_power_meter(health, x, y, width, height) end
  local doubleHealth = 2 * health - 0xFF
  if health >= 0x500 then
    hud_render_power_meter(doubleHealth - 0x801, x, y, width, height)
    djui_hud_set_font(FONT_HUD)
    djui_hud_print_text("+8", x + width / 2, y + height / 2, math.min(width, height) / 64)
  else
    hud_render_power_meter(doubleHealth, x, y, width, height)
  end
end

function render_power_meter_interpolated_mariohunt(health, prevX, prevY, prevWidth, prevHeight, x, y, width, height,
                                                   index)
  if not apply_double_health(index or 0) then
    return hud_render_power_meter_interpolated(health, prevX, prevY, prevWidth,
      prevHeight, x, y, width, height)
  end
  local doubleHealth = 2 * health - 0xFF
  if health >= 0x500 then
    hud_render_power_meter_interpolated(doubleHealth - 0x801, prevX, prevY, prevWidth, prevHeight, x, y, width, height)
    djui_hud_set_font(FONT_HUD)
    djui_hud_print_text_interpolated("+8", prevX + prevWidth / 2, prevY + prevHeight / 2,
      math.min(prevWidth, prevHeight) / 64, x + width / 2, y + height / 2, math.min(width, height) / 64)
  else
    hud_render_power_meter_interpolated(doubleHealth, prevX, prevY, prevWidth, prevHeight, x, y, width, height)
  end
end

function apply_double_health(index)
  local sMario = gPlayerSyncTable[index]
  return sMario and gGlobalSyncTable.doubleHealth and (sMario.team == 1 or gGlobalSyncTable.mhMode == 3) and
      (sMario.hard == nil or sMario.hard == 0) and (gGlobalSyncTable.mhState == 1 or gGlobalSyncTable.mhState == 2)
end

-- tip data
-- arg 1: what team is needed for the tip to appear (-1 is either)
-- arg 2: TRUE if mod powers are needed
-- arg 3: game mode needed for tip to appear (-1 refers to any, -2 is Not MiniHunt, -3 is Swap or MiniHunt)
-- arg 4: TRUE if OMM is needed for the tip to appear
-- arg 5: TRUE if the hack must be vanilla
-- arg 6: a function for more complex requirements
local total_tips = 46
tip_data = {
  [5] = { -1, true },
  [6] = { -1, true },
  [7] = { -1, true },
  [8] = { 1, false, -2 },
  [9] = { 0, false, -2 },
  [11] = { -1, true, -2 },
  [12] = { 0, false, -3 },
  [14] = { 0, false, -2 },
  [15] = { -1, false, -1, false, true },
  [16] = { -1, false, -2, false, true },
  [17] = { -1, false, -1, true },
  [18] = { -1, false, -1, true },
  [19] = { -1, false, -1, true },
  [20] = { -1, false, -1, true },
  [21] = { -1, true, -2 },
  [22] = { -1, true },
  [24] = { -1, false, -2 },
  [25] = { 1, false, 2, false, false, function() return gGlobalSyncTable.anarchy ~= 0 and gGlobalSyncTable.anarchy ~= 2 end },
  [28] = { 1, false, -2, false, false, function() return gLevelValues.disableActs and gLevelValues.disableActs ~= 0 end },
  [29] = { -1, false, -1, false, false, function() return (month == 13 or month == 12 or month == 10) end },
  [30] = { 0, false, -1, false, false, function() return gGlobalSyncTable.allowSpectate end },
  [31] = { -1, false, -1, false, false, function() return gGlobalSyncTable.allowStalk end },
  [36] = { -1, false, -1, false, false, function() return gGlobalSyncTable.nerfVanishCap end },
  [38] = { 1, false, -2, false, false, function() return gLevelValues.disableActs and gLevelValues.disableActs ~= 0 end },
  [40] = { -1, false, -1, false, false, function() return gGlobalSyncTable.voidDmg ~= -1 end },
  [42] = { -1, true },
  [43] = { -1, true },
  [44] = { -1, false, -1, false, false, function() return gPlayerSyncTable[0].role ~= 0 end },
}
local new_tips = { 1, 43, 46, 13, 42, 10, 11, 4, 5, 6, 7, 22 }

local newTipProg = 0
local chosenTip = 0
function render_tip(pickNew)
  djui_hud_set_font(FONT_MENU)
  djui_hud_set_color(255, 255, 255, 255)
  local scale = 0.1

  if pickNew or chosenTip == 0 then
    if network_is_server() and gPlayerSyncTable[0].kills == 0 and gGlobalSyncTable.mhState == 0 then -- display certain tips for new hosts
      newTipProg = newTipProg + 1
      if newTipProg > #new_tips then
        newTipProg = 1
      end
      chosenTip = new_tips[newTipProg]
    else
      local LIMIT = 0
      local invalid = true
      while LIMIT < 100 and invalid do
        chosenTip = math.random(1, total_tips)
        invalid = false
        LIMIT = LIMIT + 1
        local data = tip_data[chosenTip]
        if data then
          if data[1] ~= -1 and gPlayerSyncTable[0].team ~= data[1] then
            invalid = true
          elseif data[2] and not has_mod_powers(0) then
            invalid = true
          elseif data[3] ~= -1 and gGlobalSyncTable.mhMode ~= data[3] and not ((data[3] == -2 and gGlobalSyncTable.mhMode ~= 2) or (data[3] == -3 and gGlobalSyncTable.mhMode ~= 0 and gGlobalSyncTable.mhMode ~= 3)) then
            invalid = true
          elseif data[4] and not OmmEnabled then
            invalid = true
          elseif data[5] and gGlobalSyncTable.romhackFile ~= "vanilla" then
            invalid = true
          elseif data[6] and not data[6]() then
            invalid = true
          end
        end
      end
    end
  end

  local extra
  if chosenTip == 1 or chosenTip == 10 then -- show actual menu bind
    local buttonString = { "L + Start", "R + Start", "U-DPAD", "D-DPAD", "L-DPAD", "R-DPAD" }
    extra = buttonString[menuButton]
  elseif chosenTip == 36 then -- show actual vanish bind
    local buttonString = { "A", "B", "Z", "START", "U-DPAD", "D-DPAD", "L-DPAD", "R-DPAD", "Y", "X", "L", "R" }
    extra = buttonString[nerfVanishButton]
  end
  local text = trans("tip") .. trans("tip_" .. chosenTip, extra)
  local screenWidth = djui_hud_get_screen_width()
  local width = djui_hud_measure_text(text) * scale
  local x = 0
  local y = 15
  if width > screenWidth * 0.8 then
    local spaceLoc = text:find(" ", text:len() // 2) or text:len() // 2
    local text1 = text:sub(1, spaceLoc)
    text = text:sub(spaceLoc)
    width = djui_hud_measure_text(text1) * scale
    x = (screenWidth - width) / 2
    djui_hud_print_text(text1, x, y, scale)
    width = djui_hud_measure_text(text) * scale
    y = y + 10
  end
  x = (screenWidth - width) / 2
  djui_hud_print_text(text, x, y, scale)
end

function set_override_team_colors(np, team)
  if not know_team(np.localIndex) then
    network_player_reset_palette_custom(np)
    return
  end

  local sMario = gPlayerSyncTable[np.localIndex]
  if disguiseMod then
    local gIndex = disguiseMod.getDisguisedIndex(np.globalIndex)
    sMario = gPlayerSyncTable[network_local_index_from_global(gIndex)]
  end

  local m = gMarioStates[np.localIndex]
  if team == 1 then
    -- azure
    local darkBlue = { r = 0x4f, g = 0x31, b = 0x8b }
    local lightBlue = { r = 0x5a, g = 0x94, b = 0xff }
    if runnerAppearance ~= 4 and (runnerAppearance ~= 2 or m.marioBodyState.modelState & MODEL_STATE_METAL == 0) then
      network_player_reset_palette_custom(np)
      return
    end
    if charSelectExists then
      charSelect.restrict_palettes(not (charSelect.is_menu_open()))
    end

    network_player_reset_palette_custom_part(np, GLOVES)
    network_player_reset_palette_custom_part(np, SKIN)
    network_player_reset_palette_custom_part(np, SHOES)
    network_player_reset_palette_custom_part(np, HAIR)
    if m.marioBodyState.modelState & MODEL_STATE_METAL ~= 0 then
      if runnerAppearance == 4 or sMario.hard == nil or sMario.hard == 0 then
        network_player_set_override_palette_color(np, METAL, lightBlue)
      elseif sMario.hard == 1 then
        network_player_set_override_palette_color(np, METAL, { r = 255, g = 0xbd, b = 0 })     -- wario yellow
      else
        network_player_set_override_palette_color(np, METAL, { r = 0x61, g = 0x25, b = 0xb0 }) -- waluigi purple
      end
      return
    end
    network_player_set_override_palette_color(np, EMBLEM, darkBlue)
    network_player_set_override_palette_color(np, CAP, lightBlue)
    network_player_set_override_palette_color(np, PANTS, darkBlue)
    network_player_set_override_palette_color(np, SHIRT, lightBlue)
  else
    -- burgundy
    local darkRed = { r = 0x23, g = 0x11, b = 0x03 }
    local lightRed = { r = 0x68, g = 0x0a, b = 0x17 }
    if hunterAppearance ~= 4 and (hunterAppearance ~= 2 or m.marioBodyState.modelState & MODEL_STATE_METAL == 0) then
      network_player_reset_palette_custom(np)
      return
    end
    if charSelectExists then
      charSelect.restrict_palettes(not (charSelect.is_menu_open()))
    end

    network_player_reset_palette_custom_part(np, GLOVES)
    network_player_reset_palette_custom_part(np, SKIN)
    network_player_reset_palette_custom_part(np, SHOES)
    network_player_reset_palette_custom_part(np, HAIR)
    if m.marioBodyState.modelState & MODEL_STATE_METAL ~= 0 then
      network_player_set_override_palette_color(np, METAL, lightRed)
      return
    end
    network_player_set_override_palette_color(np, EMBLEM, darkRed)
    network_player_set_override_palette_color(np, CAP, lightRed)
    network_player_set_override_palette_color(np, PANTS, darkRed)
    network_player_set_override_palette_color(np, SHIRT, lightRed)
  end
end

function network_player_reset_palette_custom_part(np, part)
  if disguiseMod then
    local gIndex = disguiseMod.getDisguisedIndex(np.globalIndex)
    if gIndex ~= np.globalIndex then
      local np2 = network_player_from_global_index(gIndex)
      local color = network_player_get_palette_color(np2, part, color)
      network_player_set_override_palette_color(np, part, color)
      return
    end
  end

  return network_player_set_override_palette_color(np, part, network_player_get_palette_color(np, part))
end

function network_player_reset_palette_custom(np)
  if charSelectExists then
    charSelect.restrict_palettes(false)
  end
  if disguiseMod then
    local gIndex = disguiseMod.getDisguisedIndex(np.globalIndex)
    if gIndex ~= np.globalIndex then
      local np2 = network_player_from_global_index(gIndex)
      for i = 0, PLAYER_PART_MAX - 1 do
        local color = network_player_get_palette_color(np2, i, color)
        network_player_set_override_palette_color(np, i, color)
      end
      return
    end
  end

  return network_player_reset_override_palette(np)
end

-- main command
hook_chat_command("mh", "[COMMAND,ARGS] - Runs commands; type nothing or \"menu\" to open the menu", mario_hunt_command)
function setup_commands()
  -- commands for main command
  marioHuntCommands = {}
  -- format is: command, alias, function, debug
  table.insert(marioHuntCommands, { "start", nil, start_game })
  table.insert(marioHuntCommands, { "add", "addrunner", add_runner })
  table.insert(marioHuntCommands, { "random", "randomize", runner_randomize })
  table.insert(marioHuntCommands, { "lives", "runnerlives", runner_lives })
  table.insert(marioHuntCommands, { "time", "timeneeded", time_needed_command })
  table.insert(marioHuntCommands, { "stars", "starsneeded", stars_needed_command })
  table.insert(marioHuntCommands, { "category", "starrun", star_count_command })
  table.insert(marioHuntCommands, { "flip", "changeteam", change_team_command })
  table.insert(marioHuntCommands, { "setlife", nil, set_life_command })
  table.insert(marioHuntCommands, { "leave", "allowleave", allow_leave_command })
  table.insert(marioHuntCommands, { "mode", nil, change_game_mode })
  table.insert(marioHuntCommands, { "starmode", nil, star_mode_command })
  table.insert(marioHuntCommands, { "spectator", "allowspectate", allow_spectate_command })
  table.insert(marioHuntCommands, { "stalking", "allowstalk", allow_stalk_command })
  table.insert(marioHuntCommands, { "pause", "freeze", pause_command })
  --table.insert(marioHuntCommands, {"metal", "seeker", metal_command})
  table.insert(marioHuntCommands, { "hack", "romhack", rom_hack_command })
  table.insert(marioHuntCommands, { "weak", nil, weak_command })
  table.insert(marioHuntCommands, { "auto", nil, auto_command })
  table.insert(marioHuntCommands, { "forcespectate", "dead", force_spectate_command })
  table.insert(marioHuntCommands, { "desync", "fixdesync", desync_fix_command })
  table.insert(marioHuntCommands, { "out", "getout", out_command })
  table.insert(marioHuntCommands, { "stop", "halt", halt_command })
  table.insert(marioHuntCommands, { "default", nil, default_settings })
  table.insert(marioHuntCommands, { "blacklist", "black", blacklist_command })
  table.insert(marioHuntCommands, { "hidehud", "hide", function()
    mhHideHud = not mhHideHud
    return true
  end })
  table.insert(marioHuntCommands, { "mute", nil, mute_command })
  table.insert(marioHuntCommands, { "unmute", nil, unmute_command })

  -- debug
  table.insert(marioHuntCommands, { "print", nil, print, true })
  table.insert(marioHuntCommands, { "warp", nil, do_warp, true })
  table.insert(marioHuntCommands, { "quick", nil, quick_debug, true })
  table.insert(marioHuntCommands, { "combo", nil, combo_debug, true })
  table.insert(marioHuntCommands, { "field", nil, get_field, true })
  table.insert(marioHuntCommands, { "allstars", nil, get_all_stars, true })
  table.insert(marioHuntCommands, { "langtest", nil, lang_test, true })
  table.insert(marioHuntCommands, { "unmod", nil, unmod, true })
  table.insert(marioHuntCommands, { "gfield", nil, get_field_global, true })
  table.insert(marioHuntCommands,
    { "wing-cap", nil, (function()
      gMarioStates[0].flags = gMarioStates[0].flags | MARIO_WING_CAP
      play_sound(SOUND_GENERAL_SHORT_STAR, gMarioStates[0].marioObj.header.gfx.cameraToObject)
      play_cap_music(SEQ_EVENT_POWERUP)
      play_character_sound(gMarioStates[0], CHAR_SOUND_HERE_WE_GO)
      return true
    end), true })
  table.insert(marioHuntCommands,
    { "set-fov", nil, (function(msg)
      set_override_fov(tonumber(msg) or 45)
      return true
    end), true })
  table.insert(marioHuntCommands, { "kill-bowser", nil, kill_bowser, true })
  table.insert(marioHuntCommands, { "location", nil, get_location, true })
  table.insert(marioHuntCommands, { "complete", nil, complete_command, true })
  table.insert(marioHuntCommands, { "djui", nil, function()
    djui_open_pause_menu()
    return true
  end, true })
  table.insert(marioHuntCommands, { "swarp", nil, function(msg)
    return warp_special(tonumber(msg))
  end, true })
  table.insert(marioHuntCommands,
    { "safe", "safesurface", function()
      DEBUG_SAFE_SURFACE = not DEBUG_SAFE_SURFACE
      return true
    end, true })
  table.insert(marioHuntCommands,
    { "nowin", "novictory", function()
      DEBUG_NO_VICTORY = not DEBUG_NO_VICTORY
      return true
    end, true })
  table.insert(marioHuntCommands,
    { "ping", "showping", function()
      DEBUG_SHOW_PING = not DEBUG_SHOW_PING
      return true
    end, true })
end
