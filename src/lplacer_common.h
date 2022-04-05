#ifndef LPLACER_COMMON_H
#define LPLACER_COMMON_H

struct basic_cell
{
    unsigned int instance;
    unsigned int reference;
    unsigned int width;
    struct net** nets;
    unsigned int* pinoffset;
    unsigned int num_conns;
};

#endif /* LPLACER_COMMON_H */
