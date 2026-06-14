/*
 * Public interface functions for the object module.
 * All other functionality should be hidden in object.xx.c modules, for better encapsulation.
 * Only the necessary parts should be exposed.
 */

#include "object.h"

#include <stdlib.h>
#include <string.h>

#define OPC_OBJECT_IMPLEMENTATION
#include "object.base.h"
#include "object.util.h"
#undef OPC_OBJECT_IMPLEMENTATION

#include "helpers.h"

struct object* object_create(const char* name)
{
    return objectbase_create(name);
}

struct object* object_create_pseudo(void)
{
    return objectbase_create_pseudo();
}

struct object* object_create_proxy(const char* name, struct object* reference)
{
    return objectbase_create_proxy(name, reference);
}

struct object* object_copy(const struct object* cell)
{
    return objectbase_copy(cell);
}

void object_destroy(void* cell)
{
    objectbase_destroy(cell);
}

void object_set_name(struct object* cell, const char* name)
{
    objectbase_set_name(cell, name);
}

int object_add_anchor(struct object* cell, const char* name, coordinate_t x, coordinate_t y)
{
    return objectbase_add_anchor(cell, name, x, y);
}

int object_add_area_anchor_bltr(struct object* cell, const char* name, const struct point* bl, const struct point* tr)
{
    return objectbase_add_area_anchor_bltr(cell, name, bl->x, bl->y, tr->x, tr->y);
}

int object_add_area_anchor_points(struct object* cell, const char* name, const struct point* pt1, const struct point* pt2)
{
    coordinate_t blx = point_getx(pt1);
    coordinate_t bly = point_gety(pt1);
    coordinate_t trx = point_getx(pt2);
    coordinate_t try = point_gety(pt2);
    objectutil_fix_rectangle_order_xy(&blx, &bly, &trx, &try);
    return objectbase_add_area_anchor_bltr(cell, name, blx, bly, trx, try);
}

int object_add_area_anchor_blwh(struct object* cell, const char* name, const struct point* bl, coordinate_t width, coordinate_t height)
{
    return objectbase_add_area_anchor_bltr(cell, name, bl->x, bl->y, bl->x + width, bl->y + height);
}

int object_add_anchor_line_x(struct object* cell, const char* name, coordinate_t c)
{
    objectbase_add_anchor_line_x(cell, name, c);
}

int object_add_anchor_line_y(struct object* cell, const char* name, coordinate_t c)
{
    objectbase_add_anchor_line_y(cell, name, c);
}

int object_inherit_anchor_as(struct object* cell, const struct object* other, const char* name, const char* newname)
{
    if(object_is_proxy(cell))
    {
        return 0;
    }
    struct point* anchor = object_get_anchor(other, name);
    if(anchor)
    {
        object_add_anchor(cell, newname, point_getx(anchor), point_gety(anchor));
        free(anchor);
    }
    return 1;
}

int object_inherit_anchor(struct object* cell, const struct object* other, const char* name)
{
    return object_inherit_anchor_as(cell, other, name, name);
}

int object_inherit_area_anchor_as(struct object* cell, const struct object* other, const char* name, const char* newname)
{
    if(object_is_proxy(cell))
    {
        return 0;
    }
    struct point* anchor = object_get_area_anchor(other, name);
    if(anchor)
    {
        object_add_area_anchor_bltr(cell, newname, anchor + 0, anchor + 1);
        free(anchor);
    }
    return 1;
}

int object_inherit_area_anchor(struct object* cell, const struct object* other, const char* name)
{
    return object_inherit_area_anchor_as(cell, other, name, name);
}

void object_inherit_all_anchors(struct object* cell, const struct object* other)
{
    objectbase_inherit_all_anchors_with_prefix(cell, other, "");
}

void object_inherit_all_anchors_with_prefix(struct object* cell, const struct object* other, const char* prefix)
{
    objectbase_inherit_all_anchors_with_prefix(cell, other, prefix);
}

// ************************************************************************************************************************ 
// Alignment Box
// ************************************************************************************************************************ 
struct point* object_get_alignment_anchor(const struct object* cell, const char* name)
{
    coordinate_t* ab = objectbase_get_transformed_alignment_box(cell);
    coordinate_t x, y;
    if(strcmp(name, "outerbl") == 0)
    {
        x = objectbase_alignmentbox_get_outerblx(ab);
        y = objectbase_alignmentbox_get_outerbly(ab);
    }
    else if(strcmp(name, "outerbr") == 0)
    {
        x = objectbase_alignmentbox_get_outertrx(ab);
        y = objectbase_alignmentbox_get_outerbly(ab);
    }
    else if(strcmp(name, "outertl") == 0)
    {
        x = objectbase_alignmentbox_get_outerblx(ab);
        y = objectbase_alignmentbox_get_outertry(ab);
    }
    else if(strcmp(name, "outertr") == 0)
    {
        x = objectbase_alignmentbox_get_outertrx(ab);
        y = objectbase_alignmentbox_get_outertry(ab);
    }
    else if(strcmp(name, "innerbl") == 0)
    {
        x = objectbase_alignmentbox_get_innerblx(ab);
        y = objectbase_alignmentbox_get_innerbly(ab);
    }
    else if(strcmp(name, "innerbr") == 0)
    {
        x = objectbase_alignmentbox_get_innertrx(ab);
        y = objectbase_alignmentbox_get_innerbly(ab);
    }
    else if(strcmp(name, "innertl") == 0)
    {
        x = objectbase_alignmentbox_get_innerblx(ab);
        y = objectbase_alignmentbox_get_innertry(ab);
    }
    else if(strcmp(name, "innertr") == 0)
    {
        x = objectbase_alignmentbox_get_innertrx(ab);
        y = objectbase_alignmentbox_get_innertry(ab);
    }
    else
    {
        free(ab);
        return NULL;
    }
    free(ab);
    return point_create(x, y);
}

