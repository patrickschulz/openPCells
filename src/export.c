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

#define EXPORT_STATUS_SUCCESS 0
#define EXPORT_STATUS_NOTFOUND 1
#define EXPORT_STATUS_LOADERROR 2

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
            return util_copy_string(funcs->get_techexport());
        }
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

static void _write_ports(object_t* cell, struct export_data* data, struct export_functions* funcs, char leftdelim, char rightdelim)
{
    for(unsigned int i = 0; i < cell->ports_size; ++i)
    {
        char* name;
        if(cell->ports[i]->isbusport)
        {
            size_t len = strlen(cell->ports[i]->name) + 2 + util_num_digits(cell->ports[i]->busindex);
            name = malloc(len + 1);
            snprintf(name, len + 1, "%s%c%d%c", cell->ports[i]->name, leftdelim, cell->ports[i]->busindex, rightdelim);
        }
        else
        {
            name = cell->ports[i]->name;
        }
        transformationmatrix_apply_transformation(cell->trans, cell->ports[i]->where);
        struct keyvaluearray* layerdata = cell->ports[i]->layer->data[0];
        funcs->write_port(data, name, layerdata, cell->ports[i]->where->x, cell->ports[i]->where->y);
        if(cell->ports[i]->isbusport)
        {
            free(name);
        }
    }
}

static void _write_cell(object_t* cell, struct export_data* data, struct export_functions* funcs, int write_ports, char leftdelim, char rightdelim)
{
    for(unsigned int i = 0; i < cell->shapes_size; ++i)
    {
        shape_t* shape = cell->shapes[i];
        shape_apply_transformation(shape, cell->trans);
        struct keyvaluearray* layerdata = shape->layer->data[0];
        switch(shape->type)
        {
            case RECTANGLE:
                funcs->write_rectangle(data, layerdata, shape->points[0], shape->points[1]);
                break;
            case POLYGON:
                funcs->write_polygon(data, layerdata, shape->points, shape->size);
                break;
            case PATH:
                if(funcs->write_path)
                {
                    path_properties_t* properties = shape->properties;
                    funcs->write_path(data, layerdata, shape->points, shape->size, properties->width, properties->extension);
                }
                else
                {
                    shape_resolve_path(shape);
                    funcs->write_polygon(data, layerdata, shape->points, shape->size);
                }
                break;
        }
    }
    if(cell->children)
    {
        for(unsigned int i = 0; i < vector_size(cell->children); ++i)
        {
            point_t origin = { .x = 0, .y = 0 };
            object_t* child = vector_get(cell->children, i);
            transformationmatrix_apply_transformation(child->trans, &origin);
            transformationmatrix_apply_transformation(cell->trans, &origin);
            if(child->isarray && funcs->write_cell_array)
            {
                funcs->write_cell_array(data, child->identifier, origin.x, origin.y, child->trans, child->xrep, child->yrep, child->xpitch, child->ypitch);
            }
            else
            {
                for(unsigned int ix = 1; ix <= child->xrep; ++ix)
                {
                    for(unsigned int iy = 1; iy <= child->yrep; ++iy)
                    {
                        funcs->write_cell_reference(data, child->identifier, origin.x + (ix - 1) * child->xpitch, origin.y + (iy - 1) * child->ypitch, child->trans);
                    }
                }
            }
        }
    }
    if(write_ports)
    {
        _write_ports(cell, data, funcs, leftdelim, rightdelim);
    }
}

static void _push_layer(lua_State* L, struct keyvaluearray* data)
{
    lua_newtable(L);
    for(unsigned int i = 0; i < keyvaluearray_size(data); ++i)
    {
        struct keyvaluepair* pair = keyvaluearray_get_indexed_pair(data, i);
        lua_pushstring(L, pair->key);
        switch(pair->tag)
        {
            case INT:
                lua_pushinteger(L, *(int*)pair->value);
                break;
            case STRING:
                lua_pushstring(L, (const char*)pair->value);
                break;
            case BOOLEAN:
                lua_pushboolean(L, *(int*)pair->value);
                break;
            default: // silence warning about unhandled UNTAGGED
                break;
        }
        lua_rawset(L, -3);
    }
}

static void _push_point(lua_State* L, point_t* pt)
{
    lua_newtable(L);
    lua_pushinteger(L, pt->x);
    lua_setfield(L, -2, "x");
    lua_pushinteger(L, pt->y);
    lua_setfield(L, -2, "y");
}

