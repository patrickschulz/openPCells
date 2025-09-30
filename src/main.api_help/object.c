/* object.abut_area_anchor_bottom */
{
    struct parameter parameters[] = {
        { "cell",               OBJECT,     NULL, "cell to be moved" },
        { "anchorname",         STRING,     NULL, "abutment anchor" },
        { "targetcell",         OBJECT,     NULL, "alignment target cell" },
        { "targetanchorname",   STRING,     NULL, "target abutment anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "abut_area_anchor_bottom",
        MODULE_OBJECT,
        "translate the cell so that the specified area anchor is abutted to the bottom of the target area anchor of the specified target cell. This only changes the y coordinate",
        "cell:abut_area_anchor_bottom(\"topgatestrap\", othercell, \"botgatestrap\")",
        parameters
    ));
}

/* object.abut_area_anchor_left */
{
    struct parameter parameters[] = {
        { "cell",               OBJECT,     NULL, "cell to be moved" },
        { "anchorname",         STRING,     NULL, "abutment anchor" },
        { "targetcell",         OBJECT,     NULL, "alignment target cell" },
        { "targetanchorname",   STRING,     NULL, "target abutment anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "abut_area_anchor_left",
        MODULE_OBJECT,
        "translate the cell so that the specified area anchor is abutted to the left of the target area anchor of the specified target cell. This only changes the x coordinate",
        "cell:abut_area_anchor_left(\"leftsourcedrain\", othercell, \"rightsourcedrain\")",
        parameters
    ));
}

/* object.abut_area_anchor_right */
{
    struct parameter parameters[] = {
        { "cell",               OBJECT,     NULL, "cell to be moved" },
        { "anchorname",         STRING,     NULL, "abutment anchor" },
        { "targetcell",         OBJECT,     NULL, "alignment target cell" },
        { "targetanchorname",   STRING,     NULL, "target abutment anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "abut_area_anchor_right",
        MODULE_OBJECT,
        "translate the cell so that the specified area anchor is abutted to the right of the target area anchor of the specified target cell. This only changes the x coordinate",
        "cell:abut_area_anchor_right(\"rightsourcedrain\", othercell, \"leftsourcedrain\")",
        parameters
    ));
}
/* object.abut_area_anchor_top */
{
    struct parameter parameters[] = {
        { "cell",               OBJECT,     NULL, "cell to be moved" },
        { "anchorname",         STRING,     NULL, "abutment anchor" },
        { "targetcell",         OBJECT,     NULL, "alignment target cell" },
        { "targetanchorname",   STRING,     NULL, "target abutment anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "abut_area_anchor_top",
        MODULE_OBJECT,
        "translate the cell so that the specified area anchor is abutted to the top of the target area anchor of the specified target cell. This only changes the y coordinate",
        "cell:abut_area_anchor_top(\"botgatestrap\", othercell, \"topgatestrap\")",
        parameters
    ));
}

/* object.abut_bottom_origin */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be abutted" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "abut_bottom_origin",
        MODULE_OBJECT,
        "translate the cell so that its alignment box (outer boundary) is abutted-bottom to the origin. This only changes the y coordinate",
        "cell:abut_bottom_origin()",
        parameters
    ));
}

/* object.abut_bottom */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be abutted" },
        { "targetcell",     OBJECT,     NULL, "abutment target cell" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "abut_bottom",
        MODULE_OBJECT,
        "translate the cell so that its alignment box is abutted to the bottom of the alignment box of the specified target cell. This only changes the y coordinate",
        "cell:abut_bottom(othercell)",
        parameters
    ));
}

/* object.abut_left_origin */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be abutted" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "abut_left_origin",
        MODULE_OBJECT,
        "translate the cell so that its alignment box (outer boundary) is abutted-left to the origin. This only changes the x coordinate",
        "cell:abut_left_origin()",
        parameters
    ));
}

/* object.abut_left */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be abutted" },
        { "targetcell",     OBJECT,     NULL, "abutment target cell" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "abut_left",
        MODULE_OBJECT,
        "translate the cell so that its alignment box is abutted to the left of the alignment box of the specified target cell. This only changes the y coordinate",
        "cell:abut_left(othercell)",
        parameters
    ));
}
/* object.abut_right_origin */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be abutted" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "abut_right_origin",
        MODULE_OBJECT,
        "translate the cell so that its alignment box (outer boundary) is abutted-right to the origin. This only changes the x coordinate",
        "cell:abut_right_origin()",
        parameters
));
}

/* object.abut_right */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be abutted" },
        { "targetcell",     OBJECT,     NULL, "abutment target cell" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "abut_right",
        MODULE_OBJECT,
        "translate the cell so that its alignment box is abutted to the right of the alignment box of the specified target cell. This only changes the y coordinate",
        "cell:abut_right(othercell)",
        parameters
    ));
}

/* object.abut_top_origin */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be abutted" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "abut_top_origin",
        MODULE_OBJECT,
        "translate the cell so that its alignment box (outer boundary) is abutted-top to the origin. This only changes the x coordinate",
        "cell:abut_top_origin()",
        parameters
    ));
}

/* object.abut_top */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be abutted" },
        { "targetcell",     OBJECT,     NULL, "abutment target cell" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "abut_top",
        MODULE_OBJECT,
        "translate the cell so that its alignment box is abutted to the top of the alignment box of the specified target cell. This only changes the y coordinate",
        "cell:abut_top(othercell)",
        parameters
    ));
}
/* object.add_anchor */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT, NULL, "object to which an anchor should be added" },
        { "name",   STRING, NULL, "name of the anchor" },
        { "where",  POINT,  NULL, "location of the anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "add_anchor",
        MODULE_OBJECT,
        "add an anchor to an object",
        "cell:add_anchor(\"output\", point.create(200, -20))",
        parameters
    ));
}

/* object.place_bottom_origin */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be placed" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_bottom_origin",
        MODULE_OBJECT,
        "translate the cell so that its alignment box (outer boundary) is placed-bottom to the origin. This only changes the y coordinate. This is similar to the corresponding abut function, but uses the bounding boxes of the cells.",
        "cell:place_bottom_origin()",
        parameters
    ));
}

/* object.place_bottom */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be placed" },
        { "targetcell",     OBJECT,     NULL, "placement target cell" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_bottom",
        MODULE_OBJECT,
        "translate the cell so that its alignment box is placed to the bottom of the alignment box of the specified target cell. This only changes the y coordinate. This is similar to the corresponding abut function, but uses the bounding boxes of the cells.",
        "cell:place_bottom(othercell)",
        parameters
    ));
}

/* object.place_left_origin */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be placed" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_left_origin",
        MODULE_OBJECT,
        "translate the cell so that its alignment box (outer boundary) is placed-left to the origin. This only changes the x coordinate. This is similar to the corresponding abut function, but uses the bounding boxes of the cells.",
        "cell:place_left_origin()",
        parameters
    ));
}

/* object.place_left */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be placed" },
        { "targetcell",     OBJECT,     NULL, "placement target cell" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_left",
        MODULE_OBJECT,
        "translate the cell so that its alignment box is placed to the left of the alignment box of the specified target cell. This only changes the y coordinate. This is similar to the corresponding abut function, but uses the bounding boxes of the cells.",
        "cell:place_left(othercell)",
        parameters
    ));
}
/* object.place_right_origin */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be placed" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_right_origin",
        MODULE_OBJECT,
        "translate the cell so that its alignment box (outer boundary) is placed-right to the origin. This only changes the x coordinate. This is similar to the corresponding abut function, but uses the bounding boxes of the cells.",
        "cell:place_right_origin()",
        parameters
    ));
}

