#include "keyvaluepairs.h"

#include <stdlib.h>
#include <string.h>

struct keyvaluearray* keyvaluearray_create(void)
{
    struct keyvaluearray* array = malloc(sizeof(*array));
    array->pairs = vector_create();
    return array;
}

void _destroy_pair(void* ptr)
{
    struct keyvaluepair* pair = ptr;
    free(pair->key);
    if(pair->tag != UNTAGGED) // untagged values are not memory-managed by the array
    {
        free(pair->value);
    }
    free(pair);
}

void keyvaluearray_destroy(struct keyvaluearray* array)
{
    vector_destroy(array->pairs, _destroy_pair);
    free(array);
}

static struct keyvaluepair* _create_pair(const char* key, enum tag_t tag)
{
    struct keyvaluepair* pair = malloc(sizeof(*pair));
    pair->key = malloc(strlen(key) + 1);
    strcpy(pair->key, key);
    pair->tag = tag;
    return pair;
}

void keyvaluearray_add_int(struct keyvaluearray* array, const char* key, int value)
{
    struct keyvaluepair* pair = _create_pair(key, INT);
    pair->value = malloc(sizeof(int));
    *((int*)pair->value) = value;
    vector_append(array->pairs, pair);
}

void keyvaluearray_add_boolean(struct keyvaluearray* array, const char* key, int value)
{
    struct keyvaluepair* pair = _create_pair(key, BOOLEAN);
    pair->value = malloc(sizeof(int));
    *((int*)pair->value) = value ? 1 : 0;
    vector_append(array->pairs, pair);
}

void keyvaluearray_add_string(struct keyvaluearray* array, const char* key, const char* value)
{
    struct keyvaluepair* pair = _create_pair(key, STRING);
    pair->value = malloc(strlen(value) + 1);
    strcpy(pair->value, value);
    vector_append(array->pairs, pair);
}

void keyvaluearray_add_untagged(struct keyvaluearray* array, const char* key, void* value)
{
    struct keyvaluepair* pair = _create_pair(key, UNTAGGED);
    pair->value = value;
    vector_append(array->pairs, pair);
}

size_t keyvaluearray_size(const struct keyvaluearray* array)
{
    return vector_size(array->pairs);
}

struct keyvaluepair* keyvaluearray_get_indexed_pair(const struct keyvaluearray* array, size_t idx)
{
    return vector_get(array->pairs, idx);
}

void* keyvaluearray_get(const struct keyvaluearray* array, const char* key)
{
    for(unsigned int i = 0; i < vector_size(array->pairs); ++i)
    {
        struct keyvaluepair* pair = vector_get(array->pairs, i);
        if(strcmp(key, pair->key) == 0)
        {
            return pair->value;
        }
    }
    return NULL;
}

int keyvaluearray_get_int(const struct keyvaluearray* array, const char* key, int* value)
{
    for(unsigned int i = 0; i < vector_size(array->pairs); ++i)
    {
        struct keyvaluepair* pair = vector_get(array->pairs, i);
        if(strcmp(key, pair->key) == 0)
        {
            if(pair->tag == INT)
            {
                *value = *((int*)pair->value);
                return 1;
            }
        }
    }
    return 0;
}