void object_width_height_alignmentbox(const struct object* cell, ucoordinate_t* width, ucoordinate_t* height)
{
    coordinate_t* ab = objectbase_get_transformed_alignment_box(cell);
    *width = objectbase_alignmentbox_get_outertrx(ab) - objectbase_alignmentbox_get_innerblx(ab);
    *height = objectbase_alignmentbox_get_outertry(ab) - objectbase_alignmentbox_get_innerbly(ab);
    free(ab);
}

struct point* object_get_alignmentbox_anchor_outerbl(const struct object* cell)
{
    coordinate_t* ab = objectbase_get_transformed_alignment_box(cell);
    coordinate_t x = objectbase_alignmentbox_get_outerblx(ab);
    coordinate_t y = objectbase_alignmentbox_get_outerbly(ab);
    free(ab);
    return point_create(x, y);
}

struct point* object_get_alignmentbox_anchor_outertr(const struct object* cell)
{
    coordinate_t* ab = objectbase_get_transformed_alignment_box(cell);
    coordinate_t x = objectbase_alignmentbox_get_outertrx(ab);
    coordinate_t y = objectbase_alignmentbox_get_outertry(ab);
    free(ab);
    return point_create(x, y);
}

struct point* object_get_alignmentbox_anchor_innerbl(const struct object* cell)
{
    coordinate_t* ab = objectbase_get_transformed_alignment_box(cell);
    coordinate_t x = objectbase_alignmentbox_get_innerblx(ab);
    coordinate_t y = objectbase_alignmentbox_get_innerbly(ab);
    free(ab);
    return point_create(x, y);
}

struct point* object_get_alignmentbox_anchor_innertr(const struct object* cell)
{
    coordinate_t* ab = objectbase_get_transformed_alignment_box(cell);
    coordinate_t x = objectbase_alignmentbox_get_innertrx(ab);
    coordinate_t y = objectbase_alignmentbox_get_innertry(ab);
    free(ab);
    return point_create(x, y);
}

// ************************************************************************************************************************ 
// Anchors
// ************************************************************************************************************************ 
struct point* object_get_anchor(const struct object* cell, const char* name)
{
    return objectbase_get_anchor(cell, name);
}

struct point* object_get_area_anchor(const struct object* cell, const char* name)
{
    return objectbase_get_area_anchor(cell, name);
}

struct point* object_get_array_anchor(const struct object* cell, int xindex, int yindex, const char* name)
{
    return objectbase_get_array_anchor(cell, xindex, yindex, name);
}

struct point* object_get_array_area_anchor(const struct object* cell, int xindex, int yindex, const char* name)
{
    return objectbase_get_array_area_anchor(cell, xindex, yindex, name);
}

coordinate_t* object_get_anchor_line_x(const struct object* cell, const char* name)
{
    coordinate_t* c = objectbase_get_anchor_line(cell, name);
    if(c)
    {
        coordinate_t dummy;
        objectbase_transform_to_global_coordinates_xy(cell, c, &dummy);
        return c;
    }
    else
    {
        return NULL;
    }
}

coordinate_t* object_get_anchor_line_y(const struct object* cell, const char* name)
{
    coordinate_t* c = objectbase_get_anchor_line(cell, name);
    if(c)
    {
        coordinate_t dummy;
        objectbase_transform_to_global_coordinates_xy(cell, &dummy, c);
        return c;
    }
    else
    {
        return NULL;
    }
}

// ************************************************************************************************************************ 
// Placment/Abutting/Aligning
// ************************************************************************************************************************ 
int object_abut_right(struct object* cell, const struct object* other)
{
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t* alb2 = objectbase_get_transformed_alignment_box(other);
    coordinate_t x1 = objectbase_alignmentbox_get_outerblx(alb1);
    coordinate_t x2 = objectbase_alignmentbox_get_innertrx(alb2);
    object_translate(cell, x2 - x1, 0);
    free(alb1);
    free(alb2);
    return 1;
}

int object_abut_left(struct object* cell, const struct object* other)
{
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t* alb2 = objectbase_get_transformed_alignment_box(other);
    coordinate_t x1 = objectbase_alignmentbox_get_outertrx(alb1);
    coordinate_t x2 = objectbase_alignmentbox_get_innerblx(alb2);
    object_translate(cell, x2 - x1, 0);
    free(alb1);
    free(alb2);
    return 1;
}

int object_abut_top(struct object* cell, const struct object* other)
{
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t* alb2 = objectbase_get_transformed_alignment_box(other);
    coordinate_t y1 = objectbase_alignmentbox_get_outerbly(alb1);
    coordinate_t y2 = objectbase_alignmentbox_get_innertry(alb2);
    object_translate(cell, 0, y2 - y1);
    free(alb1);
    free(alb2);
    return 1;
}

int object_abut_bottom(struct object* cell, const struct object* other)
{
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t* alb2 = objectbase_get_transformed_alignment_box(other);
    coordinate_t y1 = objectbase_alignmentbox_get_outertry(alb1);
    coordinate_t y2 = objectbase_alignmentbox_get_innerbly(alb2);
    object_translate(cell, 0, y2 - y1);
    free(alb1);
    free(alb2);
    return 1;
}

int object_abut_right_origin(struct object* cell)
{
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t x1 = objectbase_alignmentbox_get_outerblx(alb1);
    object_translate(cell, 0 - x1, 0);
    free(alb1);
    return 1;
}

int object_abut_left_origin(struct object* cell)
{
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t x1 = objectbase_alignmentbox_get_outertrx(alb1);
    object_translate(cell, 0 - x1, 0);
    free(alb1);
    return 1;
}

int object_abut_top_origin(struct object* cell)
{
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t y1 = objectbase_alignmentbox_get_outerbly(alb1);
    object_translate(cell, 0, 0 - y1);
    free(alb1);
    return 1;
}

int object_abut_bottom_origin(struct object* cell)
{
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t y1 = objectbase_alignmentbox_get_outertry(alb1);
    object_translate(cell, 0, 0 - y1);
    free(alb1);
    return 1;
}

