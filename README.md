2024 update : It seems that the natural point policy for the sdk changed, but I have no idea where my trackir device is


![](http://puu.sh/dTvQb/1c1e78fd52.png)

Greetings ! gmcl_TrackIR is a ClientSide Windows module providing a simple interface to TrackIR software
(See bellow for the video and to see how it works)

**API Features :**

-*Easy implantation*, with examples to show how to convert raw variables to Ingame variables (To Angles() or to°)

-*6 DOF API Support* (Pitch, Yaw, Roll, X, Y, Z)

-*All TrackIR features* (not shit) -> Important thing, dependent what you're going to do with TrackIR , you better use different profiles on the trackIR software (Default for FPS/Fight gamemode where you need to aim | Smooth for walking or piloting helicopters/planes -see at the bottom of the thread about WAC support)

**Example Features :**

-4DOF Support (Pitch Yaw and Roll + lean left or right)

-Angle limit (So you don't break your neck)

-"Nice" angle Limit system, when you turn your head and "hit" the angle limit, the camera movement will not be brutally stopped.


**Api guide :**

![](http://puu.sh/gvJ2u/5004204308.png)

All functions are stored in the TrackIR table after the module got executed


This way : 


```txt
] lua_run_cl PrintTable(TrackIR)
	[...]
	Update	=	function: 0x0219b60ac978	
	get_Debug	=	function: 0x0219b60ac9b0
	get_Pitch	=	function: 0x0219b60ac6f8
	get_Roll	=	function: 0x0219b60ac7a0
	get_Status	=	function: 0x0219b60ac878
	get_Ver	=	function: 0x0219b60ac940
	get_X	=	function: 0x0219b60ac730
	get_Y	=	function: 0x0219b60ac840
	get_Yaw	=	function: 0x0219b60ac768
	get_Z	=	function: 0x0219b60ac7d8

```

*Functions returning coordinates :*
TrackIR.get_X;  TrackIR.get_Y;  TrackIR.get_Z;  TrackIR.get_Pitch;  TrackIR.get_Yaw;  TrackIR.get_Roll;  

*Functions returning debug informations :*
TrackIR.get_Debug -> Returning debug infos , if everything is working it will return raw vars formatted , else a message.

*Functions returning informations :*
TrackIR.get_Ver (Not really tested)

*Functions returning .... nothing :*
TrackIR.Update (Request an update for all the coordinates, run it every time you wanna update the view, you better make what i did in the example)



*GLua functions you'll love* : 

TrackIR_Deg_ToRealDeg -> Convert raw values (from the API) to °

	local function map(value, low1, high1, low2, high2)
		return (low2 + (value - low1 ) * ( high2 - low2 ) / (high1 - low1))
	end

	local function TrackIR_Deg_ToRealDeg(deg1)
		deg1 = deg1 or 0;
		return map(deg1, -16383, 16383, -180, 180)
	end



**Requirements : **


TrackIR usb Device

TrackIR Software

Windows (I'll see later for OSX and linux support, i need to contact NaturalPoint about that)



**Copyright (c) 2006-2019 NaturalPoint Inc. All Rights Reserved**




