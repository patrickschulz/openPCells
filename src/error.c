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

void error_print(error_t* e, const char* pre, const char* post)
{
    fprintf(stderr, "%s%s%s", e->message, pre, post);
}
