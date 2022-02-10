#include "ldebug.h"

#include <stdio.h>

void ldebug_dump_stack(lua_State *L)
{
	int i;
	int top = lua_gettop(L);
	printf("\n#### BOS ####\n");
	for(i = top; i >= 1; i--)
	{
		int t = lua_type(L, i);
		switch(t)
		{
		case LUA_TSTRING:
			printf("%i (%i) = `%s'", i, i - (top + 1), lua_tostring(L, i));
			break;

		case LUA_TBOOLEAN:
			printf("%i (%i) = %s", i, i - (top + 1), lua_toboolean(L, i) ? "true" : "false");
			break;

		case LUA_TNUMBER:
			printf("%i (%i) = %g", i, i - (top + 1), lua_tonumber(L, i));
			break;

        case LUA_TUSERDATA:
			printf("%i (%i) = userdata: %p", i, i - (top + 1), lua_touserdata(L, i));
            break;

		default:
			printf("%i (%i) = %s", i, i - (top + 1), lua_typename(L, t));
			break;
		}
		printf("\n");
	}
	printf("#### EOS ####\n");
	printf("\n");
}
