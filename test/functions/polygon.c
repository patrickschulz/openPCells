#include "src/polygon.h"
#include "check.h"

int main(void)
{
    {
        struct simple_polygon* polygon = simple_polygon_create_from_rectangle(-50, -50, 50, 50);
        int intersect = simple_polygon_intersects_rectangle(polygon, -60, -60, 40, 40);
        check_boolean(intersect, "polygon intersection 01");
        simple_polygon_destroy(polygon);
    }
    {
        struct simple_polygon* polygon = simple_polygon_create_from_rectangle(-50, -50, 50, 50);
        int intersect = simple_polygon_intersects_rectangle(polygon, 49, 49, 60, 60);
        check_boolean(intersect, "polygon intersection 02");
        simple_polygon_destroy(polygon);
    }
}
