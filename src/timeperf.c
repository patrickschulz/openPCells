#include "timeperf.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "array.h"
#include "helpers.h"

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

static void _print_character(size_t len, char ch)
{
    for(size_t i = 0; i < len; ++i)
    {
        putchar(ch);
    }
}

static void _print_top_bottom_line(size_t funcname_len, size_t parent_len, size_t numcalls_len, size_t time_len, size_t percentage_len)
{
    // +2 for all lengths because of the spacing
    _print_character(funcname_len + 2, '=');
    _print_character(parent_len + 2, '=');
    _print_character(numcalls_len + 2, '=');
    _print_character(time_len + 2, '=');
    _print_character(percentage_len + 2, '=');
    _print_character(6, '='); // 6x '|'
    putchar('\n');
}

void timeperf_print_summary(void)
{
    // iterate first to get print sizes
    // default values are minimum values from the header
    size_t funcname_len = 7; // "Function"
    size_t parent_len = 6; // "Parent"
    size_t numcalls_len = 15; // I could determine this dynamically, but I'm currently too lazy and this will last for a long time
    size_t time_len = 8;
    size_t percentage_len = 10;
    for(size_t i = 0; i < array_size(entries); ++i)
    {
        struct timeperf_entry* entry = entries + i;
        funcname_len = MAX2(funcname_len, strlen(entry->funcname));
        parent_len = MAX2(parent_len, strlen(entry->parent ? entry->parent : "<none>"));
    }

    // get time
    clock_t c_end = clock();
    double fulltime = (double)(c_end - c_start) / CLOCKS_PER_SEC;

    // sort entries
    qsort(entries, array_size(entries), sizeof(struct timeperf_entry), _cmp_timperf_entry);

    // info
    printf("total CPU time: %.3f\n", fulltime);

    // print first table line
    _print_top_bottom_line(funcname_len, parent_len, numcalls_len, time_len, percentage_len);

    // print header
    printf("| %-*s | %-*s | %*s | %*s | %*s |\n",
        (int)funcname_len, "Function",
        (int)parent_len, "Parent",
        (int)numcalls_len, "Number of Calls",
        (int)time_len, "Time (s)",
        (int)percentage_len, "Percentage"
    );

    // print separator
    putchar('+');
    _print_character(funcname_len + 2, '-');
    putchar('+');
    _print_character(parent_len + 2, '-');
    putchar('+');
    _print_character(numcalls_len + 2, '-');
    putchar('+');
    _print_character(time_len + 2, '-');
    putchar('+');
    _print_character(percentage_len + 2, '-');
    putchar('+');
    putchar('\n');

    // print entries
    for(size_t i = 0; i < array_size(entries); ++i)
    {
        struct timeperf_entry* entry = entries + i;
        double time = (double)entry->time / CLOCKS_PER_SEC;
        printf("| %-*s | %-*s | %*ld | %*.3f | %*.2f |\n",
            (int)funcname_len, entry->funcname,
            (int)parent_len, entry->parent ? entry->parent : "<none>",
            (int)numcalls_len, entry->numcalls,
            (int)time_len, time,
            (int)percentage_len, time / fulltime * 100
        );
    }

    // print last table line
    _print_top_bottom_line(funcname_len, parent_len, numcalls_len, time_len, percentage_len);
}
