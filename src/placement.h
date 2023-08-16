#include "object.h"
#include "vector.h"

struct vector* placement_place_within_boundary(struct object* toplevel, struct object* cell, const char* basename, const struct vector* targetarea, const struct vector* excludes);
void placement_place_within_boundary_merge(struct object* toplevel, struct object* cell, const struct vector* targetarea, const struct vector* excludes);
struct object* placement_place_within_rectangular_boundary(struct object* toplevel, struct object* cell, const char* basename, const point_t* targetbl, const point_t* targettr);

