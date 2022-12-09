#include "export_writer.h"

#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <assert.h>

#include "tagged_value.h"
#include "util.h"

struct export_writer {
    union {
        lua_State* L;
        const struct export_functions* funcs;
    };
    struct export_data* data;
    int islua;
};

static struct export_writer* _create(int islua, struct export_data* data, lua_State* L, const struct export_functions* funcs)
{
    struct export_writer* writer = malloc(sizeof(*writer));
    writer->islua = islua;
    if(writer->islua)
    {
        writer->L = L;
    }
    else
    {
        writer->funcs = funcs;
    }
    writer->data = data;
    return writer;
}

struct export_writer* export_writer_create_lua(lua_State* L, struct export_data* data)
{
    return _create(1, data, L, NULL);
}

struct export_writer* export_writer_create_C(const struct export_functions* funcs, struct export_data* data)
{
    return _create(0, data, NULL, funcs);
}

void export_writer_destroy(struct export_writer* writer)
{
    free(writer);
}

static int _check_function(lua_State* L, const char* funcname)
{
    lua_getfield(L, -1, funcname);
    if(lua_isnil(L, -1))
    {
        lua_pop(L, 1);
        return 0;
    }
    if(lua_type(L, -1) != LUA_TFUNCTION)
    {
        lua_pop(L, 1);
        return 0;
    }
    lua_pop(L, 1);
    return 1;
}

static void _push_layer(lua_State* L, const struct hashmap* data)
{
    lua_newtable(L);
    struct hashmap_const_iterator* it = hashmap_const_iterator_create(data);
    while(hashmap_const_iterator_is_valid(it))
    {
        lua_pushstring(L, hashmap_const_iterator_key(it));
        const struct tagged_value* value = hashmap_const_iterator_value(it);
        if(tagged_value_is_integer(value))
        {
            lua_pushinteger(L, tagged_value_get_integer(value));
        }
        if(tagged_value_is_string(value))
        {
            lua_pushstring(L, tagged_value_get_const_string(value));
        }
        if(tagged_value_is_boolean(value))
        {
            lua_pushboolean(L, tagged_value_get_boolean(value));
        }
        lua_rawset(L, -3);
        hashmap_const_iterator_next(it);
    }
    hashmap_const_iterator_destroy(it);
}

static void _push_point_xy(lua_State* L, coordinate_t x, coordinate_t y)
{
    lua_newtable(L);
    lua_pushinteger(L, x);
    lua_setfield(L, -2, "x");
    lua_pushinteger(L, y);
    lua_setfield(L, -2, "y");
}

static void _push_point(lua_State* L, const point_t* pt)
{
    _push_point_xy(L, pt->x, pt->y);
}

static void _push_points(lua_State* L, const struct vector* pts)
{
    lua_newtable(L);
    for(unsigned int i = 0; i < vector_size(pts); ++i)
    {
        _push_point(L, vector_get_const(pts, i));
        lua_rawseti(L, -2, i + 1);
    }
}

static void _push_trans(lua_State* L, const struct transformationmatrix* trans)
{
    lua_newtable(L);
    const coordinate_t* coefficients = transformationmatrix_get_coefficients(trans);
    for(unsigned int i = 0; i < 6; ++i)
    {
        lua_pushinteger(L, coefficients[i]);
        lua_rawseti(L, -2, i + 1);
    }
}

static void _push_rep_pitch(lua_State* L, unsigned int xrep, unsigned int yrep, unsigned int xpitch, unsigned int ypitch)
{
    lua_pushinteger(L, xrep);
    lua_pushinteger(L, yrep);
    lua_pushinteger(L, xpitch);
    lua_pushinteger(L, ypitch);
}

static int _has_initialize(struct export_writer* writer)
{
    if(writer->islua)
    {
        return _check_function(writer->L, "initialize");
    }
    else // C
    {
        if(writer->funcs->initialize)
        {
            return 1;
        }
    }
    return 0;
}
static int _has_write_cell_reference(struct export_writer* writer)
{
    if(writer->islua)
    {
        return _check_function(writer->L, "write_cell_reference");
    }
    else // C
    {
        if(writer->funcs->write_cell_reference)
        {
            return 1;
        }
    }
    return 0;
}

