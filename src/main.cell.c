#include "main.cell.h"

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "lua/lauxlib.h"

#include "lpoint.h"
#include "lgeometry.h"
#include "lgenerics.h"
#include "lbind.h"
#include "ldir.h"
#include "lobject.h"
#include "filesystem.h"
#include "lplacer.h"
#include "lrouter.h"
#include "gdsparser.h"
#include "technology.h"
#include "graphics.h"
#include "util.h"
#include "lua_util.h"
#include "export.h"
#include "info.h"
#include "postprocess.h"
#include "geometry.h"

#include "config.h"

#include "main.functions.h"

#include "modulemanager.h"
#include "scriptmanager.h"

static lua_State* _create_and_initialize_lua(void)
{
    lua_State* L = util_create_basic_lua_state();

    // opc libraries
    open_ldir_lib(L);
    open_lpoint_lib(L);
    open_lgeometry_lib(L);
    open_lgenerics_lib(L);
    open_ltechnology_lib(L);
    open_lgraphics_lib(L);
    open_lbind_lib(L);
    open_lobject_lib(L);
    open_lpcell_lib(L);
    open_lfilesystem_lib(L);
    open_lplacer_lib(L);
    open_lrouter_lib(L);

    open_gdsparser_lib(L);

    return L;
}

static struct technology_state* _create_techstate(struct vector* techpaths, const char* techname)
{
    struct technology_state* techstate = technology_initialize();
    for(unsigned int i = 0; i < vector_size(techpaths); ++i)
    {
        technology_add_techpath(techstate, vector_get(techpaths, i));
    }
    if(!technology_load(techstate, techname))
    {
        return NULL;
    }
    return techstate;
}

static struct layermap* _create_layermap(void)
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

static void _prepare_cellpaths(struct vector* cellpaths_to_prepend, struct vector* cellpaths_to_append, struct cmdoptions* cmdoptions, struct keyvaluearray* config)
{

    if(cmdoptions_was_provided_long(cmdoptions, "prepend-cellpath"))
    {
        const char** arg = cmdoptions_get_argument_long(cmdoptions, "prepend-cellpath");
        while(*arg)
        {
            vector_append(cellpaths_to_prepend, util_copy_string(*arg));
            ++arg;
        }
    }
    if(cmdoptions_was_provided_long(cmdoptions, "cellpath"))
    {
        const char** arg = cmdoptions_get_argument_long(cmdoptions, "cellpath");
        while(*arg)
        {
            vector_append(cellpaths_to_append, util_copy_string(*arg));
            ++arg;
        }
    }
    if(cmdoptions_was_provided_long(cmdoptions, "append-cellpath"))
    {
        const char** arg = cmdoptions_get_argument_long(cmdoptions, "append-cellpath");
        while(*arg)
        {
            vector_append(cellpaths_to_append, util_copy_string(*arg));
            ++arg;
        }
    }
    struct vector* config_prepend_cellpaths = keyvaluearray_get(config, "prepend_cellpaths");
    if(config_prepend_cellpaths)
    {
        for(unsigned int i = 0; i < vector_size(config_prepend_cellpaths); ++i)
        {
            vector_append(cellpaths_to_prepend, vector_get(config_prepend_cellpaths, i));
        }
    }
    struct vector* config_append_cellpaths = keyvaluearray_get(config, "append_cellpaths");
    if(config_append_cellpaths)
    {
        for(unsigned int i = 0; i < vector_size(config_append_cellpaths); ++i)
        {
            vector_append(cellpaths_to_append, vector_get(config_append_cellpaths, i));
        }
    }
    vector_append(cellpaths_to_append, util_copy_string(OPC_HOME "/cells"));
}

void main_list_cell_parameters(struct cmdoptions* cmdoptions, struct keyvaluearray* config)
{
    lua_State* L = _create_and_initialize_lua();

    open_lpcell_lib(L);
    module_load_aux(L);
    module_load_pcell(L);
    module_load_load(L);

    // pcell state
    struct vector* cellpaths_to_prepend = vector_create();
    struct vector* cellpaths_to_append = vector_create();
    _prepare_cellpaths(cellpaths_to_prepend, cellpaths_to_append, cmdoptions, config);
    struct pcell_state* pcell_state = pcell_initialize_state(cellpaths_to_prepend, cellpaths_to_append);
    vector_destroy(cellpaths_to_prepend, free);
    vector_destroy(cellpaths_to_append, free);
    // and register
    lua_pushlightuserdata(L, pcell_state);
    lua_setfield(L, LUA_REGISTRYINDEX, "pcellstate");

    // assemble cell arguments
    lua_newtable(L);
    const char* cellname = cmdoptions_get_argument_long(cmdoptions, "cell");
    lua_pushstring(L, cellname);
    lua_setfield(L, -2, "cell");
    const char* parametersformat = cmdoptions_get_argument_long(cmdoptions, "parameters-format");
    if(parametersformat)
    {
        lua_pushstring(L, parametersformat);
        lua_setfield(L, -2, "parametersformat");
    }
    lua_setglobal(L, "args");

    int retval = script_call_list_parameters(L);
    if(retval != LUA_OK)
    {
        puts("error while running list_parameters.lua");
    }
    lua_close(L);
}

