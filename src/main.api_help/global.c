/* parameters */
{
    struct parameter parameters[] = {
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "parameters",
        MODULE_NONE,
        "Cell definition function. Define cell parameters. This function takes no arguments and does not return anything (the value will be ignored). This function is optional, but a cell without parameters is not very useful.",
        "function parameters()\n    pcell.add_parameters(\n        { \"param1\", 0 },\n        { \"param2\", 100 }    )\nend",
        parameters
    ));
}

/* process_parameters */
{
    struct parameter parameters[] = {
        { "_P", TABLE, NULL, "parameter table" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "process_parameters",
        MODULE_NONE,
        "Cell definition function. Process parameters after user values have been set. This can be used to re-evaluate parameters based on different settings. As an example the width of a metal line could be set to the minimum width value of the used metal. This can not be done in regular parameter definitions for cells. The function receives the table with all parameter values and should return a new table with altered parameters. Every parameter in this new table will overwrite a parameter in the main parameter table, but only if it was not explicitly modified when calling the cell. This function is optional.",
        "function process_parameters(_P)\n    local t = {}\n    t.width = technology.get_dimension(string.format(\"Minimum M%d Width\"), _P.metal)\n    t.length = _P.totallength -- simple follower parameter\n    return t\nend",
        parameters
    ));
}

/* prepare */
{
    struct parameter parameters[] = {
        { "_P", TABLE, NULL, "parameter table" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "prepare",
        MODULE_NONE,
        "Cell definition function. Prepare a state for further cell functions. This function is useful when some calculations/logic have to be run for different functions (for instance check() and layout()). In order to avoid code duplication, the prepare() function can be used. It receives the final parameters table (after a possible call to process_parameters()) and is expected to return a table as a common state for all following cell functions. This function is optional.",
        "function prepare(_P)\n    local state = {}\n    state.metalwidths = util.rep(_P.numlines, _P.linewidth)\nend",
        parameters
    ));
}

/* check */
{
    struct parameter parameters[] = {
        { "_P",         TABLE, NULL, "parameter table" },
        { "cellstate",  TABLE, NULL, "common cell state obtained from prepare()" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "check",
        MODULE_NONE,
        "Cell definition function. Check parameters for sane values. This function should return 'true' if all checks succeed. This means that an empty check function should still return 'true'. Any arbitrary checks can be implemented (typically simply 'if ... then return false, message end') and if a check fails the function should return 'false' and a message. This function can receive (if present) the cellstate from prepare(). This function is optional, but if present the last statement should be 'return true'.",
        "function check(_P, cellstate)\n    if _P.topmetal > 4 then\n        return false, string.format(\"the top metal must not exceed 4, got %d\", _P.topmetal)\n    end\n    return true -- final return\nend",
        parameters
    ));
}

/* layout */
{
    struct parameter parameters[] = {
        { "cell",       OBJECT, NULL, "cell to place shapes/instances/etc. in" },
        { "_P",         TABLE,  NULL, "parameter table" },
        { "env",        TABLE,  NULL, "cell environment" },
        { "cellstate",  TABLE,  NULL, "common cell state obtained from prepare()" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "layout",
        MODULE_NONE,
        "Cell definition function. Main layout definition of a cell. This function receives an object where shapes, instances, ports etc. are to be placed in. This function should not create its own top-level layout object (even if it did, it would simply be ignored). As inputs the function receives (besides the object) the final parameter values, and possibly a cell environment and the common cell state. The parameter table controls the layout creation and should always be present (just like 'parameters()', although both are technically optional). The cell environment is equal for all called cells (invocations but also cell types) within one opc call, there is only one cell environment. This can be used for cells of one project that only work together. For this reason, it is not used in standard cell implementations in openPCells. The cellstate is the shared common cellstate from a potential 'prepare()' call. This function is technically optional, but only in very rare cases it is not needed (a base cell defining parameters can be created, see stdcells/base).",
        "function layout(cell, _P)\n    geometry.rectanglebltr(cell, generics.metal(1), point.create(0, 0), point.create(_P.width, _P.height))\nend\n\nfunction layout(cell, _P, env)\n    if env.XXX then ... end\nend\n\nfunction layout(cell, _P, _envnotused, state)\n    if state.XXX then ... end\nend",
        parameters
    ));
}

