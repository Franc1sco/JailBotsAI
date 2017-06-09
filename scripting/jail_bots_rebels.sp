#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <hosties>
#include <lastrequest>
#include <jailbots>
#include <cstrike>

Handle timers[MAXPLAYERS+1];

public Plugin:myinfo =
{
	name = "SM Jail Bots Rebels",
	author = "Franc1sco steam: franug",
	description = ".",
	version = "4.0",
	url = "http://steamcommunity.com/id/franug/"
};


public OnPluginStart()
{
	HookEvent("player_death", PlayerDeath, EventHookMode_Pre);
	HookEvent("weapon_fire", EventWeaponFire, EventHookMode_Pre);
	HookEvent("player_hurt", Event_hurt, EventHookMode_Pre);
	
	for(new i = 1; i <= MaxClients; i++)
	{
		if(timers[i] != INVALID_HANDLE) KillTimer(timers[i]);
	
		timers[i] = INVALID_HANDLE;
	}
		
}

public OnClientDisconnect(client)
{
	if(timers[client] != INVALID_HANDLE) KillTimer(timers[client]);
	
	timers[client] = INVALID_HANDLE;
}

public Action:Event_hurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(attacker < 1 || !IsClientInGame(attacker) || !IsPlayerAlive(attacker)) return;
	if(IsClientInLastRequest(attacker) || timers[attacker] != INVALID_HANDLE)
	{
		return;
	}
	//PrintToChat(attacker, "pasado");
	Handle pack;
	CreateDataTimer(0.7, Endhurt, pack);
	WritePackCell(pack, GetEventInt(event, "attacker"));
	WritePackCell(pack, GetEventInt(event, "userid"));
	
	
}

public Action noatacarp(Handle timer, int client)
{
	timers[client] = INVALID_HANDLE;
}

public Action Endhurt(Handle timer, Handle pack)
{
	//unpack into
	new client;
	new atacado;
	
	
	ResetPack(pack);
	client = GetClientOfUserId(ReadPackCell(pack));
	atacado = GetClientOfUserId(ReadPackCell(pack));
	if(!client || !atacado || !IsClientInGame(client) || !IsClientInGame(atacado) || GetClientTeam(client) != 2 || IsClientInLastRequest(client)) return;
	//PrintToChat(client, "pasado2");
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == CS_TEAM_CT && IsPlayerAlive(i) && !JBOT_IsRebel(i, client) && CanSeeOther(i, client))
		{
			if(atacado == i)
				JBOT_MakeRebel(i, client, "I've seen you attacking me so you're gonna die!", "I killed you because I saw you attacking me with your gun");
			else
				JBOT_MakeRebel(i, client, "I've seen you attack to a CT so you're gonna die!", "I killed you because I saw you attack with your gun to a CT");

		}
	}
}

public Action Endfire(Handle timer, Handle pack)
{
	//unpack into
	new client;
	
	
	ResetPack(pack);
	client = GetClientOfUserId(ReadPackCell(pack));
	if(!client || !IsClientInGame(client) || GetClientTeam(client) != 2 || IsClientInLastRequest(client)) return;
	

	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == CS_TEAM_CT && IsPlayerAlive(i) && !JBOT_IsRebel(i, client) && CanSeeOther(i, client))
		{

			JBOT_MakeRebel(i, client, "I've seen you shoot a gun so you gonna die!", "I killed you because I saw you attack with your gun");

		}
	}
}

public Action:EventWeaponFire(Handle:event,const String:name[],bool:dontBroadcast) 
{       
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(IsClientInLastRequest(client))
	{
		if(timers[client] != INVALID_HANDLE) KillTimer(timers[client]);
		
		timers[client] = CreateTimer(0.5, noatacarp, client);
		return;
	}
	
	decl String:ClassName[30];
	new WeaponIndex;
	WeaponIndex = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(IsValidEntity(WeaponIndex))
	{
		GetEdictClassname(WeaponIndex, ClassName, sizeof(ClassName));
		if (!StrEqual("weapon_knife", ClassName, false) && !StrEqual("weapon_hegrenade", ClassName, false) && !StrEqual("weapon_flashbang", ClassName, false) && !StrEqual("weapon_smokegrenade", ClassName, false) && !StrEqual("weapon_c4", ClassName, false))
		{
		

			Handle pack;
			CreateDataTimer(0.6, Endfire, pack);
			WritePackCell(pack, GetEventInt(event, "userid"));
		}
	}
}

public Action Enddead(Handle timer, Handle pack)
{
	//unpack into
	new client;
	new attacker;
	
	
	ResetPack(pack);
	attacker = GetClientOfUserId(ReadPackCell(pack));
	client = GetClientOfUserId(ReadPackCell(pack));
	
	if(!attacker || !client || !IsClientInGame(client) || !IsClientInGame(attacker)) return;
	//PrintToChatAll("hecho");
	if(GetClientTeam(attacker) == 2 && GetClientTeam(client) == 3 && !IsClientInLastRequest(attacker))
	{
		//PrintToChatAll("hecho a ver xd");
		for(new i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && IsFakeClient(i) && GetClientTeam(i) == CS_TEAM_CT && IsPlayerAlive(i) && i != client && !JBOT_IsRebel(i, attacker) && CanSeeOther(i, attacker))
			{
				//PrintToChatAll("hecho2");
				JBOT_MakeRebel(i, attacker, "I've seen you kill a CT so you gonna die!", "I killed you because I saw you kill to a CT");
			}
		}
	}
}

public Action:PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(attacker < 1 || !IsClientInGame(attacker) || !IsPlayerAlive(attacker)) return;
	if(IsClientInLastRequest(attacker) || timers[attacker] != INVALID_HANDLE) return;
	
	Handle pack;
	CreateDataTimer(0.4, Enddead, pack);
	WritePackCell(pack, GetEventInt(event, "attacker"));
	WritePackCell(pack, GetEventInt(event, "userid"));
}

stock bool:CanSeeOther(index, target, Float:distance = 0.0, Float:Height = 50.0)
{

		new Float:Position[3], Float:vTargetPosition[3];
		
		GetEntPropVector(index, Prop_Send, "m_vecOrigin", Position);
		Position[2] += Height;
		
		GetClientEyePosition(target, vTargetPosition);
		
		if (distance == 0.0 || GetVectorDistance(Position, vTargetPosition, false) < distance)
		{
			new Handle:trace = TR_TraceRayFilterEx(Position, vTargetPosition, MASK_SOLID_BRUSHONLY, RayType_EndPoint, Base_TraceFilter);

			if(TR_DidHit(trace))
			{
				CloseHandle(trace);
				return (false);
			}
			
			CloseHandle(trace);

			return (true);
		}
		return false;
}

public bool:Base_TraceFilter(entity, contentsMask, any:data)
{
	if(entity != data)
		return (false);

	return (true);
}