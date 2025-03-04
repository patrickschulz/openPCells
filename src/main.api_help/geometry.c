/* geometry.rectanglebltr */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL,   "Object in which the rectangle is created" },
        { "layer",  GENERICS,   NULL,   "Layer of the generated rectangular shape" },
        { "bl",     POINT,      NULL,   "Bottom-left point of the generated rectangular shape" },
        { "tr",     POINT,      NULL,   "Top-right point of the generated rectangular shape" },
    };
    vector_append(entries, _make_api_entry(
        "rectanglebltr",
        MODULE_GEOMETRY,
        "Create a rectangular shape with the given corner points in cell",
        "geometry.rectanglebltr(cell, generics.other(\"nwell\"), point.create(-100, -100), point.create(100, 100))\ngeometry.rectanglebltr(cell, generics.metal(1), obj:get_anchor(\"bottomleft\"), obj:get_anchor(\"topright\"))\ngeometry.rectanglebltr(cell, generics.metal(-1), point.create(-100, -100), point.create(100, 100))\n",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.rectangleblwh */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL,   "Object in which the rectangle is created" },
        { "layer",  GENERICS,   NULL,   "Layer of the generated rectangular shape" },
        { "bl",     POINT,      NULL,   "Bottom-left point of the generated rectangular shape" },
        { "width",  INTEGER,    NULL,   "Width of the rectangular shape" },
        { "height", INTEGER,    NULL,   "Height of the rectangular shape" }
    };
    vector_append(entries, _make_api_entry(
        "rectangleblwh",
        MODULE_GEOMETRY,
        "Create a rectangular shape with the given bottom-left corner point and the width and height in cell",
        "geometry.rectangleblwh(cell, generics.other(\"nwell\"), point.create(-100, -100), 200, 200)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.rectanglepoints */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL,   "Object in which the rectangle is created" },
        { "layer",  GENERICS,   NULL,   "Layer of the generated rectangular shape" },
        { "pt1",    POINT,      NULL,   "First corner point of the generated rectangular shape" },
        { "pt2",    POINT,      NULL,   "Second corner point of the generated rectangular shape" }
    };
    vector_append(entries, _make_api_entry(
        "rectanglepoints",
        MODULE_GEOMETRY,
        "Create a rectangular shape with the given corner points in cell. Similar to geometry.rectanglebltr, but any of the corner points can be given in any order",
        "geometry.rectanglepoints(cell, generics.metal(1), point.create(100, -100), point(-100, 100))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.rectanglepath */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the rectangle is created" },
        { "layer",      GENERICS,   NULL,   "Layer of the generated rectangular shape" },
        { "pt1",        POINT,      NULL,   "First path point of the generated rectangular shape" },
        { "pt2",        POINT,      NULL,   "Second path point of the generated rectangular shape" },
        { "width",      INTEGER,    NULL,   "Width of the path-like shape" },
        { "extension",  TABLE,      NULL,   "optional table argument containing the start/end extensions" }
    };
    vector_append(entries, _make_api_entry(
        "rectanglepath",
        MODULE_GEOMETRY,
        "Create a rectangular shape that is defined by its path-like endpoints. This function behaves like geometry.path, but takes only two points, not a list of points. This function likely will be removed in the future, use geometry.rectanglebltr or geometry.rectanglepoints",
        "geometry.rectanglepath(cell, generics.metal(1), point.create(-100, 0), point(100, 0), 50)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.rectanglearray */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL,   "Object in which the rectangle is created" },
        { "layer",  GENERICS,   NULL,   "Layer of the generated rectangular shape" },
        { "width",  INTEGER,    NULL,   "Width of the generated rectangular shape" },
        { "height", INTEGER,    NULL,   "Height of the generated rectangular shape" },
        { "xshift", INTEGER,    NULL,   "Number of repetitions in x direction. The Rectangles are shifted so that an equal number is above and below" },
        { "yshift", INTEGER,    NULL,   "Number of repetitions in y direction. The Rectangles are shifted so that an equal number is above and below" },
        { "xrep",   INTEGER,    NULL,   "Number of repetitions in x direction. The Rectangles are shifted so that an equal number is above and below" },
        { "yrep",   INTEGER,    NULL,   "Number of repetitions in y direction. The Rectangles are shifted so that an equal number is above and below" },
        { "xpitch", INTEGER,    NULL,   "Pitch in x direction, used for repetition in x" },
        { "ypitch", INTEGER,    NULL,   "Pitch in y direction, used for repetition in y" }
    };
    vector_append(entries, _make_api_entry(
        "rectanglearray",
        MODULE_GEOMETRY,
        "Create an array of rectangles with the given width, height, repetition and pitch in cell",
        "geometry.rectanglebltr(cell, generics.other(\"nwell\"), 100, 100, 0, 0, 10, 20, 200, 200)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.slotted_rectangle */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL,   "Object in which the rectangle is created" },
        { "layer",          GENERICS,   NULL,   "Layer of the generated rectangular shape" },
        { "bl",             POINT,      NULL,   "bottom-left point of rectangular area" },
        { "tr",             POINT,      NULL,   "top-right point of rectangular area" },
        { "slotwidth",      INTEGER,    NULL,   "Width of the created slots (space in x-direction between the shapes)" },
        { "slotheight",     INTEGER,    NULL,   "Height of the created slots (space in y-direction between the shapes)" },
        { "slotxspace",     INTEGER,    NULL,   "Width of the regions between the slots" },
        { "slotxspace",     INTEGER,    NULL,   "Height of the regions between the slots" },
        { "slotedgexspace", INTEGER,    NULL,   "Minimum width of the edge regions (they can be larger than this value)" },
        { "slotedgeyspace", INTEGER,    NULL,   "Minimum height of the edge regions (they can be larger than this value)" }
    };
    vector_append(entries, _make_api_entry(
        "slotted_rectangle",
        MODULE_GEOMETRY,
        "Create a rectangle with slotting",
        "geometry.slotted_rectangle(cell, generics.other(\"nwell\"), point.create(-200, -2000), point.create(200, 2000), 50, 50, 50, 50, 100, 100)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.rectanglevlines */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the rectangle is created" },
        { "layer",      GENERICS,   NULL,   "Layer of the generated rectangular shape" },
        { "pt1",        POINT,      NULL,   "First corner point of the target area" },
        { "pt2",        POINT,      NULL,   "Second corner point of the target area" },
        { "numlines",   INTEGER,    NULL,   "Number of lines to be generated" },
        { "ratio",      NUMBER,     NULL,   "Ratio between width and spacing of lines" }
    };
    vector_append(entries, _make_api_entry(
        "rectanglevlines",
        MODULE_GEOMETRY,
        "Fill a rectangular area with vertical lines with a given ratio between width and spacing",
        "geometry.rectanglevlines(cell, generics.metal(1), point.create(100, -100), point(-100, 100), 8, 1)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.rectanglevlines_width_space */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the rectangle is created" },
        { "layer",      GENERICS,   NULL,   "Layer of the generated rectangular shape" },
        { "pt1",        POINT,      NULL,   "First corner point of the target area" },
        { "pt2",        POINT,      NULL,   "Second corner point of the target area" },
        { "width",      INTEGER,    NULL,   "Width target of lines to be generated" },
        { "space",      INTEGER,    NULL,   "Space target between lines to be generated" }
    };
    vector_append(entries, _make_api_entry(
        "rectanglevlines_width_space",
        MODULE_GEOMETRY,
        "Fill a rectangular area with vertical lines with the given width and spacing. The given numbers are only targets, in some cases they can't be matched exactly.",
        "geometry.rectanglevlines_width_space(cell, generics.metal(1), point.create(100, -100), point(-100, 100), 20, 20)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.rectanglevlines_settings */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the rectangle is created" },
        { "layer",      GENERICS,   NULL,   "Layer of the generated rectangular shape" },
        { "pt1",        POINT,      NULL,   "First corner point of the target area" },
        { "pt2",        POINT,      NULL,   "Second corner point of the target area" },
        { "numlines",   INTEGER,    NULL,   "Number of lines to be generated" },
        { "ratio",      NUMBER,     NULL,   "Ratio between width and spacing of lines" }
    };
    vector_append(entries, _make_api_entry(
        "rectanglevlines_settings",
        MODULE_GEOMETRY,
        "Calculate the geometries of vertical lines to fill a rectangular area with a given ratio between width and spacing. This function is like geometry.rectanglevlines, but it does not actually create the lines. It return the width, heigh, space, offset and number of lines. These parameters can then be used to call geometry.rectanglearray. This function is useful if the parameters of the lines are required for further layout functions like placing vias.",
        "local width, height, space, offset, numlines = geometry.rectanglevlines_settings(point.create(-100, -100), point(100, 100), 20, 1)\ngeometry.rectanglearray(cell, generics.metal(1), width, height, -100 + offset, -100, numlines, 1, width + space, 0)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.rectanglevlines_width_space_settings */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the rectangle is created" },
        { "layer",      GENERICS,   NULL,   "Layer of the generated rectangular shape" },
        { "pt1",        POINT,      NULL,   "First corner point of the target area" },
        { "pt2",        POINT,      NULL,   "Second corner point of the target area" },
        { "width",      INTEGER,    NULL,   "Width target of lines to be generated" },
        { "space",      INTEGER,    NULL,   "Space target between lines to be generated" }
    };
    vector_append(entries, _make_api_entry(
        "rectanglevlines_width_space_settings",
        MODULE_GEOMETRY,
        "Calculate the geometries of vertical lines to fill a rectangular area with a given width and spacing. This function is like geometry.rectanglevlines_width_space, but it does not actually create the lines. It return the width, heigh, space, offset and number of lines. These parameters can then be used to call geometry.rectanglearray. This function is useful if the parameters of the lines are required for further layout functions like placing vias.",
        "local width, height, space, offset, numlines = geometry.rectanglevlines_width_space_settings(point.create(-100, -100), point(100, 100), 20, 20)\ngeometry.rectanglearray(cell, generics.metal(1), width, height, -100 + offset, -100, numlines, 1, width + space, 0)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.rectanglehlines */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the rectangle is created" },
        { "layer",      GENERICS,   NULL,   "Layer of the generated rectangular shape" },
        { "pt1",        POINT,      NULL,   "First corner point of the target area" },
        { "pt2",        POINT,      NULL,   "Second corner point of the target area" },
        { "numlines",   INTEGER,    NULL,   "Number of lines to be generated" },
        { "ratio",      NUMBER,     NULL,   "Ratio between width and spacing of lines" }
    };
    vector_append(entries, _make_api_entry(
        "rectanglehlines",
        MODULE_GEOMETRY,
        "Fill a rectangular area with horizontal lines with a given ratio between width and spacing",
        "geometry.rectanglehlines(cell, generics.metal(1), point.create(100, -100), point(-100, 100), 8, 1)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.rectanglehlines_height_space */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the rectangle is created" },
        { "layer",      GENERICS,   NULL,   "Layer of the generated rectangular shape" },
        { "pt1",        POINT,      NULL,   "First corner point of the target area" },
        { "pt2",        POINT,      NULL,   "Second corner point of the target area" },
        { "height",     INTEGER,    NULL,   "Height target of lines to be generated" },
        { "space",      INTEGER,    NULL,   "Space target of lines to be generated" }
    };
    vector_append(entries, _make_api_entry(
        "rectanglehlines_height_space",
        MODULE_GEOMETRY,
        "Fill a rectangular area with horizontal lines with the given height and spacing. The given numbers are only targets, in some cases they can't be matched exactly.",
        "geometry.rectanglehlines(cell, generics.metal(1), point.create(100, -100), point(-100, 100), 20, 20)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.rectanglehlines_settings */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the rectangle is created" },
        { "layer",      GENERICS,   NULL,   "Layer of the generated rectangular shape" },
        { "pt1",        POINT,      NULL,   "First corner point of the target area" },
        { "pt2",        POINT,      NULL,   "Second corner point of the target area" },
        { "numlines",   INTEGER,    NULL,   "Number of lines to be generated" },
        { "ratio",      NUMBER,     NULL,   "Ratio between width and spacing of lines" }
    };
    vector_append(entries, _make_api_entry(
        "rectanglehlines_settings",
        MODULE_GEOMETRY,
        "Calculate the geometries of horizontal lines to fill a rectangular area with a given ratio between width and spacing. This function is like geometry.rectanglehlines, but it does not actually create the lines. It return the width, heigh, space, offset and number of lines. These parameters can then be used to call geometry.rectanglearray. This function is useful if the parameters of the lines are required for further layout functions like placing vias.",
        "local width, height, space, offset, numlines = geometry.rectanglehlines_settings(point.create(-100, -100), point(100, 100), 20, 1)\ngeometry.rectanglearray(cell, generics.metal(1), width, height, -100, -100 + offset, 1, numlines, 0, height + space)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.rectanglehlines_height_space_settings */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the rectangle is created" },
        { "layer",      GENERICS,   NULL,   "Layer of the generated rectangular shape" },
        { "pt1",        POINT,      NULL,   "First corner point of the target area" },
        { "pt2",        POINT,      NULL,   "Second corner point of the target area" },
        { "width",      INTEGER,    NULL,   "Width target of lines to be generated" },
        { "space",      INTEGER,    NULL,   "Space target between lines to be generated" }
    };
    vector_append(entries, _make_api_entry(
        "rectanglehlines_height_space_settings",
        MODULE_GEOMETRY,
        "Calculate the geometries of horizontal lines to fill a rectangular area with a given width and spacing. This function is like geometry.rectanglehlines_width_space, but it does not actually create the lines. It return the width, heigh, space, offset and number of lines. These parameters can then be used to call geometry.rectanglearray. This function is useful if the parameters of the lines are required for further layout functions like placing vias.",
        "local width, height, space, offset, numlines = geometry.rectanglehlines_height_space_settings(point.create(-100, -100), point(100, 100), 20, 20)\ngeometry.rectanglearray(cell, generics.metal(1), width, height, -100, -100 + offset, 1, numlines, 0, height + space)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.rectangle_fill_in_boundary */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL,   "Object in which the rectangle is created" },
        { "layer",          GENERICS,   NULL,   "Layer of the generated rectangular shape" },
        { "width",          INTEGER,    NULL,   "Width of the rectangles" },
        { "height",         INTEGER,    NULL,   "Height of the rectangles" },
        { "xpitch",         INTEGER,    NULL,   "Pitch in x-direction" },
        { "ypitch",         INTEGER,    NULL,   "Pitch in y-direction" },
        { "xstartshift",    INTEGER,    NULL,   "Shift the start of the rectangle placment algorithm in x-direction" },
        { "ystartshift",    INTEGER,    NULL,   "Shift the start of the rectangle placment algorithm in y-direction" },
        { "boundary",       POINTLIST,  NULL,   "List of points defining fill boundary (a polygon)" },
        { "excludes",       TABLE,      NULL,   "Collection of excludes (polygons)" }
    };
    vector_append(entries, _make_api_entry(
        "rectangle_fill_in_boundary",
        MODULE_GEOMETRY,
        "Fill a given boundary (a polygon) with rectangles of a given width and height. If given, the rectangles are not placed in the regions defined by the exclude rectangles. Optionally, binary excludes can be given, where no fill is placed. This should be a table containing polygons, which can (for instance) be fetched from cells by object:get_boundary().",
        "geometry.rectangle_fill_in_boundary(\n    cell,\n     generics.metal(1),\n     100, 100,\n     200, 200,\n     { point.create(-10000, -10000), point.create(10000, -10000), point.create(10000, 10000), point.create(-10000, 10000) },\n     { util.rectangle_to_polygon( point.create(1000, 1000), point.create(2000, 2000)) }\n)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.polygon */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT, NULL,             "Object in which the polygon is created" },
        { "layer",  GENERICS, NULL,            "Layer of the generated rectangular shape" },
        { "pts",    POINTLIST, NULL,          "List of points that make up the polygon" },
    };
    vector_append(entries, _make_api_entry(
        "polygon",
        MODULE_GEOMETRY,
        "Create a polygon shape with the given points in cell",
        "geometry.polygon(cell, generics.metal(1), { point.create(-50, 0), point.create(50, 0), point.create(0, 50))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.path */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the path is created" },
        { "layer",      GENERICS,   NULL,   "Layer of the generated rectangular shape" },
        { "pts",        POINTLIST,  NULL,   "List of points where the path passes through" },
        { "width",      INTEGER,    NULL,   "width of the path. Must be even" },
        { "extension",  TABLE,      NULL,   "optional table argument containing the start/end extensions" }
    };
    vector_append(entries, _make_api_entry(
        "path",
        MODULE_GEOMETRY,
        "Create a path shape with the given points and width in cell",
        "geometry.path(cell, generics.metal(1), { point.create(-50, 0), point.create(50, 0), point.create(50, 50))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.path_polygon */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the path is created" },
        { "layer",      GENERICS,   NULL,   "Layer of the generated rectangular shape" },
        { "pts",        POINTLIST,  NULL,   "List of points where the path passes through" },
        { "width",      INTEGER,    NULL,   "width of the path. Must be even" },
        { "extension",  TABLE,      NULL,   "optional table argument containing the start/end extensions" }
    };
    vector_append(entries, _make_api_entry(
        "path_polygon",
        MODULE_GEOMETRY,
        "Like geometry.path, but create a polygon with the outline of the path, not the actual path. From a physical standpoint, the result is the same.",
        "geometry.path_polygon(cell, generics.metal(1), { point.create(-50, 0), point.create(50, 0), point.create(50, 50))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.path_manhatten */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT, NULL,    "Object in which the path is created" },
        { "layer",  GENERICS, NULL,   "Layer of the generated rectangular shape" },
        { "pts",    POINTLIST, NULL, "List of points where the path passes through" },
        { "width",  INTEGER, NULL,   "width of the path. Must be even" },
        { "extension",  TABLE,      NULL,   "optional table argument containing the start/end extensions" }
    };
    vector_append(entries, _make_api_entry(
        "path_manhatten",
        MODULE_GEOMETRY,
        "Create a manhatten path shape with the given points and width in cell. This only allows vertical or horizontal movements",
        "geometry.path(cell, generics.metal(1), { point.create(-50, 0), point.create(50, 50))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.path_2x */
{
    struct parameter parameters[] = {
        { "cell",     OBJECT,   NULL,   "Object in which the path is created" },
        { "layer",    GENERICS, NULL,   "Layer of the generated rectangular shape" },
        { "ptstart",  POINT,    NULL,   "Start point of the path" },
        { "ptend",    POINT,    NULL,   "End point of the path" },
        { "width",    INTEGER,  NULL,   "width of the path. Must be even" }
    };
    vector_append(entries, _make_api_entry(
        "path_2x",
        MODULE_GEOMETRY,
        "Create a path that starts at ptstart and ends at ptend by moving first in x direction, then in y-direction (similar to an 'L')",
        "geometry.path_2x(cell, generics.metal(2), point.create(0, 0), point.create(200, 200))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.path_2y */
{
    struct parameter parameters[] = {
        { "cell",     OBJECT,   NULL,   "Object in which the path is created" },
        { "layer",    GENERICS, NULL,   "Layer of the generated rectangular shape" },
        { "ptstart",  POINT,    NULL,   "Start point of the path" },
        { "ptend",    POINT,    NULL,   "End point of the path" },
        { "width",    INTEGER,  NULL,   "width of the path. Must be even" }
    };
    vector_append(entries, _make_api_entry(
        "path_2y",
        MODULE_GEOMETRY,
        "Create a path that starts at ptstart and ends at ptend by moving first in y direction, then in x-direction (similar to an capital greek gamma)",
        "geometry.path_2y(cell, generics.metal(2), point.create(0, 0), point.create(200, 200))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.path_3x */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,   NULL,   "Object in which the path is created" },
        { "layer",      GENERICS, NULL,   "Layer of the generated rectangular shape" },
        { "ptstart",    POINT,    NULL,   "Start point of the path" },
        { "ptend",      POINT,    NULL,   "End point of the path" },
        { "width",      INTEGER,  NULL,   "width of the path. Must be even" },
        { "position",   NUMBER,   NULL,   "position factor (a number between 0 and 1)" },
        { "extension",  TABLE,    NULL,   "optional table argument containing the start/end extensions" }
    };
    vector_append(entries, _make_api_entry(
        "path_3x",
        MODULE_GEOMETRY,
        "Create a path that starts at ptstart and ends at ptend by moving first in x direction, then in y-direction. Different from path_2x this make a bend in the middle between the start and the end point. The position factor influences where the middle point lies. It is a linear interpolation between the start- and the end-point, with a factor of 0.5 leading to exactly the middle. Values closer to 0 shift this point to the beginning, values closer to 1 shift this point to the end.",
        "geometry.path_3x(cell, generics.metal(2), point.create(0, 0), point.create(200, 200), 0.5)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.path_3y */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,   NULL,   "Object in which the path is created" },
        { "layer",      GENERICS, NULL,   "Layer of the generated rectangular shape" },
        { "ptstart",    POINT,    NULL,   "Start point of the path" },
        { "ptend",      POINT,    NULL,   "End point of the path" },
        { "width",      INTEGER,  NULL,   "width of the path. Must be even" },
        { "position",   NUMBER,   NULL,   "position factor (a number between 0 and 1)" },
        { "extension",  TABLE,    NULL,   "optional table argument containing the start/end extensions" }
    };
    vector_append(entries, _make_api_entry(
        "path_3y",
        MODULE_GEOMETRY,
        "Create a path that starts at ptstart and ends at ptend by moving first in y direction, then in x-direction. Different from path_2x this make a bend in the middle between the start and the end point. The position factor influences where the middle point lies. It is a linear interpolation between the start- and the end-point, with a factor of 0.5 leading to exactly the middle. Values closer to 0 shift this point to the beginning, values closer to 1 shift this point to the end.",
        "geometry.path_3y(cell, generics.metal(2), point.create(0, 0), point.create(200, 200), 0.5)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.path_cshape */
{
    struct parameter parameters[] = {
        { "cell",     OBJECT,   NULL,   "Object in which the path is created" },
        { "layer",    GENERICS, NULL,   "Layer of the generated rectangular shape" },
        { "ptstart",  POINT,    NULL,   "Start point of the path" },
        { "ptend",    POINT,    NULL,   "End point of the path" },
        { "ptoffset", POINT,    NULL,   "Offset point" },
        { "width",    INTEGER,  NULL,   "width of the path. Must be even" }
    };
    vector_append(entries, _make_api_entry(
        "path_cshape",
        MODULE_GEOMETRY,
        "Create a path shape that starts and ends at the start and end point, respectively and passes through the offset point. Only the x-coordinate of the offset point is taken, creating a shape resembling a (possibly inverted) 'C'",
        "geometry.path_cshape(cell, generics.metal(1), point.create(-50, 50), point.create(-50, -50), point.create(100, 0))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.path_ushape */
{
    struct parameter parameters[] = {
        { "cell",     OBJECT,   NULL,   "Object in which the path is created" },
        { "layer",    GENERICS, NULL,   "Layer of the generated rectangular shape" },
        { "ptstart",  POINT,    NULL,   "Start point of the path" },
        { "ptend",    POINT,    NULL,   "End point of the path" },
        { "ptoffset", POINT,    NULL,   "Offset point" },
        { "width",    INTEGER,  NULL,   "width of the path. Must be even" }
    };
    vector_append(entries, _make_api_entry(
        "path_ushape",
        MODULE_GEOMETRY,
        "Create a path shape that starts and ends at the start and end point, respectively and passes through the offset point. Only the y-coordinate of the offset point is taken, creating a shape resembling a (possibly inverted) 'U'",
        "geometry.path_ushape(cell, generics.metal(1), point.create(-50, 0), point.create(50, 0), point.create(0, 100))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.path_points_xy */
{
    struct parameter parameters[] = {
        { "ptstart",    POINT,      NULL,   "Start point of the path" },
        { "pts",        POINTLIST,  NULL,   "List of points or scalars" }
    };
    vector_append(entries, _make_api_entry(
        "path_points_xy",
        MODULE_GEOMETRY,
        "Create a point list for use in geometry.path that contains only horizontal and vertical movements based on a list of points or scalars.\n"
        "This function only creates the resulting list of points, no shapes by itself.\n"
        "A movement can be a point, in which case two resulting movements are created: first x, than y (or vice versa, depending on the current state).\n"
        "A scalar movement moves relatively by that amount (in x or y, again depending on the state)\n"
        "This function does the same as geometry.path_points_yx, but starts in x-direction"
        ,
        "geometry.path(cell, generics.metal(2), geometry.path_points_xy(point.create(0, 0), {\n"
        "    100, -- move 100 to the right\n"
        "    100, -- move 200 upwards\n"
        "      0, -- don't move, but switch direction\n"
        "    point.create(300, 300) -- move to (300, 300), first in y-direction, than in x-direction\n"
        "    }), 100)"
        ,
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.path_points_yx */
{
    struct parameter parameters[] = {
        { "ptstart",    POINT,      NULL,   "Start point of the path" },
        { "pts",        POINTLIST,  NULL,   "List of points or scalars" }
    };
    vector_append(entries, _make_api_entry(
        "path_points_yx",
        MODULE_GEOMETRY,
        "Create a point list for use in geometry.path that contains only horizontal and vertical movements based on a list of points or scalars.\n"
        "This function only creates the resulting list of points, no shapes by itself.\n"
        "A movement can be a point, in which case two resulting movements are created: first x, than y (or vice versa, depending on the current state).\n"
        "A scalar movement moves relatively by that amount (in x or y, again depending on the state)\n"
        "This function does the same as geometry.path_points_xy, but starts in y-direction"
        ,
        "geometry.path(cell, generics.metal(2), geometry.path_points_yx(point.create(0, 0), {\n"
        "    100, -- move 100 to the right\n"
        "    100, -- move 200 upwards\n"
        "      0, -- don't move, but switch direction\n"
        "    point.create(300, 300) -- move to (300, 300), first in y-direction, than in x-direction\n"
        "    }), 100)"
        ,
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.viabltr */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the via is created" },
        { "firstmetal", INTEGER,    NULL,   "Number of the first metal. Negative values are possible" },
        { "lastmetal",  INTEGER,    NULL,   "Number of the last metal. Negative values are possible" },
        { "bl",         POINT,      NULL,   "Bottom-left point of the generated rectangular shape" },
        { "tr",         POINT,      NULL,   "Top-right point of the generated rectangular shape" },
        { "properties", TABLE,      NULL,   "optional properties table" }
    };
    vector_append(entries, _make_api_entry(
        "viabltr",
        MODULE_GEOMETRY,
        "Create vias (single or stack) in a rectangular area with the given corner points in cell. Special properties can be passed to the via generation function: 'xcontinuous' (create vias that can be abutted in x-direction, boolean), 'ycontinuous' (create vias that can be abutted in y-direction, boolean), 'minxspace' (minimum x space), 'minyspace' (minimum y space), 'equal_pitch' (use equal spacing in both x- and y-direction, boolean) and 'widthclass' (give a width of the surrounding metal that the via is placed in and create the via as if it had this width. This is useful to solve DRC issues. Numeric parameter)",
        "geometry.viabltr(cell, 1, 3, point.create(-100, -20), point.create(100, 4))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.viabarebltr */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the via is created" },
        { "firstmetal", INTEGER,    NULL,   "Number of the first metal. Negative values are possible" },
        { "lastmetal",  INTEGER,    NULL,   "Number of the last metal. Negative values are possible" },
        { "bl",         POINT,      NULL,   "Bottom-left point of the generated rectangular shape" },
        { "tr",         POINT,      NULL,   "Top-right point of the generated rectangular shape" }
    };
    vector_append(entries, _make_api_entry(
        "viabarebltr",
        MODULE_GEOMETRY,
        "Create vias (single or stack) in a rectangular area with the given corner points in cell. This function is like viabltr, but no metals are drawn",
        "geometry.viabarebltr(cell, 1, 3, point.create(-100, -20), point.create(100, 4))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.viabltr_xcontinuous */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the via is created" },
        { "firstmetal", INTEGER,    NULL,   "Number of the first metal. Negative values are possible" },
        { "lastmetal",  INTEGER,    NULL,   "Number of the last metal. Negative values are possible" },
        { "bl",         POINT,      NULL,   "Bottom-left point of the generated rectangular shape" },
        { "tr",         POINT,      NULL,   "Top-right point of the generated rectangular shape" }
    };
    vector_append(entries, _make_api_entry(
        "viabltr_xcontinuous",
        MODULE_GEOMETRY,
        "Create vias (single or stack) in a rectangular area with the given corner points in cell. This function creates vias that can be abutted in x-direction. For this, the space between cuts and the surroundings are equalized",
        "geometry.viabltr_xcontinuous(cell, 1, 3, point.create(-100, -20), point.create(100, 4))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.viabltr_ycontinuous */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the via is created" },
        { "firstmetal", INTEGER,    NULL,   "Number of the first metal. Negative values are possible" },
        { "lastmetal",  INTEGER,    NULL,   "Number of the last metal. Negative values are possible" },
        { "bl",         POINT,      NULL,   "Bottom-left point of the generated rectangular shape" },
        { "tr",         POINT,      NULL,   "Top-right point of the generated rectangular shape" }
    };
    vector_append(entries, _make_api_entry(
        "viabltr_ycontinuous",
        MODULE_GEOMETRY,
        "Create vias (single or stack) in a rectangular area with the given corner points in cell. This function creates vias that can be abutted in y-direction. For this, the space between cuts and the surroundings are equalized",
        "geometry.viabltr_ycontinuous(cell, 1, 3, point.create(-100, -20), point.create(100, 4))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.viabltr_continuous */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the via is created" },
        { "firstmetal", INTEGER,    NULL,   "Number of the first metal. Negative values are possible" },
        { "lastmetal",  INTEGER,    NULL,   "Number of the last metal. Negative values are possible" },
        { "bl",         POINT,      NULL,   "Bottom-left point of the generated rectangular shape" },
        { "tr",         POINT,      NULL,   "Top-right point of the generated rectangular shape" }
    };
    vector_append(entries, _make_api_entry(
        "viabltr_continuous",
        MODULE_GEOMETRY,
        "Create vias (single or stack) in a rectangular area with the given corner points in cell. This function creates vias that can be abutted in both x- and y-direction. For this, the space between cuts and the surroundings are equalized",
        "geometry.viabltr_continuous(cell, 1, 3, point.create(-100, -20), point.create(100, 4))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.viabarebltr_xcontinuous */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the via is created" },
        { "firstmetal", INTEGER,    NULL,   "Number of the first metal. Negative values are possible" },
        { "lastmetal",  INTEGER,    NULL,   "Number of the last metal. Negative values are possible" },
        { "bl",         POINT,      NULL,   "Bottom-left point of the generated rectangular shape" },
        { "tr",         POINT,      NULL,   "Top-right point of the generated rectangular shape" }
    };
    vector_append(entries, _make_api_entry(
        "viabarebltr_xcontinuous",
        MODULE_GEOMETRY,
        "Create vias (single or stack) in a rectangular area with the given corner points in cell. This function creates vias that can be abutted in x-direction. For this, the space between cuts and the surroundings are equalized. This function is like viabltr_xcontinuous, but no metals are drawn",
        "geometry.viabltr_xcontinuous(cell, 1, 3, point.create(-100, -20), point.create(100, 4))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.viabarebltr_ycontinuous */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the via is created" },
        { "firstmetal", INTEGER,    NULL,   "Number of the first metal. Negative values are possible" },
        { "lastmetal",  INTEGER,    NULL,   "Number of the last metal. Negative values are possible" },
        { "bl",         POINT,      NULL,   "Bottom-left point of the generated rectangular shape" },
        { "tr",         POINT,      NULL,   "Top-right point of the generated rectangular shape" }
    };
    vector_append(entries, _make_api_entry(
        "viabarebltr_ycontinuous",
        MODULE_GEOMETRY,
        "Create vias (single or stack) in a rectangular area with the given corner points in cell. This function creates vias that can be abutted in y-direction. For this, the space between cuts and the surroundings are equalized. This function is like viabltr_ycontinuous, but no metals are drawn",
        "geometry.viabltr_ycontinuous(cell, 1, 3, point.create(-100, -20), point.create(100, 4))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.viabarebltr_continuous */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the via is created" },
        { "firstmetal", INTEGER,    NULL,   "Number of the first metal. Negative values are possible" },
        { "lastmetal",  INTEGER,    NULL,   "Number of the last metal. Negative values are possible" },
        { "bl",         POINT,      NULL,   "Bottom-left point of the generated rectangular shape" },
        { "tr",         POINT,      NULL,   "Top-right point of the generated rectangular shape" }
    };
    vector_append(entries, _make_api_entry(
        "viabarebltr_continuous",
        MODULE_GEOMETRY,
        "Create vias (single or stack) in a rectangular area with the given corner points in cell. This function creates vias that can be abutted in both x- and y-direction. For this, the space between cuts and the surroundings are equalized. This function is like viabltr_continuous, but no metals are drawn",
        "geometry.viabltr_continuous(cell, 1, 3, point.create(-100, -20), point.create(100, 4))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.contactbltr */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL,   "Object in which the contact is created" },
        { "layer",  STRING,     NULL,   "Identifier of the contact type. Possible values: 'gate', 'active', 'sourcedrain'" },
        { "bl",     POINT,      NULL,   "Bottom-left point of the generated rectangular shape" },
        { "tr",     POINT,      NULL,   "Top-right point of the generated rectangular shape" }
    };
    vector_append(entries, _make_api_entry(
        "contactbltr",
        MODULE_GEOMETRY,
        "Create contacts in a rectangular area with the given corner points in cell",
        "geometry.contactbltr(cell, \"sourcedrain\", point.create(-20, -250), point.create(20, 500))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.contactbarebltr */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL,   "Object in which the contact is created" },
        { "layer",  STRING,     NULL,   "Identifier of the contact type. Possible values: 'gate', 'active', 'sourcedrain'" },
        { "bl",     POINT,      NULL,   "Bottom-left point of the generated rectangular shape" },
        { "tr",     POINT,      NULL,   "Top-right point of the generated rectangular shape" }
    };
    vector_append(entries, _make_api_entry(
        "contactbarebltr",
        MODULE_GEOMETRY,
        "Create contacts in a rectangular area with the given corner points in cell. This function creates 'bare' contacts, so only the cut layers, no surrouning metals or semi-conductor layers",
        "geometry.contactbarebltr(cell, \"sourcedrain\", point.create(-20, -250), point.create(20, 500))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.cross */
{
    struct parameter parameters[] = {
        { "cell",      OBJECT,      NULL,   "Object in which the cross is created" },
        { "layer",     GENERICS,    NULL,   "Layer of the generated cross shape" },
        { "width",     INTEGER,     NULL,   "Width of the generated cross shape" },
        { "height",    INTEGER,     NULL,   "Height of the generated cross shape" },
        { "crosssize", INTEGER,     NULL,   "Cross size of the generated cross shape (the 'width' of the rectangles making up the cross)" },
    };
    vector_append(entries, _make_api_entry(
        "cross",
        MODULE_GEOMETRY,
        "Create a cross shape in the given cell. The cross is made up by two overlapping rectangles in horizontal and in vertical direction.",
        "geometry.cross(cell, generics.metal(2), 1000, 1000, 100)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.unequal_ring_pts */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,    NULL, "Object in which the ring is created" },
        { "layer",      GENERICS,  NULL, "Layer of the generated ring shape" },
        { "outerbl",    POINT,     NULL, "Outer lower-left corner of the generated ring shape" },
        { "outertr",    POINT,     NULL, "Outer upper-right corner of the generated ring shape" },
        { "innerbl",    POINT,     NULL, "Inner lower-left corner of the generated ring shape" },
        { "innertr",    POINT,     NULL, "Inner upper-right corner of the generated ring shape" },
    };
    vector_append(entries, _make_api_entry(
        "unequal_ring_pts",
        MODULE_GEOMETRY,
        "Create a ring shape with unequal ring widths in the given cell, defined by the corner points",
        "geometry.unequal_ring_pts(cell, generics.other(\"nwell\"), point.create(-1000, -1000), point.create(1000, 1000), point.create(-800, -800), point.create(800, 800))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.unequal_ring */
{
    struct parameter parameters[] = {
        { "cell",            OBJECT,    NULL, "Object in which the ring is created" },
        { "layer",           GENERICS,  NULL, "Layer of the generated ring shape" },
        { "center",          POINT,     NULL, "Center of the generated ring shape" },
        { "width",           INTEGER,   NULL, "Width of the generated ring shape" },
        { "height",          INTEGER,   NULL, "Height of the generated ring shape" },
        { "leftringwidth",   INTEGER,   NULL, "Left ring width of the generated ring shape (the 'width' of the path making up the left part of the ring)" },
        { "rightringwidth",  INTEGER,   NULL, "Right ring width of the generated ring shape (the 'width' of the path making up the right part of the ring)" },
        { "topringwidth",    INTEGER,   NULL, "Top ring width of the generated ring shape (the 'width' of the path making up the top part of the ring)" },
        { "bottomringwidth", INTEGER,   NULL, "Bottom ring width of the generated ring shape (the 'width' of the path making up the bottom part of the ring)" },
    };
    vector_append(entries, _make_api_entry(
        "unequal_ring",
        MODULE_GEOMETRY,
        "Create a ring shape with unequal ring widths in the given cell",
        "geometry.unequal_ring(cell, generics.other(\"nwell\"), point.create(0, 0), 2000, 2000, 100, 80, 20, 20)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.ring */
{
    struct parameter parameters[] = {
        { "cell",      OBJECT,      NULL, "Object in which the ring is created" },
        { "layer",     GENERICS,    NULL, "Layer of the generated ring shape" },
        { "center",    POINT,       NULL, "Center of the generated ring shape" },
        { "width",     INTEGER,     NULL, "Width of the generated ring shape" },
        { "height",    INTEGER,     NULL, "Height of the generated ring shape" },
        { "ringwidth", INTEGER,     NULL, "Ring width of the generated ring shape (the 'width' of the path making up the ring)" },
    };
    vector_append(entries, _make_api_entry(
        "ring",
        MODULE_GEOMETRY,
        "Create a ring shape width equal ring widths in the given cell. Like geometry.unequal_ring, but all widths are the same",
        "geometry.ring(cell, generics.other(\"nwell\"), point.create(0, 0), 2000, 2000, 100)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.curve */
{
    struct parameter parameters[] = {
        { "cell",      OBJECT,      NULL,       "Object in which the ring is created" },
        { "layer",     GENERICS,    NULL,       "Layer of the generated ring shape" },
        { "origin",    POINT,       NULL,       "Start point of the curve" },
        { "segments",  TABLE,       NULL,       "Table of curve segments" },
        { "grid",      INTEGER,     NULL,       "Grid for rasterization of the curve" },
        { "allow45",   BOOLEAN,     "false",    "Start point of the curve" },
    };
    vector_append(entries, _make_api_entry(
        "curve",
        MODULE_GEOMETRY,
        "Create a curve shape width in the given cell. Segments must be added for a curve to be meaningful. See the functions for adding curve segments: curve.lineto, curve.arcto and curve.cubicto",
        "geometry.curve(cell, generics.metal(-1), _pt(radius * math.cos(math.pi / 180 * angle), radius * math.sin(math.pi / 180 * angle)), {\n curve.arcto(135, 180, cornerradius, false),\n }, grid, allow45)\n geometry.curve(cell, generics.metal(-2), _pt((radius + cornerradius) * math.cos(math.pi / 180 * angle) - cornerradius, (radius + cornerradius) * math.sin(math.pi / 180 * angle)), {\n curve.arcto(180, 135, cornerradius, true),\n }, grid, allow45)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.curve_rasterized */
{
    struct parameter parameters[] = {
        { "cell",      OBJECT,      NULL,       "Object in which the ring is created" },
        { "layer",     GENERICS,    NULL,       "Layer of the generated ring shape" },
        { "origin",    POINT,       NULL,       "Start point of the curve" },
        { "segments",  TABLE,       NULL,       "Table of curve segments" },
        { "grid",      INTEGER,     NULL,       "Grid for rasterization of the curve" },
        { "allow45",   BOOLEAN,     "false",    "Start point of the curve" },
    };
    vector_append(entries, _make_api_entry(
        "curve_rasterized",
        MODULE_GEOMETRY,
        "Like geometry.curve, but rasterize the curve right now. Typically, the rasterization happens later in the layout generation process (it is resolved when the design is exported, depending whether the export format supports arbitrary curves, in which case there is no rasterization). This function is useful to generate rasterized curves for export formats that support arbitrary curves.",
        "geometry.curve_rasterized(cell, generics.metal(-1), _pt(radius * math.cos(math.pi / 180 * angle), radius * math.sin(math.pi / 180 * angle)), {\n curve.arcto(135, 180, cornerradius, false),\n }, grid, allow45)\n geometry.curve(cell, generics.metal(-2), _pt((radius + cornerradius) * math.cos(math.pi / 180 * angle) - cornerradius, (radius + cornerradius) * math.sin(math.pi / 180 * angle)), {\n curve.arcto(180, 135, cornerradius, true),\n }, grid, allow45)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.get_side_path_points */
{
    struct parameter parameters[] = {
        { "pts",    POINTLIST,  NULL,   "List of points that make up the path" },
        { "width",  INTEGER,    NULL,   "Width of the path" }
    };
    vector_append(entries, _make_api_entry(
        "get_side_path_points",
        MODULE_GEOMETRY,
        "Get one side of the edge points of a path given by the center points and the width. The sign of the width is significant: With positive values, the right-hand-side points are created, with negative values the left-hand-side (in the direction of the path). This function does not create any shapes.",
        "geometry.get_side_path_points({ point.create(0, 0), point.create(1000, 0) }, 50)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* geometry.path_points_to_polygon */
{
    struct parameter parameters[] = {
        { "pts",    POINTLIST,  NULL,   "List of points that make up the path" },
        { "width",  INTEGER,    NULL,   "Width of the path" }
    };
    vector_append(entries, _make_api_entry(
        "path_points_to_polygon",
        MODULE_GEOMETRY,
        "Get the edge points of a path given by the center points and the width. This function does not create any shapes. The result of this function can be put into geometry.polygon to create the path shape.",
        "geometry.path_points_to_polygon({ point.create(0, 0), point.create(1000, 0) }, 50)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

