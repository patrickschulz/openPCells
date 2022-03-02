#include "lgenerics.h"

#include "lua/lauxlib.h"

#include <stdlib.h>
#include <string.h>

#include "generics.h"

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
        generics_t* layer = malloc(sizeof(*layer));
        layer->size = 0;
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

    uint8_t data[sizeof(num) + 1];
    data[0] = METAL_MAGIC_IDENTIFIER;
    memcpy(data + 1, &num, sizeof(num));

    generics_t* layer = generics_get_layer(data, sizeof(num) + 1);
    if(!layer)
    {
        lua_pushfstring(L, "M%d", num);
        layer = _map_and_store_layer(L);
        generics_insert_layer(data, sizeof(num) + 1, layer);
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
    uint8_t data[sizeof(metal1) + sizeof(metal2) + 1];
    data[0] = VIA_MAGIC_IDENTIFIER;
    memcpy(data + 1, &metal1, sizeof(metal1));
    memcpy(data + 1 + sizeof(metal1), &metal2, sizeof(metal2));

    generics_t* layer = generics_get_layer(data, sizeof(metal1) + sizeof(metal2) + 1);
    if(!layer)
    {
        lua_pushfstring(L, "viacutM%dM%d", metal1, metal2);
        layer = _map_and_store_layer(L);
        generics_insert_layer(data, sizeof(metal1) + sizeof(metal2) + 1, layer);
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

    generics_t* layer = generics_get_layer(data, len + 1);
    if(!layer)
    {
        lua_pushfstring(L, "contact%s", region);
        layer = _map_and_store_layer(L);
        generics_insert_layer(data, len + 1, layer);
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

    generics_t* layer = generics_get_layer(data, len + 1);
    if(!layer)
    {
        lua_pushstring(L, str);
        layer = _map_and_store_layer(L);
        generics_insert_layer(data, len + 1, layer);
    }
    lua_pushlightuserdata(L, layer);
    return 1;
}


static int lgenerics_resolve_premapped_layers(lua_State* L)
{
    const char* exportname = luaL_checkstring(L, 1);
    generics_resolve_premapped_layers(exportname);
    return 0;
}

int open_lgenerics_lib(lua_State* L)
{
    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { "metal",                    lgenerics_create_metal             },
        { "viacut",                   lgenerics_create_viacut            },
        { "contact",                  lgenerics_create_contact           },
        { "other",                    lgenerics_create_other             },
        { "resolve_premapped_layers", lgenerics_resolve_premapped_layers },
        { NULL,                       NULL                               }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LGENERICSMODULE);

    return 0;
}
