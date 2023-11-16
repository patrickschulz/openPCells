/* layouthelpers.place_welltap */
{
    struct parameter parameters[] = {
        { "cell",           OBJECT,     NULL, "cell to place guardring in" },
        { "bl",             POINT,      NULL, "bottom-left boundary corner" },
        { "tr",             POINT,      NULL, "top-right boundary corner" },
        { "anchorprefix",   INTEGER,    NULL, "anchor prefix for inherited anchors (cell inherits the 'boundary' area anchor)" },
        { "options",        TABLE,      NULL, "placement options" }
    };
    vector_append(entries, _make_api_entry(
        "place_welltap",
        MODULE_LAYOUTHELPERS,
        // help text
        "place a welltap in a cell with a defined boundary and spacing",
        // example
"layouthelpers.place_welltap(cell,\n    nmos:get_area_anchor(\"sourcestrap\").bl,\n    nmos:get_area_anchor(\"sourcestrap\").tr,\n    {\n        contype = \"n\",\n    }\n)",
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
        { "anchorprefix",   INTEGER,    NULL, "anchor prefix for inherited anchors (cell inherits the 'innerboundary' and 'outerboundary' area anchors). If this is nil, no anchors are inherited" },
        { "options",        TABLE,      NULL, "placement options" }
    };
    vector_append(entries, _make_api_entry(
        "place_guardring",
        MODULE_LAYOUTHELPERS,
        // help text
        "place a guardring in a cell with a defined boundary and spacing",
        // example
"layouthelpers.place_guardring(cell,\n    nmos:get_area_anchor(\"active\").bl,\n    nmos:get_area_anchor(\"active\").tr,\n    200, 200,\n    {\n        contype = \"n\",\n        ringwidth = 100,\n        drawdeepwell = true,\n    }\n)",
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
        { "bl",             POINT,      NULL, "bottom-left hole boundary corner" },
        { "tr",             POINT,      NULL, "top-right hole boundary corner" },
        { "xspace",         INTEGER,    NULL, "space in x-direction between boundary and guardring" },
        { "yspace",         INTEGER,    NULL, "space in y-direction between boundary and guardring" },
        { "anchorprefix",   INTEGER,    NULL, "anchor prefix for inherited anchors (cell inherits the 'innerboundary' and 'outerboundary' area anchors). If this is nil, no anchors are inherited" },
        { "options",        TABLE,      NULL, "placement options" }
    };
    vector_append(entries, _make_api_entry(
        "place_guardring_with_hole",
        MODULE_LAYOUTHELPERS,
        // help text
        "place a guardring with a well hole in a cell with a defined boundary and spacing",
        // example
"layouthelpers.place_guardring_with_hole(cell,\n    nmos:get_area_anchor(\"active\").bl,\n    pmos:get_area_anchor(\"active\").tr,\n    pmos:get_area_anchor(\"active\").bl,\n    pmos:get_area_anchor(\"active\").tr),\n    200, 200,\n    {\n        contype = \"n\",\n        ringwidth = 100,\n        drawdeepwell = true,\n    }\n)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}
