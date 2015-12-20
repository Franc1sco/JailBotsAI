// I am a god of jail ^^
#pragma semicolon 1
#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <botattackcontrol>
#include <hosties>
#include <lastrequest>
#include <colors>
#include <jailbots>


new Handle:hOnClientRebel = INVALID_HANDLE;


#define PLUGIN_VERSION "2.0"

enum listado
{
	String:frase[192],
	bool:rebelado
}

new g_MatrixArray[MAXPLAYERS+1][MAXPLAYERS+1][listado];


public Plugin:myinfo =
{
	name = "SM Jail Bots Base",
	author = "Franc1sco steam: franug",
	description = ".",
	version = PLUGIN_VERSION,
	url = "http://www.clanuea.com/"
};

public OnPluginStart()
{
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("player_death", PlayerDeath);
	
	
	CreateConVar("sm_JailBots_version", PLUGIN_VERSION, "version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
}

public Action:PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(!attacker || !IsFakeClient(attacker)) return;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	
	if(GetClientTeam(attacker) == 3 && GetClientTeam(client) == 2 && g_MatrixArray[attacker][client][rebelado])
	{
		if(!g_MatrixArray[attacker][client][rebelado])
			CPrintToChatAllEx(attacker, "{teamcolor}%N{default} :  %N I'm sorry, I killed you because you were in the middle", attacker, client);
		else if(!StrEqual(g_MatrixArray[attacker][client][frase], "none"))
			CPrintToChatAllEx(attacker, "{teamcolor}%N{default} :  %N %s", attacker, client, g_MatrixArray[attacker][client][frase]);
	}
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsFakeClient(client))
	{
		OnlyCT(client);
		return;
	}
	
	for(new i = 1; i <= MaxClients; i++)
	{
		g_MatrixArray[i][client][rebelado] = false;
	}

}

OnlyCT(client)
{
	if(GetClientTeam(client) == 2)
	{
		CS_SwitchTeam(client, 3);
		CS_RespawnPlayer(client);
	}
}

public Action:OnShouldBotAttackPlayer(bot, player, &bool:result)
{
	if(!result) return Plugin_Continue; // no le atacara de todos modos (a uno del equipo)
	
	if(g_MatrixArray[bot][player][rebelado] && !IsClientInLastRequest(player))
	{
		return Plugin_Continue;
	}
	result = false;
	return Plugin_Changed;
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	CreateNative("JBOT_MakeRebel", Native_MakeRebel);
	CreateNative("JBOT_IsRebel", Native_IsRebel);
	CreateNative("JBOT_MakeNoRebel", Native_MakeNoRebel);
	hOnClientRebel = CreateGlobalForward("JBOT_OnClientRebel", ET_Ignore, Param_Cell, Param_Cell);
    
	return APLRes_Success;
}

stock MakeRebel(bot, player, String:now[192], String:OnDead[192])
{
	Call_StartForward(hOnClientRebel);
	Call_PushCell(bot);
	Call_PushCell(player);
	Call_Finish();
	
	if(!StrEqual(now, "none"))
		CPrintToChatAllEx(bot, "{teamcolor}%N{default} :  %N %s", bot, player, now);
	
	Format(g_MatrixArray[bot][player][frase], 192, OnDead);
	g_MatrixArray[bot][player][rebelado] = true;
}

public Native_MakeRebel(Handle:plugin, argc)
{   
	decl String:now2[192],String:OnDead2[192];
	
	//if(GetNativeString(3, now2, 192) != SP_ERROR_NONE) Format(now2, 192, "none");
	//if(GetNativeString(4, OnDead2, 192) != SP_ERROR_NONE) Format(OnDead2, 192, "none");
	GetNativeString(3, now2, 192);
	GetNativeString(4, OnDead2, 192);
	
	new bot = GetNativeCell(1);
	new player = GetNativeCell(2);
	
	MakeRebel(bot, player, now2, OnDead2);	
}

public Native_IsRebel(Handle:plugin, argc)
{
	new bot = GetNativeCell(1);
	new player = GetNativeCell(2);
	
	return g_MatrixArray[bot][player][rebelado];
}

public Native_MakeNoRebel(Handle:plugin, argc)
{
	decl String:now3[192];
	new bot = GetNativeCell(1);
	new player = GetNativeCell(2);
	
	GetNativeString(3, now3, 192);
	if(!StrEqual(now3, "none"))
		CPrintToChatAllEx(bot, "{teamcolor}%N{default} :  %N %s", bot, player, now3);
	
	g_MatrixArray[bot][player][rebelado] = false;
}