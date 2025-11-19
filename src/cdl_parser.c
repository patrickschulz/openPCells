#include "cdl_parser.h"

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "buffer.h"
#include "cdl_tokenlist.h"
#include "hashmap.h"
#include "helpers.h"
#include "string.h"
#include "util.h"
#include "vector.h"

static char siprefixes[] = {
    'P',
    'T',
    'M',
    'K', // should be lowercase k, but spectre si weird
    'm',
    'u',
    'n',
    'p',
    'f',
    'a',
    0 /* sentinel */
};

static int _is_si_prefix(char ch)
{
    const char* ptr = siprefixes;
    while(*ptr)
    {
        if(ch == *ptr)
        {
            return 1;
        }
        ++ptr;
    }
    return 0;
}

static char* _make_context(const char* filename, size_t startindex, size_t endindex)
{
    return util_strdup("foobar");
    FILE* file = fopen(filename, "r");
    size_t total = 0;
    size_t previouseol = 0;
    size_t nexteol = 0;
    while(1)
    {
        int ich = fgetc(file);
        if(ich == EOF)
        {
            break;
        }
        char ch = (char)ich;
        ++total;
        if((total <= startindex) && ch == '\n')
        {
            previouseol = total;
        }
        if((total > endindex) && ch == '\n')
        {
            nexteol = total;
            break; // found all info
        }
    }
    fclose(file);
    // FIXME: this code assumes that the start and end position are found in the file.
    //        this is never checked and might lead to errors if there are bugs in the 
    //        initial position setting

    // restart and gather context string
    struct string* context = string_create();
    struct string* marker = string_create();
    file = fopen(filename, "r");
    total = 0;
    while(1)
    {
        char ch = fgetc(file);
        ++total;
        if(total > previouseol && total < nexteol)
        {
            string_add_character(context, ch);
            char markch;
            if(total == startindex + 1)
            {
                markch = '^';
            }
            else if((total > startindex) && (total <= endindex))
            {
                markch = '~';
            }
            else
            {
                markch = ' ';
            }
            string_add_character(marker, markch);
        }
        if(total >= nexteol)
        {
            break;
        }
    }
    fclose(file);
    string_add_character(context, '\n');
    string_add_string(context, string_dissolve(marker));
    return string_dissolve(context);
}

static int _is_identifier_character(char c, int first)
{
    if(first)
    {
        return isalpha(c) || c == '_' || c == '~' || c == '!';
    }
    else
    {
        return isalnum(c) || c == '_' || c == '~' || c == '!';
    }
}

