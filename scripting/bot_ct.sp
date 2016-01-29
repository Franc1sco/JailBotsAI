#pragma semicolon 1
#include <sourcemod>
#include <cstrike>
#include <sdktools>

public Plugin:myinfo =
{
	name = "SM Force bots in CT team",
	author = "Franc1sco steam: franug",
	description = ".",
	version = "1.0",
	url = "http://steamcommunity.com/id/franug/"
};

new Collision_Offsets;

public OnPluginStart()
{
	Collision_Offsets = FindSendPropInfo("CBaseEntity", "m_CollisionGroup");
	HookEvent("player_spawn", PlayerSpawn);
}

public OnClientPutInServer(client)
{
	if(IsFakeClient(client)) ChangeClientTeam(client, 3);
}

/* OnlyCT(client)
{
	if(GetClientTeam(client) == 2)
	{
		//CS_SwitchTeam(client, 3);
		ChangeClientTeam(client, 3);
		//PrintToChatAll("hehcho");
		//CS_RespawnPlayer(client);
	}
} */

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsFakeClient(client) && GetClientTeam(client) > 1)
	{
		SetEntData(client, Collision_Offsets, 2, 1, true);
		//OnlyCT(client);
	}

}