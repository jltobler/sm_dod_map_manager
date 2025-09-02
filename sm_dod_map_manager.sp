#include <sourcemod>

public Plugin myinfo =
{
	name = "Map Manager",
	author = "Justin Tobler",
	description = "Manages the server map",
	version = "0.0.0",
	url = "https://github.com/jltobler/sm_dod_map_manager"
};

public void OnPluginStart()
{
	PrintToServer("---- sm_dod_map_manager loaded ----");
}
