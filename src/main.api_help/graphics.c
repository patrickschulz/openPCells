/* graphics.quartercircle */
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
        "quartercircle",
        MODULE_GRAPHICS,
        "Create a rasterized circle quarter (a polygon) with the given parameters. The generated quadrant is the first (between 0 and 90 degrees). The rasterization is governed by the grid, a finer grid produces more points, a looser grid fewer. With 'allow45' false, only a single x- or y-movement is allowed at each step, with 'allow45' true there can also be simultaneous x/y moves (diagonal edges). This function does not create any shapes, use with geometry.polygon if you want to actually have a circle shape.",
        "local pts = graphics.quartercircle(point.create(0, 0), 5000, 100, false)",
        parameters
    ));
}

/* graphics.quarterellipse */
{
    struct parameter parameters[] = {
        { "origin",         POINT,      NULL, "origin of ellipse" },
        { "x-radius",       INTEGER,    NULL, "radius of ellipse" },
        { "y-radius",       INTEGER,    NULL, "radius of ellipse" },
        { "startangle",     NUMBER,     NULL, "startangle (for segments, use 0 for a full ellipse)" },
        { "endangle",       NUMBER,     NULL, "endangle (for segments, use 360 for a full ellipse)" },
        { "grid",           INTEGER,    NULL, "rasterization grid" },
        { "allow45",        BOOLEAN,    NULL, "allow diagonal polygon edges" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "quarterellipse",
        MODULE_GRAPHICS,
        "Create a rasterized ellipse quarter (a polygon) with the given parameters. The generated quadrant is the first (between 0 and 90 degrees). The rasterization is governed by the grid, a finer grid produces more points, a looser grid fewer. With 'allow45' false, only a single x- or y-movement is allowed at each step, with 'allow45' true there can also be simultaneous x/y moves (diagonal edges). This function does not create any shapes, use with geometry.polygon if you want to actually have a ellipse shape.",
        "local pts = graphics.quarterellipse(point.create(0, 0), 5000, 100, false)",
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
        "Create a rasterized circle (a polygon) with the given parameters. The rasterization is governed by the grid, a finer grid produces more points, a looser grid fewer. With 'allow45' false, only a single x- or y-movement is allowed at each step, with 'allow45' true there can also be simultaneous x/y moves (diagonal edges). This function does not create any shapes, use with geometry.polygon if you want to actually have a circle shape.",
        "local pts = graphics.circle(point.create(0, 0), 5000, 0, 360, 100, false)",
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
        "Create a rasterized ellipse (a polygon) with the given parameters. The rasterization is governed by the grid, a finer grid produces more points, a looser grid fewer. With 'allow45' false, only a single x- or y-movement is allowed at each step, with 'allow45' true there can also be simultaneous x/y moves (diagonal edges). This function does not create any shapes, use with geometry.polygon if you want to actually have a ellipse shape.",
        "local pts = graphics.ellipse(point.create(0, 0), 5000, 10000, 0, 360, 100, false)",
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
        "Create a coarse rendering of a circle, where points lying on the circle are simply connected by polygon edges. No rasterization is performed. This function creates regular polygons, for instance with 8 points an octagonal shape is generated.",
        "local pts = graphics.coarse_circle(point.create(0, 0), 5000, 0)",
        parameters
    ));
}
