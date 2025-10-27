
/* aux.assert_one_of */
{
    struct parameter parameters[] = {
        { "msg",    STRING,     NULL, "message/identifier that is pinted in case of an assertion failure" },
        { "key",    STRING,     NULL, "key that is checked against list of candidates" },
        { "...",    VARARGS,    NULL, "vararg list of candidates" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "assert_one_of",
        MODULE_AUX,
        "check that a key is within a list of possible candidates",
        "aux.assert_one_of(\"variable\", variable, \"foo\", \"bar\", \"baz\")",
        parameters
    ));
}

/* aux.clone_shallow */
{
    struct parameter parameters[] = {
        { "t",          TABLE,      NULL, "table to be copied" },
        { "predicate",  FUNCTION,   NULL, "optional predicate to filter elements" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "clone_shallow",
        MODULE_AUX,
        "create a shallow copy of a table. This function does not copy elements in the table, which means that nested tables refer to the same objects. The predicate function can be used to filter out unwanted entries. Only items where the predicate returns true are inserted. Without a predicate, all items are inserted.",
        "aux.clone_shallow({ 1, 2, 3, \"foo\", \"bar\", \"baz\" }, function(k, v) return type(v) == \"number\") -- { 1, 2, 3 }",
        parameters
    ));
}

/* aux.make_even */
{
    struct parameter parameters[] = {
        { "num", NUMBER, NULL, "number" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "make_even",
        MODULE_AUX,
        "return num + 1 if the number is odd",
        "aux.make_even(7) -- 8\naux.make_even(32) -- 32",
        parameters
    ));
}

/* aux.split_path */
{
    struct parameter parameters[] = {
        { "path", STRING, NULL, "number" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "split_path",
        MODULE_AUX,
        "split a path into its prefix/suffix (like dirname/basename). If no path separator '/' is present, the function returns \".\" and the full given path",
        "aux.split_path(\"foo/bar/baz\") -- \"foo/bar\" \"baz\"\naux.split_path(\"baz\") -- \".\" \"baz\"",
        parameters
    ));
}

/* aux.pop_top_directory */
{
    struct parameter parameters[] = {
        { "path", STRING, NULL, "number" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "pop_top_directory",
        MODULE_AUX,
        "remove the last part of a path, separated by '/' (like basename)",
        "aux.pop_top_directory(\"foo/bar/baz\") -- \"foo/bar\"",
        parameters
    ));
}

/* aux.shuffle */
{
    struct parameter parameters[] = {
        { "t", TABLE, NULL, "number" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "shuffle",
        MODULE_AUX,
        "shuffle the array elements of a table",
        "aux.shuffle({ 1, 2, 3 }) -- { 3, 1, 2 }",
        parameters
    ));
}

/* aux.strsplit */
{
    struct parameter parameters[] = {
        { "str",        STRING,     NULL, "string" },
        { "pattern",    STRING,     NULL, "pattern" },
        { "plain",      BOOLEAN,    NULL, "plain" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "strsplit",
        MODULE_AUX,
        "split a string at a given separator pattern. If 'plain' is true, then the separator pattern is taken literally, no lua pattern matching is performed.",
        "aux.strsplit(\"foo:bar:baz\", \":\") -- { \"foo\", \"bar\", \"baz\" }",
        parameters
    ));
}

/* aux.strgsplit */
{
    struct parameter parameters[] = {
        { "str",        STRING,     NULL, "string" },
        { "pattern",    STRING,     NULL, "pattern" },
        { "plain",      BOOLEAN,    NULL, "plain" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "strgsplit",
        MODULE_AUX,
        "split a string at a given separator pattern. If 'plain' is true, then the separator pattern is taken literally, no lua pattern matching is performed. This is the iterator version of aux.strsplit.",
        "for match in aux.strgsplit(\"foo:bar:baz\", \":\") do\n    -- do something with 'match'\nend",
        parameters
    ));
}

/* aux.sum */
{
    struct parameter parameters[] = {
        { "t", TABLE, NULL, "numeric array" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "sum",
        MODULE_AUX,
        "calculate the sum of all array entries of the table t. This function assumes that the operator '+' is defined for all the array items.",
        "aux.sum({ 1, 2, 3 }) -- 6",
        parameters
    ));
}

/* aux.gcd */
{
    struct parameter parameters[] = {
        { "...", VARARGS, NULL, "number arguments" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "gcd",
        MODULE_AUX,
        "calculate the greatest common divisor (GDC) of all given input arguments",
        "aux.gcd(12, 9) -- 3",
        parameters
    ));
}

/* aux.tabgcd */
{
    struct parameter parameters[] = {
        { "t", TABLE, NULL, "numeric array" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "tabgcd",
        MODULE_AUX,
        "calculate the greatest common divisor (GDC) of all elements of the given array",
        "aux.gcd({ 12, 9 }) -- 3",
        parameters
    ));
}

/* aux.tprint */
{
    struct parameter parameters[] = {
        { "t", TABLE, NULL, "numeric array" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "tprint",
        MODULE_AUX,
        "recursively pretty-print the contents of the given table. This function has a simple implementation and will fail on odd tables, like cycles.",
        "aux.tprint({ 12, 9, \"foo\", sub = { name = \"name\" }, })",
        parameters
    ));
}