static int _has_write_triangle(struct export_writer* writer)
{
    if(writer->islua)
    {
        return _check_function(writer->L, "write_triangle");
    }
    else // C
    {
        if(writer->funcs->write_triangle)
        {
            return 1;
        }
    }
    return 0;
}

static int _has_write_path(struct export_writer* writer)
{
    if(writer->islua)
    {
        return _check_function(writer->L, "write_path");
    }
    else // C
    {
        if(writer->funcs->write_path)
        {
            return 1;
        }
    }
    return 0;
}

static int _has_write_cell_array(struct export_writer* writer)
{
    if(writer->islua)
    {
        return _check_function(writer->L, "write_cell_array");
    }
    else // C
    {
        if(writer->funcs->write_cell_array)
        {
            return 1;
        }
    }
    return 0;
}

static int _has_curve_support(struct export_writer* writer)
{
    if(writer->islua)
    {
        return _check_function(writer->L, "setup_curve") && _check_function(writer->L, "close_curve") && _check_function(writer->L, "curve_add_line_segment");
    }
    else // C
    {
        if(writer->funcs->setup_curve && writer->funcs->close_curve && writer->funcs->curve_add_line_segment)
        {
            return 1;
        }
    }
    return 0;
}

static int _write_child_array(struct export_writer* writer, const char* identifier, const point_t* origin, const struct transformationmatrix* trans, unsigned int xrep, unsigned int yrep, unsigned int xpitch, unsigned int ypitch)
{
    if(writer->islua)
    {
        lua_getfield(writer->L, -1, "write_cell_array");
        lua_pushstring(writer->L, identifier);
        lua_pushinteger(writer->L, origin->x);
        lua_pushinteger(writer->L, origin->y);
        _push_trans(writer->L, trans);
        _push_rep_pitch(writer->L, xrep, yrep, xpitch, ypitch);
        int lret = lua_pcall(writer->L, 8, 0, 0);
        if(lret != LUA_OK)
        {
            return 0;
        }
        return 1;
    }
    else // C
    {
        writer->funcs->write_cell_array(writer->data, identifier, origin->x, origin->y, trans, xrep, yrep, xpitch, ypitch);
        return 1;
    }
}

static int _write_child_single(struct export_writer* writer, const char* refname, const point_t* origin, const struct transformationmatrix* trans, unsigned int xrep, unsigned int yrep, unsigned int xpitch, unsigned int ypitch)
{
    for(unsigned int ix = 1; ix <= xrep; ++ix)
    {
        for(unsigned int iy = 1; iy <= yrep; ++iy)
        {
            coordinate_t x = origin->x + (ix - 1) * xpitch;
            coordinate_t y = origin->y + (iy - 1) * ypitch;
            if(writer->islua)
            {
                lua_getfield(writer->L, -1, "write_cell_reference");
                lua_pushstring(writer->L, refname);
                lua_pushinteger(writer->L, x);
                lua_pushinteger(writer->L, y);
                _push_trans(writer->L, trans);
                int lret = lua_pcall(writer->L, 4, 0, 0);
                if(lret != LUA_OK)
                {
                    return 0;
                }
            }
            else // C
            {
                writer->funcs->write_cell_reference(writer->data, refname, x, y, trans);
            }
        }
    }
    return 1;
}

static char* _concat_namecontext(const char* namecontext, const char* appendix)
{
    char* newcontext;
    if(namecontext)
    {
        newcontext = malloc(strlen(namecontext) + strlen(appendix) + 1 + 1); // + 1 for underscore
        sprintf(newcontext, "%s_%s", namecontext, appendix);
    }
    else
    {
        newcontext = strdup(appendix);
    }
    return newcontext;
}

