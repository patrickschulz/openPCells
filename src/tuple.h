#ifndef OPC_TUPLE_H
#define OPC_TUPLE_H

struct tuple2 {
    void* first;
    void (*first_destructor)(void* v);
    void* second;
    void (*second_destructor)(void* v);
};

struct tuple2* tuple2_create(
    void* first,
    void (*first_destructor)(void* v),
    void* second,
    void (*second_destructor)(void* v)
);
void tuple2_destroy(void* v);

#endif /* OPC_TUPLE_H */
