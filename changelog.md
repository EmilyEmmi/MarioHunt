# Changelog
## v1.7
### Additions:
  - Added /mh weak, which halves invulnerability frames for all players
    - It is enabled by default when using OMM Rebirth
  - Added a popup message when using Nametags advising how to turn nametags on
  - **Added Brazillian Portuguese translation, courtesy of PietroM#4782**
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
