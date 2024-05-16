#ifndef OPC_EXPORT_WRITER
#define OPC_EXPORT_WRITER

#include "lua/lua.h"
#include "export_common.h"
#include "hashmap.h"

struct export_writer;

struct export_writer* export_writer_create_lua(lua_State* L, struct export_data* data);
struct export_writer* export_writer_create_C(const struct export_functions* funcs, struct export_data* data);
void export_writer_destroy(struct export_writer* writer);
int export_writer_write_cell(struct export_writer* writer, const struct object* cell, int write_ports, char leftdelim, char rightdelim);
int export_writer_write_toplevel(struct export_writer* writer, const struct object* object, int expand_namecontext, int writeports, int writechildrenports, char leftdelim, char rightdelim);

#endif // OPC_EXPORT_WRITER

