/* generics.metal */
{
    struct parameter parameters[] = {
        { "index", INTEGER, NULL, "metal index" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "metal",
        MODULE_GENERICS,
        "create a metal layer",
        "Create a generic layer representing a metal. Metals are identified by numeric indices, where 1 denotes the first metal, 2 the second one etc. Metals can also be identified by negative indicies, where -1 denotes the top-most metal, -2 the metal below that etc.",
        "generics.metal(1)\ngenerics.metal(-2)",
        parameters
    ));
}

/* generics.mptmetal*/
{
    struct parameter parameters[] = {
        { "index",      INTEGER, NULL, "metal index" },
        { "maskindex",  INTEGER, NULL, "mask index" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "mptmetal",
        MODULE_GENERICS,
        "create a metal layer with multiple-patterning support",
        "Create a generic layer representing a metal with multiple-patterning (mpt) information. Metals are identified by numeric indices, where 1 denotes the first metal, 2 the second one etc. Metals can also be identified by negative indicies, where -1 denotes the top-most metal, -2 the metal below that etc. The mask information is a numeric indix starting at 1. The number of available masks for the respective metal can be queried by technology.multiple_patterning_number(metalnumber). Whether a metal is a mpt metal can be queried by technology.has_multiple_patterning(metalnumber)",
        "generics.mptmetal(1, 1)\ngenerics.mptmetal(1, 2)",
        parameters
    ));
}

/* generics.metalport */
{
    struct parameter parameters[] = {
        { "index", INTEGER, NULL, "metal index" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "metalport",
        MODULE_GENERICS,
        "create a metal port layer",
        "Create a generic layer representing a metal port. Metals are identified by numeric indices, where 1 denotes the first metal, 2 the second one etc. Metals can also be identified by negative indicies, where -1 denotes the top-most metal, -2 the metal below that etc.",
        "generics.metalport(1)\ngenerics.metalport(-2)",
        parameters
    ));
}

/* generics.metalfill */
{
    struct parameter parameters[] = {
        { "index", INTEGER, NULL, "metal index" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "metalfill",
        MODULE_GENERICS,
        "create a metal fill layer",
        "Create a generic layer representing a metal fill. Some technologies have special layer for metal fillings, but technology files can also map these to the same layers as generics.metal(). Metals are identified by numeric indices, where 1 denotes the first metal, 2 the second one etc. Metals can also be identified by negative indicies, where -1 denotes the top-most metal, -2 the metal below that etc.",
        "generics.metalfill(1)\ngenerics.metalfill(-2)",
        parameters
    ));
}

/* generics.mptmetalfill*/
{
    struct parameter parameters[] = {
        { "index",      INTEGER, NULL, "metal index" },
        { "maskindex",  INTEGER, NULL, "mask index" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "mptmetalfill",
        MODULE_GENERICS,
        "create a metal fill layer with multiple-patterning support",
        "Create a generic layer representing a metal fill shape with multiple-patterning (mpt) information. Some technologies have special layer for metal fillings, but technology files can also map these to the same layers as generics.metal(). Metals are identified by numeric indices, where 1 denotes the first metal, 2 the second one etc. Metals can also be identified by negative indicies, where -1 denotes the top-most metal, -2 the metal below that etc. The mask information is a numeric indix starting at 1. The number of available masks for the respective metal can be queried by technology.multiple_patterning_number(metalnumber). Whether a metal is a mpt metal can be queried by technology.has_multiple_patterning(metalnumber)",
        "generics.mptmetal(1, 1)\ngenerics.mptmetal(1, 2)",
        parameters
    ));
}

/* generics.metalexclude */
{
    struct parameter parameters[] = {
        { "index", INTEGER, NULL, "metal index" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "metalexclude",
        MODULE_GENERICS,
        "create a metal fill exclude layer",
        "Create a generic layer representing a metal exclude where automatic filling is blocked. Metals are identified by numeric indices, where 1 denotes the first metal, 2 the second one etc. Metals can also be identified by negative indicies, where -1 denotes the top-most metal, -2 the metal below that etc.",
        "generics.metalexclude(1)\ngenerics.metalexclude(-2)",
        parameters
    ));
}

