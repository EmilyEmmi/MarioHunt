-- name: Nametags (MH)
-- incompatible: nametags
-- description: Nametags\nBy \\#ec7731\\Agent X\\#dcdcdc\\\n\nThis mod adds nametags to sm64ex-coop, this helps to easily identify other players without the player list, nametags can toggled on and off with \\#ffff00\\/nametag-distance 7000\\#dcdcdc\\ and \\#ffff00\\/nametag-distance 0\\#dcdcdc\\ respectively.\n\nThis version uses the MarioHunt API.

local MAX_SCALE = 0.32

gGlobalSyncTable.dist = 7000

local showHealth = true
local showSelfTag = false

local gStateExtras = {}
for i = 0, (MAX_PLAYERS - 1) do
    gStateExtras[i] = {}
    local e = gStateExtras[i]
    e.prevPos = {}
    e.prevPos.x = 0
    e.prevPos.y = 0
    e.prevPos.z = 0
    e.prevScale = 1
end

-- localize functions to improve performance
local djui_chat_message_create = djui_chat_message_create
local djui_hud_measure_text = djui_hud_measure_text
local djui_hud_print_text_interpolated = djui_hud_print_text_interpolated
local djui_hud_set_color = djui_hud_set_color
local djui_hud_set_font = djui_hud_set_font
local djui_hud_set_resolution = djui_hud_set_resolution
local djui_hud_world_pos_to_screen_pos = djui_hud_world_pos_to_screen_pos
local vec3f_dist = vec3f_dist
local network_player_connected_count = network_player_connected_count
local network_player_palette_to_color = network_player_palette_to_color
local network_is_server = network_is_server
local is_player_active = is_player_active
local clampf = clampf
local hud_render_power_meter_interpolated = (_G.mhExists and _G.mhApi.render_power_meter_interpolated) or hud_render_power_meter_interpolated
local is_game_paused = is_game_paused
local obj_get_first_with_behavior_id = obj_get_first_with_behavior_id

-- localize MH api functions
local mhExists = _G.mhExists or false
local function get_role_name_and_color(index) end
local function mh_is_spectator(index) return false end
local function get_mh_tag(index) return "" end
if mhExists then
  mh_is_spectator = _G.mhApi.isSpectator
  get_role_name_and_color = _G.mhApi.get_role_name_and_color
  get_mh_tag = _G.mhApi.get_tag
end

for i in pairs(gActiveMods) do
    local name = gActiveMods[i].name:lower()
    if gActiveMods[i].enabled and (name:find("hide") or name:find("hns") or name:find("hunt")) then
        gGlobalSyncTable.dist = 0
    end
end

local function on_or_off(value)
    if value then return "\\#00ff00\\ON" end
    return "\\#ff0000\\OFF"
end

--- @param m MarioState
local function active_player(m)
    local np = gNetworkPlayers[m.playerIndex]
    if m.playerIndex == 0 then
        return 1
    end
    if not np.connected then
        return 0
    end
    if np.currCourseNum ~= gNetworkPlayers[0].currCourseNum then
        return 0
    end
    if np.currActNum ~= gNetworkPlayers[0].currActNum then
        return 0
    end
    if np.currLevelNum ~= gNetworkPlayers[0].currLevelNum then
        return 0
    end
    if np.currAreaIndex ~= gNetworkPlayers[0].currAreaIndex then
        return 0
    end
    if mh_is_spectator(m.playerIndex) then
        return 0
    end
    return is_player_active(m)
end

local function if_then_else(cond, if_true, if_false)
    if cond then return if_true end
    return if_false
end

local function djui_hud_set_adjusted_color(r, g, b, a)
    local multiplier = 1
    if is_game_paused() then multiplier = 0.5 end
    djui_hud_set_color(r * multiplier, g * multiplier, b * multiplier, a)
end

local function djui_hud_print_outlined_text_interpolated(text, prevX, prevY, prevScale, x, y, scale, r, g, b, a, outlineDarkness)
    local offset = 1 * (scale * 2)
    local prevOffset = 1 * (prevScale * 2)

    -- render outline
    djui_hud_set_adjusted_color(r * outlineDarkness, g * outlineDarkness, b * outlineDarkness, a)
    djui_hud_print_text_interpolated(text, prevX - prevOffset, prevY,              prevScale, x - offset, y,          scale)
    djui_hud_print_text_interpolated(text, prevX + prevOffset, prevY,              prevScale, x + offset, y,          scale)
    djui_hud_print_text_interpolated(text, prevX,              prevY - prevOffset, prevScale, x,          y - offset, scale)
    djui_hud_print_text_interpolated(text, prevX,              prevY + prevOffset, prevScale, x,          y + offset, scale)
    -- render text
    djui_hud_set_adjusted_color(r, g, b, 255)
    djui_hud_print_text_interpolated(text, prevX, prevY, prevScale, x, y, scale)
    djui_hud_set_color(255, 255, 255, 255)
