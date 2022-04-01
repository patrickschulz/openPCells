#ifndef OPC_LEXPORT_H
#define OPC_LEXPORT_H

#include "lua/lua.h"

#define LEXPORTMODULE "export"

#include "object.h"

void export_add_path(const char* path);
void export_write_toplevel(object_t* toplevel, const char* exportname, const char* basename, const char* toplevelname, char leftdelim, char rightdelim, const char* const * exportoptions, int writechildrenports);

#endif // OPC_LEXPORT_H
