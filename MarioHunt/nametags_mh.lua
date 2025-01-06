-- name: Nametags (MH)
-- description: Nametags\nBy \\#ec7731\\Agent X\\#dcdcdc\\\n\nThis mod adds nametags to sm64ex-coop, this helps to easily identify other players without the player list, nametags can toggled on and off with \\#ffff00\\/nametag-distance 7000\\#dcdcdc\\ and \\#ffff00\\/nametag-distance 0\\#dcdcdc\\ respectively.\n\nThis version uses the MarioHunt API.

local FADE_SCALE = 4

if gServerSettings.nametags ~= 0 then
    gGlobalSyncTable.tagDist = 7000
else
    gGlobalSyncTable.tagDist = 0
end
gServerSettings.nametags = 0

--local showHealth = true
gNametagsSettings.showHealth = true
--local showSelfTag = false
local showRoleColor = true

local gStateExtras = {}
for i = 0, (MAX_PLAYERS - 1) do
    gStateExtras[i] = {}
    local e = gStateExtras[i]
    e.prevPos = {}
    e.prevPos.x = 0
    e.prevPos.y = 0
    e.prevPos.z = 0
    e.prevScale = 1
    e.inited = false
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
local network_is_server = network_is_server
local is_player_active = is_player_active
local clampf = clampf
local is_game_paused = is_game_paused
local obj_get_first_with_behavior_id = obj_get_first_with_behavior_id
local djui_hud_get_fov_coeff = djui_hud_get_fov_coeff or function()
    return 1.13 -- backwards compatibility
end

local mh_is_spectator = function(index)
    return gPlayerSyncTable[index].spectator == 1
end

--[[for i in pairs(gActiveMods) do
    local name = gActiveMods[i].name:lower()
    if gActiveMods[i].enabled and (name:find("hide") or name:find("hns") or name:find("hunt")) then
        gGlobalSyncTable.tagDist = 0
    end
end]]

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

function djui_hud_print_outlined_text_interpolated(text, prevX, prevY, prevScale, x, y, scale, r, g, b, a,
                                                   outlineDarkness)
    local offset = 1 * (scale * 2)
    local prevOffset = 1 * (prevScale * 2)

    -- render outline
    djui_hud_set_color(r * outlineDarkness, g * outlineDarkness, b * outlineDarkness, a)
    djui_hud_print_text_interpolated(text, prevX - prevOffset, prevY, prevScale, x - offset, y, scale)
    djui_hud_print_text_interpolated(text, prevX + prevOffset, prevY, prevScale, x + offset, y, scale)
    djui_hud_print_text_interpolated(text, prevX, prevY - prevOffset, prevScale, x, y - offset, scale)
    djui_hud_print_text_interpolated(text, prevX, prevY + prevOffset, prevScale, x, y + offset, scale)
    -- render text
    djui_hud_set_color(r, g, b, a)
    djui_hud_print_text_interpolated(text, prevX, prevY, prevScale, x, y, scale)
    djui_hud_set_color(255, 255, 255, 255)
end

-- for tags
-- removes color string
local function remove_color(text, get_color)
    local start = text:find("\\")
    local next = 1
    while (next ~= nil) and (start ~= nil) do
        start = text:find("\\")
        if start ~= nil then
            next = text:find("\\", start + 1)
            if next == nil then
                next = text:len() + 1
            end

            if get_color then
                local color = text:sub(start, next)
                local render = text:sub(1, start - 1)
                text = text:sub(next + 1)
                return text, color, render
            else
                text = text:sub(1, start - 1) .. text:sub(next + 1)
            end
        end
    end
    return text
end

local function djui_hud_print_outlined_text_interpolated_with_color(text, prevX, prevY, prevScale, x, y, scale, alpha,
                                                                    outlineDarkness)
    local space = 0
    local color = ""
    local render = ""
    text, color, render = remove_color(text, true)
    local r, g, b, a = 255, 255, 255, alpha or 255
    while render ~= nil do
        if render ~= "" then
            djui_hud_print_outlined_text_interpolated(render, prevX + space, prevY, prevScale, x + space, y, scale, r, g,
                b, a, outlineDarkness);
        end
        r, g, b, a = convert_color(color)
        a = alpha or a
        space = space + djui_hud_measure_text(render) * scale
        text, color, render = remove_color(text, true)
    end
    djui_hud_print_outlined_text_interpolated(text, prevX + space, prevY, prevScale, x + space, y, scale, r, g, b, a,
        outlineDarkness);
