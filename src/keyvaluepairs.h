#ifndef OPC_KEYVALUEPAIRS_H
#define OPC_KEYVALUEPAIRS_H

#include <stddef.h>

#include "vector.h"

struct keyvaluepair
{
    char* key;
    void* value;
    enum tag_t
    {
        INT, BOOLEAN, STRING, UNTAGGED
    } tag;
};

struct keyvaluearray
{
    struct vector* pairs;
};

struct keyvaluearray* keyvaluearray_create(void);
void keyvaluearray_destroy(struct keyvaluearray*);

void keyvaluearray_add_int(struct keyvaluearray*, const char* key, int value);
void keyvaluearray_add_boolean(struct keyvaluearray*, const char* key, int value);
void keyvaluearray_add_string(struct keyvaluearray*, const char* key, const char* value);
void keyvaluearray_add_untagged(struct keyvaluearray*, const char* key, void* value);

size_t keyvaluearray_size(const struct keyvaluearray* array);

const struct keyvaluepair* keyvaluearray_get_indexed_pair(const struct keyvaluearray*, size_t idx);
void* keyvaluearray_get(const struct keyvaluearray*, const char* key);
int keyvaluearray_get_int(const struct keyvaluearray*, const char* key, int* value);

#endif /* OPC_KEYVALUEPAIRS_H */
