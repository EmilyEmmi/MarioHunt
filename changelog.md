# Changelog
## v2.7
### Additions:
  - Added painting overlay that shows how many stars have been collected in that stage
    - Also shows keys and caps
    - Can be disabled in personal settings menu
  - You can now change the button used to activate the vanish cap in Nerf Vanish Cap in the personal settings menu
    - Default is B
  - Added rewards for ASN Tournament!
    - The chat role and crown can be disabled seperately in the Hide My Roles menu, via "ASN Placement" and "ASN Crown" respectively
      - For 1st place, the rainbow radar is tied to the "ASN Crown" role
      - Your placement being annouced is tied to "ASN Placement"
    - All rewards are based on your Discord ID unless requested otherwise. Let me know if you do not have access to your reward.
  - Added radar for keys
  - If the host types "pause" in chat, all players will be paused
    - Must be first word
    - "Unpause" unpauses all players
    - If anyone else does so, the host will be prompted the pause command
  - Added Nametags (MH) to the base mod
    - Is disabled if the server setting is not active
    - You can also now do /nametags color to toggle the role color
  - Added Runners Spectate On Death option
    - Does what it says on the tin
  - Added Team Shuffle option
    - Shuffles the teams of every alive player in the selected amount of time
  - Force spectate state is now stored when disconnecting
  - Added the ability to set the amount of Hunters instead with Randomize and Add (Max, Max-1, etc.)
    - Auto game can also do this
  - Added ASN Tourney preset
    - Sets settings to the same as used in the ASN Tourney (1 extra life)
  - **And now, for the star of the show: The new game mode, MYSTERYHUNT!**
    - Combination of Murder Mystery and MarioHunt
    - Hunters have to defeat all Runners without getting caught
    - Comes with 5 exclusive options:
      - Confirm Hunter Deaths: Displays a message whenever a Hunter dies. Disabling this also makes Hunters produce corpses. Default is ON.
      - Hunters Win Early: Hunters win when they match/exceed the amount of Runners, like in Among Us. Default is ON.
      - Global Chat Time: Time that players can speak whenever a body is found. "Always" allows players to speak to eachother at any time, and "X" gives no time. Default is 1:30.
      - Grace Period: Time before players can kill each other. Default is 20s.
      - Hunters Know Teammates: If disabled, Hunters can kill each other. Default is ON.
    - Mysteryhunt has a different Auto chart, shown here (formula is floor(X * 2 + 1) / 3, in which X is the amount of players, OR X-1, whichever is lower):
      | Players | Hunters |
      |---------|---------|
      | 2-6     | 1       |
      | 7-9     | 2       |
      | 10-12   | 3       |
      | 13-15   | 4       |
      | 16      | 5       |
  - Added support for Limbokong's Voicechat
    - Note that global chat won't work in MysteryHunt (you won't be able to hear everyone)
  - Added lives counter when using OMM Rebirth's hud
