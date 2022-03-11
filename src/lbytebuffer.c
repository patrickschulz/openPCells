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

static int lbytebuffer_append_byte(lua_State* L)
{
    struct bytebuffer* buffer = lua_touserdata(L, 1);
    char datum = lua_tointeger(L, 2);
    while(buffer->size + 1 > buffer->capacity)
    {
        _resize_data(buffer, buffer->capacity * 2);
    }
    buffer->data[buffer->size] = datum;
    buffer->size += 1;
    return 0;
}

static int lbytebuffer_append_two_bytes(lua_State* L)
{
    struct bytebuffer* buffer = lua_touserdata(L, 1);
    int datum = lua_tointeger(L, 2);
    while(buffer->size + 2 > buffer->capacity)
    {
        _resize_data(buffer, buffer->capacity * 2);
    }
    int byte1 = datum >> 8;
    if(datum < 0)
    {
        byte1 += 256;
    }
    datum = datum - (byte1 << 8);
    int byte2 = datum;
    buffer->data[buffer->size + 0] = byte1;
    buffer->data[buffer->size + 1] = byte2;
    buffer->size += 2;
    return 0;
}

static int lbytebuffer_append_four_bytes(lua_State* L)
{
    struct bytebuffer* buffer = lua_touserdata(L, 1);
    int datum = lua_tointeger(L, 2);
    while(buffer->size + 4 > buffer->capacity)
    {
        _resize_data(buffer, buffer->capacity * 2);
    }
    int byte1 = datum >> 24;
    if(datum < 0)
    {
        byte1 += 256;
    }
    datum = datum - (byte1 << 24);
    int byte2 = datum >> 16;
    datum = datum - (byte2 << 16);
    int byte3 = datum >> 8;
    datum = datum - (byte3 << 8);
    int byte4 = datum;
    buffer->data[buffer->size + 0] = byte1;
    buffer->data[buffer->size + 1] = byte2;
    buffer->data[buffer->size + 2] = byte3;
    buffer->data[buffer->size + 3] = byte4;
    buffer->size += 4;
    return 0;
}

static int lbytebuffer_string(lua_State* L)
{
    struct bytebuffer* buffer = lua_touserdata(L, 1);
    size_t len;
    const char* data = lua_tolstring(L, 2, &len);
    while(buffer->size + len > buffer->capacity)
    {
        _resize_data(buffer, buffer->capacity * 2);
    }
    for(unsigned int i = 0; i < len; ++i)
    {
        buffer->data[buffer->size + i] = data[i];
    }
    buffer->size += len;
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
        { "append_byte",       lbytebuffer_append_byte       },
        { "append_two_bytes",  lbytebuffer_append_two_bytes  },
        { "append_four_bytes", lbytebuffer_append_four_bytes },
        { "append_string",     lbytebuffer_string            },
        { "str",               lbytebuffer_tostring          },
        { NULL,                NULL                          }
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