int object_align_right(struct object* cell, const struct object* other)
{
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t* alb2 = objectbase_get_transformed_alignment_box(other);
    coordinate_t x1 = objectbase_alignmentbox_get_outertrx(alb1);
    coordinate_t x2 = objectbase_alignmentbox_get_outertrx(alb2);
    object_translate(cell, x2 - x1, 0);
    free(alb1);
    free(alb2);
    return 1;
}

int object_align_left(struct object* cell, const struct object* other)
{
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t* alb2 = objectbase_get_transformed_alignment_box(other);
    coordinate_t x1 = objectbase_alignmentbox_get_outerblx(alb1);
    coordinate_t x2 = objectbase_alignmentbox_get_outerblx(alb2);
    object_translate(cell, x2 - x1, 0);
    free(alb1);
    free(alb2);
    return 1;
}

int object_align_top(struct object* cell, const struct object* other)
{
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t* alb2 = objectbase_get_transformed_alignment_box(other);
    coordinate_t y1 = objectbase_alignmentbox_get_outertry(alb1);
    coordinate_t y2 = objectbase_alignmentbox_get_outertry(alb2);
    object_translate(cell, 0, y2 - y1);
    free(alb1);
    free(alb2);
    return 1;
}

int object_align_bottom(struct object* cell, const struct object* other)
{
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t* alb2 = objectbase_get_transformed_alignment_box(other);
    coordinate_t y1 = objectbase_alignmentbox_get_outerbly(alb1);
    coordinate_t y2 = objectbase_alignmentbox_get_outerbly(alb2);
    object_translate(cell, 0, y2 - y1);
    free(alb1);
    free(alb2);
    return 1;
}

int object_align_center_x(struct object* cell, const struct object* other)
{
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t* alb2 = objectbase_get_transformed_alignment_box(other);
    coordinate_t x1l = objectbase_alignmentbox_get_outerblx(alb1);
    coordinate_t x1r = objectbase_alignmentbox_get_outertrx(alb1);
    coordinate_t x2l = objectbase_alignmentbox_get_outerblx(alb2);
    coordinate_t x2r = objectbase_alignmentbox_get_outertrx(alb2);
    object_translate(cell, (x2l + x2r - x1l - x1r) / 2, 0);
    free(alb1);
    free(alb2);
    return 1;
}

int object_align_center_y(struct object* cell, const struct object* other)
{
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t* alb2 = objectbase_get_transformed_alignment_box(other);
    coordinate_t y1l = objectbase_alignmentbox_get_outerbly(alb1);
    coordinate_t y1r = objectbase_alignmentbox_get_outertry(alb1);
    coordinate_t y2l = objectbase_alignmentbox_get_outerbly(alb2);
    coordinate_t y2r = objectbase_alignmentbox_get_outertry(alb2);
    object_translate(cell, 0, (y2l + y2r - y1l - y1r) / 2);
    free(alb1);
    free(alb2);
    return 1;
}

int object_place_right(struct object* cell, const struct object* other)
{
    coordinate_t* alb1 = objectbase_get_transformed_bounding_box(cell);
    coordinate_t* alb2 = objectbase_get_transformed_bounding_box(other);
    coordinate_t x1 = objectbase_boundingbox_get_blx(alb1);
    coordinate_t x2 = objectbase_boundingbox_get_trx(alb2);
    object_translate(cell, x2 - x1, 0);
    free(alb1);
    free(alb2);
    return 1;
}

int object_place_left(struct object* cell, const struct object* other)
{
    coordinate_t* alb1 = objectbase_get_transformed_bounding_box(cell);
    coordinate_t* alb2 = objectbase_get_transformed_bounding_box(other);
    coordinate_t x1 = objectbase_boundingbox_get_trx(alb1);
    coordinate_t x2 = objectbase_boundingbox_get_blx(alb2);
    object_translate(cell, x2 - x1, 0);
    free(alb1);
    free(alb2);
    return 1;
}

int object_place_top(struct object* cell, const struct object* other)
{
    coordinate_t* alb1 = objectbase_get_transformed_bounding_box(cell);
    coordinate_t* alb2 = objectbase_get_transformed_bounding_box(other);
    coordinate_t y1 = objectbase_boundingbox_get_bly(alb1);
    coordinate_t y2 = objectbase_boundingbox_get_try(alb2);
    object_translate(cell, 0, y2 - y1);
    free(alb1);
    free(alb2);
    return 1;
}

int object_place_bottom(struct object* cell, const struct object* other)
{
    coordinate_t* alb1 = objectbase_get_transformed_bounding_box(cell);
    coordinate_t* alb2 = objectbase_get_transformed_bounding_box(other);
    coordinate_t y1 = objectbase_boundingbox_get_try(alb1);
    coordinate_t y2 = objectbase_boundingbox_get_bly(alb2);
    object_translate(cell, 0, y2 - y1);
    free(alb1);
    free(alb2);
    return 1;
}

int object_place_right_origin(struct object* cell)
{
    coordinate_t* alb1 = objectbase_get_transformed_bounding_box(cell);
    coordinate_t x1 = objectbase_boundingbox_get_blx(alb1);
    object_translate(cell, 0 - x1, 0);
    free(alb1);
    return 1;
}

int object_place_left_origin(struct object* cell)
{
    coordinate_t* alb1 = objectbase_get_transformed_bounding_box(cell);
    coordinate_t x1 = objectbase_boundingbox_get_trx(alb1);
    object_translate(cell, 0 - x1, 0);
    free(alb1);
    return 1;
}

int object_place_top_origin(struct object* cell)
{
    coordinate_t* alb1 = objectbase_get_transformed_bounding_box(cell);
    coordinate_t y1 = objectbase_boundingbox_get_bly(alb1);
    object_translate(cell, 0, 0 - y1);
    free(alb1);
    return 1;
}

int object_place_bottom_origin(struct object* cell)
{
    coordinate_t* alb1 = objectbase_get_transformed_bounding_box(cell);
    coordinate_t y1 = objectbase_boundingbox_get_try(alb1);
    object_translate(cell, 0, 0 - y1);
    free(alb1);
    return 1;
}

