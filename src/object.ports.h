#ifdef OPC_OBJECTPORTS_H
#error "This header must only be included once, in the object implementation module."
#endif

#include "object.h"
#include "point.h"
#include "technology.h"
#include "transformationmatrix.h"

#define OPC_OBJECTPORTS_H

struct port;

struct port* objectport_create(const char* name, const struct generics* layer, coordinate_t x, coordinate_t y, int isbusport, int busindex, unsigned int sizehint);
struct port* objectport_copy(const struct port* port);
void objectport_transform_to_global_coordinates(struct port* port, struct transformationmatrix* matrix);
void objectport_transform_to_cell_coordinates(struct port* port, struct transformationmatrix* matrix);
void objectport_destroy(void* p);
void objectport_get_point(const struct port* port, struct point* pt);
int objectport_call_port(const struct port* port, struct transformationmatrix* matrix, port_action action, void* extraarg);
int objectport_call_label(const struct port* label, struct transformationmatrix* matrix, label_action action, void* extraarg);
