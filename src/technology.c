#include "technology.h"

#include "lua/lauxlib.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "error.h"
#include "filesystem.h"
#include "lua_util.h"
#include "strprint.h"
#include "tagged_value.h"
#include "util.h"

struct generics_entry {
    char* exportname;
    struct hashmap* data; // stores tagged_value*
};

struct generics {
    char* name;
    char* prettyname;
    struct vector* entries; // stores struct generics_entry*
};

struct mpentry { // entry for multiple patterning
    int metal;
    int number;
};

struct technology_config {
    unsigned int metals;
    unsigned int grid;
    int is_soi;
    int has_gatecut;
    int allow_poly_routing;
    struct vector* multiple_patterning_metals; // stores struct mpentry*
};

struct technology_state {
    char* name;
    struct vector* layertable; // stores struct generics*
    struct vector* viatable; // stores struct viaentry*
    struct technology_config* config;
    struct hashmap* constraints; // stores struct tagged_value*
    int create_fallback_vias;
    int create_via_arrays;
    int ignore_premapped;
    int ignore_missing_layers;
    int ignore_missing_exports;

    struct hashmap* layermap; // this hashmap stores the actually used layers in an opc call.
                              // FIXME: it is highly questionable that this is of any use,
                              //        as the layertable (a vector) does probably never store more than
                              //        around 100 layers (often less).
    struct vector* extra_layers; // stores struct generics*, extra premapped layers
    struct generics* empty_layer; // store one empty layer which is reused by all ignored layers
};

static char* _get_tech_filename(const struct vector* techpaths, const char* name, const char* what)
{
    for(unsigned int i = 0; i < vector_size(techpaths); ++i)
    {
        const char* path = vector_get_const(techpaths, i);
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

int technology_has_techfile(const struct vector* techpaths, const char* name, const char* what)
{
    char* filename = _get_tech_filename(techpaths, name, what);
    int has = filename != NULL;
    free(filename);
    return has;
}

int technology_exists(const struct vector* techpaths, const char* name)
{
    return technology_has_techfile(techpaths, name, "config") ||
           technology_has_techfile(techpaths, name, "layermap") ||
           technology_has_techfile(techpaths, name, "vias") ||
           technology_has_techfile(techpaths, name, "constraints");
}

int technology_fully_defined(const struct vector* techpaths, const char* name)
{
    return technology_has_techfile(techpaths, name, "config") &&
           technology_has_techfile(techpaths, name, "layermap") &&
           technology_has_techfile(techpaths, name, "vias") &&
           technology_has_techfile(techpaths, name, "constraints");
}

struct viaentry {
    char* name;
    struct via_definition** viadefs;
    struct via_definition* fallback;
};

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

static struct generics_entry* _create_generics_entry(const char* name)
{
    struct generics_entry* entry = malloc(sizeof(*entry));
    entry->exportname = util_strdup(name);
    entry->data = hashmap_create(tagged_value_destroy);
    return entry;
}

static struct generics_entry* _get_export_entry(const struct generics* layer, const char* exportname)
{
    struct vector_iterator* it = vector_iterator_create(layer->entries);
    struct generics_entry* entry = NULL;
    while(vector_iterator_is_valid(it))
    {
        struct generics_entry* e = vector_iterator_get(it);
        if(strcmp(e->exportname, exportname) == 0)
        {
            entry = e;
            break;
        }
        vector_iterator_next(it);
    }
    vector_iterator_destroy(it);
    return entry;
}

static void _insert_lpp_pairs(lua_State* L, struct hashmap* map)
{
    lua_pushnil(L);
    while (lua_next(L, -2) != 0)
    {
        struct tagged_value* value = NULL;
        // check first of number is an integer
        // this extra step is taken because in lua
        // integers and floats are not disitnguished by type.
        // Hence, lua_type(L, -1) will report LUA_TNUMBER for both integers and doubles.
        int success;
        int num = lua_tointegerx(L, -1, &success);
        if(success)
        {
            value = tagged_value_create_integer(num);
        }
        else // not an integer, check other values
        {
            switch(lua_type(L, -1))
            {
                case LUA_TNUMBER:
                    value = tagged_value_create_number(lua_tonumber(L, -1));
                    break;
                case LUA_TSTRING:
                    value = tagged_value_create_string(lua_tostring(L, -1));
                    break;
                case LUA_TBOOLEAN:
                    value = tagged_value_create_boolean(lua_toboolean(L, -1));
                    break;
            }
        }
        if(value)
        {
            hashmap_insert(map, lua_tostring(L, -2), value);
        }
        lua_pop(L, 1); // pop value, keep key for next iteration
    }
}

static void _destroy_entry(void* entryv)
{
    if(!entryv) // NULL entries are allowed due to --ignore-missing-export
    {
        return;
    }
    struct generics_entry* entry = entryv;
    free(entry->exportname);
    hashmap_destroy(entry->data);
    free(entry);
}

static struct generics* _make_layer_from_lua(const char* layername, lua_State* L)
{
    struct generics* layer = generics_create_empty_layer(layername);
    if(!layer)
    {
        return NULL;
    }
    if(!lua_isnil(L, -1))
    {
        lua_pushnil(L);
        while (lua_next(L, -2) != 0)
        {
            const char* name = lua_tostring(L, -2);
            struct generics_entry* entry = _create_generics_entry(name);
            _insert_lpp_pairs(L, entry->data);
            vector_append(layer->entries, entry);
            lua_pop(L, 1); // pop value, keep key for next iteration
        }
    }
    return layer;
}

static int _check_layer_content(lua_State* L, const char* layername)
{
    lua_pushnil(L);
    while(lua_next(L, -2) != 0)
    {
        const char* key = lua_tostring(L, -2);
        if(
            !(
                (strcmp(key, "layer") == 0) ||
                (strcmp(key, "name") == 0)
            )
        )
        {
            lua_pushfstring(L, "the layer '%s' contains an entry '%s', but only 'layer' and 'name' are allowed.", layername, key);
            return 0;
        }
        lua_pop(L, 1); // pop value, keep key for next iteration
    }
    return 1;
}

static int _load_layermap(struct technology_state* techstate, const char* name, const struct const_vector* ignoredlayers)
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
            if(!_check_layer_content(L, layername))
            {
                const char* msg = lua_tostring(L, -1);
                fprintf(stderr, "error while loading layermap:\n  %s\n", msg);
                lua_close(L);
                return 0;
            }
            // get layer data
            lua_getfield(L, -1, "layer");
            struct generics* layer = _make_layer_from_lua(layername, L);
            lua_pop(L, 1); // pop layer table
            // get optional pretty name
            lua_getfield(L, -1, "name");
            if(lua_type(L, -1) == LUA_TSTRING)
            {
                const char* prettyname = lua_tostring(L, -1);
                generics_set_pretty_name(layer, prettyname);
            }
            lua_pop(L, 1); // pop 'name' value (the optional pretty name)
            vector_append(techstate->layertable, layer);
        }
        else
        {
            // create dummy layer (as if {} was given in the layermap file)
            struct generics* layer = generics_create_empty_layer(layername);
            vector_append(techstate->layertable, layer);
        }
        lua_pop(L, 1); // pop value, keep key for next iteration
    }
    lua_close(L);
    return 1;
}

