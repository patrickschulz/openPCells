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
    const char* help;
    struct option* aliased;
};

struct section
{
    const char* name;
};

struct cmdoptions
{
    struct vector* entries;
    struct vector* positional_parameters;
    struct const_vector* prehelpmsg;
    struct const_vector* posthelpmsg;
    int force_narrow_mode;
};

struct cmdoptions* cmdoptions_create(void);
void cmdoptions_enable_narrow_mode(struct cmdoptions* options);
void cmdoptions_disable_narrow_mode(struct cmdoptions* options);
void cmdoptions_destroy(struct cmdoptions* options);
void cmdoptions_exit(struct cmdoptions* options, int exitcode);

int cmdoptions_parse(struct cmdoptions* options, int argc, const char* const * argv);

void cmdoptions_add_section(struct cmdoptions* options, const char* section);
void cmdoptions_add_option(struct cmdoptions* options, char short_identifier, const char* long_identifier, int numargs, const char* help);
void cmdoptions_add_option_default(struct cmdoptions* options, char short_identifier, const char* long_identifier, int numargs, const char* default_arg, const char* help);
void cmdoptions_add_alias(struct cmdoptions* options, const char* long_alias_identifier, char short_identifier, const char* long_identifier, const char* help);

void cmdoptions_prepend_help_message(struct cmdoptions* options, const char* msg);
void cmdoptions_append_help_message(struct cmdoptions* options, const char* msg);

void cmdoptions_help(struct cmdoptions* options);
void cmdoptions_export_manpage(struct cmdoptions* options);

struct option* cmdoptions_get_option_short(struct cmdoptions* options, char short_identifier);
struct option* cmdoptions_get_option_long(struct cmdoptions* options, const char* long_identifier);
struct vector* cmdoptions_get_positional_parameters(struct cmdoptions* options);

int cmdoptions_was_provided_long(struct cmdoptions* options, const char* opt);

void* cmdoptions_get_argument_long(struct cmdoptions* options, const char* long_identifier);

#endif // OPC_CMDOPTS_H
