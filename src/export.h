#ifndef OPC_LEXPORT_H
#define OPC_LEXPORT_H

#include "lua/lua.h"

#define LEXPORTMODULE "export"

#include "object.h"
#include "pcell.h"
#include "vector.h"

char* export_get_export_layername(struct const_vector* searchpaths, const char* exportname);
void export_write_toplevel(object_t* toplevel, struct pcell_state* pcell_state, struct const_vector* searchpaths, const char* exportname, const char* basename, const char* toplevelname, char leftdelim, char rightdelim, const char* const * exportoptions, int writechildrenports);

#endif // OPC_LEXPORT_H
