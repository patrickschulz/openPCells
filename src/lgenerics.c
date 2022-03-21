#include "lgenerics.h"

#include "lua/lauxlib.h"

#include "generics.h"
#include "technology.h"

static int lgenerics_create_metal(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);
    generics_t* layer = generics_create_metal(num);
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_metalport(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);
    generics_t* layer = generics_create_metalport(num);
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_viacut(lua_State* L)
{
    int metal1 = luaL_checkinteger(L, 1);
    int metal2 = luaL_checkinteger(L, 2);
    generics_t* layer = generics_create_viacut(metal1, metal2);
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_contact(lua_State* L)
{
    const char* region = luaL_checkstring(L, 1);
    generics_t* layer = generics_create_contact(region);
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_oxide(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);
    generics_t* layer = generics_create_oxide(num);
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_implant(lua_State* L)
{
    const char* str = luaL_checkstring(L, 1);
    generics_t* layer = generics_create_implant(str[0]);
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_vthtype(lua_State* L)
{
    const char* channeltype = luaL_checkstring(L, 1);
    int vthtype = luaL_checkinteger(L, 2);
    generics_t* layer = generics_create_vthtype(channeltype[0], vthtype);
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_other(lua_State* L)
{
    const char* str = luaL_checkstring(L, 1);
    generics_t* layer = generics_create_other(str);
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_special(lua_State* L)
{
    generics_t* layer = generics_create_special();
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_premapped(lua_State* L)
{
    uint32_t key = 0xffffffff; // this key is arbitrary (it is not used), but it must not collide with any other possible key
    generics_t* layer = technology_make_layer(L);
    generics_insert_extra_layer(key, layer);
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_resolve_premapped_layers(lua_State* L)
{
    const char* exportname = luaL_checkstring(L, 1);
    int ret = generics_resolve_premapped_layers(exportname);
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
        { "special",                  lgenerics_create_special           },
        { "premapped",                lgenerics_create_premapped         },
        { "resolve_premapped_layers", lgenerics_resolve_premapped_layers },
        { NULL,                       NULL                               }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LGENERICSMODULE);

    return 0;
}

