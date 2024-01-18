# COMMANDS:
These likely won't be necessary, since the menu exists now. However, I have kept them here for completeness.

Important commands are in bold. All commands except /mh (no arguments) are moderator, host, or MarioHunt developer only. If you are still confused, read the wiki [here](wiki/home.md)

**/mh**: Displays command list. Add a number to go to a certain page. Do /mh [COMMAND] to run the specified command. Do /mh [COMMAND] [PARAMETER] to add parameters. If nothing is entered, the menu will be opened.

**/mh help** [NUM|COMMAND]: Browse available commands. Enter a page number, or a specific command to get information about that command.

**/mh start** [CONTINUE|MAIN|ALT|RESET] - Starts the game. Must have at least 1 runner. Add "continue" to skip timer sequence, add "main" to use main save file, add "alt" to use alt save file, and add "reset" to reset the alt save file.

**/mh add [INT|AUTO]** - Adds the specified amount of runners at random. Must have at least 1 hunter remaining after selection.

**/mh random [INT|AUTO]** - Sets the specified amount of runners total at random. Must have at least 1 hunter remaining after selection.

/mh lives [INT] - Sets amount of lives runners have. Remember that 0 is a life, so /mh runnerlives 1 gives Runners 2 deaths until they lose.

/mh time [NUM] - Sets time runners need to stay in a course in seconds. Note that time is also cut based on existing stars in the level (1:30 for each star)

/mh stars [NUM] - For Star Mode, sets amount of stars runners need to get to leave a course.

/mh category [INT] - Sets number of stars runners need to collect total. Changing this opens doors, disables infinite stairs, etc. To set this to any%, enter "any" or -1.

**/mh flip [NAME|ID]** - Switches team of specified player (or yourself if not specified).

/mh setlife [NAME|ID|INT,INT] - Sets the specified lives for the specified runner (or yourself if not specified).

/mh leave [NAME|ID] - Lets the specified player leave the course (or yourself if not specified).

**/mh mode [NORMAL|SWAP|MINI]** - Change game mode. In Runner Swap mode, when a runner is defeated, a random hunter becomes a runner. MiniHunt is a new gamemode described [here](wiki/mini.md).

/mh starmode [ON|OFF] - Toggles using stars to leave a stage as opposed to the timer, like in the old days of MarioHunt.

/mh spectator [ON|OFF] - Toggles hunters' ability to use spectator.

/mh pause [NAME|ID|ALL] - Freezes or unfreezes the specified player, or all players by default.

/mh metal [ON|OFF] - Toggles making hunters appear as if they have the metal cap; this does not make them invincible

/mh hack [STRING] - Sets the rom hack; Supported hacks are "vanilla", "star-road", "sm74", "sapphire", "Ztar Attack 2", "coop-mods-green-stars", "custom" (for hacks that use the MarioHunt API), and "default" (all other rom hacks), case sensitive. This should work automatically, but this should be used in otherwise.

/mh weak [ON|OFF] - Toggles cutting players' invulnerability frames in half

/mh auto [ON|OFF|NUM] - Start games automatically; MiniHunt only, host only. Add a number to choose the amount of runners; picks based on lobby size otherwise

/mh forcespectate [NAME|ID|ALL] - Force the following players to spectate; does not affect Runners. Similar format to /mh pause

/mh default - Resets to default settings.

/mh desync - If players report having Runners with negative lives, being unable to attack Runners, or are in the wrong level in MiniHunt, try running this command.

/mh out - If the doors disappear in a level (like the castle), run this command while in that level to warp everyone out.

/mh blacklist [ADD|REMOVE|LIST|RESET|SAVE|RESET,COURSE,ACT] - Manage the blacklist for MiniHunt. For example, do /mh blacklist add bob 2 to blacklist Footrace With Koopa The Quick.

/mh stalking [ON|OFF] - Enables the /stalk command. OFF by default. Enabling this will also automatically run /stalk for new players.

/mh stop - Stops the game.

/mh mute/unmute [NAME|ID] - Mutes/unmutes a player, respectively. This prevents them from chatting.
<br/>
<br/>
<br/>
In addition, the following commands are available for all players, unless specified:

/mh - Opens the menu. This is the only aspect of this command available for non-moderators.

/tc [MSG|ON|OFF] - Send message to team only. ON enables this without having to type /tc every time.

/lang [EN|ES|DE|PT-BR|FR] - Switches language. Some languages may have incomplete translations due to development complications.

/spectate [NAME|ID|OFF] - Hunters only. Spectate the specified player, or unspectate. Use /spectate runner to automatically focus on Runners.

/stats - Displays a table of stats for all players. Navigate with the Joystick or DPad and A. Press START or B to close.

/skip - Vote to skip a star in MiniHunt. Half the lobby must agree.

/timer [ON|OFF] - Show/hide the speedrun timer in Normal or Swap mode.

/stalk [NAME|ID|OFF] - Warp to the same area as the specified Runner, or the first Runner if not specified. There is a 5 second frozen timer upon use. Not usable unless "stalking" is turned on.
For all Bowser arenas, the player will be warped to the start of the respective Bowser level. For the town in Wet-Dry World, some areas of the slide in Tall, Tall Mountain, the Eyerok fight in Shifting Sand Land, and the sub area of Dire Dire Docks, the player will be warped to the start of the level.

/target [NAME|ID] - "Targets" a Runner, which displays their location at all times, changes the appearance of their radar, and sets them as the default target of /stalk and /spectate. Only Hunters can use this.