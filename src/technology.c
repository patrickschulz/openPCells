#include "technology.h"

#include "lua/lauxlib.h"
#include <stdlib.h>
#include <string.h>

#include "util.h"
#include "lua_util.h"
#include "vector.h"
#include "tagged_value.h"

struct technology_state {
    struct vector* layertable; // stores generics_t*
    struct vector* viatable; // stores struct viaentry*
    struct technology_config* config;
    struct hashmap* constraints;
    struct vector* techpaths; // stores strings
    int create_via_arrays;
};

void technology_add_techpath(struct technology_state* techstate, const char* path)
{
    vector_append(techstate->techpaths, util_copy_string(path));
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

struct viaentry
{
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

int technology_load_layermap(struct technology_state* techstate, const char* name)
{
    lua_State* L = util_create_minimal_lua_state();
    int ret = luaL_dofile(L, name);
    if(ret != LUA_OK)
    {
        const char* msg = lua_tostring(L, -1);
        fprintf(stderr, "error while loading layermap:\n  %s\n", msg);
        return 0;
    }
    lua_pushnil(L);
    while(lua_next(L, -2) != 0)
    {
        const char* layername = lua_tostring(L, -2);
        lua_getfield(L, -1, "layer");
        generics_t* layer = generics_make_layer_from_lua(layername, L);
        vector_append(techstate->layertable, layer);
        lua_pop(L, 1); // pop layer table
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
        return 0;
    }
    lua_pushnil(L);
    while(lua_next(L, -2) != 0)
    {
        char* vianame = util_copy_string(lua_tostring(L, -2));
        struct via_definition** viadefs = _read_via(L);
        struct via_definition* fallback = _read_via_fallback(L);
        _insert_via(techstate, vianame, viadefs, fallback);
        lua_pop(L, 1); // pop value, keep key for next iteration
    }
    lua_close(L);
    return 0;
}

int technology_load_config(struct technology_state* techstate, const char* name)
{
    lua_State* L = util_create_minimal_lua_state();
    int ret = luaL_dofile(L, name);
    if(ret != LUA_OK)
    {
        puts("error while loading config");
        return 0;
    }
    lua_getfield(L, -1, "metals");
    techstate->config->metals = lua_tointeger(L, -1);
    lua_pop(L, 1); // pop config table
    lua_close(L);
    return 0;
}

int technology_load_constraints(struct technology_state* techstate, const char* name)
{
    lua_State* L = util_create_minimal_lua_state();
    int ret = luaL_dofile(L, name);
    if(ret != LUA_OK)
    {
        puts("error while loading constraints");
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

int technology_load(struct technology_state* techstate, const char* techname)
{
    char* layermapname = _get_tech_filename(techstate, techname, "layermap");
    if(!layermapname)
    {
        printf("technology: no techfile for technology '%s' found", techname);
        free(layermapname);
        return 0;
    }
    int ret;
    ret = technology_load_layermap(techstate, layermapname);
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
    technology_load_config(techstate, configname);
    free(configname);

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

generics_t* technology_get_layer(struct technology_state* techstate, const char* layername)
{
    for(unsigned int i = 0; i < vector_size(techstate->layertable); ++i)
    {
        generics_t* layer = vector_get(techstate->layertable, i);
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

int technology_resolve_metal(struct technology_state* techstate, int metalnum)
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

struct technology_state* technology_initialize(void)
{
    struct technology_state* techstate = malloc(sizeof(*techstate));
    techstate->layertable = vector_create(32);
    techstate->viatable = vector_create(32);
    techstate->config = malloc(sizeof(*techstate->config));
    techstate->constraints = hashmap_create();
    techstate->techpaths = vector_create(32);
    techstate->create_via_arrays = 1;
    return techstate;
}

void technology_destroy(struct technology_state* techstate)
{
    vector_destroy(techstate->layertable, generics_destroy_layer);

    for(unsigned int i = 0; i < vector_size(techstate->viatable); ++i)
    {
        struct viaentry* entry = vector_get(techstate->viatable, i);
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
    vector_destroy(techstate->viatable, NULL);

    free(techstate->config);

    hashmap_destroy(techstate->constraints, tagged_value_destroy);

    vector_destroy(techstate->techpaths, free);

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

static int ltechnology_get_dimension(lua_State* L)
{
    const char* dimension = lua_tostring(L, 1);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    if(hashmap_exists(techstate->constraints, dimension))
    {
        struct tagged_value* v = hashmap_get(techstate->constraints, dimension);
        int value = tagged_value_get_integer(v);
        lua_pushinteger(L, value);
    }
    else
    {
        lua_pushfstring(L, "technology: no dimension '%s' found", dimension);
        lua_error(L);
    }
    return 1;
}

static int ltechnology_has_layer(lua_State* L)
{
    generics_t* layer = lua_touserdata(L, 1);
    lua_pushboolean(L, !generics_is_empty(layer));
    return 1;
}

int open_ltechnology_lib(lua_State* L)
{
    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { "list_techpaths", ltechnology_list_techpaths },
        { "get_dimension",  ltechnology_get_dimension  },
        { "has_layer",      ltechnology_has_layer      },
        { NULL,             NULL                       }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "technology");

    return 0;
}
