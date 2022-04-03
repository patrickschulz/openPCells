#include "vector.h"

#include <stdlib.h>
#include <string.h>

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

void vector_destroy(struct vector* vector, void (*destructor)(void*))
{
    if(destructor)
    {
        for(size_t i = 0; i < vector->length; ++i)
        {
            destructor(vector->elements[i]);
        }
    }
    // non-owned data, only destroy vector structure
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

void vector_prepend(struct vector* vector, void* element)
{
    while(vector->length + 1 > vector->capacity)
    {
        _resize_data(vector, vector->capacity * 2);
    }
    memmove(vector->elements + 1, vector->elements, vector->length);
    vector->elements[0] = element;
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

static void _const_resize_data(struct const_vector* const_vector, size_t capacity)
{
    const_vector->capacity = capacity;
    void* e = realloc(const_vector->elements, sizeof(void*) * const_vector->capacity);
    const_vector->elements = e;
}

struct const_vector* const_vector_create(void)
{
    struct const_vector* const_vector = malloc(sizeof(*const_vector));
    const_vector->elements = NULL;
    const_vector->length = 0;
    _const_resize_data(const_vector, 1024);
    return const_vector;
}

void const_vector_destroy(struct const_vector* const_vector)
{
    free(const_vector->elements);
    free(const_vector);
}

size_t const_vector_size(struct const_vector* const_vector)
{
    return const_vector->length;
}

const void* const_vector_get(struct const_vector* const_vector, size_t i)
{
    return const_vector->elements[i];
}

void const_vector_set(struct const_vector* const_vector, size_t i, const void* element)
{
    const_vector->elements[i] = element;
}

void const_vector_append(struct const_vector* const_vector, const void* element)
{
    while(const_vector->length + 1 > const_vector->capacity)
    {
        _const_resize_data(const_vector, const_vector->capacity * 2);
    }
    const_vector->elements[const_vector->length] = element;
    const_vector->length += 1;
}

void const_vector_prepend(struct const_vector* const_vector, const void* element)
{
    while(const_vector->length + 1 > const_vector->capacity)
    {
        _const_resize_data(const_vector, const_vector->capacity * 2);
    }
    memmove(const_vector->elements + 1, const_vector->elements, const_vector->length);
    const_vector->elements[0] = element;
    const_vector->length += 1;
}

void const_vector_remove(struct const_vector* const_vector, size_t index)
{
    for(size_t i = index + 1; i < const_vector->length; ++i)
    {
        const_vector->elements[i - 1] = const_vector->elements[i];
    }
    --const_vector->length;
}
