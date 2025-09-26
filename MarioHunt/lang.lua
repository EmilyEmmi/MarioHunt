--[[
Hello! For those who are looking to translate:
- PLEASE PLEASE PLEASE have more than a basic understanding of whatever language you're translating
- Scroll down and copy one of the language tables (I would copy English, as it's always complete)
- Translate all of the things. Make sure you don't miss anything, unless stated.
- Send the table (don't need the whole file) to me in some text style format (or do a pull request)
- Let me know who worked on it so I can provide proper credit
- Also note that I may ask for more translations in the future

Use "/mh langtest [ID,EXTRA1,EXTRA2,LANG]" for testing.
- ID is the phrase's id (ex: "to_switch")
- EXTRA1 is the first "blank" (ex: in "collect_bowser", this is the amount of stars)
- EXTRA2 is the second "blank" (ex: in "killed", this is the victim's name)
- LANG is what language, which is otherwise whichever one you have selected (ex: "fr" is french)
- add "plural" at the end for phrases that change based on the entered data
"/mh langtest all [LANG]" lists every id that doesn't have a translation

IF something you want to translate does not use this table, you can add it to your table and let me know
]]

-- this is the translate command, it supports up to two blanks
function trans(id, format, format2_, lang_)
  local usingLang = lang_ or lang or "en"
  local format2 = format2_ or 10
  if not id then
    return "INVALID"
  elseif month == 13 and not noSeason then
    if id == "menu_mh" or id == "rules_desc" or id == "up_to_date" or id == "has_update" then
      id = id .. "_egg"
    end
  end
  if not langdata then return id end

  if not langdata[usingLang] then
    usingLang = "en"
  end

  local translation = langdata[usingLang][id] or langdata["en"][id] or id
  if format then
    translation = string.format(translation, format, format2)
  end
  return translation
end

-- this is for scenarios where a word needs to be plural or not plural (usually "life/lives")
function trans_plural(id, format, format2_, lang_)
  local num = tonumber(format2_) or tonumber(format) or 0
  if num ~= 1 or not id then
    return trans(id, format, format2_, lang_)
  else
    return trans(id .. "_one", format, format2_, lang_)
  end
end

langdata = {} -- filled with each other file

-- this allows players to switch languages
function switch_lang(msg)
  if langdata[string.lower(msg)] then
    lang = string.lower(msg)
    djui_chat_message_create(trans("switched"))
    update_chat_command_description("mh", trans("mh_desc"))
    update_chat_command_description("rules", trans("rules_desc"))
    update_chat_command_description("lang", trans("lang_desc", lang_list))
    update_chat_command_description("stats", trans("stats_desc"))
    update_chat_command_description("hard", trans("hard_desc"))
    update_chat_command_description("tc", trans("tc_desc"))
    if (gGlobalSyncTable.allowStalk) then
      update_chat_command_description("stalk", trans("stalk_desc"))
    else
      update_chat_command_description("stalk", "- " .. trans("command_disabled"))
    end
    update_chat_command_description("timer", trans("menu_timer_desc"))
    update_chat_command_description("skip", trans("menu_skip_desc"))
    update_chat_command_description("target", trans("target_desc"))
    if (gGlobalSyncTable.allowSpectate) then
      update_chat_command_description("spectate", trans("spectate_desc"))
    else
      update_chat_command_description("spectate", "- " .. trans("command_disabled"))
    end
    if (gGlobalSyncTable.mhMode == 3) then
      update_chat_command_description("gc", trans("gc_desc"))
    else
      update_chat_command_description("gc", "- " .. trans("wrong_mode"))
    end
    --show_rules()
    return true
  end
  return false
end

hook_chat_command("lang", "PLACEHOLDER", switch_lang) -- description is updated later

-- debug command
function lang_test(msg)
  local args = split(msg or "", " ")
  if args[1] == "all" then
    local allLang = {}
    for lang, data in pairs(langdata) do
      if ((not args[2]) or lang == args[2]) and lang ~= "en" then
        table.insert(allLang, lang)
      end
    end
    if #allLang == 0 then
      djui_chat_message_create("Invalid language!")
      return true
    end

    for i, lang in ipairs(allLang) do
      local trans_missing = {}
      print("\n!!!!! Missing translation (" .. langdata[lang].fullname .. "): !!!!!")
      for id, phrase in pairs(langdata["en"]) do
        if id:sub(1, 6) ~= "debug_" and id:sub(1, 6) ~= "chara_" and not langdata[lang][id] then
          table.insert(trans_missing, id)
        end
      end
      table.sort(trans_missing)
      for i, id in ipairs(trans_missing) do
        local translated = trans(id, nil, nil, lang)
        djui_chat_message_create(id .. " lacks translation for " .. langdata[lang].fullname .. "!")
        print(string.format("%s = %q,", id, translated))
      end
    end
    return true
  end
  local id = args[1]
  local extra1 = args[2]
  local extra2 = args[3]
  local lang = args[4]
  if args[5] ~= "plural" then
    djui_chat_message_create(trans(id, extra1, extra2, lang))
  else
    djui_chat_message_create(trans_plural(id, extra1, extra2, lang))
  end

  return true
end

function on_mods_loaded()
  -- this generates a list of available languages for the command description
  lang = "en"
  local lang_table = {}
  for lang, data in pairs(langdata) do
    table.insert(lang_table, string.upper(lang))
  end
  table.sort(lang_table)
  lang_list = "["
  for i, name in ipairs(lang_table) do
    lang_list = lang_list .. name .. "|"
  end
  lang_list = lang_list:sub(1, -2) .. "]"

  -- this handles auto select
  for langname, data in pairs(langdata) do
    if data.fullname == smlua_text_utils_get_language() or (data.fullname == "Spanish" and data.fullname == smlua_text_utils_get_language():sub(1, -3)) then
      lang = langname
      break
    end
  end

  -- update some chat commands here
  update_chat_command_description("lang", trans("lang_desc", lang_list))
  update_chat_command_description("mh", trans("mh_desc"))
end
hook_event(HOOK_ON_MODS_LOADED, on_mods_loaded)