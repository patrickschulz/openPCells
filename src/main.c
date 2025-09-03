/*
 *  openPCells - main.c
 *  This file is the entry point into the program execution.
 *  int main() is defined here.
 *  Some general functionality is directly addressed in this file,
 *  other, more complex tasks (such as layout generation) are handled
 *  in other files (main.XXX.c, e.g. main.cell.c)
 */

#include <fcntl.h> // open()
#include <sys/stat.h> // S_IRUSR etc.
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "lua/lua.h"
#include "lua/lauxlib.h"

#include "_config.h"

#include "cmdoptions.h"
#include "filesystem.h"
#include "hashmap.h"
#include "lterminal.h"
#include "lua_util.h"
#include "pcell.h"
#include "tagged_value.h"
#include "util.h"
#include "version.h"

#include "main.api_help.h"
#include "main.assistant.h"
#include "main.cell.h"
#include "main.functions.h"
#include "main.gds.h"
#include "main.import.h"
#include "main.tutorial.h"

#include "_scriptmanager.h"
#include "_modulemanager.h"

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
    puts("");
    puts("A tutorial showing the usage of opc can be accessed by 'opc --tutorial'.");
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
    cmdoptions_append_help_message(cmdoptions, "    get cell parameter information:");
    cmdoptions_append_help_message(cmdoptions, "        opc --cell stdcells/dff --parameters");
    cmdoptions_append_help_message(cmdoptions, "    create a cell:");
    cmdoptions_append_help_message(cmdoptions, "        opc --technology TECH --export gds --cell stdcells/dff");
    cmdoptions_append_help_message(cmdoptions, "    create a cell from a foreign collection:");
    cmdoptions_append_help_message(cmdoptions, "        opc --cellpath /path/to/collection --technology TECH --export gds --cell other/somecell");
    cmdoptions_append_help_message(cmdoptions, "    create a cell by using a cellscript:");
    cmdoptions_append_help_message(cmdoptions, "        opc --technology TECH --export gds --cellscript celldef.lua");
    cmdoptions_append_help_message(cmdoptions, "    read a GDS stream file and create cells:");
    cmdoptions_append_help_message(cmdoptions, "        opc --read-GDS stream.gds");
    cmdoptions_append_help_message(cmdoptions, "");
    cmdoptions_append_help_message(cmdoptions, "For more information on a specific command-line option you can also pass this to --help, e.g. opc --help --read-gds");

    if(!cmdoptions_parse(cmdoptions, argc, argv))
    {
        returnvalue = 1;
        goto DESTROY_CMDOPTIONS;
    }
    if(cmdoptions_help_passed(cmdoptions))
    {
        cmdoptions_help(cmdoptions);
        goto DESTROY_CMDOPTIONS;
    }
    if(cmdoptions_was_provided_long(cmdoptions, "version"))
    {
        printf("openPCells (opc) %u.%u.%u\n", OPC_VERSION_MAJOR, OPC_VERSION_MINOR, OPC_VERSION_REVISION);
        goto DESTROY_CMDOPTIONS;
    }
    int stdoutp = 0;
    if(cmdoptions_was_provided_long(cmdoptions, "stdout-to"))
    {
        const char* stdoutto = cmdoptions_get_argument_long(cmdoptions, "stdout-to");
        stdoutp = open(stdoutto, O_CREAT | O_WRONLY | O_TRUNC, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH);
        if(stdoutp == -1)
        {
            perror("could not create file descriptor for stdout redirection");
            goto DESTROY_CMDOPTIONS;
        }
        dup2(stdoutp, STDOUT_FILENO);
    }
    int stderrp = 0;
    if(cmdoptions_was_provided_long(cmdoptions, "stderr-to"))
    {
        const char* stderrto = cmdoptions_get_argument_long(cmdoptions, "stderr-to");
        stderrp = open(stderrto, O_CREAT | O_WRONLY | O_TRUNC, S_IRUSR | S_IWUSR | S_IRGRP | S_IWGRP | S_IROTH | S_IWOTH);
        if(stderrp == -1)
        {
            perror("could not create file descriptor for stderr redirection");
            goto DESTROY_CMDOPTIONS;
        }
        dup2(stderrp, STDERR_FILENO);
    }

    // execute lua script
    if(cmdoptions_was_provided_long(cmdoptions, "execute-lua-script"))
    {
        lua_State* L = util_create_basic_lua_state();
        const char* filename = cmdoptions_get_argument_long(cmdoptions, "execute-lua-script");
        main_call_lua_program(L, filename);
        lua_close(L);
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

    /* check technology */
    if(cmdoptions_was_provided_long(cmdoptions, "check-technology"))
    {
        struct vector* techpaths = hashmap_get(config, "techpaths");
        vector_append(techpaths, util_strdup(OPC_TECH_PATH "/tech"));
        if(cmdoptions_was_provided_long(cmdoptions, "techpath"))
        {
            const char* const* arg = cmdoptions_get_argument_long(cmdoptions, "techpath");
            while(*arg)
            {
                vector_append(techpaths, util_strdup(*arg));
                ++arg;
            }
        }
        const char* techname = cmdoptions_get_argument_long(cmdoptions, "check-technology");
        struct technology_state* techstate = main_create_techstate(techpaths, techname, NULL);
        if(!techstate)
        {
            fputs("could not initialize technology state\n", stderr);
            return 0;
        }
        lua_State* L = util_create_basic_lua_state();
        open_lterminal_lib(L);
        // load config file
        const char* configfile = technology_get_configfile_path(techstate, techname);
        lua_pushstring(L, configfile);
        lua_setglobal(L, "config_path");
        int ret = luaL_dofile(L, configfile);
        if(ret != LUA_OK)
        {
            const char* msg = lua_tostring(L, -1);
            fprintf(stderr, "error while loading configfile:\n  %s\n", msg);
            lua_close(L);
            return 0;
        }
        lua_setglobal(L, "config");
        // load layer map
        const char* layermap = technology_get_layermap_path(techstate, techname);
        lua_pushstring(L, layermap);
        lua_setglobal(L, "layermap_path");
        ret = luaL_dofile(L, layermap);
        if(ret != LUA_OK)
        {
            const char* msg = lua_tostring(L, -1);
            fprintf(stderr, "error while loading layermap:\n  %s\n", msg);
            lua_close(L);
            return 0;
        }
        lua_setglobal(L, "layermap");
        // load via table
        const char* viatable = technology_get_viatable_path(techstate, techname);
        lua_pushstring(L, viatable);
        lua_setglobal(L, "viatable_path");
        ret = luaL_dofile(L, viatable);
        if(ret != LUA_OK)
        {
            const char* msg = lua_tostring(L, -1);
            fprintf(stderr, "error while loading viatable:\n  %s\n", msg);
            lua_close(L);
            return 0;
        }
        lua_setglobal(L, "viatable");
        // load constraints
        const char* constraints = technology_get_constraints_path(techstate, techname);
        lua_pushstring(L, constraints);
        lua_setglobal(L, "constraints_path");
        ret = luaL_dofile(L, constraints);
        if(ret != LUA_OK)
        {
            const char* msg = lua_tostring(L, -1);
            fprintf(stderr, "error while loading constraints:\n  %s\n", msg);
            lua_close(L);
            return 0;
        }
        lua_setglobal(L, "constraints");
        // ignore export type errors?
        int ignore_export_errors = cmdoptions_was_provided_long(cmdoptions, "check-technology-ignore-export");
        lua_pushboolean(L, ignore_export_errors);
        lua_setglobal(L, "ignore_export_errors");
        // call check script
        script_call_check_technology(L);
        lua_close(L);
        goto DESTROY_CONFIG;
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
    if(cmdoptions_was_provided_long(cmdoptions, "tutorial"))
    {
        main_tutorial();
        goto DESTROY_CMDOPTIONS;
    }

    if(cmdoptions_was_provided_long(cmdoptions, "import"))
    {
        const char* scriptname = cmdoptions_get_argument_long(cmdoptions, "import");
        const char** ptr = cmdoptions_get_positional_parameters(cmdoptions);
        const struct const_vector* args = const_vector_adapt_from_pointer_array((void**)ptr);
        main_import_script(scriptname, args);
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
        main_techfile_assistant();
        goto DESTROY_CONFIG;
    }

    // get technology dimension
    if(cmdoptions_was_provided_long(cmdoptions, "get-dimension"))
    {
        if(!cmdoptions_was_provided_long(cmdoptions, "technology"))
        {
            fputs("no technology given\n", stderr);
            goto DESTROY_CONFIG;
        }
        const char* techname = cmdoptions_get_argument_long(cmdoptions, "technology");
        struct vector* techpaths = hashmap_get(config, "techpaths");
        vector_append(techpaths, util_strdup(OPC_TECH_PATH "/tech"));
        if(cmdoptions_was_provided_long(cmdoptions, "techpath"))
        {
            const char* const* arg = cmdoptions_get_argument_long(cmdoptions, "techpath");
            while(*arg)
            {
                vector_append(techpaths, util_strdup(*arg));
                ++arg;
            }
        }
        struct technology_state* techstate = main_create_techstate(techpaths, techname, NULL);
        if(!techstate)
        {
            fputs("could not initialize technology state\n", stderr);
            return 0;
        }
        const char* dimension = cmdoptions_get_argument_long(cmdoptions, "get-dimension");
        struct tagged_value* v = technology_get_dimension(techstate, dimension);
        tagged_value_print(v);
        putchar('\n');
        tagged_value_destroy(v);
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

    // cell parameters (only names)
    if(cmdoptions_was_provided_long(cmdoptions, "parameters-name"))
    {
        // cell name
        const char* cellname = cmdoptions_get_argument_long(cmdoptions, "parameters-name");
        // parameter format
        const char* parametersformat = "%n";
        // parameter names
        const char** parameternames = cmdoptions_get_positional_parameters(cmdoptions);
        main_list_cell_parameters(cellname, parametersformat, parameternames, cmdoptions, config);
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
        int verbose = cmdoptions_was_provided_long(cmdoptions, "verbose");
        int ret = main_create_and_export_cell(cmdoptions, config, create_cell_script, verbose); // 0: regular cell, 1: cellscript
        if(!ret)
        {
            returnvalue = 1;
        }
        goto DESTROY_CONFIG;
    }

    // should not reach here
    fputs("no cell given\n", stderr);
    returnvalue = 1;

    if(stdoutp)
    {
        close(stdoutp);
    }
    if(stderrp)
    {
        close(stderrp);
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

