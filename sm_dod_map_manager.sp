#include <sourcemod>

#include <sdktools>

ConVar mm_time_limit;
ConVar mm_win_limit;

ConVar server_time_limit;
ConVar server_win_limit;

public Plugin myinfo =
{
	name = "Map Manager",
	author = "Justin Tobler",
	description = "Manages the server map",
	version = "0.0.0",
	url = "https://github.com/jltobler/sm_dod_map_manager"
};

void enable_rotation()
{
	SetConVarInt(server_time_limit, GetConVarInt(mm_time_limit));
	SetConVarInt(server_win_limit, GetConVarInt(mm_win_limit));
}

void disable_rotation()
{
	SetConVarInt(server_time_limit, 0);
	SetConVarInt(server_win_limit, 0);
}

public Action toggle_rotation(int client, int args)
{
	if (GetConVarInt(server_time_limit) || GetConVarInt(server_win_limit)) {
		PrintToChatAll("\x04[MapManager]\x01 Map rotation disabled!");
		disable_rotation();
	} else {
		PrintToChatAll("\x04[MapManager]\x01 Map rotation enabled!");
		enable_rotation();
	}

	return Plugin_Handled;
}

public void OnPluginStart()
{
	mm_time_limit = CreateConVar("mm_timelimit", "25", "Time limit set by map manager");
	mm_win_limit = CreateConVar("mm_winlimit", "5", "Win limit set by map manager");

	server_time_limit = FindConVar("mp_timelimit");
	server_win_limit = FindConVar("mp_winlimit");

	RegAdminCmd("sm_togglerotation", toggle_rotation, ADMFLAG_GENERIC);

	PrintToServer("---- sm_dod_map_manager loaded ----");
}
