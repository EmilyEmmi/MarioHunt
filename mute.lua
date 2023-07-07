-- name: Mute (MH)
-- description: The host can mute players with /mute.\n\n(example: /mute 4)\n\nOriginal mod by Beard, this was edited to be compatible with MarioHunt using the MarioHunt API.

function on_chat_message(m, msg)
    if gPlayerSyncTable[m.playerIndex].mute then
        if m.playerIndex == 0 then
            djui_chat_message_create("You are muted.")
        end
        return false
    end
end

function mute_command(msg)
    if network_is_server() or network_is_moderator() then
        if network_player_from_global_index(tonumber(msg)) ~= nil then
            network_send(true, {id = "MUTE_PLAYER", playerIndex = tonumber(msg), muter = gNetworkPlayers[0].globalIndex, popupMessage = "\\#FFFFFF\\ was muted by "})
            djui_popup_create("\\#FFFFFF\\You muted ".."\\#FFFF00\\"..network_player_from_global_index(tonumber(msg)).name.."\\#FFFFFF\\.", 1)
            return true
        end
    end
end

function unmute_command(msg)
    if network_player_from_global_index(tonumber(msg)) ~= nil then
        network_send(true, {id = "MUTE_PLAYER", playerIndex = tonumber(msg), muter = gNetworkPlayers[0].globalIndex, popupMessage = "\\#FFFFFF\\ was unmuted by "})
        djui_popup_create("\\#FFFFFF\\You unmuted ".."\\#FFFF00\\"..network_player_from_global_index(tonumber(msg)).name.."\\#FFFFFF\\.", 1)
        return true
    end
end

function on_packet_receive(dataTable)
    if dataTable.id == "MUTE_PLAYER" then
        if gNetworkPlayers[0] == network_player_from_global_index(dataTable.playerIndex) then
            if dataTable.popupMessage == "\\#FFFFFF\\ was muted by " then
                gPlayerSyncTable[0].mute = true
            else
                gPlayerSyncTable[0].mute = false
            end
        end
        djui_popup_create("\\#FFFF00\\"..network_player_from_global_index(tonumber(dataTable.playerIndex)).name.. dataTable.popupMessage .. network_player_from_global_index(tonumber(dataTable.muter)).name, 1)
    end
end

-- here, we only hook the function if MarioHunt does not exist
if _G.mhExists then
  _G.mhApi.chatValidFunction = on_chat_message -- don't worry, it will still run
else
  hook_event(HOOK_ON_CHAT_MESSAGE, on_chat_message)
end
hook_event(HOOK_ON_PACKET_RECEIVE, on_packet_receive)
if network_is_server() then
    hook_chat_command("mute", "[player index]", mute_command)
    hook_chat_command("unmute", "[player index]", unmute_command)
end
