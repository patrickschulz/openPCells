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
#include "geometry.h"

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
    if(status == LUA_OK)
    {
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
    open_lpoint_lib(L);
    open_lgeometry_lib(L);
    open_lgenerics_lib(L);
    open_ltechnology_lib(L);
    open_ltransformationmatrix_lib(L);
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

    open_gdsparser_lib(L);

    return L;
}

static void _load_module(lua_State* L, const char* modname)
{
    size_t len = strlen(OPC_HOME) + strlen(modname) + 9; // +9: "/src/" + ".lua"
    char* path = malloc(len + 1);
    snprintf(path, len + 1, "%s/src/%s.lua", OPC_HOME, modname);
    call_main_program(L, path);
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

    // read gds
    if(cmdoptions_was_provided_long(cmdoptions, "read-gds"))
    {
        const char* arg = cmdoptions_get_argument_long(cmdoptions, "read-gds");
        lua_State* L = util_create_basic_lua_state();
        open_gdsparser_lib(L);
        open_lfilesystem_lib(L);
        _load_module(L, "gdsparser");
        _load_module(L, "envlib");
        _load_module(L, "import");
        lua_newtable(L);
        lua_pushstring(L, arg);
        lua_setfield(L, -2, "readgds");
        lua_setglobal(L, "args");
        call_main_program(L, OPC_HOME "/src/scripts/read_gds.lua");
        lua_close(L);
        cmdoptions_exit(cmdoptions, 0);
    }

    // technology file generation assistant
    if(cmdoptions_was_provided_long(cmdoptions, "techfile-assistant"))
    {
        lua_State* L = util_create_basic_lua_state();
        call_main_program(L, OPC_HOME "/src/scripts/assistant.lua");
        lua_close(L);
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

    // move origin
    if(cmdoptions_was_provided_long(cmdoptions, "origin"))
    {
        const char* arg = cmdoptions_get_argument_long(cmdoptions, "origin");
        int x, y;
        if(!_parse_point(arg, &x, &y))
        {
            printf("could not parse translation '%s'\n", arg);
        }
        else
        {
            object_move_to(toplevel, x, y);
        }
    }

    // translate
    if(cmdoptions_was_provided_long(cmdoptions, "translate"))
    {
        const char* arg = cmdoptions_get_argument_long(cmdoptions, "translate");
        int dx, dy;
        if(!_parse_point(arg, &dx, &dy))
        {
            printf("could not parse translation '%s'\n", arg);
        }
        else
        {
            object_translate(toplevel, dx, dy);
        }
    }

    // orientation
    //if args.orientation then
    //    local lut = {
    //        ["0"] = function() end, -- do nothing, but allow this as command line option
    //        ["fx"] = function() cell:flipx() end,
    //        ["fy"] = function() cell:flipy() end,
    //        ["fxy"] = function() cell:flipx(); cell:flipy() end,
    //    }
    //    local f = lut[args.orientation]
    //    if not f then
    //        moderror(string.format("unknown orientation: '%s'", args.orientation))
    //    end
    //    f()
    //end

    // draw anchors
    //if args.drawanchor then
    //    for _, da in ipairs(args.drawanchor) do
    //        local anchor = cell:get_anchor(da)
    //        cell:merge_into_shallow(marker.cross(anchor))
    //    end
    //end

    // draw alignmentbox(es)
    if(cmdoptions_was_provided_long(cmdoptions, "draw-alignmentbox") || cmdoptions_was_provided_long(cmdoptions, "draw-all-alignmentboxes"))
    {
        point_t* bl = object_get_anchor(toplevel, "bottomleft");
        point_t* tr = object_get_anchor(toplevel, "topright");
        if(bl && tr)
        {
            geometry_rectanglebltr(toplevel, generics_create_special(layermap, techstate), bl, tr, 1, 1, 0, 0);
            point_destroy(bl);
            point_destroy(tr);
        }
    }
    if(cmdoptions_was_provided_long(cmdoptions, "draw-all-alignmentboxes"))
    {
        for(unsigned int i = 0; i < pcell_get_reference_count(); ++i)
        {
            object_t* cell = pcell_get_indexed_cell_reference(i)->cell;
            point_t* bl = object_get_anchor(cell, "bottomleft");
            point_t* tr = object_get_anchor(cell, "topright");
            if(bl && tr)
            {
                geometry_rectanglebltr(cell, generics_create_special(layermap, techstate), bl, tr, 1, 1, 0, 0);
                point_destroy(bl);
                point_destroy(tr);
            }
        }
    }

    // flatten cell
    if(cmdoptions_was_provided_long(cmdoptions, "flat"))
    {
        int flattenports = cmdoptions_was_provided_long(cmdoptions, "flattenports");
        object_flatten(toplevel, flattenports);
    }

    // post-processing
    if(cmdoptions_was_provided_long(cmdoptions, "filter-layers"))
    {
        const char** layernames = cmdoptions_get_argument_long(cmdoptions, "filter-layers");
        if(cmdoptions_was_provided_long(cmdoptions, "filter-list") &&
           strcmp(cmdoptions_get_argument_long(cmdoptions, "filter-list"), "include") == 0)
        {
            postprocess_filter_include(toplevel, layernames);
            for(unsigned int i = 0; i < pcell_get_reference_count(); ++i)
            {
                object_t* cell = pcell_get_indexed_cell_reference(i)->cell;
                postprocess_filter_include(cell, layernames);
            }
        }
        else
        {
            postprocess_filter_exclude(toplevel, layernames);
            for(unsigned int i = 0; i < pcell_get_reference_count(); ++i)
            {
                object_t* cell = pcell_get_indexed_cell_reference(i)->cell;
                postprocess_filter_exclude(cell, layernames);
            }
        }
    }
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

    // cell info
    if(cmdoptions_was_provided_long(cmdoptions, "show-cellinfo"))
    {
       info_cellinfo(toplevel);
    }

    // clean up states
    generics_destroy_layer_map(layermap);
    technology_destroy(techstate);
    pcell_destroy_references();
    cmdoptions_destroy(cmdoptions);
    vector_destroy(techpaths, free); // every techpath is a copied string
    keyvaluearray_destroy(config);
    lua_close(L);

    return 0;
}