/* object.place_right */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be placed" },
        { "targetcell",     OBJECT,     NULL, "placment target cell" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_right",
        MODULE_OBJECT,
        "translate the cell so that its alignment box is placed to the right of the alignment box of the specified target cell. This only changes the y coordinate. This is similar to the corresponding abut function, but uses the bounding boxes of the cells.",
        "cell:place_right(othercell)",
        parameters
    ));
}

/* object.place_top_origin */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be placed" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_top_origin",
        MODULE_OBJECT,
        "translate the cell so that its alignment box (outer boundary) is placed-top to the origin. This only changes the x coordinate. This is similar to the corresponding abut function, but uses the bounding boxes of the cells.",
        "cell:place_top_origin()",
        parameters
    ));
}

/* object.place_top */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be placed" },
        { "targetcell",     OBJECT,     NULL, "placement target cell" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_top",
        MODULE_OBJECT,
        "translate the cell so that its alignment box is placed to the top of the alignment box of the specified target cell. This only changes the y coordinate. This is similar to the corresponding abut function, but uses the bounding boxes of the cells.",
        "cell:place_top(othercell)",
        parameters
    ));
}
/* object.add_anchor */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT, NULL, "object to which an anchor should be added" },
        { "name",   STRING, NULL, "name of the anchor" },
        { "where",  POINT,  NULL, "location of the anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "add_anchor",
        MODULE_OBJECT,
        "add an anchor to an object",
        "cell:add_anchor(\"output\", point.create(200, -20))",
        parameters
    ));
}

/* object.add_area_anchor_bltr */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,  NULL, "object to which an anchor should be added" },
        { "name",   STRING,  NULL, "name of the anchor" },
        { "bl",     POINT,   NULL, "bottom-left point of the rectangular area" },
        { "tr",     POINT,   NULL, "top-right point of the rectangular area" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "add_area_anchor_bltr",
        MODULE_OBJECT,
        "Add an area anchor to a cell, defined by the lower-left and upper-right corner points of the rectangular area",
        "cell:add_area_anchor_bltr(\"source\", point.create(-100, -20), point.create(100, 20))",
        parameters
    ));
}

/* object.add_area_anchor_points */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,  NULL, "object to which an anchor should be added" },
        { "name",   STRING,  NULL, "name of the anchor" },
        { "pt1",    POINT,   NULL, "first point of the rectangular area" },
        { "pt2",    POINT,   NULL, "second point of the rectangular area" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "add_area_anchor_points",
        MODULE_OBJECT,
        "Add an area anchor to a cell, defined by the two corner points of the rectangular area (order does not matter)",
        "cell:add_area_anchor_points(\"source\", point.create(100, 20), point.create(-100, -20))",
        parameters
    ));
}

/* object.add_area_anchor_blwh */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,  NULL, "object to which an anchor should be added" },
        { "name",   STRING,  NULL, "name of the anchor" },
        { "pt1",    POINT,   NULL, "first point of the rectangular area" },
        { "width",  INTEGER, NULL, "width of the rectangular area" },
        { "height", INTEGER, NULL, "height of the rectangular area" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "add_area_anchor_blwh",
        MODULE_OBJECT,
        "Add an area anchor to a cell, defined by the the lower-left corner point and the width and height of the rectangular area",
        "cell:add_area_anchor_blwh(\"source\", point.create(-100, -20), 200, 40)",
        parameters
    ));
}

/* object.add_anchor_line_x */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,  NULL, "object to which an anchor line should be added" },
        { "name",   STRING,  NULL, "name of the anchor line" },
        { "x",      INTEGER, NULL, "x-coordinate of the anchor line" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "add_anchor_line_x",
        MODULE_OBJECT,
        "Add an anchor line to a cell (given its x-coordinate)",
        "cell:add_anchor_line_x(\"xbase\", 40)",
        parameters
    ));
}

/* object.add_anchor_line_y */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,  NULL, "object to which an anchor line should be added" },
        { "name",   STRING,  NULL, "name of the anchor line" },
        { "y",      INTEGER, NULL, "y-coordinate of the anchor line" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "add_anchor_line_y",
        MODULE_OBJECT,
        "Add an anchor line to a cell (given its y-coordinate)",
        "cell:add_anchor_line_y(\"ybase\", 40)",
        parameters
    ));
}

/* object.add_bus_port */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL, "object to which a port should be added" },
        { "name",       STRING,     NULL, "base name of the port" },
        { "layer",      GENERICS,   NULL, "layer of the port" },
        { "where",      POINT,      NULL, "location of the port" },
        { "startindex", INTEGER,    NULL, "start index of the bus port" },
        { "endindex",   INTEGER,    NULL, "end index of the bus port" },
        { "xpitch",     INTEGER,    NULL, "pitch in x direction" },
        { "ypitch",     INTEGER,    NULL, "pitch in y direction" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "add_bus_port",
        MODULE_OBJECT,
        "add a bus port (multiple ports like vout[0:4]) to a cell. The port expression is portname[startindex:endindex] and portname[i] is placed at 'where' with an offset of ((i - 1) * xpitch, (i - 1) * ypitch)",
        "cell:add_bus_port(\"vout\", generics.metalport(4), point.create(200, 0), 0, 4, 200, 0)",
        parameters
    ));
}

/* object.add_child_array */
{
    struct parameter parameters[] = {
        { "cell",      OBJECT,      NULL,   "Object to which the child is added" },
        { "child",     OBJECT,      NULL,   "Child to add" },
        { "instname",  STRING,      NULL,   "Instance name (not used by all exports)" },
        { "xrep",      INTEGER,     NULL,   "Number of repetitions in x direction" },
        { "yrep",      INTEGER,     NULL,   "Number of repetitions in y direction" },
        { "xpitch",    INTEGER,     NULL,   "Optional itch in x direction, used for repetition in x. If not given, this parameter is derived from the alignment box" },
        { "ypitch",    INTEGER,     NULL,   "Optional itch in y direction, used for repetition in y. If not given, this parameter is derived from the alignment box" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "add_child_array",
        MODULE_OBJECT,
        "Add a child as an arrayed object to the given cell. The child array has xrep * yrep elements, with a pitch of xpitch and ypitch, respectively. The array grows to the upper-left, with the first placed untranslated. The pitch does not have to be explicitly given: If the child has an alignment box, the xpitch and ypitch are deferred from this box, if they are not given in the call. In this case, it is an error if no alignment box is present in child. As with object.add_child: don't use the original child object after this call unless it is object.add_child or object.add_child_array",
        "-- with explicit xpitch and ypitch:\nlocal ref = pcell.create_layout(\"basic/mosfet\", \"mosfet\")\ncell:add_child_array(ref, \"mosinst0\", 8, 1, 200, 0)\n-- with alignment box:\nlocal ref = pcell.create_layout(\"basic/mosfet\", \"mosfet\")\ncell:add_child_array(ref, \"mosinst0\", 8, 1)",
        parameters
    ));
}

/* object.add_layer_boundary */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL, "object to which the layer boundary should be added" },
        { "layer",      GENERICS,   NULL, "layer for the layer boundary" },
        { "boundary",   POINTLIST,  NULL, "the boundary (a polygon)" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "add_layer_boundary",
        MODULE_OBJECT,
        "Add a layer boundary to an object. A layer boundary is useful for automatic filling",
        "cell:add_layer_boundary(generics.metal(1), { point.create(0, 0), point.create(1000, 0), point.create(500, 500) })",
        parameters
    ));
}

/* object.add_layer_boundary_rectangular */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "object to which the layer boundary should be added" },
        { "layer",  GENERICS,   NULL, "layer for the layer boundary" },
        { "bl",     POINT,      NULL, "lower-left corner point of the rectangular boundary" },
        { "tr",     POINT,      NULL, "upper-right corner point of the rectangular boundary" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "add_layer_boundary_rectangular",
        MODULE_OBJECT,
        "Add a rectangular layer boundary to an object. A layer boundary is useful for automatic filling",
        "cell:add_layer_boundary_rectangular(generics.metal(1), point.create(-100, -100), point.create(100, 100))",
        parameters
    ));
}

