#include "main.api_help.h"

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "terminal_colors.h"
#include "util.h"
#include "vector.h"

#define API_HELP_TYPE_VARARGS   COLOR_BOLD COLOR_RGB(0, 0, 0)
#define API_HELP_TYPE_ANY       COLOR_BOLD COLOR_RGB(0, 0, 0)
#define API_HELP_TYPE_FUNCTION  COLOR_BOLD COLOR_RGB(0, 0, 0)
#define API_HELP_TYPE_TABLE     COLOR_BOLD COLOR_RGB(0, 0, 0)
#define API_HELP_TYPE_BOOLEAN   COLOR_BOLD COLOR_RGB(0, 0, 0)
#define API_HELP_TYPE_STRING    COLOR_BOLD COLOR_RGB(100, 205, 0)
#define API_HELP_TYPE_OBJECT    COLOR_BOLD COLOR_RGB(0, 180, 140)
#define API_HELP_TYPE_INTEGER   COLOR_BOLD COLOR_RGB(230, 0, 120)
#define API_HELP_TYPE_NUMBER    COLOR_BOLD COLOR_RGB(230, 0, 120)
#define API_HELP_TYPE_GENERICS  COLOR_BOLD COLOR_RGB(0, 80, 200)
#define API_HELP_TYPE_POINT     COLOR_BOLD COLOR_RGB(255, 128, 0)

static int _is_func(const char* tocheck, const char* func, const char* module)
{
    if(module)
    {
        char* fullname = malloc(strlen(func) + strlen(module) + 1 + 1); // extra +1: '.'
        sprintf(fullname, "%s.%s", module, func);
        int match = (strcmp(tocheck, func) == 0) || (strcmp(tocheck, fullname) == 0);
        free(fullname);
        return match;
    }
    else
    {
        return (strcmp(tocheck, func) == 0);
    }
}

struct parameter {
    char* name;
    enum {
        VARARGS,
        ANY,
        FUNCTION,
        TABLE,
        BOOLEAN,
        STRING,
        OBJECT,
        GENERICS,
        INTEGER,
        NUMBER,
        POINT,
        POINTLIST
    } type;
    char* default_value;
    char* text;
};

enum module {
    MODULE_NONE,
    MODULE_OBJECT,
    MODULE_GEOMETRY,
    MODULE_POINT,
    MODULE_TECHNOLOGY,
    MODULE_GENERICS,
    MODULE_PCELL,
    MODULE_UTIL,
    MODULE_PLACEMENT,
    MODULE_ROUTING,
    MODULE_CURVE,
    MODULE_LAYOUTHELPERS
};

struct api_entry {
    char* funcname;
    enum module module;
    char* info;
    char* example;
    struct vector* parameters;
};

static const char* _stringify_module(enum module module)
{
    switch(module)
    {
        case MODULE_NONE:
            return NULL;
        case MODULE_OBJECT:
            return "object";
        case MODULE_GEOMETRY:
            return "geometry";
        case MODULE_TECHNOLOGY:
            return "technology";
        case MODULE_PCELL:
            return "pcell";
        case MODULE_GENERICS:
            return "generics";
        case MODULE_CURVE:
            return "curve";
        case MODULE_ROUTING:
            return "routing";
        case MODULE_PLACEMENT:
            return "placement";
        case MODULE_POINT:
            return "point";
        case MODULE_UTIL:
            return "util";
        case MODULE_LAYOUTHELPERS:
            return "layouthelpers";
    }
    return NULL; // make the compiler happy
}

static int _pstrlen(const char* str)
{
    const char* ptr = str;
    int len = 0;
    while(*ptr)
    {
        if(*ptr == '\033')
        {
            while(*ptr != 'm')
            {
                ++ptr;
            }
            ++ptr; // skip 'm'
            if(!*ptr)
            {
                break;
            }
        }
        ++len;
        ++ptr;
    }
    return len;
}

