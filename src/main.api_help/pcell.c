/* pcell.set_property */
{
    struct parameter parameters[] = {
        { "property", STRING, NULL, "property to set" },
        { "value",    ANY,    NULL, "value of the property" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "set_property",
        MODULE_PCELL,
        "set a property of a pcell.",
        "Set a property of a pcell. "
        "Not many properties are supported currently, so this function is very rarely used. "
        "The base cell of the standard cell library uses it to be hidden, but that's the only current use.",
        "function config()\n    pcell.set_property(\"hidden\", true)\nend",
        parameters
    ));
}

/* pcell.add_parameter */
{
    struct parameter parameters[] = {
        { "name",           STRING, NULL, "parameter name" },
        { "defaultvalue",   ANY,    NULL, "default parameter value (can be any lua type)" },
        { "opt",            TABLE,  NULL, "options table" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "add_parameter",
        MODULE_PCELL,
        "add a parameter to a pcell definition",
        "Add a parameter to a pcell definition. "
        "Must be called in parameters(). "
        "The parameter options table can contain the following fields: "
        "'argtype': (type of the parameter, usually deduced from the default value), "
        "'posvals': possible parameter values, see functions 'even', 'odd', 'interval', 'positive', 'negative' and 'set'; "
        "'follow': copy the values from the followed parameter to this one if not explicitly specified and if the followed parameter was given explicitly; "
        "'readonly': make parameter readonly",
        "function parameters()\n    pcell.add_parameter(\"fingers\", 2, { posvals = even() })\nend",
        parameters
    ));
}

/* pcell.add_parameters */
{
    struct parameter parameters[] = {
        { "args", VARARGS, NULL, "argument list of single parameter entries" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "add_parameters",
        MODULE_PCELL,
        "add multiple parameters to a pcell definition",
        "Add multiple parameters to a cell. "
        "Internally, this calls pcell.add_parameter, so this function is merely a shorthand for multiple calls to pcell.parameter. "
        "Hint for the usage: in lua tables, a trailing comma after the last entry is explicitely allowed. "
        "However, this is a variable number of arguments for a function call, where the list has to be well-defined. "
        "A common error is a trailing comma after the last entry.",
        "function parameters()\n    pcell.add_parameters(\n        {\n            \"fingers\",\n            2,\n            posvals = even()\n        },\n        {\n            \"fingerwidth\",\n            100,\n            posvals = positive()\n        },\n        {\n            \"channeltype\",\n            \"nmos\",\n            posvals = set(\"nmos\", \"pmos\")\n        } -- <--- no comma!\n    )\nend",
        parameters
    ));
}

/* pcell.check_expression */
{
    struct parameter parameters[] = {
        { "expression", STRING, NULL, "expression to check" },
        { "message",    STRING, NULL, "custom message which is displayed if the expression could not be satisfied" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "check_expression",
        MODULE_PCELL,
        "check valid parameter values with expressions",
        "Check valid parameter values with expressions. "
        "If parameter values depend on some other parameter or the posval function of parameter definitions do not offer enough flexibility, parameters can be checked with arbitrary lua expressions. "
        "This function must be called in parameters().",
        "function parameters()\n    pcell.add_parameters({\n        {\n            \"width\", 100\n        },\n        {\n            \"height\", 200\n        },\n    })\n    pcell.check_expression(\n        \"(height / width) % 2 == 0\",\n        \"quotionent of height and width must be even\"\n    )\nend",
        parameters
    ));
}

/* pcell.add_area_anchor_documentation */
{
    struct parameter parameters[] = {
        { "name",           STRING, NULL, "anchor name" },
        { "description",    STRING, NULL, "description of the anchor's function" },
        { "condition",      STRING, NULL, "optional condition under which the anchor is present" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "add_area_anchor_documentation",
        MODULE_PCELL,
        "add documentation of an area anchor of a pcell",
        "Add documentation of an area anchor of a pcell. "
        "This function is called in the 'anchor' function of a pcell definition. "
        "The anchors defined here are available via 'opc --anchors'.",
        "pcell.add_area_anchor_documentation(\n    \"someanchor\",\n    \"anchor of some region\",\n    \"someflag == true\"\n)",
        parameters
    ));
}

