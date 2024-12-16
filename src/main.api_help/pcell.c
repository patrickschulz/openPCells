/* pcell.set_property */
{
    struct parameter parameters[] = {
        { "property", STRING, NULL, "property to set" },
        { "value",    ANY,    NULL, "value of the property" }
    };
    vector_append(entries, _make_api_entry(
        "set_property",
        MODULE_PCELL,
        "set a property of a pcell. Not many properties are supported currently, so this function is very rarely used. The base cell of the standard cell library uses it to be hidden, but that's the only current use",
        "function config()\n    pcell.set_property(\"hidden\", true)\nend",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* pcell.add_parameter */
{
    struct parameter parameters[] = {
        { "name",           STRING, NULL, "parameter name" },
        { "defaultvalue",   ANY,    NULL, "default parameter value (can be any lua type)" },
        { "opt",            TABLE,  NULL, "options table" }
    };
    vector_append(entries, _make_api_entry(
        "add_parameter",
        MODULE_PCELL,
        "add a parameter to a pcell definition. Must be called in parameters(). The parameter options table can contain the following fields: 'argtype': (type of the parameter, usually deduced from the default value), 'posvals': possible parameter values, see functions 'even', 'odd', 'interval', 'positive', 'negative' and 'set'; 'follow': copy the values from the followed parameter to this one if not explicitly specified; 'readonly': make parameter readonly",
        "function parameters()\n    pcell.add_parameter(\"fingers\", 2, { posvals = even() })\nend",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* pcell.add_parameters */
{
    struct parameter parameters[] = {
        { "args", VARARGS, NULL, "argument list of single parameter entries" }
    };
    vector_append(entries, _make_api_entry(
        "add_parameters",
        MODULE_PCELL,
        "add multiple parameters to a cell. Internally, this calls pcell.add_parameter, so this function is merely a shorthand for multiple calls to pcell.parameter. Hint for the usage: in lua tables, a trailing comma after the last entry is explicitely allowed. However, this is a variable number of arguments for a function call, where the list has to be well-defined. A common error is a trailing comma after the last entry",
        "function parameters()\n    pcell.add_parameters(\n        { \"fingers\",     2,      posvals = even()              },\n        { \"fingerwidth\", 100,    posvals = positive()          },\n        { \"channeltype\", \"nmos\", posvals = set(\"nmos\", \"pmos\") } -- <--- no comma!\n    )\nend",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* pcell.get_parameters */
{
    struct parameter parameters[] = {
        { "cellname", STRING, NULL, "cellname of the cell whose parameters should be queried" }
    };
    vector_append(entries, _make_api_entry(
        "get_parameters",
        MODULE_PCELL,
        "access the (updated) parameter values of another cell",
        "function parameters()\n    end\n\nfunction layout(cell)\n    local bp = pcell.get_parameters(\"foo/bar\")\nend",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* pcell.check_expression */
{
    struct parameter parameters[] = {
        { "expression", STRING, NULL, "expression to check" },
        { "message",    STRING, NULL, "custom message which is displayed if the expression could not be satisfied" }
    };
    vector_append(entries, _make_api_entry(
        "check_expression",
        MODULE_PCELL,
        "check valid parameter values with expressions. If parameter values depend on some other parameter or the posval function of parameter definitions do not offer enough flexibility, parameters can be checked with arbitrary lua expressions. This function must be called in parameters()",
        "function parameters()\n    pcell.add_parameters({\n        { \"width\", 100 },\n        { \"height\", 200 },\n    })\n    pcell.check_expression(\"(height / width) % 2 == 0\", \"quotionent of height and width must be even\")\nend",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* pcell.create_layout */
{
    struct parameter parameters[] = {
        { "cellname",   STRING, NULL,   "cellname of the to-be-generated layout cell in the form libname/cellname" },
        { "objectname", STRING, NULL,   "name of the to-be-generated object. This name will be used as identifier in exports that support hierarchies (e.g. GDSII, SKILL)" },
        { "parameters", TABLE, NULL,  "a table with key-value pairs to be used for the layout pcell. The parameter must exist in the pcell, otherwise this triggers an error" }
    };
    vector_append(entries, _make_api_entry(
        "create_layout",
        MODULE_PCELL,
        "Create a layout based on a parametric cell",
        "pcell.create_layout(\"stdcells/not_gate\", \"not_gate\", { pwidth = 600 })",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* pcell.create_layout_env */
{
    struct parameter parameters[] = {
        { "cellname",   STRING, NULL,   "cellname of the to-be-generated layout cell in the form libname/cellname" },
        { "objectname", STRING, NULL,   "name of the to-be-generated object. This name will be used as identifier in exports that support hierarchies (e.g. GDSII, SKILL)" },
        { "parameters", TABLE, NULL,  "a table with key-value pairs to be used for the layout pcell. The parameter must exist in the pcell, otherwise this triggers an error" },
        { "environment", TABLE, NULL,  "a table containing the environment for all cells called from this cell. The content of the environment can contain anything and is defined by the cells. It is useful in order to pass a set of common options to multiple cells" }
    };
    vector_append(entries, _make_api_entry(
        "create_layout_env",
        MODULE_PCELL,
        "Create a layout based on a parametric cell with a given cell environment",
        "pcell.create_layout_env(\"libname/cellname\", \"toplevel\", args, env)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* pcell.create_layout_env_in_object */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL,   "object to place shapes in" },
        { "cellname",   STRING, NULL,   "cellname of the to-be-generated layout cell in the form libname/cellname" },
        { "objectname", STRING, NULL,   "name of the to-be-generated object. This name will be used as identifier in exports that support hierarchies (e.g. GDSII, SKILL)" },
        { "parameters", TABLE, NULL,  "a table with key-value pairs to be used for the layout pcell. The parameter must exist in the pcell, otherwise this triggers an error" },
        { "environment", TABLE, NULL,  "a table containing the environment for all cells called from this cell. The content of the environment can contain anything and is defined by the cells. It is useful in order to pass a set of common options to multiple cells" }
    };
    vector_append(entries, _make_api_entry(
        "create_layout_env_in_object",
        MODULE_PCELL,
        "Create a layout based on a parametric cell with a given cell environment in an existing cell. This function does NOT return a new object but places everything from the pcell in the given object (first argument)",
        "pcell.create_layout_env_in_object(cell, \"libname/cellname\", \"toplevel\", args, env)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/*
    FIXME:
	pcell.add_cell
	pcell.append_cellpath
	pcell.check
	pcell.constraints
	pcell.create_layout_from_script
	pcell.enable_debug
	pcell.enable_dprint
	pcell.evaluate_parameters
	pcell.get_cell_filename
	pcell.parameters
*/