int object_place_right_bltr(struct object* cell, const struct point* bl, const struct point* tr)
{
    (void)bl;
    coordinate_t* alb1 = objectbase_get_transformed_bounding_box(cell);
    coordinate_t x1 = objectbase_boundingbox_get_blx(alb1);
    coordinate_t x2 = point_getx(tr);
    object_translate(cell, x2 - x1, 0);
    free(alb1);
    return 1;
}

int object_place_left_bltr(struct object* cell, const struct point* bl, const struct point* tr)
{
    (void)tr;
    coordinate_t* alb1 = objectbase_get_transformed_bounding_box(cell);
    coordinate_t x1 = objectbase_boundingbox_get_trx(alb1);
    coordinate_t x2 = point_getx(bl);
    object_translate(cell, x2 - x1, 0);
    free(alb1);
    return 1;
}

int object_place_top_bltr(struct object* cell, const struct point* bl, const struct point* tr)
{
    (void)bl;
    coordinate_t* alb1 = objectbase_get_transformed_bounding_box(cell);
    coordinate_t y1 = objectbase_boundingbox_get_bly(alb1);
    coordinate_t y2 = point_gety(tr);
    object_translate(cell, 0, y2 - y1);
    free(alb1);
    return 1;
}

int object_place_bottom_bltr(struct object* cell, const struct point* bl, const struct point* tr)
{
    (void)tr;
    coordinate_t* alb1 = objectbase_get_transformed_bounding_box(cell);
    coordinate_t y1 = objectbase_boundingbox_get_try(alb1);
    coordinate_t y2 = point_gety(bl);
    object_translate(cell, 0, y2 - y1);
    free(alb1);
    return 1;
}

int object_abut_right_bltr(struct object* cell, const struct point* bl, const struct point* tr)
{
    (void)bl;
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t x1 = objectbase_alignmentbox_get_outerblx(alb1);
    coordinate_t x2 = point_getx(tr);
    object_translate(cell, x2 - x1, 0);
    free(alb1);
    return 1;
}

int object_abut_left_bltr(struct object* cell, const struct point* bl, const struct point* tr)
{
    (void)tr;
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t x1 = objectbase_alignmentbox_get_outertrx(alb1);
    coordinate_t x2 = point_getx(bl);
    object_translate(cell, x2 - x1, 0);
    free(alb1);
    return 1;
}

int object_abut_top_bltr(struct object* cell, const struct point* bl, const struct point* tr)
{
    (void)bl;
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t y1 = objectbase_alignmentbox_get_outerbly(alb1);
    coordinate_t y2 = point_gety(tr);
    object_translate(cell, 0, y2 - y1);
    free(alb1);
    return 1;
}

int object_abut_bottom_bltr(struct object* cell, const struct point* bl, const struct point* tr)
{
    (void)tr;
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t y1 = objectbase_alignmentbox_get_outertry(alb1);
    coordinate_t y2 = point_gety(bl);
    object_translate(cell, 0, y2 - y1);
    free(alb1);
    return 1;
}

int object_align_right_bltr(struct object* cell, const struct point* bl, const struct point* tr)
{
    (void)bl;
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t x1 = objectbase_alignmentbox_get_outertrx(alb1);
    coordinate_t x2 = point_getx(tr);
    object_translate(cell, x2 - x1, 0);
    free(alb1);
    return 1;
}

int object_align_left_bltr(struct object* cell, const struct point* bl, const struct point* tr)
{
    (void)tr;
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t x1 = objectbase_alignmentbox_get_outerblx(alb1);
    coordinate_t x2 = point_getx(bl);
    object_translate(cell, x2 - x1, 0);
    free(alb1);
    return 1;
}

int object_align_top_bltr(struct object* cell, const struct point* bl, const struct point* tr)
{
    (void)bl;
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t y1 = objectbase_alignmentbox_get_outertry(alb1);
    coordinate_t y2 = point_gety(tr);
    object_translate(cell, 0, y2 - y1);
    free(alb1);
    return 1;
}

int object_align_bottom_bltr(struct object* cell, const struct point* bl, const struct point* tr)
{
    (void)tr;
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t y1 = objectbase_alignmentbox_get_outerbly(alb1);
    coordinate_t y2 = point_gety(bl);
    object_translate(cell, 0, y2 - y1);
    free(alb1);
    return 1;
}

int object_align_center_x_bltr(struct object* cell, const struct point* bl, const struct point* tr)
{
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t x1l = objectbase_alignmentbox_get_outerblx(alb1);
    coordinate_t x1r = objectbase_alignmentbox_get_outertrx(alb1);
    coordinate_t x2l = point_getx(bl);
    coordinate_t x2r = point_getx(tr);
    object_translate(cell, (x2r - x2l - x1r + x1l) / 2, 0);
    free(alb1);
    return 1;
}

int object_align_center_y_bltr(struct object* cell, const struct point* bl, const struct point* tr)
{
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t y1l = objectbase_alignmentbox_get_outerbly(alb1);
    coordinate_t y1r = objectbase_alignmentbox_get_outertry(alb1);
    coordinate_t y2l = point_gety(bl);
    coordinate_t y2r = point_gety(tr);
    object_translate(cell, 0, (y2r - y2l - y1r + y1l) / 2);
    free(alb1);
    return 1;
}

int object_align_right_origin(struct object* cell)
{
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t x1 = objectbase_alignmentbox_get_outertrx(alb1);
    object_translate(cell, 0 - x1, 0);
    free(alb1);
    return 1;
}

int object_align_left_origin(struct object* cell)
{
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t x1 = objectbase_alignmentbox_get_outerblx(alb1);
    object_translate(cell, 0 - x1, 0);
    free(alb1);
    return 1;
}

int object_align_top_origin(struct object* cell)
{
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t y1 = objectbase_alignmentbox_get_outertry(alb1);
    object_translate(cell, 0, 0 - y1);
    free(alb1);
    return 1;
}

