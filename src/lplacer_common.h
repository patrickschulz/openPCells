#ifndef OPC_LPLACER_COMMON_H
#define OPC_LPLACER_COMMON_H

struct basic_cell
{
    unsigned int instance;
    unsigned int reference;
    unsigned int width;
    struct net** nets;
    unsigned int* pinoffset;
    unsigned int num_conns;
};

#endif /* OPC_LPLACER_COMMON_H */
