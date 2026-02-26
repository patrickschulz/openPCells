#include <stdlib.h>

#define OPC_PCELL_IMPLEMENTATION
#include "pcell.def.h"
#undef OPC_PCELL_IMPLEMENTATION

#include "util.h"

struct pcell_state* pcell_initialize_state(void)
{
    struct pcell_state* pcell_state = malloc(sizeof(*pcell_state));
    pcell_state->cellpaths = vector_create(64, free);
    pcell_state->pfilenames = const_vector_create(4);
    pcell_state->dprint_target = NULL;
    pcell_state->enable_dprint = 0;
    pcell_state->enable_debug = 0;
    pcell_state->verbose = 0;
    return pcell_state;
}

void pcell_destroy_state(struct pcell_state* pcell_state)
{
    if(pcell_state->dprint_target)
    {
        fclose(pcell_state->dprint_target);
    }
    vector_destroy(pcell_state->cellpaths);
    const_vector_destroy(pcell_state->pfilenames);
    free(pcell_state);
}

void pcell_append_pfile(struct pcell_state* pcell_state, const char* pfile)
{
    const_vector_append(pcell_state->pfilenames, pfile);
}

void pcell_enable_debug(struct pcell_state* pcell_state)
{
    pcell_state->enable_debug = 1;
}

void pcell_set_dprint_target(struct pcell_state* pcell_state, const char* filename)
{
    pcell_state->dprint_target = fopen(filename, "w");
}

void pcell_enable_dprint(struct pcell_state* pcell_state)
{
    pcell_state->enable_dprint = 1;
}

void pcell_set_verbose(struct pcell_state* pcell_state)
{
    pcell_state->verbose = 1;
}

void pcell_prepend_cellpath(struct pcell_state* pcell_state, const char* path)
{
    vector_prepend(pcell_state->cellpaths, util_strdup(path));
}

void pcell_append_cellpath(struct pcell_state* pcell_state, const char* path)
{
    vector_append(pcell_state->cellpaths, util_strdup(path));
}
