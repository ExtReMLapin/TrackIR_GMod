if not file.Exists("garrysmod/lua/bin/gmcl_TrackIR_win32.dll", "BASE_PATH") then print("no trackir  m8") return end
if CLIENT then
	local NPSTATUS;
	local NPSTATUS_REMOTEACTIVE = 0x0
	local NPSTATUS_REMOTEDISABLED = 0x1
	local DPS = 120 -- tickrate multiplier

	local _DEBUG = false;
	local draw = draw -- very important, no time (time searching in the global table) to waste
	local math = math
	local type = type
	local net = net
	local Angle = Angle
	local data1; local data2;
	TrackIR = {}
		TrackIR.VERSION = "Unknown"
		TrackIR.Debug = ""
		TrackIR.Pitch = 0
		TrackIR.Roll = 0
		TrackIR.Yaw = 0
		TrackIR.X = 0
		TrackIR.Y = 0
		TrackIR.Z = 0
		TrackIR.Status = 0
		TrackIR.LostFrames = 0
	surface.CreateFont("terminaltitle", {font="Myriad Pro", size=18, antialias=true}) --Title




	local function RotateVector(vector, angle) -- nice job garry, i have to recode your functions
		local _vector = vector
		local _angle = angle
		_vector:Rotate(angle)
		return _vector
	end
		
	local function RotateVectorAroundAxis( angle, axis, degree )
		local angle1 = angle
		angle1:RotateAroundAxis( axis, degree )
		return angle1
	end
		

	local function map(value, low1, high1, low2, high2)
		return (low2 + (value - low1 ) * ( high2 - low2 ) / (high1 - low1))
	end

	local function TrackIR_Deg_ToRealDeg(deg1)
		deg1 = deg1 or 0;
		return map(deg1, -16383, 16383, -180, 180)
	end

	local function Nicerlimit(var, minu, maxi) -- no ugly view like 'max is 130, min is 130, more like max is 130 but every ° over 130 is reducted (1/exp function)
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


	local function draw_debuginfos()
		draw.RoundedBox(1, 150, 150, 1300, 600, Color(64, 134, 195,170))
		draw.SimpleText(TrackIR.Debug .. "\nTrackIR.Status = " .. TrackIR.Status, "terminaltitle", 200, 200, Color(255,255,255))
		draw.SimpleText("Raw Pitch : " .. TrackIR.Pitch, "terminaltitle", 200, 250, Color(255,255,255)) ; 	draw.SimpleText("Realistic Pitch : " .. math.Round(TrackIR_Deg_ToRealDeg(TrackIR.Pitch)) .. "°" , "terminaltitle", 470, 250, Color(255,255,255)) 
		draw.SimpleText("Raw Yaw : " .. TrackIR.Yaw, "terminaltitle", 200, 300, Color(255,255,255)) ; 		draw.SimpleText("Realistic Yaw : " .. math.Round(TrackIR_Deg_ToRealDeg(TrackIR.Yaw)) .. "°", "terminaltitle", 470, 300, Color(255,255,255))
		draw.SimpleText("Raw Roll : " .. TrackIR.Roll, "terminaltitle", 200, 350, Color(255,255,255)) ;		draw.SimpleText("Realistic Roll : " .. math.Round(TrackIR_Deg_ToRealDeg(TrackIR.Roll)) .. "°", "terminaltitle", 470, 350, Color(255,255,255))
		draw.SimpleText("Raw X : " .. TrackIR.X, "terminaltitle", 200, 400, Color(255,255,255))	;			draw.SimpleText("Realistic Raw X : " .. math.Round(TrackIR.X)/100 .. " cm", "terminaltitle", 470, 400, Color(255,255,255))
		draw.SimpleText("Raw Y : " .. TrackIR.Y, "terminaltitle", 200, 450, Color(255,255,255))	;			draw.SimpleText("Realistic Raw Y : " .. math.Round(TrackIR.Y)/100 .. " cm", "terminaltitle", 470, 450, Color(255,255,255))
		draw.SimpleText("Raw Z : " .. TrackIR.Z, "terminaltitle", 200, 500, Color(255,255,255))	;			draw.SimpleText("Realistic Raw Z : " .. math.Round(TrackIR.Z)/100 .. " cm", "terminaltitle", 470, 500, Color(255,255,255))
		draw.SimpleText("Lost Frames : " .. TrackIR.LostFrames, "terminaltitle", 200, 550, Color(255,255,255))	;			draw.SimpleText("TrackIR software version : " .. TrackIR.VERSION, "terminaltitle", 470, 550, Color(255,255,255))

	end


	local function TrackIR_View( ply, origin, angles, fov, znear, zfar ) -- for the players
			if LocalPlayer():InVehicle() then return end
			if LocalPlayer():GetNetworkedEntity( "ScriptedVehicle", NULL ) != NULL then 
				if string.StartWith(LocalPlayer():GetNetworkedEntity( "ScriptedVehicle", NULL ):GetClass(), "sent_") then return end
			end
			local view = {}
			view.origin 		= origin + RotateVector(Vector(0,Nicerlimit(TrackIR.X/500, -15, 10),-1*math.abs(Nicerlimit(TrackIR.X/900, -5, 5))), (angles))
			view.angles			= angles + (Var_TrackIR_Angle_W or Angle(0,0,0))
			view.fov 			= fov
			view.znear			= znear
			view.zfar			= zfar
			view.drawviewer		= false
			return view
	end



	local function TrackIR_Timer() -- the best way would be to make it 60/120 times per sec. (i mean, not 60-120, it's 60 OR 120 (depending of the trackir device))
			TrackIR_Update()
			TrackIR.VERSION = TrackIR_Ver() or "Unknown"
			TrackIR.Debug = TrackIR_Debug() or ""
			TrackIR.Pitch = TrackIR_Pitch() or 0
			TrackIR.Yaw	= TrackIR_Yaw() or 0
			TrackIR.Roll= TrackIR_Roll() or 0
			TrackIR.X = TrackIR_X() or 0
			TrackIR.Y = TrackIR_Y() or 0
			TrackIR.Z = TrackIR_Z() or 0
			TrackIR.LostFrames = TrackIR_LostFrames() or 0;
			local ang1 = Angle(Nicerlimit(TrackIR.Pitch/90, -70, 70),0,0)
			local ang2 = Angle(0,Nicerlimit(TrackIR.Yaw/90, -130, 130),0)
			local ang3 = Angle(0,0,Nicerlimit(-1*TrackIR.Roll/90 + -2*TrackIR.X/900, -70, 70))
			ang3:RotateAroundAxis( ang3:Right(), -1*ang1[1] )
			ang3:RotateAroundAxis( ang3:Up(), ang2[2] )
			Var_TrackIR_Angle_W =  ang3
			Var_TrackIR_Angle_APIRAW = Angle(Nicerlimit(TrackIR.Pitch/90, -70, 70), Nicerlimit(TrackIR.Yaw/90, -130, 130), Nicerlimit(-1*TrackIR.Roll/90 + -2*TrackIR.X/900, -70, 70))
			TrackIR.Status = TrackIR_Status() or 0 -- if == 1 , it means it's mouse emulation (which is a bit stupid there but anyway)
			data1 = Angle( Nicerlimit(TrackIR.Roll/90 +TrackIR.X/900, -70, 70), -1*Nicerlimit(TrackIR.Pitch/90, -70, 70), Nicerlimit(TrackIR.Yaw/90, -130, 130))
			data2 = -1*TrackIR.X/500
	end

	hook.Add("HUDPaint", "TrackIr real aiming", function() -- don't get lost my friend, know where you're aiming ;)
		if TrackIR.VERSION != "5.00" then return end -- If trackir is not found, then abort mission
		local tr = (util.TraceLine( util.GetPlayerTrace(LocalPlayer())).HitPos):ToScreen()
		draw.RoundedBox(0, tr.x-6, tr.y-6, 12, 12, Color(0, 0, 0,105))
		draw.RoundedBox(4, tr.x-5, tr.y-5, 10, 10, Color(64, 134, 195,170))	
	end)


	hook.Add("Tick", "fix *AfxGetMainWnd()", function() -- wait until gmod has focus, else *AfxGetMainWnd() from the module will return a NULL (0x0)
		if !system.HasFocus() then return end
		require("TrackIR") -- no shit sherlock

		if  _DEBUG then 
			hook.Add("HUDPaint", "get rekt trackir", draw_debuginfos)
		end
		
		local _data1;
		local _data2;
		timer.Create("TrackIR_Calc", 1/120, 0, TrackIR_Timer)
		timer.Create("TrackIR_Net", 1/DPS, 0, function()
			if data1 != _data1 then 
				_data1 = data1;
				net.Start( "TrackIR_Data.h" )
				net.WriteAngle(data1)
				net.SendToServer()
			end
			
			if data2 != _data2 then 
				_data2 = data2;
				net.Start( "TrackIR_Data.s" )
				net.WriteFloat( data2 )
				net.SendToServer()
			end

			
		end)
		hook.Add("CalcView", "trackirview", TrackIR_View) -- hook.Remove("CalcView", "trackirview")
		hook.Remove("Tick", "fix *AfxGetMainWnd()") -- everything has been executed, don't let it get executed twice
		
	end)
end

if SERVER then

	util.AddNetworkString( "TrackIR_Data.h")
	util.AddNetworkString( "TrackIR_Data.s") 
	
	function TrackIR_Applybone( ent, angle, bone)
		if type(angle) == "number" then
			angle = Angle(angle, 0,0)
		end
		local headBoneID = ent:LookupBone( bone )
		if headBoneID then
			ent:ManipulateBoneAngles( headBoneID, angle )
		end
	end
	

	net.Receive("TrackIR_Data.h", function(lenght, ply)
		TrackIR_Applybone(ply, net.ReadAngle(), "ValveBiped.Bip01_Head1" )
	end)
	net.Receive("TrackIR_Data.s", function(lenght, ply)
		TrackIR_Applybone(ply, net.ReadFloat(),  "ValveBiped.Bip01_Spine1")
	end)
	
	
end
