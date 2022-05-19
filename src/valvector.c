#include "valvector.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

/*
 * Memory layout:
 * 
 *  | element_size | capacity | size | data.... |
 */
#define VECTOR_ELEMENT_SIZE_OFFSET 0
#define VECTOR_CAPACITY_OFFSET 1
#define VECTOR_SIZE_OFFSET 2
#define VECTOR_BOOKKEEPING_SIZE 3
void* valvector_create(size_t elem_size);
{
    size_t capacity = 0;
    void* data = malloc(VECTOR_BOOKKEEPING_SIZE * sizeof(size_t) + capacity * elem_size);
    memset(data, 0, VECTOR_BOOKKEEPING_SIZE * sizeof(size_t));
    size_t* elem_size_ptr = data + VECTOR_ELEMENT_SIZE_OFFSET * sizeof(size_t);
    *elem_size_ptr = elem_size;
    size_t* capacity_ptr = data + VECTOR_CAPACITY_OFFSET * sizeof(size_t);
    *capacity_ptr = capacity;
    size_t* size_ptr = data + VECTOR_SIZE_OFFSET * sizeof(size_t);
    *size_ptr = 0;
    return data + VECTOR_BOOKKEEPING_SIZE * sizeof(size_t);
}

void valvector_destroy(void* vp)
{
    void* data = *(void**)vp;
    void* v = data - VECTOR_BOOKKEEPING_SIZE * sizeof(size_t);
    free(v);
}

void valvector_append(void* vp, void* e)
{
    void* data = *(void**)vp;
    size_t* elem_size_ptr = data + (-VECTOR_BOOKKEEPING_SIZE + VECTOR_ELEMENT_SIZE_OFFSET) * sizeof(size_t);
    size_t elem_size = *elem_size_ptr;
    size_t* capacity_ptr = data + (-VECTOR_BOOKKEEPING_SIZE + VECTOR_CAPACITY_OFFSET) * sizeof(size_t);
    size_t* size_ptr = data + (-VECTOR_BOOKKEEPING_SIZE + VECTOR_SIZE_OFFSET) * sizeof(size_t);
    if(*size_ptr == *capacity_ptr)
    {
        size_t capacity = *capacity_ptr > 0 ? (2 * *capacity_ptr) : 1;
        void* v = data - VECTOR_BOOKKEEPING_SIZE * sizeof(size_t);
        void* new = realloc(v, VECTOR_BOOKKEEPING_SIZE * sizeof(size_t) + capacity * elem_size);
        (*(void**)vp) = new + VECTOR_BOOKKEEPING_SIZE * sizeof(size_t);
        data = *(void**)vp;
        size_ptr = new + VECTOR_SIZE_OFFSET * sizeof(size_t);
        capacity_ptr = new + VECTOR_CAPACITY_OFFSET * sizeof(size_t);
        *capacity_ptr = capacity;
    }
    memcpy(data + *size_ptr * elem_size, e, elem_size);
    (*size_ptr)++;
}

size_t valvector_size(void* vp)
{
    void* data = *(void**)vp;
    size_t* size_ptr = data + (-VECTOR_BOOKKEEPING_SIZE + VECTOR_SIZE_OFFSET) * sizeof(size_t);
    return *size_ptr;
}

