#include "main.functions.h"

#include <stdlib.h>
#include <string.h>

#include "lua/lauxlib.h"

#include "lua_util.h"

#include "filesystem.h"
#include "pcell.h"
#include "util_cmodule.h"

#include "ldir.h"
#include "lgenerics.h"
#include "lgeometry.h"
#include "lobject.h"
#include "lplacement.h"
#include "lplacer.h"
#include "lpoint.h"
#include "lpolygon.h"
#include "lpostprocess.h"
#include "lrouter.h"
#include "lua_util.h"

void main_load_opc_libraries(lua_State* L)
{
    // opc libraries
    open_ldir_lib(L);
    open_lfilesystem_lib(L);
    open_lpoint_lib(L);
    open_lgeometry_lib(L);
    open_lgenerics_lib(L);
    open_ltechnology_lib(L);
    open_lobject_lib(L);
    open_lplacement_lib(L);
    open_lpostprocess(L);
    open_lpolygon_lib(L);
    open_lutil_cmodule_lib(L);
    // FIXME: these libraries are probably not needed for cell creation (they are used in place & route scripts)
    open_lplacer_lib(L);
    open_lrouter_lib(L);
}

struct technology_state* main_create_techstate(const struct vector* techpaths, const char* techname, const struct const_vector* ignoredlayers)
{
    struct technology_state* techstate = technology_initialize(techname);
    if(!technology_load(techpaths, techstate, ignoredlayers))
    {
        technology_destroy(techstate);
        return NULL;
    }
    return techstate;
}