struct viaentry* _find_viaentry_by_name(struct technology_state* techstate, const char* vianame)
{
    struct viaentry* entry = NULL;
    for(unsigned int i = 0; i < vector_size(techstate->viatable); ++i)
    {
        struct viaentry* e = vector_get(techstate->viatable, i);
        if(strcmp(e->name, vianame) == 0)
        {
            entry = e;
            break;
        }
    }
    return entry;
}

char* _make_vianame(int startmetal)
{
    size_t len = 3 + 1 + util_num_digits(startmetal) + 1 + util_num_digits(startmetal + 1); // via + M + %d + M + %d
    char* vianame = malloc(len + 1);
    snprintf(vianame, len + 1, "viaM%dM%d", startmetal, startmetal + 1);
    return vianame;
}

struct viaentry* _find_viaentry(struct technology_state* techstate, int startmetal)
{
    char* vianame = _make_vianame(startmetal);
    struct viaentry* entry = _find_viaentry_by_name(techstate, vianame);
    free(vianame);
    return entry;
}

void _insert_via_entry(struct via_definition*** viadefs, struct via_definition* viadef)
{
    struct via_definition** p = *viadefs;
    size_t index = 0;
    while(*p)
    {
        ++index;
        ++p;
    }
    *viadefs = realloc(*viadefs, (1 + index + 1) * sizeof(struct via_definition*));
    (*viadefs)[index] = viadef;
    (*viadefs)[index + 1] = NULL;
}

static error_t _read_via_property(lua_State* L, const char* what, unsigned int* param, int allownil)
{
    lua_getfield(L, -1, what);
    error_t e = error_success();
    if(!lua_isnumber(L, -1))
    {
        if(allownil)
        {
            // do nothing, as the default values are already in the variables
        }
        else
        {
            if(lua_isnil(L, -1))
            {
                e.message = strprintf("expected a number for the via property '%s'", what);
            }
            else
            {
                e.message = strprintf("expected a number for the via property '%s', got '%s'", what, luaL_typename(L, -1));
            }
            e.status = 0;
        }
    }
    else
    {
        *param = lua_tointeger(L, -1);
        e.status = 1;
    }
    lua_pop(L, 1);
    return e;
}

error_t _read_via(lua_State* L, struct technology_state* techstate, const char* vianame)
{
    struct viaentry* entry = _find_viaentry_by_name(techstate, vianame);
    if(!entry)
    {
        return error_fail();
    }
    lua_getfield(L, -1, "entries");
    lua_len(L, -1);
    size_t len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    for(unsigned int i = 1; i <= len; ++i)
    {
        // get table
        lua_rawgeti(L, -1, i);
        // check entry type (common xspace etc. or xenclosure1, xenclosure2, etc.)
        int is_duo = 0;
        lua_getfield(L, -1, "xenclosure1");
        if(!lua_isnil(L, -1))
        {
            is_duo = 1;
        }
        lua_pop(L, 1);
        // get entries
        if(is_duo)
        {
            unsigned int width;
            unsigned int height;
            unsigned int xspace;
            unsigned int yspace;
            unsigned int xenclosure1;
            unsigned int xenclosure2;
            unsigned int yenclosure1;
            unsigned int yenclosure2;
            unsigned int maxwidth = UINT_MAX;
            unsigned int maxheight = UINT_MAX;
            error_t e = _read_via_property(L, "width", &width, 0);
            if(!e.status)
            {
                return e;
            }
            e = _read_via_property(L, "height", &height, 0);
            if(!e.status)
            {
                return e;
            }
            e = _read_via_property(L, "xspace", &xspace, 0);
            if(!e.status)
            {
                return e;
            }
            e = _read_via_property(L, "yspace", &yspace, 0);
            if(!e.status)
            {
                return e;
            }
            e = _read_via_property(L, "xenclosure1", &xenclosure1, 0);
            if(!e.status)
            {
                return e;
            }
            e = _read_via_property(L, "xenclosure2", &xenclosure2, 0);
            if(!e.status)
            {
                return e;
            }
            e = _read_via_property(L, "yenclosure1", &yenclosure1, 0);
            if(!e.status)
            {
                return e;
            }
            e = _read_via_property(L, "yenclosure2", &yenclosure2, 0);
            if(!e.status)
            {
                return e;
            }
            e = _read_via_property(L, "maxwidth", &maxwidth, 1);
            if(!e.status)
            {
                return e;
            }
            e = _read_via_property(L, "maxheight", &maxheight, 1);
            if(!e.status)
            {
                return e;
            }
            technology_add_via_definition_by_name2(techstate, vianame, width, height, xspace, yspace, xenclosure1, xenclosure2, yenclosure1, yenclosure2, maxwidth, maxheight);
        }
        else
        {
            unsigned int width;
            unsigned int height;
            unsigned int xspace;
            unsigned int yspace;
            unsigned int xenclosure;
            unsigned int yenclosure;
            unsigned int maxwidth = UINT_MAX;
            unsigned int maxheight = UINT_MAX;
            error_t e = _read_via_property(L, "width", &width, 0);
            if(!e.status)
            {
                return e;
            }
            e = _read_via_property(L, "height", &height, 0);
            if(!e.status)
            {
                return e;
            }
            e = _read_via_property(L, "xspace", &xspace, 0);
            if(!e.status)
            {
                return e;
            }
            e = _read_via_property(L, "yspace", &yspace, 0);
            if(!e.status)
            {
                return e;
            }
            e = _read_via_property(L, "xenclosure", &xenclosure, 0);
            if(!e.status)
            {
                return e;
            }
            e = _read_via_property(L, "yenclosure", &yenclosure, 0);
            if(!e.status)
            {
                return e;
            }
            e = _read_via_property(L, "maxwidth", &maxwidth, 1);
            if(!e.status)
            {
                return e;
            }
            e = _read_via_property(L, "maxheight", &maxheight, 1);
            if(!e.status)
            {
                return e;
            }
            technology_add_via_definition_by_name(techstate, vianame, width, height, xspace, yspace, xenclosure, yenclosure, maxwidth, maxheight);
        }
        // pop table
        lua_pop(L, 1);
    }
    lua_pop(L, 1);
    return error_success();
}

