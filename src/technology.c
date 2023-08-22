#include "technology.h"

#include "lua/lauxlib.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "util.h"
#include "lua_util.h"
#include "vector.h"
#include "tagged_value.h"
#include "util.h"

struct generics_entry {
    char* exportname;
    struct hashmap* data;
};

struct generics {
    char* name;
    struct vector* entries; // stores struct generics_entry*
};

struct mpentry { // entry for multiple patterning
    int metal;
    int number;
};

struct technology_state {
    struct vector* layertable; // stores struct generics*
    struct vector* viatable; // stores struct viaentry*
    struct technology_config* config;
    struct hashmap* constraints;
    struct vector* techpaths; // stores strings
    int create_via_arrays;
    int ignore_premapped;

    struct hashmap* layermap;
    struct vector* extra_layers; // stores struct generics*, extra premapped layers
    struct generics* empty_layer; // store one empty layer which is reused by all ignored layers
};

void technology_add_techpath(struct technology_state* techstate, const char* path)
{
    vector_append(techstate->techpaths, util_strdup(path));
}

static int ltechnology_list_techpaths(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    for(unsigned int i = 0; i < vector_size(techstate->techpaths); ++i)
    {
        const char* path = vector_get(techstate->techpaths, i);
        puts(path);
    }
    return 0;
}

struct viaentry {
    char* name;
    struct via_definition** viadefs;
    struct via_definition* fallback;
};

static char* _get_tech_filename(struct technology_state* techstate, const char* name, const char* what)
{
    for(unsigned int i = 0; i < vector_size(techstate->techpaths); ++i)
    {
        const char* path = vector_get(techstate->techpaths, i);
        size_t len = strlen(path) + strlen(name) + strlen(what) + 6; // + 6: '/' + '/' + ".lua"
        char* filename = malloc(len + 1);
        snprintf(filename, len + 1, "%s/%s/%s.lua", path, name, what);
        if(util_file_exists(filename))
        {
            return filename;
        }
        free(filename);
    }
    return NULL;
}

static int _is_ignored_layer(const char* layername, const struct const_vector* ignoredlayers)
{
    int ret = 0;
    if(ignoredlayers)
    {
        struct const_vector_iterator* it = const_vector_iterator_create(ignoredlayers);
        while(const_vector_iterator_is_valid(it))
        {
            const char* name = const_vector_iterator_get(it);
            if(strcmp(layername, name) == 0)
            {
                ret = 1;
            }
            const_vector_iterator_next(it);
        }
        const_vector_iterator_destroy(it);
    }
    return ret;
}

static struct generics_entry* _create_entry(const char* name)
{
    struct generics_entry* entry = malloc(sizeof(*entry));
    entry->exportname = util_strdup(name);
    entry->data = hashmap_create();
    return entry;
}

static void _insert_lpp_pairs(lua_State* L, struct hashmap* map)
{
    lua_pushnil(L);
    while (lua_next(L, -2) != 0)
    {
        struct tagged_value* value = NULL;
        switch(lua_type(L, -1))
        {
            case LUA_TNUMBER:
                value = tagged_value_create_integer(lua_tointeger(L, -1));
                break;
            case LUA_TSTRING:
                value = tagged_value_create_string(lua_tostring(L, -1));
                break;
            case LUA_TBOOLEAN:
                value = tagged_value_create_boolean(lua_toboolean(L, -1));
                break;
        }
        if(value)
        {
            hashmap_insert(map, lua_tostring(L, -2), value);
        }
        lua_pop(L, 1); // pop value, keep key for next iteration
    }
}

static struct generics* _create_empty_layer(const char* name)
{
    struct generics* layer = malloc(sizeof(*layer));
    memset(layer, 0, sizeof(*layer));
    layer->name = util_strdup(name);
    return layer;
}

static void _destroy_entry(void* entryv)
{
    struct generics_entry* entry = entryv;
    free(entry->exportname);
    hashmap_destroy(entry->data, tagged_value_destroy);
    free(entry);
}

