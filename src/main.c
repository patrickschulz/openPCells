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

#include <signal.h>

#include "lua/lua.h"
#include "lua/lauxlib.h"
#include "lua/lualib.h"

#include <math.h>
#include <ctype.h>
#include <string.h>

#include "cmdoptions.h"

#include "lpoint.h"
#include "lgeometry.h"
#include "lgenerics.h"
#include "technology.h"
#include "graphics.h"
#include "lload.h"
#include "lbind.h"
#include "ldir.h"
#include "lobject.h"
#include "pcell.h"
#include "info.h"
#include "export.h"
#include "postprocess.h"
//#include "lunion.h"
#include "lfilesystem.h"
#include "lplacer.h"
#include "lrouter.h"
#include "util.h"
#include "gdsparser.h"
#include "geometry.h"

#include "config.h"

#include "main.functions.h"

//static lua_State* globalL = NULL;

/*
** Hook set by signal function to stop the interpreter.
*/
//static void lstop (lua_State* L, lua_Debug* ar) {
//  (void)ar;  /* unused arg. */
//  lua_sethook(L, NULL, 0, 0);  /* reset hook */
//  luaL_error(L, "interrupted!");
//}


/*
** Function to be called at a C signal. Because a C signal cannot
** just change a Lua state (as there is no proper synchronization),
** this function only sets a hook that, when called, will stop the
** interpreter.
*/
//static void laction (int i) {
//  int flag = LUA_MASKCALL | LUA_MASKRET | LUA_MASKLINE | LUA_MASKCOUNT;
//  signal(i, SIG_DFL); /* if another SIGINT happens, terminate process */
//  lua_sethook(globalL, lstop, flag, 1);
//}


/*
** Message handler used to run all chunks
*/
//static int msghandler(lua_State* L)
//{
//    const char* msg = lua_tostring(L, 1);
//    /*
//    if (msg == NULL) // is error object not a string?
//    {
//        msg = lua_pushfstring(L, "(error object is a %s value)", luaL_typename(L, 1));
//    }
//    */
//    int traceback = 1;
//    lua_getglobal(L, "envlib");
//    lua_pushstring(L, "get");
//    lua_gettable(L, -2);
//    lua_pushstring(L, "debug");
//    int ret = lua_pcall(L, 1, 1, 0);
//    if(ret != LUA_OK)
//    {
//        printf("%s\n", "error in msghandler (while calling envlib.get('debug'). A traceback will be printed");
//    }
//    else
//    {
//        traceback = lua_toboolean(L, -1);
//    }
//    lua_pop(L, 1); // pop envlib
//
//    if(traceback)
//    {
//        luaL_traceback(L, L, msg, 2);
//    }
//    else
//    {
//        lua_pushstring(L, msg);
//    }
//    return 1;
//}

static void _load_module(lua_State* L, const char* modname)
{
    size_t len = strlen(OPC_HOME) + strlen(modname) + 9; // +9: "/src/" + ".lua"
    char* path = malloc(len + 1);
    snprintf(path, len + 1, "%s/src/%s.lua", OPC_HOME, modname);
    main_call_lua_program(L, path);
    free(path);
}

static int _parse_point(const char* arg, int* xptr, int* yptr)
{
    unsigned int idx1, idx2;
    const char* ptr = arg;
    while(*ptr)
    {
        if(*ptr == '(')
        {
            idx1 = ptr - arg;
        }
        if(*ptr == ',')
        {
            idx2 = ptr - arg;
        }
        ++ptr;
    }
    char* endptr;
    int x = strtol(arg + idx1 + 1, &endptr, 10);
    if(endptr == arg + idx1 + 1)
    {
        return 0;
    }
    int y = strtol(arg + idx2 + 1, &endptr, 10);
    if(endptr == arg + idx2 + 1)
    {
        return 0;
    }
    *xptr = x;
    *yptr = y;
    return 1;
}

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
        lua_pushnil(L);
        while(lua_next(L, -2) != 0)
        {
            const char* path = lua_tostring(L, -1);
            vector_append(techpaths, util_copy_string(path));
            lua_pop(L, 1);
        }
        keyvaluearray_add_untagged(config, "techpaths", techpaths);
    }
    lua_close(L);
    return ret == LUA_OK;
}

