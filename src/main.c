#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "lua/lua.h"
#include "lua/lauxlib.h"

#include "cmdoptions.h"
#include "config.h"
#include "filesystem.h"
#include "hashmap.h"
#include "lua_util.h"
#include "pcell.h"
#include "scriptmanager.h"
#include "util.h"
#include "version.h"

#include "main.api_help.h"
#include "main.cell.h"
#include "main.functions.h"
#include "main.gds.h"
#include "main.tutorial.h"
#include "main.verilog.h"

static int _load_config(struct hashmap* config)
{
    /* prepare config */
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
        return 1; /* non-existing user config is not an error */
    }
    lua_State* L = util_create_basic_lua_state();
    int ret = luaL_dofile(L, filename);
    free(filename);
    if(ret == LUA_OK)
    {
        /* techpaths */
        techpaths = hashmap_get(config, "techpaths");
        lua_getfield(L, -1, "techpaths");
        if(!lua_isnil(L, -1))
        {
            lua_pushnil(L);
            while(lua_next(L, -2) != 0)
            {
                const char* path = lua_tostring(L, -1);
                vector_append(techpaths, util_strdup(path));
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
                vector_append(prepend_cellpaths, util_strdup(path));
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
                vector_append(append_cellpaths, util_strdup(path));
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
    printf("This is the openPCell layout generator (opc), version %u.%u.%u.\n", OPC_VERSION_MAJOR, OPC_VERSION_MINOR, OPC_VERSION_REVISION);
    puts("Copyright 2020-2025 Patrick Kurth");
    puts("");
    puts("To generate a layout, you need to pass the technology,");
    puts("the export type and a cellname or the name of a cellscript.");
    puts("Example:");
    puts("         opc --technology opc --export gds --cell stdcells/not_gate");
    puts("         opc --technology opc --export gds --cellscript script.lua");
    puts("");
    puts("You can find out more about the available command line options by running 'opc -h'.");
}

#include "modulemanager.h"

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
    cmdoptions_disable_narrow_mode(cmdoptions);
    #include "cmdoptions_def.c" // yes, I did that

    // Help Header
    const char* helpheader_first_part = "openPCells layout generator (opc) version";
    const char* helpheader_second_part = "- Patrick Kurth 2020 - 2025";
    size_t helpheader_size = 
        strlen(helpheader_first_part) + strlen(helpheader_second_part) +
        2 + // extra white space
        util_num_digits(OPC_VERSION_MAJOR) + 1 +
        util_num_digits(OPC_VERSION_MINOR) + 1 +
        util_num_digits(OPC_VERSION_REVISION) +
        1 // terminating zero
        ;
    char* helpheader_with_version = malloc(helpheader_size);
    snprintf(helpheader_with_version, helpheader_size, "%s %u.%u.%u %s", helpheader_first_part, OPC_VERSION_MAJOR, OPC_VERSION_MINOR, OPC_VERSION_REVISION, helpheader_second_part);
    cmdoptions_prepend_help_message(cmdoptions, helpheader_with_version);
    free(helpheader_with_version);
    cmdoptions_prepend_help_message(cmdoptions, "");
    cmdoptions_prepend_help_message(cmdoptions, "Generate layouts of integrated circuit geometry");
    cmdoptions_prepend_help_message(cmdoptions, "opc supports technology-independent descriptions of parametric layout cells (pcells),");
    cmdoptions_prepend_help_message(cmdoptions, "which can be translated into a physical technology and exported to a file via a specific export.");

    // Help Footer
    cmdoptions_append_help_message(cmdoptions, "");
    cmdoptions_append_help_message(cmdoptions, "Most common usage examples:");
    cmdoptions_append_help_message(cmdoptions, "   get cell parameter information:             opc --cell stdcells/dff --parameters");
    cmdoptions_append_help_message(cmdoptions, "   create a cell:                              opc --technology TECH --export gds --cell stdcells/dff");
    cmdoptions_append_help_message(cmdoptions, "   create a cell from a foreign collection:    opc --cellpath /path/to/collection --technology TECH --export gds --cell other/somecell");
    cmdoptions_append_help_message(cmdoptions, "   create a cell by using a cellscript:        opc --technology TECH --export gds --cellscript celldef.lua");
    cmdoptions_append_help_message(cmdoptions, "   read a GDS stream file and create cells:    opc --read-GDS stream.gds");

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
        printf("openPCells (opc) %u.%u.%u\n", OPC_VERSION_MAJOR, OPC_VERSION_MINOR, OPC_VERSION_REVISION);
        goto DESTROY_CMDOPTIONS;
    }
    FILE* fstdout = NULL;
    if(cmdoptions_was_provided_long(cmdoptions, "stdout-to"))
    {
        const char* stdoutto = cmdoptions_get_argument_long(cmdoptions, "stdout-to");
        fstdout = fopen(stdoutto, "w");
        int pfd = fileno(fstdout);
        dup2(pfd, STDOUT_FILENO);
    }
    FILE* fstderr = NULL;
    if(cmdoptions_was_provided_long(cmdoptions, "stderr-to"))
    {
        const char* stderrto = cmdoptions_get_argument_long(cmdoptions, "stderr-to");
        fstderr = fopen(stderrto, "w");
        int pfd = fileno(fstderr);
        dup2(pfd, STDERR_FILENO);
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

    /* templates */
    if(cmdoptions_was_provided_long(cmdoptions, "template"))
    {
        const char* template_name = cmdoptions_get_argument_long(cmdoptions, "template");
        lua_State* L = util_create_basic_lua_state();
        lua_pushstring(L, template_name);
        lua_setglobal(L, "template");
        script_call_templates(L);
        const char* content = lua_tostring(L, -1);
        if(!content)
        {
            printf("template '%s' not found\n", template_name);
        }
        else
        {
            printf("%s\n", content);
        }
        lua_close(L);
        goto DESTROY_CMDOPTIONS;
    }

    /* templates (auto) */
    if(cmdoptions_was_provided_long(cmdoptions, "template-auto"))
    {
        const char* template_name = cmdoptions_get_argument_long(cmdoptions, "template-auto");
        lua_State* L = util_create_basic_lua_state();
        lua_pushstring(L, template_name);
        lua_setglobal(L, "template");
        script_call_templates(L);
        const char* content = lua_tostring(L, -1);
        if(!content)
        {
            printf("local cell = pcell.create_layout(\"%s\", \"_cell\", {\n", template_name);
            main_list_cell_parameters(template_name, "    %n = %v,", NULL, cmdoptions, config);
            puts("})");
        }
        else
        {
            printf("%s\n", content);
        }
        lua_close(L);
        goto DESTROY_CMDOPTIONS;
    }

    if(cmdoptions_was_provided_long(cmdoptions, "api-help"))
    {
        const char* funcname = cmdoptions_get_argument_long(cmdoptions, "api-help");
        main_API_help(funcname);
        goto DESTROY_CMDOPTIONS;
    }
    if(cmdoptions_was_provided_long(cmdoptions, "api-search"))
    {
        const char* funcname = cmdoptions_get_argument_long(cmdoptions, "api-search");
        main_API_search(funcname);
        goto DESTROY_CMDOPTIONS;
    }
    if(cmdoptions_was_provided_long(cmdoptions, "api-list"))
    {
        main_API_list();
        goto DESTROY_CMDOPTIONS;
    }
    if(cmdoptions_was_provided_long(cmdoptions, "generate-tutorial"))
    {
        main_generate_tutorial();
        goto DESTROY_CMDOPTIONS;
    }

    if(cmdoptions_was_provided_long(cmdoptions, "import-verilog"))
    {
        const char* scriptname = cmdoptions_get_argument_long(cmdoptions, "import-verilog");
        const char** ptr = cmdoptions_get_positional_parameters(cmdoptions);
        const struct const_vector* args = const_vector_adapt_from_pointer_array((void**)ptr);
        main_verilog_import(scriptname, args);
        goto DESTROY_CMDOPTIONS;
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
        vector_append(ignoredlayers, util_strdup("gatecut"));
    }
    if(cmdoptions_was_provided_long(cmdoptions, "ignore-layer"))
    {
        struct vector* ignoredlayers = hashmap_get(config, "ignoredlayers");
        const char* const* layernames = cmdoptions_get_argument_long(cmdoptions, "ignore-layer");
        while(*layernames)
        {
            vector_append(ignoredlayers, util_strdup(*layernames));
            ++layernames;
        }
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

    // show gds cell definitions
    if(cmdoptions_was_provided_long(cmdoptions, "show-gds-cell-definitions"))
    {
        main_gds_show_cell_definitions(cmdoptions);
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

    // list tech paths
    if(cmdoptions_was_provided_long(cmdoptions, "list-techpaths"))
    {
        printf("%s\n", OPC_TECH_PATH "/tech");
        const char* const* arg = cmdoptions_get_argument_long(cmdoptions, "techpath");
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
    if(cmdoptions_was_provided_long(cmdoptions, "list-cellpaths") ||
       cmdoptions_was_provided_long(cmdoptions, "list"))
    {
        main_list_cells_cellpaths(cmdoptions, config);
        goto DESTROY_CONFIG;
    }

    // cell parameters
    if(cmdoptions_was_provided_long(cmdoptions, "parameters"))
    {
        // cell name
        const char* cellname = cmdoptions_get_argument_long(cmdoptions, "parameters");
        // parameter format
        const char* parametersformat = cmdoptions_get_argument_long(cmdoptions, "parameters-format");
        // parameter names
        const char** parameternames = cmdoptions_get_positional_parameters(cmdoptions);
        main_list_cell_parameters(cellname, parametersformat, parameternames, cmdoptions, config);
        goto DESTROY_CONFIG;
    }

    // cell anchors (FIXME: broken)
    if(cmdoptions_was_provided_long(cmdoptions, "anchors"))
    {
        main_list_cell_anchors(cmdoptions, config);
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

    if(fstdout)
    {
        fclose(fstdout);
    }
    if(fstderr)
    {
        fclose(fstderr);
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

