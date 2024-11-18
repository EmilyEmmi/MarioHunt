-- name: \\#f8b195\\Limbo\\#f67280\\kong's \\#c06c84\\Voice\\#6c5b7b\\chat (MH)
-- description: \\#ffffff\\Voicechat if you know what i'm sayin'?\ntwitter.com/limbokong\n\nThis version has MH support and also fixes some bugs

-- (Limbokong) IF YOU'RE READING THIS THEN HOLY SHIT DON'T JUDGE MY LUA CODING SKILLS PLEASE IT'S MY FIRST TIME USING LUA AND IM LIKE 16 YEARS OLD SO MY BRAIN IS DUMB
-- (Emily) That's fair

-- ver 0.5

local timer = 0
local saveString1 = ""
local saveLine2 = ""
local saveLine1 = ""
local playerVolumes = {}

gGlobalSyncTable.distanceMultiplier = 1

function save_command(msg)

    timer=timer+1

    if(timer >= 15) then

        saveLine1 = ""
        saveLine2 = ""

        --playerIndex; PlayerAmount; PlayerState
        saveString1 = gNetworkPlayers[0].globalIndex .. "-" .. tostring(network_player_connected_count()) .. "-0"

        -- (Emily) use MAX_PLAYERS instead of network_player_connected_count to make sure all players can be heard
        for i = 1, MAX_PLAYERS - 1, 1
        do
            --globalIndex; Distance; PlayerState

            if gNetworkPlayers[i].connected then
                currentPlayersDistance = 99
                currentPlayersMuffled = 0
                
                if(mhExists and mhApi.getMode() == 3 and mhApi.isDead(i) and not mhApi.isDead(0)) then -- (Emily) MH support; In MysteryHunt, don't hear dead unlesss also dead
                    currentPlayersDistance = "99"
                elseif(mhExists and ((mhApi.isGlobalTalkActive and mhApi.isGlobalTalkActive()) or (mhApi.getMode() ~= 3 and (mhApi.isSpectator(i) or mhApi.isSpectator(0))))) -- (Emily) MH support; always hear spectators, spectators always hear (non-mysteryhunt), hear all with global chat
                then
                    currentPlayersDistance = "0"
                elseif(is_player_active(gMarioStates[i]) == 0) -- (Emily) Replaced level check with is_player_active
                then
                    currentPlayersDistance = "99"
                elseif mhExists and mhApi.isSpectator(0) and mhApi.getFocusPos then -- (Emily) For mysteryhunt, spectators can only hear those they are nearby (unless global chat is active)
                    local focusPos = mhApi.getFocusPos()
                    currentPlayersDistance = tostring(clamp(math.floor(dist_between_object_and_point(gMarioStates[i].marioObj, focusPos.x, focusPos.y, focusPos.z) / (40 * gGlobalSyncTable.distanceMultiplier))))
                else
                    currentPlayersDistance = tostring(clamp(math.floor(dist_between_objects(gMarioStates[0].marioObj, gMarioStates[i].marioObj) / (40 * gGlobalSyncTable.distanceMultiplier))))
                end

                if(obj_get_first_with_behavior_id(id_bhvActSelector) ~= nil)
                then
                    currentPlayersDistance = "99"
                end

                if((gMarioStates[i].currentRoom ~= gMarioStates[0].currentRoom) and (gNetworkPlayers[i].currLevelNum == gNetworkPlayers[0].currLevelNum))
                then
                    currentPlayersMuffled = 1
                end

                if((gMarioStates[i].flags & MARIO_VANISH_CAP) ~= 0)
                then
                    currentPlayersMuffled = 2
                end

                if((gMarioStates[i].flags & MARIO_METAL_CAP) ~= 0)
                then
                    currentPlayersMuffled = 3
                end

                saveString1 = saveString1 .. "_" .. gNetworkPlayers[i].globalIndex .. "-" .. currentPlayersDistance .. "-" .. currentPlayersMuffled
            end
        end

        count = 0

        
        
        for i in string.gmatch(saveString1, ".") do
            count = count + 1
            if(count >= 64)
            then
                saveLine2 = saveLine2 .. i
            else
                saveLine1 = saveLine1 .. i
            end
        end

        if(saveLine2 == "")
        then
            saveLine2 = "a"
        end

        mod_storage_save("1", saveLine1)
        mod_storage_save("2", saveLine2)


        

        if(string.find(gNetworkPlayers[0].name, "%W") == nil)
        then
            mod_storage_save("3", gNetworkPlayers[0].name)
        else

            newName = ""
            
            letterCount = 0

            for let in string.gmatch(gNetworkPlayers[0].name, ".") do
                if(string.find(let, "%W") == nil)
                then
                    newName = newName .. let
                end

                letterCount = letterCount + 1
            end

            if(newName == "")
            then
                mod_storage_save("3", "Player" .. gNetworkPlayers[0].globalIndex)
            else
                mod_storage_save("3", newName)
            end

        end

        timer = 0
    end

    return true

end

function set_distance_command(msg)

    -- (Emily) Added this to prevent other players from changing volumes
    if not (network_is_server() or network_is_moderator()) then
        djui_chat_message_create("\\#959595\\You gotta have permission! >:(")
        return true
    end

    if(msg == "")
    then
        djui_chat_message_create("\\#959595\\You gotta input a number! >:(")
        return true
    end

    if(tonumber(msg) ~= nil)
    then
        gGlobalSyncTable.distanceMultiplier = tonumber(msg) -- (Emily) added tonumber so this actually works
        djui_chat_message_create("\\#959595\\Voicechat Distance Multiplier is now set to \\#ffffff\\x" .. msg .. "\\#959595\\ for all players!")
    else
        djui_chat_message_create("\\#FF0000\\" .. msg .. "\\#959595\\ is not a number! >:(")
    end

    return true
end


function clamp(val)

    if(val > 99)
    then
        return 99
    else
        return val
    end
end

hook_event(HOOK_UPDATE, save_command)
hook_chat_command("setdistance", "[distance]", set_distance_command)