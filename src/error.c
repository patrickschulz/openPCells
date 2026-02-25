#include "error.h"

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>

#include "strprint.h"

void error_clean(error_t* e)
{
    free(e->message);
}

error_t error_fail(void)
{
    error_t e = { .status = 0, .message = NULL };
    return e;
}

error_t error_success(void)
{
    error_t e = { .status = 1, .message = NULL };
    return e;
}

void error_set_failure(error_t* e)
{
    e->status = 0;
}

int error_is_success(error_t* e)
{
    return e->status != 0;
}

int error_is_failure(error_t* e)
{
    return e->status == 0;
}

void error_prepend(error_t* e , const char* message)
{
    const char* old = e->message ? e->message : "";
    char* new = strprintf("%s%s", message, old);
    free(e->message);
    e->message = new;
}

void error_add(error_t* e , const char* message)
{
    const char* old = e->message ? e->message : "";
    char* new = strprintf("%s%s", old, message);
    free(e->message);
    e->message = new;
}

void error_printf(error_t* e, const char* fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    char* str = strprintfv(fmt, args);
    va_end(args);
    fputs(str, stderr);
    fputs(e->message, stderr);
    fputc('\n', stderr);
    free(str);
}