int object_align_bottom_origin(struct object* cell)
{
    coordinate_t* alb1 = objectbase_get_transformed_alignment_box(cell);
    coordinate_t y1 = objectbase_alignmentbox_get_outerbly(alb1);
    object_translate(cell, 0, 0 - y1);
    free(alb1);
    return 1;
}

// ************************************************************************************************************************ 
// Area Anchor Placement
// ************************************************************************************************************************ 
int object_abut_area_anchor_right(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t blx1 = objectbase_area_anchor_get_blx(pts1);
    coordinate_t trx2 = objectbase_area_anchor_get_trx(pts2);
    object_translate(cell, trx2 - blx1, 0);
    free(pts1);
    free(pts2);
    return 1;
}

int object_abut_area_anchor_left(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t trx1 = objectbase_area_anchor_get_trx(pts1);
    coordinate_t blx2 = objectbase_area_anchor_get_blx(pts2);
    object_translate(cell, blx2 - trx1, 0);
    free(pts1);
    free(pts2);
    return 1;
}

int object_abut_area_anchor_top(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t bly1 = objectbase_area_anchor_get_bly(pts1);
    coordinate_t try2 = objectbase_area_anchor_get_try(pts2);
    object_translate(cell, 0, try2 - bly1);
    free(pts1);
    free(pts2);
    return 1;
}

int object_abut_area_anchor_bottom(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t try1 = objectbase_area_anchor_get_try(pts1);
    coordinate_t bly2 = objectbase_area_anchor_get_bly(pts2);
    object_translate(cell, 0, bly2 - try1);
    free(pts1);
    free(pts2);
    return 1;
}

int object_area_anchors_fit(const struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t blx1 = objectbase_area_anchor_get_blx(pts1);
    coordinate_t bly1 = objectbase_area_anchor_get_bly(pts1);
    coordinate_t trx1 = objectbase_area_anchor_get_trx(pts1);
    coordinate_t try1 = objectbase_area_anchor_get_try(pts1);
    coordinate_t blx2 = objectbase_area_anchor_get_blx(pts2);
    coordinate_t bly2 = objectbase_area_anchor_get_bly(pts2);
    coordinate_t trx2 = objectbase_area_anchor_get_trx(pts2);
    coordinate_t try2 = objectbase_area_anchor_get_try(pts2);
    free(pts1);
    free(pts2);
    return ((trx1 - blx1) == (trx2 - blx2)) && ((try1 - bly1) == (try2 - bly2));
}

int object_align_area_anchor(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    if(!object_area_anchors_fit(cell, anchorname, other, otheranchorname))
    {
        return 0;
    }
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t blx1 = objectbase_area_anchor_get_blx(pts1);
    coordinate_t bly1 = objectbase_area_anchor_get_bly(pts1);
    coordinate_t blx2 = objectbase_area_anchor_get_blx(pts2);
    coordinate_t bly2 = objectbase_area_anchor_get_bly(pts2);
    object_translate(cell, blx2 - blx1, bly2 - bly1);
    free(pts1);
    free(pts2);
    return 1;
}

int object_align_area_anchor_x(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t blx1 = objectbase_area_anchor_get_blx(pts1);
    coordinate_t blx2 = objectbase_area_anchor_get_blx(pts2);
    object_translate(cell, blx2 - blx1, 0);
    free(pts1);
    free(pts2);
    return 1;
}

int object_align_area_anchor_left(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t blx1 = objectbase_area_anchor_get_blx(pts1);
    coordinate_t blx2 = objectbase_area_anchor_get_blx(pts2);
    object_translate(cell, blx2 - blx1, 0);
    free(pts1);
    free(pts2);
    return 1;
}

int object_align_area_anchor_right(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t trx1 = objectbase_area_anchor_get_trx(pts1);
    coordinate_t trx2 = objectbase_area_anchor_get_trx(pts2);
    object_translate(cell, trx2 - trx1, 0);
    free(pts1);
    free(pts2);
    return 1;
}

int object_align_area_anchor_y(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t bly1 = objectbase_area_anchor_get_bly(pts1);
    coordinate_t bly2 = objectbase_area_anchor_get_bly(pts2);
    object_translate(cell, 0, bly2 - bly1);
    free(pts1);
    free(pts2);
    return 1;
}

int object_align_area_anchor_top(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t try1 = objectbase_area_anchor_get_try(pts1);
    coordinate_t try2 = objectbase_area_anchor_get_try(pts2);
    object_translate(cell, 0, try2 - try1);
    free(pts1);
    free(pts2);
    return 1;
}

int object_align_area_anchor_bottom(struct object* cell, const char* anchorname, const struct object* other, const char* otheranchorname)
{
    struct point* pts1 = object_get_area_anchor(cell, anchorname);
    struct point* pts2 = object_get_area_anchor(other, otheranchorname);
    coordinate_t bly1 = objectbase_area_anchor_get_bly(pts1);
    coordinate_t bly2 = objectbase_area_anchor_get_bly(pts2);
    object_translate(cell, 0, bly2 - bly1);
    free(pts1);
    free(pts2);
    return 1;
}

// ************************************************************************************************************************ 
// Reference/Child Adding
// ************************************************************************************************************************ 
struct object* object_create_handle(struct object* cell, struct object* reference)
{
    if(objectbase_is_pseudo(reference)) // can't add pseudo objects
    {
        return NULL;
    }
    objectbase_add_reference(cell, reference);
    objectbase_set_managed(reference);
    objectbase_set_unused(reference); // stored objects are not necessarily used
    return reference;
}

struct object* object_add_child(struct object* cell, struct object* child, const char* name)
{
    if(objectbase_is_pseudo(child)) // can't add pseudo objects
    {
        return NULL;
    }
    if(!name) // need to pass name explicitly
    {
        return NULL;
    }
    struct object* proxy = objectbase_create_proxy(name, child);
    const struct transformationmatrix* ptrans = objectbase_get_tmatrix(cell);
    objectbase_set_tmatrix(proxy, transformationmatrix_invert(ptrans));
    objectbase_add_proxy(cell, proxy);
    objectbase_add_reference(cell, child);
    objectbase_set_used(child);
    return proxy;
}

