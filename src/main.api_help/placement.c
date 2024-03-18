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
        { "flip",       BOOLEAN,    "false",    "flip cells when advancing a row (useful for standard cell blocks)" },
        { "flipfirst",  BOOLEAN,    "false",    "flip the first row" }
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
        { "flip",       BOOLEAN,    "false",    "flip cells when advancing a row (useful for standard cell blocks)" },
        { "flipfirst",  BOOLEAN,    "false",    "flip the first row" }
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

/* placement.place_at_origins */
{
    struct parameter parameters[] = {
        { "toplevel",       OBJECT,     NULL,   "toplevel cell to place cells in" },
        { "cell",           OBJECT,     NULL,   "cell which will be placed in the toplevel cell" },
        { "basename",       STRING,     NULL,   "basename for the instance names" },
        { "origins",        POINTLIST,  NULL,   "origins where cells are placed" }
    };
    vector_append(entries, _make_api_entry(
        "place_at_origins",
        MODULE_PLACEMENT,
        "place cells in a toplevel cells at the specified origins. The instances are named accordingly to the basename (with _1, _2, etc. appended). This is a more low-level placement function (compared to placement.place_within_boundary), which is called by the higher-level functions. In some cases, using this function directly can be useful. The function returns all placed children in a table.",
        "local origins = {\n    point.create(0, -10000),\n    point.create(0, 10000),\n    point.create(0, 20000),\n    point.create(0, 30000)\n}\nplacement.place_at_origins(toplevel, filler, \"fill\", origins)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* placement.place_on_grid */
{
    struct parameter parameters[] = {
        { "toplevel",   OBJECT,     NULL,   "toplevel cell to place cells in" },
        { "cell",       OBJECT,     NULL,   "cell which will be placed in the toplevel cell" },
        { "basename",   STRING,     NULL,   "basename for the instance names" },
        { "basept",     POINT,      NULL,   "base point for the grid placement" },
        { "xpitch",     INTEGER,    NULL,   "x-pitch of the cell (can be negative)" },
        { "ypitch",     INTEGER,    NULL,   "y-pitch of the cell (can be negative)" },
        { "grid",       TABLE,      NULL,   "two-dimensional table defining the grid (with '0' or '1' entries)" }
    };
    vector_append(entries, _make_api_entry(
        "place_on_grid",
        MODULE_PLACEMENT,
        "place cells in a toplevel cells corresponding to the given grid. The instances are named accordingly to the basename (with _1, _2, etc. appended). This function is a convenient low-level wrapper for placement.place_at_origins, where the individual points don't have to be typed out. The function returns all placed children in a table.",
        "local grid = {\n    { 0, 1, 1 }\n    { 1, 1, 1 },\n    { 0, 0, 1 },\n}\nplacement.place_on_grid(toplevel, cell, \"cell\", point.create(0, 0), 100, 100, grid)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* placement.place_within_boundary */
{
    struct parameter parameters[] = {
        { "toplevel",       OBJECT,     NULL,   "toplevel cell to place cells in" },
        { "cell",           OBJECT,     NULL,   "cell which will be placed in the toplevel cell" },
        { "basename",       STRING,     NULL,   "basename for the instance names" },
        { "targetarea",     POINTLIST,  NULL,   "target area (a polygon)" },
        { "excludes",       TABLE,      "{}",   "optional list of polygons with fill excludes" }
    };
    vector_append(entries, _make_api_entry(
        "place_within_boundary",
        MODULE_PLACEMENT,
        "automatically place a cell multiple times in a toplevel cell. The cell instances will be placed in the given target area and given names based on the given basename. An optional table can hold list of points (polygons), which describe areas that should not be filled. The x- and y-pitch of the cell are inferred from the alignment box. The function returns all placed children in a table.",
        "local targetarea = {\n    point.create(-10000, -10000),\n    point.create(10000, -10000),\n    point.create(10000, 10000),\n    point.create(-10000, 10000)\n} local excludes = { {\n    point.create(-2000, -2000),\n    point.create(2000, -2000),\n    point.create(2000, 2000),\n    point.create(-2000, 2000)\n}, -- possibly more exludes after this }\nplacement.place_with_boundary(toplevel, filler, \"fill\", targetarea, excludes)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* placement.place_within_boundary_merge */
{
    struct parameter parameters[] = {
        { "toplevel",       OBJECT,     NULL,       "toplevel cell to place cells in" },
        { "cell",           OBJECT,     NULL,       "cell which will be placed in the toplevel cell" },
        { "targetarea",     POINTLIST,  NULL,       "target area (a polygon)" },
        { "excludes",       TABLE,      "false",    "optional list of polygons with fill excludes" }
    };
    vector_append(entries, _make_api_entry(
        "place_within_boundary_merge",
        MODULE_PLACEMENT,
        "same as placement.place_with_boundary, but merges the cells (instead of adding them as children). Since only children need instance names, the 'basename' parameter is not present for this function",
        "local targetarea = {\n    point.create(-10000, -10000),\n    point.create(10000, -10000),\n    point.create(10000, 10000),\n    point.create(-10000, 10000)\n} local excludes = { {\n    point.create(-2000, -2000),\n    point.create(2000, -2000),\n    point.create(2000, 2000),\n    point.create(-2000, 2000)\n}, -- possibly more exludes after this }\nplacement.place_with_boundary_merge(toplevel, filler, targetarea, excludes)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* placement.place_within_rectangular_boundary */
{
    struct parameter parameters[] = {
        { "toplevel",   OBJECT, NULL,   "toplevel cell to place cells in" },
        { "cell",       OBJECT, NULL,   "cell which will be placed in the toplevel cell" },
        { "basename",   STRING, NULL,   "basename for the instance names" },
        { "targetbl",   POINT,  NULL,   "bottom-left corner point of target area" },
        { "targettr",   POINT,  NULL,   "top-right corner point of target area" }
    };
    vector_append(entries, _make_api_entry(
        "place_within_rectangular_boundary",
        MODULE_PLACEMENT,
        "place fill in a rectangular boundary. This function behaves like placement.place_with_boundary, but it takes the corner points (bottom-left and top-right) as inputs. Furthermore, no excludes are accepted. This means that the entire rectangular boundary is filled. This function is magnitudes faster than placement.place_with_boundary (as no point-in-polygon checks are required and a more efficient data representation for the resulting array can be used), so consider using this function if no excludes are required.",
        "local targetbl = point.create(-10000, -10000)\nlocal targettr = point.create(10000, 10000)\nplacement.place_with_rectangular_boundary(toplevel, filler, \"fill\", targetbl, targettr)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* placement.place_within_layer_boundaries */
{
    struct parameter parameters[] = {
        { "toplevel",       OBJECT,     NULL,   "toplevel cell to place cells in" },
        { "celllookup",     TABLE,      NULL,   "lookup-table containing the cells and their layers" },
        { "basename",       STRING,     NULL,   "basename for the instance names" },
        { "targetarea",     TABLE,      NULL,   "target area (a polygon)" },
        { "xpitch",         TABLE,      NULL,   "xpitch of all to-be-placed cells" },
        { "ypitch",         TABLE,      NULL,   "ypitch of all to-be-placed cells" },
        { "layerexcludes",  TABLE,      NULL,   "layer excludes table (see detailed documentation and example for format)" },
        { "ignorelayer",    GENERICS,   NULL,   "layer that is ignored for extra excludes (optional)" }
    };
    vector_append(entries, _make_api_entry(
        "place_within_layer_boundaries",
        MODULE_PLACEMENT,
        "place cells in a boundary based on their layer content. This function is similar to placement.place_within_boundary, but uses non-binary excludes. A look-up table with cells is given, that defines the occupied layers of these cells and places only cells that don't have content in the excluded layers. The layerexcludes table contains the excludes in the respective layers. This function tries to maximize the number of placed cells, starting for every point with the first cell. After a cell is placed, its layers are used to block that region. That means that if cells exist with non-overlapping layer content, it is possible that multiple cells are placed per grid point. Therefore the order of the cells matters (first come, first serve). The sixth (optional) argument of this function is a singular generic layer that will be ignored when building the new excludes for subsequent cells. The reasoning behind is that if a certain layer is used as a marking layer as a full block, then all the cells in the cell lookup also need to contain this layer, which then in turn blocks the subsequent placing of further cells.",
        "local celllut = {\n    {\n        cell = object1,\n        layers = {\n            generics.metal(1),\n            generics.metal(2),\n            generics.metal(3),\n            generics.metal(4),\n        },\n    },\n    {\n        cell = object2,\n        layers = {\n            generics.metal(1),\n            generics.metal(2),\n        },\n    },\n    {\n        cell = object2,\n        layers = {\n            generics.other(\"active\"),\n        },\n    },\n}\nlocal target = {\n    point.create(-10000, -10000),\n    point.create( 10000, -10000),\n    point.create( 10000,  10000),\n    point.create(-10000,  10000),\n}\nlocal excludes = {\n    {\n        excludes = { -- multiple polygons are possible\n            {\n                point.create(-5000, -5000),\n                point.create( 5000, -5000),\n                point.create( 5000,  5000),\n                point.create(-5000,  5000),\n            },\n            layers = {\n                generics.metal(1),\n                generics.metal(2),\n            },\n        },\n    }\n    {\n        excludes = { -- multiple polygons are possible\n            {\n                point.create( 2000,  1000),\n                point.create( 4000,  1000),\n                point.create( 4000,  8000),\n                point.create( 2000,  8000),\n            },\n            layers = {\n                generics.other(\"active\"),\n            },\n        },\n    }\n}\nplacement.place_within_layer_boundaries(toplevel, celllookup, \"fill\", targetarea, 1000, 1000, excludes)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* placement.calculate_grid */
{
    struct parameter parameters[] = {
        { "bl",         POINT,      NULL,   "botton-left target boundary" },
        { "tr",         POINT,      NULL,   "top-right target boundary" },
        { "pitch",      INTEGER,    NULL,   "cell pitch in x- and y-direction" },
        { "excludes",   TABLE,      NULL,   "optional list of polygons with fill excludes" }
    };
    vector_append(entries, _make_api_entry(
        "calculate_grid",
        MODULE_PLACEMENT,
        "calculate a grid of cell origins in a rectangular target area with the given binary excludes (in or out). This function returns a table which can be used as input for placement.place_boundary_grid",
        "local excludes = { {\n    point.create(2000, 2000),\n    point.create(8000, 2000),\n    point.create(8000, 20000),\n    point.create(2000, 20000)\n}, }\nplacement.calculate_grid(point.create(0, 0), point.create(100000, 100000), 10000, excludes)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* placement.place_boundary_grid */
{
    struct parameter parameters[] = {
        { "toplevel",       OBJECT,     NULL,   "toplevel cell to place cells in" },
        { "boundarycells",  TABLE,      NULL,   "lookup-table containing the boundary cells" },
        { "basept",         POINT,      NULL,   "base point for the grid placement" },
        { "grid",           TABLE,      NULL,   "grid table" },
        { "pitch",          INTEGER,    NULL,   "cell pitch in x- and y-direction" },
        { "basename",       STRING,     NULL,   "basename for the instance names" }
    };
    vector_append(entries, _make_api_entry(
        "place_boundary_grid",
        MODULE_PLACEMENT,
        "place cells on a regular grid with the given pitch. The grid contains numeric entries of either 1 or 0, meaning 'place' or 'don't place'. This grid can be obtained by using placement.calculate_grid. The cells are placed on this grid, so that the proper cells are used at each of the grid points. This means that special cells are placed at the boundary of the grid (e.g., where there is no neighbouring cell to the left). The boundarycells table should contain sixteen (2^4) key-value pairs: cells for 'center', 'top', 'bottom', 'left', 'right', 'topleft', 'topright', 'topbottom', 'bottomleft', 'bottomright', 'leftright', 'topleftright', 'topbottomleft', 'topbottomright', 'bottomleftright' and 'topbottomleftright'",
        "local grid = { --[[ some grid definition --]] }\nlocal boundarycells = { center = centercell, top = topcell, --[[ and so on --]] } \nplacement.place_boundary_grid(toplevel, boundarycells, point.create(0, 0), grid, 10000, \"gridcell\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

