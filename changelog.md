# Changelog
## v2.32 (minor fix)
### Fixes:
  - Disabled lobby music on MacOSX to prevent game crash (EmeraldLockdown)
  - Removed "WIP" from name
## v2.32
### Additions:
  - Added a new option: "Defeat Bowser". Toggle it off to end the match as soon as the needed Stars are collected. Not available in MiniHunt.
### Adjustments:
  - Custom HUD font now uses the default characters added to the hud font in version 36
  - Player names in the menu are now capped at 16 characters (not including colors) to prevent cutoff
  - Added message when using version lower than version 36
  - The category displayed "List Settings" now displays as "X Star" instead of just "X"
  - **API CHANGE:** *no_bowser* now sets the default option for the Defeat Bowser value.
  - /mh category now accepts "any"
### Fixes:
  - Fixed softlock relating to mod storage changes
  - Corrected "MH Contribut<u>e</u>r" to "MH Contribut<u>o</u>r"
  - Alt save and alt save reset now actually work!
    - Buggy tag has been removed
  - Fixed key popups appearing for keys that have already been obtained
  - For unsupported rom hacks, vanilla levels are no longer factored in the total auto-generated star count
## v2.31
### Fixes:
  - Fixed Extreme Edition getting swapped to when using Spectator Mode as host/mod
  - Fixed save file desyncs
    - Alt save has been flagged as "buggy" again
  - Updated German Translation (N64-Mario)
  - Fixed getting softlocked when dialog skips while paused
