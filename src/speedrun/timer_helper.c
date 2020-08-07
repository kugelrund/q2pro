#include "timer_helper.h"
#include <math.h>
#include <stdio.h>
#include <string.h>


struct SpeedrunTime GetSpeedrunTime(int milliseconds)
{
	const int HOUR_IN_MILLISECONDS = 1000 * 60 * 60;
	const int MINUTE_IN_MILLISECONDS = 1000 * 60;
	const int SECOND_IN_MILLISECONDS = 1000;

	struct SpeedrunTime t;
	t.hours = min(23, milliseconds / HOUR_IN_MILLISECONDS);
	milliseconds %= HOUR_IN_MILLISECONDS;
	t.minutes = milliseconds / MINUTE_IN_MILLISECONDS;
	milliseconds %= MINUTE_IN_MILLISECONDS;
	t.seconds = milliseconds / SECOND_IN_MILLISECONDS;
	milliseconds %= SECOND_IN_MILLISECONDS;
	t.milliseconds = milliseconds;
	return t;
}

void SpeedrunGetTimeString(const int milliseconds, int accuracy,
                           char time_string[static SPEEDRUN_TIME_LENGTH])
{
	/**
	 * As 'GetSpeedrunTime' guarantees
	 *  t.hours in [0, 23]
	 *  t.minutes in [0, 59]
	 *  t.seconds in [0, 59]
	 *  t.milliseconds in [0, 999],
	 * we can be sure that our time_string will be long enough.
	 */
	const struct SpeedrunTime t = GetSpeedrunTime(milliseconds);

	memset(time_string, 0, SPEEDRUN_TIME_LENGTH);
	char *p = time_string;
	if (t.hours > 0)
	{
		const char *format = (t.hours >= 10 ? "%02i:" : "%i:");
		p += sprintf(p, format, t.hours);
	}
	if (t.hours == 0 && t.minutes < 10)
	{
		p += sprintf(p, "%i:", t.minutes);
	}
	else
	{
		p += sprintf(p, "%02i:", t.minutes);
	}
	p += sprintf(p, "%02i", t.seconds);

	if (accuracy > 0)
	{
		const int MAX_ACCURACY = 3;
		accuracy = min(MAX_ACCURACY, accuracy);

		char format[6] = ".%00i";
		format[3] += accuracy;
		const int divisor = pow(10, MAX_ACCURACY - accuracy);
		sprintf(p, format, t.milliseconds / divisor);
	}
}
