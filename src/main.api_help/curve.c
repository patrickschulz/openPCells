/* curve.arcto, */
{
    struct parameter parameters[] = {
        { "startangle", NUMBER,     NULL, "start angle of the line segment" },
        { "endangle",   NUMBER,     NULL, "end angle of the line segment" },
        { "radius",     INTEGER,    NULL, "radius of the line segment" },
        { "clockwise",  BOOLEAN,    NULL, "flag if arc is drawn clock-wise or counter-clock-wise" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "arcto",
        MODULE_CURVE,
        "create an arc segment for a curve",
        "Create an arc segment for a curve. "
        "The segment must be added to a curve definition, which will be handed to geometry.curve(). "
        "An arc segment starts at the previous point of the curve (or the start point of the curve if it is the first segment). "
        "The arc segment is then defined by the 'startangle' and the 'endangle', both with respect to 0, which is defined pointing to the right. "
        "Additionally, the arc segment is defined by its 'radius'. "
        "The boolean 'clockwise' can be set to true, to get an arc in the other direction. "
        "If not given, the arc is defined counter-clockwise.",
        "geometry.curve(cell, generics.metal(1), point.create(0, 0), {\n"
        "	curve.arcto(180, 0, 1000, true),\n"
        "}, grid, allow45)\n",
        parameters
    ));
}

/* curve.cubicto */
{
    struct parameter parameters[] = {
        { "ctp1",   POINT, NULL, "first control point" },
        { "ctp2",   POINT, NULL, "second control point" },
        { "endpt",  POINT, NULL, "destination point of the cubic bezier segment" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "cubicto",
        MODULE_CURVE,
        "create a cubic bezier segment for a curve",
        "Create a cubic bezier segment for a curve. "
        "The segment must be added to a curve definition, which will be handed to geometry.curve(). "
        "A cubic segment starts at the previous point of the curve (or the start point of the curve if it is the first segment). "
        "The cubic segment is then defined by the (implicit) start point, the 'endpoint' (third parameter) and two control points 'cpt1' and 'cpt2'.",
        "geometry.curve(cell, generics.metal(1), point.create(0, 0), {\n"
        "	curve.cubicto(point.create(0, 500), point.create(500, 500), point.create(500, 0)),\n"
        "}, grid, allow45)\n",
        parameters
    ));
}

/* curve.lineto, */
{
    struct parameter parameters[] = {
        { "point", POINT, NULL, "destination point of the line segment" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "lineto",
        MODULE_CURVE,
        "create a line segment for a curve",
        "Create a line segment for a curve. "
        "The segment must be added to a curve definition, which will be handed to geometry.curve(). "
        "A line segment starts at the previous point of the curve (or the start point of the curve if it is the first segment). "
        "The line segment is then defined by the (implicit) start point and the 'point' (the next point given as parameter).",
        "geometry.curve(cell, generics.metal(1), point.create(0, 0), {\n"
        "	curve.lineto(point.create(1000, 1000)),\n"
        "}, grid, allow45)\n",
        parameters
    ));
}

