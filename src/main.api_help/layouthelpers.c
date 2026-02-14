/* layouthelpers.via_area_anchor_multiple */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to place bus in" },
        { "startmetal",     INTEGER,    NULL, "start metal for via stack" },
        { "endmetal",       INTEGER,    NULL, "end metal for via stack" },
        { "fmt",            STRING,     NULL, "base format string for area anchors. Percent signs ('%') are replaced by the iterator value (an integer)" },
        { "startindex",     INTEGER,    NULL, "start index for numeric for-loop" },
        { "endindex",       INTEGER,    NULL, "end index for numeric for-loop" },
        { "increment",      INTEGER,    NULL, "increment for numeric for-loop (optional, default 1)" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "via_area_anchor_multiple",
        MODULE_LAYOUTHELPERS,
        "place (possibly arrayed) vias on (multiple) area anchors based on a format/pattern",
        "Place a via stack on an area anchor of the given cell (also places the via stack in the given cell). The via stack starts at the startmetal and ends at the endmetal. The vias are created within a for-loop that starts at the given startindex and ends at the given endindex. Optionally, an increment value (default 1) can be given. The fourth argument is a base name for the area anchor, in with the percent sign ('%') is replaced by the current iterator value.",
        "layouthelpers.via_area_anchor_multiple(cell,\n    1, 2,\n    \"gate_%\",\n    1, 8\n)",
        parameters
    ));
}

