#include "main.cell.h"

#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "lua/lauxlib.h"

#include "export.h"
#include "filesystem.h"
#include "gdsparser.h"
#include "geometry.h"
#include "hashmap.h"
#include "info.h"
#include "main.functions.h"
#include "pcell.h"
#include "postprocess.h"
#include "technology.h"
#include "util_cmodule.h"
#include "util.h"
#include "config.h"

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

static void _prepare_cellpaths(struct pcell_state* pcell_state, struct cmdoptions* cmdoptions, struct hashmap* config)
{
    if(cmdoptions_was_provided_long(cmdoptions, "prepend-cellpath"))
    {
        const char* const* arg = cmdoptions_get_argument_long(cmdoptions, "prepend-cellpath");
        while(*arg)
        {

            pcell_append_cellpath(pcell_state, *arg);
            ++arg;
        }
    }
    struct vector* config_prepend_cellpaths = hashmap_get(config, "prepend_cellpaths");
    if(config_prepend_cellpaths)
    {
        for(unsigned int i = 0; i < vector_size(config_prepend_cellpaths); ++i)
        {
            pcell_append_cellpath(pcell_state, vector_get(config_prepend_cellpaths, i));
        }
    }
    if(cmdoptions_was_provided_long(cmdoptions, "append-cellpath"))
    {
        const char* const* arg = cmdoptions_get_argument_long(cmdoptions, "append-cellpath");
        while(*arg)
        {
            pcell_append_cellpath(pcell_state, *arg);
            ++arg;
        }
    }
    struct vector* config_append_cellpaths = hashmap_get(config, "append_cellpaths");
    if(config_append_cellpaths)
    {
        for(unsigned int i = 0; i < vector_size(config_append_cellpaths); ++i)
        {
            pcell_append_cellpath(pcell_state, vector_get(config_append_cellpaths, i));
        }
    }
    // add default path
    pcell_append_cellpath(pcell_state, OPC_CELL_PATH "/cells");
}

void main_list_cells_cellpaths(struct cmdoptions* cmdoptions, struct hashmap* config)
{
    struct pcell_state* pcell_state = pcell_initialize_state();
    _prepare_cellpaths(pcell_state, cmdoptions, config);
    if(cmdoptions_was_provided_long(cmdoptions, "list"))
    {
        const char* listformat = cmdoptions_get_argument_long(cmdoptions, "list-format");
        pcell_list_cells(pcell_state, listformat);
    }
    if(cmdoptions_was_provided_long(cmdoptions, "list-cellpaths"))
    {
        pcell_list_cellpaths(pcell_state);
    }
    pcell_destroy_state(pcell_state);
}

void main_list_cell_parameters(const char* cellname, const char* parametersformat, const char** parameternames_ptr, struct cmdoptions* cmdoptions, struct hashmap* config)
{
    // techstate
    struct vector* techpaths = hashmap_get(config, "techpaths");
    vector_append(techpaths, util_strdup(OPC_TECH_PATH "/tech"));
    if(cmdoptions_was_provided_long(cmdoptions, "techpath"))
    {
        const char* const* arg = cmdoptions_get_argument_long(cmdoptions, "techpath");
        while(*arg)
        {
            vector_append(techpaths, util_strdup(*arg));
            ++arg;
        }
    }
    struct const_vector* ignoredlayers = hashmap_get(config, "ignoredlayers");
    const char* techname = cmdoptions_get_argument_long(cmdoptions, "technology");
    struct technology_state* techstate = NULL;
    if(techname)
    {
        techstate = main_create_techstate(techpaths, techname, ignoredlayers);
        if(!techstate)
        {
            fputs("could not initialize technology state\n", stderr);
            return;
        }
    }

    // pcell state
    struct pcell_state* pcell_state = pcell_initialize_state();
    if(!pcell_state)
    {
        fputs("could not initialize pcell state\n", stderr);
        goto LIST_PARAMETERS_DESTROY_TECHNOLOGY;
    }
    _prepare_cellpaths(pcell_state, cmdoptions, config);

    struct const_vector* parameternames = const_vector_adapt_from_pointer_array((void**)parameternames_ptr);

    pcell_list_parameters(pcell_state, techstate, cellname, parametersformat, parameternames);
    pcell_destroy_state(pcell_state);
LIST_PARAMETERS_DESTROY_TECHNOLOGY:
    if(techstate)
    {
        technology_destroy(techstate);
    }
}

