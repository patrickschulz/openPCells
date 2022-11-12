#include "main.cell.h"

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "lua/lauxlib.h"

#include "lpoint.h"
#include "lgeometry.h"
#include "lgenerics.h"
#include "ldir.h"
#include "lobject.h"
#include "filesystem.h"
#include "lplacer.h"
#include "lrouter.h"
#include "gdsparser.h"
#include "technology.h"
#include "util.h"
#include "lua_util.h"
#include "export.h"
#include "info.h"
#include "postprocess.h"
#include "geometry.h"
#include "hashmap.h"
#include "pcell.h"

#include "config.h"

#include "main.functions.h"

#include "modulemanager.h"
#include "scriptmanager.h"

static lua_State* _create_and_initialize_lua(void)
{
    lua_State* L = util_create_basic_lua_state();

    // opc libraries
    open_ldir_lib(L);
    open_lfilesystem_lib(L);
    open_lpoint_lib(L);
    open_lgeometry_lib(L);
    open_lgenerics_lib(L);
    open_ltechnology_lib(L);
    open_lpcell_lib(L);
    open_lobject_lib(L);
    // FIXME: these libraries are probably not needed for cell creation (they are used in place & route scripts)
    open_lplacer_lib(L);
    open_lrouter_lib(L);
    return L;
}

static struct technology_state* _create_techstate(struct vector* techpaths, const char* techname, const struct const_vector* ignoredlayers)
{
    struct technology_state* techstate = technology_initialize();
    for(unsigned int i = 0; i < vector_size(techpaths); ++i)
    {
        technology_add_techpath(techstate, vector_get(techpaths, i));
    }
    if(!technology_load(techstate, techname, ignoredlayers))
    {
        return NULL;
    }
    return techstate;
}

static int _parse_point(const char* arg, int* xptr, int* yptr)
{
    unsigned int idx1 = 0;
    unsigned int idx2 = 0;
    const char* ptr = arg;
    while(*ptr)
    {
        if(*ptr == '(')
        {
            idx1 = (unsigned int)(ptr - arg);
        }
        if(*ptr == ',')
        {
            idx2 = (unsigned int)(ptr - arg);
        }
        ++ptr;
    }
    char* endptr;
    int x = (int)strtol(arg + idx1 + 1, &endptr, 10);
    if(endptr == arg + idx1 + 1)
    {
        return 0;
    }
    int y = (int)strtol(arg + idx2 + 1, &endptr, 10);
    if(endptr == arg + idx2 + 1)
    {
        return 0;
    }
    *xptr = x;
    *yptr = y;
    return 1;
}

static void _prepare_cellpaths(struct vector* cellpaths_to_prepend, struct vector* cellpaths_to_append, struct cmdoptions* cmdoptions, struct hashmap* config)
{

    if(cmdoptions_was_provided_long(cmdoptions, "prepend-cellpath"))
    {
        const char** arg = cmdoptions_get_argument_long(cmdoptions, "prepend-cellpath");
        while(*arg)
        {
            vector_append(cellpaths_to_prepend, strdup(*arg));
            ++arg;
        }
    }
    if(cmdoptions_was_provided_long(cmdoptions, "append-cellpath"))
    {
        const char** arg = cmdoptions_get_argument_long(cmdoptions, "append-cellpath");
        while(*arg)
        {
            vector_append(cellpaths_to_append, strdup(*arg));
            ++arg;
        }
    }
    struct vector* config_prepend_cellpaths = hashmap_get(config, "prepend_cellpaths");
    if(config_prepend_cellpaths)
    {
        for(unsigned int i = 0; i < vector_size(config_prepend_cellpaths); ++i)
        {
            vector_append(cellpaths_to_prepend, strdup(vector_get(config_prepend_cellpaths, i)));
        }
    }
    struct vector* config_append_cellpaths = hashmap_get(config, "append_cellpaths");
    if(config_append_cellpaths)
    {
        for(unsigned int i = 0; i < vector_size(config_append_cellpaths); ++i)
        {
            vector_append(cellpaths_to_append, strdup(vector_get(config_append_cellpaths, i)));
        }
    }
    vector_append(cellpaths_to_append, strdup(OPC_HOME "/cells"));
}