/* layouthelpers.place_bus */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to place bus in" },
        { "layer",          GENERICS,   NULL, "layer of the bus shapes" },
        { "pts",            POINTLIST,  NULL, "path point defining the middle of the bus" },
        { "numbits",        INTEGER,    NULL, "number of bits" },
        { "width",          INTEGER,    NULL, "width of the bus lines" },
        { "space",          INTEGER,    NULL, "space between the bus lines" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_bus",
        MODULE_LAYOUTHELPERS,
        "place a bus defined by a list of points (like a path)",
        "Place a bus with 'numbits' lines with the given 'width' and 'space'. The bus is defined by the path points (like a regular path), which define the center of the bus.",
"layouthelpers.place_bus(cell,\n    generics.metal(2),\n    pts,\n    16\n    100, 100\n)",
        parameters
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
        { "options",        TABLE,      NULL, "placement options" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_guardring",
        MODULE_LAYOUTHELPERS,
        "place a guardring in a cell with a defined boundary and spacing",
        "Place a guardring in a cell with a defined boundary and spacing. "
        "The guardring is drawn around the given bottom-left ('bl') and top-right ('tr') points, with additional spacing in x- and y-direction ('xspace' and 'yspace'). "
        "The guardring anchors are inherited by the cell (prefixed by the given 'anchorprefix'), for further use for alignment/connections/etc. "
        "The guardring itself can be configured by the 'options' table, its keys are passed to auxiliary/guardring as parameters.",
"layouthelpers.place_guardring(cell,\n    nmos:get_area_anchor(\"active\").bl,\n    nmos:get_area_anchor(\"active\").tr,\n    200, 200,\n    \"guardring_\",\n    {\n        contype = \"n\",\n        ringwidth = 100,\n        drawdeepwell = true,\n    }\n)",
        parameters
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
        { "basexsize",      INTEGER,    NULL, "basesize for calculating the quantized hole width" },
        { "baseysize",      INTEGER,    NULL, "basesize for calculating the quantized hole height" },
        { "anchorprefix",   STRING,     NULL, "anchor prefix for inherited anchors (cell inherits the 'innerboundary' and 'outerboundary' area anchors). If this is nil, no anchors are inherited" },
        { "options",        TABLE,      NULL, "placement options" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_guardring_quantized",
        MODULE_LAYOUTHELPERS,
        "place a quantized guardring in a cell with a defined boundary and spacing",
        "Place a quantized guardring in a cell with a defined boundary and spacing. "
        "The guardring is drawn around the given bottom-left ('bl') and top-right ('tr') points, with additional spacing in x- and y-direction ('xspace' and 'yspace'). "
        "The guardring hole width and height are quantized so that they fit a multiple of the specified basesize (x and y). "
        "This does NOT account for the width of the guardring. "
        "While this might be a short-coming of this function, this issue can easily be circumvented by using a ring width that is also a multiple of the basesize. "
        "The guardring anchors are inherited by the cell (prefixed by the given 'anchorprefix'), for further use for alignment/connections/etc. "
        "The guardring itself can be configured by the 'options' table, its keys are passed to auxiliary/guardring as parameters.",
"layouthelpers.place_guardring_quantized(cell,\n    nmos:get_area_anchor(\"active\").bl,\n    nmos:get_area_anchor(\"active\").tr,\n    200, 200,\n    500, 500,\n    \"guardring_\",\n    {\n        contype = \"n\",\n        ringwidth = 100,\n        drawdeepwell = true,\n    }\n)",
        parameters
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
        { "options",        TABLE,      NULL, "placement options" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_guardring_with_hole",
        MODULE_LAYOUTHELPERS,
        "place a guardring with a well hole",
        "Place a guardring with a well hole in a cell with a defined boundary and spacing. "
        "This function is like placement.place_guardring, but expects two more points that define the hole boundary. "
        "The placed guardring then has a hole in the well which encompasses exactly the given boundary. "
        "The connection to this inner well is not placed, this has to be done manually.",
        "layouthelpers.place_guardring_with_hole(cell,\n    nmos:get_area_anchor(\"active\").bl,\n    pmos:get_area_anchor(\"active\").tr,\n    pmos:get_area_anchor(\"active\").bl,\n    pmos:get_area_anchor(\"active\").tr),\n    200, 200,\n    0, 0,\n    \"guardring_\",\n    {\n        contype = \"n\",\n        ringwidth = 100,\n        drawdeepwell = true,\n    }\n)",
        parameters
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
        { "basexsize",      INTEGER,    NULL, "basesize for calculating the quantized hole width" },
        { "baseysize",      INTEGER,    NULL, "basesize for calculating the quantized hole height" },
        { "wellxoffset",    INTEGER,    NULL, "well offset in x-direction" },
        { "wellyoffset",    INTEGER,    NULL, "well offset in y-direction" },
        { "anchorprefix",   STRING,     NULL, "anchor prefix for inherited anchors (cell inherits the 'innerboundary' and 'outerboundary' area anchors). If this is nil, no anchors are inherited" },
        { "options",        TABLE,      NULL, "placement options" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_guardring_with_hole_quantized",
        MODULE_LAYOUTHELPERS,
        "place a quantized guardring with a well hole",
        "This function is like a combination of placement.place_guardring_quantized and placement.place_guardring_with_hole, it creates a quantized guardring with a well hole, whose width and height are made a multiple of the given basesize (x and y). "
        "See also the information on placement.place_guardring_quantized.",
        "layouthelpers.place_guardring_with_hole_quantized(cell,\n    nmos:get_area_anchor(\"active\").bl,\n    nmos:get_area_anchor(\"active\").tr,\n    pmos:get_area_anchor(\"active\").bl,\n    pmos:get_area_anchor(\"active\").tr,\n    200, 200,\n    0, 0,\n    500, 500,\n    \"guardring_\",\n    {\n        contype = \"n\",\n        ringwidth = 100,\n        drawdeepwell = true,\n    }\n)",
        parameters
    ));
}

/* layouthelpers.place_double_guardring */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to place guardring in" },
        { "bl",             POINT,      NULL, "bottom-left boundary corner" },
        { "tr",             POINT,      NULL, "top-right boundary corner" },
        { "xspace",         INTEGER,    NULL, "space in x-direction between boundary and guardring" },
        { "yspace",         INTEGER,    NULL, "space in y-direction between boundary and guardring" },
        { "innercontype",   STRING,     NULL, "contact type of inner guardring, the outer one has the opposite polarity" },
        { "anchorprefix1",  STRING,     NULL, "anchor prefix for inherited anchors for inner guardring (cell inherits the 'innerboundary' and 'outerboundary' area anchors). If this is nil, no anchors are inherited" },
        { "anchorprefix2",  STRING,     NULL, "anchor prefix for inherited anchors for outer guardring (cell inherits the 'innerboundary' and 'outerboundary' area anchors). If this is nil, no anchors are inherited" },
        { "options",        TABLE,      NULL, "placement options, this table needs to contain at least 'ringwidth'" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_double_guardring",
        MODULE_LAYOUTHELPERS,
        "place two guardrings",
        "Place two surrounding guardrings in a cell with a defined boundary and spacing.",
"layouthelpers.place_double_guardring(cell,\n    nmos:get_area_anchor(\"active\").bl,\n    nmos:get_area_anchor(\"active\").tr,\n    200, 200,\n    \"p\",\n    \"innerguardring_\", \"outerguardring_\",\n    {\n        contype = \"n\",\n        ringwidth = 100,\n    }\n)",
        parameters
    ));
}

