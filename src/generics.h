#ifndef OPC_GENERICS_H
#define OPC_GENERICS_H

#include <stddef.h>
#include <stdint.h>

#include "keyvaluepairs.h"
#include "hashmap.h"
#include "vector.h"
//#include "technology.h"
struct technology_state;

typedef struct
{
    char* name;
    char** exportnames;
    struct keyvaluearray** data;
    size_t size;
} generics_t;

struct layermap;
struct layer_iterator;

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

void generics_destroy_layer(void* layerv);

void generics_insert_extra_layer(struct layermap* generics_layer_map, generics_t* layer);

int generics_resolve_premapped_layers(struct layermap* generics_layer_map, const char* exportname);

struct layermap* generics_initialize_layer_map(void);
void generics_destroy_layer_map(struct layermap* layermap);

struct layer_iterator* layer_iterator_create(struct layermap* layermap);
int layer_iterator_is_valid(struct layer_iterator* iterator);
void* layer_iterator_get(struct layer_iterator* iterator);
void layer_iterator_next(struct layer_iterator* iterator);
void layer_iterator_destroy(struct layer_iterator* iterator);

#endif /* OPC_GENERICS_H */