void main_list_cell_parameters(struct cmdoptions* cmdoptions, struct hashmap* config)
{
    // FIXME: this probably loads too many C modules
    lua_State* L = _create_and_initialize_lua();

    module_load_aux(L);
    module_load_stack(L);
    module_load_pcell(L);
    module_load_load(L);

    struct vector* techpaths = hashmap_get(config, "techpaths");
    vector_append(techpaths, strdup(OPC_HOME "/tech"));
    if(cmdoptions_was_provided_long(cmdoptions, "techpath"))
    {
        const char** arg = cmdoptions_get_argument_long(cmdoptions, "techpath");
        while(*arg)
        {
            vector_append(techpaths, strdup(*arg));
            ++arg;
        }
    }
    struct const_vector* ignoredlayers = hashmap_get(config, "ignoredlayers");
    const char* techname = cmdoptions_get_argument_long(cmdoptions, "technology");
    if(techname)
    {
        struct technology_state* techstate = _create_techstate(techpaths, techname, ignoredlayers);
        // register techstate
        lua_pushlightuserdata(L, techstate);
        lua_setfield(L, LUA_REGISTRYINDEX, "techstate");
    }

    // pcell state
    struct vector* cellpaths_to_prepend = vector_create(1, free);
    struct vector* cellpaths_to_append = vector_create(1, free);
    _prepare_cellpaths(cellpaths_to_prepend, cellpaths_to_append, cmdoptions, config);
    struct pcell_state* pcell_state = pcell_initialize_state(cellpaths_to_prepend, cellpaths_to_append);
    vector_destroy(cellpaths_to_prepend);
    vector_destroy(cellpaths_to_append);
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
    lua_pushboolean(L, techname ? 0 : 1);
    lua_setfield(L, -2, "generictech");
    lua_setglobal(L, "args");

    int retval = script_call_list_parameters(L);
    if(retval != LUA_OK)
    {
        puts("error while running list_parameters.lua");
    }
    lua_close(L);
}

static int _read_cellenv(lua_State* L, const char* filename)
{
    if(!filename)
    {
        lua_newtable(L);
    }
    else
    {
        // call adapted from macro for luaL_dofile (only one return value as a fail-safe)
        if((luaL_loadfile(L, filename) || lua_pcall(L, 0, 1, 0)) != LUA_OK)
        {
            const char* msg = lua_tostring(L, -1);
            fprintf(stderr, "error while loading cell environment file: %s\n", msg);
            return 0;
        }
    }
    lua_setfield(L, -2, "cellenv");
    return 1;
}

