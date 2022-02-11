#include "ldebug.h"

#include <stdio.h>

void ldebug_dump_stack(lua_State *L)
{
	int i;
	int top = lua_gettop(L);
	puts("#### BOS ####");
	for(i = top; i >= 1; i--)
	{
		int t = lua_type(L, i);
		switch(t)
		{
		case LUA_TSTRING:
			printf("%i (%i) = string: \"%s\"", i, i - (top + 1), lua_tostring(L, i));
			break;

		case LUA_TBOOLEAN:
			printf("%i (%i) = %s", i, i - (top + 1), lua_toboolean(L, i) ? "true" : "false");
			break;

		case LUA_TNUMBER:
			printf("%i (%i) = %g", i, i - (top + 1), lua_tonumber(L, i));
			break;

        case LUA_TUSERDATA:
            /* FIXME: broken, but I don't know why
            if(lua_getmetatable(L, i))
            {
                lua_pushstring(L, "__tostring");
                lua_gettable(L, -2);
                if(lua_isnil(L, -1))
                {
                    lua_pop(L, 1); // pop nil
                    lua_pushstring(L, "userdata");
                }
                else
                {
                    lua_pushvalue(L, i);
                    lua_call(L, 1, 1);
                }
                lua_insert(L, -2);
                lua_pop(L, 1); // pop meta table
            }
            else
            {
                lua_pushstring(L, "userdata");
            }
            const char* tag = lua_tostring(L, -1);
			printf("%i (%i) = %s: %p", i, i - (top + 1), tag, lua_touserdata(L, i));
            lua_pop(L, 1);
            */
			printf("%i (%i) = %s: %p", i, i - (top + 1), "userdata", lua_touserdata(L, i));
            break;

		default:
			printf("%i (%i) = %s", i, i - (top + 1), lua_typename(L, t));
			break;
		}
		putchar('\n');
	}
	puts("#### EOS ####");
}
