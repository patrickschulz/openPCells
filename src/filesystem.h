#ifndef OPC_FILESYSTEM_H
#define OPC_FILESYSTEM_H

#include "lua/lua.h"

int filesystem_mkdir(const char* path);

#define LFILESYSTEMMODULE "filesystem"

int open_lfilesystem_lib(lua_State* L);

#endif /* OPC_FILESYSTEM_H */
