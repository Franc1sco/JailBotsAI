#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <smartjaildoors>

new tiempo;

new Handle:eltimer = INVALID_HANDLE;
new Handle:Cvar_Tiempo = INVALID_HANDLE;

public Plugin:myinfo =
{
	name = "SM Jail Bots Doors Opener",
	author = "Franc1sco steam: franug",
	description = ".",
	version = "3.0",
	url = "http://steamcommunity.com/id/franug/"
};

public OnPluginStart()
{
	HookEvent("round_start", Event_RoundStart);
	Cvar_Tiempo = CreateConVar("sm_jailbots_doorsopenertime", "15", "Time in seconds for open doors on round start when CTs only have bots");
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (eltimer != INVALID_HANDLE)
		KillTimer(eltimer);
		
	eltimer = INVALID_HANDLE;
	
	new vivos = 0;
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == 3)
		{
			vivos++;
		}
	}
	if(vivos > 0) return;
	
	tiempo = GetConVarInt(Cvar_Tiempo);
	PrintCenterTextAll("Doors will open in %i seconds",tiempo);
	eltimer = CreateTimer(1.0, contador, _, TIMER_REPEAT);
}

public Action:contador(Handle:timer, Handle:pack)
{
	--tiempo;
	PrintCenterTextAll("Doors will open in %i seconds",tiempo);
	if(tiempo < 1)
	{
		Abrir();
		PrintCenterTextAll("Doors opened");
		
		if (eltimer != INVALID_HANDLE)
			KillTimer(eltimer);
		
		eltimer = INVALID_HANDLE;
	}
}

Abrir()
{
    SJD_OpenDoors(); 
}