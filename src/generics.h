#ifndef OPC_GENERICS_H
#define OPC_GENERICS_H

#include <stddef.h>
#include <stdint.h>

#include "lua/lua.h"

#include "keyvaluepairs.h"

struct generic_premapped_t
{
    char** exportnames;
    struct keyvaluearray** data;
    size_t size;
};

struct generic_mapped_t
{
    struct keyvaluearray* data;
};

typedef struct
{
    void* layer;
    int is_pre;
} generics_t;

struct hashmapentry
{
    uint32_t key;
    generics_t* layer;
};

struct hashmap // FIXME: pseudo hashmap, but it will probably be good enough as there are not many elements
{
    struct hashmapentry* entries;
    size_t size;
    size_t capacity;
};
extern struct hashmap generics_layer_map;

generics_t* generics_create_metal(int metalnum, lua_State* L);

void generics_destroy(generics_t* layer);
generics_t* generics_copy(generics_t* layer);

void generics_resolve_premapped_layers(const char* exportname);

#endif /* OPC_GENERICS_H */