static int _write_child(struct export_writer* writer, const struct object* child, const point_t* origin, const char* namecontext)
{
    unsigned int xrep = object_get_child_xrep(child);
    unsigned int yrep = object_get_child_yrep(child);
    char* refname = _concat_namecontext(namecontext, object_get_child_reference_name(child));
    const struct transformationmatrix* trans = object_get_transformation_matrix(child);
    unsigned int xpitch = object_get_child_xpitch(child);
    unsigned int ypitch = object_get_child_ypitch(child);
    // FIXME: error checking
    if(object_is_child_array(child) && _has_write_cell_array(writer))
    {
        _write_child_array(writer, refname, origin, trans, xrep, yrep, xpitch, ypitch);
    }
    else
    {
        _write_child_single(writer, refname, origin, trans, xrep, yrep, xpitch, ypitch);
    }
    free(refname);
    return 1;
}

static int _write_cell_shape_rectangle(struct export_writer* writer, const struct shape* shape, const struct transformationmatrix* trans)
{
    const struct hashmap* layerdata = shape_get_main_layerdata(shape);
    point_t bl;
    point_t tr;
    shape_get_transformed_rectangle_points(shape, trans, &bl, &tr);
    if(writer->islua)
    {
        lua_getfield(writer->L, -1, "write_rectangle");
        _push_layer(writer->L, layerdata);
        _push_point(writer->L, &bl);
        _push_point(writer->L, &tr);
        int lret = lua_pcall(writer->L, 3, 0, 0);
        if(lret != LUA_OK)
        {
            return 0;
        }
        return 1;
    }
    else // C
    {
        writer->funcs->write_rectangle(writer->data, layerdata, &bl, &tr);
        return 1;
    }
}

static int _write_polygon(struct export_writer* writer, const struct hashmap* layerdata, const struct vector* points)
{
    if(writer->islua)
    {
        lua_getfield(writer->L, -1, "write_polygon");
        _push_layer(writer->L, layerdata);
        _push_points(writer->L, points);
        int lret = lua_pcall(writer->L, 2, 0, 0);
        if(lret != LUA_OK)
        {
            return 0;
        }
        return 1;
    }
    else // C
    {
        writer->funcs->write_polygon(writer->data, layerdata, points);
        return 1;
    }
}

static int _write_cell_shape_polygon(struct export_writer* writer, const struct shape* shape, const struct transformationmatrix* trans)
{
    const struct hashmap* layerdata = shape_get_main_layerdata(shape);
    struct vector* points = vector_create(128, point_destroy);
    shape_get_transformed_polygon_points(shape, trans, points);
    int ret = _write_polygon(writer, layerdata, points);
    vector_destroy(points);
    return ret;
}

static int _write_cell_shape_triangulated_polygon(struct export_writer* writer, const struct shape* shape, const struct transformationmatrix* trans)
{
    const struct hashmap* layerdata = shape_get_main_layerdata(shape);
    struct vector* points = vector_create(128, point_destroy);
    shape_get_transformed_polygon_points(shape, trans, points);
    int ret = 1;
    for(unsigned int i = 0; i < vector_size(points) - 2; i += 3)
    {
        if(_has_write_triangle(writer))
        {
            const point_t* pt1 = vector_get_const(points, i + 0);
            const point_t* pt2 = vector_get_const(points, i + 1);
            const point_t* pt3 = vector_get_const(points, i + 2);
            if(writer->islua)
            {
                lua_getfield(writer->L, -1, "write_triangle");
                _push_layer(writer->L, layerdata);
                _push_point(writer->L, pt1);
                _push_point(writer->L, pt2);
                _push_point(writer->L, pt3);
                int lret = lua_pcall(writer->L, 4, 0, 0);
                if(lret != LUA_OK)
                {
                    ret = 0;
                    break;
                }
            }
            else // C
            {
                writer->funcs->write_triangle(writer->data, layerdata, pt1, pt2, pt3);
            }
        }
        else // !has_write_triangle
        {
            struct vector* tripts = vector_create(3, NULL);
            vector_append(tripts, vector_get(points, i));
            vector_append(tripts, vector_get(points, i + 1));
            vector_append(tripts, vector_get(points, i + 2));
            ret = _write_polygon(writer, layerdata, tripts);
            vector_destroy(tripts);
        }
    }
    vector_destroy(points);
    return ret;
}

