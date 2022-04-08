#ifndef OPC_MAIN_CELL_H
#define OPC_MAIN_CELL_H

#include "object.h"
#include "technology.h"
#include "pcell.h"
#include "generics.h"
#include "keyvaluepairs.h"
#include "cmdoptions.h"

struct technology_state* main_create_techstate(struct vector* techpaths, const char* techname);
struct pcell_state* main_create_pcell_state(void);
struct layermap* main_create_layermap(void);
object_t* main_create_cell(const char* cellname, struct vector* cellargs, struct technology_state* techstate, struct pcell_state* pcell_state, struct layermap* layermap);
void main_create_and_export_cell(struct cmdoptions* cmdoptions, struct keyvaluearray* config);

#endif // OPC_MAIN_CELL_H
