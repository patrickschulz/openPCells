#include "lshape.h"

#include <string.h>

#include "lua/lauxlib.h"

#include "shape.h"
#include "lpoint.h"
#include "ltransformationmatrix.h"

#include "ldebug.h"

typedef struct
{
    shape_t* shape;
} lshape_t;

static lshape_t* _create_lshape(lua_State* L)
{
    lshape_t* lshape = lua_newuserdatauv(L, sizeof(lshape_t), 1);
    lshape->shape = NULL;
    luaL_setmetatable(L, LSHAPEMODULE);

    // set lpp
    lua_pushvalue(L, 1); 
    lua_setiuservalue(L, -2, 1);

    return lshape;
}

static int lshape_tostring(lua_State* L)
{
    lshape_t* lshape = luaL_checkudata(L, 1, LSHAPEMODULE);
    switch(lshape->shape->type)
    {
        case RECTANGLE:
        {
            lua_pushfstring(L, "rectangle: (%d, %d) (%d, %d)", 
                lshape->shape->points[0]->x, lshape->shape->points[0]->y, 
                lshape->shape->points[1]->x, lshape->shape->points[1]->y);
            break;
        }
        case POLYGON:
        {
            lua_pushfstring(L, "polygon: %p", lshape);
            break;
        }
        case PATH:
        {
            lua_pushfstring(L, "path: %p", lshape);
            break;
        }
    }
    return 1;
}

static int lshape_create_rectangle_bltr(lua_State* L)
{
    if(lua_gettop(L) != 3)
    {
        lua_pushstring(L, "shape.create_rectangle_bltr() expects three arguments");
        lua_error(L);
    }
    if(!lua_istable(L, 1))
    {
        lua_pushstring(L, "shape.create_rectangle_bltr(): first argument must be a table");
        lua_error(L);
    }
    lshape_t* lshape = _create_lshape(L);
    lpoint_t* bl = luaL_checkudata(L, 2, LPOINTMETA);
    lpoint_t* tr = luaL_checkudata(L, 3, LPOINTMETA);
    lshape->shape = shape_create_rectangle(bl->point->x, bl->point->y, tr->point->x, tr->point->y);
    return 1;
}

static int lshape_create_polygon(lua_State* L)
{
    if(lua_gettop(L) < 1)
    {
        lua_pushstring(L, "shape.create_polygon() expects at least one argument");
        lua_error(L);
    }
    if(!lua_istable(L, 1))
    {
        lua_pushstring(L, "shape.create_rectangle_bltr(): first argument must be a table");
        lua_error(L);
    }
    lshape_t* lshape = _create_lshape(L);
    int len = 0;
    if(lua_gettop(L) == 3 && lua_istable(L, 3))
    {
        lua_len(L, 2);
        len = lua_tointeger(L, -1);
        lua_pop(L, 1);
    }
    lshape->shape = shape_create_polygon(len);
    for(int i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 2, i);
        lpoint_t* pt = luaL_checkudata(L, -1, LPOINTMETA);
        shape_append(lshape->shape, pt->point->x, pt->point->y);
        lua_pop(L, 1);
    }
    return 1;
}

static int lshape_create_path(lua_State* L)
{
    if(lua_gettop(L) < 3)
    {
        lua_pushstring(L, "shape.create_path() expects at least three arguments");
        lua_error(L);
    }
    coordinate_t extstart = 0;
    coordinate_t extend = 0;
    if(lua_gettop(L) == 4 && lua_istable(L, 4))
    {
        lua_rawgeti(L, 4, 1);
        lua_rawgeti(L, 4, 2);
        extstart = lua_tointeger(L, -2);
        extend = lua_tointeger(L, -1);
        lua_pop(L, 2);
    }
    lshape_t* lshape = _create_lshape(L);
    lua_len(L, 2);
    int len = lua_tointeger(L, -1);
    lua_pop(L, 1);
    ucoordinate_t width = luaL_checkinteger(L, 3);
    lshape->shape = shape_create_path(len, width, extstart, extend);
    for(int i = 1; i <= len; ++i)
    {
        lua_rawgeti(L, 2, i);
        lpoint_t* pt = luaL_checkudata(L, -1, LPOINTMETA);
        shape_append(lshape->shape, pt->point->x, pt->point->y);
        lua_pop(L, 1);
    }

    return 1;
}

static int lshape_get_points(lua_State* L)
{
    lua_newtable(L);
    lshape_t* lshape = luaL_checkudata(L, 1, LSHAPEMODULE);
    shape_t* shape = lshape->shape;
    if(shape->type == RECTANGLE)
    {
        lua_pushstring(L, "bl");
        lpoint_create_internal(L, shape->points[0]->x, shape->points[0]->y);
        lua_rawset(L, -3);
        lua_pushstring(L, "tr");
        lpoint_create_internal(L, shape->points[1]->x, shape->points[1]->y);
        lua_rawset(L, -3);
    }
    else
    {
        for(unsigned int i = 0; i < shape->size; ++i)
        {
            lpoint_create_internal(L, shape->points[i]->x, shape->points[i]->y);
            lua_rawseti(L, -2, i + 1);
        }
    }
    return 1;
}

