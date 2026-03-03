#include <time.h>

#define TIMEPERF_START() clock_t __opc_timeperf_c_start = clock()
#define TIMEPERF_STOP() clock_t __opc_timeperf_c_diff = clock() - __opc_timeperf_c_start

void timeperf_enable(void);
void timeperf_disable(void);
int timeperf_is_enabled(void);
