#ifndef OPC_POSTPROCESS_H
#define OPC_POSTPROCESS_H

#include "object.h"
#include "technology.h"

void postprocess_merge_shapes(struct object* object, struct technology_state* techstate);
void postprocess_remove_layer_shapes_flat(struct object* object, const struct generics* layer);
void postprocess_remove_layer_shapes(struct object* object, const struct generics* layer);
void postprocess_remove_empty_layer_shapes(struct object* object);

#endif // OPC_POSTPROCESS_H