static const char* _get_color(const char* identifier, size_t len)
{
    static const char* identifiers[] = {
        "RESET",
        "OBJECT",
        "INTEGER",
        "NUMBER",
        "GENERICS",
        "STRING"
    };
    static const char* escape_sequences[] = {
        "\033[0m",
        API_HELP_TYPE_OBJECT,
        API_HELP_TYPE_INTEGER,
        API_HELP_TYPE_NUMBER,
        API_HELP_TYPE_GENERICS,
        API_HELP_TYPE_STRING
    };
    for(size_t i = 0; i < sizeof(identifiers) / sizeof(identifiers[0]); ++i)
    {
        if(strncmp(identifier, identifiers[i], len) == 0)
        {
            return escape_sequences[i];
            break;
        }
    }
    return NULL;
}

static void _append_to_string(char** str, size_t* length, size_t* capacity, char ch)
{
    if(*length == *capacity - 1)
    {
        *capacity *= 2;
        char* tmp = realloc(*str, *capacity);
        *str = tmp;
    }
    *(*str + *length) = ch;
    ++(*length);
}

// FIXME: is this even really used any more?
static char* _resolve_color_commands(const char* str)
{
    size_t capacity = 32;
    size_t length = 0;
    char* resolved = malloc(capacity);
    const char* sptr = str;
    while(*sptr)
    {
        if(*sptr == '$')
        {
            const char* cptr = sptr;
            do {
                ++sptr;
            } while(*sptr != '$');
            const char* sequence = _get_color(cptr + 1, sptr - cptr - 1);
            if(sequence)
            {
                while(*sequence)
                {
                    _append_to_string(&resolved, &length, &capacity, *sequence);
                    ++sequence;
                }
            }
            ++sptr;
        }
        _append_to_string(&resolved, &length, &capacity, *sptr);
        ++sptr;
    }
    _append_to_string(&resolved, &length, &capacity, 0);
    return resolved;
}

static void _putstr(const char* str)
{
    char* resolved = _resolve_color_commands(str);
    fputs(resolved, stdout);
    free(resolved);
}

static void _print_escaped_string(const char* str, int width)
{
    int w = _pstrlen(str);
    for(int i = 0; i < width - w; ++i)
    {
        putchar(' ');
    }
    _putstr(str);
}

static int _get_type_width(const struct parameter* parameter)
{
    int defshift = 0;
    if(parameter->default_value)
    {
        defshift = 17 + strlen(parameter->default_value);
    }
    switch(parameter->type)
    {
        case VARARGS:
            return defshift + 3;
        case ANY:
            return defshift + 3;
        case FUNCTION:
            return defshift + 8;
        case TABLE:
            return defshift + 5;
        case STRING:
            return defshift + 6;
        case OBJECT:
            return defshift + 6;
        case GENERICS:
            return defshift + 8;
        case NUMBER:
            return defshift + 6;
        case INTEGER:
            return defshift + 7;
        case BOOLEAN:
            return defshift + 7;
        case POINT:
            return defshift + 5;
        case POINTLIST:
            return defshift + 9;
    }
    return 0; // make the compiler happy
}

static const char* _get_param_color(const struct parameter* parameter)
{
    switch(parameter->type)
    {
        case VARARGS:
            return API_HELP_TYPE_VARARGS;
        case ANY:
            return API_HELP_TYPE_ANY;
        case FUNCTION:
            return API_HELP_TYPE_FUNCTION;
        case BOOLEAN:
            return API_HELP_TYPE_BOOLEAN;
        case TABLE:
            return API_HELP_TYPE_TABLE;
        case STRING:
            return API_HELP_TYPE_STRING;
        case OBJECT:
            return API_HELP_TYPE_OBJECT;
        case GENERICS:
            return API_HELP_TYPE_GENERICS;
        case NUMBER:
            return API_HELP_TYPE_NUMBER;
        case INTEGER:
            return API_HELP_TYPE_INTEGER;
        case POINT:
            return API_HELP_TYPE_POINT;
        case POINTLIST:
            return API_HELP_TYPE_POINT;
    }
    return COLOR_NORMAL; // make the compiler happy
}

