#include "keyvaluepairs.h"

#include <stdlib.h>
#include <string.h>

struct keyvaluearray* keyvaluearray_create(void)
{
    struct keyvaluearray* array = malloc(sizeof(*array));
    array->size = 0;
    array->capacity = 1;
    array->pairs = calloc(array->capacity, sizeof(*array->pairs));
    return array;
}

void keyvaluearray_destroy(struct keyvaluearray* array)
{
    for(unsigned int i = 0; i < array->size; ++i)
    {
        free(array->pairs[i]->key);
        free(array->pairs[i]->value);
        free(array->pairs[i]);
    }
    free(array->pairs);
    free(array);
}

static void _prepare_add(struct keyvaluearray* array, const char* key, enum tag_t tag)
{
    if(array->size == array->capacity)
    {
        array->capacity = (array->capacity * 2) > (array->size + 1) ? (array->capacity * 2) : (array->size + 1);
        struct keyvaluepair** pairs = realloc(array->pairs, array->capacity * sizeof(*array->pairs));
        array->pairs = pairs;
    }
    array->size += 1;
    array->pairs[array->size - 1] = malloc(sizeof(**array->pairs));
    array->pairs[array->size - 1]->key = malloc(strlen(key) + 1);
    strcpy(array->pairs[array->size - 1]->key, key);
    array->pairs[array->size - 1]->tag = tag;
}

void keyvaluearray_add_int(struct keyvaluearray* array, const char* key, int value)
{
    _prepare_add(array, key, INT);
    array->pairs[array->size - 1]->value = malloc(sizeof(int));
    *((int*)array->pairs[array->size - 1]->value) = value;
}

void keyvaluearray_add_boolean(struct keyvaluearray* array, const char* key, int value)
{
    _prepare_add(array, key, BOOLEAN);
    array->pairs[array->size - 1]->value = malloc(sizeof(int));
    *((int*)array->pairs[array->size - 1]->value) = value ? 1 : 0;
}

void keyvaluearray_add_string(struct keyvaluearray* array, const char* key, const char* value)
{
    _prepare_add(array, key, STRING);
    array->pairs[array->size - 1]->value = malloc(strlen(value) + 1);
    strcpy(array->pairs[array->size - 1]->value, value);
}

