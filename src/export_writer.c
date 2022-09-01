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

static void _push_point(lua_State* L, const point_t* pt)
{
    lua_newtable(L);
    lua_pushinteger(L, pt->x);
    lua_setfield(L, -2, "x");
    lua_pushinteger(L, pt->y);
    lua_setfield(L, -2, "y");
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

static int _write_child(struct export_writer* writer, const struct object* child, const point_t* origin)
{
    unsigned int xrep = object_get_child_xrep(child);
    unsigned int yrep = object_get_child_yrep(child);
    const char* identifier = object_get_identifier(child);
    const struct transformationmatrix* trans = object_get_transformation_matrix(child);
    unsigned int xpitch = object_get_child_xpitch(child);
    unsigned int ypitch = object_get_child_ypitch(child);
    int ret = LUA_OK;
    if(object_is_child_array(child) && _has_write_cell_array(writer))
    {
        if(writer->islua)
        {
            lua_getfield(writer->L, -1, "write_cell_array");
            lua_pushstring(writer->L, identifier);
            _push_point(writer->L, origin);
            _push_trans(writer->L, trans);
            _push_rep_pitch(writer->L, xrep, yrep, xpitch, ypitch);
            ret = lua_pcall(writer->L, 8, 0, 0);
            if(ret != LUA_OK)
            {
                return ret;
            }
        }
        else // C
        {
            writer->funcs->write_cell_array(writer->data, identifier, origin->x, origin->y, trans, xrep, yrep, xpitch, ypitch);
        }
    }
    else
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
                    lua_pushstring(writer->L, identifier);
                    lua_pushinteger(writer->L, x);
                    lua_pushinteger(writer->L, y);
                    _push_trans(writer->L, trans);
                    ret = lua_pcall(writer->L, 4, 0, 0);
                    if(ret != LUA_OK)
                    {
                        return ret;
                    }
                }
                else // C
                {
                    writer->funcs->write_cell_reference(writer->data, identifier, x, y, trans);
                }
            }
        }

    }
    return ret;
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
        return lua_pcall(writer->L, 3, 0, 0);
    }
    else // C
    {
        writer->funcs->write_rectangle(writer->data, layerdata, &bl, &tr);
        return LUA_OK;
    }
}

static int _write_polygon(struct export_writer* writer, const struct hashmap* layerdata, const struct vector* points)
{
    int ret = LUA_OK;
    if(writer->islua)
    {
        lua_getfield(writer->L, -1, "write_polygon");
        _push_layer(writer->L, layerdata);
        _push_points(writer->L, points);
        ret = lua_pcall(writer->L, 2, 0, 0);
    }
    else // C
    {
        writer->funcs->write_polygon(writer->data, layerdata, points);
        ret = LUA_OK;
    }
    return ret;
}

static int _write_cell_shape_polygon(struct export_writer* writer, const struct shape* shape, const struct transformationmatrix* trans)
{
    const struct hashmap* layerdata = shape_get_main_layerdata(shape);
    struct vector* points = vector_create(128);
    shape_get_transformed_polygon_points(shape, trans, points);
    int ret = _write_polygon(writer, layerdata, points);
    vector_destroy(points, point_destroy);
    return ret;
}

static int _write_cell_shape_triangulated_polygon(struct export_writer* writer, const struct shape* shape, const struct transformationmatrix* trans)
{
    const struct hashmap* layerdata = shape_get_main_layerdata(shape);
    struct vector* points = vector_create(128);
    shape_get_transformed_polygon_points(shape, trans, points);
    int ret = LUA_OK;
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
                ret = lua_pcall(writer->L, 4, 0, 0);
                if(ret != LUA_OK)
                {
                    ret = LUA_ERRRUN;
                }
            }
            else // C
            {
                writer->funcs->write_triangle(writer->data, layerdata, pt1, pt2, pt3);
            }
        }
        else // !has_write_triangle
        {
            struct vector* tripts = vector_create(3);
            vector_append(tripts, vector_get(points, i));
            vector_append(tripts, vector_get(points, i + 1));
            vector_append(tripts, vector_get(points, i + 2));
            ret = _write_polygon(writer, layerdata, tripts);
            vector_destroy(tripts, NULL);
        }
    }
    vector_destroy(points, point_destroy);
    return ret;
}

static int _write_cell_shape_path(struct export_writer* writer, const struct shape* shape, const struct transformationmatrix* trans)
{
    const struct hashmap* layerdata = shape_get_main_layerdata(shape);
    struct vector* points = vector_create(128);
    int ret = LUA_OK;
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
            ret = lua_pcall(writer->L, 4, 0, 0);
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
    vector_destroy(points, point_destroy);
    return ret;
}

static coordinate_t _fix_to_grid(coordinate_t c, unsigned int grid)
{
    return (c / grid) * grid;
}

