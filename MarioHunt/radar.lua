-- based on arena

TEX_RAD = get_texture_info('runner-mark')
icon_radar = {}
for i=0,(MAX_PLAYERS-1) do
  icon_radar[i] = {tex = TEX_RAD, prevX = 0, prevY = 0}
end

function render_radar(m, hudIcon, isObj)
  djui_hud_set_resolution(RESOLUTION_N64)
  local pos = {}
  if not isObj then
    pos = { x = m.pos.x, y = m.pos.y + 80, z = m.pos.z } -- mario is 161 units tall
  else
    pos = { x = m.oPosX, y = m.oPosY, z = m.oPosZ }
  end
  local out = { x = 0, y = 0, z = 0 }
  djui_hud_world_pos_to_screen_pos(pos, out)

  if out.z > -260 then
      return
  end

  local alpha = clamp(vec3f_dist(pos, gMarioStates[0].pos), 0, 1200) - 1000
  if alpha <= 0 then
      return
  end

  local dX = out.x - 10
  local dY = out.y - 10

  local r,g,b = 0,0,0
  if not isObj then
    local np = gNetworkPlayers[m.playerIndex]
    local playercolor = network_get_player_text_color_string(np.localIndex)
    r,g,b = convert_color(playercolor)
  else
    r = pos.x % 255 + 1
    g = pos.y % 255 + 1
    b = pos.z % 255 + 1
  end


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

  djui_hud_set_color(r, g, b, alpha)
  djui_hud_render_texture_interpolated(hudIcon.tex, hudIcon.prevX, hudIcon.prevY, 0.6, 0.6, dX, dY, 0.6, 0.6)

  hudIcon.prevX = dX
  hudIcon.prevY = dY
end
