#ifndef OPC_TECHNOLOGY_H
#define OPC_TECHNOLOGY_H

#include <stddef.h>

#include "lua/lua.h"

#include "vector.h"
#include "hashmap.h"

// public struct declarations
struct technology_state;
struct generics;
struct layer_iterator;

struct via_definition { // FIXME: this is in the header file because the geometry module uses this.
                        // But the via strategies could be implemented within the technology module, making this private
    unsigned int width;
    unsigned int height;
    unsigned int xspace;
    unsigned int yspace;
    int xenclosure;
    int yenclosure;
    unsigned int maxwidth;
    unsigned int maxheight;
};

struct technology_state* technology_initialize(void);
void technology_destroy(struct technology_state* state);

void technology_add_techpath(struct technology_state* techstate, const char* path);
int technology_load(struct technology_state* techstate, const char* name, const struct const_vector* ignoredlayers);

void technology_enable_fallback_vias(struct technology_state* techstate);
void technology_disable_via_arrayzation(struct technology_state* techstate);
int technology_is_create_via_arrays(const struct technology_state* techstate);
void technology_ignore_premapped_layers(struct technology_state* techstate);

struct generics* technology_get_layer(struct technology_state* state, const char* layername);
int technology_resolve_metal(const struct technology_state* state, int metalnum);
int technology_has_multiple_patterning(const struct technology_state* state, int metalnum);
struct via_definition** technology_get_via_definitions(struct technology_state* state, int metal1, int metal2);
struct via_definition* technology_get_via_fallback(struct technology_state* state, int metal1, int metal2);
struct via_definition** technology_get_contact_definitions(struct technology_state* state, const char* region);
struct via_definition* technology_get_contact_fallback(struct technology_state* state, const char* region);

struct generics* technology_make_layer(const char* layername, lua_State* L);

int open_ltechnology_lib(lua_State* L);

int generics_is_empty(const struct generics* layer);
int generics_is_layer_name(const struct generics* layer, const char* layername);
const struct hashmap* generics_get_first_layer_data(const struct generics* layer);

void technology_insert_extra_layer(struct technology_state* techstate, struct generics* layer);
int technology_resolve_premapped_layers(struct technology_state* techstate, const char* exportname);

// layer creation interface
const struct generics* generics_create_metal(struct technology_state* techstate, int num);
const struct generics* generics_create_mptmetal(struct technology_state* techstate, int num, int mask);
const struct generics* generics_create_metalport(struct technology_state* techstate, int num);
const struct generics* generics_create_metalfill(struct technology_state* techstate, int num);
const struct generics* generics_create_mptmetalfill(struct technology_state* techstate, int num, int mask);
const struct generics* generics_create_metalexclude(struct technology_state* techstate, int num);
const struct generics* generics_create_viacut(struct technology_state* techstate, int metal1, int metal2);
const struct generics* generics_create_contact(struct technology_state* techstate, const char* region);
const struct generics* generics_create_oxide(struct technology_state* techstate, int num);
const struct generics* generics_create_implant(struct technology_state* techstate, char polarity);
const struct generics* generics_create_vthtype(struct technology_state* techstate, char channeltype, int vthtype);
const struct generics* generics_create_other(struct technology_state* techstate, const char* str);
const struct generics* generics_create_otherport(struct technology_state* techstate, const char* str);
const struct generics* generics_create_outline(struct technology_state* techstate);
const struct generics* generics_create_special(struct technology_state* techstate);
const struct generics* generics_create_layer_from_lua(struct technology_state* techstate, const char* layername, lua_State* L);

// layermap iterator
struct layer_iterator* layer_iterator_create(const struct technology_state* techstate);
int layer_iterator_is_valid(struct layer_iterator* iterator);
const struct generics* layer_iterator_get(struct layer_iterator* iterator);
void layer_iterator_next(struct layer_iterator* iterator);
void layer_iterator_destroy(struct layer_iterator* iterator);

#endif // OPC_TECHNOLOGY_H