static struct object* _create_cell(
    const char* cellname,
    const char* name,
    int iscellscript,
    struct vector* cellargs,
    struct technology_state* techstate,
    struct pcell_state* pcell_state,
    int enabledprint,
    struct const_vector* pfilenames,
    const char* cellenvfilename
)
{
    lua_State* L = _create_and_initialize_lua();

    // register techstate
    lua_pushlightuserdata(L, techstate);
    lua_setfield(L, LUA_REGISTRYINDEX, "techstate");

    // register pcell state
    lua_pushlightuserdata(L, pcell_state);
    lua_setfield(L, LUA_REGISTRYINDEX, "pcellstate");

    // load main modules
    module_load_aux(L);
    module_load_envlib(L);
    module_load_geometry(L);
    module_load_globals(L);
    module_load_graphics(L);
    module_load_load(L);
    module_load_stack(L); // must be loaded before pcell (FIXME: explicitly create the lua pcell state)
    module_load_pcell(L);
    module_load_placement(L);
    module_load_point(L);
    module_load_routing(L);
    module_load_support(L);
    module_load_util(L);

    // assemble cell arguments
    lua_newtable(L);

    // is cell script
    lua_pushboolean(L, iscellscript);
    lua_setfield(L, -2, "isscript");

    // cell name
    lua_pushstring(L, cellname);
    lua_setfield(L, -2, "cell");

    // object name
    lua_pushstring(L, name);
    lua_setfield(L, -2, "toplevelname");

    // enable dprint
    lua_pushboolean(L, enabledprint);
    lua_setfield(L, -2, "enabledprint");

    // cell args
    lua_newtable(L);
    for(unsigned int i = 0; i < vector_size(cellargs); ++i)
    {
        lua_pushstring(L, vector_get(cellargs, i));
        lua_rawseti(L, -2, i + 1);
    }
    lua_setfield(L, -2, "cellargs");

    // pfile names
    lua_newtable(L);
    for(unsigned int i = 0; i < const_vector_size(pfilenames); ++i)
    {
        lua_pushstring(L, const_vector_get(pfilenames, i));
        lua_rawseti(L, -2, i + 1);
    }
    lua_setfield(L, -2, "pfilenames");
    
    // cell environment
    if(!_read_cellenv(L, cellenvfilename))
    {
        lua_close(L);
        return NULL;
    }

    // register args
    lua_setglobal(L, "args");

    int retval = script_call_create_cell(L);
    if(retval != LUA_OK)
    {
        lua_close(L);
        return NULL;
    }
    struct lobject* lobject = lobject_check_soft(L, -1);
    if(!lobject)
    {
        fputs("cell/cellscript did not return an object\n", stderr);
        lua_close(L);
        return NULL;
    }
    struct object* toplevel = lobject_disown(lobject);

    lua_close(L);

    return toplevel;
}

static void _move_origin(struct object* toplevel, struct cmdoptions* cmdoptions)
{
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
}

static void _translate(struct object* toplevel, struct cmdoptions* cmdoptions)
{
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
}

static void _scale(struct object* toplevel, struct cmdoptions* cmdoptions)
{
    if(cmdoptions_was_provided_long(cmdoptions, "scale"))
    {
        const char* arg = cmdoptions_get_argument_long(cmdoptions, "scale");
        double factor = atof(arg);
        object_scale(toplevel, factor);
    }
}

static void _draw_alignmentboxes(struct object* toplevel, struct cmdoptions* cmdoptions, struct technology_state* techstate)
{
    if(cmdoptions_was_provided_long(cmdoptions, "draw-alignmentbox") || cmdoptions_was_provided_long(cmdoptions, "draw-all-alignmentboxes"))
    {
        point_t* bl = object_get_anchor(toplevel, "bottomleft");
        point_t* tr = object_get_anchor(toplevel, "topright");
        if(bl && tr)
        {
            geometry_rectanglebltr(toplevel, generics_create_special(techstate), bl, tr, 1, 1, 0, 0);
            point_destroy(bl);
            point_destroy(tr);
        }
    }
    if(cmdoptions_was_provided_long(cmdoptions, "draw-all-alignmentboxes"))
    {
        struct vector* references = object_collect_references_mutable(toplevel);
        struct vector_iterator* it = vector_iterator_create(references);
        while(vector_iterator_is_valid(it))
        {
            struct object* ref = vector_iterator_get(it);
            point_t* bl = object_get_anchor(ref, "bottomleft");
            point_t* tr = object_get_anchor(ref, "topright");
            if(bl && tr)
            {
                geometry_rectanglebltr(ref, generics_create_special(techstate), bl, tr, 1, 1, 0, 0);
                point_destroy(bl);
                point_destroy(tr);
            }
            vector_iterator_next(it);
        }
        vector_iterator_destroy(it);
        vector_destroy(references);
    }
}