error_t _read_via_fallback(lua_State* L, struct technology_state* techstate, const char* vianame)
{
    error_t e = error_success();
    struct viaentry* entry = _find_viaentry_by_name(techstate, vianame);
    if(!entry)
    {
        error_set_failure(&e);
        return e;
    }

    lua_getfield(L, -1, "fallback");
    if(lua_isnil(L, -1))
    {
        lua_pop(L, 1);
        return e; // missing fallback is not an error (e is still on success)
    }

    lua_getfield(L, -1, "width");
    unsigned width = lua_tointeger(L, -1);
    lua_pop(L, 1);
    lua_getfield(L, -1, "height");
    unsigned height = lua_tointeger(L, -1);
    lua_pop(L, 1);

    technology_set_fallback_via_by_name(techstate, vianame, width, height);

    lua_pop(L, 1);
    return e;
}

static void _create_via_entry_in_techstate(struct technology_state* techstate, char* vianame)
{
    struct viaentry* entry = malloc(sizeof(*entry));
    entry->name = vianame;
    entry->viadefs = malloc(1 * sizeof(struct via_definition*));
    entry->viadefs[0] = NULL;
    entry->fallback = NULL;
    vector_append(techstate->viatable, entry);
}

static error_t _load_viadefinitions(struct technology_state* techstate, const char* name)
{
    error_t e = error_success();
    lua_State* L = util_create_minimal_lua_state();
    int ret = luaL_dofile(L, name);
    if(ret != LUA_OK)
    {
        e.status = 0;
        const char* msg = lua_tostring(L, -1);
        error_add(&e, msg);
        goto VIA_EXIT;
    }
    lua_pushnil(L);
    while(lua_next(L, -2) != 0)
    {
        char* vianame = util_strdup(lua_tostring(L, -2));
        _create_via_entry_in_techstate(techstate, vianame);
        error_t ev = _read_via(L, techstate, vianame);
        if(!ev.status)
        {
            error_set_failure(&e);
            error_prepend(&e, "\": ");
            error_prepend(&e, vianame);
            error_prepend(&e, "\"");
            error_add(&e, ev.message);
            error_clean(&ev);
            goto VIA_EXIT;
        }
        ev = _read_via_fallback(L, techstate, vianame);
        if(!ev.status)
        {
            error_set_failure(&e);
            error_add(&e, strprintf("error while loading fallback via definitions for '%s': %s", name, ev.message));
            error_clean(&ev);
            goto VIA_EXIT;
        }
        lua_pop(L, 1); // pop value, keep key for next iteration
    }
VIA_EXIT:
    lua_close(L);
    return e;
}

static int _load_config(struct technology_state* techstate, const char* name, const char** errmsg)
{
    lua_State* L = util_create_minimal_lua_state();
    int ret = luaL_dofile(L, name);
    if(ret != LUA_OK)
    {
        //const char* msg = lua_tostring(L, -1);
        //fprintf(stderr, "error while loading config file: %s\n", msg);
        *errmsg = "error while loading technology configuration file";
        lua_close(L);
        return 0;
    }

    // number of metals
    lua_getfield(L, -1, "metals");
    if(lua_isnil(L, -1))
    {
        *errmsg = "technology configuration file does not contain the number of metals ('metals' entry)";
        lua_close(L);
        return 0;
    }
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
                *errmsg = "error while loading technology config: multiple_patterning is not a table";
                lua_close(L);
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

    // is soi
    lua_getfield(L, -1, "is_soi");
    if(lua_isnil(L, -1))
    {
        *errmsg = "technology configuration file does not contain info about the wafer type of this process node('is_soi' entry)";
        lua_close(L);
        return 0;
    }
    techstate->config->is_soi = lua_toboolean(L, -1);
    lua_pop(L, 1); // pop is_soi

    // allow poly routing
    lua_getfield(L, -1, "allow_poly_routing");
    if(lua_isnil(L, -1))
    {
        *errmsg = "technology configuration file does not contain info about poly routing ('allow_poly_routing' entry)";
        lua_close(L);
        return 0;
    }
    techstate->config->allow_poly_routing = lua_toboolean(L, -1);
    lua_pop(L, 1); // pop allow_poly_routing

    // has gatecut
    lua_getfield(L, -1, "has_gatecut");
    if(lua_isnil(L, -1))
    {
        *errmsg = "technology configuration file does not contain info about the gate cut layer ('has_gatecut' entry)";
        lua_close(L);
        return 0;
    }
    techstate->config->has_gatecut = lua_toboolean(L, -1);
    lua_pop(L, 1); // pop has_gatecut

    lua_close(L);
    return 1;
}

static int _load_constraints(struct technology_state* techstate, const char* name)
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

