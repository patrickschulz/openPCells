#ifndef LROUTER_QUEUE_H
#define LROUTER_QUEUE_H

#include "lrouter_field.h"

/*
 * taken from
 * https://de.wikibooks.org/wiki/Algorithmen_und_Datenstrukturen_in_C/
 * _Warteschlange
 * Modified by Philipp nickel
 */

struct queue;

int queue_destroy(struct queue *queue);
int queue_empty(struct queue *queue);
void queue_clear(struct queue *queue);
struct queue *queue_new(void);
void *queue_dequeue(struct queue *queue);
int queue_enqueue(struct queue *queue, void *data);
int queue_len(struct queue *queue);
void queue_print(struct queue *queue);
void queue_reverse(struct queue *queue);
void *queue_peek_nth_elem(struct queue *queue, unsigned int n);

/* takes a queue and gives back the entries as a position_t array */
point_t *queue_as_array(struct queue *queue);

#endif