/* layouthelpers.place_welltap */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to place guardring in" },
        { "bl",             POINT,      NULL, "bottom-left boundary corner" },
        { "tr",             POINT,      NULL, "top-right boundary corner" },
        { "anchorprefix",   STRING,     NULL, "anchor prefix for inherited anchors (cell inherits the 'boundary' area anchor). If this is nil, no anchors are inherited" },
        { "options",        TABLE,      NULL, "placement options" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_welltap",
        MODULE_LAYOUTHELPERS,
        "place a welltap",
        "Place a welltap in a cell with a defined boundary and spacing",
"layouthelpers.place_welltap(cell,\n    nmos:get_area_anchor(\"sourcestrap\").bl,\n    nmos:get_area_anchor(\"sourcestrap\").tr,\n    {\n        contype = \"n\",\n    }\n)",
        parameters
    ));
}

/* layouthelpers.place_maximum_width_via */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the via is created" },
        { "firstmetal", INTEGER,    NULL,   "Number of the first metal. Negative values are possible" },
        { "lastmetal",  INTEGER,    NULL,   "Number of the last metal. Negative values are possible" },
        { "pt1",        POINT,      NULL,   "first corner point of the to-be-created via" },
        { "pt2",        POINT,      NULL,   "second corner point of the to-be-created via" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_maximum_width_via",
        MODULE_LAYOUTHELPERS,
        "place a via stack that respects maximum metal widths",
        "Place a via (or a via stack) in an object. The function behaves like geometry.viabltr, but takes into account the maximum width of the metal layers. This means that possibly not all vias are created with the full width of the given region. This means that the first point (pt1) must touch the actual shape that should connect to the via. Therefore, pt1 and pt2 don't have to be the lower-left and the top-right corner points. The maximum widths are specified by the technology constraint file (entries \"Maximum Mn Width\", where 'n' is an integer). If no values are specified, the full width of the via region is used, in which case the function behaves exactly like geometry.viabltr (except for the order of the points).",
        "layouthelpers.place_maximum_width_via(cell,\n    1, 8,\n    point.create(-100, 200),\n    point.create(-800, 1500)\n)",
        parameters
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
        { "separation", INTEGER,    NULL,   "separation between the signal and the ground paths" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_coplanar_waveguide",
        MODULE_LAYOUTHELPERS,
        "place a coplanar waveguide",
        "Place a coplanar waveguide defined by the center path points. This function is almost the same as geometry.path but draws three paths in total (ground-signal-ground).",
        "local pts = {\n    point.create(0, 0),\n    point.create(100000, 0),\n    point.create(100000, 100000)\n}\nlayouthelpers.place_coplanar_waveguide(cell,\n    generics.metal(-1),\n    pts,\n    5000, 10000, 10000\n)",
        parameters
    ));
}

/* layouthelpers.place_stripline */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT,     NULL,   "Object in which the via is created" },
        { "metalindex", INTEGER,    NULL,   "Metal index denoting the signal layer of the stripline" },
        { "pts",        POINTLIST,  NULL,   "point list defining the center of the signal path" },
        { "swidth",     INTEGER,    NULL,   "width of the signal path" },
        { "gwidth",     INTEGER,    NULL,   "width of the ground paths" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_stripline",
        MODULE_LAYOUTHELPERS,
        "place a stripline",
        "place a stripline defined by the center path points. This function is almost the same as geometry.path but draws three paths in total (ground-signal-ground). The layer argument is NOT a generic layer but a metal index (as striplines are assumed to be drawn in a metal). The metals below and above the signal layer are used for ground. Therefore, 'metalindex' must be 2 and the highest metal (-1).",
        "local pts = {\n    point.create(0, 0),\n    point.create(100000, 0),\n    point.create(100000, 100000)\n}\nlayouthelpers.place_stripline(cell, 4, pts, 5000, 10000)",
        parameters
    ));
}

