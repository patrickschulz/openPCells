/*
*  File:   lrouter_min_heap.h
*  Desc:   Program showing various operations on a binary min heap
*  Author: Robin Thomas <robinthomas2591@gmail.com>
*  Taken from: https://github.com/robin-thomas/min-heap
*  Changed and restructured by Philipp Nickel to store point_t
*/

#ifndef LROUTER_MIN_HEAP_H
#define LROUTER_MIN_HEAP_H

#include "lrouter_field.h"

typedef struct node {
    point_t *point;
} heap_node_t;

typedef struct minheap {
    size_t size;
    heap_node_t *elem;
} min_heap_t;

/* Function to initialize the min heap with size = 0 */
min_heap_t *heap_init(void);
void heap_destroy(min_heap_t* heap);

/*
*  Function to insert a node into the min heap, by allocating space for
*  that node in the heap and also making sure that the heap property
*  and shape propety are never violated.
*  Changed smaller to smaller or equal so it works as a FIFO queue for same val
*  nodes
*/
void heap_insert_point(min_heap_t *hp, int x, int y, int z, unsigned int score);

/*
*  Function to get a node from the min heap
*  It shall remove the root node, and place the last node in its place
*  and then call heapify function to make sure that the heap property
*  is never violated
*/
point_t *heap_get_point(min_heap_t *hp);

/* Function to display all the nodes in the min heap by inorder traversal */
void heap_inorder_trav(min_heap_t *hp, size_t i);

#endif