/* set */
{
    struct parameter parameters[] = {
        { "...", VARARGS, NULL, "variable number of arguments, usually strings or integers" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "set",
        MODULE_NONE,
        "define a set of possible values that a parameter can take. Only useful within a parameter definition of a pcell",
        "pcell.add_parameters({ { \"mostype\", \"nmos\", posvals = set(\"nmos\", \"pmos\") } })",
        parameters
    ));
}

/* interval */
{
    struct parameter parameters[] = {
        { "lower", INTEGER, NULL, "lower (inklusive) bound of the interval" },
        { "upper", INTEGER, NULL, "upper (inklusive) bound of the interval" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "interval",
        MODULE_NONE,
        "define an interval of possible values that a parameter can take. Only useful within a parameter definition of a pcell",
        "pcell.add_parameters({ { \"fingers\", 2, posvals = interval = (1, inf) } })",
        parameters
    ));
}

/* even */
{
    struct parameter parameters[] = {
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "even",
        MODULE_NONE,
        "define that a parameter must be even. Only useful within a parameter definition of a pcell",
        "pcell.add_parameters({ { fingerwidth, 100, posvals = even() } })",
        parameters
    ));
}

/* odd */
{
    struct parameter parameters[] = {
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "odd",
        MODULE_NONE,
        "define that a parameter must be odd. Only useful within a parameter definition of a pcell",
        "pcell.add_parameters({ { fingerwidth, 100, posvals = odd() } })",
        parameters
    ));
}

/* positive */
{
    struct parameter parameters[] = {
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "positive",
        MODULE_NONE,
        "define that a parameter must be positive. Only useful within a parameter definition of a pcell",
        "pcell.add_parameters({ { fingerwidth, 100, posvals = positive() } })",
        parameters
    ));
}

/* negative */
{
    struct parameter parameters[] = {
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "negative",
        MODULE_NONE,
        "define that a parameter must be negative. Only useful within a parameter definition of a pcell",
        "pcell.add_parameters({ { offset, -100, posvals = negative() } })",
        parameters
    ));
}

/* enable */
{
    struct parameter parameters[] = {
        { "bool",   BOOLEAN,    NULL,   "boolean for enable/disable" },
        { "value",  NUMBER,     "1",    "value to be enabled/disabled" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "enable",
        MODULE_NONE,
        "multiply a value with 1 or 0, depending on a boolean parameter. Essentially val * (bool and 1 or 0)",
        "enable(_P.drawguardring, _P.guardringspace)",
        parameters
    ));
}

/* evenodddiv2 */
{
    struct parameter parameters[] = {
        { "value",  INTEGER,    NULL,   "value to divide" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "evenodddiv2",
        MODULE_NONE,
        "divide a value by 2. If it is odd, return floor(val / 2) and ceil(val / 2), otherwise return val / 2",
        "local low, high = evenodddiv2(13) -- return 6 and 7",
        parameters
    ));
}

/* divevenup */
{
    struct parameter parameters[] = {
        { "value",  INTEGER,    NULL,   "value to divide" },
        { "div",    INTEGER,    NULL,   "divisor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "divevenup",
        MODULE_NONE,
        "approximately divide a value by the divisor, so that the result is even. If this can't be achieved with the original value, increment it until it works",
        "local result = divevenup(6, 2) -- returns 4",
        parameters
    ));
}

/* divevendown */
{
    struct parameter parameters[] = {
        { "value",  INTEGER,    NULL,   "value to divide" },
        { "div",    INTEGER,    NULL,   "divisor" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "divevendown",
        MODULE_NONE,
        "approximately divide a value by the divisor, so that the result is even. If this can't be achieved with the original value, decrement it until it works",
        "local result = divevendown(6, 2) -- returns 2",
        parameters
    ));
}

/* dprint */
{
    struct parameter parameters[] = {
        { "...", VARARGS, NULL, "variable arguments that should be printed" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "dprint",
        MODULE_NONE,
        "debug print. Works like regular print (which is not available in pcell definitions). Only prints something when opc is called with --enable-dprint",
        "dprint(_P.fingers)",
        parameters
    ));
}

/*
    FIXME (?)
	check_arg
	check_arg_or_nil
	check_number
	check_object
	check_point
	check_table
*/