static int _write_cell_shape_path(struct export_writer* writer, const struct shape* shape, const struct transformationmatrix* trans)
{
    const struct hashmap* layerdata = shape_get_main_layerdata(shape);
    struct vector* points = vector_create(128, point_destroy);
    int ret = 1;
    if(_has_write_path(writer))
    {
        shape_get_transformed_path_points(shape, trans, points);
        ucoordinate_t width;
        shape_get_path_width(shape, &width);
        coordinate_t extension[2];
        shape_get_path_extension(shape, &extension[0], &extension[1]);
        if(writer->islua)
        {
            lua_getfield(writer->L, -1, "write_path");
            _push_layer(writer->L, layerdata);
            _push_points(writer->L, points);
            lua_pushinteger(writer->L, width);
            lua_newtable(writer->L);
            lua_pushinteger(writer->L, extension[0]);
            lua_rawseti(writer->L, -2, 1);
            lua_pushinteger(writer->L, extension[0]);
            lua_rawseti(writer->L, -2, 2);
            int lret = lua_pcall(writer->L, 4, 0, 0);
            if(lret != LUA_OK)
            {
                ret = 0;
                goto WRITE_CELL_SHAPE_PATH_CLEANUP;
            }
        }
        else
        {
            writer->funcs->write_path(writer->data, layerdata, points, width, extension);
        }
    }
    else
    {
        struct shape* resolved = shape_resolve_path(shape);
        shape_get_transformed_polygon_points(resolved, trans, points);
        shape_destroy(resolved);
        ret = _write_polygon(writer, layerdata, points);
    }
WRITE_CELL_SHAPE_PATH_CLEANUP:
    vector_destroy(points);
    return ret;
}

static int _line_segment(const point_t* pt, void* writerv)
{
    struct export_writer* writer = writerv;
    lua_getfield(writer->L, -1, "curve_add_line_segment");
    _push_point(writer->L, pt);
    int lret = lua_pcall(writer->L, 1, 0, 0);
    if(lret != LUA_OK)
    {
        return 0;
    }
    return 1;
}
static int _arc_segment(double startangle, double endangle, coordinate_t radius, int clockwise, void* writerv)
{
    struct export_writer* writer = writerv;
    lua_getfield(writer->L, -1, "curve_add_arc_segment");
    lua_pushnumber(writer->L, startangle);
    lua_pushnumber(writer->L, endangle);
    lua_pushinteger(writer->L, radius);
    lua_pushboolean(writer->L, clockwise);
    int lret = lua_pcall(writer->L, 4, 0, 0);
    if(lret != LUA_OK)
    {
        return 0;
    }
    return 1;
}

static int _cubic_bezier_segment(const point_t* cpt1, const point_t* cpt2, const point_t* endpt, void* writerv)
{
    struct export_writer* writer = writerv;
    lua_getfield(writer->L, -1, "curve_add_cubic_bezier_segment");
    _push_point(writer->L, cpt1);
    _push_point(writer->L, cpt2);
    _push_point(writer->L, endpt);
    int lret = lua_pcall(writer->L, 3, 0, 0);
    if(lret != LUA_OK)
    {
        return 0;
    }
    return 1;
}

