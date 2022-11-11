#include "main.api_help.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "terminal_colors.h"
#include "vector.h"

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
    char* type;
    char* text;
};

struct api_entry {
    char* funcname;
    char* modulename;
    char* info;
    char* example;
    struct vector* parameters;
};

#define _switch_color(color) fputs(color, stdout)

static void _reset(void)
{
    _switch_color(COLOR_NORMAL);
}

static void _print_parameter(const struct parameter* parameter, int namewidth, int typewidth)
{
    fputs("    ", stdout);
    _switch_color(COLOR_BLUE_BOLD);
    printf("%*s" COLOR_NORMAL, namewidth, parameter->name);
    _reset();
    _switch_color(COLOR_GREEN_BOLD);
    printf(" (%*s)", typewidth, parameter->type);
    _reset();
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
        int nw = strlen(param->name);
        if(nw > namewidth) { namewidth = nw; }
        int tw = strlen(param->type);
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
    new->type = strdup(param->type);
    new->text = strdup(param->text);
    return new;
}

void _destroy_parameter(void* v)
{
    struct parameter* parameter = v;
    free(parameter->name);
    free(parameter->type);
    free(parameter->text);
    free(parameter);
}

struct api_entry* _make_api_entry(
    const char* funcname,
    const char* modulename,
    const char* info,
    const char* example,
    struct parameter* parameters, size_t len
)
{
    struct api_entry* entry = malloc(sizeof(*entry));
    entry->funcname = strdup(funcname);
    if(modulename)
    {
        entry->modulename = strdup(modulename);
    }
    else
    {
        entry->modulename = NULL;
    }
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
    free(entry->modulename);
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
    putchar('\n');
    if(entry->modulename)
    {
        printf("Syntax: %s.%s(", entry->funcname, entry->modulename);
    }
    else
    {
        printf("Syntax: %s(", entry->funcname);
    }
    for(size_t i = 0; i < vector_size(entry->parameters); ++i)
    {
        const struct parameter* param = vector_get_const(entry->parameters, i);
        printf("%s", param->name);
        if(i < vector_size(entry->parameters) - 1)
        {
            putchar(',');
            putchar(' ');
        }
    }

    printf("%s\n\n", ")");
    printf("%s\n\n", entry->info);
    fputs("Example: ", stdout);
    _print_with_newlines_and_offset(entry->example, 9); // 9: strlen("Example: ")
    putchar('\n');
    putchar('\n');
    _print_parameters(entry->parameters);
}

struct vector* _initialize_api_entries(void)
{
    /* initialize entries */
    struct vector* entries = vector_create(32, _destroy_api_entry);

