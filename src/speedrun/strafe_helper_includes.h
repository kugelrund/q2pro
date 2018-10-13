#ifndef STRAFE_HELPER_INCLUDES_H
#define STRAFE_HELPER_INCLUDES_H

#include "shared/shared.h"
#include "refresh/refresh.h"
#include <math.h>
#include <stdint.h>


static const uint32_t shi_color_accelerating = MakeColor(0, 128, 32, 96);
static const uint32_t shi_color_optimal = MakeColor(0, 255, 64, 192);
static const uint32_t shi_color_center_marker = MakeColor(255, 255, 255, 192);

static inline void shi_drawFilledRectangle(const float x, const float y,
                                           const float w, const float h,
                                           const uint32_t color)
{
    R_DrawFill32(roundf(x), roundf(y), roundf(w), roundf(h), color);
}

#endif // STRAFE_HELPER_INCLUDES_H
