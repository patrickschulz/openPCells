#include "lgenerics.h"

#include "lua/lauxlib.h"

#include <stdlib.h>
#include <string.h>

#include "generics.h"

static void _create_layer_table(lua_State* L, struct layer_collection* layers)
{
    lua_newtable(L);
    for(unsigned int i = 0; i < layers->size; ++i)
    {
        lua_newtable(L);
        lua_pushlightuserdata(L, layers->layers[i]);
        lua_setfield(L, -2, "layer");
        lua_rawseti(L, -2, i + 1);
    }
}

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

static void _store_mapped(lua_State* L, struct layer_collection* collection)
{
    lua_len(L, -1);
    collection->size = lua_tointeger(L, -1);
    collection->layers = calloc(collection->size, sizeof(*collection->layers));
    lua_pop(L, 1);
    for(unsigned int coll = 0; coll < collection->size; ++coll)
    {
        lua_rawgeti(L, -1, coll + 1);
        // count entries
        size_t num = 0;
        lua_pushnil(L);
        while (lua_next(L, -2) != 0)
        {
            lua_pop(L, 1); // pop value, keep key for next iteration
            num += 1;
        }

        generics_t* layer = malloc(sizeof(*layer));
        layer->data = calloc(num, sizeof(*layer->data));
        layer->exportnames = calloc(num, sizeof(*layer->exportnames));
        layer->size = num;

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
        lua_pop(L, 1); // pop premapped table
        layer->is_pre = 1;
        collection->layers[coll] = layer;
    }
}

static void _map_and_store_layer(lua_State* L, struct layer_collection* layers)
{
    lua_getglobal(L, "technology");
    lua_pushstring(L, "__map");
    lua_rawget(L, -2);
    lua_rotate(L, -3, 2);
    lua_call(L, 1, 1);
    _store_mapped(L, layers);
    lua_pop(L, 2); // pop results table and technology table
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

    struct layer_collection* layers = generics_get_layers(data, sizeof(num) + 1);
    if(!layers)
    {
        layers = generics_create_layer_collection();
        lua_pushfstring(L, "M%d", num);
        _map_and_store_layer(L, layers);
        generics_insert_layers(data, sizeof(num) + 1, layers);
    }
    _create_layer_table(L, layers);
    return 1;
}

void _merge_layer_collections(struct layer_collection* into, struct layer_collection* from)
{
    size_t oldsize = into->size;
    into->size += from->size;
    into->layers = reallocarray(into->layers, into->size, sizeof(*into->layers)); // FIXME: check return value
    for(unsigned int i = 0; i < from->size; ++i)
    {
        into->layers[oldsize + i] = from->layers[i];
    }
}

static int lgenerics_create_via(lua_State* L)
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

    struct layer_collection* layers = generics_get_layers(data, sizeof(metal1) + sizeof(metal2) + 1);
    if(!layers)
    {
        layers = generics_create_layer_collection();
        lua_pushfstring(L, "M%d", metal1);
        _map_and_store_layer(L, layers);

        struct layer_collection* to_add = generics_create_layer_collection();
        lua_pushfstring(L, "M%d", metal2);
        _map_and_store_layer(L, to_add);

        _merge_layer_collections(layers, to_add);
        free(to_add->layers);
        free(to_add);

        generics_insert_layers(data, sizeof(metal1) + sizeof(metal2) + 1, layers);
    }
    _create_layer_table(L, layers);
    return 1;
}

static int lgenerics_create_other(lua_State* L)
{
    size_t len;
    const char* str = luaL_checklstring(L, 1, &len);
    uint8_t data[len + 1];
    data[0] = OTHER_MAGIC_IDENTIFIER;
    memcpy(data + 1, str, len);

    struct layer_collection* layers = generics_get_layers(data, len + 1);
    if(!layers)
    {
        layers = generics_create_layer_collection();
        lua_pushstring(L, str);
        _map_and_store_layer(L, layers);
        generics_insert_layers(data, len + 1, layers);
    }
    _create_layer_table(L, layers);
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
        { "via",                      lgenerics_create_via               },
        { "other",                    lgenerics_create_other             },
        { "resolve_premapped_layers", lgenerics_resolve_premapped_layers },
        { NULL,                       NULL                               }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LGENERICSMODULE);

    return 0;
}
