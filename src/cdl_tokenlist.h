#ifndef OPC_CDL_TOKENLIST_H
#define OPC_CDL_TOKENLIST_H

#include <stddef.h>

#include "string.h"

enum tokentype {
    KEYWORD,
    COMMENT,
    NUMBER,
    DIRECTIVE,
    IDENTIFIER,
    OPENANGLEBRACE,
    CLOSEANGLEBRACE,
    OPENBRACE,
    CLOSEBRACE,
    OPENSQUAREBRACE,
    CLOSESQUAREBRACE,
    OPERATORDIVISION,
    OPERATORPLUS,
    OPERATORMINUS,
    EQUALSIGN,
    DOLLARSIGN,
    QUOTEDSTRING,
    ENDOFLINE,
};

struct CDL_tokenlist;

struct CDL_tokenlist* CDL_tokenlist_create(void);
void CDL_tokenlist_destroy(struct CDL_tokenlist* CDL_tokenlist);
void CDL_tokenlist_reset(struct CDL_tokenlist* CDL_tokenlist);
void CDL_token_add(struct CDL_tokenlist* CDL_tokenlist, enum tokentype type, struct string* value, char* context);
int CDL_token_expect(struct CDL_tokenlist* CDL_tokenlist, enum tokentype type);
int CDL_token_expect_next(struct CDL_tokenlist* CDL_tokenlist, enum tokentype type);
int CDL_token_expect_n(struct CDL_tokenlist* CDL_tokenlist, size_t n, enum tokentype type);
void CDL_token_advance(struct CDL_tokenlist* CDL_tokenlist);
void CDL_token_advance_until(struct CDL_tokenlist* CDL_tokenlist, enum tokentype type);
void CDL_token_remove(struct CDL_tokenlist* CDL_tokenlist);
int CDL_token_empty(struct CDL_tokenlist* CDL_tokenlist);
const char* CDL_token_get_value(const struct CDL_tokenlist* CDL_tokenlist);
const char* CDL_token_stringify(const struct CDL_tokenlist* CDL_tokenlist);
void CDL_token_print_context(struct CDL_tokenlist* CDL_tokenlist);
void CDL_token_print(struct CDL_tokenlist* CDL_tokenlist);
void CDL_tokenlist_print_from_current(struct CDL_tokenlist* CDL_tokenlist);

#endif /* OPC_CDL_TOKENLIST_H */
