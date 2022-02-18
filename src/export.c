#include "lua/lua.h"

typedef struct
{
    void (*write_rectangle)(void);
} export_functions_t;

void _export_from_C(export_functions_t* export)
{
    export->write_rectangle();
}

void _export_from_lua(lua_State* L)
{

}

void export(void)
{
    int found_C_export = 1;
    if(found_C_export)
    {
        export_functions_t* export;
        _export_from_C(export);
    }
    else
    {
        lua_State* L;
    }
}

