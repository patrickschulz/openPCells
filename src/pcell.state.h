#ifndef OPC_PCELL_STATE_H
#define OPC_PCELL_STATE_H

struct pcell_state* pcell_initialize_state(void);
void pcell_destroy_state(struct pcell_state* pcell_state);
void pcell_append_pfile(struct pcell_state* pcell_state, const char* pfile);
void pcell_enable_debug(struct pcell_state* pcell_state);
void pcell_set_dprint_target(struct pcell_state* pcell_state, const char* filename);
void pcell_enable_dprint(struct pcell_state* pcell_state);
void pcell_set_verbose(struct pcell_state* pcell_state);
void pcell_prepend_cellpath(struct pcell_state* pcell_state, const char* path);
void pcell_append_cellpath(struct pcell_state* pcell_state, const char* path);

#endif /* OPC_PCELL_STATE_H */
