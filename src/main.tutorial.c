#include "main.tutorial.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h> /* mkdir */

#define OPC_TUTORIAL_PATH "openPCells_tutorial"

#define _puts(str) do { fputs(str, outfile); fputc('\n', outfile); } while(0)

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
