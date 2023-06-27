--[[
Hello! For those who are looking to translate:
- PLEASE PLEASE PLEASE have more than a basic understanding of whatever language you're translating
- Scroll down and copy one of the language tables (I would copy English, as it's always complete)
- Translate all of the things. Make sure you don't miss anything, unless stated.
- Send the table (don't need the whole file) to me in some text style format
- Let me know who worked on it so I can provide proper credit
- Also note that I may ask for more translations in the future

Use "/mh langtest [ID,EXTRA1,EXTRA2,LANG]" for testing.
- ID is the phrase's id (ex: "to_switch")
- EXTRA1 is the first "blank" (ex: in "collect_bowser", this is the amount of stars)
- EXTRA2 is the second "blank" (ex: in "killed", this is the victim's name)
- LANG is what language, which is otherwise whichever one you have selected (ex: "fr" is french)
- add "plural" at the end for phrases that change based on the entered data
"/mh langtest all [LANG]" lists every id that doesn't have a translation (this does not include incomplete translations)
]]

-- this is the translate command, it supports up to two blanks
function trans(id,format,format2_,lang_)
  local usingLang = lang_ or lang or "en"
  local format2 = format2_ or 10
  if id == nil then return "INVALID" end
  if langdata == nil then return id end

  if langdata[usingLang] == nil then
    usingLang = "en"
  end

  local translation = langdata[usingLang][id] or langdata["en"][id] or id
  if format ~= nil then
    translation = string.format(translation,format,format2)
  end
  return translation
end
-- this is for scenarios where a word needs to be plural or not plural (usually "life/lives")
function trans_plural(id,format,format2_,lang_)
  local num = tonumber(format2_) or tonumber(format) or 0
  if num ~= 1 or id == nil then
    return trans(id,format,format2_,lang_)
  else
    return trans(id.."_one",format,format2_,lang_)
  end
end

langdata = {}

-- below is where all of the language data starts

langdata["en"] = -- the letters here will be what you type for the command (ex: to switch to this language, type "/lang en")
{
  -- fullname for auto select (make sure this matches in-game under Misc -> Languages)
  fullname = "English",

  -- global command info
  to_switch = "Type \"/lang %s\" to switch languages",
  switched = "Switched to English!", -- Replace "English" with the name of this language
  rule_command = "Type /rules to show this message again",
  stalk = "Use /stalk to warp to runners!",

  -- roles
  runner = "Runner",
  runners = "Runners",
  short_runner = "Run", -- unused
  hunters = "Hunters",
  hunter = "Hunter",
  spectator = "Spectator",
  player = "Player",

  -- rules
  --[[
    This is laid out as follows:
    {welcome|welcome_mini}
    {runners}{shown_above|thats_you}{any_bowser|collect_bowser|mini_collect}
    {hunters}{thats_you}{all_runners|any_runners}
    {rule_lives_one|rule_lives}{time_needed|stars_needed}{become_hunter|become_runner}
    {infinite_lives}{spectate}
    {banned_glitchless|banned_general}{fun}

    I highly recommend testing this in-game
    Also:
    \\#ffffff\\ = white (default)
    \\#00ffff\\ = cyan (for Runner team name)
    \\#ff5c5c\\ = red (for Hunter team name and popups)
    \\#ffff5a\\ = yellow
    \\#5aff5a\\ = green
  ]]
  welcome = "Welcome to \\#00ffff\\Mario\\#ff5c5c\\Hunt\\#ffffff\\! HOW TO PLAY:",
  welcome_mini = "Welcome to \\#ffff5a\\Mini\\#ff5c5c\\Hunt\\#ffffff\\! HOW TO PLAY:",
  welcome_egg = "Welcome to \\#5aff5a\\Luigi\\#ff5c5c\\Hunt\\#ffffff\\! HOW TO PLAY:",
  all_runners = "Defeat all \\#00ffff\\Runners\\#ffffff\\.",
  any_runners = "Defeat any \\#00ffff\\Runners\\#ffffff\\.",
  shown_above = "(shown above)",
  any_bowser = "Defeat Bowser through any means necessary.",
  collect_bowser = "Collect %d star(s) and defeat Bowser.",
  mini_collect = "Be the first to collect the star.",
  collect_only = "Collect %d star(s).",
  thats_you = "(that's you!)",
  banned_glitchless = "NO: Cross teaming, BLJs, wall clipping, stalling, camping.",
  banned_general = "NO: Cross teaming, stalling, camping.",
  time_needed = "%d:%02d to leave any main stage; collect stars to decrease",
  stars_needed = "%d star(s) to leave any main stage",
  become_hunter = "become \\#ff5c5c\\Hunters\\#ffffff\\ when defeated",
  become_runner = "defeat a \\#00ffff\\Runner\\#ffffff\\ to become one",
  infinite_lives = "Infinite lives",
  spectate = "type \"/spectate\" to spectate",
  mini_goal = "\\#ffff5a\\Whoever collects the most stars in %d:%02d wins!\\#ffffff\\",
  fun = "Have fun!",

  -- hud, extra desc, and results text (%s is a placeholder for names, and %d is a placeholder for a number)
  win = "%s\\#ffffff\\ win!", -- team name is placed here
  can_leave = "\\#5aff5a\\Can leave course",
  cant_leave = "\\#ff5c5c\\Can't leave course",
  time_left = "Can leave in \\#ffff5a\\%d:%02d",
  stars_left = "Need \\#ffff5a\\%d star(s)\\#ffffff\\ to leave",
  in_castle = "In castle",
  until_hunters = "%d second(s) until \\#ff5c5c\\Hunters\\#ffffff\\ begin",
  until_runners = "%d second(s) until \\#00ffff\\Runners\\#ffffff\\ begin",
  lives_one = "1 life",
  lives = "%d lives",
  stars_one = "1 star",
  stars = "%d stars",
  no_runners = "No \\#00ffff\\Runners!",
  camp_timer = "Keep moving! \\#ff5c5c\\(%d)",
  game_over = "The game is over!",
  winners = "Winners: ",
  no_winners = "\\#ff5c5c\\No winners!",

  -- popups
  lost_life = "%s\\#ffa0a0\\ lost a life!",
  lost_all = "%s\\#ffa0a0\\ lost all of their lives!",
  now_runner = "%s\\#ffa0a0\\ is now a \\#00ffff\\Runner\\#ffa0a0\\.",
  now_hunter = "%s\\#ffa0a0\\ is now a \\#ff5c5c\\Hunter\\#ffa0a0\\.",
  got_star = "%s\\#ffa0a0\\ got a star!",
  got_key = "%s\\#ffa0a0\\ got a key!",
  rejoin_start = "%s\\#ffa0a0\\ has two minutes to rejoin.",
  rejoin_success = "%s\\#ffa0a0\\ rejoined in time!",
  rejoin_fail = "%s\\#ffa0a0\\ did not reconnect in time.",
  using_ee = "This is using Extreme Edition only.",
  not_using_ee = "This is using Standard Edition only.",
  killed = "%s\\#ffa0a0\\ killed %s!",
  sidelined = "%s\\#ffa0a0\\ finished off %s!",
  paused = "You have been paused.",
  unpaused = "You are no longer paused.",
  kill_combo_2 = "%s\\#ffa0a0\\ got a \\#ffff5a\\double\\#ffa0a0\\ kill!",
  kill_combo_3 = "%s\\#ffa0a0\\ got a \\#ffff5a\\triple\\#ffa0a0\\ kill!",
  kill_combo_4 = "%s\\#ffa0a0\\ got a \\#ffff5a\\quadruple\\#ffa0a0\\ kill!",
  kill_combo_5 = "%s\\#ffa0a0\\ got a \\#ffff5a\\quintuple\\#ffa0a0\\ kill!",
  kill_combo_large = "\\#ffa0a0\\Wow! %s\\#ffa0a0\\ got \\#ffff5a\\%d\\#ffa0a0\\ kills in a row!",
  set_hack = "Hack set to %s",
  incompatible_hack = "WARNING: Hack does not have compatibility!",
  vanilla = "Using vanilla game",
  omm_detected = "OMM Rebirth detected!",
  warp_spam = "Slow down with the warps!",

  -- command feedback
  not_mod = "You don't have the AUTHORITY to run this command, you fool!",
  no_such_player = "No such player exists",
  bad_id = "Invalid player ID!",

  -- more command feedback (only host or mod will see these, so it's not as critical)
  bad_param = "Invalid parameters!",
  bad_command = "Invalid command!",
  error_no_runners = "Can't start game with 0 runners!",
  set_team = "%s's team has been set to '%s'", -- First %s is player name, second is team name (now unused)
  not_started = "Game hasn't been started yet",
  set_lives_one = "%s now has 1 life",
  set_lives = "%s now has %d lives",
  not_runner = "%s isn't a Runner",
  may_leave = "%s may leave",
  must_have_one = "Must have at least 1 hunter",
  added = "Added runners: ", -- list comes afterward
  runners_are = "Runners are: ",
  set_lives_total = "Runner lives set to %d",
  wrong_mode = "Not available in this mode",
  need_time_feedback = "Runners can leave in %d second(s) now",
  game_time = "Game now lasts %d second(s)",
  need_stars_feedback = "Runners need %d star(s) now",
  new_category = "This is now a %d star run",
  new_category_any = "This is now an any% run",
  mode_normal = "In Normal mode",
  mode_switch = "In Switch mode",
  mode_mini = "In MiniHunt mode",
  using_stars = "Using stars collected",
  using_timer = "Using timer",
  can_spectate = "Hunters can now spectate",
  no_spectate = "Hunters can no longer spectate",
  all_paused = "All players paused",
  all_unpaused = "All players unpaused",
  player_paused = "%s has been paused",
  player_unpaused = "%s has been unpaused",
  now_metal = "All hunters are metal",
  not_metal = "All hunters are not metal",
  now_weak = "All players have half invincibility frames",
  not_weak = "All players have normal invincibility frames",
  auto_on = "Games will start automatically",
  auto_off = "Games will not start automatically",
  force_spectate = "Everyone must spectate",
  force_spectate_off = "Spectate is no longer forced",
  force_spectate_one = "%s must spectate",
  force_spectate_one_off = "%s does not have to spectate anymore",

  -- team chat
  tc_on = "Team chat is \\#5cff5c\\ON!",
  tc_off = "Team chat is \\#ff5c5c\\OFF!",
  to_team = "\\#8a8a8a\\To team: ",
  from_team = "\\#8a8a8a\\ (team): ",

  -- vote skip
  vote_skip = "%s\\#dcdcdc\\ voted to skip this star",
  vote_info = "Type /skip to vote",
  vote_pass = "The vote passed!",
  already_voted = "You've already voted.",

  -- hard mode
  hard_notice = "Psst, try typing /hard...",
  hard_on = "\\#ff5c5c\\Hard Mode\\#ffffff\\ is \\#5cff5c\\ON!",
  hard_off = "\\#ff5c5c\\Hard Mode\\#ffffff\\ is \\#ff5c5c\\OFF!",
  hard_info = "Interested in \\#ff5c5c\\Hard Mode\\#ffffff\\?"..
  "\n- Half health"..
  "\n- No water heal"..
  "\n- \\#ff5c5c\\One life"..
  "\n\\#ffffff\\Type /hard ON if you're up for the challenge.",
  no_hard_win = "Your Hard Wins score will not be updated for this game.",

  -- spectator
  hunters_only = "Only Hunters can spectate!",
  spectate_disabled = "Spectate is disabled!",
  timer_going = "Can't spectate during timer!", -- now unused
  spectate_self = "Can't spectate yourself!",
  spectator_controls = "Controls:"..
  "\nDPAD-UP: Turn off hud"..
  "\nDPAD-DOWN: Swap freecam/player view"..
  "\nDPAD-LEFT / DPAD-RIGHT: Switch player"..
  "\nJOYSTICK: Move"..
  "\nA: Go up"..
  "\nZ: Go down"..
  "\nType \"/spectate OFF\" to cancel",
  spectate_off = "No longer spectating.",
  empty = "EMPTY (%d )",
  free_camera = "FREE CAMERA",

  -- stats
  disp_wins_one = "%s\\#ffffff\\ has won 1 time as \\#00ffff\\Runner\\#ffffff\\!",
  disp_wins = "%s\\#ffffff\\ has won %d times as \\#00ffff\\Runner\\#ffffff\\!",
  disp_kills_one = "%s\\#ffffff\\ has killed 1 player!", -- unused
  disp_kills = "%s\\#ffffff\\ has killed %d players!",
  disp_wins_hard_one = "%s\\#ffffff\\ has won 1 time as \\#ffff5c\\Runner\\#ffffff\\ in \\#ff5c5c\\Hard Mode!\\#ffffff\\",
  disp_wins_hard = "%s\\#ffffff\\ has won %d times as \\#ffff5c\\Runner\\#ffffff\\ in \\#ff5c5c\\Hard Mode!\\#ffffff\\",
  -- for stats table
  stat_wins = "Wins",
  stat_kills = "Kills",
  stat_combo = "Max Kill Streak",
  stat_wins_hard = "Wins (Hard Mode)",
  stat_mini_stars = "Maximum Stars in one game of MiniHunt",
  stat_placement = "64 Tour Placement",

  -- placements
  place_1 = "\\#e3bc2d\\[1st Place]",
  place_2 = "\\#c5d8de\\[2nd Place]",
  place_3 = "\\#b38752\\[3rd Place]",
  place = "\\#e7a1ff\\[%dth Place]", -- thankfully we don't go up to 21
  place_0 = "\\#96ecff\\[DEV]", -- dev role

  -- command descriptions (only host or mod will see these, so it's not as critical)
  page = "\\#ffff5a\\Page %d/%d", -- page for mariohunt command
  start_desc = "[CONTINUE|MAIN|ALT|RESET] - Starts the game; add \"continue\" to not warp to start; add \"alt\" for alt save file (buggy); add \"main\" for main save file; add \"reset\" to reset file (buggy)",
  add_desc = "[INT] - Adds the specified amount of runners at random",
  random_desc = "[INT] - Picks the specified amount of runners at random",
  lives_desc = "[INT] - Sets the amount of lives Runners have, from 0 to 99 (note: 0 lives is still 1 life)",
  time_desc = "[NUM] - Sets the amount of time Runners have to wait to leave, in seconds",
  stars_desc = "[INT] - Sets the amount of stars Runners must collect to leave, from 1 to 7 (only in star mode)",
  category_desc = "[INT] - Sets the amount of stars Runners must have to face Bowser. Set to -1 for any%.",
  flip_desc = "[NAME|ID] - Flips the team of the specified player, or your own if none entered",
  setlife_desc = "[NAME|ID|INT,INT] - Sets the specified lives for the specified runner, or yourself if not specified",
  leave_desc = "[NAME|ID] - Allows the specified player, or yourself if none entered, to leave the level if they are a runner",
  mode_desc = "[NORMAL|SWITCH|MINI] - Changes game mode; switch switches runners when one dies",
  starmode_desc = "[ON|OFF] - Toggles using stars collected instead of time",
  spectator_desc = "[ON|OFF] - Toggles Hunters' ability to spectate",
  pause_desc = "[NAME|ID|ALL] - Toggles pause status for specified players, self if not specified, or all",
  metal_desc = "[ON|OFF] - Toggles making hunters appear as if they have the metal cap; this does not make them invincible",
  hack_desc = "[STRING] - Sets current rom hack",
  weak_desc = "[ON|OFF] - Cuts invincibility frames in half for all players",
  auto_desc = "[ON|OFF|NUM] - Start games automatically; host only, MiniHunt only",
  forcespectate_desc = "[NAME|ID|ALL] - Toggle forcing spectate for this player or all players",
  desync_desc = "- Attempts to fix desync errors",
  stop_desc = "- Stop the game",
  default_desc = "- Set settings to default; host only",

  -- These commands only appear to me, so I wouldn't bother translating them. You can delete these lines and everything should still work.
  print_desc = "[STRING] - Outputs message to console",
  warp_desc = "[LEVEL|C#|STRING,AREA,ACT,NODE] - Warp to level",
  quick_desc = "[LEVEL|C#|STRING,AREA,ACT,NODE] - Quick game testing",
  combo_desc = "[NUM] - Test combo message",
  field_desc = "[STRING] - Get specified field for all players",
  allstars_desc = "- Lists all stars",
  langtest_desc = "- Do language testing stuff",
}

langdata["es"] = -- massively improved by KanHeaven and SonicDark
{
  -- fullname for auto select
  fullname = "Spanish",

  -- global command info
  to_switch = "Escribe \"/lang %s\" para cambiar idioma",
  switched = "¡Cambiaste a español!",
  rule_command = "Escribe /rules para mostrar este mensaje otra vez",

  -- roles
  runner = "Corredor",
  runners = "Corredores",
  short_runner = "Corre",
  hunter = "Cazador",
  hunters = "Cazadores",
  spectator = "Espectador",
  player = "Jugador",

  -- rules (%d:%02d is time in minutes:seconds format)
  welcome = "¡Bienvenido a \\#00ffff\\Mario\\#ff5c5c\\Hunt\\#ffffff\\! CÓMO JUGAR:",
  welcome_mini = "¡Bienvenido a \\#ffff5a\\Mini\\#ff5c5c\\Hunt\\#ffffff\\! CÓMO JUGAR:",
  welcome_egg = "¡Bienvenido a \\#5aff5a\\Luigi\\#ff5c5c\\Hunt\\#ffffff\\! CÓMO JUGAR:",
  all_runners = "Eliminen a todos los \\#00ffff\\Corredores\\#ffffff\\.",
  any_runners = "Eiminen a cualquiera de los \\#00ffff\\Corredores\\#ffffff\\.",
  shown_above = "(mostrado arriba)",
  any_bowser = "Derrota a Bowser de cualquiera manera.",
  collect_bowser = "Recolecten %d estrella(s) y derroten a Bowser.",
  mini_collect = "Sé el primero en recolectar la estrella.",
  collect_only = "Recolecten %d estrella(s).",
  thats_you = "(¡ese eres tú!)",
  banned_glitchless = "NO: Traicionar a tu equipo, BLJs, atravesar paredes, frenar el avance del juego, campear.",
  banned_general = "NO: Traicionar a tu equipo, frenar el avance del juego, campear.",
  time_needed = "%d:%02d para salir de cualquier nivel; recolecta estrellas para reducir este tiempo",
  stars_needed = "%d estrella(s) para salir de cualquier nivel",
  become_hunter = "únete a los \\#ff5c5c\\Cazadores\\#ffffff\\ cuando hayas sido eliminado",
  become_runner = "elimina a un \\#00ffff\\Corredor\\#ffffff\\ para volverte uno", -- this was changed
  infinite_lives = "Vidas infinitas",
  spectate = "escribe \"/spectate\" para ser un espectador",
  mini_goal = "\\#ffff5a\\¡Quien recolecte la mayor cantidad de estrellas en %d:%02d gana!\\#ffffff\\",
  fun = "¡Diviértete!",

  -- hud, extra desc, and results text
  win = "¡%s\\#ffffff\\ ganan!",
  can_leave = "\\#5aff5a\\Puedes salir del nivel",
  cant_leave = "\\#ff5c5c\\No puedes salir del nivel", -- is this correct?
  time_left = "Puedes salir en \\#ffff5a\\%d:%02d",
  stars_left = "Necesitas \\#ffff5a\\%d estrella(s)\\#ffffff\\ para salir del nivel",
  in_castle = "En el Castillo",
  until_hunters = "Los \\#ff5c5c\\Cazadores\\#ffffff\\ empiezan en: %d segundo(s)",
  until_runners = "Los \\#00ffff\\Corredores\\#ffffff\\ empiezan en: %d segundo(s)",
  lives_one = "1 vida",
  lives = "%d vidas",
  stars_one = "1 estrella",
  stars = "%d estrellas",
  no_runners = "¡No hay \\#00ffff\\Corredores!",
  camp_timer = "¡Muévete! \\#ff5c5c\\(%d)",
  game_over = "¡La partida terminó!",
  winners = "Ganadores: ",
  no_winners = "\\#ff5c5c\\¡No hay ganadores!",

  -- popups
  lost_life = "¡%s\\#ffa0a0\\ perdió una vida!",
  lost_all = "¡%s\\#ffa0a0\\ perdió todas sus vidas!",
  now_runner = "%s\\#ffa0a0\\ ahora es un \\#00ffff\\Corredor\\#ffa0a0\\.",
  now_hunter = "%s\\#ffa0a0\\ ahora es un \\#ff5c5c\\Cazador\\#ffa0a0\\.",
  got_star = "¡%s\\#ffa0a0\\ consiguió una estrella!",
  got_key = "¡%s\\#ffa0a0\\ consiguió una llave!",
  rejoin_start = "%s\\#ffa0a0\\ tiene dos minutos para volver a unirse.",
  rejoin_success = "¡%s\\#ffa0a0\\ volvió a tiempo!",
  rejoin_fail = "%s\\#ffa0a0\\ no volvió a tiempo.", -- changed recently
  using_ee = "\\#ffa0a0\\La partida está teniendo lugar en Extreme Edition.",
  not_using_ee = "\\#ffa0a0\\La partida está teniendo lugar en Normal Edition.",
  killed = "¡%s\\#ffa0a0\\ mató a %s!",
  sidelined = "¡%s\\#ffa0a0\\ eliminó a %s!",
  paused = "Has sido pausado.",
  unpaused = "Ya no estás pausado.",
  kill_combo_2 = "¡%s\\#ffa0a0\\ hizo una \\#ffff5a\\doble\\#ffa0a0\\ muerte!",
  kill_combo_3 = "¡%s\\#ffa0a0\\ hizo una \\#ffff5a\\triple\\#ffa0a0\\ muerte!",
  kill_combo_4 = "¡%s\\#ffa0a0\\ hizo una \\#ffff5a\\cuádruple\\#ffa0a0\\ muerte!",
  kill_combo_5 = "¡%s\\#ffa0a0\\ hizo una \\#ffff5a\\quíntuple\\#ffa0a0\\ muerte!",
  kill_combo_large = "\\#ffa0a0\\¡Wow! ¡%s\\#ffa0a0\\ hizo \\#ffff5a\\%d\\#ffa0a0\\ muertes consecutivas!",
  set_hack = "Romhack seleccionado: %s",
  incompatible_hack = "ADVERTENCIA: ¡Este romhack no tiene compatibilidad!",
  vanilla = "Usando el juego original",
  omm_detected = "¡Se detectó OMM Rebirth!",

  -- command feedback
  not_mod = "No tienes la AUTORIDAD para usar este comando, ¡tontito!",
  no_such_player = "Ese jugador no existe",
  bad_id = "¡ID de jugador inválido!",

  -- more command feedback (only host or mod will see these, so it's not as critical)
  bad_param = "¡Parámetros inválidos!",
  bad_command = "¡Comando inválido!",
  error_no_runners = "¡No se puede iniciar la partida con 0 corredores!",
  set_team = "%s ahora es un '%s'", -- First %s is player name, second is team name (now unused)
  not_started = "La partida aún no ha iniciado",
  set_lives_one = "%s ahora tiene 1 vida",
  set_lives = "%s ahora tiene %d vidas",
  not_runner = "%s no es un Corredor",
  may_leave = "%s puede salir del nivel",
  must_have_one = "Debes tener al menos un cazador",
  added = "Se agregó a los corredores: ", -- list comes afterward
  runners_are = "Los corredores son: ",
  set_lives_total = "Vidas de los corredores ajustadas a %d",
  wrong_mode = "No disponible en este modo",
  need_time_feedback = "Los corredores podrán salir del nivel en %d segundo(s) ahora",
  game_time = "La partida ahora durará %d segundo(s)",
  need_stars_feedback = "Los corredores ahora necesitan %d estrella(s)",
  new_category = "Ahora esto es una %d star run",
  new_category_any = "Ahora esto es una any% run",
  mode_normal = "En modo Normal",
  mode_switch = "En modo Switch",
  mode_mini = "En modo MiniHunt",
  using_stars = "Usando estrellas recolectadas",
  using_timer = "Usando tiempo",
  can_spectate = "Los cazadores ahora pueden ser espectadores",
  no_spectate = "Los cazadores ya no pueden ser espectadores",
  all_paused = "Todos los jugadores han sido pausados",
  all_unpaused = "Todos los jugadores ya no están pausados",
  player_paused = "%s ha sido pausado",
  player_unpaused = "%s ya no está pausado",
  now_metal = "Todos los cazadores son de metal",
  not_metal = "Todos los cazadores ya no son de metal",
  now_weak = "Todos los jugadores tienen la mitad de invincibility frames",
  not_weak = "Todos los jugadores tienen invincibility frames normales",
  auto_on = "Las partidas empezarán automáticamente",
  auto_off = "Las partidas no empezarán automáticamente",

  -- team chat
  tc_on = "¡El chat de equipo está \\#5cff5c\\ACTIVADO!",
  tc_off = "¡El chat de equipo está \\#ff5c5c\\DESACTIVADO!",
  to_team = "\\#8a8a8a\\Para tu equipo: ",
  from_team = "\\#8a8a8a\\ (equipo): ",

  -- hard mode
  hard_notice = "Psst, intenta escribir /hard...",
  hard_on = "\\#ff5c5c\\Hard Mode\\#ffffff\\ \\#5cff5c\\ACTIVADO!",
  hard_off = "\\#ff5c5c\\Hard Mode\\#ffffff\\ \\#ff5c5c\\DESACTIVADO!",
  hard_info = "Interesado en \\#ff5c5c\\Hard Mode\\#ffffff\\?"..
  "\n- Sólo tienes la mitad de salud"..
  "\n- No te puedes curar usando el agua"..
  "\n- \\#ff5c5c\\Sólo tienes una vida"..
  "\n\\#ffffff\\Escribe /hard ON si aceptas el desafío.",

  -- spectator
  hunters_only = "¡Solo los Cazadores pueden ser espectadores!",
  spectate_disabled = "¡Modo espectador desactivado!",
  timer_going = "¡No puedes ser espectador cuando el tiempo corre!", -- now unused
  spectate_self = "¡No puedes ser espectador de ti mismo!",
  spectator_controls = "Controles:"..
  "\nDPAD-UP: Desactiva la interfaz"..
  "\nDPAD-DOWN: Cambia la vista entre cámara libre/punto de vista del jugador"..
  "\nDPAD-LEFT / DPAD-RIGHT: Cambia jugador"..
  "\nJOYSTICK: Moverse"..
  "\nA: Moverse hacia arriba"..
  "\nZ: Moverse hacia abajo"..
  "\nType \"/spectate OFF\" para cancelar",
  spectate_off = "Dejaste de ser espectador.",
  empty = "VACÍO (%d )",
  free_camera = "CÁMARA LIBRE",

  -- stats
  disp_wins_one = "¡%s\\#ffffff\\ ganó 1 vez como \\#00ffff\\Corredor\\#ffffff\\!",
  disp_wins = "¡%s\\#ffffff\\ ganó %d veces como \\#00ffff\\Corredor\\#ffffff\\!",
  disp_kills_one = "%s\\#ffffff\\ mató a 1 jugador!", -- unused
  disp_kills = "%s\\#ffffff\\ mató a %d jugadores!",
  disp_wins_hard_one = "¡%s\\#ffffff\\ ganó 1 vez como \\#ffff5c\\Corredor\\#ffffff\\ en \\#ff5c5c\\Hard Mode\\#ffffff\\!",
  disp_wins_hard = "¡%s\\#ffffff\\ ganó %d veces como \\#ffff5c\\Corredor\\#ffffff\\ en \\#ff5c5c\\Hard Mode\\#ffffff\\!",
  -- for stats table
  stat_wins = "Victorias",
  stat_kills = "Muertes",
  stat_combo = "Racha de muertes más alta",
  stat_wins_hard = "Victorias (Hard Mode)",
  stat_mini_stars = "Cantidad de estrellas más alta en una partida de MiniHunt",

  -- placements
  place_1 = "\\#e3bc2d\\[1o Lugar]",
  place_2 = "\\#c5d8de\\[2o Lugar]",
  place_3 = "\\#b38752\\[3o Lugar]",
  place = "\\#e7a1ff\\[%do Lugar]", -- thankfully we don't go up to 21

  -- command descriptions (only host or mod will see these, so it's not as critical)
  start_desc = "[CONTINUE|MAIN|ALT|RESET] - Inicia la partida; agrega \"continue\" para no ser enviado al principio; agrega \"alt\" para usar una ranura de guardado alternativa (puede causar bugs); agrega \"main\" para usar la ranura de guardado principal; agrega \"reset\" para reiniciar la ranura de guardado (puede causar bugs)", -- is this correct?
  add_desc = "[INT] - Agrega la cantidad especificada de corredores de manera aleatoria",
  random_desc = "[INT] - Escoge la cantidad de corredores de manera aleatoria",
  lives_desc = "[INT] - Ajusta la cantidad de vidas de los Corredores, de 0 a 99 (nota: 0 vidas es aún 1 vida)",
  time_desc = "[NUM] - Ajusta la cantidad de tiempo que deben esperar los Corredores para salir del nivel, en segundos",
  stars_desc = "[INT] - Ajusta la cantidad de estrellas que los Corredores deben recolectar para salir del nivel, de 1 a 7 (sólo en star mode)",
  category_desc = "[INT] - Ajusta la cantidad de estrellas que los Corredores deben recolectar para enfrentarse a Bowser. Ajústalo a -1 para any%.",
  flip_desc = "[NAME|ID] - Cambia el equipo del jugador especificado, o el tuyo, si no especificas a uno",
  setlife_desc = "[NAME|ID|INT,INT] - Ajusta las vidas especificadas para el corredor especificado, o tus vidas si no especificas a uno",
  leave_desc = "[NAME|ID] - Permite al jugador especificado, o a ti mismo, si no especificas a uno, abandonar el nivel si es un corredor.",
  mode_desc = "[NORMAL|SWITCH|MINI] - Cambia el modo de juego; switch cambia a los corredores cuando uno es eliminado",
  starmode_desc = "[ON|OFF] - Utiliza las estrellas recogidas en lugar del tiempo",
  spectator_desc = "[ON|OFF] - Permite a los cazadores ser espectadores",
  pause_desc = "[NAME|ID|ALL] - Pausa a los jugadores especificados, a ti mismo si no especificas uno, o todos",
  metal_desc = "[ON|OFF] - Hace que los cazadores tengan la apariencia de metal; esto no los hace invencibles",
  hack_desc = "[STRING] - Ajusta el rom hack actual",
  weak_desc = "[ON|OFF] - Reduce los invincibility frames a la mitad a todos los jugadores",
  auto_desc = "[ON|OFF|NUM] - Inicia la partida automaticamente; sólo para el anfitrion, sólo para MiniHunt",
}

langdata["de"] = -- by N64 Mario
{
  -- fullname for auto select
  fullname = "German",

  -- global command info
  to_switch = "Gebe \"/lang %s\" ein, um die Sprache zu wechseln",
  switched = "Auf Deutsch umgestellt!",
  rule_command = "Gebe /rules ein, um diese Nachricht erneut anzuzeigen",

  -- roles
  runner = "Läufer",
  runners = "Läufer",
  short_runner = "Run",
  hunters = "Jäger",
  hunter = "Jäger",
  spectator = "Zuschauer",
  player = "Spieler",

  -- rules
  welcome = "Wilkommen zu \\#00ffff\\Mario\\#ff5c5c\\Hunt\\#ffffff\\! WIE MAN SPIELT:",
  welcome_mini = "Wilkommen zu \\#ffff5a\\Mini\\#ff5c5c\\Hunt\\#ffffff\\! WIE MAN SPIELT:",
  welcome_egg = "Wilkommen zu \\#5aff5a\\Luigi\\#ff5c5c\\Hunt\\#ffffff\\! WIE MAN SPIELT:",
  all_runners = "Besiege alle \\#00ffff\\Läufer\\#ffffff\\.",
  any_runners = "Besiege alle \\#00ffff\\Läufer\\#ffffff\\.",
  shown_above = "(oben gezeigt)",
  any_bowser = "Besiege Bowser, egal durch welcher Art und Weise.",
  collect_bowser = "Sammle %d Stern(e) und besiege Bowser.",
  mini_collect = "Be the first to collect the star.", -- not translated yet
  collect_only = "Sammle %d Stern(e).",
  thats_you = "(das bist du!)",
  banned_glitchless = "NEIN: Cross-Teaming, BLJs, durch Wände clippen, hinhalten, camping.",
  banned_general = "NEIN: Cross-Teaming, stalling, camping.",
  time_needed = "%d:%02d um jeden Hauptkurs zu verlassen; Sammle Sterne zum Verringern",
  stars_needed = "%d Stern(e) werden benötigt, um jeden Hauptkurs zu verlassen",
  become_hunter = "werde \\#ff5c5c\\Jäger\\#ffffff\\, wenn du besiegt wirst",
  become_runner = "defeat a \\#00ffff\\Runner\\#ffffff\\ to become one", -- this was changed
  infinite_lives = "Unendlich viele Leben",
  spectate = "gebe \"/spectate\" ein, um zuzuschauen",
  mini_goal = "\\#ffff5a\\Whoever collects the most stars in %d:%02d wins!\\#ffffff\\", -- not translated yet
  fun = "Viel Spaß!",

  -- some untranslated things here
  -- hud, extra desc, and results text
  win = "%s\\#ffffff\\ haben gewonnen!",
  can_leave = "\\#5aff5a\\Kurs kann verlassen werden",
  cant_leave = "\\#ff5c5c\\Kurs kann nicht verlassen werden", -- is this correct?
  time_left = "Kannst in \\#ffff5a\\%d:%02d\\#ffffff\\ verlassen",
  stars_left = "Brauchst \\#ffff5a\\%d Stern(e)\\#ffffff\\ um zu verlassen",
  in_castle = "Im Schloss",
  until_hunters = "%d Sekunde(n) bis die \\#ff5c5c\\Jäger\\#ffffff\\ beginnen",
  until_runners = "%d Sekunde(n) bis die \\#00ffff\\Läufer\\#ffffff\\ beginnen",
  lives_one = "1 Leben",
  lives = "%d Leben",
  stars_one = "1 Stern",
  stars = "%d Sterne",
  no_runners = "Keine \\#00ffff\\Läufer!",
  camp_timer = "Weiter bewegen! \\#ff5c5c\\(%d)",
  game_over = "The game is over!",
  winners = "Gewinner: ", -- is this correct?
  no_winners = "\\#ff5c5c\\Keine Gewinner!", -- is this correct?

  -- popups
  lost_life = "%s\\#ffa0a0\\ hat einen Leben verloren!",
  lost_all = "%s\\#ffa0a0\\ hat ihr ganzes Leben verloren!",
  now_runner = "%s\\#ffa0a0\\ ist jetzt ein \\#00ffff\\Läufer\\#ffa0a0\\.",
  now_hunter = "%s\\#ffa0a0\\ ist jetzt ein \\#ff5c5c\\Jäger\\#ffa0a0\\.",
  got_star = "%s\\#ffa0a0\\ hat einen Stern bekommen!",
  got_key = "%s\\#ffa0a0\\ hat einen Schlüssel bekommen!",
  rejoin_start = "%s\\#ffa0a0\\ hat zwei Minuten um erneut beizutreten.",
  rejoin_success = "%s\\#ffa0a0\\ ist das Spiel pünktlich erneut beigetreten!",
  rejoin_fail = "%s\\#ffa0a0\\ did not reconnect in time.", -- changed recently
  using_ee = "Dies verwendet nur die Extreme Edition.",
  not_using_ee = "Dies verwendet nur die Standard Version.",
  killed = "%s\\#ffa0a0\\ hat %s getötet!",
  sidelined = "%s\\#ffa0a0\\ hat %s erledigt!",
  paused = "Du wurdest pausiert.",
  unpaused = "Du bist nicht mehr pausiert.",
  kill_combo_2 = "%s\\#ffa0a0\\ hat einen \\#ffff5a\\doppelten\\#ffa0a0\\ Kill!",
  kill_combo_3 = "%s\\#ffa0a0\\ hat einen \\#ffff5a\\dreifachen\\#ffa0a0\\ Kill!",
  kill_combo_4 = "%s\\#ffa0a0\\ hat einen \\#ffff5a\\vierfachen\\#ffa0a0\\ Kill!",
  kill_combo_5 = "%s\\#ffa0a0\\ hat einen \\#ffff5a\\fünffachen\\#ffa0a0\\ Kill!",
  kill_combo_large = "\\#ffa0a0\\Wow! %s\\#ffa0a0\\ hat \\#ffff5a\\%d\\#ffa0a0\\ Kills in Folge!",
  set_hack = "Hack set to %s",
  incompatible_hack = "WARNING: Hack does not have compatibility!",
  vanilla = "Using vanilla game",
  omm_detected = "OMM Rebirth detected!",

  -- command feedback
  not_mod = "You don't have the AUTHORITY to run this command, you fool!",
  no_such_player = "Es gibt nicht so einen Spieler",
  bad_id = "Ungültige Spieler ID!",

  -- more command feedback (only host or mod will see these, so it's not as critical)
  bad_param = "Invalid parameters!",
  bad_command = "Invalid command!",
  error_no_runners = "Can't start game with 0 runners!",
  set_team = "%s's team has been set to '%s'", -- First %s is player name, second is team name (now unused)
  not_started = "Game hasn't been started yet",
  set_lives_one = "%s now has 1 life",
  set_lives = "%s now has %d lives",
  not_runner = "%s isn't a Runner",
  may_leave = "%s may leave",
  must_have_one = "Must have at least 1 hunter",
  added = "Added runners: ", -- list comes afterward
  runners_are = "Runners are: ",
  set_lives_total = "Runner lives set to %d",
  wrong_mode = "Not available in this mode",
  need_time_feedback = "Runners can leave in %d second(s) now",
  game_time = "Game now lasts %d second(s)",
  need_stars_feedback = "Runners need %d star(s) now",
  new_category = "This is now a %d star run",
  new_category_any = "This is now an any% run",
  mode_normal = "In Normal mode",
  mode_switch = "In Switch mode",
  mode_mini = "In MiniHunt mode",
  using_stars = "Using stars collected",
  using_timer = "Using timer",
  can_spectate = "Hunters can now spectate",
  no_spectate = "Hunters can no longer spectate",
  all_paused = "All players paused",
  all_unpaused = "All players unpaused",
  player_paused = "%s has been paused",
  player_unpaused = "%s has been unpaused",
  now_metal = "All hunters are metal",
  not_metal = "All hunters are not metal",
  now_weak = "All players have half invincibility frames",
  not_weak = "All players have normal invincibility frames",
  auto_on = "Games will start automatically",
  auto_off = "Games will not start automatically",

  -- team chat
  tc_on = "Team chat ist \\#5cff5c\\AN!",
  tc_off = "Team chat ist \\#ff5c5c\\AUS!",
  to_team = "\\#8a8a8a\\zu Team: ",
  from_team = "\\#8a8a8a\\ (Team): ",

  -- hard mode
  hard_notice = "Psst, try typing /hard...",
  hard_on = "\\#ff5c5c\\Hard Mode\\#ffffff\\ is \\#5cff5c\\ON!",
  hard_off = "\\#ff5c5c\\Hard Mode\\#ffffff\\ is \\#ff5c5c\\OFF!",
  hard_info = "Interested in \\#ff5c5c\\Hard Mode\\#ffffff\\?"..
  "\n- Half health"..
  "\n- No water heal"..
  "\n- \\#ff5c5c\\One life"..
  "\n\\#ffffff\\Type /hard ON if you're up for the challenge.",

  -- spectator
  hunters_only = "Nur Jäger können zuschauen!",
  spectate_disabled = "Zuschauermodus ist deaktiviert!",
  timer_going = "Kann während des Timers nicht zuschauen!", -- now unused
  spectate_self = "Du kannst dich nicht selber zuschauen!",
  spectator_controls = "Steuerung:"..
  "\nDPAD-UP: HUD ausschalten"..
  "\nDPAD-DOWN: Freecam/Spieleransicht tauschen"..
  "\nDPAD-LEFT / DPAD-RIGHT: Spieler wechseln"..
  "\nJOYSTICK: Bewegen"..
  "\nA: Geh hoch"..
  "\nZ: geh runter"..
  "\nType \"/spectate OFF\" um abzubrechen",
  spectate_off = "Nicht mehr am zuschauen.",
  empty = "LEER (%d )",
  free_camera = "FREIE KAMERA",

  -- stats
  disp_wins_one = "%s\\#ffffff\\ hat 1 mal als Läufer gewonnen!",
  disp_wins = "%s\\#ffffff\\ hat %d mal als Läufer gewonnen!",
  disp_kills_one = "%s\\#ffffff\\ hat einen Spieler getötet!", -- unused
  disp_kills = "%s\\#ffffff\\ hat %d Spieler getötet!",
  disp_wins_hard_one = "%s\\#ffffff\\ hat 1 mal als \\#ffff5c\\Läufer\\#ffffff\\ gewonnen [in \\#ff5c5c\\Hard Mode\\#ffffff\\]!", -- not translated fully
  disp_wins_hard = "%s\\#ffffff\\ hat %d mal als \\#ffff5c\\Läufer\\#ffffff\\ gewonnen [in \\#ff5c5c\\Hard Mode\\#ffffff\\]!", -- not translated fully
  -- for stats table
  stat_wins = "Gewinnt",
  stat_kills = "Kills",
  stat_combo = "Max Kill Streak",
  stat_wins_hard = "Gewinnt (Hard Mode)", -- not translated fully
  stat_mini_stars = "Maximum Stars in one game of MiniHunt",

  -- placements
  place_1 = "\\#e3bc2d\\[Platz 1]",
  place_2 = "\\#c5d8de\\[Platz 2]",
  place_3 = "\\#b38752\\[Platz 3]",
  place = "\\#e7a1ff\\[Platz %d]", -- thankfully we don't go up to 21

  -- command descriptions (only host or mod will see these, so it's not as critical)
  start_desc = "[CONTINUE|MAIN|ALT|RESET] - Starts the game; add \"continue\" to not warp to start; add \"alt\" for alt save file (buggy); add \"main\" for main save file; add \"reset\" to reset file (buggy)",
  add_desc = "[INT] - Adds the specified amount of runners at random",
  random_desc = "[INT] - Picks the specified amount of runners at random",
  lives_desc = "[INT] - Sets the amount of lives Runners have, from 0 to 99 (note: 0 lives is still 1 life)",
  time_desc = "[NUM] - Sets the amount of time Runners have to wait to leave, in seconds",
  stars_desc = "[INT] - Sets the amount of stars Runners must collect to leave, from 1 to 7 (only in star mode)",
  category_desc = "[INT] - Sets the amount of stars Runners must have to face Bowser. Set to -1 for any%.",
  flip_desc = "[NAME|ID] - Flips the team of the specified player, or your own if none entered",
  setlife_desc = "[NAME|ID|INT,INT] - Sets the specified lives for the specified runner, or yourself if not specified",
  leave_desc = "[NAME|ID] - Allows the specified player, or yourself if none entered, to leave the level if they are a runner",
  mode_desc = "[NORMAL|SWITCH|MINI] - Changes game mode; switch switches runners when one dies",
  starmode_desc = "[ON|OFF] - Toggles using stars collected instead of time",
  spectator_desc = "[ON|OFF] - Toggles Hunters' ability to spectate",
  pause_desc = "[NAME|ID|ALL] - Toggles pause status for specified players, self if not specified, or all",
  metal_desc = "[ON|OFF] - Toggles making hunters appear as if they have the metal cap; this does not make them invincible",
  hack_desc = "[STRING] - Sets current rom hack",
  weak_desc = "[ON|OFF] - Cuts invincibility frames in half for all players",
  auto_desc = "[ON|OFF|NUM] - Start games automatically; host only, MiniHunt only",
}

langdata["pt-br"] = -- Made by PietroM (PietroM#4782)
{
  -- fullname for auto select (make sure this matches in-game under Misc -> Languages)
  fullname = "Portuguese",

  -- global command info
  to_switch = "Type \"/lang %s\" para trocar a linguagem.",
  switched = "Trocou para Português do Brasil!",
  rule_command = "Use o comando /rules para mostrar as regras novamente.",

  -- roles
  runner = "Corredor",
  runners = "Corredores",
  short_runner = "Corre",
  hunters = "Caçadores",
  hunter = "Caçador",
  spectator = "Observador",
  player = "Jogador",

  -- rules
  --[[
    This is laid out as follows:
    {welcome}
    {runners}{shown_above|thats_you}{any_bowser|collect_bowser}
    {hunters}{thats_you}{all_runners|any_runners}
    {rule_lives_one|rule_lives}{time_needed|stars_needed}{become_hunter|become_runner}
    {infinite_lives}{spectate}
    {banned_glitchless|banned_general}{fun}
    I highly recommend testing this in-game
    Also:
    \\#ffffff\\ = white (default)
    \\#00ffff\\ = cyan (for Runner team name)
    \\#ff5c5c\\ = red (for Hunter team name and popups)
    \\#ffff5a\\ = yellow
    \\#5aff5a\\ = green
  ]]
  welcome = "Bem vindo à \\#ff5c5c\\Caça-\\#00ffff\\Mario\\#ffffff\\! INSTRUÇÕES:",
  welcome_mini = "Bem vindo à \\#ffff5a\\Mini-\\#ff5c5c\\Caça\\#ffffff\\! INSTRUÇÕES:",
  welcome_egg = "Bem vindo à \\#ff5c5c\\Caça-\\#5aff5a\\Luigi\\#ffffff\\! INSTRUÇÕES:",
  all_runners = "Derrote todos os \\#00ffff\\Corredores\\#ffffff\\.",
  any_runners = "Derrote quaisquer \\#00ffff\\Corredores\\#ffffff\\.",
  shown_above = "(demonstrado acima)",
  any_bowser = "Derrote Bowser de qualquer maneira.",
  collect_bowser = "Colete %d estrela(s) e derrote Bowser.",
  mini_collect = "Seja o primeiro a coletar a estrela.", -- not translated yet
  collect_only = "Colete %d estrela(s).",
  thats_you = "(este é você!)",
  banned_glitchless = "NÃO DEVE: Ajudar a equipe oposta, BLJs, cruzar paredes com glitches, enrolar, guardar caixão.",
  banned_general = "NÃO DEVE: Ajudar a equipe oposta, enrolar, guardar caixão.",
  time_needed = "%d:%02d para sair de qualquer fase; coletar estrelas para diminuir o cronômetro",
  stars_needed = "%d estrela(s) para sair de qualquer fase",
  become_hunter = "você virará um dos \\#ff5c5c\\Caçadores\\#ffffff\\ quando derrotado",
  become_runner = "derrote um \\#00ffff\\Corredor\\#ffffff\\ para virar um",
  infinite_lives = "Vidas infinitas",
  spectate = "use o comando \"/spectate\" para observar a partida.",
  mini_goal = "\\#ffff5a\\Quem coletar mais estrelas em %d:%02d ganha!\\#ffffff\\",
  fun = "Se divirta!",

  -- hud, extra desc, and results text (%s is a placeholder for names, and %d is a placeholder for a number)
  win = "%s\\#ffffff\\ Ganham!", -- team name is placed here
  can_leave = "\\#5aff5a\\Pode sair do nível.",
  cant_leave = "\\#ff5c5c\\Não pode salir do nível.", -- is this correct?
  time_left = "Poderá sair em \\#ffff5a\\%d:%02d",
  stars_left = "Precisa-se de \\#ffff5a\\%d estrela(s)\\#ffffff\\ para sair.",
  in_castle = "Dentro do Castelo",
  until_hunters = "%d segundo(s) até que os \\#ff5c5c\\Caçadores\\#ffffff\\ comecem.",
  until_runners = "%d segundo(s) até que os \\#00ffff\\Corredores\\#ffffff\\ comecem.",
  lives_one = "1 vida",
  lives = "%d vidas",
  stars_one = "1 estrela",
  stars = "%d estrelas",
  no_runners = "Não há\\#00ffff\\Corredores!",
  camp_timer = "Continue se mexendo! \\#ff5c5c\\(%d)",
  game_over = "A partida acabou!",
  winners = "Vencedores: ",
  no_winners = "\\#ff5c5c\\Não há vencedores!",

  -- popups
  lost_life = "%s\\#ffa0a0\\ perdeu uma vida!",
  lost_all = "%s\\#ffa0a0\\ perdeu todas as suas vidas!",
  now_runner = "%s\\#ffa0a0\\ agora é um \\#00ffff\\Corredor\\#ffa0a0\\.",
  now_hunter = "%s\\#ffa0a0\\ agora é um \\#ff5c5c\\Caçador\\#ffa0a0\\.",
  got_star = "%s\\#ffa0a0\\ conseguiu uma estrela!",
  got_key = "%s\\#ffa0a0\\ pegou uma das chaves!",
  rejoin_start = "%s\\#ffa0a0\\ tem dois minutos para entrar novamente na partida.",
  rejoin_success = "%s\\#ffa0a0\\ entrou à tempo!",
  rejoin_fail = "%s\\#ffa0a0\\ Não reconectou a tempo.", -- changed recently
  using_ee = "Este servidor está usando a versão Extrema.",
  not_using_ee = "Este servidor usa a versão normal.",
  killed = "%s\\#ffa0a0\\ derrotou %s!",
  sidelined = "%s\\#ffa0a0\\ acabou de vez com %s!",
  paused = "Você está sob efeito de pausa.",
  unpaused = "Você não está mais sob o efeito de pausa.",
  kill_combo_2 = "%s\\#ffa0a0\\ já derrotou \\#ffff5a\\dois\\#ffa0a0\\ jogadores!",
  kill_combo_3 = "%s\\#ffa0a0\\ já derrotou \\#ffff5a\\três\\#ffa0a0\\ jogadores!",
  kill_combo_4 = "%s\\#ffa0a0\\ já derrotou \\#ffff5a\\quatro \\#ffa0a0\\ jogadores!",
  kill_combo_5 = "%s\\#ffa0a0\\ já derrotou \\#ffff5a\\cinco\\#ffa0a0\\ jogadores!",
  kill_combo_large = "\\#ffa0a0\\Uau! %s\\#ffa0a0\\ já consegiu\\#ffff5a\\%d\\#ffa0a0\\ baixas em uma única tacada!",
  set_hack = "A hack selecionada foi %s",
  incompatible_hack = "AVISO: Essa hack não é compatível!",
  vanilla = "Usando o jogo original",
  omm_detected = "OMM Rebirth está em uso!",

  -- command feedback
  not_mod = "Você não tem AUTORIDADE para usar esse comando, seu tolo!",
  no_such_player = "Esse jogador não existe.",
  bad_id = "ID de jogador inválido!",

  -- more command feedback (only host or mod will see these, so it's not as critical)
  bad_param = "Invalid parameters!",
  bad_command = "Invalid command!",
  error_no_runners = "Can't start game with 0 runners!",
  set_team = "%s's team has been set to '%s'", -- First %s is player name, second is team name (now unused)
  not_started = "Game hasn't been started yet",
  set_lives_one = "%s now has 1 life",
  set_lives = "%s now has %d lives",
  not_runner = "%s isn't a Runner",
  may_leave = "%s may leave",
  must_have_one = "Must have at least 1 hunter",
  added = "Added runners: ", -- list comes afterward
  runners_are = "Runners are: ",
  set_lives_total = "Runner lives set to %d",
  wrong_mode = "Not available in this mode",
  need_time_feedback = "Runners can leave in %d second(s) now",
  game_time = "Game now lasts %d second(s)",
  need_stars_feedback = "Runners need %d star(s) now",
  new_category = "This is now a %d star run",
  new_category_any = "This is now an any% run",
  mode_normal = "In Normal mode",
  mode_switch = "In Switch mode",
  mode_mini = "In MiniHunt mode",
  using_stars = "Using stars collected",
  using_timer = "Using timer",
  can_spectate = "Hunters can now spectate",
  no_spectate = "Hunters can no longer spectate",
  all_paused = "All players paused",
  all_unpaused = "All players unpaused",
  player_paused = "%s has been paused",
  player_unpaused = "%s has been unpaused",
  now_metal = "All hunters are metal",
  not_metal = "All hunters are not metal",
  now_weak = "All players have half invincibility frames",
  not_weak = "All players have normal invincibility frames",
  auto_on = "Games will start automatically",
  auto_off = "Games will not start automatically",

  -- team chat
  tc_on = "Chat de time está \\#5cff5c\\LIGADO!",
  tc_off = "Chat de time está \\#ff5c5c\\DESLIGADO!",
  to_team = "\\#8a8a8a\\Para time: ",
  from_team = "\\#8a8a8a\\ (time): ",

  -- hard mode
  hard_notice = "Psiu, tente usar o modo /hard...",
  hard_on = "\\#ff5c5c\\Modo Difícil\\#ffffff\\ está \\#5cff5c\\LIGADO!",
  hard_off = "\\#ff5c5c\\Modo Difícil\\#ffffff\\ está \\#ff5c5c\\DESLIGADO!",
  hard_info = "Interessado em usar o \\#ff5c5c\\Modo Difícil\\#ffffff\\?"..
  "\n- Barra de vida pela metade."..
  "\n- A água não recupera sua vida"..
  "\n- \\#ff5c5c\\Uma vida"..
  "\n\\#ffffff\\Use o comando /hard ON se você topa tentar o desafio.",

  -- spectator
  hunters_only = "Apenas os caçadores podem observar a partida!",
  spectate_disabled = "Modo de observação desligado!",
  timer_going = "Você não pode observar durante o temporizador!", -- now unused
  spectate_self = "Você não pode observar a si mesmo!",
  spectator_controls = "Controles:"..
  "\nDPAD-UP: Desligar a barra de status"..
  "\nDPAD-DOWN: Trocar entre câmera livre/visão do jogador"..
  "\nDPAD-LEFT / DPAD-RIGHT: Trocar de jogador"..
  "\nJOYSTICK: Movimentar"..
  "\nA: Ir para cima"..
  "\nZ: Ir para baixo"..
  "\nType \"/spectate OFF\" para cancelar.",
  spectate_off = "Não está mais observando.",
  empty = "VAZIO (%d )",
  free_camera = "CÂMERA LIVRE",

  -- stats
  disp_wins_one = "%s\\#ffffff\\ ganhou uma vez como \\#00ffff\\Corredor\\#ffffff\\!",
  disp_wins = "%s\\#ffffff\\ ganhou %d vezes como \\#00ffff\\Corredor\\#ffffff\\!",
  disp_kills_one = "%s\\#ffffff\\ matou um jogador!",
  disp_kills = "%s\\#ffffff\\ matou %d jogadores!",
  disp_wins_hard_one = "%s\\#ffffff\\ ganhou uma vez como \\#ffff5c\\Corredor\\#ffffff\\ no \\#ff5c5c\\Modo Difícil\\#ffffff\\!", -- not translated fully
  disp_wins_hard = "%s\\#ffffff\\ ganhou %d vezes como \\#ffff5c\\Corredor\\#ffffff\\ no \\#ff5c5c\\Modo Difícil\\#ffffff\\!", -- not translated fully
  -- for stats table
  stat_wins = "Vitórias",
  stat_kills = "Já Matou",
  stat_combo = "Combo Máx. de Assassinatos",
  stat_wins_hard = "Vitórias (Modo Difícil)",
  stat_mini_stars = "Máximo de Estrelas em uma rodada de Mini-Caça",

  -- placements
  place_1 = "\\#e3bc2d\\[1o Lugar]",
  place_2 = "\\#c5d8de\\[2o Lugar]",
  place_3 = "\\#b38752\\[3o Lugar]",
  place = "\\#e7a1ff\\[%do Lugar]", -- thankfully we don't go up to 21

  -- command descriptions (only host or mod will see these, so it's not as critical)
  start_desc = "[CONTINUE|MAIN|ALT|RESET] - Starts the game; add \"continue\" to not warp to start; add \"alt\" for alt save file (buggy); add \"main\" for main save file; add \"reset\" to reset file (buggy)",
  add_desc = "[INT] - Adds the specified amount of runners at random",
  random_desc = "[INT] - Picks the specified amount of runners at random",
  lives_desc = "[INT] - Sets the amount of lives Runners have, from 0 to 99 (note: 0 lives is still 1 life)",
  time_desc = "[NUM] - Sets the maximum amount of time Runners have to wait to leave, in seconds",
  stars_desc = "[INT] - Sets the maximum amount of stars Runners must collect to leave, from 1 to 7 (only in star mode)",
  category_desc = "[INT] - Sets the amount of stars Runners must have to face Bowser. Set to -1 for any%.",
  flip_desc = "[NAME|ID] - Flips the team of the specified player, or your own if none entered",
  setlife_desc = "[NAME|ID|INT,INT] - Sets the specified lives for the specified runner, or yourself if not specified",
  leave_desc = "[NAME|ID] - Allows the specified player, or yourself if none entered, to leave the level if they are a runner",
  mode_desc = "[NORMAL|SWITCH|MINI] - Changes game mode; switch switches runners when one dies",
  starmode_desc = "[ON|OFF] - Toggles using stars collected instead of time",
  spectator_desc = "[ON|OFF] - Toggles Hunters' ability to spectate",
  pause_desc = "[NAME|ID|ALL] - Toggles pause status for specified players, self if not specified, or all",
  metal_desc = "[ON|OFF] - Toggles making hunters appear as if they have the metal cap; this does not make them invincible",
  hack_desc = "[STRING] - Sets current rom hack",
  weak_desc = "[ON|OFF] - Cuts invincibility frames in half for all players",
  auto_desc = "[ON|OFF|NUM] - Start games automatically; host only, MiniHunt only",
}

langdata["fr"] = -- By Skeltan
{
  -- fullname for auto select (make sure this matches in-game under Misc -> Languages)
  fullname = "French",

  -- global command info
  to_switch = "Faites \"/lang %s\" pour changer de langue",
  switched = "La langue a été changée en français!", -- Replace "English" with the name of this language
  rule_command = "Faites /rules pour faire apparaître ce message de nouveau",

  -- roles
  runner = "Coureur",
  runners = "Coureurs",
  short_runner = "Cours", -- unused
  hunters = "Chasseurs",
  hunter = "Chasseur",
  spectator = "Spectateur",
  player = "Joueur",

  -- rules
  --[[
    This is laid out as follows:
    {welcome}
    {runners}{shown_above|thats_you}{any_bowser|collect_bowser}
    {hunters}{thats_you}{all_runners|any_runners}
    {rule_lives_one|rule_lives}{time_needed|stars_needed}{become_hunter|become_runner}
    {infinite_lives}{spectate}
    {banned_glitchless|banned_general}{fun}

    I highly recommend testing this in-game
    Also:
    \\#ffffff\\ = white (default)
    \\#00ffff\\ = cyan (for Runner team name)
    \\#ff5c5c\\ = red (for Hunter team name and popups)
    \\#ffff5a\\ = yellow
    \\#5aff5a\\ = green
  ]]
  welcome = "Bienvenue dans \\#00ffff\\Mario\\#ff5c5c\\Hunt\\#ffffff\\! COMMENT JOUER:",
  welcome_mini = "Bienvenue dans \\#ffff5a\\Mini\\#ff5c5c\\Hunt\\#ffffff\\! COMMENT JOUER:",
  welcome_egg = "Bienvenue dans \\#5aff5a\\Luigi\\#ff5c5c\\Hunt\\#ffffff\\! COMMENT JOUER:",
  all_runners = "Éliminez tous les \\#00ffff\\Coureurs\\#ffffff\\.",
  any_runners = "Éliminez n'importe quel \\#00ffff\\Coureur\\#ffffff\\.",
  shown_above = "(montré çi-dessus)",
  any_bowser = "Battez Bowser par tous les moyens nécessaires.",
  collect_bowser = "Collectez %d étoile(s) et battez Bowser.",
  mini_collect = "Be the first to collect the star.", -- not translated yet
  collect_only = "Collectez %d étoile(s).",
  thats_you = "(c'est vous!)",
  banned_glitchless = "INTERDICTION DE: Faire des Alliances, faire des BLJs, passer à travers les murs, freiner l'avancée du jeu, camper.",
  banned_general = "INTERDICTION DE: Faire des Alliances, freiner l'avancée du jeu, camper.",
  time_needed = "%d:%02d pour sortir de n'importe quel niveau; collectez des étoiles pour réduire le compte à rebours",
  stars_needed = "%d étoile(s) pour sortir de n'importe quel niveau",
  become_hunter = "devenez \\#ff5c5c\\Chasseurs\\#ffffff\\ une fois vaincu",
  become_runner = "defeat a \\#00ffff\\Runner\\#ffffff\\ to become one", -- this was changed
  infinite_lives = "Vies Illimités",
  spectate = "faites \"/spectate\" pour devenir spectateur",
  mini_goal = "\\#ffff5a\\Whoever collects the most stars in %d:%02d wins!\\#ffffff\\", -- not translated yet
  fun = "Amusez-vous bien!",

  -- serveral untranslated things here
  -- hud, extra desc, and results text (%s is a placeholder for names, and %d is a placeholder for a number)
  win = "%s\\#ffffff\\ ont gagné!", -- team name is placed here
  can_leave = "\\#5aff5a\\Peut sortir du niveau",
  cant_leave = "\\#ff5c5c\\Peut ne sortir du niveau", -- is this correct?
  time_left = "Peut sortir dans \\#ffff5a\\%d:%02d",
  stars_left = "\\#ffff5a\\%d étoile(s)\\#ffffff\\ nécessaires pour sortir",
  in_castle = "Dans le château",
  until_hunters = "%d seconde(s) avant que les \\#ff5c5c\\Chasseurs\\#ffffff\\ commencent",
  until_runners = "%d seconde(s) avant que les \\#00ffff\\Coureurs\\#ffffff\\ commencent",
  lives_one = "1 vie",
  lives = "%d vies",
  stars_one = "1 étoile",
  stars = "%d étoiles",
  no_runners = "Pas de \\#00ffff\\Coureurs!",
  camp_timer = "Restez en mouvement! \\#ff5c5c\\(%d)",
  game_over = "The game is over!",
  winners = "Gagnants: ", -- is this correct?
  no_winners = "\\#ff5c5c\\Pas de gagnants!", -- is this correct?

  -- popups
  lost_life = "%s\\#ffa0a0\\ a perdu une vie!",
  lost_all = "%s\\#ffa0a0\\ a perdu toute ses vies!",
  now_runner = "%s\\#ffa0a0\\ est désormais un \\#00ffff\\Coureur\\#ffa0a0\\.",
  now_hunter = "%s\\#ffa0a0\\ est désormais un \\#ff5c5c\\Chasseur\\#ffa0a0\\.",
  got_star = "%s\\#ffa0a0\\ a obtenu une étoile!",
  got_key = "%s\\#ffa0a0\\ a obtenu une clé!",
  rejoin_start = "%s\\#ffa0a0\\ a 2 minutes pour se reconnecter.",
  rejoin_success = "%s\\#ffa0a0\\ est revenu à temps!",
  rejoin_fail = "%s\\#ffa0a0\\ did not reconnect in time.", -- changed recently
  using_ee = "Ceci utilise le mode extrême uniquement.",
  not_using_ee = "Ceci utilise le mode standard uniquement.",
  killed = "%s\\#ffa0a0\\ a tué %s!",
  sidelined = "%s\\#ffa0a0\\ a vaincu %s!",
  paused = "Vous avez été mis en pause.",
  unpaused = "Vous n'êtes plus en pause.",
  kill_combo_2 = "%s\\#ffa0a0\\ a tué \\#ffff5a\\deux\\#ffa0a0\\ personnes à la suite!",
  kill_combo_3 = "%s\\#ffa0a0\\ a tué \\#ffff5a\\trois\\#ffa0a0\\ personnes à la suite!",
  kill_combo_4 = "%s\\#ffa0a0\\ a tué \\#ffff5a\\quatre\\#ffa0a0\\ personnes à la suite!",
  kill_combo_5 = "%s\\#ffa0a0\\ a tué \\#ffff5a\\cinq\\#ffa0a0\\ personnes à la suite!",
  kill_combo_large = "\\#ffa0a0\\Wow! %s\\#ffa0a0\\ a tué \\#ffff5a\\%d\\#ffa0a0\\ personnes à la suite!",
  set_hack = "Hack set to %s",
  incompatible_hack = "WARNING: Hack does not have compatibility!",
  vanilla = "Using vanilla game",
  omm_detected = "OMM Rebirth detected!",

  -- command feedback
  not_mod = "You don't have the AUTHORITY to run this command, you fool!",
  no_such_player = "Ce joueur n'existe pas",
  bad_id = "ID de joueur invalide!",

  -- more command feedback (only host or mod will see these, so it's not as critical)
  bad_param = "Invalid parameters!",
  bad_command = "Invalid command!",
  error_no_runners = "Can't start game with 0 runners!",
  set_team = "%s's team has been set to '%s'", -- First %s is player name, second is team name (now unused)
  not_started = "Game hasn't been started yet",
  set_lives_one = "%s now has 1 life",
  set_lives = "%s now has %d lives",
  not_runner = "%s isn't a Runner",
  may_leave = "%s may leave",
  must_have_one = "Must have at least 1 hunter",
  added = "Added runners: ", -- list comes afterward
  runners_are = "Runners are: ",
  set_lives_total = "Runner lives set to %d",
  wrong_mode = "Not available in this mode",
  need_time_feedback = "Runners can leave in %d second(s) now",
  game_time = "Game now lasts %d second(s)",
  need_stars_feedback = "Runners need %d star(s) now",
  new_category = "This is now a %d star run",
  new_category_any = "This is now an any% run",
  mode_normal = "In Normal mode",
  mode_switch = "In Switch mode",
  mode_mini = "In MiniHunt mode",
  using_stars = "Using stars collected",
  using_timer = "Using timer",
  can_spectate = "Hunters can now spectate",
  no_spectate = "Hunters can no longer spectate",
  all_paused = "All players paused",
  all_unpaused = "All players unpaused",
  player_paused = "%s has been paused",
  player_unpaused = "%s has been unpaused",
  now_metal = "All hunters are metal",
  not_metal = "All hunters are not metal",
  now_weak = "All players have half invincibility frames",
  not_weak = "All players have normal invincibility frames",
  auto_on = "Games will start automatically",
  auto_off = "Games will not start automatically",

  -- team chat
  tc_on = "Le tchat d'équipe est \\#5cff5c\\ACTIVÉ!",
  tc_off = "Le tchat d'équipe est \\#ff5c5c\\DÉSACTIVÉ!",
  to_team = "\\#8a8a8a\\Pour ton équipe: ",
  from_team = "\\#8a8a8a\\ (équipe): ",

  -- hard mode
  hard_notice = "Psst, try typing /hard...",
  hard_on = "\\#ff5c5c\\Hard Mode\\#ffffff\\ is \\#5cff5c\\ON!",
  hard_off = "\\#ff5c5c\\Hard Mode\\#ffffff\\ is \\#ff5c5c\\OFF!",
  hard_info = "Interested in \\#ff5c5c\\Hard Mode\\#ffffff\\?"..
  "\n- Half health"..
  "\n- No water heal"..
  "\n- \\#ff5c5c\\One life"..
  "\n\\#ffffff\\Type /hard ON if you're up for the challenge.",

  -- spectator
  hunters_only = "Seuls les chasseurs peuvent être spectateurs!",
  spectate_disabled = "Le mode spectateur est désactivé!",
  timer_going = "Vous ne pouvez pas être spectateur durant le compte à rebours!", -- now unused
  spectate_self = "Vous ne pouvez être votre propre spectateur!",
  spectator_controls = "Contrôles:"..
  "\nDPAD-UP: Désactiver le HUD"..
  "\nDPAD-DOWN: Alterner Caméra Libre/Suivre Joueur"..
  "\nDPAD-LEFT / DPAD-RIGHT: Changer de joueur"..
  "\nJOYSTICK: Se déplacer"..
  "\nA: Aller vers le haut"..
  "\nZ: Aller vers le bas"..
  "\nFaites \"/spectate OFF\" pour annuler",
  spectate_off = "Vous n'êtes plus en mode spectateur.",
  empty = "Vide (%d )",
  free_camera = "CAMÉRA LIBRE",

  -- stats
  disp_wins_one = "%s\\#ffffff\\ a gagné 1 fois en tant que \\#00ffff\\Coureur\\#ffffff\\!",
  disp_wins = "%s\\#ffffff\\ a gagné %d fois en tant que \\#00ffff\\Coureur\\#ffffff\\!",
  disp_kills_one = "%s\\#ffffff\\ a tué 1 joueur!", -- unused
  disp_kills = "%s\\#ffffff\\ a tué %d joueurs!",
  disp_wins_hard_one = "%s\\#ffffff\\ a gagné 1 fois en tant que \\#ffff5c\\Coureur\\#ffffff\\ [in \\#ff5c5c\\Hard Mode\\#ffffff\\]!", -- not translated fully
  disp_wins_hard = "%s\\#ffffff\\ a gagné %d fois en tant que \\#ffff5c\\Coureur\\#ffffff\\ [in \\#ff5c5c\\Hard Mode\\#ffffff\\]!", -- not translated fully
  -- for stats table
  stat_wins = "Victoires",
  stat_kills = "Kills",
  stat_combo = "Record de Kills",
  stat_wins_hard = "Victoires (Hard Mode)", -- not translated fully
  stat_mini_stars = "Maximum Stars in one game of MiniHunt",

  -- placements
  place_1 = "\\#e3bc2d\\[1ère Place]",
  place_2 = "\\#c5d8de\\[2e Place]",
  place_3 = "\\#b38752\\[3e Place]",
  place = "\\#e7a1ff\\[%de Place]", -- thankfully we don't go up to 21

  -- command descriptions (only host or mod will see these, so it's not as critical)
  start_desc = "[CONTINUE|MAIN|ALT|RESET] - Starts the game; add \"continue\" to not warp to start; add \"alt\" for alt save file (buggy); add \"main\" for main save file; add \"reset\" to reset file (buggy)",
  add_desc = "[INT] - Adds the specified amount of runners at random",
  random_desc = "[INT] - Picks the specified amount of runners at random",
  lives_desc = "[INT] - Sets the amount of lives Runners have, from 0 to 99 (note: 0 lives is still 1 life)",
  time_desc = "[NUM] - Sets the amount of time Runners have to wait to leave, in seconds",
  stars_desc = "[INT] - Sets the amount of stars Runners must collect to leave, from 1 to 7 (only in star mode)",
  category_desc = "[INT] - Sets the amount of stars Runners must have to face Bowser. Set to -1 for any%.",
  flip_desc = "[NAME|ID] - Flips the team of the specified player, or your own if none entered",
  setlife_desc = "[NAME|ID|INT,INT] - Sets the specified lives for the specified runner, or yourself if not specified",
  leave_desc = "[NAME|ID] - Allows the specified player, or yourself if none entered, to leave the level if they are a runner",
  mode_desc = "[NORMAL|SWITCH|MINI] - Changes game mode; switch switches runners when one dies",
  starmode_desc = "[ON|OFF] - Toggles using stars collected instead of time",
  spectator_desc = "[ON|OFF] - Toggles Hunters' ability to spectate",
  pause_desc = "[NAME|ID|ALL] - Toggles pause status for specified players, self if not specified, or all",
  metal_desc = "[ON|OFF] - Toggles making hunters appear as if they have the metal cap; this does not make them invincible",
  hack_desc = "[STRING] - Sets current rom hack",
  weak_desc = "[ON|OFF] - Cuts invincibility frames in half for all players",
  auto_desc = "[ON|OFF|NUM] - Start games automatically; host only, MiniHunt only",
}

-- language data ends here

-- this generates a list of available languages for the command description
lang = "en"
local lang_table = {}
for lang,data in pairs(langdata) do
  table.insert(lang_table,string.upper(lang))
end
table.sort(lang_table)
lang_list = "["
for i,name in ipairs(lang_table) do
  lang_list = lang_list .. name .. "|"
end
lang_list = lang_list:sub(1,-2) .. "]"

-- this allows players to switch languages
function lang_command(msg)
  if langdata[string.lower(msg)] ~= nil then
    lang = string.lower(msg)
    djui_chat_message_create(trans("switched"))
    show_rules()
    return true
  end
  return false
end
hook_chat_command("lang", lang_list .. " - Switch language", lang_command)

-- this handles auto select
for langname,data in pairs(langdata) do
  if data.fullname == smlua_text_utils_get_language() then
    lang = langname
    break
  end
end

-- debug command
function lang_test(msg)
  local args = {}
  local lastspace = 0
  while lastspace ~= nil do
    lastspace = msg:find(" ")
    if lastspace ~= nil then
      local arg = msg:sub(1,lastspace-1)
      table.insert(args, arg)
      msg = msg:sub(lastspace+1)
    else
      local arg = msg
      table.insert(args, arg)
    end
  end
  if args[1] == "all" then
    local allLang = {}
    for lang,data in pairs(langdata) do
      if (args[2] == nil or lang == args[2]) and lang ~= "en" then
        table.insert(allLang, lang)
      end
    end
    print("Missing translation:")
    for id,phrase in pairs(langdata["en"]) do
      local translated_en = trans(id,nil,1,"en")
      for i,lang in ipairs(allLang) do
        local translated = trans(id,nil,10,lang)

        local noline = ""
        if langdata[lang][id] == nil then noline = " (no line)" end

        if translated == translated_en then
          djui_chat_message_create(id.." lacks translation for "..langdata[lang].fullname.."!"..noline)
          print(id,langdata[lang].fullname,noline)
        end
      end
    end
    return true
  end
  local id = args[1]
  local extra1 = args[2]
  local extra2 = args[3]
  local lang = args[4]
  local translated = trans(id, extra1, extra2)
  if args[5] ~= "plural" then
    djui_chat_message_create(trans(id, extra1, extra2, lang))
  else
    djui_chat_message_create(trans_plural(id, extra1, extra2, lang))
  end

  return true
end
