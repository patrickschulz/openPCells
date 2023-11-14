/* placement.create_floorplan_aspectratio */
{
    struct parameter parameters[] = {
        { "instances",      TABLE,      NULL,   "instances table" },
        { "utilization",    NUMBER,     NULL,   "utilization factor, must be between 0 and 1" },
        { "aspectration",   NUMBER,     NULL,   "aspectratio (width / height) of the floorplan" }
    };
    vector_append(entries, _make_api_entry(
        "create_floorplan_aspectratio",
        MODULE_PLACEMENT,
        "create a floorplan configuration based on utilization and an aspectratio. The 'instances' table is the result of parsing and processing verilog netlists. This function is intended to be called in a place-and-route-script for --import-verilog",
        "local floorplan = placement.create_floorplan_aspectratio(instances, 0.8, 2 / 1)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* placement.create_floorplan_fixed_rows */
{
    struct parameter parameters[] = {
        { "instances",      TABLE,      NULL,   "instances table" },
        { "utilization",    NUMBER,     NULL,   "utilization factor, must be between 0 and 1" },
        { "rows",           INTEGER,    NULL,   "number of rows" }
    };
    vector_append(entries, _make_api_entry(
        "create_floorplan_fixed_rows",
        MODULE_PLACEMENT,
        "create a floorplan configuration based on utilization and a fixed number of rows. The 'instances' table is the result of parsing and processing verilog netlists. This function is intended to be called in a place-and-route-script for --import-verilog",
        "local floorplan = placement.create_floorplan_fixed_rows(instances, 0.8, 20)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* placement.optimize */
{
    struct parameter parameters[] = {
        { "instances",      TABLE,      NULL,   "instances table" },
        { "nets",           TABLE,      NULL,   "nets table" },
        { "floorplan",      TABLE,      NULL,   "floorplan configuration" }
    };
    vector_append(entries, _make_api_entry(
        "optimize",
        MODULE_PLACEMENT,
        "minimize wire length by optimizing the placement of the instances by a simulated annealing algorithm. This function returns a table with the rows and columns of the placement of the instances. It is intended to be called in a place-and-route-script for --import-verilog",
        "local rows = placement.optimize(instances, nets, floorplan)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* placement.manual */
{
    struct parameter parameters[] = {
        { "instances",      TABLE,      NULL,   "instances table" },
        { "plan",           TABLE,      NULL,   "row-column table" }
    };
    vector_append(entries, _make_api_entry(
        "manual",
        MODULE_PLACEMENT,
        "create a placement of instances manually. This function expects a row-column table with all instance names. Thus the instance names must match the ones found in the instances table (from the verilog netlist). This function then updates all required references in the row-column table, that are needed for further processing (e.g. routing). This function is useful for small designs, especially in a hierarchical flow",
        "local plan = {\n    { \"inv\", \"nand1\", \"dff_out\" },\n    { \"nand2\", \"dff_buf\" },\n    { \"nand3\", \"dff_in\" },\n}\nlocal rows = placement.manual(instances, plan)\n",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])));
}

/* placement.insert_filler_names */
{
    struct parameter parameters[] = {
        { "rows",   TABLE,      NULL,   "placement rows table" },
        { "width",  INTEGER,    NULL,   "width as multiple of transistor gates. Must be equal to or larger than every row" }
    };
    vector_append(entries, _make_api_entry(
        "insert_filler_names",
        MODULE_PLACEMENT,
        // help text
        "equalize placement rows by inserting fillers in every row."
        "The method tries to equalize spacing between cells."
        "This function is intended to be called in a place-and-route-script for --import-verilog",
        // example
        "placement.insert_filler_names(rows, 200)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* placement.create_reference_rows */
{
    struct parameter parameters[] = {
        { "cellnames",  TABLE,      NULL,   "row placement table with cellnames" },
        { "xpitch",     INTEGER,    NULL,   "minimum cell pitch in x direction" }
    };
    vector_append(entries, _make_api_entry(
        "create_reference_rows",
        MODULE_PLACEMENT,
        // help text
        "prepare a row placement table for further placement functions by parsing a definition given in 'cellnames'."
        "This table contains the individual rows of the placment, which every row consiting of individual cells."
        "Cell entries can either be given by just the name of the standard cell (the 'reference') or the instance name ('instance') and the reference name ('reference')"
        "This function is meant to be used in pcell definitions"
        ,
        // example
        "-- un-named mode:\n"
        "local rows = placement.create_reference_rows({\n"
        "    { \"inv\", \"nand1\", \"dff_out\" },\n"
        "    { \"nand2\", \"dff_buf\" },\n"
        "    { \"nand3\", \"dff_in\" },\n"
        "})\n\n"
        "-- named mode:\n"
        "local rows = placement.create_reference_rows({\n"
        "    { { name = \"inv0\", reference = \"not_gate\" }, { name = \"nand1\", reference = \"nand_gate\" }, { name = \"dff_out\", reference = \"dffpq\" } },\n"
        "    { { name = \"nand2\", reference = \"nand_gate\" }, { name = \"dff_buf\", reference = \"dffpq\" } },\n"
        "    { { name = \"nand3\", reference = \"nand_gate\" }, { name = \"dff_in\", reference = \"dffpq\" } },\n"
        "})",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* placement.digital */ // FIXME: digital
{
    struct parameter parameters[] = {

    };
    vector_append(entries, _make_api_entry(
        "digital",
        MODULE_PLACEMENT,
        "",
        "",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* placement.rowwise */
{
    struct parameter parameters[] = {
        { "parent",     OBJECT,     NULL,       "parent cell to place cells in" },
        { "cellsdef",   TABLE,      NULL,       "cells definition containing rows with entries for 'reference' (an object) and 'instance' (an instance name, must be unique)" },
        { "flipfirst",  BOOLEAN,    "false",    "flip the first row" },
        { "noflip",     BOOLEAN,    "false",    "don't flip cells when advancing a row (useful for standard cell blocks that occupy an even number of rows)" }
    };
    vector_append(entries, _make_api_entry(
        "rowwise",
        MODULE_PLACEMENT,
        "place cells in a row-wise manner in a parent cell. The cells definition contains definitions for every row, which in turn contain entries with two keys: 'reference' (an object) and 'instance' (an instance name). The placed cells are aligned by their alignment boxes and grow into the upper-right direction. This means that the first entry in the first row is the bottom-left-most cell. This function is useful for digital standard cell layouts (and in fact called by placement.digital, which offers a more high-level interface), but it can also be useful for regular analog structures",
        "local celldef = {\n    { -- first row (bottom)\n        { reference = someobject, instance = \"instance_1_1\" },\n        { reference = someobject, instance = \"instance_1_2\" },\n    },\n    { -- second row\n        { reference = someotherobject, instance = \"instance_2_1\" },\n        { reference = someotherobject, instance = \"instance_2_2\" },\n    }\n}\nplacement.rowwise(parent, cellsdef)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* placement.rowwise_flat */
{
    struct parameter parameters[] = {
        { "parent",     OBJECT,     NULL,       "parent cell to place cells in" },
        { "cellsdef",   TABLE,      NULL,       "cells definition containing rows with entries for 'reference' (an object) and 'instance' (an instance name, must be unique)" },
        { "flipfirst",  BOOLEAN,    "false",    "flip the first row" },
        { "noflip",     BOOLEAN,    "false",    "don't flip cells when advancing a row (useful for standard cell blocks that occupy an even number of rows)" }
    };
    vector_append(entries, _make_api_entry(
        "rowwise_flat",
        MODULE_PLACEMENT,
        "like placement.rowwise, but merges cells into parents (flat)",
        "local celldef = {\n    { -- first row (bottom)\n        { reference = someobject, instance = \"instance_1_1\" },\n        { reference = someobject, instance = \"instance_1_2\" },\n    },\n    { -- second row\n        { reference = someotherobject, instance = \"instance_2_1\" },\n        { reference = someotherobject, instance = \"instance_2_2\" },\n    }\n}\nplacement.rowwise_flat(parent, cellsdef)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}


/* list of all modules and functions in the global table that are not documented (needs to be checked):

    FIXME: placement.place_within_boundary
    FIXME: placement.place_within_boundary_merge
    FIXME: placement.place_within_rectangular_boundary

 */