int technology_load(const struct vector* techpaths, struct technology_state* techstate, const struct const_vector* ignoredlayers)
{
    char* layermapname = _get_tech_filename(techpaths, techstate->name, "layermap");
    const char* errmsg;
    if(!layermapname)
    {
        fprintf(stderr, "technology: no techfile for technology '%s' found\n", techstate->name);
        free(layermapname);
        return 0;
    }
    int ret;
    error_t e;
    ret = _load_layermap(techstate, layermapname, ignoredlayers);
    free(layermapname);
    if(!ret)
    {
        return 0;
    }

    char* vianame = _get_tech_filename(techpaths, techstate->name, "vias");
    if(!vianame)
    {
        fprintf(stderr, "technology: no via definitions for technology '%s' found\n", techstate->name);
        free(vianame);
        return 0;
    }
    e = _load_viadefinitions(techstate, vianame);
    if(!e.status)
    {
        fprintf(stderr, "technology: errors while loading via definitions: %s\n", e.message);
        return 0;
    }
    free(vianame);

    char* configname = _get_tech_filename(techpaths, techstate->name, "config");
    if(!configname)
    {
        fprintf(stderr, "technology: no config file for technology '%s' found\n", techstate->name);
        free(configname);
        return 0;
    }
    ret = _load_config(techstate, configname, &errmsg);
    if(!ret)
    {
        fprintf(stderr, "technology: errrors while loading technology config file ('%s'):\n%s\n", configname, errmsg);
        free(configname);
        return 0;
    }
    free(configname);

    char* constraintsname = _get_tech_filename(techpaths, techstate->name, "constraints");
    if(!constraintsname)
    {
        fprintf(stderr, "technology: no constraints file for technology '%s' found\n", techstate->name);
        free(constraintsname);
        return 0;
    }
    _load_constraints(techstate, constraintsname);
    free(constraintsname);

    return 1;
}

static char* _make_path(const char* p1, const char* p2)
{
    char* path = malloc(strlen(p1) + strlen(p2) + 1 + 1); // additional +1: '/'
    sprintf(path, "%s/%s", p1, p2);
    return path;
}

static void _write_config(const struct technology_state* techstate, const char* basepath)
{
    char* path = _make_path(basepath, "config.lua");
    FILE* file = fopen(path, "w");
    fputs("return {\n", file);
    fprintf(file, "    metals = %u,\n", techstate->config->metals);
    fprintf(file, "    grid = %u,\n", techstate->config->grid);
    fprintf(file, "    allow_poly_routing = %s,\n", techstate->config->allow_poly_routing ? "true" : "false");
    fprintf(file, "    has_gatecut = %s,\n", techstate->config->has_gatecut ? "true" : "false");
    fputs("}\n", file);
    fclose(file);
    free(path);
}

static void _write_layer_export(FILE* file, const struct generics_entry* entry)
{
    fprintf(file, "        %s = {", entry->exportname);
    struct hashmap_iterator* it = hashmap_iterator_create(entry->data);
    while(hashmap_iterator_is_valid(it))
    {
        fputc(' ', file);
        const char* key = hashmap_iterator_key(it);
        struct tagged_value* value = hashmap_iterator_value(it);
        if(tagged_value_is_integer(value))
        {
            int number = tagged_value_get_integer(value);
            fprintf(file, "%s = %d,", key, number);
        }
        else if(tagged_value_is_number(value))
        {
            double number = tagged_value_get_integer(value);
            fprintf(file, "%s = %f,", key, number);
        }
        else if(tagged_value_is_string(value))
        {
            const char* str = tagged_value_get_const_string(value);
            fprintf(file, "%s = \"%s\",", key, str);
        }
        else // boolean
        {
            int b = tagged_value_get_boolean(value);
            fprintf(file, "%s = %s,", key, b ? "true" : "false");
        }
        hashmap_iterator_next(it);
    }
    hashmap_iterator_destroy(it);
    fputs(" },\n", file);
}

static void _write_layer(FILE* file, const struct generics* layer)
{
    if(!layer->prettyname && vector_size(layer->entries) == 0) // empty layer
    {
        fprintf(file, "    %s = {},\n", layer->name);
    }
    else
    {
        fprintf(file, "    %s = {\n", layer->name);
        if(layer->prettyname)
        {
            fprintf(file, "        name = \"%s\",\n", layer->prettyname);
        }
        struct vector_iterator* it = vector_iterator_create(layer->entries);
        while(vector_iterator_is_valid(it))
        {
            struct generics_entry* entry = vector_iterator_get(it);
            _write_layer_export(file, entry);
            vector_iterator_next(it);
        }
        vector_iterator_destroy(it);
        fputs("    },\n", file);
    }
}

static void _write_layermap(const struct technology_state* techstate, const char* basepath)
{
    char* path = _make_path(basepath, "layermap.lua");
    FILE* file = fopen(path, "w");
    fputs("return {\n", file);
    struct vector_iterator* it = vector_iterator_create(techstate->layertable);
    while(vector_iterator_is_valid(it))
    {
        const struct generics* layer = vector_iterator_get(it);
        _write_layer(file, layer);
        vector_iterator_next(it);
    }
    vector_iterator_destroy(it);
    fputs("}\n", file);
    fclose(file);
    free(path);
}

static void _write_viaentry(FILE* file, const struct viaentry* entry)
{
    fprintf(file, "    %s = {\n", entry->name);
    struct via_definition** viadef = entry->viadefs;
    fputs("        entries = {\n", file);
    while(*viadef)
    {
        struct via_definition* v = *viadef;
        if((v->xenclosure1 == v->xenclosure2) &&
           (v->yenclosure1 == v->yenclosure2)
        )
        {
            fprintf(
                file,
                "            { width = %d, height = %d, xspace = %d, yspace = %d, xenclosure = %d, yenclosure = %d },\n",
                v->width, v->height,
                v->xspace, v->yspace,
                v->xenclosure1, v->yenclosure1
            );
        }
        else
        {
            fprintf(
                file,
                "            { width = %d, height = %d, xspace = %d, yspace = %d, xenclosure1 = %d, yenclosure1 = %d, xenclosure2 = %d, yenclosure2 = %d },\n",
                v->width, v->height,
                v->xspace, v->yspace,
                v->xenclosure1, v->yenclosure1,
                v->xenclosure2, v->yenclosure2
            );
        }
        ++viadef;
    }
    fputs("        },\n", file);
    if(entry->fallback)
    {
        fprintf(
            file,
            "        fallback = { width = %d, height = %d },\n",
            entry->fallback->width, entry->fallback->height
        );
    }
    fputs("    },\n", file);
}

