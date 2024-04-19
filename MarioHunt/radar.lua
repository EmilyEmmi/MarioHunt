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

-- minimap
TEX_HUD_STAR_GREYSCALE = get_texture_info('hud_star_greyscale')
TEX_HUD_BOX = get_texture_info('hud_box')
TEX_HUD_DEMON = get_texture_info('hud_demon')
TEX_HUD_TARGET = get_texture_info('hud_target')
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

levelSize = 8192
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
stat_icon_data = {}
stat_icon_data_alt1 = {}
stat_icon_data_alt2 = {}
stat_icon_data[1] = { tex = TEX_FLAG, r = 255, g = 255, b = 92 }
stat_icon_data[2] = { tex = TEX_STAR, r = 255, g = 255, b = 92 }
stat_icon_data[3] = { tex = TEX_BOOT, r = 255, g = 255, b = 255 }
stat_icon_data[4] = { tex = TEX_MULTI_BOOT, r = 255, g = 255, b = 255 }
stat_icon_data[5] = { tex = TEX_MULTI_STARS, r = 255, g = 255, b = 92 }
stat_icon_data[6] = { tex = TEX_MEDAL, r = 255, g = 255, b = 255 }
stat_icon_data[7] = { tex = TEX_WATCH, r = 255, g = 255, b = 255 }
stat_icon_data[8] = { tex = TEX_WATCH, r = 80, g = 255, b = 80 }

-- hard and extreme
stat_icon_data_alt1[1] = { tex = TEX_FLAG, r = 255, g = 92, b = 92 }
stat_icon_data_alt1[2] = { tex = TEX_STAR, r = 255, g = 92, b = 92 }
stat_icon_data_alt1[7] = { tex = TEX_WATCH_OMM, r = 255, g = 255, b = 255 }
stat_icon_data_alt2[1] = { tex = TEX_FLAG, r = 180, g = 92, b = 255 }
stat_icon_data_alt2[2] = { tex = TEX_STAR, r = 180, g = 92, b = 255 }
stat_icon_data_alt2[7] = { tex = TEX_WATCH_OTHER, r = 255, g = 255, b = 255 }