end

local function name_without_hex(name)
    local s = ''
    local inSlash = false
    for i = 1, #name do
        local c = name:sub(i, i)
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

local invalid_nametag_action = {
    [ACT_START_CROUCHING] = 1,
    [ACT_CROUCHING] = 1,
    [ACT_STOP_CROUCHING] = 1,
    [ACT_START_CRAWLING] = 1,
    [ACT_CRAWLING] = 1,
    [ACT_STOP_CRAWLING] = 1,
    [ACT_IN_CANNON] = 1,
    [ACT_DISAPPEARED] = 1,
}

local function render_nametags()
    if gGlobalSyncTable.tagDist == 0 or (get_active_sabo() == 3 and gPlayerSyncTable[0].team == 1 and gPlayerSyncTable[0].spectator ~= 1) or (not gNametagsSettings.showSelfTag and network_player_connected_count() == 1) or not gNetworkPlayers[0].currAreaSyncValid or obj_get_first_with_behavior_id(id_bhvActSelector) then return end

    djui_hud_set_resolution(RESOLUTION_N64)
    local fovCoeff = djui_hud_get_fov_coeff() -- this is a very expensive calculation, so only run it once

    for i = if_then_else(gNametagsSettings.showSelfTag, 0, 1), (MAX_PLAYERS - 1) do
        djui_hud_set_font(FONT_SPECIAL)
        local m = gMarioStates[i]
        local np = gNetworkPlayers[i]
        local out = { x = 0, y = 0, z = 0 }
        local pos = { x = m.marioBodyState.headPos.x, y = m.marioBodyState.headPos.y + 100, z = m.marioBodyState.headPos.z }
        if np.currAreaSyncValid and active_player(m) ~= 0 and (not invalid_nametag_action[m.action]) and (m.playerIndex ~= 0 or m.action ~= ACT_FIRST_PERSON) and djui_hud_world_pos_to_screen_pos(m.marioObj.header.gfx.pos, out) and djui_hud_world_pos_to_screen_pos(pos, out) then
            local scale = -400 / out.z * fovCoeff

            -- collision nametags
            if scale >= 0 and gGlobalSyncTable.mhMode == 3 and m.playerIndex ~= 0 and gPlayerSyncTable[0].spectator ~= 1 and not no_wall_between_points(gLakituState.pos, pos) then
                scale = 0
            end

            local e = gStateExtras[i]
            if scale >= 0 then
                local name = np.name
                local vIndex = i
                local hookedString
                for a,func in ipairs(on_nametags_render_hooks) do
                    hookedString = func(i)
                end

                if hookedString ~= "" then
                    if hookedString then
                        name = hookedString
                        -- check if our name was changed to the same as another player; if so, set vIndex to that player
                        for a=0,MAX_PLAYERS-1 do
                            if name == name_without_hex(gNetworkPlayers[a].name) then
                                vIndex = a
                                break
                            end
                        end
                    else
                        name = name_without_hex(name)
                    end
                    local color = { r = 162, g = 202, b = 234 }
                    local tag = ""

                    if showRoleColor and know_team(vIndex) then
                        local dum, dum2, roleColor = mhApi.get_role_name_and_color(vIndex)
                        color = roleColor
                    else
                        local colorString = network_get_player_text_color_string(i)
                        color.r, color.g, color.b = convert_color(colorString)
                    end
                    tag = get_tag(vIndex)

                    local measure = djui_hud_measure_text(name) * scale * 0.5
                    out.y = out.y - 16 * scale
                    
                    local alpha = (i == 0 and 255 or math.min(np.fadeOpacity << 3, 255)) * clampf(FADE_SCALE - scale, 0, 1)
                    if i ~= 0 and out.z < -gGlobalSyncTable.tagDist + 1000 then
                        alpha = clamp((out.z + gGlobalSyncTable.tagDist) * 0.255, 0, alpha)
                    end

                    if not e.inited then
                        vec3f_copy(e.prevPos, out)
                        e.prevScale = scale
                        e.inited = true
                    end

                    local exHealthScale = 1
                    djui_hud_print_outlined_text_interpolated(name, e.prevPos.x - measure, e.prevPos.y, e.prevScale,
                        out.x - measure, out.y, scale, color.r, color.g, color.b, alpha, 0.25)
                    if tag ~= "" then
                        local tagMeasure = djui_hud_measure_text(name_without_hex(tag)) * scale * 0.5
                        djui_hud_print_outlined_text_interpolated_with_color(tag, e.prevPos.x - tagMeasure,
                            e.prevPos.y - 32 * e.prevScale, e.prevScale, out.x - tagMeasure, out.y - 32 * scale, scale, alpha,
                            0.25)
                        exHealthScale = 1.3
                    end

                    if m.playerIndex ~= 0 and gNametagsSettings.showHealth then
                        djui_hud_set_color(255, 255, 255, alpha)
                        local healthScale = 75 * scale
                        local prevHealthScale = 75 * e.prevScale
                        render_power_meter_interpolated_mariohunt(m.health,
                            e.prevPos.x - (prevHealthScale * 0.5), e.prevPos.y - prevHealthScale * exHealthScale,
                            prevHealthScale, prevHealthScale,
                            out.x - (healthScale * 0.5), out.y - healthScale * exHealthScale, healthScale, healthScale, m.playerIndex)
                    end
                end
            else
                e.inited = false
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
        gGlobalSyncTable.tagDist = dist
        return true
    else
        djui_chat_message_create(
        "/nametags \\#00ffff\\distance\\#ffff00\\ [number]\\#ffffff\\\nSets the distance at which nametags disappear,\ndefault is \\#ffff00\\7000\\#ffffff\\, \\#ffff00\\0\\#ffffff\\ turns nametags off")
        return true
    end
    return false
