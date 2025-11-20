/* technology.get_grid */
{
    struct parameter parameters[] = {
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_grid",
        MODULE_TECHNOLOGY,
        "Get the manufacturing grid of the process node (in nanometer)",
        "local grid = technology.get_grid()",
        parameters
    ));
}

/* technology.get_dimension */
{
    struct parameter parameters[] = {
        { "property", STRING, NULL, "technology property name" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_dimension",
        MODULE_TECHNOLOGY,
        "Get critical technology dimensions such as minimum metal width. Predominantly used in pcell parameter definitions, but not necessarily restricted to that. There is a small set of technology properties that are used in the standard opc cells, but there is currently no proper definitions of the supported fields. See basic/mosfet and basic/cmos for examples",
        "function parameters()\n    pcell.add_parameters({ {\"width\", technology.get_dimension(\"Minimum M1 Width\") } })\nend",
        parameters
    ));
}

/* technology.get_optional_dimension */
{
    struct parameter parameters[] = {
        { "property", STRING, NULL, "technology property name" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_optional_dimension",
        MODULE_TECHNOLOGY,
        "Like get_dimension, but this function does not raise an error if the dimension was not found but simply return 0.",
        "function parameters()\n    pcell.add_parameters({ {\"width\", technology.get_optional_dimension(\"Minimum M1 Width\") } })\nend",
        parameters
    ));
}

/* technology.has_layer */
{
    struct parameter parameters[] = {
        { "layer", GENERICS, NULL, "generic layer which should be checked" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "has_layer",
        MODULE_TECHNOLOGY,
        "Check if the chosen technology supports a certain layer",
        "if technology.has_layer(generics.other(\"gatecut\")) then\n    -- do something with gatecuts\nend",
        parameters
    ));
}

/* technology.has_multiple_patterning */
{
    struct parameter parameters[] = {
        { "metalnumber", INTEGER, NULL, "metal index" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "has_multiple_patterning",
        MODULE_TECHNOLOGY,
        "Check if the chosen metal layer (represented by the metal index) supports multiple patterning",
        "local metallayer\nif technology.has_multiple_patterning(1) then\n    metallayer = generics.mptmetal(1, 1)\nelse\n    metallayer = generics.metal(1)\nend",
        parameters
    ));
}

/* technology.has_metal */
{
    struct parameter parameters[] = {
        { "metalnumber", INTEGER, NULL, "metal index" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "has_metal",
        MODULE_TECHNOLOGY,
        "Check if the given metal layer is within the range of available metal layers. Negative numbers are resolved as in generics.metal.",
        "if technology.has_metal(1) then ...",
        parameters
    ));
}

/* technology.multiple_patterning_number */
{
    struct parameter parameters[] = {
        { "metalnumber", INTEGER, NULL, "metal index" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "multiple_patterning_number",
        MODULE_TECHNOLOGY,
        "Get the number of available mask for a metal layer that supports multiple patterning (otherwise the result is 0)",
        "local nummasks = technology.multiple_patterning_number(1)\nfor i = 1, nummasks do\n    -- do something for every mask of this metal layer\nend",
        parameters
    ));
}

/* technology.resolve_metal */
{
    struct parameter parameters[] = {
        { "index", INTEGER, NULL, "metal index to be resolved" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "resolve_metal",
        MODULE_TECHNOLOGY,
        "resolve negative metal indices to their 'real' value (e.g. in a metal stack with five metals -1 becomes 5, -3 becomes 3). This function does not do anything if the index is positive",
        "local metalindex = technology.resolve_metal(-2)",
        parameters
    ));
}

/* technology.list_techpaths */
{
    struct parameter parameters[] = {
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "list_techpaths",
        MODULE_TECHNOLOGY,
        "list the current technology paths",
        "technology.list_techpaths()",
        parameters
    ));
}
