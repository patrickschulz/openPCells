#ifndef OPC_LEXPORT_H
#define OPC_LEXPORT_H

#include "lua/lua.h"

#define LEXPORTMODULE "export"

#include "object.h"
#include "pcell.h"

void export_add_path(const char* path);
void export_write_toplevel(object_t* toplevel, struct pcell_state* pcell_state, const char* exportname, const char* basename, const char* toplevelname, char leftdelim, char rightdelim, const char* const * exportoptions, int writechildrenports);

#endif // OPC_LEXPORT_H