/* pcell.create_layout */
{
    struct parameter parameters[] = {
        { "cellname",   STRING, NULL,   "cellname of the to-be-generated layout cell in the form libname/cellname" },
        { "objectname", STRING, NULL,   "name of the to-be-generated object. This name will be used as identifier in exports that support hierarchies (e.g. GDSII, SKILL)" },
        { "parameters", TABLE, NULL,  "a table with key-value pairs to be used for the layout pcell. The parameter must exist in the pcell, otherwise this triggers an error" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "create_layout",
        MODULE_PCELL,
        "create a layout based on a parametric cell",
        "Create a layout based on a parametric cell. "
        "A name has to be given, the parameters are optional. ",
        "pcell.create_layout(\"stdcells/not_gate\", \"not_gate\",\n    { pwidth = 600 }\n)",
        parameters
    ));
}

/* pcell.create_layout_env */
{
    struct parameter parameters[] = {
        { "cellname",   STRING, NULL,   "cellname of the to-be-generated layout cell in the form libname/cellname" },
        { "objectname", STRING, NULL,   "name of the to-be-generated object. This name will be used as identifier in exports that support hierarchies (e.g. GDSII, SKILL)" },
        { "parameters", TABLE, NULL,  "a table with key-value pairs to be used for the layout pcell. The parameter must exist in the pcell, otherwise this triggers an error" },
        { "environment", TABLE, NULL,  "a table containing the environment for all cells called from this cell. The environment can contain anything and is defined by the cells. It is useful in order to pass a set of common options to multiple cells" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "create_layout_env",
        MODULE_PCELL,
        "create a layout of a parametric cell with a cell environment",
        "Create a layout based on a parametric cell with a given cell environment",
        "pcell.create_layout_env(\n    \"libname/cellname\",\n     \"toplevel\",\n     args,\n     env\n)",
        parameters
    ));
}

/* pcell.create_layout_in_object */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL,   "object to place shapes in" },
        { "cellname",   STRING, NULL,   "cellname of the to-be-generated layout cell in the form libname/cellname" },
        { "parameters", TABLE,  NULL,  "a table with key-value pairs to be used for the layout pcell. The parameter must exist in the pcell, otherwise this triggers an error" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "create_layout_in_object",
        MODULE_PCELL,
        "create a layout of a parametric cell in an already-existing cell",
        "Create a layout based on a parametric cell in an existing cell. "
        "This function does NOT return a new object but places everything from the pcell in the given object (first argument).",
        "pcell.create_layout_in_object(cell,\n    \"libname/cellname\",\n    args\n)",
        parameters
    ));
}

/* pcell.create_layout_env_in_object */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL,   "object to place shapes in" },
        { "cellname",   STRING, NULL,   "cellname of the to-be-generated layout cell in the form libname/cellname" },
        { "parameters", TABLE,  NULL,  "a table with key-value pairs to be used for the layout pcell. The parameter must exist in the pcell, otherwise this triggers an error" },
        { "environment", TABLE, NULL,  "a table containing the environment for all cells called from this cell. The content of the environment can contain anything and is defined by the cells. It is useful in order to pass a set of common options to multiple cells" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "create_layout_env_in_object",
        MODULE_PCELL,
        "create a layout of a parametric cell in an already-existing cell with a cell environment",
        "Create a layout based on a parametric cell with a given cell environment in an existing cell. "
        "This function does NOT return a new object but places everything from the pcell in the given object (first argument).",
        "pcell.create_layout_env_in_object(cell,\n    \"libname/cellname\",\n    args,\n    env\n)",
        parameters
    ));
}

/* pcell.create_layout_from_script(scriptpath, args, cellenv) */
{
    struct parameter parameters[] = {
        { "scriptpath",     STRING, NULL,   "path of the script" },
        { "args",           TABLE,  NULL,   "arguments for the script" },
        { "cellenv",        TABLE,  NULL,   "a table containing the environment for all cells called from this cell. The content of the environment can contain anything and is defined by the cells. It is useful in order to pass a set of common options to multiple cells" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "create_layout_from_script",
        MODULE_PCELL,
        "create a layout with a cell script",
        "Create a layout based on a cellscript."
        "The 'args' and 'cellenv' parameters are supported for special cases, but typically not needed. "
        "If extensive use of cell parameters is required, a proper parametric cell might be better. "
        "This function is intended for use in helper scripts, e.g. for power scripts. "
        "This function returns a new object. "
        "The object is created in the cell script, as cell script are required to return an object.",
        "pcell.create_layout_from_script(\"cellscript.lua\")",
        parameters
    ));
}

/*
    FIXME:
    pcell.append_cellpath
    pcell.get_cell_filename
    pcell.has_parameter
    pcell.parameters
*/
