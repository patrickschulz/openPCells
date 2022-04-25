#ifndef OPC_GENERICS_H
#define OPC_GENERICS_H

#include <stddef.h>
#include <stdint.h>

#include "keyvaluepairs.h"
//#include "technology.h"
struct technology_state;

typedef struct
{
    char* name;
    char** exportnames;
    struct keyvaluearray** data;
    size_t size;
} generics_t;

struct hashmapentry
{
    uint32_t key;
    generics_t* layer;
    int destroy;
};

struct layermap // FIXME: pseudo hashmap, but it will probably be good enough as there are not many elements
{
    struct hashmapentry** entries;
    size_t size;
    size_t capacity;
};

generics_t* generics_create_empty_layer(const char* name);
generics_t* generics_create_premapped_layer(const char* name, size_t size);

generics_t* generics_create_special(struct layermap* generics_layer_map, struct technology_state* techstate);
generics_t* generics_create_metal(struct layermap* generics_layer_map, struct technology_state* techstate, int num);
generics_t* generics_create_metalport(struct layermap* generics_layer_map, struct technology_state* techstate, int num);
generics_t* generics_create_viacut(struct layermap* generics_layer_map, struct technology_state* techstate, int metal1, int metal2);
generics_t* generics_create_contact(struct layermap* generics_layer_map, struct technology_state* techstate, const char* region);
generics_t* generics_create_oxide(struct layermap* generics_layer_map, struct technology_state* techstate, int num);
generics_t* generics_create_implant(struct layermap* generics_layer_map, struct technology_state* techstate, char polarity);
generics_t* generics_create_vthtype(struct layermap* generics_layer_map, struct technology_state* techstate, char channeltype, int vthtype);
generics_t* generics_create_other(struct layermap* generics_layer_map, struct technology_state* techstate, const char* str);

void generics_destroy_layer(generics_t* layer);

void generics_insert_extra_layer(struct layermap* generics_layer_map, uint32_t key, generics_t* layer);

generics_t* generics_get_layer(struct layermap* generics_layer_map, uint32_t key);

size_t generics_get_layer_map_size(struct layermap* generics_layer_map);
generics_t* generics_get_indexed_layer(struct layermap* generics_layer_map, size_t idx);

int generics_resolve_premapped_layers(struct layermap* generics_layer_map, const char* exportname);

struct layermap* generics_initialize_layer_map(void);
void generics_destroy_layer_map(struct layermap* layermap);

#endif /* OPC_GENERICS_H */