static void _print_parameter(const struct parameter* parameter, int namewidth, int typewidth)
{
    // name
    _putstr("    ");
    _print_escaped_string(parameter->name, namewidth);

    // type
    putchar(' ');
    putchar('(');
    int tw = _get_type_width(parameter);
    switch(parameter->type)
    {
        case VARARGS:
            _putstr(API_HELP_TYPE_VARARGS "...");
            break;
        case ANY:
            _putstr(API_HELP_TYPE_ANY "any");
            break;
        case FUNCTION:
            _putstr(API_HELP_TYPE_FUNCTION "function");
            break;
        case BOOLEAN:
            _putstr(API_HELP_TYPE_BOOLEAN "boolean");
            break;
        case TABLE:
            _putstr(API_HELP_TYPE_TABLE "table");
            break;
        case STRING:
            _putstr(API_HELP_TYPE_STRING "string");
            break;
        case OBJECT:
            _putstr(API_HELP_TYPE_OBJECT "object");
            break;
        case GENERICS:
            _putstr(API_HELP_TYPE_GENERICS "generics");
            break;
        case NUMBER:
            _putstr(API_HELP_TYPE_NUMBER "number");
            break;
        case INTEGER:
            _putstr(API_HELP_TYPE_INTEGER "integer");
            break;
        case POINT:
            _putstr(API_HELP_TYPE_POINT "point");
            break;
        case POINTLIST:
            _putstr(API_HELP_TYPE_POINT "pointlist");
            break;
    }
    _putstr(COLOR_NORMAL);
    for(int i = 0; i < typewidth - tw; ++i)
    {
        putchar(' ');
    }

    if(parameter->default_value)
    {
        _putstr(", default value: ");
        _putstr(parameter->default_value);
    }
    putchar(')');
    
    // text
    putchar(':');
    putchar(' ');
    _putstr(parameter->text);
    putchar('\n');
}

static void _print_parameters(const struct vector* parameters)
{
    int namewidth = 0;
    int typewidth = 0;
    struct vector_const_iterator* it = vector_const_iterator_create(parameters);
    while(vector_const_iterator_is_valid(it))
    {
        const struct parameter* param = vector_const_iterator_get(it);
        int nw = _pstrlen(param->name);
        if(nw > namewidth) { namewidth = nw; }
        int tw = _get_type_width(param);
        if(tw > typewidth) { typewidth = tw; }
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);

    if(vector_size(parameters) > 0)
    {
        terminal_set_bold();
        terminal_set_color_RGB(255, 0, 185);
        _putstr("Parameters:");
        terminal_reset_color();
        putchar('\n');
        it = vector_const_iterator_create(parameters);
        while(vector_const_iterator_is_valid(it))
        {
            const struct parameter* param = vector_const_iterator_get(it);
            _print_parameter(param, namewidth, typewidth);
            vector_const_iterator_next(it);
        }
        vector_const_iterator_destroy(it);
    }
}

static struct parameter* _copy_parameter(const struct parameter* param)
{
    struct parameter* new = malloc(sizeof(*new));
    new->name = util_strdup(param->name);
    new->type = param->type;
    if(param->default_value)
    {
        new->default_value = util_strdup(param->default_value);
    }
    else
    {
        new->default_value = NULL;
    }
    new->text = util_strdup(param->text);
    return new;
}

static void _destroy_parameter(void* v)
{
    struct parameter* parameter = v;
    free(parameter->name);
    free(parameter->text);
    if(parameter->default_value)
    {
        free(parameter->default_value);
    }
    free(parameter);
}

static struct api_entry* _make_api_entry(
    const char* funcname,
    enum module module,
    const char* info,
    const char* example,
    struct parameter* parameters, size_t len
)
{
    struct api_entry* entry = malloc(sizeof(*entry));
    entry->funcname = util_strdup(funcname);
    entry->module = module;
    entry->info = util_strdup(info);
    entry->example = util_strdup(example);
    entry->parameters = vector_create(len, _destroy_parameter);
    for(size_t i = 0; i < len; ++i)
    {
        vector_append(entry->parameters, _copy_parameter(parameters + i));
    }
    return entry;
}

static void _destroy_api_entry(void* v)
{
    struct api_entry* entry = v;
    free(entry->funcname);
    free(entry->info);
    free(entry->example);
    vector_destroy(entry->parameters);
    free(entry);
}

