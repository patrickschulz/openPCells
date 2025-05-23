#ifndef OPC_MAIN_GDS_H
#define OPC_MAIN_GDS_H

#include "cmdoptions.h"

void main_gds_show_data(struct cmdoptions* cmdoptions);
void main_gds_show_cell_hierarchy(struct cmdoptions* cmdoptions);
void main_gds_show_cell_definitions(struct cmdoptions* cmdoptions);
void main_gds_read(struct cmdoptions* cmdoptions);

#endif // OPC_MAIN_GDS_H