static int lshape_is_type(lua_State* L)
{
    lshape_t* lshape = luaL_checkudata(L, 1, LSHAPEMODULE);
    const char* type = luaL_checkstring(L, 2);
    switch(lshape->shape->type)
    {
        case RECTANGLE:
            lua_pushboolean(L, !strcmp(type, "rectangle"));
            break;
        case POLYGON:
            lua_pushboolean(L, !strcmp(type, "polygon"));
            break;
        case PATH:
            lua_pushboolean(L, !strcmp(type, "path"));
            break;
    }
    return 1;
}

static int lshape_get_path_width(lua_State* L)
{
    lshape_t* lshape = luaL_checkudata(L, 1, LSHAPEMODULE);
    ucoordinate_t width;
    int available = shape_get_path_width(lshape->shape, &width);
    if(available)
    {
        lua_pushinteger(L, width);
    }
    else
    {
        lua_pushnil(L);
    }
    return 1;
}

static int lshape_get_path_extension(lua_State* L)
{
    lshape_t* lshape = luaL_checkudata(L, 1, LSHAPEMODULE);
    coordinate_t start;
    coordinate_t end;
    int available = shape_get_path_extension(lshape->shape, &start, &end);
    if(available)
    {
        lua_newtable(L);
        lua_pushinteger(L, start);
        lua_rawseti(L, -2, 1);
        lua_pushinteger(L, end);
        lua_rawseti(L, -2, 2);
    }
    else
    {
        lua_pushnil(L);
    }
    return 1;
}

static int lshape_is_lpp_type(lua_State* L)
{
    lua_getiuservalue(L, 1, 1);
    lua_pushstring(L, "typ");
    lua_gettable(L, -2);
    const char* type1 = luaL_checkstring(L, 2);
    const char* type2 = luaL_checkstring(L, -1);
    lua_pushboolean(L, !strcmp(type1, type2));
    return 1;
}

static int lshape_set_lpp(lua_State* L)
{
    lua_setiuservalue(L, 1, 1);
    return 0;
}

static int lshape_get_lpp(lua_State* L)
{
    lua_getiuservalue(L, 1, 1);
    return 1;
}

static int lshape_copy(lua_State* L)
{
    lshape_t* lshape = luaL_checkudata(L, 1, LSHAPEMODULE);

    lshape_t* new = lua_newuserdatauv(L, sizeof(lshape_t), 1);
    luaL_setmetatable(L, LSHAPEMODULE);
    new->shape = shape_copy(lshape->shape);

    // copy lpp
    lua_getglobal(L, "generics");
    lua_pushstring(L, "copy");
    lua_rawget(L, -2);
    lua_getiuservalue(L, 1, 1); 
    lua_call(L, 1, 1);
    lua_setiuservalue(L, 2, 1);
    lua_pop(L, 1); // pop 'generics' table

    return 1;
}

static int lshape_append_xy(lua_State* L)
{
    lshape_t* lshape = luaL_checkudata(L, 1, LSHAPEMODULE);
    if(lshape->shape->type == RECTANGLE)
    {
        lua_pushstring(L, "lshape: can't append to a rectangle");
        lua_error(L);
    }
    coordinate_t x = luaL_checkinteger(L, 2);
    coordinate_t y = luaL_checkinteger(L, 3);
    shape_append(lshape->shape, x, y);
    return 1;
}

static int lshape_append_pt(lua_State* L)
{
    lshape_t* lshape = luaL_checkudata(L, 1, LSHAPEMODULE);
    if(lshape->shape->type == RECTANGLE)
    {
        lua_pushstring(L, "lshape: can't append to a rectangle");
        lua_error(L);
    }
    lpoint_t* pt = luaL_checkudata(L, 2, LPOINTMETA);
    shape_append(lshape->shape, pt->point->x, pt->point->y);
    return 1;
}

static int lshape_apply_transformation(lua_State* L)
{
    lshape_t* lshape = luaL_checkudata(L, 1, LSHAPEMODULE);
    ltransformationmatrix_t* lmatrix = luaL_checkudata(L, 2, LTRANSFORMATIONMATRIXMODULE);
    shape_apply_transformation(lshape->shape, lmatrix->matrix);
    lua_pop(L, 1);
    return 1;
}

static int lshape_apply_translation(lua_State* L)
{
    lshape_t* lshape = luaL_checkudata(L, 1, LSHAPEMODULE);
    ltransformationmatrix_t* lmatrix = luaL_checkudata(L, 2, LTRANSFORMATIONMATRIXMODULE);
    shape_apply_translation(lshape->shape, lmatrix->matrix);
    lua_pop(L, 1);
    return 1;
}

