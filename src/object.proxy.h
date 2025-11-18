#ifndef OPC_OBJECT_IMPLEMENTATION
#error "This header must only be included in the implementation files of the object module. It is not intended for external use."
#endif

#ifndef OPC_OBJECT_PROXY_H
#define OPC_OBJECT_PROXY_H

// the struct is exposed so that composition is possible, but all content is hidden behind 'private'
struct object_proxy {
    struct {
        const struct object* reference;
        int isarray;
        unsigned int xrep;
        unsigned int yrep;
        coordinate_t xpitch;
        coordinate_t ypitch;
        struct transformationmatrix* array_trans;
    } private;
};

void objectproxy_initialize(struct object_proxy* proxy, const struct object* reference);
void objectproxy_copy_to(const struct object_proxy* proxy, struct object_proxy* new);
void objectproxy_destroy(struct object_proxy* proxy);
const struct object* objectproxy_get_reference(const struct object_proxy* proxy);
void objectproxy_set_array(struct object_proxy* proxy, unsigned int xrep, unsigned int yrep, coordinate_t xpitch, coordinate_t ypitch);

void objectproxy_translate_x_to_array_end(const struct object_proxy* proxy, coordinate_t* x);
void objectproxy_translate_y_to_array_end(const struct object_proxy* proxy, coordinate_t* y);

#endif /* OPC_OBJECT_PROXY_H */