struct object* object_add_child_array(struct object* cell, struct object* child, const char* name, unsigned int xrep, unsigned int yrep, coordinate_t xpitch, coordinate_t ypitch)
{
    if(objectbase_is_pseudo(child)) // can't add pseudo objects
    {
        return NULL;
    }
    struct object* proxy = object_add_child(cell, child, name);
    objectbase_set_array(proxy, xrep, yrep, xpitch, ypitch);
    return proxy;
}

// ************************************************************************************************************************ 
// Shape Manipulation
// ************************************************************************************************************************ 
void object_add_raw_shape(struct object* cell, struct shape* S)
{
    objectbase_add_raw_shape(cell, S);
}

void object_add_shape(struct object* cell, struct shape* S)
{
    objectbase_add_shape(cell, S);
}

void object_remove_shape(struct object* cell, size_t idx)
{
    objectbase_remove_shape(cell, idx);
}

struct shape* object_disown_shape(struct object* cell, size_t idx)
{
    return objectbase_disown_shape(cell, idx);
}

struct shape* object_get_shape(struct object* cell, size_t idx)
{
    return objectbase_get_shape(cell, idx);
}

const struct shape* object_get_shape_const(const struct object* cell, size_t idx)
{
    return objectbase_get_shape_const(cell, idx);
}

struct shape* object_get_transformed_shape(const struct object* cell, size_t idx)
{
    return objectbase_get_transformed_shape(cell, idx);
}

void object_merge_into(struct object* cell, const struct object* other)
{
    objectbase_merge_into(cell, other, 0);
}

void object_merge_into_with_ports(struct object* cell, const struct object* other)
{
    objectbase_merge_into(cell, other, 1);
}

void object_foreach_shapes(struct object* cell, void (*func)(struct shape*))
{
    objectbase_foreach_shapes(cell, func);
}

size_t object_get_shapes_size(const struct object* cell)
{
    return objectbase_get_shapes_size(cell);
}

void object_rasterize_curves(struct object* cell)
{
    objectbase_rasterize_curves(cell);
}

struct polygon_container* object_get_shape_outlines(const struct object* cell, const struct generics* layer)
{
    return objectbase_get_shape_outlines(cell, layer);
}

// children
const struct object* object_get_reference(const struct object* cell)
{
    return objectbase_get_reference(cell);
}

struct object* object_get_reference_mutable(struct object* cell)
{
    return objectbase_get_reference_mutable(cell);
}

// boundary
int object_has_boundary(const struct object* cell)
{
    return objectbase_has_boundary(cell);
}

void object_set_boundary(struct object* cell, struct vector* boundary)
{
    objectbase_set_boundary(cell, boundary);
}

struct vector* object_get_boundary(const struct object* cell)
{
    return objectbase_get_boundary(cell);
}

void object_set_empty_layer_boundary(struct object* cell, const struct generics* layer)
{
    objectbase_set_empty_layer_boundary(cell, layer);
}

void object_add_layer_boundary(struct object* cell, const struct generics* layer, struct simple_polygon* new)
{
    objectbase_add_layer_boundary(cell, layer, new);
}

void object_inherit_boundary(struct object* cell, const struct object* othercell)
{
    objectbase_inherit_boundary(cell, othercell);
}

int object_has_layer_boundary(const struct object* cell, const struct generics* layer)
{
    return objectbase_has_layer_boundary(cell, layer);
}

struct polygon_container* object_get_layer_boundary(const struct object* cell, const struct generics* layer)
{
    return objectbase_get_layer_boundary(cell, layer);
}

void object_inherit_layer_boundary(struct object* cell, const struct object* othercell, const struct generics* layer)
{
    objectbase_inherit_layer_boundary(cell, othercell, layer);
}


// ports
void object_add_port(
    struct object* cell,
    const char* name,
    const struct generics* layer,
    const struct point* where,
    unsigned int sizehint
)
{
    objectbase_add_port(cell, name, layer, where, sizehint);
}

void object_add_bus_port(
    struct object* cell,
    const char* name,
    const struct generics* layer,
    const struct point* where,
    int startindex, int endindex,
    coordinate_t xpitch, coordinate_t ypitch,
    unsigned int sizehint
)
{
    objectbase_add_bus_port(cell, name, layer, where, startindex, endindex, xpitch, ypitch, sizehint);
}

const struct vector* object_get_ports(const struct object* cell)
{
    return objectbase_get_ports(cell);
}

// labels
void object_add_label(struct object* cell, const char* name, const struct generics* layer, const struct point* where, unsigned int sizehint)
{
    objectbase_add_label(cell, name, layer, where, sizehint);
}

// nets
void object_add_net_shape(struct object* cell, const char* netname, const struct point* bl, const struct point* tr, const struct generics* layer)
{
    objectbase_add_net_shape(cell, netname, bl, tr, layer);
}

struct vector* object_get_net_shapes(const struct object* cell, const char* netname, const struct generics* layer)
{
    return object_get_net_shapes(cell, netname, layer);
}

struct vector* object_get_array_net_shapes(const struct object* cell, int xindex, int yindex, const char* netname, const struct generics* layer)
{
    return object_get_array_net_shapes(cell, xindex, yindex, netname, layer);
}


// alignment box and bounding box
void object_clear_alignment_box(struct object* cell)
{
    objectbase_clear_alignment_box(cell);
}

void object_set_alignment_box(
    struct object* cell,
    coordinate_t outerblx, coordinate_t outerbly,
    coordinate_t outertrx, coordinate_t outertry,
    coordinate_t innerblx, coordinate_t innerbly,
    coordinate_t innertrx, coordinate_t innertry
)
{
    objectbase_set_alignment_box(cell,
        outerblx, outerbly,
        outertrx, outertry,
        innerblx, innerbly,
        innertrx, innertry
    );
}

void object_inherit_alignment_box(struct object* cell, const struct object* other)
{
    objectbase_inherit_alignment_box(cell, other);
}

