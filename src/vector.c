#include "vector.h"

#include <stdlib.h>
#include <string.h>

struct vector {
    void** elements;
    size_t size;
    size_t capacity;
    void (*destructor)(void*);
};

static void _resize_data(struct vector* vector, size_t capacity)
{
    vector->capacity = capacity;
    void* e = realloc(vector->elements, sizeof(void*) * vector->capacity);
    vector->elements = e;
}

struct vector* vector_create(size_t capacity, void (*destructor)(void*))
{
    struct vector* vector = malloc(sizeof(*vector));
    vector->elements = NULL;
    vector->size = 0;
    vector->capacity = capacity;
    if(capacity > 0)
    {
        _resize_data(vector, capacity);
    }
    vector->destructor = destructor;
    return vector;
}

struct vector* vector_adapt_from_pointer_array(void** ptrarray)
{
    struct vector* vector = vector_create(8, NULL);
    void** ptr = ptrarray;
    while(*ptr)
    {
        vector_append(vector, *ptr);
        ++ptr;
    }
    return vector;
}

void vector_destroy(void* v)
{
    struct vector* vector = v;
    if(vector->destructor)
    {
        for(size_t i = 0; i < vector->size; ++i)
        {
            vector->destructor(vector->elements[i]);
        }
    }
    // non-owned data, only destroy vector structure
    free(vector->elements);
    free(vector);
}

struct vector* vector_copy(struct vector* vector, void* (*copy)(const void*))
{
    struct vector* new = vector_create(vector->capacity, vector->destructor);
    for(size_t i = 0; i < vector->size; ++i)
    {
        new->elements[i] = copy(vector->elements[i]);
    }
    new->size = vector->size;
    return new;
}

void vector_reserve(struct vector* vector, size_t capacity)
{
    if(vector->capacity < capacity)
    {
        _resize_data(vector, capacity);
    }
}

size_t vector_size(const struct vector* vector)
{
    return vector->size;
}

size_t vector_capacity(const struct vector* vector)
{
    return vector->capacity;
}

int vector_empty(const struct vector* vector)
{
    return vector->size == 0;
}

void* vector_get(struct vector* vector, size_t i)
{
    return vector->elements[i];
}

const void* vector_get_const(const struct vector* vector, size_t i)
{
    return vector->elements[i];
}

void* vector_get_reference(struct vector* vector, size_t i)
{
    return &vector->elements[i];
}

void* vector_content(struct vector* vector)
{
    return vector->elements;
}

void* vector_disown_content(struct vector* vector)
{
    void* content = vector->elements;
    free(vector);
    return content;
}

void* vector_disown_element(struct vector* vector, size_t index)
{
    void* element = vector->elements[index];
    for(size_t i = index + 1; i < vector->size; ++i)
    {
        vector->elements[i - 1] = vector->elements[i];
    }
    --vector->size;
    return element;
}

void vector_set(struct vector* vector, size_t i, void* element)
{
    vector->elements[i] = element;
}

void vector_append(struct vector* vector, void* element)
{
    while(vector->size + 1 > vector->capacity)
    {
        _resize_data(vector, vector->capacity ? vector->capacity * 2 : 1);
    }
    vector->elements[vector->size] = element;
    vector->size += 1;
}

void vector_prepend(struct vector* vector, void* element)
{
    while(vector->size + 1 > vector->capacity)
    {
        _resize_data(vector, vector->capacity ? vector->capacity * 2 : 1);
    }
    memmove(vector->elements + 1, vector->elements, sizeof(void*) * vector->size);
    vector->elements[0] = element;
    vector->size += 1;
}

void vector_remove(struct vector* vector, size_t index)
{
    if(vector->destructor)
    {
        vector->destructor(vector->elements[index]);
    }
    for(size_t i = index + 1; i < vector->size; ++i)
    {
        vector->elements[i - 1] = vector->elements[i];
    }
    --vector->size;
}

struct vector_iterator
{
    struct vector* vector;
    size_t index;
};

struct vector_iterator* vector_iterator_create(struct vector* vector)
{
    struct vector_iterator* it = malloc(sizeof(*it));
    it->vector = vector;
    it->index = 0;
    return it;
}

int vector_iterator_is_valid(struct vector_iterator* iterator)
{
    return iterator->index < iterator->vector->size;
}

void* vector_iterator_get(struct vector_iterator* iterator)
{
    return vector_get(iterator->vector, iterator->index);
}

void vector_iterator_next(struct vector_iterator* iterator)
{
    iterator->index += 1;
}

void vector_iterator_destroy(struct vector_iterator* iterator)
{
    free(iterator);
}

struct vector_const_iterator
{
    const struct vector* vector;
    size_t index;
};

