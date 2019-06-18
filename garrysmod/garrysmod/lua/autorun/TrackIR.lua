if CLIENT then
	if not file.Exists("garrysmod/lua/bin/gmcl_TrackIR_win32.dll", "BASE_PATH") then
		print("no trackir  m8")
		return
	end

	local DPS = 66 -- tickrate
	local draw = draw
	local math = math
	local net = net
	local Angle = Angle
	local data1
	local data2



	local function RotateVector(vector, angle)
		local _vector = vector
		local _angle = angle
		_vector:Rotate(angle)

		return _vector
	end

	local function Nicerlimit(var, minu, maxi)
		local _maxi = maxi + 0.2 * maxi -- +20%
		local _minu = minu + 0.2 * minu
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
			var = var + math.sqrt(_var) / 2 - _var
		else
			var = var + -1 * math.sqrt(math.abs(_var)) / 2 - _var
		end

		var = math.min(math.max(_minu, var), _maxi)

		return var
	end -- no ugly view like 'max is 130, min is 130, more like max is 130 but every ° over 130 is reducted (1/exp function)

	local function TrackIR_View(ply, origin, angles, fov, znear, zfar)
		local vehicle = LocalPlayer():GetVehicle()

		if LocalPlayer():InVehicle() then
			return
		end

		if IsValid(vehicle) and IsValid(vehicle:GetNWEntity("wac_aircraft")) then
			return
		end


		if LocalPlayer():GetNWEntity("ScriptedVehicle", NULL) ~= NULL and string.StartWith(LocalPlayer():GetNetworkedEntity("ScriptedVehicle", NULL):GetClass(), "sent_") then
			return
		end


		local ang1 = Angle(Nicerlimit(TrackIR.Pitch / 90, -70, 70), 0, 0)
		local ang2 = Angle(0, Nicerlimit(TrackIR.Yaw / 90, -130, 130), 0)
		local ang3 = Angle(0, 0, Nicerlimit(-1 * TrackIR.Roll / 90 + -2 * TrackIR.X / 900, -70, 70))
		ang3:RotateAroundAxis(ang3:Right(), -1 * ang1[1])
		ang3:RotateAroundAxis(ang3:Up(), ang2[2])
		Var_TrackIR_Angle_W = ang3
		local view = {}
		view.origin = origin + RotateVector(Vector(0, Nicerlimit(TrackIR.X / 500, -15, 10), -1 * math.abs(Nicerlimit(TrackIR.X / 900, -5, 5))), angles)
		view.angles = angles + (Var_TrackIR_Angle_W or Angle(0, 0, 0))
		view.fov = fov
		view.znear = znear
		view.zfar = zfar
		view.drawviewer = false

		return view
	end -- for the players

	local function TrackIR_View2(ply, origin, angles, fov, znear, zfar)
		local ang1 = Angle(Nicerlimit(TrackIR.Pitch / 90, -70, 70) + angles[1], 0, 0)
		local ang2 = Angle(0, Nicerlimit(TrackIR.Yaw / 90, -130, 130) + angles[2], 0)
		local ang3 = Angle(0, 0, Nicerlimit(-1 * TrackIR.Roll / 90 + -2 * TrackIR.X / 900, -70, 70))
		ang3:RotateAroundAxis(ang3:Right(), -1 * ang1[1])
		ang3:RotateAroundAxis(ang3:Up(), ang2[2])
		Var_TrackIR_Angle_W = ang3
		local view = {}
		view.origin = origin + RotateVector(Vector(0, Nicerlimit(TrackIR.X / 500, -15, 10), -1 * math.abs(Nicerlimit(TrackIR.X / 900, -5, 5))), angles)
		view.angles = angles + (Var_TrackIR_Angle_W or Angle(0, 0, 0))
		view.fov = fov
		view.znear = znear
		view.zfar = zfar
		view.drawviewer = false

		return view
	end -- for the players

	local function TrackIR_Timer()
		TrackIR.Update()
		TrackIR.Pitch = TrackIR.get_Pitch() or 0
		TrackIR.Yaw = TrackIR.get_Yaw() or 0
		TrackIR.Roll = TrackIR.get_Roll() or 0
		TrackIR.X = TrackIR.get_X() or 0
		TrackIR.Y = TrackIR.get_Y() or 0
		TrackIR.Z = TrackIR.get_Z() or 0
		TrackIR.LostFrames = TrackIR_LostFrames and TrackIR.get_LostFrames() or 0
		Var_TrackIR_Angle_APIRAW = Angle(Nicerlimit(TrackIR.Pitch / 90, -70, 70), Nicerlimit(TrackIR.Yaw / 90, -130, 130), Nicerlimit(-1 * TrackIR.Roll / 90 + -2 * TrackIR.X / 900, -70, 70))
		data1 = Angle(Nicerlimit(TrackIR.Roll / 90 + TrackIR.X / 900, -70, 70), -1 * Nicerlimit(TrackIR.Pitch / 90, -70, 70), Nicerlimit(TrackIR.Yaw / 90, -130, 130))
		data2 = -1 * TrackIR.X / 500
	end -- the best way would be to make it 60/120 times per sec. (i mean, not 60-120, it's 60 OR 120 (depending of the trackir device))

	hook.Add("HUDPaint", "TrackIr real aiming", function()
		local tr = (util.TraceLine(util.GetPlayerTrace(LocalPlayer())).HitPos):ToScreen()
		draw.RoundedBox(0, tr.x - 6, tr.y - 6, 12, 12, Color(0, 0, 0, 105))
		draw.RoundedBox(4, tr.x - 5, tr.y - 5, 10, 10, Color(64, 134, 195, 170))
	end) -- don't get lost my friend, know where you're aiming ;)

	hook.Add("Tick", "fix *AfxGetMainWnd()", function()
		if not system.HasFocus() then
			return
		end

		require("TrackIR") -- no shit sherlock

		TrackIR.Pitch = 0
		TrackIR.Roll = 0
		TrackIR.Yaw = 0
		TrackIR.X = 0
		TrackIR.Y = 0
		TrackIR.Z = 0


		local _data1
		local _data2


		hook.Add("Think", "TrackIRupdate", TrackIR_Timer)

		timer.Create("TrackIR_Net", 1 / DPS, 0, function()
			if data1 ~= _data1 then
				_data1 = data1
				net.Start("TrackIR_Data.h")
				net.WriteAngle(data1)
				net.SendToServer()
			end

			if data2 ~= _data2 then
				_data2 = data2
				net.Start("TrackIR_Data.s")
				net.WriteFloat(data2)
				net.SendToServer()
			end
		end)

		hook.Add("CalcView", "trackirview", TrackIR_View) -- hook.Remove("CalcView", "trackirview")

		if wac then
			wac.hook("CalcView", "trackirview", TrackIR_View2)
		end

		hook.Remove("Tick", "fix *AfxGetMainWnd()") -- everything has been executed, don't let it get executed twice
	end) -- wait until gmod has focus, else *AfxGetMainWnd() from the module will return NULL (0x0)
end

if SERVER then
	util.AddNetworkString("TrackIR_Data.h")
	util.AddNetworkString("TrackIR_Data.s")

	function TrackIR_Applybone(ent, angle, bone)
		if type(angle) == "number" then
			angle = Angle(angle, 0, 0)
		end

		local headBoneID = ent:LookupBone(bone)

		if headBoneID then
			ent:ManipulateBoneAngles(headBoneID, angle)
		end
	end

	net.Receive("TrackIR_Data.h", function(lenght, ply)
		TrackIR_Applybone(ply, net.ReadAngle(), "ValveBiped.Bip01_Head1")
	end)

	net.Receive("TrackIR_Data.s", function(lenght, ply)
		TrackIR_Applybone(ply, net.ReadFloat(), "ValveBiped.Bip01_Spine1")
	end)
end