void object_alignment_box_include_point(struct object* cell, const struct point* pt)
{
    objectbase_alignment_box_include_point(cell, pt);
}

void object_alignment_box_include_x(struct object* cell, coordinate_t x)
{
    objectbase_alignment_box_include_x(cell, x);
}

void object_alignment_box_include_y(struct object* cell, coordinate_t y)
{
    objectbase_alignment_box_include_y(cell, y);
}

int object_extend_alignment_box(
    struct object* cell,
    coordinate_t extouterblx, coordinate_t extouterbly,
    coordinate_t extoutertrx, coordinate_t extoutertry,
    coordinate_t extinnerblx, coordinate_t extinnerbly,
    coordinate_t extinnertrx, coordinate_t extinnertry
)
{
    return objectbase_extend_alignment_box(
        cell,
        extouterblx, extouterbly,
        extoutertrx, extoutertry,
        extinnerblx, extinnerbly,
        extinnertrx, extinnertry
    );
}

int object_get_alignment_box_corners(
    const struct object* cell,
    coordinate_t* outerblx, coordinate_t* outerbly, coordinate_t* outertrx, coordinate_t* outertry,
    coordinate_t* innerblx, coordinate_t* innerbly, coordinate_t* innertrx, coordinate_t* innertry
)
{
    return objectbase_get_alignment_box_corners(
        cell,
        outerblx, outerbly,
        outertrx, outertry,
        innerblx, innerbly,
        innertrx, innertry
    );
}

coordinate_t* object_get_minmax_xy(const struct object* cell)
{
    return objectbase_get_minmax_xy(cell);
}

// transformations
const struct transformationmatrix* object_get_transformation_matrix(const struct object* cell)
{
    return objectbase_get_tmatrix(cell);
}

const struct transformationmatrix* object_get_array_transformation_matrix(const struct object* cell)
{
    return objectbase_get_array_tmatrix(cell);
}

void object_move_to(struct object* cell, coordinate_t x, coordinate_t y)
{
    objectbase_move_to(cell, x, y);
}

void object_reset_translation(struct object* cell)
{
    objectbase_reset_translation(cell);
}

void object_translate(struct object* cell, coordinate_t x, coordinate_t y)
{
    objectbase_translate(cell, x, y);
}

void object_translate_x(struct object* cell, coordinate_t x)
{
    objectbase_translate(cell, x, 0);
}

void object_translate_y(struct object* cell, coordinate_t y)
{
    objectbase_translate(cell, 0, y);
}

void object_mirror_at_xaxis(struct object* cell)
{
    objectbase_mirror_at_xaxis(cell);
}

void object_mirror_at_yaxis(struct object* cell)
{
    objectbase_mirror_at_yaxis(cell);
}

void object_mirror_at_origin(struct object* cell)
{
    objectbase_mirror_at_origin(cell);
}

void object_rotate_90_left(struct object* cell)
{
    objectbase_rotate_90_left(cell);
}

void object_rotate_90_right(struct object* cell)
{
    objectbase_rotate_90_right(cell);
}

void object_array_rotate_90_left(struct object* cell)
{
    objectbase_array_rotate_90_left(cell);
}

void object_array_rotate_90_right(struct object* cell)
{
    objectbase_array_rotate_90_right(cell);
}

void object_flipx(struct object* cell)
{
    objectbase_flipx(cell);
}

void object_flipy(struct object* cell)
{
    objectbase_flipy(cell);
}

int object_move_x(struct object* cell, coordinate_t source, coordinate_t target)
{
    return objectbase_move_x(cell, source, target);
}

int object_move_y(struct object* cell, coordinate_t source, coordinate_t target)
{
    return objectbase_move_y(cell, source, target);
}

int object_move_point(struct object* cell, const struct point* source, const struct point* target)
{
    return objectbase_move_point(cell, source, target);
}

int object_move_point_to_origin(struct object* cell, const struct point* target)
{
    return objectbase_move_point_to_origin(cell, target);
}

int object_move_point_to_origin_xy(struct object* cell, coordinate_t x, coordinate_t y)
{
    return objectbase_move_point_to_origin_xy(cell, x, y);
}

int object_move_point_x(struct object* cell, const struct point* source, const struct point* target)
{
    return objectbase_move_point_x(cell, source, target);
}

int object_move_point_y(struct object* cell, const struct point* source, const struct point* target)
{
    return objectbase_move_point_y(cell, source, target);
}

int object_center(struct object* cell, const struct point* target)
{
    return objectbase_center(cell, target);
}

int object_center_x(struct object* cell, const struct point* target)
{
    return objectbase_center_x(cell, target);
}

int object_center_y(struct object* cell, const struct point* target)
{
    return objectbase_center_y(cell, target);
}

void object_scale(struct object* cell, double factor)
{
    objectbase_scale(cell, factor);
}

void object_transform_point(const struct object* cell, struct point* pt)
{
    objectbase_transform_point(cell, pt);
}

// object info
int object_is_proxy(const struct object* cell)
{
    return objectbase_is_proxy(cell);
}

int object_is_pseudo(const struct object* cell)
{
    return objectbase_is_pseudo(cell);
}

int object_has_shapes(const struct object* cell)
{
    return objectbase_has_shapes(cell);
}

int object_has_layer_flat(const struct object* cell, const struct generics* layer)
{
    return objectbase_has_layer_flat(cell, layer);
}

int object_has_layer(const struct object* cell, const struct generics* layer)
{
    return objectbase_has_layer(cell, layer);
}

int object_has_children(const struct object* cell)
{
    return objectbase_has_children(cell);
}

int object_has_ports(const struct object* cell)
{
    return objectbase_has_ports(cell);
}

int object_is_empty(const struct object* cell)
{
    return objectbase_is_empty(cell);
}

int object_is_used(const struct object* cell)
{
    return objectbase_is_used(cell);
}

int object_is_array(const struct object* cell)
{
    return objectbase_is_array(cell);
}