static void _write_viarules(const struct technology_state* techstate, const char* basepath)
{
    char* path = _make_path(basepath, "vias.lua");
    FILE* file = fopen(path, "w");
    fputs("return {\n", file);
    struct vector_iterator* it = vector_iterator_create(techstate->viatable);
    while(vector_iterator_is_valid(it))
    {
        const struct viaentry* layer = vector_iterator_get(it);
        _write_viaentry(file, layer);
        vector_iterator_next(it);
    }
    vector_iterator_destroy(it);
    fputs("}\n", file);
    fclose(file);
    free(path);
}

static void _write_constraint(const char* key, void* vvalue, void* vfile)
{
    FILE* file = vfile;
    struct tagged_value* value = vvalue;
    fputs("    ", file);
    fprintf(file, "[\"%s\"] = ", key);
    if(tagged_value_is_integer(value))
    {
        int number = tagged_value_get_integer(value);
        fprintf(file, "%d,", number);
    }
    else if(tagged_value_is_number(value))
    {
        double number = tagged_value_get_integer(value);
        fprintf(file, "%f,", number);
    }
    else if(tagged_value_is_string(value))
    {
        const char* str = tagged_value_get_const_string(value);
        fprintf(file, "\"%s\",", str);
    }
    else // boolean
    {
        int b = tagged_value_get_boolean(value);
        fprintf(file, "%s,", b ? "true" : "false");
    }
    fputc('\n', file);
}

static void _write_constraints(const struct technology_state* techstate, const char* basepath)
{
    char* path = _make_path(basepath, "constraints.lua");
    FILE* file = fopen(path, "w");
    fputs("return {\n", file);
    hashmap_foreach(techstate->constraints, _write_constraint, file);
    fputs("}\n", file);
    fclose(file);
    free(path);
}

void technology_write_definition_files(const struct technology_state* techstate, const char* basepath)
{
    char* path = _make_path(basepath, techstate->name);
    filesystem_mkdir(path);
    _write_config(techstate, path);
    _write_layermap(techstate, path);
    _write_viarules(techstate, path);
    _write_constraints(techstate, path);
    free(path);
}

unsigned int technology_get_grid(struct technology_state* techstate)
{
    return techstate->config->grid;
}

void technology_set_grid(struct technology_state* techstate, unsigned int grid)
{
    techstate->config->grid = grid;
}

int technology_set_feature(struct technology_state* techstate, const char* feature, int value)
{
    if(strcmp(feature, "has_gatecut") == 0)
    {
        techstate->config->has_gatecut = value;
    }
    else if(strcmp(feature, "allow_poly_routing") == 0)
    {
        techstate->config->allow_poly_routing = value;
    }
    else if(strcmp(feature, "is_soi") == 0)
    {
        techstate->config->is_soi = value;
    }
    else
    {
        return 0;
    }
    return 1;
}

unsigned int technology_get_num_metals(const struct technology_state* techstate)
{
    return techstate->config->metals;
}

void technology_set_num_metals(struct technology_state* techstate, unsigned int nummetals)
{
    techstate->config->metals = nummetals;
}

int technology_add_via_definition(struct technology_state* techstate, unsigned int startindex, unsigned int width, unsigned int height, unsigned int xspace, unsigned int yspace, unsigned int xenclosure, unsigned int yenclosure, unsigned int maxwidth, unsigned int maxheight)
{
    struct viaentry* entry = _find_viaentry(techstate, startindex);
    if(!entry)
    {
        char* vianame = _make_vianame(startindex);
        _create_via_entry_in_techstate(techstate, vianame);
        // the newly created entry owns the vianame string, therefore there is no free()
        entry = _find_viaentry(techstate, startindex);
    }
    struct via_definition* viadef = malloc(sizeof(*viadef));
    viadef->width = width;
    viadef->height = height;
    viadef->xspace = xspace;
    viadef->yspace = yspace;
    viadef->xenclosure1 = xenclosure;
    viadef->xenclosure2 = xenclosure;
    viadef->yenclosure1 = yenclosure;
    viadef->yenclosure2 = yenclosure;
    viadef->maxwidth = maxwidth;
    viadef->maxheight = maxheight;
    _insert_via_entry(&entry->viadefs, viadef);
    return 1;
}

int technology_add_via_definition_by_name(struct technology_state* techstate, const char* vianame, unsigned int width, unsigned int height, unsigned int xspace, unsigned int yspace, unsigned int xenclosure, unsigned int yenclosure, unsigned int maxwidth, unsigned int maxheight)
{
    struct viaentry* entry = _find_viaentry_by_name(techstate, vianame);
    if(!entry)
    {
        return 0;
    }
    struct via_definition* viadef = malloc(sizeof(*viadef));
    viadef->width = width;
    viadef->height = height;
    viadef->xspace = xspace;
    viadef->yspace = yspace;
    viadef->xenclosure1 = xenclosure;
    viadef->xenclosure2 = xenclosure;
    viadef->yenclosure1 = yenclosure;
    viadef->yenclosure2 = yenclosure;
    viadef->maxwidth = maxwidth;
    viadef->maxheight = maxheight;
    _insert_via_entry(&entry->viadefs, viadef);
    return 1;
}

int technology_add_via_definition_by_name2(struct technology_state* techstate, const char* vianame, unsigned int width, unsigned int height, unsigned int xspace, unsigned int yspace, unsigned int xenclosure1, unsigned int xenclosure2, unsigned int yenclosure1, unsigned int yenclosure2, unsigned int maxwidth, unsigned int maxheight)
{
    struct viaentry* entry = _find_viaentry_by_name(techstate, vianame);
    if(!entry)
    {
        return 0;
    }
    struct via_definition* viadef = malloc(sizeof(*viadef));
    viadef->width = width;
    viadef->height = height;
    viadef->xspace = xspace;
    viadef->yspace = yspace;
    viadef->xenclosure1 = xenclosure1;
    viadef->xenclosure2 = xenclosure2;
    viadef->yenclosure1 = yenclosure1;
    viadef->yenclosure2 = yenclosure2;
    viadef->maxwidth = maxwidth;
    viadef->maxheight = maxheight;
    _insert_via_entry(&entry->viadefs, viadef);
    return 1;
}