static void _draw_anchors(struct object* toplevel, struct cmdoptions* cmdoptions, struct technology_state* techstate)
{
    if(cmdoptions_was_provided_long(cmdoptions, "draw-anchor"))
    {
        const char** anchornames = cmdoptions_get_argument_long(cmdoptions, "draw-anchor");
        while(*anchornames)
        {
            point_t* pt = object_get_anchor(toplevel, *anchornames);
            if(pt)
            {
                object_add_port(toplevel, *anchornames, generics_create_special(techstate), pt, 0); // 0: don't store anchor
                point_destroy(pt);
            }
            else
            {
                fprintf(stderr, "--draw-anchor: could not find anchor '%s', ignoring\n", *anchornames);
            }
            ++anchornames;
        }
    }
    if(cmdoptions_was_provided_long(cmdoptions, "draw-all-anchors"))
    {
        const struct hashmap* anchors = object_get_all_regular_anchors(toplevel);
        struct hashmap_const_iterator* iterator = hashmap_const_iterator_create(anchors);
        while(hashmap_const_iterator_is_valid(iterator))
        {
            const char* key = hashmap_const_iterator_key(iterator);
            const point_t* anchor = hashmap_const_iterator_value(iterator);
            object_add_port(toplevel, key, generics_create_special(techstate), anchor, 0); // 0: don't store anchor
            hashmap_const_iterator_next(iterator);
        }
        hashmap_const_iterator_destroy(iterator);
    }
}

static void _filter_layers(struct object* toplevel, struct cmdoptions* cmdoptions)
{
    if(cmdoptions_was_provided_long(cmdoptions, "filter-layers"))
    {
        const char** layernames = cmdoptions_get_argument_long(cmdoptions, "filter-layers");
        if(cmdoptions_was_provided_long(cmdoptions, "filter-list") &&
                strcmp(cmdoptions_get_argument_long(cmdoptions, "filter-list"), "include") == 0)
        {
            postprocess_filter_include(toplevel, layernames);
            struct vector* references = object_collect_references_mutable(toplevel);
            struct vector_iterator* it = vector_iterator_create(references);
            while(vector_iterator_is_valid(it))
            {
                struct object* ref = vector_iterator_get(it);
                postprocess_filter_include(ref, layernames);
                vector_iterator_next(it);
            }
            vector_iterator_destroy(it);
            vector_destroy(references);
        }
        else
        {
            postprocess_filter_exclude(toplevel, layernames);
            struct vector* references = object_collect_references_mutable(toplevel);
            struct vector_iterator* it = vector_iterator_create(references);
            while(vector_iterator_is_valid(it))
            {
                struct object* ref = vector_iterator_get(it);
                postprocess_filter_exclude(ref, layernames);
                vector_iterator_next(it);
            }
            vector_iterator_destroy(it);
            vector_destroy(references);
        }
    }
}

static void _merge_rectangles(struct object* toplevel, struct cmdoptions* cmdoptions, struct technology_state* techstate)
{
    if(cmdoptions_was_provided_long(cmdoptions, "merge-rectangles"))
    {
        postprocess_merge_shapes(toplevel, techstate);
        struct vector* references = object_collect_references_mutable(toplevel);
        struct vector_iterator* it = vector_iterator_create(references);
        while(vector_iterator_is_valid(it))
        {
            struct object* ref = vector_iterator_get(it);
            postprocess_merge_shapes(ref, techstate);
            vector_iterator_next(it);
        }
        vector_iterator_destroy(it);
        vector_destroy(references);
    }
}

static void _resolve_cell_paths(struct object* cell)
{
    object_foreach_shapes(cell, shape_resolve_path_inline);
}

static void _resolve_paths(struct object* toplevel, struct cmdoptions* cmdoptions)
{
    if(cmdoptions_was_provided_long(cmdoptions, "resolve-paths"))
    {
        _resolve_cell_paths(toplevel);
        struct vector* references = object_collect_references_mutable(toplevel);
        struct vector_iterator* it = vector_iterator_create(references);
        while(vector_iterator_is_valid(it))
        {
            struct object* ref = vector_iterator_get(it);
            _resolve_cell_paths(ref);
            vector_iterator_next(it);
        }
        vector_iterator_destroy(it);
        vector_destroy(references);
    }
}

