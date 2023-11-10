#include "lcheck.h"

void lcheck_check_numargs1(lua_State* L, int numargs, const char* funcname)
{
    int top = lua_gettop(L);
    if(top != numargs)
    {
        lua_pushfstring(L, "%s: expected %d arguments, got %d", funcname, numargs, top);
        lua_error(L);
    }
}

void lcheck_check_numargs2(lua_State* L, int numargs1, int numargs2, const char* funcname)
{
    int top = lua_gettop(L);
    if(top != numargs1 && top != numargs2)
    {
        lua_pushfstring(L, "%s: expected %d or %d arguments, got %d", funcname, numargs1, numargs2, top);
        lua_error(L);
    }
}

void lcheck_check_numargs3(lua_State* L, int numargs1, int numargs2, int numargs3, const char* funcname)
{
    int top = lua_gettop(L);
    if(top != numargs1 && top != numargs2 && top != numargs3)
    {
        lua_pushfstring(L, "%s: expected %d, %d or %d arguments, got %d", funcname, numargs1, numargs2, numargs3, top);
        lua_error(L);
    }
}

