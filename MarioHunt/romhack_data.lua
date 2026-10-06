-- constants
STAR_EXIT = (1 << 4)                -- player can leave when grabbing this star
STAR_IGNORE_STARMODE = (1 << 5)     -- star is not counted in star mode
STAR_ACT_SPECIFIC = (1 << 6)        -- star can only be gotten in this act
STAR_NOT_ACT_1 = (1 << 7)           -- star cannot be gotten in act 1
STAR_APPLY_NO_ACTS = (1 << 8)       -- applies even if disable acts is on (like in OMM)
STAR_NOT_BEFORE_THIS_ACT = (1 << 9) -- star cannot be gotten before this act
STAR_REPLICA = (1 << 9)             -- replica flag (uses replica_start or replica_func)
STAR_MULTIPLE_AREAS = (1 << 10)     -- only needed if your star can be obtained in only certain areas
STAR_AREA_MASK = STAR_EXIT - 1      -- 1-15

ACT_1 = (1 << 0)
ACT_2 = (1 << 1)
ACT_3 = (1 << 2)
ACT_4 = (1 << 3)
ACT_5 = (1 << 4)
ACT_6 = (1 << 5)
ALL_ACTS = (ACT_1 | ACT_2 | ACT_3 | ACT_4 | ACT_5 | ACT_6)
NOT_ACT_1 = (ACT_2 | ACT_3 | ACT_4 | ACT_5 | ACT_6)
NOT_ACT_2 = (ACT_1 | ACT_3 | ACT_4 | ACT_5 | ACT_6)
NOT_ACT_3 = (ACT_1 | ACT_2 | ACT_4 | ACT_5 | ACT_6)
NOT_ACT_4 = (ACT_1 | ACT_2 | ACT_3 | ACT_5 | ACT_6)
NOT_ACT_5 = (ACT_1 | ACT_2 | ACT_3 | ACT_4 | ACT_6)
NOT_ACT_6 = (ACT_1 | ACT_2 | ACT_3 | ACT_4 | ACT_5)

romhack_data = {}

-- List of romhack data files. They are loaded when the relevant romhack is active
local unloaded_romhack_files = {
  ["default"] = "!rom_default",
  ["vanilla"] = "!rom_vanilla",
  ["star-road"] = "rom_star_road",
  ["coop-romhacks-star-road"] = "rom_star_road",
  ["sapphire"] = "rom_sapphire",
  ["SM64 Sapphire Green Comet"] = "rom_sapphire",
  ["Ztar Attack 2"] = "rom_ztar_attack_2",
  ["coop-mods-green-stars"] = "rom_green_stars",
  ["underworld"] = "rom_underworld",
  ["B3313"] = "rom_b3313",
  ["moonshine"] = "rom_moonshine",
  ["ldd"] = "rom_ldd",
  ["ldd_green_comet"] = "rom_ldd",
  ["luigis-mansion-64"] = "rom_lm64",
  ["sr7-coop-port"] = "rom_sr7",
  ["decades-later-coop-main"] = "rom_decades_later", -- https://github.com/Moldy64/sm64-dl-hack-mh
  ["decades-later-coop"] = "rom_decades_later", -- https://github.com/Moldy64/sm64-dl-hack-mh
  ["sm64-dl-hack-mh-main"] = "rom_decades_later", -- https://github.com/Moldy64/sm64-dl-hack-mh
  ["sm64-dl-hack-mh"] = "rom_decades_later", -- https://github.com/Moldy64/sm64-dl-hack-mh
}

ROMHACK = {}               -- table containing the romhack data we're using
PARSE_COURSE = 0           -- what course we're parsing in level_script_parse
PARSE_AREA = 0             -- what area we're parsing in level_script_parse
PARSE_LEVEL = 0            -- what level we're parsing in level_script_parse
PARSE_PRINT = false        -- used in debug command; displays information about found stars
PARSE_FOUND_STARS = {}     -- stars we've found in the level we're parsing
PARSE_MINI_EXCLUDE = {}    -- stars we've found to exclude in minihunt
PARSE_STAR_NAMES = {}      -- the name of the stars we've found

disable_chat_hook = false  -- disabled if a mod uses it (swear filter, for example)
voice_chat_enabled = false -- limbokong's proximity voicechat; changes how spectator mode works

