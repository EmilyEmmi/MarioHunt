-- based on arena

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
icon_radar = {}
star_radar = {}
box_radar = {}
for i = 0, (MAX_PLAYERS - 1) do
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
defaultStarColor = { r = 255, g = 255, b = 92 } -- yellow

-- also includes texture data for stats
TEX_FLAG = get_texture_info('stat-flag')
TEX_MULTI_STARS = get_texture_info('stat-stars')
TEX_BOOT = get_texture_info('stat-kill')
TEX_MULTI_BOOT = get_texture_info('stat-multikill')
TEX_MEDAL = get_texture_info('stat-medal')
TEX_ARROW = get_texture_info('stat-arrow')
stat_icon_data = {}
stat_icon_data[1] = { tex = TEX_FLAG, r = 255, g = 255, b = 92 }
stat_icon_data[2] = { tex = TEX_STAR, r = 255, g = 255, b = 92 }
stat_icon_data[3] = { tex = TEX_FLAG, r = 255, g = 92, b = 92 }
stat_icon_data[4] = { tex = TEX_STAR, r = 255, g = 92, b = 92 }
stat_icon_data[5] = { tex = TEX_FLAG, r = 180, g = 92, b = 255 }
stat_icon_data[6] = { tex = TEX_STAR, r = 180, g = 92, b = 255 }
stat_icon_data[7] = { tex = TEX_BOOT, r = 129, g = 90, b = 50 }
stat_icon_data[8] = { tex = TEX_MULTI_BOOT, r = 129, g = 90, b = 50 }
stat_icon_data[9] = { tex = TEX_MULTI_STARS, r = 255, g = 255, b = 92 }
stat_icon_data[10] = { tex = TEX_MEDAL, r = 255, g = 255, b = 255 }

local rainbow_counter = 0
function render_radar(m, hudIcon, isObj, objType)
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
  local out = { x = 0, y = 0, z = 0 }
  djui_hud_world_pos_to_screen_pos(pos, out)

  local dX = out.x
  local dY = out.y
  local screenWidth = djui_hud_get_screen_width()
  local screenHeight = djui_hud_get_screen_height()

  if out.z > -260 then
    hudIcon.prevX = dX
    hudIcon.prevY = dY
    return
  end

  local dist = vec3f_dist(pos, gMarioStates[0].pos)
  local alpha = clamp(dist, 0, 1200) - 1000
  if alpha <= 0 then
    return
  end

  local r, g, b = 0, 0, 0
  local tex = hudIcon.tex or TEX_STAR
  if not isObj then
    if runnerTarget == m.playerIndex then
      tex = TEX_RAD_TARGET
    end
    local sMario = gPlayerSyncTable[m.playerIndex]
    if sMario.placement ~= 1 then
      local np = gNetworkPlayers[m.playerIndex]
      local playercolor = network_get_player_text_color_string(np.localIndex)
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
  djui_hud_render_texture_interpolated(tex, hudIcon.prevX, hudIcon.prevY, hudIcon.prevScale, hudIcon.prevScale, dX, dY,
    scale, scale)
  --[[if not objType then
    djui_hud_set_font(FONT_HUD)
    djui_hud_print_text_interpolated(tostring((obj.oBehParams >> 24) + 1), hudIcon.prevX, hudIcon.prevY, 0.6, dX, dY, 0.6)
  end]]

  hudIcon.prevScale = scale
  hudIcon.prevX = dX
  hudIcon.prevY = dY
end

function render_radar_act_select()
  djui_hud_set_resolution(RESOLUTION_N64)
  local screenWidth = djui_hud_get_screen_width()
  local screenHeight = djui_hud_get_screen_height()

  local alpha = 200
  local np0 = gNetworkPlayers[0]
  local course = gNetworkPlayers[0].currCourseNum
  local stars = save_file_get_star_flags(get_current_save_file_num() - 1, course - 1)
  local maxStar = -1

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

  for i = 1, (MAX_PLAYERS - 1) do
    local act = 0
    local np = gNetworkPlayers[i]
    local sMario = gPlayerSyncTable[i]
    if np and np.connected and sMario.team == 1 and np.currCourseNum == np0.currCourseNum and np.currActNum ~= 0 then
      act = np.currActNum

      if act <= maxStar + 1 then
        local dX = (139 - maxStar * 17 + act * 34) + djui_hud_get_screen_width() * 0.5 - 171
        local dY = 64

        local r, g, b = 0, 0, 0
        local hudIcon = icon_radar[i]
        local tex = hudIcon.tex or TEX_STAR
        if runnerTarget == i then
          tex = TEX_RAD_TARGET
        end
        local sMario = gPlayerSyncTable[i]
        if sMario.placement ~= 1 then
          local playercolor = network_get_player_text_color_string(np.localIndex)
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
        djui_hud_render_texture_interpolated(tex, hudIcon.prevX, hudIcon.prevY, hudIcon.prevScale, hudIcon.prevScale, dX,
          dY, scale, scale)
        --[[if not objType then
        djui_hud_set_font(FONT_HUD)
        djui_hud_print_text_interpolated(tostring((obj.oBehParams >> 24) + 1), hudIcon.prevX, hudIcon.prevY, 0.6, dX, dY, 0.6)
        end]]

        hudIcon.prevScale = scale
        hudIcon.prevX = dX
        hudIcon.prevY = dY
      end
    end
  end
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
