#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <jailbots>

new Handle:eltimer[MAXPLAYERS+1] = INVALID_HANDLE;
new Handle:Cvar_Tiempo = INVALID_HANDLE;

public Plugin:myinfo =
{
	name = "SM Jail Bots Forgive",
	author = "Franc1sco steam: franug",
	description = ".",
	version = "2.0",
	url = "http://steamcommunity.com/id/franug/"
};

public OnPluginStart()
{
	HookEvent("round_start", Event_RoundStart);
	Cvar_Tiempo = CreateConVar("sm_jailbots_forgivetime", "60.0", "Time elapsed since a bot see a rebel action for forgive rebel player");
}

public JBOT_OnClientRebel(bot, client)
{
	new Handle:pack;
	
	eltimer[bot] = CreateDataTimer(GetConVarFloat(Cvar_Tiempo), Acabado, pack);
	WritePackCell(pack, bot);
	WritePackCell(pack, client);
}

public Action:Acabado(Handle:timer, Handle:pack)
{
	new bot;
	new client;
	
	
	ResetPack(pack);
	bot = ReadPackCell(pack);
	client = ReadPackCell(pack);
	
	if(IsClientInGame(bot) && IsClientInGame(client) && IsPlayerAlive(bot) && IsPlayerAlive(client) && JBOT_IsRebel(bot, client))
		JBOT_MakeNoRebel(bot, client, "I forgive you");
		
	eltimer[bot] = INVALID_HANDLE;
}

public OnClientDisconnect(client)
{
	if (eltimer[client] != INVALID_HANDLE)
		KillTimer(eltimer[client]);
		
	eltimer[client] = INVALID_HANDLE;
}

public Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if (eltimer[i] != INVALID_HANDLE)
		{
			KillTimer(eltimer[i]);
			eltimer[i] = INVALID_HANDLE;
		}
		
	}
}