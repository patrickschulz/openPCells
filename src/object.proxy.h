#ifndef OPC_OBJECT_IMPLEMENTATION
#error "This header must only be included in the implementation files of the object module. It is not intended for external use."
#endif

#ifndef OPC_OBJECT_PROXY_H
#define OPC_OBJECT_PROXY_H

#include "point.h"
#include "transformationmatrix.h"

// the struct is exposed so that composition is possible, but all content is hidden behind 'private'
struct object_proxy {
    struct {
        struct object* reference;
        int isarray;
        unsigned int xrep;
        unsigned int yrep;
        coordinate_t xpitch;
        coordinate_t ypitch;
        struct transformationmatrix* array_trans;
    } private;
};

void objectproxy_initialize(struct object_proxy* proxy, struct object* reference);
void objectproxy_copy_to(const struct object_proxy* proxy, struct object_proxy* new);
void objectproxy_destroy(struct object_proxy* proxy);
const struct object* objectproxy_get_reference(const struct object_proxy* proxy);
struct object* objectproxy_get_reference_mutable(struct object_proxy* proxy);
void objectproxy_set_array(struct object_proxy* proxy, unsigned int xrep, unsigned int yrep, coordinate_t xpitch, coordinate_t ypitch);
int objectproxy_is_array(const struct object_proxy* proxy);

// access to array transformation
const struct transformationmatrix* objectproxy_get_array_tmatrix(const struct object_proxy* proxy);

// handle array translation
unsigned int objectproxy_get_xrep(const struct object_proxy* proxy);
unsigned int objectproxy_get_yrep(const struct object_proxy* proxy);
coordinate_t objectproxy_get_xpitch(const struct object_proxy* proxy);
coordinate_t objectproxy_get_ypitch(const struct object_proxy* proxy);
void objectproxy_translate_pt_to_array(const struct object_proxy* proxy, struct point* pt, int xindex, int yindex);
void objectproxy_translate_x_to_array_end(const struct object_proxy* proxy, coordinate_t* x);
void objectproxy_translate_y_to_array_end(const struct object_proxy* proxy, coordinate_t* y);
int objectproxy_check_array_bounds(const struct object_proxy* proxy, int xindex, int yindex);
void objectproxy_array_rotate_90_left(struct object_proxy* proxy);
void objectproxy_array_rotate_90_right(struct object_proxy* proxy);

#endif /* OPC_OBJECT_PROXY_H */