struct CDL_tokenlist* _tokenize(const char* filename, const char** message)
{
    struct buffer* buffer = open_buffer(filename);
    if(!buffer)
    {
        fprintf(stderr, "could not open file '%s'\n", filename);
        exit(1);
    }
    struct CDL_tokenlist* CDL_tokenlist = CDL_tokenlist_create();
    while(1)
    {
        char ch;
        int status = buffer_get(buffer, &ch);
        size_t startindex = buffer_get_index(buffer);
        buffer_advance(buffer);
        if(!status)
        {
            break;
        }
        if(ch == '\n')
        {
            char* context = _make_context(filename, startindex, startindex + 1);
            CDL_token_add(CDL_tokenlist, ENDOFLINE, NULL, context);
            goto restart;
        }
        if(isspace(ch))
        {
            goto restart;
        }
        if(ch == '*')
        {
            char nch;
            size_t endindex = startindex + 1;
            buffer_advance(buffer);
            struct string* str = string_create();
            while(1)
            {
                if(!buffer_get(buffer, &nch))
                {
                    break;
                }
                endindex = buffer_get_index(buffer);
                if(nch == '\n')
                {
                    break;
                }
                else
                {
                    string_add_character(str, nch);
                }
                buffer_advance(buffer);
            }
            char* context = _make_context(filename, startindex, endindex);
            CDL_token_add(CDL_tokenlist, COMMENT, str, context);
            goto restart;
        }
        if(ch == '.')
        {
            size_t endindex;
            struct string* str = string_create();
            while(1)
            {
                char nch;
                if(!buffer_get(buffer, &nch))
                {
                    *message = "reached end of file while reading a DIRECTIVE";
                    return NULL;
                }
                endindex = buffer_get_index(buffer);
                if(!isalpha(nch))
                {
                    break;
                }
                buffer_advance(buffer);
                string_add_character(str, nch);
            }
            char* context = _make_context(filename, startindex, endindex);
            CDL_token_add(CDL_tokenlist, DIRECTIVE, str, context);
            goto restart;
        }
        if(_is_identifier_character(ch, 1))
        {
            size_t endindex = startindex + 1;
            struct string* str = string_create();
            string_add_character(str, ch);
            while(1)
            {
                char nch;
                if(!buffer_get(buffer, &nch))
                {
                    break;
                }
                endindex = buffer_get_index(buffer);
                if(nch == '\\') // escaped character, skip to next one
                {
                    string_add_character(str, '\\');
                    buffer_advance(buffer);
                    if(!buffer_get(buffer, &nch))
                    {
                        *message = "reached end of file while reading an escaped character within an IDENTIFIER";
                        return NULL;
                    }
                    endindex = buffer_get_index(buffer);
                }
                else // regular-non-escaped character
                {
                    if(!(_is_identifier_character(nch, 0)))
                    {
                        break;
                    }
                }
                buffer_advance(buffer);
                string_add_character(str, nch);
            }
            char* context = _make_context(filename, startindex, endindex);
            CDL_token_add(CDL_tokenlist, IDENTIFIER, str, context);
            goto restart;
        }
        if(isdigit(ch) || ch == '-') // number
        {
            size_t endindex = startindex + 1;
            struct string* str = string_create();
            string_add_character(str, ch);
            while(1)
            {
                char d;
                if(!buffer_get(buffer, &d))
                {
                    break;
                }
                if(!isdigit(d))
                {
                    break;
                }
                string_add_character(str, (char)d);
                buffer_advance(buffer);
            }
            char nch;
            buffer_get(buffer, &nch); // no return value check is required, there must be a character
                                      // this check was performed in the above while(1) loop
            if(nch == '.') // fractional number
            {
                string_add_character(str, '.');
                buffer_advance(buffer);
                buffer_get(buffer, &nch); // no return value check is required, because if the get fails
                                          // the nch character is not updated, hence it will still contain '.'
                                          // in this case, the following isdigit/si_prefix/scientific_number
                                          // checks will also fail
            }
            if(isdigit(nch))
            {
                string_add_character(str, nch);
                buffer_advance(buffer);
                while(1)
                {
                    if(!buffer_get(buffer, &nch))
                    {
                        break;
                    }
                    endindex = buffer_get_index(buffer);
                    if(!isdigit(nch))
                    {
                        break;
                    }
                    buffer_advance(buffer);
                    string_add_character(str, nch);
                }
            }
            if(_is_si_prefix(nch)) // (SI prefix)
            {
                buffer_advance(buffer);
                buffer_advance(buffer); // last character is part of the number
                string_add_character(str, nch);
            }
            if(nch == 'e') // scientific notation
            {
                string_add_character(str, 'e');
                buffer_advance(buffer);
                // first character after 'e' can be a '-'
                if(!buffer_get(buffer, &nch))
                {
                    *message = "expected more number characters after 'e'";
                    return NULL;
                }
                if(!(isdigit(nch) || nch == '-'))
                {
                    break;
                }
                buffer_advance(buffer);
                string_add_character(str, nch);
                while(1)
                {
                    if(!buffer_get(buffer, &nch))
                    {
                        break;
                    }
                    if(!isdigit(nch))
                    {
                        break;
                    }
                    buffer_advance(buffer);
                    string_add_character(str, nch);
                }
            }
            char* context = _make_context(filename, startindex, endindex);
            CDL_token_add(CDL_tokenlist, NUMBER, str, context);
            goto restart;
        }
        if(ch == '<')
        {
            char* context = _make_context(filename, startindex, startindex + 1);
            CDL_token_add(CDL_tokenlist, OPENANGLEBRACE, NULL, context);
            goto restart;
        }
        if(ch == '>')
        {
            char* context = _make_context(filename, startindex, startindex + 1);
            CDL_token_add(CDL_tokenlist, CLOSEANGLEBRACE, NULL, context);
            goto restart;
        }
        if(ch == '+')
        {
            char* context = _make_context(filename, startindex, startindex + 1);
            CDL_token_add(CDL_tokenlist, OPERATORPLUS, NULL, context);
            goto restart;
        }
        if(ch == '-')
        {
            char* context = _make_context(filename, startindex, startindex + 1);
            CDL_token_add(CDL_tokenlist, OPERATORMINUS, NULL, context);
            goto restart;
        }
        if(ch == '/')
        {
            char* context = _make_context(filename, startindex, startindex + 1);
            CDL_token_add(CDL_tokenlist, OPERATORDIVISION, NULL, context);
            goto restart;
        }
        if(ch == '=')
        {
            char* context = _make_context(filename, startindex, startindex + 1);
            CDL_token_add(CDL_tokenlist, EQUALSIGN, NULL, context);
            goto restart;
        }
        if(ch == '(')
        {
            char* context = _make_context(filename, startindex, startindex + 1);
            CDL_token_add(CDL_tokenlist, OPENBRACE, NULL, context);
            goto restart;
        }
        if(ch == ')')
        {
            char* context = _make_context(filename, startindex, startindex + 1);
            CDL_token_add(CDL_tokenlist, CLOSEBRACE, NULL, context);
            goto restart;
        }
        if(ch == '[')
        {
            char* context = _make_context(filename, startindex, startindex + 1);
            CDL_token_add(CDL_tokenlist, OPENSQUAREBRACE, NULL, context);
            goto restart;
        }
        if(ch == ']')
        {
            char* context = _make_context(filename, startindex, startindex + 1);
            CDL_token_add(CDL_tokenlist, CLOSESQUAREBRACE, NULL, context);
            goto restart;
        }
        if(ch == '$')
        {
            char* context = _make_context(filename, startindex, startindex + 1);
            CDL_token_add(CDL_tokenlist, DOLLARSIGN, NULL, context);
            goto restart;
        }
        /*
        if(ch == '"')
        {
            size_t endindex;
            int isescaping = 0;
            struct string* str = string_create();
            while(1)
            {
                char nch;
                if(!buffer_get(buffer, &nch))
                {
                    return NULL;
                }
                buffer_advance(buffer); // advance before the break, as the '"' is part of the string
                if(nch == '\\') // escape mode
                {
                    isescaping = 1;
                }
                endindex = buffer_get_index(buffer);
                if(!isescaping && nch == '"')
                {
                    break;
                }
                string_add_character(str, nch);
                isescaping = 0;
            }
            char* context = _make_context(filename, startindex, endindex);
            CDL_token_add(CDL_tokenlist, QUOTEDSTRING, str, context);
            goto restart;
        }
        */
        char* context = _make_context(filename, startindex, startindex + 1);
        fprintf(stderr, "error: unknown token: '%c'\n", ch);
        fprintf(stderr, "%s\n", context);
        free(context);
        return NULL;
restart: ; // empty statement for older gcc versions
    }
    close_buffer(buffer);
    CDL_token_add(CDL_tokenlist, ENDOFLINE, NULL, util_strdup("virtual extra end-of-line"));
    return CDL_tokenlist;
}