/* generics.viacut */
{
    struct parameter parameters[] = {
        { "m1index", INTEGER, NULL, "first metal index" },
        { "m2index", INTEGER, NULL, "second metal index" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "viacut",
        MODULE_GENERICS,
        "create a via cut layer between two metals",
        "Create a generic layer representing a via cut. This does not calculate the right size for the via cuts. This function is rarely used directly. Via cuts are generated by geometry.via[bltr]. If you are using this function as a user, it is likely you are doing something wrong",
        "generics.viacut(1, 2)",
        parameters
    ));
}

/* generics.contact */
{
    struct parameter parameters[] = {
        { "region", STRING, NULL, "region which should be contacted. Possible values: \"sourcedrain\", \"gate\" and \"active\"" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "contact",
        MODULE_GENERICS,
        "create a contact layer between an FEOL and a BEOL layer",
        "Create a generic layer representing a contact. "
        "This does not calculate the right size for the contact cuts. "
        "This function is rarely used directly. "
        "Contact cuts are generated by geometry.contact[bltr]. "
        "If you are using this function as a user, it is likely you are doing something wrong. "
        "Supported parameters for this function are 'active', 'poly', 'gate' and 'sourcedrain'.",
        "generics.contact(\"gate\")",
        parameters
    ));
}

/* generics.oxide */
{
    struct parameter parameters[] = {
        { "index", INTEGER, NULL, "oxide thickness index. Conventionally starts with 1, but depends on the technology mapping" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "oxide",
        MODULE_GENERICS,
        "create an oxide thickness modification layer",
        "Create a generic layer representing a marking layer for MOSFET gate oxide thickness (e.g. for core or I/O devices).",
        "generics.oxide(2)",
        parameters
    ));
}

/* generics.implant */
{
    struct parameter parameters[] = {
        { "polarity", STRING, NULL, "identifier for the type (polarity) of the implant. Can be \"n\" or \"p\"" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "implant",
        MODULE_GENERICS,
        "create an p-type or n-type implant layer",
        "Create a generic layer representing MOSFET source/drain implant polarity.",
        "generics.implant(\"n\")",
        parameters
    ));
}

/* generics.well */
{
    struct parameter parameters[] = {
        { "polarity", STRING, NULL, "identifier for the type (polarity) of the well. Can be \"n\" or \"p\"" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "well",
        MODULE_GENERICS,
        "create an n-well or p-well layer",
        "Create a generic layer representing a well.",
        "generics.well(\"n\")",
        parameters
    ));
}

/* generics.vthtype */
{
    struct parameter parameters[] = {
        { "index", INTEGER, NULL, "threshold voltage marking layer index. Conventionally starts with 1, but depends on the technology mapping" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "vthtype",
        MODULE_GENERICS,
        "Create a MOSFET threshold voltage modification layer",
        "Create a generic layer representing MOSFET source/drain threshold voltage marking layers (a channel implant).",
        "generics.vthtype(2)",
        parameters
    ));
}

/* generics.active */
{
    struct parameter parameters[] = {
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "active",
        MODULE_GENERICS,
        "Create an 'active' layer",
        "Create a generic layer representing active area, for instance for mosfets.",
        "generics.active()",
        parameters
    ));
}

/* generics.gate */
{
    struct parameter parameters[] = {
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "gate",
        MODULE_GENERICS,
        "Create a 'gate' layer",
        "Create a generic layer representing gate area of mosfets.",
        "generics.gate()",
        parameters
    ));
}

/* generics.feol */
{
    struct parameter parameters[] = {
        { "identifier", STRING, NULL, "layer identifier" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "feol",
        MODULE_GENERICS,
        "create a generic front-end-of-line layer",
        "Create a front-end-of-line layer. This is for layers that do not need special processing, such as \"silicideblocker\".",
        "generics.feol(\"gate\")",
        parameters
    ));
}

/* generics.beol */
{
    struct parameter parameters[] = {
        { "identifier", STRING, NULL, "layer identifier" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "beol",
        MODULE_GENERICS,
        "create a generic back-end-of-line layer",
        "Create a back-end-of-line layer. This is for layers that do not need special processing, such as \"padopening\".",
        "generics.beol(\"gate\")",
        parameters
    ));
}