static int lshape_apply_inverse_transformation(lua_State* L)
{
    lshape_t* lshape = luaL_checkudata(L, 1, LSHAPEMODULE);
    ltransformationmatrix_t* lmatrix = luaL_checkudata(L, 2, LTRANSFORMATIONMATRIXMODULE);
    shape_apply_inverse_transformation(lshape->shape, lmatrix->matrix);
    lua_pop(L, 1);
    return 1;
}

static int lshape_get_width(lua_State* L)
{
    lshape_t* lshape = luaL_checkudata(L, 1, LSHAPEMODULE);
    coordinate_t width = shape_get_width(lshape->shape);
    lua_pushinteger(L, width);
    return 1;
}

static int lshape_get_height(lua_State* L)
{
    lshape_t* lshape = luaL_checkudata(L, 1, LSHAPEMODULE);
    coordinate_t height = shape_get_height(lshape->shape);
    lua_pushinteger(L, height);
    return 1;
}

static int lshape_get_center(lua_State* L)
{
    lshape_t* lshape = luaL_checkudata(L, 1, LSHAPEMODULE);
    coordinate_t x, y;
    int ret = shape_get_center(lshape->shape, &x, &y);
    if(ret)
    {
        lpoint_create_internal(L, x, y);
        return 1;
    }
    else
    {
        lua_pushnil(L);
        lua_pushstring(L, "only rectangles support get_center()");
        return 2;
    }
}

static int lshape_resize_lrtb(lua_State* L)
{
    lshape_t* lshape = luaL_checkudata(L, 1, LSHAPEMODULE);
    coordinate_t left = luaL_checkinteger(L, 2);
    coordinate_t right = luaL_checkinteger(L, 3);
    coordinate_t top = luaL_checkinteger(L, 4);
    coordinate_t bottom = luaL_checkinteger(L, 5);
    shape_resize_lrtb(lshape->shape, left, right, top, bottom);
    return 0;
}

static int lshape_resize(lua_State* L)
{
    lshape_t* lshape = luaL_checkudata(L, 1, LSHAPEMODULE);
    coordinate_t xsize = luaL_checkinteger(L, 2);
    coordinate_t ysize = luaL_checkinteger(L, 3);
    shape_resize_lrtb(lshape->shape, xsize / 2, xsize / 2, ysize / 2, ysize / 2);
    return 0;
}

static int lshape_resolve_path(lua_State* L)
{
    lshape_t* lshape = luaL_checkudata(L, -1, LSHAPEMODULE);
    shape_resolve_path(lshape->shape);
    return 0;
}

static int lshape_destroy(lua_State* L)
{
    lshape_t* lshape = luaL_checkudata(L, -1, LSHAPEMODULE);
    if(lshape->shape)
    {
        shape_destroy(lshape->shape);
    }
    return 0;
}

int open_lshape_lib(lua_State* L)
{
    // create metatable for shapes
    luaL_newmetatable(L, LSHAPEMODULE);

    // set methods
    static const luaL_Reg metafuncs[] =
    {
        { "copy",                         lshape_copy                         },
        { "append_xy",                    lshape_append_xy                    },
        { "append_pt",                    lshape_append_pt                    },
        { "get_points",                   lshape_get_points                   },
        { "get_path_width",               lshape_get_path_width               },
        { "get_path_extension",           lshape_get_path_extension           },
        { "set_lpp",                      lshape_set_lpp                      },
        { "get_lpp",                      lshape_get_lpp                      },
        { "is_type",                      lshape_is_type                      },
        { "is_lpp_type",                  lshape_is_lpp_type                  },
        { "apply_translation",            lshape_apply_translation            },
        { "apply_transformation",         lshape_apply_transformation         },
        { "apply_inverse_transformation", lshape_apply_inverse_transformation },
        { "get_width",                    lshape_get_width                    },
        { "get_height",                   lshape_get_height                   },
        { "get_center",                   lshape_get_center                   },
        { "resize_lrtb",                  lshape_resize_lrtb                  },
        { "resize",                       lshape_resize                       },
        { "resolve_path",                 lshape_resolve_path                 },
        { "__tostring",                   lshape_tostring                     },
        { "__gc",                         lshape_destroy                      },
        { NULL,                           NULL                                }
    };
    luaL_setfuncs(L, metafuncs, 0);

    // add __index
    lua_pushstring(L, "__index");
    lua_pushvalue(L, -2); 
    lua_rawset(L, -3);

    static const luaL_Reg modfuncs[] =
    {
        { "create_rectangle_bltr", lshape_create_rectangle_bltr },
        { "create_polygon",        lshape_create_polygon        },
        { "create_path",           lshape_create_path           },
        { NULL,                    NULL                         }
    };
    luaL_setfuncs(L, modfuncs, 0);

    lua_setglobal(L, LSHAPEMODULE);

    return 0;
}
