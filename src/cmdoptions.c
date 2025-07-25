#include "cmdoptions.h"

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#include "print.h"

struct option {
    char short_identifier;
    const char* long_identifier;
    int numargs;
    void* argument; /* is char* for once-only options, char** (with NULL terminator) for multiple options */
    int was_provided;
    int was_checked;
    const char* help;
    struct option* aliased;
};

struct section {
    char* name;
};

struct entry {
    void* value; /* struct option* or struct section* */
    enum { SECTION, OPTION } what;
};

struct mode {
    char* identifier;
    struct entry** entries;
    size_t entries_size;
    size_t entries_capacity;
    int was_selected;
};

struct cmdoptions {
    struct mode** modes; /* first 'mode' is mode-less */
    size_t size;
    size_t capacity;
    char** positional_parameters;
    char* prehelpmsg;
    char* posthelpmsg;
    int force_narrow_mode;
    int valid;
    int help_passed;
};

struct cmdoptions* cmdoptions_create_no_help(void)
{
    struct cmdoptions* options = malloc(sizeof(*options));
    struct mode* basemode = malloc(sizeof(*basemode));
    basemode->identifier = NULL;
    basemode->entries_size = 0;
    basemode->entries_capacity = 1;
    basemode->entries = malloc(basemode->entries_capacity * sizeof(*basemode->entries));
    basemode->was_selected = 1; /* basemode is always selected */
    options->modes = malloc(sizeof(*options->modes));
    options->modes[0] = basemode;
    options->size = 1;
    options->capacity = 1;
    options->positional_parameters = malloc(sizeof(*options->positional_parameters));;
    *options->positional_parameters = NULL; /* sentinel */
    options->prehelpmsg = malloc(1);
    options->prehelpmsg[0] = 0;
    options->posthelpmsg = malloc(1);
    options->posthelpmsg[0] = 0;
    options->force_narrow_mode = 0;
    options->valid = 1;
    options->help_passed = 0;
    return options;
}

static int _add_option_checked(struct cmdoptions* options, char short_identifier, const char* long_identifier, int numargs, const char* help);
struct cmdoptions* cmdoptions_create(void)
{
    struct cmdoptions* options = cmdoptions_create_no_help();
    _add_option_checked(options, 'h', "help", NO_ARG, "display help");
    return options;
}

void cmdoptions_enable_narrow_mode(struct cmdoptions* options)
{
    options->force_narrow_mode = 1;
}

void cmdoptions_disable_narrow_mode(struct cmdoptions* options)
{
    options->force_narrow_mode = 0;
}

