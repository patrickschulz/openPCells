#include "object.h"

#include <stdlib.h>

#include "object.h"
#include "transformationmatrix.h"
#include "util.h"

struct port {
    char* name;
    struct point* where;
    const struct generics* layer;
    int isbusport;
    int busindex;
    unsigned int sizehint;
};

struct port* objectport_create(const char* name, const struct generics* layer, coordinate_t x, coordinate_t y, int isbusport, int busindex, unsigned int sizehint)
{
    struct port* port = malloc(sizeof(*port));
    port->where = point_create(x, y);
    port->layer = layer;
    port->isbusport = isbusport;
    port->busindex = busindex;
    port->name = util_strdup(name);
    port->sizehint = sizehint;
    return port;
}

struct port* objectport_copy(const struct port* port)
{
    struct port* newport = malloc(sizeof(*newport));
    newport->where = point_copy(port->where);
    newport->layer = port->layer;
    newport->isbusport = port->isbusport;
    newport->busindex = port->busindex;
    newport->name = util_strdup(port->name);
    newport->sizehint = port->sizehint;
    return newport;
}

void objectport_apply_tmatrix(struct port* port, const struct transformationmatrix* trans)
{
    transformationmatrix_apply_transformation(trans, port->where);
}

void objectport_destroy(void* p)
{
    struct port* port = p;
    point_destroy(port->where);
    free(port->name);
    free(port);
}

struct point* objectport_get_point(const struct port* port)
{
    return port->where;
}

int objectport_call_port(const struct port* port, const struct transformationmatrix* matrix, port_action action, struct generic_arg* extraargs)
{
    struct point* where = point_copy(port->where);
    transformationmatrix_apply_transformation(matrix, where);
    int ret = action(port->name, port->layer, where, port->isbusport, port->busindex, port->sizehint, extraargs);
    point_destroy(where);
    return ret;
}

int objectport_call_label(const struct port* label, const struct transformationmatrix* matrix, label_action action, struct generic_arg* extraargs)
{
    struct point* where = point_copy(label->where);
    transformationmatrix_apply_transformation(matrix, where);
    int ret = action(label->name, label->layer, where, label->sizehint, extraargs);
    point_destroy(where);
    return ret;
}
