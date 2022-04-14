/*
** $Id: lua.c $
** Lua stand-alone interpreter
** See Copyright Notice in lua.h
*/

#include "lua/lprefix.h"

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <errno.h>
#include <math.h>
#include <ctype.h>
#include <string.h>

#include "lua/lua.h"
#include "lua/lauxlib.h"
#include "lua/lualib.h"

#include "cmdoptions.h"
#include "util.h"
#include "config.h"
#include "scriptmanager.h"
#include "modulemanager.h"
#include "pcell.h"
#include "lplacer.h"
#include "lrouter.h"
#include "filesystem.h"

#include "main.functions.h"
#include "main.cell.h"
#include "main.gds.h"

static int _load_config(struct keyvaluearray* config)
{
    const char* home = getenv("HOME");
    lua_State* L = util_create_basic_lua_state();
    lua_pushfstring(L, "%s/.opcconfig.lua", home);
    lua_setglobal(L, "filename");
    int ret = luaL_dofile(L, OPC_HOME "/src/config.lua");
    if(ret == LUA_OK)
    {
        struct vector* techpaths = vector_create();
        lua_getfield(L, -1, "techpaths");
        if(!lua_isnil(L, -1))
        {
            lua_pushnil(L);
            while(lua_next(L, -2) != 0)
            {
                const char* path = lua_tostring(L, -1);
                vector_append(techpaths, util_copy_string(path));
                lua_pop(L, 1);
            }
        }
        lua_pop(L, 1); // pop techpaths table (or nil)
        keyvaluearray_add_untagged(config, "techpaths", techpaths);
    }
    lua_close(L);
    return ret == LUA_OK;
}

void _print_general_info(void)
{
    puts("This is the openPCell layout generator.");
    puts("To generate a layout, you need to pass the technology, the export type and a cellname.");
    puts("Example:");
    puts("         opc --technology opc --export gds --cell stdcells/not_gate");
    puts("");
    puts("You can find out more about the available command line options by running 'opc -h'.");
}

