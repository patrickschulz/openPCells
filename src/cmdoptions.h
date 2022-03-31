#ifndef OPC_CMDOPTS_H
#define OPC_CMDOPTS_H

#include "vector.h"

struct option
{
    char short_identifier;
    const char* long_identifier;
    int argument_required;
    int flags;
    void* argument; // is char* for once-only options, char** (with NULL terminator) for multiple options
    int was_provided;
};

struct cmdoptions
{
    struct vector* options;
};

struct cmdoptions* cmdoptions_create(void);
void cmdoptions_destroy(struct cmdoptions* options);
void cmdoptions_exit(struct cmdoptions* options, int exitcode);

int cmdoptions_parse(struct cmdoptions* options, int argc, const char* const * argv);

#define NO_FLAGS 0
#define MULTIPLE 1
void cmdoptions_add_long_option(struct cmdoptions* options, char short_identifier, const char* long_identifier, int argument_required, int flags);

struct option* cmdoptions_get_option_short(struct cmdoptions* options, char short_identifier);
struct option* cmdoptions_get_option_long(struct cmdoptions* options, const char* long_identifier);

int cmdoptions_was_provided_long(struct cmdoptions* options, const char* opt);

void* cmdoptions_get_argument_long(struct cmdoptions* options, const char* long_identifier);

#endif // OPC_CMDOPTS_H
