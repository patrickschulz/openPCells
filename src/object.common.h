#ifndef OPC_OBJECT_IMPLEMENTATION
#error "This header must only be included in the implementation files of the object module. It is not intended for external use."
#endif

#ifndef OPC_OBJECT_COMMON_H
#define OPC_OBJECT_COMMON_H

// the struct is exposed so that composition is possible, but all content is hidden behind 'private'
struct object_common {
    struct {
        char* name;
        int isproxy;
        int ismanaged; // FIXME: is this really a common property? Do proxy objects ever use this?
        int isused; // FIXME: is this really a common property? Do proxy objects ever use this?
        struct transformationmatrix* trans;
    } private;
};

void objectcommon_initialize(struct object_common* obc);
void objectcommon_destroy(struct object_common* obc);
void objectcommon_set_name(struct object_common* obc, const char* name);
void objectcommon_set_managed(struct object_common* obc, int ismanaged);
int objectcommon_is_managed(const struct object_common* obc);
void objectcommon_set_used(struct object_common* obc, int isused);
int objectcommon_is_used(const struct object_common* obc);
void objectcommon_set_proxy(struct object_common* obc, int isproxy);
int objectcommon_is_proxy(const struct object_common* obc);
int objectcommon_is_full(const struct object_common* obc);
void objectcommon_copy_to(const struct object_common* obc, struct object_common* new);
const struct transformationmatrix* objectcommon_get_tmatrix(const struct object_common* obc);
void objectcommon_set_tmatrix(const struct object_common* obc, struct transformationmatrix* trans);
void objectcommon_transform_to_local_coordinates_xy(const struct object_common* cell, coordinate_t* x, coordinate_t* y);
void objectcommon_transform_to_local_coordinates_pt(const struct object_common* cell, struct point* pt);
void objectcommon_transform_to_global_coordinates_xy(const struct object_common* cell, coordinate_t* x, coordinate_t* y);
void objectcommon_transform_to_global_coordinates_pt(const struct object_common* cell, struct point* pt);

#endif /* OPC_OBJECT_COMMON_H */
