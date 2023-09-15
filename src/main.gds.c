#include "main.gds.h"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "main.functions.h"
#include "lua_util.h"
#include "gdsparser.h"

#include "scriptmanager.h"
#include "modulemanager.h"

void main_gds_show_data(struct cmdoptions* cmdoptions)
{
    const char* arg = cmdoptions_get_argument_long(cmdoptions, "show-gds-data");
    int raw = cmdoptions_was_provided_long(cmdoptions, "show-gds-data-raw");
    int ret = gdsparser_show_records(arg, raw);
    if(!ret)
    {
        // FIXME
    }
}

void main_gds_show_cell_hierarchy(struct cmdoptions* cmdoptions)
{
    lua_State* L = util_create_basic_lua_state();
    open_gdsparser_lib(L);
    module_load_gdsparser(L);
    if(!lua_isnil(L, -1))
    {
        lua_setglobal(L, "gdsparser");
    }
    module_load_aux(L);
    if(!lua_isnil(L, -1))
    {
        lua_setglobal(L, "aux");
    }
    const char* filename = cmdoptions_get_argument_long(cmdoptions, "show-gds-cell-hierarchy");
    lua_pushstring(L, filename);
    lua_setglobal(L, "filename");
    int depth = atoi(cmdoptions_get_argument_long(cmdoptions, "show-gds-depth"));
    lua_pushinteger(L, depth);
    lua_setglobal(L, "depth");
    script_call_show_gds_hierarchy(L);
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
            if(!importlibname)
            {
                fputs("memory allocation error\n", stderr);
                return;
            }
            strncpy(importlibname, readgds, len);
            importlibname[len] = 0;
            must_free = 1;
        }
    }
    const char* gdslayermapfile = cmdoptions_get_argument_long(cmdoptions, "gds-layermap");
    struct vector* gdslayermap = gdsparser_create_layermap(gdslayermapfile);
    struct vector* ignorelpp = vector_create(1, free);
    if(cmdoptions_was_provided_long(cmdoptions, "gds-ignore-lpp"))
    {
        const char** lppstrs = cmdoptions_get_argument_long(cmdoptions, "gds-ignore-lpp");
        while(*lppstrs)
        {
            const char* lppstr = *lppstrs;
            char* ptr;
            int16_t* lpp = malloc(2 * sizeof(*lpp));
            lpp[0] = strtol(lppstr, &ptr, 10);
            lpp[1] = strtol(ptr + 1, NULL, 10);
            vector_append(ignorelpp, lpp);
            ++lppstrs;
        }
    }
    int16_t* ablayer = NULL;
    if(cmdoptions_was_provided_long(cmdoptions, "gds-alignmentbox-layer"))
    {
        ablayer = malloc(sizeof(*ablayer));
        *ablayer = strtol(cmdoptions_get_argument_long(cmdoptions, "gds-alignmentbox-layer"), NULL, 10);
    }
    int16_t* abpurpose = NULL;
    if(cmdoptions_was_provided_long(cmdoptions, "gds-alignmentbox-purpose"))
    {
        abpurpose = malloc(sizeof(*abpurpose));
        *abpurpose = strtol(cmdoptions_get_argument_long(cmdoptions, "gds-alignmentbox-purpose"), NULL, 10);
    }
    int ret = gdsparser_read_stream(readgds, importlibname, gdslayermap, ignorelpp, ablayer, abpurpose);
    if(must_free)
    {
        free(importlibname);
    }
    if(!ret)
    {
        printf("could not read stream file '%s'\n", readgds);
    }
    gdsparser_destroy_layermap(gdslayermap);
    vector_destroy(ignorelpp);
    if(ablayer)
    {
        free(ablayer);
    }
    if(abpurpose)
    {
        free(abpurpose);
    }
}