/* layouthelpers.collect_gridlines */
{
    struct parameter parameters[] = {
        { "t",              TABLE,      NULL,   "table where anchors are collected" },
        { "cells",          TABLE,      NULL,   "list of cells defining the anchors" },
        { "anchorname",     STRING,     NULL,   "name of the anchor to be collected" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "collect_gridlines",
        MODULE_LAYOUTHELPERS,
        "collect gridlines for placing vias",
        "Combine overlapping/touching rectangular anchors into larger rectangles. This function expects a list of cells that all have at least the given area anchor. Then all overlaps are computed an inserted into the table. This function is useful when placing vias from a powergrid down to power bars. If only the individual anchors are used it can happen (depending on the type of the grid cell) that only partial vias can be placed. Merging the lines beforehand solves this.",
        "local lines = {}\nlayouthelpers.collect_gridlines(lines, gridcells, \"vddline\")",
        parameters
    ));
}

/* layouthelpers.place_powergrid */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to place guardring in" },
        { "bl",             POINT,      NULL, "bottom-left boundary corner" },
        { "tr",             POINT,      NULL, "top-right boundary corner" },
        { "vlayer",         INTEGER,    NULL, "metal layer (number) for vertical lines" },
        { "hlayer",         INTEGER,    NULL, "metal layer (number) for horizontal lines" },
        { "vwidth",         INTEGER,    NULL, "width of vertical lines" },
        { "vspace",         INTEGER,    NULL, "space of vertical lines" },
        { "hwidth",         INTEGER,    NULL, "width of horizontal lines" },
        { "hspace",         INTEGER,    NULL, "space of horizontal lines" },
        { "plusshapes",     TABLE,      NULL, "target shapes for 'plus' net via creation. Table containing tables with 'bl' and 'tr' items" },
        { "minusshapes",    TABLE,      NULL, "target shapes for 'minus' net via creation. Table containing tables with 'bl' and 'tr' items " },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_powergrid",
        MODULE_LAYOUTHELPERS,
        "place a power grid",
        "Create a power grid with vertical and horizontal lines that connect to given target shapes. The power grid lays out alternating lines for the 'plus' net and the 'minus' net (e.g., VDD and VSS). Target shapes for both these nets are given in the form of tables containing { bl = ..., tr = ... } pairs.",
        "local vddshapes = {\n    {\n        bl = point(2000, 0),\n        tr = point.create(8000, 200)\n    }\n}\nlocal vssshapes = {\n    {\n        bl = point.create(2000, 800),\n        tr = point.create(8000, 1000)\n    }\n}\nlayouthelpers.place_powergrid(cell,\n    -- target area:\n    point.create(0, 0), point.create(10000, 4000),\n    5, 6, -- metal layers\n    400, 800,-- vertical width/space\n     400, 800,-- horizontal width/space\n    vddshapes, vssshapes)",
        parameters
    ));
}

/* layouthelpers.place_powervlines */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to place power lines in" },
        { "bl",             POINT,      NULL, "bottom-left boundary corner" },
        { "tr",             POINT,      NULL, "top-right boundary corner" },
        { "layer",          INTEGER,    NULL, "metal layer (number) for power lines" },
        { "width",          INTEGER,    NULL, "width of power lines" },
        { "space",          INTEGER,    NULL, "space of power lines" },
        { "powershapes",    TABLE,      NULL, "target shapes for via creation. Table containing tables with 'bl' and 'tr' items" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_powervlines",
        MODULE_LAYOUTHELPERS,
        "place vertical power lines",
        "Create power lines with vertical lines that connect to given target shapes. Target shapes for the power net are given in the form of tables containing { bl = ..., tr = ... } pairs.",
        "local powershapes = {\n    {\n        bl = point(2000, 0),\n        tr = point.create(8000, 200)\n    }\n}\nlayouthelpers.place_powervlines(cell,\n    -- target area:\n    point.create(0, 0), point.create(10000, 4000),\n    5, -- metal layer\n    400, 800,-- width/space\n    powershapes\n)",
        parameters
    ));
}