/*
int _parse_instance_parameter(struct CDL_tokenlist* CDL_tokenlist, struct device* device)
{
    const char* parametername;
    const char* parametervalue;
    if(!CDL_token_expect(CDL_tokenlist, IDENTIFIER)) // parameter name
    {
        fprintf(stderr, "instantiation: expected an identifier for parameter, got %s\n", CDL_token_stringify(CDL_tokenlist));
        return 0;
    }
    else
    {
        parametername = CDL_token_get_value(CDL_tokenlist);
    }
    CDL_token_advance(CDL_tokenlist);
    if(!CDL_token_expect(CDL_tokenlist, EQUALSIGN))
    {
        puts("instantiation: expected equal sign for parameter");
        return 0;
    }
    CDL_token_advance(CDL_tokenlist);
    if(!(CDL_token_expect(CDL_tokenlist, IDENTIFIER) || CDL_token_expect(CDL_tokenlist, NUMBER))) // parameter value
    {
        puts("instantiation: expected a value for parameter");
        return 0;
    }
    else
    {
        parametervalue = CDL_token_get_value(CDL_tokenlist);
    }
    device_set_parameter(device, parametername, parametervalue);
    CDL_token_advance(CDL_tokenlist);
    return 1;
}

struct device* _parse_device(struct CDL_tokenlist* CDL_tokenlist)
{
    struct device* device = device_create();
    if(!CDL_token_expect(CDL_tokenlist, IDENTIFIER)) // instance name
    {
        return NULL;
    }
    else
    {
        device_set_name(device, CDL_token_get_value(CDL_tokenlist));
    }
    CDL_token_advance(CDL_tokenlist);
    if(!CDL_token_expect(CDL_tokenlist, OPENBRACE)) // start nets
    {
        puts("instantiation: expected opening brace for port connections");
        return NULL;
    }
    CDL_token_advance(CDL_tokenlist);
    while(CDL_token_expect(CDL_tokenlist, IDENTIFIER) || CDL_token_expect(CDL_tokenlist, NUMBER)) // port connections (nets) can be identifiers or numbers (as '0' is a valid net)
    {
        device_add_port_connection(device, CDL_token_get_value(CDL_tokenlist));
        CDL_token_advance(CDL_tokenlist);
    }
    if(!CDL_token_expect(CDL_tokenlist, CLOSEBRACE)) // end nets
    {
        fprintf(stderr, "instantiation: expected closing brace after port connections, got %s\n", CDL_token_stringify(CDL_tokenlist));
    }
    CDL_token_advance(CDL_tokenlist);
    if(!CDL_token_expect(CDL_tokenlist, IDENTIFIER)) // model name
    {
        fprintf(stderr, "instantiation: expected model name (IDENTIFIER), got %s\n", CDL_token_stringify(CDL_tokenlist));
        return NULL;
    }
    else
    {
        const char* modelname = CDL_token_get_value(CDL_tokenlist);
        if(strcmp(modelname, "resistor") == 0)
        {
            device_set_type(device, DEVICE_RESISTOR);
        }
        else if(strcmp(modelname, "capacitor") == 0)
        {
            device_set_type(device, DEVICE_CAPACITOR);
        }
        else if(strcmp(modelname, "inductor") == 0)
        {
            device_set_type(device, DEVICE_INDUCTOR);
        }
        else if(strcmp(modelname, "vsource") == 0)
        {
            device_set_type(device, DEVICE_VOLTAGESOURCE);
        }
        else
        {
            device_set_type(device, DEVICE_OTHER);
            device_set_modelname(device, modelname);
        }
    }
    CDL_token_advance(CDL_tokenlist);
    // parameters
    while(!CDL_token_expect(CDL_tokenlist, ENDOFLINE))
    {
        if(CDL_token_expect(CDL_tokenlist, IDENTIFIER))
        {
            int ret = _parse_instance_parameter(CDL_tokenlist, device);
            if(!ret)
            {
                return NULL;
            }
        }
        else if(CDL_token_expect(CDL_tokenlist, COMMENT))
        {
            const char* comment = CDL_token_get_value(CDL_tokenlist);
            device_add_comment(device, comment);
            CDL_token_advance(CDL_tokenlist);
        }
        else
        {
            fprintf(stderr, "unexpected token while parsing instance: %s\n", CDL_token_stringify(CDL_tokenlist));
        }
    }
    // eat end-of-line token
    CDL_token_advance(CDL_tokenlist);
    return device;
}
*/