end

-- for tags
-- removes color string
local function remove_color(text,get_color)
    local start = text:find("\\")
    local next = 1
    while (next ~= nil) and (start ~= nil) do
      start = text:find("\\")
      if start ~= nil then
        next = text:find("\\",start+1)
        if next == nil then
          next = text:len() + 1
        end
  
        if get_color then
          local color = text:sub(start,next)
          local render = text:sub(1,start-1)
          text = text:sub(next+1)
          return text,color,render
        else
          text = text:sub(1,start-1) .. text:sub(next+1)
        end
      end
    end
    return text
end
  
-- converts hex string to RGB values
local function convert_color(text)
    if text:sub(2,2) ~= "#" then
      return nil
    end
    text = text:sub(3,-2)
    local rstring = text:sub(1,2) or "ff"
    local gstring = text:sub(3,4) or "ff"
    local bstring = text:sub(5,6) or "ff"
    local astring = text:sub(7,8) or "ff"
    local r = tonumber("0x"..rstring) or 255
    local g = tonumber("0x"..gstring) or 255
    local b = tonumber("0x"..bstring) or 255
    local a = tonumber("0x"..astring) or 255
    return r,g,b,a
end

local function djui_hud_print_outlined_text_interpolated_with_color(text, prevX, prevY, prevScale, x, y, scale, alpha, outlineDarkness)
    local space = 0
    local color = ""
    local render = ""
    text,color,render = remove_color(text,true)
    local r,g,b,a = 255,255,255,alpha or 255
    while render ~= nil do
      if render ~= "" then
        djui_hud_print_outlined_text_interpolated(render, prevX+space, prevY, prevScale, x+space, y, scale, r, g, b, a, outlineDarkness);
      end
      r,g,b,a = convert_color(color)
      space = space + djui_hud_measure_text(render) * scale
      text,color,render = remove_color(text,true)
    end
    djui_hud_print_outlined_text_interpolated(text, prevX+space, prevY, prevScale, x+space, y, scale, r, g, b, a, outlineDarkness);
  end

local function name_without_hex(name)
    local s = ''
    local inSlash = false
    for i = 1, #name do
        local c = name:sub(i,i)
        if c == '\\' then
            inSlash = not inSlash
        elseif not inSlash then
            s = s .. c
        end
    end
    return s
end

local function split(s)
    local result = {}
    for match in (s):gmatch(string.format("[^%s]+", " ")) do
        table.insert(result, match)
    end
    return result
end