int technology_set_fallback_via(struct technology_state* techstate, unsigned int startindex, unsigned int width, unsigned int height)
{
    struct viaentry* entry = _find_viaentry(techstate, startindex);
    if(!entry)
    {
        return 0;
    }
    if(entry->fallback)
    {
        free(entry->fallback);
    }
    struct via_definition* viadef = malloc(sizeof(*viadef));
    if(!viadef)
    {
        return 0;
    }
    viadef->width = width;
    viadef->height = height;
    viadef->xspace = 0;
    viadef->yspace = 0;
    viadef->xenclosure1 = 0;
    viadef->xenclosure2 = 0;
    viadef->yenclosure1 = 0;
    viadef->yenclosure2 = 0;
    viadef->maxwidth = UINT_MAX;
    viadef->maxheight = UINT_MAX;
    entry->fallback = viadef;
    return 1;
}

int technology_set_fallback_via_by_name(struct technology_state* techstate, const char* vianame, unsigned int width, unsigned int height)
{
    struct viaentry* entry = _find_viaentry_by_name(techstate, vianame);
    if(!entry)
    {
        return 0;
    }
    if(entry->fallback)
    {
        free(entry->fallback);
    }
    struct via_definition* viadef = malloc(sizeof(*viadef));
    if(!viadef)
    {
        return 0;
    }
    viadef->width = width;
    viadef->height = height;
    viadef->xspace = 0;
    viadef->yspace = 0;
    viadef->xenclosure1 = 0;
    viadef->xenclosure2 = 0;
    viadef->yenclosure1 = 0;
    viadef->yenclosure2 = 0;
    viadef->maxwidth = UINT_MAX;
    viadef->maxheight = UINT_MAX;
    entry->fallback = viadef;
    return 1;
}

struct generics* technology_add_empty_layer(struct technology_state* techstate, const char* layername)
{
    struct generics* layer = generics_create_empty_layer(layername);
    vector_append(techstate->layertable, layer);
    return layer;
}

int technology_set_constraint_integer(struct technology_state* techstate, const char* name, int value)
{
    struct tagged_value* tv = tagged_value_create_integer(value);
    if(hashmap_exists(techstate->constraints, name))
    {
        return 0;
    }
    hashmap_insert(techstate->constraints, name, tv);
    return 1;
}

void generics_set_layer_export_integer(struct generics* layer, const char* exportname, const char* key, int value)
{
    struct generics_entry* entry = _get_export_entry(layer, exportname);
    if(!entry)
    {
        entry = _create_generics_entry(exportname);
        vector_append(layer->entries, entry);
    }
    struct tagged_value* v = tagged_value_create_integer(value);
    hashmap_insert(entry->data, key, v);
}

void generics_set_layer_export_string(struct generics* layer, const char* exportname, const char* key, const char* value)
{
    struct generics_entry* entry = _get_export_entry(layer, exportname);
    if(!entry)
    {
        entry = _create_generics_entry(exportname);
        vector_append(layer->entries, entry);
    }
    struct tagged_value* v = tagged_value_create_string(value);
    hashmap_insert(entry->data, key, v);
}

void generics_set_pretty_name(struct generics* layer, const char* prettyname)
{
    if(layer->prettyname)
    {
        free(layer->prettyname);
    }
    layer->prettyname = util_strdup(prettyname);
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

struct via_definition** technology_get_via_definitions(struct technology_state* techstate, int lowermetal)
{
    struct viaentry* entry = _find_viaentry(techstate, lowermetal);
    if(!entry)
    {
        fprintf(stderr, "could not find via definitions for via from metal %d to metal %d\n", lowermetal, lowermetal + 1);
    }
    return entry->viadefs;
}

struct via_definition* technology_get_via_fallback(struct technology_state* techstate, int lowermetal)
{
    if(!techstate->create_fallback_vias)
    {
        return NULL;
    }
    char* vianame = _make_vianame(lowermetal);
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
        //fprintf(stderr, "could not find fallback via definitions for '%s'\n", vianame);
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
    // check if non-rotated definitions are available
    if(!viadefs)
    {
        const char* found = strstr(region, "rotated");
        if(found != NULL)
        {
            // perform search again, skip last seven characters ('rotated')
            memset(contactname, 0, len + 1); // reset region identifier
            snprintf(contactname, len + 1 - 7, "contact%s", region);
            for(unsigned int i = 0; i < vector_size(techstate->viatable); ++i)
            {
                struct viaentry* entry = vector_get(techstate->viatable, i);
                if(strcmp(entry->name, contactname) == 0)
                {
                    viadefs = entry->viadefs;
                    break;
                }
            }
        }
    }
    // no viadefs found
    if(!viadefs)
    {
        fprintf(stderr, "could not find contact definitions for '%s'\n", contactname);
    }
    free(contactname);
    return viadefs;
}

struct via_definition* technology_get_contact_fallback(struct technology_state* techstate, const char* region)
{
    if(!techstate->create_fallback_vias)
    {
        return NULL;
    }
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
        //fprintf(stderr, "could not find fallback contact definitions for '%s'\n", contactname);
    }
    free(contactname);
    return fallback;
}

