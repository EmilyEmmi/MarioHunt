# Running a Game
**FIRST: If you are playing in one of the Standard modes (Normal and Switch) make sure you start with an empty save file!** Unless you're continuing a past game, of course. Don't worry about this with MiniHunt.

MarioHunt is controlled entirely with the **/mh** command. This command handles everything, from picking teams, selecting the game mode, and more.

Setting up a game is a simple 3-step process.
## Step 1: Settings
The commands are listed on the [home page](https://github.com/EmilyEmmi/MarioHunt/blob/main/README.md).
Don't be overwhelmed by the amount of commands. You probably won't use half of them.

Here are the settings you will most likely want to change:

**/mh lives:** Set the amount lives Runners have.
Remember that this is based on Mario 64 rules; so setting this to 1 will have Runners lose after dying **twice**, since game over occurs at -1 lives.

**/mh time:** Sets the amount of time runners have to wait to leave a course OR the amount of time MiniHunt lasts (in seconds).
This is 4 minutes by default.

**/mh mode:** Change the game mode. Do /mh mode mini for MiniHunt, and do /mh mode switch for Switch Mode.
For standard MarioHunt, do /mh mode normal (default).

**/mh default:** Changed too many settings? This will reset everything back to default (including the gamemode).

**/mh auto:** Feeling lazy? In MiniHunt, turn this on and new games will be started **automatically!** It'll even pick a good amount of Runners for you.
Now you can go eat lunch or something (though I would have at least one moderator on to handle any rude players)

**/mh category:** If you want a shorter game, try a different category! Simply type /mh category [NUMBER OF STARS].
This uses Speedrunner Terminology™. The default is a **70 star run**. Other common categories include:
  - 0 star: Play all Bowser stages.
  - 1 star: Play all Bowser stages, plus Board Bowser's Sub.
  - 16 star: Get 15 stars, enter DDD and get Board Bowser's Sub, then enter BITS.
  - 31 star: Play normally until after BITFS, then skip right to BITS.
  - 50 star: Play normally until unlocking the Top Castle Floor, then skip to BITS.
  - 120 star: Get every star in the game! You can't fight Bowser until you get every last one. Not for the faint of heart!
But you don't have to play these categories. You can try, say, 8 stars. Or 42 stars. Or even 78 stars. Everything should work as intended.

Some of these categories normally require glitches. However, MarioHunt will automatically open doors and deactivate the Infinite Stairs so that no glitches are required.
(Imagine trying to do Mips Clips with 7 players trying to beat you up...)
But what if you do want glitches? Set the category to -1. This will activate an **any% run**, where anything goes.

Once that's all handled...
## Step 2: Picking teams
Now it's time to decide who gets to be Runner. First, run
**/mh random [NUM]**, with [NUM] being the amount of Runners.

Now you're ready to- wait, hold on, what if someone wants to *not* be Runner?
Well then, use /mh flip [NAME|ID] to flip their team. Enter their name, or type /players and enter their corresponding ID.
If you want to refer to yourself, just enter nothing and it'll flip your team. You can also use /mh flip to flip a Hunter to a Runner, if someone *really* wants to be Runner.

If you're sure everyone is happy with their teams, it's time to...
## STEP 3: START THE GAME!!!
Just do /mh start. That's it.

But don't forget that you can run commands mid-game, too. If there aren't enough Runners, use /mh add [NUM] to add more runners at random.
You can also use /mh flip in case someone loses their role by disconnecting.

That's it! If you want to know how to play, check the [MarioHunt rules](rules.md) or [MiniHunt rules](mini.md).