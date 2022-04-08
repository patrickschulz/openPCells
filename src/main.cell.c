#include "main.cell.h"

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "lua/lauxlib.h"

#include "lpoint.h"
#include "lgeometry.h"
#include "lgenerics.h"
#include "lload.h"
#include "lbind.h"
#include "ldir.h"
#include "lobject.h"
#include "lfilesystem.h"
#include "lplacer.h"
#include "lrouter.h"
#include "gdsparser.h"
#include "technology.h"
#include "graphics.h"
#include "util.h"
#include "export.h"
#include "info.h"
#include "postprocess.h"
#include "geometry.h"

#include "config.h"

#include "main.functions.h"

static lua_State* create_and_initialize_lua(void)
{
    lua_State* L = util_create_basic_lua_state();

    // opc libraries
    open_ldir_lib(L);
    open_lpoint_lib(L);
    open_lgeometry_lib(L);
    open_lgenerics_lib(L);
    open_ltechnology_lib(L);
    open_lgraphics_lib(L);
    open_lload_lib(L);
    open_lbind_lib(L);
    open_lobject_lib(L);
    open_lpcell_lib(L);
    open_lfilesystem_lib(L);
    open_lplacer_lib(L);
    open_lrouter_lib(L);

    open_gdsparser_lib(L);

    return L;
}

struct technology_state* main_create_techstate(struct vector* techpaths, const char* techname)
{
    struct technology_state* techstate = technology_initialize();
    for(unsigned int i = 0; i < vector_size(techpaths); ++i)
    {
        technology_add_techpath(techstate, vector_get(techpaths, i));
    }
    technology_load(techstate, techname);
    return techstate;
}

struct pcell_state* main_create_pcell_state(void)
{
    struct pcell_state* pcell_state = pcell_initialize_state();
    return pcell_state;
}

struct layermap* main_create_layermap(void)
{
    struct layermap* layermap = generics_initialize_layer_map();
    return layermap;
}

static int _parse_point(const char* arg, int* xptr, int* yptr)
{
    unsigned int idx1, idx2;
    const char* ptr = arg;
    while(*ptr)
    {
        if(*ptr == '(')
        {
            idx1 = ptr - arg;
        }
        if(*ptr == ',')
        {
            idx2 = ptr - arg;
        }
        ++ptr;
    }
    char* endptr;
    int x = strtol(arg + idx1 + 1, &endptr, 10);
    if(endptr == arg + idx1 + 1)
    {
        return 0;
    }
    int y = strtol(arg + idx2 + 1, &endptr, 10);
    if(endptr == arg + idx2 + 1)
    {
        return 0;
    }
    *xptr = x;
    *yptr = y;
    return 1;
}

object_t* main_create_cell(const char* cellname, struct vector* cellargs, struct technology_state* techstate, struct pcell_state* pcell_state, struct layermap* layermap)
{
    lua_State* L = create_and_initialize_lua();

    // register techstate
    lua_pushlightuserdata(L, techstate);
    lua_setfield(L, LUA_REGISTRYINDEX, "techstate");

    // register pcell state
    lua_pushlightuserdata(L, pcell_state);
    lua_setfield(L, LUA_REGISTRYINDEX, "pcellstate");

    // register layermap
    lua_pushlightuserdata(L, layermap);
    lua_setfield(L, LUA_REGISTRYINDEX, "genericslayermap");

    // assemble cell arguments
    lua_newtable(L);
    lua_pushstring(L, cellname);
    lua_setfield(L, -2, "cell");
    lua_newtable(L);
    for(unsigned int i = 0; i < vector_size(cellargs); ++i)
    {
        lua_pushstring(L, vector_get(cellargs, i));
        lua_rawseti(L, -2, i + 1);
    }
    lua_setfield(L, -2, "cellargs");
    lua_setglobal(L, "args");
    int retval = main_call_lua_program(L, OPC_HOME "/src/scripts/create_cell.lua");
    if(retval != LUA_OK)
    {
        lua_close(L);
        return NULL;
    }
    lobject_t* lobject = lobject_check(L, -1);
    lobject->destroy = 0; // disown object from lua
    object_t* toplevel = lobject->object;

    lua_close(L);

    return toplevel;
}

