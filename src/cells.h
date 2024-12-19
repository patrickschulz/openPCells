#ifndef OPC_CELLS_H
#define OPC_CELLS_H

#include "pcell.h"
#include "technology.h"

int cell_powergrid_layout(struct pcell_state* pcell_state, struct technology_state* techstate, struct object* powergrid);

#endif /* OPC_CELLS_H */