## v2.3
### Additions:
  - Added a new Lobby! It appears between rounds, and contains a new platforming challenge! Aim for a fast time!
  - Added roles for contributers and translators
  - Added Lead Dev role (me)
  - Support for multiple roles
  - Added Hide My Roles menu, to control what roles display in chat
  - Updated all translations
    - Updated Spanish Translation (KanHeaven)
    - Updated French Translation (Skeltan)
    - Updated Brazillian Portuguese translation (PietroM)
  - Added support for the following romhacks:
    - B3313 v0.7
    - Super Mario 64 Moonshine
  - **API CHANGE:** Added *levelNames*, which allows for custom level names for different areas
  - **API CHANGE:** Added *vagueName*, a property which displays courses and stars as "Course X" and "Star X"
  - **API CHANGE:** Added *parseStars*, which will automatically set up star information
  - **API CHANGE:** The new *star_data* has new features, such as setting up stars that allow the player to exit
    - See mhSetup.lua for more info
  - **API CHANGE:** Added badGuy for listing the villian of the hack (if it isn't Bowser)
  - Romhacks without built-in support will now have their star data read automatically
  - **API CHANGE:** mini_exclude can now control which area players start in MiniHunt
  - **API CHANGE:** Added modifyChatFunction, useful for mods like Swear Filter and Nicknames
  - The runner timer will now properly adjust based on how many stars may be obtained in an area
  - Some stars will now allow the player to leave immediately (such as Plunder In The Sunken Ship)
  - You can now press X in the player menu to flip their team (if you have mod powers)
  - You can now press X in the course blacklist menu to toggle an entire course
  - Added the ability to disable the HUD
  - Added the ability to disable Faster Actions
  - Added compatibility with Personal Star Counter (if the incompatibility tag for PSC is disabled)
  - Added mouse support for the menu! Just set one of your mouse click buttons to A and you should be good to go!
    - Some adjustments have been made to accomodate this
  - **MiniHunt may now be played in singleplayer**
  - The text "NEW RECORD!!!" will appear and a different sound effect will play when beating your Maximum Stars in one game of MiniHunt record
  - Scrolling in the menu will now speed up if the direction is held
  - Added four more game options:
    - **Nerf Vanish Cap: Players have to hold B to vanish, and it drains faster while doing so. ON by default.**
    - Friendly Fire: Allows players to attack their own teammates. It can also be set for Runners or Hunters individually. OFF by default in Standard Modes, RUNNERS by default in MiniHunt.
    - Runner PVP DMG Up: Runners will take more damage when attacked by players. 0 by default in Standard Modes, 2 by default in MiniHunt.
      - Select "OHKO" for *instant* kills
    - **Leader Death Timer**: MiniHunt exclusive; the player with the most stars gets the death timer from Extreme mode. ON by default.
  - Added "List Settings" to the main menu
  - Added support for Blocky's "121rst star" mod
  - Typing "desync" in the chat will automatically fix MiniHunt desyncs (runs /mh desync from the host's end)
    - Simularly, typing "stuck" in chat will try to fix softlocks
  - Added "Auto" option for both Randomize Runners and Add Runners, which adds an ideal amount of runners
    - Formula is floor((n+2) / 4), where n is the amount of non-spectators
  - Added sound effects to more popups, such as stars, keys, and players entering levels
    - Can be disabled in Settings
  - Added popup stating how many stars are in a level
  - Added popup when the amount of stars needed to complete a run are collected
  - Added popup when collecting the Grand Star
  - Wins in MiniHunt are now counted separately
    - All wins prior to this update now count as "MiniHunt/pre v2.3 wins"
  - Advice signs now appear with a red backdrop
  - Added 32 player support for the Stats and Players menus
  - Explosion sfx now plays when killed by another player
### Adjustments:
  - **Hunters no longer run faster**
  - **Bowser stages can no longer be left, even in Timer mode**
  - **When a Runner is defeated in Switch mode or MiniHunt, the new Runner is now chosen based on whoever is closest instead of being random**
    - If no other player is in the level, the Runner is selected at random.
    - Thanks to Vanilla for this suggestion!
  - Radars now shrink when near the player, like in Shine Thief
  - Increased grace period when entering a level
  - When joining a lobby, players are told how to open the menu instead of how to display the rules again
  - Swapped the location of Gamemode and Runner Lives in the menu
  - Menu description no longer displays command hints
  - False stars will no longer be tracked by the radar
  - Added more actions to Faster Actions, such as throwing objects or falling into snow or sand
  - Unlocking a key door and entering a door now occur instantly (Troopa)
  - Removed "enter course" actions (Troopa)
    - Can be disabled by disabling Faster Actions
  - Ledge grabs are no longer included in Faster Actions
  - The Death Timer in Extreme Mode no longer drains while talking with an npc or other idle actions
  - Changed the name of the [DEV] role to [MH Dev]
  - Non-mod players can no longer access their own player menu
  - Reimplemented the *HIDDEN FEATURE*, resulting in the following changes:
    - The *HIDDEN FEATURE* can no longer be grabbed with Cappy
    - The *HIDDEN FEATURE* now has a custom texture (N64 Mario)
    - The *HIDDEN FEATURE* now waits for the player's invulnerability timer instead of respawning
    - Instead of respawning at 10000+ units away, the *HIDDEN FEATURE* now gains the ability to go through walls at 5000+ units away
    - The *HIDDEN FEATURE* now travels at half speed if the player is swimming
    - The *HIDDEN FEATURE* will no longer home in on other players
  - Some additonal text relating to spectating is now translated in some languages
  - **API CHANGE:** starCount, renumber_stars, and area_stars have been combined into star_data
    - The old format will still work, but it is recommended that one updates
  - **API CHANGE:** get_tag now returns an empty string if there are no tags instead of nil
  - The goal in SM64: Underworld is now listed as "Collect 30 stars and defeat The Shitilizer" instead of simply "Collect 30 Stars"
  - Various visual adjustments to the menu
  - Adjusted some characters in the Extended HUD Font
  - Runner Lives, Time/Stars, Team Attack, and Runner PVP DMG Up will be saved separately for each mode
  - Respawning is now faster in MiniHunt
  - All chat commands now use the language system
  - Fixed some lines not being in the language system
  - Changed /mh pause to refer to all players by default, like the description says.
  - The timer will not remain frozen if "All Players" are paused if the host is unpaused.
  - **All star/key cutscenes are faster**
  - **Runners now gain 20 seconds of invulnerability when the Grand Star appears**
  - Weak mode is no longer on by default when using OMM Rebirth (Isaac)
  - Mips and Mother Penguin dialog is now automatically skipped
  - The punishment for warping is now smarter (won't trigger from standard gameplay anymore!)
### Fixes:
  - Fixed team change popups displaying the wrong color for the name
  - Fixed win detection for SM64 Sapphire
  - Fixed spectating in the Eyerok boss and TTM slide
  - Fixed Warp To Level in the player menu not being selectable
  - Fixed 1ups killing the player in Ztar Attack 2
  - The Star Radar will no longer glitch out if multiple of the same star is present
  - Fixed a softlock when using OMM Rebirth + Ztar Attack 2
  - Fixed script error when typing /hard with no arguments
  - Fixed reconnecting Runners getting their lives restored
  - Fixed black screen when switching to MiniHunt while in the castle
  - Some fixes for snowman's head (CCM) and the Manta Ray have been added (Issac)
  - Fixed runner timer being recalculated whenever a new runner is selected in Switch mode
  - Fixed double message bug when using Nicknames or Swear Filter
    - Note that Team Chat and roles are disabled when these are used
  - Fixed box stars falling through the floor while the menu is open
  - FINALLY fixed talking to Toad after exiting a course resulting in the camera getting stuck
  - Probably a bunch of other things
## v2.2
### Additions:
  - Updated Spanish Translation (KanHeaven)
  - Added support for SM64: The Underworld
### Adjustments:
  - Some animations will now be faster (Troopa)
  - **Hunters now run slightly faster**
  - More star requirements have been added to Star Road
  - Adjusted the size of selectors in menu
  - Made the Exclamation Box radar less opaque
### Fixes/Backend changes:
  - All menu-related text now uses the language system
  - Fixed switching languages via commands not update the menu
  - Fixed script errors as a result of the latest OMM Rebirth update
  - Fixed coin duplication when using OMM Rebirth
  - Fixed issue with being able to cross-team when using Cappy
    - This was actually implemented earlier, but didn't work until this OMM update
  - Due to complaints, the debug command /mh combo was modified to only display locally
  - Fixed the API version string still being v2.0
  - Fixed being able to grab stars with Cappy in MiniHunt
## v2.1
### Additions:
  - **Added menu!** Use /mh to open or hold L and press START. It does almost everything commands can do! (not fully translated at this time)
    - Thanks so much to **Blocky** for making the framework for this.
  - Updated German Translation (N64-Mario)
  - Added /mh blacklist, which lets you select stars to blacklist in MiniHunt! You can also use the menu.
  - You can now get info about a specific command with /mh help [command]
  - Added Red Coin and Secret radars
  - Added Extreme Mode, because Hard Mode wasn't hard enough apparently
  - Added... something else (secret)
  - **API Additions:**
    - isExtremeMode, which works like isHardMode
    - trans and trans_plural, which can use the language data
    - valid_star, which returns if the star is valid (useful for minihunt integrations)
    - mod_powers, which allows you to quickly check for hosts, mods, or devs
    - isMenuOpen, for checking if the menu is open (duh)
    - getPlayerField and getGlobalField, to read other fields such as lives
    - get_role_name_and_color, which returns the name of the player's role, a color string, and a color table
    - global_popup_lang, which is a combination of trans and djui_popup_create_global
    - get_tag, which gets the tag like shown in chat
    - For rom hacks: heartReplace, which replaces hearts with 1-ups if enabled
    - mute.lua now displays who muted the player
### Adjustments:
  - Changed the name of Windy Wing Cap Well's replica to reflect its actual location
  - Nerfed Hunters' water punch again
  - Buffed Hunters' water punch when using OMM Rebirth
  - Regular doors now open automatically instead of being destroyed (EmeraldLockdown)
  - Added some more stars to the blacklist in Star Road
  - You can now only restart a stage in MiniHunt (exit course) when standing on the ground
  - A star sound now plays whenever you become Runner, rather than only from a kill
  - Role change popups now change color depending on if the player is in Hard or Extreme mode
  - Moderators and devs can change the auto status, instead of just the host
  - Other people's placement in the 64 Tour will now be displayed in Stats (note: Only those with known discord ids will have their placement shown)
  - Rejoin notifications now appear for all players
### Fixes/Backend changes:
  - Fixed cap switches being unlocked when loading a lobby in MiniHunt mode
  - Fixed star count not resetting when switching save files, or when switching from MiniHunt to Standard modes
  - Fixed non-stop mode in OMM not getting disabled sometimes
  - Fixed some popups being displayed in the sender's language rather than your own
  - **API CHANGE:** Fixed script errors when using mhSetup.lua without having MarioHunt enabled
  - **API CHANGE:** become_runner and become_hunter now use indexes as their arguments (and therefore, now actually work)
  - Obfuscated code related to the dev role and competition placement (thanks Isaac)
  - Removed .png images from the files; they are available in mh-textures.zip
## v2.0
### Additions:
  - **Added MiniHunt!** A new gamemode for bite-sized gameplay.
    - Added /mh auto, for starting games of MiniHunt automatically
    - Added /skip to skip stars in MiniHunt
  - Readded /mh start reset, though be warned: it is quite buggy
  - Added more new text
  - Added a speedrun timer for Standard modes; toggle with /timer
  - Added /mh forcespectate, allowing for players to make private games that others can spectate
  - Added support for the following rom hacks:
    - Super Mario 64 Sapphire
    - Ztar Attack 2
      - Added /stalk, exclusive to this rom hack as of now
    - SM64: The Green Stars
  - Added a [wiki](wiki/home.md) (wip)
  - **Added the MarioHunt API!** Now you can make your own rom hacks compatible, make add-on mods, or make your own mods compatible. Check the [wiki](wiki/home.md) for more info.
    - The files test_mh_api.lua and mhSetup.lua are meant to be examples.
    - mute.lua is Beard's mute mod made compatible with MarioHunt.
  - Added /mh desync to fix desync issues
  - Added /mh stop to quickly end games
  - Your last used settings are now automatically saved
    - Use /mh default to reset
  - Added two new spectate modes: A more zoomed in mode, and FIRST PERSON (may cause motion sickness)
  - Added more alias for some commands
  - Added a new menu for stats, accessible with /stats
    - Two new stats: Hard Mode wins and placement in the 64 Tour Competition (Top 10 only)
  - Added **Hard Mode** for Runners
  - All supported rom hacks have new names for Secret Stars! (intentionally different from Progress Pop-Ups, which is not compatible with MarioHunt)
  - Added a Star Radar to track down stars (and star boxes!)
  - Top 10 players in the 64 Tour Competition have their placement displayed next to their name whenever they chat.
    - The first place player, Bombs-_-, has a rainbow radar when they are Runner.
  - Almost all command descriptions and feedback have been translated into Spanish (thanks KanHeaven)
  - Added punishment for camping using warps
  - Added some level settings to improve experience, such as Visible Secrets, Cap Timer, Blue Coin Switch Respawn, etc.
  - **1Ups now heal players**
    - In vanilla, Recovery Hearts are replaced with 1Ups
  - Added /spectate runner to... spectate runners
  - Specator mode now shows the health of the player
  - Players who ask questions about how to play or why they can't collect stars are prompted to read the rules
    - Spanish and English only (Spanish does not have a "can't collect stars" check)
  - Spanish speakers who ask if this is an English server will be prompted to change languages
  - TroopaParaKoopa and I are now displayed as Devs when chatting
  - The "game state reset" timer is now displayed in the top left
### Adjustments:
  - Red Coins now once again heal Runners
  - Adjusted some sign text (also fixed bad margins)
  - Changed switch mode description to correctly reflect changes to how Runner selection works
  - MarioHunt will always display first in the mods list (necessary for the API to work)
    - A warning message will be displayed if this mod is installed in the base directory (breaks API)
  - The size of all pop-ups, excluding star messages, has been reduced
  - The name of the mod is now displayed with Mario being blue and Hunt being red
  - The kill combo is now displayed as it builds rather than after the combo ends
  - A message is displayed for all players when a player's role is changed via /mh flip, /mh random, or /mh add
  - Runners can be damaged while wearing the Metal Cap
  - Players wearing the Metal Cap now sparkle (like in OMM Rebirth)
  - Messages for defeating Boos, collecting Stars, or entering levels are now automatically skipped in vanilla
  - **Collecting a Star no longer heals the player when using OMM Rebirth**
  - Runners no longer have more invulnerability frames when on the **surface** of water
  - Entering a level early now warps back to the start as opposed to out of the level
  - Changed the way /mh pause works
  - The spectator mode camera is smoother
  - Empty player slots are skipped in spectator mode
  - The specator player list now loops
  - Attacked status is only reset when grounded; as such, kicking players off cliffs will now always count as your kill
  - The camp timer will no longer revoke runner status unless the player is in the star menu; instead, it will activate text boxes/fire cannons automatically
  - Slightly changed victory conditions for Star Road and Super Mario 74
  - Runners cannot read signs while invulnerable
  - Collecting stars now keeps players mid-air
  - Spectators can no longer be made Runners in Switch mode or by /mh random and /mh add
  - Changed the sound effects used for Runners or Hunters winning
  - The coin counter no longer lowers when dying in OMM Rebirth
  - Now using Releases for the mod download
  - probably some other things I'm forgetting
### Fixes/Backend changes
  - Nametags is no longer disabled by default
  - Kills with Cappy are now properly detected
  - Performance improvements (maybe)
  - Fixed issue where collecting red coins with Cappy as Hunter would cause desync... by allowing Hunters to collect red coins when OMM is enabled
  - Fixed issue where rom hacks/omm would sometimes not be detected
  - Added /mh langtest for translators
  - Spectators are now able to spectate players in the DDD and WDW sub areas
  - The "got a key" message should appear again
  - Fixed many issues with the Star Timer
  - The Metal Hunters setting now properly displays the Vanish Cap and Teleportion effects
  - Spectators are no longer affected by level restrictions (so they can spectate desynced players)
  - Fixed issues relating to spectators interacting with water
  - The list of languages by /lang is now alphabetical as opposed to random
  - Fixed Runners with 1 life displaying as "1 lives"
  - Runners no longer lose more health when attacked on the surface of water
  - Fixed issues with lobby music
  - Hunters winning no longer stops the game music
  - Learned why you should not try to put every feature in one update
  - Fixed "LuigiHunt" issue, maybe
  - Removed Wario Apparition
  - more things I'm probably forgetting
## v1.8
### Additions:
  - French Translation by Skeletan
  - Added new text for many bosses, sings, and NPCs (not translated atm)
    - These signs have useful tips for both teams
### Adjustments:
  - Players can now interact with trees, signs, etc. while the game is not active
  - In OMM Rebirth, Runners have invulnerability frames when grabbing a star in Odyssey mode
  - A player's kill count will be displayed if they have over 50 when they join instead of 10
  - Actions that grant invulnerablity frames (such as talking to an NPC) will not be halved in Weak mode
### Fixes/Backend changes:
  - Camp Timer now runs during all text properly
  - Runners have invulnerability frames during all text
  - /mh spectator now works properly
  - Added a notice that I may ask for more translations from translators
  - Runner Switch mode no longer makes everyone Runner when one dies
  - Command feedback now uses language data
    - Note that only English is translated for these at this time
  - Changing the rom hack mid-game properly updates for all players
  - In OMM Rebirth, the star message does not appear twice in Odyssey mode
  - Fixed null lives bug in the lobby
## v1.71
### Adjustments:
  - New Spanish Translation by KanHeaven and SonicDark
### Backend changes:
  - Added more instructions for submitting translations
## v1.7
### Additions:
  - Added /mh weak, which halves invulnerability frames for all players
    - It is enabled by default when using OMM Rebirth
  - Added a popup message when using Nametags advising how to turn nametags on
  - **Added Brazillian Portuguese translation, courtesy of PietroM#4782**
  - "Got a star!" popup now displays what level the star was collected in
### Adjustments:
  - Several changes to lives system, including players being counted as killed faster
    - These changes make the mod work properly with OMM Rebirth
  - Runners will no longer heal from red coins
  - Runners have more invulnerability frames when starting a level
  - Runners have invulnerability frames when exiting a cannon
  - Both runners and hunters now have a camp timer when in a cannon
  - Runners have more invulnerability frames
  - In Runner Switch mode, killing a runner will now make you a runner
  - Renamed many commands to be more concise
    - The old names still function as they always have
  - Replaced /mh addlife with /mh setlife
  - Replaced /mh runnerswitch with /mh mode
### Fixes:
  - HOPEFULLY fixed runners having nil lives _this_ time
  - Fixed rejoin system reconnecting people as if they were someone who just left
  - Reverted spectator change from v1.6 to fix script errors with other mode

## v1.6
### Adjustments:
  - In Runner Switch mode, those who become runners now get their time set to what the other runner's time was
  - Spectators can no longer become Runner in Runner Switch mode
  - Slightly nerfed Hunters' underwatch punch
  - Description for /mh start mentions that the "alt" modifier is buggy
### Fixes/Backend changes:
  - Custom music now plays for players who have just joined the lobby
  - ~~Spectators will no longer interact with lava, quicksand, paintings, etc.~~ Did not fix issue
  - Kill Combo now resets when its time runs out
  - Kill Combo now saves
  - Fixed issue with Runners becoming Hunters when a new player joins
  - Runners can no longer lose lives before the game begins
  - Hopefully fixed issue with Runners having nil lives
  - /mh allowleave now works
  - The Bowser Laugh plays when a Runner dies without being killed
  - The death message appears when a Runner dies without being killed in Runner Switch mode
  - lang.lua has more comments for those who wish to add their own language

## v1.5
- Added changelog

### Mod Additions:
  - Kill Combo: Killing several players in a row displays a popup, and is saved in Stats.
  - Stats: Do /stats to see stats for all players. Keeps track of wins (as runner), kills, and maximum kill streak.
  - While the game is not started, a new music track plays
  - Hunters now move faster when punching underwater
  - Runners have more invulnerability frames underwater
  - /mh hack: Sets rom hack
### Adjustments:
  - Not all cutscenes activate the camp timer anymore
  - Runners can now spectate if the game is not active
  - Runners can no longer constantly grab caps to remain invincible
  - Kill messages now display while the game is not active
  - When the game ends, all players are warped to the starting area
  - The pause command now pauses the entire game
  - A popup is displayed when a player is paused
  - Added color to the upper bar text
  - /mh randomize and /mh addrunner commands will try not to pick the same runner twice in a row
  - Bowser now jumps at the start of the 2nd Bowser fight, like in vanilla
  - Bowser bombs now respawn
  - Players that have not been hit by a player for 10 seconds are not marked as being attacked by that player
  - Popups now display for all players
  - The "got a star!" and "got a key!" messages now include what star or key
    - This mod has issues with Progress Popups, which is why this change is necessary
### Fixes/Backend changes:
  - Made some packets non-essential
  - Exiting spectator no longer warps you to the water's surface
  - Fixed issue in which using multiple spectate commands in a row could teleport you
  - Optimized (?) kill message code a bit
  - Rejoin timer now works for Beta 34
  - Players cannot leave starting area while game is not started
  - Fixed issues regarding star requirements
