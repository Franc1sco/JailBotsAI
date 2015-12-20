#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

new tiempo;
new iEnt;
new String:EntityList[][] = {
	
	"func_door",
	"func_rotating",
	"func_door_rotating",
	"func_movelinear",
	"prop_door",
	"prop_door_rotating",
	"func_tracktrain",
	"func_elevator",
	"\0"
};

new Handle:eltimer = INVALID_HANDLE;
new Handle:Cvar_Tiempo = INVALID_HANDLE;

public Plugin:myinfo =
{
	name = "SM Jail Bots Doors Opener",
	author = "Franc1sco steam: franug",
	description = ".",
	version = "2.0",
	url = "http://www.clanuea.com/"
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
    for(new i = 0; i < sizeof(EntityList); i++)
        while((iEnt = FindEntityByClassname(iEnt, EntityList[i])) != -1)
            AcceptEntityInput(iEnt, "Open");
}