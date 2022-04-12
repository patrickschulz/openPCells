#include "main.gds.h"

#include <stdlib.h>

#include "main.functions.h"
#include "util.h"
#include "gdsparser.h"
#include "lfilesystem.h"
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
    lua_State* L = util_create_basic_lua_state();
    open_gdsparser_lib(L);
    open_lfilesystem_lib(L);
    main_load_lua_module(L, "gdsparser");
    module_load_envlib(L);
    if(!lua_isnil(L, -1))
    {
        lua_setglobal(L, "envlib");
    }
    main_load_lua_module(L, "import");
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

    const char* importlibname = cmdoptions_get_argument_long(cmdoptions, "import-libname");
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
}
