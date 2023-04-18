A gamemode based off of Blue Beyond's concept. Hunters stop Runners from clearing the game!


Main Programming by EmilyEmmi, and TroopaParaKoopa

Automatic Doors and Disable Star Spawn Cutscenes by Blocky, and Sunk

Spectator mod by Sprinter05


Spanish Translation made with help from TroopaParaKoopa (I've gotten mixed feedback on the quality, so please report any inaccuracies)

German Translation made with help from N64 Mario


HOW TO USE:
Install like a regular mod. The main rules of the game will appear first. To change rules, start the game, and select players, the following commands are available:

Important commands are denoted by "***"

*** /mh: Displays command list. Do /mh [COMMAND] to run the specified command. Do /mh [COMMAND] [PARAMETER] to add parameters. Host/moderator/developer (me) only

*** /mh start [CONTINUE|MAIN|ALT] - Starts the game. Must have at least 1 runner. Add "continue" to skip timer sequence, add "main" to use main save file, and add "alt" to use alt save file.

*** /mh addrunner [INT] - Adds the specified amount of runners at random. Must have at least 1 hunter remaining after selection.

*** /mh randomize [INT] - Sets the specified amount of runners total at random. Must have at least 1 hunter remaining after selection.

/mh runnerlives [INT] - Sets amount of lives runners have. Remember that 0 is a life, so /mh runnerlives 1 gives Runners 2 deaths until they lose.

/mh timeneeded [NUM] - Sets time runners need to stay in a course in seconds. Note that time is also cut based on existing stars in the level (1:30 for each star)

/mh starrun [INT] - Sets number of stars runners need to collect total. Changing this opens doors, disables infinite stairs, etc.

*** /mh changeteam [NAME|ID] - Switches team of specified player (or yourself if not specified).

/mh addlife [NAME|ID] - Adds 1 life to the specified player (or yourself if not specified).

/mh allowleave [NAME|ID] - Lets the specified player leave the course (or yourself if not specified).

/mh runnerswitch [ON|OFF] - In this mode, when a runner is defeated, a random hunter becomes a runner.

/mh spectator [ON|OFF] - Toggles hunters' ability to use spectator

/mh pause [NAME|ID|ALL] - Freezes or unfreezes the specified player, yourself if not specified, or all players if specified.


In addition, the following commands are available:

/tc [MSG|ON|OFF] - Send message to team only. ON enables this without having to type /tc every time.

/lang [EN|ES|DE] - Switches language. Some command feedback and descriptions are not translated.

/spectate [NAME|ID|OFF] - Hunters only. Spectate the specified player, or unspectate.

Have fun, and please report any bugs.
