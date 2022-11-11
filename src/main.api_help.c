#include "main.api_help.h"

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "terminal_colors.h"
#include "vector.h"

#define API_HELP_TYPE_VARARGS   COLOR_BOLD COLOR_RGB(0, 0, 0)
#define API_HELP_TYPE_TABLE     COLOR_BOLD COLOR_RGB(0, 0, 0)
#define API_HELP_TYPE_BOOLEAN   COLOR_BOLD COLOR_RGB(0, 0, 0)
#define API_HELP_TYPE_STRING    COLOR_BOLD COLOR_RGB(100, 205, 0)
#define API_HELP_TYPE_OBJECT    COLOR_BOLD COLOR_RGB(0, 180, 140)
#define API_HELP_TYPE_INTEGER   COLOR_BOLD COLOR_RGB(230, 0, 120)
#define API_HELP_TYPE_GENERICS  COLOR_BOLD COLOR_RGB(0, 80, 200)
#define API_HELP_TYPE_POINT     COLOR_BOLD COLOR_RGB(255, 128, 0)

static int _is_func(const char* tocheck, const char* func, const char* module)
{
    if(module)
    {
        char* fullname = malloc(strlen(func) + strlen(module) + 1 + 1); // extra +1: '.'
        sprintf(fullname, "%s.%s", module, func);
        int match = (strcmp(tocheck, func) == 0) || (strcmp(tocheck, fullname) == 0);
        free(fullname);
        return match;
    }
    else
    {
        return (strcmp(tocheck, func) == 0);
    }
}

struct parameter {
    char* name;
    enum {
        VARARGS,
        TABLE,
        BOOLEAN,
        STRING,
        OBJECT,
        GENERICS,
        INTEGER,
        POINT,
        POINTLIST
    } type;
    char* default_value;
    char* text;
};

enum module {
    MODULE_NONE,
    MODULE_OBJECT,
    MODULE_GEOMETRY,
    MODULE_POINT,
    MODULE_TECH,
    MODULE_GENERICS,
    MODULE_PCELL,
    MODULE_UTIL,
    MODULE_PLACEMENT,
    MODULE_ROUTING,
    MODULE_CURVE
};

struct api_entry {
    char* funcname;
    enum module module;
    char* info;
    char* example;
    struct vector* parameters;
};

static const char* _stringify_module(enum module module)
{
    switch(module)
    {
        case MODULE_NONE:
            return NULL;
        case MODULE_OBJECT:
            return "object";
        case MODULE_GEOMETRY:
            return "geometry";
        case MODULE_TECH:
            return "tech";
        case MODULE_PCELL:
            return "pcell";
        case MODULE_GENERICS:
            return "generics";
        case MODULE_CURVE:
            return "curve";
        case MODULE_ROUTING:
            return "routing";
        case MODULE_PLACEMENT:
            return "PLACEMENT";
        case MODULE_POINT:
            return "point";
        case MODULE_UTIL:
            return "util";
    }
    return NULL; // make the compiler happy
}

static int _pstrlen(const char* str)
{
    const char* ptr = str;
    int len = 0;
    while(*ptr)
    {
        if(*ptr == '\033')
        {
            while(*ptr != 'm')
            {
                ++ptr;
            }
            ++ptr; // skip 'm'
            if(!*ptr)
            {
                break;
            }
        }
        ++len;
        ++ptr;
    }
    return len;
}

static void _print_escaped_string(const char* str, int width)
{
    int w = _pstrlen(str);
    for(int i = 0; i < width - w; ++i)
    {
        putchar(' ');
    }
    fputs(str, stdout);
}

static int _get_type_width(const struct parameter* parameter)
{
    switch(parameter->type)
    {
        case VARARGS:
            return 3;
        case TABLE:
            return 5;
        case STRING:
            return 6;
        case OBJECT:
            return 6;
        case GENERICS:
            return 8;
        case INTEGER:
            return 7;
        case BOOLEAN:
            return 7;
        case POINT:
            return 5;
        case POINTLIST:
            return 9;
    }
    return 0; // make the compiler happy
}

static const char* _get_param_color(const struct parameter* parameter)
{
    switch(parameter->type)
    {
        case VARARGS:
            return API_HELP_TYPE_VARARGS;
        case BOOLEAN:
            return API_HELP_TYPE_BOOLEAN;
        case TABLE:
            return API_HELP_TYPE_TABLE;
        case STRING:
            return API_HELP_TYPE_STRING;
        case OBJECT:
            return API_HELP_TYPE_OBJECT;
        case GENERICS:
            return API_HELP_TYPE_GENERICS;
        case INTEGER:
            return API_HELP_TYPE_INTEGER;
        case POINT:
            return API_HELP_TYPE_POINT;
        case POINTLIST:
            return API_HELP_TYPE_POINT;
    }
    return COLOR_NORMAL; // make the compiler happy
}

static void _print_parameter(const struct parameter* parameter, int namewidth, int typewidth)
{
    // name
    fputs("    ", stdout);
    _print_escaped_string(parameter->name, namewidth);

    // type
    putchar(' ');
    putchar('(');
    int tw = _get_type_width(parameter);
    for(int i = 0; i < typewidth - tw; ++i)
    {
        putchar(' ');
    }
    switch(parameter->type)
    {
        case VARARGS:
            fputs(API_HELP_TYPE_VARARGS "...", stdout);
            break;
        case BOOLEAN:
            fputs(API_HELP_TYPE_BOOLEAN "boolean", stdout);
            break;
        case TABLE:
            fputs(API_HELP_TYPE_TABLE "table", stdout);
            break;
        case STRING:
            fputs(API_HELP_TYPE_STRING "string", stdout);
            break;
        case OBJECT:
            fputs(API_HELP_TYPE_OBJECT "object", stdout);
            break;
        case GENERICS:
            fputs(API_HELP_TYPE_GENERICS "generics", stdout);
            break;
        case INTEGER:
            fputs(API_HELP_TYPE_INTEGER "integer", stdout);
            break;
        case POINT:
            fputs(API_HELP_TYPE_POINT "point", stdout);
            break;
        case POINTLIST:
            fputs(API_HELP_TYPE_POINT "pointlist", stdout);
            break;
    }
    fputs(COLOR_NORMAL, stdout);
    putchar(')');

    // FIXME: default values
    
    // text
    printf(": %s\n", parameter->text);
}

static void _print_parameters(const struct vector* parameters)
{
    int namewidth = 0;
    int typewidth = 0;
    struct vector_const_iterator* it = vector_const_iterator_create(parameters);
    while(vector_const_iterator_is_valid(it))
    {
        const struct parameter* param = vector_const_iterator_get(it);
        int nw = _pstrlen(param->name);
        if(nw > namewidth) { namewidth = nw; }
        int tw = _get_type_width(param);
        if(tw > typewidth) { typewidth = tw; }
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);

    puts("Parameters:");
    it = vector_const_iterator_create(parameters);
    while(vector_const_iterator_is_valid(it))
    {
        const struct parameter* param = vector_const_iterator_get(it);
        _print_parameter(param, namewidth, typewidth);
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);

}