static void _raster_cell_curves(struct object* cell)
{
    object_foreach_shapes(cell, shape_rasterize_curve_inline);
}

static void _raster_curves(struct object* toplevel, struct cmdoptions* cmdoptions)
{
    if(cmdoptions_was_provided_long(cmdoptions, "rasterize-curves"))
    {
        _raster_cell_curves(toplevel);
        struct vector* references = object_collect_references_mutable(toplevel);
        struct vector_iterator* it = vector_iterator_create(references);
        while(vector_iterator_is_valid(it))
        {
            struct object* ref = vector_iterator_get(it);
            _raster_cell_curves(ref);
            vector_iterator_next(it);
        }
        vector_iterator_destroy(it);
        vector_destroy(references);
    }
}

static void _triangulate_cell_polygons(struct object* cell)
{
    object_foreach_shapes(cell, shape_triangulate_polygon_inline);
}

static void _triangulate_polygons(struct object* toplevel, struct cmdoptions* cmdoptions)
{
    if(cmdoptions_was_provided_long(cmdoptions, "triangulate-polygons"))
    {
        _triangulate_cell_polygons(toplevel);
        struct vector* references = object_collect_references_mutable(toplevel);
        struct vector_iterator* it = vector_iterator_create(references);
        while(vector_iterator_is_valid(it))
        {
            struct object* ref = vector_iterator_get(it);
            _triangulate_cell_polygons(ref);
            vector_iterator_next(it);
        }
        vector_iterator_destroy(it);
        vector_destroy(references);
    }
}

