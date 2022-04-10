#ifndef OPC_MODULEMANAGER_H
#define OPC_MODULEMANAGER_H
#include "lua/lua.h"
int module_load_aux(lua_State* L);
int module_load_envlib(lua_State* L);
int module_load_geometry(lua_State* L);
int module_load_globals(lua_State* L);
int module_load_graphics(lua_State* L);
int module_load_pcell(lua_State* L);
int module_load_placement(lua_State* L);
int module_load_point(lua_State* L);
int module_load_public(lua_State* L);
int module_load_routing(lua_State* L);
int module_load_stack(lua_State* L);
int module_load_support(lua_State* L);
int module_load_util(lua_State* L);
#endif // OPC_MODULEMANAGER_H
