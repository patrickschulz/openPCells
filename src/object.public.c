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
#include "object.anchors.h"
#undef OPC_OBJECT_IMPLEMENTATION

#include "helpers.h"

int object_add_anchor(struct object* cell, const char* name, coordinate_t x, coordinate_t y)
{
    struct anchor* anchor = objectanchor_create_regular(x, y);
    int ret = objectbase_add_anchor(cell, name, anchor);
    if(!ret)
    {
        objectanchor_destroy(anchor);
    }
    return ret;
}

int object_add_area_anchor_bltr(struct object* cell, const char* base, const struct point* bl, const struct point* tr)
{
    struct anchor* anchor = objectanchor_create_area_bltr(bl->x, bl->y, tr->x, tr->y);
    int ret = objectbase_add_anchor(cell, base, anchor);
    if(!ret)
    {
        objectanchor_destroy(anchor);
    }
    return ret;
}

int object_add_area_anchor_points(struct object* cell, const char* base, const struct point* pt1, const struct point* pt2)
{
    struct anchor* anchor = objectanchor_create_area_points(pt1->x, pt1->y, pt2->x, pt2->y);
    int ret = objectbase_add_anchor(cell, base, anchor);
    if(!ret)
    {
        objectanchor_destroy(anchor);
    }
    return ret;
}

int object_add_area_anchor_blwh(struct object* cell, const char* base, const struct point* bl, coordinate_t width, coordinate_t height)
{
    struct anchor* anchor = objectanchor_create_area_bltr(bl->x, bl->y, bl->x + width, bl->y + height);
    int ret = objectbase_add_anchor(cell, base, anchor);
    if(!ret)
    {
        objectanchor_destroy(anchor);
    }
    return ret;
}

int object_inherit_area_anchor(struct object* cell, const struct object* other, const char* name)
{
    return object_inherit_area_anchor_as(cell, other, name, name);
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

int object_inherit_anchor(struct object* cell, const struct object* other, const char* name)
{
    return object_inherit_anchor_as(cell, other, name, name);
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

void object_inherit_all_anchors(struct object* cell, const struct object* other)
{
    object_inherit_all_anchors_with_prefix(cell, other, "");
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
    struct anchor* anchor = objectbase_get_anchor(cell, name);
    if(anchor && !objectanchor_is_area(anchor))
    {
        struct point* pt = point_create(0, 0);
        objectanchor_get_point(anchor, pt);
        objectbase_transform_to_global_coordinates(cell, pt);
        return pt;
    }
    else
    {
        return NULL;
    }
}

struct point* object_get_area_anchor(const struct object* cell, const char* base)
{
    struct anchor* anchor = objectbase_get_anchor(cell, base);
    if(!anchor)
    {
        return NULL;
    }
    if(objectanchor_is_area(anchor))
    {
        struct point* pts = malloc(2 * sizeof(*pts));
        objectanchor_get_area_points(anchor, pts);
        objectbase_transform_to_global_coordinates(cell, pts + 0);
        objectbase_transform_to_global_coordinates(cell, pts + 1);
        objectutil_fix_rectangle_order(pts + 0, pts + 1);
        return pts;
    }
    return NULL;
}

struct point* object_get_array_anchor(const struct object* cell, int xindex, int yindex, const char* name)
{
    return objectbase_get_array_anchor(cell, xindex, yindex, name);
}

struct point* object_get_array_area_anchor(const struct object* cell, int xindex, int yindex, const char* base)
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
// Anchor Availability
// ************************************************************************************************************************ 
int object_has_anchor(const struct object* cell, const char* anchorname)
{
    struct anchor* anchor = objectbase_get_anchor(cell, anchorname);
    if(anchor)
    {
        return !objectanchor_is_area(anchor);
    }
    return 0;
}

int object_has_area_anchor(const struct object* cell, const char* anchorname)
{
    struct anchor* anchor = objectbase_get_anchor(cell, anchorname);
    if(anchor)
    {
        return objectanchor_is_area(anchor);
    }
    return 0;
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

// ************************************************************************************************************************ 
// Reference/Child Adding
// ************************************************************************************************************************ 
struct object* object_create_handle(struct object* cell, struct object* reference)
{
    if(object_is_pseudo(reference)) // can't add pseudo objects
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
    if(object_is_pseudo(child)) // can't add pseudo objects
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
    if(object_is_pseudo(child)) // can't add pseudo objects
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
    CHECK_FULL(cell, "object_add_raw_shape");
    objectbase_add_shape(FULL(cell), S);
}

void object_add_shape(struct object* cell, struct shape* S)
{
    CHECK_FULL(cell, "object_add_shape");
    object_add_raw_shape(cell, S);
    shape_apply_inverse_transformation(S, objectcommon_get_tmatrix(COMMON(cell)));
}

void object_remove_shape(struct object* cell, size_t idx)
{
    CHECK_FULL(cell, "object_remove_shape");
    objectfull_remove_shape(FULL(cell), idx);
}

struct shape* object_disown_shape(struct object* cell, size_t idx)
{
    CHECK_FULL(cell, "object_disown_shape");
    return objectfull_disown_shape(FULL(cell), idx);
}