static int _write_cell_shape_curve(struct export_writer* writer, const struct shape* shape, const struct transformationmatrix* trans)
{
    const struct hashmap* layerdata = shape_get_main_layerdata(shape);
    if(_has_curve_support(writer))
    {
        point_t origin;
        shape_get_transformed_curve_origin(shape, trans, &origin);
        if(writer->islua)
        {
            lua_getfield(writer->L, -1, "setup_curve");
            _push_layer(writer->L, layerdata);
            _push_point(writer->L, &origin);
            int lret = lua_pcall(writer->L, 2, 0, 0);
            if(lret != LUA_OK)
            {
                return 0;
            }
            int ret = shape_foreach_curve_segments(shape, writer, _line_segment, _arc_segment, _cubic_bezier_segment);
            if(!ret)
            {
                return 0;
            }
            lua_getfield(writer->L, -1, "close_curve");
            lret = lua_pcall(writer->L, 0, 0, 0);
            if(lret != LUA_OK)
            {
                return 0;
            }
        }
        else // C
        {
            // FIXME: implement this
            assert(0);
        }
    }
    else
    {
        struct shape* resolved = shape_rasterize_curve(shape);
        struct vector* points = vector_create(128, point_destroy);
        shape_get_transformed_polygon_points(resolved, trans, points);
        _write_polygon(writer, layerdata, points);
        vector_destroy(points);
        shape_destroy(resolved);
    }
    return 1;
}

static int _write_shapes(struct export_writer* writer, const struct object* cell)
{
    struct shape_iterator* it = object_create_shape_iterator(cell);
    const struct transformationmatrix* trans = object_get_transformation_matrix(cell);
    int ret = 1;
    while(shape_iterator_is_valid(it))
    {
        const struct shape* shape = shape_iterator_get(it);
        if(shape_is_rectangle(shape))
        {
            ret = _write_cell_shape_rectangle(writer, shape, trans);
        }
        if(shape_is_polygon(shape))
        {
            ret = _write_cell_shape_polygon(writer, shape, trans);
        }
        if(shape_is_triangulated_polygon(shape))
        {
            ret = _write_cell_shape_triangulated_polygon(writer, shape, trans);
        }
        if(shape_is_path(shape))
        {
            ret = _write_cell_shape_path(writer, shape, trans);
        }
        if(shape_is_curve(shape))
        {
            ret = _write_cell_shape_curve(writer, shape, trans);
        }
        if(!ret)
        {
            break;
        }
        shape_iterator_next(it);
    }
    shape_iterator_destroy(it);
    return ret;
}

static int _write_children(struct export_writer* writer, const struct object* cell, const char* namecontext)
{
    struct child_iterator* it = object_create_child_iterator(cell);
    while(child_iterator_is_valid(it))
    {
        const struct object* child = child_iterator_get(it);
        point_t origin = { .x = 0, .y = 0 };
        object_transform_point(child, &origin);
        object_transform_point(cell, &origin);
        _write_child(writer, child, &origin, namecontext);
        child_iterator_next(it);
    }
    child_iterator_destroy(it);
    return 1;
}

static int _write_port(struct export_writer* writer, const char* name, const struct hashmap* layerdata, point_t* where, double sizehint)
{
    if(writer->islua)
    {
        lua_getfield(writer->L, -1, "write_port");
        lua_pushstring(writer->L, name);
        _push_layer(writer->L, layerdata);
        _push_point(writer->L, where);
        if(sizehint > 0.0)
        {
            lua_pushnumber(writer->L, sizehint);
        }
        else
        {
            lua_pushnil(writer->L);
        }
        int lret = lua_pcall(writer->L, 4, 0, 0);
        if(lret != LUA_OK)
        {
            return 0;
        }
        return 1;
    }
    else
    {
        writer->funcs->write_port(writer->data, name, layerdata, where->x, where->y, sizehint);
        return 1;
    }
}