static struct generics* _create_premapped_layer(const char* name, size_t size)
{
    struct generics* layer = _create_empty_layer(name);
    layer->entries = vector_create(size, _destroy_entry);
    return layer;
}


static struct generics* _make_layer_from_lua(const char* layername, lua_State* L)
{
    struct generics* layer;
    if(lua_isnil(L, -1))
    {
        layer = _create_empty_layer(layername);
    }
    else
    {
        // count entries
        size_t num = 0;
        lua_pushnil(L);
        while(lua_next(L, -2) != 0)
        {
            lua_pop(L, 1); // pop value, keep key for next iteration
            num += 1;
        }

        layer = _create_premapped_layer(layername, num);
        lua_pushnil(L);
        while (lua_next(L, -2) != 0)
        {
            const char* name = lua_tostring(L, -2);
            struct generics_entry* entry = _create_entry(name);
            _insert_lpp_pairs(L, entry->data);
            vector_append(layer->entries, entry);
            lua_pop(L, 1); // pop value, keep key for next iteration
        }
    }
    return layer;
}

int technology_load_layermap(struct technology_state* techstate, const char* name, const struct const_vector* ignoredlayers)
{
    lua_State* L = util_create_minimal_lua_state();
    int ret = luaL_dofile(L, name);
    if(ret != LUA_OK)
    {
        const char* msg = lua_tostring(L, -1);
        fprintf(stderr, "error while loading layermap:\n  %s\n", msg);
        lua_close(L);
        return 0;
    }
    lua_pushnil(L);
    while(lua_next(L, -2) != 0)
    {
        const char* layername = lua_tostring(L, -2);
        if(!_is_ignored_layer(layername, ignoredlayers))
        {
            lua_getfield(L, -1, "layer");
            struct generics* layer = _make_layer_from_lua(layername, L);
            vector_append(techstate->layertable, layer);
            lua_pop(L, 1); // pop layer table
        }
        else
        {
            // create dummy layer (as if {} was given in the layermap file)
            struct generics* layer = _create_premapped_layer(layername, 0);
            vector_append(techstate->layertable, layer);
        }
        lua_pop(L, 1); // pop value, keep key for next iteration
    }
    lua_close(L);
    return 1;
}

struct via_definition** _read_via(lua_State* L)
{
    lua_getfield(L, -1, "entries");
    lua_len(L, -1);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    struct via_definition** viadefs = calloc(len + 1, sizeof(*viadefs)); // + 1: sentinel-terminated
    for(unsigned int i = 1; i <= len; ++i)
    {
        struct via_definition* viadef = malloc(sizeof(*viadef));
        lua_rawgeti(L, -1, i);

        lua_getfield(L, -1, "width");
        viadef->width = lua_tointeger(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, -1, "height");
        viadef->height = lua_tointeger(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, -1, "xspace");
        viadef->xspace = lua_tointeger(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, -1, "yspace");
        viadef->yspace = lua_tointeger(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, -1, "xenclosure");
        viadef->xenclosure = lua_tointeger(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, -1, "yenclosure");
        viadef->yenclosure = lua_tointeger(L, -1);
        lua_pop(L, 1);
        lua_getfield(L, -1, "maxwidth");
        viadef->maxwidth = luaL_optinteger(L, -1, UINT_MAX);
        lua_pop(L, 1);
        lua_getfield(L, -1, "maxheight");
        viadef->maxheight = luaL_optinteger(L, -1, UINT_MAX);
        lua_pop(L, 1);

        lua_pop(L, 1);
        viadefs[i - 1] = viadef;
    }
    viadefs[len] = NULL;
    lua_pop(L, 1);
    return viadefs;
}

struct via_definition* _read_via_fallback(lua_State* L)
{
    struct via_definition* viadef = malloc(sizeof(*viadef));
    viadef->xspace = 0;
    viadef->yspace = 0;
    viadef->xenclosure = 0;
    viadef->yenclosure = 0;

    lua_getfield(L, -1, "fallback");
    if(lua_isnil(L, -1))
    {
        lua_pop(L, 1);
        free(viadef);
        return NULL;
    }