/*
static void _print_with_newlines_and_offset(const char* str, unsigned int offset)
{
    const char* ptr = str;
    while(*ptr)
    {
        putchar(*ptr);
        if(*ptr == '\n')
        {
            for(unsigned int i = 0; i < offset; ++i)
            {
                putchar(' ');
            }
        }
        ++ptr;
    }
}
*/

static void _print_api_entry(const struct api_entry* entry)
{
    // function name
    putchar('\n');
    terminal_set_bold();
    terminal_set_color_RGB(255, 0, 185);
    _putstr("Syntax: ");
    terminal_reset_color();
    if(entry->module != MODULE_NONE)
    {
        _putstr(_stringify_module(entry->module));
        putchar('.');
    }
    _putstr(entry->funcname);
    putchar('(');

    // argument list
    for(size_t i = 0; i < vector_size(entry->parameters); ++i)
    {
        const struct parameter* param = vector_get_const(entry->parameters, i);

        _putstr(_get_param_color(param));
        _putstr(param->name);
        _putstr(COLOR_NORMAL);
        if(i < vector_size(entry->parameters) - 1)
        {
            putchar(',');
            putchar(' ');
        }
    }

    _putstr(")");
    
    // function info
    putchar('\n');
    _putstr(entry->info);
    putchar('\n');
    putchar('\n');

    // detailed parameter list
    _print_parameters(entry->parameters);

    putchar('\n');

    // function example
    terminal_set_bold();
    terminal_set_color_RGB(255, 0, 185);
    _putstr("Example: ");
    terminal_reset_color();
    putchar('\n');
    // FIXME: make _print_with_newlines_and_offset color-aware
    //_print_with_newlines_and_offset(entry->example, 9); // 9: strlen("Example: ")
    _putstr(entry->example);

    putchar('\n');
}

static struct vector* _initialize_api_entries(void)
{
    /* initialize entries */
    struct vector* entries = vector_create(32, _destroy_api_entry);

#include "main.api_help/aux.c"
#include "main.api_help/curve.c"
#include "main.api_help/generics.c"
#include "main.api_help/geometry.c"
#include "main.api_help/global.c"
#include "main.api_help/graphics.c"
#include "main.api_help/layouthelpers.c"
#include "main.api_help/object.c"
#include "main.api_help/pcell.c"
#include "main.api_help/placement.c"
#include "main.api_help/placer.c"
#include "main.api_help/point.c"
#include "main.api_help/router.c"
#include "main.api_help/routing.c"
#include "main.api_help/technology.c"
#include "main.api_help/util.c"

    return entries;
}

static void _destroy_api_entries(struct vector* entries)
{
    vector_destroy(entries);
}

void main_API_help(const char* funcname)
{
    struct vector* entries = _initialize_api_entries();

    /* search and print API info */
    int found = 0;
    struct vector_const_iterator* it = vector_const_iterator_create(entries);
    while(vector_const_iterator_is_valid(it))
    {
        const struct api_entry* entry = vector_const_iterator_get(it);
        if(_is_func(funcname, entry->funcname, _stringify_module(entry->module)))
        {
            _print_api_entry(entry);
            found = 1;
            break;
        }
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);

    if(!found)
    {
        printf("no help entry for '%s' was found (use --api-search to find help entries)\n", funcname);
    }
    _destroy_api_entries(entries);
}

