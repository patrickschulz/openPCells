#include "ltransformationmatrix.h"

#include "lpoint.h"

#include "lua/lauxlib.h"

static int ltransformationmatrix_tostring(lua_State* L)
{
    ltransformationmatrix_t* lmatrix = lua_touserdata(L, 1);
    transformationmatrix_t* matrix = lmatrix->matrix;
    lua_pushfstring(L, "%d %d\n%d %d\ndx: %d, dy: %d\nauxdx: %d, auxdy: %d", 
            matrix->coefficients[1], matrix->coefficients[2], matrix->coefficients[3], matrix->coefficients[4], 
            matrix->dx, matrix->dy, matrix->auxdx, matrix->auxdy);
    return 1;
}

ltransformationmatrix_t* _create(lua_State* L)
{
    ltransformationmatrix_t* lmatrix = lua_newuserdata(L, sizeof(*lmatrix));
    luaL_setmetatable(L, LTRANSFORMATIONMATRIXMODULE);
    return lmatrix;
}

ltransformationmatrix_t* ltransformationmatrix_create(lua_State* L)
{
    ltransformationmatrix_t* lmatrix = _create(L);
    lmatrix->matrix = transformationmatrix_create();
    return lmatrix;
}

static int ltransformationmatrix_destroy(lua_State* L)
{
    ltransformationmatrix_t* lmatrix = lua_touserdata(L, 1);
    transformationmatrix_destroy(lmatrix->matrix);
    return 0;
}

static int ltransformationmatrix_identity(lua_State* L)
{
    ltransformationmatrix_t* lmatrix = ltransformationmatrix_create(L);
    transformationmatrix_identity(lmatrix->matrix);
    return 1;
}

static int ltransformationmatrix_chain(lua_State* L)
{
    ltransformationmatrix_t* lhs = lua_touserdata(L, 1);
    ltransformationmatrix_t* rhs = lua_touserdata(L, 2);
    ltransformationmatrix_t* lmatrix = ltransformationmatrix_create(L);
    lmatrix->matrix = transformationmatrix_chain(lhs->matrix, rhs->matrix);
    return 1;
}

static int ltransformationmatrix_copy(lua_State* L)
{
    ltransformationmatrix_t* old = lua_touserdata(L, 1);
    ltransformationmatrix_t* lmatrix = _create(L);
    lmatrix->matrix = transformationmatrix_copy(old->matrix);
    return 1;
}

static int ltransformationmatrix_move_to(lua_State* L)
{
    ltransformationmatrix_t* lmatrix = lua_touserdata(L, 1);
    coordinate_t x = lua_tointeger(L, 2);
    coordinate_t y = lua_tointeger(L, 3);
    transformationmatrix_move_to(lmatrix->matrix, x, y);
    return 1;
}

static int ltransformationmatrix_move_x_to(lua_State* L)
{
    ltransformationmatrix_t* lmatrix = lua_touserdata(L, 1);
    coordinate_t x = lua_tointeger(L, 2);
    transformationmatrix_move_x_to(lmatrix->matrix, x);
    return 1;
}

static int ltransformationmatrix_move_y_to(lua_State* L)
{
    ltransformationmatrix_t* lmatrix = lua_touserdata(L, 1);
    coordinate_t y = lua_tointeger(L, 2);
    transformationmatrix_move_y_to(lmatrix->matrix, y);
    return 1;
}

static int ltransformationmatrix_translate(lua_State* L)
{
    ltransformationmatrix_t* lmatrix = lua_touserdata(L, 1);
    coordinate_t dx = lua_tointeger(L, 2);
    coordinate_t dy = lua_tointeger(L, 3);
    transformationmatrix_translate(lmatrix->matrix, dx, dy);
    return 1;
}

static int ltransformationmatrix_translate_x(lua_State* L)
{
    ltransformationmatrix_t* lmatrix = lua_touserdata(L, 1);
    coordinate_t dx = lua_tointeger(L, 2);
    transformationmatrix_translate_x(lmatrix->matrix, dx);
    return 1;
}

