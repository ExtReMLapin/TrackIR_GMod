local _DEBUG = false;

local draw = draw -- very important, no time (time searching in the global table) to waste
local math = math
local Angle = Angle

function Nicerlimit(var, minu, maxi) -- no ugly vew like 'max is 130, min is 130, more like max is 130 but every ° over 130 is reducted (exp function)
	local _maxi = maxi + 0.2*maxi -- +20%
	local _minu = minu + 0.2*minu
	local _var = var
	
	if var >= maxi then
		_var = var - maxi
	else 
		if var <= minu then
			_var = var - minu
		else 
			_var = 0
		end
	end
	-- _var is now "how much its over the limit"
	if _var >= 0 then
		var = var + math.sqrt(_var)/2 - _var
	else
		var = var + -1*math.sqrt(math.abs(_var))/2 - _var
	end
	
	var = math.min(math.max(_minu, var), _maxi)
	return var
end

function TrackIR_View( ply, origin, angles, fov, znear, zfar ) -- for the players
	local view = {}
	view.origin 		= origin
	view.angles			= angles + Angle(Nicerlimit(Var_TrackIR_Pitch/90, -70, 70), Nicerlimit(Var_TrackIR_Yaw/90, -130, 130), Nicerlimit(-1*Var_TrackIR_Roll/90, -70, 70))
	view.fov 			= fov
	view.znear			= znear
	view.zfar			= zfar
	view.drawviewer		= false
	return view
end

hook.Add("Tick", "fix *AfxGetMainWnd()", function() -- wait util gmod has focus, else *AfxGetMainWnd() from the module will return a NULL (0x0)
	if !system.HasFocus() then return end
	Var_TrackIR_Debug = ""
	Var_TrackIR_Pitch = 0
	Var_TrackIR_Roll = 0
	Var_TrackIR_Yaw = 0
	Var_TrackIR_X = 0
	Var_TrackIR_Y = 0
	Var_TrackIR_Z = 0
	
	local function map(value, low1, high1, low2, high2)
		return (low2 + (value - low1 ) * ( high2 - low2 ) / (high1 - low1))
	end

	local function TrackIR_Deg_ToRealDeg(deg1)
		deg1 = deg1 or 0;
		return map(deg1, -16383, 16383, -180, 180)
	end

	surface.CreateFont("terminaltitle", {font="Myriad Pro", size=18, antialias=true}) --Title

	require("TrackIR") -- no shit sherlock
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
	hook.Add("CalcView", "trackirview", TrackIR_View)
	
	if  _DEBUG then 
	hook.Add("HUDPaint", "get rekt trackir", function()
		draw.RoundedBox(1, 150, 150, 1300, 400, Color(64, 134, 195,170))
		draw.SimpleText(Var_TrackIR_Debug, "terminaltitle", 200, 200, Color(255,255,255))
		draw.SimpleText("Raw Pitch : " .. Var_TrackIR_Pitch, "terminaltitle", 200, 250, Color(255,255,255)) ; 	draw.SimpleText("Realistic Pitch : " .. math.round(TrackIR_Deg_ToRealDeg(Var_TrackIR_Pitch)) .. "°" , "terminaltitle", 470, 250, Color(255,255,255)) 
		draw.SimpleText("Raw Yaw : " .. Var_TrackIR_Yaw, "terminaltitle", 200, 300, Color(255,255,255)) ; 		draw.SimpleText("Realistic Yaw : " .. math.round(TrackIR_Deg_ToRealDeg(Var_TrackIR_Yaw)) .. "°", "terminaltitle", 470, 300, Color(255,255,255))
		draw.SimpleText("Raw Roll : " .. Var_TrackIR_Roll, "terminaltitle", 200, 350, Color(255,255,255)) ;		draw.SimpleText("Realistic Roll : " .. math.round(TrackIR_Deg_ToRealDeg(Var_TrackIR_Roll)) .. "°", "terminaltitle", 470, 350, Color(255,255,255))
		draw.SimpleText("Raw X : " .. Var_TrackIR_X, "terminaltitle", 200, 400, Color(255,255,255))	;			draw.SimpleText("Realistic Raw X : " .. math.round(Var_TrackIR_X)/100 .. " cm", "terminaltitle", 470, 400, Color(255,255,255))
		draw.SimpleText("Raw Y : " .. Var_TrackIR_Y, "terminaltitle", 200, 450, Color(255,255,255))	;			draw.SimpleText("Realistic Raw Y : " .. math.round(Var_TrackIR_Y)/100 .. " cm", "terminaltitle", 470, 450, Color(255,255,255))
		draw.SimpleText("Raw Z : " .. Var_TrackIR_Z, "terminaltitle", 200, 500, Color(255,255,255))	;			draw.SimpleText("Realistic Raw Z : " .. math.round(Var_TrackIR_Z)/100 .. " cm", "terminaltitle", 470, 500, Color(255,255,255))
		TrackIR_Update()
	end)
	end
	hook.Remove("Tick", "fix *AfxGetMainWnd()") -- everything has been executed, don't let it get executed twice
	
end)

hook.Add("HUDPaint", "TrackIr real aiming", function() -- don't get lost my friend, know where you're aiming ;)
	local tr = (util.TraceLine( util.GetPlayerTrace(LocalPlayer())).HitPos):ToScreen()
	draw.RoundedBox(0, tr.x-6, tr.y-6, 12, 12, Color(0, 0, 0,105))
	draw.RoundedBox(4, tr.x-5, tr.y-5, 10, 10, Color(64, 134, 195,170))	
end)