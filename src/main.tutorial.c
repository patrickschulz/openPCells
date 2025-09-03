#include "main.tutorial.h"

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h> /* mkdir */

#include "print.h"
#include "terminal.h"

#define OPC_TUTORIAL_PATH "openPCells_tutorial"

static void _write(const char* filename, const char** content, int executable)
{
    char* path = malloc(strlen(OPC_TUTORIAL_PATH) + 1 + strlen(filename) + 1);
    sprintf(path, "%s/%s", OPC_TUTORIAL_PATH, filename);
    FILE* file = fopen(path, "w");
    const char** ptr = content;
    while(*ptr)
    {
        fputs(*ptr, file);
        fputc('\n', file);
        ++ptr;
    }
    fclose(file);
    if(executable)
    {
        chmod(path, 0755);
    }
    free(path);
}

static void _write_README(void)
{
    const char* content[] = {
        "This is a tutorial for the openPCells layout generator.",
        "In this folder there are various sub-folders with opc programs that demonstrate different concepts.",
        "They loosely build upon each other, however they can also be used as references for how to do specific things.",
        NULL
    };
    _write("README", content, 0);
}

static void _write_01_momcap(void)
{
    /* generate directory */
    mkdir(OPC_TUTORIAL_PATH "/01_momcap", 0777);
    /* generate cellscript */
    const char* cellscriptcontent[] = {
        "local cell = object.create(\"momcap\")",
        "",
        "-- parameters (dimensions are in nanometer)",
        "local fingers = 20",
        "local fingerwidth = 200",
        "local fingerspace = 200",
        "local fingerheight = 5000",
        "local fingeroffset = 500",
        "local fingermetal = 1",
        "for i = 1, fingers + 1 do",
        "    geometry.rectangleblwh(cell, generics.metal(fingermetal),",
        "        point.create(",
        "           0 + (i - 1) * 2 * (fingerwidth + fingerspace),",
        "           0",
        "        ),",
        "        fingerwidth,",
        "        fingerheight",
        "    )",
        "end",
        "for i = 1, fingers + 1 do",
        "    geometry.rectangleblwh(cell, generics.metal(fingermetal),",
        "        point.create(",
        "           fingerwidth + fingerspace + (i - 1) * 2 * (fingerwidth + fingerspace),",
        "           fingeroffset",
        "        ),",
        "        fingerwidth,",
        "        fingerheight",
        "    )",
        "end",
        "return cell",
        NULL
    };
    _write("01_momcap/main.lua", cellscriptcontent, 0);
    /* generate run.sh */
    const char* runshcontent[] = {
        "opc --technology opc --export gds --cellscript main.lua",
        NULL
    };
    _write("01_momcap/run.sh", runshcontent, 1);
}

void main_generate_tutorial(void)
{
    /* generate main directory */
    mkdir(OPC_TUTORIAL_PATH, 0777);
    /* create main README */
    _write_README();
    /* write 01_momcap */
    _write_01_momcap();
}

static int _read_key(void)
{
    terminal_cursor_visibility(1);
    int ch;
    int saved = 0;
    while(1)
    {
        ch = getchar();
        if(ch == '\n')
        {
            break;
        }
        saved = ch;
    }
    terminal_cursor_visibility(0);
    return saved;
}

static void _write_with_color(const char* text, int fr, int fg, int fb, int br, int bg, int bb)
{
    terminal_set_foreground_color_RGB(fr, fg, fb);
    terminal_set_background_color_RGB(br, bg, bb);
    fputs(text, stdout);
    terminal_reset_color();
}

static void _code(const char* text)
{
    _write_with_color(text, 0, 0, 0, 200, 200, 200);
}

static void _hcode(const char* text)
{
    _write_with_color(text, 0, 0, 0, 255, 200, 200);
}

static void _codech(char ch)
{
    char str[2] = { ch, 0 };
    _write_with_color(str, 0, 0, 0, 200, 200, 200);
}

static void _hcodech(char ch)
{
    char str[2] = { ch, 0 };
    _write_with_color(str, 0, 0, 0, 255, 200, 200);
}

