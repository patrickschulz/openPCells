#include "transformationmatrix.h"

#include "lpoint.h"

#include "lua/lauxlib.h"

static int ltransformationmatrix_tostring(lua_State* L)
{
    transformationmatrix_t* matrix = lua_touserdata(L, 1);
    lua_pushfstring(L, "%d %d\n%d %d\ndx: %d, dy: %d\nauxdx: %d, auxdy: %d", 
            matrix->coefficients[1], matrix->coefficients[2], matrix->coefficients[3], matrix->coefficients[4], 
            matrix->dx, matrix->dy, matrix->auxdx, matrix->auxdy);
    return 1;
}

static int ltransformationmatrix_identity(lua_State* L)
{
    transformationmatrix_t* matrix = lua_newuserdata(L, sizeof(*matrix));
    luaL_setmetatable(L, LTRANSFORMATIONMATRIXMODULE);
    matrix->coefficients[0] = 1;
    matrix->coefficients[1] = 0;
    matrix->coefficients[2] = 0;
    matrix->coefficients[3] = 1;
    matrix->dx = 0;
    matrix->dy = 0;
    matrix->auxdx = 0;
    matrix->auxdy = 0;
    matrix->scalefactor = 1;
    return 1;
}

static int ltransformationmatrix_chain(lua_State* L)
{
    transformationmatrix_t* lhs = lua_touserdata(L, 1);
    transformationmatrix_t* rhs = lua_touserdata(L, 2);
    transformationmatrix_t* matrix = lua_newuserdata(L, sizeof(*matrix));
    matrix->coefficients[0] = lhs->coefficients[0] * rhs->coefficients[0] + lhs->coefficients[1] * rhs->coefficients[2];
    matrix->coefficients[1] = lhs->coefficients[0] * rhs->coefficients[1] + lhs->coefficients[1] * rhs->coefficients[3];
    matrix->coefficients[2] = lhs->coefficients[2] * rhs->coefficients[0] + lhs->coefficients[3] * rhs->coefficients[2];
    matrix->coefficients[3] = lhs->coefficients[2] * rhs->coefficients[1] + lhs->coefficients[3] * rhs->coefficients[3];
    matrix->dx = lhs->dx + rhs->dx;
    matrix->dy = lhs->dy + rhs->dy;
    matrix->auxdx = lhs->auxdx + rhs->auxdx;
    matrix->auxdy = lhs->auxdy + rhs->auxdy;
    matrix->scalefactor = lhs->scalefactor * rhs->scalefactor;
    return 1;
}

static int ltransformationmatrix_copy(lua_State* L)
{
    transformationmatrix_t* old = lua_touserdata(L, 1);
    transformationmatrix_t* matrix = lua_newuserdata(L, sizeof(*matrix));
    luaL_setmetatable(L, LTRANSFORMATIONMATRIXMODULE);
    matrix->coefficients[0] = old->coefficients[0];
    matrix->coefficients[1] = old->coefficients[1];
    matrix->coefficients[2] = old->coefficients[2];
    matrix->coefficients[3] = old->coefficients[3];
    matrix->dx = old->dx;
    matrix->dy = old->dy;
    matrix->auxdx = old->auxdx;
    matrix->auxdy = old->auxdy;
    matrix->scalefactor = old->scalefactor;
    return 1;
}

static int ltransformationmatrix_move_to(lua_State* L)
{
    transformationmatrix_t* matrix = lua_touserdata(L, 1);
    coordinate_t x = lua_tointeger(L, 2);
    coordinate_t y = lua_tointeger(L, 3);
    matrix->dx = x;
    matrix->dy = y;
    return 1;
}

static int ltransformationmatrix_translate(lua_State* L)
{
    transformationmatrix_t* matrix = lua_touserdata(L, 1);
    coordinate_t dx = lua_tointeger(L, 2);
    coordinate_t dy = lua_tointeger(L, 3);
    matrix->dx += dx;
    matrix->dy += dy;
    return 1;
}

static int ltransformationmatrix_auxtranslate(lua_State* L)
{
    transformationmatrix_t* matrix = lua_touserdata(L, 1);
    coordinate_t dx = lua_tointeger(L, 2);
    coordinate_t dy = lua_tointeger(L, 3);
    matrix->auxdx += dx;
    matrix->auxdy += dy;
    return 1;
}

static int ltransformationmatrix_scale(lua_State* L)
{
    transformationmatrix_t* matrix = lua_touserdata(L, 1);
    double factor = lua_tonumber(L, 2);
    matrix->scalefactor = factor;
    return 1;
}

static int ltransformationmatrix_flipx(lua_State* L)
{
    transformationmatrix_t* matrix = lua_touserdata(L, 1);
    matrix->coefficients[0] = -matrix->coefficients[0];
    matrix->coefficients[1] = -matrix->coefficients[1];
    return 1;
}

static int ltransformationmatrix_flipy(lua_State* L)
{
    transformationmatrix_t* matrix = lua_touserdata(L, 1);
    matrix->coefficients[2] = -matrix->coefficients[2];
    matrix->coefficients[3] = -matrix->coefficients[3];
    return 1;
}

static int ltransformationmatrix_rotate_90_right(lua_State* L)
{
    transformationmatrix_t* matrix = lua_touserdata(L, 1);
    coordinate_t tmp = matrix->coefficients[0];
    matrix->coefficients[0] = matrix->coefficients[2];
    matrix->coefficients[2] = -tmp;
    tmp = matrix->coefficients[1];
    matrix->coefficients[1] = matrix->coefficients[3];
    matrix->coefficients[3] = -tmp;
    return 1;
}

