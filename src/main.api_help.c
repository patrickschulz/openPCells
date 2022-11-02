#include "main.api_help.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "terminal_colors.h"

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

#define _switch_color(color) fputs(color, stdout)

static void _reset(void)
{
    _switch_color(COLOR_NORMAL);
}

static void _print_parameter(struct parameter parameter, int namewidth, int typewidth)
{
    fputs("    ", stdout);
    _switch_color(COLOR_BLUE_BOLD);
    printf("%*s" COLOR_NORMAL, namewidth, parameter.name);
    _reset();
    _switch_color(COLOR_GREEN_BOLD);
    printf(" (%*s)", typewidth, parameter.type);
    _reset();
    printf(": %s\n", parameter.text);
}

static void _print_parameters(const struct parameter* parameters, size_t len)
{
    int namewidth = 0;
    int typewidth = 0;
    for(size_t i = 0; i < len; ++i)
    {
        int nw = strlen(parameters[i].name);
        if(nw > namewidth) { namewidth = nw; }
        int tw = strlen(parameters[i].type);
        if(tw > typewidth) { typewidth = tw; }
    }
    puts("Parameters:");
    for(size_t i = 0; i < len; ++i)
    {
        _print_parameter(parameters[i], namewidth, typewidth);
    }
}

void main_API_help(const char* funcname)
{
    if(_is_func(funcname, "rectangle", "geometry"))
    {
        puts("Syntax: geometry.rectangle(cell, layer,");
        puts("                           width, height,");
        puts("                           xshift, yshift,");
        puts("                           xrep, yrep, xpitch, ypitch");
        puts("                          )");
        puts("Create a rectangular shape width the given width and height in cell");
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
        _print_parameters(parameters, sizeof(parameters) / sizeof(parameters[0]));
    }
    else
    {
        puts("Sorry, --API-help is in a very alpha stage and not many functions are documented.");
    }
}

