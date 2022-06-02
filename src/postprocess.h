#ifndef OPC_POSTPROCESS_H
#define OPC_POSTPROCESS_H

#include "object.h"
#include "generics.h"

void postprocess_merge_shapes(struct object* object, struct layermap* layermap);
void postprocess_filter_include(struct object* object, const char** layernames);
void postprocess_filter_exclude(struct object* object, const char** layernames);

#endif // OPC_POSTPROCESS_H