/* object.add_label */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,   NULL, "object to which a port should be added" },
        { "name",   STRING,   NULL, "name of the port" },
        { "layer",  GENERICS, NULL, "layer of the port" },
        { "where",  POINT,    NULL, "location of the port" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "add_label",
        MODULE_OBJECT,
        "add a label to a cell. Works like add_anchor, but additionally a layer is expected. This is different from add_port in that it expresses intent for labels that are not connectivity-related (as opposed to ports)",
        "cell:add_label(\"0.8\", generics.other(\"M1voltagelabelhigh\"), point.create(100, 0))",
        parameters
    ));
}

/* object.add_port */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,   NULL, "object to which a port should be added" },
        { "name",   STRING,   NULL, "name of the port" },
        { "layer",  GENERICS, NULL, "layer of the port" },
        { "where",  POINT,    NULL, "location of the port" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "add_port",
        MODULE_OBJECT,
        "add a port to a cell. Works like add_anchor, but additionally a layer is expected",
        "cell:add_port(\"vdd\", generics.metalport(2), point.create(100, 0))",
        parameters
    ));
}

/* object.add_port_with_anchor */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,   NULL, "object to which a port should be added" },
        { "name",   STRING,   NULL, "name of the port" },
        { "layer",  GENERICS, NULL, "layer of the port" },
        { "where",  POINT,    NULL, "location of the port" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "add_port_with_anchor",
        MODULE_OBJECT,
        "add a port to a cell. Works like add_anchor, but additionally a layer is expected. This function also adds an anchor to the cell (named like the port)",
        "cell:add_port_with_anchor(\"vdd\", generics.metalport(2), point.create(100, 0))",
        parameters
    ));
}

/* object.align_area_anchor_bottom */
{
    struct parameter parameters[] = {
        { "cell",               OBJECT,     NULL, "cell to be moved" },
        { "anchorname",         STRING,     NULL, "alignment anchor" },
        { "targetcell",         OBJECT,     NULL, "alignment target cell" },
        { "targetanchorname",   STRING,     NULL, "target alignment anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "align_area_anchor_bottom",
        MODULE_OBJECT,
        "translate the cell so that the specified area anchor is aligned to the bottom of the target area anchor of the specified target cell. This only changes the y coordinate",
        "cell:align_area_anchor_bottom(\"topgatestrap\", othercell, \"botgatestrap\")",
        parameters
    ));
}

/* object.align_area_anchor_left */
{
    struct parameter parameters[] = {
        { "cell",               OBJECT,     NULL, "cell to be moved" },
        { "anchorname",         STRING,     NULL, "alignment anchor" },
        { "targetcell",         OBJECT,     NULL, "alignment target cell" },
        { "targetanchorname",   STRING,     NULL, "target alignment anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "align_area_anchor_left",
        MODULE_OBJECT,
        "translate the cell so that the specified area anchor is aligned to the left of the target area anchor of the specified target cell. This only changes the x coordinate",
        "cell:align_area_anchor_left(\"leftsourcedrain\", othercell, \"rightsourcedrain\")",
        parameters
    ));
}

/* object.align_area_anchor_right */
{
    struct parameter parameters[] = {
        { "cell",               OBJECT,     NULL, "cell to be moved" },
        { "anchorname",         STRING,     NULL, "alignment anchor" },
        { "targetcell",         OBJECT,     NULL, "alignment target cell" },
        { "targetanchorname",   STRING,     NULL, "target alignment anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "align_area_anchor_right",
        MODULE_OBJECT,
        "translate the cell so that the specified area anchor is aligned to the right of the target area anchor of the specified target cell. This only changes the x coordinate",
        "cell:align_area_anchor_right(\"rightsourcedrain\", othercell, \"leftsourcedrain\")",
        parameters
    ));
}

/* object.align_area_anchor_top */
{
    struct parameter parameters[] = {
        { "cell",               OBJECT,     NULL, "cell to be moved" },
        { "anchorname",         STRING,     NULL, "alignment anchor" },
        { "targetcell",         OBJECT,     NULL, "alignment target cell" },
        { "targetanchorname",   STRING,     NULL, "target alignment anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "align_area_anchor_top",
        MODULE_OBJECT,
        "translate the cell so that the specified area anchor is aligned to the top of the target area anchor of the specified target cell. This only changes the y-coordinate",
        "cell:align_area_anchor_top(\"botgatestrap\", othercell, \"topgatestrap\")",
        parameters
    ));
}

/* object.align_area_anchor*/
{
    struct parameter parameters[] = {
        { "cell",               OBJECT,     NULL, "cell to be moved" },
        { "anchorname",         STRING,     NULL, "alignment anchor" },
        { "targetcell",         OBJECT,     NULL, "alignment target cell" },
        { "targetanchorname",   STRING,     NULL, "target alignment anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "align_area_anchor",
        MODULE_OBJECT,
        "translate the cell so that the specified area anchor is aligned to the target area anchor of the specified target cell. This changes both the x- and the y-coordinate",
        "cell:align_area_anchor(\"leftsourcedrain\", othercell, \"rightsourcedrain\")",
        parameters
    ));
}

/* object.align_area_anchor_x*/
{
    struct parameter parameters[] = {
        { "cell",               OBJECT,     NULL, "cell to be moved" },
        { "anchorname",         STRING,     NULL, "alignment anchor" },
        { "targetcell",         OBJECT,     NULL, "alignment target cell" },
        { "targetanchorname",   STRING,     NULL, "target alignment anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "align_area_anchor_x",
        MODULE_OBJECT,
        "translate the cell so that the specified area anchor is aligned to the target area anchor of the specified target cell. This changes only the x-coordinate",
        "cell:align_area_anchor_x(\"leftsourcedrain\", othercell, \"rightsourcedrain\")",
        parameters
    ));
}

/* object.align_area_anchor_y*/
{
    struct parameter parameters[] = {
        { "cell",               OBJECT,     NULL, "cell to be moved" },
        { "anchorname",         STRING,     NULL, "alignment anchor" },
        { "targetcell",         OBJECT,     NULL, "alignment target cell" },
        { "targetanchorname",   STRING,     NULL, "target alignment anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "align_area_anchor_y",
        MODULE_OBJECT,
        "translate the cell so that the specified area anchor is aligned to the target area anchor of the specified target cell. This changes only the y-coordinate",
        "cell:align_area_anchor_y(\"leftsourcedrain\", othercell, \"rightsourcedrain\")",
        parameters
    ));
}

/* object.align_bottom */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be aligned" },
        { "targetcell",     OBJECT,     NULL, "alignment target cell" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "align_bottom",
        MODULE_OBJECT,
        "translate the cell so that its alignment box is aligned to the bottom of the alignment box of the specified target cell. This only changes the y coordinate",
        "cell:align_bottom(othercell)",
        parameters
    ));
}

/* object.align_bottom_origin */
{
    struct parameter parameters[] = {
        { "cell", OBJECT, NULL, "cell to be aligned" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "align_bottom_origin",
        MODULE_OBJECT,
        "translate the cell so that its alignment box (outer boundary) is aligned-bottom to the origin. This only changes the y coordinate",
        "cell:align_bottom_origin(othercell)",
        parameters
    ));
}

/* object.align_left_origin */
{
    struct parameter parameters[] = {
        { "cell", OBJECT, NULL, "cell to be aligned" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "align_left_origin",
        MODULE_OBJECT,
        "translate the cell so that its alignment box (outer boundary) is aligned-left to the origin. This only changes the x coordinate",
        "cell:align_left_origin(othercell)",
        parameters
    ));
}

