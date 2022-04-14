#include "main.gds.h"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "main.functions.h"
#include "util.h"
#include "gdsparser.h"
#include "filesystem.h"
#include "config.h"

#include "modulemanager.h"

void main_gds_show_data(struct cmdoptions* cmdoptions)
{
    const char* arg = cmdoptions_get_argument_long(cmdoptions, "show-gds-data");
    int ret = gdsparser_show_records(arg);
    if(!ret)
    {
        // FIXME
    }
}

void main_gds_show_cell_hierarchy(struct cmdoptions* cmdoptions)
{
    lua_State* L = util_create_basic_lua_state();
    open_gdsparser_lib(L);
    main_load_lua_module(L, "gdsparser");
    main_load_lua_module(L, "aux");
    const char* filename = cmdoptions_get_argument_long(cmdoptions, "show-gds-cell-hierarchy");
    lua_pushstring(L, filename);
    lua_setglobal(L, "filename");
    int depth = atoi(cmdoptions_get_argument_long(cmdoptions, "show-gds-depth"));
    lua_pushinteger(L, depth);
    lua_setglobal(L, "depth");
    main_call_lua_program(L, OPC_HOME "/src/scripts/show_gds_hierarchy.lua");
    lua_close(L);
}

void main_gds_read(struct cmdoptions* cmdoptions)
{
    const char* readgds = cmdoptions_get_argument_long(cmdoptions, "read-gds");
    int gdsusestreamlibname = cmdoptions_was_provided_long(cmdoptions, "gds-use-libname");
    char* importlibname = cmdoptions_get_argument_long(cmdoptions, "import-libname");
    int must_free = 0;
    if(!importlibname)
    {
        if(gdsusestreamlibname)
        {
            importlibname = NULL;
        }
        else
        {
            size_t len = strlen(readgds) - 4;
            importlibname = malloc(len + 1);
            strncpy(importlibname, readgds, len);
            importlibname[len] = 0;
            must_free = 1;
        }
    }
    int ret = gdsparser_read_stream(readgds, importlibname);
    if(must_free)
    {
        free(importlibname);
    }
    if(!ret)
    {
        printf("could not read stream file '%s'\n", readgds);
    }
}
