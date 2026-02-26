#ifndef OPC_PCELL_IMPLEMENTATION
#error "This header must only be included in the implementation files of the pcell module. It is not intended for external use."
#endif

#ifndef OPC_PCELL_DEF_H
#define OPC_PCELL_DEF_H

#include <stdio.h>

#include "vector.h"

struct pcell_state {
    struct vector* cellpaths;
    struct const_vector* pfilenames;
    FILE* dprint_target;
    int enable_dprint;
    int enable_debug;
    int verbose;
};

#endif /* OPC_PCELL_DEF_H */
