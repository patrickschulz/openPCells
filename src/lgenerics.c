#include "lgenerics.h"

#include "lua/lauxlib.h"

#include "technology.h"

static void _push_layer(lua_State* L, const struct generics* layer)
{
    // lua_pushlightuserdata expects a void*, but generics are constant
    lua_pushlightuserdata(L, (void*)layer);
}

static int lgenerics_create_metal(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_metal(techstate, num);
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.metal(%d)\nif this layer is not needed, set it to {}", num);
        lua_error(L);
    }
    _push_layer(L, layer);
    return 1;
}

static int lgenerics_create_mptmetal(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);
    int mask = luaL_checkinteger(L, 2);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_mptmetal(techstate, num, mask);
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.mptmetal(%d, %d)\nif this layer is not needed, set it to {}", num, mask);
        lua_error(L);
    }
    _push_layer(L, layer);
    return 1;
}

static int lgenerics_create_metalport(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_metalport(techstate, num);
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.metalport(%d)\nif this layer is not needed, set it to {}", num);
        lua_error(L);
    }
    _push_layer(L, layer);
    return 1;
}

static int lgenerics_create_metalfill(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_metalfill(techstate, num);
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.metalfill(%d)\nif this layer is not needed, set it to {}", num);
        lua_error(L);
    }
    _push_layer(L, layer);
    return 1;
}

static int lgenerics_create_mptmetalfill(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);
    int mask = luaL_checkinteger(L, 2);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_mptmetalfill(techstate, num, mask);
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.mptmetalfill(%d, %d)\nif this layer is not needed, set it to {}", num, mask);
        lua_error(L);
    }
    _push_layer(L, layer);
    return 1;
}

static int lgenerics_create_metalexclude(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_metalexclude(techstate, num);
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
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_viacut(techstate, metal1, metal2);
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
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_contact(techstate, region);
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
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_oxide(techstate, num);
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
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_implant(techstate, str[0]);
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.implant('%c')\nif this layer is not needed, set it to {}", str[0]);
        lua_error(L);
    }
    _push_layer(L, layer);
    return 1;
}

static int lgenerics_create_well(lua_State* L)
{
    const char* str = luaL_checkstring(L, 1);
    const char* mode = NULL;
    if(lua_gettop(L) == 2)
    {
        mode = luaL_checkstring(L, 2);
    }
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_well(techstate, str[0], mode);
    if(!layer)
    {
        if(mode)
        {
            lua_pushfstring(L, "generics: got NULL layer: generics.well('%c', \"%s\")\nif this layer is not needed, set it to {}", str[0], mode);
        }
        else
        {
            lua_pushfstring(L, "generics: got NULL layer: generics.well('%c')\nif this layer is not needed, set it to {}", str[0]);
        }
        lua_error(L);
    }
    _push_layer(L, layer);
    return 1;
}

static int lgenerics_create_vthtype(lua_State* L)
{
    const char* channeltype = luaL_checkstring(L, 1);
    int vthtype = luaL_checkinteger(L, 2);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_vthtype(techstate, channeltype[0], vthtype);
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.vthtype('%c', %d)\nif this layer is not needed, set it to {}", channeltype[0], vthtype);
        lua_error(L);
    }
    _push_layer(L, layer);
    return 1;
}

static int lgenerics_create_active(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_active(techstate);
    if(!layer)
    {
        lua_pushstring(L, "generics: got NULL layer: generics.active()\nif this layer is not needed, set it to {}");
        lua_error(L);
    }
    _push_layer(L, layer);
    return 1;
}

static int lgenerics_create_gate(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_gate(techstate);
    if(!layer)
    {
        lua_pushstring(L, "generics: got NULL layer: generics.gate()\nif this layer is not needed, set it to {}");
        lua_error(L);
    }
    _push_layer(L, layer);
    return 1;
}

static int lgenerics_create_feol(lua_State* L)
{
    const char* str = luaL_checkstring(L, 1);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_feol(techstate, str);
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.feol(\"%s\")\nif this layer is not needed, set it to {}", str);
        lua_error(L);
    }
    _push_layer(L, layer);
    return 1;
}

static int lgenerics_create_beol(lua_State* L)
{
    const char* str = luaL_checkstring(L, 1);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_beol(techstate, str);
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.beol(\"%s\")\nif this layer is not needed, set it to {}", str);
        lua_error(L);
    }
    _push_layer(L, layer);
    return 1;
}

