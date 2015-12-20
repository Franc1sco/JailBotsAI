#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <hosties>
#include <lastrequest>
#include <jailbots>


public Plugin:myinfo =
{
	name = "SM Jail Bots Rebels",
	author = "Franc1sco steam: franug",
	description = ".",
	version = "2.0",
	url = "http://www.clanuea.com/"
};


public OnPluginStart()
{
	HookEvent("player_death", PlayerDeath);
	HookEvent("weapon_fire", EventWeaponFire);
	HookEvent("player_hurt", Event_hurt);
}


public Action:Event_hurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if(!client || GetClientTeam(client) != 2 || IsClientInLastRequest(client)) return;
	
	new atacado = GetClientOfUserId(GetEventInt(event, "userid"));
	
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i) && IsPlayerAlive(i) && !JBOT_IsRebel(i, client) && PuedeVerAlOtro(i, client))
		{
			if(atacado == i)
				JBOT_MakeRebel(i, client, "I've seen you attacking me so you're gonna die!", "I killed you because I saw you attacking me with your gun");
			else
				JBOT_MakeRebel(i, client, "I've seen you attack to a CT so you're gonna die!", "I killed you because I saw you attack with your gun to a CT");

		}
	}
	
}

public Action:EventWeaponFire(Handle:event,const String:name[],bool:dontBroadcast) 
{       
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(GetClientTeam(client) != 2 || IsClientInLastRequest(client)) return;
		
	decl String:ClassName[30];
	new WeaponIndex;
	WeaponIndex = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(IsValidEntity(WeaponIndex))
	{
		GetEdictClassname(WeaponIndex, ClassName, sizeof(ClassName));
		if (!StrEqual("weapon_knife", ClassName, false) && !StrEqual("weapon_hegrenade", ClassName, false) && !StrEqual("weapon_flashbang", ClassName, false) && !StrEqual("weapon_smokegrenade", ClassName, false))
		{
			for(new i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && IsFakeClient(i) && IsPlayerAlive(i) && !JBOT_IsRebel(i, client) && PuedeVerAlOtro(i, client))
				{

					JBOT_MakeRebel(i, client, "I've seen you shoot a gun so you gonna die!", "I killed you because I saw you attack with your gun");

				}
			}
		}
	}
}

public Action:PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if(!attacker) return;
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	
	if(GetClientTeam(attacker) == 2 && GetClientTeam(client) == 3 && !IsClientInLastRequest(attacker))
	{
		for(new i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && IsFakeClient(i) && IsPlayerAlive(i) && i != client && !JBOT_IsRebel(i, attacker) && PuedeVerAlOtro(i, attacker))
			{
				JBOT_MakeRebel(i, attacker, "I've seen you kill a CT so you gonna die!", "I killed you because I saw you kill to a CT");
			}
		}
	}

}

stock bool:PuedeVerAlOtro(visionario, es_visto, Float:distancia = 0.0, Float:altura_visionario = 50.0)
{

		new Float:vMonsterPosition[3], Float:vTargetPosition[3];
		
		GetEntPropVector(visionario, Prop_Send, "m_vecOrigin", vMonsterPosition);
		vMonsterPosition[2] += altura_visionario;
		
		GetClientEyePosition(es_visto, vTargetPosition);
		
		if (distancia == 0.0 || GetVectorDistance(vMonsterPosition, vTargetPosition, false) < distancia)
		{
			new Handle:trace = TR_TraceRayFilterEx(vMonsterPosition, vTargetPosition, MASK_SOLID_BRUSHONLY, RayType_EndPoint, Base_TraceFilter);

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