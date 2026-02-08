# sm_dod_map_manager

A SourceMod plugin for Day of Defeat: Source that monitors the server and
automatically switches to the default map when player count is low.

## Commands

- `sm_togglerotation`: enables/disables the map rotation
- `sm_voterotation`: starts vote to enable/disable the map rotation

## Configuration Cvars

- `mm_timelimit`: the time limit set by the map manager when rotation is enabled
- `mm_winlimit`: the win limit set by the map manager when rotation is enabled
- `mm_votepercent`: the percent threshold required for map rotation vote to pass
- `mm_votetime`: the time duration of the map rotation vote
- `mm_defaultmap`: the default map changed to when the map rotation ends
