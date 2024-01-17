#ifndef OPC_CELLS_H
#define OPC_CELLS_H

#include "pcell.h"
#include "technology.h"

int cell_powergrid_layout(struct object* powergrid, struct technology_state* techstate, struct pcell_state* pcell_state);

#endif /* OPC_CELLS_H */
