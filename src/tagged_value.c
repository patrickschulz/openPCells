#include "tagged_value.h"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "util.h"

struct tagged_value {
    //void* value;
    union {
        int i;
        double d;
        char* str;
    } content;
    enum tag {
        INTEGER,
        NUMBER,
        STRING,
        BOOLEAN
    } tag;
};

struct tagged_value* _create(enum tag tag)
{
    struct tagged_value* value = malloc(sizeof(*value));
    value->tag = tag;
    return value;
}

struct tagged_value* tagged_value_copy(const struct tagged_value* v)
{
    struct tagged_value* value = malloc(sizeof(*value));
    value->tag = v->tag;
    switch(v->tag)
    {
        case INTEGER:
            value->content.i = v->content.i;
            break;
        case NUMBER:
            value->content.d = v->content.d;
            break;
        case STRING:
            value->content.str = util_strdup(v->content.str);
            break;
        case BOOLEAN:
            value->content.i = v->content.i;
            break;
    }
    return value;
}

struct tagged_value* tagged_value_create_integer(int i)
{
    struct tagged_value* value = _create(INTEGER);
    value->content.i = i;
    return value;
}

struct tagged_value* tagged_value_create_number(double d)
{
    struct tagged_value* value = _create(NUMBER);
    value->content.d = d;
    return value;
}

struct tagged_value* tagged_value_create_string(const char* str)
{
    struct tagged_value* value = _create(STRING);
    value->content.str = util_strdup(str);
    return value;
}

struct tagged_value* tagged_value_create_boolean(int b)
{
    struct tagged_value* value = _create(BOOLEAN);
    value->content.i = b;
    return value;
}

void tagged_value_destroy(void* vp)
{
    struct tagged_value* v = vp;
    if(v->tag == STRING)
    {
        free(v->content.str);
    }
    free(vp);
}

void tagged_value_print(const struct tagged_value* v)
{
    switch(v->tag)
    {
        case INTEGER:
            fprintf(stdout, "%d", v->content.i);
            break;
        case NUMBER:
            fprintf(stdout, "%g", v->content.d);
            break;
        case STRING:
            fprintf(stdout, "%s", v->content.str);
            break;
        case BOOLEAN:
            fprintf(stdout, "%s", v->content.i ? "true" : "false");
            break;
    }
}

int tagged_value_is_integer(const struct tagged_value* value)
{
    return value->tag == INTEGER;
}

int tagged_value_is_number(const struct tagged_value* value)
{
    return value->tag == NUMBER;
}

int tagged_value_is_string(const struct tagged_value* value)
{
    return value->tag == STRING;
}

int tagged_value_is_boolean(const struct tagged_value* value)
{
    return value->tag == BOOLEAN;
}

int tagged_value_get_integer(const struct tagged_value* value)
{
    return value->content.i;
}

double tagged_value_get_number(const struct tagged_value* value)
{
    return value->content.d;
}

const char* tagged_value_get_const_string(const struct tagged_value* value)
{
    return value->content.str;
}

char* tagged_value_get_string(struct tagged_value* value)
{
    return value->content.str;
}

int tagged_value_get_boolean(const struct tagged_value* value)
{
    return value->content.i;
}
