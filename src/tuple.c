#include "tuple.h"

#include <stdlib.h>

struct tuple2* tuple2_create(
    void* first,
    void (*first_destructor)(void* v),
    void* second,
    void (*second_destructor)(void* v)
)
{
    struct tuple2* tuple = malloc(sizeof(*tuple));
    tuple->first = first;
    tuple->first_destructor = first_destructor;
    tuple->second = second;
    tuple->second_destructor = second_destructor;
    return tuple;
}

void tuple2_destroy(void* v)
{
    struct tuple2* tuple = v;
    if(tuple->first_destructor)
    {
        tuple->first_destructor(tuple->first);
    }
    if(tuple->second_destructor)
    {
        tuple->second_destructor(tuple->second);
    }
    free(tuple);
}
