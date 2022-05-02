#ifndef OPC_LPLACER_RAND_H
#define OPC_LPLACER_RAND_H

typedef unsigned long Rand64;
struct RanState {
  Rand64 s[4];
};

void randseed (struct RanState *state, unsigned long n1, unsigned long n2);
long _lua_randi(struct RanState* state, long low, long up);
int random_choice(struct RanState* rstate, double prob);

struct UPRNG
{
    unsigned int* numbers;
    unsigned int size;
    unsigned int index;
    struct RanState* rstate;
};

struct UPRNG* UPRNG_init(unsigned int size, struct RanState* rstate);
void UPRNG_destroy(struct UPRNG* rng);
void UPRNG_resize(struct UPRNG** rng, unsigned int size);
unsigned int UPRNG_next(struct UPRNG* rng);

#endif // OPC_LPLACER_RAND_H
