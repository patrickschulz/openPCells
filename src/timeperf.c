#include "timeperf.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "array.h"

struct timeperf_entry {
    const char* parent;
    const char* funcname;
    unsigned long int numcalls;
    clock_t time;
};

static clock_t c_start;
static int enabled = 0;

//const char** previous_funcnames;
const char* previous_funcname;
static struct timeperf_entry* entries;

void timeperf_initialize(void)
{
    //array_create_in(previous_funcnames, const char*, 32);
    array_create_in(entries, struct timeperf_entry, 32);
}

void timeperf_enable(void)
{
    c_start = clock();
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

static struct timeperf_entry* _get_entry(const char* funcname)
{
    struct timeperf_entry* entry = NULL;
    for(size_t i = 0; i < array_size(entries); ++i)
    {
        if(strcmp(entries[i].funcname, funcname) == 0)
        {
            entry = &entries[i];
            break;
        }
    }
    if(!entry)
    {
        struct timeperf_entry new = {
            .parent = previous_funcname,
            .funcname = funcname,
            .numcalls = 0,
            .time = 0
        };
        array_append(struct timeperf_entry, entries, new);
        entry = &entries[array_size(entries) - 1];
    }
    return entry;
}

void timeperf_start(const char* funcname)
{
    if(enabled)
    {
        struct timeperf_entry* entry = _get_entry(funcname);
        entry->time += -clock();
        previous_funcname = funcname;
        //array_append(const char*, previous_funcnames, funcname);
    }
}

void timeperf_stop(const char* funcname)
{
    if(enabled)
    {
        struct timeperf_entry* entry = _get_entry(funcname);
        entry->time += clock();
        previous_funcname = entry->parent;
        //array_pop(previous_funcnames);
    }
}

static int _cmp_timperf_entry(const void* vlhs, const void* vrhs)
{
    const struct timeperf_entry* lhs = (const struct timeperf_entry*)vlhs;
    const struct timeperf_entry* rhs = (const struct timeperf_entry*)vrhs;
    return lhs->time > rhs->time;
}

void timeperf_print_summary(void)
{
    clock_t c_end = clock();
    double fulltime = (double)(c_end - c_start) / CLOCKS_PER_SEC;
    qsort(entries, array_size(entries), sizeof(struct timeperf_entry), _cmp_timperf_entry);
    printf("total CPU time: %.3f\n", fulltime);
    puts("==================================================================================================================");
    printf("| %-24s | %-24s | %20s | %20s | %10s |\n", "Function", "Parent", "Number of Calls", "Time", "Percentage");
    puts("+--------------------------+--------------------------+----------------------+----------------------+-------------");
    for(size_t i = 0; i < array_size(entries); ++i)
    {
        struct timeperf_entry* entry = entries + i;
        double time = (double)entry->time / CLOCKS_PER_SEC;
        printf("| %-24s | %-24s | %20ld | %20.3f | %10.2f |\n",
            entry->funcname,
            entry->parent ? entry->parent : "<none>",
            entry->numcalls,
            time,
            time / fulltime * 100
        );
    }
    puts("==================================================================================================================");
}
