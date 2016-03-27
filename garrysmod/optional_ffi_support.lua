--this file has been auto generated
if TrackIR_Update then return end
require('ffi')
ffi.cdef[[
	int trackIR_Pitch();
	int trackIR_Roll();
	int trackIR_Yaw();
	int trackIR_X();
	int trackIR_Y();
	int trackIR_Z();
	int trackIR_Update();
	int trackIR_NPStatus();
	int trackIR_Init();
	int trackIR_End();
]]
TrackIR = TrackIR or {}

TrackIR.lib = TrackIR.lib or ffi.load("TrackIR_FFI")

TrackIR_Ver =  function() return "Not working with FFI" end
TrackIR_Debug = function() return "Not working with FFI" end
TrackIR_LostFrames = function() return -42 end
TrackIR_Pitch = TrackIR.lib.trackIR_Pitch
TrackIR_Yaw = TrackIR.lib.trackIR_Yaw
TrackIR_Roll = TrackIR.lib.trackIR_Roll
TrackIR_X = TrackIR.lib.trackIR_X
TrackIR_Y = TrackIR.lib.trackIR_Y
TrackIR_Z = TrackIR.lib.trackIR_Z
TrackIR_Update = TrackIR.lib.trackIR_Update
TrackIR_Status = TrackIR.lib.trackIR_NPStatus


if not TrackIR.lib.trackIR_Init then
	print("failed to initialize TrackIR FFI")
else
	print("INITED DIS MATE")
end