/* object.align_left */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be aligned" },
        { "targetcell",     OBJECT,     NULL, "alignment target cell" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "align_left",
        MODULE_OBJECT,
        "translate the cell so that its alignment box is aligned to the left of the alignment box of the specified target cell. This only changes the x coordinate",
        "cell:align_left(othercell)",
        parameters
    ));
}

/* object.alignment_box_include_point */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT, NULL, "cell to extend the alignment box of" },
        { "pt",     POINT,  NULL, "point to be included in the alignment box of the cell" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "alignment_box_include_point",
        MODULE_OBJECT,
        "extend the alignment box of a cell in a way that the given point is included in it. The alignment box is never shrunken, only enlarged.",
        "cell:alignment_box_include_point(point.create(200, 200))",
        parameters
    ));
}

/* object.alignment_box_include_x */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT, NULL, "cell to extend the alignment box of" },
        { "pt",     POINT,  NULL, "point to be included in the alignment box of the cell" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "alignment_box_include_x",
        MODULE_OBJECT,
        "like alignment_box_include_point, but only change the x-coordinates of the alignment box. The y-coordinate is ignored, the second argument is a point only for convenience.",
        "cell:alignment_box_include_x(point.create(200, 200))",
        parameters
    ));
}

/* object.alignment_box_include_y */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT, NULL, "cell to extend the alignment box of" },
        { "pt",     POINT,  NULL, "point to be included in the alignment box of the cell" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "alignment_box_include_y",
        MODULE_OBJECT,
        "like alignment_box_include_point, but only change the y-coordinates of the alignment box. The x-coordinate is ignored, the second argument is a point only for convenience.",
        "cell:alignment_box_include_y(point.create(200, 200))",
        parameters
    ));
}

/* object.align_right_origin */
{
    struct parameter parameters[] = {
        { "cell", OBJECT, NULL, "cell to be aligned" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "align_right_origin",
        MODULE_OBJECT,
        "translate the cell so that its alignment box (outer boundary) is aligned-right to the origin. This only changes the x coordinate",
        "cell:align_right_origin(othercell)",
        parameters
    ));
}

/* object.align_right */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be aligned" },
        { "targetcell",     OBJECT,     NULL, "alignment target cell" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "align_right",
        MODULE_OBJECT,
        "translate the cell so that its alignment box is aligned to the right of the alignment box of the specified target cell. This only changes the x coordinate",
        "cell:align_right(othercell)",
        parameters
    ));
}

/* object.align_top_origin */
{
    struct parameter parameters[] = {
        { "cell", OBJECT, NULL, "cell to be aligned" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "align_top_origin",
        MODULE_OBJECT,
        "translate the cell so that its alignment box (outer boundary) is aligned-top to the origin. This only changes the y coordinate",
        "cell:align_top_origin(othercell)",
        parameters
    ));
}

/* object.align_top */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be aligned" },
        { "targetcell",     OBJECT,     NULL, "alignment target cell" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "align_top",
        MODULE_OBJECT,
        "translate the cell so that its alignment box is aligned to the top of the alignment box of the specified target cell. This only changes the y coordinate",
        "cell:align_top(othercell)",
        parameters
    ));
}

/* object.align_center_x */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be aligned" },
        { "targetcell",     OBJECT,     NULL, "alignment target cell" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "align_center_x",
        MODULE_OBJECT,
        "translate the cell so that its alignment box is centered (in x) to the alignment box of the specified target cell. This only changes the x coordinate",
        "cell:align_center_x(othercell)",
        parameters
    ));
}

/* object.align_center_y */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be aligned" },
        { "targetcell",     OBJECT,     NULL, "alignment target cell" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "align_center_y",
        MODULE_OBJECT,
        "translate the cell so that its alignment boy is centered (in y) to the alignment boy of the specified target cell. This only changes the y coordinate",
        "cell:align_center_y(othercell)",
        parameters
    ));
}

/* object.clear_alignment_box */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT, NULL, "cell to clear the alignment box of" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "clear_alignment_box",
        MODULE_OBJECT,
        "clear (remove) the alignment box of a cell. Useful to set a new alignment box with object.set_alignment_box(...)",
        "cell:clear_alignment_box()",
        parameters
    ));
}

/* object.copy */
{
    struct parameter parameters[] = {
        { "cell", OBJECT, NULL, "Object to copy" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "copy",
        MODULE_OBJECT,
        "copy an object",
        "local new = cell:copy()",
        parameters
    ));
}

/* object.create_object_handle */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "parent cell to add the reference to" },
        { "reference",  OBJECT, NULL, "the reference cell, of which a handle is created" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "create_object_handle",
        MODULE_OBJECT,
        "create an object handle of a reference cell and store it in a parent cell. This is used internally when a cell is added for the first time as child. This function is exposed to the user in order to explicitly create these handles. They are useful when multiple cells in a hierarchy add the same object as a child, which would not be possible otherwise (this would require either a complete copy of the object with a new name or the cell hierarchy would contain the same object twice)",
        "local handle = object.create_object_handle(parent, reference)\nsubcell1:add_child(handle, \"child\")\nsubcell2:add_child(handle, \"child\")\nparent:add_child(subcell1, \"sub1\")\nparent:add_child(subcell2, \"sub2\")",
        parameters
    ));
}

/* object.create */
{
    struct parameter parameters[] = {
        { "cellname", STRING, NULL, "the name of the layout cell" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "create",
        MODULE_OBJECT,
        "create a new object. A name must be given. Hierarchical exports use this name to identify layout cells and no checks for duplication are done. Therefore the user must make sure that every name is unique. Note that this will probably change in the future",
        "local cell = object.create(\"toplevel\")",
        parameters
    ));
}

/* object.create_pseudo */
{
    struct parameter parameters[] = {
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "create_pseudo",
        MODULE_OBJECT,
        "create a new object without a name. This kind of object behaves exactly like a regular object, but it can't be added as a child to a parent object. It is intended to be used as a flat container for shapes that are merged into another cell. This function is there to express this intent, but other than this there are no advantages of using this function over object.create() (except that one does not have to come up with a name)",
        "local container = object.create_pseudo()",
        parameters
    ));
}

/* object.exchange */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "Object which should take over the other object" },
        { "othercell",  OBJECT, NULL, "Object which should be taken over. The object handle must not be used after this operation" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "exchange",
        MODULE_OBJECT,
        "Take over internal state of the other object, effectively making this the main cell. The object handle to 'othercell' must not be used afterwards as this object is destroyed. This function is only really useful in cells that act as a parameter wrapper for other cells (e.g. dffpq -> dff)",
        "cell:exchange(othercell)",
        parameters
    ));
}

/* object.extend_alignment_box */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL,   "cell to add the alignment box to" },
        { "extouterblx",    INTEGER,    NULL,   "extension of outer-left coordinate" },
        { "extouterbly",    INTEGER,    NULL,   "extension of outer-bottom coordinate" },
        { "extoutertrx",    INTEGER,    NULL,   "extension of outer-right coordinate" },
        { "extoutertry",    INTEGER,    NULL,   "extension of outer-top coordinate" },
        { "extinnerblx",    INTEGER,    NULL,   "extension of inner-left coordinate" },
        { "extinnerbly",    INTEGER,    NULL,   "extension of inner-bottom coordinate" },
        { "extinnertrx",    INTEGER,    NULL,   "extension of inner-right coordinate" },
        { "extinnertry",    INTEGER,    NULL,   "extension of inner-top coordinate" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "extend_alignment_box",
        MODULE_OBJECT,
        "extend an existing object alignment box. Takes eight values for the extension of the four corner points making up the alignment box",
        "cell:extend_alignment_box(-100, -100, 100, 100, 0, 0, 0, 0)",
        parameters
    ));
}

