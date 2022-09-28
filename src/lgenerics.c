#include "lgenerics.h"

#include "lua/lauxlib.h"

#include "generics.h"
#include "technology.h"

static void _push_layer(lua_State* L, const struct generics* layer)
{
    // lua_pushlightuserdata expects a void*, but generics are constant
    lua_pushlightuserdata(L, (void*)layer);
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
    const struct generics* layer = generics_create_metal(layermap, techstate, num);
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.metal(%d)\nif this layer is not needed, set it to {}", num);
        lua_error(L);
    }
    _push_layer(L, layer);
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
    const struct generics* layer = generics_create_metalport(layermap, techstate, num);
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.metalport(%d)\nif this layer is not needed, set it to {}", num);
        lua_error(L);
    }
    _push_layer(L, layer);
    return 1;
}

static int lgenerics_create_metalexclude(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);
    lua_getfield(L, LUA_REGISTRYINDEX, "genericslayermap");
    struct layermap* layermap = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop layermap
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_metalexclude(layermap, techstate, num);
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.metalexclude(%d)\nif this layer is not needed, set it to {}", num);
        lua_error(L);
    }
    _push_layer(L, layer);
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
    const struct generics* layer = generics_create_viacut(layermap, techstate, metal1, metal2);
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.viacut(%d, %d)\nif this layer is not needed, set it to {}", metal1, metal2);
        lua_error(L);
    }
    _push_layer(L, layer);
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
    const struct generics* layer = generics_create_contact(layermap, techstate, region);
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.contact(\"%s\")\nif this layer is not needed, set it to {}", region);
        lua_error(L);
    }
    _push_layer(L, layer);
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
    const struct generics* layer = generics_create_oxide(layermap, techstate, num);
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.oxide(%d)\nif this layer is not needed, set it to {}", num);
        lua_error(L);
    }
    _push_layer(L, layer);
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
    const struct generics* layer = generics_create_implant(layermap, techstate, str[0]);
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.implant('%c')\nif this layer is not needed, set it to {}", str[0]);
        lua_error(L);
    }
    _push_layer(L, layer);
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
    const struct generics* layer = generics_create_vthtype(layermap, techstate, channeltype[0], vthtype);
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.vthtype('%c', %d)\nif this layer is not needed, set it to {}", channeltype[0], vthtype);
        lua_error(L);
    }
    _push_layer(L, layer);
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
    const struct generics* layer = generics_create_other(layermap, techstate, str);
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.other(\"%s\")\nif this layer is not needed, set it to {}", str);
        lua_error(L);
    }
    _push_layer(L, layer);
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
    const struct generics* layer = generics_create_otherport(layermap, techstate, str);
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.otherport(\"%s\")\nif this layer is not needed, set it to {}", str);
        lua_error(L);
    }
    _push_layer(L, layer);
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
    const struct generics* layer = generics_create_special(layermap, techstate);
    if(!layer)
    {
        lua_pushstring(L, "generics: got NULL layer: generics.special()\nif this layer is not needed, set it to {}");
        lua_error(L);
    }
    _push_layer(L, layer);
    return 1;
}

static int lgenerics_create_premapped(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "genericslayermap");
    struct layermap* layermap = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop layermap
    struct generics* layer = generics_make_layer_from_lua("_EXPLICITLY_PREMAPPED", L); // FIXME: get layername
    generics_insert_extra_layer(layermap, layer);
    _push_layer(L, layer);
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
        { "metalexclude",             lgenerics_create_metalexclude      },
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

