#pragma once

#include "shared/shared.h"


#define SPEEDRUN_TIME_LENGTH 13

void SpeedrunResetTimer();
void SpeedrunUpdateTimer();
void SpeedrunTimerAddMilliseconds(int msec);
void SpeedrunUnpauseTimer();
int SpeedrunPauseTimer();
void SpeedrunLevelFinished();
void SpeedrunGetTotalTimeString(int accuracy,
                                char time_string[static SPEEDRUN_TIME_LENGTH]);
void SpeedrunGetLevelTimeString(int accuracy,
                                char time_string[static SPEEDRUN_TIME_LENGTH]);
