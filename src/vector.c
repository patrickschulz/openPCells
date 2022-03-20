#include "vector.h"

#include <stdlib.h>

static void _resize_data(struct vector* vector, size_t capacity)
{
    vector->capacity = capacity;
    void* e = realloc(vector->elements, sizeof(void*) * vector->capacity);
    vector->elements = e;
}

struct vector* vector_create(void)
{
    struct vector* vector = malloc(sizeof(*vector));
    vector->elements = NULL;
    vector->length = 0;
    _resize_data(vector, 1024);
    return vector;
}

void vector_destroy(struct vector* vector)
{
    // non-owned data, only detroy vector structure
    free(vector->elements);
    free(vector);
}

size_t vector_size(struct vector* vector)
{
    return vector->length;
}

void* vector_get(struct vector* vector, size_t i)
{
    return vector->elements[i];
}

void vector_set(struct vector* vector, size_t i, void* element)
{
    vector->elements[i] = element;
}

void vector_append(struct vector* vector, void* element)
{
    while(vector->length + 1 > vector->capacity)
    {
        _resize_data(vector, vector->capacity * 2);
    }
    vector->elements[vector->length] = element;
    vector->length += 1;
}

void vector_remove(struct vector* vector, size_t index, void (*destructor)(void*))
{
    if(destructor)
    {
        destructor(vector->elements[index]);
    }
    for(size_t i = index + 1; i < vector->length; ++i)
    {
        vector->elements[i - 1] = vector->elements[i];
    }
    --vector->length;
}
