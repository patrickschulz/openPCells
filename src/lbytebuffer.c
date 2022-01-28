#include "lbytebuffer.h"

#include "lua/lauxlib.h"

#include <stdlib.h>

void _resize_data(struct bytebuffer* buffer, size_t capacity)
{
    buffer->capacity = capacity;
    char* data = realloc(buffer->data, sizeof(char) * buffer->capacity);
    buffer->data = data;
}

void _destroy_data(struct bytebuffer* buffer)
{
    free(buffer->data);
}

static int lbytebuffer_create(lua_State* L)
{
    int size = luaL_optinteger(L, 1, 1024 * 1024);
    struct bytebuffer* buffer = lua_newuserdatauv(L, sizeof(struct bytebuffer), 0);
    buffer->data = NULL;
    buffer->size = 0;
    _resize_data(buffer, size);
    luaL_setmetatable(L, LBYTEBUFFERMETA);
    return 1;
}

static int lbytebuffer_destroy(lua_State* L)
{

    struct bytebuffer* buffer = lua_touserdata(L, 1);
    _destroy_data(buffer);
    return 0;
}

static int lbytebuffer_append(lua_State* L)
{
    struct bytebuffer* buffer = lua_touserdata(L, 1);
    char datum = lua_tointeger(L, 2);
    if(buffer->size == buffer->capacity)
    {
        _resize_data(buffer, buffer->capacity * 2);
    }
    buffer->data[buffer->size] = datum;
    buffer->size += 1;
    return 0;
}

static int lbytebuffer_tostring(lua_State* L)
{
    struct bytebuffer* buffer = lua_touserdata(L, 1);
    lua_pushlstring(L, buffer->data, buffer->size);
    return 1;
}

int open_lbytebuffer_lib(lua_State* L)
{
    static const luaL_Reg metafuncs[] =
    {
        { "append", lbytebuffer_append   },
        { "str",    lbytebuffer_tostring },
        { NULL,     NULL                 }
    };
    // create metatable for points
    luaL_newmetatable(L, LBYTEBUFFERMETA);

    // add __index
    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2); 
    lua_rawset(L, -3);

    // add __gc
    lua_pushstring(L, "__gc");
    lua_pushcfunction(L, lbytebuffer_destroy);
    lua_rawset(L, -3);

    // set meta functions
    luaL_setfuncs(L, metafuncs, 0);

    // remove metatable from stack
    lua_pop(L, 1);

    // create module function table
    static const luaL_Reg modfuncs[] =
    {
        { "create", lbytebuffer_create   },
        { NULL,     NULL                 }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LBYTEBUFFERMODULE);
    return 0;
}
