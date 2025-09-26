-- based on arena; this handles object radars and the minimap, also some texture stuff

-- this reduces lag apparently
local djui_hud_set_color, get_texture_info, djui_hud_render_texture_interpolated, djui_hud_set_resolution, clamp, network_get_player_text_color_string, obj_has_model_extended =
    djui_hud_set_color, get_texture_info, djui_hud_render_texture_interpolated, djui_hud_set_resolution, clamp,
    network_get_player_text_color_string, obj_has_model_extended

TEX_RAD = get_texture_info('runner-mark')
TEX_STAR = get_texture_info('star-mark')
TEX_BOX = get_texture_info('box-mark')
TEX_COIN = get_texture_info('coin-mark')
TEX_SECRET = get_texture_info('secret-mark')
TEX_DEMON = get_texture_info('demon-mark')
TEX_MOON = get_texture_info('moon-mark')
TEX_RAD_TARGET = get_texture_info('target-mark')
TEX_MAP_ARROW = get_texture_info('map-arrow')
TEX_KEY = get_texture_info('key-mark')
TEX_SPOTLIGHT = get_texture_info('spotlight')
SABO_TARGET_TEX = {
  get_texture_info('bomb_sabo_target'),
  get_texture_info('tox_sabo_target'),
  get_texture_info('dark_sabo_target'),
}

-- radars
icon_radar = {}
star_radar = {}
box_radar = {}
for i = 1, (MAX_PLAYERS - 1) do
  icon_radar[i] = { tex = TEX_RAD, prevX = 0, prevY = 0, prevScale = 0.6 }
end
for i = 1, 7 do
  star_radar[i] = { tex = TEX_STAR, prevX = 0, prevY = 0, prevScale = 0.6 }
end
for i = 1, 7 do
  box_radar[i] = { tex = TEX_BOX, prevX = 0, prevY = 0, prevScale = 0.6 }
end
ex_radar = {}
ex_radar[1] = { tex = TEX_COIN, prevX = 0, prevY = 0, prevScale = 0.6 }
ex_radar[2] = { tex = TEX_SECRET, prevX = 0, prevY = 0, prevScale = 0.6 }
ex_radar[3] = { tex = TEX_DEMON, prevX = 0, prevY = 0, prevScale = 0.6 }
ex_radar[4] = { tex = TEX_RAD_TARGET, prevX = 0, prevY = 0, prevScale = 0.6 }

radar_store = {} -- used with objects

-- minimap
TEX_HUD_BOX = get_texture_info('exclamation_box_seg8_texture_08017628')
TEX_HUD_DEMON = get_texture_info('hud_demon')
TEX_HUD_TARGET = get_texture_info('hud_target')
TEX_HUD_KEY_LEFT = get_texture_info('bowser_key_left_texture')
TEX_HUD_KEY_RIGHT = get_texture_info('bowser_key_right_texture')
icon_minimap = {}
star_minimap = {}
box_minimap = {}
for i = 0, (MAX_PLAYERS - 1) do
  icon_minimap[i] = { tex = nil, prevX = 0, prevY = 0 } -- overriden with this character's head
end
for i = 1, 7 do
  star_minimap[i] = { tex = gTextures.star, prevX = 0, prevY = 0 }
end
for i = 1, 7 do
  box_minimap[i] = { tex = TEX_HUD_BOX, prevX = 0, prevY = 0 }
end
ex_minimap = {}
ex_minimap[1] = { tex = gTextures.coin, prevX = 0, prevY = 0 }
ex_minimap[2] = { tex = nil, prevX = 0, prevY = 0 } -- overriden with "S" in hud font
ex_minimap[3] = { tex = TEX_HUD_DEMON, prevX = 0, prevY = 0 }
ex_minimap[4] = { tex = TEX_HUD_TARGET, prevX = 0, prevY = 0 }

defaultStarColor = { r = 255, g = 255, b = 92 } -- yellow

-- also includes texture data for stats
TEX_FLAG = get_texture_info('stat-flag')
TEX_POLE = get_texture_info('stat-flag-pole')
TEX_MULTI_STARS = get_texture_info('stat-stars')
TEX_BOOT = get_texture_info('stat-kill')
TEX_MULTI_BOOT = get_texture_info('stat-multikill')
TEX_MEDAL = get_texture_info('stat-medal')
TEX_ARROW = get_texture_info('stat-arrow')
TEX_WATCH = get_texture_info('stat-watch')
TEX_WATCH_OMM = get_texture_info('stat-watch-omm')
TEX_WATCH_OTHER = get_texture_info('stat-watch-other')
TEX_MAG_GLASS = get_texture_info('stat-mag')
stat_icon_data = {}
stat_icon_data_alt1 = {}
stat_icon_data_alt2 = {}
stat_icon_data[1] = { tex = TEX_FLAG, r = 255, g = 255, b = 92 }
stat_icon_data[2] = { tex = TEX_STAR, r = 255, g = 255, b = 92 }
stat_icon_data[3] = { tex = TEX_MAG_GLASS, r = 255, g = 255, b = 92 }
stat_icon_data[4] = { tex = TEX_BOOT, r = 255, g = 255, b = 255 }
stat_icon_data[5] = { tex = TEX_MULTI_BOOT, r = 255, g = 255, b = 255 }
stat_icon_data[6] = { tex = TEX_MULTI_STARS, r = 255, g = 255, b = 92 }
stat_icon_data[7] = { tex = TEX_MEDAL, r = 255, g = 255, b = 255 }
stat_icon_data[8] = { tex = TEX_WATCH, r = 255, g = 255, b = 255 }
stat_icon_data[9] = { tex = TEX_WATCH, r = 80, g = 255, b = 80 }

-- hard and extreme (and parkour record)
stat_icon_data_alt1[1] = { tex = TEX_FLAG, r = 255, g = 92, b = 92 }
stat_icon_data_alt1[2] = { tex = TEX_STAR, r = 255, g = 92, b = 92 }
stat_icon_data_alt1[3] = { tex = TEX_MAG_GLASS, r = 255, g = 92, b = 92 }
stat_icon_data_alt1[8] = { tex = TEX_WATCH_OMM, r = 255, g = 255, b = 255 }
stat_icon_data_alt2[1] = { tex = TEX_FLAG, r = 180, g = 92, b = 255 }
stat_icon_data_alt2[2] = { tex = TEX_STAR, r = 180, g = 92, b = 255 }
stat_icon_data_alt2[3] = { tex = TEX_MAG_GLASS, r = 180, g = 92, b = 255 }
stat_icon_data_alt2[8] = { tex = TEX_WATCH_OTHER, r = 255, g = 255, b = 255 }