    lua_getfield(L, -1, "width");
    viadef->width = lua_tointeger(L, -1);
    lua_pop(L, 1);
    lua_getfield(L, -1, "height");
    viadef->height = lua_tointeger(L, -1);
    lua_pop(L, 1);

    lua_pop(L, 1);
    return viadef;
}

static void _insert_via(struct technology_state* techstate, char* vianame, struct via_definition** viadefs, struct via_definition* fallback)
{
    struct viaentry* entry = malloc(sizeof(*entry));
    entry->name = vianame;
    entry->viadefs = viadefs;
    entry->fallback = fallback;
    vector_append(techstate->viatable, entry);
}

int technology_load_viadefinitions(struct technology_state* techstate, const char* name)
{
    lua_State* L = util_create_minimal_lua_state();
    int ret = luaL_dofile(L, name);
    if(ret != LUA_OK)
    {
        puts("error while loading via definitions");
        lua_close(L);
        return 0;
    }
    lua_pushnil(L);
    while(lua_next(L, -2) != 0)
    {
        char* vianame = util_strdup(lua_tostring(L, -2));
        struct via_definition** viadefs = _read_via(L);
        struct via_definition* fallback = _read_via_fallback(L);
        _insert_via(techstate, vianame, viadefs, fallback);
        lua_pop(L, 1); // pop value, keep key for next iteration
    }
    lua_close(L);
    return 1;
}

int technology_load_config(struct technology_state* techstate, const char* name)
{
    lua_State* L = util_create_minimal_lua_state();
    int ret = luaL_dofile(L, name);
    if(ret != LUA_OK)
    {
        puts("error while loading config");
        lua_close(L);
        return 0;
    }

    // number of metals
    lua_getfield(L, -1, "metals");
    techstate->config->metals = lua_tointeger(L, -1);
    lua_pop(L, 1); // pop metals

    // multiple patterning
    lua_getfield(L, -1, "multiple_patterning");
    techstate->config->multiple_patterning_metals = vector_create(1, free);
    if(lua_istable(L, -1))
    {
        lua_len(L, -1);
        size_t len = lua_tointeger(L, -1);
        lua_pop(L, 1); // pop len
        for(size_t i = 1; i <= len; ++i)
        {
            lua_rawgeti(L, -1, i);
            if(!lua_istable(L, -1))
            {
                puts("error while loading technology config: multiple_patterning is not a table");
                return 0;
            }
            struct mpentry* entry = malloc(sizeof(*entry));
            lua_getfield(L, -1, "metal");
            entry->metal = lua_tointeger(L, -1);
            lua_pop(L, 1); // pop metal
            lua_getfield(L, -1, "number");
            entry->number = lua_tointeger(L, -1);
            lua_pop(L, 1); // pop number
            lua_pop(L, 1); // pop entry
            vector_append(techstate->config->multiple_patterning_metals, entry);
        }
    }
    lua_pop(L, 1); // pop multiple_patterning
    lua_close(L);
    return 1;
}

int technology_load_constraints(struct technology_state* techstate, const char* name)
{
    lua_State* L = util_create_minimal_lua_state();
    int ret = luaL_dofile(L, name);
    if(ret != LUA_OK)
    {
        puts("error while loading constraints");
        lua_close(L);
        return 0;
    }
    lua_pushnil(L);
    // FIXME: get the keys that are needed, the current approach is unsafe
    while (lua_next(L, -2) != 0)
    {
        struct tagged_value* value = tagged_value_create_integer(lua_tointeger(L, -1));
        hashmap_insert(techstate->constraints, lua_tostring(L, -2), value);
        lua_pop(L, 1); // pop value, keep key for next iteration
    }
    lua_pop(L, 1); // pop constraints table
    lua_close(L);
    return 0;
}