object_t* _create_cell(const char* cellname, int iscellscript, struct vector* cellargs, struct technology_state* techstate, struct pcell_state* pcell_state, struct layermap* layermap, int enabledprint)
{
    lua_State* L = _create_and_initialize_lua();

    // register techstate
    lua_pushlightuserdata(L, techstate);
    lua_setfield(L, LUA_REGISTRYINDEX, "techstate");

    // register pcell state
    lua_pushlightuserdata(L, pcell_state);
    lua_setfield(L, LUA_REGISTRYINDEX, "pcellstate");

    // register layermap
    lua_pushlightuserdata(L, layermap);
    lua_setfield(L, LUA_REGISTRYINDEX, "genericslayermap");

    // load main modules
    module_load_aux(L);
    module_load_envlib(L);
    module_load_geometry(L);
    module_load_globals(L);
    module_load_graphics(L);
    module_load_load(L);
    module_load_pcell(L);
    module_load_placement(L);
    module_load_point(L);
    module_load_public(L);
    module_load_routing(L);
    module_load_stack(L);
    module_load_support(L);
    module_load_util(L);

    // assemble cell arguments
    lua_newtable(L);
    lua_pushboolean(L, iscellscript);
    lua_setfield(L, -2, "isscript");
    lua_pushstring(L, cellname);
    lua_setfield(L, -2, "cell");
    lua_pushboolean(L, enabledprint);
    lua_setfield(L, -2, "enabledprint");
    lua_newtable(L);
    for(unsigned int i = 0; i < vector_size(cellargs); ++i)
    {
        lua_pushstring(L, vector_get(cellargs, i));
        lua_rawseti(L, -2, i + 1);
    }
    lua_setfield(L, -2, "cellargs");
    lua_setglobal(L, "args");

    int retval = script_call_create_cell(L);
    if(retval != LUA_OK)
    {
        lua_close(L);
        return NULL;
    }
    lobject_t* lobject = lobject_check(L, -1);
    lobject_disown(lobject);
    object_t* toplevel = lobject->object;

    lua_close(L);

    return toplevel;
}

void main_create_and_export_cell(struct cmdoptions* cmdoptions, struct keyvaluearray* config, int iscellscript)
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
    struct technology_state* techstate = _create_techstate(techpaths, techname);
    if(!techstate)
    {
        goto EXIT;
    }

    // pcell state
    struct vector* cellpaths_to_prepend = vector_create();
    struct vector* cellpaths_to_append = vector_create();
    _prepare_cellpaths(cellpaths_to_prepend, cellpaths_to_append, cmdoptions, config);
    struct pcell_state* pcell_state = pcell_initialize_state(cellpaths_to_prepend, cellpaths_to_append);
    vector_destroy(cellpaths_to_prepend, free);
    vector_destroy(cellpaths_to_append, free);

    if(!pcell_state)
    {
        goto DESTROY_TECHNOLOGY;
    }
    struct layermap* layermap = _create_layermap();
    if(!layermap)
    {
        goto DESTROY_PCELL_STATE;
    }
    struct vector* cellargs = cmdoptions_get_positional_parameters(cmdoptions);
    const char* cellname;
    if(iscellscript)
    {
        cellname = cmdoptions_get_argument_long(cmdoptions, "cellscript");
    }
    else
    {
        cellname = cmdoptions_get_argument_long(cmdoptions, "cell");
    }
    int enabledprint = cmdoptions_was_provided_long(cmdoptions, "enable-dprint");
    object_t* toplevel = _create_cell(cellname, iscellscript, cellargs, techstate, pcell_state, layermap, enabledprint);
    if(toplevel)
    {
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


        //function marker.cross(where, size)
        //    local x, y = where:unwrap()
        //    local obj = object.create()
        //    size = size or 100
        //    obj:merge_into_shallow(geometry.rectanglebltr(generics.special(), point.create(x - 5, y - size), point.create(x + 5, y + size)))
        //    obj:merge_into_shallow(geometry.rectanglebltr(generics.special(), point.create(x - size, y - 5), point.create(x + size, y + 5)))
        //    return obj
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
            for(unsigned int i = 0; i < pcell_get_reference_count(pcell_state); ++i)
            {
                object_t* cell = pcell_get_indexed_cell_reference(pcell_state, i)->cell;
                postprocess_merge_shapes(cell, layermap);
            }
        }

        // export cell
        if(cmdoptions_was_provided_long(cmdoptions, "export"))
        {
            const char* exportname = cmdoptions_get_argument_long(cmdoptions, "export");
            const char* exportlayername = cmdoptions_get_argument_long(cmdoptions, "export-layers");
            if(!exportlayername)
            {
                exportlayername = exportname;
            }
            // add export search paths. FIXME: add --exportpath cmd option
            if(!generics_resolve_premapped_layers(layermap, exportlayername))
            {
                goto DESTROY_OBJECT;
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
        }
        else
        {
            puts("no export type given");
        }
    }
    else
    {
        fputs("errors while creating cell\n", stderr);
        goto DESTROY_OBJECT;
    }

DESTROY_OBJECT:
    if(toplevel)
    {
        object_destroy(toplevel);
    }
//DESTROY_LAYERMAP:
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
