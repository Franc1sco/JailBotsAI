#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin:myinfo =
{
	name = "SM Jail Bots Remove Weapons",
	author = "Franc1sco steam: franug",
	description = ".",
	version = "3.0",
	url = "http://steamcommunity.com/id/franug/"
};

public OnPluginStart()
{
	for(new i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i)) OnClientPutInServer(i);
}

public OnClientPutInServer(client)
{
    if(IsFakeClient(client)) SDKHook(client, SDKHook_WeaponDropPost, OnWeaponDrop);
}

public OnWeaponDrop(client, entity)
{
    if (!IsClientInGame(client) || !IsValidEdict(entity) || !IsValidEntity(entity))
        return;

    AcceptEntityInput(entity, "kill");
}