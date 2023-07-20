#include "lua/lua.h"

void lcheck_check_numargs(lua_State* L, int numargs, const char* funcname);
void lcheck_check_numargs_set(lua_State* L, int numargs1, int numargs2, const char* funcname);

