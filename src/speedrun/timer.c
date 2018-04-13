#include "speedrun/timer.h"
#include "system/system.h"
#include "timer_helper.h"


int last_timestamp = 0;
int stored_total_time = 0;
int stored_level_time = 0;
volatile int current_total_time = 0;
volatile int current_level_time = 0;
qboolean paused = qtrue;

void SpeedrunResetTimer()
{
	last_timestamp = 0;
	stored_total_time = 0;
	stored_level_time = 0;
	current_total_time = 0;
	current_level_time = 0;
	paused = qtrue;
}

void SpeedrunUpdateTimer()
{
	if (paused)
	{
		return;
	}

	int const current_timestamp = Sys_Milliseconds();
	current_total_time = stored_total_time + (current_timestamp - last_timestamp);
	current_level_time = stored_level_time + (current_timestamp - last_timestamp);
}

void SpeedrunUnpauseTimer()
{
	if (paused)
	{
		paused = qfalse;
		last_timestamp = Sys_Milliseconds();
	}
}

void SpeedrunStoreCurrentTime()
{
	int const current_timestamp = Sys_Milliseconds();
	stored_total_time += (current_timestamp - last_timestamp);
	stored_level_time += (current_timestamp - last_timestamp);
	current_total_time = stored_total_time;
	current_level_time = stored_level_time;
	last_timestamp = current_timestamp;
}

qboolean SpeedrunPauseTimer()
{
	if (paused)
	{
		return qtrue;
	}

	SpeedrunStoreCurrentTime();
	paused = qtrue;
	return qfalse;
}

void SpeedrunLevelFinished()
{
	if (!paused)
	{
		SpeedrunStoreCurrentTime();
	}

	stored_level_time = 0;
}

void SpeedrunGetTotalTimeString(
		int accuracy, char time_string[static SPEEDRUN_TIME_LENGTH])
{
	SpeedrunGetTimeString(current_total_time, accuracy, time_string);
}

void SpeedrunGetLevelTimeString(
		int accuracy, char time_string[static SPEEDRUN_TIME_LENGTH])
{
	SpeedrunGetTimeString(current_level_time, accuracy, time_string);
}
