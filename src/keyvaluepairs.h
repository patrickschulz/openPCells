#ifndef OPC_KEYVALUEPAIRS_H
#define OPC_KEYVALUEPAIRS_H

#include <stddef.h>

struct keyvaluepair
{
    char* key;
    void* value;
    enum tag_t
    {
        INT, BOOLEAN, STRING
    } tag;
};

struct keyvaluearray
{
    struct keyvaluepair** pairs;
    size_t size;
    size_t capacity;
};

struct keyvaluearray* keyvaluearray_create(void);
void keyvaluearray_destroy(struct keyvaluearray*);

void keyvaluearray_add_int(struct keyvaluearray*, const char* key, int value);
void keyvaluearray_add_boolean(struct keyvaluearray*, const char* key, int value);
void keyvaluearray_add_string(struct keyvaluearray*, const char* key, const char* value);

#endif /* OPC_KEYVALUEPAIRS_H */
