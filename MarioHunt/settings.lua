-- this file now handles settings (saving/loading, listing, etc.)

settingsData = {
    { name = "mhMode",          langName = "menu_gamemode",          alwaysList = true, showStart = true },
    { name = "campaignCourse",  langName = "menu_campaign",          default = 0,       showStart = true,  noLoad = true },
    { name = "noBowser",        langName = "menu_defeat_bowser",     default = false,   noList = true,     romhackSave = true },
    { name = "starRun",         langName = "menu_category",          default = 70,      alwaysList = true, ignoreMini = true, showStart = true, romhackSave = true },
    { name = "gameArea",        langName = "menu_game_area",         default = 0,       showStart = true,  romhackSave = true, ignoreMini = true },
    { name = "freeRoam",        langName = "menu_free_roam",         default = false,   ignoreMini = true, showStart = true,  romhackSave = true },
    { name = "starSetting",     langName = "menu_star_setting",      default = gServerSettings.stayInLevelAfterStar, showStart = true,  alwaysList = true, ignoreMini = true },
    { name = "starStayOld",     langName = "menu_star_stay_old",     default = true,    showStart = true,  ignoreMini = true },
    { name = "pvpType",         langName = "menu_pvp_type",          default = gServerSettings.pvpType, showStart = true,  alwaysList = true },
    { name = "runnerLives",     langName = "menu_run_lives",         default = 1,       default_1 = 0,     default_2 = 0,     alwaysList = true },
    { name = "starMode",        langName = "menu_star_mode",         default = false,   ignoreMini = true, noList = true },
    { name = "runTime",         langName = "menu_time",              default = 7200,    default_2 = 9000,  alwaysList = true },
    { name = "spectateOnDeath", langName = "menu_spectate_on_death", default = false,   default_3 = true,  showStart = true },
    { name = "countdown",       langName = "menu_countdown",         default = 300,     default_3 = 600,   ignoreMini = true },
    { name = "maxShuffleTime",  langName = "menu_shuffle",           default = 0,       showStart = true },
    { name = "allowSpectate",   langName = "menu_allow_spectate",    default = true,    default_3 = false, forceMys = false },
    { name = "allowStalk",      langName = "menu_allow_stalk",       default = false,   default_3 = false, forceMys = false,  showStart = true, romhackSave = true },
    { name = "stalkTimer",      langName = "menu_stalk_timer",       default = 150,     noList = true },
    { name = "voidDmg",         langName = "menu_voidDmg",           default = 3,       alwaysList = true, showStart = true },
    { name = "nerfVanish",      langName = "menu_nerf_vanish",       default = true,    alwaysList = true },
    { name = "doubleHealth",    langName = "menu_double_health",     default = 0,       default_3 = 0,     showStart = true },
    { name = "weak",            langName = "menu_weak",              default = false },
    { name = "starHeal",        langName = "menu_star_heal",         default = false,   showStart = true },
    { name = "gameAuto",        langName = "menu_auto",              default = 0,       noList = true },
    { name = "dmgAdd",          langName = "menu_dmgAdd",            default = 0,       default_2 = 2,     default_3 = 6,     showStart = true, alwaysList = true },
    { name = "anarchy",         langName = "menu_anarchy",           default = 0,       default_2 = 1,     default_3 = 1,     showStart = true },
    { name = "firstTimer",      langName = "menu_first_timer",       default = true,    showStart = true,  alwaysList = true },
    { name = "showOnMap",       langName = "menu_show_on_map",       default = 1,       default_3 = 0,     forceMys = 0 },
    { name = "confirmHunter",   langName = "menu_confirm_hunter",    default = true,    mysOnly = true,    showStart = true,  alwaysList = true },
    { name = "huntersWinEarly", langName = "menu_hunters_win_early", default = false,   mysOnly = true,    showStart = true },
    { name = "maxGlobalTalk",   langName = "menu_global_chat",       default = 2700,    mysOnly = true,    alwaysList = true, showStart = true },
    { name = "noPlayerCol",     langName = "menu_no_player_col",     default = false,   showStart = true },
    { name = "defaultRole",     langName = "menu_default_role",      default = 0,       default_3 = 0,     forceMys = 0 },
    { name = "noWaterHeal",     langName = "menu_no_water_heal",     default = 0,       default_3 = 0, },
    { name = "invisWallFix",    langName = "menu_invis_wall_fix",    default = true, },
}