void main_list_cell_anchors(struct cmdoptions* cmdoptions, struct hashmap* config)
{
    // pcell state
    struct pcell_state* pcell_state = pcell_initialize_state();
    if(!pcell_state)
    {
        fputs("could not initialize pcell state\n", stderr);
        return;
    }
    _prepare_cellpaths(pcell_state, cmdoptions, config);

    // cellname
    const char* cellname = cmdoptions_get_argument_long(cmdoptions, "anchors");

    // parameter format
    const char* anchorsformat = cmdoptions_get_argument_long(cmdoptions, "anchors-format");

    // parameter names
    const char** ptr = cmdoptions_get_positional_parameters(cmdoptions);
    struct const_vector* parameternames = const_vector_adapt_from_pointer_array((void**)ptr);

    pcell_list_anchors(pcell_state, cellname, anchorsformat, parameternames);
    pcell_destroy_state(pcell_state);
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

static void _draw_alignmentbox_single(struct object* cell, struct technology_state* techstate, int asoutline)
{
    const struct generics* layer;
    if(asoutline)
    {
       layer = generics_create_outline(techstate);
    }
    else
    {
       layer = generics_create_special(techstate);
    }
    if(object_has_alignmentbox(cell))
    {
        struct point* outerbl = object_get_alignmentbox_anchor_outerbl(cell);
        struct point* outertr = object_get_alignmentbox_anchor_outertr(cell);
        struct point* innerbl = object_get_alignmentbox_anchor_innerbl(cell);
        struct point* innertr = object_get_alignmentbox_anchor_innertr(cell);
        geometry_rectanglebltr(cell, layer, outerbl, outertr);
        geometry_rectanglebltr(cell, layer, innerbl, innertr);
        point_destroy(outerbl);
        point_destroy(outertr);
        point_destroy(innerbl);
        point_destroy(innertr);
    }
}

static void _draw_alignmentboxes(struct object* toplevel, struct cmdoptions* cmdoptions, struct technology_state* techstate)
{
    int asoutline = cmdoptions_was_provided_long(cmdoptions, "draw-alignmentboxes-as-outline");
    if(cmdoptions_was_provided_long(cmdoptions, "draw-alignmentbox") || cmdoptions_was_provided_long(cmdoptions, "draw-all-alignmentboxes"))
    {
        _draw_alignmentbox_single(toplevel, techstate, asoutline);
    }
    if(cmdoptions_was_provided_long(cmdoptions, "draw-all-alignmentboxes"))
    {
        struct vector* references = object_collect_references_mutable(toplevel);
        struct vector_iterator* it = vector_iterator_create(references);
        while(vector_iterator_is_valid(it))
        {
            struct object* ref = vector_iterator_get(it);
            _draw_alignmentbox_single(ref, techstate, asoutline);
            vector_iterator_next(it);
        }
        vector_iterator_destroy(it);
        vector_destroy(references);
    }
}

static void _draw_cell_anchors(struct object* cell, struct technology_state* techstate, int asoutline)
{
    struct anchor_iterator* iterator = object_create_anchor_iterator(cell);
    const struct generics* layer;
    if(asoutline)
    {
       layer = generics_create_outline(techstate);
    }
    else
    {
       layer = generics_create_special(techstate);
    }
    while(anchor_iterator_is_valid(iterator))
    {
        if(anchor_iterator_is_area(iterator))
        {
            const struct point* anchor = anchor_iterator_anchor(iterator);
            const char* name = anchor_iterator_name(iterator);
            geometry_rectanglebltr(cell, layer, anchor + 0, anchor + 1);
            object_add_port(cell, name, layer, anchor + 0, 100);
        }
        else
        {
            const struct point* anchor = anchor_iterator_anchor(iterator);
            const char* name = anchor_iterator_name(iterator);
            object_add_port(cell, name, layer, anchor, 100);
        }
        anchor_iterator_next(iterator);
    }
    anchor_iterator_destroy(iterator);
}

static void _draw_anchors(struct object* toplevel, struct cmdoptions* cmdoptions, struct technology_state* techstate)
{
    if(cmdoptions_was_provided_long(cmdoptions, "draw-anchor"))
    {
        const char* const* anchornames = cmdoptions_get_argument_long(cmdoptions, "draw-anchor");
        while(*anchornames)
        {
            struct point* pt = object_get_anchor(toplevel, *anchornames);
            if(pt)
            {
                object_add_port(toplevel, *anchornames, generics_create_special(techstate), pt, 100);
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
        int asoutline = cmdoptions_was_provided_long(cmdoptions, "draw-anchors-as-outline");
        _draw_cell_anchors(toplevel, techstate, asoutline);
        if(cmdoptions_was_provided_long(cmdoptions, "draw-all-anchors"))
        {
            struct vector* references = object_collect_references_mutable(toplevel);
            struct vector_iterator* it = vector_iterator_create(references);
            while(vector_iterator_is_valid(it))
            {
                struct object* ref = vector_iterator_get(it);
                _draw_cell_anchors(ref, techstate, asoutline);
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

static void _resolve_cell_path_extensions(struct object* cell)
{
    object_foreach_shapes(cell, shape_resolve_path_extensions_inline);
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

static void _resolve_path_extensions(struct object* toplevel, struct cmdoptions* cmdoptions)
{
    if(cmdoptions_was_provided_long(cmdoptions, "resolve-path-extensions"))
    {
        _resolve_cell_path_extensions(toplevel);
        struct vector* references = object_collect_references_mutable(toplevel);
        struct vector_iterator* it = vector_iterator_create(references);
        while(vector_iterator_is_valid(it))
        {
            struct object* ref = vector_iterator_get(it);
            _resolve_cell_path_extensions(ref);
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
    vector_append(techpaths, util_strdup(OPC_TECH_PATH "/tech"));
    if(cmdoptions_was_provided_long(cmdoptions, "techpath"))
    {
        const char* const* arg = cmdoptions_get_argument_long(cmdoptions, "techpath");
        while(*arg)
        {
            vector_append(techpaths, util_strdup(*arg));
            ++arg;
        }
    }
    struct const_vector* ignoredlayers = hashmap_get(config, "ignoredlayers");
    const char* techname = cmdoptions_get_argument_long(cmdoptions, "technology");
    struct technology_state* techstate = main_create_techstate(techpaths, techname, ignoredlayers);
    if(!techstate)
    {
        fputs("could not initialize technology state\n", stderr);
        retval = 0;
        goto EXIT;
    }
    if(cmdoptions_was_provided_long(cmdoptions, "enable-fallback-vias"))
    {
        technology_enable_fallback_vias(techstate);
    }
    if(cmdoptions_was_provided_long(cmdoptions, "disable-via-arrayzation"))
    {
        technology_disable_via_arrayzation(techstate);
    }
    if(cmdoptions_was_provided_long(cmdoptions, "ignore-premapped-layers"))
    {
        technology_ignore_premapped_layers(techstate);
    }
    if(cmdoptions_was_provided_long(cmdoptions, "ignore-missing-layers"))
    {
        technology_ignore_missing_layers(techstate);
    }
    if(cmdoptions_was_provided_long(cmdoptions, "ignore-missing-exports"))
    {
        technology_ignore_missing_exports(techstate);
    }

    // pcell state
    struct pcell_state* pcell_state = pcell_initialize_state();
    if(!pcell_state)
    {
        retval = 0;
        goto DESTROY_TECHNOLOGY;
    }
    _prepare_cellpaths(pcell_state, cmdoptions, config);
    const char** ptr = cmdoptions_get_positional_parameters(cmdoptions);
    struct const_vector* cellargs = const_vector_adapt_from_pointer_array((void**)ptr);
    const char* cellname;
    if(iscellscript)
    {
        cellname = cmdoptions_get_argument_long(cmdoptions, "cellscript");
    }
    else
    {
        cellname = cmdoptions_get_argument_long(cmdoptions, "cell");
    }
    
    // enable dprint
    if(cmdoptions_was_provided_long(cmdoptions, "enable-dprint"))
    {
        pcell_enable_dprint(pcell_state);
    }

    // dprint target
    if(cmdoptions_was_provided_long(cmdoptions, "redirect-dprint"))
    {
        const char* target = cmdoptions_get_argument_long(cmdoptions, "redirect-dprint");
        pcell_set_dprint_target(pcell_state, target);
    }

    // enable debug
    if(cmdoptions_was_provided_long(cmdoptions, "debug-cell"))
    {
        pcell_enable_debug(pcell_state);
    }

    // read pfile prepend/append lists
    if(!cmdoptions_was_provided_long(cmdoptions, "disable-pfiles"))
    {
        const char* const * prependpfilenames = cmdoptions_get_argument_long(cmdoptions, "prepend-parameter-file");
        if(prependpfilenames)
        {
            while(*prependpfilenames)
            {
                pcell_append_pfile(pcell_state, *prependpfilenames);
                ++prependpfilenames;
            }
        }
        const char* const * appendpfilenames = cmdoptions_get_argument_long(cmdoptions, "append-parameter-file");
        if(appendpfilenames)
        {
            while(*appendpfilenames)
            {
                pcell_append_pfile(pcell_state, *appendpfilenames);
                ++appendpfilenames;
            }
        }
    }

    const char* cellenvfilename = cmdoptions_get_argument_long(cmdoptions, "cell-environment");
    const char* name = cmdoptions_get_argument_long(cmdoptions, "cellname");
    struct object* toplevel = NULL;
    if(iscellscript)
    {
        toplevel = pcell_create_layout_from_script(pcell_state, techstate, cellname, name, cellargs, cellenvfilename);
    }
    else
    {
        if(const_vector_size(cellargs) > 0)
        {
            fputs("creating a cell from a cell definition, but additional positional arguments are present\n", stderr);
        }
        else
        {
            toplevel = pcell_create_layout_env(pcell_state, techstate, cellname, name, cellenvfilename);
        }
    }
    const_vector_destroy(cellargs);
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
        _merge_rectangles(toplevel, cmdoptions, techstate);

        // resolve paths
        _resolve_paths(toplevel, cmdoptions);

        // resolve path extensions
        _resolve_path_extensions(toplevel, cmdoptions);

        // curve rasterization
        _raster_curves(toplevel, cmdoptions);

        // polygon triangulation
        _triangulate_polygons(toplevel, cmdoptions);

        // export cell
        if(cmdoptions_was_provided_long(cmdoptions, "export"))
        {
            struct export_state* export_state = export_create_state();

            // add export search paths. FIXME: add --exportpath cmd option
            export_add_searchpath(export_state, OPC_EXPORT_PATH "/export");

            // basename
            export_set_basename(export_state, cmdoptions_get_argument_long(cmdoptions, "filename"));

            // export options
            export_set_export_options(export_state, cmdoptions_get_argument_long(cmdoptions, "export-options"));

            // expand namecontexts
            export_set_namecontext_expansion(export_state, !cmdoptions_was_provided_long(cmdoptions, "no-expand-namecontexts"));

            // don't write ports
            if(cmdoptions_was_provided_long(cmdoptions, "disable-ports"))
            {
                export_disable_ports(export_state);
            }

            // don't export malformed shapes
            if(cmdoptions_was_provided_long(cmdoptions, "ignore-malformed-shapes"))
            {
                export_disable_malformed_shapes(export_state);
            }

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
                    export_destroy_state(export_state);
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