local function on_hud_render()
    if gGlobalSyncTable.dist == 0 or (not showSelfTag and network_player_connected_count() == 1) or not gNetworkPlayers[0].currAreaSyncValid or obj_get_first_with_behavior_id(id_bhvActSelector) ~= nil then return end

    djui_hud_set_resolution(RESOLUTION_N64)

    for i = if_then_else(showSelfTag, 0, 1), (MAX_PLAYERS - 1) do
        djui_hud_set_font(FONT_NORMAL)
        local m = gMarioStates[i]
        local out = { x = 0, y = 0, z = 0 }
        local pos = { x = m.marioObj.header.gfx.pos.x, y = m.pos.y + 210, z = m.marioObj.header.gfx.pos.z }
        if djui_hud_world_pos_to_screen_pos(pos, out) and m.marioBodyState.updateTorsoTime == gMarioStates[0].marioBodyState.updateTorsoTime and active_player(m) ~= 0 and m.action ~= ACT_IN_CANNON and (m.playerIndex ~= 0 or (m.playerIndex == 0 and m.action ~= ACT_FIRST_PERSON)) then
            local scale = MAX_SCALE
            local dist = vec3f_dist(gLakituState.pos, m.pos)
            if m.playerIndex ~= 0 and dist > 1000 then
                scale = 0.5
                scale = scale + dist / gGlobalSyncTable.dist
                scale = clampf(1 - scale, 0, MAX_SCALE)
            end
            local name = name_without_hex(gNetworkPlayers[i].name)
            local color = { r = 162, g = 202, b = 234 }
            local tag = ""

            if not mhExists then
              network_player_palette_to_color(gNetworkPlayers[i], SHIRT, color)
            else
              local dum,dum2,roleColor = get_role_name_and_color(i)
              color = roleColor
              tag = get_mh_tag(i)
            end

            local measure = djui_hud_measure_text(name) * scale * 0.5
            
            local alpha = if_then_else(m.action ~= ACT_CROUCHING and m.action ~= ACT_START_CRAWLING and m.action ~= ACT_CRAWLING and m.action ~= ACT_STOP_CRAWLING, 255, 100)

            local e = gStateExtras[i]

            local exHealthScale = 1
            djui_hud_print_outlined_text_interpolated(name, e.prevPos.x - measure, e.prevPos.y, e.prevScale, out.x - measure, out.y, scale, color.r, color.g, color.b, alpha, 0.25)
            if tag ~= "" then
                local tagMeasure = djui_hud_measure_text(name_without_hex(tag)) * scale * 0.5
                djui_hud_print_outlined_text_interpolated_with_color(tag, e.prevPos.x - tagMeasure, e.prevPos.y-32*e.prevScale, e.prevScale, out.x - tagMeasure, out.y-32*scale, scale, alpha, 0.25)
                exHealthScale = 1.3
            end

            if m.playerIndex ~= 0 and showHealth then
                djui_hud_set_adjusted_color(255, 255, 255, alpha)
                local healthScale = 75 * scale
                local prevHealthScale = 75 * e.prevScale
                if _G.mhExists then 
                    hud_render_power_meter_interpolated(m.health,
                        e.prevPos.x - (prevHealthScale * 0.5), e.prevPos.y - prevHealthScale * exHealthScale, prevHealthScale, prevHealthScale,
                        out.x - (healthScale * 0.5), out.y - healthScale * exHealthScale, healthScale, healthScale, m.playerIndex)
                else
                    hud_render_power_meter_interpolated(m.health,
                        e.prevPos.x - (prevHealthScale * 0.5), e.prevPos.y - prevHealthScale * exHealthScale, prevHealthScale, prevHealthScale,
                        out.x - (healthScale * 0.5), out.y - healthScale * exHealthScale, healthScale, healthScale)
                end
            end

            e.prevPos.x = out.x
            e.prevPos.y = out.y
            e.prevPos.z = out.z
            e.prevScale = scale
        end
    end
end

local function on_distance_command(msg)
    if not network_is_server() and not network_is_moderator() then
        djui_chat_message_create("\\#d86464\\You do not have permission to run this command.")
        return true
    end

    local dist = tonumber(msg)
    if dist ~= nil then
        djui_chat_message_create("Set nametag distance to " .. msg)
        gGlobalSyncTable.dist = dist
        return true
    else
        djui_chat_message_create("/nametags \\#00ffff\\distance\\#ffff00\\ [number]\\#ffffff\\\nSets the distance at which nametags disappear,\ndefault is \\#ffff00\\7000\\#ffffff\\, \\#ffff00\\0\\#ffffff\\ turns nametags off")
        return true
    end
    return false
end

local function on_show_health_command(msg)
    if msg == "?" then
        djui_chat_message_create("/nametags \\#00ffff\\show-health\\#ffffff\\\nToggles showing health above the nametag, default is \\#00ff00\\ON")
        return true
    end

    showHealth = not showHealth
    djui_chat_message_create("Show health status: " .. on_or_off(showHealth))
    return true
end

local function on_show_tag_command(msg)
    if msg == "?" then
        djui_chat_message_create("/nametags \\#00ffff\\show-tag\\#ffffff\\\nToggles your own nametag on or off, default is \\#ff0000\\OFF")
        return true
    end

    showSelfTag = not showSelfTag
    djui_chat_message_create("Show my tag status: " .. on_or_off(showSelfTag))
    return true
end

local function on_nametags_command(msg)
    local args = split(msg)
    if args[1] == "distance" then
        return on_distance_command(args[2])
    elseif args[1] == "show-health" then
        return on_show_health_command(args[2])
    elseif args[1] == "show-tag" then
        return on_show_tag_command(args[2])
    end
    return false
end

hook_event(HOOK_ON_HUD_RENDER, on_hud_render)

if SM64COOPDX_VERSION then
    hook_chat_command("nametags_mh", "\\#00ffff\\[show-tag|show-health|distance]", on_nametags_command)
else
    hook_chat_command("nametags", "\\#00ffff\\[show-tag|show-health|distance]", on_nametags_command)
end