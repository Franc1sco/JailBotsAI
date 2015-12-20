#pragma semicolon 1
#include <sourcemod>
#include <sdkhooks>

public Plugin:myinfo =
{
	name = "SM Jail Bots Remove Weapons",
	author = "Franc1sco steam: franug",
	description = ".",
	version = "2.0",
	url = "http://www.clanuea.com/"
};

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