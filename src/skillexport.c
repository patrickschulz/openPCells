#include "skillexport.h"

#include <stdint.h>
#include <stdlib.h>
#include <string.h>

#include "tagged_value.h"
#include "util.h"

const unsigned int __baseunit = 1000; // virtuoso is micrometer-based. The implementation tried to make future changes possible, but this should be a power-of-ten
const unsigned int __numdigits = 3; // digits after the decimal point. Must be log10(__baseunit)
static int __group = 0;
static const char* __groupname = "opcgroup";
static coordinate_t __labelsize = 100;
static int __splitlets = 1;
static unsigned int __counter = 0;
static unsigned int __maxletlimit = 1000;
static int __istoplevel = 0;
static char* __cellname = NULL;

static void _prepare_shape_for_group(struct export_data* data)
{
    if(__group)
    {
        export_data_append_string(data, "    dbAddFigToFigGroup(group ");
    }
    else
    {
        export_data_append_string(data, "    ");
    }
}

static void _finish_shape_for_group(struct export_data* data)
{
    if(__group)
    {
        export_data_append_string(data, ")");
    }
}

static void _start_let(struct export_data* data, int initial)
{
    export_data_append_string(data, "let(");
    export_data_append_char(data, '\n');
    export_data_append_string(data, "    (");
    export_data_append_char(data, '\n');
    if(__istoplevel)
    {
        export_data_append_string(data, "        (cv geGetEditCellView())");
        export_data_append_char(data, '\n');
    }
    else
    {
        export_data_append_string(data, "        (cv dbOpenCellViewByType(libname \"");
        export_data_append_string(data, __cellname);
        export_data_append_string(data, "\" \"layout\" \"maskLayout\"");
        export_data_append_char(data, ' ');
        if(initial)
        {
            export_data_append_string(data, "\"w\"");
        }
        else
        {
            export_data_append_string(data, "\"a\"");
        }
        export_data_append_string(data, "))");
        export_data_append_char(data, '\n');
    }
    if(__group)
    {
        export_data_append_string(data, "        (group if(dbGetFigGroupByName(cv \"");
        export_data_append_string(data, __groupname);
        export_data_append_string(data, "\") then dbGetFigGroupByName(cv \"");
        export_data_append_string(data, __groupname);
        export_data_append_string(data, "\") else dbCreateFigGroup(cv \"");
        export_data_append_string(data, __groupname);
        export_data_append_string(data, "\" t 0:0 \"R0\")))");
        export_data_append_char(data, '\n');
    }
    export_data_append_string(data, "    )");
    export_data_append_char(data, '\n');
}

static void _close_let(struct export_data* data)
{
    export_data_append_string(data, ") ; let");
    export_data_append_char(data, '\n');
    __counter = 0;
}

static void _ensure_legal_limit(struct export_data* data)
{
    if(__splitlets)
    {
        __counter = __counter + 1;
        if(__counter > __maxletlimit)
        {
            _close_let(data); // resets the counter
            _start_let(data, 0);
        }
    }
}

static void _at_begin(struct export_data* data)
{
    (void) data;
}

static void _at_end(struct export_data* data)
{
    (void) data;
}

static void _at_begin_cell(struct export_data* data, const char* name, int istoplevel)
{
    __istoplevel = istoplevel;
    __cellname = util_strdup(name);
    _start_let(data, 1); // true: initial let for this cell
}

static void _at_end_cell(struct export_data* data, int istoplevel)
{
    if(!istoplevel)
    {
        export_data_append_string(data, "    dbSave(cv)");
        export_data_append_char(data, '\n');
        export_data_append_string(data, "    dbPurge(cv)");
        export_data_append_char(data, '\n');
    }
    _close_let(data);
}

