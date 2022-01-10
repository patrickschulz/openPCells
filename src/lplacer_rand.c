#include "lplacer_rand.h"

#include <stdlib.h>

#include "lua/lua.h"

/* avoid using extra bits when needed */
#define trim64(x)	((x) & 0xffffffffffffffffu)

/* rotate left 'x' by 'n' bits */
static Rand64 rotl (Rand64 x, int n) {
  return (x << n) | (trim64(x) >> (64 - n));
}

static Rand64 nextrand(struct RanState *state)
{
    Rand64 state0 = state->s[0];
    Rand64 state1 = state->s[1];
    Rand64 state2 = state->s[2] ^ state0;
    Rand64 state3 = state->s[3] ^ state1;
    Rand64 res = rotl(state1 * 5, 7) * 9;
    state->s[0] = state0 ^ state3;
    state->s[1] = state1 ^ state2;
    state->s[2] = state2 ^ (state1 << 17);
    state->s[3] = rotl(state3, 45);
    return res;
}


void randseed(struct RanState *state, unsigned long n1, unsigned long n2)
{
    int i;
    state->s[0] = (Rand64)(n1);
    state->s[1] = (Rand64)(0xff);  /* avoid a zero state */
    state->s[2] = (Rand64)(n2);
    state->s[3] = (Rand64)(0);
    for (i = 0; i < 16; i++)
    {
        nextrand(state);  /* discard initial values to "spread" seed */
    }
}

/* convert a 'Rand64' to a 'unsigned long' */
#define I2UInt(x)	((unsigned long)trim64(x))

/*
** Project the random integer 'ran' into the interval [0, n].
** Because 'ran' has 2^B possible values, the projection can only be
** uniform when the size of the interval is a power of 2 (exact
** division). Otherwise, to get a uniform projection into [0, n], we
** first compute 'lim', the smallest Mersenne number not smaller than
** 'n'. We then project 'ran' into the interval [0, lim].  If the result
** is inside [0, n], we are done. Otherwise, we try with another 'ran',
** until we have a result inside the interval.
*/
static unsigned long project (unsigned long ran, unsigned long n,
                             struct RanState *state) {
  if ((n & (n + 1)) == 0)  /* is 'n + 1' a power of 2? */
    return ran & n;  /* no bias */
  else {
    unsigned long lim = n;
    /* compute the smallest (2^b - 1) not smaller than 'n' */
    lim |= (lim >> 1);
    lim |= (lim >> 2);
    lim |= (lim >> 4);
    lim |= (lim >> 8);
    lim |= (lim >> 16);
#if (LUA_MAXUNSIGNED >> 31) >= 3
    lim |= (lim >> 32);  /* integer type has more than 32 bits */
#endif
    while ((ran &= lim) > n)  /* project 'ran' into [0..lim] */
      ran = I2UInt(nextrand(state));  /* not inside [0..n]? try again */
    return ran;
  }
}

#define FIGS 64
/* must throw out the extra (64 - FIGS) bits */
#define shift64_FIG	(64 - FIGS)

/* to scale to [0, 1), multiply by scaleFIG = 2^(-FIGS) */
#define scaleFIG	(l_mathop(0.5) / ((Rand64)1 << (FIGS - 1)))

static double I2d (Rand64 x) {
  return (double)(trim64(x) >> shift64_FIG) * scaleFIG;
}

static double _lua_rand(struct RanState* state)
{
    Rand64 rv = nextrand(state);  /* next pseudo-random value */
    return I2d(rv);  /* float between 0 and 1 */
}

long _lua_randi(struct RanState* state, long low, long up)
{
    Rand64 rv = nextrand(state);  /* next pseudo-random value */
    /* project random integer into the interval [0, up - low] */
    unsigned long p;
    p = project(I2UInt(rv), (unsigned long)up - (unsigned long)low, state);
    return p + (unsigned long)low;
}

int random_choice(struct RanState* rstate, double prob)
{
    double r = _lua_rand(rstate);
    return r < prob;
}

// unique random number generator
static void _shuffle(unsigned int *numbers, unsigned int size, struct RanState* rstate)
{
    unsigned int i, j, tmp;
    for (i = size - 1; i > 0; i--)
    {
        j = _lua_randi(rstate, 0, i);
        tmp = numbers[j];
        numbers[j] = numbers[i];
        numbers[i] = tmp;
    }
}

struct UPRNG* UPRNG_init(unsigned int size, struct RanState* rstate)
{
    struct UPRNG* rng = malloc(sizeof(struct UPRNG));
    rng->numbers = malloc(sizeof(unsigned int) * size);
    for(unsigned int i = 0; i < size; ++i)
    {
        rng->numbers[i] = i;
    }
    rng->index = 0;
    rng->size = size;
    rng->rstate = rstate;
    _shuffle(rng->numbers, rng->size, rng->rstate);
    return rng;
}

void UPRNG_destroy(struct UPRNG* rng)
{
    free(rng);
}

void UPRNG_resize(struct UPRNG** rng, unsigned int size)
{
    struct RanState* rstate = (*rng)->rstate;
    UPRNG_destroy(*rng);
    *rng = UPRNG_init(size, rstate);
}

unsigned int UPRNG_next(struct UPRNG* rng)
{
    unsigned int num = rng->numbers[rng->index];
    rng->index = (rng->index + 1) % rng->size;
    if(rng->index == 0)
    {
        _shuffle(rng->numbers, rng->size, rng->rstate);
    }
    return num;
}