struct parameter* _copy_parameter(const struct parameter* param)
{
    struct parameter* new = malloc(sizeof(*new));
    new->name = strdup(param->name);
    new->type = param->type;
    if(param->default_value)
    {
        new->default_value = strdup(param->default_value);
    }
    else
    {
        new->default_value = NULL;
    }
    new->text = strdup(param->text);
    return new;
}

void _destroy_parameter(void* v)
{
    struct parameter* parameter = v;
    free(parameter->name);
    free(parameter->text);
    if(parameter->default_value)
    {
        free(parameter->default_value);
    }
    free(parameter);
}

struct api_entry* _make_api_entry(
    const char* funcname,
    enum module module,
    const char* info,
    const char* example,
    struct parameter* parameters, size_t len
)
{
    struct api_entry* entry = malloc(sizeof(*entry));
    entry->funcname = strdup(funcname);
    entry->module = module;
    entry->info = strdup(info);
    entry->example = strdup(example);
    entry->parameters = vector_create(len, _destroy_parameter);
    for(size_t i = 0; i < len; ++i)
    {
        vector_append(entry->parameters, _copy_parameter(parameters + i));
    }
    return entry;
}

void _destroy_api_entry(void* v)
{
    struct api_entry* entry = v;
    free(entry->funcname);
    free(entry->info);
    free(entry->example);
    vector_destroy(entry->parameters);
    free(entry);
}

void _print_with_newlines_and_offset(const char* str, unsigned int offset)
{
    const char* ptr = str;
    while(*ptr)
    {
        putchar(*ptr);
        if(*ptr == '\n')
        {
            for(unsigned int i = 0; i < offset; ++i)
            {
                putchar(' ');
            }
        }
        ++ptr;
    }
}

void _print_api_entry(const struct api_entry* entry)
{
    // function name
    putchar('\n');
    fputs("Syntax: ", stdout);
    if(entry->module != MODULE_NONE)
    {
        printf("%s.", _stringify_module(entry->module));
    }
    printf("%s(", entry->funcname);

    // argument list
    for(size_t i = 0; i < vector_size(entry->parameters); ++i)
    {
        const struct parameter* param = vector_get_const(entry->parameters, i);

        fputs(_get_param_color(param), stdout);
        printf("%s", param->name);
        fputs(COLOR_NORMAL, stdout);
        if(i < vector_size(entry->parameters) - 1)
        {
            putchar(',');
            putchar(' ');
        }
    }

    fputs(")\n\n", stdout);
    
    // function info
    printf("%s\n\n", entry->info);

    // function example
    fputs("Example: ", stdout);
    _print_with_newlines_and_offset(entry->example, 9); // 9: strlen("Example: ")
                                                        //
    putchar('\n');
    putchar('\n');

    // detailed parameter list
    _print_parameters(entry->parameters);
}

struct vector* _initialize_api_entries(void)
{
    /* initialize entries */
    struct vector* entries = vector_create(32, _destroy_api_entry);

