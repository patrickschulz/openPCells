#ifndef LFILESYSTEM_H
#define LFILESYSTEM_H

#include "lua/lua.h"

int filesystem_mkdir(const char* path);

#define LFILESYSTEMMODULE "filesystem"

int open_lfilesystem_lib(lua_State* L);

#endif /* LFILESYSTEM_H */