int object_has_anchor(const struct object* cell, const char* anchorname)
{
    return objectbase_has_anchor(cell, anchorname);
}

int object_has_area_anchor(const struct object* cell, const char* anchorname)
{
    return objectbase_has_area_anchor(cell, anchorname);
}

int object_has_alignmentbox(const struct object* cell)
{
    return objectbase_has_alignmentbox(cell);
}

const char* object_get_name(const struct object* cell)
{
    return objectbase_get_name(cell);
}

const char* object_get_child_reference_name(const struct object* child)
{
    return objectbase_get_child_reference_name(child);
}

// ************************************************************************************************************************ 
// Area Anchor Width/Height
// ************************************************************************************************************************ 
coordinate_t object_get_area_anchor_width(const struct object* cell, const char* anchorname)
{
    struct point* anchor = object_get_area_anchor(cell, anchorname);
    coordinate_t width = anchor[1].x - anchor[0].x;
    free(anchor);
    return width;
}

coordinate_t object_get_area_anchor_height(const struct object* cell, const char* anchorname)
{
    struct point* anchor = object_get_area_anchor(cell, anchorname);
    coordinate_t height = anchor[1].y - anchor[0].y;
    free(anchor);
    return height;
}

void object_flatten_inline(struct object* cell, int flattenports)
{
    objectbase_flatten_inline(cell, flattenports);
}

struct object* object_flatten(const struct object* cell, int flattenports)
{
    return objectbase_flatten(cell, flattenports);
}

unsigned int object_get_child_xrep(const struct object* cell)
{
    return objectbase_get_child_xrep(cell);
}

unsigned int object_get_child_yrep(const struct object* cell)
{
    return objectbase_get_child_yrep(cell);
}

coordinate_t object_get_child_xpitch(const struct object* cell)
{
    return objectbase_get_child_xpitch(cell);
}

coordinate_t object_get_child_ypitch(const struct object* cell)
{
    return objectbase_get_child_ypitch(cell);
}

const struct const_vector* object_collect_references(const struct object* cell)
{
    return objectbase_collect_references(cell);
}

struct vector* object_collect_references_mutable(struct object* cell)
{
    return objectbase_collect_references_mutable(cell);
}

struct shape_iterator {
    const struct vector* shapes;
    size_t index;
};

struct shape_iterator* object_create_shape_iterator(const struct object* cell)
{
    struct shape_iterator* it = malloc(sizeof(*it));
    it->shapes = objectbase_get_full_shapes_const(cell);
    it->index = 0;
    return it;
}

int shape_iterator_is_valid(struct shape_iterator* it)
{
    if(!it->shapes)
    {
        return 0;
    }
    else
    {
        return it->index < vector_size(it->shapes);
    }
}

void shape_iterator_next(struct shape_iterator* it)
{
    it->index += 1;
}

const struct shape* shape_iterator_get(struct shape_iterator* it)
{
    return vector_get_const(it->shapes, it->index);
}

void shape_iterator_destroy(struct shape_iterator* it)
{
    free(it);
}

// child iterator
struct child_iterator {
    const struct vector* children;
    size_t index;
};

struct child_iterator* object_create_child_iterator(const struct object* cell)
{
    struct child_iterator* it = malloc(sizeof(*it));
    it->children = objectbase_get_full_children_const(cell);
    it->index = 0;
    return it;
}

int child_iterator_is_valid(struct child_iterator* it)
{
    if(!it->children)
    {
        return 0;
    }
    else
    {
        return it->index < vector_size(it->children);
    }
}

void child_iterator_next(struct child_iterator* it)
{
    it->index += 1;
}

const struct object* child_iterator_get(struct child_iterator* it)
{
    return vector_get_const(it->children, it->index);
}

void child_iterator_destroy(struct child_iterator* it)
{
    free(it);
}

// reference iterator
struct reference_iterator {
    const struct vector* references;
    size_t index;
};

struct reference_iterator* object_create_reference_iterator(const struct object* cell)
{
    struct reference_iterator* it = malloc(sizeof(*it));
    it->references = objectbase_get_full_references_const(cell);
    it->index = 0;
    return it;
}

int reference_iterator_is_valid(struct reference_iterator* it)
{
    if(!it->references)
    {
        return 0;
    }
    else
    {
        return it->index < vector_size(it->references);
    }
}

void reference_iterator_next(struct reference_iterator* it)
{
    it->index += 1;
}

const struct object* reference_iterator_get(struct reference_iterator* it)
{
    return vector_get_const(it->references, it->index);
}

void reference_iterator_destroy(struct reference_iterator* it)
{
    free(it);
}

// mutable reference iterator
struct mutable_reference_iterator {
    struct vector* references;
    size_t index;
};

struct mutable_reference_iterator* object_create_mutable_reference_iterator(struct object* cell)
{
    struct mutable_reference_iterator* it = malloc(sizeof(*it));
    it->references = objectbase_get_full_references(cell);
    it->index = 0;
    return it;
}

int mutable_reference_iterator_is_valid(struct mutable_reference_iterator* it)
{
    if(!it->references)
    {
        return 0;
    }
    else
    {
        return it->index < vector_size(it->references);
    }
}

void mutable_reference_iterator_next(struct mutable_reference_iterator* it)
{
    it->index += 1;
}

struct object* mutable_reference_iterator_get(struct mutable_reference_iterator* it)
{
    return vector_get(it->references, it->index);
}

void mutable_reference_iterator_destroy(struct mutable_reference_iterator* it)
{
    free(it);
}

// anchor foreach
int object_foreach_anchor(const struct object* cell, anchor_action action, struct generic_arg* extraargs)
{
    objectbase_foreach_anchor(cell, action, extraargs);
}

// port foreach
int object_foreach_port(const struct object* cell, port_action action, struct generic_arg* extraargs)
{
    objectbase_foreach_port(cell, action, extraargs);
}

// label foreach
int object_foreach_label(const struct object* cell, label_action action, struct generic_arg* extraargs)
{
    objectbase_foreach_label(cell, action, extraargs);
}
