=/\= STRIKE FORCE Unit Scripts release 3.0
12/1/07

Presented here are new unit scripts for land and air battle units, civil, carrier, harvesting, builder and transporter units called "Strike Force" "SF" for short. Included in this release:

=/\= SF Tank 3.0	
=/\= SF Air 3.0 	
=/\= SF Civil 3.0
=/\= SF Builder 3.0
=/\= SF Carrier 3.0
=/\= SF Harvester 3.0
=/\= SF Transporter 3.0

Summary:
-------
SF Tank and Air offers several new offensive and defensive strategies to the the moon player. It offers a button interface for unit formations, lights, movement, targeting, etc.

The SF Builder can build groups of towers. By teaching the script you can easily build a group of small or large towers close to one another or spread out over your base for AA defense. The builder usually will not get stuck.

The SF harvester offers improved behavior for the UCS flying units.

The SF carrier offers the abilty to clear the green target spots for the ED carrier units, especially useful when the carrier is misbehaving :).

The SF Transporter allows for group pick-up and delivery for group tranportation attack



Version 3.0 Changes:
The standard LIGHTS toggle buttons have been returned. The sub-menus have been removed.
SF Air and Land units now have improved targeting when using laser weapon.
SF Air and Land units DOUBLE CLICK move and attack behavior changed, see below.
SF Air and Land and Civil units have the "Turn Unit" button.
A bug preventing SF Air and Land units to move using platoon has been fixed.
SF Civil units now have the FRONTLINE button available.
SF Builder has more choices for spacing of towers.
SF Transporter is added.




Installation:
------------
Please note that this suite may have already been installed as part of an OPX3 upgrade.

To use the scripts, unzip and place the .wd file in this folder:  
<theMoonProjectmainfolder>\WDFiles

You may produce units with this script by setting the unit script to "=/\=SF ..." in the Unit Construction Menu reached by F1.

Alternatively, you may change a unit's script by using the unit's CHANGE SCRIPT BUTTON or by the Hotkey Left-ALT-S and then chosing "=/\=SF ..."


Tank and Air Features:
---------------------

1) The FRONT LINE feature. It is a way to align and position your units. When activated all SELECTED units stop, then move up to a line facing in same direction similar to platoon behavior. Air units will tend to make a vertical wall.

How to use: select the desired units, hit FRONT LINE button, draw a line on ground with the special cursor and units will advance to that line. If a unit gets killed, others behind will move up. 

NOTE: Any move order will cancel FRONT LINE and they will return to their previously defined behavior, chase, hold etc.  Default is FRONT LINE unit behavior OFF.


2) ATTACK feature. Unlike the standard unit behavior in which the unit on the way to the primary target does not shoot at others SF ATTACK shoots at other targets while moving before it reaches primary target.

3) Double Click ATTACK feature.  This is a fast concentrated attack on a specific target. With SPECIAL LIGHTS mode enabled, Lights are turned on, and the unit will only target the selected target until it is destroyed.  It will then resume default behavior. How to use: DOUBLE click a target.


4) MOVE feature: Unlike the standard unit behavior in which the unit stops firing and clears its current target when given a MOVE command, SF MOVE does NOT clear the target and keeps firing while changing direction to the new MOVE destination.  


5) Double Click MOVE feature.  This is a fast move. The current target is cleared, With SPECIAL LIGHTS mode enabled, lights are turned on until destination is reached.  How to use: DOUBLE click a spot on the ground. 


6) MOVEMENT feature. This script starts units out in limited chase mode. Unlike the "Battle Unit" and "Advanced Battle Unit" game scripts that actually allow units to chase for large distances into the enemy's sights, the unit behavior in SF is a limited chase to either 5 or 10 ground spaces for enhanced unit control. There is of course the option of Hold Position. 

How to use: select the desired units, hit MOVEMENT button to access the sub-menu. Then choose CHASE 5, CHASE 10 or HOLD POS.  HOTKEY "H" for hold. Default is CHASE 5.


7) AUTOCANNON feature.  Some players have noted that certain combinations of primary and secondary weapons on the unit cause the unit to shoot slower than usual. With AUTOCANNON ON the script determines the target, With AUTOCANNON OFF the weapon itself determines the target.

How to use: select the desired units, Choose AUTOCANNON OFF or AUTOCANNON ON. Default is AUTOCANNON OFF.


8) SPECIAL LIGHTS feature. The standard hotkey "L"  toggles the lights AUTO, ON, OFF.  Units given the SPECIAL LIGHTS mode have lights that are lights OFF at rest or <10 spaces of destination, lights ON if move >=20 spaces.  This allows for moving fast with lights on to a new destination but when near they shut them off so as not to be noticed. Note the button that contains the "*Lights" reveals the current unit setting.

