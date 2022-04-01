#ifndef OPC_CMDOPTS_H
#define OPC_CMDOPTS_H

#include "vector.h"

// arguments
#define NO_ARG 0
#define SINGLE_ARG 1
#define MULTI_ARGS 2

// short and long options
#define NO_SHORT 0
#define NO_LONG NULL

struct option
{
    char short_identifier;
    const char* long_identifier;
    int numargs;
    void* argument; // is char* for once-only options, char** (with NULL terminator) for multiple options
    int was_provided;
};

struct cmdoptions
{
    struct vector* options;
    struct vector* positional_parameters;
};

struct cmdoptions* cmdoptions_create(void);
void cmdoptions_destroy(struct cmdoptions* options);
void cmdoptions_exit(struct cmdoptions* options, int exitcode);

int cmdoptions_parse(struct cmdoptions* options, int argc, const char* const * argv);

void cmdoptions_add_option(struct cmdoptions* options, char short_identifier, const char* long_identifier, int numargs);
void cmdoptions_add_option_default(struct cmdoptions* options, char short_identifier, const char* long_identifier, int numargs, const char* default_arg);

struct option* cmdoptions_get_option_short(struct cmdoptions* options, char short_identifier);
struct option* cmdoptions_get_option_long(struct cmdoptions* options, const char* long_identifier);

int cmdoptions_was_provided_long(struct cmdoptions* options, const char* opt);

void* cmdoptions_get_argument_long(struct cmdoptions* options, const char* long_identifier);

#endif // OPC_CMDOPTS_H
