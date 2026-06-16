#ifndef OPC_MAIN_CONFIG_H
#define OPC_MAIN_CONFIG_H

#include "cmdoptions.h"
#include "error.h"
#include "hashmap.h"

error_t main_load_config(struct hashmap* config, struct cmdoptions* cmdoptions, int load_user_config);

#endif /* OPC_MAIN_CONFIG_H */
