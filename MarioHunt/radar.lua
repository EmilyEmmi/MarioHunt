-- based on arena

-- this reduces lag apparently
local djui_hud_set_color,get_texture_info,djui_hud_render_texture_interpolated,djui_hud_set_resolution,clamp,network_get_player_text_color_string,obj_has_model_extended = djui_hud_set_color,get_texture_info,djui_hud_render_texture_interpolated,djui_hud_set_resolution,clamp,network_get_player_text_color_string,obj_has_model_extended

TEX_RAD = get_texture_info('runner-mark')
TEX_STAR = get_texture_info('star-mark')
TEX_BOX = get_texture_info('box-mark')
icon_radar = {}
star_radar = {}
box_radar = {}
for i=0,(MAX_PLAYERS-1) do
  icon_radar[i] = {tex = TEX_RAD, prevX = 0, prevY = 0}
end
for i=1,7 do
  star_radar[i] = {tex = TEX_STAR, prevX = 0, prevY = 0}
end
for i=1,7 do
  box_radar[i] = {tex = TEX_BOX, prevX = 0, prevY = 0}
end
defaultStarColor = {r = 255,g = 255,b = 92} -- yellow

-- also includes texture data for stats
TEX_FLAG = get_texture_info('stat-flag')
TEX_BOOT = get_texture_info('stat-kill')
TEX_MULTI_BOOT = get_texture_info('stat-multikill')
TEX_MEDAL = get_texture_info('stat-medal')
TEX_ARROW = get_texture_info('stat-arrow')
stat_icon_data = {}
stat_icon_data[1] = {tex = TEX_FLAG, r = 255, g = 255, b = 92}
stat_icon_data[2] = {tex = TEX_BOOT, r = 129, g = 90, b = 50}
stat_icon_data[3] = {tex = TEX_MULTI_BOOT, r = 129, g = 90, b = 50}
stat_icon_data[4] = {tex = TEX_FLAG, r = 255, g = 92, b = 92}
stat_icon_data[5] = {tex = TEX_STAR, r = 255, g = 255, b = 92}
stat_icon_data[6] = {tex = TEX_MEDAL, r = 255, g = 255, b = 255}

local rainbow_counter = 0
function render_radar(m, hudIcon, isObj, isBox)
  djui_hud_set_resolution(RESOLUTION_N64)
  local pos = {}
  local obj = m
  if not isObj then
    pos = { x = m.pos.x, y = m.pos.y + 80, z = m.pos.z } -- mario is 161 units tall
  else
    pos = { x = obj.oPosX + 10, y = obj.oPosY + 10, z = obj.oPosZ + 10} -- I'm just guessing
    if isBox then
      pos.y = pos.y + 30
    end
  end
  local out = { x = 0, y = 0, z = 0 }
  djui_hud_world_pos_to_screen_pos(pos, out)

  local dX = out.x - 10
  local dY = out.y - 10
  local screenWidth = djui_hud_get_screen_width()
  local screenHeight = djui_hud_get_screen_height()
  if dX > (screenWidth - 20) then
    dX = (screenWidth - 20)
  elseif dX < 0 then
    dX = 0
  end
  if dY > (screenHeight - 20) then
    dY = (screenHeight - 20)
  elseif dY < 0 then
    dY = 0
  end

  if out.z > -260 then
    hudIcon.prevX = dX
    hudIcon.prevY = dY
    return
  end

  local alpha = clamp(vec3f_dist(pos, gMarioStates[0].pos), 0, 1200) - 1000
  if alpha <= 0 then
    return
  end

  local r,g,b = 0,0,0
  if not isObj then
    local sMario = gPlayerSyncTable[m.playerIndex]
    if sMario.placement ~= 1 then
      local np = gNetworkPlayers[m.playerIndex]
      local playercolor = network_get_player_text_color_string(np.localIndex)
      r,g,b = convert_color(playercolor)
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
      local z = (M - m) * (1 - math.abs(h/60 % 2 - 1))
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
  elseif isBox then
    r,g,b = 255,255,255 -- texture has color
  else
    if _G.OmmEnabled
    and ROMHACK.ommSupport ~= false -- romhacks that use a custom model can't be checked; as such, the omm colored radar will never be displayed (only relevant for Green Stars)
    and obj_has_model_extended(obj, E_MODEL_STAR) ~= 1
    and obj_has_model_extended(obj, E_MODEL_TRANSPARENT_STAR) ~= 1 then
      -- do colored radar
      local np = gNetworkPlayers[0]
      local starColor = omm_star_colors[np.currCourseNum]
      if starColor ~= nil then
        r,g,b = starColor.r,starColor.g,starColor.b
      else
        r,g,b = 255,255,92 -- yellow
      end
    elseif gGlobalSyncTable.ee then
      r,g,b = 255,0,0 -- red
    else
      r,g,b = defaultStarColor.r,defaultStarColor.g,defaultStarColor.b
    end
    alpha = alpha - 100
    if alpha <= 0 then
      return
    end
  end

  djui_hud_set_color(r, g, b, alpha)
  djui_hud_render_texture_interpolated(hudIcon.tex, hudIcon.prevX, hudIcon.prevY, 0.6, 0.6, dX, dY, 0.6, 0.6)

  hudIcon.prevX = dX
  hudIcon.prevY = dY
end

-- star color table for OMM, based on course number
omm_star_colors = {
  [COURSE_BOB] = {r = 71, g = 192, b = 71},
  [COURSE_WF] = {r = 190, g = 190, b = 190},
  [COURSE_JRB] = {r = 237, g = 176, b = 204},
  [COURSE_CCM] = {r = 30, g = 255, b = 255},
  [COURSE_BBH] = {r = 189, g = 148, b = 203},
  [COURSE_HMC] = {r = 127, g = 127, b = 127},
  [COURSE_LLL] = {r = 255, g = 25, b = 25},
  [COURSE_SSL] = {r = 192, g = 246, b = 74},
  [COURSE_DDD] = {r = 28, g = 169, b = 240},
  [COURSE_SL] = {r = 255, g = 255, b = 255},
  [COURSE_WDW] = {r = 168, g = 189, b = 208},
  [COURSE_TTM] = {r = 198, g = 161, b = 124},
  [COURSE_THI] = {r = 255, g = 200, b = 64},
  [COURSE_TTC] = {r = 250, g = 182, b = 146},
  [COURSE_RR] = {r = 241, g = 127, b = 237},
}