static int _write_ports(struct export_writer* writer, const struct object* cell, char leftdelim, char rightdelim)
{
    struct port_iterator* it = object_create_port_iterator(cell);
    while(port_iterator_is_valid(it))
    {
        const char* portname;
        const point_t* portwhere;
        const struct generics* portlayer;
        int portisbusport;
        int portbusindex;
        double sizehint;
        port_iterator_get(it, &portname, &portwhere, &portlayer, &portisbusport, &portbusindex, &sizehint);
        point_t where = { .x = portwhere->x, .y = portwhere->y };
        object_transform_point(cell, &where);
        const struct hashmap* layerdata = generics_get_first_layer_data(portlayer);
        char* busportname = NULL;
        const char* name = portname;
        if(portisbusport)
        {
            size_t len = strlen(portname) + 2 + util_num_digits(portbusindex);
            char* busportname = malloc(len + 1);
            snprintf(busportname, len + 1, "%s%c%d%c", portname, leftdelim, portbusindex, rightdelim);
            name = busportname;
        }
        _write_port(writer, name, layerdata, &where, sizehint);
        if(busportname)
        {
            free(busportname);
        }
        port_iterator_next(it);
    }
    port_iterator_destroy(it);
    return 1;
}

static int _write_cell_elements(struct export_writer* writer, const struct object* cell, const char* namecontext, int write_ports, char leftdelim, char rightdelim)
{
    /* shapes */
    int ret = _write_shapes(writer, cell);
    if(!ret)
    {
        return 0;
    }

    /* children */
    char* newnamecontext = _concat_namecontext(namecontext, object_get_name(cell));
    /* FIXME: this behaviour would be preferable, but it currently does not work and I don't know why
    char* newnamecontext = NULL;
    if(namecontext) // don't prepend the toplevel name
    {
        newnamecontext = _concat_namecontext(namecontext, object_get_name(cell));
    }
    */
    ret = _write_children(writer, cell, newnamecontext);
    free(newnamecontext);
    if(!ret)
    {
        return 0;
    }

    /* ports */
    if(write_ports && object_has_ports(cell))
    {
        int ret = _write_ports(writer, cell, leftdelim, rightdelim);
        if(!ret)
        {
            return 0;
        }
    }
    return 1;
}

static int _call_or_pop_nil(lua_State* L, int numargs)
{
    if(!lua_isnil(L, -1 - numargs))
    {
        int lret = lua_pcall(L, numargs, 0, 0);
        if(lret != LUA_OK)
        {
            return 0;
        }
        return 1;
    }
    else
    {
        lua_pop(L, 1 + numargs);
        return 1;
    }
}

static int _write_cell(struct export_writer* writer, const struct object* cell, const char* namecontext, int istoplevel, int write_ports, char leftdelim, char rightdelim)
{
    // FIXME: split up function calls to at_begin, at_end and write_cell_elements in order to have more abstraction from lua/C
    char* name = _concat_namecontext(namecontext, object_get_name(cell));
    if(writer->islua)
    {
        lua_getfield(writer->L, -1, "at_begin_cell");
        lua_pushstring(writer->L, name);
        lua_pushboolean(writer->L, istoplevel);
        int ret = _call_or_pop_nil(writer->L, 2);
        if(!ret)
        {
            free(name);
            return 0;
        }
        ret = _write_cell_elements(writer, cell, namecontext, write_ports, leftdelim, rightdelim);
        if(!ret)
        {
            free(name);
            return 0;
        }
        lua_getfield(writer->L, -1, "at_end_cell");
        lua_pushboolean(writer->L, istoplevel);
        _call_or_pop_nil(writer->L, 1);
    }
    else // C
    {
        writer->funcs->at_begin_cell(writer->data, name);
        _write_cell_elements(writer, cell, namecontext, write_ports, leftdelim, rightdelim);
        writer->funcs->at_end_cell(writer->data);
    }
    free(name);
    return 1;
}

static int _initialize(struct export_writer* writer, const struct object* object)
{
    if(writer->islua)
    {
        lua_getfield(writer->L, -1, "initialize");
        coordinate_t minx, maxx, miny, maxy;
        object_get_minmax_xy(object, &minx, &miny, &maxx, &maxy);
        lua_pushinteger(writer->L, minx);
        lua_pushinteger(writer->L, maxx);
        lua_pushinteger(writer->L, miny);
        lua_pushinteger(writer->L, maxy);
        int ret = _call_or_pop_nil(writer->L, 4);
        if(!ret)
        {
            return 0;
        }
        return 1;
    }
    else // C
    {
        writer->funcs->initialize(object);
        return 1;
    }
}

