#include "lua/lua.h"

void lcheck_check_numargs1(lua_State* L, int numargs, const char* funcname);
void lcheck_check_numargs2(lua_State* L, int numargs1, int numargs2, const char* funcname);
void lcheck_check_numargs3(lua_State* L, int numargs1, int numargs2, int numargs3, const char* funcname);
void lcheck_check_numargs_range(lua_State* L, int minargs, int maxargs, const char* funcname);