function setup_hack_data(settingRomHack, initial, usingOMM)
  local romhack_file = gGlobalSyncTable.romhackFile
  ROMHACK = romhack_data[romhack_file]

  if initial and usingOMM then
    local verstring = (OmmVersion and OmmVersion:sub(9)) or "Unknown"
    if tonumber(verstring) and tonumber(verstring) >= 1.2 then
      djui_popup_create(trans("omm_detected"), 1)
    else
      djui_popup_create(trans("omm_bad_version", "1.2", verstring), 3)
    end
  end

  local found_121 = false
  if not ROMHACK and settingRomHack then
    if not (mhApi and mhApi.romhackSetup) then
      romhack_file = "vanilla"
    else
      romhack_file = "custom"
    end
    for i, mod in pairs(gActiveMods) do
      if mod.enabled then
        if not (mhApi and mhApi.romhackSetup) and incompatible_or_category(mod, "romhack") then   -- is a romhack
          romhack_file = mod.relativePath:gsub("ROMHACK - ", "")
          found_121 = false
        elseif initial and not (usingOMM or movesetEnabled) and incompatible_or_category(mod, "moveset") then   -- is moveset
          movesetEnabled = true
        elseif (not found_121) and (romhack_file == "vanilla") and string.find(mod.name, "121rst star") then                         -- 121rst star support
          found_121 = true
        elseif not voice_chat_enabled and mod.name and (get_uncolored_string(mod.name) == ("Limbokong's Voicechat") or mod.name:find("Roblox Chat Bubbles")) and not mod.name:find("(MH)") then
          voice_chat_enabled = true
        elseif not disable_chat_hook then                                                                                            -- disable hook for some mods
          local name = mod.name:lower()
          if (name:find("mute") or name:find("swear filter") or name:find("nicknames")) and not name:find("(mh)") then
            disable_chat_hook = true
          end
        end
      end
    end
    print("Romhack is", romhack_file)
    ROMHACK = romhack_data[romhack_file]
  end

  -- load romhack lua file
  ROMHACK = load_romhack_file(romhack_file)

  if romhack_file == "custom" and (mhApi and mhApi.romhackSetup) then
    ROMHACK = mhApi.romhackSetup()
    print("Romhack is", ROMHACK.name, "custom")
  end

  if initial and romhack_file == "vanilla" then
    dialog_replace()
    omm_replace(usingOMM)
  end

  -- inherit
  if ROMHACK and ROMHACK.inherit then
    local new_rom = load_romhack_file(ROMHACK.inherit)
    if new_rom then
      print("Inheriting data from", ROMHACK.inherit)
      for i, v in pairs(ROMHACK) do
        if type(v) ~= "table" then
          new_rom[i] = v
        else
          if not new_rom[i] then
            new_rom[i] = {}
          end
          for a, b in pairs(v) do
            new_rom[i][a] = b
          end
        end
      end
      ROMHACK = new_rom
    end
  end

  if found_121 then
    ROMHACK.star_data[COURSE_NONE] = { 8, 8, 8, 8, 8, 8 }
    ROMHACK.starNames[6] = "Red Coins at Midnight"
  end

  if not ROMHACK then
    romhack_file = "default"
    ROMHACK = load_romhack_file(romhack_file)
    print("Not compatible!")
    djui_popup_create(trans("incompatible_hack"), 1)
    set_without_sync(gGlobalSyncTable, "romhackFile", "default")
  elseif romhack_file ~= "vanilla" then
    djui_popup_create(trans("set_hack", ROMHACK.name), 1)
  end

  if ROMHACK.starColor then
    defaultStarColor = ROMHACK.starColor
  else
    defaultStarColor = { r = 255, g = 255, b = 92 } -- yellow
  end
  if ROMHACK.noMiniMap then
    showMiniMap = false
  end
  if ROMHACK.noRadar then
    showRadar = false
  end

  if initial then
    if ROMHACK.otherStarIds then
      local otherStarIds = ROMHACK.otherStarIds() or {}
      for id, name in pairs(otherStarIds) do
        star_ids[id] = name
      end
    end
    if ROMHACK.otherStarSources then
      local otherStarSources = ROMHACK.otherStarSources() or {}
      for id, data in pairs(otherStarSources) do
        star_sources[id] = data
      end
    end
    disableActlessOption = (not gGlobalSyncTable.actless) and (gLevelValues.disableActs ~= 0 or ROMHACK.disableNonStop or usingOMM)
  end

  -- support for old format
  if not ROMHACK.star_data then
    ROMHACK.star_data = {}
    for level=LEVEL_NONE,LEVEL_COUNT-1 do
      local course = get_level_course_num(level)
      if ROMHACK.starCount[level] then
        if not ROMHACK.star_data[course] then ROMHACK.star_data[course] = {} end
        if ROMHACK.starCount[level] > 0 then
          for i = 1, ROMHACK.starCount[level] do
            local starNum = i
            if ROMHACK.renumber_stars and ROMHACK.renumber_stars[course * 10 + i] then
              starNum = ROMHACK.renumber_stars[course * 10 + i]
            end
            if starNum ~= 0 then
              ROMHACK.star_data[course][starNum] = 8
            end
          end
        end
      end
    end
  end

  if ROMHACK.parseStars then
    for course = 0, COURSE_MAX - 1 do
      parse_course_stars(course, get_level_num_from_course_num(course) or 0)
    end
  end

  if settingRomHack and network_is_server() then
    gGlobalSyncTable.allowStalk = ROMHACK.stalk or false
    gGlobalSyncTable.starRun = ROMHACK.default_stars
    gGlobalSyncTable.noBowser = ROMHACK.no_bowser or false
    set_without_sync(gGlobalSyncTable, "romhackFile", romhack_file)
    change_setting_default("allowStalk", gGlobalSyncTable.allowStalk)
    change_setting_default("starRun", gGlobalSyncTable.starRun)
    change_setting_default("noBowser", gGlobalSyncTable.noBowser)
    if disableActlessOption then
      change_setting_default("actless", false)
    end
  end
  return romhack_file