struct vector_const_iterator* vector_const_iterator_create(const struct vector* vector)
{
    struct vector_const_iterator* it = malloc(sizeof(*it));
    it->vector = vector;
    it->index = 0;
    return it;
}

int vector_const_iterator_is_valid(struct vector_const_iterator* iterator)
{
    return iterator->index < iterator->vector->size;
}

const void* vector_const_iterator_get(struct vector_const_iterator* iterator)
{
    return vector_get_const(iterator->vector, iterator->index);
}

void vector_const_iterator_next(struct vector_const_iterator* iterator)
{
    iterator->index += 1;
}

void vector_const_iterator_destroy(struct vector_const_iterator* iterator)
{
    free(iterator);
}

void vector_sort(struct vector* vector, int (*cmp_func)(const void* left, const void* right))
{
    qsort(vector->elements, vector->size, sizeof(void*), cmp_func);
}

void vector_swap(struct vector* vector, size_t idx1, size_t idx2)
{
    void* tmp = vector->elements[idx1];
    vector->elements[idx1] = vector->elements[idx2];
    vector->elements[idx2] = tmp;
}

void vector_reverse(struct vector* vector)
{
    for(size_t i = 0; i < vector->size / 2; ++i)
    {
        vector_swap(vector, i, vector->size - 1 - i);
    }
}

int vector_find_flat(const struct vector* vector, const void* p)
{
    int index = -1;
    for(size_t i = 0; i < vector->size; ++i)
    {
        const void* e = vector->elements[i];
        if(e == p)
        {
            index = i;
            break;
        }
    }
    return index;
}

struct const_vector {
    const void** elements;
    size_t size;
    size_t capacity;
};

static void _const_resize_data(struct const_vector* const_vector, size_t capacity)
{
    const_vector->capacity = capacity;
    void* e = realloc(const_vector->elements, sizeof(void*) * const_vector->capacity);
    const_vector->elements = e;
}

struct const_vector* const_vector_create(size_t capacity)
{
    struct const_vector* const_vector = malloc(sizeof(*const_vector));
    const_vector->elements = NULL;
    const_vector->size = 0;
    _const_resize_data(const_vector, capacity);
    return const_vector;
}

void const_vector_destroy(void* v)
{
    struct const_vector* const_vector = v;
    free(const_vector->elements);
    free(const_vector);
}

size_t const_vector_size(const struct const_vector* const_vector)
{
    return const_vector->size;
}

const void* const_vector_get(const struct const_vector* const_vector, size_t i)
{
    return const_vector->elements[i];
}

void const_vector_set(struct const_vector* const_vector, size_t i, const void* element)
{
    const_vector->elements[i] = element;
}

void const_vector_append(struct const_vector* const_vector, const void* element)
{
    while(const_vector->size + 1 > const_vector->capacity)
    {
        _const_resize_data(const_vector, const_vector->capacity ? const_vector->capacity * 2 : 1);
    }
    const_vector->elements[const_vector->size] = element;
    const_vector->size += 1;
}

void const_vector_prepend(struct const_vector* const_vector, const void* element)
{
    while(const_vector->size + 1 > const_vector->capacity)
    {
        _const_resize_data(const_vector, const_vector->capacity ? const_vector->capacity * 2 : 1);
    }
    memmove(const_vector->elements + 1, const_vector->elements, sizeof(void*) * const_vector->size);
    const_vector->elements[0] = element;
    const_vector->size += 1;
}

void const_vector_remove(struct const_vector* const_vector, size_t index)
{
    for(size_t i = index + 1; i < const_vector->size; ++i)
    {
        const_vector->elements[i - 1] = const_vector->elements[i];
    }
    --const_vector->size;
}

int const_vector_find_flat(const struct const_vector* vector, const void* p)
{
    int index = -1;
    for(size_t i = 0; i < vector->size; ++i)
    {
        const void* e = vector->elements[i];
        if(e == p)
        {
            index = i;
            break;
        }
    }
    return index;
}

struct const_vector_iterator
{
    const struct const_vector* vector;
    size_t index;
};

struct const_vector_iterator* const_vector_iterator_create(const struct const_vector* vector)
{
    struct const_vector_iterator* it = malloc(sizeof(*it));
    it->vector = vector;
    it->index = 0;
    return it;
}

int const_vector_iterator_is_valid(struct const_vector_iterator* iterator)
{
    return iterator->index < iterator->vector->size;
}

const void* const_vector_iterator_get(struct const_vector_iterator* iterator)
{
    return const_vector_get(iterator->vector, iterator->index);
}

void const_vector_iterator_next(struct const_vector_iterator* iterator)
{
    iterator->index += 1;
}

void const_vector_iterator_destroy(struct const_vector_iterator* iterator)
{
    free(iterator);
}

