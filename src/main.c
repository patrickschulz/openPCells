#include "lua/lprefix.h"

#include <ctype.h>
#include <errno.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>

#include "lua/lua.h"
#include "lua/lualib.h"
#include "lua/lauxlib.h"

#include "cmdoptions.h"
#include "config.h"
#include "filesystem.h"
#include "hashmap.h"
#include "lplacer.h"
#include "lrouter.h"
#include "lua_util.h"
#include "modulemanager.h"
#include "pcell.h"
#include "scriptmanager.h"
#include "util.h"

#include "main.api_help.h"
#include "main.cell.h"
#include "main.functions.h"
#include "main.gds.h"
#include "main.verilog.h"

static int _load_config(struct hashmap* config)
{
    // prepare config
    struct vector* techpaths = vector_create(8, free);
    hashmap_insert(config, "techpaths", techpaths);
    struct vector* prepend_cellpaths = vector_create(8, free);
    hashmap_insert(config, "prepend_cellpaths", prepend_cellpaths);
    struct vector* append_cellpaths = vector_create(8, free);
    hashmap_insert(config, "append_cellpaths", append_cellpaths);
    struct vector* ignoredlayers = vector_create(8, free);
    hashmap_insert(config, "ignoredlayers", ignoredlayers);

    const char* home = getenv("HOME");
    size_t len = strlen(home) + strlen("/.opcconfig.lua");
    char* filename = malloc(len + 1);
    snprintf(filename, len + 1, "%s/.opcconfig.lua", home);
    if(!filesystem_exists(filename))
    {
        free(filename);
        return 1; // non-existing user config is not an error
    }
    lua_State* L = util_create_basic_lua_state();
    int ret = luaL_dofile(L, filename);
    free(filename);
    if(ret == LUA_OK)
    {
        // techpaths
        techpaths = hashmap_get(config, "techpaths");
        lua_getfield(L, -1, "techpaths");
        if(!lua_isnil(L, -1))
        {
            lua_pushnil(L);
            while(lua_next(L, -2) != 0)
            {
                const char* path = lua_tostring(L, -1);
                vector_append(techpaths, strdup(path));
                lua_pop(L, 1);
            }
        }
        lua_pop(L, 1); // pop techpaths table (or nil)
        // remove entry
        lua_pushnil(L);
        lua_setfield(L, -2, "techpaths");

        // cellpaths
        techpaths = hashmap_get(config, "prepend_cellpaths");
        lua_getfield(L, -1, "prepend_cellpaths");
        if(!lua_isnil(L, -1))
        {
            lua_pushnil(L);
            while(lua_next(L, -2) != 0)
            {
                const char* path = lua_tostring(L, -1);
                vector_append(prepend_cellpaths, strdup(path));
                lua_pop(L, 1);
            }
        }
        lua_pop(L, 1); // pop prepend_cellpaths table (or nil)
        // remove entry
        lua_pushnil(L);
        lua_setfield(L, -2, "prepend_cellpaths");

        append_cellpaths = hashmap_get(config, "append_cellpaths");
        lua_getfield(L, -1, "append_cellpaths");
        if(!lua_isnil(L, -1))
        {
            lua_pushnil(L);
            while(lua_next(L, -2) != 0)
            {
                const char* path = lua_tostring(L, -1);
                vector_append(append_cellpaths, strdup(path));
                lua_pop(L, 1);
            }
        }
        lua_pop(L, 1); // pop append_cellpaths table (or nil)
        // remove entry
        lua_pushnil(L);
        lua_setfield(L, -2, "append_cellpaths");

        lua_pushnil(L);
        while(lua_next(L, -2) != 0)
        {
            printf("unknown config entry '%s'\n", lua_tostring(L, -2));
            lua_pop(L, 1);
            ret = LUA_ERRRUN;
        }
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
    FILE* pfd_f = NULL;
    if(cmdoptions_was_provided_long(cmdoptions, "stderr-to"))
    {
        const char* stderrto = cmdoptions_get_argument_long(cmdoptions, "stderr-to");
        pfd_f = fopen(stderrto, "w");
        int pfd = fileno(pfd_f);
        dup2(pfd, STDERR_FILENO);
    }

    if(cmdoptions_was_provided_long(cmdoptions, "api-help"))
    {
        const char* funcname = cmdoptions_get_argument_long(cmdoptions, "api-help");
        main_API_help(funcname);
        goto DESTROY_CMDOPTIONS;
    }

    if(cmdoptions_was_provided_long(cmdoptions, "import-verilog"))
    {
        const char* scriptname = cmdoptions_get_argument_long(cmdoptions, "import-verilog");
        main_verilog_import(scriptname);
        goto DESTROY_CMDOPTIONS;
    }

    // load config
    struct hashmap* config = hashmap_create();
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

    if(cmdoptions_was_provided_long(cmdoptions, "disable-gatecut"))
    {
        struct vector* ignoredlayers = hashmap_get(config, "ignoredlayers");
        vector_append(ignoredlayers, strdup("gatecut"));
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
        open_lfilesystem_lib(L);
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
        if(hashmap_exists(config, "techpaths"))
        {
            struct vector* techpaths = hashmap_get(config, "techpaths");
            for(unsigned int i = 0; i < vector_size(techpaths); ++i)
            {
                printf("%s\n", (const char*)vector_get(techpaths, i));
            }
        }
        goto DESTROY_CONFIG;
    }

    // list + listcellpaths
    if(cmdoptions_was_provided_long(cmdoptions, "listcellpaths") ||
       cmdoptions_was_provided_long(cmdoptions, "list"))
    {
        struct vector* cellpaths_to_prepend = vector_create(8, free);
        if(cmdoptions_was_provided_long(cmdoptions, "prepend-cellpath"))
        {
            const char** arg = cmdoptions_get_argument_long(cmdoptions, "prepend-cellpath");
            while(*arg)
            {
                vector_append(cellpaths_to_prepend, strdup(*arg));
                ++arg;
            }
        }
        struct vector* cellpaths_to_append = vector_create(8, free);
        if(cmdoptions_was_provided_long(cmdoptions, "cellpath"))
        {
            const char** arg = cmdoptions_get_argument_long(cmdoptions, "cellpath");
            while(*arg)
            {
                vector_append(cellpaths_to_append, strdup(*arg));
                ++arg;
            }
        }
        if(cmdoptions_was_provided_long(cmdoptions, "append-cellpath"))
        {
            const char** arg = cmdoptions_get_argument_long(cmdoptions, "append-cellpath");
            while(*arg)
            {
                vector_append(cellpaths_to_append, strdup(*arg));
                ++arg;
            }
        }
        if(hashmap_exists(config, "prepend_cellpaths"))
        {
            struct vector* config_cellpaths_to_prepend = hashmap_get(config, "prepend_cellpaths");
            for(unsigned int i = 0; i < vector_size(config_cellpaths_to_prepend); ++i)
            {
                vector_append(cellpaths_to_prepend, strdup((const char*)vector_get(config_cellpaths_to_prepend, i)));
            }
        }
        if(hashmap_exists(config, "prepend_cellpaths"))
        {
            struct vector* config_cellpaths_to_append = hashmap_get(config, "append_cellpaths");
            for(unsigned int i = 0; i < vector_size(config_cellpaths_to_append); ++i)
            {
                vector_append(cellpaths_to_append, strdup((const char*)vector_get(config_cellpaths_to_append, i)));
            }
        }
        vector_append(cellpaths_to_append, strdup(OPC_HOME "/cells"));
        struct pcell_state* pcell_state = pcell_initialize_state(cellpaths_to_prepend, cellpaths_to_append);
        vector_destroy(cellpaths_to_prepend);
        vector_destroy(cellpaths_to_append);
        if(cmdoptions_was_provided_long(cmdoptions, "list"))
        {
            const char* listformat = cmdoptions_get_argument_long(cmdoptions, "list-format");
            pcell_list_cells(pcell_state, listformat);
        }
        if(cmdoptions_was_provided_long(cmdoptions, "listcellpaths"))
        {
            pcell_list_cellpaths(pcell_state);
        }
        pcell_destroy_state(pcell_state);
        goto DESTROY_CONFIG;
    }

    if(cmdoptions_was_provided_long(cmdoptions, "parameters"))
    {
        main_list_cell_parameters(cmdoptions, config);
        goto DESTROY_CONFIG;
    }

    // create cell
    int create_cell_script = cmdoptions_was_provided_long(cmdoptions, "cellscript");
    if(cmdoptions_was_provided_long(cmdoptions, "cell") || create_cell_script)
    {
        if(!cmdoptions_was_provided_long(cmdoptions, "technology"))
        {
            fputs("no technology given\n", stderr);
            goto DESTROY_CONFIG;
        }
        if(!cmdoptions_was_provided_long(cmdoptions, "export"))
        {
            fputs("no export given\n", stderr);
            goto DESTROY_CONFIG;
        }
        int ret = main_create_and_export_cell(cmdoptions, config, create_cell_script); // 0: regular cell, 1: cellscript
        if(!ret)
        {
            returnvalue = 1;
        }
        goto DESTROY_CONFIG;
    }

    // should not reach here
    fputs("no cell given\n", stderr);
    returnvalue = 1;

    if(pfd_f)
    {
        fclose(pfd_f);
    }

    // clean up states
DESTROY_CONFIG: ;
    {
        struct vector* techpaths = hashmap_get(config, "techpaths");
        vector_destroy(techpaths);
        struct vector* prepend_cellpaths = hashmap_get(config, "prepend_cellpaths");
        vector_destroy(prepend_cellpaths);
        struct vector* append_cellpaths = hashmap_get(config, "append_cellpaths");
        vector_destroy(append_cellpaths);
        struct vector* ignoredlayers = hashmap_get(config, "ignoredlayers");
        vector_destroy(ignoredlayers);
    }
    hashmap_destroy(config, NULL);
DESTROY_CMDOPTIONS:
    cmdoptions_destroy(cmdoptions);
    return returnvalue;
}

