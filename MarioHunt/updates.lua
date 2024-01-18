
local updateFile = nil

_G.mhVersion = "v2.5" -- version string

function check_for_updates()
    if VERSION_NUMBER < 37 then return end -- only works in v37

    -- attempt to load the current verion's audio file
    local url = "https://github.com/EmilyEmmi/MarioHunt/raw/main/".._G.mhVersion..".mp3"
    updateFile = audio_stream_load_url(url)
    -- if it doesn't load, the file doesn't exist, so assume there's an update
    if not updateFile or not updateFile.loaded or updateFile.handle == 0 then
        djui_chat_message_create(trans("has_update"))
    else
        djui_chat_message_create(trans("up_to_date"))
    end
end

