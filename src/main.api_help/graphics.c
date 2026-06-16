/* graphics.quartercircle */
{
    struct parameter parameters[] = {
        { "quadrant",       INTEGER,    NULL, "quadrant of the circle" },
        { "origin",         POINT,      NULL, "origin of the circle" },
        { "radius",         INTEGER,    NULL, "radius of the circle" },
        { "grid",           INTEGER,    NULL, "rasterization grid" },
        { "allow45",        BOOLEAN,    NULL, "allow diagonal polygon edges" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "quartercircle",
        MODULE_GRAPHICS,
        "create a rasterized circle quarter",
        "Create a rasterized circle quarter (a polygon) with the given parameters. The generated quadrant is the first (between 0 and 90 degrees). The rasterization is governed by the grid, a finer grid produces more points, a looser grid fewer. With 'allow45' false, only a single x- or y-movement is allowed at each step, with 'allow45' true there can also be simultaneous x/y moves (diagonal edges). This function does not create any shapes, use with geometry.polygon if you want to actually have a circle shape.",
        "local pts = graphics.quartercircle(1, point.create(0, 0),\n    5000, 100, false\n)",
        parameters
    ));
}

/* graphics.quarterellipse */
{
    struct parameter parameters[] = {
        { "quadrant",       INTEGER,    NULL, "quadrant of the ellipse" },
        { "origin",         POINT,      NULL, "origin of the ellipse" },
        { "x-radius",       INTEGER,    NULL, "radius of the ellipse" },
        { "y-radius",       INTEGER,    NULL, "radius of the ellipse" },
        { "grid",           INTEGER,    NULL, "rasterization grid" },
        { "allow45",        BOOLEAN,    NULL, "allow diagonal polygon edges" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "quarterellipse",
        MODULE_GRAPHICS,
        "create a rasterized ellipse quarter",
        "Create a rasterized ellipse quarter (a polygon) with the given parameters. The generated quadrant is the first (between 0 and 90 degrees). The rasterization is governed by the grid, a finer grid produces more points, a looser grid fewer. With 'allow45' false, only a single x- or y-movement is allowed at each step, with 'allow45' true there can also be simultaneous x/y moves (diagonal edges). This function does not create any shapes, use with geometry.polygon if you want to actually have a ellipse shape.",
        "local pts = graphics.quarterellipse(1, point.create(0, 0),\n    5000, 10000,\n    100, false\n)",
        parameters
    ));
}

/* graphics.circle */
{
    struct parameter parameters[] = {
        { "origin",         POINT,      NULL, "origin of circle" },
        { "radius",         INTEGER,    NULL, "radius of circle" },
        { "startangle",     NUMBER,     NULL, "startangle (for segments, use 0 for a full circle)" },
        { "endangle",       NUMBER,     NULL, "endangle (for segments, use 360 for a full circle)" },
        { "grid",           INTEGER,    NULL, "rasterization grid" },
        { "allow45",        BOOLEAN,    NULL, "allow diagonal polygon edges" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "circle",
        MODULE_GRAPHICS,
        "create a rasterized circle",
        "Create a rasterized circle (a polygon) with the given parameters. The rasterization is governed by the grid, a finer grid produces more points, a looser grid fewer. With 'allow45' false, only a single x- or y-movement is allowed at each step, with 'allow45' true there can also be simultaneous x/y moves (diagonal edges). This function does not create any shapes, use with geometry.polygon if you want to actually have a circle shape.",
        "local pts = graphics.circle(point.create(0, 0),\n    5000,\n    0, 360,\n    100, false\n)",
        parameters
    ));
}

/* graphics.ellipse */
{
    struct parameter parameters[] = {
        { "origin",         POINT,      NULL, "origin of ellipse" },
        { "xradius",        INTEGER,    NULL, "x-radius of ellipse" },
        { "yradius",        INTEGER,    NULL, "y-radius of ellipse" },
        { "startangle",     NUMBER,     NULL, "startangle (for segments, use 0 for a full ellipse)" },
        { "endangle",       NUMBER,     NULL, "endangle (for segments, use 360 for a full ellipse)" },
        { "grid",           INTEGER,    NULL, "rasterization grid" },
        { "allow45",        BOOLEAN,    NULL, "allow diagonal polygon edges" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "ellipse",
        MODULE_GRAPHICS,
        "create a rasterized ellipse",
        "Create a rasterized ellipse (a polygon) with the given parameters. The rasterization is governed by the grid, a finer grid produces more points, a looser grid fewer. With 'allow45' false, only a single x- or y-movement is allowed at each step, with 'allow45' true there can also be simultaneous x/y moves (diagonal edges). This function does not create any shapes, use with geometry.polygon if you want to actually have a ellipse shape.",
        "local pts = graphics.ellipse(point.create(0, 0),\n    5000, 10000,\n    0, 360,\n    100, false\n)",
        parameters
    ));
}

/* graphics.coarse_circle*/
{
    struct parameter parameters[] = {
        { "origin",         POINT,      NULL, "origin of circle" },
        { "numpoints",      BOOLEAN,    NULL, "number of total points" },
        { "startangle",     NUMBER,     NULL, "startangle, determines where the first point is placed" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "circle",
        MODULE_GRAPHICS,
        "create a coarsely-approximated circle",
        "Create a coarse rendering of a circle, where points lying on the circle are simply connected by polygon edges. No rasterization is performed. This function creates regular polygons, for instance with 8 points an octagonal shape is generated.",
        "local pts = graphics.coarse_circle(point.create(0, 0),\n    5000, 0\n)",
        parameters
    ));
}
