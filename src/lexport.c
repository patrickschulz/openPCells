#include "lexport.h"

#include "lua/lauxlib.h"
#include <stdio.h>
#include <string.h>

#include "lobject.h"

#include "lexport_common.h"
#include "pcell.h"

#include "gdsexport.h"

static int lexport_add_path(lua_State* L)
    //string.format("%s/export", _get_opc_home()))
{
    (void) L;
    return 0;
}

static int lexport_load(lua_State* L)
    //args.export
{
    (void) L;
    return 0;
}

static int lexport_set_options(lua_State* L)
    //args.export_options
{
    (void) L;
    return 0;
}

static int lexport_check(lua_State* L)
{
    (void) L;
    return 0;
}

static int lexport_set_bus_delimiters(lua_State* L)
    //leftdelim, rightdelim
{
    (void) L;
    return 0;
}

static void _write_cell(object_t* cell, struct export_data* data, struct export_functions* funcs)
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
                path_properties_t* properties = shape->properties;
                funcs->write_path(data, layerdata, shape->points, shape->size, properties->width, properties->extension);
                break;
        }
        //if S:is_type("path") and not export.write_path then
        //    S:resolve_path()
        //end
    }
    for(unsigned int i = 0; i < cell->children_size; ++i)
    {
        point_t origin = { .x = 0, .y = 0 };
        object_t* child = cell->children[i];
        transformationmatrix_apply_transformation(child->trans, &origin);
        transformationmatrix_apply_transformation(cell->trans, &origin);
        if(child->isarray && funcs->write_cell_array)
        {

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

static struct export_functions* get_export_functions(const char* exportname)
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

static int lexport_write_toplevel(lua_State* L)
    //filename, args.technology, cell, args.toplevelname or "opctoplevel", args.writechildrenports, args.dryrun
{
    const char* filename = lua_tostring(L, 1);
    lobject_t* lobject = lua_touserdata(L, 2);
    struct export_functions* funcs = get_export_functions("gds");
    if(funcs)
    {
        struct export_data* data = export_create_data();
        funcs->at_begin(data);

        funcs->at_begin_cell(data, "opctoplevel");
        _write_cell(lobject->object, data, funcs);
        funcs->at_end_cell(data);

        for(unsigned int i = 0; i < pcell_get_reference_count(); ++i)
        {
            struct cellreference* reference = pcell_get_indexed_cell_reference(i);
            funcs->at_begin_cell(data, reference->identifier);
            _write_cell(reference->cell, data, funcs);
            funcs->at_end_cell(data);
        }

        funcs->at_end(data);
        FILE* file = fopen("openPCells.gds", "wb");
        fwrite(data->data, 1, data->length, file);
        fclose(file);
        export_destroy_data(data);
        export_destroy_functions(funcs);
    }
    return 0;
}

int open_lexport_lib(lua_State* L)
{
    lua_newtable(L);
    static const luaL_Reg modfuncs[] =
    {
        { "add_path",           lexport_add_path            },
        { "load",               lexport_load                },
        { "set_options",        lexport_set_options         },
        { "check",              lexport_check               },
        { "set_bus_delimiters", lexport_set_bus_delimiters  },
        { "write_toplevel",     lexport_write_toplevel      },
        { NULL,                 NULL                        }
    };
    luaL_setfuncs(L, modfuncs, 0);
    lua_setglobal(L, LEXPORTMODULE);

    return 0;
}
