#include "main.cellbase.h"

#include "_config.h"

void main_cellbase_prepare_cellpaths(struct pcell_state* pcell_state, struct cmdoptions* cmdoptions, struct hashmap* config)
{
    if(cmdoptions && cmdoptions_was_provided_long(cmdoptions, "prepend-cellpath"))
    {
        const char* const* arg = cmdoptions_get_argument_long(cmdoptions, "prepend-cellpath");
        while(*arg)
        {

            pcell_append_cellpath(pcell_state, *arg);
            ++arg;
        }
    }
    struct vector* config_prepend_cellpaths = hashmap_get(config, "prepend_cellpaths");
    if(config_prepend_cellpaths)
    {
        for(unsigned int i = 0; i < vector_size(config_prepend_cellpaths); ++i)
        {
            pcell_append_cellpath(pcell_state, vector_get(config_prepend_cellpaths, i));
        }
    }
    if(cmdoptions && cmdoptions_was_provided_long(cmdoptions, "append-cellpath"))
    {
        const char* const* arg = cmdoptions_get_argument_long(cmdoptions, "append-cellpath");
        while(*arg)
        {
            pcell_append_cellpath(pcell_state, *arg);
            ++arg;
        }
    }
    struct vector* config_append_cellpaths = hashmap_get(config, "append_cellpaths");
    if(config_append_cellpaths)
    {
        for(unsigned int i = 0; i < vector_size(config_append_cellpaths); ++i)
        {
            pcell_append_cellpath(pcell_state, vector_get(config_append_cellpaths, i));
        }
    }
    // add default path
    pcell_append_cellpath(pcell_state, OPC_CELL_PATH "/cells");
}

