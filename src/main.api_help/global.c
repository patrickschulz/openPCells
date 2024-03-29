    /* set */
    {
        struct parameter parameters[] = {
            { "...", VARARGS, NULL, "variable number of arguments, usually strings or integers" },
        };
        vector_append(entries, _make_api_entry(
            "set",
            MODULE_NONE,
            "define a set of possible values that a parameter can take. Only useful within a parameter definition of a pcell",
            "pcell.add_parameters({ { \"mostype\", \"nmos\", posvals = set(\"nmos\", \"pmos\") } })",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* interval */
    {
        struct parameter parameters[] = {
            { "lower", INTEGER, NULL, "lower (inklusive) bound of the interval" },
            { "upper", INTEGER, NULL, "upper (inklusive) bound of the interval" }
        };
        vector_append(entries, _make_api_entry(
            "interval",
            MODULE_NONE,
            "define an interval of possible values that a parameter can take. Only useful within a parameter definition of a pcell",
            "pcell.add_parameters({ { \"fingers\", 2, posvals = interval = (1, inf) } })",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* even */
    {
        struct parameter parameters[] = {};
        vector_append(entries, _make_api_entry(
            "even",
            MODULE_NONE,
            "define that a parameter must be even. Only useful within a parameter definition of a pcell",
            "pcell.add_parameters({ { fingerwidth, 100, posvals = even() } })",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* odd */
    {
        struct parameter parameters[] = {};
        vector_append(entries, _make_api_entry(
            "odd",
            MODULE_NONE,
            "define that a parameter must be odd. Only useful within a parameter definition of a pcell",
            "pcell.add_parameters({ { fingerwidth, 100, posvals = odd() } })",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* positive */
    {
        struct parameter parameters[] = {};
        vector_append(entries, _make_api_entry(
            "positive",
            MODULE_NONE,
            "define that a parameter must be positive. Only useful within a parameter definition of a pcell",
            "pcell.add_parameters({ { fingerwidth, 100, posvals = positive() } })",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* negative */
    {
        struct parameter parameters[] = {};
        vector_append(entries, _make_api_entry(
            "negative",
            MODULE_NONE,
            "define that a parameter must be negative. Only useful within a parameter definition of a pcell",
            "pcell.add_parameters({ { offset, -100, posvals = negative() } })",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* enable */
    {
        struct parameter parameters[] = {
            { "bool",   BOOLEAN,    NULL,   "boolean for enable/disable" },
            { "value",  NUMBER,     "1",    "value to be enabled/disabled" }
        };
        vector_append(entries, _make_api_entry(
            "enable",
            MODULE_NONE,
            "multiply a value with 1 or 0, depending on a boolean parameter. Essentially val * (bool and 1 or 0)",
            "enable(_P.drawguardring, _P.guardringspace)",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* evenodddiv2 */
    {
        struct parameter parameters[] = {
            { "value",  INTEGER,    NULL,   "value to divide" }
        };
        vector_append(entries, _make_api_entry(
            "evenodddiv2",
            MODULE_NONE,
            "divide a value by 2. If it is odd, return floor(val / 2) and ceil(val / 2), otherwise return val / 2",
            "local low, high = evenodddiv2(13) -- return 6 and 7",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* divevenup */
    {
        struct parameter parameters[] = {
            { "value",  INTEGER,    NULL,   "value to divide" },
            { "div",    INTEGER,    NULL,   "divisor" }
        };
        vector_append(entries, _make_api_entry(
            "divevenup",
            MODULE_NONE,
            "approximately divide a value by the divisor, so that the result is even. If this can't be achieved with the original value, increment it until it works",
            "local result = divevenup(6, 2) -- returns 4",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* divevendown */
    {
        struct parameter parameters[] = {
            { "value",  INTEGER,    NULL,   "value to divide" },
            { "div",    INTEGER,    NULL,   "divisor" }
        };
        vector_append(entries, _make_api_entry(
            "divevendown",
            MODULE_NONE,
            "approximately divide a value by the divisor, so that the result is even. If this can't be achieved with the original value, decrement it until it works",
            "local result = divevendown(6, 2) -- returns 2",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
        ));
    }

    /* dprint */
    {
        struct parameter parameters[] = {
            { "...", VARARGS, NULL, "variable arguments that should be printed" }
        };
        vector_append(entries, _make_api_entry(
            "dprint",
            MODULE_NONE,
            "debug print. Works like regular print (which is not available in pcell definitions). Only prints something when opc is called with --enable-dprint",
            "dprint(_P.fingers)",
            parameters,
            sizeof(parameters) / sizeof(parameters[0])
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
