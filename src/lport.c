#include "lport.h"

#include "lua/lauxlib.h"

#include "generics.h"

static int lport_create(lua_State* L)
{
    lua_newtable(L);
    luaL_setmetatable(L, "port");
    lua_pushvalue(L, 1);
    lua_setfield(L, -2, "name");
    lua_pushvalue(L, 2);
    lua_setfield(L, -2, "layer");
    lua_pushvalue(L, 3);
    lua_setfield(L, -2, "where");
    return 1;
}

static int lport_get_layer(lua_State* L)
{
    lua_getfield(L, -1, "layer");
    generics_t* layer = lua_touserdata(L, -1);
    if(layer->is_pre) // only return mapped layers to lua (FIXME: only temporarily, until this works properly)
    {
        lua_pushstring(L, "port.get_layer: can't get premapped layer");
        lua_error(L);
    }
    else
    {
        struct keyvaluearray* data = layer->data[0];
        lua_newtable(L);
        for(unsigned int i = 0; i < data->size; ++i)
        {
            lua_pushstring(L, data->pairs[i]->key);
            switch(data->pairs[i]->tag)
            {
                case INT:
                    lua_pushinteger(L, *(int*)data->pairs[i]->value);
                    break;
                case STRING:
                    lua_pushstring(L, (const char*)data->pairs[i]->value);
                    break;
                case BOOLEAN:
                    lua_pushboolean(L, *(int*)data->pairs[i]->value);
                    break;
            }
            lua_rawset(L, -3);
        }
    }
    return 1;
}

int open_lport_lib(lua_State* L)
{
    luaL_newmetatable(L, "port");
    // add __index
    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2); 
    lua_rawset(L, -3);
    static const luaL_Reg modfuncs[] =
    {
        { "create",    lport_create    },
        { "get_layer", lport_get_layer },
        { NULL,        NULL            }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "port");
    return 0;
}