int main_create_and_export_cell(struct cmdoptions* cmdoptions, struct hashmap* config, int iscellscript)
{
    int retval = 1;
    struct vector* techpaths = hashmap_get(config, "techpaths");
    vector_append(techpaths, strdup(OPC_HOME "/tech"));
    if(cmdoptions_was_provided_long(cmdoptions, "techpath"))
    {
        const char** arg = cmdoptions_get_argument_long(cmdoptions, "techpath");
        while(*arg)
        {
            vector_append(techpaths, strdup(*arg));
            ++arg;
        }
    }
    struct const_vector* ignoredlayers = hashmap_get(config, "ignoredlayers");
    const char* techname = cmdoptions_get_argument_long(cmdoptions, "technology");
    struct technology_state* techstate = _create_techstate(techpaths, techname, ignoredlayers);
    if(!techstate)
    {
        retval = 0;
        goto EXIT;
    }
    if(cmdoptions_was_provided_long(cmdoptions, "disable-via-arrayzation"))
    {
        technology_disable_via_arrayzation(techstate);
    }

    // pcell state
    struct vector* cellpaths_to_prepend = vector_create(1, free);
    struct vector* cellpaths_to_append = vector_create(1, free);
    _prepare_cellpaths(cellpaths_to_prepend, cellpaths_to_append, cmdoptions, config);
    struct pcell_state* pcell_state = pcell_initialize_state(cellpaths_to_prepend, cellpaths_to_append);
    vector_destroy(cellpaths_to_prepend);
    vector_destroy(cellpaths_to_append);

    if(!pcell_state)
    {
        retval = 0;
        goto DESTROY_TECHNOLOGY;
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
    struct const_vector* pfilenames = const_vector_create(1);
    const char* const * prependpfilenames = cmdoptions_get_argument_long(cmdoptions, "prepend-parameter-file");
    if(prependpfilenames)
    {
        while(*prependpfilenames)
        {
            const_vector_append(pfilenames, *prependpfilenames);
            ++prependpfilenames;
        }
    }
    const char* const * appendpfilenames = cmdoptions_get_argument_long(cmdoptions, "append-parameter-file");
    if(appendpfilenames)
    {
        while(*appendpfilenames)
        {
            const_vector_append(pfilenames, *appendpfilenames);
            ++appendpfilenames;
        }
    }
    const char* cellenvfilename = cmdoptions_get_argument_long(cmdoptions, "cell-environment");
    const char* name = cmdoptions_get_argument_long(cmdoptions, "cellname");
    struct object* toplevel = _create_cell(cellname, name, iscellscript, cellargs, techstate, pcell_state, enabledprint, pfilenames, cellenvfilename);
    const_vector_destroy(pfilenames);
    if(toplevel)
    {
        _move_origin(toplevel, cmdoptions);
        _translate(toplevel, cmdoptions);
        _scale(toplevel, cmdoptions);

        // draw alignmentbox(es)
        _draw_alignmentboxes(toplevel, cmdoptions, techstate);

        // draw achors
        _draw_anchors(toplevel, cmdoptions, techstate);

        // flatten cell
        if(cmdoptions_was_provided_long(cmdoptions, "flat"))
        {
            int flattenports = cmdoptions_was_provided_long(cmdoptions, "flattenports");
            object_flatten_inline(toplevel, flattenports);
        }

        // post-processing
        _filter_layers(toplevel, cmdoptions);
        _merge_rectangles(toplevel, cmdoptions, techstate);

        // resolve paths
        _resolve_paths(toplevel, cmdoptions);

        // curve rasterization
        _raster_curves(toplevel, cmdoptions);

        // polygon triangulation
        _triangulate_polygons(toplevel, cmdoptions);

        // export cell
        if(cmdoptions_was_provided_long(cmdoptions, "export"))
        {
            struct export_state* export_state = export_create_state();

            // add export search paths. FIXME: add --exportpath cmd option
            export_add_searchpath(export_state, OPC_HOME "/export");

            // basename
            export_set_basename(export_state, cmdoptions_get_argument_long(cmdoptions, "filename"));

            // export options
            export_set_export_options(export_state, cmdoptions_get_argument_long(cmdoptions, "export-options"));

            // write children ports
            export_set_write_children_ports(export_state, cmdoptions_was_provided_long(cmdoptions, "write-children-ports"));

            // bus delimiters
            const char* delimiters = cmdoptions_get_argument_long(cmdoptions, "bus-delimiters");
            if(delimiters && delimiters[0] && delimiters[1])
            {
                export_set_bus_delimiters(export_state, delimiters[0], delimiters[1]);
            }
            else
            {
                export_set_bus_delimiters(export_state, '<', '>');
            }

            const char* const * exportnames = cmdoptions_get_argument_long(cmdoptions, "export");
            while(*exportnames)
            {
                export_set_exportname(export_state, *exportnames);
                if(!technology_resolve_premapped_layers(techstate, export_get_layername(export_state)))
                {
                    retval = 0;
                    goto DESTROY_OBJECT;
                }
                int export_result = export_write_toplevel(
                    toplevel, 
                    export_state
                );
                if(!export_result)
                {
                    retval = 0;
                    goto DESTROY_OBJECT;
                }
                ++exportnames;
            }
            export_destroy_state(export_state);
        }
        else
        {
            retval = 0;
            puts("no export type given");
        }
    }
    else
    {
        fputs("errors while creating cell\n", stderr);
        retval = 0;
        goto DESTROY_OBJECT;
    }

    // cell info
    if(cmdoptions_was_provided_long(cmdoptions, "show-cellinfo"))
    {
        if(toplevel)
        {
            info_cellinfo(toplevel);
        }
    }

DESTROY_OBJECT:
    if(toplevel)
    {
        object_destroy(toplevel);
    }
    pcell_destroy_state(pcell_state);
DESTROY_TECHNOLOGY:
    technology_destroy(techstate);
EXIT:
    return retval;
}
