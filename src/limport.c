#include "limport.h"

#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#include "lua/lauxlib.h"

#include "_modulemanager.h"
#include "cdl_parser.h"
#include "netlist.h"

static int limport_read_CDL_netlist(lua_State* L)
{
    const char* filename = luaL_checkstring(L, 1);
    struct netlist* netlist = cdlparser_parse(filename);
    if(!netlist)
    {
        return luaL_error(L, "import.read_CDL_netlist: could not parse netlist '%s'", filename);
    }
    netlist_create_lua_representation(netlist, L);
    netlist_destroy(netlist);
    return 1; // netlist_create_lua_representation creates a table
}

// SPICE scale factors (case-insensitive: 'm' is milli, mega is 'meg', 'mil' is 1/1000 inch)
// entries that start with another entry must come first ('meg' and 'mil' before 'm')
static const struct {
    const char* name;
    double factor;
} scalefactors[] = {
    { "meg",    1e6     },
    { "mil",    25.4e-6 },
    { "t",      1e12    },
    { "g",      1e9     },
    { "k",      1e3     },
    { "m",      1e-3    },
    { "u",      1e-6    },
    { "n",      1e-9    },
    { "p",      1e-12   },
    { "f",      1e-15   },
    { "a",      1e-18   },
    { NULL,     0       } /* sentinel */
};

static int _starts_with_nocase(const char* str, const char* prefix)
{
    while(*prefix)
    {
        if(tolower(*str) != *prefix)
        {
            return 0;
        }
        ++str;
        ++prefix;
    }
    return 1;
}

static int limport_parse_string_float(lua_State* L)
{
    // format: number [scale factor] [unit], e.g. 2, -0.24e-9, 500n, 1.5E+3, 4um, 1meg
    // remaining letters after the scale factor (the unit) are ignored
    const char* str = luaL_checkstring(L, 1);
    const char* ptr = str;
    // number
    if(*ptr == '-' || *ptr == '+')
    {
        ++ptr;
    }
    const char* digitstart = ptr;
    while(isdigit(*ptr))
    {
        ++ptr;
    }
    if(*ptr == '.')
    {
        ++ptr;
        while(isdigit(*ptr))
        {
            ++ptr;
        }
    }
    if(ptr == digitstart || (ptr == digitstart + 1 && *digitstart == '.'))
    {
        return luaL_error(L, "import.parse_string_float: '%s' does not start with a number", str);
    }
    if((ptr[0] == 'e' || ptr[0] == 'E') &&
       (isdigit(ptr[1]) || ((ptr[1] == '+' || ptr[1] == '-') && isdigit(ptr[2])))) // exponent
    {
        ptr += 2;
        while(isdigit(*ptr))
        {
            ++ptr;
        }
    }
    // convert only the validated number part (strtod would also accept things like hexadecimal numbers)
    char numstr[64];
    size_t numlen = ptr - str;
    if(numlen >= sizeof(numstr))
    {
        return luaL_error(L, "import.parse_string_float: number in '%s' is too long", str);
    }
    memcpy(numstr, str, numlen);
    numstr[numlen] = 0;
    double num = strtod(numstr, NULL);
    // scale factor
    for(size_t i = 0; scalefactors[i].name; ++i)
    {
        if(_starts_with_nocase(ptr, scalefactors[i].name))
        {
            num *= scalefactors[i].factor;
            ptr += strlen(scalefactors[i].name);
            break;
        }
    }
    // unit
    while(isalpha(*ptr))
    {
        ++ptr;
    }
    if(*ptr)
    {
        return luaL_error(L, "import.parse_string_float: unexpected character '%c' in '%s'", *ptr, str);
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