static void _push_points(lua_State* L, point_t** pts, size_t len)
{
    lua_newtable(L);
    for(unsigned int i = 0; i < len; ++i)
    {
        _push_point(L, pts[i]);
        lua_rawseti(L, -2, i + 1);
    }
}

static void _push_trans(lua_State* L, transformationmatrix_t* trans)
{
    lua_newtable(L);
    for(unsigned int i = 0; i < 6; ++i)
    {
        lua_pushinteger(L, trans->coefficients[i]);
        lua_rawseti(L, -2, i + 1);
    }
}

static int _write_ports_lua(lua_State* L, object_t* cell, char leftdelim, char rightdelim)
{
    for(unsigned int i = 0; i < cell->ports_size; ++i)
    {
        char* name;
        if(cell->ports[i]->isbusport)
        {
            size_t len = strlen(cell->ports[i]->name) + 2 + util_num_digits(cell->ports[i]->busindex);
            name = malloc(len + 1);
            snprintf(name, len + 1, "%s%c%d%c", cell->ports[i]->name, leftdelim, cell->ports[i]->busindex, rightdelim);
        }
        else
        {
            name = cell->ports[i]->name;
        }
        transformationmatrix_apply_transformation(cell->trans, cell->ports[i]->where);
        struct keyvaluearray* layerdata = cell->ports[i]->layer->data[0];
        lua_pushvalue(L, -1); // write_port is already on the stack (from the check if the function exists)
        lua_pushstring(L, name);
        _push_layer(L, layerdata);
        _push_point(L, cell->ports[i]->where);
        int ret = lua_pcall(L, 3, 0, 0);
        if(ret != LUA_OK)
        {
            return ret;
        }
        if(cell->ports[i]->isbusport)
        {
            free(name);
        }
    }
    return LUA_OK;
}

static int _write_cell_lua(lua_State* L, object_t* cell, int write_ports, char leftdelim, char rightdelim)
{
    int has_write_path = 0;
    lua_getfield(L, -1, "write_path");
    if(!lua_isnil(L, -1))
    {
        has_write_path = 1;
    }
    lua_pop(L, 1);
    for(unsigned int i = 0; i < cell->shapes_size; ++i)
    {
        shape_t* shape = cell->shapes[i];
        shape_apply_transformation(shape, cell->trans);
        struct keyvaluearray* layerdata = shape->layer->data[0];
        if(!has_write_path && shape->type == PATH)
        {
            shape_resolve_path(shape);
        }
        switch(shape->type)
        {
            case RECTANGLE:
            {
                lua_getfield(L, -1, "write_rectangle");
                _push_layer(L, layerdata);
                _push_point(L, shape->points[0]);
                _push_point(L, shape->points[1]);
                int ret = lua_pcall(L, 3, 0, 0);
                if(ret != LUA_OK)
                {
                    return ret;
                }
                break;
            }
            case POLYGON:
            {
                lua_getfield(L, -1, "write_polygon");
                _push_layer(L, layerdata);
                _push_points(L, shape->points, shape->size);
                int ret = lua_pcall(L, 2, 0, 0);
                if(ret != LUA_OK)
                {
                    return ret;
                }
                break;
            }
            case PATH:
            {
                lua_getfield(L, -1, "write_path");
                path_properties_t* properties = shape->properties;
                _push_layer(L, layerdata);
                _push_points(L, shape->points, shape->size);
                lua_pushinteger(L, properties->width);
                lua_newtable(L);
                lua_pushinteger(L, properties->extension[0]);
                lua_rawseti(L, -2, 1);
                lua_pushinteger(L, properties->extension[0]);
                lua_rawseti(L, -2, 2);
                int ret = lua_pcall(L, 4, 0, 0);
                if(ret != LUA_OK)
                {
                    return ret;
                }
                break;
            }
        }
    }
    if(cell->children)
    {
        for(unsigned int i = 0; i < vector_size(cell->children); ++i)
        {
            point_t origin = { .x = 0, .y = 0 };
            object_t* child = vector_get(cell->children, i);
            transformationmatrix_apply_transformation(child->trans, &origin);
            transformationmatrix_apply_transformation(cell->trans, &origin);
            if(child->isarray)
            {
                lua_getfield(L, -1, "write_cell_array");
                if(lua_isnil(L, -1))
                {
                    lua_pop(L, 1);
                }
                else
                {
                    lua_pushstring(L, child->identifier);
                    lua_pushinteger(L, origin.x);
                    lua_pushinteger(L, origin.y);
                    _push_trans(L, child->trans);
                    lua_pushinteger(L, child->xrep);
                    lua_pushinteger(L, child->yrep);
                    lua_pushinteger(L, child->xpitch);
                    lua_pushinteger(L, child->ypitch);
                    int ret = lua_pcall(L, 8, 0, 0);
                    if(ret != LUA_OK)
                    {
                        return ret;
                    }
                }
            }
            else
            {
                for(unsigned int ix = 1; ix <= child->xrep; ++ix)
                {
                    for(unsigned int iy = 1; iy <= child->yrep; ++iy)
                    {
                        lua_getfield(L, -1, "write_cell_reference");
                        lua_pushstring(L, child->identifier);
                        lua_pushinteger(L, origin.x + (ix - 1) * child->xpitch);
                        lua_pushinteger(L, origin.y + (iy - 1) * child->ypitch);
                        _push_trans(L, child->trans);
                        int ret = lua_pcall(L, 4, 0, 0);
                        if(ret != LUA_OK)
                        {
                            return ret;
                        }
                    }
                }
            }
        }
    }
    if(write_ports)
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
        return 0;
    }
    if(!_check_function(L, "finalize"))
    {
        return 0;
    }
    return 1;
}

