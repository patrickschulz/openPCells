#include "lstringbuffer.h"

#include "lua/lua.h"
#include "lua/lauxlib.h"

#include <stdlib.h>
#include <string.h>

struct lstringbuffer_t
{
    char* data;
    size_t capacity;
    size_t length;
};

static void bufalloc(struct lstringbuffer_t* buf, size_t length)
{
    buf->data = realloc(buf->data, length);
    buf->capacity = length;
}

static int lstringbuffer_destroy(lua_State* L)
{
    struct lstringbuffer_t* buf = lua_touserdata(L, 1);
    free(buf->data);
    buf->capacity = 0;
    buf->length = 0;
    return 0;
}

static int lstringbuffer_create(lua_State* L)
{
    struct lstringbuffer_t* buf = lua_newuserdatauv(L, sizeof(struct lstringbuffer_t), 0);
    luaL_setmetatable(L, LSTRINGBUFFERMETA);
    buf->data = NULL;
    buf->length = 0;
    bufalloc(buf, 512);
    return 1;
}

static int lstringbuffer_append(lua_State* L)
{
    if(lua_gettop(L) != 2)
    {
        lua_pushstring(L, "append: expecting two arguments");
        lua_error(L);
    }
    size_t len;
    struct lstringbuffer_t* buf = lua_touserdata(L, 1);
    const char* str = lua_tolstring(L, 2, &len);
    while(len > buf->capacity - buf->length)
    {
        bufalloc(buf, 2 * buf->capacity);
    }
    strncpy(buf->data + buf->length, str, len);
    buf->length += len;
    return 0;
}

static int lstringbuffer_tostring(lua_State* L)
{
    struct lstringbuffer_t* buf = lua_touserdata(L, 1);
    lua_pushlstring(L, buf->data, buf->length);
    return 1;
}

int open_lstringbuffer_lib(lua_State* L)
{
    // create metatable for points
    luaL_newmetatable(L, LSTRINGBUFFERMETA);
    // add __index
    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2); 
    lua_rawset(L, -3);
    // add __gc
    lua_pushstring(L, "__gc");
    lua_pushcfunction(L, lstringbuffer_destroy); 
    lua_rawset(L, -3);
    // add __tostring
    lua_pushstring(L, "__tostring");
    lua_pushcfunction(L, lstringbuffer_tostring); 
    lua_rawset(L, -3);
    // add append
    lua_pushstring(L, "append");
    lua_pushcfunction(L, lstringbuffer_append); 
    lua_rawset(L, -3);
    // remove metatable from stack
    lua_pop(L, 1);

    static const luaL_Reg modfuncs[] =
    {
        { "create", lstringbuffer_create },
        { NULL,             NULL         }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LSTRINGBUFFERMODULE);
    return 0;
}
