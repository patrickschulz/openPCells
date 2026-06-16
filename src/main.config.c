#include "main.config.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "_config.h"

#include "filesystem.h"
#include "lua_util.h"
#include "util.h"
#include "vector.h"

error_t main_load_config(struct hashmap* config, struct cmdoptions* cmdoptions, int load_user_config)
{
    error_t error_status = error_success();

    /* prepare config */
    struct vector* techpaths = vector_create(8, free);
    hashmap_insert(config, "techpaths", techpaths);
    struct vector* prepend_cellpaths = vector_create(8, free);
    hashmap_insert(config, "prepend_cellpaths", prepend_cellpaths);
    struct vector* append_cellpaths = vector_create(8, free);
    hashmap_insert(config, "append_cellpaths", append_cellpaths);
    struct vector* ignoredlayers = vector_create(8, free);
    hashmap_insert(config, "ignoredlayers", ignoredlayers);

    // set/load technology search paths
    vector_append(techpaths, util_strdup(OPC_TECH_PATH "/tech"));
    if(cmdoptions && cmdoptions_was_provided_long(cmdoptions, "techpath"))
    {
        const char* const* arg = cmdoptions_get_argument_long(cmdoptions, "techpath");
        while(*arg)
        {
            vector_append(techpaths, util_strdup(*arg));
            ++arg;
        }
    }

    int no_user_config = !load_user_config || (cmdoptions && cmdoptions_was_provided_long(cmdoptions, "no-user-config"));
    int ret = LUA_OK;

    if(!no_user_config)
    {
        const char* home = getenv("HOME");
        if(!home)
        {
            home = ".";
        }
        size_t len = strlen(home) + strlen("/.opcconfig.lua");
        char* filename = malloc(len + 1);
        snprintf(filename, len + 1, "%s/.opcconfig.lua", home);
        if(!filesystem_exists(filename))
        {
            free(filename);
            return error_status;
            /* non-existing user config is not an error (status is success at this point) */
        }
        lua_State* L = util_create_basic_lua_state();
        ret = luaL_dofile(L, filename);
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
            prepend_cellpaths = hashmap_get(config, "prepend_cellpaths");
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
                const char* msg = lua_tostring(L, -2);
                error_set_failure(&error_status);
                error_add(&error_status, "unknown config entry ");
                error_add(&error_status, "'");
                error_add(&error_status, msg);
                error_add(&error_status, "'");
                lua_pop(L, 1);
            }
        }
        else
        {
            const char* msg = lua_tostring(L, -1);
            error_set_failure(&error_status);
            error_add(&error_status, msg);
            lua_pop(L, 1);
        }
        lua_close(L);
    }
    return error_status;
}