/* generics.marker */
{
    struct parameter parameters[] = {
        { "type",   STRING,   NULL, "type of the marker (e.g. a generic lvs marker or an inductor marker)" },
        { "level",  INTEGER,  "0",  "optional level of the marker. If not present, this marker is considered to have no level (for instance, there might only be one marker for inductors)." },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "marker",
        MODULE_GENERICS,
        "create a generic marker layer",
        "Create a generic layer representing any marker (a non-physical layer).",
        "generics.marker(\"inductor\")\ngenerics.marker(\"lvs\", 2)",
        parameters
    ));
}


/* generics.devicelabel */
{
    struct parameter parameters[] = {
        { "type",   STRING,   NULL, "type of the devicelabel (e.g. a label marking devices for specific LVS use cases)" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "devicelabel",
        MODULE_GENERICS,
        "create a generic device-marking layer",
        "Create a generic device-marking layer (a non-physical layer, used for labels).",
        "generics.devicelabel(\"resistancelevel2\")\ngenerics.marker(\"specialmosfet\")",
        parameters
    ));
}

/* generics.exclude */
{
    struct parameter parameters[] = {
        { "identifier", STRING, NULL, "exclude layer identifier" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "exclude",
        MODULE_GENERICS,
        "create a generic fill exclude layer",
        "Create a generic layer representing an exclude where automatic filling is blocked.",
        "generics.exclude(\"gate\")",
        parameters
    ));
}

/* generics.fill */
{
    struct parameter parameters[] = {
        { "identifier", STRING, NULL, "fill layer identifier" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "fill",
        MODULE_GENERICS,
        "create a generic fill layer",
        "Create a generic layer representing a fill. Some technologies have special layer for fillings, but technology files can also map these to the same layers with their main purposes.",
        "generics.fill(\"gate\")",
        parameters
    ));
}

/* generics.other */
{
    struct parameter parameters[] = {
        { "identifier", STRING, NULL, "layer identifier" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "other",
        MODULE_GENERICS,
        "create a generic 'anything' layer",
        "Create a generic layer representing 'something else'. "
        "This is for layers that are special to the used technology node and should not be used for generic layout representation. "
        "It is best to avoid this layer as much as possible.",
        "generics.other(\"somespecialfoundrylayer\")",
        parameters
    ));
}

/* generics.otherport */
{
    struct parameter parameters[] = {
        { "identifier", STRING, NULL, "layer identifier" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "otherport",
        MODULE_GENERICS,
        "create a generic 'anything' port layer",
        "Create a generic layer representing a port for 'something else'. "
        "This is for layers that are special to the used technology node and should not be used for generic layout representation. "
        "It is best to avoid this layer as much as possible.",
        "generics.otherport(\"somespecialfoundrylayer\")",
        parameters
    ));
}

/* generics.outline */
{
    struct parameter parameters[] = {
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "outline",
        MODULE_GENERICS,
        "create an outline layer",
        "Create a generic layer representing a block outline.",
        "generics.outline()",
        parameters
    ));
}

/* generics.special */
{
    struct parameter parameters[] = {
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "special",
        MODULE_GENERICS,
        "create a 'special' layer",
        "Create a 'special' layer. This is used to mark certain things in layouts (usually for debugging, like anchors or alignment boxes). This is not intended to translate to any meaningful layer for fabrication",
        "generics.special()",
        parameters
    ));
}

/* generics.premapped */
{
    struct parameter parameters[] = {
        { "name",       STRING, NULL, "layer name. Can be nil" },
        { "entries",    TABLE,  NULL, "key-value pairs for the entries" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "premapped",
        MODULE_GENERICS,
        "Create an already-mapped layer with technology-specific data",
        "Create a non-generic layer from specific layer data for a certain technology. "
        "The entries table should contain one table per supported export. "
        "The supplied key-value pairs in this table must match the key-value pairs that are expected by the export"
        "This layer is mostly useful in auto-generated opc layouts, that are (for instance) generated from virtuoso. "
        "The virtuoso export or the GDS import modules uses these for representing layers where no semantic information is available.",
        "generics.premapped(\"specialmetal\", { gds = { layer = 32, purpose = 17 }, SKILL = { layer = \"specialmetal\", purpose = \"drawing\" } })",
        parameters
    ));
}

