# Virpil-configurator-input-translation script
a Powershell Script that will convert input xml file created with old virpil mapping from VPC Software to new mapping set by VPC configurator Alpha.
Game support : Star Citizen, X4 Foundation, Edge of Chaos: Independence War 2

	The script support following configuration (default Virpil buttons assignement)
			Virpil Constellation Alpha prime joystick
			Virpil Constellation Alpha joystick
			Virpil CDT Aero Grip
			Virpil Warbrd-grip
			MongoosT-50CM2/3 Throttle (no shift and 5 way shift modifier)
	        MongoosT-50CM2/3 Throttle in 5 way shift modifier (master) with virpil control panel 2 (slave).
			VMAX Prime Throttle (no shift and 5 way shifter)
			Control Panel 1
			Control Panel 2
	
	Note : Control Panel 3 (standalone) has no buttons assignement change between VPC Configuration and Vpc control configurator.

## Configuration :   

You will need to define Joystick instance / Order value to your specific input configuration.
example: for star citizen

 <options type="joystick" instance="1" Product="VPC Stick WarBRD  {00D53344-0000-0000-0000-504944564944}"></options>
 <options type="joystick" instance="2" Product="VPC Throttle MT-50CM2  {01933344-0000-0000-0000-504944564944}"></options>

 VPC Stick WarBRD (Const alpha) will use joystick instance number 1 (JS1)
 VPC Throttle MT-50CM2 will use joystick instance 2 (JS2)

## launch the script  
Open cmd terminal and launch following command:

powershell.exe -ep bypass -file "x:\xxx\virpil_sc_conversion.ps1"

<img width="525" height="484" alt="image" src="https://github.com/user-attachments/assets/97ef67cf-15c7-4918-a8eb-c150b9d0acf2" />

