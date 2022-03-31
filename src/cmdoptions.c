#include "cmdoptions.h"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "util.h"

struct cmdoptions* cmdoptions_create(void)
{
    struct cmdoptions* options = malloc(sizeof(options));
    options->options = vector_create();
    options->positional_parameters = vector_create();
    return options;
}

void _destroy_option(void* ptr)
{
    struct option* option = ptr;
    if(option->argument)
    {
        if(option->flags & MULTIPLE)
        {
            char** p = option->argument;
            while(*p)
            {
                free(*p);
                ++p;
            }
        }
        free(option->argument);
    }
    free(ptr);
}

void cmdoptions_destroy(struct cmdoptions* options)
{
    vector_destroy(options->options, _destroy_option);
    vector_destroy(options->positional_parameters, NULL);
    free(options);
}

void cmdoptions_exit(struct cmdoptions* options, int exitcode)
{
    cmdoptions_destroy(options);
    exit(exitcode);
}

void cmdoptions_add_long_option(struct cmdoptions* options, char short_identifier, const char* long_identifier, int argument_required, int flags)
{
    struct option* option = malloc(sizeof(*option));
    option->short_identifier = short_identifier;
    option->long_identifier = long_identifier;
    option->flags = flags;
    option->argument_required = argument_required;
    option->argument = NULL;
    option->was_provided = 0;
    vector_append(options->options, option);
}

struct option* cmdoptions_get_option_short(struct cmdoptions* options, char short_identifier)
{
    for(unsigned int i = 0; i < vector_size(options->options); ++i)
    {
        struct option* option = vector_get(options->options, i);
        if(option->short_identifier == short_identifier)
        {
            return option;
        }
    }
    return NULL;
}

struct option* cmdoptions_get_option_long(struct cmdoptions* options, const char* long_identifier)
{
    for(unsigned int i = 0; i < vector_size(options->options); ++i)
    {
        struct option* option = vector_get(options->options, i);
        if(strcmp(option->long_identifier, long_identifier) == 0)
        {
            return option;
        }
    }
    return NULL;
}

int cmdoptions_was_provided_long(struct cmdoptions* options, const char* opt)
{
    for(unsigned int i = 0; i < vector_size(options->options); ++i)
    {
        struct option* option = vector_get(options->options, i);
        if(strcmp(option->long_identifier, opt) == 0)
        {
            return option->was_provided;
        }
    }
    return 0;
}

void _store_argument(struct option* option, int* iptr, int argc, const char* const * argv)
{
    if(option->argument_required)
    {
        if(*iptr < argc - 1)
        {
            if(option->flags & MULTIPLE)
            {
                if(!option->argument)
                {
                    char** argument = calloc(2, sizeof(char*));
                    argument[0] = util_copy_string(argv[*iptr + 1]);
                    option->argument = argument;
                }
                else
                {
                    char** ptr = option->argument;
                    while(*ptr) { ++ptr; }
                    int len = ptr - (char**)option->argument;
                    char** argument = calloc(len + 2, sizeof(char*));
                    for(int j = 0; j < len; ++j)
                    {
                        argument[j] = ((char**)option->argument)[j];
                    }
                    argument[len] = util_copy_string(argv[*iptr + 1]);
                    free(option->argument);
                    option->argument = argument;
                }
            }
            else // non-MULTIPLE option
            {
                option->argument = util_copy_string(argv[*iptr + 1]);
            }
        }
        else // argument required, but not entries in argv left
        {
            //printf("expected argument for option '%s'\n", longopt);
            //return 0;
        }
        *iptr += 1;
    }
}

int cmdoptions_parse(struct cmdoptions* options, int argc, const char* const * argv)
{
    int endofoptions = 0;
    for(int i = 1; i < argc; ++i)
    {
        const char* arg = argv[i];
        if(!endofoptions && arg[0] == '-' && arg[1] == 0); // single dash (-)
        else if(!endofoptions && arg[0] == '-' && arg[1] == '-' && arg[2] == 0) // end of options (--)
        {
            endofoptions = 1;
        }
        else if(!endofoptions && arg[0] == '-') // option
        {
            if(arg[1] == '-') // long option
            {
                const char* longopt = arg + 2;
                struct option* option = cmdoptions_get_option_long(options, longopt);
                if(!option)
                {
                    //printf("unknown command line option: '--%s'\n", longopt);
                    //return 0;
                }
                else
                {
                    if(option->was_provided && !(option->flags & MULTIPLE))
                    {
                        printf("option '%s' is only allowed once\n", longopt);
                    }
                    option->was_provided = 1;
                    _store_argument(option, &i, argc, argv);
                }
            }
            else // short option
            {
                const char* ch = arg + 1;
                while(*ch)
                {
                    char shortopt = *ch;
                    struct option* option = cmdoptions_get_option_short(options, shortopt);
                    if(!option)
                    {
                        //printf("unknown command line option: '--%s'\n", longopt);
                        //return 0;
                    }
                    else
                    {
                        if(option->was_provided && !(option->flags & MULTIPLE))
                        {
                            printf("option '%c' is only allowed once\n", shortopt);
                        }
                        option->was_provided = 1;
                        _store_argument(option, &i, argc, argv);
                    }
                    ++ch;
                }
            }
        }
        else // positional parameter
        {
            vector_append(options->positional_parameters, util_copy_string(arg));
        }
    }
    return 1;
}

void* cmdoptions_get_argument_long(struct cmdoptions* options, const char* long_identifier)
{
    for(unsigned int i = 0; i < vector_size(options->options); ++i)
    {
        struct option* option = vector_get(options->options, i);
        if(strcmp(option->long_identifier, long_identifier) == 0)
        {
            return option->argument;
        }
    }
    return NULL;
}