int technology_load(struct technology_state* techstate, const char* techname, const struct const_vector* ignoredlayers)
{
    char* layermapname = _get_tech_filename(techstate, techname, "layermap");
    if(!layermapname)
    {
        printf("technology: no techfile for technology '%s' found", techname);
        free(layermapname);
        return 0;
    }
    int ret;
    ret = technology_load_layermap(techstate, layermapname, ignoredlayers);
    free(layermapname);
    if(!ret)
    {
        return 0;
    }

    char* vianame = _get_tech_filename(techstate, techname, "vias");
    if(!vianame)
    {
        printf("technology: no via definitions for technology '%s' found", techname);
        free(vianame);
        return 0;
    }
    technology_load_viadefinitions(techstate, vianame);
    free(vianame);

    char* configname = _get_tech_filename(techstate, techname, "config");
    if(!configname)
    {
        printf("technology: no config file for technology '%s' found", techname);
        free(configname);
        return 0;
    }
    ret = technology_load_config(techstate, configname);
    free(configname);
    if(!ret)
    {
        puts("technology: errrors while loading technology config file");
        return 0;
    }

    char* constraintsname = _get_tech_filename(techstate, techname, "constraints");
    if(!constraintsname)
    {
        printf("technology: no constraints file for technology '%s' found", techname);
        free(constraintsname);
        return 0;
    }
    technology_load_constraints(techstate, constraintsname);
    free(constraintsname);

    return 1;
}

struct generics* technology_get_layer(struct technology_state* techstate, const char* layername)
{
    for(unsigned int i = 0; i < vector_size(techstate->layertable); ++i)
    {
        struct generics* layer = vector_get(techstate->layertable, i);
        if(generics_is_layer_name(layer, layername))
        {
            return layer;
        }
    }
    return NULL;
}

struct via_definition** technology_get_via_definitions(struct technology_state* techstate, int metal1, int metal2)
{
    size_t len = 3 + 1 + util_num_digits(metal1) + 1 + util_num_digits(metal2); // via + M + %d + M + %d
    char* vianame = malloc(len + 1);
    snprintf(vianame, len + 1, "viaM%dM%d", metal1, metal2);
    struct via_definition** viadefs = NULL;
    for(unsigned int i = 0; i < vector_size(techstate->viatable); ++i)
    {
        struct viaentry* entry = vector_get(techstate->viatable, i);
        if(strcmp(entry->name, vianame) == 0)
        {
            viadefs = entry->viadefs;
            break;
        }
    }
    if(!viadefs)
    {
        printf("could not find via definitions for '%s'\n", vianame);
    }
    free(vianame);
    return viadefs;
}

struct via_definition* technology_get_via_fallback(struct technology_state* techstate, int metal1, int metal2)
{
    size_t len = 3 + 1 + util_num_digits(metal1) + 1 + util_num_digits(metal2); // via + M + %d + M + %d
    char* vianame = malloc(len + 1);
    snprintf(vianame, len + 1, "viaM%dM%d", metal1, metal2);
    struct via_definition* viadef = NULL;
    for(unsigned int i = 0; i < vector_size(techstate->viatable); ++i)
    {
        struct viaentry* entry = vector_get(techstate->viatable, i);
        if(strcmp(entry->name, vianame) == 0)
        {
            viadef = entry->fallback;
            break;
        }
    }
    if(!viadef)
    {
        //printf("could not find fallback via definitions for '%s'\n", vianame);
    }
    free(vianame);
    return viadef;
}

struct via_definition** technology_get_contact_definitions(struct technology_state* techstate, const char* region)
{
    size_t len = 7 + strlen(region);
    char* contactname = malloc(len + 1);
    snprintf(contactname, len + 1, "contact%s", region);
    struct via_definition** viadefs = NULL;
    for(unsigned int i = 0; i < vector_size(techstate->viatable); ++i)
    {
        struct viaentry* entry = vector_get(techstate->viatable, i);
        if(strcmp(entry->name, contactname) == 0)
        {
            viadefs = entry->viadefs;
            break;
        }
    }
    if(!viadefs)
    {
        printf("could not find contact definitions for '%s'\n", contactname);
    }
    free(contactname);
    return viadefs;
}