end

local function on_show_health_command(msg)
    if msg == "?" then
        djui_chat_message_create(
        "/nametags \\#00ffff\\show-health\\#ffffff\\\nToggles showing health above the nametag, default is \\#00ff00\\ON")
        return true
    end

    gNametagsSettings.showHealth = not gNametagsSettings.showHealth
    djui_chat_message_create("Show health status: " .. on_or_off(gNametagsSettings.showHealth))
    return true
end

local function on_show_tag_command(msg)
    if msg == "?" then
        djui_chat_message_create(
        "/nametags \\#00ffff\\show-tag\\#ffffff\\\nToggles your own nametag on or off, default is \\#ff0000\\OFF")
        return true
    end

    gNametagsSettings.showSelfTag = not gNametagsSettings.showSelfTag
    djui_chat_message_create("Show my tag status: " .. on_or_off(gNametagsSettings.showSelfTag))
    return true
end

local function on_color_command(msg)
    if msg == "?" then
        djui_chat_message_create(
        "/nametags \\#00ffff\\color\\#ffffff\\\nToggles the role color for all nametags, default is \\#00ff00\\ON")
        return true
    end

    showRoleColor = not showRoleColor
    djui_chat_message_create("Show role color status: " .. on_or_off(showRoleColor))
    return true
end

local function on_nametags_command(msg)
    local args = split(msg)
    if args[1] == "distance" or args[1] == "dist" then
        return on_distance_command(args[2])
    elseif args[1] == "show-health" then
        return on_show_health_command(args[2])
    elseif args[1] == "show-tag" then
        return on_show_tag_command(args[2])
    elseif args[1] == "color" then
        return on_color_command(args[2])
    end
    return false
end

hook_event(HOOK_ON_HUD_RENDER_BEHIND, render_nametags)

hook_chat_command("nametags", "\\#00ffff\\[show-tag|show-health|dist|color]", on_nametags_command)
