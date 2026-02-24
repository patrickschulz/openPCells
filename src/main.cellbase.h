#ifndef OPC_MAIN_CELLBASE_H
#define OPC_MAIN_CELLBASE_H

#include "cmdoptions.h"
#include "hashmap.h"
#include "pcell.h"

void main_cellbase_prepare_cellpaths(struct pcell_state* pcell_state, struct cmdoptions* cmdoptions, struct hashmap* config);

#endif /* OPC_MAIN_CELLBASE_H */