void main_create_and_export_cell(struct cmdoptions* cmdoptions, struct keyvaluearray* config)
{
    struct vector* techpaths = keyvaluearray_get(config, "techpaths");
    vector_append(techpaths, util_copy_string(OPC_HOME "/tech"));
    if(cmdoptions_was_provided_long(cmdoptions, "techpath"))
    {
        const char** arg = cmdoptions_get_argument_long(cmdoptions, "techpath");
        while(*arg)
        {
            vector_append(techpaths, util_copy_string(*arg));
            ++arg;
        }
    }
    const char* techname = cmdoptions_get_argument_long(cmdoptions, "technology");
    struct technology_state* techstate = main_create_techstate(techpaths, techname);
    if(!techstate)
    {
        goto EXIT;
    }
    struct pcell_state* pcell_state = main_create_pcell_state();
    if(!pcell_state)
    {
        goto DESTROY_TECHNOLOGY;
    }
    struct layermap* layermap = main_create_layermap();
    if(!layermap)
    {
        goto DESTROY_PCELL_STATE;
    }
    struct vector* cellargs = cmdoptions_get_positional_parameters(cmdoptions);
    const char* cellname = cmdoptions_get_argument_long(cmdoptions, "cell");
    object_t* toplevel = main_create_cell(cellname, cellargs, techstate, pcell_state, layermap);
    if(toplevel)
    {
        // export cell
        if(cmdoptions_was_provided_long(cmdoptions, "export") || cmdoptions_was_provided_long(cmdoptions, "exportlayers"))
        {
            const char* exportname = cmdoptions_get_argument_long(cmdoptions, "exportlayers");
            if(!exportname)
            {
                exportname = cmdoptions_get_argument_long(cmdoptions, "export");
            }
            // add export search paths. FIXME: add --exportpath cmd option
            if(!generics_resolve_premapped_layers(layermap, exportname))
            {
                printf("no layer data for export type '%s' found", exportname);
            }
            export_add_path(OPC_HOME "/export");
            const char* basename = cmdoptions_get_argument_long(cmdoptions, "filename");
            const char* toplevelname = cmdoptions_get_argument_long(cmdoptions, "cellname");
            const char** exportoptions = cmdoptions_get_argument_long(cmdoptions, "export-options");
            int writechildrenports = cmdoptions_was_provided_long(cmdoptions, "write-children-ports");
            const char* delimiters = cmdoptions_get_argument_long(cmdoptions, "bus-delimiters");
            char leftdelim = '<';
            char rightdelim = '>';
            if(delimiters && delimiters[0] && delimiters[1])
            {
                leftdelim = delimiters[0];
                rightdelim = delimiters[1];
            }
            export_write_toplevel(toplevel, pcell_state, exportname, basename, toplevelname, leftdelim, rightdelim, exportoptions, writechildrenports);
            object_destroy(toplevel);
        }
        else
        {
            puts("no export type given");
        }
    }

    // move origin
    if(cmdoptions_was_provided_long(cmdoptions, "origin"))
    {
        const char* arg = cmdoptions_get_argument_long(cmdoptions, "origin");
        int x, y;
        if(!_parse_point(arg, &x, &y))
        {
            printf("could not parse translation '%s'\n", arg);
        }
        else
        {
            object_move_to(toplevel, x, y);
        }
    }

    // translate
    if(cmdoptions_was_provided_long(cmdoptions, "translate"))
    {
        const char* arg = cmdoptions_get_argument_long(cmdoptions, "translate");
        int dx, dy;
        if(!_parse_point(arg, &dx, &dy))
        {
            printf("could not parse translation '%s'\n", arg);
        }
        else
        {
            object_translate(toplevel, dx, dy);
        }
    }

    /*
    // orientation
    //if args.orientation then
    //    local lut = {
    //        ["0"] = function() end, -- do nothing, but allow this as command line option
    //        ["fx"] = function() cell:flipx() end,
    //        ["fy"] = function() cell:flipy() end,
    //        ["fxy"] = function() cell:flipx(); cell:flipy() end,
    //    }
    //    local f = lut[args.orientation]
    //    if not f then
    //        moderror(string.format("unknown orientation: '%s'", args.orientation))
    //    end
    //    f()
    //end

    // draw anchors
    //if args.drawanchor then
    //    for _, da in ipairs(args.drawanchor) do
    //        local anchor = cell:get_anchor(da)
    //        cell:merge_into_shallow(marker.cross(anchor))
    //    end
    //end
    */

    // draw alignmentbox(es)
    if(cmdoptions_was_provided_long(cmdoptions, "draw-alignmentbox") || cmdoptions_was_provided_long(cmdoptions, "draw-all-alignmentboxes"))
    {
        point_t* bl = object_get_anchor(toplevel, "bottomleft");
        point_t* tr = object_get_anchor(toplevel, "topright");
        if(bl && tr)
        {
            geometry_rectanglebltr(toplevel, generics_create_special(layermap, techstate), bl, tr, 1, 1, 0, 0);
            point_destroy(bl);
            point_destroy(tr);
        }
    }
    if(cmdoptions_was_provided_long(cmdoptions, "draw-all-alignmentboxes"))
    {
        for(unsigned int i = 0; i < pcell_get_reference_count(pcell_state); ++i)
        {
            object_t* cell = pcell_get_indexed_cell_reference(pcell_state, i)->cell;
            point_t* bl = object_get_anchor(cell, "bottomleft");
            point_t* tr = object_get_anchor(cell, "topright");
            if(bl && tr)
            {
                geometry_rectanglebltr(cell, generics_create_special(layermap, techstate), bl, tr, 1, 1, 0, 0);
                point_destroy(bl);
                point_destroy(tr);
            }
        }
    }

    // flatten cell
    if(cmdoptions_was_provided_long(cmdoptions, "flat"))
    {
        int flattenports = cmdoptions_was_provided_long(cmdoptions, "flattenports");
        object_flatten(toplevel, pcell_state, flattenports);
    }

    // post-processing
    if(cmdoptions_was_provided_long(cmdoptions, "filter-layers"))
    {
        const char** layernames = cmdoptions_get_argument_long(cmdoptions, "filter-layers");
        if(cmdoptions_was_provided_long(cmdoptions, "filter-list") &&
           strcmp(cmdoptions_get_argument_long(cmdoptions, "filter-list"), "include") == 0)
        {
            postprocess_filter_include(toplevel, layernames);
            for(unsigned int i = 0; i < pcell_get_reference_count(pcell_state); ++i)
            {
                object_t* cell = pcell_get_indexed_cell_reference(pcell_state, i)->cell;
                postprocess_filter_include(cell, layernames);
            }
        }
        else
        {
            postprocess_filter_exclude(toplevel, layernames);
            for(unsigned int i = 0; i < pcell_get_reference_count(pcell_state); ++i)
            {
                object_t* cell = pcell_get_indexed_cell_reference(pcell_state, i)->cell;
                postprocess_filter_exclude(cell, layernames);
            }
        }
    }
    if(cmdoptions_was_provided_long(cmdoptions, "merge-rectangles"))
    {
        postprocess_merge_shapes(toplevel, layermap);
    }

    generics_destroy_layer_map(layermap);
DESTROY_PCELL_STATE:
    pcell_destroy_state(pcell_state);
DESTROY_TECHNOLOGY:
    technology_destroy(techstate);
EXIT:

    // cell info
    if(cmdoptions_was_provided_long(cmdoptions, "show-cellinfo"))
    {
       info_cellinfo(toplevel);
    }
}
