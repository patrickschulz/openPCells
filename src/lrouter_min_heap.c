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

struct node {
    point_t *point;
};

struct minheap {
    size_t size;
    struct node *elem;
};

struct minheap *heap_init(void)
{
    struct minheap *heap = malloc(sizeof(struct minheap));
    heap->size = 0;
    return heap;
}

void heap_destroy(struct minheap* heap)
{
    for(size_t i = 0; i < heap->size; ++i)
    {
        free(heap->elem[i].point);
    }
    if(heap->size)
    {
        free(heap->elem);
    }
    free(heap);
}

/* Function to swap data within two nodes of the min heap using pointers */
static void swap(struct node *n1, struct node *n2)
{
    struct node temp = *n1;
    *n1 = *n2;
    *n2 = temp;
}

/*
 *  Heapify function is used to make sure that the heap property is never violated
 *  In case of deletion of a node, or creating a min heap from an array, heap property
 *  may be violated. In such cases, heapify function can be called to make sure that
 *  heap property is never violated
 */
static void heapify(struct minheap *hp, size_t i)
{
    size_t smallest = (LCHILD(i) < hp->size && hp->elem[LCHILD(i)].point->score <
            hp->elem[i].point->score) ? LCHILD(i) : i;
    if(RCHILD(i) < hp->size && hp->elem[RCHILD(i)].point->score < hp->elem[smallest].point->score)
    {
        smallest = RCHILD(i);
    }

    if(smallest != i)
    {
        swap(&(hp->elem[i]), &(hp->elem[smallest]));
        heapify(hp, smallest);
    }
}

void heap_insert_point(struct minheap *hp, int x, int y, int z, unsigned int score)
{
    if(hp->size)
    {
        hp->elem = realloc(hp->elem, (hp->size + 1) * sizeof(struct node));
    }
    else
    {
        hp->elem = malloc(sizeof(struct node));
    }

    struct node nd;
    nd.point = point_new(x, y, z, score);

    size_t i = hp->size;
    while(i && nd.point->score <= hp->elem[PARENT(i)].point->score)
    {
        hp->elem[i] = hp->elem[PARENT(i)];
        i = PARENT(i);
    }
    hp->size++;
    hp->elem[i] = nd;
}

/*
 *  Function to get a node from the min heap
 *  It shall remove the root node, and place the last node in its place
 *  and then call heapify function to make sure that the heap property
 *  is never violated
 */
point_t *heap_get_point(struct minheap *hp)
{
    if(hp->size)
    {
        point_t* point = hp->elem[0].point;
        hp->elem[0] = hp->elem[--(hp->size)];
        hp->elem = realloc(hp->elem, hp->size * sizeof(struct node));
        heapify(hp, 0);
        return point;
    }
    else
    {
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
point_t *heap_get_max_node(struct minheap *hp, size_t i)
{
    if(LCHILD(i) >= hp->size)
    {
        return hp->elem[i].point;
    }

    point_t *left = heap_get_max_node(hp, LCHILD(i));
    unsigned int l = left->score;
    point_t *right = heap_get_max_node(hp, RCHILD(i));
    unsigned int r = right->score;

    if(l >= r)
    {
        return left;
    }
    else
    {
        return right;
    }
}


/* Function to clear the memory allocated for the min heap */
void heap_delete(struct minheap *hp)
{
    free(hp->elem);
}


/*
   Function to display all the nodes in the min heap by doing a inorder traversal
   */
void heap_inorder_trav(struct minheap *hp, size_t i)
{
    if(LCHILD(i) < hp->size)
    {
        heap_inorder_trav(hp, LCHILD(i));
    }
    printf("%d ", hp->elem[i].point->score);
    if(RCHILD(i) < hp->size)
    {
        heap_inorder_trav(hp, RCHILD(i));
    }
}


/*
   Function to display all the nodes in the min heap by doing a preorder traversal
   */
void heap_preorder_trav(struct minheap *hp, size_t i)
{
    if(LCHILD(i) < hp->size)
    {
        heap_preorder_trav(hp, LCHILD(i));
    }
    if(RCHILD(i) < hp->size)
    {
        heap_preorder_trav(hp, RCHILD(i));
    }
    printf("%d ", hp->elem[i].point->score);
}


/*
   Function to display all the nodes in the min heap by doing a post order traversal
   */
void heap_postorder_trav(struct minheap *hp, size_t i)
{
    printf("%d ", hp->elem[i].point->score);
    if(LCHILD(i) < hp->size)
    {
        heap_postorder_trav(hp, LCHILD(i));
    }
    if(RCHILD(i) < hp->size)
    {
        heap_postorder_trav(hp, RCHILD(i));
    }
}


/*
   Function to display all the nodes in the min heap by doing a level order traversal
   */
void heap_levelorder_trav(struct minheap *hp)
{
    size_t i;
    for(i = 0; i < hp->size; i++)
    {
        printf("%d ", hp->elem[i].point->score);
    }
}

int heap_empty(struct minheap* heap)
{
    return heap->size == 0;
}

