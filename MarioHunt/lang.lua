--[[
Hello! For those who are looking to translate, please scroll down.
Also, be sure to read the comments.
]]

-- this is the translate command, it supports up to two blanks
function trans(id,format,format2_)
  local format2 = format2_ or 10
  if id == nil then return "INVALID" end
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

  -- roles
  runner = "Runner",
  runners = "Runners",
  short_runner = "Run", -- unused
  hunters = "Hunters",
  hunter = "Hunter",
  spectator = "Spectator",

  -- rules
  --[[
    This is laid out as follows:
    {welcome}
    {runners}{shown_above|thats_you}{any_bowser|collect_bowser}
    {hunters}{thats_you}{all_runners|any_runners}
    {single_life|multi_life}{time_needed|stars_needed}{become_hunter|switch_runner}
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
  welcome = "Welcome to \\#ffff5a\\Mariohunt\\#ffffff\\! HOW TO PLAY:",
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
  stars_needed = "%d star(s) to leave any main stage;\n",
  become_hunter = "Become \\#ff5c5c\\Hunters\\#ffffff\\ when defeated.",
  switch_runner = "A random \\#ff5c5c\\Hunter\\#ffffff\\ becomes a \\#00ffff\\Runner\\#ffffff\\ when one is defeated.",
  infinite_lives = "\\#ff5c5c\\Hunters\\#ffffff\\: Infinite lives",
  spectate = "; type \"/spectate\" to spectate",
  fun = " Have fun!",

  -- hud text (%s is a placeholder for names, and %d is a placeholder for a number)
  win = "%s\\#ffffff\\ win!", -- team name is placed here
  can_leave = "\\#5aff5a\\Can leave course",
  time_left = "Can leave in \\#ffff5a\\%d:%02d",
  stars_left = "Need \\#ffff5a\\%d star(s)\\#ffffff\\ to leave",
  in_castle = "In castle",
  until_hunters = "%d second(s) until \\#ff5c5c\\Hunters\\#ffffff\\ begin",
  until_runners = "%d second(s) until \\#00ffff\\Runners\\#ffffff\\ begin",
  show_lives_one = "1 life",
  show_lives = "%d lives",
  no_runners = "No \\#00ffff\\Runners!",
  camp_timer = "Keep moving! \\#ff5c5c\\(%d)",

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
  paused = "You have been paused.",
  unpaused = "You are no longer paused.",
  kill_combo_2 = "%s\\#ffa0a0\\ got a \\#ffff5a\\double\\#ffa0a0\\ kill!",
  kill_combo_3 = "%s\\#ffa0a0\\ got a \\#ffff5a\\triple\\#ffa0a0\\ kill!",
  kill_combo_4 = "%s\\#ffa0a0\\ got a \\#ffff5a\\quadruple\\#ffa0a0\\ kill!",
  kill_combo_5 = "%s\\#ffa0a0\\ got a \\#ffff5a\\quintuple\\#ffa0a0\\ kill!",
  kill_combo_large = "\\#ffa0a0\\Wow! %s\\#ffa0a0\\ got \\#ffff5a\\%d\\#ffa0a0\\ kills in a row!",

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
  empty = "EMPTY (%d )",
  free_camera = "FREE CAMERA",

  -- stats
  disp_wins_one = "%s\\#ffffff\\ has won 1 time as \\#00ffff\\Runner\\#ffffff\\!",
  disp_wins = "%s\\#ffffff\\ has won %d times as \\#00ffff\\Runner\\#ffffff\\!",
  disp_kills_one = "%s\\#ffffff\\ has killed 1 player!", -- unused
  disp_kills = "%s\\#ffffff\\ has killed %d players!",
  -- for stats table
  stat_wins = "Wins:",
  stat_kills = "Kills:",
  stat_combo = "Max Kill Streak:",
}

langdata["es"] = -- made with wordreference and help from TroopaParaKoopa
{
  -- fullname for auto select
  fullname = "Spanish",

  -- global command info
  to_switch = "Escriba \"/lang %s\" cambiar idiomas",
  switched = "Cambiaste a español!",
  rule_command = "Escriba /rules mostrar este mensaje otra vez",

  -- roles
  runner = "Corredor",
  runners = "Corredores",
  short_runner = "Corre",
  hunter = "Cazador",
  hunters = "Cazadores",
  spectator = "Espectador",

  -- rules (%d:%02d is time in minutes:seconds format)
  welcome = "¡Bienvenido a \\#ffff5a\\Mariohunt\\#ffffff\\! COMO JUGAR:",
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
  stars_needed = "%d estrella(s) partir cualquier nivel principal;\n",
  become_hunter = "Haceos \\#ff5c5c\\Cazadores\\#ffffff\\ cuando venció.",
  switch_runner = "Un \\#ff5c5c\\Cazador\\#ffffff\\ aleatorio hace un \\#00ffff\\Corredor\\#ffffff\\ cuando uno es venció.",
  infinite_lives = "\\#ff5c5c\\Cazadores\\#ffffff\\: Vidas infinitas",
  spectate = "; escrita \"/spectate\" observar",
  fun = " ¡Disfruta!",

  -- hud text
  win = "¡%s\\#ffffff\\ ganan!",
  can_leave = "\\#5aff5a\\Puede partes nivel",
  time_left = "Puede partes en \\#ffff5a\\%d:%02d",
  stars_left = "Necesitas \\#ffff5a\\%d estrella(s)\\#ffffff\\ partir",
  in_castle = "En castillo",
  until_hunters = "%d segundo(s) hasta \\#ff5c5c\\Cazadores\\#ffffff\\ empiezan",
  until_runners = "%d segundo(s) hasta \\#00ffff\\Corredores\\#ffffff\\ empiezan",
  show_lives_one = "1 vida",
  show_lives = "%d vidas",
  no_runners = "¡No \\#00ffff\\Corredores!",
  camp_timer = "¡Vamos! \\#ff5c5c\\(%d)",

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
  paused = "Hayas interrumpiste.",
  unpaused = "No está interrumpido ahora.",
  kill_combo_2 = "¡%s\\#ffa0a0\\ sacó una \\#ffff5a\\doble\\#ffa0a0\\ muerte!",
  kill_combo_3 = "¡%s\\#ffa0a0\\ sacó una \\#ffff5a\\triple\\#ffa0a0\\ muerte!",
  kill_combo_4 = "¡%s\\#ffa0a0\\ sacó una \\#ffff5a\\cuádrupla\\#ffa0a0\\ muerte!",
  kill_combo_5 = "¡%s\\#ffa0a0\\ sacó una \\#ffff5a\\quíntupla\\#ffa0a0\\ muerte!",
  kill_combo_large = "\\#ffa0a0\\¡Guau! ¡%s\\#ffa0a0\\ sacó \\#ffff5a\\%d\\#ffa0a0\\ muertes consecutivas!",

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
  empty = "VACÍO (%d )",
  free_camera = "CÁMARA LIBRE",

  -- stats
  disp_wins_one = "%s\\#ffffff\\ ganó 1 vez cuando era \\#00ffff\\Corredor\\#ffffff\\!",
  disp_wins = "%s\\#ffffff\\ ganó %d veces cuando era \\#00ffff\\Corredor\\#ffffff\\!",
  disp_kills_one = "%s\\#ffffff\\ mató 1 jugador!", -- unused
  disp_kills = "%s\\#ffffff\\ mató %d jugadores!",
  stat_wins = "Victoria:",
  stat_kills = "Muertes:",
  stat_combo = "Racha de Muertes Máxima:",
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

  -- rules
  welcome = "Wilkommen zu \\#ffff5a\\Mariohunt\\#ffffff\\! WIE MAN SPIELT:",
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
  stars_needed = "%d Stern(e) werden benötigt, um jeden Hauptkurs zu verlassen;\n",
  become_hunter = "Werde \\#ff5c5c\\Jäger\\#ffffff\\, wenn du besiegt wirst.",
  switch_runner = "Ein zufälliger \\#ff5c5c\\Jäger\\#ffffff\\ wird zum \\#00ffff\\Läufer\\#ffffff\\ wenn einer besiegt wird.",
  infinite_lives = "\\#ff5c5c\\Jäger\\#ffffff\\: Unendlich viele Leben",
  spectate = "; gebe \"/spectate\" ein, um zuzuschauen",
  fun = " Viel Spaß!",

  -- hud text
  win = "%s\\#ffffff\\ haben gewonnen!",
  can_leave = "\\#5aff5a\\Kurs kann verlassen werden",
  time_left = "Kannst in \\#ffff5a\\%d:%02d\\#ffffff\\ verlassen",
  stars_left = "Brauchst \\#ffff5a\\%d Stern(e)\\#ffffff\\ um zu verlassen",
  in_castle = "Im Schloss",
  until_hunters = "%d Sekunde(n) bis die \\#ff5c5c\\Jäger\\#ffffff\\ beginnen",
  until_runners = "%d Sekunde(n) bis die \\#00ffff\\Läufer\\#ffffff\\ beginnen",
  show_lives_one = "1 Leben",
  show_lives = "%d Leben",
  no_runners = "Keine \\#00ffff\\Läufer!",
  camp_timer = "Weiter bewegen! \\#ff5c5c\\(%d)",

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
  paused = "Du wurdest pausiert.",
  unpaused = "Du bist nicht mehr pausiert.",
  kill_combo_2 = "%s\\#ffa0a0\\ hat einen \\#ffff5a\\doppelten\\#ffa0a0\\ Kill!",
  kill_combo_3 = "%s\\#ffa0a0\\ hat einen \\#ffff5a\\dreifachen\\#ffa0a0\\ Kill!",
  kill_combo_4 = "%s\\#ffa0a0\\ hat einen \\#ffff5a\\vierfachen\\#ffa0a0\\ Kill!",
  kill_combo_5 = "%s\\#ffa0a0\\ hat einen \\#ffff5a\\fünffachen\\#ffa0a0\\ Kill!",
  kill_combo_large = "\\#ffa0a0\\Wow! %s\\#ffa0a0\\ hat \\#ffff5a\\%d\\#ffa0a0\\ Kills in Folge!",

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
  empty = "LEER (%d )",
  free_camera = "FREIE KAMERA",

  -- stats
  disp_wins_one = "%s\\#ffffff\\ hat 1 mal als Läufer gewonnen!",
  disp_wins = "%s\\#ffffff\\ hat %d mal als Läufer gewonnen!", -- may not be correct
  disp_kills_one = "%s\\#ffffff\\ hat einen Spieler getötet!", -- unused
  disp_kills = "%s\\#ffffff\\ hat %d Spieler getötet!",
  stat_wins = "Gewinnt:",
  stat_kills = "Kills:",
  stat_combo = "Max Kill Streak:",
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

  -- rules
  --[[
    This is laid out as follows:
    {welcome}
    {runners}{shown_above|thats_you}{any_bowser|collect_bowser}
    {hunters}{thats_you}{all_runners|any_runners}
    {single_life|multi_life}{time_needed|stars_needed}{become_hunter|switch_runner}
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
  welcome = "Bem vindo à \\#ffff5a\\Caça-Mario\\#ffffff\\! INSTRUÇÕES:",
  all_runners = ": Derrote todos os \\#00ffff\\Corredores\\#ffffff\\.",
  any_runners = ": Derrote quaisquer \\#00ffff\\Corredores\\#ffffff\\.",
  shown_above = " (demonstrado acima)",
  any_bowser = ": Derrote Bowser de qualquer maneira.",
  collect_bowser = ": Colete %d estrela(s) e derrote Bowser.",
  thats_you = " (este é você!)",
  banned_glitchless = "NÃO DEVE: Ajudar a equipe oposta, BLJs, cruzar paredes com glitches, enrolar, guardar caixão.",
  banned_general = "NÃO DEVE: Ajudar a equipe oposta, enrolar, guardar caixão.",
  single_life = "\n\\#00ffff\\Corredores\\#ffffff\\: 1 vida; ",
  multi_life = "\n\\#00ffff\\Corredores\\#ffffff\\: %d vidas; ",
  time_needed = "%d:%02d para sair de qualquer fase; coletar estrelas para diminuir o cronômetro; ",
  stars_needed = "%d estrela(s) para sair de qualquer fase;\n",
  become_hunter = "Você virará um dos \\#ff5c5c\\Caçadores\\#ffffff\\ quando derrotado.",
  switch_runner = "Um \\#ff5c5c\\Caçador\\#ffffff\\ aleatório vira \\#00ffff\\Corredor\\#ffffff\\ quando algum outro caçador e derrotado.",
  infinite_lives = "\\#ff5c5c\\Caçadores\\#ffffff\\: Vidas infinitas",
  spectate = "; use o comando \"/spectate\" para observar a partida.",
  fun = " Se divirta!",

  -- hud text (%s is a placeholder for names, and %d is a placeholder for a number)
  win = "%s\\#ffffff\\ Ganham!", -- team name is placed here
  can_leave = "\\#5aff5a\\Pode sair do nível.",
  time_left = "Poderá sair em \\#ffff5a\\%d:%02d",
  stars_left = "Precisam-se de \\#ffff5a\\%d estrela(s)\\#ffffff\\ para sair.",
  in_castle = "Dentro do Castelo",
  until_hunters = "%d segundo(s) até que os \\#ff5c5c\\Caçadores\\#ffffff\\ comecem.",
  until_runners = "%d segundo(s) até que os \\#00ffff\\Corredores\\#ffffff\\ comecem.",
  show_lives_one = "1 vida",
  show_lives = "%d vidas",
  no_runners = "Não há\\#00ffff\\Corredores!",
  camp_timer = "Continue se mexendo! \\#ff5c5c\\(%d)",

  -- popups
  lost_life = "%s\\#ffa0a0\\ perdeu uma vida!",
  lost_all = "%s\\#ffa0a0\\ perdeu todas as suas vidas!",
  now_runner = "%s\\#ffa0a0\\ agora é um \\#00ffff\\Corredor\\#ffa0a0\\.",
  got_star = "%s\\#ffa0a0\\ conseguiu uma estrela!",
  got_key = "%s\\#ffa0a0\\ pegou uma das chaves!",
  rejoin_start = "%s\\#ffa0a0\\ tem dois minutos para entrar novamente na partida.",
  rejoin_success = "%s\\#ffa0a0\\ entrou à tempo!",
  rejoin_fail = "%s\\#ffa0a0\\ não é mais um \\#00ffff\\Corredor\\#ffa0a0\\.",
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

  -- command feedback
  no_such_player = "Esse jogador não existe.",
  bad_id = "ID de jogador inválido!",

  -- team chat
  tc_on = "Chat de time está \\#5cff5c\\LIGADO!",
  tc_off = "Chat de time está \\#ff5c5c\\DESLIGADO!",
  to_team = "\\#8a8a8a\\Para time: ",
  from_team = "\\#8a8a8a\\ (time): ",

  -- spectator
  hunters_only = "Apenas os caçadores podem observar a partida!",
  spectate_disabled = "Modo de observação desligado!",
  timer_going = "Você não pode observar durante o temporizador!",
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
  -- for stats table
  stat_wins = "Vitórias:",
  stat_kills = "Já Matou:",
  stat_combo = "Combo Máx. de Assassinatos:",
}

-- language data ends here

-- this generates a list of available languages for the command description
lang = "en"
lang_list = "["
for lang,data in pairs(langdata) do
  lang_list = lang_list .. string.upper(lang) .. "|"
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
