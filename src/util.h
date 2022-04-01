#ifndef OPC_UTIL_H
#define OPC_UTIL_H

#include "lua/lua.h"

lua_State* util_create_minimal_lua_state(void);
lua_State* util_create_basic_lua_state(void);
unsigned int util_num_digits(unsigned int n);
char* util_copy_string(const char* str);
void util_append_string(char* target, const char* str);
int util_file_exists(const char* path);

#endif // OPC_UTIL_H
