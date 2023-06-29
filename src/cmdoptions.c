#include "cmdoptions.h"

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <sys/ioctl.h>
#include <err.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>

#include "util.h"

struct option {
    char short_identifier;
    const char* long_identifier;
    int numargs;
    void* argument; /* is char* for once-only options, char** (with NULL terminator) for multiple options */
    int was_provided;
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
struct cmdoptions {
    struct vector* entries;
    struct vector* positional_parameters;
    struct const_vector* prehelpmsg;
    struct const_vector* posthelpmsg;
    int force_narrow_mode;
};


static void _destroy_argument(void* argument, int numargs)
{
    if(numargs & MULTI_ARGS)
    {
        char** p = argument;
        while(*p)
        {
            free(*p);
            ++p;
        }
    }
    free(argument);
}

static void _destroy_option(void* ptr)
{
    struct entry* entry = ptr;
    if(entry->what == OPTION)
    {
        struct option* option = entry->value;
        if(option->argument)
        {
            _destroy_argument(option->argument, option->numargs);
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

struct cmdoptions* cmdoptions_create(void)
{
    struct cmdoptions* options = malloc(sizeof(*options));
    options->entries = vector_create(128, _destroy_option);
    options->positional_parameters = vector_create(8, free);
    options->prehelpmsg = const_vector_create(1);
    options->posthelpmsg = const_vector_create(1);
    options->force_narrow_mode = 0;
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

void cmdoptions_destroy(struct cmdoptions* options)
{
    vector_destroy(options->entries);
    vector_destroy(options->positional_parameters);
    const_vector_destroy(options->prehelpmsg);
    const_vector_destroy(options->posthelpmsg);
    free(options);
}

void cmdoptions_exit(struct cmdoptions* options, int exitcode)
{
    cmdoptions_destroy(options);
    exit(exitcode);
}

void cmdoptions_add_section(struct cmdoptions* options, const char* name)
{
    struct section* section = malloc(sizeof(*section));
    section->name = util_strdup(name);
    struct entry* entry = malloc(sizeof(*entry));
    entry->what = SECTION;
    entry->value = section;
    vector_append(options->entries, entry);
}

static struct entry* _create_option(char short_identifier, const char* long_identifier, int numargs, const char* help)
{
    struct option* option = malloc(sizeof(*option));
    option->short_identifier = short_identifier;
    option->long_identifier = long_identifier;
    option->numargs = numargs;
    option->argument = NULL;
    option->was_provided = 0;
    option->help = help;
    option->aliased = NULL;
    struct entry* entry = malloc(sizeof(*entry));
    entry->value = option;
    entry->what = OPTION;
    return entry;
}

void cmdoptions_add_alias(struct cmdoptions* options, const char* long_aliased_identifier, char short_identifier, const char* long_identifier, const char* help)
{
    struct option* alias = NULL;
    for(unsigned int i = 0; i < vector_size(options->entries); ++i)
    {
        struct entry* entry = vector_get(options->entries, i);
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

    struct entry* entry = _create_option(short_identifier, long_identifier, 0, help); // num_args will never be used
    ((struct option*)entry->value)->aliased = alias;
    vector_append(options->entries, entry);
}

void cmdoptions_add_option(struct cmdoptions* options, char short_identifier, const char* long_identifier, int numargs, const char* help)
{
    struct entry* entry = _create_option(short_identifier, long_identifier, numargs, help);
    vector_append(options->entries, entry);
}

void cmdoptions_add_option_default(struct cmdoptions* options, char short_identifier, const char* long_identifier, int numargs, const char* default_arg, const char* help)
{
    struct entry* entry = _create_option(short_identifier, long_identifier, numargs, help);
    if(numargs > 1)
    {
        const char** arg = calloc(2, sizeof(*arg));
        arg[0] = util_strdup(default_arg);
        arg[1] = NULL;
        ((struct option*)entry->value)->argument = arg;
    }
    else
    {
        ((struct option*)entry->value)->argument = util_strdup(default_arg);
    }
    vector_append(options->entries, entry);
}

void cmdoptions_prepend_help_message(struct cmdoptions* options, const char* msg)
{
    const_vector_append(options->prehelpmsg, msg);
}

void cmdoptions_append_help_message(struct cmdoptions* options, const char* msg)
{
    const_vector_append(options->posthelpmsg, msg);
}

static int _get_screen_width(unsigned int* width)
{
    struct winsize ws;
    int fd;

    fd = open("/dev/tty", O_RDWR);
    if(fd < 0 || ioctl(fd, TIOCGWINSZ, &ws) < 0)
    {
        err(8, "/dev/tty");
        return 0;
    }

    close(fd);

    *width = ws.ws_col;
    return 1;
}

static void _print_sep(unsigned int num)
{
    for(unsigned int i = 0; i < num; ++i)
    {
        putchar(' ');
    }
}

static void _put_line(unsigned int textwidth, unsigned int* linewidth, const char** ch, const char* wptr, unsigned int leftmargin)
{
    if(*linewidth + wptr - *ch > textwidth)
    {
        *linewidth = 0;
        putchar('\n');
        _print_sep(leftmargin - 1);
    }
    *linewidth += (wptr - *ch);
    while(*ch < wptr)
    {
        putchar(**ch);
        ++(*ch);
    }
}

static void _print_wrapped_paragraph(const char* text, unsigned int textwidth, unsigned int leftmargin)
{
    const char* ch = text;
    const char* wptr = ch;
    unsigned int linewidth = 0;
    while(*wptr)
    {
        if(*wptr == ' ')
        {
            _put_line(textwidth, &linewidth, &ch, wptr, leftmargin);
        }
        ++wptr;
    }
    _put_line(textwidth, &linewidth, &ch, wptr, leftmargin);
}

void cmdoptions_help(struct cmdoptions* options)
{
    unsigned int displaywidth = 80;
    _get_screen_width(&displaywidth);

    unsigned int optwidth = 0;
    for(unsigned int i = 0; i < vector_size(options->entries); ++i)
    {
        struct entry* entry = vector_get(options->entries, i);
        if(entry->what == OPTION)
        {
            struct option* option = entry->value;
            if(option->short_identifier && !option->long_identifier)
            {
                optwidth = util_max(optwidth, 2); // 2: -%c
            }
            else if(!option->short_identifier && option->long_identifier)
            {
                optwidth = util_max(optwidth, strlen(option->long_identifier) + 2); // + 2: --
            }
            else
            {
                optwidth = util_max(optwidth, 2 + 1 + strlen(option->long_identifier) + 2); // +1: ,
            }
        }
    }

    unsigned int startskip = 4;
    unsigned int helpsep = 4;
    unsigned int leftmargin = 0;
    unsigned int rightmargin = 1;
    int narrow = options->force_narrow_mode || (displaywidth < 100); // FIXME: make dynamic (dependent on maximum word width or something)
    unsigned int offset = narrow ? 2 * startskip : optwidth + startskip + helpsep;
    unsigned int textwidth = displaywidth - offset - leftmargin - rightmargin;

    for(unsigned int i = 0; i < const_vector_size(options->prehelpmsg); ++i)
    {
        const char* msg = const_vector_get(options->prehelpmsg, i);
        puts(msg);
    }
    puts("list of command line options:\n");
    for(unsigned int i = 0; i < vector_size(options->entries); ++i)
    {
        struct entry* entry = vector_get(options->entries, i);
        if(entry->what == SECTION)
        {
            struct section* section = entry->value;
            puts(section->name);
        }
        else
        {
            struct option* option = entry->value;
            _print_sep(startskip);
            unsigned int count = optwidth;
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
            unsigned int leftmargin = narrow ? 2 * startskip : startskip + optwidth + helpsep;
            _print_wrapped_paragraph(option->help, textwidth, leftmargin);
            putchar('\n');
        }
    }
    for(unsigned int i = 0; i < const_vector_size(options->posthelpmsg); ++i)
    {
        const char* msg = const_vector_get(options->posthelpmsg, i);
        puts(msg);
    }
}

static void _print_with_correct_escape_sequences(const char* str)
{
    unsigned int numescape = 0;
    const char* ptr = str;
    while(*ptr)
    {
        if(*ptr == '\\')
        {
            ++numescape;
        }
        ++ptr;
    }
    size_t len = strlen(str);
    char* buf = malloc(len + numescape + 1);
    ptr = str;
    char* dest = buf;
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

void cmdoptions_export_manpage(struct cmdoptions* options)
{
    for(unsigned int i = 0; i < vector_size(options->entries); ++i)
    {
        struct entry* entry = vector_get(options->entries, i);
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
        else // section
        {
            struct section* section = entry->value;
            printf(".SS %s\n", section->name);
        }
    }
}

struct option* cmdoptions_get_option_short(struct cmdoptions* options, char short_identifier)
{
    for(unsigned int i = 0; i < vector_size(options->entries); ++i)
    {
        struct entry* entry = vector_get(options->entries, i);
        if(entry->what == OPTION)
        {
            struct option* option = entry->value;
            if(option->short_identifier == short_identifier)
            {
                return option;
            }
        }
    }
    return NULL;
}

struct option* cmdoptions_get_option_long(struct cmdoptions* options, const char* long_identifier)
{
    for(unsigned int i = 0; i < vector_size(options->entries); ++i)
    {
        struct entry* entry = vector_get(options->entries, i);
        if(entry->what == OPTION)
        {
            struct option* option = entry->value;
            if(strcmp(option->long_identifier, long_identifier) == 0)
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

struct vector* cmdoptions_get_positional_parameters(struct cmdoptions* options)
{
    return options->positional_parameters;
}

int cmdoptions_was_provided_long(struct cmdoptions* options, const char* opt)
{
    for(unsigned int i = 0; i < vector_size(options->entries); ++i)
    {
        struct entry* entry = vector_get(options->entries, i);
        if(entry->what == OPTION)
        {
            struct option* option = entry->value;
            if(strcmp(option->long_identifier, opt) == 0)
            {
                return option->was_provided;
            }
        }
    }
    return 0;
}

int _store_argument(struct option* option, int* iptr, int argc, const char* const * argv)
{
    if(option->numargs)
    {
        if(*iptr < argc - 1)
        {
            if(option->numargs & MULTI_ARGS)
            {
                if(!option->argument)
                {
                    char** argument = calloc(2, sizeof(char*));
                    argument[0] = util_strdup(argv[*iptr + 1]);
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
                    int len = ptr - (char**)option->argument;
                    char** argument = calloc(len + 2, sizeof(char*));
                    for(int j = 0; j < len; ++j)
                    {
                        argument[j] = ((char**)option->argument)[j];
                    }
                    argument[len] = util_strdup(argv[*iptr + 1]);
                    free(option->argument);
                    option->argument = argument;
                }
            }
            else // SINGLE_ARG option
            {
                if(option->argument && !option->was_provided) /* default argument */
                {
                    free(option->argument);
                }
                option->argument = util_strdup(argv[*iptr + 1]);
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
                    struct option* option = cmdoptions_get_option_short(options, shortopt);
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
            vector_append(options->positional_parameters, util_strdup(arg));
        }
    }
    return 1;
}

void* cmdoptions_get_argument_long(struct cmdoptions* options, const char* long_identifier)
{
    for(unsigned int i = 0; i < vector_size(options->entries); ++i)
    {
        struct entry* entry = vector_get(options->entries, i);
        if(entry->what == OPTION)
        {
            struct option* option = entry->value;
            if(strcmp(option->long_identifier, long_identifier) == 0)
            {
                return option->argument;
            }
        }
    }
    return NULL;
}

