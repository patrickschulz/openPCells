#ifndef OPC_MAIN_CELL_H
#define OPC_MAIN_CELL_H

#include "hashmap.h"
#include "cmdoptions.h"

void main_list_cells_cellpaths(struct cmdoptions* cmdoptions, struct hashmap* config);
void main_list_cell_parameters(const char* cellname, const char* parametersformat, const char** parameternames_ptr, struct cmdoptions* cmdoptions, struct hashmap* config);
void main_list_cell_anchors(struct cmdoptions* cmdoptions, struct hashmap* config);
int main_create_and_export_cell(struct cmdoptions* cmdoptions, struct hashmap* config, int iscellscript);

#endif // OPC_MAIN_CELL_H