static void _codenl(const char* text, unsigned int width)
{
    _code(text);
    if(width > 0)
    {
        int difference = width - strlen(text);
        for(int i = 0; i < difference; ++i)
        {
            _codech(' ');
        }
    }
    fputc('\n', stdout);
}

static void _hcodenl(const char* text, unsigned int width)
{
    _hcode(text);
    if(width > 0)
    {
        int difference = width - strlen(text);
        for(int i = 0; i < difference; ++i)
        {
            _hcodech(' ');
        }
    }
    fputc('\n', stdout);
}

static void _puts(const char* text)
{
    fputs(text, stdout);
}

static void _putsnl(const char* text)
{
    fputs(text, stdout);
    fputc('\n', stdout);
}

static void _putnl(void)
{
    putchar('\n');
}

static void _wait_chunk(void)
{
    getchar();
    terminal_cursor_line_up(1);
}

static void _wait_chunk_reset(void)
{
    _wait_chunk();
    terminal_clear_screen();
}

static void _table_of_contents(void)
{
    _putsnl("Table of contents:");
    _putsnl("  1: Basic Introduction (Read First)");
    _putsnl("  2: Simple Example");
    _putsnl("  3: Layer Stack Model");
    _putsnl("  4: Geometry Module");
    _putsnl("  5: Layers: Generics Module");
    _putsnl("  6: Cell Hierarchies");
    _putsnl("  7: Technology Files");
    _putsnl("  8: Export Creation");
}

static void _introduction(void)
{
    terminal_clear_screen();
    _putsnl("***************************************************************************************************");
    _putsnl("*                                   openPCells                                                    *");
    _putsnl("*                               IC Layout Generator                                               *");
    _putsnl("***************************************************************************************************");
    _putnl();
    _putsnl("This is a collection of tutorials for showing most of the important features of openPCells.");
    _putnl();
}

static void _setup(void)
{
    terminal_cursor_visibility(0);
    terminal_clear_screen();
}

static void _basic_introduction(void)
{
    _putsnl("openPCells (opc) is an IC layer generator for analog and digital integrated layouts");
    _putsnl("This tutorial will show the basic flow, key API functions and general recommendations");
    _putnl();
    _putsnl("The content of the tutorial is displayed in pages/chunks.");
    _putsnl("If you are finished with reading a part, just hit 'Enter' to advance.");
    _putnl();
    _putsnl("You can directly try that now.");
    _wait_chunk();
    _putsnl("Good.");
    /*
    _putnl();
    _putsnl("The main function of opc is to generate layouts, for which there are two ways: cells and cell scripts.");
    _putnl();
    _putsnl("Cells (or parametric cells, pcells) define layouts in a restricted way by defining certain functions.");
    _putsnl("They support parameters, offer alignment anchors and boxes, can perform input parameter checks and other things.");
    _putsnl("While they can be directly created as the top-most cell level, in general they are instantiated by other cells.");
    _putnl();
    _putsnl("Cell scripts on the other hand are simply scripts that directly create layouts without any additional support for internal checks, parameters etc.");
    _putnl();
    _putsnl("In general, cells are good for sub-blocks that are used in other layouts whereas cell scripts are good as entry points for layout generation.");
    _putnl();
    */
    _wait_chunk_reset();
    _putsnl("A general note about openPCells:");
    _putsnl("It is designed to speed up/reduce repetitive work of an experienced layout engineer.");
    _putsnl("While this might change in the future, there are currently no real automation features.");
    _putsnl("Creating layouts with openPCells might sometimes be faster than with traditional methods,");
    _putsnl("but in other cases it will not.");
    _putnl();
    _putsnl("OpenPCells will help with fast layout iteration *after* a base layout is established,");
    _putsnl("but it requires sufficient knowledge about the layout process in general.");
    _putnl();
    terminal_set_foreground_color_RGB(255, 0, 0);
    _putsnl("It is not a suitable tool for beginners in integrated circuits layouts");
    terminal_reset_color();
    _wait_chunk_reset();
    _putsnl("As openPCells is text-based, code examples will be shown.");
    _putsnl("They will be highlighted by a grey background and");
    _putsnl("new/important content will be shown with a red-ish background.");
    _putsnl("Line numbers will be shown as well, so an example could look like this:");
    _putnl();
    _codenl(" | 1 a line of code", 23);
    _codenl(" | 2 another line", 23);
    _hcodenl(" | 3 a highlighted line", 23);
    _codenl(" | 4 more", 23);
    _codenl(" | 5 lines", 23);
    _wait_chunk_reset();
}