### Adjustments:
  - Updated all languages! (EpikCool, N64-Mario, PietroM, Skeltan, N64yt, Mr. L-Ore)
    - Tips are also now translated for Spanish, Portuguese, French, Romanian, and Italian
  - **1Ups now only heal 4 HP instead of 8**
    - Does not apply to Star Revenge 7.5
  - **Moved the star counter to the left side of the screen**
    - Does not apply if Character Select or Personal Star Counter are enabled
  - Lives no longer appear when playing as Hunter
    - Does not apply if Character Select is enabled
  - The rules screen now has new, higher quality images courtesy of MaybeNotJohny
  - Changed the last page of the rules screen to say "Happy Hunting!" instead of "Have fun!"
    - English only for now
    - Thanks to MaybeNotJohny for this suggestion!
  - All players menu was removed; you can now pause/force spectate all players in the Misc. menu
  - Players menu now notifies of unsaved changes
  - Improved "error leave" detection; no longer activates when closing the game purposefully
  - All players now have their state stored when disconnecting; in addition, rejoining while your old player state is still active now sets your role immediately rather than waiting for the old player state to leave
  - Both left and right click now act as "accept" with the mouse (assuming they are set to default binds)
  - Runners can now exit a stage with 0 health, even if they don't have the needed requirements
  - You can now choose your direction after the star grab animation
  - The Red Coin Marker now appears yellow if the red coin star has not been collected
  - Fall Onto The Cage Island is no longer listed as obtainable in Act 1
  - Force Spectate now applies in the lobby again
  - Updated MarioHunt lobby logo to match the color of the mod name (LeoHaha)
  - MarioHunt lobby now has thicker walls in some areas
  - Menu now better matches resolution
  - When using OMM Rebirth, the stars on the minimap now use their OMM textures
  - The following actions are now even faster with Faster Actions enabled (multiplier is compared to vanilla):
    - Dive Picking Up (x4)
    - Releasing Bowser (x3)
    - All "water knockback" actions (x3)
    - All "stuck in ground" actions (x3)
  - Added Stomach Slide Stop to Faster Actions
  - Unlocking a key door is now instant regardless of if Faster Actions is enabled or not
  - Moved the location of the health meter when in spectator mode
  - ALL doors no longer show any dialog when invulnerability is active
  - Stating "the doors are *broken*" now also prompts */mh out*
  - Simply stating "how do" or "como se" no longer prompts the rules message; You now must say "how do I/you play" or "como se juego/juega/juegas"
    - Also now matches "cómo juego/juegas"
  - More phrases along the lines of "I can't grab/collect stars" prompt the rules message, and don't do so when the player is Runner
  - The players menu will shrink of less players are configured
    - Additionally, loops involving players will take less time
  - The Randomize and Add Runners options no longer require at least one hunter, except in MysteryHunt
  - Game settings are now saved when exiting the Game Settings menu instead of when the game starts
  - Made Glow the default option for Runner and Hunter Appearance
  - Being in Hard Mode while double health is enabled now just uses the vanilla health
  - Changed how some settings are displayed at the start of a game
  - Runner PVP DMG Up no longer applies in the lobby
  - /mh out now always uses the death warp (except in Castle Grounds, where it insteads warps to inside castle)
  - Staying in a Bowser stage as a Hunter now follows the same rules as /mh out
### Fixes/backend changes:
  - Fixed Faster Actions not working
  - Fixed not being able to mash A out of "stuck in ground" actions when using Faster Actions
  - Fixed exiting to castle no longer healing
  - Fixed being able to keep vanish cap between levels in rare cases when Nerf Vanish Cap is enabled
  - Fixed Whomp's Fortress incorrectly assuming that Act 1 is completed when calculating obtainable stars
  - Fixed Snowman's Lost His Head not being act specific
  - Fixed spectate controls appearing every time /spectate is used
  - Fixed scrolling through players immediately warping in spectate
  - Fixed incorrect direction being inputted after exiting a door
  - Fixed not being able to exit Free Camera after taking void damage
  - Fixed wins counting multiple times in some scenarios
  - Fixed the cannon in castle grounds being inaccessible regardless of star count
  - Fixed stars not getting recolored in OMM Rebirth on the radar and minimap
  - Fixed unsaved changes message appearing for invalid options
  - Fixed */mh out* warping the one who runs it to Bob-Omb Battlefield instead of Castle Grounds
  - Fixed Swap/Minihunt exclusive tips never appearing
  - Fixed getting sent to zero life in Star Road
  - Fixed Sapphire and LDD Green Comet having star requirements
  - RNG now also depends on global index; this will hopefully reduce repetitive stars in MiniHunt
  - Fixed Leader Death Timer not applying for Hard Mode players
  - Added message when there are more than 10 settings when pressing "List Settings"
  - Fixed "Got All Stars!" message not appearing when it should in vanilla
  - Hopefully fixed games ending immediately on start
  - **API CHANGE:** ommSupport was replaced with ommColorStar
    - Used to know if color stars are supported with the hack
    - Defaults to FALSE
  - */mh langtest all* no longer lists the debug commands or lines that are identical to English
  - */mh langtest all* print statementes are now sorted based on language and in alphabetical order
  - Added several new API functions related to MysteryHunt
