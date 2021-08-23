"Bounty Open Beta v5" Gametype v081  released 2008-08-09

===============================================================================================
This gametype is based on "Bounty Huunter" a gametype by SuperStorm Mod author Gary Mullins ("SpaceTug").

In addition to earning CR for destroying units and structures this gametype offers standard Auto-Ally, the ability to Spy and Anti-Spy enemies as well as the ability to stay in game to observe after you are defeated. Real time rolling in-game statistics are viewed at the top of the screen including Kill Ratio %. Additional player statistics are given for each player prior to the game closing.


For this mod the original 'DES' options have been set as standard default values.
Gaining Money:		Destroy Enemy Units and Structures
Victory Conditions:	Destroy all structures
Research time:		1x
Researches:			All
Unit limit:			No limit
Allied victory:		Allowed
Weater			Passive

Game Options:

TEAM1 and TEAM2
The Team1 and Team2 choices signify how many real players are on each team.
Team1 players are sellected in order going down the game lobby. Once Team1 members are filled Team2 will be filled. Team members will AUTO ALLY (see below) if this option is set. All other players not in Team1 or Team2 will be WATCHERS (see below).

Note some maps have skipped standard player starting positions. This gametype will adjust to missing starting positions. Remember, it will fill the teams from top to bottom. There is no problem setting unequal teams. For example,. 3v2 or 2v1.
Choosing the FFA "Free for All" option sets no teams, no Auto Ally and no WATCHERS at game start. All are real players in game.

AUTO ALLY- DEFAULTED ON
This feature allows players to automatically send a request to ally to other team players and watchers. If asked, the player must still confirm the ally. The gametype starts with the first player in each team to send the request to the others in the team. If you are player #2 in a 5 player team you will get one request.from player #1. You will send ally requests to players #3, #4 and #5.  If you are player #5 of a 5 player team you will have to confirm the ally with all your team members.

The gametype will begin the auto-ally process after a certain time delay so as not to go asynch at game launch. The time delay is determined by the total number of people in the game. (The time delay equals 7 sec + 1 second for each player or watcher. For example, in a 3v3 the ally request will come at 7+6=13 seconds into the game. You have about 1 minute to complete the auto ally, then it will stop sending requests.


STARTING CREDITS:
Self explanitory. This is the amount of credits that you have to begin building your base and units.



BOUNTY DETERMINATION
There are Multiple Factors that Determine the final bounty.

1) UNIT BOUTNY 500CR+
[Choices are: 500|1000|1500|2000|2500|3000|3500|4000|4500|200% HP|225% HP|225% HP|250% HP|275% HP|300% HP] per unit destroyed
The bounty may be based on Credits or Determined by the % of Maximum HP of the destroyed unit.

2) STRUCTURE BOUNTY
[Choices are: 1000|1500|2000|2500|3000|3500|4000|4500|5000|100% HP|105% HP|110% HP|125% HP|150% HP]per unit destroyed
The bounty may be based on Credits or Determined by the % of Maximum HP of the destroyed structure.

3) RACE FACTOR
Due to the difference in ballancing the 3 races the Rebalance Team has included a slight adjustment factor. There is no adjustment if ED kills an ED or UCS kills a UCS, etc. However, if ED kills a LC or UCS unit/structure he will get a 3% reduction. If LC kills ED or UCS he will get a 6% reduction of the amount.

4) DISTANCE FACTOR
The set reference point is the point where the player starts the game.  All kills are measured from that distance. To prevent only defensive strategies the bounty earned is increased proportional to the distance from the reference point.
For thuis version v075 the following range and % multiplers are active
  1-70 spaces linear progression from 0% to 100%
71-120 spaces 100%
  >120 spaces  35%

5) TIME FACTOR
Earning credits is harder at game start and easier mid game. Therefore the final multiplyer based on time is used.
1-15 minutes 150% of potential credit is given
16 minutes and on 100% credit is given unless the following option is chosen:

UnitCR after 15 min
[Choices are: No Reduction|-20% every 5 min.|-20% every 10 min.|-20% every 15 min.|-20% every 20 min.]
As time progresses the bounty earned for kills decreases. The minimum time factor multiplyer is 50% for units, 25% for structures.

SPYING AVAILABLE- DEFAULTED AT 5 MINUTES
This option allows the player to see all units/structures of a single enemy for the cost of 5000 CR. The first requirement to Spy an enemy is that you must have at least one Headquarters structure(HQ) constructed. Next, you must wait for the notice "*** Spy Available***" to appear at the top of the screen. Once the notice is given, (it only is available for one minute), select the HQ building to see the new buttons. Click the button and you will 'Spy' that enemy including any shadowed units. To stop an enemy from Spying yourself you must research and build one or more of the SDI structures. Each SDI building will counter one of the enemy's HQ buildings. For example, to stop your enemy who has 3 HQ buildings from Spying you, you must build at least 3 SDI structures to counter. Also, if I desire to Spy a player who has 3 SDI buildings, I must have at least 4 functioning HQ, etc.

Note WATCHERS:
All people in game not in Team1 or Team2 will be WATCHERS.  In FFA game all are real players. A watcher will start without money and at 5 seconds any watcher units will be destroyed. Therefore, watchers no longer must be "No LC" at game launch. There will be no watcher stats displayed. As in the original DES, allied watchers will get a VICTORY and MoonNet points.

Note DEFEATED PLAYER
A defeated player will be allowed to remain in the game similar to a watcher. A pop-up briefing will be sent to all people stating that player X has been defeated along with player X Kill Bonus and Kill Ratio stats.

Note END OF GAME:
The game enters a temporary mode when all remaining real players are allies and at least one real player has been defeated. Pop-up briefings are sent to all people, one player per page, giving VICTORY notices with the corresponding Kill Bonus and Kill Ratios. This temporary mode is noted at the top of the screen as a count down timer to game close. The time delay equals 10 seconds per real player with a maximum delay of 45 sec. After this time the game will close as usual but the briefings will no longer be available. Unfortunately, any player who quits the game will NOT be able to see his special Kill Bonus or Kill Ratio stats. 

Note SELF KILL:
You may Self-Kill (destroy all your units and sturctures) and remain in game by destroying 2 Landing Zone (LZ) buildings, you will also be able to view your stats.

CHANGELOG
=========
v077- adds the top scroll stat: "Team1 Has X Buildings", "Team2 Has X Buildings", also code optimization.
v078- adds the players on each team to the scroll
    - bug correction on bounty earned.
v079- changes to distance factor
v080- code optimization
v081- v5 compile


CREDITS
=======
Special thanks to "Sam" aka "Sexo" aka "Rocketman" who assisted in the settings and parameter development of this gametype.

===============================================================================================

Please send any comments or feature requests to me, Kumu at:  Kumu222@hotmail.com