static int ltransformationmatrix_rotate_90_left(lua_State* L)
{
    transformationmatrix_t* matrix = lua_touserdata(L, 1);
    coordinate_t tmp = matrix->coefficients[0];
    matrix->coefficients[0] = -matrix->coefficients[2];
    matrix->coefficients[2] = tmp;
    tmp = matrix->coefficients[1];
    matrix->coefficients[1] = -matrix->coefficients[3];
    matrix->coefficients[3] = tmp;
    return 1;
}

static int ltransformationmatrix_apply_translation(lua_State* L)
{
    transformationmatrix_t* matrix = lua_touserdata(L, 1);
    lpoint_t* pt = lua_touserdata(L, 2);
    pt->point->x += matrix->dx;
    pt->point->y += matrix->dy;
    return 1;
}

static int ltransformationmatrix_apply_aux_translation(lua_State* l)
{
    transformationmatrix_t* matrix = lua_touserdata(l, 1);
    lpoint_t* pt = lua_touserdata(l, 2);
    pt->point->x += matrix->auxdx;
    pt->point->y += matrix->auxdy;
    return 1;
}

static int ltransformationmatrix_apply_transformation(lua_State* l)
{
    transformationmatrix_t* matrix = lua_touserdata(l, 1);
    lpoint_t* pt = lua_touserdata(l, 2);
    pt->point->x = matrix->scalefactor * (matrix->coefficients[0] * pt->point->x + matrix->coefficients[1] * pt->point->y) + matrix->dx + matrix->auxdx;
    pt->point->y = matrix->scalefactor * (matrix->coefficients[2] * pt->point->x + matrix->coefficients[3] * pt->point->y) + matrix->dy + matrix->auxdy;
    return 1;
}

static int ltransformationmatrix_apply_inverse_transformation(lua_State* l)
{
    transformationmatrix_t* matrix = lua_touserdata(l, 1);
    lpoint_t* pt = lua_touserdata(l, 2);
    coordinate_t x = pt->point->x;
    coordinate_t y = pt->point->y;
    coordinate_t det = matrix->coefficients[0] * matrix->coefficients[3] - matrix->coefficients[1] * matrix->coefficients[2];
    pt->point->x = ((x - matrix->dx - matrix->auxdx) / matrix->scalefactor * matrix->coefficients[3] - (y - matrix->dy - matrix->auxdy) / matrix->scalefactor * matrix->coefficients[1]) / det;
    pt->point->y = ((y - matrix->dy - matrix->auxdy) / matrix->scalefactor * matrix->coefficients[0] - (x - matrix->dx - matrix->auxdx) / matrix->scalefactor * matrix->coefficients[2]) / det;
    return 1;
}

static int ltransformationmatrix_apply_inverse_aux_translation(lua_State* l)
{
    transformationmatrix_t* matrix = lua_touserdata(l, 1);
    lpoint_t* pt = lua_touserdata(l, 2);
    pt->point->x -= matrix->auxdx;
    pt->point->y -= matrix->auxdy;
    return 1;
}

static int ltransformationmatrix_orientation_string(lua_State* L)
{
    transformationmatrix_t* matrix = lua_touserdata(L, 1);
    if(matrix->coefficients[0] >= 0 && matrix->coefficients[3] >= 0)
    {
        if(matrix->coefficients[1] < 0)
        {
            lua_pushstring(L, "R90");
        }
        else
        {
            lua_pushstring(L, "R0");
        }
    }
    else if(matrix->coefficients[0] <  0 && matrix->coefficients[3] >= 0)
    {
        lua_pushstring(L, "fx");
    }
    else if(matrix->coefficients[0] >= 0 && matrix->coefficients[3] <  0)
    {
        lua_pushstring(L, "fy");
    }
    else if(matrix->coefficients[0] <  0 && matrix->coefficients[3] <  0)
    {
        lua_pushstring(L, "R180");
    }
    return 1;
}

int open_ltransformationmatrix_lib(lua_State* L)
{
    // create metatable for shapes
    luaL_newmetatable(L, LTRANSFORMATIONMATRIXMODULE);

    // set methods
    static const luaL_Reg metafuncs[] =
    {
        { "__tostring", ltransformationmatrix_tostring },
        { NULL,         NULL                           }
    };
    luaL_setfuncs(L, metafuncs, 0);

    // add __index
    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2); 
    lua_rawset(L, -3);

    static const luaL_Reg modfuncs[] =
    {
        { "identity", ltransformationmatrix_identity },
        { "chain",    ltransformationmatrix_chain    },
        { "copy", ltransformationmatrix_copy },
        { "move_to", ltransformationmatrix_move_to },
        { "translate", ltransformationmatrix_translate },
        { "auxtranslate", ltransformationmatrix_auxtranslate },
        { "scale", ltransformationmatrix_scale },
        { "flipx", ltransformationmatrix_flipx },
        { "flipy", ltransformationmatrix_flipy },
        { "rotate_90_right", ltransformationmatrix_rotate_90_right },
        { "rotate_90_left", ltransformationmatrix_rotate_90_left },
        { "apply_translation", ltransformationmatrix_apply_translation },
        { "apply_aux_translation", ltransformationmatrix_apply_aux_translation },
        { "apply_transformation", ltransformationmatrix_apply_transformation },
        { "apply_inverse_transformation", ltransformationmatrix_apply_inverse_transformation },
        { "apply_inverse_aux_translation", ltransformationmatrix_apply_inverse_aux_translation },
        { "orientation_string", ltransformationmatrix_orientation_string },
        { NULL,       NULL                           }
    };
    luaL_setfuncs(L, modfuncs, 0);

    lua_setglobal(L, LTRANSFORMATIONMATRIXMODULE);

    return 0;
}