void _destroy_entry(void* ptr)
{
    struct entry* entry = ptr;
    if(entry->what == OPTION)
    {
        struct option* option = entry->value;
        if(option->argument)
        {
            if(option->numargs & MULTI_ARGS)
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
    }
    else /* SECTION */
    {
        struct section* section = entry->value;
        free(section->name);
    }
    free(entry->value);
    free(ptr);
}

static void _destroy_mode(struct mode* mode)
{
    size_t i;
    for(i = 0; i < mode->entries_size; ++i)
    {
        _destroy_entry(mode->entries[i]);
    }
    free(mode->entries);
    free(mode->identifier);
    free(mode);
}

void cmdoptions_destroy(struct cmdoptions* options)
{
    size_t i;
    char** p;
    for(i = 0; i < options->size; ++i)
    {
        _destroy_mode(options->modes[i]);
    }
    free(options->modes);
    p = options->positional_parameters;
    while(*p)
    {
        free(*p);
        ++p;
    }
    free(options->positional_parameters);
    free(options->prehelpmsg);
    free(options->posthelpmsg);
    free(options);
}

void cmdoptions_exit(struct cmdoptions* options, int exitcode)
{
    cmdoptions_destroy(options);
    exit(exitcode);
}

int cmdoptions_is_valid(const struct cmdoptions* options)
{
    return options->valid;
}

int cmdoptions_assert_all_options_checked(const struct cmdoptions* options)
{
    size_t i;
    size_t j;
    struct mode* mode;
    struct entry* entry;
    struct option* option;
    for(i = 0; i < options->size; ++i)
    {
        mode = options->modes[i];
        for(j = 0; j < mode->entries_size; ++j)
        {
            entry = mode->entries[j];
            if(entry->what == OPTION)
            {
                option = entry->value;
                if(!option->was_checked)
                {
                    if(option->long_identifier)
                    {
                        fprintf(stderr, "option '--%s' was no checked\n", option->long_identifier);
                    }
                    else
                    {
                        fprintf(stderr, "option '-%c' was no checked\n", option->short_identifier);
                    }
                    return 0;
                }
            }
        }
    }
    return 1;
}

static int _check_capacity(struct mode* mode)
{
    struct entry** tmp;
    if(mode->entries_size + 1 > mode->entries_capacity)
    {
        mode->entries_capacity *= 2;
        tmp = realloc(mode->entries, sizeof(*tmp) * mode->entries_capacity);
        if(!tmp)
        {
            return 0;
        }
        mode->entries = tmp;
    }
    return 1;
}

static int _add_entry(struct mode* mode, struct entry* entry)
{
    if(!_check_capacity(mode))
    {
        return 0;
    }
    mode->entries[mode->entries_size] = entry;
    mode->entries_size += 1;
    return 1;
}

static struct mode* _find_mode(struct cmdoptions* options, const char* modename)
{
    size_t i;
    for(i = 1; i < options->size; ++i) /* start at 1: skip basemode */
    {
        if(strcmp(modename, options->modes[i]->identifier) == 0)
        {
            return options->modes[i];
        }
    }
    return NULL;
}

static const struct mode* _find_const_mode(const struct cmdoptions* options, const char* modename)
{
    size_t i;
    for(i = 1; i < options->size; ++i) /* start at 1: skip basemode */
    {
        if(strcmp(modename, options->modes[i]->identifier) == 0)
        {
            return options->modes[i];
        }
    }
    return NULL;
}

int cmdoptions_mode_add_section(struct cmdoptions* options, const char* modename, const char* name)
{
    struct entry* entry;
    struct section* section = malloc(sizeof(*section));
    struct mode* mode = _find_mode(options, modename);
    if(!mode)
    {
        return 0;
    }
    section->name = malloc(strlen(name) + 1);
    if(!section->name)
    {
        free(section);
        return 0;
    }
    strcpy(section->name, name);
    entry = malloc(sizeof(*entry));
    entry->what = SECTION;
    entry->value = section;
    if(!_add_entry(mode, entry))
    {
        free(section);
        free(entry);
        return 0;
    }
    return 1;
}

int cmdoptions_add_section(struct cmdoptions* options, const char* name)
{
    struct mode* mode = options->modes[0]; /* base mode */
    struct entry* entry;
    struct section* section = malloc(sizeof(*section));
    section->name = malloc(strlen(name) + 1);
    if(!section->name)
    {
        free(section);
        return 0;
    }
    strcpy(section->name, name);
    entry = malloc(sizeof(*entry));
    entry->what = SECTION;
    entry->value = section;
    if(!_add_entry(mode, entry))
    {
        free(section);
        free(entry);
        return 0;
    }
    return 1;
}

static struct entry* _create_option(char short_identifier, const char* long_identifier, int numargs, const char* help)
{
    struct entry* entry;
    struct option* option = malloc(sizeof(*option));
    if(!option)
    {
        return NULL;
    }
    option->short_identifier = short_identifier;
    option->long_identifier = long_identifier;
    option->numargs = numargs;
    option->argument = NULL;
    option->was_provided = 0;
    option->was_checked = 0;
    option->help = help;
    option->aliased = NULL;
    entry = malloc(sizeof(*entry));
    if(!entry)
    {
        free(option);
        return NULL;
    }
    entry->value = option;
    entry->what = OPTION;
    return entry;
}

static struct mode* _get_basemode(struct cmdoptions* options)
{
    return options->modes[0];
}

static const struct mode* _get_const_basemode(const struct cmdoptions* options)
{
    return options->modes[0];
}

int cmdoptions_add_mode(struct cmdoptions* options, const char* modename)
{
    struct mode* mode;
    if(_find_const_mode(options, modename))
    {
        return 0;
    }
    options->size += 1;
    options->capacity += 1; /* capacity really needed? */
    options->modes = realloc(options->modes, options->capacity * sizeof(*options->modes));
    mode = malloc(sizeof(*mode));
    mode->identifier = malloc(strlen(modename) + 1);
    strcpy(mode->identifier, modename);
    mode->entries_size = 0;
    mode->entries_capacity = 1;
    mode->entries = malloc(mode->entries_capacity * sizeof(*mode->entries));
    mode->was_selected = 0;
    options->modes[options->size - 1] = mode;
    return 1;
}

int cmdoptions_add_alias(struct cmdoptions* options, const char* long_aliased_identifier, char short_identifier, const char* long_identifier, const char* help)
{
    struct entry* entry;
    struct option* alias = NULL;
    unsigned int i;
    struct mode* basemode = _get_basemode(options);
    for(i = 0; i < basemode->entries_size; ++i)
    {
        struct entry* entry = basemode->entries[i];
        if(entry->what == OPTION)
        {
            struct option* option = entry->value;
            if(strcmp(option->long_identifier, long_aliased_identifier) == 0)
            {
                alias = option;
                break;
            }
        }
    }

    entry = _create_option(short_identifier, long_identifier, 0, help); /* num_args will never be used */
    if(!entry)
    {
        return 0;
    }
    ((struct option*)entry->value)->aliased = alias;
    if(!_add_entry(basemode, entry))
    {
        _destroy_entry(entry);
        return 0;
    }
    return 1;
}

static int _add_option_checked(struct cmdoptions* options, char short_identifier, const char* long_identifier, int numargs, const char* help)
{
    struct entry* entry = _create_option(short_identifier, long_identifier, numargs, help);
    struct option* option = entry->value;
    option->was_checked = 1;
    if(!entry)
    {
        return 0;
    }
    struct mode* basemode = _get_basemode(options);
    if(!_add_entry(basemode, entry))
    {
        _destroy_entry(entry);
        return 0;
    }
    return 1;
}

int cmdoptions_add_option(struct cmdoptions* options, char short_identifier, const char* long_identifier, int numargs, const char* help)
{
    struct entry* entry = _create_option(short_identifier, long_identifier, numargs, help);
    if(!entry)
    {
        return 0;
    }
    struct mode* basemode = _get_basemode(options);
    if(!_add_entry(basemode, entry))
    {
        _destroy_entry(entry);
        return 0;
    }
    return 1;
}

int cmdoptions_mode_add_option(struct cmdoptions* options, const char* modename, char short_identifier, const char* long_identifier, int numargs, const char* help)
{
    struct entry* entry = _create_option(short_identifier, long_identifier, numargs, help);
    if(!entry)
    {
        return 0;
    }
    struct mode* mode = _find_mode(options, modename);
    if(!_add_entry(mode, entry))
    {
        _destroy_entry(entry);
        return 0;
    }
    return 1;
}

int cmdoptions_add_option_default(struct cmdoptions* options, char short_identifier, const char* long_identifier, int numargs, const char* default_arg, const char* help)
{
    struct entry* entry = _create_option(short_identifier, long_identifier, numargs, help);
    if(!entry)
    {
        return 0;
    }
    struct mode* basemode = _get_basemode(options);
    if(numargs > 1)
    {
        char** arg = calloc(2, sizeof(*arg));
        arg[0] = malloc(strlen(default_arg) + 1);
        strcpy(arg[0], default_arg);
        arg[1] = NULL;
        ((struct option*)entry->value)->argument = arg;
    }
    else
    {
        char* arg = malloc(strlen(default_arg) + 1);
        if(!arg)
        {
            _destroy_entry(entry);
            return 0;
        }
        strcpy(arg, default_arg);
        ((struct option*)entry->value)->argument = arg;
    }
    if(!_add_entry(basemode, entry))
    {
        _destroy_entry(entry);
        return 0;
    }
    return 1;
}

void cmdoptions_prepend_help_message(struct cmdoptions* options, const char* msg)
{
    int empty = options->prehelpmsg[0] == 0;
    size_t len = strlen(options->prehelpmsg) + strlen(msg);
    if(!empty)
    {
        len = len + 1; /* +1: for newline */
    }
    char* str = realloc(options->prehelpmsg, len + 1);
    if(!str)
    {
        options->valid = 0;
        return;
    }
    if(!empty)
    {
        strcat(str, "\n");
    }
    strcat(str, msg);
    options->prehelpmsg = str;
}

void cmdoptions_append_help_message(struct cmdoptions* options, const char* msg)
{
    int empty = options->posthelpmsg[0] == 0;
    size_t len = strlen(options->posthelpmsg) + strlen(msg);
    if(!empty)
    {
        len = len + 1; /* +1: for newline */
    }
    char* str = realloc(options->posthelpmsg, len + 1);
    if(!str)
    {
        options->valid = 0;
        return;
    }
    if(!empty)
    {
        strcat(str, "\n");
    }
    strcat(str, msg);
    options->posthelpmsg = str;
}

static void _print_sep(unsigned int num)
{
    unsigned int i;
    for(i = 0; i < num; ++i)
    {
        putchar(' ');
    }
}

#define _MAX(a, b) ((a) > (b) ? (a) : (b))

static void _find_max_opt_width(const struct cmdoptions* options, unsigned int* optwidth)
{
    size_t i;
    size_t m;
    struct mode* mode;
    for(m = 0; m < options->size; ++m)
    {
        mode = options->modes[m];
        for(i = 0; i < mode->entries_size; ++i)
        {
            struct entry* entry = mode->entries[i];
            if(entry->what == OPTION)
            {
                struct option* option = entry->value;
                if(option->short_identifier && !option->long_identifier)
                {
                    *optwidth = _MAX(*optwidth, 2); /* 2: -%c */
                }
                else if(!option->short_identifier && option->long_identifier)
                {
                    *optwidth = _MAX(*optwidth, strlen(option->long_identifier) + 2); /* + 2: -- */
                }
                else
                {
                    *optwidth = _MAX(*optwidth, 2 + 1 + strlen(option->long_identifier) + 2); /* +1: , */
                }
            }
        }
    }

}

static void _print_help_entry(const struct entry* entry, unsigned int startskip, unsigned int leftmargin, unsigned int textwidth, unsigned int optwidth, unsigned int helpsep, int narrow)
{
    unsigned int count;
    if(entry->what == SECTION)
    {
        struct section* section = entry->value;
        puts(section->name);
    }
    else
    {
        struct option* option = entry->value;
        _print_sep(startskip);
        count = optwidth;
        if(option->short_identifier)
        {
            putchar('-');
            putchar(option->short_identifier);
            count -= 2;
        }
        if(option->short_identifier && option->long_identifier)
        {
            putchar(',');
            count -= 1;
        }
        if(option->long_identifier)
        {
            putchar('-');
            putchar('-');
            fputs(option->long_identifier, stdout);
            count -= (2 + strlen(option->long_identifier));
        }
        if(narrow)
        {
            putchar('\n');
            _print_sep(2 * startskip);
        }
        else
        {
            _print_sep(helpsep + count);
        }
        leftmargin = narrow ? 2 * startskip : startskip + optwidth + helpsep;
        print_wrapped_paragraph(option->help, textwidth, leftmargin);
    }
}

size_t _number_of_passed_options(const struct cmdoptions* options)
{
    size_t count = 0;
    struct mode* mode;
    size_t m;
    size_t i;
    for(m = 0; m < options->size; ++m)
    {
        mode = options->modes[m];
        for(i = 0; i < mode->entries_size; ++i)
        {
            const struct entry* entry = mode->entries[i];
            if(entry->what == OPTION)
            {
                struct option* option = entry->value;
                if(option->was_provided)
                {
                    ++count;
                }
            }
        }
    }
    return count;
}

static int _no_positional_parameters(const struct cmdoptions* options);
int cmdoptions_help(const struct cmdoptions* options)
{
    /* FIXME: include modes */
    unsigned int displaywidth = 80;
    unsigned int optwidth = 0;
    unsigned int i;
    unsigned int startskip = 4;
    unsigned int helpsep = 4;
    unsigned int leftmargin = 0;
    unsigned int rightmargin = 1;
    int narrow;
    unsigned int offset;
    unsigned int textwidth;
    size_t m;
    const struct mode* mode;
    const char** pospar;

    displaywidth = print_get_screen_width();

    _find_max_opt_width(options, &optwidth);

    narrow = options->force_narrow_mode || (displaywidth < 100); /* FIXME: make dynamic (dependent on maximum word width or something) */

    offset = narrow ? 2 * startskip : optwidth + startskip + helpsep;
    textwidth = displaywidth - offset - leftmargin - rightmargin;

    if(!_no_positional_parameters(options)) /* additional options are present, only print those */
    {
        mode = _get_const_basemode(options);
        pospar = cmdoptions_get_positional_parameters(options);
        while(*pospar)
        {
            int printed = 0;
            for(i = 0; i < mode->entries_size; ++i)
            {
                const struct entry* entry = mode->entries[i];
                if(entry->what == OPTION)
                {
                    struct option* option = entry->value;
                    if((*pospar)[1] == 0) /* single character */
                    {
                        if(**pospar == option->short_identifier)
                        {
                            printed = 1;
                            _print_help_entry(entry, startskip, leftmargin, textwidth, optwidth, helpsep, narrow);
                        }
                    }
                    else if(((*pospar)[0] == '-') && ((*pospar)[1] != 0) && ((*pospar)[2] == 0)) /* single character with dash */
                    {
                        if((*pospar)[1] == option->short_identifier)
                        {
                            printed = 1;
                            _print_help_entry(entry, startskip, leftmargin, textwidth, optwidth, helpsep, narrow);
                        }
                    }
                    else /* multi-character */
                    {
                        char* identifier = malloc(strlen(*pospar) + 1);
                        if(((*pospar)[0] == '-') && (*pospar)[1] == '-') /* starts with two dashes */
                        {
                            strcpy(identifier, *pospar + 2);
                        }
                        else
                        {
                            strcpy(identifier, *pospar);
                        }
                        if(strstr(option->long_identifier, identifier)) /* (partial) match */
                        {
                            printed = 1;
                            _print_help_entry(entry, startskip, leftmargin, textwidth, optwidth, helpsep, narrow);
                        }
                        free(identifier);
                    }
                }
            }
            if(!printed)
            {
                fprintf(stderr, "help: option '%s' not found\n", *pospar);
                return 0;
            }
            ++pospar;
        }
        /* FIXME: also enable for modes, although cmdline syntax is unclear */
    }
    else /* no additional options, print all */
    {
        puts(options->prehelpmsg);
        puts("list of command line options:\n");
        if(options->size > 1)
        {
            printf("%s:\n", "generic options");
        }
        mode = _get_const_basemode(options);
        for(i = 0; i < mode->entries_size; ++i)
        {
            const struct entry* entry = mode->entries[i];
            _print_help_entry(entry, startskip, leftmargin, textwidth, optwidth, helpsep, narrow);
        }
        putchar('\n');

        for(m = 1; m < options->size; ++m)
        {
            mode = options->modes[m];
            printf("%s:\n", mode->identifier);
            for(i = 0; i < mode->entries_size; ++i)
            {
                const struct entry* entry = mode->entries[i];
                _print_help_entry(entry, startskip, leftmargin, textwidth, optwidth, helpsep, narrow);
            }
            putchar('\n');
        }
        fputs(options->posthelpmsg, stdout);
        fputc('\n', stdout);
    }
    return 1;
}

static void _print_with_correct_escape_sequences(const char* str)
{
    unsigned int numescape = 0;
    const char* ptr = str;
    size_t len = strlen(str);
    char* buf;
    char* dest;

    /* count number of required escapes */
    while(*ptr)
    {
        if(*ptr == '\\')
        {
            ++numescape;
        }
        ++ptr;
    }

    /* assemble escaped string */
    buf = malloc(len + numescape + 1);
    ptr = str;
    dest = buf;
    while(*ptr)
    {
        *dest = *ptr;
        if(*ptr == '\\')
        {
            *(dest + 1) = '\\';
            ++dest;
        }
        ++ptr;
        ++dest;
    }
    *dest = 0;
    puts(buf);
    free(buf);
}

void cmdoptions_export_manpage(const struct cmdoptions* options)
{
    unsigned int m;
    unsigned int i;
    struct mode* mode;
    for(m = 0; m < options->size; ++m)
    {
        mode = options->modes[m];
        for(i = 0; i < mode->entries_size; ++i)
        {
            struct entry* entry = mode->entries[i];
            if(entry->what == OPTION)
            {
                struct option* option = entry->value;
                fputs(".IP \"\\fB\\", stdout);
                if(option->short_identifier && option->long_identifier)
                {
                    fputc('-', stdout);
                    fputc(option->short_identifier, stdout);
                    fputc(',', stdout);
                    fputc('-', stdout);
                    fputc('-', stdout);
                    fputs(option->long_identifier, stdout);
                }
                else if(option->short_identifier)
                {
                    fputc('-', stdout);
                    fputc(option->short_identifier, stdout);
                }
                else if(option->long_identifier)
                {
                    fputc('-', stdout);
                    fputc('-', stdout);
                    fputs(option->long_identifier, stdout);
                }
                printf("\\fR %s\" 4\n", "");
                _print_with_correct_escape_sequences(option->help);
            }
            else /* section */
            {
                struct section* section = entry->value;
                printf(".SS %s\n", section->name);
            }
        }
    }
}

static struct option* _get_option(struct mode* mode, char short_identifier, const char* long_identifier)
{
    unsigned int i;
    int found = 0;
    for(i = 0; i < mode->entries_size; ++i)
    {
        struct entry* entry = mode->entries[i];
        if(entry->what == OPTION)
        {
            struct option* option = entry->value;
            if(long_identifier)
            {
                found = (strcmp(option->long_identifier, long_identifier) == 0);
            }
            else
            {
                found = (option->short_identifier == short_identifier);
            }
            if(found)
            {
                if(option->aliased)
                {
                    return option->aliased;
                }
                else
                {
                    return option;
                }
            }
        }
    }
    return NULL;
}

static const struct option* _get_const_option(const struct mode* mode, char short_identifier, const char* long_identifier)
{
    unsigned int i;
    int found = 0;
    for(i = 0; i < mode->entries_size; ++i)
    {
        struct entry* entry = mode->entries[i];
        if(entry->what == OPTION)
        {
            struct option* option = entry->value;
            if(long_identifier)
            {
                found = (strcmp(option->long_identifier, long_identifier) == 0);
            }
            else
            {
                found = (option->short_identifier == short_identifier);
            }
            if(found)
            {
                if(option->aliased)
                {
                    return option->aliased;
                }
                else
                {
                    return option;
                }
            }
        }
    }
    return NULL;
}

const char** cmdoptions_get_positional_parameters(const struct cmdoptions* options)
{
    return (const char**) options->positional_parameters;
}

static int _no_positional_parameters(const struct cmdoptions* options)
{
    unsigned int count = 0;
    char** p = options->positional_parameters;
    while(*p)
    {
        ++count;
        ++p;
    }
    return count == 0;
}

int cmdoptions_help_passed(struct cmdoptions* options)
{
    return options->help_passed;
}

int cmdoptions_empty(const struct cmdoptions* options)
{
    return cmdoptions_no_args_given(options) && _no_positional_parameters(options);
}

static int _no_args_given(const struct mode* mode)
{
    unsigned int i;
    for(i = 0; i < mode->entries_size; ++i)
    {
        const struct entry* entry = mode->entries[i];
        if(entry->what == OPTION)
        {
            const struct option* option = entry->value;
            if(option->was_provided)
            {
                return 0;
            }
        }
    }
    return 1;
}

int cmdoptions_no_args_given(const struct cmdoptions* options)
{
    unsigned int m;
    int ret = 1;
    for(m = 0; m < options->size; ++m)
    {
        const struct mode* mode = options->modes[m];
        if(mode->was_selected)
        {
            ret = ret && _no_args_given(mode);
        }
    }
    return ret;
}

int cmdoptions_mode_no_args_given(const struct cmdoptions* options, const char* modename)
{
    const struct mode* mode = _find_const_mode(options, modename);
    if(!mode)
    {
        fprintf(stderr, "trying to access command-line mode '%s'. This mode does not exist\n", modename);
        return -1;
    }
    return _no_args_given(mode);
}

static int _was_provided(struct mode* mode, char short_identifier, const char* long_identifier)
{
    struct option* option = _get_option(mode, short_identifier, long_identifier);
    if(option)
    {
        option->was_checked = 1;
        return option->was_provided;
    }
    return 0;
}

static int _was_provided_short(struct mode* mode, char short_identifier)
{
    return _was_provided(mode, short_identifier, NULL);
}

int cmdoptions_was_provided_short(struct cmdoptions* options, char short_identifier)
{
    struct mode* mode = _get_basemode(options);
    return _was_provided_short(mode, short_identifier);
}

int cmdoptions_mode_was_provided_short(struct cmdoptions* options, const char* modename, char short_identifier)
{
    struct mode* mode = _find_mode(options, modename);
    if(!mode)
    {
        fprintf(stderr, "trying to access command-line option '%c' of mode '%s'. This mode does not exist\n", short_identifier, modename);
        return 0;
    }
    return _was_provided_short(mode, short_identifier);
}

static int _was_provided_long(struct mode* mode, const char* long_identifier)
{
    return _was_provided(mode, 0, long_identifier);
}

int cmdoptions_was_provided_long(struct cmdoptions* options, const char* long_identifier)
{
    struct mode* mode = _get_basemode(options);
    return _was_provided_long(mode, long_identifier);
}

int cmdoptions_mode_was_provided_long(struct cmdoptions* options, const char* modename, const char* long_identifier)
{
    struct mode* mode = _find_mode(options, modename);
    if(!mode)
    {
        fprintf(stderr, "trying to access command-line option '%s' of mode '%s'. This mode does not exist\n", long_identifier, modename);
        return 0;
    }
    return _was_provided_long(mode, long_identifier);
}

int _store_argument(struct option* option, int* iptr, int argc, const char* const * argv)
{
    int j;
    int len;
    char** argument;
    if(option->numargs)
    {
        if(*iptr < argc - 1)
        {
            if(option->numargs & MULTI_ARGS)
            {
                if(!option->argument)
                {
                    argument = calloc(2, sizeof(char*));
                    argument[0] = malloc(strlen(argv[*iptr + 1]) + 1);
                    strcpy(argument[0], argv[*iptr + 1]);
                    option->argument = argument;
                }
                else
                {
                    if(!option->was_provided) /* default argument */
                    {
                        /* FIXME: this if-branch is currently untested and might result in memory access errors */
                        char** p = option->argument;
                        while(*p)
                        {
                            free(*p);
                            ++p;
                        }
                        /* start new with only terminator */
                        free(option->argument);
                        char** new = malloc(sizeof(*new));
                        new[0] = NULL;
                        option->argument = new;
                    }
                    char** ptr = option->argument;
                    while(*ptr) { ++ptr; }
                    len = ptr - (char**)option->argument;
                    argument = calloc(len + 2, sizeof(char*));
                    for(j = 0; j < len; ++j)
                    {
                        argument[j] = ((char**)option->argument)[j];
                    }
                    argument[len] = malloc(strlen(argv[*iptr + 1]) + 1);
                    strcpy(argument[len], argv[*iptr + 1]);
                    free(option->argument);
                    option->argument = argument;
                }
            }
            else /* SINGLE_ARG option */
            {
                if(option->argument && !option->was_provided) /* default argument */
                {
                    free(option->argument);
                }
                option->argument = malloc(strlen(argv[*iptr + 1]) + 1);
                strcpy(option->argument, argv[*iptr + 1]);
            }
        }
        else /* argument required, but not entries in argv left */
        {
            if(option->long_identifier)
            {
                printf("expected argument for option '%s'\n", option->long_identifier);
            }
            else
            {
                printf("expected argument for option '%c'\n", option->short_identifier);
            }
            return 0;
        }
        *iptr += 1;
    }
    return 1;
}

int cmdoptions_parse(struct cmdoptions* options, int argc, const char* const * argv)
{
    int endofoptions = 0;
    int i;
    struct mode* mode = _get_basemode(options);
    for(i = 1; i < argc; ++i)
    {
        const char* arg = argv[i];
        if(!endofoptions && arg[0] == '-' && arg[1] == 0) /* single dash (-) */
        {
            /* FIXME: handle single dash */
        }
        else if(!endofoptions && arg[0] == '-' && arg[1] == '-' && arg[2] == 0) /* end of options (--) */
        {
            endofoptions = 1;
        }
        /* special help mode (-h/--help as *first* argument) */
        else if(!endofoptions &&
            (
                (arg[0] == '-' && arg[1] == 'h') ||
                (arg[0] == '-' && arg[1] == '-' && arg[2] == 'h' && arg[3] == 'e' && arg[4] == 'l' && arg[5] == 'p')
            ) /* yes, it's ugly, but simple */
        )
        {
            endofoptions = 1; /* causes all subsequent parameters to be parsed as positional parameters */
            options->help_passed = 1;
        }
        else if(!endofoptions && i == 1 && arg[0] != '-') /* mode */
        {
            /* FIXME: the current parsing does not support command lines such as:
             * cmd --generic-option mode --mode-argument 42
             */
            mode = _find_mode(options, arg);
            if(!mode) /* non-existing mode is a parse error */
            {
                return 0;
            }
            mode->was_selected = 1;
        }
        else if(!endofoptions && arg[0] == '-') /* option */
        {
            if(arg[1] == '-') /* long option */
            {
                const char* longopt = arg + 2;
                struct option* option = _get_option(mode, 0, longopt);
                if(!option)
                {
                    printf("unknown command line option: '--%s'\n", longopt);
                    return 0;
                }
                else
                {
                    if(option->was_provided && !(option->numargs & MULTI_ARGS))
                    {
                        printf("option '%s' is only allowed once\n", longopt);
                    }
                    if(!_store_argument(option, &i, argc, argv))
                    {
                        return 0;
                    }
                    /* was_provided is checked in _store_argument, so this has to come after the _store_argument call */
                    option->was_provided = 1;
                }
            }
            else /* short option */
            {
                const char* ch = arg + 1;
                while(*ch)
                {
                    char shortopt = *ch;
                    struct option* option = _get_option(mode, shortopt, NULL);
                    if(!option)
                    {
                        printf("unknown command line option: '-%c'\n", shortopt);
                        return 0;
                    }
                    else
                    {
                        if(option->was_provided && !(option->numargs & MULTI_ARGS))
                        {
                            printf("option '%c' is only allowed once\n", shortopt);
                            return 0;
                        }
                        option->was_provided = 1;
                        if(!_store_argument(option, &i, argc, argv))
                        {
                            return 0;
                        }
                    }
                    ++ch;
                }
            }
        }
        else /* positional parameter */
        {
            unsigned int count = 0;
            char** p = options->positional_parameters;
            while(*p)
            {
                ++count;
                ++p;
            }
            char** positional_parameters = realloc(
                options->positional_parameters,
                sizeof(*options->positional_parameters) * (count + 2)); /* one more for the sentinel */
            if(!positional_parameters)
            {
                options->valid = 0;
                return 0;
            }
            options->positional_parameters = positional_parameters;
            options->positional_parameters[count] = malloc(strlen(arg) + 1);
            strcpy(options->positional_parameters[count], arg);
            options->positional_parameters[count + 1] = NULL; /* terminate */
        }
    }
    return 1;
}

static const void* _get_argument_short(const struct mode* mode, char short_identifier)
{
    const struct option* option = _get_const_option(mode, short_identifier, NULL);
    if(option)
    {
        return option->argument;
    }
    return NULL;
}

const void* cmdoptions_get_argument_short(struct cmdoptions* options, char short_identifier)
{
    const struct mode* mode = _get_const_basemode(options);
    return _get_argument_short(mode, short_identifier);
}

const void* cmdoptions_mode_get_argument_short(struct cmdoptions* options, const char* modename, char short_identifier)
{
    const struct mode* mode = _find_const_mode(options, modename);
    if(!mode)
    {
        fprintf(stderr, "trying to access command-line option '%c' of mode '%s'. This mode does not exist\n", short_identifier, modename);
        return NULL;
    }
    return _get_argument_short(mode, short_identifier);
}

static const void* _get_argument_long(const struct mode* mode, const char* long_identifier)
{
    const struct option* option = _get_const_option(mode, 0, long_identifier);
    if(option)
    {
        return option->argument;
    }
    return NULL;
}

const void* cmdoptions_get_argument_long(struct cmdoptions* options, const char* long_identifier)
{
    const struct mode* mode = _get_const_basemode(options);
    return _get_argument_long(mode, long_identifier);
}

const void* cmdoptions_mode_get_argument_long(struct cmdoptions* options, const char* modename, const char* long_identifier)
{
    const struct mode* mode = _find_const_mode(options, modename);
    if(!mode)
    {
        fprintf(stderr, "trying to access command-line option '%s' of mode '%s'. This mode does not exist\n", long_identifier, modename);
        return NULL;
    }
    return _get_argument_long(mode, long_identifier);
}

