#include "main.functions.h"

#include <string.h>
#include <stdio.h>

#include "lua/lauxlib.h"

#include "lpoint.h"
#include "lgeometry.h"
#include "lgenerics.h"
#include "lload.h"
#include "lbind.h"
#include "ldir.h"
#include "lobject.h"
#include "lfilesystem.h"
#include "lplacer.h"
#include "lrouter.h"
#include "gdsparser.h"
#include "technology.h"
#include "graphics.h"
#include "util.h"

#include "config.h"

static lua_State* create_and_initialize_lua(void)
{
    lua_State* L = util_create_basic_lua_state();

    // opc libraries
    open_ldir_lib(L);
    open_lpoint_lib(L);
    open_lgeometry_lib(L);
    open_lgenerics_lib(L);
    open_ltechnology_lib(L);
    open_lgraphics_lib(L);
    open_lload_lib(L);
    open_lbind_lib(L);
    open_lobject_lib(L);
    open_lpcell_lib(L);
    open_lfilesystem_lib(L);
    open_lplacer_lib(L);
    open_lrouter_lib(L);

    open_gdsparser_lib(L);

    return L;
}

static int msghandler (lua_State *L)
{
    const char *msg = lua_tostring(L, 1);
    if (msg == NULL) /* is error object not a string? */
    {
        if (luaL_callmeta(L, 1, "__tostring") &&  /* does it have a metamethod */
                lua_type(L, -1) == LUA_TSTRING)  /* that produces a string? */
        {
            return 1;  /* that is the message */
        }
        else
        {
            msg = lua_pushfstring(L, "(error object is a %s value)",
                    luaL_typename(L, 1));
        }
    }
    luaL_traceback(L, L, msg, 1);  /* append a standard traceback */
    return 1;  /* return the traceback */
}

int main_call_lua_program(lua_State* L, const char* filename)
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

struct technology_state* main_create_techstate(struct vector* techpaths, const char* techname)
{
    struct technology_state* techstate = technology_initialize();
    for(unsigned int i = 0; i < vector_size(techpaths); ++i)
    {
        technology_add_techpath(techstate, vector_get(techpaths, i));
    }
    technology_load(techstate, techname);
    return techstate;
}

struct pcell_state* main_create_pcell_state(void)
{
    struct pcell_state* pcell_state = pcell_initialize_state();
    return pcell_state;
}

struct layermap* main_create_layermap(void)
{
    struct layermap* layermap = generics_initialize_layer_map();
    return layermap;
}

object_t* main_create_cell(const char* cellname, struct vector* cellargs, struct technology_state* techstate, struct pcell_state* pcell_state, struct layermap* layermap)
{
    lua_State* L = create_and_initialize_lua();

    // register techstate
    lua_pushlightuserdata(L, techstate);
    lua_setfield(L, LUA_REGISTRYINDEX, "techstate");

    // register pcell state
    lua_pushlightuserdata(L, pcell_state);
    lua_setfield(L, LUA_REGISTRYINDEX, "pcellstate");

    // register layermap
    lua_pushlightuserdata(L, layermap);
    lua_setfield(L, LUA_REGISTRYINDEX, "genericslayermap");

    // assemble cell arguments
    lua_newtable(L);
    lua_pushstring(L, cellname);
    lua_setfield(L, -2, "cell");
    lua_newtable(L);
    for(unsigned int i = 0; i < vector_size(cellargs); ++i)
    {
        lua_pushstring(L, vector_get(cellargs, i));
        lua_rawseti(L, -2, i + 1);
    }
    lua_setfield(L, -2, "cellargs");
    lua_setglobal(L, "args");
    int retval = main_call_lua_program(L, OPC_HOME "/src/scripts/create_cell.lua");
    if(retval != LUA_OK)
    {
        lua_close(L);
        return NULL;
    }
    lobject_t* lobject = lobject_check(L, -1);
    lobject->destroy = 0; // disown object from lua
    object_t* toplevel = lobject->object;

    lua_close(L);

    return toplevel;

    /*
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
        for(unsigned int i = 0; i < pcell_get_reference_count(pcell_state); ++i)
        {
            object_t* cell = pcell_get_indexed_cell_reference(pcell_state, i)->cell;
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
        object_flatten(toplevel, pcell_state, flattenports);
    }

    // post-processing
    if(cmdoptions_was_provided_long(cmdoptions, "filter-layers"))
    {
        const char** layernames = cmdoptions_get_argument_long(cmdoptions, "filter-layers");
        if(cmdoptions_was_provided_long(cmdoptions, "filter-list") &&
           strcmp(cmdoptions_get_argument_long(cmdoptions, "filter-list"), "include") == 0)
        {
            postprocess_filter_include(toplevel, layernames);
            for(unsigned int i = 0; i < pcell_get_reference_count(pcell_state); ++i)
            {
                object_t* cell = pcell_get_indexed_cell_reference(pcell_state, i)->cell;
                postprocess_filter_include(cell, layernames);
            }
        }
        else
        {
            postprocess_filter_exclude(toplevel, layernames);
            for(unsigned int i = 0; i < pcell_get_reference_count(pcell_state); ++i)
            {
                object_t* cell = pcell_get_indexed_cell_reference(pcell_state, i)->cell;
                postprocess_filter_exclude(cell, layernames);
            }
        }
    }
    if(cmdoptions_was_provided_long(cmdoptions, "merge-rectangles"))
    {
        postprocess_merge_shapes(toplevel, layermap);
    }
    */
}