/* layouthelpers.place_powerhlines */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to place power lines in" },
        { "bl",             POINT,      NULL, "bottom-left boundary corner" },
        { "tr",             POINT,      NULL, "top-right boundary corner" },
        { "layer",          INTEGER,    NULL, "metal layer (number) for power lines" },
        { "width",          INTEGER,    NULL, "width of power lines" },
        { "space",          INTEGER,    NULL, "space of power lines" },
        { "powershapes",    TABLE,      NULL, "target shapes for via creation. Table containing tables with 'bl' and 'tr' items" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_powerhlines",
        MODULE_LAYOUTHELPERS,
        "place horizontal power lines",
        "Create power lines with horizontal lines that connect to given target shapes. Target shapes for the power net are given in the form of tables containing { bl = ..., tr = ... } pairs.",
        "local powershapes = {\n    {\n        bl = point(2000, 0),\n        tr = point.create(8000, 200)\n    }\n}\nlayouthelpers.place_powerhlines(cell,\n    -- target area:\n    point.create(0, 0), point.create(10000, 4000),\n    5, -- metal layer\n    400, 800,-- height/space\n    powershapes)",
        parameters
    ));
}

/* layouthelpers.place_vlines_numsets */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to place lines in" },
        { "bl",             POINT,      NULL, "bottom-left boundary corner" },
        { "tr",             POINT,      NULL, "top-right boundary corner" },
        { "layer",          GENERICS,   NULL, "metal layer for lines" },
        { "width",          INTEGER,    NULL, "width of lines" },
        { "netnames",       TABLE,      NULL, "table with netnames (one line per set and net)" },
        { "numsets",        INTEGER,    NULL, "number of line sets to place (one line per set and net)" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_vlines_numsets",
        MODULE_LAYOUTHELPERS,
        "place vertical lines (number of sets)",
        "Create vertical lines in a cell on a given layer. The target area is given as well as the width of the placed lines. The number of placed lines is calculated from the number of given nets and the number of net sets (numnets * numsets). This function returns a table with a net target entry for every line, where one entry looks like this: { net = <netname>, bl = <bl>, tr = <tr>, layer = <layer> }",
        "local netshapes = layouthelpers.place_vlines_numsets(cell,\n    -- target area:\n    point.create(0, 0), point.create(10000, 4000),\n    generics.metal(5), -- layer\n    400, -- width\n    { \"VDD\", \"VSS\", \"BIAS\", }, -- net names \n    4 -- number of sets)",
        parameters
    ));
}

/* layouthelpers.place_vlines */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to place lines in" },
        { "bl",             POINT,      NULL, "bottom-left boundary corner" },
        { "tr",             POINT,      NULL, "top-right boundary corner" },
        { "layer",          GENERICS,   NULL, "metal layer for lines" },
        { "width",          INTEGER,    NULL, "width of lines" },
        { "space",          INTEGER,    NULL, "space of lines" },
        { "minheight",      INTEGER,    NULL, "minimum height of lines" },
        { "netnames",       TABLE,      NULL, "table with netnames (one line net)" },
        { "excludes",       TABLE,      NULL, "table with polygon excludes" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_vlines",
        MODULE_LAYOUTHELPERS,
        "place vertical lines",
        "Create vertical lines in a cell on a given layer. "
        "The target area is given as well as the width of the placed lines. "
        "The number of placed lines is calculated from the available area and the width and space. "
        "Additionally a table with exclude polygons can be given. "
        "No lines will be drawn in these excludes. "
        "Note that the minimum fitting rectangle around the polygon is used, not the polygon itself. "
        "This might result in too pessimistic line placement. "
        "However, as most geometries are rectangles, in general this will work quite well. "
        "As excludes can cause short lines to be created, the 'minheight' parameter restricts the creation of too small lines. "
        "This can be 0 (zero), then all possible lines will be created. "
        "This function returns a table with a net target entry for every line, where one entry looks like this: "
        "{ net = <netname>, bl = <bl>, tr = <tr>, layer = <layer> }",
        "local netshapes = layouthelpers.place_vlines(cell,\n    -- target area:\n    point.create(0, 0), point.create(10000, 4000),\n    generics.metal(5), -- layer\n    400, 400, -- width/space\n    { \"VDD\", \"VSS\", \"BIAS\", }, -- net names)",
        parameters
    ));
}

