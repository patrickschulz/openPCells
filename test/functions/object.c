#include "src/object.h"
#include "src/geometry.h"
#include "check.h"
#include "helper.h"

int main(void)
{
    struct technology_state* techstate = helper_create_techstate();
    const struct generics* metallayer = generics_create_metal(techstate, 1);
    {
        struct object* cell = object_create("objet_test_01");
        struct point* bl = point_create(0, 0);
        struct point* tr = point_create(100, 100);
        geometry_rectanglebltr(cell, metallayer, bl, tr);
        point_destroy(bl);
        point_destroy(tr);
        struct point** boundary = object_get_bounding_box(cell);
        check_point(boundary[0], 0, 0, "object get_bounding_box (bl)");
        check_point(boundary[1], 100, 100, "object get_bounding_box (tr)");
        point_destroy(boundary[0]);
        point_destroy(boundary[1]);
        free(boundary);
        object_destroy(cell);
    }
    technology_destroy(techstate);
}