local GST = gGlobalSyncTable

-- load saved settings for host
function load_settings(prevMode, starOnly)
    if not network_is_server() then return end

    local loadRomHack = (not starOnly)

    for i, settingData in ipairs(settingsData) do
        local setting = settingData.name
        local toLoad = setting
        local option
        local currModeDefault = settingData["default_" .. GST.mhMode]
        local append = ""

        if prevMode then
            if prevMode == GST.mhMode then return end
            loadRomHack = false
            local prevModeDefault = prevMode and settingData["default_" .. prevMode]
            if settingData.default == nil or (prevModeDefault == nil and currModeDefault == nil) then
                toLoad = nil
            end
        end

        -- load star category based on game area setting
        if setting == "starRun" then
            local fileName = string.gsub(GST.romhackFile, " ", "_")
            local gameArea = 0
            if fileName == "vanilla" then
                gameArea = mod_storage_load_number("gameArea")
            else
                gameArea = mod_storage_load_number(fileName .. "_gameArea")
            end
            if gameArea ~= 0 then
                append = tostring(gameArea) .. "_" .. append
            end
        end

        if settingData.romhackSave then
            if not loadRomHack then
                toLoad = nil
            else
                local fileName = string.gsub(GST.romhackFile, " ", "_")
                if fileName ~= "vanilla" then
                    append = fileName .. "_" .. append
                end
            end
        end

        if settingData.noLoad then
            toLoad = nil
        elseif currModeDefault then
            if setting == "gameAuto" then
                if GST.mhMode ~= 2 then
                    append = "stan_" .. append
                end
            elseif GST.mhMode == 1 then
                append = "switch_" .. append
            elseif GST.mhMode == 2 then
                append = "mini_" .. append
            elseif GST.mhMode == 3 then
                append = "mys_" .. append
            end
        end

        if GST.mhMode == 3 and settingData.forceMys ~= nil then
            toLoad = nil
            option = tostring(settingData.forceMys)
        elseif (setting == "runTime") and GST.mhMode ~= 2 then
            if GST.starMode then
                toLoad = ("neededStars")
            end
        elseif starOnly then
            toLoad = nil
        elseif setting == "gameAuto" and GST.mhMode ~= 2 then
            toLoad = ("stan_" .. setting)
        end

        if append and toLoad then
            toLoad = append .. toLoad
        end

        if toLoad then
            option = mod_storage_load(toLoad)
        end

        if (not option) and toLoad then
            if toLoad ~= "neededStars" then
                option = tostring(currModeDefault)
            else
                option = "2"
            end
        end

        if option then
            local toSet
            if option == "true" then
                toSet = true
            elseif option == "false" then
                toSet = false
            elseif tonumber(option) then
                toSet = math.floor(tonumber(option))
            end

            -- type check
            if toSet ~= nil and type(GST[setting]) == type(toSet) then
                if setting == "mhMode" and toSet == 3 and disable_chat_hook then
                    djui_chat_message_create(trans("mysteryhunt_disabled"))
                    GST.mhMode = 0
                else
                    GST[setting] = toSet
                    if setting == "gameAuto" and toSet == 0 and (GST.mhState == 0 or GST.mhState >= 3) then
                        GST.mhTimer = 0
                    end
                end
                print("Loaded:", toLoad, option, toSet)
            elseif toSet ~= nil then
                print("Type check fail:", toLoad, type(GST[setting]), type(toSet))
            end
            
            if starOnly then break end
        end
    end
end