static int _write_at_begin(struct export_writer* writer)
{
    if(writer->islua)
    {
        lua_getfield(writer->L, -1, "at_begin");
        int ret = _call_or_pop_nil(writer->L, 0);
        if(!ret)
        {
            return 0;
        }
        return 1;
    }
    else // C
    {
        writer->funcs->at_begin(writer->data);
        return 1;
    }
}

static int _write_at_end(struct export_writer* writer)
{
    if(writer->islua)
    {
        lua_getfield(writer->L, -1, "at_end");
        int ret = _call_or_pop_nil(writer->L, 0);
        if(!ret)
        {
            return 0;
        }
        return 1;
    }
    else // C
    {
        writer->funcs->at_end(writer->data);
        return 1;
    }
}

static int _write_cell_hierarchy_with_namecontext(struct export_writer* writer, const struct object* cell, const char* namecontext, int write_ports, char leftdelim, char rightdelim)
{
    struct reference_iterator* ref_it = object_create_reference_iterator(cell);
    while(reference_iterator_is_valid(ref_it))
    {
        const struct object* reference = reference_iterator_get(ref_it);
        const char* name = object_get_name(reference);
        char* newnamecontext;
        if(namecontext)
        {
            newnamecontext = malloc(strlen(namecontext) + strlen(name) + 1 + 1); // + 1 for underscore
            sprintf(newnamecontext, "%s_%s", namecontext, name);
        }
        else
        {
            newnamecontext = strdup(name);
        }
        _write_cell_hierarchy_with_namecontext(writer, reference, newnamecontext, write_ports, leftdelim, rightdelim);
        int ret = _write_cell(writer, reference, namecontext, 0, write_ports, leftdelim, rightdelim); // 0: cell is not toplevel
        if(!ret)
        {
            return 0;
        }
        free(newnamecontext);
        reference_iterator_next(ref_it);
    }
    reference_iterator_destroy(ref_it);
    return 1;
}

int export_writer_write_toplevel(struct export_writer* writer, const struct object* toplevel, int writechildrenports, char leftdelim, char rightdelim)
{
    int ret = 1;
    if(_has_initialize(writer))
    {
        ret = _initialize(writer, toplevel);
    }
    if(!ret)
    {
        return 0;
    }

    int mustdelete = 0;
    struct object* copy;
    if(!_has_write_cell_reference(writer))
    {
        fputs("this export does not know how to write hierarchies, hence the cell is being written flat\n", stderr);
        copy = object_flatten(toplevel, 0); // 0: !flattenports
        toplevel = copy; // extra pointer to silence warning
        mustdelete = 1;
    }

    ret = _write_at_begin(writer);
    if(!ret)
    {
        return 0;
    }

    _write_cell_hierarchy_with_namecontext(writer, toplevel, object_get_name(toplevel), writechildrenports, leftdelim, rightdelim);

    ret = _write_cell(writer, toplevel, NULL, 1, 1, leftdelim, rightdelim); // NULL: no name context; first 1: istoplevel, second 1: write_ports
    if(!ret)
    {
        // FIXME: proper cleanup
        return 0;
    }

    if(mustdelete)
    {
        object_destroy(copy);
    }

    ret = _write_at_end(writer);
    if(!ret)
    {
        return 0;
    }

    // finalize (only lua exports)
    if(writer->islua)
    {
        lua_getfield(writer->L, -1, "finalize");
        int lret = lua_pcall(writer->L, 0, 1, 0);
        if(lret != LUA_OK)
        {
            return 0;
        }
        size_t datalen;
        const char* strdata = lua_tolstring(writer->L, -1, &datalen);
        export_data_append_string(writer->data, strdata, datalen);
        lua_pop(writer->L, 1); // pop data
    }

    return 1;
}

