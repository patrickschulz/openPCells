#include "cpu.h"

#include <unistd.h>

unsigned int cpu_get_num_cpus()
{
    return (unsigned int)sysconf(_SC_NPROCESSORS_CONF);
}

