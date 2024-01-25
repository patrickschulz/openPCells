/* layouthelpers.place_bus */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to place bus in" },
        { "layer",          GENERICS,   NULL, "layer of the bus shapes" },
        { "pts",            POINTLIST,  NULL, "path point defining the middle of the bus" },
        { "numbits",        INTEGER,    NULL, "number of bits" },
        { "width",          INTEGER,    NULL, "width of the bus lines" },
        { "space",          INTEGER,    NULL, "space between the bus lines" }
    };
    vector_append(entries, _make_api_entry(
        "place_bus",
        MODULE_LAYOUTHELPERS,
        "place a bus with 'numbits' lines with the given 'width' and 'space'. The bus is defined by the path points (like a regular path), which define the center of the bus.",
"layouthelpers.place_bus(cell,\n    generics.metal(2),\n    pts,\n    16\n    100, 100\n)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* layouthelpers.place_guardring */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to place guardring in" },
        { "bl",             POINT,      NULL, "bottom-left boundary corner" },
        { "tr",             POINT,      NULL, "top-right boundary corner" },
        { "xspace",         INTEGER,    NULL, "space in x-direction between boundary and guardring" },
        { "yspace",         INTEGER,    NULL, "space in y-direction between boundary and guardring" },
        { "anchorprefix",   STRING,     NULL, "anchor prefix for inherited anchors (cell inherits the 'innerboundary' and 'outerboundary' area anchors). If this is nil, no anchors are inherited" },
        { "options",        TABLE,      NULL, "placement options" }
    };
    vector_append(entries, _make_api_entry(
        "place_guardring",
        MODULE_LAYOUTHELPERS,
        "place a guardring in a cell with a defined boundary and spacing",
"layouthelpers.place_guardring(cell,\n    nmos:get_area_anchor(\"active\").bl,\n    nmos:get_area_anchor(\"active\").tr,\n    200, 200,\n    \"guardring_\",\n    {\n        contype = \"n\",\n        ringwidth = 100,\n        drawdeepwell = true,\n    }\n)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* layouthelpers.place_guardring_quantized */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to place guardring in" },
        { "bl",             POINT,      NULL, "bottom-left boundary corner" },
        { "tr",             POINT,      NULL, "top-right boundary corner" },
        { "xspace",         INTEGER,    NULL, "space in x-direction between boundary and guardring" },
        { "yspace",         INTEGER,    NULL, "space in y-direction between boundary and guardring" },
        { "basesize",       INTEGER,    NULL, "basesize for calculating the quantized hole width and height" },
        { "anchorprefix",   STRING,     NULL, "anchor prefix for inherited anchors (cell inherits the 'innerboundary' and 'outerboundary' area anchors). If this is nil, no anchors are inherited" },
        { "options",        TABLE,      NULL, "placement options" }
    };
    vector_append(entries, _make_api_entry(
        "place_guardring_quantized",
        MODULE_LAYOUTHELPERS,
        "place a guardring in a cell with a defined boundary and spacing. The guardring hole width and height are quantized so that they fit a multiple of the specified basesize. This does NOT account for the width of the guardring. While this might be a short-coming of this function, this issue can easily be circumvented by using a ring width that is also a multiple of the basesize.",
"layouthelpers.place_guardring_quantized(cell,\n    nmos:get_area_anchor(\"active\").bl,\n    nmos:get_area_anchor(\"active\").tr,\n    200, 200,\n    500,\n    \"guardring_\",\n    {\n        contype = \"n\",\n        ringwidth = 100,\n        drawdeepwell = true,\n    }\n)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* layouthelpers.place_guardring_with_hole */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to place guardring in" },
        { "bl",             POINT,      NULL, "bottom-left boundary corner" },
        { "tr",             POINT,      NULL, "top-right boundary corner" },
        { "hbl",            POINT,      NULL, "bottom-left hole boundary corner" },
        { "htr",            POINT,      NULL, "top-right hole boundary corner" },
        { "xspace",         INTEGER,    NULL, "space in x-direction between boundary and guardring" },
        { "yspace",         INTEGER,    NULL, "space in y-direction between boundary and guardring" },
        { "wellxoffset",    INTEGER,    NULL, "well offset in x-direction" },
        { "wellyoffset",    INTEGER,    NULL, "well offset in y-direction" },
        { "anchorprefix",   STRING,     NULL, "anchor prefix for inherited anchors (cell inherits the 'innerboundary' and 'outerboundary' area anchors). If this is nil, no anchors are inherited" },
        { "options",        TABLE,      NULL, "placement options" }
    };
    vector_append(entries, _make_api_entry(
        "place_guardring_with_hole",
        MODULE_LAYOUTHELPERS,
        "place a guardring with a well hole in a cell with a defined boundary and spacing. This function is like placement.place_guardring, but expects two more points that define the hole boundary. The placed guardring then has a hole in the well which encompasses exactly the given boundary. The connection to this inner well is not placed, this has to be done manually.",
"layouthelpers.place_guardring_with_hole(cell,\n    nmos:get_area_anchor(\"active\").bl,\n    pmos:get_area_anchor(\"active\").tr,\n    pmos:get_area_anchor(\"active\").bl,\n    pmos:get_area_anchor(\"active\").tr),\n    200, 200,\n    0, 0,\n    \"guardring_\",\n    {\n        contype = \"n\",\n        ringwidth = 100,\n        drawdeepwell = true,\n    }\n)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* layouthelpers.place_guardring_with_hole_quantized */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to place guardring in" },
        { "bl",             POINT,      NULL, "bottom-left boundary corner" },
        { "tr",             POINT,      NULL, "top-right boundary corner" },
        { "hbl",            POINT,      NULL, "bottom-left hole boundary corner" },
        { "htr",            POINT,      NULL, "top-right hole boundary corner" },
        { "xspace",         INTEGER,    NULL, "space in x-direction between boundary and guardring" },
        { "yspace",         INTEGER,    NULL, "space in y-direction between boundary and guardring" },
        { "basesize",       INTEGER,    NULL, "basesize for calculating the quantized hole width and height" },
        { "wellxoffset",    INTEGER,    NULL, "well offset in x-direction" },
        { "wellyoffset",    INTEGER,    NULL, "well offset in y-direction" },
        { "anchorprefix",   STRING,     NULL, "anchor prefix for inherited anchors (cell inherits the 'innerboundary' and 'outerboundary' area anchors). If this is nil, no anchors are inherited" },
        { "options",        TABLE,      NULL, "placement options" }
    };
    vector_append(entries, _make_api_entry(
        "place_guardring_with_hole_quantized",
        MODULE_LAYOUTHELPERS,
        "This function is like placement.place_guardring_with_hole, but creates a guardring whose hole width and height are made a multiple of the given basesize. See also the information on placement.place_guardring_quantized.",
"layouthelpers.place_guardring_with_hole_quantized(cell,\n    nmos:get_area_anchor(\"active\").bl,\n    nmos:get_area_anchor(\"active\").tr,\n    pmos:get_area_anchor(\"active\").bl,\n    pmos:get_area_anchor(\"active\").tr,\n    200, 200,\n    0, 0,\n    500,\n    \"guardring_\",\n    {\n        contype = \"n\",\n        ringwidth = 100,\n        drawdeepwell = true,\n    }\n)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* layouthelpers.place_welltap */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to place guardring in" },
        { "bl",             POINT,      NULL, "bottom-left boundary corner" },
        { "tr",             POINT,      NULL, "top-right boundary corner" },
        { "anchorprefix",   STRING,     NULL, "anchor prefix for inherited anchors (cell inherits the 'boundary' area anchor)" },
        { "options",        TABLE,      NULL, "placement options" }
    };
    vector_append(entries, _make_api_entry(
        "place_welltap",
        MODULE_LAYOUTHELPERS,
        "place a welltap in a cell with a defined boundary and spacing",
"layouthelpers.place_welltap(cell,\n    nmos:get_area_anchor(\"sourcestrap\").bl,\n    nmos:get_area_anchor(\"sourcestrap\").tr,\n    {\n        contype = \"n\",\n    }\n)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* layouthelpers.place_maximum_width_via */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the via is created" },
        { "firstmetal", INTEGER,    NULL,   "Number of the first metal. Negative values are possible" },
        { "lastmetal",  INTEGER,    NULL,   "Number of the last metal. Negative values are possible" },
        { "pt1",        POINT,      NULL,   "first corner point of the to-be-created via" },
        { "pt2",        POINT,      NULL,   "second corner point of the to-be-created via" }
    };
    vector_append(entries, _make_api_entry(
        "place_maximum_width_via",
        MODULE_LAYOUTHELPERS,
        "place a via (or a via stack) in an object. The function behaves like geometry.viabltr, but takes into account the maximum width of the metal layers. This means that possibly not all vias are created with the full width of the given region. This means that the first point (pt1) must touch the actual shape that should connect to the via. Therefore, pt1 and pt2 don't have to be the lower-left and the top-right corner points. The maximum widths are specified by the technology constraint file (entries \"Maximum Mn Width\", where 'n' is an integer). If no values are specified, the full width of the via region is used, in which case the function behaves exactly like geometry.viabltr (except for the order of the points).",
        "layouthelpers.place_maximum_width_via(cell, 1, 8, point.create(-100, 200), point.create(-800, 1500))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* layouthelpers.place_coplanar_waveguide */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the via is created" },
        { "layer",      GENERICS,   NULL,   "Layer for the waveguide shapes" },
        { "pts",        POINTLIST,  NULL,   "point list defining the center of the signal path" },
        { "swidth",     INTEGER,    NULL,   "width of the signal path" },
        { "gwidth",     INTEGER,    NULL,   "width of the ground paths" },
        { "separation", INTEGER,    NULL,   "separation between the signal and the ground paths" }
    };
    vector_append(entries, _make_api_entry(
        "place_coplanar_waveguide",
        MODULE_LAYOUTHELPERS,
        "place a coplanar waveguide defined by the center path points. This function is almost the same as geometry.path but draws three paths in total (ground-signal-ground).",
        "local pts = {\n    point.create(0, 0),\n    point.create(100000, 0),\n    point.create(100000, 100000)\n}\nlayouthelpers.place_coplanar_waveguide(cell, generics.metal(-1), pts, 5000, 10000, 10000)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* layouthelpers.place_stripline */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the via is created" },
        { "metalindex", INTEGER,    NULL,   "Metal index denoting the signal layer of the stripline" },
        { "pts",        POINTLIST,  NULL,   "point list defining the center of the signal path" },
        { "swidth",     INTEGER,    NULL,   "width of the signal path" },
        { "gwidth",     INTEGER,    NULL,   "width of the ground paths" }
    };
    vector_append(entries, _make_api_entry(
        "place_stripline",
        MODULE_LAYOUTHELPERS,
        "place a stripline defined by the center path points. This function is almost the same as geometry.path but draws three paths in total (ground-signal-ground). The layer argument is NOT a generic layer but a metal index (as striplines are assumed to be drawn in a metal). The metals below and above the signal layer are used for ground. Therefore, 'metalindex' must be 2 and the highest metal (-1).",
        "local pts = {\n    point.create(0, 0),\n    point.create(100000, 0),\n    point.create(100000, 100000)\n}\nlayouthelpers.place_stripline(cell, 4, pts, 5000, 10000)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

