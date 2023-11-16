/* util.xmirror(pts, xcenter) */
{
    struct parameter parameters[] = {
        { "pts",        POINTLIST,  NULL,   "list of points" },
        { "xcenter",    INTEGER,    "0",    "mirror center" }
    };
    vector_append(entries, _make_api_entry(
        "xmirror",
        MODULE_UTIL,
        "create a copy of the points in pts (a table) with all x-coordinates mirrored with respect to xcenter",
        "local pts = { point.create(10, 0), point.create(20, 0) }\nutil.xmirror(pts, 0) -- { (-10, 0), (-20, 0) }",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* util.ymirror(pts, ycenter) */
{
    struct parameter parameters[] = {
        { "pts",        POINTLIST,  NULL,   "list of points" },
        { "ycenter",    INTEGER,    "0",    "mirror center" }
    };
    vector_append(entries, _make_api_entry(
        "ymirror",
        MODULE_UTIL,
        "create a copy of the points in pts (a table) with all y-coordinates mirrored with respect to ycenter",
        "local pts = { point.create(0, 10), point.create(0, 20) }\nutil.ymirror(pts, 0) -- { (0, -10), (0, -20) }",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* util.xymirror(pts, xcenter, ycenter) */
{
    struct parameter parameters[] = {
        { "pts",        POINTLIST,  NULL,   "list of points" },
        { "xcenter",    INTEGER,    "0",    "mirror center x-coordinate" },
        { "ycenter",    INTEGER,    "0",    "mirror center y-coordinate" }
    };
    vector_append(entries, _make_api_entry(
        "xymirror",
        MODULE_UTIL,
        "create a copy of the points in pts (a table) with all x- and y-coordinates mirrored with respect to xcenter and ycenter, respectively",
        "local pts = { point.create(10, 10), point.create(20, 20) }\nutil.ymirror(pts, 0, 0) -- { (-10, -10), (-20, -20) }",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* util.filter_forward(pts, fun) */
{
    struct parameter parameters[] = {
        { "pts",    POINTLIST,  NULL,   "point array to append to" },
        { "fun",    FUNCTION,   NULL,   "filter function" }
    };
    vector_append(entries, _make_api_entry(
        "filter_forward",
        MODULE_UTIL,
        "iterate forward through the list of points and create a new list with points that match the predicate. The predicate function is called with every point.",
        "local pts = { ... }\nlocal predicate = function(pt) return pt:getx() > 0 end\nlocal newpts = util.filter_forward(pts, predicate)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* util.filter_backward(pts, fun) */
{
    struct parameter parameters[] = {
        { "pts",    POINTLIST,  NULL,   "point array to append to" },
        { "fun",    FUNCTION,   NULL,   "filter function" }
    };
    vector_append(entries, _make_api_entry(
        "filter_backward",
        MODULE_UTIL,
        "iterate backward through the list of points and create a new list with points that match the predicate. The predicate function is called with every point.",
        "local pts = { ... }\nlocal predicate = function(pt) return pt:getx() > 0 end\nlocal newpts = util.filter_backward(pts, predicate)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* util.merge_forwards(pts, pts2) */
{
    struct parameter parameters[] = {
        { "pts",    POINTLIST,  NULL,   "point array to append to" },
        { "pts2",   POINTLIST,  NULL,   "point array to append from" }
    };
    vector_append(entries, _make_api_entry(
        "merge_forwards",
        MODULE_UTIL,
        "append all points from pts2 to pts1. Iterate pts2 forward. Operates in-place, thus pts is modified",
        "util.merge_forward(pts, pts2)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* util.merge_backwards(pts, pts2) */
{
    struct parameter parameters[] = {
        { "pts",    POINTLIST,  NULL,   "point array to append to" },
        { "pts2",   POINTLIST,  NULL,   "point array to append from" }
    };
    vector_append(entries, _make_api_entry(
        "merge_backwards",
        MODULE_UTIL,
        "append all points from pts2 to pts1. Iterate pts2 backwards. Operates in-place, thus pts is modified",
        "util.merge_backward(pts, pts2)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* util.reverse(pts) */
{
    struct parameter parameters[] = {
        { "pts",    POINTLIST,  NULL,   "point array" }
    };
    vector_append(entries, _make_api_entry(
        "reverse",
        MODULE_UTIL,
        "create a copy of the point array with the order of points reversed",
        "local reversed = util.reverse(pts)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* util.make_insert_xy(pts, idx) */
{
    struct parameter parameters[] = {
        { "pts",    POINTLIST,  NULL,   "point array" },
        { "index",  INTEGER,    "nil",  "optional index" }
    };
    vector_append(entries, _make_api_entry(
        "make_insert_xy",
        MODULE_UTIL,
        "create a function that inserts points into a point array. XY mode, thus points are given as two coordinates. If an index is given, insert at that position. Mostly useful with 1 as an index or not index at all (append)",
        "local pts = {}\nlocal _append = util.make_insert_xy(pts)\n_append(0, 0)\n_append(100, 0)\n_append(100, 100)\n_append(0, 100)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* util.make_insert_pts(pts, idx) */
{
    struct parameter parameters[] = {
        { "pts",    POINTLIST,  NULL,   "point array" },
        { "index",  INTEGER,    "nil",  "optional index" }
    };
    vector_append(entries, _make_api_entry(
        "make_insert_pts",
        MODULE_UTIL,
        "create a function that inserts points into a point array. Point mode, thus points are given as single points. If an index is given, insert at that position. Mostly useful with 1 as an index or not index at all (append)",
        "local pts = {}\nlocal _append = util.make_insert_pts(pts)\n_append(point.create(0, 0))\n_append(point.create(100, 0))\n_append(point.create(100, 100))\n_append(point.create(0, 100))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* util.range(lower, upper, incr) */
{
    struct parameter parameters[] = {
        { "lower",  INTEGER, NULL,  "lower (inclusive) bound" },
        { "upper",  INTEGER, NULL,  "upper (inclusive) bound" },
        { "incr",   INTEGER, "1",   "increment" },
    };
    vector_append(entries, _make_api_entry(
        "range",
        MODULE_UTIL,
        "create a table with numeric entries between lower and upper (both inclusive). The entries spacing is specified by the increment (default 1)",
        "util.range(1, 5) -- { 1, 2, 3, 4, 5 }\nutil.range(2, 8, 3) -- { 2, 5, 8 }",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* util.remove(t, comp) */
{
    struct parameter parameters[] = {
        { "t",      TABLE,  NULL,  "array" },
        { "comp",   ANY,    NULL,  "comparison value of function" }
    };
    vector_append(entries, _make_api_entry(
        "remove",
        MODULE_UTIL,
        "create a shallow copy of a table with certain elements matching the given criteria removed. The 'comp' parameter can either be a value, which will be compared directly to the entries or a comparison function. If the result of the function call is 'true', the entry is NOT included in the results table.",
        "util.remove({1, 2, 3, 4, 5}, 3) -- { 1, 2, 4, 5 }\nutil.remove({1, 2, 3, 4, 5}, function(e) return e % 2 == 0 end) -- { 1, 3, 5 }",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* util.fill_all_with(num, filler) */
{
    struct parameter parameters[] = {
        { "num",    INTEGER, NULL, "number of repetitions" },
        { "filler", ANY,     NULL, "value which should be repeated. Can be anything, but probably most useful with strings or numbers" }
    };
    vector_append(entries, _make_api_entry(
        "fill_all_with",
        MODULE_UTIL,
        "create an array-like table with one entry repeated N times. This is useful, for example, for specifying gate contacts for basic/cmos",
        "local gatecontactpos = util.fill_all_with(4, \"center\") -- { \"center\", \"center\", \"center\", \"center\" }",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* util.fill_predicate_with(num, filler, predicate, other) */
{
    struct parameter parameters[] = {
        { "num",        INTEGER,    NULL, "number of repetitions" },
        { "filler",     ANY,        NULL, "value which should be repeated at even numbers. Can be anything, but probably most useful with strings or numbers" },
        { "predicate",  FUNCTION,   NULL, "predicate which is called with every index" },
        { "other",      ANY,        NULL, "value which should be repeated at odd numbers. Can be anything, but probably most useful with strings or numbers" }
    };
    vector_append(entries, _make_api_entry(
        "fill_predicate_with",
        MODULE_UTIL,
        "create an array-like table with two entries (total number of entries is N). This function (compared to fill_all_with, fill_odd_with and fill_even_with) allows for more complex patterns. To do this, a predicate (a function) is called on every index. If the predicate is true, the first entry is inserted, otherwise the second one. This function is useful, for example, for specifying gate contacts for basic/cmos. Counting starts at 1, so the first entry will be 'other'",
        "local contactpos = util.fill_predicate_with(8, \"power\", function(i) return i % 4 == 0 end, \"outer\")",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* util.fill_even_with(num, filler, other) */
{
    struct parameter parameters[] = {
        { "num",    INTEGER, NULL, "number of repetitions" },
        { "filler", ANY,     NULL, "value which should be repeated at even numbers. Can be anything, but probably most useful with strings or numbers" },
        { "other",  ANY,     NULL, "value which should be repeated at odd numbers. Can be anything, but probably most useful with strings or numbers" }
    };
    vector_append(entries, _make_api_entry(
        "fill_even_with",
        MODULE_UTIL,
        "create an array-like table with two entries repeated N / 2 times, alternating. Counting starts at 1. This is useful, for example, for specifying gate contacts for basic/cmos. Counting starts at 1, so the first entry will be 'other'",
        "local gatecontactpos = util.fill_even_with(4, \"center\", \"upper\") -- { \"upper\", \"center\", \"upper\", \"center\" }",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* util.fill_odd_with(num, filler, other) */
{
    struct parameter parameters[] = {
        { "num",    INTEGER, NULL, "number of repetitions" },
        { "filler", ANY,     NULL, "value which should be repeated at odd numbers. Can be anything, but probably most useful with strings or numbers" },
        { "other",  ANY,     NULL, "value which should be repeated at even numbers. Can be anything, but probably most useful with strings or numbers" }
    };
    vector_append(entries, _make_api_entry(
        "fill_odd_with",
        MODULE_UTIL,
        "create an array-like table with two entries repeated N / 2 times, alternating. Counting starts at 1. This is useful, for example, for specifying gate contacts for basic/cmos. Counting starts at 1, so the first entry will be 'filler'",
        "local gatecontactpos = util.fill_odd_with(4, \"center\", \"upper\") -- { \"center\", \"upper\", \"center\", \"upper\" }",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* util.add_options(baseoptions, additional) */
{
    struct parameter parameters[] = {
        { "baseoptions",        TABLE,      NULL, "base options" },
        { "additionaloptions",  TABLE,      NULL, "additional options" },
    };
    vector_append(entries, _make_api_entry(
        "add_options",
        MODULE_UTIL,
        "create a copy of the baseoptions table and add all key-value pairs found in additionaloptions. This function clones baseoptions so the original is not altered. This copy is flat, so only the first-level elements are copied (e.g. tables will reference the same object). This function is useful to modify a set of base options for several devices such as mosfets, which only differ in a few options",
        "local baseoptions = ...\nlocal fet = pcell.create_layout(\"basic/mosfet\", \"fet\", util.add_options(baseoptions, { gatelength = 100 }))",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* util.ratio_split_even(value, ratio) */
{
    struct parameter parameters[] = {
        { "value",  INTEGER,    NULL, "value for division" },
        { "ratio",  NUMBER,     NULL, "target ratio of the two result values" },
    };
    vector_append(entries, _make_api_entry(
        "ratio_split_even",
        MODULE_UTIL,
        "create two values that sum up to the input value and have the specified ratio. The values are adjusted so that both of them are even, possibly changing the ratio slightly. The input value must be even",
        "local pitch = 100\nlocal width, space = util.ratio_split_even(pitch, 2) -- results in 68 and 32, the actual ratio then is 2.125",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* util.rectangle_to_polygon(value, ratio) */
{
    struct parameter parameters[] = {
        { "bl",         POINT,  NULL, "lower-left corner of the rectangle" },
        { "tr",         POINT,  NULL, "upper-right corner of the rectangle" },
        { "leftext",    POINT,  NULL, "left extension" },
        { "rightext",   POINT,  NULL, "right extension" },
        { "bottomext",  POINT,  NULL, "bottom extension" },
        { "topext",     POINT,  NULL, "top extension" },
    };
    vector_append(entries, _make_api_entry(
        "rectangle_to_polygon",
        MODULE_UTIL,
        "convert a two-point rectangle to a polygon describing this rectangle. Optionally, the polygon can be extended in the four directions (left/right/bottom/top). This function is useful for creating fill layer boundaries or fill target regions",
        "local region = util.rectangle_to_polygon(point.create(-100, -100), point.create(100, 100), -100, 0, 0, 200)",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* util.any_of(value, ratio) */
{
    struct parameter parameters[] = {
        { "comp",    ANY,       NULL, "either a value for direct comparison or a comparison function" },
        { "table",   TABLE,     NULL, "array-like table" },
        { "...",     VARARGS,   NULL, "additional arguments passed to comparison function" },
    };
    vector_append(entries, _make_api_entry(
        "any_of",
        MODULE_UTIL,
        "return true if any of the values in the array part of the table compare true (either directly to the given value or the function call is true). If a comparison function is given it is called with every element of the array and (if present) any additional parameters to util.any_of are passed to the function, following the array element",
        "util.any_of(42, { 1, 2, 3 }) -- false\nutil.any_of(function(e) return e == 42 end, { 1, 2, 3 }) -- also false",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* util.all_of(value, ratio) */
{
    struct parameter parameters[] = {
        { "comp",    ANY,       NULL, "either a value for direct comparison or a comparison function" },
        { "table",   TABLE,     NULL, "array-like table" },
        { "...",     VARARGS,   NULL, "additional arguments passed to comparison function" },
    };
    vector_append(entries, _make_api_entry(
        "any_of",
        MODULE_UTIL,
        "return true if all of the values in the array part of the table compare true (either directly to the given value or the function call is true). If a comparison function is given it is called with every element of the array and (if present) any additional parameters to util.all_of are passed to the function, following the array element",
        "util.all_of(42, { 42, 42, 42 }) -- true\nutil.all_of(function(e) return e == 42 end, { 42, 2, 3 }) -- false",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/*
    FIXME:
	util.check_grid
	util.check_string
	util.intersection
	util.intersection_ab
	util.polygon_xmax
	util.polygon_xmin
	util.polygon_ymax
	util.polygon_ymin
	util.sum
*/