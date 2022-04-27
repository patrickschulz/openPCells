#ifndef OPC_LVECTOR_H
#define OPC_LVECTOR_H

#include <stddef.h>

struct vector
{
    void** elements;
    size_t length;
    size_t capacity;
};

struct vector* vector_create(void);
void vector_destroy(struct vector* vector, void (*desctructor)(void*));
size_t vector_size(struct vector* vector);
void* vector_get(struct vector* vector, size_t i);
void vector_set(struct vector* vector, size_t i, void* element);
void vector_append(struct vector* vector, void* element);
void vector_prepend(struct vector* vector, void* element);
void vector_remove(struct vector* vector, size_t index, void (*destructor)(void*));

struct vector_iterator;
struct vector_iterator* vector_iterator_create(struct vector* vector);
int vector_iterator_is_valid(struct vector_iterator* iterator);
void* vector_iterator_get(struct vector_iterator* iterator);
void vector_iterator_next(struct vector_iterator* iterator);
void vector_iterator_destroy(struct vector_iterator* iterator);

struct const_vector
{
    const void** elements;
    size_t length;
    size_t capacity;
};

struct const_vector* const_vector_create(void);
void const_vector_destroy(struct const_vector* const_vector);
size_t const_vector_size(struct const_vector* const_vector);
const void* const_vector_get(struct const_vector* const_vector, size_t i);
void const_vector_set(struct const_vector* const_vector, size_t i, const void* element);
void const_vector_append(struct const_vector* const_vector, const void* element);
void const_vector_prepend(struct const_vector* const_vector, const void* element);
void const_vector_remove(struct const_vector* const_vector, size_t index);

#endif // OPC_LVECTOR_H
