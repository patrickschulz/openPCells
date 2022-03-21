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
void vector_remove(struct vector* vector, size_t index, void (*destructor)(void*));

#endif // OPC_LVECTOR_H
