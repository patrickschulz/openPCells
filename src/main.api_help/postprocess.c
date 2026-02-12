/* postprocess.remove_layer_shapes */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "top-level cell" },
        { "layer",  GENERICS,   NULL, "layer" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "remove_layer_shapes",
        MODULE_POSTPROCESS,
        "remove shapes on a given layer in a cell hierarchy",
        "Remove shapes on a given layer in a cell hierarchy. "
        "This function traverses through the cell hierarchy and removes shapes in every referenced cell.",
        "postprocess.remove_layer_shapes(cell, generics.metal(1))",
        parameters
    ));
}

/* postprocess.remove_layer_shapes_flat */
{
    struct parameter parameters[] = {
        { "cell",   OBJECT,     NULL, "top-level cell" },
        { "layer",  GENERICS,   NULL, "layer" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "remove_layer_shapes_flat",
        MODULE_POSTPROCESS,
        "remove shapes on a given layer in a cell (flat variant)",
        "Remove shapes on a given layer in a cell. "
        "This function only and shapes in the given cell, without traversing through the cell hierarchy.",
        "postprocess.remove_layer_shapes_flat(cell, generics.metal(1))",
        parameters
    ));
}