static inline void _write_layer(struct export_data* data, const struct hashmap* layer)
{
    // FIXME: check layer/purpose type, might be integer?
    export_data_append_string(data, "list(");
    const struct tagged_value* vl = hashmap_get_const(layer, "layer");
    const char* layername = tagged_value_get_const_string(vl);
    export_data_append_char(data, '"');
    export_data_append_string(data, layername);
    export_data_append_char(data, '"');

    export_data_append_char(data, ' ');

    const struct tagged_value* vp = hashmap_get_const(layer, "purpose");
    const char* layerpurpose = tagged_value_get_const_string(vp);
    export_data_append_char(data, '"');
    export_data_append_string(data, layerpurpose);
    export_data_append_char(data, '"');
    export_data_append_char(data, ')');
}

// reversing of digits is performed by recursion
// The stack size should never be too large, as a coordinate_t does only hold so many digits
// if this really becomes a bottleneck (TEST!) than this could be re-written with
// a static buffer of an appropriate size (log10(COORDINATE_MAX))
static void _write_ipart(struct export_data* data, coordinate_t num)
{
    if(num)
    {
        char digit = (((char)(num % 10)) + '0');
        if(num >= 10)
        {
            _write_ipart(data, num / 10);
        }
        export_data_append_char(data, digit);
    }
    else
    {
        export_data_append_char(data, '0');
    }
}

static void _write_fpart(struct export_data* data, coordinate_t num)
{
    char digit1 = (((char)((num / 100) % 10)) + '0');
    export_data_append_char(data, digit1);
    char digit2 = (((char)((num / 10) % 10)) + '0');
    export_data_append_char(data, digit2);
    char digit3 = (((char)((num / 1) % 10)) + '0');
    export_data_append_char(data, digit3);
}

static void _write_coordinate(struct export_data* data, coordinate_t num)
{
    if(num < 0)
    {
        export_data_append_char(data, '-');
        num = -num;
    }
    coordinate_t ipart = num / __baseunit;
    coordinate_t fpart = num - __baseunit * ipart;
    _write_ipart(data, ipart);
    export_data_append_char(data, '.');
    _write_fpart(data, fpart);
}

static void _write_point(struct export_data* data, const struct point* pt)
{
    _write_coordinate(data, point_getx(pt));
    export_data_append_char(data, ':');
    _write_coordinate(data, point_gety(pt));
}

static void _write_rectangle(struct export_data* data, const struct hashmap* layer, const struct point* bl, const struct point* tr)
{
    _prepare_shape_for_group(data);
    export_data_append_string(data, "dbCreateRect");
    export_data_append_char(data, '(');
    export_data_append_string(data, "cv");
    export_data_append_char(data, ' ');
    _write_layer(data, layer);
    export_data_append_char(data, ' ');
    export_data_append_string(data, "list");
    export_data_append_char(data, '(');
    _write_point(data, bl);
    export_data_append_char(data, ' ');
    _write_point(data, tr);
    export_data_append_char(data, ')');
    export_data_append_char(data, ')');
    export_data_append_char(data, '\n');
    _finish_shape_for_group(data);
    _ensure_legal_limit(data);
}

