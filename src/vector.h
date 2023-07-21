#ifndef OPC_VECTOR_H
#define OPC_VECTOR_H

#include <stddef.h>

struct vector;
struct vector* vector_create(size_t capacity, void (*destructor)(void*));
void vector_destroy(void* vector);
struct vector* vector_copy(struct vector* vector, void* (*copy)(const void*));
void vector_reserve(struct vector* vector, size_t additional_capacity);
size_t vector_size(const struct vector* vector);
size_t vector_capacity(const struct vector* vector);
int vector_empty(const struct vector* vector);
void* vector_get(struct vector* vector, size_t i);
const void* vector_get_const(const struct vector* vector, size_t i);
void* vector_get_reference(struct vector* vector, size_t i);
void* vector_content(struct vector* vector);
void* vector_disown_content(struct vector* vector);
void* vector_disown_element(struct vector* vector, size_t index);
void vector_set(struct vector* vector, size_t i, void* element);
void vector_append(struct vector* vector, void* element);
void vector_swap(struct vector* vector, size_t i, size_t j);
void vector_prepend(struct vector* vector, void* element);
void vector_remove(struct vector* vector, size_t index);
void vector_sort(struct vector* vector, int (*cmp_func)(const void*, const void*));
void vector_swap(struct vector* vector, size_t idx1, size_t idx2);
void vector_reverse(struct vector* vector);
int vector_find_flat(const struct vector* vector, const void* p);

struct vector_iterator;
struct vector_iterator* vector_iterator_create(struct vector* vector);
int vector_iterator_is_valid(struct vector_iterator* iterator);
void* vector_iterator_get(struct vector_iterator* iterator);
void vector_iterator_next(struct vector_iterator* iterator);
void vector_iterator_destroy(struct vector_iterator* iterator);

struct vector_const_iterator;
struct vector_const_iterator* vector_const_iterator_create(const struct vector* vector);
int vector_const_iterator_is_valid(struct vector_const_iterator* iterator);
const void* vector_const_iterator_get(struct vector_const_iterator* iterator);
void vector_const_iterator_next(struct vector_const_iterator* iterator);
void vector_const_iterator_destroy(struct vector_const_iterator* iterator);

struct const_vector;
struct const_vector* const_vector_create(size_t capacity);
void const_vector_destroy(void* const_vector);
size_t const_vector_size(const struct const_vector* const_vector);
const void* const_vector_get(const struct const_vector* const_vector, size_t i);
void const_vector_set(struct const_vector* const_vector, size_t i, const void* element);
void const_vector_append(struct const_vector* const_vector, const void* element);
void const_vector_prepend(struct const_vector* const_vector, const void* element);
void const_vector_remove(struct const_vector* const_vector, size_t index);
int const_vector_find_flat(const struct const_vector* vector, const void* p);

struct const_vector_iterator;
struct const_vector_iterator* const_vector_iterator_create(const struct const_vector* vector);
int const_vector_iterator_is_valid(struct const_vector_iterator* iterator);
const void* const_vector_iterator_get(struct const_vector_iterator* iterator);
void const_vector_iterator_next(struct const_vector_iterator* iterator);
void const_vector_iterator_destroy(struct const_vector_iterator* iterator);

#endif // OPC_VECTOR_H
