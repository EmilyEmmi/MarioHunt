# Changelog
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
