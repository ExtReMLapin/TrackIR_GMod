![](http://puu.sh/dTvQb/1c1e78fd52.png)

Greetings ! gmcl_TrackIR is a ClientSide Windows module providing a simple interface to TrackIR software (See bellow for the video and to see how it works)
**
API Features :**

-*Easy implantation*, with examples to show how to convert raw variables to Ingame variables (To Angles() or to °)
-*6 DOF API Support* (Pitch, Yaw, Roll, X, Y, Z)
-*All TrackIR features* (not shit) -> Important thing, dependent what you're going to do with TrackIR , you better use different profiles on the trackIR software (Default for FPS/Fight gamemode where you need to aim | Smooth for walking or piloting helicopters/planes -see at the bottom of the thread about WAC support)


```flow
st=>start: Lua Script is loaded
op=>operation: require("TrackIR")
op2=>operation: Window Handle is registered and sent to TrackIR software
op3=>operation: Data is requested from the software and can be called from Gmod
op4=>operation: the Example request the data and apply it to the CalcView hook
cond=>condition: system.HasFocus()?
cond2=>condition: Hook started


st->cond(yes)->op
cond(no)->op
op->op2->op3->cond2(yes)->op4->cond2
```


**Example Features :**

-3DOF Support (Pitch Yaw and Roll)
-Angle limit (So you don't break your neck)
-"Nice" angle Limit system, when you turn your head and "hit" the angle limit, the camera movement will not be brutally stopped.


**Api guide :**

*Functions returning coordinates :*
TrackIR_X ; TrackIR_Y ; TrackIR_Z ; TrackIR_Pitch ; TrackIR_Yaw ; TrackIR_Roll

*Functions returning debug informations :*
TrackIR_Debug -> Returning debug infos , if everything is working it will return raw vars formatted , else a message.

*Functions returning informations :*
TrackIR_Ver (Not really tested)

*Functions returning .... nothing :*
TrackIR_Update (Request an update for all the coordinates, run it every time you wanna update the view, you better make what i did in the example)

Like this : 


	function TrackIR_Timer() -- the best way would be to make it 60/120 times per sec. (i mean, not 60-120, it's 60 OR 120 (depending of the trackir device))
		TrackIR_Update()
		Var_TrackIR_Debug = TrackIR_Debug()
		Var_TrackIR_Pitch = TrackIR_Pitch()
		Var_TrackIR_Yaw	= TrackIR_Yaw()
		Var_TrackIR_Roll= TrackIR_Roll()
		Var_TrackIR_X = TrackIR_X()
		Var_TrackIR_Y = TrackIR_Y()
		Var_TrackIR_Z = TrackIR_Z()
	end

	hook.Add("Think", "trackir timer", TrackIR_Timer)



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


About WAC : 

I tried to contact the dev, no answer he didn't accept my friend request :v:

**Copyright (c) 2006-2014 NaturalPoint Inc. All Rights Reserved**




