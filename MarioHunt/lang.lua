lang = "en"

function trans(id,format,format2_)
  local format2 = format2_ or 10
  if langdata == nil then return id end

  if langdata[lang] == nil then
    lang = "en"
  end

  local translation = langdata[lang][id] or langdata["en"][id] or id
  if format ~= nil then
    translation = string.format(translation,format,format2)
  end
  return translation
end

function lang_command(msg)
  if langdata[string.lower(msg)] ~= nil then
    lang = string.lower(msg)
    djui_chat_message_create(trans("switched"))
    show_rules()
    return true
  end
  return false
end
hook_chat_command("lang", "[EN|ES|DE] - Switch language", lang_command)

langdata = {}
langdata["en"] =
{
  -- fullname for auto select
  fullname = "English",

  -- global command info
  to_switch = "Type \"/lang [EN|ES|DE]\" to switch languages",
  switched = "Switched to English!",
  rule_command = "Type /rules to show this message again",

  -- roles
  runner = "Runner",
  runners = "Runners",
  short_runner = "Run",
  hunters = "Hunters",
  hunter = "Hunter",
  spectator = "Spectator",

  -- rules
  welcome = "Welcome to \\#ffff00\\Mariohunt\\#ffffff\\! HOW TO PLAY:",
  all_runners = ": Defeat all \\#00ffff\\Runners\\#ffffff\\.",
  any_runners = ": Defeat any \\#00ffff\\Runners\\#ffffff\\.",
  shown_above = " (shown above)",
  any_bowser = ": Defeat Bowser through any means necessary.",
  collect_bowser = ": Collect %d star(s) and defeat Bowser.",
  thats_you = " (that's you!)",
  banned_glitchless = "NO: Cross teaming, BLJs, wall clipping, stalling, camping.",
  banned_general = "NO: Cross teaming, stalling, camping.",
  single_life = "\n\\#00ffff\\Runners\\#ffffff\\: 1 life; ",
  multi_life = "\n\\#00ffff\\Runners\\#ffffff\\: %d lives; ",
  time_needed = "%d:%02d to leave any main stage; collect stars to decrease; ",
  become_hunter = "Become \\#ff5c5c\\Hunters\\#ffffff\\ when defeated.",
  switch_runner = "A random \\#ff5c5c\\Hunter\\#ffffff\\ becomes a \\#00ffff\\Runner\\#ffffff\\ when one is defeated.",
  infinite_lives = "\\#ff5c5c\\Hunters\\#ffffff\\: Infinite lives",
  spectate = "; type \"/spectate\" to spectate",
  fun = " Have fun!",

  -- hud text
  win = "%s win!",
  can_leave = "Can leave course",
  time_left = "Can leave in %d:%02d",
  in_castle = "In castle",
  until_hunters = "%s second(s) until Hunters begin",
  until_runners = "%s second(s) until Runners begin",
  show_lives_one = "1 life",
  show_lives = "%d lives",
  no_runners = "No Runners!",
  camp_timer = "Keep moving! (%d)",

  -- popups
  lost_life = "%s\\#ffa0a0\\ lost a life!",
  lost_all = "%s\\#ffa0a0\\ lost all of their lives!",
  now_runner = "%s\\#ffa0a0\\ is now a \\#00ffff\\Runner\\#ffa0a0\\.",
  got_star = "%s\\#ffa0a0\\ got a star!",
  got_key = "%s\\#ffa0a0\\ got a key!",
  rejoin_start = "%s\\#ffa0a0\\ has two minutes to rejoin.",
  rejoin_success = "%s\\#ffa0a0\\ rejoined in time!",
  rejoin_fail = "%s\\#ffa0a0\\ is no longer a \\#00ffff\\Runner\\#ffa0a0\\.",
  using_ee = "This is using Extreme Edition only.",
  not_using_ee = "This is using Standard Edition only.",
  killed = "%s\\#ffa0a0\\ killed %s!",
  sidelined = "%s\\#ffa0a0\\ finished off %s!",

  -- command feedback
  no_such_player = "No such player exists",
  bad_id = "Invalid player ID!",

  -- team chat
  tc_on = "Team chat is \\#5cff5c\\ON!",
  tc_off = "Team chat is \\#ff5c5c\\OFF!",
  to_team = "\\#8a8a8a\\To team: ",
  from_team = "\\#8a8a8a\\ (team): ",

  -- spectator
  hunters_only = "Only Hunters can spectate!",
  spectate_disabled = "Spectate is disabled!",
  timer_going = "Can't spectate during timer!",
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
  empty = "EMPTY (%s )",
  free_camera = "FREE CAMERA",
}

