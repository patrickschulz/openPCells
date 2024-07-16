#include "export_writer.h"

#include <stdlib.h>
#include <string.h>
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

static void _push_point(lua_State* L, const struct point* pt)
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

static void _push_rep_pitch(lua_State* L, unsigned int xrep, unsigned int yrep, coordinate_t xpitch, coordinate_t ypitch)
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

static int _has_write_path_extension(struct export_writer* writer)
{
    if(writer->islua)
    {
        return _check_function(writer->L, "write_path");
    }
    else // C
    {
        if(writer->funcs->write_path_extension)
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
        if(writer->funcs->write_path_extension || writer->funcs->write_path)
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

static int _pcall(lua_State* L, int nargs, int nresults, const char* str)
{
    int lret = lua_pcall(L, nargs, nresults, 0);
    if(lret != LUA_OK)
    {
        const char* msg = lua_tostring(L, -1);
        char* copy = util_strdup(msg);
        lua_pop(L, 1);
        lua_pushfstring(L, "%s (%s)", copy, str);
        free(copy);
        return 0;
    }
    else
    {
        return 1;
    }
}

static int _write_child_array(struct export_writer* writer, const char* identifier, const char* instbasename, const struct point* origin, const struct transformationmatrix* trans, unsigned int xrep, unsigned int yrep, coordinate_t xpitch, coordinate_t ypitch)
{
    if(writer->islua)
    {
        lua_getfield(writer->L, -1, "write_cell_array");
        lua_pushstring(writer->L, identifier);
        lua_pushstring(writer->L, instbasename);
        _push_point(writer->L, origin);
        _push_trans(writer->L, trans);
        _push_rep_pitch(writer->L, xrep, yrep, xpitch, ypitch);
        int ret = _pcall(writer->L, 8, 0, "write_cell_array");
        if(!ret)
        {
            return 0;
        }
        return 1;
    }
    else // C
    {
        writer->funcs->write_cell_array(writer->data, identifier, instbasename, origin, trans, xrep, yrep, xpitch, ypitch);
        return 1;
    }
}

static int _write_child_manual_array(struct export_writer* writer, const char* refname, const char* instname, const struct point* origin, const struct transformationmatrix* trans, unsigned int xrep, unsigned int yrep, coordinate_t xpitch, coordinate_t ypitch)
{
    for(unsigned int ix = 1; ix <= xrep; ++ix)
    {
        for(unsigned int iy = 1; iy <= yrep; ++iy)
        {
            struct point where = {
                .x = origin->x + (ix - 1) * xpitch,
                .y = origin->y + (iy - 1) * ypitch
            };
            if(writer->islua)
            {
                lua_getfield(writer->L, -1, "write_cell_reference");
                lua_pushstring(writer->L, refname);
                lua_pushfstring(writer->L, "%s_%d_%d", instname, ix, iy);
                _push_point(writer->L, &where);
                _push_trans(writer->L, trans);
                int ret = _pcall(writer->L, 4, 0, "write_cell_reference");
                if(!ret)
                {
                    return 0;
                }
            }
            else // C
            {
                writer->funcs->write_cell_reference(writer->data, refname, instname, &where, trans);
            }
        }
    }
    return 1;
}

static int _write_child_single(struct export_writer* writer, const char* refname, const char* instname, const struct point* origin, const struct transformationmatrix* trans)
{
    if(writer->islua)
    {
        lua_getfield(writer->L, -1, "write_cell_reference");
        lua_pushstring(writer->L, refname);
        lua_pushstring(writer->L, instname);
        _push_point(writer->L, origin);
        _push_trans(writer->L, trans);
        int ret = _pcall(writer->L, 4, 0, "write_cell_reference");
        if(!ret)
        {
            return 0;
        }
    }
    else // C
    {
        writer->funcs->write_cell_reference(writer->data, refname, instname, origin, trans);
    }
    return 1;
}

static char* _concat_namecontext(const char* namecontext, const char* appendix)
{
    char* newcontext;
    if(namecontext)
    {
        newcontext = malloc(strlen(namecontext) + strlen(appendix) + 1 + 1); // + 1 for underscore
        if(!newcontext)
        {
            return NULL;
        }
        sprintf(newcontext, "%s_%s", namecontext, appendix);
    }
    else
    {
        newcontext = util_strdup(appendix);
    }
    return newcontext;
}

static int _write_child(struct export_writer* writer, const struct object* child, const struct point* origin, const char* namecontext, int expand_namecontext)
{
    unsigned int xrep = object_get_child_xrep(child);
    unsigned int yrep = object_get_child_yrep(child);
    char* refname = _concat_namecontext(expand_namecontext ? namecontext : NULL, object_get_child_reference_name(child));
    const char* instname = object_get_name(child);
    const struct transformationmatrix* trans = object_get_transformation_matrix(child);
    coordinate_t xpitch = object_get_child_xpitch(child);
    coordinate_t ypitch = object_get_child_ypitch(child);
    // FIXME: error checking
    if(object_is_child_array(child) && _has_write_cell_array(writer))
    {
        int ret = _write_child_array(writer, refname, instname, origin, trans, xrep, yrep, xpitch, ypitch);
        if(!ret)
        {
            free(refname);
            return 0;
        }
    }
    else
    {
        // this check is necessary for pretty-printing of singular instance names (e.g. avoid names like 'instance_1_1' when there is only one)
        if(xrep > 1 && yrep > 1)
        {
            int ret = _write_child_manual_array(writer, refname, instname, origin, trans, xrep, yrep, xpitch, ypitch);
            if(!ret)
            {
                free(refname);
                return 0;
            }
        }
        else
        {
            int ret = _write_child_single(writer, refname, instname, origin, trans);
            if(!ret)
            {
                free(refname);
                return 0;
            }
        }
    }
    free(refname);
    return 1;
}

static int _write_cell_shape_rectangle(struct export_writer* writer, const struct shape* shape, const struct transformationmatrix* trans)
{
    const struct hashmap* layerdata = shape_get_main_layerdata(shape);
    struct point bl;
    struct point tr;
    shape_get_transformed_rectangle_points(shape, trans, &bl, &tr);
    if(writer->islua)
    {
        lua_getfield(writer->L, -1, "write_rectangle");
        _push_layer(writer->L, layerdata);
        _push_point(writer->L, &bl);
        _push_point(writer->L, &tr);
        int ret = _pcall(writer->L, 3, 0, "write_rectangle");
        if(!ret)
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
        int ret = _pcall(writer->L, 2, 0, "write_polygon");
        if(!ret)
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
            const struct point* pt1 = vector_get_const(points, i + 0);
            const struct point* pt2 = vector_get_const(points, i + 1);
            const struct point* pt3 = vector_get_const(points, i + 2);
            if(writer->islua)
            {
                lua_getfield(writer->L, -1, "write_triangle");
                _push_layer(writer->L, layerdata);
                _push_point(writer->L, pt1);
                _push_point(writer->L, pt2);
                _push_point(writer->L, pt3);
                ret = _pcall(writer->L, 4, 0, "write_triangle");
                if(!ret)
                {
                    goto WRITE_CELL_SHAPE_TRIANGULATED_POLYGON_CLEANUP;
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
WRITE_CELL_SHAPE_TRIANGULATED_POLYGON_CLEANUP:
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
            ret = _pcall(writer->L, 4, 0, "write_path");
            if(!ret)
            {
                goto WRITE_CELL_SHAPE_PATH_CLEANUP;
            }
        }
        else
        {
            if(_has_write_path_extension(writer))
            {
                writer->funcs->write_path_extension(writer->data, layerdata, points, width, extension);
            }
            else
            {
                writer->funcs->write_path(writer->data, layerdata, points, width);
            }
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

static int _line_segment(const struct point* pt, void* writerv)
{
    struct export_writer* writer = writerv;
    lua_getfield(writer->L, -1, "curve_add_line_segment");
    _push_point(writer->L, pt);
    int ret = _pcall(writer->L, 1, 0, "curve_add_line_segment");
    if(!ret)
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
    int ret = _pcall(writer->L, 4, 0, "curve_add_arc_segment");
    if(!ret)
    {
        return 0;
    }
    return 1;
}

static int _cubic_bezier_segment(const struct point* cpt1, const struct point* cpt2, const struct point* endpt, void* writerv)
{
    struct export_writer* writer = writerv;
    lua_getfield(writer->L, -1, "curve_add_cubic_bezier_segment");
    _push_point(writer->L, cpt1);
    _push_point(writer->L, cpt2);
    _push_point(writer->L, endpt);
    int ret = _pcall(writer->L, 3, 0, "curve_add_cubic_bezier_segment");
    if(!ret)
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
        struct point origin;
        shape_get_transformed_curve_origin(shape, trans, &origin);
        if(writer->islua)
        {
            lua_getfield(writer->L, -1, "setup_curve");
            _push_layer(writer->L, layerdata);
            _push_point(writer->L, &origin);
            int ret = _pcall(writer->L, 2, 0, "setup_curve");
            if(!ret)
            {
                return 0;
            }
            ret = shape_foreach_curve_segments(shape, writer, _line_segment, _arc_segment, _cubic_bezier_segment);
            if(!ret)
            {
                return 0;
            }
            lua_getfield(writer->L, -1, "close_curve");
            ret = _pcall(writer->L, 0, 0, "close_curve");
            if(!ret)
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
        else if(shape_is_polygon(shape))
        {
            ret = _write_cell_shape_polygon(writer, shape, trans);
        }
        else if(shape_is_triangulated_polygon(shape))
        {
            ret = _write_cell_shape_triangulated_polygon(writer, shape, trans);
        }
        else if(shape_is_path(shape))
        {
            ret = _write_cell_shape_path(writer, shape, trans);
        }
        else if(shape_is_curve(shape))
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

static int _write_children(struct export_writer* writer, const struct object* cell, const char* namecontext, int expand_namecontext)
{
    struct child_iterator* it = object_create_child_iterator(cell);
    while(child_iterator_is_valid(it))
    {
        const struct object* child = child_iterator_get(it);
        struct point origin = { .x = 0, .y = 0 };
        object_transform_point(child, &origin);
        object_transform_point(cell, &origin);
        _write_child(writer, child, &origin, namecontext, expand_namecontext);
        child_iterator_next(it);
    }
    child_iterator_destroy(it);
    return 1;
}

static int _write_port(struct export_writer* writer, const char* name, const struct hashmap* layerdata, struct point* where, unsigned int sizehint)
{
    if(writer->islua)
    {
        lua_getfield(writer->L, -1, "write_port");
        lua_pushstring(writer->L, name);
        _push_layer(writer->L, layerdata);
        _push_point(writer->L, where);
        if(sizehint > 0)
        {
            lua_pushinteger(writer->L, sizehint);
        }
        else
        {
            lua_pushnil(writer->L);
        }
        int ret = _pcall(writer->L, 4, 0, "write_port");
        if(!ret)
        {
            return 0;
        }
        return 1;
    }
    else
    {
        writer->funcs->write_port(writer->data, name, layerdata, where, sizehint);
        return 1;
    }
}

static int _write_ports(struct export_writer* writer, const struct object* cell, char leftdelim, char rightdelim)
{
    struct port_iterator* it = object_create_port_iterator(cell);
    int ret = 1;
    while(port_iterator_is_valid(it))
    {
        const char* portname;
        const struct point* portwhere;
        const struct generics* portlayer;
        int portisbusport;
        int portbusindex;
        unsigned int sizehint;
        port_iterator_get(it, &portname, &portwhere, &portlayer, &portisbusport, &portbusindex, &sizehint);
        struct point where = { .x = portwhere->x, .y = portwhere->y };
        object_transform_point(cell, &where);
        const struct hashmap* layerdata = generics_get_first_layer_data(portlayer);
        char* busportname = NULL;
        const char* name = portname;
        if(portisbusport)
        {
            size_t len = strlen(portname) + 2 + util_num_digits(portbusindex);
            busportname = malloc(len + 1);
            snprintf(busportname, len + 1, "%s%c%d%c", portname, leftdelim, portbusindex, rightdelim);
            name = busportname;
        }
        ret = _write_port(writer, name, layerdata, &where, sizehint);
        if(portisbusport)
        {
            free(busportname);
        }
        if(!ret)
        {
            break;
        }
        port_iterator_next(it);
    }
    port_iterator_destroy(it);
    return ret;
}

static int _write_label(struct export_writer* writer, const char* name, const struct hashmap* layerdata, struct point* where, unsigned int sizehint)
{
    if(writer->islua)
    {
        lua_getfield(writer->L, -1, "write_label");
        if(lua_isnil(writer->L, -1))
        {
            lua_pop(writer->L, 1);
            lua_getfield(writer->L, -1, "write_port");
        }
        lua_pushstring(writer->L, name);
        _push_layer(writer->L, layerdata);
        _push_point(writer->L, where);
        if(sizehint > 0)
        {
            lua_pushinteger(writer->L, sizehint);
        }
        else
        {
            lua_pushnil(writer->L);
        }
        int ret = _pcall(writer->L, 4, 0, "write_label");
        if(!ret)
        {
            return 0;
        }
        return 1;
    }
    else
    {
        if(writer->funcs->write_label)
        {
            writer->funcs->write_label(writer->data, name, layerdata, where, sizehint);
        }
        else
        {
            writer->funcs->write_port(writer->data, name, layerdata, where, sizehint);
        }
        return 1;
    }
}

static int _write_labels(struct export_writer* writer, const struct object* cell)
{
    struct label_iterator* it = object_create_label_iterator(cell);
    int ret = 1;
    while(label_iterator_is_valid(it))
    {
        const char* labelname;
        const struct point* labelwhere;
        const struct generics* labellayer;
        unsigned int sizehint;
        label_iterator_get(it, &labelname, &labelwhere, &labellayer, &sizehint);
        struct point where = { .x = labelwhere->x, .y = labelwhere->y };
        object_transform_point(cell, &where);
        const struct hashmap* layerdata = generics_get_first_layer_data(labellayer);
        ret = _write_label(writer, labelname, layerdata, &where, sizehint);
        if(!ret)
        {
            break;
        }
        label_iterator_next(it);
    }
    label_iterator_destroy(it);
    return ret;
}

static int _write_cell_elements(struct export_writer* writer, const struct object* cell, const char* namecontext, int expand_namecontext, int write_ports, char leftdelim, char rightdelim)
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
    ret = _write_children(writer, cell, newnamecontext, expand_namecontext);
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

    /* label */
    ret = _write_labels(writer, cell);
    if(!ret)
    {
        return 0;
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

static int _write_cell(struct export_writer* writer, const struct object* cell, const char* namecontext, int expand_namecontext, int istoplevel, int write_ports, char leftdelim, char rightdelim)
{
    // FIXME: split up function calls to at_begin, at_end and write_cell_elements in order to have more abstraction from lua/C
    char* name = _concat_namecontext(expand_namecontext ? namecontext : NULL, object_get_name(cell));
    if(writer->islua)
    {
        lua_getfield(writer->L, -1, "at_begin_cell");
        lua_pushstring(writer->L, name);
        lua_pushboolean(writer->L, istoplevel);
        int ret = _call_or_pop_nil(writer->L, 2);
        if(!ret)
        {
            //_append_to_error_msg(writer->L, " (at_begin_cell)");
            free(name);
            return 0;
        }
        ret = _write_cell_elements(writer, cell, namecontext, expand_namecontext, write_ports, leftdelim, rightdelim);
        if(!ret)
        {
            free(name);
            return 0;
        }
        lua_getfield(writer->L, -1, "at_end_cell");
        lua_pushboolean(writer->L, istoplevel);
        ret = _call_or_pop_nil(writer->L, 1);
        if(!ret)
        {
            //_append_to_error_msg(writer->L, " (at_end_cell)");
            free(name);
            return 0;
        }
    }
    else // C
    {
        writer->funcs->at_begin_cell(writer->data, name, istoplevel);
        _write_cell_elements(writer, cell, namecontext, expand_namecontext, write_ports, leftdelim, rightdelim);
        writer->funcs->at_end_cell(writer->data, istoplevel);
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
        object_get_minmax_xy(object, &minx, &miny, &maxx, &maxy, NULL); // NULL: no extra transformation matrix
        lua_pushinteger(writer->L, minx);
        lua_pushinteger(writer->L, maxx);
        lua_pushinteger(writer->L, miny);
        lua_pushinteger(writer->L, maxy);
        int ret = _pcall(writer->L, 4, 0, "initialize");
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

static int _write_cell_hierarchy_with_namecontext(struct export_writer* writer, const struct object* cell, const char* namecontext, int expand_namecontext, int write_ports, char leftdelim, char rightdelim)
{
    struct reference_iterator* ref_it = object_create_reference_iterator(cell);
    while(reference_iterator_is_valid(ref_it))
    {
        const struct object* reference = reference_iterator_get(ref_it);
        if(object_is_used(reference))
        {
            const char* name = object_get_name(reference);
            char* newnamecontext;
            // FIXME: save already-exported reference names, as there can be duplicates
            if(namecontext)
            {
                newnamecontext = malloc(strlen(namecontext) + strlen(name) + 1 + 1); // + 1 for underscore
                if(!newnamecontext)
                {
                    reference_iterator_destroy(ref_it);
                    return 0;
                }
                sprintf(newnamecontext, "%s_%s", namecontext, name);
            }
            else
            {
                newnamecontext = util_strdup(name);
            }
            _write_cell_hierarchy_with_namecontext(writer, reference, newnamecontext, expand_namecontext, write_ports, leftdelim, rightdelim);
            int ret = _write_cell(writer, reference, namecontext, expand_namecontext, 0, write_ports, leftdelim, rightdelim); // 0: cell is not toplevel
            if(!ret)
            {
                return 0;
            }
            free(newnamecontext);
        }
        reference_iterator_next(ref_it);
    }
    reference_iterator_destroy(ref_it);
    return 1;
}

int export_writer_write_toplevel(struct export_writer* writer, const struct object* toplevel, int expand_namecontext, int writeports, int writechildrenports, char leftdelim, char rightdelim)
{
    int ret = 1;
    if(_has_initialize(writer))
    {
        ret = _initialize(writer, toplevel);
    }
    if(!ret)
    {
        fputs("export_writer_write_toplevel: could not initialize export\n", stderr);
        return 0;
    }

    int mustdelete = 0;
    struct object* copy;
    if(!_has_write_cell_reference(writer) && !_has_write_path_extension(writer))
    {
        fputs("this export does not know how to write hierarchies, hence the cell is being written flat\n", stderr);
        fputs("this export does not know how to write path extensions, hence all path extensions are being resolved\n", stderr);
        copy = object_flatten(toplevel, 0); // 0: !flattenports
        object_foreach_shapes(copy, shape_resolve_path_extensions_inline);
        toplevel = copy; // extra pointer to silence warning
        mustdelete = 1;
    }
    else if(!_has_write_path_extension(writer))
    {
        fputs("this export does not know how to write path extensions, hence all path extensions are being resolved\n", stderr);
        copy = object_copy(toplevel);
        object_foreach_shapes(copy, shape_resolve_path_extensions_inline);
        toplevel = copy; // extra pointer to silence warning
        mustdelete = 1;
    }
    else if(!_has_write_cell_reference(writer))
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

    _write_cell_hierarchy_with_namecontext(writer, toplevel, object_get_name(toplevel), expand_namecontext, writechildrenports, leftdelim, rightdelim);

    ret = _write_cell(writer, toplevel, NULL, expand_namecontext, 1, writeports, leftdelim, rightdelim); // NULL: no name context; first 1: istoplevel, second 1: write_ports
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
        ret = _pcall(writer->L, 0, 1, "finalize");
        if(!ret)
        {
            return 0;
        }
        if(lua_type(writer->L, -1) != LUA_TSTRING)
        {
            lua_pushstring(writer->L, "finalize() did not return a string");
            return 0;
        }
        size_t datalen;
        const char* strdata = lua_tolstring(writer->L, -1, &datalen);
        export_data_append_string_len(writer->data, strdata, datalen);
        lua_pop(writer->L, 1); // pop data
    }

    return 1;
}