static int _write_cell_shape_curve(struct export_writer* writer, const struct shape* shape, const struct transformationmatrix* trans)
{
    const struct hashmap* layerdata = shape_get_main_layerdata(shape);
    int ret = LUA_OK;
    if(_has_curve_support(writer))
    {
        point_t origin;
        shape_get_transformed_curve_origin(shape, trans, &origin);
        if(writer->islua)
        {
            lua_getfield(writer->L, -1, "setup_curve");
            _push_layer(writer->L, layerdata);
            _push_point(writer->L, &origin);
            ret = lua_pcall(writer->L, 2, 0, 0);
            if(ret != LUA_OK)
            {
                return ret;
            }
            // FIXME: implement an abstraction for this
            const struct curve* curve = shape_get_content(shape);
            struct vector_const_iterator* it = vector_const_iterator_create(curve->segments);
            point_t* lastpt = curve->origin;
            while(vector_const_iterator_is_valid(it))
            {
                const struct curve_segment* segment = vector_const_iterator_get(it);
                switch(segment->type)
                {
                    case LINESEGMENT:
                    {
                        lua_getfield(writer->L, -1, "curve_add_line_segment");
                        _push_point(writer->L, segment->data.pt);
                        ret = lua_pcall(writer->L, 1, 0, 0);
                        if(ret != LUA_OK)
                        {
                            return ret;
                        }
                        lastpt = segment->data.pt;
                        break;
                    }
                    case ARCSEGMENT:
                    {
                        lua_getfield(writer->L, -1, "curve_add_arc_segment");
                        _push_point(writer->L, lastpt);
                        lua_pushnumber(writer->L, segment->data.startangle);
                        lua_pushnumber(writer->L, segment->data.endangle);
                        lua_pushinteger(writer->L, segment->data.radius);
                        lua_pushboolean(writer->L, segment->data.clockwise);
                        ret = lua_pcall(writer->L, 5, 0, 0);
                        if(ret != LUA_OK)
                        {
                            return ret;
                        }
                        double startcos = cos(segment->data.startangle * M_PI / 180);
                        double startsin = sin(segment->data.startangle * M_PI / 180);
                        double endcos = cos(segment->data.endangle * M_PI / 180);
                        double endsin = sin(segment->data.endangle * M_PI / 180);
                        lastpt->x = lastpt->x + _fix_to_grid((endcos - startcos) * segment->data.radius, curve->grid);
                        lastpt->y = lastpt->y + _fix_to_grid((endsin - startsin) * segment->data.radius, curve->grid);
                        break;
                    }
                }
                vector_const_iterator_next(it);
            }
            vector_const_iterator_destroy(it);
            lua_getfield(writer->L, -1, "close_curve");
            ret = lua_pcall(writer->L, 0, 0, 0);
            if(ret != LUA_OK)
            {
                return ret;
            }
            return LUA_OK;
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
        struct vector* points = vector_create(128);
        shape_get_transformed_polygon_points(resolved, trans, points);
        writer->funcs->write_polygon(writer->data, layerdata, points);
        vector_destroy(points, point_destroy);
        shape_destroy(resolved);
    }
    return ret;
}

static int _write_shapes(struct export_writer* writer, const struct object* cell)
{
    struct shape_iterator* it = object_create_shape_iterator(cell);
    const struct transformationmatrix* trans = object_get_transformation_matrix(cell);
    int ret = LUA_OK;
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
        if(ret != LUA_OK)
        {
            break;
        }
        shape_iterator_next(it);
    }
    shape_iterator_destroy(it);
    return ret;
}

static int _write_children(struct export_writer* writer, const struct object* cell)
{
    struct child_iterator* it = object_create_child_iterator(cell);
    while(child_iterator_is_valid(it))
    {
        const struct object* child = child_iterator_get(it);
        point_t origin = { .x = 0, .y = 0 };
        object_transform_point(child, &origin);
        object_transform_point(cell, &origin);
        _write_child(writer, child, &origin);
        child_iterator_next(it);
    }
    child_iterator_destroy(it);
    return LUA_OK;
}

static int _write_port(struct export_writer* writer, const char* name, const struct hashmap* layerdata, point_t* where)
{
    int ret;
    if(writer->islua)
    {
        lua_getfield(writer->L, -1, "write_port");
        lua_pushstring(writer->L, name);
        _push_layer(writer->L, layerdata);
        _push_point(writer->L, where);
        ret = lua_pcall(writer->L, 3, 0, 0);
    }
    else
    {
        writer->funcs->write_port(writer->data, name, layerdata, where->x, where->y);
        ret = LUA_OK; // FIXME: don't use LUA_OK to signal success in the export module
    }
    return ret;
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
        port_iterator_get(it, &portname, &portwhere, &portlayer, &portisbusport, &portbusindex);
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
        _write_port(writer, name, layerdata, &where);
        if(busportname)
        {
            free(busportname);
        }
        port_iterator_next(it);
    }
    port_iterator_destroy(it);
    return LUA_OK;
}

static int _write_cell(struct export_writer* writer, const struct object* cell, int write_ports, char leftdelim, char rightdelim)
{
    _write_shapes(writer, cell);
    int ret = _write_children(writer, cell);
    if(ret != LUA_OK)
    {
        return ret;
    }
    if(write_ports && object_has_ports(cell))
    {
        ret = _write_ports(writer, cell, leftdelim, rightdelim);
    }
    return ret;
}

