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

struct layer_collection
{
    generics_t** layers;
    size_t size;
};

struct layer_collection* generics_create_metal(int metalnum, lua_State* L);
struct layer_collection* generics_create_other(const char* str, size_t len, lua_State* L);

void generics_destroy_layer_collection(struct layer_collection* layers);

void generics_destroy(generics_t* layer);

void generics_resolve_premapped_layers(const char* exportname);

void generics_initialize_layer_map(void);
void generics_destroy_layer_map(void);

#endif /* OPC_GENERICS_H */
