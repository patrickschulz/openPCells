/* point.create */
{
    struct parameter parameters[] = {
        { "x", INTEGER, NULL, "x-coordinate of new point" },
        { "y", INTEGER, NULL, "y-coordinate of new point" }
    };
    vector_append(entries, _make_api_entry(
        "create",
        MODULE_POINT,
        "create a point from an x- and y-coordinate",
        "local pt = point.create(0, 0)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* point.combine_12(lhs, rhs) */
{
    struct parameter parameters[] = {
        { "pt1", POINT, NULL,   "point for the x-coordinate of the new point" },
        { "pt2", POINT, NULL,   "point for the y-coordinate of the new point" }
    };
    vector_append(entries, _make_api_entry(
        "combine_12",
        MODULE_POINT,
        "create a new point by combining the coordinates of two other points. The new point is made up by x1 and y2",
        "local new = point.combine_12(pt1, pt2) -- equivalent to point.create(pt1:getx(), pt2:gety())",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* point.combine_21(lhs, rhs) */
{
    struct parameter parameters[] = {
        { "pt1", POINT, NULL,   "point for the y-coordinate of the new point" },
        { "pt2", POINT, NULL,   "point for the x-coordinate of the new point" }
    };
    vector_append(entries, _make_api_entry(
        "combine_21",
        MODULE_POINT,
        "create a new point by combining the coordinates of two other points. The new point is made up by x2 and y1. This function is equivalent to combine_12 with swapped arguments",
        "local new = point.combine_21(pt1, pt2) -- equivalent to point.create(pt2:getx(), pt1:gety())",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* point.combine(lhs, rhs) */
{
    struct parameter parameters[] = {
        { "pt1", POINT, NULL,   "first point for the new point" },
        { "pt2", POINT, NULL,   "second point for the new point" }
    };
    vector_append(entries, _make_api_entry(
        "combine",
        MODULE_POINT,
        "combine two points into a new one by taking the arithmetic average of their coordinates, that is x = 0.5 * (x1 + x2), y = 0.5 * (y1 + y2)",
        "local newpt = point.combine(pt1, pt2)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* point.copy */
{
    struct parameter parameters[] = {
        { "point", POINT, NULL,   "point which should be copied" }
    };
    vector_append(entries, _make_api_entry(
        "copy",
        MODULE_POINT,
        "copy a point. Can be used as module function or as a point method",
        "local newpt = point.copy(pt)\nlocal newpt = pt:copy()",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* point.getx */
{
    struct parameter parameters[] = {
        { "point", POINT, NULL,   "point whose x-coordinate should be queried" },
    };
    vector_append(entries, _make_api_entry(
        "getx",
        MODULE_POINT,
        "get the x-coordinate from a point. Can be used as module function or as a point method",
        "local x = point.getx(pt)\nlocal x = pt:getx()",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* point.gety */
{
    struct parameter parameters[] = {
        { "point", POINT, NULL,   "point whose y-coordinate should be queried" },
    };
    vector_append(entries, _make_api_entry(
        "gety",
        MODULE_POINT,
        "get the y-coordinate from a point. Can be used as module function or as a point method",
        "local y = point.gety(pt)\nlocal y = pt:gety()",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* point.translate */
{
    struct parameter parameters[] = {
        { "point", POINT, NULL,   "point to translate" },
        { "x",     INTEGER, NULL, "x delta by which the point should be translated" },
        { "y",     INTEGER, NULL, "y delta by which the point should be translated" }
    };
    vector_append(entries, _make_api_entry(
        "translate",
        MODULE_POINT,
        "translate a point in x and y. Can be used as module function or as a point method",
        "point.translate(pt, 100, -20)\npt:translate(100, -20)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* point.translate_x */
{
    struct parameter parameters[] = {
        { "point", POINT, NULL,   "point to translate" },
        { "x",     INTEGER, NULL, "x delta by which the point should be translated" }
    };
    vector_append(entries, _make_api_entry(
        "translate_x",
        MODULE_POINT,
        "translate a point in x. Can be used as module function or as a point method",
        "point.translate(pt, 100)\npt:translate(100)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* point.translate_y */
{
    struct parameter parameters[] = {
        { "point", POINT, NULL,   "point to translate" },
        { "y",     INTEGER, NULL, "y delta by which the point should be translated" }
    };
    vector_append(entries, _make_api_entry(
        "translate_y",
        MODULE_POINT,
        "translate a point in y. Can be used as module function or as a point method",
        "point.translate(pt, 100)\npt:translate(100)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* point.xdistance */
{
    struct parameter parameters[] = {
        { "pt1", POINT, NULL, "point 1" },
        { "pt2", POINT, NULL, "point 2" }
    };
    vector_append(entries, _make_api_entry(
        "xdistance",
        MODULE_POINT,
        "calculate the y-distance between two points, (the ordering of input parameters matters, it is pt1.x - pt2.x)",
        "local distance = point.xdistance(pt1, pt2)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* point.xdistance_abs */
{
    struct parameter parameters[] = {
        { "pt1", POINT, NULL, "point 1" },
        { "pt2", POINT, NULL, "point 2" }
    };
    vector_append(entries, _make_api_entry(
        "xdistance_abs",
        MODULE_POINT,
        "calculate the x-distance between two points, but return the absolute (regardless of the ordering of input parameters)",
        "local distance = point.xdistance_abs(pt1, pt2)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* point.ydistance */
{
    struct parameter parameters[] = {
        { "pt1", POINT, NULL, "point 1" },
        { "pt2", POINT, NULL, "point 2" }
    };
    vector_append(entries, _make_api_entry(
        "ydistance",
        MODULE_POINT,
        "calculate the y-distance between two points, (the ordering of input parameters matters, it is pt1.y - pt2.y)",
        "local distance = point.ydistance(pt1, pt2)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* point.ydistance_abs */
{
    struct parameter parameters[] = {
        { "pt1", POINT, NULL, "point 1" },
        { "pt2", POINT, NULL, "point 2" }
    };
    vector_append(entries, _make_api_entry(
        "ydistance_abs",
        MODULE_POINT,
        "calculate the y-distance between two points, but return the absolute (regardless of the ordering of input parameters)",
        "local distance = point.ydistance_abs(pt1, pt2)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* point.xaverage */
{
    struct parameter parameters[] = {
        { "point", POINT, NULL,   "point which should be unwrapped" }
    };
    vector_append(entries, _make_api_entry(
        "xaverage",
        MODULE_POINT,
        "calculate the arithmetic average of the x-coordinates of two points",
        "local xmid = point.xaverage(pt1, pt2)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* point.yaverage */
{
    struct parameter parameters[] = {
        { "point", POINT, NULL,   "point which should be unwrapped" }
    };
    vector_append(entries, _make_api_entry(
        "yaverage",
        MODULE_POINT,
        "calculate the arithmetic average of the y-coordinates of two points",
        "local ymid = point.yaverage(pt1, pt2)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* point.fix */
{
    struct parameter parameters[] = {
        { "pt",   POINT, NULL,     "point to fix to the grid" },
        { "grid", INTEGER, NULL, "grid on which the coordinates should be fixed" },
    };
    vector_append(entries, _make_api_entry(
        "fix",
        MODULE_POINT,
        "fix the x- and y-coordinate from a point on a certain grid, that is 120 would become 100 on a grid of 100. This function behaves like floor(), no rounding is done",
        "point.create(120, 80):fix(100) -- yields (100, 0)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* point.operator+ */
{
    struct parameter parameters[] = {
        { "pt1",   POINT, NULL,     "first point for the sum" },
        { "pt2",   POINT, NULL,     "second point for the sum" },
    };
    vector_append(entries, _make_api_entry(
        "operator+",
        MODULE_POINT,
        "sum two points. This is the same as point.combine",
        "point.create(0, 0) + point.create(100, 0) -- yields (50, 0)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* point.operator- */
{
    struct parameter parameters[] = {
        { "pt1", POINT, NULL,   "first point for the subtraction (the minuend)" },
        { "pt2", POINT, NULL,   "second point for the subtraction (the subtrahend)" },
    };
    vector_append(entries, _make_api_entry(
        "operator-",
        MODULE_POINT,
        "create a new point representing the difference of two points",
        "point.create(0, 100) - point.create(50, 20) -- (-50, 80)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* point.operator.. */
{
    struct parameter parameters[] = {
        { "pt1", POINT, NULL,   "point for the x-coordinate of the new point" },
        { "pt2", POINT, NULL,   "point for the y-coordinate of the new point" }
    };
    vector_append(entries, _make_api_entry(
        "operator..",
        MODULE_POINT,
        "combine two points into a new one. Takes the x-coordinate from the first point and the y-coordinate from the second one. Equivalent to point.combine_12(pt1, pt2)",
        "point.create(0, 100) .. point.create(100, 0) -- (0, 0)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* point.unwrap */
{
    struct parameter parameters[] = {
        { "point", POINT, NULL,   "point which should be unwrapped" }
    };
    vector_append(entries, _make_api_entry(
        "unwrap",
        MODULE_POINT,
        "unwrap: get the x- and y-coordinate from a point. Can be used as module function or as a point method",
        "local x, y = point.unwrap(pt)\nlocal x, y = pt:unwrap()",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

