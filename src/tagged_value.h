#ifndef OPC_TAGGED_VALUE_H
#define OPC_TAGGED_VALUE_H

struct tagged_value;

struct tagged_value* tagged_value_create_integer(int value);
struct tagged_value* tagged_value_create_string(const char* value);
struct tagged_value* tagged_value_create_boolean(int value);
void tagged_value_destroy(void*);

int tagged_value_is_integer(const struct tagged_value* value);
int tagged_value_is_string(const struct tagged_value* value);
int tagged_value_is_boolean(const struct tagged_value* value);

int tagged_value_get_integer(const struct tagged_value*);
const char* tagged_value_get_const_string(const struct tagged_value*);
char* tagged_value_get_string(struct tagged_value*);
int tagged_value_get_boolean(const struct tagged_value*);

#endif /* OPC_TAGGED_VALUE_H */
