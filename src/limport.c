#include "limport.h"

#include <ctype.h>

#include "lua/lauxlib.h"

#include "_modulemanager.h"
#include "cdl_parser.h"
#include "netlist.h"

static int limport_read_CDL_netlist(lua_State* L)
{
    const char* filename = luaL_checkstring(L, 1);
    struct netlist* netlist = cdlparser_parse(filename);
    netlist_create_lua_representation(netlist, L);
    netlist_destroy(netlist);
    return 1; // netlist_create_lua_representation creates a table
}

static int limport_parse_string_float(lua_State* L)
{
    // can be 0.24e-9 or 2 or 500n or 123.456e2 or similar
    const char* str = luaL_checkstring(L, 1);
    const char* ptr = str;
    enum state {
        INTEGRAL,
        FRACTIONAL,
        UNIT,
        SCIENTIFIC,
        END
    } state;
    state = INTEGRAL;
    double num = 0;
    int fraccount = 1;
    int negative = 0;
    if(*ptr == '-')
    {
        negative = 1;
        ++ptr;
    }
    while(*ptr)
    {
        switch(state)
        {
            case INTEGRAL:
                if(isdigit(*ptr))
                {
                    num *= 10;
                    num += *ptr - '0';
                    ++ptr;
                }
                else if(*ptr == '.')
                {
                    state = FRACTIONAL;
                    ++ptr;
                }
                else if(*ptr == 'e')
                {
                    state = SCIENTIFIC;
                    ++ptr;
                }
                else
                {
                    state = UNIT;
                    // don't skip character, the next iteration then reads the current
                }
                break;
            case FRACTIONAL:
                if(isdigit(*ptr))
                {
                    double frac = *ptr - '0';
                    int f = fraccount;
                    while(f > 0)
                    {
                        frac /= 10;
                        --f;
                    }
                    num += frac;
                    ++fraccount;
                    ++ptr;
                }
                else
                {
                    lua_pushfstring(L, "import.parse_string_float: non-integer character '%c' encountered while reading fractional part", *ptr);
                    lua_error(L);
                }
                break;
            case UNIT:
                switch(*ptr)
                {
                    case 'E':
                        num *= 1e18;
                        break;
                    case 'P':
                        num *= 1e15;
                        break;
                    case 'T':
                        num *= 1e12;
                        break;
                    case 'G':
                        num *= 1e9;
                        break;
                    case 'M':
                        num *= 1e6;
                        break;
                    case 'k':
                        num *= 1e3;
                        break;
                    case 'm':
                        num *= 1e-3;
                        break;
                    case 'u':
                        num *= 1e-6;
                        break;
                    case 'n':
                        num *= 1e-9;
                        break;
                    case 'p':
                        num *= 1e-12;
                        break;
                    case 'f':
                        num *= 1e-15;
                        break;
                    case 'a':
                        num *= 1e-18;
                        break;
                }
                ++ptr;
                break;
            case SCIENTIFIC:
                // FIXME
                break;
            case END:
                lua_pushfstring(L, "import.parse_string_float: garbage character '%c' encountered after reading unit", *ptr);
                lua_error(L);
                break;
        }
    }
    if(negative)
    {
        num = -num;
    }
    lua_pushnumber(L, num);
    return 1;
}

static int limport_parse_string_integer(lua_State* L)
{
    const char* str = luaL_checkstring(L, 1);
    const char* ptr = str;
    int num = 0;
    int negative = 0;
    if(*ptr == '-')
    {
        negative = 1;
        ++ptr;
    }
    while(*ptr)
    {
        if(isdigit(*ptr))
        {
            num *= 10;
            num += *ptr - '0';
            ++ptr;
        }
        else
        {
            lua_pushfstring(L, "import.parse_string_integer: non-integer character '%c' encountered", *ptr);
            lua_error(L);
        }
    }
    if(negative)
    {
        num = -num;
    }
    lua_pushinteger(L, num);
    return 1;
}

int open_limport_lib(lua_State* L)
{
    // register lua functions (also creates the global table)
    module_load_import(L);
    static const luaL_Reg modfuncs[] =
    {
        { "read_CDL_netlist",       limport_read_CDL_netlist        },
        { "parse_string_float",     limport_parse_string_float      },
        { "parse_string_integer",   limport_parse_string_integer    },
        { NULL,                     NULL                            }
    };
    // register C functions
    lua_getglobal(L, "import");
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, "import");
    return 0;
}

