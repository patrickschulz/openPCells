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
#include "ltransformationmatrix.h"
#include "graphics.h"
#include "lload.h"
#include "lbind.h"
#include "ldir.h"
#include "lbinary.h"
#include "lobject.h"
#include "pcell.h"
#include "info.h"
#include "export.h"
#include "postprocess.h"
//#include "lunion.h"
#include "lfilesystem.h"
#include "lplacer.h"
#include "lrouter.h"
#include "lutil.h"
#include "util.h"
#include "gdsparser.h"

#include "config.h"

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
static int msghandler (lua_State *L) {
  const char *msg = lua_tostring(L, 1);
  if (msg == NULL) {  /* is error object not a string? */
    if (luaL_callmeta(L, 1, "__tostring") &&  /* does it have a metamethod */
        lua_type(L, -1) == LUA_TSTRING)  /* that produces a string? */
      return 1;  /* that is the message */
    else
      msg = lua_pushfstring(L, "(error object is a %s value)",
                               luaL_typename(L, 1));
  }
  luaL_traceback(L, L, msg, 1);  /* append a standard traceback */
  return 1;  /* return the traceback */
}

static void create_argument_table(lua_State* L, int argc, const char* const * argv)
{
    lua_newtable(L);
    int i;
    for(i = 1; i < argc; ++i)
    {
        lua_pushstring(L, argv[i]);
        lua_rawseti(L, -2, i);
    }
    lua_setglobal(L, "arg");
}

static int call_main_program(lua_State* L, const char* filename)
{
    int status = luaL_loadfile(L, filename);
    if (status == LUA_OK) {
        lua_pushcfunction(L, msghandler);
        lua_insert(L, 1);
        status = lua_pcall(L, 0, 1, 1);
    }
    if(status != LUA_OK) 
    {
        const char* msg = lua_tostring(L, -1);
        fprintf(stderr, "%s\n", msg);
        lua_pop(L, 1);
        return LUA_ERRRUN;
    }
    return LUA_OK;
}

static lua_State* create_and_initialize_lua(void)
{
    lua_State* L = util_create_basic_lua_state();

    // opc libraries
    open_ldir_lib(L);
    open_lpoint_lib(L); // must be called before 'load_api'
    open_lgeometry_lib(L);
    open_lgenerics_lib(L);
    open_ltechnology_lib(L);
    open_ltransformationmatrix_lib(L); // must be called before 'load_api'
    open_lgraphics_lib(L);
    open_lload_lib(L);
    open_lbind_lib(L);
    open_lbinary_lib(L);
    open_lobject_lib(L);
    open_lpcell_lib(L);
    open_lutil_lib(L);
    open_lfilesystem_lib(L);
    open_lplacer_lib(L);
    open_lrouter_lib(L);
    open_info_lib(L);

    open_gdsparser_lib(L);

    return L;
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

    // create and parse command line options
    struct cmdoptions* cmdoptions = cmdoptions_create();
    #include "cmdoptions_def.c" // yes, I did that
    if(!cmdoptions_parse(cmdoptions, argc, argv))
    {
        return 1;
    }

    // show gds data
    if(cmdoptions_was_provided_long(cmdoptions, "show-gds-data"))
    {
        const char* arg = cmdoptions_get_argument_long(cmdoptions, "show-gds-data");
        int ret = gdsparser_show_records(arg);
        if(!ret)
        {
            cmdoptions_exit(cmdoptions, 1);
        }
        cmdoptions_exit(cmdoptions, 0);
    }

    // technology file generation assistant
    if(cmdoptions_was_provided_long(cmdoptions, "techfile-assistant"))
    {
        lua_State* L = util_create_basic_lua_state();
        int retval = call_main_program(L, OPC_HOME "/src/assistant.lua");
        cmdoptions_exit(cmdoptions, 0);
    }

    lua_State* L = create_and_initialize_lua();
    create_argument_table(L, argc, argv);

    // create layermap
    struct layermap* layermap = generics_initialize_layer_map();
    lua_pushlightuserdata(L, layermap);
    lua_setfield(L, LUA_REGISTRYINDEX, "genericslayermap");

    // create technology state
    if(!cmdoptions_was_provided_long(cmdoptions, "technology"))
    {
        puts("no technology given");
        cmdoptions_exit(cmdoptions, 0);
    }
    struct technology_state* techstate = technology_initialize();

    struct keyvaluearray* config = keyvaluearray_create();
    if(!cmdoptions_was_provided_long(cmdoptions, "no-user-config"))
    {
        if(!_load_config(config))
        {
            puts("error while loading user config");
            return 1;
        }
    }

    // add technology search paths
    technology_add_techpath(techstate, OPC_HOME "/tech");
    if(cmdoptions_was_provided_long(cmdoptions, "techpath"))
    {
        const char** arg = cmdoptions_get_argument_long(cmdoptions, "techpath");
        while(*arg)
        {
            technology_add_techpath(techstate, *arg);
            ++arg;
        }
    }
    // add techpaths from config file
    struct vector* techpaths = keyvaluearray_get(config, "techpaths");
    for(unsigned int i = 0; i < vector_size(techpaths); ++i)
    {
        technology_add_techpath(techstate, vector_get(techpaths, i));
    }

    // load technology and store in lua registry
    const char* techname = cmdoptions_get_argument_long(cmdoptions, "technology");
    technology_load(techstate, techname);
    lua_pushlightuserdata(L, techstate);
    lua_setfield(L, LUA_REGISTRYINDEX, "techstate");

    // create pcell references FIXME: remove global variable
    pcell_initialize_references();

    // create cell
    int retval = call_main_program(L, OPC_HOME "/src/main.lua");
    if(retval != LUA_OK)
    {
        // clean up states
        generics_destroy_layer_map(layermap);
        technology_destroy(techstate);
        pcell_destroy_references();
        cmdoptions_destroy(cmdoptions);
        lua_close(L);
        return 1;
    }
    object_t* toplevel = lobject_check(L, -1)->object;

    // flatten cell
    if(cmdoptions_was_provided_long(cmdoptions, "flat"))
    {
        int flattenports = cmdoptions_was_provided_long(cmdoptions, "flattenports");
        object_flatten(toplevel, flattenports);
    }

    // post-processing
    if(cmdoptions_was_provided_long(cmdoptions, "merge-rectangles"))
    {
        postprocess_merge_shapes(toplevel, layermap);
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
        export_write_toplevel(toplevel, exportname, basename, toplevelname, leftdelim, rightdelim, exportoptions, writechildrenports);
    }
    else
    {
        puts("no export type given");
    }

    // clean up states
    generics_destroy_layer_map(layermap);
    technology_destroy(techstate);
    pcell_destroy_references();
    cmdoptions_destroy(cmdoptions);
    lua_close(L);

    return 0;
}

