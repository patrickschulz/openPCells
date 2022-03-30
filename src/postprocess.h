#ifndef OPC_POSTPROCESS_H
#define OPC_POSTPROCESS_H

#include "object.h"
#include "generics.h"

void postprocess_merge_shapes(object_t* object, struct layermap* layermap);
void postprocess_filter_include(object_t* object, const char** layernames, size_t len);
void postprocess_filter_exclude(object_t* object, const char** layernames, size_t len);

#endif // OPC_POSTPROCESS_H
