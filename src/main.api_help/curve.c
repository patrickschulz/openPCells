/* curve.lineto, */
{
    struct parameter parameters[] = {
        { "point", POINT, NULL, "destination point of the line segment" }
    };
    vector_append(entries, _make_api_entry(
        "lineto",
        MODULE_CURVE,
        // help text
        "create a line segment for a curve",
        // example
        "geometry.curve(cell, generics.metal(1), point.create(0, 0), {\n"
        "	curve.lineto(point.create(1000, 1000)),\n"
        "}, grid, allow45)\n"
        ,
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* curve.arcto, */
{
    struct parameter parameters[] = {
        { "startangle", NUMBER,     NULL, "start angle of the line segment" },
        { "endangle",   NUMBER,     NULL, "end angle of the line segment" },
        { "radius",     INTEGER,    NULL, "radius of the line segment" },
        { "clockwise",  BOOLEAN,    NULL, "flag if arc is drawn clock-wise or counter-clock-wise" }
    };
    vector_append(entries, _make_api_entry(
        "arcto",
        MODULE_CURVE,
        // help text
        "create an arc segment for a curve",
        // example
        "geometry.curve(cell, generics.metal(1), point.create(0, 0), {\n"
        "	curve.arcto(180, 0, 1000, true),\n"
        "}, grid, allow45)\n"
        ,
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* curve.cubicto */
{
    struct parameter parameters[] = {
        { "ctp1",   POINT, NULL, "first control point" },
        { "ctp2",   POINT, NULL, "second control point" },
        { "endpt",  POINT, NULL, "destination point of the cubic bezier segment" }
    };
    vector_append(entries, _make_api_entry(
        "cubicto",
        MODULE_CURVE,
        // help text
        "create a cubic bezier segment for a curve",
        // example
        "geometry.curve(cell, generics.metal(1), point.create(0, 0), {\n"
        "	curve.cubicto(point.create(0, 500), point.create(500, 500), point.create(500, 0)),\n"
        "}, grid, allow45)\n"
        ,
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

