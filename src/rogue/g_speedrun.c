#include "g_speedrun.h"
#include "g_local.h"
#include "speedrun/timer.h"

#define STRINGIFY2(X) #X
#define STRINGIFY(X) STRINGIFY2(X)


void PrintSpeedrunTimer()
{
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

void SpeedrunRunTimer()
{
	if (!level.intermissiontime)
	{
		gi.SpeedrunUnpauseTimer();
	}
}