static void _write_toplevel_C(object_t* object, struct pcell_state* pcell_state, const char* toplevelname, struct export_data* data, struct export_functions* funcs, int writechildrenports, char leftdelim, char rightdelim)
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

static int _write_toplevel_lua(lua_State* L, object_t* object, struct pcell_state* pcell_state, const char* toplevelname, struct export_data* data, int writechildrenports, char leftdelim, char rightdelim)
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

void export_write_toplevel(object_t* toplevel, struct pcell_state* pcell_state, struct const_vector* searchpaths, const char* exportname, const char* basename, const char* toplevelname, char leftdelim, char rightdelim, const char* const * exportoptions, int writechildrenports)
{
    if(object_is_empty(toplevel))
    {
        puts("export: toplevel is empty");
        return;
    }

    struct export_data* data = export_create_data();
    char* extension;
    int status = EXPORT_STATUS_NOTFOUND;

    struct export_functions* funcs = _get_export_functions(exportname);
    if(funcs) // C-defined exports
    {
        _write_toplevel_C(toplevel, pcell_state, toplevelname, data, funcs, writechildrenports, leftdelim, rightdelim);
        extension = util_copy_string(funcs->get_extension());
        status = EXPORT_STATUS_SUCCESS;
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
                    status = EXPORT_STATUS_LOADERROR;
                    lua_close(L);
                    break;
                }
                if(lua_type(L, -1) == LUA_TTABLE)
                {
                    // check minimal function support
                    if(!_check_lua_export(L))
                    {
                        fprintf(stderr, "export '%s' must define at least the functions 'get_extension', 'write_rectangle', 'write_polygon' and 'finalize'\n", exportname);
                        status = EXPORT_STATUS_LOADERROR;
                        lua_close(L);
                        break;
                    }

                    // parse and set export cmd options
                    if(exportoptions)
                    {
                        lua_getfield(L, -1, "set_options");
                        lua_newtable(L);
                        const char* const * opt = exportoptions;
                        while(*opt)
                        {
                            lua_pushstring(L, *opt);
                            lua_rawseti(L, -2, opt - exportoptions + 1);
                            ++opt;
                        }
                        _call_or_pop_nil(L, 1);
                    }

                    int ret = _write_toplevel_lua(L, toplevel, pcell_state, toplevelname, data, writechildrenports, leftdelim, rightdelim);
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
        if(*basename == '-' && !*(basename + 1)) // send to standard output
        {
            fwrite(data->data, 1, data->length, stdout);
        }
        else
        {
            size_t len = strlen(basename) + strlen(extension) + 2; // + 2: '.' and the terminating zero
            char* filename = malloc(len);
            snprintf(filename, len + 2, "%s.%s", basename, extension);
            FILE* file = fopen(filename, "w");
            fwrite(data->data, 1, data->length, file);
            fclose(file);
            free(extension);
            free(filename);
        }
        export_destroy_data(data);
        export_destroy_functions(funcs);
    }
    else if(status == EXPORT_STATUS_NOTFOUND)
    {
        printf("could not find export '%s'\n", exportname);
    }
    else // EXPORT_STATUS_LOADERROR
    {
        puts("error while loading export");
    }
}

