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
        return (strcmp(tocheck, func) == 0) || (strcmp(tocheck, fullname) == 0);
    }
    else
    {
        return (strcmp(tocheck, func) == 0);
    }
}

struct parameter {
    const char* name;
    const char* type;
    const char* text;
};

struct api_entry {
    const char* funcname;
    const char* modulename;
    const char* info;
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

struct api_entry* _make_api_entry(const char* funcname, const char* modulename, const char* info, struct parameter* parameters, size_t len)
{
    struct api_entry* entry = malloc(sizeof(*entry));
    entry->funcname = funcname;
    entry->modulename = modulename;
    entry->info = info;
    entry->parameters = vector_create(len, NULL);
    for(size_t i = 0; i < len; ++i)
    {
        vector_append(entry->parameters, &parameters[i]);
    }
    return entry;
}

void _destroy_api_entry(void* v)
{
    struct api_entry* entry = v;
    vector_destroy(entry->parameters);
    free(entry);
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
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* set */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "set",
            NULL,
            "", // FIXME: set
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
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* pcell.inherit_parameter */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "inherit_parameter",
            "pcell",
            "", // FIXME: inherit_parameter
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* pcell.inherit_parameter_as */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "inherit_parameter_as",
            "pcell",
            "", // FIXME: inherit_parameter_as
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* pcell.inherit_all_parameters */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "inherit_all_parameters",
            "pcell",
            "", // FIXME: inherit_all_parameters
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
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* pcell.create_layout */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "create_layout",
            "pcell",
            "", // FIXME: create_layout
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
            "", // FIXME: has_layer
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
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.copy */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "copy",
            "point",
            "", // FIXME: copy
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.unwrap */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "unwrap",
            "point",
            "", // FIXME: unwrap
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.getx */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "getx",
            "point",
            "", // FIXME: getx
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.gety */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "gety",
            "point",
            "", // FIXME: gety
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.translate */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "translate",
            "point",
            "", // FIXME: translate
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.create */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "create",
            "point",
            "", // FIXME: create
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.combine_12(lhs, rhs) */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "combine_12",
            "point",
            "", // FIXME: combine_12
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.combine_21(lhs, rhs) */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "combine_21",
            "point",
            "", // FIXME: combine_21
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.combine(lhs, rhs) */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "combine",
            "point",
            "", // FIXME: combine
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.xdistance(lhs, rhs) */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "xdistance",
            "point",
            "", // FIXME: xdistance
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.ydistance(lhs, rhs) */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "ydistance",
            "point",
            "", // FIXME: ydistance
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.fix */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "fix",
            "point",
            "", // FIXME: fix
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.operator+ */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "operator+",
            "point",
            "", // FIXME: operator+
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.operator- */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "operator-",
            "point",
            "", // FIXME: operator-
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }
    /* point.operator.. */
    {
        struct parameter parameters[] = {

        };
        vector_append(entries, _make_api_entry(
            "operator..",
            "point",
            "", // FIXME: operator..
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
    struct vector_const_iterator* it = vector_const_iterator_create(entries);
    while(vector_const_iterator_is_valid(it))
    {
        const struct api_entry* entry = vector_const_iterator_get(it);
        if(_is_func(funcname, entry->funcname, entry->modulename))
        {
            size_t funclen;
            if(entry->modulename)
            {
                funclen = strlen(entry->funcname) + strlen(entry->modulename) + 10;
                printf("Syntax: %s.%s(\n", entry->funcname, entry->modulename);
            }
            else
            {
                funclen = strlen(entry->funcname) + 10;
                printf("Syntax: %s(\n", entry->funcname);
            }
            struct vector_const_iterator* pit = vector_const_iterator_create(entry->parameters);
            while(vector_const_iterator_is_valid(pit))
            {
                const struct parameter* param = vector_const_iterator_get(pit);
                for(size_t i = 0; i < funclen; ++i)
                {
                    putchar(' ');
                }
                printf("%s\n", param->name);
                vector_const_iterator_next(pit);
            }
            vector_const_iterator_destroy(pit);
            for(size_t i = 0; i < funclen; ++i)
            {
                putchar(' ');
            }
            printf("%s\n", ")");
            printf("%s\n", entry->info);
            _print_parameters(entry->parameters);
            return;
        }
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);

    /* nothing found */
    printf("Sorry, --API-help is in a very alpha stage, there was no entry for '%s' found\n", funcname);
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