langdata["es"] = -- made with wordreference and help from TroopaParaKoopa
{
  -- fullname for auto select
  fullname = "Spanish",

  -- global command info
  to_switch = "Escriba \"/lang [EN|ES|DE]\" cambiar idiomas",
  switched = "Cambiaste a español!",
  rule_command = "Escriba /rules mostrar este mensaje otra vez",

  -- roles
  runner = "Corredor",
  runners = "Corredores",
  short_runner = "Corre",
  hunter = "Cazador",
  hunters = "Cazadores",
  spectator = "Espectador",

  -- rules
  welcome = "¡Bienvenido a \\#ffff00\\Mariohunt\\#ffffff\\! COMO JUGAR:",
  all_runners = ": Venced todo \\#00ffff\\Corredores\\#ffffff\\.",
  any_runners = ": Venced cualquier \\#00ffff\\Corredores\\#ffffff\\.",
  shown_above = " (mostrado de arriba)",
  any_bowser = ": Venced Bowser en cualquiera manera.",
  collect_bowser = ": Coleccionad %d estrella(s) y venced Bowser.",
  thats_you = " (¡ese es tú!)",
  banned_glitchless = "NO: Traicionar a tu equipo, BLJs, cortar de pared, postergado, acampado.",
  banned_general = "NO: Traicionar a tu equipo, postergado, acampado.",
  single_life = "\n\\#00ffff\\Corredores\\#ffffff\\: 1 vida; ",
  multi_life = "\n\\#00ffff\\Corredores\\#ffffff\\: %d vidas; ",
  time_needed = "%d:%02d partir cualquier nivel principal; Colecciona estrellas reducir; ",
  become_hunter = "Haceos \\#ff5c5c\\Cazadores\\#ffffff\\ cuando venció.",
  switch_runner = "Un \\#ff5c5c\\Cazador\\#ffffff\\ aleatorio hace un \\#00ffff\\Corredor\\#ffffff\\ cuando uno es venció.",
  infinite_lives = "\\#ff5c5c\\Cazadores\\#ffffff\\: Vidas infinitas",
  spectate = "; escrita \"/spectate\" observar",
  fun = " ¡Disfruta!",

  -- hud text
  win = "¡%s ganan!",
  can_leave = "Puede partes nivel",
  time_left = "Puede partes en %d:%02d",
  in_castle = "En castillo",
  until_hunters = "%s segundo(s) hasta Cazadores empiezan",
  until_runners = "%s segundo(s) hasta Corredores empiezan",
  show_lives_one = "1 vida",
  show_lives = "%d vidas",
  no_runners = "¡No Corredores!",
  camp_timer = "¡Vamos! (%d)",

  -- popups
  lost_life = "¡%s\\#ffa0a0\\ perdió una vida!",
  lost_all = "¡%s\\#ffa0a0\\ perdió todos sus vidas!",
  now_runner = "%s\\#ffa0a0\\ es ahora un \\#00ffff\\Corredor\\#ffa0a0\\.",
  got_star = "¡%s\\#ffa0a0\\ consiguió una estrella!",
  got_key = "¡%s\\#ffa0a0\\ consiguió una llave!",
  rejoin_start = "%s\\#ffa0a0\\ tiene dos minutos unir de nuevo.",
  rejoin_success = "¡%s\\#ffa0a0\\ se unió a tiempo!",
  rejoin_fail = "%s\\#ffa0a0\\ no es un \\#00ffff\\Corredor\\#ffa0a0\\ ahora.",
  using_ee = "\\#ffa0a0\\Este solo usa Edicion de Extrema.",
  not_using_ee = "\\#ffa0a0\\Este solo usa Edicion de Tradicional.",
  killed = "¡%s\\#ffa0a0\\ mató a %s!",
  sidelined = "¡%s\\#ffa0a0\\ terminó a %s!",

  -- command feedback
  no_such_player = "Jugador no existe",
  bad_id = "ID de jugador inválido!",

  -- team chat
  tc_on = "¡Charla de equipo es \\#5cff5c\\ENCENDIDO!",
  tc_off = "¡Charla de equipo es \\#ff5c5c\\APAGADO!",
  to_team = "\\#8a8a8a\\De equipo: ",
  from_team = "\\#8a8a8a\\ (equipo): ",

  -- spectator
  hunters_only = "¡Solo Cazadores puede observa!",
  spectate_disabled = "¡Espectador no es activado!",
  timer_going = "¡No observa durante temporizador!",
  spectate_self = "¡No observa te!",
  spectator_controls = "Controles:"..
  "\nDPAD-UP: Apaga hud"..
  "\nDPAD-DOWN: Cambia vista de camara libre/jugador"..
  "\nDPAD-LEFT / DPAD-RIGHT: Cambia jugador"..
  "\nJOYSTICK: Viaja"..
  "\nA: Viaja arriba"..
  "\nZ: Viaja abajo"..
  "\nEscrita \"/spectate OFF\" cancelar",
  spectate_off = "No observa ahora.",
  empty = "VACÍO (%s )",
  free_camera = "CÁMARA LIBRE",
}