int main(int argc, const char* const * argv)
{
    // no arguments: exit and write a short helpful message if called without any arguments
    if(argc == 1)
    {
        _print_general_info();
        return 0;
    }

    int returnvalue = 0;

    // create and parse command line options
    struct cmdoptions* cmdoptions = cmdoptions_create();
    #include "cmdoptions_def.c" // yes, I did that
    if(!cmdoptions_parse(cmdoptions, argc, argv))
    {
        returnvalue = 1;
        goto DESTROY_CMDOPTIONS;
    }
    if(cmdoptions_was_provided_long(cmdoptions, "help"))
    {
        cmdoptions_help(cmdoptions);
        goto DESTROY_CMDOPTIONS;
    }
    if(cmdoptions_was_provided_long(cmdoptions, "version"))
    {
        puts("openPCells (opc) 0.2.0");
        puts("Copyright 2020-2022 Patrick Kurth");
        goto DESTROY_CMDOPTIONS;
    }

    if(cmdoptions_was_provided_long(cmdoptions, "import-verilog"))
    {
        const char* scriptname = cmdoptions_get_argument_long(cmdoptions, "import-verilog");
        lua_State* L = util_create_basic_lua_state();
        module_load_globals(L);
        if(!lua_isnil(L, -1))
        {
            lua_setglobal(L, "globals");
        }
        module_load_aux(L);
        if(!lua_isnil(L, -1))
        {
            lua_setglobal(L, "aux");
        }
        module_load_verilog(L);
        if(!lua_isnil(L, -1))
        {
            lua_setglobal(L, "verilog");
        }
        module_load_verilogprocessor(L);
        if(!lua_isnil(L, -1))
        {
            lua_setglobal(L, "verilogprocessor");
        }
        open_lplacer_lib(L);
        module_load_placement(L);
        if(!lua_isnil(L, -1))
        {
            lua_setglobal(L, "placement");
        }
        open_lrouter_lib(L);
        module_load_routing(L);
        if(!lua_isnil(L, -1))
        {
            lua_setglobal(L, "routing");
        }
        open_lfilesystem_lib(L);
        module_load_generator(L);
        if(!lua_isnil(L, -1))
        {
            lua_setglobal(L, "generator");
        }
        int ret = luaL_dofile(L, scriptname);
        if(ret != LUA_OK)
        {
            const char* msg = lua_tostring(L, -1);
            printf("errors while loading verilog import script:\n    %s\n", msg);
        }
        lua_close(L);
        goto DESTROY_CMDOPTIONS;
    }

    // load config
    struct keyvaluearray* config = keyvaluearray_create();
    if(!cmdoptions_was_provided_long(cmdoptions, "no-user-config"))
    {
        if(!_load_config(config))
        {
            puts("error while loading user config");
            returnvalue = 1;
            goto DESTROY_CONFIG;
        }
    }

    // FIXME
    if(cmdoptions_was_provided_long(cmdoptions, "watch"))
    {
        puts("sorry, watch mode is currently not implemented");
        returnvalue = 1;
        goto DESTROY_CONFIG;
    }

    // show gds data
    if(cmdoptions_was_provided_long(cmdoptions, "show-gds-data"))
    {
        main_gds_show_data(cmdoptions);
        goto DESTROY_CONFIG;
    }

    // show gds hierarchy
    if(cmdoptions_was_provided_long(cmdoptions, "show-gds-cell-hierarchy"))
    {
        main_gds_show_cell_hierarchy(cmdoptions);
        goto DESTROY_CONFIG;
    }

    // read gds
    if(cmdoptions_was_provided_long(cmdoptions, "read-gds"))
    {
        main_gds_read(cmdoptions);
        goto DESTROY_CONFIG;
    }

    // technology file generation assistant
    if(cmdoptions_was_provided_long(cmdoptions, "techfile-assistant"))
    {
        lua_State* L = util_create_basic_lua_state();
        script_call_assistant(L);
        lua_close(L);
        goto DESTROY_CONFIG;
    }

    if(cmdoptions_was_provided_long(cmdoptions, "listtechpaths"))
    {
        printf("%s\n", OPC_HOME "/tech");
        const char** arg = cmdoptions_get_argument_long(cmdoptions, "techpath");
        while(arg && *arg)
        {
            printf("%s\n", *arg);
            ++arg;
        }
        struct vector* techpaths = keyvaluearray_get(config, "techpaths");
        for(unsigned int i = 0; i < vector_size(techpaths); ++i)
        {
            printf("%s\n", (const char*)vector_get(techpaths, i));
        }
        goto DESTROY_CONFIG;
    }

    // list + listcellpaths
    if(cmdoptions_was_provided_long(cmdoptions, "listcellpaths") ||
       cmdoptions_was_provided_long(cmdoptions, "list"))
    {
        struct vector* cellpaths_to_prepend = vector_create();
        if(cmdoptions_was_provided_long(cmdoptions, "prepend-cellpath"))
        {
            const char** arg = cmdoptions_get_argument_long(cmdoptions, "prepend-cellpath");
            while(*arg)
            {
                vector_append(cellpaths_to_prepend, util_copy_string(*arg));
                ++arg;
            }
        }
        struct vector* cellpaths_to_append = vector_create();
        if(cmdoptions_was_provided_long(cmdoptions, "cellpath"))
        {
            const char** arg = cmdoptions_get_argument_long(cmdoptions, "cellpath");
            while(*arg)
            {
                vector_append(cellpaths_to_append, util_copy_string(*arg));
                ++arg;
            }
        }
        if(cmdoptions_was_provided_long(cmdoptions, "append-cellpath"))
        {
            const char** arg = cmdoptions_get_argument_long(cmdoptions, "append-cellpath");
            while(*arg)
            {
                vector_append(cellpaths_to_append, util_copy_string(*arg));
                ++arg;
            }
        }
        vector_append(cellpaths_to_append, util_copy_string(OPC_HOME "/cells"));
        struct pcell_state* pcell_state = pcell_initialize_state(cellpaths_to_prepend, cellpaths_to_append);
        vector_destroy(cellpaths_to_prepend, free);
        vector_destroy(cellpaths_to_append, free);
        if(cmdoptions_was_provided_long(cmdoptions, "list"))
        {
            const char* listformat = cmdoptions_get_argument_long(cmdoptions, "list-format");
            pcell_list_cells(pcell_state, listformat);
        }
        if(cmdoptions_was_provided_long(cmdoptions, "listcellpaths"))
        {
            pcell_list_cellpaths(pcell_state);
        }
    }

    // create cell
    if(cmdoptions_was_provided_long(cmdoptions, "cell"))
    {
        main_create_and_export_cell(cmdoptions, config, 0); // 0: regular cell
    }
    else if(cmdoptions_was_provided_long(cmdoptions, "cellscript"))
    {
        main_create_and_export_cell(cmdoptions, config, 1); // 1: is cell script
    }

    // clean up states
DESTROY_CONFIG: ;
    struct vector* techpaths = keyvaluearray_get(config, "techpaths");
    if(techpaths)
    {
        vector_destroy(techpaths, free); // every techpath is a copied string
    }
    keyvaluearray_destroy(config);
DESTROY_CMDOPTIONS:
    cmdoptions_destroy(cmdoptions);
    return returnvalue;
}