## v2.6.2
### Additions:
  - Updated mod for coopDX v1.0 (although there is a version for 36.1, but this is the LAST one for this version)
  - Added Classic preset, which changes settings to match old versions of MarioHunt
  - Added game setting: "Stay If Already Collected"
    - Stay in the level if the star you collected has already been collected
    - Only applies when star collection is set to Leave
    - ON by default
  - Added an option to show at what time the last star was collected
  - Added support for Star Revenge 7 - Park Of Time
  - **API CHANGE:** Added coinColor, which works like starColor but for red coins
  - **API CHANGE:** Added numRedCoins, for rom hacks that make the star appear with less coins
  - Added a message when attempting to leave a menu without saving settings
  - Added support for headless servers
  - The menu now uses coopdx exclusive fonts, if available
  - Some enemies can now be the subject of kill messages (ex: "Bowser finished off EmilyEmmi!")
### Adjustments:
  - Updated the minimap icons for players
  - Updated the lobby minimap to be more accurate
  - Adjusted falling effect in lobby; it now has sound and stops playing when in a bubble
  - Metal doors now make the appropriate noise when being opened automatically
  - Locked key doors no longer show any dialog while invulnerability frames are active
  - **API CHANGE:** Added a third argument to getStarFlagsFunc, a bool called "recalc"
    - TRUE if the function is ran in calculate_leave_requirements (used in Star Revenge 7 to unmark stars that are locked behind badges)'
  - Anniversary date is now April 18th instead of April 19th
  - Removed the update checker, since the function it uses was deprecated
  - Changed the message that appears instructing on how to open the menu into a popup
  - Hunters no longer get paused when entering a Bowser stage that has already been cleared while there are no Runners present
  - Hunters are no longer affected by "Slow down with the warps!"
  - Void DMG now applies to the last hub of Star Road
  - The last safe position for void damage is now automatically set when warping: as such, it is no longer possible to die instantly in Tower Of The Wing Cap
  - Speedrun timer now pauses when global pause is active
  - Placement roles for the 64 Tour now have "64T:" appended to the front
  - Disabling your 64 Tour Placement role will now also disable the rainbow radar, if applicable
  - Force spectate now overrides allow spectate
  - Force spectate now only applies during the game
  - Setting a Runner to force spectate will no longer turn them into Hunters
    - Force spectate Runners will spectate upon death
  - Idling in the act select will no longer instantly kill Runners
    - coopDX v1.0: Runners will enter act 1
    - Old edition: Runners will lose one life
    - The only reason for the difference is that the v1.0 version was made a bit more recently
  - Entering Bowser In The Fire Sea in Free Roam is now possible before collecting Board Bowser's Sub
  - In Free Roam, if Board Bowser's Sub is not collected, the Sub will still appear
  - In Free Roam, courtyard boos now always appear (coopDX v1.0 only)
  - Secrets counter no longer has background, and custom red coin counter was removed since the old one works now (coopDX v1.0 only)
  - Color options now only change your Cap, Emblem, Shirt, and Overalls (coopDX v1.0 only)
