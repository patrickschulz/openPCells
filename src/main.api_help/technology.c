/* technology.get_dimension */
{
    struct parameter parameters[] = {
        { "property", STRING, NULL, "technology property name" }
    };
    vector_append(entries, _make_api_entry(
        "get_dimension",
        MODULE_TECHNOLOGY,
        "Get critical technology dimensions such as minimum metal width. Predominantly used in pcell parameter definitions, but not necessarily restricted to that. There is a small set of technology properties that are used in the standard opc cells, but there is currently no proper definitions of the supported fields. See basic/mosfet and basic/cmos for examples",
        "function parameters()\n    pcell.add_parameters({ {\"width\", technology.get_dimension(\"Minimum M1 Width\") } })\nend",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* technology.has_layer */
{
    struct parameter parameters[] = {
        { "layer", GENERICS, NULL, "generic layer which should be checked" }
    };
    vector_append(entries, _make_api_entry(
        "has_layer",
        MODULE_TECHNOLOGY,
        "Check if the chosen technology supports a certain layer",
        "if technology.has_layer(generics.other(\"gatecut\")) then\n    -- do something with gatecuts\nend",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* technology.resolve_metal */
{
    struct parameter parameters[] = {
        { "index", INTEGER, NULL, "metal index to be resolved" }
    };
    vector_append(entries, _make_api_entry(
        "resolve_metal",
        MODULE_TECHNOLOGY,
        "resolve negative metal indices to their 'real' value (e.g. in a metal stack with five metals -1 becomes 5, -3 becomes 3). This function does not do anything if the index is positive",
        "local metalindex = technology.resolve_metal(-2)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/*
    FIXME:
	technology.has_multiple_patterning
	technology.list_techpaths
	technology.multiple_patterning_number
*/
