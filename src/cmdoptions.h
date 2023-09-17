#ifndef OPC_CMDOPTS_H
#define OPC_CMDOPTS_H

/* arguments */
#define NO_ARG 0
#define SINGLE_ARG 1
#define MULTI_ARGS 2

/* short and long options */
#define NO_SHORT 0
#define NO_LONG NULL

/* main public structure */
struct cmdoptions;

/* initialization and clean-up */
struct cmdoptions* cmdoptions_create(void);
void cmdoptions_enable_narrow_mode(struct cmdoptions* options);
void cmdoptions_disable_narrow_mode(struct cmdoptions* options);
void cmdoptions_destroy(struct cmdoptions* options);
void cmdoptions_exit(struct cmdoptions* options, int exitcode);
int cmdoptions_is_valid(const struct cmdoptions* options);
int cmdoptions_all_options_checked(const struct cmdoptions* options);

/* parsing */
int cmdoptions_parse(struct cmdoptions* options, int argc, const char* const * argv);

/* defining options and sections */
int cmdoptions_add_mode(struct cmdoptions* options, const char* modename);
int cmdoptions_add_section(struct cmdoptions* options, const char* section);
int cmdoptions_mode_add_section(struct cmdoptions* options, const char* modename, const char* section);
int cmdoptions_mode_add_option(struct cmdoptions* options, const char* modename, char short_identifier, const char* long_identifier, int numargs, const char* help);
int cmdoptions_add_option(struct cmdoptions* options, char short_identifier, const char* long_identifier, int numargs, const char* help);
int cmdoptions_add_option_default(struct cmdoptions* options, char short_identifier, const char* long_identifier, int numargs, const char* default_arg, const char* help);
int cmdoptions_add_alias(struct cmdoptions* options, const char* long_alias_identifier, char short_identifier, const char* long_identifier, const char* help);

/* help message content */
void cmdoptions_prepend_help_message(struct cmdoptions* options, const char* msg);
void cmdoptions_append_help_message(struct cmdoptions* options, const char* msg);

/* help display */
void cmdoptions_help(const struct cmdoptions* options);
void cmdoptions_export_manpage(const struct cmdoptions* options);

/* query option info */
int cmdoptions_empty(const struct cmdoptions* options);
int cmdoptions_no_args_given(const struct cmdoptions* options);
int cmdoptions_mode_no_args_given(const struct cmdoptions* options, const char* modename);
int cmdoptions_was_provided_short(struct cmdoptions* options, char short_identifier);
int cmdoptions_mode_was_provided_short(struct cmdoptions* options, const char* modename, char short_identifier);
int cmdoptions_was_provided_long(struct cmdoptions* options, const char* long_identifier);
int cmdoptions_mode_was_provided_long(struct cmdoptions* options, const char* modename, const char* long_identifier);

/* query option content */
const void* cmdoptions_get_argument_short(struct cmdoptions* options, char short_identifier);
const void* cmdoptions_mode_get_argument_short(struct cmdoptions* options, const char* modename, char short_identifier);
const void* cmdoptions_get_argument_long(struct cmdoptions* options, const char* long_identifier);
const void* cmdoptions_mode_get_argument_long(struct cmdoptions* options, const char* modename, const char* long_identifier);
const char** cmdoptions_get_positional_parameters(struct cmdoptions* options);

#endif /* OPC_CMDOPTS_H */

