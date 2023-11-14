/* object.create */
{
    struct parameter parameters[] = {
        { "cellname", STRING, NULL, "the name of the layout cell" }
    };
    vector_append(entries, _make_api_entry(
        "create",
        MODULE_OBJECT,
        "create a new object. A name must be given. Hierarchical exports use this name to identify layout cells and no checks for duplication are done. Therefore the user must make sure that every name is unique. Note that this will probably change in the future",
        "local cell = object.create(\"toplevel\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.copy */
{
    struct parameter parameters[] = {
        { "cell", OBJECT, NULL, "Object to copy" }
    };
    vector_append(entries, _make_api_entry(
        "copy",
        MODULE_OBJECT,
        "copy an object",
        "local new = cell:copy()",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.exchange */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "Object which should take over the other object" },
        { "othercell",  OBJECT, NULL, "Object which should be taken over. The object handle must not be used after this operation" }
    };
    vector_append(entries, _make_api_entry(
        "exchange",
        MODULE_OBJECT,
        "Take over internal state of the other object, effectively making this the main cell. The object handle to 'othercell' must not be used afterwards as this object is destroyed. This function is only really useful in cells that act as a parameter wrapper for other cells (e.g. dffpq -> dff)",
        "cell:exchange(othercell)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.add_anchor */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT, NULL, "object to which an anchor should be added" },
        { "name",   STRING, NULL, "name of the anchor" },
        { "where",  POINT,  NULL, "location of the anchor" }
    };
    vector_append(entries, _make_api_entry(
        "add_anchor",
        MODULE_OBJECT,
        "add an anchor to an object",
        "cell:add_anchor(\"output\", point.create(200, -20))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.add_area_anchor_bltr */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,  NULL, "object to which an anchor should be added" },
        { "name",   STRING,  NULL, "name of the anchor" },
        { "bl",     POINT,   NULL, "bottom-left point of the rectangular area" },
        { "tr",     POINT,   NULL, "bottom-left point of the rectangular area" }

    };
    vector_append(entries, _make_api_entry(
        "add_area_anchor_bltr",
        MODULE_OBJECT,
        "Similar to add_area_anchor, but takes to lower-left and upper-right corner points of the rectangular area",
        "cell:add_area_anchor(\"source\", point.create(-100, -20), point.create(100, 20))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.get_anchor */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "object to get an anchor from" },
        { "anchorname", STRING, NULL, "name of the anchor" }
    };
    vector_append(entries, _make_api_entry(
        "get_anchor",
        MODULE_OBJECT,
        "Retrieve an anchor from a cell. This function returns a point that contains the position of the specified anchor, corrected by the cell transformation. Retrieving non-existing anchor raises an error.",
        "cell:get_anchor(\"sourcedrain1bl\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.get_alignment_anchor */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "object to get an anchor from" },
        { "anchorname", STRING, NULL, "name of the alignment anchor" }
    };
    vector_append(entries, _make_api_entry(
        "get_alignment_anchor",
        MODULE_OBJECT,
        "Retrieve an alignment anchor from a cell. These anchors are the defining points of the alignment box. Valid anchor names are 'outerbl', 'outerbr', 'outertl', 'outertr', 'innerbl', 'innerbr', 'innertl' and 'innertr'. This function returns a point that contains the position of the specified anchor, corrected by the cell transformation. A non-existing anchor is an error",
        "cell:get_alignment_anchor(\"outerbl\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.get_area_anchor */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "object to get an anchor from" },
        { "anchorname", STRING, NULL, "name of the anchor" }
    };
    vector_append(entries, _make_api_entry(
        "get_area_anchor",
        MODULE_OBJECT,
        "Retrieve an area anchor from a cell. This function returns a table containing two points (bl (bottom-left) and tr (top-right)) that contain the position of the specified area anchor, corrected by the cell transformation. A non-existing anchor is an error",
        "cell:get_area_anchor(\"sourcedrain1\").bl",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.get_array_anchor */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,  NULL, "object to get an anchor from" },
        { "xindex",     INTEGER, NULL, "x-index" },
        { "yindex",     INTEGER, NULL, "y-index" },
        { "anchorname", STRING,  NULL, "name of the anchor" }
    };
    vector_append(entries, _make_api_entry(
        "get_array_anchor",
        MODULE_OBJECT,
        "Like object.get_anchor, but works on child arrays. The first two argument are the x- and the y-index (starting at 1, 1). Accessing an array anchor of a non-array object is an error",
        "local ref = object.create(\"ref\")\nlocal array = cell:add_child_array(ref, \"refarray\", 20, 2, 100, 1000)\nlocal anchor = array:get_array_anchor(4, 1, \"sourcedrain1bl\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.get_array_area_anchor */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,  NULL, "object to get an anchor from" },
        { "xindex",     INTEGER, NULL, "x-index" },
        { "yindex",     INTEGER, NULL, "y-index" },
        { "anchorname", STRING,  NULL, "name of the anchor" }
    };
    vector_append(entries, _make_api_entry(
        "get_array_area_anchor",
        MODULE_OBJECT,
        "Like object.get_area_anchor, but works on child arrays. The first two argument are the x- and the y-index (starting at 1, 1). Accessing an array anchor of a non-array object is an error",
        "local ref = object.create(\"ref\")\nlocal array = cell:add_child_array(ref, \"refarray\", 20, 2, 100, 1000)\nlocal anchor = array:get_array_area_anchor(4, 1, \"sourcedrain1bl\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.add_port */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,   NULL, "object to which a port should be added" },
        { "name",   STRING,   NULL, "name of the port" },
        { "layer",  GENERICS, NULL, "layer of the port" },
        { "where",  POINT,    NULL, "location of the port" }
    };
    vector_append(entries, _make_api_entry(
        "add_port",
        MODULE_OBJECT,
        "add a port to a cell. Works like add_anchor, but additionally a layer is expected",
        "cell:add_port(\"vdd\", generics.metalport(2), point.create(100, 0))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.add_port_with_anchor */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,   NULL, "object to which a port should be added" },
        { "name",   STRING,   NULL, "name of the port" },
        { "layer",  GENERICS, NULL, "layer of the port" },
        { "where",  POINT,    NULL, "location of the port" }
    };
    vector_append(entries, _make_api_entry(
        "add_port_with_anchor",
        MODULE_OBJECT,
        "add a port to a cell. Works like add_anchor, but additionally a layer is expected. This function also adds an anchor to the cell (named like the port)",
        "cell:add_port_with_anchor(\"vdd\", generics.metalport(2), point.create(100, 0))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
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
        { "ypitch",     INTEGER,    NULL, "pitch in y direction" }
    };
    vector_append(entries, _make_api_entry(
        "add_bus_port",
        MODULE_OBJECT,
        "add a bus port (multiple ports like vout[0:4]) to a cell. The port expression is portname[startindex:endindex] and portname[i] is placed at 'where' with an offset of ((i - 1) * xpitch, (i - 1) * ypitch)",
        "cell:add_bus_port(\"vout\", generics.metalport(4), point.create(200, 0), 0, 4, 200, 0)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.get_ports */
{
    struct parameter parameters[] = {
        { "cell", OBJECT, NULL, "object to get the ports from" }
    };
    vector_append(entries, _make_api_entry(
        "get_ports",
        MODULE_OBJECT,
        "return a table which contains key-value pairs with all ports of a cell. The key is the portname, the value the corresponding point.",
        "local ports = cell:get_ports()",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.set_alignment_box */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT, NULL, "cell to add the alignment box to" },
        { "bl",     POINT,  NULL, "bottom-left corner of alignment box" },
        { "tr",     POINT,  NULL, "top-right corner of alignment box" }
    };
    vector_append(entries, _make_api_entry(
        "set_alignment_box",
        MODULE_OBJECT,
        "set the alignment box of an object. Overwrites any previous existing alignment boxes",
        "cell:set_alignment_box(point.create(-100, -100), point.create(100, 100))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.inherit_alignment_box */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "cell to add the alignment box to" },
        { "othercell",  OBJECT, NULL, "cell to inherit the alignment box from" }
    };
    vector_append(entries, _make_api_entry(
        "inherit_alignment_box",
        MODULE_OBJECT,
        "inherit the alignment box from another cell. This EXPANDS the current alignment box, if any is present. This means that this function can be called multiple times with different objects to establish an overall alignment box",
        "cell:inherit_alignment_box(someothercell)\ncell:inherit_alignment_box(anothercell)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.alignment_box_include_point */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT, NULL, "cell to extend the alignment box of" },
        { "pt",     POINT,  NULL, "point to be included in the alignment box of the cell" }
    };
    vector_append(entries, _make_api_entry(
        "alignment_box_include_point",
        MODULE_OBJECT,
        "extend the alignment box of a cell in a way that the given point is included in it. The alignment box is never shrunken, only enlarged.",
        "cell:alignment_box_include_point(point.create(200, 200))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.alignment_box_include_x */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT, NULL, "cell to extend the alignment box of" },
        { "pt",     POINT,  NULL, "point to be included in the alignment box of the cell" }
    };
    vector_append(entries, _make_api_entry(
        "alignment_box_include_x",
        MODULE_OBJECT,
        "like alignment_box_include_point, but only change the x-coordinates of the alignment box. The y-coordinate is ignored, the second argument is a point only for convenience.",
        "cell:alignment_box_include_x(point.create(200, 200))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.alignment_box_include_y */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT, NULL, "cell to extend the alignment box of" },
        { "pt",     POINT,  NULL, "point to be included in the alignment box of the cell" }
    };
    vector_append(entries, _make_api_entry(
        "alignment_box_include_y",
        MODULE_OBJECT,
        "like alignment_box_include_point, but only change the y-coordinates of the alignment box. The x-coordinate is ignored, the second argument is a point only for convenience.",
        "cell:alignment_box_include_y(point.create(200, 200))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.clear_alignment_box */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT, NULL, "cell to clear the alignment box of" }
    };
    vector_append(entries, _make_api_entry(
        "clear_alignment_box",
        MODULE_OBJECT,
        "clear (remove) the alignment box of a cell. Useful to set a new alignment box with object.set_alignment_box(...)",
        "cell:clear_alignment_box()",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.inherit_area_anchor */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "cell to add the anchor to" },
        { "othercell",  OBJECT, NULL, "cell to inherit the anchor from" },
        { "anchorname", STRING, NULL, "anchor name of the to-be-inherited anchor" }
    };
    vector_append(entries, _make_api_entry(
        "inherit_area_anchor",
        MODULE_OBJECT,
        "inherit an area anchor from another cell.",
        "cell:inherit_area_anchor(someothercell, \"anchor\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.inherit_area_anchor_as */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "cell to add the anchor to" },
        { "othercell",  OBJECT, NULL, "cell to inherit the anchor from" },
        { "anchorname", STRING, NULL, "anchor name of the to-be-inherited anchor" },
        { "newname",    STRING, NULL, "new name of the inherited anchor" }
    };
    vector_append(entries, _make_api_entry(
        "inherit_area_anchor_as",
        MODULE_OBJECT,
        "inherit an area anchor from another cell under a different name.",
        "cell:inherit_area_anchor(someothercell, \"anchor\", \"newname\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.set_boundary */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "cell to add the boundary to" },
        { "pts",    POINTLIST,  NULL, "polygon boundary" }
    };
    vector_append(entries, _make_api_entry(
        "set_boundary",
        MODULE_OBJECT,
        "set the cell boundary (polygon)",
        "cell:set_boundary({ point.create(-100, -100), point.create(100, -100), point.create(100, 100), point.create(-100, 100) })",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.set_boundary_rectangular */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "cell to add the boundary to" },
        { "pts",    POINTLIST,  NULL, "polygon boundary" }
    };
    vector_append(entries, _make_api_entry(
        "set_boundary_rectangular",
        MODULE_OBJECT,
        "set the cell boundary (rectangular)",
        "cell:set_boundary_rectangular(point.create(-100, -100), point.create(100, 100))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.inherit_boundary */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "cell to add the boundary to" },
        { "othercell",  OBJECT, NULL, "cell to inherit the boundary from" }
    };
    vector_append(entries, _make_api_entry(
        "inherit_boundary",
        MODULE_OBJECT,
        "inherit the boundary from another cell.",
        "cell:inherit_boundary(someothercell)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
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
        { "extinnertry",    INTEGER,    NULL,   "extension of inner-top coordinate" }
    };
    vector_append(entries, _make_api_entry(
        "extend_alignment_box",
        MODULE_OBJECT,
        "extend an existing object alignment box. Takes eight values for the extension of the four corner points making up the alignment box",
        "cell:extend_alignment_box(-100, -100, 100, 100, 0, 0, 0, 0)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.extend_alignment_box_x_symmetrical */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL,   "cell to add the alignment box to" },
        { "extx",   INTEGER,    NULL,   "x-extension" }
    };
    vector_append(entries, _make_api_entry(
        "extend_alignment_box_x_symmetrical",
        MODULE_OBJECT,
        "extend an existing object alignment box. Takes only one value for the extension of the four corner points and extends all x-coordinates of the box symmetrically in the left/right direction",
        "cell:extend_alignment_box_x_symmetrical(200)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.extend_alignment_box_y_symmetrical */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL,   "cell to add the alignment box to" },
        { "exty",   INTEGER,    NULL,   "y-extension" }
    };
    vector_append(entries, _make_api_entry(
        "extend_alignment_box_y_symmetrical",
        MODULE_OBJECT,
        "extend an existing object alignment box. Takes only one value for the extension of the four corner points and extends all y-coordinates of the box symmetrically in the left/right direction",
        "cell:extend_alignment_box_y_symmetrical(200)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.extend_alignment_box_xy_symmetrical */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL,   "cell to add the alignment box to" },
        { "extx",   INTEGER,    NULL,   "x-extension" },
        { "exty",   INTEGER,    NULL,   "y-extension" }
    };
    vector_append(entries, _make_api_entry(
        "extend_alignment_box_xy_symmetrical",
        MODULE_OBJECT,
        "extend an existing object alignment box. Takes two values for the extension of the four corner points and extends all x- and y-coordinates of the box symmetrically in the left/right direction. This function is the same as calling the individual alignment box extension functions for x- and y-directions individually",
        "cell:extend_alignment_box_xy_symmetrical(200, 300)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.width_height_alignmentbox */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "cell to compute width and height" }
    };
    vector_append(entries, _make_api_entry(
        "width_height_alignmentbox",
        MODULE_OBJECT,
        "get the width and the height of the alignment box. A non-existing alignment box triggers an error",
        "local width, height = cell:width_height_alignmentbox()",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.move_to */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "cell to be moved" },
        { "x",      INTEGER,    NULL, "x coordinate (can be a point, in this case x and y are taken from this point)" },
        { "y",      INTEGER,    NULL, "y coordinate" }
    };
    vector_append(entries, _make_api_entry(
        "move_to",
        MODULE_OBJECT,
        "move the cell to the specified coordinates (absolute movement). If x is a point, x and y are taken from this point",
        "cell:move_to(100, 200)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.reset_translation */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "cell to be resetted" },
    };
    vector_append(entries, _make_api_entry(
        "reset_translation",
        MODULE_OBJECT,
        "reset all previous translations (transformations are kept)",
        "cell:reset_translation()",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.translate */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "cell to be translated" },
        { "x",      INTEGER,    NULL, "x offset (can be a point, in this case x and y are taken from this point)" },
        { "y",      INTEGER,    NULL, "y offset" }
    };
    vector_append(entries, _make_api_entry(
        "translate",
        MODULE_OBJECT,
        "translate the cell by the specified offsets (relative movement). If x is a point, x and y are taken from this point",
        "cell:translate(100, 200)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.translate_x */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "cell to be translated" },
        { "x",      INTEGER,    NULL, "x offset" }
    };
    vector_append(entries, _make_api_entry(
        "translate_x",
        MODULE_OBJECT,
        "translate the cell by the specified x offset (relative movement).",
        "cell:translate_x(100)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.translate_y */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "cell to be translated" },
        { "y",      INTEGER,    NULL, "y offset" }
    };
    vector_append(entries, _make_api_entry(
        "translate_y",
        MODULE_OBJECT,
        "translate the cell by the specified y offset (relative movement).",
        "cell:translate_y(100)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.abut_left */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be abutted" },
        { "targercell",     OBJECT,     NULL, "abutment target cell" },
    };
    vector_append(entries, _make_api_entry(
        "abut_left",
        MODULE_OBJECT,
        "translate the cell so that its alignment box is abutted to the left of the alignment box of the specified target cell. This only changes the y coordinate",
        "cell:abut_left(othercell)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.abut_right */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be abutted" },
        { "targercell",     OBJECT,     NULL, "abutment target cell" },
    };
    vector_append(entries, _make_api_entry(
        "abut_right",
        MODULE_OBJECT,
        "translate the cell so that its alignment box is abutted to the right of the alignment box of the specified target cell. This only changes the y coordinate",
        "cell:abut_right(othercell)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.abut_top */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be abutted" },
        { "targercell",     OBJECT,     NULL, "abutment target cell" },
    };
    vector_append(entries, _make_api_entry(
        "abut_top",
        MODULE_OBJECT,
        "translate the cell so that its alignment box is abutted to the top of the alignment box of the specified target cell. This only changes the y coordinate",
        "cell:abut_top(othercell)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.abut_bottom */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be abutted" },
        { "targercell",     OBJECT,     NULL, "abutment target cell" },
    };
    vector_append(entries, _make_api_entry(
        "abut_bottom",
        MODULE_OBJECT,
        "translate the cell so that its alignment box is abutted to the bottom of the alignment box of the specified target cell. This only changes the y coordinate",
        "cell:abut_bottom(othercell)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.align_left */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be aligned" },
        { "targercell",     OBJECT,     NULL, "alignment target cell" },
    };
    vector_append(entries, _make_api_entry(
        "align_left",
        MODULE_OBJECT,
        "translate the cell so that its alignment box is aligned to the left of the alignment box of the specified target cell. This only changes the x coordinate",
        "cell:align_left(othercell)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.align_right */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be aligned" },
        { "targercell",     OBJECT,     NULL, "alignment target cell" },
    };
    vector_append(entries, _make_api_entry(
        "align_right",
        MODULE_OBJECT,
        "translate the cell so that its alignment box is aligned to the right of the alignment box of the specified target cell. This only changes the x coordinate",
        "cell:align_right(othercell)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.align_top */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be aligned" },
        { "targercell",     OBJECT,     NULL, "alignment target cell" },
    };
    vector_append(entries, _make_api_entry(
        "align_top",
        MODULE_OBJECT,
        "translate the cell so that its alignment box is aligned to the top of the alignment box of the specified target cell. This only changes the y coordinate",
        "cell:align_top(othercell)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.align_bottom */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to be aligned" },
        { "targercell",     OBJECT,     NULL, "alignment target cell" },
    };
    vector_append(entries, _make_api_entry(
        "align_bottom",
        MODULE_OBJECT,
        "translate the cell so that its alignment box is aligned to the bottom of the alignment box of the specified target cell. This only changes the y coordinate",
        "cell:align_bottom(othercell)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.abut_area_anchor_left */
{
    struct parameter parameters[] = {
        { "cell",               OBJECT,     NULL, "cell to be moved" },
        { "anchorname",         STRING,     NULL, "abutment anchor" },
        { "targercell",         OBJECT,     NULL, "alignment target cell" },
        { "targetanchorname",   STRING,     NULL, "target abutment anchor" },
    };
    vector_append(entries, _make_api_entry(
        "abut_area_anchor_left",
        MODULE_OBJECT,
        "translate the cell so that the specified area anchor is abutted to the left of the target area anchor of the specified target cell. This only changes the x coordinate",
        "cell:abut_area_anchor_left(\"leftsourcedrain\", othercell, \"rightsourcedrain\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.abut_area_anchor_right */
{
    struct parameter parameters[] = {
        { "cell",               OBJECT,     NULL, "cell to be moved" },
        { "anchorname",         STRING,     NULL, "abutment anchor" },
        { "targercell",         OBJECT,     NULL, "alignment target cell" },
        { "targetanchorname",   STRING,     NULL, "target abutment anchor" },
    };
    vector_append(entries, _make_api_entry(
        "abut_area_anchor_right",
        MODULE_OBJECT,
        "translate the cell so that the specified area anchor is abutted to the right of the target area anchor of the specified target cell. This only changes the x coordinate",
        "cell:abut_area_anchor_right(\"rightsourcedrain\", othercell, \"leftsourcedrain\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.abut_area_anchor_top */
{
    struct parameter parameters[] = {
        { "cell",               OBJECT,     NULL, "cell to be moved" },
        { "anchorname",         STRING,     NULL, "abutment anchor" },
        { "targercell",         OBJECT,     NULL, "alignment target cell" },
        { "targetanchorname",   STRING,     NULL, "target abutment anchor" },
    };
    vector_append(entries, _make_api_entry(
        "abut_area_anchor_top",
        MODULE_OBJECT,
        "translate the cell so that the specified area anchor is abutted to the top of the target area anchor of the specified target cell. This only changes the y coordinate",
        "cell:abut_area_anchor_top(\"botgatestrap\", othercell, \"topgatestrap\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.abut_area_anchor_bottom */
{
    struct parameter parameters[] = {
        { "cell",               OBJECT,     NULL, "cell to be moved" },
        { "anchorname",         STRING,     NULL, "abutment anchor" },
        { "targercell",         OBJECT,     NULL, "alignment target cell" },
        { "targetanchorname",   STRING,     NULL, "target abutment anchor" },
    };
    vector_append(entries, _make_api_entry(
        "abut_area_anchor_bottom",
        MODULE_OBJECT,
        "translate the cell so that the specified area anchor is abutted to the bottom of the target area anchor of the specified target cell. This only changes the y coordinate",
        "cell:abut_area_anchor_bottom(\"topgatestrap\", othercell, \"botgatestrap\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.align_area_anchor*/
{
    struct parameter parameters[] = {
        { "cell",               OBJECT,     NULL, "cell to be moved" },
        { "anchorname",         STRING,     NULL, "alignment anchor" },
        { "targercell",         OBJECT,     NULL, "alignment target cell" },
        { "targetanchorname",   STRING,     NULL, "target alignment anchor" },
    };
    vector_append(entries, _make_api_entry(
        "align_area_anchor",
        MODULE_OBJECT,
        "translate the cell so that the specified area anchor is aligned to the target area anchor of the specified target cell. This changes both the x and the y coordinate",
        "cell:align_area_anchor(\"leftsourcedrain\", othercell, \"rightsourcedrain\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.align_area_anchor_left */
{
    struct parameter parameters[] = {
        { "cell",               OBJECT,     NULL, "cell to be moved" },
        { "anchorname",         STRING,     NULL, "alignment anchor" },
        { "targercell",         OBJECT,     NULL, "alignment target cell" },
        { "targetanchorname",   STRING,     NULL, "target alignment anchor" },
    };
    vector_append(entries, _make_api_entry(
        "align_area_anchor_left",
        MODULE_OBJECT,
        "translate the cell so that the specified area anchor is aligned to the left of the target area anchor of the specified target cell. This only changes the x coordinate",
        "cell:align_area_anchor_left(\"leftsourcedrain\", othercell, \"rightsourcedrain\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.align_area_anchor_right */
{
    struct parameter parameters[] = {
        { "cell",               OBJECT,     NULL, "cell to be moved" },
        { "anchorname",         STRING,     NULL, "alignment anchor" },
        { "targercell",         OBJECT,     NULL, "alignment target cell" },
        { "targetanchorname",   STRING,     NULL, "target alignment anchor" },
    };
    vector_append(entries, _make_api_entry(
        "align_area_anchor_right",
        MODULE_OBJECT,
        "translate the cell so that the specified area anchor is aligned to the right of the target area anchor of the specified target cell. This only changes the x coordinate",
        "cell:align_area_anchor_right(\"rightsourcedrain\", othercell, \"leftsourcedrain\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.align_area_anchor_top */
{
    struct parameter parameters[] = {
        { "cell",               OBJECT,     NULL, "cell to be moved" },
        { "anchorname",         STRING,     NULL, "alignment anchor" },
        { "targercell",         OBJECT,     NULL, "alignment target cell" },
        { "targetanchorname",   STRING,     NULL, "target alignment anchor" },
    };
    vector_append(entries, _make_api_entry(
        "align_area_anchor_top",
        MODULE_OBJECT,
        "translate the cell so that the specified area anchor is aligned to the top of the target area anchor of the specified target cell. This only changes the y coordinate",
        "cell:align_area_anchor_top(\"botgatestrap\", othercell, \"topgatestrap\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.align_area_anchor_bottom */
{
    struct parameter parameters[] = {
        { "cell",               OBJECT,     NULL, "cell to be moved" },
        { "anchorname",         STRING,     NULL, "alignment anchor" },
        { "targercell",         OBJECT,     NULL, "alignment target cell" },
        { "targetanchorname",   STRING,     NULL, "target alignment anchor" },
    };
    vector_append(entries, _make_api_entry(
        "align_area_anchor_bottom",
        MODULE_OBJECT,
        "translate the cell so that the specified area anchor is aligned to the bottom of the target area anchor of the specified target cell. This only changes the y coordinate",
        "cell:align_area_anchor_bottom(\"topgatestrap\", othercell, \"botgatestrap\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.mirror_at_xaxis */
{
    struct parameter parameters[] = {};
    vector_append(entries, _make_api_entry(
        "mirror_at_xaxis",
        MODULE_OBJECT,
        "mirror the entire object at the x axis",
        "cell:mirror_at_xaxis()",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.mirror_at_yaxis */
{
    struct parameter parameters[] = {};
    vector_append(entries, _make_api_entry(
        "mirror_at_yaxis",
        MODULE_OBJECT,
        "mirror the entire object at the y axis",
        "cell:mirror_at_yaxis()",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.mirror_at_origin */
{
    struct parameter parameters[] = {};
    vector_append(entries, _make_api_entry(
        "mirror_at_origin",
        MODULE_OBJECT,
        "mirror the entire object at the origin",
        "cell:mirror_at_origin()",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.rotate_90_left */
{
    struct parameter parameters[] = {};
    vector_append(entries, _make_api_entry(
        "rotate_90_left",
        MODULE_OBJECT,
        "rotate the entire object 90 degrees counter-clockwise with respect to the origin",
        "cell:rotate_90_left()",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.rotate_90_right */
{
    struct parameter parameters[] = {};
    vector_append(entries, _make_api_entry(
        "rotate_90_right",
        MODULE_OBJECT,
        "rotate the entire object 90 degrees clockwise with respect to the origin",
        "cell:rotate_90_right()",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.flipx */
{
    struct parameter parameters[] = {};
    vector_append(entries, _make_api_entry(
        "flipx",
        MODULE_OBJECT,
        "flip the entire object in x direction. This is similar to mirror_at_yaxis (note the x vs. y), but is done in-place. The object is translated so that it is still in its original location. Works best on objects with an alignment box, since this is used to calculate the required translation. On other objects, this operation can be time-consuming as an accurate bounding box has to be computed. It is recommended not to use this function on objects without an alignment box because the result is not always ideal",
        "cell:flipx()",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.flipy */
{
    struct parameter parameters[] = {};
    vector_append(entries, _make_api_entry(
        "flipy",
        MODULE_OBJECT,
        "flip the entire object in y direction. This is similar to mirror_at_xaxis (note the y vs. x), but is done in-place. The object is translated so that it is still in its original location. Works best on objects with an alignment box, since this is used to calculate the required translation. On other objects, this operation can be time-consuming as an accurate bounding box has to be computed. It is recommended not to use this function on objects without an alignment box because the result is not always ideal",
        "cell:flipy()",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.move_point */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL,   "cell which should be moved" },
        { "source",     POINT,  NULL,   "source point" },
        { "target",     POINT,  NULL,   "target point" }
    };
    vector_append(entries, _make_api_entry(
        "move_point",
        MODULE_OBJECT,
        "translate (move) the object so that the source point lies on the target. Usually the source point is an anchor of the object, but that is not a necessity. The points are just references for the delta vector and can be any points.",
        "cell:move_point(cell:get_area_anchor(\"gate\").bl, point.create(0, 0)) -- move to origin\nmosfet:move_point(mosfet:get_area_anchor(\"leftsourcedrain\").bl, othermosfet:get_area_anchor(\"rightsourcedrain\").bl) -- align two mosfets",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.move_point_x */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL,   "cell which should be moved" },
        { "source",     POINT,  NULL,   "source point" },
        { "target",     POINT,  NULL,   "target point" }
    };
    vector_append(entries, _make_api_entry(
        "move_point_x",
        MODULE_OBJECT,
        "translate (move) the object so that the x-coorindate of the source point lies on the x-coordinate target. Usually the source point is an anchor of the object, but that is not a necessity. The points are just references for the delta vector and can be any points.",
        "cell:move_point_x(cell:get_area_anchor(\"gate\").bl, point.create(0, 0)) -- move the x-coordinate of the origin\nmosfet:move_point_x(mosfet:get_area_anchor(\"leftsourcedrain\").bl, othermosfet:get_area_anchor(\"rightsourcedrain\").bl) -- align the x-coordinate of two mosfets",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.move_point_y */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL,   "cell which should be moved" },
        { "source",     POINT,  NULL,   "source point" },
        { "target",     POINT,  NULL,   "target point" }
    };
    vector_append(entries, _make_api_entry(
        "move_point_y",
        MODULE_OBJECT,
        "translate (move) the object so that the y-coorindate of the source point lies on the y-coordinate target. Usually the source point is an anchor of the object, but that is not a necessity. The points are just references for the delta vector and can be any points.",
        "cell:move_point_y(cell:get_area_anchor(\"gate\").bl, point.create(0, 0)) -- move the y-coordinate of the origin\nmosfet:move_point_y(mosfet:get_area_anchor(\"leftsourcedrain\").bl, othermosfet:get_area_anchor(\"rightsourcedrain\").bl) -- align the y-coordinate of two mosfets",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}
/* object.add_child */
{
    struct parameter parameters[] = {
        { "cell",      OBJECT, NULL, "Object to which the child is added" },
        { "child",     OBJECT, NULL, "Child to add" },
        { "instname",  STRING, NULL,   "Instance name (not used by all exports)" },
    };
    vector_append(entries, _make_api_entry(
        "add_child",
        MODULE_OBJECT,
        "Add a child object (instance) to the given cell. This make 'cell' the parent of the child (it manages its memory). This means that you should not use the original child object any more after this call (unless it is object.add_child or object.add_child_array)",
        "local ref = pcell.create_layout(\"basic/mosfet\", \"mosfet\")\ncell:add_child(ref, \"mosinst0\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
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
        { "ypitch",    INTEGER,     NULL,   "Optional itch in y direction, used for repetition in y. If not given, this parameter is derived from the alignment box" }
    };
    vector_append(entries, _make_api_entry(
        "add_child_array",
        MODULE_OBJECT,
        "Add a child as an arrayed object to the given cell. The child array has xrep * yrep elements, with a pitch of xpitch and ypitch, respectively. The array grows to the upper-left, with the first placed untranslated. The pitch does not have to be explicitly given: If the child has an alignment box, the xpitch and ypitch are deferred from this box, if they are not given in the call. In this case, it is an error if no alignment box is present in child. As with object.add_child: don't use the original child object after this call unless it is object.add_child or object.add_child_array",
        "-- with explicit xpitch and ypitch:\nlocal ref = pcell.create_layout(\"basic/mosfet\", \"mosfet\")\ncell:add_child_array(ref, \"mosinst0\", 8, 1, 200, 0)\n-- with alignment box:\nlocal ref = pcell.create_layout(\"basic/mosfet\", \"mosfet\")\ncell:add_child_array(ref, \"mosinst0\", 8, 1)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.merge_into */
{
    struct parameter parameters[] = {
        { "cell",      OBJECT, NULL, "Object to which the child is added" },
        { "othercell", OBJECT, NULL, "Other layout cell to be merged into the cell" },
    };
    vector_append(entries, _make_api_entry(
        "merge_into",
        MODULE_OBJECT,
        "add all shapes and children from othercell to the cell -> 'dissolve' othercell in cell",
        "cell:merge_into(othercell)\ncell:merge_into(othercell:flatten())",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.flatten */
{
    struct parameter parameters[] = {
        { "cell",      OBJECT, NULL, "Object which should be flattened" },
    };
    vector_append(entries, _make_api_entry(
        "flatten_inline",
        MODULE_OBJECT,
        "resolve the cell by placing all shapes from all children in the parent cell. This operates in-place and modifies the object. Copy the cell if this is unwanted",
        "cell:flatten()\ncell:copy():flatten()",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.flatten */
{
    struct parameter parameters[] = {
        { "cell",      OBJECT, NULL, "Object which should be flattened" },
    };
    vector_append(entries, _make_api_entry(
        "flatten",
        MODULE_OBJECT,
        "resolve the cell by placing all shapes from all children in the parent cell. This does not change the original object and creates a copy.",
        "cell:flatten()\ncell:copy():flatten()",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* object.flatten_inline */
{
    struct parameter parameters[] = {
        { "cell",      OBJECT, NULL, "Object which should be flattened" },
    };
    vector_append(entries, _make_api_entry(
        "flatten_inline",
        MODULE_OBJECT,
        "resolve the cell by placing all shapes from all children in the parent cell. This operates in-place and modifies the object. Copy the cell or use object:flatten() if this is unwanted",
        "cell:flatten_inline()\ncell:copy():flatten_inline()",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/*
    FIXME:
	object.abut_bottom_origin
	object.abut_left_origin
	object.abut_right_origin
	object.abut_top_origin
	object.add_layer_boundary
	object.add_layer_boundary_rectangular
	object.align_area_anchor_x
	object.align_area_anchor_y
	object.align_bottom_origin
	object.align_left_origin
	object.align_right_origin
	object.align_top_origin
	object.create_object_handle
	object.create_pseudo
	object.get_all_regular_anchors
	object.get_area_anchor_height
	object.get_area_anchor_width
	object.get_boundary
	object.get_layer_boundary
	object.get_name
	object.has_boundary
	object.has_layer_boundary
	object.inherit_all_anchors_with_prefix
	object.inherit_anchor
	object.inherit_anchor_as
	object.inherit_area_anchor
	object.inherit_area_anchor_as
	object.is_object
	object.merge_into_with_ports
	object.rasterize_curves
	object.set_empty_layer_boundary
	object.set_name
*/