static int _read_parameter(struct CDL_tokenlist* CDL_tokenlist, char** key, char** value, const char** message)
{
    const char* parametername;
    const char* parametervalue;
    if(!CDL_token_expect(CDL_tokenlist, IDENTIFIER)) // parameter name
    {
        *message = "instantiation: expected an identifier for parameter";
        return 0;
    }
    else
    {
        parametername = CDL_token_get_value(CDL_tokenlist);
    }
    CDL_token_advance(CDL_tokenlist);
    if(!CDL_token_expect(CDL_tokenlist, EQUALSIGN))
    {
        *message = "instantiation: expected equal sign for parameter";
        return 0;
    }
    CDL_token_advance(CDL_tokenlist);
    if(!(CDL_token_expect(CDL_tokenlist, IDENTIFIER) || CDL_token_expect(CDL_tokenlist, NUMBER))) // parameter value
    {
        *message = "instantiation: expected a value for parameter";
        return 0;
    }
    else
    {
        parametervalue = CDL_token_get_value(CDL_tokenlist);
    }
    *key = util_strdup(parametername);
    *value = util_strdup(parametervalue);
    CDL_token_advance(CDL_tokenlist);
    return 1;
}

static int _is_directive(struct CDL_tokenlist* CDL_tokenlist, const char* key)
{
    if(!CDL_token_expect(CDL_tokenlist, DIRECTIVE))
    {
        return 0;
    }
    const char* keyword = CDL_token_get_value(CDL_tokenlist);
    return strcmp(keyword, key) == 0;
}

