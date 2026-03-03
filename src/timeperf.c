#include "timeperf.h"

static int enabled = 0;

void timeperf_enable(void)
{
    enabled = 1;
}

void timeperf_disable(void)
{
    enabled = 0;
}

int timeperf_is_enabled(void)
{
    return enabled;
}