struct via_definition* technology_get_contact_fallback(struct technology_state* techstate, const char* region)
{
    size_t len = 7 + strlen(region);
    char* contactname = malloc(len + 1);
    snprintf(contactname, len + 1, "contact%s", region);
    struct via_definition* fallback = NULL;
    for(unsigned int i = 0; i < vector_size(techstate->viatable); ++i)
    {
        struct viaentry* entry = vector_get(techstate->viatable, i);
        if(strcmp(entry->name, contactname) == 0)
        {
            fallback = entry->fallback;
            break;
        }
    }
    if(!fallback)
    {
        //printf("could not find fallback contact definitions for '%s'\n", contactname);
    }
    free(contactname);
    return fallback;
}

int technology_resolve_metal(const struct technology_state* techstate, int metalnum)
{
    if(metalnum < 0)
    {
        return techstate->config->metals + metalnum + 1;
    }
    else
    {
        return metalnum;
    }
}

int technology_has_multiple_patterning(const struct technology_state* techstate, int metalnum)
{
    int ret = 0;
    int m = technology_resolve_metal(techstate, metalnum);
    struct vector_iterator* it = vector_iterator_create(techstate->config->multiple_patterning_metals);
    while(vector_iterator_is_valid(it))
    {
        struct mpentry* entry = vector_iterator_get(it);
        if(entry->metal == m)
        {
            ret = 1;
        }
        vector_iterator_next(it);
    }
    vector_iterator_destroy(it);
    return ret;
}

int technology_multiple_patterning_number(const struct technology_state* techstate, int metalnum)
{
    int number = 0;
    int m = technology_resolve_metal(techstate, metalnum);
    struct vector_iterator* it = vector_iterator_create(techstate->config->multiple_patterning_metals);
    while(vector_iterator_is_valid(it))
    {
        struct mpentry* entry = vector_iterator_get(it);
        if(entry->metal == m)
        {
            number = entry->number;
        }
        vector_iterator_next(it);
    }
    vector_iterator_destroy(it);
    return number;
}

static int _resolve_layer(struct generics* layer, const char* exportname)
{
    int found = 0;
    if(!generics_is_empty(layer)) // empty layers are ignored
    {
        unsigned int idx = 0;
        for(unsigned int k = 0; k < vector_size(layer->entries); ++k)
        {
            const struct generics_entry* entry = vector_get_const(layer->entries, k);
            if(strcmp(exportname, entry->exportname) == 0)
            {
                found = 1;
                idx = k;
            }
        }
        if(!found)
        {
            if(vector_size(layer->entries) > 1)
            {
                printf("no layer data for export type '%s' found (layer: %s, has %zd entries)\n", exportname, layer->name, vector_size(layer->entries));
            }
            else
            {
                printf("no layer data for export type '%s' found (layer: %s, has 1 entry)\n", exportname, layer->name);
            }
            return 0;
        }

        // swap data
        // for mapped entries, only the first entry is used, but it is easier to keep the data here
        // and let _destroy_generics free all data, regardless if a layer is premapped or mapped
        vector_swap(layer->entries, 0, idx);
    }
    return 1;
}

int technology_resolve_premapped_layers(struct technology_state* techstate, const char* exportname)
{
    // main layers
    struct hashmap_iterator* it = hashmap_iterator_create(techstate->layermap);
    while(hashmap_iterator_is_valid(it))
    {
        struct generics* layer = hashmap_iterator_value(it);
        if(!_resolve_layer(layer, exportname))
        {
            hashmap_iterator_destroy(it);
            return 0;
        }
        hashmap_iterator_next(it);
    }
    hashmap_iterator_destroy(it);

    // extra layers
    for(unsigned int i = 0; i < vector_size(techstate->extra_layers); ++i)
    {
        struct generics* layer = vector_get(techstate->extra_layers, i);
        if(!_resolve_layer(layer, exportname))
        {
            return 0;
        }
    }
    return 1;
}

static void _destroy_layer(void* layerv)
{
    struct generics* layer = layerv;
    if(layer->entries)
    {
        vector_destroy(layer->entries);
    }
    free(layer->name);
    free(layer);
}