/* object.extend_alignment_box_x_symmetrical */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL,   "cell to add the alignment box to" },
        { "extx",   INTEGER,    NULL,   "x-extension" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "extend_alignment_box_x_symmetrical",
        MODULE_OBJECT,
        "extend an existing object alignment box. Takes only one value for the extension of the four corner points and extends all x-coordinates of the box symmetrically in the left/right direction",
        "cell:extend_alignment_box_x_symmetrical(200)",
        parameters
    ));
}

/* object.extend_alignment_box_xy_symmetrical */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL,   "cell to add the alignment box to" },
        { "extx",   INTEGER,    NULL,   "x-extension" },
        { "exty",   INTEGER,    NULL,   "y-extension" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "extend_alignment_box_xy_symmetrical",
        MODULE_OBJECT,
        "extend an existing object alignment box. Takes two values for the extension of the four corner points and extends all x- and y-coordinates of the box symmetrically in the left/right direction. This function is the same as calling the individual alignment box extension functions for x- and y-directions individually",
        "cell:extend_alignment_box_xy_symmetrical(200, 300)",
        parameters
    ));
}

/* object.extend_alignment_box_y_symmetrical */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL,   "cell to add the alignment box to" },
        { "exty",   INTEGER,    NULL,   "y-extension" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "extend_alignment_box_y_symmetrical",
        MODULE_OBJECT,
        "extend an existing object alignment box. Takes only one value for the extension of the four corner points and extends all y-coordinates of the box symmetrically in the left/right direction",
        "cell:extend_alignment_box_y_symmetrical(200)",
        parameters
    ));
}

/* object.flatten_inline */
{
    struct parameter parameters[] = {
        { "cell",      OBJECT, NULL, "Object which should be flattened" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "flatten_inline",
        MODULE_OBJECT,
        "resolve the cell by placing all shapes from all children in the parent cell. This operates in-place and modifies the object. Copy the cell or use object:flatten() if this is unwanted",
        "cell:flatten_inline()\ncell:copy():flatten_inline()",
        parameters
    ));
}

/* object.flatten */
{
    struct parameter parameters[] = {
        { "cell",      OBJECT, NULL, "Object which should be flattened" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "flatten",
        MODULE_OBJECT,
        "resolve the cell by placing all shapes from all children in the parent cell. This operates in-place and modifies the object. Copy the cell if this is unwanted",
        "cell:flatten()\ncell:copy():flatten()",
        parameters
    ));
}

/* object.flatten */
{
    struct parameter parameters[] = {
        { "cell",      OBJECT, NULL, "Object which should be flattened" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "flatten",
        MODULE_OBJECT,
        "resolve the cell by placing all shapes from all children in the parent cell. This does not change the original object and creates a copy.",
        "cell:flatten()\ncell:copy():flatten()",
        parameters
    ));
}

/* object.flipx */
{
    struct parameter parameters[] = {
        { "cell", OBJECT, NULL, "object to be flipped in y-direction" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "flipx",
        MODULE_OBJECT,
        "flip the entire object in x direction. This is similar to mirror_at_yaxis (note the x vs. y), but is done in-place. The object is translated so that it is still in its original location. Works best on objects with an alignment box, since this is used to calculate the required translation. On other objects, this operation can be time-consuming as an accurate bounding box has to be computed. It is recommended not to use this function on objects without an alignment box because the result is not always ideal",
        "cell:flipx()",
        parameters
    ));
}

/* object.flipy */
{
    struct parameter parameters[] = {
        { "cell", OBJECT, NULL, "object to be flipped in y-direction" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "flipy",
        MODULE_OBJECT,
        "flip the entire object in y direction. This is similar to mirror_at_xaxis (note the y vs. x), but is done in-place. The object is translated so that it is still in its original location. Works best on objects with an alignment box, since this is used to calculate the required translation. On other objects, this operation can be time-consuming as an accurate bounding box has to be computed. It is recommended not to use this function on objects without an alignment box because the result is not always ideal",
        "cell:flipy()",
        parameters
    ));
}

/* object.get_alignment_anchor */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "object to get an anchor from" },
        { "anchorname", STRING, NULL, "name of the alignment anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_alignment_anchor",
        MODULE_OBJECT,
        "Retrieve an alignment anchor from a cell. These anchors are the defining points of the alignment box. Valid anchor names are 'outerbl', 'outerbr', 'outertl', 'outertr', 'innerbl', 'innerbr', 'innertl' and 'innertr'. This function returns a point that contains the position of the specified anchor, corrected by the cell transformation. A non-existing anchor is an error",
        "cell:get_alignment_anchor(\"outerbl\")",
        parameters
    ));
}

/* object.get_all_regular_anchors */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "object to get an anchor from" },
        { "anchorname", STRING, NULL, "name of the anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_all_regular_anchors",
        MODULE_OBJECT,
        "Create a table containing all regular (non-alignment) anchors of a cell. The table can be iterated with standard lua methods (pairs). Area anchors are reported with four anchors (bl, br, tl and tr)",
        "cell:get_all_regular_anchors()",
        parameters
    ));
}

/* object.get_anchor_line_x */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "object to get an anchor from" },
        { "anchorname", STRING, NULL, "name of the anchor line" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_anchor_line_x",
        MODULE_OBJECT,
        "Retrieve an anchor line from a cell. This function returns a coordinate that contains the x-position of the specified anchor line, corrected by the cell transformation. Retrieving non-existing anchor lines raises an error. There is (and can't) be any checks that an x-coordinate is not used as a y-coordinate and vice versa.",
        "cell:get_anchor_line_x(\"activeleft\")",
        parameters
    ));
}

/* object.get_anchor_line_y */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "object to get an anchor from" },
        { "anchorname", STRING, NULL, "name of the anchor line" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_anchor_line_y",
        MODULE_OBJECT,
        "Retrieve an anchor line from a cell. This function returns a coordinate that contains the y-position of the specified anchor line, corrected by the cell transformation. Retrieving non-existing anchor lines raises an error. There is (and can't) be any checks that an x-coordinate is not used as a y-coordinate and vice versa.",
        "cell:get_anchor_line_y(\"activetop\")",
        parameters
    ));
}

/* object.get_anchor */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "object to get an anchor from" },
        { "anchorname", STRING, NULL, "name of the anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_anchor",
        MODULE_OBJECT,
        "Retrieve an anchor from a cell. This function returns a point that contains the position of the specified anchor, corrected by the cell transformation. Retrieving non-existing anchor raises an error.",
        "cell:get_anchor(\"sourcedrain1bl\")",
        parameters
    ));
}

/* object.get_area_anchor */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "object to get an anchor from" },
        { "anchorname", STRING, NULL, "name of the anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_area_anchor",
        MODULE_OBJECT,
        "Retrieve an area anchor from a cell. This function returns a table with four points (bl (bottom-left), tr (top-right), br (bottom-right) and tl (top-left)) that contain the position of the specified area anchor, corrected by the cell transformation. Furthermore, the individual coordinates are also available as skalar values with the keys 'b', 't', 'l' and 'r'. Retrieving a non-existing anchor raises an error.",
        "cell:get_area_anchor(\"sourcedrain1\").bl\npoint.create(cell1:get_area_anchor(\"sourcedrain1\").l, cell2:get_area_anchor(\"topgatestrap\").t)",
        parameters
    ));
}

/* object.get_area_anchor_fmt */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "object to get an anchor from" },
        { "anchorname", STRING, NULL, "name of the anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_area_anchor_fmt",
        MODULE_OBJECT,
        "Like object.get_array_anchor, but call string.format on the input arguments",
        "cell:get_area_anchor_fmt(\"sourcedrain%d\", 1)",
        parameters
    ));
}

