#ifndef OPC_MAIN_CELL_H
#define OPC_MAIN_CELL_H

#include "keyvaluepairs.h"
#include "cmdoptions.h"

void main_list_cell_parameters(struct cmdoptions* cmdoptions, struct keyvaluearray* config);
void main_create_and_export_cell(struct cmdoptions* cmdoptions, struct keyvaluearray* config, int iscellscript);

#endif // OPC_MAIN_CELL_H