int technology_has_metal(const struct technology_state* techstate, int metalnum)
{
    if(metalnum < 0)
    {
        metalnum = -metalnum;
    }
    return metalnum <= (int)techstate->config->metals;
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

static int _is_mpmetal(const void* value, const void* comp)
{
    int m = *((int*)comp);
    const struct mpentry* entry = value;
    if(entry->metal == m)
    {
        return 1;
    }
    return 0;
}

int technology_has_multiple_patterning(const struct technology_state* techstate, int metalnum)
{
    int m = technology_resolve_metal(techstate, metalnum);
    int ret = vector_find_comp(techstate->config->multiple_patterning_metals, _is_mpmetal, &m);
    return ret != -1;
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

int technology_has_feature(const struct technology_state* techstate, const char* feature)
{
    if(strcmp(feature, "has_gatecut") == 0)
    {
        return techstate->config->has_gatecut;
    }
    else if(strcmp(feature, "allow_poly_routing") == 0)
    {
        return techstate->config->allow_poly_routing;
    }
    else if(strcmp(feature, "is_soi") == 0)
    {
        return techstate->config->is_soi;
    }
    else
    {
        return -1;
    }
}

static int _resolve_layer(struct generics* layer, const char* exportname, int ignoremissing)
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
                break;
            }
        }
        if(found)
        {
            // swap data
            // for mapped entries, only the first entry is used, but it is easier to keep the data here
            // and let _destroy_generics free all data, regardless if a layer is premapped or mapped
            vector_swap(layer->entries, 0, idx);
        }
        else
        {
            if(ignoremissing)
            {
                // insert NULL to represent a missing, but allowed layer
                // subsequent use of this layer needs to check for NULL and act accordingly
                vector_prepend(layer->entries, NULL);
            }
            else
            {
                return 0;
            }
        }
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
        if(!_resolve_layer(layer, exportname, techstate->ignore_missing_exports))
        {
            fprintf(
                stderr,
                "no layer data for export type '%s' found (layer: %s, number of entries: %zd)\n",
                exportname, layer->name, vector_size(layer->entries)
            );
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
        if(!_resolve_layer(layer, exportname, techstate->ignore_missing_exports))
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
    free(layer->prettyname);
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

struct technology_state* technology_initialize(const char* name)
{
    struct technology_state* techstate = malloc(sizeof(*techstate));
    techstate->name = util_strdup(name);
    techstate->layertable = vector_create(32, _destroy_layer);
    techstate->viatable = vector_create(32, _destroy_viaentry);
    techstate->config = malloc(sizeof(*techstate->config));
    memset(techstate->config, 0, sizeof(*techstate->config));
    techstate->constraints = hashmap_create(tagged_value_destroy);
    techstate->create_fallback_vias = 0;
    techstate->create_via_arrays = 1;
    techstate->ignore_premapped = 0;
    techstate->layermap = hashmap_create(NULL);
    techstate->extra_layers = vector_create(1024, _destroy_layer);
    techstate->empty_layer = generics_create_empty_layer("_EMPTY_");
    techstate->ignore_missing_layers = 0;
    techstate->ignore_missing_exports = 0;
    return techstate;
}

void technology_destroy(struct technology_state* techstate)
{
    free(techstate->name);
    vector_destroy(techstate->layertable);
    vector_destroy(techstate->viatable);

    if(techstate->config->multiple_patterning_metals)
    {
        vector_destroy(techstate->config->multiple_patterning_metals);
    }
    free(techstate->config);

    hashmap_destroy(techstate->constraints);

    hashmap_destroy(techstate->layermap);
    vector_destroy(techstate->extra_layers); // (externally) premapped layers are owned by the layer map

    _destroy_layer(techstate->empty_layer);

    free(techstate);
}

void technology_enable_fallback_vias(struct technology_state* techstate)
{
    techstate->create_fallback_vias = 1;
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

void technology_ignore_missing_layers(struct technology_state* techstate)
{
    techstate->ignore_missing_layers = 1;
}

void technology_ignore_missing_exports(struct technology_state* techstate)
{
    techstate->ignore_missing_exports = 1;
}

struct tagged_value* technology_get_dimension(const struct technology_state* techstate, const char* dimension)
{
    if(hashmap_exists(techstate->constraints, dimension))
    {
        const struct tagged_value* v = hashmap_get(techstate->constraints, dimension);
        return tagged_value_copy(v);
    }
    else
    {
        return NULL;
    }
}

unsigned int technology_get_number_of_layers(const struct technology_state* techstate)
{
    return vector_size(techstate->layertable);
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
        if(!techstate)
        {
            lua_pushinteger(L, 0);
            return 1;
        }
        else
        {
            if(hashmap_exists(techstate->constraints, dimension))
            {
                struct tagged_value* v = hashmap_get(techstate->constraints, dimension);
                int value = tagged_value_get_integer(v);
                lua_pushinteger(L, value);
                return 1;
            }
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

static int ltechnology_get_dimension_max(lua_State* L)
{
    int n = lua_gettop(L);
    int found = 0;
    int value = INT_MIN;
    for(int i = 1; i <= n; ++i)
    {
        const char* dimension = lua_tostring(L, i);
        lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
        struct technology_state* techstate = lua_touserdata(L, -1);
        lua_pop(L, 1); // pop techstate
        if(!techstate)
        {
            lua_pushinteger(L, 0);
            return 1;
        }
        else
        {
            if(hashmap_exists(techstate->constraints, dimension))
            {
                struct tagged_value* v = hashmap_get(techstate->constraints, dimension);
                int newval = tagged_value_get_integer(v);
                if(newval > value)
                {
                    value = newval;
                }
                found = 1;
            }
        }
    }
    if(found)
    {
        lua_pushinteger(L, value);
        return 1;
    }
    // FIXME: this looks ugly for multiple arguments
    lua_concat(L, n);
    lua_pushstring(L, "technology.get_dimension_max: '");
    lua_rotate(L, -2, 1);
    lua_pushstring(L, "' not found");
    lua_concat(L, 3);
    lua_error(L);
    return 1;
}

static int ltechnology_get_optional_dimension(lua_State* L)
{
    const char* dimension = lua_tostring(L, 1);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    if(!techstate)
    {
        lua_pushinteger(L, 0);
        return 1;
    }
    else
    {
        if(hashmap_exists(techstate->constraints, dimension))
        {
            struct tagged_value* v = hashmap_get(techstate->constraints, dimension);
            int value = tagged_value_get_integer(v);
            lua_pushinteger(L, value);
            return 1;
        }
        else
        {
            lua_pushinteger(L, 0);
        }
    }
    // return default value if property was not found
    lua_pushvalue(L, 2);
    return 1;
}

static int ltechnology_has_feature(lua_State* L)
{
    const char* feature = luaL_checkstring(L, 1);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    if(!techstate)
    {
        lua_pushboolean(L, 0);
        return 1;
    }
    else
    {
        int value = technology_has_feature(techstate, feature);
        if(value == -1)
        {
            lua_pushfstring(L, "technology.has_feature: tried to look up feature '%s', but this is not a known technology feature", feature);
            lua_error(L);
            return 0; // this is not reached, but keeps the compiler happy
        }
        lua_pushboolean(L, value);
        return 1;
    }
}

static int ltechnology_has_layer(lua_State* L)
{
    int result = lua_pcall(L, 1, 1, 0);
    lua_pushboolean(L, result == LUA_OK);
    return 1;
}

static int ltechnology_has_metal(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    int metal = luaL_checkinteger(L, 1);
    int hasmetal = technology_has_metal(techstate, metal);
    lua_pushboolean(L, hasmetal);
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
        { "get_dimension",                  ltechnology_get_dimension               },
        { "get_dimension_max",              ltechnology_get_dimension_max           },
        { "get_optional_dimension",         ltechnology_get_optional_dimension      },
        { "has_feature",                    ltechnology_has_feature                 },
        { "has_metal",                      ltechnology_has_metal                   },
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
        if(layer)
        {
            hashmap_insert(techstate->layermap, layername, layer);
        }
        if(techstate->ignore_missing_layers)
        {
            return techstate->empty_layer;
        }
        else
        {
            return layer; // is NULL if not found
        }
    }
    else
    {
        return hashmap_get(techstate->layermap, layername);
    }
}

char* technology_get_configfile_path(const struct vector* techpaths, const char* techname)
{
    return _get_tech_filename(techpaths, techname, "config");
}

char* technology_get_layermap_path(const struct vector* techpaths, const char* techname)
{
    return _get_tech_filename(techpaths, techname, "layermap");
}

char* technology_get_viatable_path(const struct vector* techpaths, const char* techname)
{
    return _get_tech_filename(techpaths, techname, "vias");
}

char* technology_get_constraints_path(const struct vector* techpaths, const char* techname)
{
    return _get_tech_filename(techpaths, techname, "constraints");
}

struct generics* generics_create_empty_layer(const char* name)
{
    struct generics* layer = malloc(sizeof(*layer));
    if(!layer)
    {
        return 0;
    }
    memset(layer, 0, sizeof(*layer));
    layer->name = util_strdup(name);
    layer->prettyname = NULL;
    layer->entries = vector_create(1, _destroy_entry);
    return layer;
}

static void _copy_layer_export_data(const char* key, const void* vvalue, void* vdata)
{
    const struct tagged_value* value = vvalue;
    struct tagged_value* new = tagged_value_copy(value);
    struct hashmap* data = vdata;
    hashmap_insert(data, key, new);
}

static void _copy_layer_entries(const void* ventry, void* vtarget)
{
    const struct generics_entry* entry = ventry;
    struct generics* target = vtarget;
    struct generics_entry* new = _create_generics_entry(entry->exportname);
    hashmap_foreach_const(entry->data, _copy_layer_export_data, new->data);
    vector_append(target->entries, new);
}

void generics_copy_properties(const struct generics* source, struct generics* target)
{
    target->prettyname = util_strdup(source->prettyname);
    vector_foreach1_const(source->entries, _copy_layer_entries, target);
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
    char layername[] = "ximplant";
    layername[0] = polarity;
    const struct generics* layer = _get_or_create_layer(techstate, layername);
    return layer;
}

const struct generics* generics_create_well(struct technology_state* techstate, char polarity, const char* mode)
{
    char layername[] = "nnnnxwell"; // can be [deep][n|p]well
    if(mode && strcmp(mode, "deep") == 0)
    {
        sprintf(layername, "deep%cwell", polarity);
    }
    else
    {
        sprintf(layername, "%cwell", polarity);
    }
    const struct generics* layer = _get_or_create_layer(techstate, layername);
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

const struct generics* generics_create_active(struct technology_state* techstate)
{
    const struct generics* layer = _get_or_create_layer(techstate, "active");
    return layer;
}

const struct generics* generics_create_gate(struct technology_state* techstate)
{
    const struct generics* layer = _get_or_create_layer(techstate, "gate");
    return layer;
}

const struct generics* generics_create_feol(struct technology_state* techstate, const char* layername)
{
    const struct generics* layer = _get_or_create_layer(techstate, layername);
    return layer;
}

const struct generics* generics_create_beol(struct technology_state* techstate, const char* layername)
{
    const struct generics* layer = _get_or_create_layer(techstate, layername);
    return layer;
}

const struct generics* generics_create_marker(struct technology_state* techstate, const char* what, int level)
{
    char* layername;
    if(level > 0)
    {
        size_t len = 6 + strlen(what) + util_num_digits(level); // marker + %s + %d
        layername = malloc(len + 1);
        snprintf(layername, len + 1, "%smarker%d", what, level);
    }
    else
    {
        size_t len = 6 + strlen(what); // marker + %s
        layername = malloc(len + 1);
        snprintf(layername, len + 1, "%smarker", what);
    }
    const struct generics* layer = _get_or_create_layer(techstate, layername);
    free(layername);
    return layer;
}

const struct generics* generics_create_devicelabel(struct technology_state* techstate, const char* label)
{
    const struct generics* layer = _get_or_create_layer(techstate, label);
    return layer;
}

const struct generics* generics_create_exclude(struct technology_state* techstate, const char* what)
{
    char* layername;
    size_t len = 7 + strlen(what); // exclude + %s
    layername = malloc(len + 1);
    snprintf(layername, len + 1, "%sexclude", what);
    const struct generics* layer = _get_or_create_layer(techstate, layername);
    free(layername);
    return layer;
}

const struct generics* generics_create_fill(struct technology_state* techstate, const char* what)
{
    char* layername;
    size_t len = 4 + strlen(what); // fill + %s
    layername = malloc(len + 1);
    snprintf(layername, len + 1, "%sfill", what);
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

const char* generics_get_layer_pretty_name(const struct generics* layer)
{
    return layer->prettyname;
}

const struct hashmap* generics_get_first_layer_data(const struct generics* layer)
{
    const struct generics_entry* entry = vector_get_const(layer->entries, 0);
    if(!entry)
    {
        return NULL;
    }
    return entry->data;
}

const struct hashmap* generics_get_layer_data(const struct generics* layer, const char* identifier)
{
    struct generics_entry* entry = _get_export_entry(layer, identifier);
    if(entry)
    {
        return entry->data;
    }
    return NULL;
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

