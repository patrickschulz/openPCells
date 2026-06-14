#ifndef OPC_OBJECT_IMPLEMENTATION
#error "This header must only be included in the implementation files of the object module. It is not intended for external use."
#endif

#include "object.h"
#include "point.h"
#include "technology.h"
#include "transformationmatrix.h"

struct port;

struct port* objectport_create(const char* name, const struct generics* layer, coordinate_t x, coordinate_t y, int isbusport, int busindex, unsigned int sizehint);
struct port* objectport_copy(const struct port* port);
void objectport_apply_tmatrix(struct port* port, const struct transformationmatrix* matrix);
void objectport_destroy(void* p);
struct point* objectport_get_point(const struct port* port);
int objectport_call_port(const struct port* port, const struct transformationmatrix* matrix, port_action action, void* extraarg);
int objectport_call_label(const struct port* label, const struct transformationmatrix* matrix, label_action action, void* extraarg);
