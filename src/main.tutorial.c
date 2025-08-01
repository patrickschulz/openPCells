#include "main.tutorial.h"

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

static int _read_key()
{
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

static void _codenl(const char* text)
{
    _code(text);
    fputc('\n', stdout);
}

static void _hcode(const char* text)
{
    _write_with_color(text, 0, 0, 0, 255, 200, 200);
}

static void _hcodenl(const char* text)
{
    _hcode(text);
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

void main_tutorial(void)
{
    terminal_clear_screen();
    puts("**************************************************");
    puts("*                 openPCells                     *");
    puts("*             IC Layout Generator                *");
    puts("**************************************************");
    putchar('\n');
    puts("openPCells (opc) is an IC layer generator for analog and digital integrated layouts");
    puts("This tutorial will show the basic flow, key API functions and general recommendations");
    putchar('\n');
    puts("The main function of opc is to generate layouts, for which there are two ways: cells and cell scripts.");
    putchar('\n');
    puts("Cells (or parametric cells, pcells) define layouts in a restricted way by defining certain functions.");
    puts("They support parameters, offer alignment anchors and boxes, can perform input parameter checks and other things.");
    puts("While they can be directly created as the top-most cell level, in general they are instantiated by other cells.");
    putchar('\n');
    puts("Cell scripts on the other hand are simply scripts that directly create layouts without any additional support for internal checks, parameters etc.");
    putchar('\n');
    puts("In general, cells are good for sub-blocks that are used in other layouts whereas cell scripts are good as entry points for layout generation.");
    putchar('\n');
    puts("Press any key to advance");
    getchar();
    terminal_clear_screen();
    puts("This tutorial tries to show most of the important features of opc, hence the content will be rich.");
    puts("Therefore, a specific topic can be chosen from the following table of contents:");
    puts("  1: Basic Introduction");
    puts("  2: Layer Stack Model");
    puts("  3: Geometry Module");
    puts("  4: Cell Creation");
    puts("  5: Cell Hierarchies");
    puts("  6: Technology Files");
    int found = 0;
    while(!found)
    {
        fputs("Press a number key (1 - 6) to select a topic: ", stdout);
        int answer = _read_key();
        if(answer == EOF)
        {
            break;
        }
        switch(answer)
        {
            case '1':
                terminal_clear_screen();
                _putsnl("The basic introduction will use cell scripts to demonstrate the usage of opc.");
                _putsnl("For this, the best way to follow this tutorial is to have an editor and a second");
                _putsnl("terminal ready for editing cell scripts and calling opc.");
                putchar('\n');
                _putsnl("This content is displayed in pages/chunks. If you are finished with reading this part,");
                _putsnl("just hit 'Enter' to advance.");
                getchar();
                terminal_clear_screen();
                putchar('\n');
                _putsnl("We will start with a simple example: a rectangle on the lowest metal layer.");
                _putsnl("A rectangle is a shape and shape are parts of layouts. But what is the layout?");
                _putsnl("In openPCells, layout entities are represented by so-called objects.");
                _putsnl("An object behaves like similar concepts from layout editors and formats,");
                _putsnl("it can contain shapes and references to other layout objects and it can also be instantiated.");
                _putsnl("It is the encapsulation of layout-related concepts.");
                _putsnl("Hence, the first thing to do is to create a layout object:");
                putchar('\n');
                _hcode(" | 1 local cell = object.create(\"toplevel\")");
                getchar();
                terminal_clear_screen();
                _putsnl("Next, we create the shape.");
                _puts("This is done with the function ");
                _code("rectanglebltr");
                _puts(" from the ");
                _code("geometry");
                _putsnl(" module.");
                _putsnl("This function expects an object to create the shape in, a layer for the shape");
                _putsnl("and the bottom-left (bl) and top-right (tr) corner points.");
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
                _codenl(" | 1 local cell = object.create(\"toplevel\")");
                _hcodenl(" | 2 geometry.rectanglebltr(cell, generics.metal(1),");
                _hcodenl(" | 3     point.create(0, 0),");
                _hcodenl(" | 4     point.create(100, 100)");
                _hcodenl(" | 5 )");
                getchar();
                terminal_clear_screen();
                _putsnl("Now we created a layout object with a rectangle in it.");
                _putsnl("The last thing remaining is to actually generate and export it.");
                _putsnl("As cell scripts can contain many different objects, openPCells identifies");
                _putsnl("the to-be-exported object by the return value of the script:");
                _putsnl("The returned object is exported, hence our full example is:");
                _codenl(" | 1 local cell = object.create(\"toplevel\")");
                _codenl(" | 2 geometry.rectanglebltr(cell, generics.metal(1),");
                _codenl(" | 3     point.create(0, 0),");
                _codenl(" | 4     point.create(100, 100)");
                _codenl(" | 5 )");
                _hcodenl(" | 6 return cell");
                _putsnl("This cell script can now be called by openPCells with the");
                _putsnl("following command ('$' indicates that this is within a shell):");
                _codenl(" $ opc --technology opc --export gds --cellscript cellscript.lua");
                found = 1;
                break;
            case '2':
                puts("Geometry Module");
                found = 1;
                break;
            case '3':
                puts("Cell Creation");
                found = 1;
                break;
            case '4':
                puts("Cell Hierarchies");
                found = 1;
                break;
            case '5':
                puts("Technology Files");
                found = 1;
                break;
            default:
                found = 0;
                break;
        }
    }
}