static void _write_polygon(struct export_data* data, const struct hashmap* layer, const struct vector* pts)
{
    _prepare_shape_for_group(data);
    export_data_append_string(data, "dbCreatePolygon");
    export_data_append_char(data, '(');
    export_data_append_string(data, "cv");
    export_data_append_char(data, ' ');
    _write_layer(data, layer);
    export_data_append_char(data, ' ');
    export_data_append_string(data, "list");
    export_data_append_char(data, '(');
    struct vector_const_iterator* it = vector_const_iterator_create(pts);
    while(vector_const_iterator_is_valid(it))
    {
        const struct point* pt = vector_const_iterator_get(it);
        _write_point(data, pt);
        export_data_append_char(data, ' ');
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
    export_data_append_char(data, ')');
    export_data_append_char(data, ')');
    export_data_append_char(data, '\n');
    _finish_shape_for_group(data);
    _ensure_legal_limit(data);
}

static void _write_path(struct export_data* data, const struct hashmap* layer, const struct vector* pts, ucoordinate_t width)
{
    _prepare_shape_for_group(data);
    export_data_append_string(data, "dbCreatePath");
    export_data_append_char(data, '(');
    export_data_append_string(data, "cv");
    export_data_append_char(data, ' ');
    _write_layer(data, layer);
    export_data_append_char(data, ' ');
    export_data_append_string(data, "list");
    export_data_append_char(data, '(');
    struct vector_const_iterator* it = vector_const_iterator_create(pts);
    while(vector_const_iterator_is_valid(it))
    {
        const struct point* pt = vector_const_iterator_get(it);
        _write_point(data, pt);
        export_data_append_char(data, ' ');
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
    export_data_append_char(data, ')');
    export_data_append_char(data, ' ');
    _write_coordinate(data, width);
    export_data_append_char(data, ')');
    export_data_append_char(data, '\n');
    _finish_shape_for_group(data);
    _ensure_legal_limit(data);
}

static const char* _get_extension(void)
{
    return "il";
}

static int _set_options(const struct vector* vopt)
{
    size_t i = 0;
    while(i < vector_size(vopt))
    {
        const char* arg = vector_get_const(vopt, i);
        if((strcmp(arg, "-L") == 0) || (strcmp(arg, "--label-size") == 0))
        {
            if(i < vector_size(vopt) - 1)
            {
                __labelsize = atoi(vector_get_const(vopt, i + 1));
            }
            else
            {
                fputs("SKILL export: --label-size: argument expected\n", stderr);
                return 0;
            }
            ++i;
        }
        else if((strcmp(arg, "-g") == 0) || (strcmp(arg, "--group") == 0))
        {
            __group = 1;
        }
        else if((strcmp(arg, "-n") == 0) || (strcmp(arg, "--group-name") == 0))
        {
            if(i < vector_size(vopt) - 1)
            {
                __groupname = vector_get_const(vopt, i + 1);
            }
            else
            {
                fputs("SKILL export: --group-name: argument expected\n", stderr);
                return 0;
            }
            ++i;
        }
        else if((strcmp(arg, "--no-let-splits") == 0))
        {
            __splitlets = 1;
        }
        else if((strcmp(arg, "--max-let-splits") == 0))
        {
            if(i < vector_size(vopt) - 1)
            {
                __maxletlimit = atoi(vector_get_const(vopt, i + 1));
            }
            else
            {
                fputs("SKILL export: --max-let-splits: argument expected\n", stderr);
                return 0;
            }
            ++i;
        }
        else
        {
            fprintf(stderr, "SKILL export: unknown option '%s'\n", arg);
            return 0;
        }
        ++i;
    }
    return 1;
}

static void _write_port(struct export_data* data, const char* name, const struct hashmap* layer, const struct point* where, unsigned int sizehint)
{
    _prepare_shape_for_group(data);
    export_data_append_string(data, "dbCreateLabel");
    export_data_append_char(data, '(');
    export_data_append_string(data, "cv");
    export_data_append_char(data, ' ');
    _write_layer(data, layer);
    export_data_append_char(data, ' ');
    _write_point(data, where);
    export_data_append_char(data, ' ');
    export_data_append_char(data, '"');
    export_data_append_string(data, name);
    export_data_append_char(data, '"');
    export_data_append_char(data, ' ');
    export_data_append_string(data, "\"centerCenter\" \"R0\" \"roman\"");
    export_data_append_char(data, ' ');
    if(sizehint > 0)
    {
        _write_coordinate(data, sizehint);
    }
    else
    {
        _write_coordinate(data, __labelsize);
    }
    export_data_append_char(data, ')');
    export_data_append_char(data, '\n');
    _finish_shape_for_group(data);
    _ensure_legal_limit(data);
}

static void _write_cell_reference(struct export_data* data, const char* identifier, const char* instname, const struct point* where, const struct transformationmatrix* trans)
{
    _prepare_shape_for_group(data);
    export_data_append_string(data, "dbCreateInstByMasterName");
    export_data_append_char(data, '(');
    export_data_append_string(data, "cv");
    export_data_append_char(data, ' ');
    export_data_append_string(data, "libname \"");
    export_data_append_string(data, identifier);
    export_data_append_string(data, "\" \"layout\" \"");
    export_data_append_string(data, instname);
    export_data_append_string(data, "\" ");
    _write_point(data, where);
    export_data_append_string(data, " \"");
    enum orientation orientation = export_get_matrix_orientation(trans);
    switch(orientation)
    {
        case R0:
            export_data_append_string(data, "R0");
            break;
        case R90:
            export_data_append_string(data, "R90");
            break;
        case R180:
            export_data_append_string(data, "R180");
            break;
        case R270:
            export_data_append_string(data, "R270");
            break;
        case MX:
            export_data_append_string(data, "MX");
            break;
        case MY:
            export_data_append_string(data, "MY");
            break;
        // FIXME: check legal values
        case MXR90:
            export_data_append_string(data, "MXR90");
            break;
        case MYR90:
            export_data_append_string(data, "MYR90");
            break;
    }
    export_data_append_string(data, "\"");
    export_data_append_char(data, ')');
    export_data_append_char(data, '\n');
    _finish_shape_for_group(data);
    _ensure_legal_limit(data);
}

static void _write_cell_array(struct export_data* data, const char* identifier, const char* instbasename, const struct point* where, const struct transformationmatrix* trans, unsigned int xrep, unsigned int yrep, coordinate_t xpitch, coordinate_t ypitch)
{
    _prepare_shape_for_group(data);
    export_data_append_string(data, "dbCreateParamSimpleMosaicByMasterName");
    export_data_append_char(data, '(');
    export_data_append_string(data, "cv");
    export_data_append_char(data, ' ');
    export_data_append_string(data, "libname \"");
    export_data_append_string(data, identifier);
    export_data_append_string(data, "\" \"layout\" \"");
    export_data_append_string(data, instbasename);
    export_data_append_string(data, "\" ");
    _write_point(data, where);
    export_data_append_string(data, " \"");
    enum orientation orientation = export_get_matrix_orientation(trans);
    switch(orientation)
    {
        case R0:
            export_data_append_string(data, "R0");
            break;
        case R90:
            export_data_append_string(data, "R90");
            break;
        case R180:
            export_data_append_string(data, "R180");
            break;
        case R270:
            export_data_append_string(data, "R270");
            break;
        case MX:
            export_data_append_string(data, "MX");
            break;
        case MY:
            export_data_append_string(data, "MY");
            break;
        // FIXME: check legal values
        case MXR90:
            export_data_append_string(data, "MXR90");
            break;
        case MYR90:
            export_data_append_string(data, "MYR90");
            break;
    }
    export_data_append_string(data, "\"");
    export_data_append_char(data, ' ');
    _write_ipart(data, yrep);
    export_data_append_char(data, ' ');
    _write_ipart(data, xrep);
    export_data_append_char(data, ' ');
    _write_coordinate(data, ypitch);
    export_data_append_char(data, ' ');
    _write_coordinate(data, xpitch);
    export_data_append_string(data, " nil");
    export_data_append_char(data, ')');
    export_data_append_char(data, '\n');
    _finish_shape_for_group(data);
    _ensure_legal_limit(data);
}

struct export_functions* skillexport_get_export_functions(void)
{
    struct export_functions* funcs = export_create_functions();
    funcs->set_options = _set_options;
    funcs->finalize = NULL;
    funcs->at_begin = _at_begin;
    funcs->at_end = _at_end;
    funcs->at_begin_cell = _at_begin_cell;
    funcs->at_end_cell = _at_end_cell;
    funcs->write_rectangle = _write_rectangle;
    funcs->write_polygon = _write_polygon;
    funcs->write_path_extension = NULL;
    funcs->write_path = _write_path;
    funcs->write_cell_reference = _write_cell_reference;
    funcs->write_cell_array = _write_cell_array;
    funcs->write_port = _write_port;
    funcs->write_label = _write_port;
    funcs->get_extension = _get_extension;
    return funcs;
}