static void _destroy_viaentry(void* viav)
{
    struct viaentry* entry = viav;
    free(entry->name);
    struct via_definition** viadef = entry->viadefs;
    while(*viadef)
    {
        free(*viadef);
        ++viadef;
    }
    free(entry->viadefs);
    free(entry->fallback);
    free(entry);
}

struct technology_state* technology_initialize(void)
{
    struct technology_state* techstate = malloc(sizeof(*techstate));
    techstate->layertable = vector_create(32, _destroy_layer);
    techstate->viatable = vector_create(32, _destroy_viaentry);
    techstate->config = malloc(sizeof(*techstate->config));
    techstate->constraints = hashmap_create();
    techstate->techpaths = vector_create(32, free);
    techstate->create_via_arrays = 1;
    techstate->ignore_premapped = 0;
    techstate->layermap = hashmap_create();
    techstate->extra_layers = vector_create(1024, _destroy_layer);
    techstate->empty_layer = _create_empty_layer("_EMPTY_");
    return techstate;
}

void technology_destroy(struct technology_state* techstate)
{
    vector_destroy(techstate->layertable);
    vector_destroy(techstate->viatable);

    vector_destroy(techstate->config->multiple_patterning_metals);
    free(techstate->config);

    hashmap_destroy(techstate->constraints, tagged_value_destroy);

    vector_destroy(techstate->techpaths);

    hashmap_destroy(techstate->layermap, NULL);
    vector_destroy(techstate->extra_layers); // (externally) premapped layers are owned by the layer map

    _destroy_layer(techstate->empty_layer);

    free(techstate);
}

void technology_disable_via_arrayzation(struct technology_state* techstate)
{
    techstate->create_via_arrays = 0;
}

int technology_is_create_via_arrays(const struct technology_state* techstate)
{
    return techstate->create_via_arrays;
}

void technology_ignore_premapped_layers(struct technology_state* techstate)
{
    techstate->ignore_premapped = 1;
}

int technology_is_ignore_premapped_layers(const struct technology_state* techstate)
{
    return techstate->ignore_premapped;
}

static int ltechnology_get_dimension(lua_State* L)
{
    int n = lua_gettop(L);
    for(int i = 1; i <= n; ++i)
    {
        const char* dimension = lua_tostring(L, i);
        lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
        struct technology_state* techstate = lua_touserdata(L, -1);
        lua_pop(L, 1); // pop techstate
        if(hashmap_exists(techstate->constraints, dimension))
        {
            struct tagged_value* v = hashmap_get(techstate->constraints, dimension);
            int value = tagged_value_get_integer(v);
            lua_pushinteger(L, value);
            return 1;
        }
    }
    // FIXME: this looks ugly for multiple arguments
    lua_concat(L, n);
    lua_pushstring(L, "technology.get_dimension: '");
    lua_rotate(L, -2, 1);
    lua_pushstring(L, "' not found");
    lua_concat(L, 3);
    lua_error(L);
    return 1;
}

static int ltechnology_has_layer(lua_State* L)
{
    struct generics* layer = lua_touserdata(L, 1);
    lua_pushboolean(L, !generics_is_empty(layer));
    return 1;
}

static int ltechnology_resolve_metal(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int metal = luaL_checkinteger(L, 1);
    int resolved = technology_resolve_metal(techstate, metal);
    lua_pushinteger(L, resolved);
    return 1;
}

static int ltechnology_has_multiple_patterning(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int metal = luaL_checkinteger(L, 1);
    int hasmp = technology_has_multiple_patterning(techstate, metal);
    lua_pushboolean(L, hasmp);
    return 1;
}

static int ltechnology_multiple_patterning_number(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int metal = luaL_checkinteger(L, 1);
    int num = technology_multiple_patterning_number(techstate, metal);
    lua_pushinteger(L, num);
    return 1;
}