-- save settings for host
function save_settings()
    if not network_is_server() then return end

    for i, settingData in ipairs(settingsData) do
        local setting = settingData.name
        local append = ""
        local currModeDefault = settingData["default_" .. GST.mhMode]

        -- save star category based on game area setting
        if setting == "starRun" and GST.gameArea ~= 0 then
            append = tostring(GST.gameArea) .. "_" .. append
        end

        if settingData.romhackSave then
            local fileName = string.gsub(GST.romhackFile, " ", "_")
            if fileName ~= "vanilla" then
                append = fileName .. "_" .. append
            end
        end

        if settingData.noLoad or (GST.mhMode == 3 and settingData.forceMys ~= nil) then
            setting = nil -- don't save this
        elseif currModeDefault then
            if setting == "gameAuto" then
                if GST.mhMode ~= 2 then
                    append = "stan_" .. append
                end
            elseif GST.mhMode == 1 then
                append = "switch_" .. append
            elseif GST.mhMode == 2 then
                append = "mini_" .. append
            elseif GST.mhMode == 3 then
                append = "mys_" .. append
            end
        end

        if setting == "runTime" and GST.starMode then
            setting = "neededStars"
        end

        if setting then
            local option = GST[setting]
            if option ~= nil then
                setting = append .. setting
                print("Saved:", setting, option, type(option))
                if type(option) == "boolean" then
                    mod_storage_save_bool(setting, option)
                elseif tonumber(option) then
                    mod_storage_save(setting, tostring(math.floor(option)))
                end
            end
        end
    end
end

-- loads default settings for host
function default_settings()
    setup_hack_data(true, false, OmmEnabled)

    for i, settingData in ipairs(settingsData) do
        local setting = settingData.name
        --djui_chat_message_create(tostring(setting)..tostring(settingData.default))
        if settingData.noLoad then
            -- nothing
        elseif settingData["default_" .. GST.mhMode] ~= nil then
            GST[setting] = settingData["default_" .. GST.mhMode]
        elseif settingData.default ~= nil then
            GST[setting] = settingData.default
        end
    end
    return true
end

-- lists every setting
function list_settings()
    local displayNum = 0
    for i, settingData in ipairs(settingsData) do
        local setting = settingData.name
        local name, value = get_setting_as_string(i, GST[setting], true)

        if value then
            displayNum = displayNum + 1
            if name then
                djui_chat_message_create(name .. ": " .. value)
            else
                djui_chat_message_create(value)
            end
        end
    end
    if displayNum > 10 then
        djui_chat_message_create(trans("scroll_up"))
    end
end

