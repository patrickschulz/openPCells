#include <time.h>

#define TIMEPERF_START() timeperf_start(__func__)
#define TIMEPERF_STOP() timeperf_stop(__func__)

void timeperf_initialize(void);
void timeperf_enable(void);
void timeperf_disable(void);
int timeperf_is_enabled(void);
void timeperf_start(const char* funcname);
void timeperf_stop(const char* funcname);
void timeperf_print_summary(void);