static int ltransformationmatrix_translate_y(lua_State* L)
{
    ltransformationmatrix_t* lmatrix = lua_touserdata(L, 1);
    coordinate_t dy = lua_tointeger(L, 2);
    transformationmatrix_translate_y(lmatrix->matrix, dy);
    return 1;
}

static int ltransformationmatrix_auxtranslate(lua_State* L)
{
    ltransformationmatrix_t* lmatrix = lua_touserdata(L, 1);
    coordinate_t dx = lua_tointeger(L, 2);
    coordinate_t dy = lua_tointeger(L, 3);
    transformationmatrix_auxtranslate(lmatrix->matrix, dx, dy);
    return 1;
}

static int ltransformationmatrix_scale(lua_State* L)
{
    ltransformationmatrix_t* lmatrix = lua_touserdata(L, 1);
    double factor = lua_tonumber(L, 2);
    transformationmatrix_scale(lmatrix->matrix, factor);
    return 1;
}

static int ltransformationmatrix_flipx(lua_State* L)
{
    ltransformationmatrix_t* lmatrix = lua_touserdata(L, 1);
    transformationmatrix_flipx(lmatrix->matrix);
    return 1;
}

static int ltransformationmatrix_flipy(lua_State* L)
{
    ltransformationmatrix_t* lmatrix = lua_touserdata(L, 1);
    transformationmatrix_flipy(lmatrix->matrix);
    return 1;
}

static int ltransformationmatrix_rotate_90_right(lua_State* L)
{
    ltransformationmatrix_t* lmatrix = lua_touserdata(L, 1);
    transformationmatrix_rotate_90_right(lmatrix->matrix);
    return 1;
}

static int ltransformationmatrix_rotate_90_left(lua_State* L)
{
    ltransformationmatrix_t* lmatrix = lua_touserdata(L, 1);
    transformationmatrix_rotate_90_left(lmatrix->matrix);
    return 1;
}

static int ltransformationmatrix_apply_translation(lua_State* L)
{
    ltransformationmatrix_t* lmatrix = lua_touserdata(L, 1);
    lpoint_t* pt = lua_touserdata(L, 2);
    transformationmatrix_apply_translation(lmatrix->matrix, pt->point);
    return 1;
}

static int ltransformationmatrix_apply_aux_translation(lua_State* l)
{
    ltransformationmatrix_t* lmatrix = lua_touserdata(l, 1);
    lpoint_t* pt = lua_touserdata(l, 2);
    transformationmatrix_apply_aux_translation(lmatrix->matrix, pt->point);
    return 1;
}

static int ltransformationmatrix_apply_transformation(lua_State* l)
{
    ltransformationmatrix_t* lmatrix = lua_touserdata(l, 1);
    lpoint_t* pt = lua_touserdata(l, 2);
    transformationmatrix_apply_transformation(lmatrix->matrix, pt->point);
    return 1;
}

static int ltransformationmatrix_apply_inverse_transformation(lua_State* l)
{
    ltransformationmatrix_t* lmatrix = lua_touserdata(l, 1);
    lpoint_t* pt = lua_touserdata(l, 2);
    transformationmatrix_apply_inverse_transformation(lmatrix->matrix, pt->point);
    return 1;
}

static int ltransformationmatrix_apply_inverse_aux_translation(lua_State* l)
{
    ltransformationmatrix_t* lmatrix = lua_touserdata(l, 1);
    lpoint_t* pt = lua_touserdata(l, 2);
    transformationmatrix_apply_inverse_aux_translation(lmatrix->matrix, pt->point);
    return 1;
}

static int ltransformationmatrix_orientation_string(lua_State* L)
{
    ltransformationmatrix_t* lmatrix = lua_touserdata(L, 1);
    transformationmatrix_t* matrix = lmatrix->matrix;
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
        { "__gc",       ltransformationmatrix_destroy  },
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
        { "move_x_to", ltransformationmatrix_move_x_to },
        { "move_y_to", ltransformationmatrix_move_y_to },
        { "translate", ltransformationmatrix_translate },
        { "translate_x", ltransformationmatrix_translate_x },
        { "translate_y", ltransformationmatrix_translate_y },
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
