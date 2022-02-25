#ifndef OPC_GENERICS_H
#define OPC_GENERICS_H

#include <stddef.h>
#include <stdint.h>

#include "keyvaluepairs.h"

#define METAL_MAGIC_IDENTIFIER 0
#define VIA_MAGIC_IDENTIFIER 1
#define OTHER_MAGIC_IDENTIFIER 2

/*
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
*/

typedef struct
{
    char** exportnames;
    struct keyvaluearray** data;
    size_t size;
    int is_pre;
} generics_t;

struct layer_collection
{
    generics_t** layers;
    size_t size;
};

struct layer_collection* generics_create_layer_collection(void);

void generics_insert_layers(const uint8_t* data, size_t size, struct layer_collection* layers);

struct layer_collection* generics_get_layers(const uint8_t* data, size_t size);

void generics_resolve_premapped_layers(const char* exportname);

void generics_initialize_layer_map(void);
void generics_destroy_layer_map(void);

#endif /* OPC_GENERICS_H */