How to use: to place units in the SPECIAL LIGHTS mode hit the SPECIAL LIGHTS button or use the HOT KEY Hit "S" twice. Default is LIGHTS AUTO.


9) RUINS feature. Allows the script to include building ruins as targets. Feature is useful when you are trying to enter or attack enemy base or when you are trying to clear and rebuild your own.

How to use: select the desired units, Choose KILL RUINS ON or KILL RUINS OFF. Default is KILL RUINS OFF.


10) WALLS feature. Allows the script to include walls as targets.  Feature useful when you are trying to clear walls.

How to use: select the desired units, hit Choose KILL WALLS ON or KILL WALLS OFF. Default is KILL WALLS OFF.


11) RESET feature. Allows the script to reset all parameters to default.  Feature is useful when you have selected units that have different options activated and the menu button area has excessive buttons in view.

How to use: select the desired units, hit RESET button to reset all parameters to default values.


12) Change Script button acts to bring up the menu where you can chose an alterative unit script.


13) RALLY POINT (air units) feature. Allows the air units to gather at a defined RALLY POINT after they get a new supply of ammo

How to use: select the desired units, hit RALLY POINT and click on ground location for the new rally point.

14) SUPPLY button (Hotkey Y) has been added back by popular demand  :)

15) "Turn Unit" button: allows the user to point the units in a certain direction if they are at rest. 

How to use: select the desired units, hit "Turn Unit" button then click a point on the gound (best if far away) to point the units in that direction.



Note: to simplify the button interface, the standard buttons:
ATTACK 	(Hotkey A), 
STOP 		(Hotkey S)  have been hidden


Builder Features
----------------
1) TEACH towers button: this button is visable before the script is taught what tower you desire to build in multiples. 
	a) begin to build a tower that you want replicated by using the standard game interface.
	b) click the TEACH towers button and the code is saved.  note: this button MUST be clicked BEFORE you build anything else.
	c) the TEACH towers button disappears and now 3 new buttons appear. 

2) BUILD towers button: click and then drag using the special cursor to select the area on the ground that you want towers to be built.
	Note: towers will be built to all 4 edges of the build area even if the spacing is large such as 6 x 6. This will give good AA coverage.
	Also, you may use the 1 x 1 setting to block a passage without the builder getting stuck on the wrong side  :)
	The builder will build in the direction FROM your click point TO your drag point building towers along the way at the set interval.

3) SPACING towers Button: AA: 5 x 5 is the default, click for 6 x 6, 1 x 1, 2 x 2, 3 x 3, 4 x 4, 5 x 5  it toggles through the choices 
	Note: it is best to select the spacing BEFORE you build the towers.

4) FACING towers Button: With "Face Default" the script will attempt to determine the correct tower facing direction by the current
	position of the builder and the direction of your click and drag motion. In general it will face the wider dimension of the tower area.  
	Togggle through Face North, Face East, Face South and Face West to force the towers to face in that direction

5) RESET will reset the parameters and get you back to the TEACH towers button


Carrier Feature
----------------
	RESET or a DOUBLE CLICK MOVE will reset BOTH the source and destination settings for the selected carrier and demand the carrier stop until reassigned.
	Note: It will thus clear both green circular spots.


Harvester Feature
-----------------
	Enabling this script will allow the UCS flying harveters to find an alternate harvesting point after a short wait when the
	assigned spot is occupied.

Transporter Feature
-----------------
	"1) Rally A" button: if chosen this is where the transporter with loaded units will gather AFTER they pick up a unit.
	"2) Pickup Spot" button: this is the central area where units will be picked up, Note it will generate a yellow pickup spot for each transporter.
	"3) Rally B" button:  if chosen this is where the empty transporter will gather AFTER they deliver up a unit.
	"4) Delivery" Spot button This is the central area where units will be delivered. Note no yellow spots will be shown.
	DELIVER ! button: commits the delivery to the deliver spot and then moves to Rally B if defined. Note delivery can be aborted.. see below.
	ABORT ! button: cancels any unit going to deliver. The transporter will stop or move to Rally B if defined.
	RESET button: will reset the script and clear all parameters. Transporter already loaded will not lose their units.

	Note: I suggest using the buttons in the order 1) 2) 3) 4) etc. and then DELIVER !
	Note: Rally A and Rally B buttons are recommended but are not necessary to use this transporter.

Plese send any comments or feature requests to me, Kumu at:  Kumu222@hotmail.com