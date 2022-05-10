#include "lgenerics.h"

#include "lua/lauxlib.h"

#include "generics.h"
#include "technology.h"

static void _push_layer(lua_State* L, generics_t* layer, const char* info)
{
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.%s\nif this layer is not needed, set it to {}", info);
        lua_error(L);
    }
    lua_pushlightuserdata(L, layer);
}

static int lgenerics_create_metal(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);
    lua_getfield(L, LUA_REGISTRYINDEX, "genericslayermap");
    struct layermap* layermap = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop layermap
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    generics_t* layer = generics_create_metal(layermap, techstate, num);
    _push_layer(L, layer, "metal");
    return 1;
}

static int lgenerics_create_metalport(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);
    lua_getfield(L, LUA_REGISTRYINDEX, "genericslayermap");
    struct layermap* layermap = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop layermap
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    generics_t* layer = generics_create_metalport(layermap, techstate, num);
    _push_layer(L, layer, "metalport");
    return 1;
}

static int lgenerics_create_viacut(lua_State* L)
{
    int metal1 = luaL_checkinteger(L, 1);
    int metal2 = luaL_checkinteger(L, 2);
    lua_getfield(L, LUA_REGISTRYINDEX, "genericslayermap");
    struct layermap* layermap = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop layermap
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    generics_t* layer = generics_create_viacut(layermap, techstate, metal1, metal2);
    _push_layer(L, layer, "viacut");
    return 1;
}

static int lgenerics_create_contact(lua_State* L)
{
    const char* region = luaL_checkstring(L, 1);
    lua_getfield(L, LUA_REGISTRYINDEX, "genericslayermap");
    struct layermap* layermap = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop layermap
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    generics_t* layer = generics_create_contact(layermap, techstate, region);
    _push_layer(L, layer, "contact");
    return 1;
}

static int lgenerics_create_oxide(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);
    lua_getfield(L, LUA_REGISTRYINDEX, "genericslayermap");
    struct layermap* layermap = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop layermap
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    generics_t* layer = generics_create_oxide(layermap, techstate, num);
    _push_layer(L, layer, "oxide");
    return 1;
}

static int lgenerics_create_implant(lua_State* L)
{
    const char* str = luaL_checkstring(L, 1);
    lua_getfield(L, LUA_REGISTRYINDEX, "genericslayermap");
    struct layermap* layermap = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop layermap
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    generics_t* layer = generics_create_implant(layermap, techstate, str[0]);
    _push_layer(L, layer, "implant");
    return 1;
}

static int lgenerics_create_vthtype(lua_State* L)
{
    const char* channeltype = luaL_checkstring(L, 1);
    int vthtype = luaL_checkinteger(L, 2);
    lua_getfield(L, LUA_REGISTRYINDEX, "genericslayermap");
    struct layermap* layermap = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop layermap
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    generics_t* layer = generics_create_vthtype(layermap, techstate, channeltype[0], vthtype);
    _push_layer(L, layer, "vthtype");
    return 1;
}

static int lgenerics_create_other(lua_State* L)
{
    const char* str = luaL_checkstring(L, 1);
    lua_getfield(L, LUA_REGISTRYINDEX, "genericslayermap");
    struct layermap* layermap = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop layermap
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    generics_t* layer = generics_create_other(layermap, techstate, str);
    _push_layer(L, layer, "other");
    return 1;
}

static int lgenerics_create_otherport(lua_State* L)
{
    const char* str = luaL_checkstring(L, 1);
    lua_getfield(L, LUA_REGISTRYINDEX, "genericslayermap");
    struct layermap* layermap = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop layermap
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    generics_t* layer = generics_create_otherport(layermap, techstate, str);
    _push_layer(L, layer, "otherport");
    return 1;
}

static int lgenerics_create_special(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "genericslayermap");
    struct layermap* layermap = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop layermap
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    generics_t* layer = generics_create_special(layermap, techstate);
    _push_layer(L, layer, "special");
    return 1;
}

static int lgenerics_create_premapped(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "genericslayermap");
    struct layermap* layermap = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop layermap
    generics_t* layer = technology_make_layer("_EXPLICIT_PREMAPPED", L); // FIXME: get layername
    generics_insert_extra_layer(layermap, layer);
    _push_layer(L, layer, "premapped");
    return 1;
}

static int lgenerics_resolve_premapped_layers(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "genericslayermap");
    struct layermap* layermap = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop layermap
    const char* exportname = luaL_checkstring(L, 1);
    int ret = generics_resolve_premapped_layers(layermap, exportname);
    lua_pushboolean(L, ret);
    return 1;
}

int open_lgenerics_lib(lua_State* L)
{
    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { "metal",                    lgenerics_create_metal             },
        { "metalport",                lgenerics_create_metalport         },
        { "viacut",                   lgenerics_create_viacut            },
        { "contact",                  lgenerics_create_contact           },
        { "oxide",                    lgenerics_create_oxide             },
        { "implant",                  lgenerics_create_implant           },
        { "vthtype",                  lgenerics_create_vthtype           },
        { "other",                    lgenerics_create_other             },
        { "otherport",                lgenerics_create_otherport         },
        { "special",                  lgenerics_create_special           },
        { "premapped",                lgenerics_create_premapped         },
        { "resolve_premapped_layers", lgenerics_resolve_premapped_layers },
        { NULL,                       NULL                               }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LGENERICSMODULE);

    return 0;
}