static void _simple_example(void)
{
    terminal_clear_screen();
    _putsnl("The basic introduction will use cell scripts to demonstrate the usage of opc.");
    _putsnl("For this, the best way to follow this tutorial is to have an editor and a second");
    _putsnl("terminal ready for editing cell scripts and calling opc.");
    _wait_chunk_reset();
    _putsnl("The user front-end of openPCells is accesible in lua, a lightweight programming language.");
    _putsnl("This means that cell definitions and cell scripts are also written in lua,");
    _putsnl("and that layout descriptions have fully functional programming constructs available.");
    _wait_chunk_reset();
    _putsnl("For this tutorial it is not important to know lua.");
    _putsnl("The basic concepts should be clear to anyone who was some understanding of programming");
    _putsnl("in a procedural language. If any more complext topics arise, they will be explained.");
    _wait_chunk_reset();
    _putsnl("We will start with a simple example: a rectangle on the lowest metal layer.");
    _wait_chunk();
    _putnl();
    _putsnl("A rectangle is a shape and shape are parts of layouts. But what is the layout itself?");
    _putsnl("In openPCells, layout entities are represented by so-called objects.");
    _putsnl("An object behaves like similar concepts from layout editors and formats,");
    _putsnl("it can contain shapes and references to other layout objects and it can also be instantiated.");
    _putsnl("It is the encapsulation of layout-related concepts.");
    _wait_chunk();
    _putnl();
    _putsnl("Hence, the first thing to do is to create a layout object.");
    _putsnl("There is a function that does this, which expects a name of the layout cell.");
    _putsnl("The name can be chosen arbitrary, here we use 'toplevel':");
    _putnl();
    _hcodenl(" | 1 local cell = object.create(\"toplevel\")", 0);
    _putnl();
    _putsnl("In lua, variables are global per default, so to create a local instance");
    _putsnl("we use the keyword 'local'. The line above creates a local variable 'cell'");
    _putsnl("in which we store the result of a function call.");
    _putsnl("The function is stored in a so-called table (a collection of things)");
    _putsnl("whose elements can be accessed with the dot operator (.).");
    _putsnl("Besides a few exceptions, all API functions are organized as modules");
    _putsnl("in tables to group their functionality. The 'object' module is one of them.");
    _putnl();
    _putsnl("");
    _wait_chunk_reset();
    _putsnl("Next, we create the shape.");
    _wait_chunk();
    _putnl();
    _puts("This is done with the function ");
    _code("rectanglebltr");
    _puts(" from the ");
    _code("geometry");
    _putsnl(" module.");
    _putsnl("This function expects an object to create the shape in, a layer for the shape");
    _putsnl("and the bottom-left (bl) and top-right (tr) corner points.");
    _wait_chunk();
    _putnl();
    _putsnl("The object is created, points can be chosen by us, but what do we give as a layer?");
    _putsnl("For this, openPCells offers a generic layer system that expresses the layer intent");
    _putsnl("without caring about the exact layer names, GDS numbers etc.");
    _putsnl("The generic layer is translated into a technology-specific layer for export, but this");
    _putsnl("is not relevant for cell creation.");
    _puts("The ");
    _code("generics");
    _putsnl(" module offers various functions for different layer types (e.g. front end of line, back end of line).");
    _putsnl("In this case, we want a metal and there is a function with exactly that name.");
    _putsnl("Hence, our cell script example now looks like this:");
    _codenl(" | 1 local cell = object.create(\"toplevel\")", 52);
    _hcodenl(" | 2 geometry.rectanglebltr(cell, generics.metal(1),", 52);
    _hcodenl(" | 3     point.create(0, 0),", 52);
    _hcodenl(" | 4     point.create(100, 100)", 52);
    _hcodenl(" | 5 )", 52);
    _wait_chunk_reset();
    _putsnl("Now we created a layout object with a rectangle in it.");
    _putsnl("The last thing remaining is to actually generate and export it.");
    _putsnl("As cell scripts can contain many different objects, openPCells identifies");
    _putsnl("the to-be-exported object by the return value of the script:");
    _putsnl("The returned object is exported, hence our full example is:");
    _codenl(" | 1 local cell = object.create(\"toplevel\")", 52);
    _codenl(" | 2 geometry.rectanglebltr(cell, generics.metal(1),", 52);
    _codenl(" | 3     point.create(0, 0),", 52);
    _codenl(" | 4     point.create(100, 100)", 52);
    _codenl(" | 5 )", 52);
    _hcodenl(" | 6 return cell", 52);
    _putsnl("This cell script can now be called by openPCells with the");
    _putsnl("following command ('$' indicates that this is within a shell):");
    _codenl(" $ opc --technology opc --export gds --cellscript cellscript.lua", 80);
    _wait_chunk();
    _putnl();
    _putsnl("This call generates a GDS file with one cell called 'toplevel' in the");
    _putsnl("GDS library 'opclib' (default). The cell contains a BOUNDARY with four points");
    _putsnl("with the layer data (8, 0) -- because that is defined by the 'opc' techology.");
    _wait_chunk();
    _putnl();
    _putsnl("The text representation of this GDS file looks like this:");
    _codenl("      HEADER (6) -> data: 258", 80);
    _codenl("      BGNLIB (28) -> data: 2025 8 4 9 54 18 2025 8 4 9 54 18", 80);
    _codenl("     LIBNAME (10) -> data: opclib", 80);
    _codenl("       UNITS (20) -> data: 0.001 1e-09", 80);
    _codenl("      BGNSTR (28) -> data: 2025 8 4 9 54 18 2025 8 4 9 54 18", 80);
    _codenl("     STRNAME (12) -> data: toplevel", 80);
    _codenl("    BOUNDARY (4)", 80);
    _codenl("       LAYER (6) -> data: 8", 80);
    _codenl("    DATATYPE (6) -> data: 0", 80);
    _codenl("          XY (44) -> data: 0 0 100 0 100 100 0 100 0 0", 80);
    _codenl("       ENDEL (4)", 80);
    _codenl("      ENDSTR (4)", 80);
    _codenl("      ENDLIB (4)", 80);
    _wait_chunk_reset();
    _putsnl("This concludes the basic introduction.");
    _putsnl("For further information, go through the tutorial about the geometry module,");
    _putsnl("cell hierarchies. These will explain many important concepts already");
    _putsnl("to get you started writing your own cells.");
    _putsnl("If you have to set up technology files yourself then you should check out");
    _putsnl("the tutorial about technology files.");
    _putsnl("If you need a non-standard export file type, the export tutorial will help you.");
    _wait_chunk_reset();
}

