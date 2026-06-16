#ifndef OPC_ARRAY_H
#define OPC_ARRAY_H

// helper macros for accessing array structure
#define FULL(array) ((void*)((char*)array - 2 * sizeof(size_t)))
#define CAPACITY(array) ((size_t*)((char*)array - 2 * sizeof(size_t)) + 0)
#define SIZE(array) ((size_t*)((char*)array - 2 * sizeof(size_t)) + 1)

#define array_create(name, type, initial_capacity) \
    type* name = (type*)(((char*) malloc(2 * sizeof(size_t) + initial_capacity * sizeof(type))) + 2 * sizeof(size_t)); \
    *CAPACITY(name) = initial_capacity; \
    *SIZE(name) = 0; \
    do {} while(0)

#define array_create_in(name, type, initial_capacity) \
    name = (type*)(((char*) malloc(2 * sizeof(size_t) + initial_capacity * sizeof(type))) + 2 * sizeof(size_t)); \
    *CAPACITY(name) = initial_capacity; \
    *SIZE(name) = 0; \
    do {} while(0)

#define array_append(type, array, value) \
    while(*SIZE(array) + 1 > *CAPACITY(array)) \
    { \
        void* new = realloc(FULL(array), 2 * sizeof(size_t) + 2 * *CAPACITY(array) * sizeof(type)); \
        array = new; \
    } \
    array[*SIZE(array)] = value; \
    ++(*SIZE(array)); \
    do {} while(0)

#define array_remove(array, index) \
    for(size_t i = index + 1; i < *SIZE(array); ++i) \
    { \
        array[i - 1] = array[i]; \
    } \
    --(*SIZE(array)); \
    do {} while(0)

#define array_pop(array) \
    --(*SIZE(array)); \
    do {} while(0)

#define array_size(array) \
    *SIZE(array)

#define array_destroy(array) \
    free(FULL(array)); \
    do {} while(0)

#endif /* OPC_ARRAY_H */
