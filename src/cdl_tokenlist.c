#include "cdl_tokenlist.h"

#include <stdlib.h>
#include <stdio.h>

#include "helpers.h"
#include "vector.h"

struct token {
    enum tokentype type;
    struct string* value;
    char* context;
};

static void _destroy_token(void* v)
{
    struct token* token = v;
    if(token->value)
    {
        string_destroy(token->value);
    }
    free(token->context);
    free(token);
}

struct CDL_tokenlist {
    struct vector* tokens;
    size_t current;
};

struct CDL_tokenlist* CDL_tokenlist_create(void)
{
    struct CDL_tokenlist* CDL_tokenlist = malloc(sizeof(*CDL_tokenlist));
    CDL_tokenlist->tokens = vector_create(512, _destroy_token);
    CDL_tokenlist->current = 0;
    return CDL_tokenlist;
}

void CDL_tokenlist_destroy(struct CDL_tokenlist* CDL_tokenlist)
{
    vector_destroy(CDL_tokenlist->tokens);
    free(CDL_tokenlist);
}

void CDL_tokenlist_reset(struct CDL_tokenlist* CDL_tokenlist)
{
    CDL_tokenlist->current = 0;
}

static const char* _stringify(enum tokentype type)
{
    switch(type)
    {
        case KEYWORD:
            return "KEYWORD";
        case COMMENT:
            return "COMMENT";
        case NUMBER:
            return "NUMBER";
        case DIRECTIVE:
            return "DIRECTIVE";
        case IDENTIFIER:
            return "IDENTIFIER";
        case OPENANGLEBRACE:
            return "OPENANGLEBRACE";
        case CLOSEANGLEBRACE:
            return "CLOSEANGLEBRACE";
        case OPENBRACE:
            return "OPENBRACE";
        case CLOSEBRACE:
            return "CLOSEBRACE";
        case OPENSQUAREBRACE:
            return "OPENSQUAREBRACE";
        case CLOSESQUAREBRACE:
            return "CLOSESQUAREBRACE";
        case OPERATORDIVISION:
            return "OPERATORDIVISION";
        case OPERATORPLUS:
            return "OPERATORPLUS";
        case OPERATORMINUS:
            return "OPERATORMINUS";
        case EQUALSIGN:
            return "EQUALSIGN";
        case DOLLARSIGN:
            return "DOLLARSIGN";
        case QUOTEDSTRING:
            return "QUOTEDSTRING";
        case ENDOFLINE:
            return "ENDOFLINE";
    }
    return "__ERROR__";
}

void CDL_token_add(struct CDL_tokenlist* CDL_tokenlist, enum tokentype type, struct string* value, char* context)
{
    struct token* token = malloc(sizeof(*token));
    token->type = type;
    token->value = value;
    token->context = context;
    vector_append(CDL_tokenlist->tokens, token);
}

int CDL_token_expect(struct CDL_tokenlist* CDL_tokenlist, enum tokentype type)
{
    if(CDL_tokenlist->current >= vector_size(CDL_tokenlist->tokens))
    {
        return 0;
    }
    struct token* token = vector_get(CDL_tokenlist->tokens, CDL_tokenlist->current);
    if(token->type == type)
    {
        return 1;
    }
    return 0;
}

int CDL_token_expect_next(struct CDL_tokenlist* CDL_tokenlist, enum tokentype type)
{
    if(CDL_tokenlist->current + 1 >= vector_size(CDL_tokenlist->tokens))
    {
        return 0;
    }
    struct token* token = vector_get(CDL_tokenlist->tokens, CDL_tokenlist->current + 1);
    if(token->type == type)
    {
        return 1;
    }
    return 0;
}

int CDL_token_expect_n(struct CDL_tokenlist* CDL_tokenlist, size_t n, enum tokentype type)
{
    if(CDL_tokenlist->current + n >= vector_size(CDL_tokenlist->tokens))
    {
        return 0;
    }
    struct token* token = vector_get(CDL_tokenlist->tokens, CDL_tokenlist->current + n);
    if(token->type == type)
    {
        return 1;
    }
    return 0;
}

void CDL_token_advance(struct CDL_tokenlist* CDL_tokenlist)
{
    ++CDL_tokenlist->current;
}

void CDL_token_advance_until(struct CDL_tokenlist* CDL_tokenlist, enum tokentype type)
{
    // this function does not call CDL_token_expect, as with it running out of tokens
    // creates the same return value as the current token being not the expected one
    // However, this function needs to handle these cases separately
    while(1)
    {
        if(CDL_tokenlist->current >= vector_size(CDL_tokenlist->tokens))
        {
            break;
        }
        struct token* token = vector_get(CDL_tokenlist->tokens, CDL_tokenlist->current);
        if(token->type == type)
        {
            break;
        }
        CDL_token_advance(CDL_tokenlist);
    }
}

void CDL_token_remove(struct CDL_tokenlist* CDL_tokenlist)
{
    vector_remove(CDL_tokenlist->tokens, CDL_tokenlist->current);
}

int CDL_token_empty(struct CDL_tokenlist* CDL_tokenlist)
{
    return CDL_tokenlist->current >= vector_size(CDL_tokenlist->tokens);
}

const char* CDL_token_get_value(const struct CDL_tokenlist* CDL_tokenlist)
{
    const struct token* token = vector_get(CDL_tokenlist->tokens, CDL_tokenlist->current);
    return string_get(token->value);
}

const char* CDL_token_stringify(const struct CDL_tokenlist* CDL_tokenlist)
{
    struct token* token = vector_get(CDL_tokenlist->tokens, CDL_tokenlist->current);
    struct string* info = string_create();
    string_add_string(info, _stringify(token->type));
    if(token->value)
    {
        string_add_character(info, ':');
        string_add_character(info, ' ');
        string_add_character(info, '"');
        string_add_string(info, string_get(token->value));
        string_add_character(info, '"');
    }
    return string_dissolve(info);
}

void CDL_token_print(struct CDL_tokenlist* CDL_tokenlist)
{
    struct token* token = vector_get(CDL_tokenlist->tokens, CDL_tokenlist->current);
    if(token->value)
    {
        fprintf(stdout, "%s('%s')\n", _stringify(token->type), string_get(token->value));
    }
    else
    {
        fprintf(stdout, "%s\n", _stringify(token->type));
    }
}

void CDL_token_print_context(struct CDL_tokenlist* CDL_tokenlist)
{
    struct token* token = vector_get(CDL_tokenlist->tokens, CDL_tokenlist->current);
    fprintf(stdout, "%s\n", token->context);
}

void CDL_tokenlist_print(struct CDL_tokenlist* CDL_tokenlist)
{
    for(size_t i = 0; i < vector_size(CDL_tokenlist->tokens); ++i)
    {
        struct token* token = vector_get(CDL_tokenlist->tokens, i);
        if(token->value)
        {
            fprintf(stderr, "%s('%s')\n", _stringify(token->type), string_get(token->value));
        }
        else
        {
            fprintf(stderr, "%s\n", _stringify(token->type));
        }
    }
}

void CDL_tokenlist_print_from_current(struct CDL_tokenlist* CDL_tokenlist)
{
    for(size_t i = CDL_tokenlist->current; i < vector_size(CDL_tokenlist->tokens); ++i)
    {
        struct token* token = vector_get(CDL_tokenlist->tokens, i);
        if(token->value)
        {
            fprintf(stderr, "%s('%s')\n", _stringify(token->type), string_get(token->value));
        }
        else
        {
            fprintf(stderr, "%s\n", _stringify(token->type));
        }
    }
}

