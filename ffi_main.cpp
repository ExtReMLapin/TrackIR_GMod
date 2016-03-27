#define _WIN32_WINNT _WIN32_WINNT_MAXVER
#define  DLL_EXPORT extern "C" __declspec( dllexport )


#include <stdio.h>
#include "stdafx.h"
#include "NPTest.h"
#include "NPTestDlg.h"
#include "NPClient.h"
#include "NPClientWraps.h"
#include <string>

CNPTestDlg dlg;
TRACKIRDATA tid;


typedef void(*func)(const char* msg, ...);
static func f = (func)GetProcAddress(GetModuleHandle("tier0.dll"), "Log"); // not the best way but it's working so we don't really care

DLL_EXPORT int trackIR_Pitch(){
	return (tid.fNPPitch);
}

DLL_EXPORT int trackIR_Roll(){
	return (tid.fNPRoll);
}

DLL_EXPORT int trackIR_Yaw(){
	return (tid.fNPYaw);
}

DLL_EXPORT int trackIR_X(){
	return (tid.fNPX);
}

DLL_EXPORT int trackIR_Y(){
	return (tid.fNPY);
}

DLL_EXPORT int trackIR_Z(){
	return (tid.fNPZ);
}


DLL_EXPORT int trackIR_Update(){
	NP_GetData(&tid);
	return 1;
}

DLL_EXPORT int trackIR_NPStatus(){
	return (tid.wNPStatus);
}



DLL_EXPORT int trackIR_Init()
{
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	dlg.DisplayLine("*** ExtReM-Team.com TrackIR GLua API ***");

	/*
	Skyrim : Mod it until it crash										-Reddit
	Gmod : Make un-optimized code until you have less than 40 fps		-Lapin
	C++ : code shit until shit stop working								-Carlmcgee
	*/
	f("-----------------------------------------------------------\n");
	f("Copyright (c) 2016 NaturalPoint Inc. All Rights Reserved\n");
	f("Copyright (c) 2016 ExtReM-Team.com. All Rights Reserved\n");
	f("Build date is "); f(__DATE__); f(".\n");
	f("-----------------------------------------------------------\n");

	dlg.TrackIR_Enhanced_Init();
	NP_ReCenter(); // Let's recenter it so we don't have to press F12
	return 0;
}

DLL_EXPORT int trackIR_End()
{
	dlg.TrackIR_Enhanced_Shutdown();
	return 0;
}