#include "tagged_value.h"

#include <stdlib.h>
#include <string.h>

struct tagged_value {
    //void* value;
    union {
        int i;
        char* str;
    };
    enum tag {
        INTEGER,
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

struct tagged_value* tagged_value_create_integer(int i)
{
    struct tagged_value* value = _create(INTEGER);
    value->i = i;
    return value;
}

struct tagged_value* tagged_value_create_string(const char* str)
{
    struct tagged_value* value = _create(STRING);
    value->str = strdup(str);
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

int tagged_value_is_integer(const struct tagged_value* value)
{
    return value->tag == INTEGER;
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
