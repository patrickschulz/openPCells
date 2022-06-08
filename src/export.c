#include "export.h"

#include "lua/lauxlib.h"
#include <stdio.h>
#include <string.h>

#include "util.h"
#include "lua_util.h"
#include "lobject.h"
#include "export_common.h"
#include "gdsexport.h"
#include "lpoint.h"
#include "filesystem.h"
#include "hashmap.h"

#define EXPORT_STATUS_SUCCESS 0
#define EXPORT_STATUS_NOTFOUND 1
#define EXPORT_STATUS_LOADERROR 2

struct export_state {
    const char* toplevelname;
    struct const_vector* searchpaths;
    char* exportname;
    char* exportlayername;
    const char* basename;
    char leftdelim, rightdelim;
    const char* const * exportoptions;
    int writechildrenports;
};

struct export_state* export_create_state(void)
{
    struct export_state* state = malloc(sizeof(*state));
    memset(state, 0, sizeof(*state));
    state->searchpaths = const_vector_create(1);
    return state;
}

void export_destroy_state(struct export_state* state)
{
    const_vector_destroy(state->searchpaths);
    if(state->exportname)
    {
        free(state->exportname);
    }
    if(state->exportlayername)
    {
        free(state->exportlayername);
    }
    free(state);
}

void export_add_searchpath(struct export_state* state, const char* path)
{
    const_vector_append(state->searchpaths, path);
}

void export_set_basename(struct export_state* state, const char* basename)
{
    state->basename = basename;
}

void export_set_toplevel_name(struct export_state* state, const char* cellname)
{
    state->toplevelname = cellname;
}

void export_set_export_options(struct export_state* state, const char** exportoptions)
{
    state->exportoptions = exportoptions;
}

void export_set_write_children_ports(struct export_state* state, int writechildrenports)
{
    state->writechildrenports = writechildrenports;
}

void export_set_bus_delimiters(struct export_state* state, char leftdelim, char rightdelim)
{
    state->leftdelim = leftdelim;
    state->rightdelim = rightdelim;
}

static void _get_exportname(const char* exportname, struct const_vector* searchpaths, char** exportname_ptr, char** exportlayername_ptr)
{
    if(!util_split_string(exportname, ':', exportlayername_ptr, exportname_ptr)) // export layers were not specified
    {
        *exportname_ptr = util_copy_string(exportname);
        char* exportlayername_from_function = export_get_export_layername(searchpaths, *exportname_ptr);
        if(exportlayername_from_function)
        {
            *exportlayername_ptr = exportlayername_from_function;
        }
        else
        {
            *exportlayername_ptr = util_copy_string(exportname);
        }
    }
}

void export_set_exportname(struct export_state* state, const char* str)
{
    char *exportname, *exportlayername;
    _get_exportname(str, state->searchpaths, &exportname, &exportlayername);
    state->exportname = exportname;
    state->exportlayername = exportlayername;
}

const char* export_get_layername(const struct export_state* state)
{
    return state->exportlayername;
}

static struct export_functions* _get_export_functions(const char* exportname)
{
    struct export_functions* funcs = NULL;
    if(strcmp(exportname, "gds") == 0)
    {
        funcs = gdsexport_get_export_functions();
    }
    else
    {

    }
    return funcs;
}

