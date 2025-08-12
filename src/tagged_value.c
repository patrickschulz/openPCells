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
    };
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
            value->i = v->i;
            break;
        case NUMBER:
            value->d = v->d;
            break;
        case STRING:
            value->str = util_strdup(v->str);
            break;
        case BOOLEAN:
            value->i = v->i;
            break;
    }
    return value;
}

struct tagged_value* tagged_value_create_integer(int i)
{
    struct tagged_value* value = _create(INTEGER);
    value->i = i;
    return value;
}

struct tagged_value* tagged_value_create_number(double d)
{
    struct tagged_value* value = _create(NUMBER);
    value->d = d;
    return value;
}

struct tagged_value* tagged_value_create_string(const char* str)
{
    struct tagged_value* value = _create(STRING);
    value->str = util_strdup(str);
    return value;
}

struct tagged_value* tagged_value_create_boolean(int b)
{
    struct tagged_value* value = _create(BOOLEAN);
    value->i = b;
    return value;
}

void tagged_value_destroy(void* vp)
{
    struct tagged_value* v = vp;
    if(v->tag == STRING)
    {
        free(v->str);
    }
    free(vp);
}

void tagged_value_print(const struct tagged_value* v)
{
    switch(v->tag)
    {
        case INTEGER:
            printf("%d", v->i);
            break;
        case NUMBER:
            printf("%g", v->d);
            break;
        case STRING:
            printf("%s", v->str);
            break;
        case BOOLEAN:
            printf("%s", v->i ? "true" : "false");
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
    return value->i;
}

double tagged_value_get_number(const struct tagged_value* value)
{
    return value->d;
}

const char* tagged_value_get_const_string(const struct tagged_value* value)
{
    return value->str;
}

char* tagged_value_get_string(struct tagged_value* value)
{
    return value->str;
}

int tagged_value_get_boolean(const struct tagged_value* value)
{
    return value->i;
}