/* layouthelpers.place_hlines_numsets */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to place lines in" },
        { "bl",             POINT,      NULL, "bottom-left boundary corner" },
        { "tr",             POINT,      NULL, "top-right boundary corner" },
        { "layer",          GENERICS,   NULL, "metal layer for lines" },
        { "height",         INTEGER,    NULL, "height of lines" },
        { "netnames",       TABLE,      NULL, "table with netnames (one line per set and net)" },
        { "numsets",        INTEGER,    NULL, "number of line sets to place (one line per set and net)" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_hlines_numsets",
        MODULE_LAYOUTHELPERS,
        "place horizontal lines (number of sets)",
        "Create horizontal lines in a cell on a given layer. The target area is given as well as the width of the placed lines. The number of placed lines is calculated from the number of given nets and the number of net sets (numnets * numsets). This function returns a table with a net target entry for every line, where one entry looks like this: { net = <netname>, bl = <bl>, tr = <tr>, layer = <layer> }",
        "local netshapes = layouthelpers.place_hlines_numsets(cell,\n    -- target area:\n    point.create(0, 0), point.create(4000, 10000),\n    generics.metal(5), -- layer\n    400, -- height\n    { \"VDD\", \"VSS\", \"BIAS\", }, -- net names \n    4 -- number of sets)",
        parameters
    ));
}

/* layouthelpers.place_hlines */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to place lines in" },
        { "bl",             POINT,      NULL, "bottom-left boundary corner" },
        { "tr",             POINT,      NULL, "top-right boundary corner" },
        { "layer",          GENERICS,   NULL, "metal layer for lines" },
        { "width",          INTEGER,    NULL, "width of lines" },
        { "space",          INTEGER,    NULL, "space of lines" },
        { "minwidth",       INTEGER,    NULL, "minimum width of lines" },
        { "netnames",       TABLE,      NULL, "table with netnames (one line net)" },
        { "excludes",       TABLE,      NULL, "table with polygon excludes" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_hlines",
        MODULE_LAYOUTHELPERS,
        "place horizontal lines",
        "Create horizontal lines in a cell on a given layer. "
        "The target area is given as well as the width of the placed lines. "
        "The number of placed lines is calculated from the available area and the height and space. "
        "Additionally a table with exclude polygons can be given. "
        "No lines will be drawn in these excludes. "
        "Note that the minimum fitting rectangle around the polygon is used, not the polygon itself. "
        "This might result in too pessimistic line placement. "
        "However, as most geometries are rectangles, in general this will work quite well. "
        "As excludes can cause short lines to be created, the 'minwidth' parameter restricts the creation of too small lines. "
        "This can be 0 (zero), then all possible lines will be created. "
        "This function returns a table with a net target entry for every line, where one entry looks like this: "
        "{ net = <netname>, bl = <bl>, tr = <tr>, layer = <layer> }",
        "local netshapes = layouthelpers.place_hlines(cell,\n    -- target area:\n    point.create(0, 0), point.create(4000, 10000),\n    generics.metal(5), -- layer\n    400, 400, -- width/space\n    { \"VDD\", \"VSS\", \"BIAS\", }, -- net names)",
        parameters
    ));
}

/* layouthelpers.place_vias */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to place lines in" },
        { "netshapes1",     TABLE,      NULL, "table with net targets (1): { net = <netname>, bl = <bl>, tr = <tr>, layer = <layer> }" },
        { "netshapes2",     TABLE,      NULL, "table with net targets (2): { net = <netname>, bl = <bl>, tr = <tr>, layer = <layer> }" },
        { "excludes",       TABLE,      NULL, "table with polygon excludes" },
        { "netfilter",      TABLE,      NULL, "optional table containing nets that should be connected. If not given, all matching nets are conneted" },
        { "onlyfull",       BOOLEAN,    NULL, "only place vias where a full overlap exists (where one shape defines x and the other one defines y)" },
        { "nocheck",        BOOLEAN,    NULL, "don't check vias. If not given, all vias area created, if the overlap is too small an error is raised" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_vias",
        MODULE_LAYOUTHELPERS,
        "place vias between net shapes",
        "Create vias in a cell connecting net shapes on different layers. "
        "This function creates vias between the given layers. "
        "If not net filter is given, all netshapes with matching nets are connected. "
        "A table with exclusion polygons can be given, which is useful when vias across several layers are created. "
        "If a table array with string items is given, only shapes on nets in that array are connected. "
        "'nocheck' might cause the function to raise an error: "
        "when there are small overlaps without a legal via arrayzation, the function raises an error (as internally geometry.viabltr is used). "
        "With 'nocheck' == false (the default) the legality of the overlap for via generation is checked first and skipped if it would fail.",
        "layouthelpers.place_vias(cell,\n    netshapes1, netshapes2, -- netshapes\n    { \"VSS\" \"BIAS\" }, -- net filter\n)",
        parameters
    ));
}

