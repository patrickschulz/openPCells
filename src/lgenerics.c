#include "lgenerics.h"

#include "lua/lauxlib.h"

#include <stdlib.h>
#include <string.h>

#include "generics.h"

#define METAL_MAGIC_IDENTIFIER          1
#define METALPORT_MAGIC_IDENTIFIER      2
#define VIA_MAGIC_IDENTIFIER            3
#define CONTACT_MAGIC_IDENTIFIER        4
#define OXIDE_MAGIC_IDENTIFIER          5
#define IMPLANT_MAGIC_IDENTIFIER        6
#define VTHTYPE_MAGIC_IDENTIFIER        7
#define OTHER_MAGIC_IDENTIFIER          8
#define SPECIAL_MAGIC_IDENTIFIER        9

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

static generics_t* _store_mapped(lua_State* L)
{
    // count entries
    size_t num = 0;
    lua_pushnil(L);
    while(lua_next(L, -2) != 0)
    {
        lua_pop(L, 1); // pop value, keep key for next iteration
        num += 1;
    }

    generics_t* layer = malloc(sizeof(*layer));
    layer->data = calloc(num, sizeof(*layer->data));
    layer->exportnames = calloc(num, sizeof(*layer->exportnames));
    layer->size = num;
    layer->is_pre = 1;

    unsigned int i = 0;
    lua_pushnil(L);
    while (lua_next(L, -2) != 0)
    {
        const char* name = lua_tostring(L, -2);
        layer->exportnames[i] = malloc(strlen(name) + 1);
        strcpy(layer->exportnames[i], name);
        layer->data[i] = keyvaluearray_create();
        _insert_lpp_pairs(L, layer->data[i]);
        lua_pop(L, 1); // pop value, keep key for next iteration
        ++i;
    }
    return layer;
}

static generics_t* _map_and_store_layer(lua_State* L)
{
    lua_getglobal(L, "technology");
    lua_pushstring(L, "map");
    lua_rawget(L, -2);
    lua_rotate(L, -3, 2);
    lua_call(L, 1, 1);
    if(lua_isnil(L, -1)) // layer is empty
    {
        generics_t* layer = generics_create_empty_layer();
        lua_pop(L, 1); // pop and technology table
        return layer;
    }
    else
    {
        generics_t* layer = _store_mapped(L);
        lua_pop(L, 2); // pop mapped result and technology table
        return layer;
    }
}

uint32_t _hash(const uint8_t* data, size_t size)
{
    uint32_t a = 1;
    uint32_t b = 0;
    const uint32_t MODADLER = 65521;
 
    for(unsigned int i = 0; i < size; ++i)
    {
        a = (a + data[i]) % MODADLER;
        b = (b + a) % MODADLER;
        i++;
    }
    return (b << 16) | a;
}

