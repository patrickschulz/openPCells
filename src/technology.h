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

struct technology_state* technology_initialize(const char* name);
void technology_destroy(struct technology_state* state);

int technology_exists(const struct vector* techpaths, const char* name);
int technology_load(const struct vector* techpaths, struct technology_state* techstate, const struct const_vector* ignoredlayers);
void technology_write_definition_files(const struct technology_state* techstate, const char* basepath);

// technology state modification API
// not used by the main program, only the technology file assistant uses this
// this is because the internal state might be messed up by this interface, so
// it should not be used
unsigned int technology_get_grid(struct technology_state* techstate);
void technology_set_grid(struct technology_state* techstate, unsigned int grid);
int technology_set_feature(struct technology_state* techstate, const char* feature, int value);
unsigned int technology_get_num_metals(const struct technology_state* techstate);
void technology_set_num_metals(struct technology_state* techstate, unsigned int nummetals);
int technology_add_via_definition(struct technology_state* techstate, unsigned int startindex, unsigned int width, unsigned int height, unsigned int xspace, unsigned int yspace, unsigned int xenclosure, unsigned int yenclosure, unsigned int maxwidth, unsigned int maxheight);
int technology_add_via_definition_by_name(struct technology_state* techstate, const char* vianame, unsigned int width, unsigned int height, unsigned int xspace, unsigned int yspace, unsigned int xenclosure, unsigned int yenclosure, unsigned int maxwidth, unsigned int maxheight);
int technology_set_fallback_via(struct technology_state* techstate, unsigned int startindex, unsigned int width, unsigned int height);
int technology_set_fallback_via_by_name(struct technology_state* techstate, const char* vianame, unsigned int width, unsigned int height);
struct generics* technology_add_empty_layer(struct technology_state* techstate, const char* layername);
int technology_set_constraint_integer(struct technology_state* techstate, const char* name, int value);
void generics_set_layer_export_integer(struct generics* layer, const char* exportname, const char* key, int value);
void generics_set_layer_export_string(struct generics* layer, const char* exportname, const char* key, const char* value);
void generics_set_pretty_name(struct generics* layer, const char* prettyname);

// technology translation flags/options
void technology_enable_fallback_vias(struct technology_state* techstate);
void technology_disable_via_arrayzation(struct technology_state* techstate);
int technology_is_create_via_arrays(const struct technology_state* techstate);
void technology_ignore_premapped_layers(struct technology_state* techstate);
void technology_ignore_missing_layers(struct technology_state* techstate);
void technology_ignore_missing_exports(struct technology_state* techstate);

struct generics* technology_get_layer(struct technology_state* state, const char* layername);
int technology_resolve_metal(const struct technology_state* state, int metalnum);
int technology_has_multiple_patterning(const struct technology_state* state, int metalnum);
int technology_has_feature(const struct technology_state* techstate, const char* feature);

// vias
struct via_definition** technology_get_via_definitions(struct technology_state* state, int lowermetal);
struct via_definition* technology_get_via_fallback(struct technology_state* state, int lowermetal);
struct via_definition** technology_get_contact_definitions(struct technology_state* state, const char* region);
struct via_definition* technology_get_contact_fallback(struct technology_state* state, const char* region);

int open_ltechnology_lib(lua_State* L);

int generics_is_empty(const struct generics* layer);
int generics_is_layer_name(const struct generics* layer, const char* layername);
const char* generics_get_layer_pretty_name(const struct generics* layer);
const struct hashmap* generics_get_first_layer_data(const struct generics* layer);
const struct hashmap* generics_get_layer_data(const struct generics* layer, const char* identifier);

void technology_insert_extra_layer(struct technology_state* techstate, struct generics* layer);
int technology_resolve_premapped_layers(struct technology_state* techstate, const char* exportname);

// info functions
char* technology_get_configfile_path(const struct vector* techpaths, const char* techname);
char* technology_get_layermap_path(const struct vector* techpaths, const char* techname);
char* technology_get_viatable_path(const struct vector* techpaths, const char* techname);
char* technology_get_constraints_path(const struct vector* techpaths, const char* techname);
struct tagged_value* technology_get_dimension(const struct technology_state* techstate, const char* dimension);
unsigned int technology_get_number_of_layers(const struct technology_state* techstate);

// layer creation interface
struct generics* generics_create_empty_layer(const char* name);
void generics_copy_properties(const struct generics* source, struct generics* target);
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
const struct generics* generics_create_well(struct technology_state* techstate, char polarity, const char* mode);
const struct generics* generics_create_vthtype(struct technology_state* techstate, char channeltype, int vthtype);
const struct generics* generics_create_active(struct technology_state* techstate);
const struct generics* generics_create_gate(struct technology_state* techstate);
const struct generics* generics_create_feol(struct technology_state* techstate, const char* layername);
const struct generics* generics_create_beol(struct technology_state* techstate, const char* layername);
const struct generics* generics_create_marker(struct technology_state* techstate, const char* str, int level);
const struct generics* generics_create_exclude(struct technology_state* techstate, const char* str);
const struct generics* generics_create_fill(struct technology_state* techstate, const char* str);
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