static int _start_subcircuit(struct CDL_tokenlist* CDL_tokenlist, struct subcircuit* subcircuit)
{
    // eat 'SUBCKT'
    CDL_token_advance(CDL_tokenlist);
    // subcircuit name
    if(!CDL_token_expect(CDL_tokenlist, IDENTIFIER))
    {
        return 0;
    }
    else
    {
        const char* name = CDL_token_get_value(CDL_tokenlist);
        //debugprintf("subcircuit definition: '%s'\n", name);
        netlist_subcircuit_set_name(subcircuit, name);
        // FIXME: do something with the name
    }
    // eat name
    CDL_token_advance(CDL_tokenlist);
    // nets are all identifier after the name until a real newline (expect parameters)
    while(CDL_token_expect(CDL_tokenlist, IDENTIFIER) && !CDL_token_expect_n(CDL_tokenlist, 1, EQUALSIGN))
    {
        const char* port = CDL_token_get_value(CDL_tokenlist);
        // FIXME: do something with the port
        CDL_token_advance(CDL_tokenlist);
        if(CDL_token_expect(CDL_tokenlist, OPENANGLEBRACE)) // bus net
        {
            CDL_token_advance(CDL_tokenlist);
            CDL_token_expect(CDL_tokenlist, NUMBER);
            CDL_token_advance(CDL_tokenlist);
            CDL_token_expect(CDL_tokenlist, CLOSEANGLEBRACE);
            CDL_token_advance(CDL_tokenlist);
        }
    }
    // read parameters
    while(CDL_token_expect(CDL_tokenlist, IDENTIFIER) && CDL_token_expect_n(CDL_tokenlist, 1, EQUALSIGN))
    {
        char* key = NULL;
        char* value = NULL;
        const char* message;
        _read_parameter(CDL_tokenlist, &key, &value, &message);
        free(key);
        free(value);
    }
    // end header
    if(!CDL_token_expect(CDL_tokenlist, ENDOFLINE))
    {
        fprintf(stderr, "subcircuit definition: expected new line after subcitcuit ports, got %s\n", CDL_token_stringify(CDL_tokenlist));
        CDL_token_print_context(CDL_tokenlist);
    }
    // eat end-of-line
    CDL_token_advance(CDL_tokenlist);
    return 1;
}

static char* _read_net(struct CDL_tokenlist* CDL_tokenlist, const char** message)
{
    if(!CDL_token_expect(CDL_tokenlist, IDENTIFIER)) // net name
    {
        *message = "expected a net name (an IDENTIFIER)";
        return NULL;
    }
    struct string* netname = string_create();
    string_add_string(netname, CDL_token_get_value(CDL_tokenlist));
    CDL_token_advance(CDL_tokenlist);
    if(CDL_token_expect(CDL_tokenlist, OPENANGLEBRACE)) // bus net
    {
        CDL_token_advance(CDL_tokenlist);
        if(!CDL_token_expect(CDL_tokenlist, NUMBER))
        {
            *message = "expected a number after '<' for a bus net name";
            return NULL;
        }
        const char* busindex = CDL_token_get_value(CDL_tokenlist);
        string_add_character(netname, '<');
        string_add_string(netname, busindex);
        string_add_character(netname, '>');
        CDL_token_advance(CDL_tokenlist);
        if(!CDL_token_expect(CDL_tokenlist, CLOSEANGLEBRACE))
        {
            *message = "expected a closing '>' for a bus net name";
            return NULL;
        }
        CDL_token_advance(CDL_tokenlist);
    }
    return string_dissolve(netname);
}