static int lgenerics_create_marker(lua_State* L)
{
    const char* what = luaL_checkstring(L, 1);
    int level = luaL_optinteger(L, 2, 0);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_marker(techstate, what, level);
    if(!layer)
    {
        if(level > 0)
        {
            lua_pushfstring(L, "generics: got NULL layer: generics.marker(\"%s\", %d)\nif this layer is not needed, set it to {}", what, level);
        }
        else
        {
            lua_pushfstring(L, "generics: got NULL layer: generics.marker(\"%s\")\nif this layer is not needed, set it to {}", what);
        }
        lua_error(L);
    }
    _push_layer(L, layer);
    return 1;
}

static int lgenerics_create_exclude(lua_State* L)
{
    const char* what = luaL_checkstring(L, 1);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_exclude(techstate, what);
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.exclude(\"%s\")\nif this layer is not needed, set it to {}", what);
        lua_error(L);
    }
    _push_layer(L, layer);
    return 1;
}

static int lgenerics_create_fill(lua_State* L)
{
    const char* what = luaL_checkstring(L, 1);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_fill(techstate, what);
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.fill(\"%s\")\nif this layer is not needed, set it to {}", what);
        lua_error(L);
    }
    _push_layer(L, layer);
    return 1;
}

static int lgenerics_create_other(lua_State* L)
{
    const char* str = luaL_checkstring(L, 1);
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_other(techstate, str);
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
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_otherport(techstate, str);
    if(!layer)
    {
        lua_pushfstring(L, "generics: got NULL layer: generics.otherport(\"%s\")\nif this layer is not needed, set it to {}", str);
        lua_error(L);
    }
    _push_layer(L, layer);
    return 1;
}

static int lgenerics_create_outline(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_outline(techstate);
    if(!layer)
    {
        lua_pushstring(L, "generics: got NULL layer: generics.outline()\nif this layer is not needed, set it to {}");
        lua_error(L);
    }
    _push_layer(L, layer);
    return 1;
}

static int lgenerics_create_special(lua_State* L)
{
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const struct generics* layer = generics_create_special(techstate);
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
    lua_getfield(L, LUA_REGISTRYINDEX, "techstate");
    struct technology_state* techstate = lua_touserdata(L, -1);
    lua_pop(L, 1); // pop techstate
    const char* layername = lua_tostring(L, 1);
    if(!layername)
    {
        layername = "_EXPLICITLY_PREMAPPED";
    }
    const struct generics* layer = generics_create_layer_from_lua(techstate, layername, L);
    _push_layer(L, layer);
    return 1;
}

void* generics_check_generics(lua_State* L, int idx)
{
    if(lua_type(L, idx) != LUA_TLIGHTUSERDATA)
    {
        lua_pushfstring(L, "expected a generic layer at argument #%d, got %s", idx, lua_typename(L, lua_type(L, idx)));
        lua_error(L);
    }
    return lua_touserdata(L, idx);
}

int open_lgenerics_lib(lua_State* L)
{
    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { "metal",                    lgenerics_create_metal             },
        { "mptmetal",                 lgenerics_create_mptmetal          },
        { "metalport",                lgenerics_create_metalport         },
        { "metalfill",                lgenerics_create_metalfill         },
        { "mptmetalfill",             lgenerics_create_mptmetalfill      },
        { "metalexclude",             lgenerics_create_metalexclude      },
        { "viacut",                   lgenerics_create_viacut            },
        { "contact",                  lgenerics_create_contact           },
        { "oxide",                    lgenerics_create_oxide             },
        { "implant",                  lgenerics_create_implant           },
        { "well",                     lgenerics_create_well              },
        { "vthtype",                  lgenerics_create_vthtype           },
        { "active",                   lgenerics_create_active            },
        { "gate",                     lgenerics_create_gate              },
        { "feol",                     lgenerics_create_feol              },
        { "beol",                     lgenerics_create_beol              },
        { "marker",                   lgenerics_create_marker            },
        { "exclude",                  lgenerics_create_exclude           },
        { "fill",                     lgenerics_create_fill              },
        { "other",                    lgenerics_create_other             },
        { "otherport",                lgenerics_create_otherport         },
        { "outline",                  lgenerics_create_outline           },
        { "special",                  lgenerics_create_special           },
        { "premapped",                lgenerics_create_premapped         },
        { NULL,                       NULL                               }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LGENERICSMODULE);
    return 0;
}