int main(int argc, const char* const * argv)
{
    // no arguments: exit and write a short helpful message if called without any arguments
    if(argc == 1)
    {
        puts("This is the openPCell layout generator.");
        puts("To generate a layout, you need to pass the technology, the export type and a cellname.");
        puts("Example:");
        puts("         opc --technology skywater130 --export gds --cell logic/not_gate");
        puts("");
        puts("You can find out more about the available command line options by running 'opc -h'.");
        return 0;
    }

    int returnvalue = 0;

    // create and parse command line options
    struct cmdoptions* cmdoptions = cmdoptions_create();
    //cmdoptions_enable_narrow_mode(cmdoptions);
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
        const char* arg = cmdoptions_get_argument_long(cmdoptions, "show-gds-data");
        int ret = gdsparser_show_records(arg);
        if(!ret)
        {
            returnvalue = 1;
        }
        goto DESTROY_CONFIG;
    }

    // show gds hierarchy
    if(cmdoptions_was_provided_long(cmdoptions, "show-gds-cell-hierarchy"))
    {
        lua_State* L = util_create_basic_lua_state();
        open_gdsparser_lib(L);
        _load_module(L, "gdsparser");
        _load_module(L, "aux");
        const char* filename = cmdoptions_get_argument_long(cmdoptions, "show-gds-cell-hierarchy");
        lua_pushstring(L, filename);
        lua_setglobal(L, "filename");
        lua_pushinteger(L, 1000);
        int depth = atoi(cmdoptions_get_argument_long(cmdoptions, "show-gds-depth"));
        lua_pushinteger(L, depth);
        lua_setglobal(L, "depth");
        main_call_lua_program(L, OPC_HOME "/src/scripts/show_gds_hierarchy.lua");
        lua_close(L);
        goto DESTROY_CONFIG;
    }

    // read gds
    if(cmdoptions_was_provided_long(cmdoptions, "read-gds"))
    {
        lua_State* L = util_create_basic_lua_state();
        open_gdsparser_lib(L);
        open_lfilesystem_lib(L);
        _load_module(L, "gdsparser");
        _load_module(L, "envlib");
        _load_module(L, "import");
        lua_newtable(L);

        const char* readgds = cmdoptions_get_argument_long(cmdoptions, "read-gds");
        lua_pushstring(L, readgds);
        lua_setfield(L, -2, "readgds");

        const char* gdslayermap = cmdoptions_get_argument_long(cmdoptions, "gds-layermap");
        if(gdslayermap)
        {
            lua_pushstring(L, gdslayermap);
            lua_setfield(L, -2, "gdslayermap");
        }

        const char* gdsalignmentboxlayer = cmdoptions_get_argument_long(cmdoptions, "gds-alignmentbox-layer");
        if(gdsalignmentboxlayer)
        {
            lua_pushstring(L, gdsalignmentboxlayer);
            lua_setfield(L, -2, "gdsalignmentboxlayer");
        }

        const char* gdsalignmentboxpurpose = cmdoptions_get_argument_long(cmdoptions, "gds-alignmentbox-purpose");
        if(gdsalignmentboxpurpose)
        {
            lua_pushstring(L, gdsalignmentboxpurpose);
            lua_setfield(L, -2, "gdsalignmentboxpurpose");
        }

        int gdsusestreamlibname = cmdoptions_was_provided_long(cmdoptions, "gds-use-libname");
        lua_pushboolean(L, gdsusestreamlibname);
        lua_setfield(L, -2, "gdsusestreamlibname");

        int importoverwrite = cmdoptions_was_provided_long(cmdoptions, "import-overwrite");
        lua_pushboolean(L, importoverwrite);
        lua_setfield(L, -2, "importoverwrite");

        const char* importlibname = cmdoptions_get_argument_long(cmdoptions, "gds-alignmentbox-purpose");
        if(importlibname)
        {
            lua_pushstring(L, importlibname);
            lua_setfield(L, -2, "importlibname");
        }

        const char* importnamepattern = cmdoptions_get_argument_long(cmdoptions, "import-name-pattern");
        if(importnamepattern)
        {
            lua_pushstring(L, importnamepattern);
            lua_setfield(L, -2, "importnamepattern");
        }

        const char* importprefix = cmdoptions_get_argument_long(cmdoptions, "import-prefix");
        if(importprefix)
        {
            lua_pushstring(L, importprefix);
            lua_setfield(L, -2, "importprefix");
        }

        const char* importflatpattern = cmdoptions_get_argument_long(cmdoptions, "import-flatten-cell-pattern");
        if(importflatpattern)
        {
            lua_pushstring(L, importflatpattern);
            lua_setfield(L, -2, "importflatpattern");
        }

        const char* const * gdsignorelpp = cmdoptions_get_argument_long(cmdoptions, "gds-ignore-lpp");
        if(gdsignorelpp)
        {
            lua_newtable(L);
            const char* const * ptr = gdsignorelpp;
            while(*ptr)
            {
                lua_pushstring(L, *ptr);
                lua_rawseti(L, -2, ptr - gdsignorelpp + 1);
                ++ptr;
            }
            lua_setfield(L, -2, "gdsignorelpp");
        }

        lua_setglobal(L, "args");
        main_call_lua_program(L, OPC_HOME "/src/scripts/read_gds.lua");
        lua_close(L);
        goto DESTROY_CONFIG;
    }

    // technology file generation assistant
    if(cmdoptions_was_provided_long(cmdoptions, "techfile-assistant"))
    {
        lua_State* L = util_create_basic_lua_state();
        main_call_lua_program(L, OPC_HOME "/src/scripts/assistant.lua");
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

    // create cell
    object_t* toplevel = NULL;
    if(cmdoptions_was_provided_long(cmdoptions, "cell"))
    {
        struct vector* techpaths = keyvaluearray_get(config, "techpaths");
        vector_append(techpaths, util_copy_string(OPC_HOME "/tech"));
        if(cmdoptions_was_provided_long(cmdoptions, "techpath"))
        {
            const char** arg = cmdoptions_get_argument_long(cmdoptions, "techpath");
            while(*arg)
            {
                vector_append(techpaths, util_copy_string(*arg));
                ++arg;
            }
        }
        const char* techname = cmdoptions_get_argument_long(cmdoptions, "technology");
        struct technology_state* techstate = main_create_techstate(techpaths, techname);
        struct pcell_state* pcell_state = main_create_pcell_state();
        struct layermap* layermap = main_create_layermap();
        const char* cellname = cmdoptions_get_argument_long(cmdoptions, "cell");
        struct vector* cellargs = cmdoptions_get_positional_parameters(cmdoptions);
        toplevel = main_create_cell(cellname, cellargs, techstate, pcell_state, layermap);
        if(!toplevel)
        {
            returnvalue = 1;
            goto DESTROY_CONFIG;
        }
        // export cell
        if(cmdoptions_was_provided_long(cmdoptions, "export") || cmdoptions_was_provided_long(cmdoptions, "exportlayers"))
        {
            const char* exportname = cmdoptions_get_argument_long(cmdoptions, "exportlayers");
            if(!exportname)
            {
                exportname = cmdoptions_get_argument_long(cmdoptions, "export");
            }
            // add export search paths. FIXME: add --exportpath cmd option
            if(!generics_resolve_premapped_layers(layermap, exportname))
            {
                printf("no layer data for export type '%s' found", exportname);
            }
            export_add_path(OPC_HOME "/export");
            const char* basename = cmdoptions_get_argument_long(cmdoptions, "filename");
            const char* toplevelname = cmdoptions_get_argument_long(cmdoptions, "cellname");
            const char** exportoptions = cmdoptions_get_argument_long(cmdoptions, "export-options");
            int writechildrenports = cmdoptions_was_provided_long(cmdoptions, "write-children-ports");
            const char* delimiters = cmdoptions_get_argument_long(cmdoptions, "bus-delimiters");
            char leftdelim = '<';
            char rightdelim = '>';
            if(delimiters && delimiters[0] && delimiters[1])
            {
                leftdelim = delimiters[0];
                rightdelim = delimiters[1];
            }
            export_write_toplevel(toplevel, pcell_state, exportname, basename, toplevelname, leftdelim, rightdelim, exportoptions, writechildrenports);
            object_destroy(toplevel);
        }
        else
        {
            puts("no export type given");
        }
DESTROY_LAYER_MAP:
        generics_destroy_layer_map(layermap);
DESTROY_TECHNOLOGY:
        technology_destroy(techstate);
DESTROY_PCELL_STATE:
        pcell_destroy_state(pcell_state);
    }
    else if(cmdoptions_was_provided_long(cmdoptions, "cellscript"))
    {
        /*
        const char* cellscriptname = cmdoptions_get_argument_long(cmdoptions, "cellscript");
        int retval = main_call_lua_program(L, cellscriptname);
        if(retval != LUA_OK)
        {
            // clean up states
            generics_destroy_layer_map(layermap);
            technology_destroy(techstate);
            pcell_destroy_state(pcell_state);
            cmdoptions_destroy(cmdoptions);
            lua_close(L);
            return 1;
        }
        */
    }

    // cell info
    if(cmdoptions_was_provided_long(cmdoptions, "show-cellinfo"))
    {
       info_cellinfo(toplevel);
    }

    // clean up states
DESTROY_CONFIG:
    vector_destroy(keyvaluearray_get(config, "techpaths"), free); // every techpath is a copied string
    keyvaluearray_destroy(config);
DESTROY_CMDOPTIONS:
    cmdoptions_destroy(cmdoptions);

    return returnvalue;
}

