#include "helper.h"

#include <stdlib.h>

#include "src/_config.h"
#include "src/technology.h"
#include "src/util.h"
#include "src/vector.h"

struct technology_state* helper_create_techstate(void)
{
    struct vector* techpaths = vector_create(8, free);
    vector_append(techpaths, util_strdup(OPC_TECH_PATH "/tech"));

    struct technology_state* techstate = technology_initialize("opc");
    if(!technology_load(techpaths, techstate, NULL))
    {
        technology_destroy(techstate);
        return NULL;
    }
    return techstate;
}