end

-- checks both mod.incompatible and mod.category
function incompatible_or_category(mod, category)
  if mod.category then
    return mod.category == category
  elseif mod.incompatible and string.find(mod.incompatible, category) then
    return true
  end
  return false
end

function load_romhack_file(filename)
  local hackData = romhack_data[filename]
  if (not hackData) and unloaded_romhack_files[filename] then
    local file = unloaded_romhack_files[filename]
    for otherHack, otherFile in pairs(unloaded_romhack_files) do
      if file == otherFile then
        unloaded_romhack_files[otherHack] = nil
      end
    end
    ROMHACK_FILE_LOADING = filename -- for the require function to read
    require("romhacks/"..file)
    ROMHACK_FILE_LOADING = nil
    hackData = romhack_data[filename]
  end
  return hackData
end

-- uses level_script_parse to setup romhack data
function parse_course_stars(course, level)
  if gGlobalSyncTable.romhackFile ~= "vanilla" and level_is_vanilla_level(level) then
    print(level, "is vanilla", course)
    ROMHACK.star_data[course] = {}
    return
  end
  PARSE_COURSE = course
  PARSE_LEVEL = level
  PARSE_AREA = 1
  PARSE_FOUND_STARS = {}
  PARSE_MINI_EXCLUDE = {}
  PARSE_STAR_NAMES = {}

  if not ROMHACK.mini_exclude then ROMHACK.mini_exclude = {} end
  if not ROMHACK.starNames then ROMHACK.starNames = {} end
  if not ROMHACK.star_data[course] then ROMHACK.star_data[course] = {} end

  local exText = ""
  local renumText = ""

  print(PARSE_LEVEL)
  level_script_parse(PARSE_LEVEL, parse_stars)
  if course == 0 then
    PARSE_LEVEL = LEVEL_CASTLE_GROUNDS
    level_script_parse(PARSE_LEVEL, parse_stars)
    PARSE_LEVEL = LEVEL_CASTLE_COURTYARD
    level_script_parse(PARSE_LEVEL, parse_stars)
  end

  local starCount = 0
  for i = 1, 7 do
    if (PARSE_FOUND_STARS[i] or (i == 7 and course <= 15 and course > 0 and gLevelValues.coinsRequiredForCoinStar ~= 255 and gLevelValues.coinsRequiredForCoinStar ~= 0)) then
      ROMHACK.star_data[course][i] = PARSE_FOUND_STARS[i] or 1 -- 100 coin star is always area 1

      if not ROMHACK.starNames[course * 10 + i] then
        ROMHACK.starNames[course * 10 + i] = PARSE_STAR_NAMES[course * 10 + i]
      end

      if course ~= 0 and course ~= 25 then
        if PARSE_MINI_EXCLUDE[i] == 1 then
          exText = exText .. (string.format("[%d%d] = 1,", course, i)) .. "\n"
          ROMHACK.mini_exclude[course * 10 + i] = 1
        elseif PARSE_MINI_EXCLUDE[i] and PARSE_MINI_EXCLUDE[i] ~= 0 then
          exText = exText .. (string.format("[%d%d] = %d,", course, i, PARSE_MINI_EXCLUDE[i])) .. "\n"
          ROMHACK.mini_exclude[course * 10 + i] = PARSE_MINI_EXCLUDE[i]
        end
      end
    else
      ROMHACK.star_data[course][i] = 0
    end
  end
  if PARSE_PRINT then
    print(string.format("[%d] = %d,\n", level, starCount))
  end
  if PARSE_PRINT then
    print(renumText)
    print(exText)
  end