static int _call_or_pop_nil(lua_State* L, int numargs)
{
    if(!lua_isnil(L, -1 - numargs))
    {
        int ret = lua_pcall(L, numargs, 0, 0);
        if(ret != LUA_OK)
        {
            return ret;
        }
    }
    else
    {
        lua_pop(L, 1 + numargs);
    }
    return LUA_OK;
}

static int _write_cell2(struct export_writer* writer, const struct object* refcell, const char* refidentifier, int istoplevel, int write_ports, char leftdelim, char rightdelim)
{
    int ret = LUA_OK;
    if(writer->islua)
    {
        lua_getfield(writer->L, -1, "at_begin_cell");
        lua_pushstring(writer->L, refidentifier);
        lua_pushboolean(writer->L, istoplevel);
        ret = _call_or_pop_nil(writer->L, 2);
        if(ret != LUA_OK)
        {
            return ret;
        }
        ret = _write_cell(writer, refcell, write_ports, leftdelim, rightdelim);
        if(ret != LUA_OK)
        {
            return ret;
        }
        lua_getfield(writer->L, -1, "at_end_cell");
        lua_pushboolean(writer->L, istoplevel);
        _call_or_pop_nil(writer->L, 1);
    }
    else // C
    {
        writer->funcs->at_begin_cell(writer->data, refidentifier);
        _write_cell(writer, refcell, write_ports, leftdelim, rightdelim);
        writer->funcs->at_end_cell(writer->data);
    }
    return ret;
}

static int _initialize(struct export_writer* writer, const struct object* object)
{
    int ret = LUA_OK;
    if(writer->islua)
    {
        lua_getfield(writer->L, -1, "initialize");
        coordinate_t minx, maxx, miny, maxy;
        object_get_minmax_xy(object, &minx, &miny, &maxx, &maxy);
        lua_pushinteger(writer->L, minx);
        lua_pushinteger(writer->L, maxx);
        lua_pushinteger(writer->L, miny);
        lua_pushinteger(writer->L, maxy);
        ret = _call_or_pop_nil(writer->L, 4);
    }
    else // C
    {
        writer->funcs->initialize(object);
    }
    return ret;
}

static int _write_at_begin(struct export_writer* writer)
{
    int ret = LUA_OK;
    if(writer->islua)
    {
        lua_getfield(writer->L, -1, "at_begin");
        ret = _call_or_pop_nil(writer->L, 0);
        if(ret != LUA_OK)
        {
            return ret;
        }
    }
    else // C
    {
        writer->funcs->at_begin(writer->data);
    }
    return ret;
}

static int _write_at_end(struct export_writer* writer)
{
    int ret = LUA_OK;
    if(writer->islua)
    {
        lua_getfield(writer->L, -1, "at_end");
        ret = _call_or_pop_nil(writer->L, 0);
        if(ret != LUA_OK)
        {
            return ret;
        }
    }
    else // C
    {
        writer->funcs->at_end(writer->data);
    }
    return ret;
}

int export_writer_write_toplevel(struct export_writer* writer, const struct object* object, struct pcell_state* pcell_state, const char* toplevelname, int writechildrenports, char leftdelim, char rightdelim)
{
    int ret = LUA_OK;
    if(_has_initialize(writer))
    {
        ret = _initialize(writer, object);
    }
    if(ret != LUA_OK)
    {
        return ret;
    }

    if(!_has_write_cell_reference(writer))
    {
        fputs("this export does not know how to write hierarchies, hence the cell is being written flat\n", stderr);
        object = object_flatten(object, pcell_state, 0); // 0: !flattenports
    }

    ret = _write_at_begin(writer);
    if(ret != LUA_OK)
    {
        return ret;
    }

    struct cell_reference_iterator* it = pcell_create_cell_reference_iterator(pcell_state);
    while(pcell_cell_reference_iterator_is_valid(it))
    {
        char* refidentifier;
        struct object* refcell;
        int refnumused;
        pcell_cell_reference_iterator_get(it, &refidentifier, &refcell, &refnumused);
        if(refnumused > 0)
        {
            _write_cell2(writer, refcell, refidentifier, 0, writechildrenports, leftdelim, rightdelim); // 0: cell is not toplevel
        }
        pcell_cell_reference_iterator_advance(it);
    }
    pcell_destroy_cell_reference_iterator(it);

    _write_cell2(writer, object, toplevelname, 1, 1, leftdelim, rightdelim); // first 1: istoplevel, second 1: write_ports
    if(writer->islua)
    {
        lua_getfield(writer->L, -1, "finalize");
        ret = lua_pcall(writer->L, 0, 1, 0);
        if(ret != LUA_OK)
        {
            return ret;
        }
        size_t datalen;
        const char* strdata = lua_tolstring(writer->L, -1, &datalen);
        export_data_append_string(writer->data, strdata, datalen);
        lua_pop(writer->L, 1); // pop data
        return ret;
    }

    ret = _write_at_end(writer);
    if(ret != LUA_OK)
    {
        return ret;
    }
    return LUA_OK;
}