### Fixes/Backend changes:
  - Fixed being able make inputs for 2 frames at the start of the game despite being frozen
  - Fixed players at the start of the game appearing in the default pose
  - Fixed exclamation boxes causing errors in hacks such as Star Revenge 7
  - Fixed lives temporarily appearing as 100 or 101 when dying
  - Fixed incorrect numbers being displayed if there are not exactly 8 red coins/5 secrets
  - Fixed menu being displayed under HUD in some scenarios
  - Fixed the BBH back entrance causing the camera to get stuck in vanilla cam
    - As a result, this door specifically will not open automatically
  - Fixed the Runner Appearance and Runner Lives options not showing saved status properly
  - Instances of "°" in Italian have been replaced with "o". This fixes the character displaying as "?", as well as a crash when entering the settings menu in MiniHunt.
  - Corrected "[num]th Placo" in Italian to "[num]o Placo"
  - Red coins are no longer desynced in MiniHunt when using OMM Rebirth to prevent softlocks
  - Fixed spectator camera interacting with the "X Invert" and "Y Invert" options incorrectly
  - Starting a new game now resets the special triple jump state
  - Fixed solo preset causing a script error
  - Fixed signs not appearing in the lobby in vanilla
  - Fixed vanilla tips never appearing
  - Fixed Character Select support
  - Fixed some inaccuracies with Luigi's Mansion 64
  - Changed how star cutscenes are canceled (potential performance boost?)
  - Added support for short color codes (ex: #a05) (coopDX v1.0 only)
## v2.6.1
### Additions:
  - Minimap updates:
    - Added remaining minimap images for vanilla (RoxasYTB)
      - Not available in Lite mode
    - Added Character Select support for minimap (Squishy)
    - Implemented Dynamic Lives Icon into the minimap
      - Not fully available in Lite mode
  - "On star collection" setting may now be changed in-game
  - Added a little something for this **April 19th**
    - Not available in Lite Mode
  - Added Void DMG and "On star collection" to the rules that appear at the start of a game
  - **If the first level of the campaign is selected in single player, your best time is recorded after grabbing the 25th star**
    - Press L + R to restart instantly
    - Vanilla hack only
    - Recorded for movesets, OMM, and vanilla seperately
  - Added menu presets!
    - Reset to Defaults is under here now
    - Quick: Auto Runners, Normal/Swap, 0 lives, 30 (or max) stars, Free Roam, No Bowser
    - Infection: 1 Hunter, Normal, 0 lives, OHKO
    - Solo: 1 Runner (You), Normal, 2 lives, No DMG Add, Double Health
    - Tag: Auto Runners, Swap/Mini, 0 lives, OHKO
    - Star Rush: ALL Runners, Mini
    - English only right now
### Adjustments:
  - Hunters within a Bowser stage with no Runners will now be kicked out after 30 seconds
  - Entering a Bowser stage with no Runners inside as a Hunter now causes the player to freeze
  - **Hunters may no longer grab Bowser**
    - Can still grab Bowser in some rom hacks, such as Star Road
  - Increased invulnerability frames when grabbing and releasing Bowser as a Runner
  - Changed Racing Penguin dialog in vanilla, since the air time check doesn't exist in sm64ex-coop
  - Changed dialog about Hunters being able to grab secrets, since this was changed
  - Increased invulnerability frames for Runners after getting hit in water
  - Runner PVP DMG Up now displays when non-zero instead of only when set to OHKO
  - "You have enough stars!" message now appears 1 star earlier for all categories below 31 star (since DDD is required)
  - Running /mh out in the castle lobby now sends players to Castle Grounds instead of BOB
### Fixes/backend changes:
  - Made key door unlocking action instant again
  - Minor adjustments to warp spam detection (should be less strict now)
  - Fixed getting no invulnerability frames when bouncing off of another player after a hit
  - Fixed "Set as Target" option in menu not working
  - Camera now properly follows player in the bubble action when using vanilla cam
  - Fixed situations where the respawn bubble would cause the player to fall off again
  - Fixed pausing in MiniHunt causing all players to heal
  - Fixed the frame counter being off by 1
  - Fixed star popup not appearing in OMM if the moveset is disabled
  - Fixed pressing X in the players menu flipping the wrong player's team for non-hosts
  - Fixed secrets being desynced even outside of MiniHunt
  - Fixed auto muting not working
## v2.6
### Additions:
  - Added Italian translation (Mr.L-ore)
  - Added Romanian translation (N64, EpikCool)
    - Unfortunately, some important characters ("ș", "ă", and "ț") are not available in the font; as such, they have been replaced with ("s" "a", and "t" respectively)
  - Added Color option for Hunter and Runner Apperance, which forces players' palettes based on their team, a la Arena and Shine Thief
  - Added playtime and parkour records to Stats menu
    - Note that playtime only applies since this update
  - Added seperate parkour records for moveset mods other than OMM Rebirth
  - Added ability to see number of secrets in an area
  - Added Minimap, which can be enabled in player settings
    - Somewhat wip; it renders an image for BoB and the lobby (LeoHaha), renders a rectangle otherwise
    - No images in Lite Mode
  - Added option to disable the radar
  - Added option to use Romhack Cam
  - Added Free Roam game option, which disables all star and key requirements
    - Does not disable Bowser 3 requirements, unless No Bowser mode is enabled
    - Does not disable DDD painting blocking Fire Sea
    - Does not change the star numbers at which Toad and Mips appear
    - DOES disable boo cage requirements, "look up" warp requirements, the moat, and the cannon requirements in Star Road
  - Added Star Heal game option
    - Thanks to EpikCool for this suggestion!
  - Added Stalk Cooldown setting, which allows for customization of the frozen timer that appears when using /stalk
    - Thanks to CK64 and Nightf200 for this suggestion!
        - Option and description are not translated for languages other than English and Spanish
  - Added option to replace invulnerabilty frame "blink" effect with a custom particle (OFF by default)
    - Particle drawn by Key's Artworks
    - Uses vanilla particle in Lite Mode
    - Option and description are not translated for languages other than English and Spanish
  - **Added tips!** They appear in the lobby, act select, and pause menu.
    - Only available in English and Spanish at this time
  - Unsaved settings will now be highlighted in yellow
  - Added support for the following rom hacks:
    - SM64 Sapphire Green Comet
    - Luigi's Mansion 64
  - Parkour may be reset with L + R
  - Major settings now appear in the center of the screen when starting a match or joining a lobby
### Adjustments
  - **Rules is now a menu instead of just a chat message**, complete with images
  - Updated various textures for the stats menu and radars (AquariusAlexx, LeoHaha, myself)
  - Radars now render even when the object is out of view
  - Updated Spanish translation (EpikCool)
  - Hard and Extreme wins are now viewed by pressing X in the Stats menu, or by clicking the star/flag
  - Stats menu now shows 4 digits instead of 3
  - The category option now displays "Any%" instead of "Any" in the menu
  - **Red coins and secrets are no longer synced between players in MiniHunt mode** (EmeraldLockdown, Isaac)
  - Hunters may no longer collect secrets
  - Using /target with no parameters now picks the first Runner in the current level by default
  - Increased the size of the bubble that appears when using the Void DMG option
  - Removed cannon opening cutscene
  - Adjusting the "Runner Lives" setting mid-game now automatically adjusts the lives for all Runners
    - Lives will never go below 0 for Runners
  - Far away surfaces (more than 1000 units below Mario) will no longer be set as the last valid position unless no other valid position exists
    - This means that the skip in HMC is no longer trivial when Void DMG is on
### Fixes/Backend changes
  - ACTUALLY fixed star doors being unopenable in Star Road
  - Fixed "Sparkle" option making sparkles appear even if the player is not in the level
  - Removed all mentions of TroopaParaKoopa from the code
  - Fixed entering WDW causing clips and other issues
  - Fixed Glow option for Runners displaying the wrong palette when metal in CoopDX
  - Fixed star popup sound playing twice in OMM... for real this time
  - Changed the way the menu works, so that options that have been selected but not submitted (move option but not pressing "A") will return to their actual values when switching menus
  - Fixed typing no response for commands that refer to a player referring to the host by default instead of yourself
  - Fixed typing /spectate with no arguments displaying the controls message twice
  - Fixed star radar not displaying stars outside of the current room
  - Fixed being able to enter WF, PSS, CCM, and JRB early by performing LBLJ
  - Fixed some menu descriptions getting cut off in some languages
  - Fixed being able to spectate or stalk players in the Act Select
  - Ending sequence may no longer play in No Bowser mode
  - Fixed players getting stuck in Bowser levels in No Bowser mode
  - "Can leave" timer now displays the last second as 0:01 instead of 0:00
  - Fixed act select radar displaying incorrectly if a star is selected mid-level
  - Fixed act select radar taking time to move into position
  - Fixed blacklist not loading for new hacks (DX exclusive?)
  - Fixed errors and inconsistencies in the Spanish translation (green)
  - Mod description is no longer cut off
## v2.5
### Additions:
  - Added Runner Appearance, which works the same as Hunter Appearance
    - "Sparkle" is used instead of metal
    - Suggested by SilverOrigins
  - Added Outline option for Runner and Hunter Appearance (**NOT COMPATIBLE WITH DYNOS, SKIN PACKS, ETC. Also only works with Mario at this time, and there may be other issues.**)
    - Thanks to Key's Artworks for making the models!
    - Suggested by Key's Artworks and SilverOrigins
  - Added the ability to "target" a Runner with /target (or in the Players menu). This displays that Runner's location at all times, changes the target of /spectate and /stalk, and changes their radar texture.
    - Suggested by flipflopbell
  - Added Lite Mode as a seperate download. It removes:
    - All custom models (therefore, Outline does not work)
    - The custom sequence used for the lobby (uses the Title Theme instead)
    - The lobby level (the entrance level is used instead, like in versions prior to the Lobby being added)
  - **API CHANGE:** Added disableNonStop, which works with omm and disables non stop mode
  - **API CHANGE:** Added totalStarCountFunc and getStarFlagsFunc. They take the same arguments as save_file_get_total_star_count and save_file_get_star_flags respectively. Return a value to override the stars in a course, useful if your hack has an *eighth star* or something.
  - Added support for the following rom hacks:
    - Lug's Delightful Dioramas
    - Lug's Delightful Dioramas Green Comet
    - Star Road: The Replica Comet
  - Added update checker, though it will not function until version 37 of coop (EmeraldLockdown)
  - Runner radar now applies in act select
  - Mute mod is now implemented directly (original code by Beard), via /mh mute and /mh unmute
    - API mod has been removed from api_stuff
    - This also fixes many issues and adds language + menu support
  - Added two new options: *Double Runner Health* and *Void Dmg*
    - Double Runner Health: Runners have 16 points of health instead of 8. OFF by default.
    - Void Dmg: Players take this much damage from falling into the void or quicksand (set to OHKO for vanilla behavior). If a player survives, they are returned to the last flat surface they were above. 3 by default.
    - Both were suggested by Drenchy
  - Added /mh out, which warps everyone out of the current level (useful for door desyncs)
### Adjustments:
  - Commands that take player IDs now use global ids (listed when using /players) instead of local ids (unreadable)
  - In commands, players can now be referred to by portions of their name: For example, "Emily" will select "EmilyEmmi", and "Colby" will select "ColbyRayz!".
  - Adjusted vertical wind action: now wind will do a better job of "catching" the player, and cancels into freefall
    - Blocky suggested not canceling the current action at all, but I couldn't find a non-hacky way to implement this so this will have to do
  - Vertical wind now triggers the camping timer
  - Camping timer now no longer appears until 10 seconds remain
  - Added 5 seconds to the vanish cap when using the Nerf Vanish Cap option (hopefully makes some stars less frustrating)
  - Runners can now exit during the star dance animation if the "Leave level" option is used
  - Runners can no longer exit any level when getting enough stars; instead, they can exit the level they are *currently in*, unless that level is BITS
    - Again, not available with all rom hacks
    - Suggested by N64-Mario
  - The warp cooldown is now even smarter: it checks if every other destination is the same (so it now activates for Castle -> BoB -> Castle -> WF -> Castle...)
  - For unsupported rom hacks, entering the ending level will now count as a victory
  - For unsupported rom hacks, the ending level can no longer be entered without the necessary stars
  - Changed radar graphics (LeoHaha)
  - Disabled Star and Cap Switch dialogs
  - List Settings no longer lists certain options if they are set to their default values
  - Hud now appears in Spectator Mode
  - Increased grace period when collecting a star
  - Collecting a star now cancels momentum in Stay In Level mode
  - The rules and info on how to switch languages are no longer shown when joining a lobby if you have at least 1 kill: "List Settings" is used instead
  - Hard mode and extreme mode notices are now popups
  - Renamed "Across The Sinking Logs" in Star Road to "Across The Sinking Slabs"
### Fixes/Backend changes:
  - Fixed the listed runners overlapping with top-right timer
  - Fixed star doors not working in Star Road
  - Fixed star replicas counting towards the needed stars in a level
  - Fixed the death timer not displaying when in first place in MiniHunt
  - Fixed spectators getting warped into paintings
  - Fixed getting softlocked by pausing before some automatic dialog
  - Fixed getting stuck on act menu in spectator mode (Troopa)
  - Fixed some minor issues when using sm64coopdx
  - Acts below Act 1 are no longer treated as Act 1 for act-specific stars
    - This is because of a change that results in Act 0 not spawning anything act-specific
    - Not relevant unless the player is warped to Act 0 for whatever reason
  - **API CHANGE:** Reworked replica stars; now replica stars use the STAR_REPLICA flag
    - Also added *replica_func*, an optional function that lets the user set custom replica flags (useful if your hack, say, has an *eighth star* tied to something)
      - See mhSetup.lua for more
  - Fixed colored radar displaying for OMM Rebirth in SM74 EE
  - Romhacks will now load correctly even if "ROMHACK - " is placed at the start of the name
  - Chat features will now disable even if a MH-compatible chat-related mod is on when using another non MH-compatible chat-related mod
  - "Dormant" stars (when in OMM Rebirth) will no longer be displayed on the radar
  - Adjusted some translations for German (N64-Mario)
  - Fixed issue with "In Swap Mode" displaying in English when using French
  - Made some minor adjustments to Spanish. Now listed as "Español (LatAm)" (Latin American). (EpikCool)
  - **API CHANGE:** Updated version string in the API that I keep forgetting about
  - Updated nametags_mh.lua
  - Typing "single" no longer prompts the user to switch to Spanish
  - A message no longer appears when switching courses in Campaign
  - Cheating in KTQ and penguin races is now only checked locally
  - Fixed votes getting "eaten" when two players vote simultaneously
  - Fixed the menu close sound constantly playing when switching versions in SM74
    - As a consequence, only the host may do this now
## v2.4.1
### Additions:
  - Added the ability to change the countdown until Hunters can move
    - Thanks to BizzareScape for this suggestion!
### Adjustments:
  - The starting game timer now has lower priority over the camp timer
  - The starting game timer now only appears in the castle
### Fixes:
  - Fixed a very exploitable bug, which I am not going to mention to prevent abuse
  - Runners may now win or lose during the starting timer
  - Fixed being Hunters being unable to win in Normal mode if the host is paused
## v2.4
### Additions:
  - Added Hunter Glow option, which makes Hunters glow red
  - Added the ability to turn off seasonal changes
  - Added "Allow 'Stalking'" option, which toggles the /stalk command previously enabled in romhacks such as Ztar Attack 2
    - Also available as the command /mh stalking
  - If spectate is disabled, /spectate's description will be changed to "This command has been disabled."
  - Added message when using an old version of OMM Rebirth
  - **Runners may now leave any course except Bowser In The Sky when enough stars are collected**
    - Does not apply for all ROM hacks, does not apply in any%
  - A message now appears whenever any setting is changed
  - Updated Spanish, French, German, and Brazillian Portuguese translations (KanHeaven, Skeltan, N64-Mario, PietroM, respectively)
### Adjustments:
  - "Seeker Appearence" (sic) has been changed to "Hunter Appearance"
    - **Now a user preference instead of a host option**
    - Combined with the new "Hunter Glow" option
  - Renamed "Switch" mode to "Swap" mode
  - Auto mode can now be used with every mode
    - In Normal and Swap mode, this uses the "Reset Alt Save" option
  - /stalk now forces a 5 second cooldown
  - Some popups/feedback now display "This command has been disabled" instead of "Not available in this mode" for more clarity
  - Changed layout of Settings and Game Settings menus
  - Updated Ztar Attack 2 support
  - "Stop" command will not warp players back to the lobby
  - Hunters can no longer read boss or Bob-Omb Buddy dialog
    - Thanks to Glaze-eta for this suggestion!
  - Hunters can no longer /stalk into Bowser fights (suggested)
  - Adjusted the "ideal runner" formula, used for the "Auto" options
    - Now 40% of the lobby becomes Runners, EXCEPT for 5 in which case only 1 runner is selected
    - Full details for a 16 player lobby:
      | Players | Runners |
      |---------|---------|
      | 2-5     | 1       |
      | 6-7     | 2       |
      | 8-9     | 3       |
      | 10-12   | 4       |
      | 13-14   | 5       |
      | 15-16   | 6       |
  - "Blast Away The Wall" and "Can The Eel Come Out To Play?" are now flagged as act-specific
  - Death timer no longer applies during the starting time of the game
  - Hearts now grant a temporary metal cap when playing in Extreme mode
  - Hunters can no longer interact with chests at all
  - The chests now reset when getting a wrong answer once again
    - Does not apply when using OMM Rebirth
  - Glow mode now changes the color of the player's Metal form (so its visible on Mario and Luigi)
  - Runner and Hunter appearance settings now appear while the game is inactive
### Fixes/Backend changes:
  - Fixed already-collected stars decreasing the "Can leave" timer
  - Fixed being able to skip the starting platform in the parkour challenge
  - Fixed unfinished translations for French (Skeltan)
  - Fixed translation errors for Spanish (KanHeaven)
  - Updated some missing translations for German (N64-Mario)
  - Fixed being unable to open the MH menu during the start of the game
  - Fixed commands not accepting player names with colors
  - Fixed Runners being able to use /stalk without being able to leave the course
  - Fixed stalking with 0 health
  - Fixed settings for gamemode not being loaded when someone other than the host changes settings
  - Fixed some settings resetting when switching game modes
  - More performance improvements (maybe)
  - Fixed treasure chests getting desynced
  - Fixed desync command restoring runner lives in some scenarios
  - Fixed wiggler boss room being unenterable in OMM Rebirth
  - Fixed being unable to move Free Camera if previously spectating a spectator
  - Runners can now die to quicksand in course 0
## v2.33
### Addition:
  - Added leaderboard during MiniHunt!
### Adjustments:
  - Increased grace period after throwing Bowser
  - **API CHANGE:** *no_bowser* now FORCES the default option for the Defeat Bowser value.
  - "Leader Death Timer" no longer applies while playing solo
### Fixes:
  - Fixed lobby music on Mac OSX(?)
  - Fixed star popup sound playing twice in OMM
  - Fixed OMM Rebirth v1.2 not being compatible
  - Fixed playing with all Runners being mistaken for Solo mode
  - Fixed many spectate-related issues, such as being able to throw Cappy
  - Fixed Leader Death Timer option not disabling immediately when disabled mid-game
## v2.32 (minor fix)
### Fixes:
  - Disabled lobby music on Mac OSX to prevent game crash (EmeraldLockdown)
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
  - Added a [wiki](../../wiki) (wip)
  - **Added the MarioHunt API!** Now you can make your own rom hacks compatible, make add-on mods, or make your own mods compatible. Check the [wiki](../../wiki) for more info.
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
