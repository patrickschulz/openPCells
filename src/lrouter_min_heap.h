/*
*  File:   lrouter_min_heap.h
*  Desc:   Program showing various operations on a binary min heap
*  Author: Robin Thomas <robinthomas2591@gmail.com>
*  Taken from: https://github.com/robin-thomas/min-heap
*  Changed and restructured by Philipp Nickel to store struct rpoint
*/

#ifndef LROUTER_MIN_HEAP_H
#define LROUTER_MIN_HEAP_H

#include "lrouter_field.h"

struct minheap;

/* Function to initialize the min heap with size = 0 */
struct minheap *heap_init(void);
void heap_destroy(struct minheap* heap);

/*
*  Function to insert a node into the min heap, by allocating space for
*  that node in the heap and also making sure that the heap property
*  and shape propety are never violated.
*  Changed smaller to smaller or equal so it works as a FIFO queue for same val
*  nodes
*/
void heap_insert_point(struct minheap *hp, int x, int y, int z, unsigned int score);

/*
*  Function to get a node from the min heap
*  It shall remove the root node, and place the last node in its place
*  and then call heapify function to make sure that the heap property
*  is never violated
*/
struct rpoint *heap_get_point(struct minheap *hp);

/* Function to display all the nodes in the min heap by inorder traversal */
void heap_inorder_trav(struct minheap *hp, size_t i);

int heap_empty(struct minheap* heap);

#endif