static int _test_parameter(struct CDL_tokenlist* CDL_tokenlist)
{
    if(!CDL_token_expect_n(CDL_tokenlist, 0, IDENTIFIER))
    {
        return 0;
    }
    if(!CDL_token_expect_n(CDL_tokenlist, 1, EQUALSIGN))
    {
        return 0;
    }
    if(!(CDL_token_expect_n(CDL_tokenlist, 2, IDENTIFIER) || CDL_token_expect_n(CDL_tokenlist, 2, NUMBER)))
    {
        return 0;
    }
    return 1;
}

static struct instance* _read_instantiation(struct CDL_tokenlist* CDL_tokenlist)
{
    struct string* identifier = string_create();
    string_add_string(identifier, CDL_token_get_value(CDL_tokenlist));
    CDL_token_advance(CDL_tokenlist); // eat instance identifier/name
    if(CDL_token_expect(CDL_tokenlist, OPENANGLEBRACE)) // interated instance
    {
        if(!CDL_token_expect_n(CDL_tokenlist, 1, NUMBER) ||
           !CDL_token_expect_n(CDL_tokenlist, 2, CLOSEANGLEBRACE))
        {
            // FIXME: error message
            return 0;
        }
        CDL_token_advance(CDL_tokenlist);
        const char* num = CDL_token_get_value(CDL_tokenlist);
        string_add_character(identifier, '<');
        string_add_string(identifier, num);
        string_add_character(identifier, '>');
        CDL_token_advance(CDL_tokenlist);
        CDL_token_advance(CDL_tokenlist);
    }
    struct instance* instance = netlist_make_instance(string_get(identifier));
    switch(string_get_character(identifier, 0))
    {
        case 'R':
            CDL_token_advance_until(CDL_tokenlist, ENDOFLINE);
            puts("resistor");
            break;
        case 'C':
            CDL_token_advance_until(CDL_tokenlist, ENDOFLINE);
            puts("capacitor");
            break;
        case 'L':
            CDL_token_advance_until(CDL_tokenlist, ENDOFLINE);
            puts("inductor");
            break;
        case 'D':
            CDL_token_advance_until(CDL_tokenlist, ENDOFLINE);
            puts("diode");
            break;
        case 'M':
        {
            netlist_instance_set_type(instance, "mosfet");
            const char* message;
            // read terminal connections
            char* drainnet = _read_net(CDL_tokenlist, &message);
            char* gatenet = _read_net(CDL_tokenlist, &message);
            char* sourcenet = _read_net(CDL_tokenlist, &message);
            // FIXME: bulknet is optional
            char* bulknet = _read_net(CDL_tokenlist, &message);
            // read model name
            const char* modelname = CDL_token_get_value(CDL_tokenlist);
            netlist_instance_set_model(instance, modelname);
            CDL_token_advance(CDL_tokenlist);
            while(_test_parameter(CDL_tokenlist))
            {
                char* key = NULL;
                char* value = NULL;
                _read_parameter(CDL_tokenlist, &key, &value, &message);
                netlist_instance_add_parameter(instance, key, value);
                free(key);
                free(value);
            }
            // FIXME:
            CDL_token_advance_until(CDL_tokenlist, ENDOFLINE);
            // store nets
            netlist_instance_add_connection(instance, "gate", gatenet);
            netlist_instance_add_connection(instance, "drain", drainnet);
            netlist_instance_add_connection(instance, "source", sourcenet);
            netlist_instance_add_connection(instance, "bulk", bulknet);
            free(gatenet);
            free(drainnet);
            free(sourcenet);
            free(bulknet);
            break;
        }
        case 'Q':
            CDL_token_advance_until(CDL_tokenlist, ENDOFLINE);
            puts("bipolar");
            break;
        case 'X':
            CDL_token_advance_until(CDL_tokenlist, ENDOFLINE);
            puts("instance");
            break;
        default:
            return NULL;
            break;
    }
    CDL_token_advance(CDL_tokenlist); // eat end-of-line
    string_destroy(identifier);
    return instance;
}

