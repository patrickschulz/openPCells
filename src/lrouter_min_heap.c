/*
*  File:   lrouter_min_heap.c
*  Desc:   Program showing various operations on a binary min heap
*  Author: Robin Thomas <robinthomas2591@gmail.com>
*  Taken from: https://github.com/robin-thomas/min-heap
*  Changed and restructured by Philipp Nickel to store point_t
*/

#include "lrouter_field.h"
#include "lrouter_min_heap.h"

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define LCHILD(x) 2 * x + 1
#define RCHILD(x) 2 * x + 2
#define PARENT(x) (x - 1) / 2

min_heap_t *heap_init() {
    min_heap_t *heap = malloc(sizeof(min_heap_t));
    heap->size = 0;
    return heap;
}

/* Function to swap data within two nodes of the min heap using pointers */
static void swap(heap_node_t *n1, heap_node_t *n2) {
    heap_node_t temp = *n1;
    *n1 = *n2;
    *n2 = temp;
}

/*
*  Heapify function is used to make sure that the heap property is never violated
*  In case of deletion of a node, or creating a min heap from an array, heap property
*  may be violated. In such cases, heapify function can be called to make sure that
*  heap property is never violated
*/
static void heapify(min_heap_t *hp, size_t i) {
    size_t smallest = (LCHILD(i) < hp->size && hp->elem[LCHILD(i)].point->score <
		    hp->elem[i].point->score) ? LCHILD(i) : i;
    if(RCHILD(i) < hp->size && hp->elem[RCHILD(i)].point->score <
			hp->elem[smallest].point->score)
    {
        smallest = RCHILD(i);
    }

    if(smallest != i)
    {
        swap(&(hp->elem[i]), &(hp->elem[smallest]));
        heapify(hp, smallest);
    }
}

void heap_insert_point(min_heap_t *hp, point_t *point) {
    if(hp->size) {
        hp->elem = realloc(hp->elem, (hp->size + 1) * sizeof(heap_node_t));
    } else {
        hp->elem = malloc(sizeof(heap_node_t));
    }

    heap_node_t nd;
    nd.point = point;

    size_t i = (hp->size)++;
    while(i && nd.point->score <= hp->elem[PARENT(i)].point->score) {
        hp->elem[i] = hp->elem[PARENT(i)];
        i = PARENT(i);
    }
    hp->elem[i] = nd;
}

/*
*  Function to get a node from the min heap
*  It shall remove the root node, and place the last node in its place
*  and then call heapify function to make sure that the heap property
*  is never violated
*/
point_t *heap_get_point(min_heap_t *hp) {
    if(hp->size) {
	point_t *point = malloc(sizeof(point_t));
	point = hp->elem[0].point;
        hp->elem[0] = hp->elem[--(hp->size)];
        hp->elem = realloc(hp->elem, hp->size * sizeof(heap_node_t));
        heapify(hp, 0);
	return point;
    } else {
	return NULL;
    }
}

/*
*  Function to get maximum node from a min heap
*  The maximum node shall always be one of the leaf nodes. So we shall recursively
*  move through both left and right child, until we find their maximum nodes, and
*  compare which is larger. It shall be done recursively until we get the maximum
*  node
*/
point_t *heap_get_max_node(min_heap_t *hp, size_t i) {
    if(LCHILD(i) >= hp->size) {
        return hp->elem[i].point;
    }

    point_t *left = heap_get_max_node(hp, LCHILD(i));
    unsigned int l = left->score;
    point_t *right = heap_get_max_node(hp, RCHILD(i));
    unsigned int r = right->score;

    if(l >= r) {
        return left;
    } else {
        return right;
    }
}


/* Function to clear the memory allocated for the min heap */
void heap_delete(min_heap_t *hp) {
    free(hp->elem);
}


/*
    Function to display all the nodes in the min heap by doing a inorder traversal
*/
void heap_inorder_trav(min_heap_t *hp, size_t i) {
    if(LCHILD(i) < hp->size) {
        heap_inorder_trav(hp, LCHILD(i));
    }
    printf("%d ", hp->elem[i].point->score);
    if(RCHILD(i) < hp->size) {
        heap_inorder_trav(hp, RCHILD(i));
    }
}


/*
    Function to display all the nodes in the min heap by doing a preorder traversal
*/
void heap_preorder_trav(min_heap_t *hp, size_t i) {
    if(LCHILD(i) < hp->size) {
        heap_preorder_trav(hp, LCHILD(i));
    }
    if(RCHILD(i) < hp->size) {
        heap_preorder_trav(hp, RCHILD(i));
    }
    printf("%d ", hp->elem[i].point->score);
}


/*
    Function to display all the nodes in the min heap by doing a post order traversal
*/
void heap_postorder_trav(min_heap_t *hp, size_t i) {
    printf("%d ", hp->elem[i].point->score);
    if(LCHILD(i) < hp->size) {
        heap_postorder_trav(hp, LCHILD(i));
    }
    if(RCHILD(i) < hp->size) {
        heap_postorder_trav(hp, RCHILD(i));
    }
}


/*
    Function to display all the nodes in the min heap by doing a level order traversal
*/
void heap_levelorder_trav(min_heap_t *hp) {
    size_t i;
    for(i = 0; i < hp->size; i++) {
        printf("%d ", hp->elem[i].point->score);
    }
}