/* layouthelpers.place_unequal_net_vias */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to place lines in" },
        { "netshapes1",     TABLE,      NULL, "table with net targets (1): { net = <netname>, bl = <bl>, tr = <tr>, layer = <layer> }" },
        { "netshapes2",     TABLE,      NULL, "table with net targets (2): { net = <netname>, bl = <bl>, tr = <tr>, layer = <layer> }" },
        { "netfilter",      INTEGER,    NULL, "optional table containing nets that should be connected. If not given, all nets are connected" },
        { "onlyfull",       BOOLEAN,    NULL, "only place vias where a full overlap exists (where one shape defines x and the other one defines y)" },
        { "nocheck",        BOOLEAN,    NULL, "don't check vias. If not given, all vias area created, if the overlap is too small an error is raised" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "place_unequal_net_vias",
        MODULE_LAYOUTHELPERS,
        "place vias between unmatching net shapes",
        "Create vias in a cell connecting net shapes on different layers and different nets. "
        "This function creates vias between the given layers. "
        "As this function creates vias between all shapes, only the net shapes should be given that need to be connected. "
        "(This function shorts different nets). "
        "This behaviour is different than layouthelpers.place_vias, where only shapes on equal nets are connected. "
        "'nocheck' might cause the function to raise an error: "
        "when there are small overlaps without a legal via arrayzation, the function raises an error (as internally geometry.viabltr is used). "
        "With 'nocheck' == false (the default) the legality of the overlap for via generation is checked first and skipped if it would fail.",
        "layouthelpers.place_unequal_vias(cell,\n    netshapes1, netshapes2)",
        parameters
    ));
}

/* layouthelpers.annotate_netshapes */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to place net labels in" },
        { "netshapes",      TABLE,      NULL, "table with net targets: { net = <netname>, bl = <bl>, tr = <tr>, layer = <layer> }" },
        { "sizehint",       INTEGER,    NULL, "size hint for the labels" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "annotate_netshapes",
        MODULE_LAYOUTHELPERS,
        "annotate net shapes with net labels",
        "Create labels on every given net shape in the table, on all four corners. "
        "Useful for e.g. creating bigger interconnect grids",
        "layouthelpers.annotate_netshapes(cell, netshapes, 200)",
        parameters
    ));
}

/* layouthelpers.connect_area_anchor */
{
    struct parameter parameters[] = {
        { "cell",               OBJECT,     NULL, "cell to place net labels in" },
        { "layer",              GENERICS,   NULL, "layer for the created shape" },
        { "width",              INTEGER,    NULL, "width of connection path" },
        { "anchor1",            STRING,     NULL, "first area anchor for connection" },
        { "anchor2",            STRING,     NULL, "second area anchor for connection" },
        { "grid",               INTEGER,    NULL, "grid for generated points (default 1)" },
        { "matchtolerance",     STRING,     NULL, "tolerance matching factor for edges (default 1)" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "connect_area_anchor",
        MODULE_LAYOUTHELPERS,
        "connect to area anchors",
        "Create a connection between two given area anchors. "
        "This function is currently very basic and only exists for testing purposes. "
        "Its interface is likely to change as well as its function. "
        "It will create a working (and often also DRC-clean) connection, so it should be somewhat usable. "
        "The 'grid' ensures that generatd intermediate are on the specified grid. "
        "The tolerance matching factor (default: 1) determines which edges are acceptable for two-point connections. "
        "The idea behind this is that edges whose length match the width of the connection path (the 'width' parameter) can be used for more efficient two-point connections instead of three point connections. "
        "The default for this is 1, if only edges with an exact length 'width', the 'matchtolerance' should be 0.",
        "layouthelpers.connect_area_anchor(cell,\n    generics.metal(3),\n    500,\n    cell:get_area_anchor(\"anchor1\"),\n    cell:get_area_anchor(\"anchor2\")\n)",
        parameters
    ));
}