void main_API_search(const char* name)
{
    struct vector* entries = _initialize_api_entries();
    struct vector_const_iterator* it = vector_const_iterator_create(entries);
    unsigned int found = 0;
    while(vector_const_iterator_is_valid(it))
    {
        const struct api_entry* entry = vector_const_iterator_get(it);
        const char* ffound = strstr(entry->funcname, name);
        const char* mfound = NULL;
        const char* modulename = _stringify_module(entry->module);
        if(modulename)
        {
            mfound = strstr(modulename, name);
        }
        if(ffound || mfound)
        {
            ++found;
            if(modulename)
            {
                _putstr(modulename);
                putchar('.');
                _putstr(entry->funcname);
                putchar('\n');
            }
            else
            {
                _putstr(entry->funcname);
                putchar('\n');
            }
        }
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
    _destroy_api_entries(entries);
    if(found == 0)
    {
        puts("no entries found");
    }
}

void main_API_list(void)
{
    struct vector* entries = _initialize_api_entries();
    struct vector_const_iterator* it = vector_const_iterator_create(entries);
    while(vector_const_iterator_is_valid(it))
    {
        const struct api_entry* entry = vector_const_iterator_get(it);
        const char* modulename = _stringify_module(entry->module);
        if(modulename)
        {
            _putstr(modulename);
            putchar('.');
            _putstr(entry->funcname);
            putchar('\n');
        }
        else
        {
            _putstr(entry->funcname);
            putchar('\n');
        }
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
    _destroy_api_entries(entries);
}

static void _create_latex_entry(const struct api_entry* entry, const char** lastmodule)
{
    const char* module = _stringify_module(entry->module);
    if(module)
    {
        if(!(*lastmodule) || strcmp(module, *lastmodule) != 0)
        {
            printf("\\subsection{%s Module}\n", module);
        }
    }
    *lastmodule = module;
    if(entry->module != MODULE_NONE)
    {
        printf("\\begin{APIfunc}{%s.%s(", _stringify_module(entry->module), entry->funcname);
    }
    else
    {
        printf("\\begin{APIfunc}{%s(", entry->funcname);
    }
    for(size_t i = 0; i < vector_size(entry->parameters); ++i)
    {
        const struct parameter* param = vector_get_const(entry->parameters, i);
        printf("%s", param->name);
        if(i < vector_size(entry->parameters) - 1)
        {
            putchar(',');
            putchar(' ');
        }
    }
    printf("%s\n", ")}");

    // function info
    printf("    %s\n", entry->info);

    // detailed parameter list
    struct vector_const_iterator* it = vector_const_iterator_create(entry->parameters);
    puts("    \\begin{APIparameters}");
    while(vector_const_iterator_is_valid(it))
    {
        const struct parameter* parameter = vector_const_iterator_get(it);
        {
            // name
            printf("        \\parameter{%s}{", parameter->name);

            // type
            switch(parameter->type)
            {
                case VARARGS:
                    fputs("...", stdout);
                    break;
                case ANY:
                    fputs("any", stdout);
                    break;
                case FUNCTION:
                    fputs("function", stdout);
                    break;
                case BOOLEAN:
                    fputs("boolean", stdout);
                    break;
                case TABLE:
                    fputs("table", stdout);
                    break;
                case STRING:
                    fputs("string", stdout);
                    break;
                case OBJECT:
                    fputs("object", stdout);
                    break;
                case GENERICS:
                    fputs("generics", stdout);
                    break;
                case NUMBER:
                    fputs("number", stdout);
                    break;
                case INTEGER:
                    fputs("integer", stdout);
                    break;
                case POINT:
                    fputs("point", stdout);
                    break;
                case POINTLIST:
                    fputs("pointlist", stdout);
                    break;
            }
            puts("}");

            /*
            if(parameter->default_value)
            {
                _putstr(", default value: ");
                _putstr(parameter->default_value);
            }
            putchar(')');
            */
            
            // text
            printf("            %s", parameter->text);
            putchar(';');
            putchar('\n');
        }
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
    puts("    \\end{APIparameters}");

    //// function example
    //terminal_set_bold();
    //terminal_set_color_RGB(255, 0, 185);
    //_putstr("Example: ");
    //terminal_reset_color();
    //putchar('\n');
    //// FIXME: make _print_with_newlines_and_offset color-aware
    ////_print_with_newlines_and_offset(entry->example, 9); // 9: strlen("Example: ")
    //_putstr(entry->example);

    fputs("\\end{APIfunc}\n", stdout);
}

void main_API_create_latex_doc(void)
{
    struct vector* entries = _initialize_api_entries();
    struct vector_const_iterator* it = vector_const_iterator_create(entries);
    const char* lastmodule = NULL;
    while(vector_const_iterator_is_valid(it))
    {
        const struct api_entry* entry = vector_const_iterator_get(it);
        _create_latex_entry(entry, &lastmodule);
        vector_const_iterator_next(it);
    }
    vector_const_iterator_destroy(it);
    _destroy_api_entries(entries);
}

// vim: nowrap

