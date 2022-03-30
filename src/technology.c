#include "technology.h"

#include "lua/lauxlib.h"
#include <stdlib.h>
#include <string.h>

#include "util.h"

static void _insert_lpp_pairs(lua_State* L, struct keyvaluearray* map)
{
    lua_pushnil(L);
    while (lua_next(L, -2) != 0)
    {
        switch(lua_type(L, -1))
        {
            case LUA_TNUMBER:
                keyvaluearray_add_int(map, lua_tostring(L, -2), lua_tointeger(L, -1));
                break;
            case LUA_TSTRING:
                keyvaluearray_add_string(map, lua_tostring(L, -2), lua_tostring(L, -1));
                break;
            case LUA_TBOOLEAN:
                keyvaluearray_add_boolean(map, lua_tostring(L, -2), lua_toboolean(L, -1));
                break;
        }
        lua_pop(L, 1); // pop value, keep key for next iteration
    }
}

struct viaentry
{
    char* name;
    struct via_definition** viadefs;
    struct via_definition* fallback;
};


static void _insert_layer(struct technology_state* techstate, generics_t* layer)
{
    vector_append(techstate->layertable, layer);
}

generics_t* technology_make_layer(const char* layername, lua_State* L)
{
    generics_t* layer;
    if(lua_isnil(L, -1))
    {
        layer = generics_create_empty_layer(layername);
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

        layer = generics_create_premapped_layer(layername, num);
        unsigned int i = 0;
        lua_pushnil(L);
        while (lua_next(L, -2) != 0)
        {
            const char* name = lua_tostring(L, -2);
            layer->exportnames[i] = util_copy_string(name);
            layer->data[i] = keyvaluearray_create();
            _insert_lpp_pairs(L, layer->data[i]);
            lua_pop(L, 1); // pop value, keep key for next iteration
            ++i;
        }
    }
    return layer;
}

int technology_load_layermap(lua_State* L)
{
    const char* name = lua_tostring(L, 1);
    int ret = luaL_dofile(L, name);
    if(ret != LUA_OK)
    {
        puts("error while loading layermap");
        return 0;
    }
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    lua_pushnil(L);
    while(lua_next(L, -2) != 0)
    {
        const char* layername = lua_tostring(L, -2);
        lua_getfield(L, -1, "layer");
        generics_t* layer = technology_make_layer(layername, L);
        _insert_layer(techstate, layer);
        lua_pop(L, 1); // pop layer table
        lua_pop(L, 1); // pop value, keep key for next iteration
    }
    return 0;
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

int technology_load_viadefinitions(lua_State* L)
{
    const char* name = lua_tostring(L, 1);
    int ret = luaL_dofile(L, name);
    if(ret != LUA_OK)
    {
        puts("error while loading layermap");
        return 0;
    }
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    lua_pushnil(L);
    while(lua_next(L, -2) != 0)
    {
        char* vianame = util_copy_string(lua_tostring(L, -2));
        struct via_definition** viadefs = _read_via(L);
        struct via_definition* fallback = _read_via_fallback(L);
        _insert_via(techstate, vianame, viadefs, fallback);
        lua_pop(L, 1); // pop value, keep key for next iteration
    }
    return 0;
}

int technology_load_config(lua_State* L)
{
    const char* name = lua_tostring(L, 1);
    int ret = luaL_dofile(L, name);
    if(ret != LUA_OK)
    {
        puts("error while loading layermap");
        return 0;
    }
    lua_getfield(L, -1, "metals");
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    techstate->config->metals = lua_tointeger(L, -1);
    lua_pop(L, 1); // pop config table
    return 0;
}

generics_t* technology_get_layer(struct technology_state* techstate, const char* layername)
{
    for(unsigned int i = 0; i < vector_size(techstate->layertable); ++i)
    {
        generics_t* layer = vector_get(techstate->layertable, i);
        if(strcmp(layer->name, layername) == 0)
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
    techstate->layertable = vector_create();
    techstate->viatable = vector_create();
    techstate->config = malloc(sizeof(*techstate->config));
    return techstate;
}

void technology_destroy(struct technology_state* techstate)
{
    for(unsigned int i = 0; i < vector_size(techstate->layertable); ++i)
    {
        generics_t* layer = vector_get(techstate->layertable, i);
        generics_destroy_layer(layer);
    }
    vector_destroy(techstate->layertable, NULL);

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

    free(techstate);
}

int open_ltechnology_lib(lua_State* L)
{
    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { "load_layermap",       technology_load_layermap       },
        { "load_viadefinitions", technology_load_viadefinitions },
        { "load_config",         technology_load_config         },
        { NULL,                  NULL                           }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "technology");

    return 0;
}
