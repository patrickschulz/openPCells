#ifndef OPC_CMDOPTS_H
#define OPC_CMDOPTS_H

#include "vector.h"

struct option
{
    char short_identifier;
    const char* long_identifier;
    int argument_required;
    const char* argument;
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

void cmdoptions_add_long_option(struct cmdoptions* options, char short_identifier, const char* long_identifier, int argument_required);

struct option* cmdoptions_get_option_long(struct cmdoptions* options, const char* long_identifier);

int cmdoptions_was_provided_long(struct cmdoptions* options, const char* opt);

const char* cmdoptions_get_argument_long(struct cmdoptions* options, const char* long_identifier);

#endif // OPC_CMDOPTS_H