static void _end_subcircuit(struct CDL_tokenlist* CDL_tokenlist)
{
    CDL_token_advance(CDL_tokenlist); // eat 'ENDS'
}

static struct subcircuit* _read_subcircuit(struct CDL_tokenlist* CDL_tokenlist)
{
    struct subcircuit* subcircuit = netlist_make_subcircuit();
    // read start
    _start_subcircuit(CDL_tokenlist, subcircuit);
    // read content
    while(!_is_directive(CDL_tokenlist, "ENDS"))
    {
        if(CDL_token_expect(CDL_tokenlist, IDENTIFIER)) // instantiation
        {
            struct instance* instance = _read_instantiation(CDL_tokenlist);
            if(!instance)
            {
                fprintf(stderr, "%s\n", "could not read instantiation");
                return NULL;
            }
            netlist_subcircuit_add_instance(subcircuit, instance);
        }
        else
        {
            // eat the token (probably a comment)
            // FIXME: error handling
            CDL_token_advance(CDL_tokenlist);
        }
    }
    // read end
    _end_subcircuit(CDL_tokenlist);
    return subcircuit;
}

static void _resolve_line_continuations(struct CDL_tokenlist* CDL_tokenlist)
{
    while(!CDL_token_empty(CDL_tokenlist))
    {
        if(
            CDL_token_expect(CDL_tokenlist, ENDOFLINE) &&
            CDL_token_expect_next(CDL_tokenlist, OPERATORPLUS)
        )
        {
            CDL_token_remove(CDL_tokenlist);
            CDL_token_remove(CDL_tokenlist);
        }
        else
        {
            CDL_token_advance(CDL_tokenlist);
        }
    }
    CDL_tokenlist_reset(CDL_tokenlist);
}

struct netlist* cdlparser_parse(const char* filename)
{
    const char* message;
    struct CDL_tokenlist* CDL_tokenlist = _tokenize(filename, &message);
    if(!CDL_tokenlist) // tokenization errors
    {
        fprintf(stderr, "could not tokenize CDL netlist, reason: %s\n", message);
        return NULL;
    }
    /*
    while(!CDL_token_empty(CDL_tokenlist))
    {
        CDL_token_print(CDL_tokenlist);
        CDL_token_advance(CDL_tokenlist);
    }
    CDL_tokenlist_reset(CDL_tokenlist);
    */
    _resolve_line_continuations(CDL_tokenlist);
    struct netlist* netlist = netlist_create();
    while(!CDL_token_empty(CDL_tokenlist))
    {
        if(CDL_token_expect(CDL_tokenlist, ENDOFLINE)) // skip unneeded eol
        {
            CDL_token_advance(CDL_tokenlist);
        }
        else if(CDL_token_expect(CDL_tokenlist, DIRECTIVE))
        {
            if(_is_directive(CDL_tokenlist, "SUBCKT")) // subcircuit definition
            {
                struct subcircuit* subcircuit = _read_subcircuit(CDL_tokenlist);
                netlist_add_subcircuit(netlist, subcircuit);
            }
            else // ignore other directives
            {
                CDL_token_advance(CDL_tokenlist);
            }
        }
        else if(CDL_token_expect(CDL_tokenlist, COMMENT))
        {
            CDL_token_advance(CDL_tokenlist); // ignore comment characters
            CDL_token_advance(CDL_tokenlist); // eat ENDOFLINE
        }
        else
        {
            fprintf(stderr, "unexpected token: %s\n", CDL_token_stringify(CDL_tokenlist));
            CDL_token_print_context(CDL_tokenlist);
            CDL_tokenlist_destroy(CDL_tokenlist);
            return NULL;
        }
    }
    CDL_tokenlist_destroy(CDL_tokenlist);
    return netlist;
}