/* object.get_area_anchor_height */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "object to get an anchor from" },
        { "anchorname", STRING, NULL, "name of the anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_area_anchor_height",
        MODULE_OBJECT,
        "Retrieve the height (an integer) of an area anchor from a cell. A non-existing anchor is an error",
        "local height = cell:get_area_anchor_height(\"sourcedrain1\")",
        parameters
    ));
}

/* object.get_area_anchor_width */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "object to get an anchor from" },
        { "anchorname", STRING, NULL, "name of the anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_area_anchor_width",
        MODULE_OBJECT,
        "Retrieve the width (an integer) of an area anchor from a cell. A non-existing anchor is an error",
        "local width = cell:get_area_anchor_width(\"sourcedrain1\")",
        parameters
    ));
}

/* object.get_array_anchor */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,  NULL, "object to get an anchor from" },
        { "xindex",     INTEGER, NULL, "x-index" },
        { "yindex",     INTEGER, NULL, "y-index" },
        { "anchorname", STRING,  NULL, "name of the anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_array_anchor",
        MODULE_OBJECT,
        "Like object.get_anchor, but works on child arrays. The first two argument are the x- and the y-index (starting at 1, 1). Accessing an array anchor of a non-array object is an error",
        "local ref = object.create(\"ref\")\nlocal array = cell:add_child_array(ref, \"refarray\", 20, 2, 100, 1000)\nlocal anchor = array:get_array_anchor(4, 1, \"sourcedrain1bl\")",
        parameters
    ));
}

/* object.get_array_area_anchor */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,  NULL, "object to get an anchor from" },
        { "xindex",     INTEGER, NULL, "x-index" },
        { "yindex",     INTEGER, NULL, "y-index" },
        { "anchorname", STRING,  NULL, "name of the anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_array_area_anchor",
        MODULE_OBJECT,
        "Like object.get_area_anchor, but works on child arrays. The first two argument are the x- and the y-index (starting at 1, 1). Accessing an array anchor of a non-array object is an error",
        "local ref = object.create(\"ref\")\nlocal array = cell:add_child_array(ref, \"refarray\", 20, 2, 100, 1000)\nlocal anchor = array:get_array_area_anchor(4, 1, \"sourcedrain1bl\")",
        parameters
    ));
}

/* object.get_boundary */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,  NULL, "object to get the boundary from" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_boundary",
        MODULE_OBJECT,
        "Retrieve the boundary of an object. If no explicit boundary exists, it is calculated from the extrem coordinates of all shapes (bounding box). The boundary is returned as a table containing the points. A boundary is not necessarily rectangular, but automatically-calculated boundaries are",
        "local boundary = cell:get_boundary()",
        parameters
    ));
}

/* object.get_layer_boundary */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "object to get the boundary from" },
        { "layer",  GENERICS,   NULL, "layer" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_layer_boundary",
        MODULE_OBJECT,
        "Retrieve the layer boundary of an object. If the cell has no layer boundaries at all, an empty table is returned. Otherwise, if the layer boundary for the specified layer does not exist, the bounding box of the cell is returned. If the layer boundary exists, it is returned. For this case, object.set_empty_layer_boundary() is useful.",
        "local layerboundary = cell:get_layer_boundary(generics.metal(1))",
        parameters
    ));
}

/* object.get_shape_outlines */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "object to get the shape outlines from" },
        { "layer",  GENERICS,   NULL, "layer" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_shape_outlines",
        MODULE_OBJECT,
        "return a table which contains polygon outlines of all shapes on a given layer. Useful for instance for automatic filling",
        "local outlines = cell:get_shape_outlines()",
        parameters
    ));
}

/* object.add_net_shape */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL, "object to get the shape outlines from" },
        { "netname",    STRING,     NULL, "net name of added shape" },
        { "bl",         POINT,      NULL, "bottom-left point of the rectangular area" },
        { "tr",         POINT,      NULL, "top-right point of the rectangular area" },
        { "layer",      GENERICS,   NULL, "layer of the given net shape" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "add_net_shape",
        MODULE_OBJECT,
        "mark a rectangular area in a cell with a certain net. This can be used for automatic via placement from power grids, for instance.",
        "cell:add_net_shape(\"vdd\", cell:get_area_anchor(\"sourcestrap\").bl, cell:get_area_anchor(\"sourcestra\").tr, generics.metal(2))",
        parameters
    ));
}

/* object.mark_area_anchor_as_net */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL, "object to get the shape outlines from" },
        { "anchor",     STRING,     NULL, "identifier of an area anchor" },
        { "netname",    STRING,     NULL, "net name of added shape" },
        { "layer",      GENERICS,   NULL, "layer of the given net shape" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "mark_area_anchor_as_net",
        MODULE_OBJECT,
        "mark an area anchor in a cell with a certain net. This can be used for automatic via placement from power grids, for instance. This function is similar to add_net_shape, but simpler (and less flexible) to use.",
        "cell:mark_area_anchor_as_net(\"sourcestrap\", \"vdd\", generics.metal(2))",
        parameters
    ));
}

/* object.get_net_shapes */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL, "object to get the shape outlines from" },
        { "netname",    STRING,     NULL, "net name of added shape" },
        { "layer",      GENERICS,   NULL, "optional layer filter" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_net_shapes",
        MODULE_OBJECT,
        "return a table which contains rectangular netshape entries of all shapes on a given net. Useful for instance for automatic placement of via from a power grid. The structure of the table entries in the results table are: { net = <netname>, bl = <bl>, tr = <tr> }. If the 'layer' parameter is non-nil, only shapes on the given layer are returned.",
        "cell:get_net_shapes(\"vdd\")\ncell:get_net_shapes(\"vss\", generics.metal(4))",
        parameters
    ));
}

/* object.get_ports */
{
    struct parameter parameters[] = {
        { "cell", OBJECT, NULL, "object to get the ports from" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_ports",
        MODULE_OBJECT,
        "return a table which contains key-value pairs with all ports of a cell. The key is the portname, the value the corresponding point.",
        "local ports = cell:get_ports()",
        parameters
    ));
}

/* object.has_boundary */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "cell to add the alignment box to" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "has_boundary",
        MODULE_OBJECT,
        "check if the object has a boundary",
        "cell:has_boundary()",
        parameters
    ));
}

/* object.has_layer_boundary */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "cell to add the alignment box to" },
        { "layer",      GENERICS,   NULL, "layer for the layer boundary" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "has_layer_boundary",
        MODULE_OBJECT,
        "check if the object has a layer boundary for the specified layer",
        "cell:has_layer_boundary(generics.metal(1))",
        parameters
    ));
}

/* object.inherit_alignment_box */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "cell to add the alignment box to" },
        { "othercell",  OBJECT, NULL, "cell to inherit the alignment box from" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "inherit_alignment_box",
        MODULE_OBJECT,
        "inherit the alignment box from another cell. This EXPANDS the current alignment box, if any is present. This means that this function can be called multiple times with different objects to establish an overall alignment box",
        "cell:inherit_alignment_box(someothercell)\ncell:inherit_alignment_box(anothercell)",
        parameters
    ));
}

/* object.inherit_all_anchors_with_prefix */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "cell to add the anchor to" },
        { "othercell",  OBJECT, NULL, "cell to inherit the anchor from" },
        { "prefix",     STRING, NULL, "prefix of all inherited anchors" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "inherit_all_anchors_with_prefix",
        MODULE_OBJECT,
        "inherit all anchors from another cell with an attached prefix.",
        "cell:inherit_all_anchors_with_prefix(someothercell, \"othercell_\")",
        parameters
    ));
}

