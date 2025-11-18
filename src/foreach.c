#include "foreach.h"

#include <assert.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>

static struct generic_arg* _get_arg(struct generic_arg* args, size_t index)
{
    struct generic_arg* ptr = args;
    size_t size = 0;
    while(ptr->type != ARG_END)
    {
        ++size;
        ++ptr;
    }
    assert(index > 0 && index <= size);
    return args + index - 1;
}

int args_get_int(struct generic_arg* args, size_t index)
{
    struct generic_arg* arg = _get_arg(args, index);
    assert(arg->type == ARG_INT);
    return arg->content.i;
}

double args_get_double(struct generic_arg* args, size_t index)
{
    struct generic_arg* arg = _get_arg(args, index);
    assert(arg->type == ARG_DOUBLE);
    return arg->content.d;
}

char args_get_char(struct generic_arg* args, size_t index)
{
    struct generic_arg* arg = _get_arg(args, index);
    assert(arg->type == ARG_CHAR);
    return arg->content.ch;
}

const char* args_get_string(struct generic_arg* args, size_t index)
{
    struct generic_arg* arg = _get_arg(args, index);
    assert(arg->type == ARG_STRING);
    return arg->content.str;
}

void* args_get_pointer(struct generic_arg* args, size_t index)
{
    struct generic_arg* arg = _get_arg(args, index);
    assert(arg->type == ARG_POINTER);
    return arg->content.ptr;
}

const void* args_get_const_pointer(struct generic_arg* args, size_t index)
{
    struct generic_arg* arg = _get_arg(args, index);
    assert(arg->type == ARG_CONST_POINTER);
    return arg->content.cptr;
}