static int lgenerics_create_metal(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);
    if(num < 0)
    {
        lua_getglobal(L, "technology");
        lua_pushstring(L, "get_config_value");
        lua_rawget(L, -2);
        lua_pushstring(L, "metals");
        lua_call(L, 1, 1);
        unsigned int nummetals = lua_tointeger(L, -1);
        lua_pop(L, 1);
        num = nummetals + num + 1;
    }

    uint32_t key = (METAL_MAGIC_IDENTIFIER << 24) | (num & 0x00ffffff);
    generics_t* layer = generics_get_layer(key);
    if(!layer)
    {
        lua_pushfstring(L, "M%d", num);
        layer = _map_and_store_layer(L);
        generics_insert_layer(key, layer);
    }
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_metalport(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);
    if(num < 0)
    {
        lua_getglobal(L, "technology");
        lua_pushstring(L, "get_config_value");
        lua_rawget(L, -2);
        lua_pushstring(L, "metals");
        lua_call(L, 1, 1);
        unsigned int nummetals = lua_tointeger(L, -1);
        lua_pop(L, 1);
        num = nummetals + num + 1;
    }

    uint32_t key = (METALPORT_MAGIC_IDENTIFIER << 24) | (num & 0x00ffffff);
    generics_t* layer = generics_get_layer(key);
    if(!layer)
    {
        lua_pushfstring(L, "M%dport", num);
        layer = _map_and_store_layer(L);
        generics_insert_layer(key, layer);
    }
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_viacut(lua_State* L)
{
    int metal1 = luaL_checkinteger(L, 1);
    int metal2 = luaL_checkinteger(L, 2);
    if(metal1 < 0 || metal2 < 0)
    {
        lua_getglobal(L, "technology");
        lua_pushstring(L, "get_config_value");
        lua_rawget(L, -2);
        lua_pushstring(L, "metals");
        lua_call(L, 1, 1);
        unsigned int nummetals = lua_tointeger(L, -1);
        lua_pop(L, 1);
        if(metal1 < 0)
        {
            metal1 = nummetals + metal1 + 1;
        }
        if(metal2 < 0)
        {
            metal2 = nummetals + metal2 + 1;
        }
    }
    if(metal1 > metal2)
    {
        int tmp = metal2;
        metal2 = metal1;
        metal1 = tmp;
    }
    uint32_t key = (VIA_MAGIC_IDENTIFIER << 24) | ((metal1 & 0x00000fff) << 12) | (metal2 & 0x00000fff);
    generics_t* layer = generics_get_layer(key);
    if(!layer)
    {
        lua_pushfstring(L, "viacutM%dM%d", metal1, metal2);
        layer = _map_and_store_layer(L);
        generics_insert_layer(key, layer);
    }
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_contact(lua_State* L)
{
    size_t len;
    const char* region = luaL_checklstring(L, 1, &len);
    uint8_t data[len + 1];
    data[0] = CONTACT_MAGIC_IDENTIFIER;
    memcpy(data + 1, region, len);

    uint32_t key = _hash(data, len + 1);
    generics_t* layer = generics_get_layer(key);
    if(!layer)
    {
        lua_pushfstring(L, "contact%s", region);
        layer = _map_and_store_layer(L);
        generics_insert_layer(key, layer);
    }
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_oxide(lua_State* L)
{
    int num = luaL_checkinteger(L, 1);

    uint32_t key = (OXIDE_MAGIC_IDENTIFIER << 24) | (num & 0x00ffffff);
    generics_t* layer = generics_get_layer(key);
    if(!layer)
    {
        lua_pushfstring(L, "oxide%d", num);
        layer = _map_and_store_layer(L);
        generics_insert_layer(key, layer);
    }
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_implant(lua_State* L)
{
    const char* str = luaL_checkstring(L, 1);
    uint32_t key = (IMPLANT_MAGIC_IDENTIFIER << 24) | (str[0] & 0x00ffffff); // the '& 0x00ffffff' is unnecessary here, but kept for completeness
    generics_t* layer = generics_get_layer(key);
    if(!layer)
    {
        lua_pushfstring(L, "%cimplant", str[0]);
        layer = _map_and_store_layer(L);
        generics_insert_layer(key, layer);
    }
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_vthtype(lua_State* L)
{
    const char* channeltype = luaL_checkstring(L, 1);
    int vthtype = luaL_checkinteger(L, 2);
    uint32_t key = (VTHTYPE_MAGIC_IDENTIFIER << 24) | ((channeltype[0] & 0x000000ff) << 16) | (vthtype & 0x0000ffff);
    generics_t* layer = generics_get_layer(key);
    if(!layer)
    {
        lua_pushfstring(L, "vthtype%c%d", channeltype[0], vthtype);
        layer = _map_and_store_layer(L);
        generics_insert_layer(key, layer);
    }
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_other(lua_State* L)
{
    size_t len;
    const char* str = luaL_checklstring(L, 1, &len);
    uint8_t data[len + 1];
    data[0] = OTHER_MAGIC_IDENTIFIER;
    memcpy(data + 1, str, len);

    uint32_t key = _hash(data, len + 1);
    generics_t* layer = generics_get_layer(key);
    if(!layer)
    {
        lua_pushstring(L, str);
        layer = _map_and_store_layer(L);
        generics_insert_layer(key, layer);
    }
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_special(lua_State* L)
{
    uint32_t key = (SPECIAL_MAGIC_IDENTIFIER << 24);
    generics_t* layer = generics_get_layer(key);
    if(!layer)
    {
        lua_pushstring(L, "special");
        layer = _map_and_store_layer(L);
        generics_insert_layer(key, layer);
    }
    lua_pushlightuserdata(L, layer);
    return 1;
}

static int lgenerics_create_premapped(lua_State* L)
{
    uint32_t key = 0xffffffff; // this key is arbitrary, but it must not collide with any other possible key
    generics_t* layer = _store_mapped(L);
    generics_insert_layer(key, layer);
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
        //{ "mapped",                   lgenerics_create_mapped            },
        { "resolve_premapped_layers", lgenerics_resolve_premapped_layers },
        { NULL,                       NULL                               }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LGENERICSMODULE);

    return 0;
}
