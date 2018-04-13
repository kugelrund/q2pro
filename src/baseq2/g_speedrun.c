#include "g_speedrun.h"
#include "g_local.h"
#include "speedrun/timer.h"

#define STRINGIFY2(X) #X
#define STRINGIFY(X) STRINGIFY2(X)


qboolean speedrun_finished = qfalse;

void PrintSpeedrunTimer()
{
    if (speedrun_finished)
    {
        return;  // final time has been printed already
    }

    const int ACCURACY = 3;
    char total_time_string[SPEEDRUN_TIME_LENGTH];
    char level_time_string[SPEEDRUN_TIME_LENGTH];
    gi.SpeedrunGetTotalTimeString(ACCURACY, total_time_string);
    gi.SpeedrunGetLevelTimeString(ACCURACY, level_time_string);
    gi.bprintf(PRINT_HIGH,
               "==============================\n"
               "| Total time:  %" STRINGIFY(SPEEDRUN_TIME_LENGTH) "s |\n"
               "| Level time:  %" STRINGIFY(SPEEDRUN_TIME_LENGTH) "s |\n"
               "==============================\n",
               total_time_string, level_time_string);
}

void CheckSpeedrunFinished(const gclient_t *client)
{
    if (strcmp(level.mapname, "boss2") != 0)
    {
        speedrun_finished = qfalse;
        return;
    }

    if (speedrun_finished)
    {
        return;
    }

    // Some hardcoded messy stuff. Basically the buttons in the two escape pods
    // are at the most outwards points along the y axis. By checking the
    // y-position of the client we can therefore find out if either of the
    // buttons was pressed.
    const int position_y = client->ps.pmove.origin[1];
    if (position_y <= -16678 || position_y >= 1318)
    {
        gi.SpeedrunPauseTimer();
        gi.SpeedrunLevelFinished();
        PrintSpeedrunTimer();
        speedrun_finished = qtrue;
    }
}

void SpeedrunRunTimer(const gclient_t *client)
{
    CheckSpeedrunFinished(client);

    if (!level.intermissiontime && !speedrun_finished)
    {
        gi.SpeedrunUnpauseTimer();
    }
}
