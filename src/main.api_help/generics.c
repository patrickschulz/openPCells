/* generics.contact */
{
    struct parameter parameters[] = {
        { "region", STRING, NULL, "region which should be contacted. Possible values: \"sourcedrain\", \"gate\" and \"active\"" }
    };
    vector_append(entries, _make_api_entry(
        "contact",
        MODULE_GENERICS,
        "create a generic layer representing a contact. This does not calculate the right size for the contact cuts. This function is rarely used directly. Contact cuts are generated by geometry.contact[bltr]. If you are using this function as a user, it is likely you are doing something wrong",
        "generics.contact(\"gate\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* generics.implant */
{
    struct parameter parameters[] = {
        { "polarity", STRING, NULL, "identifier for the type (polarity) of the implant. Can be \"n\" or \"p\"" }
    };
    vector_append(entries, _make_api_entry(
        "implant",
        MODULE_GENERICS,
        "Create a generic layer representing MOSFET source/drain implant polarity",
        "generics.implant(\"n\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* generics.metal */
{
    struct parameter parameters[] = {
        { "index", INTEGER, NULL, "metal index" }
    };
    vector_append(entries, _make_api_entry(
        "metal",
        MODULE_GENERICS,
        "create a generic layer representing a metal. Metals are identified by numeric indices, where 1 denotes the first metal, 2 the second one etc. Metals can also be identified by negative indicies, where -1 denotes the top-most metal, -2 the metal below that etc.",
        "generics.metal(1)\ngenerics.metal(-2)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* generics.metalexclude */
{
    struct parameter parameters[] = {
        { "index", INTEGER, NULL, "metal index" }
    };
    vector_append(entries, _make_api_entry(
        "metalexclude",
        MODULE_GENERICS,
        "create a generic layer representing a metal exclude where automatic filling is blocked. Metals are identified by numeric indices, where 1 denotes the first metal, 2 the second one etc. Metals can also be identified by negative indicies, where -1 denotes the top-most metal, -2 the metal below that etc.",
        "generics.metalexclude(1)\ngenerics.metalexclude(-2)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* generics.metalfill */
{
    struct parameter parameters[] = {
        { "index", INTEGER, NULL, "metal index" }
    };
    vector_append(entries, _make_api_entry(
        "metalfill",
        MODULE_GENERICS,
        "create a generic layer representing a metal fill. Some technologies have special layer for metal fillings, but technology files can also map these to the same layers as generics.metal(). Metals are identified by numeric indices, where 1 denotes the first metal, 2 the second one etc. Metals can also be identified by negative indicies, where -1 denotes the top-most metal, -2 the metal below that etc.",
        "generics.metalfill(1)\ngenerics.metalfill(-2)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* generics.metalport */
{
    struct parameter parameters[] = {
        { "index", INTEGER, NULL, "metal index" }
    };
    vector_append(entries, _make_api_entry(
        "metalport",
        MODULE_GENERICS,
        "create a generic layer representing a metal port. Metals are identified by numeric indices, where 1 denotes the first metal, 2 the second one etc. Metals can also be identified by negative indicies, where -1 denotes the top-most metal, -2 the metal below that etc.",
        "generics.metalport(1)\ngenerics.metalport(-2)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* generics.mptmetal*/
{
    struct parameter parameters[] = {
        { "index",      INTEGER, NULL, "metal index" },
        { "maskindex",  INTEGER, NULL, "mask index" }
    };
    vector_append(entries, _make_api_entry(
        "mptmetal",
        MODULE_GENERICS,
        "create a generic layer representing a metal with multiple-patterning information. Metals are identified by numeric indices, where 1 denotes the first metal, 2 the second one etc. Metals can also be identified by negative indicies, where -1 denotes the top-most metal, -2 the metal below that etc. The mask information is a numeric indix starting at 1. The number of available masks for the respective metal can be querid by technology.multiple_patterning_number(metalnumber). If a metal is a mpt metal can be queried by technology.has_multiple_patterning(metalnumber)",
        "generics.mptmetal(1, 1)\ngenerics.mptmetal(1, 2)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* generics.mptmetalfill*/
{
    struct parameter parameters[] = {
        { "index",      INTEGER, NULL, "metal index" },
        { "maskindex",  INTEGER, NULL, "mask index" }
    };
    vector_append(entries, _make_api_entry(
        "mptmetalfill",
        MODULE_GENERICS,
        "create a generic layer representing a metal fill shape with multiple-patterning information. Some technologies have special layer for metal fillings, but technology files can also map these to the same layers as generics.metal(). Metals are identified by numeric indices, where 1 denotes the first metal, 2 the second one etc. Metals can also be identified by negative indicies, where -1 denotes the top-most metal, -2 the metal below that etc. The mask information is a numeric indix starting at 1. The number of available masks for the respective metal can be querid by technology.multiple_patterning_number(metalnumber). If a metal is a mpt metal can be queried by technology.has_multiple_patterning(metalnumber)",
        "generics.mptmetal(1, 1)\ngenerics.mptmetal(1, 2)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* generics.other */
{
    struct parameter parameters[] = {
        { "identifier", STRING, NULL, "layer identifier" }
    };
    vector_append(entries, _make_api_entry(
        "other",
        MODULE_GENERICS,
        "create a generic layer representing 'something else'. This is for layers that do not need special processing, such as \"gate\"",
        "generics.other(\"gate\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* generics.otherport */
{
    struct parameter parameters[] = {
        { "identifier", STRING, NULL, "layer identifier" }
    };
    vector_append(entries, _make_api_entry(
        "otherport",
        MODULE_GENERICS,
        "create a generic layer representing a port for 'something else'. This is for layers that do not need special processing, such as \"gate\"",
        "generics.otherport(\"gate\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* generics.outline */
{
    struct parameter parameters[] = {
    };
    vector_append(entries, _make_api_entry(
        "outline",
        MODULE_GENERICS,
        "create a generic layer representing a block outline",
        "generics.outline()",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* generics.oxide */
{
    struct parameter parameters[] = {
        { "index", INTEGER, NULL, "oxide thickness index. Conventionally starts with 1, but depends on the technology mapping" }
    };
    vector_append(entries, _make_api_entry(
        "oxide",
        MODULE_GENERICS,
        "create a generic layer representing a marking layer for MOSFET gate oxide thickness (e.g. for core or I/O devices)",
        "generics.oxide(2)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* generics.premapped */
{
    struct parameter parameters[] = {
        { "name",       STRING, NULL, "layer name. Can be nil" },
        { "entries",    TABLE,  NULL, "key-value pairs for the entries" },
    };
    vector_append(entries, _make_api_entry(
        "premapped",
        MODULE_GENERICS,
        "Create a non-generic layer from specific layer data for a certain technology. The entries table should contain one table per supported export. The supplied key-value pairs in this table must match the key-value pairs that are expected by the export",
        "generics.premapped(\"specialmetal\", { gds = { layer = 32, purpose = 17 }, SKILL = { layer = \"specialmetal\", purpose = \"drawing\" } })",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* generics.special */
{
    struct parameter parameters[] = {
    };
    vector_append(entries, _make_api_entry(
        "special",
        MODULE_GENERICS,
        "Create a 'special' layer. This is used to mark certain things in layouts (usually for debugging, like anchors or alignment boxes). This is not intended to translate to any meaningful layer for fabrication",
        "generics.special()",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* generics.viacut */
{
    struct parameter parameters[] = {
        { "m1index", INTEGER, NULL, "first metal index" },
        { "m2index", INTEGER, NULL, "second metal index" }
    };
    vector_append(entries, _make_api_entry(
        "viacut",
        MODULE_GENERICS,
        "create a generic layer representing a via cut. This does not calculate the right size for the via cuts. This function is rarely used directly. Via cuts are generated by geometry.via[bltr]. If you are using this function as a user, it is likely you are doing something wrong",
        "generics.viacut(1, 2)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* generics.vthtype */
{
    struct parameter parameters[] = {
        { "index", INTEGER, NULL, "threshold voltage marking layer index. Conventionally starts with 1, but depends on the technology mapping" }
    };
    vector_append(entries, _make_api_entry(
        "vthtype",
        MODULE_GENERICS,
        "Create a generic layer representing MOSFET source/drain threshold voltage marking layers",
        "generics.vthtype(2)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

