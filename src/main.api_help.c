#include "main.api_help.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "terminal_colors.h"
#include "vector.h"

static int _is_func(const char* tocheck, const char* func, const char* module)
{
    char* fullname = malloc(strlen(func) + strlen(module) + 1 + 1); // extra +1: '.'
    sprintf(fullname, "%s.%s", module, func);
    return (strcmp(tocheck, func) == 0) || (strcmp(tocheck, fullname) == 0);
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

    return entries;
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
            size_t funclen = strlen(entry->funcname) + strlen(entry->modulename) + 10;
            printf("Syntax: %s.%s(\n", entry->funcname, entry->modulename);
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
        const char* mfound = strstr(entry->modulename, name);
        if(ffound || mfound)
        {
            printf("%s.%s\n", entry->modulename, entry->funcname);
        }
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
}