local rainbow_counter = 0
function render_radar(m, radarData, mapData, isObj, objType, mapOnly)
  djui_hud_set_resolution(RESOLUTION_N64)
  local pos = {}
  local o = m
  if not isObj then
    pos = { x = m.pos.x, y = m.pos.y + 80, z = m.pos.z } -- mario is 161 units tall
  else
    pos = { x = o.oPosX, y = o.oPosY, z = o.oPosZ }
    if objType == "box" then                          -- box's position is a bit higher
      pos.y = pos.y + 50
    elseif objType == "secret" then                   -- secrets have a misleading hitbox (although they aren't usually visible)
      pos.y = pos.y + 15
    elseif objType == "demon" then                    -- 1ups also have a misleading hitbox
      pos.y = pos.y + o.hitboxHeight
    elseif objType == "coin" or objType == "key" then -- these have their position centered at their bottom, so move up based on hitbox size
      pos.y = pos.y + o.hitboxHeight // 2
    end
  end

  local screenWidth = djui_hud_get_screen_width()
  local screenHeight = djui_hud_get_screen_height()

  local validRunnerTarget = -1
  if not isObj then
    validRunnerTarget = get_targetted_runner()
  end

  -- minimap render
  if showMiniMap and not is_game_paused() then
    local renderSize = 80
    local x = screenWidth - 90
    local y = screenHeight - 120

    local tex = mapData.tex
    if objType == "key" then
      tex = TEX_HUD_KEY_LEFT
    end

    local level = gNetworkPlayers[0].currLevelNum
    local area = gNetworkPlayers[0].currAreaIndex
    if ROMHACK.minimap_data and ROMHACK.minimap_data[level * 10 + area] and ROMHACK.minimap_data[level * 10 + area][2] then
      levelSize = ROMHACK.minimap_data[level * 10 + area][2]
    elseif not is_vanilla_like() then
      while pos.x > levelSize + 5 or pos.x < -levelSize - 5 or pos.z > levelSize + 5 or pos.z < -levelSize - 5 do -- adjust size if oob
        levelSize = levelSize * 2
      end
    end
    local xScaled = (pos.x / (levelSize * 2) + 0.5)
    local yScaled = (pos.z / (levelSize * 2) + 0.5)

    if objType == "coin" then
      if ROMHACK.coinColor then
        djui_hud_set_color(ROMHACK.coinColor.r, ROMHACK.coinColor.g, ROMHACK.coinColor.b, 255)
      else
        djui_hud_set_color(255, 0, 0, 255) -- red
      end
    elseif objType == "secret" then
      local scale = 0.5
      local renderX = x + xScaled * renderSize - 8 * scale
      local renderY = y + yScaled * renderSize - 8 * scale
      djui_hud_set_color(255, 255, 255, 255)
      djui_hud_set_font(FONT_HUD)
      djui_hud_print_text("S", renderX, renderY, 0.5)
      mapData.prevX = renderX
      mapData.prevY = renderY
    elseif objType == "sabo" then
      djui_hud_set_color(255, 255, 255, 255)
      tex = SABO_TARGET_TEX[gGlobalSyncTable.saboActive] or tex
    elseif isObj and objType == nil then
      local r, g, b = 255, 255, 255
      if OmmEnabled and month ~= 14 and ROMHACK and ROMHACK.ommColorStar then
        -- do colored radar
        local starColor = 0
        if (ROMHACK.starColor or omm_star_colors[o.oAnimState]) and OmmApi.omm_get_setting(gMarioStates[0], "color") ~= 0 then
          starColor = o.oAnimState
        end
        tex = get_texture_info("omm_tex_hud_star_" .. starColor)
        r, g, b = 255, 255, 255
      elseif gGlobalSyncTable.ee and not (OmmEnabled and OmmApi.omm_get_setting(gMarioStates[0], "color") ~= 0) then
        r, g, b = 255, 0, 0 -- red
      end
      djui_hud_set_color(r, g, b, 255)
    else
      djui_hud_set_color(255, 255, 255, 255)
    end

    local scale = 0.5
    local texWidthHalf = 8
    if objType == "key" then
      texWidthHalf = 32
      scale = scale / 4
    elseif tex then
      texWidthHalf = tex.width * 0.5
      scale = scale / tex.width * 16
    end
    if (not isObj) and gPlayerSyncTable[0].spectator == 1 and spectateFocus == m.playerIndex and free_camera ~= 1 then
      scale = 0.6
    end

    local renderX = x + xScaled * renderSize - texWidthHalf * scale
    local renderY = y + yScaled * renderSize - texWidthHalf * scale

    if not isObj then
      render_player_head(m.playerIndex, renderX, renderY, scale, scale)

      local playercolor = network_get_player_text_color_string(m.playerIndex)
      local r, g, b = convert_color(playercolor)
      djui_hud_set_color(r, g, b, 155)
      djui_hud_set_rotation(m.faceAngle.y, 0.5, 0.5)
      djui_hud_render_texture(TEX_MAP_ARROW, renderX - 8 * scale, renderY - 8 * scale, scale, scale)
      djui_hud_set_rotation(0, 0, 0)
      
      if validRunnerTarget == m.playerIndex then
        r, g, b = get_radar_color(validRunnerTarget)
        djui_hud_set_color(r, g, b, 200)
        djui_hud_render_texture(TEX_HUD_TARGET, renderX, renderY, scale, scale)
      end
    elseif tex then
      djui_hud_render_texture_interpolated(tex, mapData.prevX, mapData.prevY, scale, scale, renderX, renderY, scale,
        scale)
      if tex == TEX_HUD_KEY_LEFT then
        djui_hud_render_texture_interpolated(TEX_HUD_KEY_RIGHT, mapData.prevX + scale * 32, mapData.prevY, scale, scale, renderX + scale * 32, renderY, scale,
        scale)
      end
      mapData.prevX = renderX
      mapData.prevY = renderY
    end
  end

  if mapOnly or (not showRadar) then return end

  local out = { x = 0, y = 0, z = 0 }
  djui_hud_world_pos_to_screen_pos(pos, out)

  local dX = out.x
  local dY = out.y

  local dist = vec3f_dist(pos, gMarioStates[0].pos)
  local alpha = clamp(dist, 0, 1200) - 1000
  if alpha <= 0 then
    return
  end

  if out.z > -260 then
    local cdist = vec3f_dist(pos, gLakituState.pos)
    if (dist < cdist) then
      dY = 0
    else
      dY = screenHeight
    end
  end

  local r, g, b = 0, 0, 0
  local tex = radarData.tex or TEX_STAR
  if not isObj then
    if validRunnerTarget == m.playerIndex then
      tex = TEX_RAD_TARGET
    end
    r, g, b = get_radar_color(m.playerIndex)
  elseif objType == "box" or objType == "demon" then
    r, g, b = 255, 255, 255 -- texture has color
    alpha = alpha - 100
    if alpha <= 0 then
      return
    end
  elseif objType == "coin" then
    r, g, b = 255, 0, 0 -- red coin
    alpha = alpha - 100
    if alpha <= 0 then
      return
    elseif ROMHACK.coinColor then
      r, g, b = ROMHACK.coinColor.r, ROMHACK.coinColor.g, ROMHACK.coinColor.b
    end
  elseif objType == "secret" then
    r, g, b = 0, 255, 0 -- green
    alpha = alpha - 100
    if alpha <= 0 then
      return
    end
  elseif objType == "key" then
    tex = TEX_KEY
    r, g, b = 255, 194, 0
  elseif objType == "sabo" then
    r, g, b = 255, 255, 255
    tex = SABO_TARGET_TEX[gGlobalSyncTable.saboActive] or tex
  else
    if ROMHACK.isMoonshine then
      tex = TEX_MOON
    end

    if OmmEnabled and month ~= 14 and ROMHACK and ROMHACK.ommColorStar and (ROMHACK.starColor or omm_star_colors[o.oAnimState]) and OmmApi.omm_get_setting(gMarioStates[0], "color") ~= 0 then
      -- do colored radar
      local starColor = omm_star_colors[o.oAnimState]
      r, g, b = starColor.r, starColor.g, starColor.b
    elseif gGlobalSyncTable.ee and not (OmmEnabled and OmmApi.omm_get_setting(gMarioStates[0], "color") ~= 0) then
      r, g, b = 255, 0, 0 -- red
    else
      r, g, b = defaultStarColor.r, defaultStarColor.g, defaultStarColor.b
    end
    alpha = alpha - 100
    if alpha <= 0 then
      return
    end
  end

  local scale = clamp(dist, 0, 2400) / 4000
  local width = tex.width * scale
  dX = dX - width * 0.5
  dY = dY - width * 0.5
  if dX > (screenWidth - width) then
    dX = (screenWidth - width)
  elseif dX < 0 then
    dX = 0
  end
  if dY > (screenHeight - width) then
    dY = (screenHeight - width)
  elseif dY < 0 then
    dY = 0
  end
  djui_hud_set_color(r, g, b, alpha)
  djui_hud_render_texture_interpolated(tex, radarData.prevX, radarData.prevY, radarData.prevScale, radarData.prevScale,
    dX, dY,
    scale, scale)
  --[[if not objType then
    djui_hud_set_font(FONT_HUD)
    djui_hud_print_text_interpolated(tostring((obj.oBehParams >> 24) + 1), radarData.prevX, radarData.prevY, 0.6, dX, dY, 0.6)
  end]]

  radarData.prevScale = scale
  radarData.prevX = dX
  radarData.prevY = dY
end

local maxStar = -1
function render_radar_act_select()
  djui_hud_set_resolution(RESOLUTION_N64)
  djui_hud_set_font(FONT_RECOLOR_HUD)
  --local screenWidth = djui_hud_get_screen_width()
  --local screenHeight = djui_hud_get_screen_height()

  local alpha = 200
  local course = gNetworkPlayers[0].currCourseNum
  local stars = save_file_get_star_flags(get_current_save_file_num() - 1, course - 1)

  if maxStar == -1 then
    local allInRow = true
    local missing = false
    for i = 0, 5 do
      if stars & 2 ^ i ~= 0 then
        maxStar = i
        if missing then
          allInRow = false
        end
      else
        missing = true
      end
    end

    if maxStar == -1 then
      maxStar = 0
    elseif allInRow and maxStar < 5 then
      maxStar = maxStar + 1
    end
  end

  if gGlobalSyncTable.mhMode ~= 3 then
    local validRunnerTarget = get_targetted_runner()

    for i = 1, (MAX_PLAYERS - 1) do
      local act = 0
      local np = gNetworkPlayers[i]
      local sMario = gPlayerSyncTable[i]
      if np and np.connected and sMario.team == 1 and np.currCourseNum == course and np.currActNum ~= 0 then
        act = np.currActNum

        if act <= maxStar + 1 then
          local dX = (-maxStar * 17 + act * 34) + djui_hud_get_screen_width() * 0.5 - 32
          local dY = 64

          local r, g, b = get_radar_color(i)
          local tex = TEX_RAD
          if validRunnerTarget == i then
            tex = TEX_RAD_TARGET
          end

          local scale = 1
          local width = tex.width * scale
          dX = dX - width * 0.5
          dY = dY - width * 0.5
          djui_hud_set_color(r, g, b, alpha)
          djui_hud_render_texture(tex, dX, dY, scale, scale)
        end
      end
    end
  else
    for act = 1, maxStar + 1 do
      local playerCountHere, isHunter = get_player_and_corpse_count(course, 0, 0, act)
      local saboLocation = get_sabo_location_table()
      local saboHere = (get_active_sabo() ~= 0 and saboLocation.course == course and saboLocation.act == act)
      if playerCountHere ~= 0 or saboHere then
        local dX = (139 - maxStar * 17 + act * 34) + djui_hud_get_screen_width() * 0.5 - 171
        local dY = 80

        local text = tostring(playerCountHere)
        local scale = 1
        local width = djui_hud_measure_text(text) * scale
        dX = dX - width * 0.5
        dY = dY - 32 * scale
        if saboHere then
          local tex = SABO_TARGET_TEX[gGlobalSyncTable.saboActive] or TEX_RAD_TARGET
          local width = tex.width * scale
          local dX = (-maxStar * 17 + act * 34) + djui_hud_get_screen_width() * 0.5 - 32
          local dY = 64
          dX = dX - width * 0.5
          dY = dY - width * 0.5
          djui_hud_set_color(255, 255, 255, alpha)
          djui_hud_render_texture(tex, dX, dY, scale, scale)
          if playerCountHere == 0 then return end
        end
        if isHunter then
          djui_hud_set_color(0, 255, 255, alpha)
        else
          djui_hud_set_color(169, 169, 169, alpha)
        end
        djui_hud_print_text(text, dX, dY, scale)
      end
    end
  end
end

-- really great feature tbh (also used for mysteryhunt radars and L button prompt)
local warpObjs = { id_bhvWarp, id_bhvWarpPipe, id_bhvDoorWarp, id_bhvFadingWarp, id_bhvWarp, id_bhvBooCage, id_bhvMHWingCapWarp }
local progressRadar = {}
local progressMinimap = {}
function painting_overlays_and_mystery_misc(paintingValid)
  local m = gMarioStates[0]
  local np = gNetworkPlayers[0]
  local doneCourses = { [np.currCourseNum] = 1 }
  local warpList = {}

  if (not gPlayerSyncTable[0].dead) and gGlobalSyncTable.mhMode == 3 and (gGlobalSyncTable.mhState == 1 or gGlobalSyncTable.mhState == 2) then
    djui_hud_set_resolution(RESOLUTION_N64)
    djui_hud_set_font(FONT_CUSTOM_HUD)
    djui_hud_set_color(255, 255, 255, 255)
    local o = obj_get_first_with_behavior_id(id_bhvMHCorpse)
    while o do
      local pos = { x = o.oPosX, y = o.oPosY + 210, z = o.oPosZ }
      local out = { x = 0, y = 0, z = 0 }
      if dist_between_objects(m.marioObj, o) < 200 and djui_hud_world_pos_to_screen_pos(pos, out) then
        local text = trans("press_report", buttonString[reportButton])
        local width = djui_hud_measure_text(text)
        djui_hud_print_text(text, out.x - width / 2, out.y, 1)
      end
      o = obj_get_next_with_same_behavior_id(o)
    end
    if gGlobalSyncTable.saboActive ~= 0 then
      o = obj_get_first_with_behavior_id(id_bhvSaboObj)
      if o then
        local pos = { x = o.oPosX, y = o.oPosY + 210, z = o.oPosZ }
        local out = { x = 0, y = 0, z = 0 }
        if dist_between_objects(m.marioObj, o) < 200 and djui_hud_world_pos_to_screen_pos(pos, out) then
          local text = trans("press_fix", buttonString[reportButton])
          local width = djui_hud_measure_text(text)
          djui_hud_print_text(text, out.x - width / 2, out.y, 1)
        end
      end
    end
  end

  -- we know that vanilla (and lm64) only have warps in the castle and HMC (and WDW in the Upper Floor area)
  if is_vanilla_like() and np.currCourseNum ~= 0 and np.currCourseNum ~= COURSE_HMC
  and (gGlobalSyncTable.gameArea ~= 3 or np.currCourseNum ~= COURSE_WDW) then return end

  -- To get the paintings, we use this get_painting_warp_node()
  -- Since it requires that mario be above the painting, we set mario's floor type and floorheight temporarily
  if ROMHACK and (is_vanilla_like() or ROMHACK.name == "B3313") and np.currLevelNum == LEVEL_CASTLE and m.floor then
    local paintingValueTable = {
      gPaintingValues.bob_painting,
      gPaintingValues.ccm_painting,
      gPaintingValues.wf_painting,
      gPaintingValues.jrb_painting,
      gPaintingValues.lll_painting,
      gPaintingValues.ssl_painting,
      gPaintingValues.ttm_slide_painting,
      gPaintingValues.ddd_painting,
      gPaintingValues.wdw_painting,
      gPaintingValues.thi_tiny_painting,
      gPaintingValues.ttm_painting,
      gPaintingValues.ttc_painting,
      gPaintingValues.sl_painting,
      gPaintingValues.thi_huge_painting,
      gPaintingValues.hmc_painting,
    }
    local donePaintings = {}
    local oldFloorType = m.floor.type
    local oldFloorHeight = m.floorHeight
    m.floorHeight = m.pos.y
    for i = 0, 14 do
      m.floor.type = i * 3 + SURFACE_PAINTING_WARP_D3
      local warpNode = get_painting_warp_node()
      local level = (warpNode and warpNode.destLevel) or 0
      if level >= 128 then level = level - 128 end
      if level ~= 0 then
        local course = level_to_course[level] or 0
        if not (doneCourses[course] and donePaintings[i]) then
          doneCourses[course] = 1
          donePaintings[i] = 1 -- so thi huge is seperate
          local area = warpNode.destArea
          local valid = true
          -- don't show if area is banned
          if valid and gGlobalSyncTable.gameArea ~= 0 and ROMHACK and ROMHACK.gameAreaData then
            local areaData = ROMHACK.gameAreaData[gGlobalSyncTable.gameArea+1]
            if areaData and areaData.bannedAreas and areaData.bannedAreas[level * 10 + area] then
              valid = false
            end
          end

          if valid then
            if i == 14 and np.currAreaIndex ~= 3 then -- rainbow ride HAD to be different (it uses hmc painting even though it's nowhere near the warp. Use hardcoded position)
              local pos = { -3400, 3116, 5886 }
              table.insert(warpList, { course, level, area, pos })
            else
              local painting = paintingValueTable[i + 1]
              if painting then
                local pos = { painting.posX, painting.posY, painting.posZ }
                local yawRadians = painting.yaw * math.pi / 180
                pos[1] = math.floor(pos[1] + math.cos(yawRadians) * painting.size * 0.5)
                pos[2] = math.floor(pos[2] + painting.size)
                pos[3] = math.floor(pos[3] - math.sin(yawRadians) * painting.size * 0.5)
                if painting.pitch ~= 0 then -- applies only to hmc
                  local pitchRadians = painting.pitch * math.pi / 180
                  pos[1] = pos[1] + math.cos(pitchRadians) * painting.size * 0.5
                  pos[2] = pos[2] + painting.size * (math.cos(pitchRadians) - 1) + 100
                  pos[3] = pos[3] + math.sin(pitchRadians) * painting.size * 0.5
                end
                table.insert(warpList, { course, level, area, pos, true })
              end
            end
          end
        end
      end
    end
    m.floorHeight = oldFloorHeight
    m.floor.type = oldFloorType
  end

  -- check for wing cap warp
  if m.numStars >= gLevelValues.wingCapLookUpReq then
    local pos = { -1024, 150, 717 }
    local valid = true
    if is_vanilla_like() then
      valid = (np.currLevelNum == LEVEL_CASTLE and np.currAreaIndex == 1) -- hard-coded pos
    else
      -- we don't know where the wing cap warp is; only display if mario is on the surface
      if m.floor and m.floor.type == SURFACE_LOOK_UP_WARP then
        pos = { m.pos.x, m.floorHeight + 300, m.pos.z }
      else
        valid = false
      end
    end
    if valid then
      local objWarpNode = area_get_warp_node(0xF2)
      local warpNode = objWarpNode and objWarpNode.node
      local level = (warpNode and warpNode.destLevel) or 0
      if level >= 128 then level = level - 128 end
      if level ~= 0 then
        local course = level_to_course[level] or 0
        if not doneCourses[course] then
          doneCourses[course] = 1
          local area = warpNode.destArea

          table.insert(warpList, { course, level, area, pos, true })
        end
      end
    end
  end

  -- iterate through all warps now
  for i, id in ipairs(warpObjs) do
    local o = obj_get_first_with_behavior_id(id)
    while o do
      local nodeID = 0
      local objWarpNode
      if o.oBehParams2ndByte ~= 0xEA00 then
        nodeID = (o.oBehParams >> 16) & 0xFF
        objWarpNode = area_get_warp_node(nodeID)
      else -- custom warp nodes
        local level = (o.oBehParams >> 16) & 0xFF
        local area = o.oBehParams & 0xFF
        objWarpNode = {node = {destLevel = level, destArea = area}}
      end
      local warpNode = objWarpNode and objWarpNode.node
      local level = (warpNode and warpNode.destLevel) or 0
      local area = (warpNode and warpNode.destArea) or 0
      if level >= 128 then level = level - 128 end
      if o.oIntangibleTimer == 0 and level ~= 0 then
        local course = level_to_course[level] or 0
        local valid = (not doneCourses[course])
        -- don't show if area is banned
        if valid and gGlobalSyncTable.gameArea ~= 0 and ROMHACK and ROMHACK.gameAreaData then
          local areaData = ROMHACK.gameAreaData[gGlobalSyncTable.gameArea+1]
          if areaData and areaData.bannedAreas and areaData.bannedAreas[level * 10 + area] then
            valid = false
          end
        end

        if valid then
          doneCourses[course] = 1
          local pos = { math.floor(o.oPosX), math.floor(o.oPosY + 300), math.floor(o.oPosZ) }
          local onScreen = true
          -- to prevent confusion, don't show radar for PSS inside of the JRB room
          -- don't show radar for COTMC inside of the PSS room, either (when game area is main floor)
          if is_vanilla_like() and np.currLevelNum == LEVEL_CASTLE and (warpNode.destLevel == LEVEL_PSS or warpNode.destLevel == LEVEL_COTMC) then
            local wrongRoom = 7
            if level == LEVEL_COTMC then wrongRoom = 4 end
            onScreen = (m.currentRoom ~= wrongRoom)
          end
          table.insert(warpList, { course, level, area, pos, onScreen })
        end
      end
      o = obj_get_next_with_same_behavior_id(o)
    end
  end

  --djui_chat_message_create("!!!!!")
  for i, warpData in ipairs(warpList) do
    local course = warpData[1]
    local level = warpData[2]
    local pos = { x = warpData[4][1], y = warpData[4][2], z = warpData[4][3] }
    local fullStarTable = 127
    local maxStarNum = 7
    local totalStars = 7

    local file = 0
    local starFlags = 0
    local exThingy = 0
    local haveExThingy = false
    local playerCountHere, isHunter = get_player_and_corpse_count(course, level, warpData[3])

    if not paintingValid then goto PAINTING_CALC_END end

    if level == LEVEL_BOWSER_1 or level == LEVEL_BOWSER_2 or level == LEVEL_BOWSER_3 then
      fullStarTable = 0
      maxStarNum = 0
      totalStars = 0
    elseif ROMHACK.star_data and ROMHACK.star_data[course] then
      local star_data = ROMHACK.star_data[course]
      if gGlobalSyncTable.ee and ROMHACK.star_data_ee and ROMHACK.star_data_ee[course] then
        star_data = ROMHACK.star_data_ee[course]
      end
      maxStarNum = #star_data
      fullStarTable = 0
      totalStars = 0
      for i, data in ipairs(star_data) do
        if data ~= 0 and (data & STAR_REPLICA == 0 or not ((ROMHACK.replica_start and m.numStars < ROMHACK.replica_start) or (ROMHACK.replica_func and not ROMHACK.replica_func(m.numStars)))) then
          if not (ROMHACK and ROMHACK.checkAreaWarp) then
            fullStarTable = fullStarTable | (1 << (i - 1))
            totalStars = totalStars + 1
          else
            local areaValid = false
            if data < STAR_MULTIPLE_AREAS then
              local area = data & STAR_AREA_MASK
              if area == 8 or warpData[3] == area then
                areaValid = true
              end
            else
              local areas = (data & ~(STAR_MULTIPLE_AREAS - 1))
              if areas & (STAR_MULTIPLE_AREAS << (warpData[3] - 1)) ~= 0 then
                areaValid = true
              end
            end
            if areaValid then
              fullStarTable = fullStarTable | (1 << (i - 1))
              totalStars = totalStars + 1
            end
          end
        end
      end
    elseif course == 0 then
      fullStarTable = 31
      maxStarNum = 5
      totalStars = 5
    elseif course > 15 then
      fullStarTable = 1
      maxStarNum = 1
      totalStars = 1
    end

    file = get_current_save_file_num() - 1
    starFlags = (ROMHACK and ROMHACK.getStarFlagsFunc and ROMHACK.getStarFlagsFunc(file, course - 1)) or
        save_file_get_star_flags(file, course - 1)


    if ROMHACK and (ROMHACK.isMoonshine or ROMHACK.name == "B3313") and level ~= LEVEL_BOWSER_1 and level ~= LEVEL_BOWSER_2 and level ~= LEVEL_BOWSER_3 then
      -- nothing
    elseif course == COURSE_BITDW then
      exThingy = 1
      if save_file_get_flags() & (SAVE_FLAG_HAVE_KEY_1 | SAVE_FLAG_UNLOCKED_BASEMENT_DOOR) ~= 0 then
        haveExThingy = true
      end
    elseif course == COURSE_BITFS then
      exThingy = 1
      if save_file_get_flags() & (SAVE_FLAG_HAVE_KEY_2 | SAVE_FLAG_UNLOCKED_UPSTAIRS_DOOR) ~= 0 then
        haveExThingy = true
      end
    elseif course == COURSE_BITS then
      exThingy = 1 -- not a key technically but whatever
      if gGlobalSyncTable.bowserBeaten then
        haveExThingy = true
      end
    elseif ROMHACK and ROMHACK.noCapDefault then
      -- nothing
    elseif course == COURSE_TOTWC then
      exThingy = 2
      if save_file_get_flags() & (SAVE_FLAG_HAVE_WING_CAP) ~= 0 then
        haveExThingy = true
      end
    elseif course == COURSE_VCUTM then
      exThingy = 3
      if save_file_get_flags() & (SAVE_FLAG_HAVE_VANISH_CAP) ~= 0 then
        haveExThingy = true
      end
    elseif course == COURSE_COTMC then
      exThingy = 4
      if save_file_get_flags() & (SAVE_FLAG_HAVE_METAL_CAP) ~= 0 then
        haveExThingy = true
      end
    end
    ::PAINTING_CALC_END::

    -- minimap render
    if showMiniMap then
      local renderSize = 80
      local screenWidth = djui_hud_get_screen_width()
      local screenHeight = djui_hud_get_screen_height()
      local x = screenWidth - 90
      local y = screenHeight - 120

      local tex = gTextures.star
      local isStar = paintingValid
      if isStar and exThingy ~= 0 and (not haveExThingy) and frameCounter % 60 >= 30 then
        isStar = false
      end

      local level = np.currLevelNum
      local area = np.currAreaIndex
      if ROMHACK.minimap_data and ROMHACK.minimap_data[level * 10 + area] and ROMHACK.minimap_data[level * 10 + area][2] then
        levelSize = ROMHACK.minimap_data[level * 10 + area][2]
      elseif not is_vanilla_like() then
        while pos.x > levelSize + 5 or pos.x < -levelSize - 5 or pos.z > levelSize + 5 or pos.z < -levelSize - 5 do -- adjust size if oob
          levelSize = levelSize * 2
        end
      end
      local xScaled = (pos.x / (levelSize * 2) + 0.5)
      local yScaled = (pos.z / (levelSize * 2) + 0.5)

      local scale = 0.5

      local renderX = x + xScaled * renderSize - 8 * scale
      local renderY = y + yScaled * renderSize - 8 * scale
      local starsLeft = 0

      local mapData = progressMinimap[i]
      if not mapData then
        progressMinimap[i] = { prevX = x, prevY = y }
        mapData = progressMinimap[i]
      end

      if not paintingValid then
        tex = nil
        exThingy = 0
      elseif isStar then
        local collectedStars = 0
        for i = 1, maxStarNum do
          if (fullStarTable & (1 << (i - 1)) ~= 0) and (starFlags & (1 << (i - 1)) ~= 0) then
            collectedStars = collectedStars + 1
            if collectedStars == totalStars then break end
          end
        end
        starsLeft = totalStars - collectedStars
        if starsLeft == 0 then
          isStar = false
          tex = nil
        end
      end

      if exThingy ~= 0 and not (isStar or haveExThingy) then
        if exThingy == 1 then
          tex = TEX_HUD_KEY_LEFT
          scale = scale / 4
        elseif exThingy == 2 then
          tex = get_texture_info("exclamation_box_seg8_texture_08015E28")
          scale = scale / 2
        elseif exThingy == 3 then
          tex = get_texture_info("exclamation_box_seg8_texture_08012E28")
          scale = scale / 2
        else
          tex = get_texture_info("exclamation_box_seg8_texture_08014628")
          scale = scale / 2
        end
      end

      if tex then
        local adjustScale = scale
        if isStar and OmmEnabled and month ~= 14 and ROMHACK and ROMHACK.ommColorStar then
          local starColor = 0
          if (ROMHACK.starColor or omm_star_colors[course]) and OmmApi.omm_get_setting(gMarioStates[0], "color") ~= 0 then
            starColor = course
          end
          tex = get_texture_info("omm_tex_hud_star_" .. starColor)
          adjustScale = adjustScale / tex.width * 16
          djui_hud_set_color(255, 255, 255, 255)
        elseif isStar and gGlobalSyncTable.ee then
          djui_hud_set_color(255, 0, 0, 255)
        else
          djui_hud_set_color(255, 255, 255, 255)
        end
        djui_hud_render_texture_interpolated(tex, mapData.prevX, mapData.prevY, adjustScale, adjustScale, renderX,
          renderY, adjustScale,
          adjustScale)
        if tex == TEX_HUD_KEY_LEFT then
          djui_hud_render_texture_interpolated(TEX_HUD_KEY_RIGHT, mapData.prevX + adjustScale * 32, mapData.prevY, adjustScale, adjustScale, renderX + adjustScale * 32,
          renderY, adjustScale,
          adjustScale)
        end

        if isStar then
          djui_hud_set_font(FONT_HUD)
          djui_hud_set_color(255, 255, 255, 255)
          djui_hud_print_text_interpolated(tostring(starsLeft), mapData.prevX + 6 * scale, mapData.prevY + 6 * scale,
            scale * 0.75, renderX + 6 * scale, renderY + 6 * scale, scale * 0.75)
        end
      end
      if playerCountHere ~= 0 then
        scale = 0.5
        djui_hud_set_font(FONT_RECOLOR_HUD)
        if isHunter then
          djui_hud_set_color(0, 255, 255, 255)
        else
          djui_hud_set_color(169, 169, 169, 255)
        end
        local prevX = mapData.prevX
        local prevY = mapData.prevY - 12 * scale
        local x = renderX
        local y = renderY - 12 * scale
        if paintingValid then
          prevX = prevX - 4 * scale
          x = x - 4 * scale
          scale = scale * 0.75
        end
        djui_hud_print_text_interpolated(tostring(playerCountHere), prevX, prevY, scale, x, y, scale)
      end
      mapData.prevX = renderX
      mapData.prevY = renderY
    end

    if warpData[5] and (gGlobalSyncTable.mhMode == 3 or totalStars ~= 0 or exThingy ~= 0 or (ROMHACK and ROMHACK.name == "B3313")) then
      djui_hud_set_resolution(RESOLUTION_N64)
      local out = { x = 0, y = 0, z = 0 }
      local scale = 0.68
      local dist = vec3f_dist(gLakituState.pos, pos)
      if dist > 2000 then
        scale = 0.5
        scale = scale + dist / 4000
        scale = clampf(1.68 - scale, 0, 0.68)
      end
      if scale ~= 0 and djui_hud_world_pos_to_screen_pos(pos, out) then
        djui_hud_set_font(FONT_NORMAL)
        local text = get_custom_level_name(warpData[1], warpData[2], warpData[3])

        local alpha = 255
        if scale ~= 0.68 then
          alpha = scale * alpha / 0.68
        end
        local radar = progressRadar[i]
        if not radar then
          progressRadar[i] = { prevX = out.x, prevY = out.y, prevScale = scale }
          radar = progressRadar[i]
        end

        local prevScale = radar.prevScale
        local width = djui_hud_measure_text(text) * scale
        local prevWidth = width * prevScale / scale
        local x = out.x - width * 0.5
        local y = out.y - 35 * scale
        local prevX = radar.prevX - prevWidth * 0.5
        local prevY = radar.prevY - 35 * prevScale
        local color = defaultStarColor
        local texWidth = 16
        local adjustScale = 1
        if omm_star_colors[course] then
          color = omm_star_colors[course]
        end
        if not paintingValid then goto PAINTING_RADAR_END end

        djui_hud_print_outlined_text_interpolated(text, prevX, prevY, prevScale, x, y, scale, color.r, color.g, color.b,
          alpha, 0.25)

        if OmmEnabled and month ~= 14 and ROMHACK and ROMHACK.ommColorStar then
          texWidth = get_texture_info("omm_tex_hud_star_empty").width
          adjustScale = adjustScale / texWidth * 16
        end

        width = (texWidth + 4) * totalStars - 4
        if exThingy ~= 0 then
          width = width + 20
        end
        width = width * scale * adjustScale
        prevWidth = width * prevScale / scale
        x = out.x - width * 0.5
        y = out.y
        prevX = radar.prevX - prevWidth * 0.5
        prevY = radar.prevY
        for i = 1, maxStarNum do
          if (fullStarTable & (1 << (i - 1)) ~= 0) then
            local tex = gTextures.star
            if (starFlags & (1 << (i - 1)) == 0) then
              if OmmEnabled and month ~= 14 and ROMHACK and ROMHACK.ommColorStar then
                tex = get_texture_info("omm_tex_hud_star_empty")
                djui_hud_set_color(255, 255, 255, alpha)
              else
                djui_hud_set_color(0, 0, 0, alpha // 2)
              end
            elseif OmmEnabled and month ~= 14 and ROMHACK and ROMHACK.ommColorStar then
              -- do colored radar
              local starColor = 0
              if (ROMHACK.starColor or omm_star_colors[course]) and OmmApi.omm_get_setting(gMarioStates[0], "color") ~= 0 then
                starColor = course
              end
              tex = get_texture_info("omm_tex_hud_star_" .. starColor)
              r, g, b = 255, 255, 255
              djui_hud_set_color(255, 255, 255, alpha) -- color is already loadeed
            elseif gGlobalSyncTable.ee then
              djui_hud_set_color(255, 0, 0, alpha)
            else
              djui_hud_set_color(255, 255, 255, alpha)
            end
            djui_hud_render_texture_interpolated(tex, prevX, prevY, prevScale * adjustScale, prevScale * adjustScale, x,
              y, scale * adjustScale, scale * adjustScale)
            x = x + (texWidth + 4) * scale * adjustScale
            prevX = prevX + (texWidth + 4) * prevScale * adjustScale
          end
        end

        if exThingy ~= 0 then
          local adjustScale = 1
          if not haveExThingy then
            djui_hud_set_color(0, 0, 0, alpha // 2)
          else
            djui_hud_set_color(255, 255, 255, alpha)
          end
          if exThingy == 1 then
            tex = TEX_HUD_KEY_LEFT
            adjustScale = 0.25
          elseif exThingy == 2 then
            tex = get_texture_info("exclamation_box_seg8_texture_08015E28")
            adjustScale = 0.5
          elseif exThingy == 3 then
            tex = get_texture_info("exclamation_box_seg8_texture_08012E28")
            adjustScale = 0.5
          else
            tex = get_texture_info("exclamation_box_seg8_texture_08014628")
            adjustScale = 0.5
          end
          djui_hud_render_texture_interpolated(tex, prevX, prevY, prevScale * adjustScale, prevScale * adjustScale, x, y,
            scale * adjustScale, scale * adjustScale)
          if tex == TEX_HUD_KEY_LEFT then
            djui_hud_render_texture_interpolated(TEX_HUD_KEY_RIGHT, prevX + prevScale * adjustScale * 32, prevY, prevScale * adjustScale, prevScale * adjustScale, x + prevScale * adjustScale * 32, y,
            scale * adjustScale, scale * adjustScale)
          end
        end

        ::PAINTING_RADAR_END::
        if playerCountHere ~= 0 then
          local color = {} -- for some reason, not doing this makes the level name also this color? doesn't make sense to me
          local adjustScale = 0.5
          local runners = ""
          if isHunter then
            runners = trans("runners")
            if playerCountHere == 1 then runners = trans("runner") end
            color.r, color.g, color.b = 0, 255, 255
          else
            runners = trans("players")
            if playerCountHere == 1 then runners = trans("player") end
            color.r, color.g, color.b = 169, 169, 169
          end
          text = tostring(playerCountHere) .. " " .. runners
          width = djui_hud_measure_text(text) * scale * adjustScale
          prevWidth = width * prevScale / scale
          x = out.x - width / 2
          y = out.y + 35 * scale * adjustScale
          prevX = radar.prevX - width / 2
          prevY = radar.prevY + 35 * prevScale * adjustScale
          djui_hud_print_outlined_text_interpolated(text, prevX, prevY, prevScale * adjustScale, x, y,
            scale * adjustScale, color.r, color.g, color
            .b, alpha, 0.25)
        end

        radar.prevX = out.x
        radar.prevY = out.y
        radar.prevScale = scale
      end
    end
  end
end

function unset_max_star()
  maxStar = -1
end

function render_minimap()
  djui_hud_set_resolution(RESOLUTION_N64)
  local screenWidth = djui_hud_get_screen_width()
  local screenHeight = djui_hud_get_screen_height()

  local renderSize = 80
  local x = screenWidth - 90
  local y = screenHeight - 120

  local level = gNetworkPlayers[0].currLevelNum
  local area = gNetworkPlayers[0].currAreaIndex
  local tex
  if (not LITE_MODE) and level == LEVEL_LOBBY then
    tex = get_texture_info("lobby-map")
  elseif (not LITE_MODE) and ROMHACK.minimap_data and ROMHACK.minimap_data[level * 10 + area] then
    local data = ROMHACK.minimap_data[level * 10 + area][1]
    if type(data) == "string" then
      tex = get_texture_info(data)
    else
      tex = data
    end
  end

  if tex then
    -- border
    djui_hud_set_color(50, 50, 50, 200)
    djui_hud_render_rect(x - 1, y - 1, renderSize + 2, renderSize + 2)

    local scale = renderSize / tex.width
    djui_hud_set_color(255, 255, 255, 200)
    djui_hud_render_texture(tex, x, y, scale, scale)
  else
    djui_hud_set_color(255, 255, 255, 100)
    djui_hud_render_rect(x, y, renderSize, renderSize)
  end
end

function render_player_minimap()
  djui_hud_set_resolution(RESOLUTION_N64)
  local screenWidth = djui_hud_get_screen_width()
  local screenHeight = djui_hud_get_screen_height()

  local renderSize = 80
  local x = screenWidth - 90
  local y = screenHeight - 120

  local pos = gMarioStates[0].pos

  local level = gNetworkPlayers[0].currLevelNum
  local area = gNetworkPlayers[0].currAreaIndex
  if ROMHACK.minimap_data and ROMHACK.minimap_data[level * 10 + area] and ROMHACK.minimap_data[level * 10 + area][2] then
    levelSize = ROMHACK.minimap_data[level * 10 + area][2]
  elseif not is_vanilla_like() then
    while pos.x > levelSize + 5 or pos.x < -levelSize - 5 or pos.z > levelSize + 5 or pos.z < -levelSize - 5 do -- adjust size if oob
      levelSize = levelSize * 2
    end
  end
  local xScaled = (pos.x / (levelSize * 2) + 0.5)
  local yScaled = (pos.z / (levelSize * 2) + 0.5)

  local renderX = x + xScaled * renderSize - 4.8
  local renderY = y + yScaled * renderSize - 4.8

  djui_hud_set_color(255, 255, 255, 255)
  render_player_head(0, renderX, renderY, 0.6, 0.6)

  local playercolor = network_get_player_text_color_string(0)
  local r, g, b = convert_color(playercolor)
  djui_hud_set_color(r, g, b, 155)
  djui_hud_set_rotation(gMarioStates[0].faceAngle.y, 0.5, 0.5)
  djui_hud_render_texture(TEX_MAP_ARROW, renderX - 8 * 0.6, renderY - 8 * 0.6, 0.6, 0.6)
  djui_hud_set_rotation(0, 0, 0)
end

function get_radar_color(index)
  local r, g, b = 0, 0, 0
  local sMario = gPlayerSyncTable[index]
  local roles = sMario.role
  if (sMario.placement ~= 1 or roles & 32 == 0) and (sMario.placementASN ~= 1 or roles & 64 == 0) then
    local playercolor = network_get_player_text_color_string(index)
    r, g, b = convert_color(playercolor)
  else -- rainbow radar
    rainbow_counter = rainbow_counter + 1
    if rainbow_counter > 360 then rainbow_counter = 0 end

    -- This is done by changing the hue over time
    local h = rainbow_counter
    local s = 0.8
    local v = 1
    -- Now it's time to convert this to RGB, which is very annoying
    local M = 255 * v
    local m = M * (1 - s)
    local z = (M - m) * (1 - math.abs(h / 60 % 2 - 1))
    -- there's SIX CASES
    if h < 60 then
      r = M
      g = z + m
      b = m
    elseif h < 120 then
      r = z + m
      g = M
      b = m
    elseif h < 180 then
      r = m
      g = M
      b = z + m
    elseif h < 240 then
      r = m
      g = z + m
      b = M
    elseif h < 300 then
      r = z + m
      g = m
      b = M
    else
      r = M
      g = m
      b = z + m
    end
    -- and we're doing this every frame. Thank god there's only two of these.
  end
  return r, g, b
end

-- star color table for OMM, based on course number
omm_star_colors = {
  [COURSE_BOB] = { r = 71, g = 192, b = 71 },
  [COURSE_WF] = { r = 190, g = 190, b = 190 },
  [COURSE_JRB] = { r = 237, g = 176, b = 204 },
  [COURSE_CCM] = { r = 30, g = 255, b = 255 },
  [COURSE_BBH] = { r = 189, g = 148, b = 203 },
  [COURSE_HMC] = { r = 127, g = 127, b = 127 },
  [COURSE_LLL] = { r = 255, g = 25, b = 25 },
  [COURSE_SSL] = { r = 192, g = 246, b = 74 },
  [COURSE_DDD] = { r = 28, g = 169, b = 240 },
  [COURSE_SL] = { r = 255, g = 255, b = 255 },
  [COURSE_WDW] = { r = 168, g = 189, b = 208 },
  [COURSE_TTM] = { r = 198, g = 161, b = 124 },
  [COURSE_THI] = { r = 255, g = 200, b = 64 },
  [COURSE_TTC] = { r = 250, g = 182, b = 146 },
  [COURSE_RR] = { r = 241, g = 127, b = 237 },
}