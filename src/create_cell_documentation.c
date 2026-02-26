#include <stddef.h>
#include <stdio.h>

#include "main.cellbase.h"
#include "main.config.h"
#include "pcell.info.h"

int main(void)
{
    // load config (standard cell paths are set here)
    struct hashmap* config = hashmap_create(NULL);
    int load_user_config = 0;
    void* cmdoptions = NULL; // do not need any command-line switches
    error_t config_status = main_load_config(config, cmdoptions, load_user_config);
    if(error_is_failure(&config_status))
    {
        error_printf(&config_status, "%s: ", "error while loading user config: ");
        error_clean(&config_status);
        return 1;
    }

    // pcell state
    struct pcell_state* pcell_state = pcell_initialize_state();
    if(!pcell_state)
    {
        fputs("could not initialize pcell state\n", stderr);
        return 1;
    }
    main_cellbase_prepare_cellpaths(pcell_state, cmdoptions, config);

    pcell_create_cell_documentation(pcell_state);
    pcell_destroy_state(pcell_state);
}

