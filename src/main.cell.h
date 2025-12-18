#ifndef OPC_MAIN_CELL_H
#define OPC_MAIN_CELL_H

#include "cmdoptions.h"
#include "hashmap.h"

void main_show_cell_info(
    const char* cellname,
    struct cmdoptions* cmdoptions,
    struct hashmap* config
);

void main_list_cells_cellpaths(
    struct cmdoptions* cmdoptions,
    struct hashmap* config
);

void main_list_cell_parameters(
    const char* cellname,
    const char* parametersformat,
    const char** parameternames_ptr,
    struct cmdoptions* cmdoptions,
    struct hashmap* config
);

void main_list_cell_anchors(
    struct cmdoptions* cmdoptions,
    struct hashmap* config
);

int main_create_and_export_cell(
    struct cmdoptions* cmdoptions,
    struct hashmap* config,
    int iscellscript,
    int verbose
);

#endif // OPC_MAIN_CELL_H