int open_ltechnology_lib(lua_State* L)
{
    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { "list_techpaths",                 ltechnology_list_techpaths              },
        { "get_dimension",                  ltechnology_get_dimension               },
        { "has_layer",                      ltechnology_has_layer                   },
        { "resolve_metal",                  ltechnology_resolve_metal               },
        { "has_multiple_patterning",        ltechnology_has_multiple_patterning     },
        { "multiple_patterning_number",     ltechnology_multiple_patterning_number  },
        { NULL,                             NULL                                    }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "technology");

    return 0;
}

static const struct generics* _get_or_create_layer(struct technology_state* techstate, const char* layername)
{
    if(!hashmap_exists(techstate->layermap, layername))
    {
        struct generics* layer = technology_get_layer(techstate, layername);
        hashmap_insert(techstate->layermap, layername, layer);
        return layer;
    }
    else
    {
        return hashmap_get(techstate->layermap, layername);
    }
}

const struct generics* generics_create_metal(struct technology_state* techstate, int num)
{
    num = technology_resolve_metal(techstate, num);
    size_t len = 1 + util_num_digits(num);
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "M%d", num);
    const struct generics* layer = _get_or_create_layer(techstate, layername);
    free(layername);
    return layer;
}

const struct generics* generics_create_mptmetal(struct technology_state* techstate, int num, int mask)
{
    num = technology_resolve_metal(techstate, num);
    size_t len = 1 + util_num_digits(num) + 1 + util_num_digits(mask);
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "M%d_%d", num, mask);
    const struct generics* layer = _get_or_create_layer(techstate, layername);
    free(layername);
    return layer;
}

const struct generics* generics_create_metalport(struct technology_state* techstate, int num)
{
    num = technology_resolve_metal(techstate, num);
    size_t len = 1 + util_num_digits(num) + 4; // M + %d + port
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "M%dport", num);
    const struct generics* layer = _get_or_create_layer(techstate, layername);
    free(layername);
    return layer;
}

const struct generics* generics_create_metalfill(struct technology_state* techstate, int num)
{
    num = technology_resolve_metal(techstate, num);
    size_t len = 1 + util_num_digits(num) + 4; // M + %d + fill
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "M%dfill", num);
    const struct generics* layer = _get_or_create_layer(techstate, layername);
    free(layername);
    return layer;
}

const struct generics* generics_create_mptmetalfill(struct technology_state* techstate, int num, int mask)
{
    num = technology_resolve_metal(techstate, num);
    size_t len = 1 + util_num_digits(num) + 1 + util_num_digits(mask) + 4; // M + %d + fill
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "M%d_%dfill", num, mask);
    const struct generics* layer = _get_or_create_layer(techstate, layername);
    free(layername);
    return layer;
}

const struct generics* generics_create_metalexclude(struct technology_state* techstate, int num)
{
    num = technology_resolve_metal(techstate, num);
    size_t len = 1 + util_num_digits(num) + 7; // M + %d + exclude
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "M%dexclude", num);
    const struct generics* layer = _get_or_create_layer(techstate, layername);
    free(layername);
    return layer;
}

const struct generics* generics_create_viacut(struct technology_state* techstate, int metal1, int metal2)
{
    metal1 = technology_resolve_metal(techstate, metal1);
    metal2 = technology_resolve_metal(techstate, metal2);
    if(metal1 > metal2)
    {
        int tmp = metal2;
        metal2 = metal1;
        metal1 = tmp;
    }
    size_t len = 6 + 1 + util_num_digits(metal1) + 1 + util_num_digits(metal2); // viacut + M + %d + M + %d
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "viacutM%dM%d", metal1, metal2);
    const struct generics* layer = _get_or_create_layer(techstate, layername);
    free(layername);
    return layer;
}

const struct generics* generics_create_contact(struct technology_state* techstate, const char* region)
{
    size_t len = 7 + strlen(region); // contact + %s
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "contact%s", region);
    const struct generics* layer = _get_or_create_layer(techstate, layername);
    free(layername);
    return layer;
}

const struct generics* generics_create_oxide(struct technology_state* techstate, int num)
{
    size_t len = 5 + util_num_digits(num); // oxide + %d
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "oxide%d", num);
    const struct generics* layer = _get_or_create_layer(techstate, layername);
    free(layername);
    return layer;
}

