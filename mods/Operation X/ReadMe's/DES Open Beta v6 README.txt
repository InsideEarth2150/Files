"DES Open Beta v6" Gametype v258  released 2008-OCT-18

===============================================================================================
This gametype modifies the standard "Destroy Enemy Structures" and offers the new options of Auto-Ally, Bounty Kill Bonus, the ability to Spy and Anti-Spy enemies, passive and active weather effects as well as the ability to stay in game to observe after you are defeated. Real time rolling in-game statistics are viewed at the top of the screen including Kill Ratio %. Additional player statistics are given for each player prior to the game closing.


For this mod the original 'DES' options have been set as standard default values.
Gaining Money:		Mine for Money
Victory Conditions:	Destroy all structures
Research time:		2x faster
Researches:			All
Unit limit:			No limit
Allied victory:		Allowed

Game Options:

TEAMS
Choices signify how many real players are on each team.
Team players are sellected in order going down the game lobby. Once Team1 members are filled Team2 will be filled. Team members will AUTO ALLY (see below) if this option is set. All other players not in Team1 or Team2 will be WATCHERS (see below).

Note some maps have skipped standard player starting positions. This gametype will adjust to missing starting positions. Remember, it will fill the teams from top to bottom. There is no problem setting unequal teams. For example,. 3v2 or 2v1.
Choosing the FFA "Free for All" option sets no teams, no Auto Ally and no WATCHERS at game start. All are real players in game.

AUTO ALLY AT START
[Choices are: All|Players Only|No Auto Ally]
This option allows players to automatically send a request to ally to other team players and watchers. If asked, the player must still confirm the ally. The team player who must confirm the ally is now randomized.

The gametype will begin the auto-ally process after a certain time delay so as not to go asynch at game launch. The time delay is determined by the total number of people in the game. (The time delay equals 7 sec + 1 second for each player or watcher. For example, in a 3v3 the ally request will come at 7+6=13 seconds into the game. You have about 1 minute to complete the auto ally, then it will stop sending requests.

BOUNTY KILL BONUS
[Choices are: 1|2|3|4|5|10|20|25% HP|Disabled]
This option adds credits to a player who destroys enemy units and structures. The bonus is determined primarily by the Maximum HP of the unit/structure that is destroyed. For example, if 25% is selected, a player who destroys an enemy unit with a maximum HP of 1000 receives a possible credit bonus of 250 CR. Note: Due to the difference in ballancing the 3 races the Rebalance Team has included a slight adjustment factor. There is no adjustment if ED kills an ED or UCS kills a UCS, etc. However, if ED kills a LC or UCS unit/structure he will get a 3% reduction. If LC kills ED or UCS he will get a 6% reduction of the amount. So, for the above example, if the attacker was LC and the killed player was ED, the LC player would receive 250 - 6% = 235 as an immediate credit bonus.  Note no bonus is given for killing your own or ally's units/structures.

SPYING AVAILABLE
[Choices are: 5|10|15|20 Minutes|Disabled]
This option allows the player to see all units/structures of a single enemy for the cost of 5000 CR. The first requirement to Spy an enemy is that you must have at least one Headquarters structure(HQ) constructed. Next, you must wait for the notice "*** Spy Available***" to appear at the top of the screen. Once the notice is given, (it only is available for one minute), select the HQ building to see the new buttons. Click the button and you will 'Spy' that enemy including any shadowed units. To stop an enemy from Spying yourself you must research and build one or more of the SDI structures. Each SDI building will counter one of the enemy's HQ buildings. For example, to stop your enemy who has 3 HQ buildings from Spying you, you must build at least 3 SDI structures to counter. Also, if I desire to Spy a player who has 3 SDI buildings, I must have at least 4 functioning HQ, etc.

WEATHER EFFECTS
[Choices are: Disabled|Passive Wind|Passive Wind, Rain|Passive Wind, Snow|Wind, Rain, Storms|Wind, Snow, Storms|Wind, Rain, Meteors|Wind, Snow, Meteors]
This option allows the game to include weather effects that are simply visual (Passive) or actually can interfere with the game play(Non-Passive). Wind blows over the entire map and its direction and strength changes every 3 minutes. Rain effects occur every 3 minutes to a limited area based on a 4x4 map grid structure. Only 1 random grid area will receive the rain, Electrical storms and Meteors showers occur only every 10 minutes to a limited area based on a 5x5 map grid structure. Only 1 random grid area will receive the storm or meteors, At 10 minutes the storm or meteor will have an intesity of 1, at 20 mintues the intensity is 2, at 30 minutes the intensity is 3, etc.  The hit area radius starts at 10 spaces and increases by one space every 10 minutes. It will therefore take over 100 minutes to reach the maximum intensity of 10 and it will hit an area of 20 spaces. When active weather effects are chosen, strong wind may prevent flying units from taking off and strong rain will slow the movement of units.  Remember the chance of getting hit is small 1/16 (6.25%) for rain/strong wind or 1/25 (4%) for meteor/storm hit.

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
v246- adds Snow as a weather option, adds the top scroll stat: "Team1 Has X Buildings", "Team2 Has X Buildings", Passive Weather is now truly passive, also code optimization. 
v254- adds the players on each team to the scroll
v255- bugfix meteor weather
v256- code optimization
v257- v5 release
v258= v6 release, Team dropdown changed, Auto Ally: during auto ally the confirmation for ally is now randomized
===============================================================================================

Please send any comments or feature requests to me, Kumu at:  Kumu222@hotmail.com