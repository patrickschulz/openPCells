#ifndef OPC_GENERICS_H
#define OPC_GENERICS_H

#include <stddef.h>
#include <stdint.h>

#include "lua/lua.h"

#include "hashmap.h"
#include "vector.h"
//#include "technology.h"
struct technology_state;

struct generics;

struct layermap;
struct layer_iterator;

// general layer creation and corresponding functions
struct generics* generics_create_empty_layer(const char* name);
struct generics* generics_create_premapped_layer(const char* name, size_t size);
struct generics* generics_make_layer_from_lua(const char* layername, lua_State* L);
void generics_destroy_layer(void* layerv);

int generics_is_empty(const struct generics* layer);
int generics_is_layer_name(const struct generics* layer, const char* layername);
struct hashmap* generics_get_first_layer_data(struct generics* layer);

// layermap
struct layermap* generics_initialize_layer_map(void);
void generics_destroy_layer_map(struct layermap* layermap);
void generics_insert_extra_layer(struct layermap* generics_layer_map, struct generics* layer);
int generics_resolve_premapped_layers(struct layermap* generics_layer_map, const char* exportname);

// layer creation interface
struct generics* generics_create_metal(struct layermap* generics_layer_map, struct technology_state* techstate, int num);
struct generics* generics_create_metalport(struct layermap* generics_layer_map, struct technology_state* techstate, int num);
struct generics* generics_create_viacut(struct layermap* generics_layer_map, struct technology_state* techstate, int metal1, int metal2);
struct generics* generics_create_contact(struct layermap* generics_layer_map, struct technology_state* techstate, const char* region);
struct generics* generics_create_oxide(struct layermap* generics_layer_map, struct technology_state* techstate, int num);
struct generics* generics_create_implant(struct layermap* generics_layer_map, struct technology_state* techstate, char polarity);
struct generics* generics_create_vthtype(struct layermap* generics_layer_map, struct technology_state* techstate, char channeltype, int vthtype);
struct generics* generics_create_other(struct layermap* generics_layer_map, struct technology_state* techstate, const char* str);
struct generics* generics_create_otherport(struct layermap* generics_layer_map, struct technology_state* techstate, const char* str);
struct generics* generics_create_special(struct layermap* generics_layer_map, struct technology_state* techstate);

// layermap iterator
struct layer_iterator* layer_iterator_create(struct layermap* layermap);
int layer_iterator_is_valid(struct layer_iterator* iterator);
void* layer_iterator_get(struct layer_iterator* iterator);
void layer_iterator_next(struct layer_iterator* iterator);
void layer_iterator_destroy(struct layer_iterator* iterator);

#endif /* OPC_GENERICS_H */