-- used for list settings and whenever a setting is changed
function get_setting_as_string(index, value, listing)
    local transName = true
    local settingData = settingsData[index]
    local name = settingData.langName
    local default = settingData["default_" .. GST.mhMode]
    if not default then default = settingData.default end
    if listing and (settingData.noList or (GST.mhMode == 3 and settingData.forceMys ~= nil) or (value == default and (not settingData.alwaysList)) or (settingData.ignoreMini and GST.mhMode == 2) or (settingData.mysOnly and GST.mhMode ~= 3)) then
        value = nil
    elseif name == "menu_gamemode" then -- gamemode
        if value == 0 then
            value = "\\#00ffff\\Normal"
        elseif value == 1 then
            value = "\\#5aff5a\\Swap"
        elseif value == 2 then
            value = "\\#ffff5a\\Mini"
        elseif value == 3 then
            value = "\\#b45aff\\Mystery"
        else
            value = "INVALID: " .. tostring(value)
        end
        if GST.gameAuto ~= 0 then
            local auto = ""
            if GST.gameAuto == -1 then
                auto = " \\#5aff5a\\(Auto)"
            elseif GST.gameAuto == 1 then
                auto = " \\#00ffff\\(Auto, 1 " .. trans("runner") .. ")"
            elseif GST.gameAuto > 1 then
                auto = " \\#00ffff\\(Auto, " .. GST.gameAuto .. " " .. trans("runners") .. ")"
            elseif GST.gameAuto == -3 then
                auto = " \\#ff5a5a\\(Auto, 1 " .. trans("hunter") .. ")"
            else
                local num = -GST.gameAuto - 2
                auto = " \\#ff5a5a\\(Auto, " .. num .. " " .. trans("hunters") .. ")"
            end
            value = value .. auto
        end
    elseif name == "menu_auto" then
        if value == -1 then
            value = "\\#5aff5a\\Auto"
        elseif value == 1 then
            value = "\\#00ffff\\1 " .. trans("runner")
        elseif value == 0 then
            value = false
        elseif value > 1 then
            value = "\\#00ffff\\" .. value .. " " .. trans("runners")
        elseif value == -3 then
            value = "\\#ff5a5a\\1 " .. trans("hunter")
        else
            value = -value - 2
            value = "\\#ff5a5a\\" .. value .. " " .. trans("hunters")
        end
    elseif name == "menu_time" then -- run time or stars needed
        name = nil
        local timeLeft = value
        if GST.mhMode == 2 then
            name = "menu_time"
            local seconds = timeLeft // 30 % 60
            local minutes = (timeLeft // 1800)
            value = "\\#ffff5a\\" .. string.format("%d:%02d", minutes, seconds)
        elseif GST.starMode then
            value = trans("stars_left", timeLeft)
        else
            timeLeft = timeLeft + 29
            local seconds = timeLeft // 30 % 60
            local minutes = (timeLeft // 1800)
            value = trans("time_left", minutes, seconds)
        end
    elseif name == "menu_anarchy" then -- team attack / hunters know team
        if GST.mhMode == 3 then
            name = "menu_know_team"
            value = (value ~= 3)
        elseif value == 3 then
            value = true
        elseif value == 1 then
            value = "\\#00ffff\\" .. trans("runners")
        elseif value == 2 then
            value = "\\#ff5a5a\\" .. trans("hunters")
        else
            value = false
        end
    elseif name == "menu_show_on_map" then -- similar to above
        if value == 1 then
            value = "\\#00ffff\\" .. trans("runners")
        elseif value == 2 then
            value = "\\#ff5a5a\\" .. trans("hunters")
        elseif value == 3 then
            value = "\\#ffff5a\\" .. trans("opponents")
        elseif value == 4 then
            value = "\\#5aff5a\\" .. trans("all")
        else
            value = false
        end
    elseif name == "menu_double_health" or name == "menu_no_water_heal" then -- even more similar to above
        if value == 0 then
            value = false
        elseif value == 2 then
            value = "\\#ff5a5a\\" .. trans("hunters")
        elseif value == 3 then
            value = "\\#5aff5a\\" .. trans("all")
        else
            value = "\\#00ffff\\" .. trans("runners")
        end
    elseif name == "menu_default_role" then -- there's a pattern
        if value == 1 then
            value = "\\#00ffff\\" .. trans("runners")
        else
            value = "\\#ff5a5a\\" .. trans("hunters")
        end
    elseif name == "menu_pvp_type" then -- pvp type
        if value == PLAYER_PVP_CLASSIC then
            value = "\\#ffff5a\\" .. trans("pvp_type_classic")
        elseif value == PLAYER_PVP_REVAMPED then
            value = "\\#5aff5a\\" .. trans("pvp_type_revamped")
        end
    elseif name == "menu_category" then -- category
        local numVal = value
        if value == -1 then
            value = "\\#5aff5a\\Any%"
        else
            value = "\\#ffff5a\\" .. value .. " Star"
        end
        if GST.noBowser and numVal > 0 then
            value = value .. "\\#ff5a5a\\" .. " (No Bowser)"
        end
    elseif name == "menu_defeat_bowser" then
        local bad = ROMHACK["badGuy_" .. lang] or ROMHACK.badGuy or "Bowser"
        name = trans(name, bad)
        transName = false
        value = not value
    elseif (name == "menu_campaign") then -- minihunt campaign
        if GST.mhMode == 2 then
            if value == 0 then value = false end
        else
            value = nil
        end
    elseif name == "menu_first_timer" then -- leader death timer
        if GST.mhMode ~= 2 then
            value = nil
        end
    elseif name == "menu_dmgAdd" or name == "menu_voidDmg" then
        if value == -1 then
            value = "\\#ff5a5a\\OHKO"
        end
    elseif name == "menu_allow_stalk" then
        if value and GST.stalkTimer ~= 150 then
            local seconds = GST.stalkTimer // 30 % 60
            local minutes = (GST.stalkTimer // 1800)
            value = trans("on") .. string.format(" (%d:%02d)", minutes, seconds)
        end
    elseif name == "menu_countdown" or name == "menu_stalk_timer" or name == "menu_shuffle" then
        if name == "menu_shuffle" and value == 0 then
            value = false
        elseif name == "menu_countdown" then
            if value == 300 and listing then
                value = nil
            elseif GST.mhMode == 3 then
                name = "menu_grace_period"
            end
        end
        if value then
            local seconds = value // 30 % 60
            local minutes = (value // 1800)
            value = "\\#ffff5a\\" .. string.format("%d:%02d", minutes, seconds)
        end
    elseif name == "menu_star_setting" then
        if GST.mhMode == 2 then
            value = nil
        elseif value == 0 then
            value = "\\#ff5a5a\\" .. trans("star_leave")
        elseif value == 1 then
            value = "\\#ffff5a\\" .. trans("star_stay")
        elseif value == 2 then
            value = "\\#5aff5a\\" .. trans("star_nonstop")
        end
    elseif name == "menu_star_stay_old" then
        if gServerSettings.stayInLevelAfterStar ~= 0 then value = nil end
    elseif name == "menu_global_chat" then
        if value == -30 then
            value = false
        elseif value == 0 then
            value = "\\#5aff5a\\Always"
        else
            local seconds = value // 30 % 60
            local minutes = (value // 1800)
            value = "\\#ffff5a\\" .. string.format("%d:%02d", minutes, seconds)
        end
    elseif name == "menu_game_area" then
        local data = ROMHACK and ROMHACK.gameAreaData and ROMHACK.gameAreaData[value+1]
        if not (data and data.name) then
            value = "\\#ff5a5a\\Default"
        else
            value = "\\#5aff5a\\" .. data.name
        end
    end

    if value == true then
        value = trans("on")
    elseif value == false then
        value = trans("off")
    elseif tonumber(value) then
        value = "\\#ffff5a\\" .. value
    end

    if name and transName then
        name = trans(name)
    end

    return name, value
end

-- if our last booted version is below this one, handle backwards compatibility
-- also sets last booted version
function handle_backwards_compatibility()
    local lastBootedVersion = mod_storage_load_number("lastVersion")
    mod_storage_save_number("lastVersion", _G.mhVersionNum)

    local fileName = string.gsub(GST.romhackFile, " ", "_")
    local lastBootedVersionHack =  mod_storage_load_number(fileName.."_lastVersion")
    mod_storage_save_number(fileName.."_lastVersion", _G.mhVersionNum)

    if lastBootedVersion < _G.mhVersionNum then
        print("Doing backwards compatibility check")

        -- convert dmgAdd and auto
        local dmgAddOption = mod_storage_load("new_dmgAdd")
        if dmgAddOption then
            mod_storage_remove("new_dmgAdd")
            mod_storage_save("dmgAdd", dmgAddOption)
        else
            dmgAddOption = mod_storage_load("dmgAdd")
            if dmgAddOption == "8" then
                mod_storage_save("dmgAdd", "-1")
            end
        end
        local autoOption = mod_storage_load("gameAuto")
        if autoOption == "99" then
            mod_storage_save("gameAuto", "-1")
        end
        local doubleHealthOption = mod_storage_load("doubleHealth")
        if doubleHealthOption == "true" then
            mod_storage_save("doubleHealth", "1")
        elseif doubleHealthOption == "false" then
            mod_storage_save("doubleHealth", "0")
        end
    end

    -- convert old romhack field saving formats
    if lastBootedVersionHack < _G.mhVersionNum then
        print("Doing backwards compatibility check (hack)")
        
        local optionCategory = mod_storage_load(fileName)
        local optionNoBow = mod_storage_load(fileName .. "_noBow")
        local optionStalk = mod_storage_load(fileName .. "_stalk")
        local saveFileName = fileName .. "_"
        if fileName == "vanilla" then
            saveFileName = ""
        end

        if optionCategory then
            mod_storage_remove(fileName)
            mod_storage_save(saveFileName.."starRun", optionCategory)
        end
        if optionNoBow then
            mod_storage_remove(fileName .. "_noBow")
            if tonumber(optionNoBow) then
                local num = tonumber(optionNoBow)
                mod_storage_save_bool(saveFileName.."noBowser", num & 1 ~= 0)
                mod_storage_save_bool(saveFileName.."freeRoam", num & 2 ~= 0)
            else
                mod_storage_save(saveFileName .. "noBowser", optionNoBow)
            end
        end
        if optionStalk then
            mod_storage_remove(fileName .. "_stalk")
            mod_storage_save_bool(saveFileName .. "allowStalk", optionStalk ~= "0")
        end
    end
end

-- changes default for setting, mainly for rom hacks
function change_setting_default(setting, value)
    for i, oSetting in ipairs(settingsData) do
        if oSetting.name == setting then
            oSetting.default = value
            break
        end
    end
end

-- displays a message when a setting is changed
function on_setting_changed(tag, oldVal, newVal)
    if newVal == nil or oldVal == newVal then return end

    local settingData = settingsData[tonumber(tag)]
    if not settingData then return end
    local settingName = settingData.langName
    if not settingName then
        return
    elseif settingName == "menu_gamemode" then
        if oldVal == nil then return end
        return on_mode_changed(tag, oldVal, newVal)
    end

    if (not noSettingDisp) and (settingName ~= "menu_star_setting" or not OmmEnabled) then
        local name, value, oldvalue
        name, value = get_setting_as_string(tonumber(tag), newVal)
        name, oldvalue = get_setting_as_string(tonumber(tag), oldVal)

        if value and oldVal ~= nil then
            if name then
                djui_chat_message_create(trans("change_setting"))
                djui_chat_message_create(name .. ": " .. oldvalue .. "\\#dcdcdc\\->" .. value)
            else
                djui_chat_message_create(trans("change_setting"))
                djui_chat_message_create(oldvalue .. "\\#dcdcdc\\->" .. value)
            end
        end
    end

    if settingName == "menu_star_heal" then
        gLevelValues.starHeal = newVal
    elseif settingName == "menu_star_setting" then
        gServerSettings.stayInLevelAfterStar = newVal
    elseif settingName == "menu_pvp_type" then
        gServerSettings.pvpType = newVal
    elseif settingName == "menu_invis_wall_fix" then
        if oldVal ~= nil and not disableWallFixOption then
            gLevelValues.fixCollisionBugs = bool_to_int(newVal)
        end
    elseif settingName == "menu_star_mode" then
        noSettingDisp = true
        load_settings(nil, true)
    elseif settingName == "menu_allow_stalk" then
        if newVal ~= true then
            update_chat_command_description("stalk", "- " .. trans("command_disabled"))
        else
            update_chat_command_description("stalk", trans("stalk_desc"))
        end
    elseif settingName == "menu_allow_spectate" then
        if newVal ~= true then
            update_chat_command_description("spectate", "- " .. trans("command_disabled"))
        else
            update_chat_command_description("spectate", trans("spectate_desc"))
        end
    elseif settingName == "menu_game_area" then
        update_game_area(newVal)
    end
end

for i, settingData in ipairs(settingsData) do
    local setting = settingData.name
    if setting ~= "campaignCourse" then
        hook_on_sync_table_change(GST, setting, tostring(i), on_setting_changed)
    end
end

-- display the change in mode
function on_mode_changed(tag, oldVal, newVal)
    if oldVal == -1 or newVal == -1 then return end
    if oldVal and oldVal ~= newVal then
        if newVal == 0 then
            djui_chat_message_create(trans("mode_normal"))
        elseif newVal == 1 then
            djui_chat_message_create(trans("mode_swap"))
        elseif newVal == 2 then
            djui_chat_message_create(trans("mode_mini"))
        else
            djui_chat_message_create(trans("mode_mys"))
        end
        noSettingDisp = true

        if newVal == 3 then
            update_chat_command_description("gc", trans("gc_desc"))
        else
            update_chat_command_description("gc", "- "..trans("wrong_mode"))
        end

        if currMenu and (currMenu.name == "settingsMenu") then
            menu_reload()
            menu_enter()
        end

        if network_is_server() then
            change_game_mode("", newVal, oldVal)
        end
    end
end
