#include <sourcemod>

#include <adminmenu>
#include <sdktools>

TopMenu admin_menu = null;

ConVar mm_vote_percent;
ConVar mm_vote_time;
ConVar mm_time_limit;
ConVar mm_win_limit;

ConVar server_time_limit;
ConVar server_win_limit;

#define VOTE_YES "VOTE_YES"
#define VOTE_NO "VOTE_NO"

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

public void vote_handler(Menu menu, MenuAction action, int param1, int param2)
{
	char item_name[64];
	int total_votes;
	int votes;
	int percent;
	int limit;

	switch (action) {
	case MenuAction_End:
		CloseHandle(menu);
	case MenuAction_VoteCancel:
		if (param1 == VoteCancel_NoVotes)
			plugin_print("No votes were cast.");
	case MenuAction_VoteEnd:
		{
			GetMenuVoteInfo(param2, votes, total_votes);
			GetMenuItem(menu, param1, item_name, sizeof(item_name));

			if (!strcmp(item_name, VOTE_NO) && param1 == 1)
				votes = total_votes - votes;

			percent = RoundToFloor(float(votes) / float(total_votes) * 100);
			limit = GetConVarInt(mm_vote_percent);

			if (percent >= limit) {
				plugin_print("Vote successful. (Received %d%% of %d votes)", percent, total_votes);
				toggle_rotation();
			} else {
				plugin_print("Vote failed. %d%% vote required. (Received %d%% of %d votes)", limit, percent, total_votes);
			}
		}
	}
}

void vote_rotation(int client)
{
	Menu vote_menu;

	if (IsVoteInProgress()) {
		PrintToChat(client, "\x04[MapManager]\x01 Vote already in progress!");
		return;
	}

	vote_menu = CreateMenu(vote_handler, MENU_ACTIONS_ALL);

	if (check_rotation_enabled())
		SetMenuTitle(vote_menu, "End rotation?");
	else
		SetMenuTitle(vote_menu, "Start rotation?");

	AddMenuItem(vote_menu, VOTE_YES, "Yes");
	AddMenuItem(vote_menu, VOTE_NO, "No");

	SetMenuExitButton(vote_menu, false);

	VoteMenuToAll(vote_menu, GetConVarInt(mm_vote_time), 0);
}

public Action vote_command(int client, int args)
{
	vote_rotation(client);

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

public void vote_rotation_menu(TopMenu m, TopMenuAction action, TopMenuObject o, int param, char[] buf, int max)
{
	switch (action) {
	case TopMenuAction_DisplayOption:
		strcopy(buf, max, "Rotation Vote");
	case TopMenuAction_SelectOption:
		vote_rotation(param);
	case TopMenuAction_DrawOption:
		buf[0] = !IsNewVoteAllowed() ? ITEMDRAW_IGNORE : ITEMDRAW_DEFAULT;
	}
}

public void OnAdminMenuReady(Handle handle)
{
	TopMenu top_menu = TopMenu.FromHandle(handle);
	TopMenuObject server_commands;
	TopMenuObject voting_commands;

	if (top_menu == admin_menu)
		return;

	admin_menu = top_menu;

	server_commands = FindTopMenuCategory(admin_menu, ADMINMENU_SERVERCOMMANDS);
	if (!(server_commands == INVALID_TOPMENUOBJECT))
		AddToTopMenu(
			admin_menu,
			"sm_togglerotation",
			TopMenuObject_Item,
			rotation_menu,
			server_commands,
			"sm_togglerotation",
			ADMFLAG_GENERIC
		);

	voting_commands = FindTopMenuCategory(admin_menu, ADMINMENU_VOTINGCOMMANDS);
	if (!(voting_commands == INVALID_TOPMENUOBJECT))
		AddToTopMenu(
			admin_menu,
			"sm_voterotation",
			TopMenuObject_Item,
			vote_rotation_menu,
			voting_commands,
			"sm_voterotation",
			ADMFLAG_VOTE
		);
}

public void OnPluginStart()
{
	TopMenu top_menu;

	if (LibraryExists("adminmenu") && ((top_menu = GetAdminTopMenu()) != null))
		OnAdminMenuReady(top_menu);

	mm_vote_percent = CreateConVar("mm_votepercent", "70", "Rotation vote threshold for map manager");
	mm_vote_time = CreateConVar("mm_votetime", "15", "Rotation vote time for map manager");
	mm_time_limit = CreateConVar("mm_timelimit", "25", "Time limit set by map manager");
	mm_win_limit = CreateConVar("mm_winlimit", "5", "Win limit set by map manager");

	server_time_limit = FindConVar("mp_timelimit");
	server_win_limit = FindConVar("mp_winlimit");

	RegAdminCmd("sm_togglerotation", rotation_command, ADMFLAG_GENERIC);
	RegAdminCmd("sm_voterotation", vote_command, ADMFLAG_VOTE);

	PrintToServer("---- sm_dod_map_manager loaded ----");
}

public void OnLibraryRemoved(const char[] name)
{
	if (StrEqual(name, "adminmenu", false))
		admin_menu = null;
}
