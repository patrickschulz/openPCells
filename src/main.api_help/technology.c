/* technology.get_grid */
{
    struct parameter parameters[] = {
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_grid",
        MODULE_TECHNOLOGY,
        "get the technology grid",
        "Get the manufacturing grid of the process node (in nanometer).",
        "local grid = technology.get_grid()",
        parameters
    ));
}

/* technology.get_even_grid */
{
    struct parameter parameters[] = {
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_even_grid",
        MODULE_TECHNOLOGY,
        "get the technology grid (even only)",
        "Get the manufacturing grid of the process node (in nanometer). "
        "If the grid is not an even number, return the next even multiple of the grid (grid * 2). "
        "This function is useful when geometries that need to be on grid are calculated from given parameters and divided later on.",
        "local grid = technology.get_even_grid()",
        parameters
    ));
}

/* technology.get_dimension */
{
    struct parameter parameters[] = {
        { "properties...", VARARGS, NULL, "technology property name, multiple can be given (including nil)" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_dimension",
        MODULE_TECHNOLOGY,
        "get critical technology dimensions such as minimum metal width",
        "Get critical technology dimensions such as minimum metal width. "
        "Predominantly used in pcell parameter definitions, but not necessarily restricted to that. "
        "There is a small set of technology properties that are used in the standard opc cells, but there is currently no proper definitions of the supported fields. "
        "See basic/mosfet and basic/cmos for examples. "
        "This function can be given multiple look-up strings, the first one that is found will be returned. "
        "If the maximum of several properties is required, use 'technology.get_dimension_max()'. "
        "For convenience, this function can also process 'nil' parameters, which will simply be ignored.",
        "function parameters()\n    pcell.add_parameters({ {\"width\", technology.get_dimension(\"Minimum M1 Width\") } })\nend",
        parameters
    ));
}

/* technology.get_dimension_max */
{
    struct parameter parameters[] = {
        { "properties...", VARARGS, NULL, "technology property name, multiple can be given (including nil)" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_dimension_max",
        MODULE_TECHNOLOGY,
        "get critical technology dimensions such as minimum metal width (max value)",
        "Get critical technology dimensions such as minimum metal width. "
        "This is similar to technology.get_dimension, but returns the maximum value of all given properties.",
        "function parameters()\n    pcell.add_parameters({ {\"width\", technology.get_dimension_ma(\"Minimum Gate Width\", \"Analog Gate Width\") } })\nend",
        parameters
    ));
}

/* technology.get_dimension_min */
{
    struct parameter parameters[] = {
        { "properties...", VARARGS, NULL, "technology property name, multiple can be given (including nil)" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_dimension_min",
        MODULE_TECHNOLOGY,
        "get critical technology dimensions such as minimum metal width (min value)",
        "Get critical technology dimensions such as minimum metal width. "
        "This is similar to technology.get_dimension, but returns the minimum value of all given properties.",
        "function parameters()\n    pcell.add_parameters({ {\"space\", technology.get_dimension_ma(\"Minimum Gate Space\", \"Minimum Gate XSpace\") } })\nend",
        parameters
    ));
}

/* technology.get_optional_dimension */
{
    struct parameter parameters[] = {
        { "properties...",  VARARGS, NULL, "technology property name, multiple can be given (including nil)" },
        { "fallback",       VARARGS, NULL, "fallback value if no property value could be found" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_optional_dimension",
        MODULE_TECHNOLOGY,
        "get optional technology dimensions",
        "Like get_dimension, but this function does not raise an error if the dimension was not found but returns the given fallback value.",
        "function parameters()\n    pcell.add_parameters({ {\"width\", technology.get_optional_dimension(\"Minimum M1 Width\") } })\nend",
        parameters
    ));
}

/* technology.has_feature */
{
    struct parameter parameters[] = {
        { "feature", STRING, NULL, "feature to be queried" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "has_feature",
        MODULE_TECHNOLOGY,
        "check technology features",
        "Check if the chosen technology supports a certain feature. "
        "Currently available features: 'has_gatecut', 'allow_poly_routing', 'is_soi'.",
        "if technology.has_feature(\"has_gatecut\") then\n    -- do something with gatecuts\nend",
        parameters
    ));
}

/* technology.has_layer */
{
    struct parameter parameters[] = {
        { "layerfunction",  FUNCTION,   NULL, "generic layer function which should be called as check" },
        { "...",            VARARGS,    NULL, "arguments to the generics layer function" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "has_layer",
        MODULE_TECHNOLOGY,
        "check technology layers",
        "Check if the chosen technology supports a certain layer.",
        "if technology.has_layer(generics.other, \"gatecut\") then\n    -- do something with gatecuts\nend",
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
        "check multiple patterning support/requirements",
        "Check if the chosen metal layer (represented by the metal index) supports multiple patterning.",
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
        "check if a metal index is available",
        "Check if the given metal layer is within the range of available metal layers. "
        "Negative numbers are resolved as in generics.metal.",
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
        "get the number of masks for a given metal",
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
        "resolve negative metal indices",
        "Resolve negative metal indices to their 'real' value (e.g. in a metal stack with five metals -1 becomes 5, -3 becomes 3). "
        "This function does not do anything if the index is positive",
        "local metalindex = technology.resolve_metal(-2)",
        parameters
    ));
}

/* technology.metal_layer_to_index */
{
    struct parameter parameters[] = {
        { "layer", GENERICS, NULL, "metal layer to be mapped to its index" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "metal_layer_to_index",
        MODULE_TECHNOLOGY,
        "convert a metal layer to its positive index",
        "Retrieve the numeric index of a metal layer. "
        "The function always returns positive indices. "
        "If a non-metal layer is given, the function returns 0.",
        "local metalindex = technology.metal_layer_to_index(generics.metal(2)) -- 2",
        parameters
    ));
}

/* technology.get_number_of_metals */
{
    struct parameter parameters[] = {
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "get_number_of_metals",
        MODULE_TECHNOLOGY,
        "get the number of metals",
        "Get the number of metals in the layer stack. "
        "This value is given in the configuration file of a technology node.",
        "local nummetals = technology.get_number_of_metals()",
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
        "list the current technology paths",
        "technology.list_techpaths()",
        parameters
    ));
}