const struct generics* generics_create_implant(struct technology_state* techstate, char polarity)
{
    size_t len = 8; // [np]implant
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "%cimplant", polarity);
    const struct generics* layer = _get_or_create_layer(techstate, layername);
    free(layername);
    return layer;
}

const struct generics* generics_create_vthtype(struct technology_state* techstate, char channeltype, int vthtype)
{
    size_t len = 7 + 1 + util_num_digits(vthtype); // vthtype + %c + %d
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "vthtype%c%d", channeltype, vthtype);
    const struct generics* layer = _get_or_create_layer(techstate, layername);
    free(layername);
    return layer;
}

const struct generics* generics_create_other(struct technology_state* techstate, const char* layername)
{
    const struct generics* layer = _get_or_create_layer(techstate, layername);
    return layer;
}

const struct generics* generics_create_otherport(struct technology_state* techstate, const char* str)
{
    size_t len = strlen(str) + 4; // + "port"
    char* layername = malloc(len + 1);
    snprintf(layername, len + 1, "%sport", str);
    const struct generics* layer = _get_or_create_layer(techstate, layername);
    free(layername);
    return layer;
}

const struct generics* generics_create_outline(struct technology_state* techstate)
{
    const struct generics* layer = _get_or_create_layer(techstate, "outline");
    return layer;
}

const struct generics* generics_create_special(struct technology_state* techstate)
{
    const struct generics* layer = _get_or_create_layer(techstate, "special");
    return layer;
}

const struct generics* generics_create_layer_from_lua(struct technology_state* techstate, const char* layername, lua_State* L)
{
    struct generics* layer;
    if(techstate->ignore_premapped)
    {
        layer = techstate->empty_layer;
    }
    else
    {
        layer = _make_layer_from_lua(layername, L);
        vector_append(techstate->extra_layers, layer);
    }
    return layer;
}

int generics_is_empty(const struct generics* layer)
{
    if(layer->entries)
    {
        return vector_size(layer->entries) == 0;
    }
    else
    {
        return 1;
    }
}

int generics_is_layer_name(const struct generics* layer, const char* layername)
{
    return strcmp(layer->name, layername) == 0;
}

const struct hashmap* generics_get_first_layer_data(const struct generics* layer)
{
    const struct generics_entry* entry = vector_get_const(layer->entries, 0);
    return entry->data;
}

// layer iterator
struct layer_iterator {
    struct hashmap_const_iterator* hashmap_iterator;
    struct vector_const_iterator* extra_iterator;
};

struct layer_iterator* layer_iterator_create(const struct technology_state* techstate)
{
    struct layer_iterator* it = malloc(sizeof(*it));
    it->hashmap_iterator = hashmap_const_iterator_create(techstate->layermap);
    it->extra_iterator = vector_const_iterator_create(techstate->extra_layers);
    return it;
}

int layer_iterator_is_valid(struct layer_iterator* iterator)
{
    return
        hashmap_const_iterator_is_valid(iterator->hashmap_iterator)
        ||
        vector_const_iterator_is_valid(iterator->extra_iterator)
        ;
}

const struct generics* layer_iterator_get(struct layer_iterator* iterator)
{
    if(hashmap_const_iterator_is_valid(iterator->hashmap_iterator))
    {
        return hashmap_const_iterator_value(iterator->hashmap_iterator);
    }
    else
    {
        return vector_const_iterator_get(iterator->extra_iterator);
    }
}

void layer_iterator_next(struct layer_iterator* iterator)
{
    if(hashmap_const_iterator_is_valid(iterator->hashmap_iterator))
    {
        hashmap_const_iterator_next(iterator->hashmap_iterator);
    }
    else
    {
        vector_const_iterator_next(iterator->extra_iterator);
    }
}

void layer_iterator_destroy(struct layer_iterator* iterator)
{
    hashmap_const_iterator_destroy(iterator->hashmap_iterator);
    vector_const_iterator_destroy(iterator->extra_iterator);
}