end

-- gets all stars (and star sources, such as King Bob-omb); used with level_script_parse
function parse_stars(area, bhvData, macroBhvIds, macroBhvArgs)
  if macroBhvIds then
    for i, id in pairs(macroBhvIds) do
      parse_stars(nil, { behavior = id, behaviorArg = macroBhvArgs[i] }) -- parse for each macro object
    end
  elseif area and area ~= 0 then
    PARSE_AREA = area
    -- check for slide star
    local surfaceTypeData = smlua_collision_util_find_surface_types(smlua_collision_util_get_level_collision(PARSE_LEVEL, PARSE_AREA))
    for i, floorType in ipairs(surfaceTypeData) do
      if floorType == SURFACE_TIMER_START then
        PARSE_FOUND_STARS[gLevelValues.pssSlideStarIndex+1] = PARSE_AREA | STAR_APPLY_NO_ACTS
        local custom_name = (gLevelValues.pssSlideStarTime//30) .. " Second Challenge (" .. (gLevelValues.pssSlideStarIndex+1) .. ")"
        PARSE_STAR_NAMES[PARSE_COURSE * 10 + gLevelValues.pssSlideStarIndex+1] = custom_name
        if PARSE_PRINT then
          djui_chat_message_create(string.format("%s (C%d, L%d, A%d)", custom_name, PARSE_COURSE, PARSE_LEVEL, PARSE_AREA))
          print(custom_name, PARSE_COURSE, PARSE_AREA)
        end
        break
      end
    end
  elseif bhvData then
    local starNum = 0
    local obj_id = bhvData.behavior
    local byte1 = bhvData.behaviorArg >> 24            -- first byte
    local byte2 = (bhvData.behaviorArg >> 16 & 0x00FF) -- second byte

    local neededByte2
    local custom_name
    if star_sources[obj_id] then
      neededByte2 = star_sources[obj_id][1] or 0
      custom_name = star_sources[obj_id][2]
    end

    local mini_invalid = false

    if star_ids[obj_id] then
      custom_name = "Star"
      starNum = (byte1) + 1
    elseif neededByte2 == true then
      starNum = (byte1) + 1
    elseif neededByte2 == 0xFF then
      if byte2 ~= 0 then
        starNum = (byte1) + 1
      end
    elseif neededByte2 then
      if byte2 == neededByte2 then
        starNum = (byte1) + 1
      end
    elseif obj_id == id_bhvKoopa then -- koopa the quick special case
      if byte2 > 0x01 then
        custom_name = "Race with Koopa The Quick"
        starNum = (byte1) + 1
      end
    elseif obj_id == id_bhvExclamationBox then -- exclamation box special case
      if exclamation_box_valid[byte2] then
        custom_name = "Box Star"

        if byte2 == 8 then
          starNum = (byte1) + 1
        else
          starNum = byte2 - 8
        end
      end
    elseif obj_id == id_bhvToadMessage then -- toad special case
      mini_invalid = true
      custom_name = "Toad Star"
      if byte1 == gBehaviorValues.dialogs.ToadStar1Dialog then
        starNum = 1
      elseif byte1 == gBehaviorValues.dialogs.ToadStar2Dialog then
        starNum = 2
      elseif byte1 == gBehaviorValues.dialogs.ToadStar3Dialog then
        starNum = 3
      end
    elseif obj_id == id_bhvMips then -- mips special case
      mini_invalid = true
      custom_name = "Mips Star"
      if area then -- if the area was set, we're doing mip's second star
        starNum = 5
      else
        -- two stars from mips, perhaps (check if star 2 is disabled)
        if gBehaviorValues.MipsStar2Requirement ~= 255 then
          parse_stars(0, bhvData) -- call again with area set to 0; this normally doesn't happen
        end
        starNum = 4
      end
    end

    if (starNum > 0 and starNum < 8) and (
          not ROMHACK.game_exclude or not ROMHACK.game_exclude[PARSE_COURSE * 10 + starNum] or
          ROMHACK.game_exclude[PARSE_COURSE * 10 + starNum] == PARSE_AREA
        ) then
      custom_name = custom_name .. " (" .. starNum .. ")"

      if PARSE_PRINT then
        djui_chat_message_create(string.format("%s (C%d, L%d, A%d)", custom_name, PARSE_COURSE, PARSE_LEVEL, PARSE_AREA))
        print(custom_name, PARSE_COURSE, PARSE_AREA)
      end

      if not PARSE_FOUND_STARS[starNum] then
        PARSE_FOUND_STARS[starNum] = PARSE_AREA | STAR_APPLY_NO_ACTS
      else
        PARSE_FOUND_STARS[starNum] = PARSE_FOUND_STARS[starNum] & ~STAR_AREA_MASK
        PARSE_FOUND_STARS[starNum] = PARSE_FOUND_STARS[starNum] | (STAR_MULTIPLE_AREAS << (PARSE_AREA - 1))
      end

      if mini_invalid and not PARSE_MINI_EXCLUDE[starNum] then
        PARSE_MINI_EXCLUDE[starNum] = 1
      elseif PARSE_AREA ~= 1 and (not mini_invalid) then
        PARSE_MINI_EXCLUDE[starNum] = PARSE_AREA
      else
        PARSE_MINI_EXCLUDE[starNum] = 0
      end

      if ROMHACK.vagueName or PARSE_COURSE > 15 or PARSE_COURSE == 0 then
        PARSE_STAR_NAMES[PARSE_COURSE * 10 + starNum] = custom_name
      end
    end
  end
end

-- exteme edition and game area support, and sets minihunt level as beginning
function warp_beginning(returnInfo)
  local warpLevel, warpArea, warpAct, warpNode = 0, 0, 0, -1
  warpCooldown = 0
  if gGlobalSyncTable.mhMode == 2 and gGlobalSyncTable.mhState ~= 0 then
    local correctAct = gGlobalSyncTable.getStar

    local course = get_level_course_num(gGlobalSyncTable.gameLevel)
    local area = (ROMHACK.mini_exclude and ROMHACK.mini_exclude[course * 10 + correctAct]) or 1
    if gGlobalSyncTable.ee then area = 2 end

    if correctAct == 7 then correctAct = 6 end
    if course == 0 then correctAct = 0 end
    warpLevel, warpArea, warpAct = gGlobalSyncTable.gameLevel, area, correctAct
  elseif gGlobalSyncTable.mhState == 0 and LEVEL_LOBBY and not ROMHACK.noLobby then
    gMarioStates[0].health = 0x880
    warpLevel, warpArea, warpAct = LEVEL_LOBBY, 1, 0 -- go to custom lobby!
  elseif entryArea ~= 1 or entryNode ~= 0 then
    warpLevel, warpArea, warpAct = gLevelValues.entryLevel, entryArea, 0
    warpNode = (entryNode == 0) and -1 or entryNode
  elseif gGlobalSyncTable.ee then
    gMarioStates[0].health = 0x880
    warpLevel, warpArea, warpAct = gLevelValues.entryLevel, 2, 0
  else
    gMarioStates[0].health = 0x880
    if not returnInfo then
      return warp_to_start_level()
    else
      warpLevel, warpArea, warpAct, warpNode = gLevelValues.entryLevel, 1, 0, 10
      if is_vanilla_like() and warpLevel == LEVEL_CASTLE_GROUNDS then
        warpNode = 3 -- death node
      end
    end
  end

  if warpLevel == 0 then return end

  if not returnInfo then
    if warpNode == -1 then
      return warp_to_level(warpLevel, warpArea, warpAct)
    else
      return warp_to_warpnode(warpLevel, warpArea, warpAct, warpNode)
    end
  end
  return warpLevel, warpArea, warpAct, warpNode
end

-- updates information when the game area is changed, such as the Exit To Castle level and such
entryArea = 1
entryNode = 0
function update_game_area(area)
  local data = ROMHACK and ROMHACK.gameAreaData and ROMHACK.gameAreaData[area+1]
  if not data then return end

  gLevelValues.entryLevel = data.entryLevel
  entryNode = data.entryNode or 0
  entryArea = data.entryArea or 1
  gLevelValues.exitCastleArea = data.exitCastleArea or 1
  gLevelValues.exitCastleLevel = data.exitCastleLevel
  gLevelValues.exitCastleWarpNode = data.exitCastleWarpNode
  -- load only the category setting
  if network_is_server() then
    local fileName = string.gsub(gGlobalSyncTable.romhackFile, " ", "_")
    local toLoad = "starRun"
    if area ~= 0 then
      toLoad = tostring(area) .. "_" .. toLoad
    end
    if fileName ~= "vanilla" then
      toLoad = fileName .. "_" .. toLoad
    end
    local starRun = tonumber(mod_storage_load(toLoad)) or data.default_stars or ROMHACK.default_stars or -1
    gGlobalSyncTable.starRun = math.floor(starRun)
  end
end

-- checks if ROMHACK.ddd is set, either for vanilla or LM64
-- if checkDDD is true, it also checks if our game area has the ddd flag
function is_vanilla_like(checkDDD)
  if not (ROMHACK and ROMHACK.ddd) then return false end
  if checkDDD and gGlobalSyncTable.gameArea ~= 0 then
    return ROMHACK.gameAreaData and ROMHACK.gameAreaData[gGlobalSyncTable.gameArea+1] and ROMHACK.gameAreaData[gGlobalSyncTable.gameArea+1].ddd
  end
  return true
end

-- deletes certain objects when their star conditions are met
function deleteStarRoadStuff(m)
  local starCategory = gGlobalSyncTable.starRun or -1
  --if (gGlobalSyncTable.gameArea ~= 2) and (not gGlobalSyncTable.freeRoam) and (starCategory == -1 or starCategory > m.numStars) then return end -- only if have enough for run
  local np = gNetworkPlayers[0]
  if m.playerIndex ~= 0 or np.currCourseNum ~= COURSE_NONE then return end                                           -- only for local and in castle

  local obj = obj_get_first(OBJ_LIST_SURFACE)
  while obj do
    local objID = get_id_from_behavior(obj.behavior)
    local starsNeeded = 1000
    if objID == bhvSMSRStarDoor then
      starsNeeded = (obj.oBehParams >> 24)
    elseif objID == bhvSMSR30StarDoorWall then
      starsNeeded = 0 -- always erase
    elseif objID == bhvSMSRHiddenAt120Stars then
      starsNeeded = 65
      if gGlobalSyncTable.gameArea ~= 0 then
        local data = ROMHACK and ROMHACK.gameAreaData and ROMHACK.gameAreaData[gGlobalSyncTable.gameArea + 1]
        if data and data.doorCost and data.doorCost[starsNeeded] then
          starsNeeded = data.doorCost[starsNeeded]
        end
      end
    elseif objID == bhvMhCustomDoor then
      -- adjust 30 star doors to actually be 30 star doors
      if (obj.oBehParams >> 24) == 4 then
        local newCount = 30
        if gGlobalSyncTable.gameArea ~= 0 then
          local data = ROMHACK and ROMHACK.gameAreaData and ROMHACK.gameAreaData[gGlobalSyncTable.gameArea + 1]
          if data and data.doorCost and data.doorCost[newCount] then
            newCount = data.doorCost[newCount]
          end
        end

        obj.oBehParams = (obj.oBehParams & 0xFFFFFF) | (newCount << 24)
        if newCount == 8 then
          obj_set_model_extended(obj, E_MODEL_CASTLE_DOOR_1_STAR)
        end
      end
    end
    if starsNeeded ~= 1000 and starCategory ~= -1 and starsNeeded > starCategory then
      starsNeeded = starCategory
    end
    if (starsNeeded ~= 1000 and (gGlobalSyncTable.freeRoam or m.numStars >= starsNeeded)) then
      print("deleted", objID, get_behavior_name_from_id(objID), (obj.oBehParams >> 24))
      obj_mark_for_deletion(obj)
      return
    end
    obj = obj_get_next(obj)
  end
end

-- sets up the minihunt blacklist using an encrypted value and mini_exclude
function setup_mini_blacklist(blacklistData)
  mini_blacklist = {}
  if blacklistData and blacklistData ~= "none" then
    decrypt_black(blacklistData)
  elseif ROMHACK.mini_exclude then
    for id, value in pairs(ROMHACK.mini_exclude) do
      if value == 1 then
        mini_blacklist[id] = 1
      end
    end
  end
end

-- takes the encrypted data and returns the blacklist
function decrypt_black(blacklistData)
  mini_blacklist = {}
  if ROMHACK and ROMHACK.customBlackLoad then
    ROMHACK.customBlackLoad(mini_blacklist, blacklistData)
    return
  end

  local i = 0
  for course = 1, 24 do -- exclude ending
    if string.len(blacklistData) <= i - 1 then break end

    local courseData = tonumber("0x" .. string.sub(blacklistData, i + 1, i + 2)) or 0
    --print(courseData)
    for act = 1, 7 do
      if (courseData & 2 ^ (act - 1)) ~= 0 then
        mini_blacklist[course * 10 + act] = 1
        --djui_chat_message_create(tostring(courseData))
      end
    end
    -- unused because we don't store course 0
    --[[if (courseData & 128) ~= 0 then -- use star 8 of other courses as course 0
      mini_blacklist[course] = 1
      --print(0,course)
    end]]
    i = i + 2
  end
end

-- encrypts the blacklist into one number value
function encrypt_black()
  if ROMHACK and ROMHACK.customBlackSave then
    return ROMHACK.customBlackSave(mini_blacklist)
  end

  local fullEncrypt = ""
  local encrypted = "00"
  for course = 1, 24 do -- exclude ending
    local courseData = 0
    for act = 1, 7 do
      local doCourse = course
      local doAct = act
      -- unused because we don't store course 0
      --[[if act == 8 then -- use act 8 for course 0
        if course > 7 then break end
        doAct = course
        doCourse = 0
      end]]
      if mini_blacklist[doCourse * 10 + doAct] then
        courseData = courseData + 2 ^ (act - 1)
      end
    end
    --djui_chat_message_create(string.format("%02x",courseData))
    fullEncrypt = fullEncrypt .. string.format("%02x", courseData)
    if courseData ~= 0 then
      encrypted = fullEncrypt
    end
  end
  return encrypted
end

-- runs for all players unless dontReload is true
function on_black_changed(tag, oldVal, newVal)
  if oldVal ~= newVal and (not dontReload) then
    print("updated blacklist")
    setup_mini_blacklist(newVal)
  elseif dontReload then
    dontReload = false
  end
end

hook_on_sync_table_change(gGlobalSyncTable, "blacklistData", "blacklist_change", on_black_changed)

-- stars to track (replicas and such are in romhack_data)
star_ids = {
  [id_bhvStar] = "bhvStar",
  [id_bhvSpawnedStar] = "bhvSpawnedStar",
  [id_bhvSpawnedStarNoLevelExit] = "bhvSpawnedStarNoLevelExit",
  [id_bhvStarSpawnCoordinates] = "bhvStarSpawnCoordinates",
}

-- other sources for stars (again, more in romhack_data)
-- The second argument is:
-- TRUE if the 2nd byte doesn't matter
-- 0xFF for any non-zero value for the second byte
-- some other number value for the second byte being equal to such
-- exclamation boxes, KTQ, toad, mips, and piranha plants are special cases
star_sources = {
  [id_bhvKingBobomb] = { true, "Big Battle with King Bob-Omb" },
  [id_bhvWhompKingBoss] = { true, "Chip Off Whomp's Block" },
  [id_bhvHiddenRedCoinStar] = { true, "Find The Red Coins" },
  [id_bhvBowserCourseRedCoinStar] = { true, "Find The Red Coins" },
  [id_bhvHiddenStar] = { true, "5 Hidden Secrets" },
  [id_bhvTuxiesMother] = { true, "Li'l Penguin Lost" },
  [id_bhvWigglerHead] = { true, "Make Wiggler Squirm" },
  [id_bhvEyerokBoss] = { true, "Hand to Hand with Eyerok" },
  [id_bhvBalconyBigBoo] = { true, "Bout with Big Boo" },
  [id_bhvGhostHuntBigBoo] = { true, "Go On A Ghost Hunt" },
  [id_bhvMerryGoRoundBooManager] = { true, "Merry Go Round" },
  [id_bhvTreasureChests] = { true, "Puzzle of the Chests" },
  [id_bhvTreasureChestsJrb] = { true, "Puzzle of the Chests" },
  [id_bhvRacingPenguin] = { true, "Penguin Race" },
  [id_bhvUnagi] = { 0x01, "Can The Eel Come Out To Play?" }, -- Is this correct?
  [id_bhvSnowmansHead] = { true, "Snowman's Lost His Head" },
  [id_bhvBigBully] = { true, "Battle the Big Bully" },
  [id_bhvBigChillBully] = { true, "Chill With The Bully" },
  [id_bhvBigBullyWithMinions] = { true, "Bully The Bullies" },
  [id_bhvCcmTouchedStarSpawn] = { true, "Sliding Star" },
  [id_bhvMrI] = { 0xFF, "Eye To Eye" }, -- any set byte
  [id_bhvMantaRay] = { true, "The Manta Ray's Reward" },
  [id_bhvJetStreamRingSpawner] = { true, "Through The Jet Stream" },
  [id_bhvKlepto] = { 0xFF, "In The Talons Of The Big Bird" },      -- any set byte
  [id_bhvUkikiCage] = { true, "Mystery Of The Monkey Cage" },
  [id_bhvFirePiranhaPlant] = { 0xFF, "Pluck The Piranha Plants" }, -- any set byte
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

string_to_level = {
  ["grounds"] = LEVEL_CASTLE_GROUNDS,
  ["castle"] = LEVEL_CASTLE,
  ["courtyard"] = LEVEL_CASTLE_COURTYARD,
  ["bob"] = LEVEL_BOB,     -- Course 1
  ["wf"] = LEVEL_WF,       -- Course 2
  ["jrb"] = LEVEL_JRB,     -- Course 3
  ["ccm"] = LEVEL_CCM,     -- Course 4
  ["bbh"] = LEVEL_BBH,     -- Course 5
  ["hmc"] = LEVEL_HMC,     -- Course 6
  ["lll"] = LEVEL_LLL,     -- Course 7
  ["ssl"] = LEVEL_SSL,     -- Course 8
  ["ddd"] = LEVEL_DDD,     -- Course 9
  ["sl"] = LEVEL_SL,       -- Course 10
  ["wdw"] = LEVEL_WDW,     -- Course 11
  ["ttm"] = LEVEL_TTM,     -- Course 12
  ["thi"] = LEVEL_THI,     -- Course 13
  ["ttc"] = LEVEL_TTC,     -- Course 14
  ["rr"] = LEVEL_RR,       -- Course 15
  ["bitdw"] = LEVEL_BITDW, -- Course 16
  ["b1"] = LEVEL_BOWSER_1,
  ["bitfs"] = LEVEL_BITFS, -- Course 17
  ["b2"] = LEVEL_BOWSER_2,
  ["bits"] = LEVEL_BITS,   -- Course 18
  ["b3"] = LEVEL_BOWSER_3,
  ["pss"] = LEVEL_PSS,     -- Course 19
  ["cotmc"] = LEVEL_COTMC, -- Course 20
  ["totwc"] = LEVEL_TOTWC, -- Course 21
  ["vcutm"] = LEVEL_VCUTM, -- Course 22
  ["wmotr"] = LEVEL_WMOTR, -- Course 23
  ["sa"] = LEVEL_SA,       -- Course 24
  ["end"] = LEVEL_ENDING,  -- Course 25
}
string_to_course = {
  ["grounds"] = COURSE_NONE,
  ["castle"] = COURSE_NONE,
  ["courtyard"] = COURSE_NONE,
  ["bob"] = COURSE_BOB,      -- Course 1
  ["wf"] = COURSE_WF,        -- Course 2
  ["jrb"] = COURSE_JRB,      -- Course 3
  ["ccm"] = COURSE_CCM,      -- Course 4
  ["bbh"] = COURSE_BBH,      -- Course 5
  ["hmc"] = COURSE_HMC,      -- Course 6
  ["lll"] = COURSE_LLL,      -- Course 7
  ["ssl"] = COURSE_SSL,      -- Course 8
  ["ddd"] = COURSE_DDD,      -- Course 9
  ["sl"] = COURSE_SL,        -- Course 10
  ["wdw"] = COURSE_WDW,      -- Course 11
  ["ttm"] = COURSE_TTM,      -- Course 12
  ["thi"] = COURSE_THI,      -- Course 13
  ["ttc"] = COURSE_TTC,      -- Course 14
  ["rr"] = COURSE_RR,        -- Course 15
  ["bitdw"] = COURSE_BITDW,  -- Course 16
  ["b1"] = COURSE_BITDW,
  ["bitfs"] = COURSE_BITFS,  -- Course 17
  ["b2"] = COURSE_BITFS,
  ["bits"] = COURSE_BITS,    -- Course 18
  ["b3"] = COURSE_BITS,
  ["pss"] = COURSE_PSS,      -- Course 19
  ["cotmc"] = COURSE_COTMC,  -- Course 20
  ["totwc"] = COURSE_TOTWC,  -- Course 21
  ["vcutm"] = COURSE_VCUTM,  -- Course 22
  ["wmotr"] = COURSE_WMOTR,  -- Course 23
  ["sa"] = COURSE_SA,        -- Course 24
  ["end"] = COURSE_CAKE_END, -- Course 25
}