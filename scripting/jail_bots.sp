// I am a god of jail ^^
#pragma semicolon 1
#include <sourcemod>
#include <cstrike>
#include <sdktools>
#include <botattackcontrol>
#include <colors>
#include <hosties>
#include <lastrequest>
#include <sdkhooks>

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

#define PLUGIN_VERSION "1.2"

new bool:rebeladomatado[MAXPLAYERS+1][MAXPLAYERS+1];
new bool:rebeladodisparo[MAXPLAYERS+1][MAXPLAYERS+1];
new bool:rebeladoatacado[MAXPLAYERS+1][MAXPLAYERS+1];

new Handle:eltimer = INVALID_HANDLE;

public Plugin:myinfo =
{
	name = "SM Jail Bots",
	author = "Franc1sco steam: franug",
	description = ".",
	version = PLUGIN_VERSION,
	url = "http://www.clanuea.com/"
};

public OnPluginStart()
{
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("player_death", PlayerDeath,EventHookMode_Pre);
	HookEvent("weapon_fire", EventWeaponFire,EventHookMode_Pre);
	HookEvent("player_hurt", Event_hurt,EventHookMode_Pre);
	
	HookEvent("round_start", Event_RoundStart);
	
	CreateConVar("sm_JailBots_version", PLUGIN_VERSION, "version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
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
	
	tiempo = 30;
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

public OnClientPutInServer(client)
{
    SDKHook(client, SDKHook_WeaponDropPost, OnWeaponDrop);
}

public OnWeaponDrop(client, entity)
{
    if (!IsClientInGame(client) || !IsValidEdict(entity) || GetClientHealth(client) > 0 || !IsFakeClient(client))
        return;

    RemoveEdict(entity);
}

public Action:Event_hurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if(!client || GetClientTeam(client) != 2 || IsClientInLastRequest(client)) return;
	
	new atacado = GetClientOfUserId(GetEventInt(event, "userid"));
	
	for(new i = 1; i <= MaxClients; i++)
	{
					if(IsClientInGame(i) && IsFakeClient(i) && IsPlayerAlive(i) && !rebeladomatado[i][client] && !rebeladodisparo[i][client] && !rebeladoatacado[i][client] && PuedeVerAlOtro(i, client))
					{
						rebeladoatacado[i][client] = true;
						if(atacado == i)
							CPrintToChatAllEx(i, "{teamcolor}%N{default} :  %N I've seen you attack so you're gonna die!", i, client);
						else
							CPrintToChatAllEx(i, "{teamcolor}%N{default} :  %N I've seen you attack to a CT so you're gonna die!", i, client);

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
					if(IsClientInGame(i) && IsFakeClient(i) && IsPlayerAlive(i) && !rebeladomatado[i][client] && !rebeladodisparo[i][client] && !rebeladoatacado[i][client]  && PuedeVerAlOtro(i, client))
					{
						rebeladodisparo[i][client] = true;
						CPrintToChatAllEx(i, "{teamcolor}%N{default} :  %N I've seen you shoot a gun so you gonna die!", i, client);

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
	
	if(GetClientTeam(attacker) == 2 && !IsClientInLastRequest(attacker))
	{
		for(new i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && IsFakeClient(i) && IsPlayerAlive(i) && i != client && !rebeladomatado[i][attacker] && !rebeladodisparo[i][attacker] && !rebeladoatacado[i][attacker]  && PuedeVerAlOtro(i, attacker))
			{
				rebeladomatado[i][attacker] = true;
				CPrintToChatAllEx(i, "{teamcolor}%N{default} :  %N I've seen you kill a CT so you gonna die!", i, attacker);
			}
		}
	}
	else if(IsFakeClient(attacker) && GetClientTeam(attacker) == 3)
	{
		if(IsFakeClient(client)) return;
		
		if(rebeladomatado[attacker][client]) CPrintToChatAllEx(attacker, "{teamcolor}%N{default} :  %N I killed you because I saw you kill to a CT", attacker, client);
		else if(rebeladoatacado[attacker][client]) CPrintToChatAllEx(attacker, "{teamcolor}%N{default} :  %N I killed you because I saw you attack with your gun to a CT", attacker, client);
		else if(rebeladodisparo[attacker][client]) CPrintToChatAllEx(attacker, "{teamcolor}%N{default} :  %N I killed you because I saw you attack with your gun", attacker, client);
		else CPrintToChatAllEx(attacker, "{teamcolor}%N{default} :  %N I'm sorry, I killed you because you were in the middle", attacker, client);
	}
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsFakeClient(client)) return;
	
	for(new i = 1; i <= MaxClients; i++)
	{
		rebeladomatado[client][i] = false;
		rebeladodisparo[client][i] = false;
		rebeladoatacado[client][i] = false;
	}

		
	if(GetClientTeam(client) == 2)
	{
		CS_SwitchTeam(client, 3);
		CS_RespawnPlayer(client);
	}
}

public Action:OnShouldBotAttackPlayer(bot, player, &bool:result)
{
	if(!result) return Plugin_Continue; // no le atacara de todos modos (a uno del equipo)
	
	if((rebeladomatado[bot][player] || rebeladodisparo[bot][player] || rebeladoatacado[bot][player]) && !IsClientInLastRequest(player))
	{
		return Plugin_Continue;
	}
	result = false;
	return Plugin_Changed;
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