/* object.inherit_anchor_as */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "cell to add the anchor to" },
        { "othercell",  OBJECT, NULL, "cell to inherit the anchor from" },
        { "anchorname", STRING, NULL, "anchor name of the to-be-inherited anchor" },
        { "newname",    STRING, NULL, "new name of the inherited anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "inherit_anchor_as",
        MODULE_OBJECT,
        "inherit an anchor from another cell under a different name.",
        "cell:inherit_anchor(someothercell, \"anchor\", \"newname\")",
        parameters
    ));
}

/* object.inherit_anchor */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "cell to add the anchor to" },
        { "othercell",  OBJECT, NULL, "cell to inherit the anchor from" },
        { "anchorname", STRING, NULL, "anchor name of the to-be-inherited anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "inherit_anchor",
        MODULE_OBJECT,
        "inherit an anchor from another cell.",
        "cell:inherit_anchor(someothercell, \"anchor\")",
        parameters
    ));
}

/* object.inherit_area_anchor_as */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "cell to add the anchor to" },
        { "othercell",  OBJECT, NULL, "cell to inherit the anchor from" },
        { "anchorname", STRING, NULL, "anchor name of the to-be-inherited anchor" },
        { "newname",    STRING, NULL, "new name of the inherited anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "inherit_area_anchor_as",
        MODULE_OBJECT,
        "inherit an area anchor from another cell under a different name.",
        "cell:inherit_area_anchor(someothercell, \"anchor\", \"newname\")",
        parameters
    ));
}

/* object.inherit_area_anchor */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "cell to add the anchor to" },
        { "othercell",  OBJECT, NULL, "cell to inherit the anchor from" },
        { "anchorname", STRING, NULL, "anchor name of the to-be-inherited anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "inherit_area_anchor",
        MODULE_OBJECT,
        "inherit an area anchor from another cell.",
        "cell:inherit_area_anchor(someothercell, \"anchor\")",
        parameters
    ));
}

/* object.inherit_all_anchors */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "cell to add the anchor to" },
        { "othercell",  OBJECT, NULL, "cell to inherit the anchor from" },
        { "anchorname", STRING, NULL, "anchor name of the to-be-inherited anchor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "inherit_all_anchors",
        MODULE_OBJECT,
        "inherit all anchors (regular and area) from another cell.",
        "cell:inherit_all_anchors(someothercell)",
        parameters
    ));
}

/* object.inherit_boundary */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "cell to add the boundary to" },
        { "othercell",  OBJECT, NULL, "cell to inherit the boundary from" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "inherit_boundary",
        MODULE_OBJECT,
        "inherit the boundary from another cell.",
        "cell:inherit_boundary(someothercell)",
        parameters
    ));
}

/* object.inherit_layer_boundary */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL, "cell to add the boundary to" },
        { "othercell",  OBJECT,     NULL, "cell to inherit the boundary from" },
        { "layer",      GENERICS,   NULL, "layer" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "inherit_layer_boundary",
        MODULE_OBJECT,
        "inherit all layer boundaries from another cell for the given layer.",
        "cell:inherit_layer_boundary(someothercell, generics.metal(1))",
        parameters
    ));
}

/* object.merge_into */
{
    struct parameter parameters[] = {
        { "cell",      OBJECT, NULL, "Object to which the child is added" },
        { "othercell", OBJECT, NULL, "Other layout cell to be merged into the cell" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "merge_into",
        MODULE_OBJECT,
        "add all shapes and children from othercell to the cell -> 'dissolve' othercell in cell",
        "cell:merge_into(othercell)\ncell:merge_into(othercell:flatten())",
        parameters
    ));
}

/* object.merge_into_with_ports */
{
    struct parameter parameters[] = {
        { "cell",      OBJECT, NULL, "Object to which the child is added" },
        { "othercell", OBJECT, NULL, "Other layout cell to be merged into the cell" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "merge_into_with_ports",
        MODULE_OBJECT,
        "add all shapes, children and ports from othercell to the cell -> 'dissolve' othercell in cell",
        "cell:merge_into_with_ports(othercell)",
        parameters
    ));
}

/* object.mirror_at_origin */
{
    struct parameter parameters[] = {
        { "cell",      OBJECT, NULL, "Cell to be mirrored" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "mirror_at_origin",
        MODULE_OBJECT,
        "mirror the entire object at the origin",
        "cell:mirror_at_origin()",
        parameters
    ));
}

/* object.mirror_at_xaxis */
{
    struct parameter parameters[] = {
        { "cell",      OBJECT, NULL, "Cell to be mirrored" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "mirror_at_xaxis",
        MODULE_OBJECT,
        "mirror the entire object at the x axis",
        "cell:mirror_at_xaxis()",
        parameters
    ));
}

/* object.mirror_at_yaxis */
{
    struct parameter parameters[] = {
        { "cell",      OBJECT, NULL, "Cell to be mirrored" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "mirror_at_yaxis",
        MODULE_OBJECT,
        "mirror the entire object at the y axis",
        "cell:mirror_at_yaxis()",
        parameters
    ));
}

/* object.move_point */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL,   "cell which should be moved" },
        { "source",     POINT,  NULL,   "source point" },
        { "target",     POINT,  NULL,   "target point" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "move_point",
        MODULE_OBJECT,
        "translate (move) the object so that the source point lies on the target. Usually the source point is an anchor of the object, but that is not a necessity. The points are just references for the delta vector and can be any points.",
        "cell:move_point(cell:get_area_anchor(\"gate\").bl, point.create(0, 0)) -- move to origin\nmosfet:move_point(mosfet:get_area_anchor(\"leftsourcedrain\").bl, othermosfet:get_area_anchor(\"rightsourcedrain\").bl) -- align two mosfets",
        parameters
    ));
}

/* object.move_point_x */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL,   "cell which should be moved" },
        { "source",     POINT,  NULL,   "source point" },
        { "target",     POINT,  NULL,   "target point" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "move_point_x",
        MODULE_OBJECT,
        "translate (move) the object so that the x-coorindate of the source point lies on the x-coordinate target. Usually the source point is an anchor of the object, but that is not a necessity. The points are just references for the delta vector and can be any points.",
        "cell:move_point_x(cell:get_area_anchor(\"gate\").bl, point.create(0, 0)) -- move the x-coordinate of the origin\nmosfet:move_point_x(mosfet:get_area_anchor(\"leftsourcedrain\").bl, othermosfet:get_area_anchor(\"rightsourcedrain\").bl) -- align the x-coordinate of two mosfets",
        parameters
    ));
}

/* object.move_point_y */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL,   "cell which should be moved" },
        { "source",     POINT,  NULL,   "source point" },
        { "target",     POINT,  NULL,   "target point" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "move_point_y",
        MODULE_OBJECT,
        "translate (move) the object so that the y-coorindate of the source point lies on the y-coordinate target. Usually the source point is an anchor of the object)",
        "cell:move_point_y(cell:get_area_anchor(\"gate\").bl, point.create(0, 0)) -- move the y-coordinate of the origin\nmosfet:move_point_y(mosfet:get_area_anchor(\"leftsourcedrain\").bl, othermosfet:get_area_anchor(\"rightsourcedrain\").bl) -- align the y-coordinate of two mosfets",
        parameters
    ));
}

/* object.add_child */
{
    struct parameter parameters[] = {
        { "cell",      OBJECT, NULL, "Object to which the child is added" },
        { "child",     OBJECT, NULL, "Child to add" },
        { "instname",  STRING, NULL,   "Instance name (not used by all exports)" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "add_child",
        MODULE_OBJECT,
        "Add a child object (instance) to the given cell. This make 'cell' the parent of the child (it manages its memory). This means that you should not use the original child object any more after this call (unless it is object.add_child or object.add_child_array)",
        "local ref = pcell.create_layout(\"basic/mosfet\", \"mosfet\")\ncell:add_child(ref, \"mosinst0\")",
        parameters
    ));
}