char* export_get_export_layername(struct const_vector* searchpaths, const char* exportname)
{
    struct export_functions* funcs = _get_export_functions(exportname);
    if(funcs) // C-defined exports
    {
        if(funcs->get_techexport)
        {
            char* techexport = util_copy_string(funcs->get_techexport());
            export_destroy_functions(funcs);
            return techexport;
        }
        export_destroy_functions(funcs);
    }
    else // lua-defined exports
    {
        if(searchpaths)
        {
            for(unsigned int i = 0; i < const_vector_size(searchpaths); ++i)
            {
                const char* searchpath = const_vector_get(searchpaths, i);
                size_t len = strlen(searchpath) + strlen(exportname) + 11; // + 11: "init.lua" + 2 * '/' + terminating zero
                char* exportfilename = malloc(len);
                snprintf(exportfilename, len, "%s/%s/init.lua", searchpath, exportname);
                if(!filesystem_exists(exportfilename))
                {
                    continue;
                }
                lua_State* L = util_create_basic_lua_state();
                int ret = luaL_dofile(L, exportfilename);
                free(exportfilename);
                if(ret != LUA_OK)
                {
                    fprintf(stderr, "error while loading export '%s': %s\n", exportname, lua_tostring(L, -1));
                    lua_close(L);
                    break;
                }
                if(lua_type(L, -1) == LUA_TTABLE)
                {
                    lua_getfield(L, -1, "get_techexport");
                    if(!lua_isnil(L, -1))
                    {
                        int ret = lua_pcall(L, 0, 1, 0);
                        if(ret != LUA_OK)
                        {
                            fprintf(stderr, "error while calling get_techexport: %s\n", lua_tostring(L, -1));
                            lua_close(L);
                            return NULL;
                        }
                        else
                        {
                            char* s = util_copy_string(lua_tostring(L, -1));
                            lua_close(L);
                            return s;
                        }
                    }
                    else
                    {
                        lua_close(L);
                        return NULL;
                    }
                }
                lua_close(L);
            }
        }
    }
    return NULL;
}

static void _write_ports(struct object* cell, struct export_data* data, struct export_functions* funcs, char leftdelim, char rightdelim)
{
    struct port_iterator* it = object_create_port_iterator(cell);
    while(port_iterator_is_valid(it))
    {
        struct port* port = port_iterator_get(it);
        char* name;
        if(port->isbusport)
        {
            size_t len = strlen(port->name) + 2 + util_num_digits(port->busindex);
            name = malloc(len + 1);
            snprintf(name, len + 1, "%s%c%d%c", port->name, leftdelim, port->busindex, rightdelim);
        }
        else
        {
            name = port->name;
        }
        point_t where = { .x = port->where->x, .y = port->where->y };
        object_transform_point(cell, &where);
        struct hashmap* layerdata = generics_get_first_layer_data(port->layer);
        funcs->write_port(data, name, layerdata, where.x, where.y);
        if(port->isbusport)
        {
            free(name);
        }
        port_iterator_next(it);
    }
    port_iterator_destroy(it);
}