local rainbow_counter = 0
function render_radar(m, radarData, mapData, isObj, objType, mapOnly)
  djui_hud_set_resolution(RESOLUTION_N64)
  local pos = {}
  local obj = m
  if not isObj then
    pos = { x = m.pos.x, y = m.pos.y + 80, z = m.pos.z } -- mario is 161 units tall
  else
    pos = { x = obj.oPosX, y = obj.oPosY, z = obj.oPosZ }
    if objType == "box" then        -- box's position is a bit higher
      pos.y = pos.y + 50
    elseif objType == "secret" then -- secrets have a misleading hitbox (although they aren't usually visible)
      pos.y = pos.y + 15
    elseif objType == "demon" then  -- 1ups also have a misleading hitbox
      pos.y = pos.y + obj.hitboxHeight
    elseif objType == "coin" then   -- these have their position centered at their bottom, so move up based on hitbox size
      pos.y = pos.y + obj.hitboxHeight / 2
    end
  end

  local screenWidth = djui_hud_get_screen_width()
  local screenHeight = djui_hud_get_screen_height()

  -- minimap render
  if showMiniMap and not is_game_paused() then
    local renderSize = 80
    local x = screenWidth - 90
    local y = screenHeight - 120

    local tex = mapData.tex

    local level = gNetworkPlayers[0].currLevelNum
    local area = gNetworkPlayers[0].currAreaIndex
    if ROMHACK.minimap_data and ROMHACK.minimap_data[level * 10 + area] and ROMHACK.minimap_data[level * 10 + area][2] then
      levelSize = ROMHACK.minimap_data[level * 10 + area][2]
    end

    if pos.x > levelSize + 5 or pos.x < -levelSize - 5 or pos.z > levelSize + 5 or pos.z < -levelSize - 5 then -- adjust size if oob
      levelSize = levelSize * 2
    end
    local xScaled = (pos.x / (levelSize * 2) + 0.5)
    local yScaled = (pos.z / (levelSize * 2) + 0.5)

    local scale = 0.5
    if (not isObj) and gPlayerSyncTable[0].spectator == 1 and spectateFocus == m.playerIndex and free_camera ~= 1 then
      scale = 0.6
    end

    local renderX = x + xScaled * renderSize - 8 * scale
    local renderY = y + yScaled * renderSize - 8 * scale

    if objType == "coin" then
      if ROMHACK.isMoonshine then
        djui_hud_set_color(0, 255, 0, 255) -- green
      else
        djui_hud_set_color(255, 0, 0, 255) -- red
      end
    elseif objType == "secret" then
      djui_hud_set_color(255, 255, 255, 255)
      djui_hud_set_font(FONT_HUD)
      djui_hud_print_text("S", renderX, renderY, 0.5)
    elseif isObj and objType == nil then
      local r, g, b = 255, 255, 255
      if _G.OmmEnabled
          and ROMHACK.ommSupport ~= false -- romhacks that use a custom model can't be checked; as such, the omm colored radar will never be displayed
          and obj_has_model_extended(obj, E_MODEL_STAR) ~= 1
          and obj_has_model_extended(obj, E_MODEL_TRANSPARENT_STAR) ~= 1
          and _G.OmmApi.omm_get_setting(gMarioStates[0], "color") == 1 then
        -- do colored radar
        local np = gNetworkPlayers[0]
        local starColor = omm_star_colors[np.currCourseNum]
        tex = TEX_HUD_STAR_GREYSCALE
        if starColor then
          r, g, b = starColor.r, starColor.g, starColor.b
        else
          r, g, b = 252, 240, 65 -- yellow (try to match original hud color)
        end
      elseif gGlobalSyncTable.ee then
        tex = TEX_HUD_STAR_GREYSCALE
        r, g, b = 255, 0, 0 -- red
      end
      djui_hud_set_color(r, g, b, 255)
    else
      djui_hud_set_color(255, 255, 255, 255)
    end

    if not isObj then
      render_player_head(m.playerIndex, renderX, renderY, scale, scale)

      local playercolor = network_get_player_text_color_string(m.playerIndex)
      local r, g, b = convert_color(playercolor)
      djui_hud_set_color(r, g, b, 155)
      djui_hud_set_rotation(m.faceAngle.y, 0.5, 0.5)
      djui_hud_render_texture(TEX_MAP_ARROW, renderX - 8 * scale, renderY - 8 * scale, scale, scale)
      djui_hud_set_rotation(0, 0, 0)
      if runnerTarget == m.playerIndex then
        r, g, b = get_radar_color(runnerTarget)
        djui_hud_set_color(r, g, b, 200)
        djui_hud_render_texture(TEX_HUD_TARGET, renderX, renderY, scale, scale)
      end
    elseif tex then
      djui_hud_render_texture_interpolated(tex, mapData.prevX, mapData.prevY, scale, scale, renderX, renderY, scale,
        scale)
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
    if runnerTarget == m.playerIndex then
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
    elseif ROMHACK.isMoonshine then -- change to green
      r, g, b = 0, 255, 0
    end
  elseif objType == "secret" then
    r, g, b = 0, 255, 0 -- green
    alpha = alpha - 100
    if alpha <= 0 then
      return
    end
  else
    if ROMHACK.isMoonshine then
      tex = TEX_MOON
    end

    if _G.OmmEnabled
        and ROMHACK.ommSupport ~= false -- romhacks that use a custom model can't be checked; as such, the omm colored radar will never be displayed
        and obj_has_model_extended(obj, E_MODEL_STAR) ~= 1
        and obj_has_model_extended(obj, E_MODEL_TRANSPARENT_STAR) ~= 1
        and _G.OmmApi.omm_get_setting(gMarioStates[0], "color") == 1 then
      -- do colored radar
      local np = gNetworkPlayers[0]
      local starColor = omm_star_colors[np.currCourseNum]
      if starColor then
        r, g, b = starColor.r, starColor.g, starColor.b
      else
        r, g, b = 255, 255, 92 -- yellow
      end
    elseif gGlobalSyncTable.ee then
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
  local screenWidth = djui_hud_get_screen_width()
  local screenHeight = djui_hud_get_screen_height()

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

  for i = 1, (MAX_PLAYERS - 1) do
    local act = 0
    local np = gNetworkPlayers[i]
    local sMario = gPlayerSyncTable[i]
    if np and np.connected and sMario.team == 1 and np.currCourseNum == course and np.currActNum ~= 0 then
      act = np.currActNum

      if act <= maxStar + 1 then
        local dX = (139 - maxStar * 17 + act * 34) + djui_hud_get_screen_width() * 0.5 - 171
        local dY = 64

        local r, g, b = get_radar_color(i)
        local tex = TEX_RAD
        if runnerTarget == i then
          tex = TEX_RAD_TARGET
        end

        local scale = 1
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
        djui_hud_render_texture(tex, dX, dY, scale, scale)
        --[[if not objType then
        djui_hud_set_font(FONT_HUD)
        djui_hud_print_text_interpolated(tostring((obj.oBehParams >> 24) + 1), radarData.prevX, radarData.prevY, 0.6, dX, dY, 0.6)
        end]]
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
  end

  if pos.x > levelSize + 5 or pos.x < -levelSize - 5 or pos.z > levelSize + 5 or pos.z < -levelSize - 5 then -- adjust size if oob
    levelSize = levelSize * 2
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
  if sMario.placement ~= 1 then
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
    -- and we're doing this every frame. Thank god there's only one of these.
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

-- renders player head... with color!
local PART_ORDER = {
  SKIN,
  HAIR,
  CAP,
}

HEAD_HUD = (not LITE_MODE) and get_texture_info("hud_head_recolor")
WING_HUD = get_texture_info("hud_wing")
CS_ACTIVE = _G.charSelectExists

local defaultIcons = {
  [gTextures.mario_head] = true,
  [gTextures.luigi_head] = true,
  [gTextures.toad_head] = true,
  [gTextures.waluigi_head] = true,
  [gTextures.wario_head] = true,
}

function render_player_head(index, x, y, scaleX, scaleY, noSpecial)
  local m = gMarioStates[index]
  local np = gNetworkPlayers[index]

  local alpha = 255
  if (not noSpecial) and (m.marioBodyState.modelState & MODEL_STATE_NOISE_ALPHA) ~= 0 then
    alpha = 100 -- vanish effect
  end

  if CS_ACTIVE then
    djui_hud_set_color(255, 255, 255, alpha)
    local TEX_CS_ICON = _G.charSelect.character_get_life_icon(index)
    if TEX_CS_ICON and not defaultIcons[TEX_CS_ICON] then
      djui_hud_render_texture(TEX_CS_ICON, x, y, scaleX / (TEX_CS_ICON.width * 0.0625),
        scaleY / (TEX_CS_ICON.width * 0.0625))
      if (not noSpecial) and m.marioBodyState.capState == MARIO_HAS_WING_CAP_ON then
        djui_hud_render_texture(WING_HUD, x, y, scaleX, scaleY)                                                -- wing
      end
      return
    elseif TEX_CS_ICON == nil then
      djui_hud_set_font(FONT_HUD)
      djui_hud_print_text("?", x, y, scaleX)
      if (not noSpecial) and m.marioBodyState.capState == MARIO_HAS_WING_CAP_ON then
        djui_hud_render_texture(WING_HUD, x, y, scaleX, scaleY)                                                -- wing
      end
      return
    end
  end

  if LITE_MODE then
    djui_hud_set_color(255, 255, 255, alpha)
    djui_hud_render_texture(m.character.hudHeadTexture, x, y, scaleX, scaleY)
    if (not noSpecial) and m.marioBodyState.capState == MARIO_HAS_WING_CAP_ON then
      djui_hud_render_texture(WING_HUD, x, y, scaleX, scaleY)                                                -- wing
    end
    return
  end
  
  local isMetal = false
  local capless = false

  local tileY = m.character.type
  for i = 1, #PART_ORDER do
    local color = { r = 255, g = 255, b = 255 }
    if (not noSpecial) and (m.marioBodyState.modelState & MODEL_STATE_METAL) ~= 0 then -- metal
      color = network_player_palette_to_color(np, METAL, color)
      djui_hud_set_color(color.r, color.g, color.b, alpha)
      isMetal = true

      if (not noSpecial) and m.marioBodyState.capState == MARIO_HAS_DEFAULT_CAP_OFF then
        capless = true
        djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, 7 * 16, tileY * 16, 16, 16) -- capless metal
      else
        djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, 5 * 16, tileY * 16, 16, 16)
      end
      break
    end

    local part = PART_ORDER[i]
    if (not noSpecial) and part == CAP and m.marioBodyState.capState == MARIO_HAS_DEFAULT_CAP_OFF then -- capless check
      capless = true
      part = HAIR
    elseif tileY == 2 and part == HAIR then -- toad doesn't use hair
      part = GLOVES
      if (not noSpecial) and m.marioBodyState.capState == MARIO_HAS_DEFAULT_CAP_OFF then
        capless = true
        break -- toad only has 1 colored part in this scenario
      end
    end
    network_player_palette_to_color(np, part, color)

    djui_hud_set_color(color.r, color.g, color.b, alpha)
    if capless then
      djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, 6 * 16, tileY * 16, 16, 16) -- render hair instead of cap
    else
      djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, (i - 1) * 16, tileY * 16, 16, 16)
    end
  end

  if not isMetal then
    djui_hud_set_color(255, 255, 255, alpha)
    --djui_hud_render_texture(HEAD_HUD, x, y, scaleX, scaleY)
    djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, (#PART_ORDER) * 16, tileY * 16, 16, 16)

    if not capless then
      djui_hud_render_texture_tile(HEAD_HUD, x, y, scaleX, scaleY, (#PART_ORDER + 1) * 16, tileY * 16, 16, 16) -- hat emblem
      if (not noSpecial) and m.marioBodyState.capState == MARIO_HAS_WING_CAP_ON then
        djui_hud_render_texture(WING_HUD, x, y, scaleX, scaleY)                                                -- wing
      end
    end
  elseif m.marioBodyState.capState == MARIO_HAS_WING_CAP_ON then
    djui_hud_set_color(109, 170, 173, alpha)                -- blueish green
    djui_hud_render_texture(WING_HUD, x, y, scaleX, scaleY) -- wing
  end
end