/* object.move_to */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "cell to be moved" },
        { "x",      INTEGER,    NULL, "x coordinate (can be a point, in this case x and y are taken from this point)" },
        { "y",      INTEGER,    NULL, "y coordinate" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "move_to",
        MODULE_OBJECT,
        "move the cell to the specified coordinates (absolute movement). If x is a point, x and y are taken from this point",
        "cell:move_to(100, 200)",
        parameters
    ));
}

/* object.move_x */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL, "cell to be moved" },
        { "xsource",    INTEGER,    NULL, "x source coordinate" },
        { "xtarget",    INTEGER,    NULL, "x target coordinate" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "move_x",
        MODULE_OBJECT,
        "move the cell so that the given x-coordinates are equal (move the difference between these coordinates)",
        "cell:move_x(cell:get_area_anchor(\"someanchor\").l, 0)",
        parameters
    ));
}

/* object.move_y */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL, "cell to be moved" },
        { "ysource",    INTEGER,    NULL, "y source coordinate" },
        { "ytarget",    INTEGER,    NULL, "y target coordinate" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "move_y",
        MODULE_OBJECT,
        "move the cell so that the given y-coordinates are equal (move the difference between these coordinates)",
        "cell:move_y(cell:get_area_anchor(\"someanchor\").l, 0)",
        parameters
    ));
}

/* object.rasterize_curves */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "cell to be moved" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "rasterize_curves",
        MODULE_OBJECT,
        "rasterize all curves in the object. This is usually not needed, as this happens during the cell export, if required. This function is useful if this should be done regardless of the export capabilities, but then there also is the geometry function geomtry.curve_rasterized",
        "cell:rasterize_curves()",
        parameters
    ));
}

/* object.reset_translation */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "cell to be resetted" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "reset_translation",
        MODULE_OBJECT,
        "reset all previous translations (transformations are kept)",
        "cell:reset_translation()",
        parameters
    ));
}

/* object.rotate_90_left */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "cell to be rotated" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "rotate_90_left",
        MODULE_OBJECT,
        "rotate the entire object 90 degrees counter-clockwise with respect to the origin",
        "cell:rotate_90_left()",
        parameters
    ));
}

/* object.rotate_90_right */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "cell to be rotated" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "rotate_90_right",
        MODULE_OBJECT,
        "rotate the entire object 90 degrees clockwise with respect to the origin",
        "cell:rotate_90_right()",
        parameters
    ));
}

/* object.array_rotate_90_left*/
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "cell to be rotated" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "array_rotate_90_left",
        MODULE_OBJECT,
        "rotate the entire object array 90 degrees counter-clockwise with respect to the origin",
        "cell:array_rotate_90_left()",
        parameters
    ));
}

/* object.array_rotate_90_right */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "cell to be rotated" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "rotate_90_right",
        MODULE_OBJECT,
        "rotate the entire object array 90 degrees clockwise with respect to the origin",
        "cell:array_rotate_90_right()",
        parameters
    ));
}

/* object.set_alignment_box */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "cell to add the alignment box to" },
        { "outerbl",    POINT,  NULL, "outer bottom-left corner of alignment box" },
        { "outertr",    POINT,  NULL, "outer top-right corner of alignment box" },
        { "innerbl",    POINT,  NULL, "inner bottom-left corner of alignment box (optional)" },
        { "innertr",    POINT,  NULL, "inner top-right corner of alignment box (optional)" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "set_alignment_box",
        MODULE_OBJECT,
        "set the alignment box of an object. Overwrites any previous existing alignment boxes. This function can either be called with three or five arguments. In the first case the alignment box is determined by only two corner points. With four corner points, a more sophisticated alignment box is established, which allows the alignment of cells with odd dimensions. Often this is not needed. The more advanced library cells use this mode, but 2 points suffice in many cases.",
        "cell:set_alignment_box(point.create(-100, -100), point.create(100, 100))",
        parameters
    ));
}

/* object.set_boundary_rectangular */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "cell to add the boundary to" },
        { "pts",    POINTLIST,  NULL, "polygon boundary" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "set_boundary_rectangular",
        MODULE_OBJECT,
        "set the cell boundary (rectangular)",
        "cell:set_boundary_rectangular(point.create(-100, -100), point.create(100, 100))",
        parameters
    ));
}


/* object.set_boundary */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "cell to add the boundary to" },
        { "pts",    POINTLIST,  NULL, "polygon boundary" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "set_boundary",
        MODULE_OBJECT,
        "set the cell boundary (polygon)",
        "cell:set_boundary({ point.create(-100, -100), point.create(100, -100), point.create(100, 100), point.create(-100, 100) })",
        parameters
    ));
}

/* object.set_empty_layer_boundary */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL, "object to which the layer boundary should be added" },
        { "layer",      GENERICS,   NULL, "layer for the layer boundary" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "set_empty_layer_boundary",
        MODULE_OBJECT,
        "Set the layer boundary of this object for the specified layer to empty. A layer boundary is useful for automatic filling, an empty layer boundary indicates that filling can take place everywhere. This function is required if fill is to be placed within the regular boundary of the object, because the regular boundary is used as layer boundary if the latter is not present.",
        "cell:set_empty_layer_boundary(generics.metal(1))",
        parameters
    ));
}

/* object.translate */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "cell to be translated" },
        { "x",      INTEGER,    NULL, "x offset (can be a point, in this case x and y are taken from this point)" },
        { "y",      INTEGER,    NULL, "y offset" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "translate",
        MODULE_OBJECT,
        "translate the cell by the specified offsets (relative movement). If x is a point, x and y are taken from this point",
        "cell:translate(100, 200)",
        parameters
    ));
}

/* object.translate_x */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "cell to be translated" },
        { "x",      INTEGER,    NULL, "x offset" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "translate_x",
        MODULE_OBJECT,
        "translate the cell by the specified x offset (relative movement).",
        "cell:translate_x(100)",
        parameters
    ));
}

/* object.translate_y */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "cell to be translated" },
        { "y",      INTEGER,    NULL, "y offset" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "translate_y",
        MODULE_OBJECT,
        "translate the cell by the specified y offset (relative movement).",
        "cell:translate_y(100)",
        parameters
    ));
}

/* object.width_height_alignmentbox */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "cell to compute width and height" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "width_height_alignmentbox",
        MODULE_OBJECT,
        "get the width and the height of the alignment box. A non-existing alignment box triggers an error",
        "local width, height = cell:width_height_alignmentbox()",
        parameters
    ));
}

/* object.get_name */
{
    struct parameter parameters[] = {
        { "cell", OBJECT, NULL, "cell" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_name",
        MODULE_OBJECT,
        "return the name of the given object",
        "local name = cell:get_name()",
        parameters
    ));
}

/* object.set_name */
{
    struct parameter parameters[] = {
        { "cell", OBJECT, NULL, "cell" },
        { "name", STRING, NULL, "new name" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "set_name",
        MODULE_OBJECT,
        "set the name of the given object",
        "cell:set_name(\"newname\")",
        parameters
    ));
}

/* object.is_object */
{
    struct parameter parameters[] = {
        { "cell", ANY, NULL, "parameter to be type-checked" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "is_object",
        MODULE_OBJECT,
        "check that a given parameter is an object (with the metatable forn objects). Useful for overloaded functions",
        "if object.is_object(cell) then\n    -- actions for object\nelse    -- actions for other types\nend",
        parameters
    ));
}

/* object.has_layer */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "cell" },
        { "layer",  GENERICS,   NULL, "layer" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "has_layer",
        MODULE_OBJECT,
        "check whether an object contains a given layer. This function is recursive and checks all hierarchy levels of the cell",
        "if cell:has_layer(generics.metal(1)) then ...",
        parameters
    ));
}

