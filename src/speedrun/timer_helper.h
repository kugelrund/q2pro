#pragma once

#include "speedrun/timer.h"


struct SpeedrunTime
{
	int hours;
	int minutes;
	int seconds;
	int milliseconds;
};

struct SpeedrunTime GetSpeedrunTime(int milliseconds);
void SpeedrunGetTimeString(int milliseconds, int accuracy,
                           char time_string[static SPEEDRUN_TIME_LENGTH]);
