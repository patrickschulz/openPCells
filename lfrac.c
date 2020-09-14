#include "lua/lua.h"
#include "lua/lauxlib.h"

#include <stdio.h>
#include <stdint.h>

#include "lfrac.h"

static lfrac_int_t gcd(lfrac_int_t a, lfrac_int_t b)
{
    if(a == 0)
    {
        return b;
    }
    else
    {
        return gcd(b % a, a);
    }
}

static void fix_and_normalize(lfrac_t* f)
{
    lfrac_int_t div = gcd(f->numerator, f->denominator);
    f->numerator /= div;
    f->denominator /= div;
}

static void calculate_numden(double d, lfrac_t* f)
{
    lfrac_sign_t sign = d < 0 ? 1 : 0;
    d *= (1 - 2 * sign);
    lfrac_int_t num = 0;
    lfrac_int_t den = CONVPRECISION;
    d *= den;
    num = (int)d;
    f->sign = sign;
    f->numerator = num;
    f->denominator = den;
}

static int lfrac_tostring(lua_State* L)
{
    lfrac_t* data = lua_touserdata(L, -1);
    char buf[MAXDIGITS + 1];
    snprintf(buf, MAXDIGITS + 1, "%s%u/%u", data->sign ? "-" : "", data->numerator, data->denominator);
    lua_pushstring(L, buf);
    return 1;
}

static int lfrac_add(lua_State* L)
{
    lfrac_t* lhs = lua_touserdata(L, -2);
    lfrac_t* rhs = lua_touserdata(L, -1);
    lfrac_t* result = lua_newuserdata(L, sizeof(lfrac_t));
    luaL_setmetatable(L, TYPENAME);
    lfrac_int_t a = lhs->numerator * rhs->denominator;
    lfrac_int_t b = rhs->numerator * lhs->denominator;
    lfrac_int_t c;
    result->sign = 0;
    if(lhs->sign && rhs->sign)
    {
        c = a + b;
        result->sign = 1;
    }
    else if(lhs->sign)
    {
        if(a > b)
        {
            c = a - b;
            result->sign = 1;
        }
        else
        {
            c = b - a;
        }
    }
    else if(rhs->sign)
    {
        if(a > b)
        {
            c = a - b;
        }
        else
        {
            c = b - a;
            result->sign = 1;
        }
    }
    else
    {
        c = a + b;
    }
    result->numerator = c;
    result->denominator = lhs->denominator * rhs->denominator;
    fix_and_normalize(result);
    return 1;
}

static int lfrac_sub(lua_State* L)
{
    lfrac_t* lhs = lua_touserdata(L, -2);
    lfrac_t* rhs = lua_touserdata(L, -1);
    lfrac_t* result = lua_newuserdata(L, sizeof(lfrac_t));
    luaL_setmetatable(L, TYPENAME);
    lfrac_int_t a = lhs->numerator * rhs->denominator;
    lfrac_int_t b = rhs->numerator * lhs->denominator;
    lfrac_int_t c;
    result->sign = 0;
    if(lhs->sign && rhs->sign)
    {
        if(a > b)
        {
            c = a - b;
            result->sign = 1;
        }
        else
        {
            c = b - a;
        }
    }
    else if(lhs->sign)
    {
        c = a + b;
        result->sign = 1;
    }
    else if(rhs->sign)
    {
        c = a + b;
    }
    else
    {
        if(a > b)
        {
            c = a - b;
        }
        else
        {
            c = b - a;
            result->sign = 1;
        }
    }
    result->numerator = c;
    result->denominator = lhs->denominator * rhs->denominator;
    fix_and_normalize(result);
    return 1;
}

static int lfrac_mul(lua_State* L)
{
    lfrac_t* lhs = lua_touserdata(L, -2);
    lfrac_t* rhs = lua_touserdata(L, -1);
    lfrac_t* result = lua_newuserdata(L, sizeof(lfrac_t));
    luaL_setmetatable(L, TYPENAME);
    result->numerator = lhs->numerator * rhs->numerator;
    result->denominator = lhs->denominator * rhs->denominator;
    result->sign = lhs->sign ^ rhs->sign;
    fix_and_normalize(result);
    return 1;
}

static int lfrac_div(lua_State* L)
{
    lfrac_t* lhs = lua_touserdata(L, -2);
    lfrac_t* rhs = lua_touserdata(L, -1);
    lfrac_t* result = lua_newuserdata(L, sizeof(lfrac_t));
    luaL_setmetatable(L, TYPENAME);
    result->numerator = lhs->numerator * rhs->denominator;
    result->denominator = lhs->denominator * rhs->numerator;
    result->sign = lhs->sign ^ rhs->sign;
    fix_and_normalize(result);
    return 1;
}

static int lfrac_unm(lua_State* L)
{
    lfrac_t* rhs = lua_touserdata(L, -1);
    lfrac_t* result = lua_newuserdata(L, sizeof(lfrac_t));
    luaL_setmetatable(L, TYPENAME);
    result->numerator = rhs->numerator;
    result->denominator = rhs->denominator;
    result->sign = !rhs->sign;
    return 1;
}

static int lfrac_create(lua_State* L)
{
    lua_Number d = luaL_checknumber(L, -1);
    int num, den;
    lfrac_t* data = lua_newuserdata(L, sizeof(lfrac_t));
    luaL_setmetatable(L, TYPENAME);
    calculate_numden(d, data);
    fix_and_normalize(data);
    return 1;
}

static int lfrac_tonum(lua_State* L)
{
    lfrac_t* f = luaL_checkudata(L, -1, TYPENAME);
    lua_Number res = (1.0 - 2.0 * f->sign) * f->numerator / f->denominator;
    lua_pushnumber(L, res);
    return 1;
}

int open_lfrac_lib(lua_State* L)
{
    static const luaL_Reg metafuncs[] =
    {
        { "__tostring",     lfrac_tostring   },
        { "__add",          lfrac_add        },
        { "__sub",          lfrac_sub        },
        { "__div",          lfrac_div        },
        { "__mul",          lfrac_mul        },
        { "__unm",          lfrac_unm        },
        { "tonum",          lfrac_tonum      },
        { NULL,             NULL             }
    };
    luaL_newmetatable(L, TYPENAME);
    luaL_setfuncs(L, metafuncs, 0);
    /* add __index */
    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2); 
    lua_rawset(L, -3);

    static const luaL_Reg modfuncs[] =
    {
        { "create",         lfrac_create     },
        { NULL,             NULL            }
    };
    lua_newtable(L);
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, MODULENAME);
    return 0;
}