langdata["de"] = -- by N64 Mario
{
  -- fullname for auto select
  fullname = "German",

  -- global command info
  to_switch = "Gebe \"/lang [EN|ES|DE] ein\", um die Sprache zu wechseln",
  switched = "Auf Deutsch umgestellt!",
  rule_command = "Gebe /rules ein, um diese Nachricht erneut anzuzeigen",

  -- roles
  runner = "Läufer",
  runners = "Läufer",
  short_runner = "Run",
  hunters = "Jäger",
  hunter = "Jäger",
  spectator = "Zuschauer",

  -- rules
  welcome = "Wilkommen zu \\#ffff00\\Mariohunt\\#ffffff\\! WIE MAN SPIELT:",
  all_runners = ": Besiege alle \\#00ffff\\Läufer\\#ffffff\\.",
  any_runners = ": Besiege alle \\#00ffff\\Läufer\\#ffffff\\.",
  shown_above = " (oben gezeigt)",
  any_bowser = ": Besiege Bowser, egal durch welcher Art und Weise.",
  collect_bowser = ": Sammle %d Stern(e) und besiege Bowser.",
  thats_you = " (das bist du!)",
  banned_glitchless = "NEIN: Cross-Teaming, BLJs, durch Wände clippen, hinhalten, camping.",
  banned_general = "NEIN: Cross-Teaming, stalling, camping.",
  single_life = "\n\\#00ffff\\Läufer\\#ffffff\\: 1 Leben; ",
  multi_life = "\n\\#00ffff\\Läufer\\#ffffff\\: %d Leben; ",
  time_needed = "%d:%02d um jeden Hauptkurs zu verlassen; Sammle Sterne zum Verringern; ",
  become_hunter = "Werde \\#ff5c5c\\Jäger\\#ffffff\\, wenn du besiegt wirst.",
  switch_runner = "Ein zufälliger \\#ff5c5c\\Jäger\\#ffffff\\ wird zum \\#00ffff\\Läufer\\#ffffff\\ wenn einer besiegt wird.",
  infinite_lives = "\\#ff5c5c\\Jäger\\#ffffff\\: Unendlich viele Leben",
  spectate = "; gebe \"/spectate\" ein, um zuzuschauen",
  fun = " Viel Spaß!",

  -- hud text
  win = "%s haben gewonnen!",
  can_leave = "Kurs kann verlassen werden",
  time_left = "Kannst in %d:%02d verlassen",
  in_castle = "Im Schloss",
  until_hunters = "%s Sekunde(n) bis die Jäger beginnen",
  until_runners = "%s Sekunde(n) bis die Läufer beginnen",
  show_lives_one = "1 Leben",
  show_lives = "%d Leben",
  no_runners = "Keine Läufer!",
  camp_timer = "Weiter bewegen! (%d)",

  -- popups
  lost_life = "%s\\#ffa0a0\\ hat einen Leben verloren!",
  lost_all = "%s\\#ffa0a0\\ hat ihr ganzes Leben verloren!",
  now_runner = "%s\\#ffa0a0\\ ist jetzt ein \\#00ffff\\Läufer\\#ffa0a0\\.",
  got_star = "%s\\#ffa0a0\\ hat einen Stern bekommen!",
  got_key = "%s\\#ffa0a0\\ hat einen Schlüssel bekommen!",
  rejoin_start = "%s\\#ffa0a0\\ hat zwei Minuten um erneut beizutreten.",
  rejoin_success = "%s\\#ffa0a0\\ ist das Spiel pünktlich erneut beigetreten!",
  rejoin_fail = "%s\\#ffa0a0\\ ist nicht mehr ein  \\#00ffff\\Läufer\\#ffa0a0\\.",
  using_ee = "Dies verwendet nur die Extreme Edition.",
  not_using_ee = "Dies verwendet nur die Standard Version.",
  killed = "%s\\#ffa0a0\\ hat %s getötet!",
  sidelined = "%s\\#ffa0a0\\ hat %s erledigt!",

  -- command feedback
  no_such_player = "Es gibt nicht so einen Spieler",
  bad_id = "Ungültige Spieler ID!",

  -- team chat
  tc_on = "Team chat ist \\#5cff5c\\AN!",
  tc_off = "Team chat ist \\#ff5c5c\\AUS!",
  to_team = "\\#8a8a8a\\zu Team: ",
  from_team = "\\#8a8a8a\\ (Team): ",

  -- spectator
  hunters_only = "Nur Jäger können zuschauen!",
  spectate_disabled = "Zuschauermodus ist deaktiviert!",
  timer_going = "Kann während des Timers nicht zuschauen!",
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
  empty = "LEER (%s )",
  free_camera = "FREIE KAMERA",
}

for langname,data in pairs(langdata) do
  if data.fullname == smlua_text_utils_get_language() then
    lang = langname
    break
  end
end