static void _write_cell(struct object* cell, struct export_data* data, struct export_functions* funcs, int write_ports, char leftdelim, char rightdelim)
{
    for(unsigned int i = 0; i < object_get_shapes_size(cell); ++i)
    {
        struct shape* shape = object_get_transformed_shape(cell, i);
        const struct hashmap* layerdata = shape_get_main_layerdata(shape);
        if(shape_is_rectangle(shape))
        {
            point_t* bl;
            point_t* tr;
            shape_get_rectangle_points(shape, &bl, &tr);
            funcs->write_rectangle(data, layerdata, bl, tr);
        }
        if(shape_is_polygon(shape))
        {
            struct vector* points;
            shape_get_polygon_points(shape, &points);
            funcs->write_polygon(data, layerdata, points);
        }
        if(shape_is_triangulated_polygon(shape))
        {
            struct vector* points;
            shape_get_polygon_points(shape, &points);
            for(unsigned int i = 0; i < vector_size(points) - 2; i += 3)
            {
                if(funcs->write_triangle)
                {
                    funcs->write_triangle(
                        data, layerdata,
                        vector_get(points, i),
                        vector_get(points, i + 1),
                        vector_get(points, i + 2)
                    );
                }
                else
                {
                    struct vector* tripts = vector_create(3);
                    vector_append(tripts, vector_get(points, i));
                    vector_append(tripts, vector_get(points, i + 1));
                    vector_append(tripts, vector_get(points, i + 2));
                    funcs->write_polygon(data, layerdata, tripts);
                }
            }
        }
        if(shape_is_path(shape))
        {
            if(funcs->write_path)
            {
                struct vector* points;
                shape_get_path_points(shape, &points);
                ucoordinate_t width;
                shape_get_path_width(shape, &width);
                coordinate_t extension[2];
                shape_get_path_extension(shape, &extension[0], &extension[1]);
                funcs->write_path(data, layerdata, points, width, extension);
            }
            else
            {
                shape_resolve_path(shape);
                struct vector* points;
                shape_get_polygon_points(shape, &points);
                funcs->write_polygon(data, layerdata, points);
            }
        }
        if(shape_is_curve(shape))
        {
            if(funcs->setup_curve && funcs->close_curve && funcs->curve_add_line_segment)
            {
            }
            else
            {
                shape_rasterize_curve(shape);
                struct vector* points;
                shape_get_polygon_points(shape, &points);
                funcs->write_polygon(data, layerdata, points);
            }
        }
    }
    struct child_iterator* it = object_create_child_iterator(cell);
    while(child_iterator_is_valid(it))
    {
        struct object* child = child_iterator_get(it);
        point_t origin = { .x = 0, .y = 0 };
        object_transform_point(child, &origin);
        object_transform_point(cell, &origin);
        if(object_is_child_array(child) && funcs->write_cell_array)
        {
            funcs->write_cell_array(data,
                object_get_identifier(child),
                origin.x, origin.y,
                object_get_transformation_matrix(child),
                object_get_child_xrep(child), object_get_child_yrep(child),
                object_get_child_xpitch(child), object_get_child_ypitch(child)
            );
        }
        else
        {
            for(unsigned int ix = 1; ix <= object_get_child_xrep(child); ++ix)
            {
                for(unsigned int iy = 1; iy <= object_get_child_yrep(child); ++iy)
                {
                    funcs->write_cell_reference(data,
                        object_get_identifier(child),
                        origin.x + (ix - 1) * object_get_child_xpitch(child),
                        origin.y + (iy - 1) * object_get_child_ypitch(child),
                        object_get_transformation_matrix(child)
                    );
                }
            }
        }
        child_iterator_next(it);
    }
    child_iterator_destroy(it);
    if(write_ports && object_has_ports(cell))
    {
        _write_ports(cell, data, funcs, leftdelim, rightdelim);
    }
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

static void _push_point(lua_State* L, point_t* pt)
{
    lua_newtable(L);
    lua_pushinteger(L, pt->x);
    lua_setfield(L, -2, "x");
    lua_pushinteger(L, pt->y);
    lua_setfield(L, -2, "y");
}

static void _push_points(lua_State* L, struct vector* pts)
{
    lua_newtable(L);
    for(unsigned int i = 0; i < vector_size(pts); ++i)
    {
        _push_point(L, vector_get(pts, i));
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

static int _write_ports_lua(lua_State* L, struct object* cell, char leftdelim, char rightdelim)
{
    struct port_iterator* it = object_create_port_iterator(cell);
    while(port_iterator_is_valid(it))
    {
        struct port* port = port_iterator_get(it);
        char* name;
        if(port->isbusport)
        {
            size_t len = strlen(port->name) + 2 + util_num_digits(port->busindex);
            name = malloc(len + 1);
            snprintf(name, len + 1, "%s%c%d%c", port->name, leftdelim, port->busindex, rightdelim);
        }
        else
        {
            name = port->name;
        }
        point_t where = { .x = port->where->x, .y = port->where->y };
        object_transform_point(cell, &where);
        struct hashmap* layerdata = generics_get_first_layer_data(port->layer);
        lua_pushvalue(L, -1); // write_port is already on the stack (from the check if the function exists)
        lua_pushstring(L, name);
        _push_layer(L, layerdata);
        _push_point(L, &where);
        int ret = lua_pcall(L, 3, 0, 0);
        if(ret != LUA_OK)
        {
            return ret;
        }
        if(port->isbusport)
        {
            free(name);
        }
        port_iterator_next(it);
    }
    port_iterator_destroy(it);
    return LUA_OK;
}

static int _write_lua_rectangle(lua_State* L, const struct hashmap* layerdata, struct shape* shape)
{
    lua_getfield(L, -1, "write_rectangle");
    _push_layer(L, layerdata);
    point_t* bl;
    point_t* tr;
    shape_get_rectangle_points(shape, &bl, &tr);
    _push_point(L, bl);
    _push_point(L, tr);
    return lua_pcall(L, 3, 0, 0);
}

static int _write_lua_polygon(lua_State* L, const struct hashmap* layerdata, struct shape* shape)
{
    lua_getfield(L, -1, "write_polygon");
    _push_layer(L, layerdata);
    struct vector* points;
    shape_get_polygon_points(shape, &points);
    _push_points(L, points);
    return lua_pcall(L, 2, 0, 0);
}

static int _write_lua_triangulated_polygon(lua_State* L, const struct hashmap* layerdata, struct shape* shape)
{
    struct vector* points;
    shape_get_polygon_points(shape, &points);
    for(unsigned int i = 0; i < vector_size(points) - 2; i += 3)
    {
        lua_getfield(L, -1, "write_triangle");
        _push_layer(L, layerdata);
        _push_point(L, vector_get(points, i + 0));
        _push_point(L, vector_get(points, i + 1));
        _push_point(L, vector_get(points, i + 2));
        int ret = lua_pcall(L, 4, 0, 0);
        if(ret != LUA_OK)
        {
            return ret;
        }
    }
    return LUA_OK;
}

static int _write_lua_path(lua_State* L, const struct hashmap* layerdata, struct shape* shape)
{
    lua_getfield(L, -1, "write_path");
    _push_layer(L, layerdata);
    struct vector* points;
    shape_get_path_points(shape, &points);
    _push_points(L, points);
    ucoordinate_t width;
    shape_get_path_width(shape, &width);
    lua_pushinteger(L, width);
    coordinate_t extension[2];
    shape_get_path_extension(shape, &extension[0], &extension[1]);
    lua_newtable(L);
    lua_pushinteger(L, extension[0]);
    lua_rawseti(L, -2, 1);
    lua_pushinteger(L, extension[0]);
    lua_rawseti(L, -2, 2);
    return lua_pcall(L, 4, 0, 0);
}

static coordinate_t _fix_to_grid(coordinate_t c, unsigned int grid)
{
    return (c / grid) * grid;
}

static int _write_lua_curve(lua_State* L, const struct hashmap* layerdata, struct shape* shape)
{
    lua_getfield(L, -1, "setup_curve");
    _push_layer(L, layerdata);
    point_t* origin;
    shape_get_curve_origin(shape, &origin);
    _push_point(L, origin);
    int ret = lua_pcall(L, 2, 0, 0);
    if(ret != LUA_OK)
    {
        return ret;
    }
    // FIXME: implement an abstraction for this
    struct curve* curve = shape_get_content(shape);
    struct vector_iterator* it = vector_iterator_create(curve->segments);
    point_t* lastpt = curve->origin;
    while(vector_iterator_is_valid(it))
    {
        struct curve_segment* segment = vector_iterator_get(it);
        switch(segment->type)
        {
            case LINESEGMENT:
            {
                lua_getfield(L, -1, "curve_add_line_segment");
                _push_point(L, segment->data.pt);
                ret = lua_pcall(L, 1, 0, 0);
                if(ret != LUA_OK)
                {
                    return ret;
                }
                lastpt = segment->data.pt;
                break;
            }
            case ARCSEGMENT:
            {
                lua_getfield(L, -1, "curve_add_arc_segment");
                _push_point(L, lastpt);
                lua_pushnumber(L, segment->data.startangle);
                lua_pushnumber(L, segment->data.endangle);
                lua_pushinteger(L, segment->data.radius);
                lua_pushboolean(L, segment->data.clockwise);
                ret = lua_pcall(L, 5, 0, 0);
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
        vector_iterator_next(it);
    }
    lua_getfield(L, -1, "close_curve");
    ret = lua_pcall(L, 0, 0, 0);
    if(ret != LUA_OK)
    {
        return ret;
    }
    return LUA_OK;
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

static int _write_cell_lua(lua_State* L, struct object* cell, int write_ports, char leftdelim, char rightdelim)
{
    int has_write_path = _check_function(L, "write_path");
    int has_curves = _check_function(L, "setup_curve") && _check_function(L, "close_curve") && _check_function(L, "curve_add_line_segment");
    int has_write_polygon = _check_function(L, "write_polygon");
    for(unsigned int i = 0; i < object_get_shapes_size(cell); ++i)
    {
        struct shape* shape = object_get_transformed_shape(cell, i);
        const struct hashmap* layerdata = shape_get_main_layerdata(shape);
        // order of the following statements matter!
        // (e.g. if curves and polygons can't be written,
        //  a rasterized and triangulated curve can be used)
        if(shape_is_path(shape) && !has_write_path)
        {
            shape_resolve_path(shape);
        }
        if(shape_is_curve(shape) && !has_curves)
        {
            shape_rasterize_curve(shape);
        }
        if(shape_is_polygon(shape) && !has_write_polygon)
        {
            shape_triangulate_polygon(shape);
        }
        if(shape_is_rectangle(shape))
        {
            if(_write_lua_rectangle(L, layerdata, shape) != LUA_OK)
            {
                return LUA_ERRRUN;
            }
        }
        if(shape_is_polygon(shape))
        {
            if(_write_lua_polygon(L, layerdata, shape) != LUA_OK)
            {
                return LUA_ERRRUN;
            }
        }
        if(shape_is_triangulated_polygon(shape))
        {
            if(_write_lua_triangulated_polygon(L, layerdata, shape) != LUA_OK)
            {
                return LUA_ERRRUN;
            }
        }
        if(shape_is_path(shape))
        {
            if(_write_lua_path(L, layerdata, shape) != LUA_OK)
            {
                return LUA_ERRRUN;
            }
        }
        if(shape_is_curve(shape))
        {
            if(_write_lua_curve(L, layerdata, shape) != LUA_OK)
            {
                return LUA_ERRRUN;
            }
        }
    }
    struct child_iterator* it = object_create_child_iterator(cell);
    while(child_iterator_is_valid(it))
    {
        struct object* child = child_iterator_get(it);
        point_t origin = { .x = 0, .y = 0 };
        object_transform_point(child, &origin);
        object_transform_point(cell, &origin);
        if(object_is_child_array(child))
        {
            lua_getfield(L, -1, "write_cell_array");
            if(lua_isnil(L, -1))
            {
                lua_pop(L, 1);
            }
            else
            {
                lua_pushstring(L, object_get_identifier(child));
                lua_pushinteger(L, origin.x);
                lua_pushinteger(L, origin.y);
                _push_trans(L, object_get_transformation_matrix(child));
                lua_pushinteger(L, object_get_child_xrep(child));
                lua_pushinteger(L, object_get_child_yrep(child));
                lua_pushinteger(L, object_get_child_xpitch(child));
                lua_pushinteger(L, object_get_child_ypitch(child));
                int ret = lua_pcall(L, 8, 0, 0);
                if(ret != LUA_OK)
                {
                    return ret;
                }
            }
        }
        else
        {
            for(unsigned int ix = 1; ix <= object_get_child_xrep(child); ++ix)
            {
                for(unsigned int iy = 1; iy <= object_get_child_yrep(child); ++iy)
                {
                    lua_getfield(L, -1, "write_cell_reference");
                    lua_pushstring(L, object_get_identifier(child));
                    lua_pushinteger(L, origin.x + (ix - 1) * object_get_child_xpitch(child));
                    lua_pushinteger(L, origin.y + (iy - 1) * object_get_child_ypitch(child));
                    _push_trans(L, object_get_transformation_matrix(child));
                    int ret = lua_pcall(L, 4, 0, 0);
                    if(ret != LUA_OK)
                    {
                        return ret;
                    }
                }
            }
        }
        child_iterator_next(it);
    }
    child_iterator_destroy(it);
    if(write_ports && object_has_ports(cell))
    {
        lua_getfield(L, -1, "write_port");
        if(!lua_isnil(L, -1))
        {
            int ret = _write_ports_lua(L, cell, leftdelim, rightdelim);
            if(ret != LUA_OK)
            {
                return ret;
            }
        }
        lua_pop(L, 1); // pop write_port (or nil)
    }
    return LUA_OK;
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

static int _check_lua_export(lua_State* L)
{
    if(!_check_function(L, "get_extension"))
    {
        return 0;
    }
    if(!_check_function(L, "write_rectangle"))
    {
        return 0;
    }
    if(!_check_function(L, "write_polygon"))
    {
        if(!_check_function(L, "write_triangle"))
        {
            return 0;
        }
    }
    if(!_check_function(L, "finalize"))
    {
        return 0;
    }
    return 1;
}

static void _write_toplevel_C(struct object* object, struct pcell_state* pcell_state, const char* toplevelname, struct export_data* data, struct export_functions* funcs, int writechildrenports, char leftdelim, char rightdelim)
{
    if(funcs->initialize)
    {
        funcs->initialize(object);
    }
    funcs->at_begin(data);

    funcs->at_begin_cell(data, toplevelname);
    _write_cell(object, data, funcs, 1, leftdelim, rightdelim); // 1: write ports
    funcs->at_end_cell(data);

    for(unsigned int i = 0; i < pcell_get_reference_count(pcell_state); ++i)
    {
        struct cellreference* reference = pcell_get_indexed_cell_reference(pcell_state, i);
        if(reference->numused > 0)
        {
            funcs->at_begin_cell(data, reference->identifier);
            _write_cell(reference->cell, data, funcs, writechildrenports, leftdelim, rightdelim);
            funcs->at_end_cell(data);
        }
    }

    funcs->at_end(data);
}

static int _write_toplevel_lua(lua_State* L, struct object* object, struct pcell_state* pcell_state, const char* toplevelname, struct export_data* data, int writechildrenports, char leftdelim, char rightdelim)
{
    int ret;
    // check if export supports hierarchies
    lua_getfield(L, -1, "write_cell_reference");
    if(lua_isnil(L, -1))
    {
        fputs("this export does not know how to write hierarchies, hence the cell is being written flat\n", stderr);
        object_flatten(object, pcell_state, 0);
    }
    lua_pop(L, 1);

    lua_getfield(L, -1, "initialize");
    coordinate_t minx, maxx, miny, maxy;
    object_get_minmax_xy(object, &minx, &miny, &maxx, &maxy);
    lua_pushinteger(L, minx);
    lua_pushinteger(L, maxx);
    lua_pushinteger(L, miny);
    lua_pushinteger(L, maxy);
    ret = _call_or_pop_nil(L, 4);
    if(ret != LUA_OK)
    {
        return ret;
    }

    lua_getfield(L, -1, "at_begin");
    ret = _call_or_pop_nil(L, 0);
    if(ret != LUA_OK)
    {
        return ret;
    }

    lua_getfield(L, -1, "at_begin_cell");
    lua_pushstring(L, toplevelname);
    ret = _call_or_pop_nil(L, 1);
    if(ret != LUA_OK)
    {
        return ret;
    }
    ret = _write_cell_lua(L, object, 1, leftdelim, rightdelim); // 1: write ports
    if(ret != LUA_OK)
    {
        return ret;
    }
    lua_getfield(L, -1, "at_end_cell");
    _call_or_pop_nil(L, 0);

    for(unsigned int i = 0; i < pcell_get_reference_count(pcell_state); ++i)
    {
        struct cellreference* reference = pcell_get_indexed_cell_reference(pcell_state, i);
        if(reference->numused > 0)
        {
            lua_getfield(L, -1, "at_begin_cell");
            lua_pushstring(L, reference->identifier);
            _call_or_pop_nil(L, 1);
            ret = _write_cell_lua(L, reference->cell, writechildrenports, leftdelim, rightdelim);
            if(ret != LUA_OK)
            {
                return ret;
            }
            lua_getfield(L, -1, "at_end_cell");
            _call_or_pop_nil(L, 0);
        }
    }

    lua_getfield(L, -1, "at_end");
    _call_or_pop_nil(L, 0);

    lua_getfield(L, -1, "finalize");
    ret = lua_pcall(L, 0, 1, 0);
    if(ret != LUA_OK)
    {
        return ret;
    }
    size_t datalen;
    const char* strdata = lua_tolstring(L, -1, &datalen);
    export_data_append_string(data, strdata, datalen);
    lua_pop(L, 1); // pop data
    return LUA_OK;
}

void export_write_toplevel(struct object* toplevel, struct pcell_state* pcell_state, struct export_state* state)
{
    if(object_is_empty(toplevel))
    {
        puts("export: toplevel is empty");
        return;
    }

    struct export_data* data = export_create_data();
    char* extension;
    int status = EXPORT_STATUS_NOTFOUND;

    struct export_functions* funcs = _get_export_functions(state->exportname);
    if(funcs) // C-defined exports
    {
        _write_toplevel_C(toplevel, pcell_state, state->toplevelname, data, funcs, state->writechildrenports, state->leftdelim, state->rightdelim);
        extension = util_copy_string(funcs->get_extension());
        status = EXPORT_STATUS_SUCCESS;
    }
    else // lua-defined exports
    {
        if(state->searchpaths)
        {
            for(unsigned int i = 0; i < const_vector_size(state->searchpaths); ++i)
            {
                const char* searchpath = const_vector_get(state->searchpaths, i);
                size_t len = strlen(searchpath) + strlen(state->exportname) + 11; // + 11: "init.lua" + 2 * '/' + terminating zero
                char* exportfilename = malloc(len);
                snprintf(exportfilename, len, "%s/%s/init.lua", searchpath, state->exportname);
                if(!filesystem_exists(exportfilename))
                {
                    continue;
                }
                lua_State* L = util_create_basic_lua_state();
                int ret = luaL_dofile(L, exportfilename);
                free(exportfilename);
                if(ret != LUA_OK)
                {
                    status = EXPORT_STATUS_LOADERROR;
                    lua_close(L);
                    break;
                }
                if(lua_type(L, -1) == LUA_TTABLE)
                {
                    // check minimal function support
                    if(!_check_lua_export(L))
                    {
                        fprintf(stderr, "export '%s' must define at least the functions 'get_extension', 'write_rectangle', 'write_polygon' (or 'write_triangle') and 'finalize'\n", state->exportname);
                        status = EXPORT_STATUS_LOADERROR;
                        lua_close(L);
                        break;
                    }

                    // parse and set export cmd options
                    if(state->exportoptions)
                    {
                        lua_getfield(L, -1, "set_options");
                        lua_newtable(L);
                        const char* const * opt = state->exportoptions;
                        while(*opt)
                        {
                            lua_pushstring(L, *opt);
                            lua_rawseti(L, -2, opt - state->exportoptions + 1);
                            ++opt;
                        }
                        _call_or_pop_nil(L, 1);
                    }

                    int ret = _write_toplevel_lua(L, toplevel, pcell_state, state->toplevelname, data, state->writechildrenports, state->leftdelim, state->rightdelim);
                    if(ret != LUA_OK)
                    {
                        const char* msg = lua_tostring(L, -1);
                        fprintf(stderr, "error while calling lua export: %s\n", msg);
                        lua_close(L);
                        return;
                    }

                    lua_getfield(L, -1, "get_extension");
                    ret = lua_pcall(L, 0, 1, 0);
                    if(ret != LUA_OK)
                    {
                        const char* msg = lua_tostring(L, -1);
                        fprintf(stderr, "error while calling lua export: %s\n", msg);
                        lua_close(L);
                        return;
                    }
                    extension = util_copy_string(lua_tostring(L, -1));
                    lua_pop(L, 1); // pop extension
                    status = EXPORT_STATUS_SUCCESS;
                    lua_close(L);
                    break; // found export, don't continue search
                }
                lua_close(L);
            }
        }
    }

    if(status == EXPORT_STATUS_SUCCESS)
    {
        if(*state->basename == '-' && !*(state->basename + 1)) // send to standard output
        {
            export_data_write_to_file(data, stdout);
        }
        else
        {
            size_t len = strlen(state->basename) + strlen(extension) + 2; // + 2: '.' and the terminating zero
            char* filename = malloc(len);
            snprintf(filename, len + 2, "%s.%s", state->basename, extension);
            FILE* file = fopen(filename, "w");
            export_data_write_to_file(data, file);
            fclose(file);
            free(extension);
            free(filename);
        }
        export_destroy_data(data);
        export_destroy_functions(funcs);
    }
    else if(status == EXPORT_STATUS_NOTFOUND)
    {
        printf("could not find export '%s'\n", state->exportname);
    }
    else // EXPORT_STATUS_LOADERROR
    {
        puts("error while loading export");
    }
}