static void _ctrc_handler(int sig)
{
    (void)sig;
    terminal_reset_all();
    exit(0);
}

void main_tutorial(void)
{
    signal(SIGINT, _ctrc_handler);
    _introduction();
    int run = 1;
    while(run)
    {
        _table_of_contents();
        _putnl();
        fputs("Press a number key (1 - 8) to select a topic or quit with 'q': ", stdout);
        int answer = _read_key();
        if(answer == EOF)
        {
            break;
        }
        if(answer == 'q')
        {
            break;
        }
        switch(answer)
        {
            case '1':
                _setup();
                _basic_introduction();
                run = 1;
                break;
            case '2':
                _setup();
                _simple_example();
                run = 1;
                break;
            case '3':
                _putsnl("Geometry Module");
                run = 0;
                break;
            case '4':
                _putsnl("Layers: Generics Module");
                run = 0;
                break;
            case '5':
                _putsnl("Layers: Generics Module");
                run = 0;
                break;
            case '6':
                _putsnl("Cell Hierarchies");
                run = 0;
                break;
            case '7':
                _putsnl("Technology Files");
                run = 0;
                break;
            case '8':
                _putsnl("Export Creation");
                run = 0;
                break;
            default:
                run = 1;
                break;
        }
    }
    terminal_cursor_visibility(1);
}