    /* geometry.rectangle */
    {
        struct parameter parameters[] = {
            { "cell",   OBJECT,   NULL, "Object in which the rectangle is created" },
            { "layer",  GENERICS, NULL, "Layer of the generated rectangular shape" },
            { "width",  INTEGER,  NULL, "Width of the generated rectangular shape" },
            { "height", INTEGER,  NULL, "Height of the generated rectangular shape" },
            { "xshift", INTEGER,  "0",  "Optional shift in x direction" },
            { "yshift", INTEGER,  "0",  "Optional shift in y direction" },
            { "xrep",   INTEGER,  "0",  "Optional number of repetitions in x direction. The Rectangles are shifted so that an equal number is above and below" },
            { "yrep",   INTEGER,  "0",  "Optional number of repetitions in y direction. The Rectangles are shifted so that an equal number is above and below" },
            { "xpitch", INTEGER,  "0",  "Optional pitch in x direction, used for repetition in x" },
            { "ypitch", INTEGER,  "0",  "Optional pitch in y direction, used for repetition in y" }
        };
        vector_append(entries, _make_api_entry(
            "rectangle",
            MODULE_GEOMETRY,
            "Create a rectangular shape with the given width and height in cell",
            "geometry.rectangle(cell, generics.metal(1), 100, 100)\ngeometry.rectangle(cell, generics.other(\"gate\"), 100, 100, 0, 0, 20, 1, 200, 0)",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.rectanglebltr */
    {
        struct parameter parameters[] = {
            { "cell",   OBJECT,     NULL,   "Object in which the rectangle is created" },
            { "layer",  GENERICS,   NULL,   "Layer of the generated rectangular shape" },
            { "bl",     POINT,      NULL,   "Bottom-left point of the generated rectangular shape" },
            { "tr",     POINT,      NULL,   "Top-right point of the generated rectangular shape" },
            { "xrep",   INTEGER,    "1",    "Optional number of repetitions in x direction. The Rectangles are shifted so that an equal number is above and below" },
            { "yrep",   INTEGER,    "1",    "Optional number of repetitions in y direction. The Rectangles are shifted so that an equal number is above and below" },
            { "xpitch", INTEGER,    "0",    "Optional pitch in x direction, used for repetition in x" },
            { "ypitch", INTEGER,    "0",    "Optional pitch in y direction, used for repetition in y" }
        };
        vector_append(entries, _make_api_entry(
            "rectanglebltr",
            MODULE_GEOMETRY,
            "Create a rectangular shape with the given corner points in cell",
            "geometry.rectanglebltr(cell, generics.other(\"nwell\"), point.create(-100, -100), point.create(100, 100))\ngeometry.rectanglebltr(cell, generics.metal(1), obj:get_anchor(\"bottomleft\"), obj:get_anchor(\"topright\"))\ngeometry.rectanglebltr(cell, generics.metal(-1), point.create(-100, -100), point.create(100, 100), 20, 2, 400, 1000)\n",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.rectanglepoints */
    {
        struct parameter parameters[] = {
            { "cell",   OBJECT,     NULL,   "Object in which the rectangle is created" },
            { "layer",  GENERICS,   NULL,   "Layer of the generated rectangular shape" },
            { "pt1",    POINT,      NULL,   "First corner point of the generated rectangular shape" },
            { "pt2",    POINT,      NULL,   "Second corner point of the generated rectangular shape" },
            { "xrep",   INTEGER,    "1",    "Optional number of repetitions in x direction. The Rectangles are shifted so that an equal number is above and below" },
            { "yrep",   INTEGER,    "1",    "Optional number of repetitions in y direction. The Rectangles are shifted so that an equal number is above and below" },
            { "xpitch", INTEGER,    "0",    "Optional pitch in x direction, used for repetition in x" },
            { "ypitch", INTEGER,    "0",    "Optional pitch in y direction, used for repetition in y" }
        };
        vector_append(entries, _make_api_entry(
            "rectanglepoints",
            MODULE_GEOMETRY,
            "Create a rectangular shape with the given corner points in cell. Similar to geometry.rectanglebltr, but any of the corner points can be given in any order",
            "", // FIXME: example for rectanglepoints
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.polygon */
    {
        struct parameter parameters[] = {
            { "cell",   OBJECT, NULL,             "Object in which the polygon is created" },
            { "layer",  GENERICS, NULL,            "Layer of the generated rectangular shape" },
            { "pts",    POINTLIST, NULL,          "List of points that make up the polygon" },
        };
        vector_append(entries, _make_api_entry(
            "polygon",
            MODULE_GEOMETRY,
            "Create a polygon shape with the given points in cell",
            "", // FIXME: example for polygon
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.path */
    {
        struct parameter parameters[] = {
            { "cell",   OBJECT, NULL,    "Object in which the path is created" },
            { "layer",  GENERICS, NULL,   "Layer of the generated rectangular shape" },
            { "pts",    POINTLIST, NULL, "List of points where the path passes through" },
            { "width",  INTEGER, NULL,   "width of the path. Must be even" }
        };
        vector_append(entries, _make_api_entry(
            "path",
            MODULE_GEOMETRY,
            "Create a path shape with the given points and width in cell",
            "", // FIXME: example for path
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.path_manhatten */
    {
        struct parameter parameters[] = {
            { "cell",   OBJECT, NULL,    "Object in which the path is created" },
            { "layer",  GENERICS, NULL,   "Layer of the generated rectangular shape" },
            { "pts",    POINTLIST, NULL, "List of points where the path passes through" },
            { "width",  INTEGER, NULL,   "width of the path. Must be even" }
        };
        vector_append(entries, _make_api_entry(
            "path_manhatten",
            MODULE_GEOMETRY,
            "Create a manhatten path shape with the given points and width in cell. This only allows vertical or horizontal movements",
            "", // FIXME: example for path_manhatten
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.path_cshape */
    {
        struct parameter parameters[] = {
            { "cell",     OBJECT, NULL,    "Object in which the path is created" },
            { "layer",    GENERICS, NULL,   "Layer of the generated rectangular shape" },
            { "ptstart",  POINT, NULL,       "Start point of the path" },
            { "ptend",    POINT, NULL,       "End point of the path" },
            { "ptoffset", POINT, NULL,       "Offset point" },
            { "width",    INTEGER, NULL,   "width of the path. Must be even" }
        };
        vector_append(entries, _make_api_entry(
            "path_cshape",
            MODULE_GEOMETRY,
            "Create a path shape that starts and ends at the start and end point, respectively and passes through the offset point. Only the x-coordinate of the offset point is taken, creating a shape resembling a (possibly inverter) 'C'",
            "", // FIXME: example for path_cshape
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.path_ushape */
    {
        struct parameter parameters[] = {
            { "cell",     OBJECT, NULL,    "Object in which the path is created" },
            { "layer",    GENERICS, NULL,   "Layer of the generated rectangular shape" },
            { "ptstart",  POINT, NULL,       "Start point of the path" },
            { "ptend",    POINT, NULL,       "End point of the path" },
            { "ptoffset", POINT, NULL,       "Offset point" },
            { "width",    INTEGER, NULL,   "width of the path. Must be even" }
        };
        vector_append(entries, _make_api_entry(
            "path_ushape",
            MODULE_GEOMETRY,
            "Create a path shape that starts and ends at the start and end point, respectively and passes through the offset point. Only the y-coordinate of the offset point is taken, creating a shape resembling a (possibly inverter) 'U'",
            "", // FIXME: example for path_ushape
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.via */
    {
        struct parameter parameters[] = {
            { "cell",       OBJECT, NULL,             "Object in which the via is created" },
            { "firstmetal", INTEGER, NULL,            "Number of the first metal. Negative values are possible" },
            { "lastmetal",  INTEGER, NULL,            "Number of the last metal. Negative values are possible" },
            { "width",      INTEGER, NULL,            "Width of the generated rectangular shape" },
            { "height",     INTEGER, NULL,            "Height of the generated rectangular shape" },
            { "xshift",     INTEGER, "0", "Optional shift in x direction" },
            { "yshift",     INTEGER, "0", "Optional shift in y direction" },
            { "xrep",       INTEGER, "1", "Optional number of repetitions in x direction. The Rectangles are shifted so that an equal number is above and below" },
            { "yrep",       INTEGER, "1", "Optional number of repetitions in y direction. The Rectangles are shifted so that an equal number is above and below" },
            { "xpitch",     INTEGER, "0", "Optional pitch in x direction, used for repetition in x" },
            { "ypitch",     INTEGER, "0", "Optional pitch in y direction, used for repetition in y" }
        };
        vector_append(entries, _make_api_entry(
            "via",
            MODULE_GEOMETRY,
            "Create via (single or stack) in a rectangular area with the given width and height in cell",
            "", // FIXME: example for via
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.viabltr */
    {
        struct parameter parameters[] = {
            { "cell",       OBJECT, NULL,             "Object in which the via is created" },
            { "firstmetal", INTEGER, NULL,            "Number of the first metal. Negative values are possible" },
            { "lastmetal",  INTEGER, NULL,            "Number of the last metal. Negative values are possible" },
            { "bl",         POINT, NULL,                "Bottom-left point of the generated rectangular shape" },
            { "tr",         POINT, NULL,                "Top-right point of the generated rectangular shape" },
            { "xrep",       INTEGER, "1", "Optional number of repetitions in x direction. The Rectangles are shifted so that an equal number is above and below" },
            { "yrep",       INTEGER, "1", "Optional number of repetitions in y direction. The Rectangles are shifted so that an equal number is above and below" },
            { "xpitch",     INTEGER, "0", "Optional pitch in x direction, used for repetition in x" },
            { "ypitch",     INTEGER, "0", "Optional pitch in y direction, used for repetition in y" }
        };
        vector_append(entries, _make_api_entry(
            "viabltr",
            MODULE_GEOMETRY,
            "Create vias (single or stack) in a rectangular area with the given corner points in cell",
            "", // FIXME: example for viabltr
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.contact */
    {
        struct parameter parameters[] = {
            { "cell",   OBJECT, NULL,             "Object in which the contact is created" },
            { "layer",  STRING, NULL,               "Identifier of the contact type. Possible values: 'gate', 'active', 'sourcedrain'" },
            { "width",  INTEGER, NULL,            "Width of the generated rectangular shape" },
            { "height", INTEGER, NULL,            "Height of the generated rectangular shape" },
            { "xshift", INTEGER, "0", "Optional shift in x direction" },
            { "yshift", INTEGER, "0", "Optional shift in y direction" },
            { "xrep",   INTEGER, "1", "Optional number of repetitions in x direction. The Rectangles are shifted so that an equal number is above and below" },
            { "yrep",   INTEGER, "1", "Optional number of repetitions in y direction. The Rectangles are shifted so that an equal number is above and below" },
            { "xpitch", INTEGER, "0", "Optional pitch in x direction, used for repetition in x" },
            { "ypitch", INTEGER, "0", "Optional pitch in y direction, used for repetition in y" }
        };
        vector_append(entries, _make_api_entry(
            "contact",
            MODULE_GEOMETRY,
            "Create contacts in a rectangular area with the given width and height in cell",
            "", // FIXME: example for contact
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.contactbltr */
    {
        struct parameter parameters[] = {
            { "cell",   OBJECT, NULL,             "Object in which the contact is created" },
            { "layer",  STRING, NULL,               "Identifier of the contact type. Possible values: 'gate', 'active', 'sourcedrain'" },
            { "bl",     POINT, NULL,                "Bottom-left point of the generated rectangular shape" },
            { "tr",     POINT, NULL,                "Top-right point of the generated rectangular shape" },
            { "xrep",   INTEGER, "1", "Optional number of repetitions in x direction. The Rectangles are shifted so that an equal number is above and below" },
            { "yrep",   INTEGER, "1", "Optional number of repetitions in y direction. The Rectangles are shifted so that an equal number is above and below" },
            { "xpitch", INTEGER, "0", "Optional pitch in x direction, used for repetition in x" },
            { "ypitch", INTEGER, "0", "Optional pitch in y direction, used for repetition in y" }
        };
        vector_append(entries, _make_api_entry(
            "contactbltr",
            MODULE_GEOMETRY,
            "Create contacts in a rectangular area with the given corner points in cell",
            "", // FIXME: example for contactbltr
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.contactbare */
    {
        struct parameter parameters[] = {
            { "cell",   OBJECT, NULL,             "Object in which the contact is created" },
            { "layer",  STRING, NULL,               "Identifier of the contact type. Possible values: 'gate', 'active', 'sourcedrain'" },
            { "width",  INTEGER, NULL,            "Width of the generated rectangular shape" },
            { "height", INTEGER, NULL,            "Height of the generated rectangular shape" },
            { "xshift", INTEGER, "0", "Optional shift in x direction" },
            { "yshift", INTEGER, "0", "Optional shift in y direction" },
            { "xrep",   INTEGER, "1", "Optional number of repetitions in x direction. The Rectangles are shifted so that an equal number is above and below" },
            { "yrep",   INTEGER, "1", "Optional number of repetitions in y direction. The Rectangles are shifted so that an equal number is above and below" },
            { "xpitch", INTEGER, "0", "Optional pitch in x direction, used for repetition in x" },
            { "ypitch", INTEGER, "0", "Optional pitch in y direction, used for repetition in y" }
        };
        vector_append(entries, _make_api_entry(
            "contactbare",
            MODULE_GEOMETRY,
            "Create contacts in a rectangular area with the given width and height in cell. This function creates 'bare' contacts, so only the cut layers, no surrouning metals or semi-conductor layers",
            "", // FIXME: example for contactbare
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.contactbarebltr */
    {
        struct parameter parameters[] = {
            { "cell",   OBJECT, NULL,             "Object in which the contact is created" },
            { "layer",  STRING, NULL,               "Identifier of the contact type. Possible values: 'gate', 'active', 'sourcedrain'" },
            { "bl",     POINT, NULL,                "Bottom-left point of the generated rectangular shape" },
            { "tr",     POINT, NULL,                "Top-right point of the generated rectangular shape" },
            { "xrep",   INTEGER, "1", "Optional number of repetitions in x direction. The Rectangles are shifted so that an equal number is above and below" },
            { "yrep",   INTEGER, "1", "Optional number of repetitions in y direction. The Rectangles are shifted so that an equal number is above and below" },
            { "xpitch", INTEGER, "0", "Optional pitch in x direction, used for repetition in x" },
            { "ypitch", INTEGER, "0", "Optional pitch in y direction, used for repetition in y" }
        };
        vector_append(entries, _make_api_entry(
            "contactbarebltr",
            MODULE_GEOMETRY,
            "Create contacts in a rectangular area with the given corner points in cell. This function creates 'bare' contacts, so only the cut layers, no surrouning metals or semi-conductor layers",
            "", // FIXME: example for contactbarebltr
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.cross */
    {
        struct parameter parameters[] = {
            { "cell",      OBJECT, NULL,  "Object in which the cross is created" },
            { "layer",     GENERICS, NULL, "Layer of the generated cross shape" },
            { "width",     INTEGER, NULL, "Width of the generated cross shape" },
            { "height",    INTEGER, NULL, "Height of the generated cross shape" },
            { "crosssize", INTEGER, NULL, "Cross size of the generated cross shape (the 'width' of the rectangles making up the cross)" },
        };
        vector_append(entries, _make_api_entry(
            "cross",
            MODULE_GEOMETRY,
            "Create a cross shape in the given cell. The cross is made up by two overlapping rectangles in horizontal and in vertical direction.",
            "", // FIXME: example for cross
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.unequal_ring */
    {
        struct parameter parameters[] = {
            { "cell",            OBJECT, NULL,  "Object in which the ring is created" },
            { "layer",           GENERICS, NULL, "Layer of the generated ring shape" },
            { "width",           INTEGER, NULL, "Width of the generated ring shape" },
            { "height",          INTEGER, NULL, "Height of the generated ring shape" },
            { "leftringwidth",   INTEGER, NULL, "Left ring width of the generated ring shape (the 'width' of the path making up the left part of the ring)" },
            { "rightringwidth",  INTEGER, NULL, "Right ring width of the generated ring shape (the 'width' of the path making up the right part of the ring)" },
            { "topringwidth",    INTEGER, NULL, "Top ring width of the generated ring shape (the 'width' of the path making up the top part of the ring)" },
            { "bottomringwidth", INTEGER, NULL, "Bottom ring width of the generated ring shape (the 'width' of the path making up the bottom part of the ring)" },
        };
        vector_append(entries, _make_api_entry(
            "unequal_ring",
            MODULE_GEOMETRY,
            "Create a ring shape with unequal ring widhts in the given cell",
            "", // FIXME: example for unequal_ring
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.ring */
    {
        struct parameter parameters[] = {
            { "cell",      OBJECT, NULL,  "Object in which the ring is created" },
            { "layer",     GENERICS, NULL, "Layer of the generated ring shape" },
            { "width",     INTEGER, NULL, "Width of the generated ring shape" },
            { "height",    INTEGER, NULL, "Height of the generated ring shape" },
            { "ringwidth", INTEGER, NULL, "Ring width of the generated ring shape (the 'width' of the path making up the ring)" },
        };
        vector_append(entries, _make_api_entry(
            "ring",
            MODULE_GEOMETRY,
            "Create a ring shape width equal ring widths in the given cell. Like geometry.unequal_ring, but all widths are the same",
            "", // FIXME: example for ring
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.curve */
    {
        struct parameter parameters[] = {
            { "cell",      OBJECT, NULL,                   "Object in which the ring is created" },
            { "layer",     GENERICS, NULL,                  "Layer of the generated ring shape" },
            { "origin",    POINT, NULL,                      "Start point of the curve" },
            { "segments",  TABLE, NULL,                    "Table of curve segments " }, // FIXME: more details on curve segments
            { "grid",      INTEGER, NULL,                  "Grid for rasterization of the curve" },
            { "allow45",   BOOLEAN, "false",   "Start point of the curve" },
        };
        vector_append(entries, _make_api_entry(
            "curve",
            MODULE_GEOMETRY,
            "Create a curve shape width in the given cell",
            "", // FIXME: example for curve
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* set */
    {
        struct parameter parameters[] = {
            { "...", VARARGS, NULL, "variable number of arguments, usually strings or integers" },
        };
        vector_append(entries, _make_api_entry(
            "set",
            MODULE_NONE,
            "define a set of possible values that a parameter can take. Only useful within a parameter definition of a pcell",
            "pcell.add_parameters({\n{ \"mostype\", \"nmos\", set = (\"nmos\", \"pmos\") }\n                    })",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* interval */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "interval",
            MODULE_NONE,
            "", // FIXME: interval
            "", // FIXME: example for interval
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* even */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "even",
            MODULE_NONE,
            "", // FIXME: even
            "", // FIXME: example for even
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* odd */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "odd",
            MODULE_NONE,
            "", // FIXME: odd
            "", // FIXME: example for odd
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* positive */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "positive",
            MODULE_NONE,
            "", // FIXME: positive
            "", // FIXME: example for positive
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* multiple */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "multiple",
            MODULE_NONE,
            "", // FIXME: multiple
            "", // FIXME: example for multiple
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* inf */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "inf",
            MODULE_NONE,
            "", // FIXME: inf
            "", // FIXME: example for inf
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* pcell.set_property */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "set_property",
            MODULE_PCELL,
            "", // FIXME: set_property
            "", // FIXME: example for set_property
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* pcell.add_parameter */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "add_parameter",
            MODULE_PCELL,
            "", // FIXME: add_parameter
            "", // FIXME: example for add_parameter
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* pcell.add_parameters */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "add_parameters",
            MODULE_PCELL,
            "", // FIXME: add_parameters
            "", // FIXME: example for add_parameters
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* pcell.reference_cell */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "reference_cell",
            MODULE_PCELL,
            "", // FIXME: reference_cell
            "", // FIXME: example for reference_cell
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* pcell.get_parameters */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "get_parameters",
            MODULE_PCELL,
            "", // FIXME: get_parameters
            "", // FIXME: example for get_parameters
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* pcell.push_overwrites */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "push_overwrites",
            MODULE_PCELL,
            "", // FIXME: push_overwrites
            "", // FIXME: example for push_overwrites
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* pcell.pop_overwrites */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "pop_overwrites",
            MODULE_PCELL,
            "", // FIXME: pop_overwrites
            "", // FIXME: example for pop_overwrites
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* pcell.check_expression */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "check_expression",
            MODULE_PCELL,
            "", // FIXME: check_expression
            "", // FIXME: example for check_expression
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* pcell.clone_parameters */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "clone_parameters",
            MODULE_PCELL,
            "", // FIXME: clone_parameters
            "", // FIXME: example for clone_parameters
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* pcell.clone_matching_parameters */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "clone_matching_parameters",
            MODULE_PCELL,
            "", // FIXME: clone_matching_parameters
            "", // FIXME: example for clone_matching_parameters
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* pcell.create_layout */
    {
        struct parameter parameters[] = {
            { "cellname",   STRING, NULL,   "cellname of the to-be-generated layout cell in the form libname/cellname" },
            { "objectname", STRING, NULL,   "name of the to-be-generated object. This name will be used as identifier in exports that support hierarchies (e.g. GDSII, SKILL)" },
            { "parameters", TABLE, NULL,  "a table with key-value pairs to be used for the layout pcell. The parameter must exist in the pcell, otherwise this triggers an error" }
        };
        vector_append(entries, _make_api_entry(
            "create_layout",
            MODULE_PCELL,
            "Create a layout based on a parametric cell",
            "", // FIXME: example for create_layout
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* tech.get_dimension */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "get_dimension",
            MODULE_TECH,
            "", // FIXME: get_dimension
            "", // FIXME: example for get_dimension
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* tech.has_layer */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "has_layer",
            MODULE_TECH,
            "Check if the chosen technology supports a certain layer",
            "", // FIXME: example for has_layer
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* tech.resolve_metal */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "resolve_metal",
            MODULE_TECH,
            "", // FIXME: resolve_metal
            "", // FIXME: example for resolve_metal
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* placement.create_floorplan_aspectratio */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "create_floorplan_aspectratio",
            MODULE_PLACEMENT,
            "", // FIXME: create_floorplan_aspectratio
            "", // FIXME: example for create_floorplan_aspectratio
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* placement.create_floorplan_fixed_rows */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "create_floorplan_fixed_rows",
            MODULE_PLACEMENT,
            "", // FIXME: create_floorplan_fixed_rows
            "", // FIXME: example for create_floorplan_fixed_rows
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* placement.optimize */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "optimize",
            MODULE_PLACEMENT,
            "", // FIXME: optimize
            "", // FIXME: example for optimize
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* placement.manual */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "manual",
            MODULE_PLACEMENT,
            "", // FIXME: manual
            "", // FIXME: example for manual
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* placement.insert_filler_names */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "insert_filler_names",
            MODULE_PLACEMENT,
            "", // FIXME: insert_filler_names
            "", // FIXME: example for insert_filler_names
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* placement.create_reference_rows */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "create_reference_rows",
            MODULE_PLACEMENT,
            "", // FIXME: create_reference_rows
            "", // FIXME: example for create_reference_rows
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* placement.format_rows */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "format_rows",
            MODULE_PLACEMENT,
            "", // FIXME: format_rows
            "", // FIXME: example for format_rows
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* placement.regular_rows */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "regular_rows",
            MODULE_PLACEMENT,
            "", // FIXME: regular_rows
            "", // FIXME: example for regular_rows
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* placement.digital */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "digital",
            MODULE_PLACEMENT,
            "", // FIXME: digital
            "", // FIXME: example for digital
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* placement.rowwise */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "rowwise",
            MODULE_PLACEMENT,
            "", // FIXME: rowwise
            "", // FIXME: example for rowwise
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* routing.legalize */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "legalize",
            MODULE_ROUTING,
            "", // FIXME: legalize
            "", // FIXME: example for legalize
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* routing.route */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "route",
            MODULE_ROUTING,
            "", // FIXME: route
            "", // FIXME: example for route
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* curve.lineto, */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "lineto,",
            MODULE_CURVE,
            "", // FIXME: lineto,
            "", // FIXME: example for lineto,
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* curve.arcto, */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "arcto,",
            MODULE_CURVE,
            "", // FIXME: arcto,
            "", // FIXME: example for arcto,
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* curve.cubicto */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "cubicto",
            MODULE_CURVE,
            "", // FIXME: cubicto
            "", // FIXME: example for cubicto
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.create */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "create",
            MODULE_OBJECT,
            "", // FIXME: create
            "", // FIXME: example for create
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.copy */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "copy",
            MODULE_OBJECT,
            "", // FIXME: copy
            "", // FIXME: example for copy
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.exchange */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "exchange",
            MODULE_OBJECT,
            "", // FIXME: exchange
            "", // FIXME: example for exchange
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.add_anchor */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "add_anchor",
            MODULE_OBJECT,
            "", // FIXME: add_anchor
            "", // FIXME: example for add_anchor
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.add_anchor_area */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "add_anchor_area",
            MODULE_OBJECT,
            "", // FIXME: add_anchor_area
            "", // FIXME: example for add_anchor_area
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.add_anchor_area_bltr */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "add_anchor_area_bltr",
            MODULE_OBJECT,
            "", // FIXME: add_anchor_area_bltr
            "", // FIXME: example for add_anchor_area_bltr
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.get_anchor */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "get_anchor",
            MODULE_OBJECT,
            "", // FIXME: get_anchor
            "", // FIXME: example for get_anchor
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.get_array_anchor */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "get_array_anchor",
            MODULE_OBJECT,
            "", // FIXME: get_array_anchor
            "", // FIXME: example for get_array_anchor
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.get_all_regular_anchors */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "get_all_regular_anchors",
            MODULE_OBJECT,
            "", // FIXME: get_all_regular_anchors
            "", // FIXME: example for get_all_regular_anchors
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.add_port */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "add_port",
            MODULE_OBJECT,
            "", // FIXME: add_port
            "", // FIXME: example for add_port
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.add_bus_port */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "add_bus_port",
            MODULE_OBJECT,
            "", // FIXME: add_bus_port
            "", // FIXME: example for add_bus_port
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.get_ports */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "get_ports",
            MODULE_OBJECT,
            "", // FIXME: get_ports
            "", // FIXME: example for get_ports
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.set_alignment_box */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "set_alignment_box",
            MODULE_OBJECT,
            "", // FIXME: set_alignment_box
            "", // FIXME: example for set_alignment_box
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.inherit_alignment_box */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "inherit_alignment_box",
            MODULE_OBJECT,
            "", // FIXME: inherit_alignment_box
            "", // FIXME: example for inherit_alignment_box
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.width_height_alignmentbox */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "width_height_alignmentbox",
            MODULE_OBJECT,
            "", // FIXME: width_height_alignmentbox
            "", // FIXME: example for width_height_alignmentbox
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.move_to */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "move_to",
            MODULE_OBJECT,
            "", // FIXME: move_to
            "", // FIXME: example for move_to
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.reset_translation */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "reset_translation",
            MODULE_OBJECT,
            "", // FIXME: reset_translation
            "", // FIXME: example for reset_translation
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.translate */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "translate",
            MODULE_OBJECT,
            "", // FIXME: translate
            "", // FIXME: example for translate
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.mirror_at_xaxis */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "mirror_at_xaxis",
            MODULE_OBJECT,
            "", // FIXME: mirror_at_xaxis
            "", // FIXME: example for mirror_at_xaxis
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.mirror_at_yaxis */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "mirror_at_yaxis",
            MODULE_OBJECT,
            "", // FIXME: mirror_at_yaxis
            "", // FIXME: example for mirror_at_yaxis
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.mirror_at_origin */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "mirror_at_origin",
            MODULE_OBJECT,
            "", // FIXME: mirror_at_origin
            "", // FIXME: example for mirror_at_origin
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.rotate_90_left */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "rotate_90_left",
            MODULE_OBJECT,
            "", // FIXME: rotate_90_left
            "", // FIXME: example for rotate_90_left
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.rotate_90_right */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "rotate_90_right",
            MODULE_OBJECT,
            "", // FIXME: rotate_90_right
            "", // FIXME: example for rotate_90_right
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.flipx */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "flipx",
            MODULE_OBJECT,
            "", // FIXME: flipx
            "", // FIXME: example for flipx
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.flipy */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "flipy",
            MODULE_OBJECT,
            "", // FIXME: flipy
            "", // FIXME: example for flipy
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.move_anchor */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "move_anchor",
            MODULE_OBJECT,
            "", // FIXME: move_anchor
            "", // FIXME: example for move_anchor
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.move_anchor_x */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "move_anchor_x",
            MODULE_OBJECT,
            "", // FIXME: move_anchor_x
            "", // FIXME: example for move_anchor_x
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.move_anchor_y */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "move_anchor_y",
            MODULE_OBJECT,
            "", // FIXME: move_anchor_y
            "", // FIXME: example for move_anchor_y
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* object.add_child */
    {
        struct parameter parameters[] = {
            { "cell",      OBJECT, NULL, "Object to which the child is added" },
            { "child",     OBJECT, NULL, "Child to add" },
            { "instname",  STRING, NULL,   "Instance name (not used by all exports)" },
        };
        vector_append(entries, _make_api_entry(
            "add_child",
            MODULE_OBJECT,
            "Add a child object (instance) to the given cell",
            "local ref = pcell.create_layout(\"basic/mosfet\", \"mosfet\")\ncell:add_child(ref, \"mosinst0\")",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* object.add_child_array */
    {
        struct parameter parameters[] = {
            { "cell",      OBJECT,      NULL,   "Object to which the child is added" },
            { "child",     OBJECT,      NULL,   "Child to add" },
            { "instname",  STRING,      NULL,   "Instance name (not used by all exports)" },
            { "xrep",      INTEGER,     NULL,   "Number of repetitions in x direction" },
            { "yrep",      INTEGER,     NULL,   "Number of repetitions in y direction" },
            { "xpitch",    INTEGER,     NULL,   "Optional itch in x direction, used for repetition in x. If not given, this parameter is derived from the alignment box" },
            { "ypitch",    INTEGER,     NULL,   "Optional itch in y direction, used for repetition in y. If not given, this parameter is derived from the alignment box" }
        };
        vector_append(entries, _make_api_entry(
            "add_child_array",
            MODULE_OBJECT,
            "Add a child as an arrayed object to the given cell. The child array has xrep * yrep elements, with a pitch of xpitch and ypitch, respectively. The array grows to the upper-left, with the first placed untranslated. The pitch does not have to be explicitly given: If the child has an alignment box, the xpitch and ypitch are deferred from this box, if they are not given in the call. In this case, it is an error if no alignment box is present in child",
            "--with explicit xpitch and ypitch:\nlocal ref = pcell.create_layout(\"basic/mosfet\", \"mosfet\")\ncell:add_child_array(ref, \"mosinst0\", 8, 1, 200, 0)\n-- with alignment box:\nlocal ref = pcell.create_layout(\"basic/mosfet\", \"mosfet\")\ncell:add_child_array(ref, \"mosinst0\", 8, 1)",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.merge_into_shallow */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "merge_into_shallow",
            MODULE_OBJECT,
            "", // FIXME: merge_into_shallow
            "", // FIXME: example for merge_into_shallow
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.flatten */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "flatten",
            MODULE_OBJECT,
            "", // FIXME: flatten
            "", // FIXME: example for flatten
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* generics.metal */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "metal",
            MODULE_GENERICS,
            "", // FIXME: metal
            "", // FIXME: example for metal
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* generics.metalport */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "metalport",
            MODULE_GENERICS,
            "", // FIXME: metalport
            "", // FIXME: example for metalport
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* generics.metalexclude */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "metalexclude",
            MODULE_GENERICS,
            "", // FIXME: metalexclude
            "", // FIXME: example for metalexclude
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* generics.viacut */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "viacut",
            MODULE_GENERICS,
            "", // FIXME: viacut
            "", // FIXME: example for viacut
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* generics.contact */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "contact",
            MODULE_GENERICS,
            "", // FIXME: contact
            "", // FIXME: example for contact
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* generics.oxide */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "oxide",
            MODULE_GENERICS,
            "", // FIXME: oxide
            "", // FIXME: example for oxide
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* generics.implant */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "implant",
            MODULE_GENERICS,
            "", // FIXME: implant
            "", // FIXME: example for implant
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* generics.vthtype */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "vthtype",
            MODULE_GENERICS,
            "", // FIXME: vthtype
            "", // FIXME: example for vthtype
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* generics.other */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "other",
            MODULE_GENERICS,
            "", // FIXME: other
            "", // FIXME: example for other
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* generics.otherport */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "otherport",
            MODULE_GENERICS,
            "", // FIXME: otherport
            "", // FIXME: example for otherport
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* generics.special */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "special",
            MODULE_GENERICS,
            "", // FIXME: special
            "", // FIXME: example for special
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* generics.premapped */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "premapped",
            MODULE_GENERICS,
            "", // FIXME: premapped
            "", // FIXME: example for premapped
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.copy */
    {
        struct parameter parameters[] = {
            { "point", POINT, NULL,   "point which should be copied" }
        };
        vector_append(entries, _make_api_entry(
            "copy",
            MODULE_POINT,
            "copy a point. Can be used as module function or as a point method",
            "local newpt = point.copy(pt)\nlocal newpt = pt:copy()",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.unwrap */
    {
        struct parameter parameters[] = {
            { "point", POINT, NULL,   "point which should be unwrapped" }

        };
        vector_append(entries, _make_api_entry(
            "unwrap",
            MODULE_POINT,
            "unwrap: get the x- and y-coordinate from a point. Can be used as module function or as a point method",
            "local x, y = point.unwrap(pt)\nlocal x, y = pt:unwrap()",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.getx */
    {
        struct parameter parameters[] = {
            { "point", POINT, NULL,   "point whose x-coordinate should be queried" },
        };
        vector_append(entries, _make_api_entry(
            "getx",
            MODULE_POINT,
            "get the x-coordinate from a point. Can be used as module function or as a point method",
            "local x = point.getx(pt)\nlocal x = pt:getx()",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.gety */
    {
        struct parameter parameters[] = {
            { "point", POINT, NULL,   "point whose y-coordinate should be queried" },
        };
        vector_append(entries, _make_api_entry(
            "gety",
            MODULE_POINT,
            "get the y-coordinate from a point. Can be used as module function or as a point method",
            "local y = point.gety(pt)\nlocal y = pt:gety()",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.translate */
    {
        struct parameter parameters[] = {
            { "point", POINT, NULL,   "point to translate" },
            { "x",     INTEGER, NULL, "x delta by which the point should be translated" },
            { "y",     INTEGER, NULL, "y delta by which the point should be translated" }
        };
        vector_append(entries, _make_api_entry(
            "translate",
            MODULE_POINT,
            "translate a point in x and y. Can be used as module function or as a point method",
            "point.translate(pt, 100, -20)\npt:translate(100, -20)",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.create */
    {
        struct parameter parameters[] = {
            { "x", INTEGER, NULL, "x-coordinate of new point" },
            { "y", INTEGER, NULL, "y-coordinate of new point" }
        };
        vector_append(entries, _make_api_entry(
            "create",
            MODULE_POINT,
            "create a point from an x- and y-coordinate",
            "local pt = point.create(0, 0)",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.combine_12(lhs, rhs) */
    {
        struct parameter parameters[] = {
            { "pt1", POINT, NULL,   "point for the x-coordinate of the new point" },
            { "pt2", POINT, NULL,   "point for the y-coordinate of the new point" }
        };
        vector_append(entries, _make_api_entry(
            "combine_12",
            MODULE_POINT,
            "create a new point by combining the coordinates of two other points. The new point is made up by x1 and y2",
            "local new = point.combine_12(pt1, pt2) -- equivalent to point.create(pt1:getx(), pt2:gety())",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.combine_21(lhs, rhs) */
    {
        struct parameter parameters[] = {
            { "pt1", POINT, NULL,   "point for the y-coordinate of the new point" },
            { "pt2", POINT, NULL,   "point for the x-coordinate of the new point" }
        };
        vector_append(entries, _make_api_entry(
            "combine_21",
            MODULE_POINT,
            "create a new point by combining the coordinates of two other points. The new point is made up by x2 and y1. This function is equivalent to combine_12 with swapped arguments",
            "local new = point.combine_21(pt1, pt2) -- equivalent to point.create(pt2:getx(), pt1:gety())",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.combine(lhs, rhs) */
    {
        struct parameter parameters[] = {
            { "pt1", POINT, NULL,   "first point for the new point" },
            { "pt2", POINT, NULL,   "second point for the new point" }
        };
        vector_append(entries, _make_api_entry(
            "combine",
            MODULE_POINT,
            "combine two points into a new one by taking the arithmetic average of their coordinates, that is x = 0.5 * (x1 + x2), y = 0.5 * (y1 + y2)",
            "local newpt = point.combine(pt1, pt2)",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.xdistance(lhs, rhs) */
    {
        struct parameter parameters[] = {
            { "pt1", POINT, NULL,   "first point for the distance" },
            { "pt2", POINT, NULL,   "second point for the distance" }
        };
        vector_append(entries, _make_api_entry(
            "xdistance",
            MODULE_POINT,
            "calculate the distance in x between two points",
            "local dx = point.xdistance(pt1, pt2)",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.ydistance(lhs, rhs) */
    {
        struct parameter parameters[] = {
            { "pt1", POINT, NULL,   "first point for the distance" },
            { "pt2", POINT, NULL,   "second point for the distance" }
        };
        vector_append(entries, _make_api_entry(
            "ydistance",
            MODULE_POINT,
            "calculate the distance in y between two points",
            "local dy = point.xdistance(pt1, pt2)",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.fix */
    {
        struct parameter parameters[] = {
            { "pt",   POINT, NULL,     "point to fix to the grid" },
            { "grid", INTEGER, NULL, "grid on which the coordinates should be fixed" },
        };
        vector_append(entries, _make_api_entry(
            "fix",
            MODULE_POINT,
            "fix the x- and y-coordinate from a point on a certain grid, that is 120 would become 100 on a grid of 100. This function behaves like floor(), no rounding is done",
            "point.create(120, 80):fix(100) -- yields (100, 0)",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.operator+ */
    {
        struct parameter parameters[] = {
            { "pt1",   POINT, NULL,     "first point for the sum" },
            { "pt2",   POINT, NULL,     "second point for the sum" },
        };
        vector_append(entries, _make_api_entry(
            "operator+",
            MODULE_POINT,
            "sum two points. This is the same as point.combine",
            "point.create(0, 0) + point.create(100, 0) -- yields (50, 0)",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.operator- */
    {
        struct parameter parameters[] = {
            { "pt1", POINT, NULL,   "first point for the subtraction (the minuend)" },
            { "pt2", POINT, NULL,   "second point for the subtraction (the subtrahend)" },
        };
        vector_append(entries, _make_api_entry(
            "operator-",
            MODULE_POINT,
            "create a new point representing the difference of two points",
            "point.create(0, 100) - point.create(50, 20) -- (-50, 80)",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.operator.. */
    {
        struct parameter parameters[] = {
            { "pt1", POINT, NULL,   "point for the x-coordinate of the new point" },
            { "pt2", POINT, NULL,   "point for the y-coordinate of the new point" }
        };
        vector_append(entries, _make_api_entry(
            "operator..",
            MODULE_POINT,
            "combine two points into a new one. Takes the x-coordinate from the first point and the y-coordinate from the second one. Equivalent to point.combine_12(pt1, pt2)",
            "point.create(0, 100) .. point.create(100, 0) -- (0, 0)",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* util.xmirror(pts, xcenter) */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "xmirror",
            MODULE_UTIL,
            "", // FIXME: xmirror
            "", // FIXME: example for xmirror
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* util.ymirror(pts, ycenter) */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "ymirror",
            MODULE_UTIL,
            "", // FIXME: ymirror
            "", // FIXME: example for ymirror
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* util.xymirror(pts, xcenter, ycenter) */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "xymirror",
            MODULE_UTIL,
            "", // FIXME: xymirror
            "", // FIXME: example for xymirror
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* util.filter_forward(pts, fun) */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "filter_forward",
            MODULE_UTIL,
            "", // FIXME: filter_forward
            "", // FIXME: example for filter_forward
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* util.filter_backward(pts, fun) */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "filter_backward",
            MODULE_UTIL,
            "", // FIXME: filter_backward
            "", // FIXME: example for filter_backward
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* util.merge_forwards(pts, pts2) */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "merge_forwards",
            MODULE_UTIL,
            "", // FIXME: merge_forwards
            "", // FIXME: example for merge_forwards
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* util.merge_backwards(pts, pts2) */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "merge_backwards",
            MODULE_UTIL,
            "", // FIXME: merge_backwards
            "", // FIXME: example for merge_backwards
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* util.reverse(pts) */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "reverse",
            MODULE_UTIL,
            "", // FIXME: reverse
            "", // FIXME: example for reverse
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* util.make_insert_xy(pts, idx) */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "make_insert_xy",
            MODULE_UTIL,
            "", // FIXME: make_insert_xy
            "", // FIXME: example for make_insert_xy
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* util.make_insert_pts(pts, idx) */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "make_insert_pts",
            MODULE_UTIL,
            "", // FIXME: make_insert_pts
            "", // FIXME: example for make_insert_pts
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* util.fill_all_with(num, filler) */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "fill_all_with",
            MODULE_UTIL,
            "", // FIXME: fill_all_with
            "", // FIXME: example for fill_all_with
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* util.fill_predicate_with(num, filler, predicate, other) */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "fill_predicate_with",
            MODULE_UTIL,
            "", // FIXME: fill_predicate_with
            "", // FIXME: example for fill_predicate_with
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* util.fill_even_with(num, filler, other) */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "fill_even_with",
            MODULE_UTIL,
            "", // FIXME: fill_even_with
            "", // FIXME: example for fill_even_with
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* util.fill_odd_with(num, filler, other) */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "fill_odd_with",
            MODULE_UTIL,
            "", // FIXME: fill_odd_with
            "", // FIXME: example for fill_odd_with
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* enable */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "enable",
            MODULE_NONE,
            "", // FIXME: enable
            "", // FIXME: example for enable
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* thisorthat */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "thisorthat",
            MODULE_NONE,
            "", // FIXME: thisorthat
            "", // FIXME: example for thisorthat
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* evenodddiv */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "evenodddiv",
            MODULE_NONE,
            "", // FIXME: evenodddiv
            "", // FIXME: example for evenodddiv
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* evenodddiv2 */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "evenodddiv2",
            MODULE_NONE,
            "", // FIXME: evenodddiv2
            "", // FIXME: example for evenodddiv2
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* dprint */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "dprint",
            MODULE_NONE,
            "", // FIXME: dprint
            "", // FIXME: example for dprint
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    return entries;
}

void _destroy_api_entries(struct vector* entries)
{
    vector_destroy(entries);
}

void main_API_help(const char* funcname)
{
    struct vector* entries = _initialize_api_entries();

    /* search and print API info */
    int found = 0;
    struct vector_const_iterator* it = vector_const_iterator_create(entries);
    while(vector_const_iterator_is_valid(it))
    {
        const struct api_entry* entry = vector_const_iterator_get(it);
        if(_is_func(funcname, entry->funcname, _stringify_module(entry->module)))
        {
            _print_api_entry(entry);
            found = 1;
            break;
        }
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);

    if(!found)
    {
        printf("Sorry, --API-help is in a very alpha stage, there was no entry for '%s' found\n", funcname);
    }
    _destroy_api_entries(entries);
}

void main_API_search(const char* name)
{
    struct vector* entries = _initialize_api_entries();
    struct vector_const_iterator* it = vector_const_iterator_create(entries);
    while(vector_const_iterator_is_valid(it))
    {
        const struct api_entry* entry = vector_const_iterator_get(it);
        const char* ffound = strstr(entry->funcname, name);
        const char* mfound = NULL;
        const char* modulename = _stringify_module(entry->module);
        if(modulename)
        {
            mfound = strstr(modulename, name);
        }
        if(ffound || mfound)
        {
            if(modulename)
            {
                printf("%s.%s\n", modulename, entry->funcname);
            }
            else
            {
                printf("%s\n", entry->funcname);
            }
        }
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
    _destroy_api_entries(entries);
}