    /* geometry.rectangle */
    {
        struct parameter parameters[] = {
            { "cell",   "object",             "Object in which the rectangle is created" },
            { "layer",  "generic",            "Layer of the generated rectangular shape" },
            { "width",  "integer",            "Width of the generated rectangular shape" },
            { "height", "integer",            "Height of the generated rectangular shape" },
            { "xshift", "integer, default 0", "Optional shift in x direction" },
            { "yshift", "integer, default 0", "Optional shift in y direction" },
            { "xrep",   "integer, default 1", "Optional number of repetitions in x direction. The Rectangles are shifted so that an equal number is above and below" },
            { "yrep",   "integer, default 1", "Optional number of repetitions in y direction. The Rectangles are shifted so that an equal number is above and below" },
            { "xpitch", "integer, default 0", "Optional pitch in x direction, used for repetition in x" },
            { "ypitch", "integer, default 0", "Optional pitch in y direction, used for repetition in y" }
        };
        vector_append(entries, _make_api_entry(
            "rectangle",
            "geometry",
            "Create a rectangular shape with the given width and height in cell",
            "geometry.rectangle(cell, generics.metal(1), 100, 100)\ngeometry.rectangle(cell, generics.other(\"gate\"), 100, 100, 0, 0, 20, 1, 200, 0)",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.rectanglebltr */
    {
        struct parameter parameters[] = {
            { "cell",   "object",             "Object in which the rectangle is created" },
            { "layer",  "generic",            "Layer of the generated rectangular shape" },
            { "bl",     "point",              "Bottom-left point of the generated rectangular shape" },
            { "tr",     "point",              "Top-right point of the generated rectangular shape" },
            { "xrep",   "integer, default 1", "Optional number of repetitions in x direction. The Rectangles are shifted so that an equal number is above and below" },
            { "yrep",   "integer, default 1", "Optional number of repetitions in y direction. The Rectangles are shifted so that an equal number is above and below" },
            { "xpitch", "integer, default 0", "Optional pitch in x direction, used for repetition in x" },
            { "ypitch", "integer, default 0", "Optional pitch in y direction, used for repetition in y" }
        };
        vector_append(entries, _make_api_entry(
            "rectanglebltr",
            "geometry",
            "Create a rectangular shape with the given corner points in cell",
            "", // FIXME: example for rectanglebltr
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.rectanglepoints */
    {
        struct parameter parameters[] = {
            { "cell",   "object",             "Object in which the rectangle is created" },
            { "layer",  "generic",            "Layer of the generated rectangular shape" },
            { "pt1",    "point",              "First corner point of the generated rectangular shape" },
            { "pt2",    "point",              "Second corner point of the generated rectangular shape" },
            { "xrep",   "integer, default 1", "Optional number of repetitions in x direction. The Rectangles are shifted so that an equal number is above and below" },
            { "yrep",   "integer, default 1", "Optional number of repetitions in y direction. The Rectangles are shifted so that an equal number is above and below" },
            { "xpitch", "integer, default 0", "Optional pitch in x direction, used for repetition in x" },
            { "ypitch", "integer, default 0", "Optional pitch in y direction, used for repetition in y" }
        };
        vector_append(entries, _make_api_entry(
            "rectanglepoints",
            "geometry",
            "Create a rectangular shape with the given corner points in cell. Similar to geometry.rectanglebltr, but any of the corner points can be given in any order",
            "", // FIXME: example for rectanglepoints
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.polygon */
    {
        struct parameter parameters[] = {
            { "cell",   "object",             "Object in which the polygon is created" },
            { "layer",  "generic",            "Layer of the generated rectangular shape" },
            { "pts",    "pointlist",          "List of points that make up the polygon" },
        };
        vector_append(entries, _make_api_entry(
            "polygon",
            "geometry",
            "Create a polygon shape with the given points in cell",
            "", // FIXME: example for polygon
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.path */
    {
        struct parameter parameters[] = {
            { "cell",   "object",    "Object in which the path is created" },
            { "layer",  "generic",   "Layer of the generated rectangular shape" },
            { "pts",    "pointlist", "List of points where the path passes through" },
            { "width",  "integer",   "width of the path. Must be even" }
        };
        vector_append(entries, _make_api_entry(
            "path",
            "geometry",
            "Create a path shape with the given points and width in cell",
            "", // FIXME: example for path
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.path_manhatten */
    {
        struct parameter parameters[] = {
            { "cell",   "object",    "Object in which the path is created" },
            { "layer",  "generic",   "Layer of the generated rectangular shape" },
            { "pts",    "pointlist", "List of points where the path passes through" },
            { "width",  "integer",   "width of the path. Must be even" }
        };
        vector_append(entries, _make_api_entry(
            "path_manhatten",
            "geometry",
            "Create a manhatten path shape with the given points and width in cell. This only allows vertical or horizontal movements",
            "", // FIXME: example for path_manhatten
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.path_cshape */
    {
        struct parameter parameters[] = {
            { "cell",     "object",    "Object in which the path is created" },
            { "layer",    "generic",   "Layer of the generated rectangular shape" },
            { "ptstart",  "point",     "Start point of the path" },
            { "ptend",    "point",     "End point of the path" },
            { "ptoffset", "point",     "Offset point" },
            { "width",    "integer",   "width of the path. Must be even" }
        };
        vector_append(entries, _make_api_entry(
            "path_cshape",
            "geometry",
            "Create a path shape that starts and ends at the start and end point, respectively and passes through the offset point. Only the x-coordinate of the offset point is taken, creating a shape resembling a (possibly inverter) 'C'",
            "", // FIXME: example for path_cshape
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.path_ushape */
    {
        struct parameter parameters[] = {
            { "cell",     "object",    "Object in which the path is created" },
            { "layer",    "generic",   "Layer of the generated rectangular shape" },
            { "ptstart",  "point",     "Start point of the path" },
            { "ptend",    "point",     "End point of the path" },
            { "ptoffset", "point",     "Offset point" },
            { "width",    "integer",   "width of the path. Must be even" }
        };
        vector_append(entries, _make_api_entry(
            "path_ushape",
            "geometry",
            "Create a path shape that starts and ends at the start and end point, respectively and passes through the offset point. Only the y-coordinate of the offset point is taken, creating a shape resembling a (possibly inverter) 'U'",
            "", // FIXME: example for path_ushape
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.via */
    {
        struct parameter parameters[] = {
            { "cell",       "object",             "Object in which the via is created" },
            { "firstmetal", "integer",            "Number of the first metal. Negative values are possible" },
            { "lastmetal",  "integer",            "Number of the last metal. Negative values are possible" },
            { "width",      "integer",            "Width of the generated rectangular shape" },
            { "height",     "integer",            "Height of the generated rectangular shape" },
            { "xshift",     "integer, default 0", "Optional shift in x direction" },
            { "yshift",     "integer, default 0", "Optional shift in y direction" },
            { "xrep",       "integer, default 1", "Optional number of repetitions in x direction. The Rectangles are shifted so that an equal number is above and below" },
            { "yrep",       "integer, default 1", "Optional number of repetitions in y direction. The Rectangles are shifted so that an equal number is above and below" },
            { "xpitch",     "integer, default 0", "Optional pitch in x direction, used for repetition in x" },
            { "ypitch",     "integer, default 0", "Optional pitch in y direction, used for repetition in y" }
        };
        vector_append(entries, _make_api_entry(
            "via",
            "geometry",
            "Create via (single or stack) in a rectangular area with the given width and height in cell",
            "", // FIXME: example for via
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.viabltr */
    {
        struct parameter parameters[] = {
            { "cell",       "object",             "Object in which the via is created" },
            { "firstmetal", "integer",            "Number of the first metal. Negative values are possible" },
            { "lastmetal",  "integer",            "Number of the last metal. Negative values are possible" },
            { "bl",         "point",              "Bottom-left point of the generated rectangular shape" },
            { "tr",         "point",              "Top-right point of the generated rectangular shape" },
            { "xrep",       "integer, default 1", "Optional number of repetitions in x direction. The Rectangles are shifted so that an equal number is above and below" },
            { "yrep",       "integer, default 1", "Optional number of repetitions in y direction. The Rectangles are shifted so that an equal number is above and below" },
            { "xpitch",     "integer, default 0", "Optional pitch in x direction, used for repetition in x" },
            { "ypitch",     "integer, default 0", "Optional pitch in y direction, used for repetition in y" }
        };
        vector_append(entries, _make_api_entry(
            "viabltr",
            "geometry",
            "Create vias (single or stack) in a rectangular area with the given corner points in cell",
            "", // FIXME: example for viabltr
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.contact */
    {
        struct parameter parameters[] = {
            { "cell",   "object",             "Object in which the contact is created" },
            { "layer",  "string",             "Identifier of the contact type. Possible values: 'gate', 'active', 'sourcedrain'" },
            { "width",  "integer",            "Width of the generated rectangular shape" },
            { "height", "integer",            "Height of the generated rectangular shape" },
            { "xshift", "integer, default 0", "Optional shift in x direction" },
            { "yshift", "integer, default 0", "Optional shift in y direction" },
            { "xrep",   "integer, default 1", "Optional number of repetitions in x direction. The Rectangles are shifted so that an equal number is above and below" },
            { "yrep",   "integer, default 1", "Optional number of repetitions in y direction. The Rectangles are shifted so that an equal number is above and below" },
            { "xpitch", "integer, default 0", "Optional pitch in x direction, used for repetition in x" },
            { "ypitch", "integer, default 0", "Optional pitch in y direction, used for repetition in y" }
        };
        vector_append(entries, _make_api_entry(
            "contact",
            "geometry",
            "Create contacts in a rectangular area with the given width and height in cell",
            "", // FIXME: example for contact
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.contactbltr */
    {
        struct parameter parameters[] = {
            { "cell",   "object",             "Object in which the contact is created" },
            { "layer",  "string",             "Identifier of the contact type. Possible values: 'gate', 'active', 'sourcedrain'" },
            { "bl",     "point",              "Bottom-left point of the generated rectangular shape" },
            { "tr",     "point",              "Top-right point of the generated rectangular shape" },
            { "xrep",   "integer, default 1", "Optional number of repetitions in x direction. The Rectangles are shifted so that an equal number is above and below" },
            { "yrep",   "integer, default 1", "Optional number of repetitions in y direction. The Rectangles are shifted so that an equal number is above and below" },
            { "xpitch", "integer, default 0", "Optional pitch in x direction, used for repetition in x" },
            { "ypitch", "integer, default 0", "Optional pitch in y direction, used for repetition in y" }
        };
        vector_append(entries, _make_api_entry(
            "contactbltr",
            "geometry",
            "Create contacts in a rectangular area with the given corner points in cell",
            "", // FIXME: example for contactbltr
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.contactbare */
    {
        struct parameter parameters[] = {
            { "cell",   "object",             "Object in which the contact is created" },
            { "layer",  "string",             "Identifier of the contact type. Possible values: 'gate', 'active', 'sourcedrain'" },
            { "width",  "integer",            "Width of the generated rectangular shape" },
            { "height", "integer",            "Height of the generated rectangular shape" },
            { "xshift", "integer, default 0", "Optional shift in x direction" },
            { "yshift", "integer, default 0", "Optional shift in y direction" },
            { "xrep",   "integer, default 1", "Optional number of repetitions in x direction. The Rectangles are shifted so that an equal number is above and below" },
            { "yrep",   "integer, default 1", "Optional number of repetitions in y direction. The Rectangles are shifted so that an equal number is above and below" },
            { "xpitch", "integer, default 0", "Optional pitch in x direction, used for repetition in x" },
            { "ypitch", "integer, default 0", "Optional pitch in y direction, used for repetition in y" }
        };
        vector_append(entries, _make_api_entry(
            "contactbare",
            "geometry",
            "Create contacts in a rectangular area with the given width and height in cell. This function creates 'bare' contacts, so only the cut layers, no surrouning metals or semi-conductor layers",
            "", // FIXME: example for contactbare
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.contactbarebltr */
    {
        struct parameter parameters[] = {
            { "cell",   "object",             "Object in which the contact is created" },
            { "layer",  "string",             "Identifier of the contact type. Possible values: 'gate', 'active', 'sourcedrain'" },
            { "bl",     "point",              "Bottom-left point of the generated rectangular shape" },
            { "tr",     "point",              "Top-right point of the generated rectangular shape" },
            { "xrep",   "integer, default 1", "Optional number of repetitions in x direction. The Rectangles are shifted so that an equal number is above and below" },
            { "yrep",   "integer, default 1", "Optional number of repetitions in y direction. The Rectangles are shifted so that an equal number is above and below" },
            { "xpitch", "integer, default 0", "Optional pitch in x direction, used for repetition in x" },
            { "ypitch", "integer, default 0", "Optional pitch in y direction, used for repetition in y" }
        };
        vector_append(entries, _make_api_entry(
            "contactbarebltr",
            "geometry",
            "Create contacts in a rectangular area with the given corner points in cell. This function creates 'bare' contacts, so only the cut layers, no surrouning metals or semi-conductor layers",
            "", // FIXME: example for contactbarebltr
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.cross */
    {
        struct parameter parameters[] = {
            { "cell",      "object",  "Object in which the cross is created" },
            { "layer",     "generic", "Layer of the generated cross shape" },
            { "width",     "integer", "Width of the generated cross shape" },
            { "height",    "integer", "Height of the generated cross shape" },
            { "crosssize", "integer", "Cross size of the generated cross shape (the 'width' of the rectangles making up the cross)" },
        };
        vector_append(entries, _make_api_entry(
            "cross",
            "geometry",
            "Create a cross shape in the given cell. The cross is made up by two overlapping rectangles in horizontal and in vertical direction.",
            "", // FIXME: example for cross
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.unequal_ring */
    {
        struct parameter parameters[] = {
            { "cell",            "object",  "Object in which the ring is created" },
            { "layer",           "generic", "Layer of the generated ring shape" },
            { "width",           "integer", "Width of the generated ring shape" },
            { "height",          "integer", "Height of the generated ring shape" },
            { "leftringwidth",   "integer", "Left ring width of the generated ring shape (the 'width' of the path making up the left part of the ring)" },
            { "rightringwidth",  "integer", "Right ring width of the generated ring shape (the 'width' of the path making up the right part of the ring)" },
            { "topringwidth",    "integer", "Top ring width of the generated ring shape (the 'width' of the path making up the top part of the ring)" },
            { "bottomringwidth", "integer", "Bottom ring width of the generated ring shape (the 'width' of the path making up the bottom part of the ring)" },
        };
        vector_append(entries, _make_api_entry(
            "unequal_ring",
            "geometry",
            "Create a ring shape with unequal ring widhts in the given cell",
            "", // FIXME: example for unequal_ring
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.ring */
    {
        struct parameter parameters[] = {
            { "cell",      "object",  "Object in which the ring is created" },
            { "layer",     "generic", "Layer of the generated ring shape" },
            { "width",     "integer", "Width of the generated ring shape" },
            { "height",    "integer", "Height of the generated ring shape" },
            { "ringwidth", "integer", "Ring width of the generated ring shape (the 'width' of the path making up the ring)" },
        };
        vector_append(entries, _make_api_entry(
            "ring",
            "geometry",
            "Create a ring shape width equal ring widths in the given cell. Like geometry.unequal_ring, but all widths are the same",
            "", // FIXME: example for ring
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* geometry.curve */
    {
        struct parameter parameters[] = {
            { "cell",      "object",                   "Object in which the ring is created" },
            { "layer",     "generic",                  "Layer of the generated ring shape" },
            { "origin",    "point",                    "Start point of the curve" },
            { "segments",  "table",                    "Table of curve segments " }, // FIXME: more details on curve segments
            { "grid",      "integer",                  "Grid for rasterization of the curve" },
            { "allow45",   "boolean, default false",   "Start point of the curve" },
        };
        vector_append(entries, _make_api_entry(
            "curve",
            "geometry",
            "Create a curve shape width in the given cell",
            "", // FIXME: example for curve
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* object.add_child */
    {
        struct parameter parameters[] = {
            { "cell",      "object", "Object to which the child is added" },
            { "child",     "object", "Child to add" },
            { "instaname", "string", "Instance name (not used by all exports)" },
        };
        vector_append(entries, _make_api_entry(
            "add_child",
            "object",
            "Add a child object (instance) to the given cell",
            "", // FIXME: example for add_child
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* set */
    {
        struct parameter parameters[] = {
            { "...", "varargs", "variable number of arguments, usually strings or integers" },
        };
        vector_append(entries, _make_api_entry(
            "set",
            NULL,
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
            NULL,
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
            NULL,
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
            NULL,
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
            NULL,
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
            NULL,
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
            NULL,
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
            "pcell",
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
            "pcell",
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
            "pcell",
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
            "pcell",
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
            "pcell",
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
            "pcell",
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
            "pcell",
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
            "pcell",
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
            "pcell",
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
            "pcell",
            "", // FIXME: clone_matching_parameters
            "", // FIXME: example for clone_matching_parameters
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* pcell.create_layout */
    {
        struct parameter parameters[] = {
            { "cellname",   "string", "cellname of the to-be-generated layout cell in the form libname/cellname" },
            { "objectname", "string", "name of the to-be-generated object. This name will be used as identifier in exports that support hierarchies (e.g. GDSII, SKILL)" },
            { "parameters", "table",  "a table with key-value pairs to be used for the layout pcell. The parameter must exist in the pcell, otherwise this triggers an error" }
        };
        vector_append(entries, _make_api_entry(
            "create_layout",
            "pcell",
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
            "tech",
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
            "tech",
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
            "tech",
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
            "placement",
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
            "placement",
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
            "placement",
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
            "placement",
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
            "placement",
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
            "placement",
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
            "placement",
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
            "placement",
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
            "placement",
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
            "placement",
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
            "routing",
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
            "routing",
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
            "curve",
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
            "curve",
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
            "curve",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
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
            "object",
            "", // FIXME: move_anchor_y
            "", // FIXME: example for move_anchor_y
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.add_child */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "add_child",
            "object",
            "", // FIXME: add_child
            "", // FIXME: example for add_child
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* object.add_child_array */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "add_child_array",
            "object",
            "", // FIXME: add_child_array
            "", // FIXME: example for add_child_array
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
            "object",
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
            "object",
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
            "generics",
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
            "generics",
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
            "generics",
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
            "generics",
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
            "generics",
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
            "generics",
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
            "generics",
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
            "generics",
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
            "generics",
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
            "generics",
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
            "generics",
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
            "generics",
            "", // FIXME: premapped
            "", // FIXME: example for premapped
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.copy */
    {
        struct parameter parameters[] = {
            { "point", "point", "point which should be copied" }
        };
        vector_append(entries, _make_api_entry(
            "copy",
            "point",
            "copy a point. Can be used as module function or as a point method",
            "local newpt = point.copy(pt)\nlocal newpt = pt:copy()",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.unwrap */
    {
        struct parameter parameters[] = {
            { "point", "point", "point which should be unwrapped" }

        };
        vector_append(entries, _make_api_entry(
            "unwrap",
            "point",
            "unwrap: get the x- and y-coordinate from a point. Can be used as module function or as a point method",
            "local x, y = point.unwrap(pt)\nlocal x, y = pt:unwrap()",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.getx */
    {
        struct parameter parameters[] = {
            { "point", "point", "point whose x-coordinate should be queried" },
        };
        vector_append(entries, _make_api_entry(
            "getx",
            "point",
            "get the x-coordinate from a point. Can be used as module function or as a point method",
            "local x = point.getx(pt)\nlocal x = pt:getx()",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.gety */
    {
        struct parameter parameters[] = {
            { "point", "point", "point whose y-coordinate should be queried" },
        };
        vector_append(entries, _make_api_entry(
            "gety",
            "point",
            "get the y-coordinate from a point. Can be used as module function or as a point method",
            "local y = point.gety(pt)\nlocal y = pt:gety()",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.translate */
    {
        struct parameter parameters[] = {
            { "point", "point", "point to translate" },
            { "x",     "integer", "x delta by which the point should be translated" },
            { "y",     "integer", "y delta by which the point should be translated" }
        };
        vector_append(entries, _make_api_entry(
            "translate",
            "point",
            "translate a point in x and y. Can be used as module function or as a point method",
            "point.translate(pt, 100, -20)\npt:translate(100, -20)",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.create */
    {
        struct parameter parameters[] = {
            { "x", "integer", "x-coordinate of new point" },
            { "y", "integer", "y-coordinate of new point" }
        };
        vector_append(entries, _make_api_entry(
            "create",
            "point",
            "create a point from an x- and y-coordinate",
            "local pt = point.create(0, 0)",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.combine_12(lhs, rhs) */
    {
        struct parameter parameters[] = {
            { "pt1", "point", "point for the x-coordinate of the new point" },
            { "pt2", "point", "point for the y-coordinate of the new point" }
        };
        vector_append(entries, _make_api_entry(
            "combine_12",
            "point",
            "create a new point by combining the coordinates of two other points. The new point is made up by x1 and y2",
            "local new = point.combine_12(pt1, pt2) -- equivalent to point.create(pt1:getx(), pt2:gety())",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.combine_21(lhs, rhs) */
    {
        struct parameter parameters[] = {
            { "pt1", "point", "point for the y-coordinate of the new point" },
            { "pt2", "point", "point for the x-coordinate of the new point" }
        };
        vector_append(entries, _make_api_entry(
            "combine_21",
            "point",
            "create a new point by combining the coordinates of two other points. The new point is made up by x2 and y1. This function is equivalent to combine_12 with swapped arguments",
            "local new = point.combine_21(pt1, pt2) -- equivalent to point.create(pt2:getx(), pt1:gety())",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.combine(lhs, rhs) */
    {
        struct parameter parameters[] = {
            { "pt1", "point", "first point for the new point" },
            { "pt2", "point", "second point for the new point" }
        };
        vector_append(entries, _make_api_entry(
            "combine",
            "point",
            "combine two points into a new one by taking the arithmetic average of their coordinates, that is x = 0.5 * (x1 + x2), y = 0.5 * (y1 + y2)",
            "local newpt = point.combine(pt1, pt2)",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.xdistance(lhs, rhs) */
    {
        struct parameter parameters[] = {
            { "pt1", "point", "first point for the distance" },
            { "pt2", "point", "second point for the distance" }
        };
        vector_append(entries, _make_api_entry(
            "xdistance",
            "point",
            "calculate the distance in x between two points",
            "local dx = point.xdistance(pt1, pt2)",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.ydistance(lhs, rhs) */
    {
        struct parameter parameters[] = {
            { "pt1", "point", "first point for the distance" },
            { "pt2", "point", "second point for the distance" }
        };
        vector_append(entries, _make_api_entry(
            "ydistance",
            "point",
            "calculate the distance in y between two points",
            "local dy = point.xdistance(pt1, pt2)",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.fix */
    {
        struct parameter parameters[] = {
            { "pt",   "point",   "point to fix to the grid" },
            { "grid", "integer", "grid on which the coordinates should be fixed" },
        };
        vector_append(entries, _make_api_entry(
            "fix",
            "point",
            "fix the x- and y-coordinate from a point on a certain grid, that is 120 would become 100 on a grid of 100. This function behaves like floor(), no rounding is done",
            "point.create(120, 80):fix(100) -- yields (100, 0)",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.operator+ */
    {
        struct parameter parameters[] = {
            { "pt1",   "point",   "first point for the sum" },
            { "pt2",   "point",   "second point for the sum" },
        };
        vector_append(entries, _make_api_entry(
            "operator+",
            "point",
            "sum two points. This is the same as point.combine",
            "point.create(0, 0) + point.create(100, 0) -- yields (50, 0)",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.operator- */
    {
        struct parameter parameters[] = {
            { "pt1", "point", "first point for the subtraction (the minuend)" },
            { "pt2", "point", "second point for the subtraction (the subtrahend)" },
        };
        vector_append(entries, _make_api_entry(
            "operator-",
            "point",
            "create a new point representing the difference of two points",
            "point.create(0, 100) - point.create(50, 20) -- (-50, 80)",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.operator.. */
    {
        struct parameter parameters[] = {
            { "pt1", "point", "point for the x-coordinate of the new point" },
            { "pt2", "point", "point for the y-coordinate of the new point" }
        };
        vector_append(entries, _make_api_entry(
            "operator..",
            "point",
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
            "util",
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
            "util",
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
            "util",
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
            "util",
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
            "util",
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
            "util",
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
            "util",
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
            "util",
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
            "util",
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
            "util",
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
            "util",
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
            "util",
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
            "util",
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
            "util",
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
            NULL,
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
            NULL,
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
            NULL,
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
            NULL,
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
            NULL,
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
        if(_is_func(funcname, entry->funcname, entry->modulename))
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
        if(entry->modulename)
        {
            mfound = strstr(entry->modulename, name);
        }
        if(ffound || mfound)
        {
            if(entry->modulename)
            {
                printf("%s.%s\n", entry->modulename, entry->funcname);
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

