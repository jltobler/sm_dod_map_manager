#include <sourcemod>

#include <adminmenu>
#include <sdktools>

TopMenu admin_menu = null;

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

void plugin_print(const char[] format, any ...)
{
	char buf[256];

	VFormat(buf, sizeof(buf), format, 2);
	PrintToChatAll("\x04[MapManager]\x01 %s", buf);
}

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

bool check_rotation_enabled()
{
	return GetConVarInt(server_time_limit) || GetConVarInt(server_win_limit);
}

void toggle_rotation()
{
	if (check_rotation_enabled()) {
		plugin_print("Map rotation disabled!");
		disable_rotation();
	} else {
		plugin_print("Map rotation enabled!");
		enable_rotation();
	}
}

public Action rotation_command(int client, int args)
{
	toggle_rotation();

	return Plugin_Handled;
}

public void rotation_menu(TopMenu m, TopMenuAction action, TopMenuObject o, int p, char[] buf, int max)
{
	switch (action) {
	case TopMenuAction_DisplayOption:
		strcopy(buf, max, "Toggle Rotation");
	case TopMenuAction_SelectOption:
		toggle_rotation();
	}
}

public void OnAdminMenuReady(Handle handle)
{
	TopMenu top_menu = TopMenu.FromHandle(handle);
	TopMenuObject server_commands;

	if (top_menu == admin_menu)
		return;

	admin_menu = top_menu;

	server_commands = FindTopMenuCategory(admin_menu, ADMINMENU_SERVERCOMMANDS);
	if (server_commands == INVALID_TOPMENUOBJECT)
		return;

	AddToTopMenu(
		admin_menu,
		"sm_togglerotation",
		TopMenuObject_Item,
		rotation_menu,
		server_commands,
		"sm_togglerotation",
		ADMFLAG_GENERIC
	);
}

public void OnPluginStart()
{
	TopMenu top_menu;

	if (LibraryExists("adminmenu") && ((top_menu = GetAdminTopMenu()) != null))
		OnAdminMenuReady(top_menu);

	mm_time_limit = CreateConVar("mm_timelimit", "25", "Time limit set by map manager");
	mm_win_limit = CreateConVar("mm_winlimit", "5", "Win limit set by map manager");

	server_time_limit = FindConVar("mp_timelimit");
	server_win_limit = FindConVar("mp_winlimit");

	RegAdminCmd("sm_togglerotation", rotation_command, ADMFLAG_GENERIC);

	PrintToServer("---- sm_dod_map_manager loaded ----");
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "adminmenu", false))
		admin_menu = null;
}
