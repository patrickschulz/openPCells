/* util.is_on_grid(t) */
{
    struct parameter parameters[] = {
        { "value",  INTEGER, NULL, "value to check" },
        { "grid",   INTEGER, NULL, "grid" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "is_on_grid",
        MODULE_UTIL,
        "check if a value is on a given grid. This function returns a boolean, and does not assert internally. This is for detecting off-grid situations in order to remedy them, not as a sanity check. Use util.check_grid if that is required.",
        "util.check_grid(80, 10) -- true\nutil.check_grid(85, 10) -- false",
        parameters
    ));
}

/* util.check_grid(t) */
{
    struct parameter parameters[] = {
        { "grid",   INTEGER, NULL, "grid" },
        { "...",    VARARGS, NULL, "one or more numbers" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "check_grid",
        MODULE_UTIL,
        "check that all given numbers are on integer multiples of the given grid. This function calls assert, so aborts the entire program if the assertation fails. This is intended as a sanity check, not detection in order to solve this. Use util.is_on_grid if that is required.",
        "util.check_grid(100, 100, 800, 42, 10000) -- will fail",
        parameters
    ));
}

/* util.min(t) */
{
    struct parameter parameters[] = {
        { "t", TABLE, NULL, "table as numeric array" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "min",
        MODULE_UTIL,
        "retrieve the minimum value of a numeric array. Returns the corresponding index as second return value",
        "local min, idx = util.min({ 1, 4, 2, 3 }) -- 1, 1",
        parameters
    ));
}

/* util.max(t) */
{
    struct parameter parameters[] = {
        { "t", TABLE, NULL, "table as numeric array" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "max",
        MODULE_UTIL,
        "retrieve the maximum value of a numeric array. Returns the corresponding index as second return value",
        "local max, idx = util.max({ 1, 4, 2, 3 }) -- 4, 2",
        parameters
    ));
}

/* util.make_counter(polygon) */
{
    struct parameter parameters[] = {
        { "start", INTEGER, NULL, "optional start value" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "make_counter",
        MODULE_UTIL,
        "create a counter function that increments and returns its current value everytime it is called. If a value is given, the counter starts at that value. The default is 1.",
        "local counter = util.make_counter()\nprint(counter()) -- 1\nprint(counter()) -- 2\nprint(counter()) -- 3",
        parameters
    ));
}

/* util.polygon_xmin(polygon) */
{
    struct parameter parameters[] = {
        { "polygon", POINTLIST, NULL, "polygon" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "polygon_xmin",
        MODULE_UTIL,
        "retrieve the minimum x-value of all points of a polygon",
        "local polygon = util.rectangle_to_polygon(\n    point.create(-50, -50),\n    point.create(50, 50)\n)\nlocal xmin = util.polygon_xmin(polygon) -- -50",
        parameters
    ));
}

/* util.polygon_xmax(polygon) */
{
    struct parameter parameters[] = {
        { "polygon", POINTLIST, NULL, "polygon" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "polygon_xmax",
        MODULE_UTIL,
        "retrieve the maximum x-value of all points of a polygon",
        "local polygon = util.rectangle_to_polygon(\n    point.create(-50, -50),\n    point.create(50, 50)\n)\nlocal xmax = util.polygon_xmax(polygon) -- 50",
        parameters
    ));
}

/* util.polygon_ymin(polygon) */
{
    struct parameter parameters[] = {
        { "polygon", POINTLIST, NULL, "polygon" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "polygon_ymin",
        MODULE_UTIL,
        "retrieve the minimum y-value of all points of a polygon",
        "local polygon = util.rectangle_to_polygon(\n    point.create(-50, -50),\n    point.create(50, 50)\n)\nlocal ymin = util.polygon_ymin(polygon) -- -50",
        parameters
    ));
}

/* util.polygon_ymax(polygon) */
{
    struct parameter parameters[] = {
        { "polygon", POINTLIST, NULL, "polygon" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "polygon_ymax",
        MODULE_UTIL,
        "retrieve the maximum y-value of all points of a polygon",
        "local polygon = util.rectangle_to_polygon(\n    point.create(-50, -50),\n    point.create(50, 50)\n)\nlocal ymax = util.polygon_ymax(polygon) -- 50",
        parameters
    ));
}

/* util.xmirror(pts, xcenter) */
{
    struct parameter parameters[] = {
        { "pts",        POINTLIST,  NULL,   "list of points" },
        { "xcenter",    INTEGER,    "0",    "mirror center" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "xmirror",
        MODULE_UTIL,
        "create a copy of the points in pts (a table) with all x-coordinates mirrored with respect to xcenter",
        "local pts = { point.create(10, 0), point.create(20, 0) }\nutil.xmirror(pts, 0) -- { (-10, 0), (-20, 0) }",
        parameters
    ));
}

/* util.ymirror(pts, ycenter) */
{
    struct parameter parameters[] = {
        { "pts",        POINTLIST,  NULL,   "list of points" },
        { "ycenter",    INTEGER,    "0",    "mirror center" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "ymirror",
        MODULE_UTIL,
        "create a copy of the points in pts (a table) with all y-coordinates mirrored with respect to ycenter",
        "local pts = { point.create(0, 10), point.create(0, 20) }\nutil.ymirror(pts, 0) -- { (0, -10), (0, -20) }",
        parameters
    ));
}

/* util.xymirror(pts, xcenter, ycenter) */
{
    struct parameter parameters[] = {
        { "pts",        POINTLIST,  NULL,   "list of points" },
        { "xcenter",    INTEGER,    "0",    "mirror center x-coordinate" },
        { "ycenter",    INTEGER,    "0",    "mirror center y-coordinate" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "xymirror",
        MODULE_UTIL,
        "create a copy of the points in pts (a table) with all x- and y-coordinates mirrored with respect to xcenter and ycenter, respectively",
        "local pts = { point.create(10, 10), point.create(20, 20) }\nutil.ymirror(pts, 0, 0) -- { (-10, -10), (-20, -20) }",
        parameters
    ));
}

/* util.filter_forward(pts, fun) */
{
    struct parameter parameters[] = {
        { "pts",    POINTLIST,  NULL,   "point array to append to" },
        { "fun",    FUNCTION,   NULL,   "filter function" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "filter_forward",
        MODULE_UTIL,
        "iterate forward through the list of points and create a new list with copied points that match the predicate. The predicate function is called with every point.",
        "local pts = { ... }\nlocal predicate = function(pt) return pt:getx() > 0 end\nlocal newpts = util.filter_forward(pts, predicate)",
        parameters
    ));
}

/* util.filter_backward(pts, fun) */
{
    struct parameter parameters[] = {
        { "pts",    POINTLIST,  NULL,   "point array to append to" },
        { "fun",    FUNCTION,   NULL,   "filter function" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "filter_backward",
        MODULE_UTIL,
        "iterate backward through the list of points and create a new list with copied points that match the predicate. The predicate function is called with every point.",
        "local pts = { ... }\nlocal predicate = function(pt) return pt:getx() > 0 end\nlocal newpts = util.filter_backward(pts, predicate)",
        parameters
    ));
}

/* util.merge_forwards(pts, pts2) */
{
    struct parameter parameters[] = {
        { "pts",    POINTLIST,  NULL,   "point array to append to" },
        { "pts2",   POINTLIST,  NULL,   "point array to append from" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "merge_forwards",
        MODULE_UTIL,
        "append all points from pts2 to pts1. Iterate pts2 forward. Operates in-place, thus pts is modified",
        "util.merge_forward(pts, pts2)",
        parameters
    ));
}

/* util.merge_backwards(pts, pts2) */
{
    struct parameter parameters[] = {
        { "pts",    POINTLIST,  NULL,   "point array to append to" },
        { "pts2",   POINTLIST,  NULL,   "point array to append from" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "merge_backwards",
        MODULE_UTIL,
        "append all points from pts2 to pts1. Iterate pts2 backwards. Operates in-place, thus pts is modified",
        "util.merge_backward(pts, pts2)",
        parameters
    ));
}

/* util.merge_tables(t1, t2) */
{
    struct parameter parameters[] = {
        { "t1", TABLE,  NULL,   "table 1" },
        { "t2", TABLE,  NULL,   "table 2" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "merge_tables",
        MODULE_UTIL,
        "create a new table with t1 and t2 concatenated. The elements of t2 are append after thos of t1. Only the array entries of t1 and t2 are processed.",
        "util.merge_tables({ 1, 2, 3 }, { 4, 5, 6 }) -- { 1, 2, 3, 4, 5, 6 }",
        parameters
    ));
}

/* util.reverse(pts) */
{
    struct parameter parameters[] = {
        { "pts",    POINTLIST,  NULL,   "point array" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "reverse",
        MODULE_UTIL,
        "create a copy of the point array with the order of points reversed",
        "local reversed = util.reverse(pts)",
        parameters
    ));
}

/* util.make_insert_xy */
{
    struct parameter parameters[] = {
        { "pts",    POINTLIST,  NULL,   "point array" },
        { "index",  INTEGER,    "nil",  "optional index" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "make_insert_xy",
        MODULE_UTIL,
        "create a function that inserts points into a point array. XY mode, thus points are given as two coordinates. If an index is given, insert at that position. Mostly useful with 1 as an index or not index at all (append)",
        "local pts = {}\nlocal _append = util.make_insert_xy(pts)\n_append(0, 0)\n_append(100, 0)\n_append(100, 100)\n_append(0, 100)",
        parameters
    ));
}

/* util.make_insert_pts(pts, idx) */
{
    struct parameter parameters[] = {
        { "pts",    POINTLIST,  NULL,   "point array" },
        { "index",  INTEGER,    "nil",  "optional index" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "make_insert_pts",
        MODULE_UTIL,
        "create a function that inserts points into a point array. Point mode, thus points are given as single points. If an index is given, insert at that position. Mostly useful with 1 as an index or not index at all (append)",
        "local pts = {}\nlocal _append = util.make_insert_pts(pts)\n_append(point.create(0, 0))\n_append(point.create(100, 0))\n_append(point.create(100, 100))\n_append(point.create(0, 100))",
        parameters
    ));
}

/* util.range(lower, upper, incr) */
{
    struct parameter parameters[] = {
        { "lower",  INTEGER, NULL,  "lower (inclusive) bound" },
        { "upper",  INTEGER, NULL,  "upper (inclusive) bound" },
        { "incr",   INTEGER, "1",   "increment" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "range",
        MODULE_UTIL,
        "create a table with numeric entries between lower and upper (both inclusive). The entries spacing is specified by the increment (default 1)",
        "util.range(1, 5) -- { 1, 2, 3, 4, 5 }\nutil.range(2, 8, 3) -- { 2, 5, 8 }",
        parameters
    ));
}

/* util.remove(t, comp) */
{
    struct parameter parameters[] = {
        { "t",      TABLE,  NULL,  "array" },
        { "comp",   ANY,    NULL,  "comparison value of function" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "remove",
        MODULE_UTIL,
        "create a shallow copy of a table with certain elements matching the given criteria removed. The 'comp' parameter can either be a value, which will be compared directly to the entries or a comparison function. If the result of the function call is 'true', the entry is NOT included in the results table.",
        "util.remove({1, 2, 3, 4, 5}, 3) -- { 1, 2, 4, 5 }\nutil.remove({1, 2, 3, 4, 5}, function(e) return e % 2 == 0 end) -- { 1, 3, 5 }",
        parameters
    ));
}

/* util.remove_index(t, comp) */
{
    struct parameter parameters[] = {
        { "t",      TABLE,      NULL,  "array" },
        { "index",  ANY,        NULL,  "index or index table of to-be-removed element(s)" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "remove_index",
        MODULE_UTIL,
        "create a shallow copy of a table with the element(s) at the 'index(es)' removed. Index can be either a scalar integer or a table containing multiple indices which shall be removed",
        "util.remove_index({10, 20, 30, 40, 50}, 3) -- { 10, 20, 40, 50 }",
        parameters
    ));
}

/* util.remove_inplace(t, comp) */
{
    struct parameter parameters[] = {
        { "t",      TABLE,  NULL,  "array" },
        { "comp",   ANY,    NULL,  "comparison value of function" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "remove_inplace",
        MODULE_UTIL,
        "remove certain elements matching the given criteria. The 'comp' parameter can either be a value, which will be compared directly to the entries or a comparison function. If the result of the function call is 'true', the entry is NOT included in the results table.",
        "util.remove({1, 2, 3, 4, 5}, 3) -- { 1, 2, 4, 5 }\nutil.remove({1, 2, 3, 4, 5}, function(e) return e % 2 == 0 end) -- { 1, 3, 5 }",
        parameters
    ));
}

/* util.remove_index_inplace(t, comp) */
{
    struct parameter parameters[] = {
        { "t",      TABLE,      NULL,  "array" },
        { "index",  INTEGER,    NULL,  "index of to-be-removed element" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "remove_index_inplace",
        MODULE_UTIL,
        "remove the element of the given table at the given index (actually just a wrapper for table.remove)",
        "util.remove_index({10, 20, 30, 40, 50}, 3) -- { 10, 20, 40, 50 }",
        parameters
    ));
}

/* util.fill_all_with(num, filler) */
{
    struct parameter parameters[] = {
        { "num",    INTEGER, NULL, "number of repetitions" },
        { "filler", ANY,     NULL, "value which should be repeated. Can be anything, but probably most useful with strings or numbers" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "fill_all_with",
        MODULE_UTIL,
        "create an array-like table with one entry repeated N times. This is useful, for example, for specifying gate contacts for basic/cmos",
        "local gatecontactpos = util.fill_all_with(4, \"center\") -- { \"center\", \"center\", \"center\", \"center\" }",
        parameters
    ));
}

/* util.fill_predicate_with(num, filler, predicate, other) */
{
    struct parameter parameters[] = {
        { "num",        INTEGER,    NULL, "number of repetitions" },
        { "filler",     ANY,        NULL, "value which should be repeated at even numbers. Can be anything, but probably most useful with strings or numbers" },
        { "predicate",  FUNCTION,   NULL, "predicate which is called with every index" },
        { "other",      ANY,        NULL, "value which should be repeated at odd numbers. Can be anything, but probably most useful with strings or numbers" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "fill_predicate_with",
        MODULE_UTIL,
        "create an array-like table with two entries (total number of entries is N). This function (compared to fill_all_with, fill_odd_with and fill_even_with) allows for more complex patterns. To do this, a predicate (a function) is called on every index. If the predicate is true, the first entry is inserted, otherwise the second one. This function is useful, for example, for specifying gate contacts for basic/cmos. Counting starts at 1, so the first entry will be 'other'",
        "local contactpos = util.fill_predicate_with(8, \"power\", function(i) return i % 4 == 0 end, \"outer\")",
        parameters
    ));
}

/* util.fill_even_with(num, filler, other) */
{
    struct parameter parameters[] = {
        { "num",    INTEGER, NULL, "number of repetitions" },
        { "filler", ANY,     NULL, "value which should be repeated at even numbers. Can be anything, but probably most useful with strings or numbers" },
        { "other",  ANY,     NULL, "value which should be repeated at odd numbers. Can be anything, but probably most useful with strings or numbers" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "fill_even_with",
        MODULE_UTIL,
        "create an array-like table with two entries repeated N / 2 times, alternating. Counting starts at 1. This is useful, for example, for specifying gate contacts for basic/cmos. Counting starts at 1, so the first entry will be 'other'",
        "local gatecontactpos = util.fill_even_with(4, \"center\", \"upper\") -- { \"upper\", \"center\", \"upper\", \"center\" }",
        parameters
    ));
}

/* util.fill_odd_with(num, filler, other) */
{
    struct parameter parameters[] = {
        { "num",    INTEGER, NULL, "number of repetitions" },
        { "filler", ANY,     NULL, "value which should be repeated at odd numbers. Can be anything, but probably most useful with strings or numbers" },
        { "other",  ANY,     NULL, "value which should be repeated at even numbers. Can be anything, but probably most useful with strings or numbers" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "fill_odd_with",
        MODULE_UTIL,
        "create an array-like table with two entries repeated N / 2 times, alternating. Counting starts at 1. This is useful, for example, for specifying gate contacts for basic/cmos. Counting starts at 1, so the first entry will be 'filler'",
        "local gatecontactpos = util.fill_odd_with(4, \"center\", \"upper\") -- { \"center\", \"upper\", \"center\", \"upper\" }",
        parameters
    ));
}

/* util.clone_shallow(t) */
{
    struct parameter parameters[] = {
        { "table", TABLE, NULL, "table" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "clone_shallow",
        MODULE_UTIL,
        "create a shallow copy of a table. This function creates a copy of the given table, where all first-level values are copied. If those values are tables, they reference the same table as the original object.",
        "local new = util.clone_shallow(t)",
        parameters
    ));
}

/* util.clone_shallow_predicate(t) */
{
    struct parameter parameters[] = {
        { "table",      TABLE,      NULL, "table" },
        { "predicate",  FUNCTION,   NULL, "predicate function" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "clone_shallow_predicate",
        MODULE_UTIL,
        "create a shallow copy of a table. This function creates a copy of the given table, where all first-level values are copied. If those values are tables, they reference the same table as the original object. This function only copies items where the given predicate function (called with the key and the value of the item) returns true.",
        "local new = util.clone_shallow_predicate(t, function(k, v) if string.match(v, \"vdd.+\") end)",
        parameters
    ));
}

/* util.add_options(baseoptions, additional) */
{
    struct parameter parameters[] = {
        { "baseoptions",        TABLE,      NULL, "base options" },
        { "additionaloptions",  TABLE,      NULL, "additional options" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "add_options",
        MODULE_UTIL,
        "create a copy of the baseoptions table and add all key-value pairs found in additionaloptions. This function clones baseoptions so the original is not altered. This copy is flat, so only the first-level elements are copied (e.g. tables will reference the same object). This function is useful to modify a set of base options for several devices such as mosfets, which only differ in a few options",
        "local baseoptions = ...\nlocal fet = pcell.create_layout(\"basic/mosfet\", \"fet\", util.add_options(baseoptions, { gatelength = 100 }))",
        parameters
    ));
}

/* util.ratio_split_even(value, ratio) */
{
    struct parameter parameters[] = {
        { "value",  INTEGER,    NULL, "value for division" },
        { "ratio",  NUMBER,     NULL, "target ratio of the two result values" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "ratio_split_even",
        MODULE_UTIL,
        "create two values that sum up to the input value and have the specified ratio. The values are adjusted so that both of them are even, possibly changing the ratio slightly. The input value must be even",
        "local pitch = 1000\nlocal width, space = util.ratio_split_even(pitch, 2) -- results in 668 and 332, the actual ratio then is 2.012",
        parameters
    ));
}

/* util.ratio_split_multiple_of(value, ratio) */
{
    struct parameter parameters[] = {
        { "value",      INTEGER,    NULL, "value for division" },
        { "ratio",      NUMBER,     NULL, "target ratio of the two result values" },
        { "multiple",   NUMBER,     NULL, "multiple target" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "ratio_split_multiple_of",
        MODULE_UTIL,
        "create two values that sum up to the input value and have the specified ratio. The values are adjusted so that both of them are multiples of the given value ('multiple'), possibly changing the ratio slightly. The input value must be divisable by 'multiple'. This function called with multiple == 2 behaves exactly like ratio_split_even",
        "local pitch = 1000\nlocal width, space = util.ratio_split_even(pitch, 2, 20) -- results in 680 and 320, the actual ratio then is 2.125",
        parameters
    ));
}

/* util.make_rectangle(value, ratio) */
{
    struct parameter parameters[] = {
        { "center",     POINT,      NULL, "center of the rectangle" },
        { "width",      INTEGER,    NULL, "width" },
        { "height",     INTEGER,    NULL, "height" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "make_rectangle",
        MODULE_UTIL,
        "create a rectangle from a center point and the width and height. This function returns two points (bottom-left and top-right)",
        "local bl, tr = util.make_rectangle(point.create(0, 0), 100, 100)",
        parameters
    ));
}

/* util.rectangle_to_polygon(value, ratio) */
{
    struct parameter parameters[] = {
        { "bl",         POINT,      NULL, "lower-left corner of the rectangle" },
        { "tr",         POINT,      NULL, "upper-right corner of the rectangle" },
        { "leftext",    INTEGER,    NULL, "left extension" },
        { "rightext",   INTEGER,    NULL, "right extension" },
        { "bottomext",  INTEGER,    NULL, "bottom extension" },
        { "topext",     INTEGER,    NULL, "top extension" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "rectangle_to_polygon",
        MODULE_UTIL,
        "convert a two-point rectangle to a polygon describing this rectangle. Optionally, the polygon can be extended in the four directions (left/right/bottom/top). This function is useful for creating fill layer boundaries or fill target regions",
        "local region = util.rectangle_to_polygon(point.create(-100, -100), point.create(100, 100), -100, 0, 0, 200)",
        parameters
    ));
}

/* util.fit_rectangular_polygon(value, ratio) */
{
    struct parameter parameters[] = {
        { "bl",         POINT,      NULL, "lower-left corner of the rectangle" },
        { "tr",         POINT,      NULL, "upper-right corner of the rectangle" },
        { "xgrid",      INTEGER,    NULL, "xgrid" },
        { "ygrid",      INTEGER,    NULL, "ygrid" },
        { "minxext",    INTEGER,    NULL, "minimum extension in x-direction" },
        { "minyext",    INTEGER,    NULL, "minimum extension in y-direction" },
        { "xmultiple",  STRING,     NULL, "multiplicity in x" },
        { "ymultiple",  STRING,     NULL, "multiplicity in y" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "fit_rectangular_polygon",
        MODULE_UTIL,
        "convert a two-point rectangle to a polygon describing this rectangle. The polygon is extended so that its width and height are a integer multiple of the specified x- and y-grid. The polygon's width and height are always at least the width and height of the rectangle. Additionally, a minimum extension can be given in x- and y-direction, which can further increase the polygon's size. The resulting rectangle can be tuned so that it has an even or odd multiplicity in either of the directions. The keys \"even\" or \"odd\" can be used for the last two parameters 'xmultiple' and 'ymultiple'. If they are nil, the resulting rectangle is not modified from the original fitting.",
        "local region = util.fit_rectangular_polygon(point.create(-127, -110), point.create(118, 109), 20, 20, 50, 50)",
        parameters
    ));
}
/* util.offset_polygon(polygon, offset) */
{
    struct parameter parameters[] = {
        { "polygon",    POINTLIST,  NULL, "subject polygon" },
        { "offset",     INTEGER,    NULL, "offset" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "offset_polygon",
        MODULE_UTIL,
        "Calculate a new polygon from a given one with all lines shifted by a given offset. This function has potentially many uses, but as of version 0.10.0 it is mostly used for expanding layer boundaries to include mandatory spacing to automatically generated fill structures. Hence, it is only tested for positive offsets. Additionally, for extreme cases (acute angles with large offsets) self-intersecting polygons can occur. This function should fix these, but it currently does not. This is a bug. Submission of proper algorithms to solve this are very welcome.",
        "local new_polygon = util.offset_polygon(polygon, 100)",
        parameters
    ));
}

/* util.rectangle_intersection(value, ratio) */
{
    struct parameter parameters[] = {
        { "bl1", POINT, NULL, "lower-left corner of the first rectangle" },
        { "tr1", POINT, NULL, "upper-right corner of the first rectangle" },
        { "bl2", POINT, NULL, "lower-left corner of the second rectangle" },
        { "tr2", POINT, NULL, "upper-right corner of the second rectangle" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "rectangle_intersection",
        MODULE_UTIL,
        "Compute the intersection of two rectangles and return it as a table with 'bl' (bottom-left) and 'tr' (top-right) entries. If no itersection exists, this function returns nil.",
        "local region = util.rectangle_intersection(point.create(0, 0), point.create(100, 100), point.create(20, 20), point.create(200, 20))",
        parameters
    ));
}

/* util.any_of(value, ratio) */
{
    struct parameter parameters[] = {
        { "comp",    ANY,       NULL, "either a value for direct comparison or a comparison function" },
        { "table",   TABLE,     NULL, "array-like table" },
        { "...",     VARARGS,   NULL, "additional arguments passed to comparison function" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "any_of",
        MODULE_UTIL,
        "return true if any of the values in the array part of the table compare true (either directly to the given value or the function call is true). If a comparison function is given it is called with every element of the array and (if present) any additional parameters to util.any_of are passed to the function, following the array element",
        "util.any_of(42, { 1, 2, 3 }) -- false\nutil.any_of(function(e) return e == 42 end, { 1, 2, 3 }) -- also false",
        parameters
    ));
}

/* util.all_of(value, ratio) */
{
    struct parameter parameters[] = {
        { "comp",    ANY,       NULL, "either a value for direct comparison or a comparison function" },
        { "table",   TABLE,     NULL, "array-like table" },
        { "...",     VARARGS,   NULL, "additional arguments passed to comparison function" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "all_of",
        MODULE_UTIL,
        "return true if all of the values in the array part of the table compare true (either directly to the given value or the function call is true). If a comparison function is given it is called with every element of the array and (if present) any additional parameters to util.all_of are passed to the function, following the array element",
        "util.all_of(42, { 42, 42, 42 }) -- true\nutil.all_of(function(e) return e == 42 end, { 42, 2, 3 }) -- false",
        parameters
    ));
}

/* util.transform_points(pts, func) */
{
    struct parameter parameters[] = {
        { "pts",    POINTLIST,  NULL, "the point list" },
        { "func",   FUNCTION,   NULL, "the transformation function" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "transform_points",
        MODULE_UTIL,
        "transform all points in a list of points. This function creates a copy of the point list (the points are copied too). Every point is transformed by the transformation function. Any return values of the function are ignored, the function should transform the given point in-place.",
        "util.transform_points({\n    point.create(0, 0),\n    point.create(100, 100)\n    point.create(50, 200)\n}, function(pt) pt:translate(100, 100) end)",
        parameters
    ));
}

/* util.round_to_grid(coordinate, grid) */
{
    struct parameter parameters[] = {
        { "coordinate", INTEGER,    NULL, "coordinate" },
        { "grid",       INTEGER,    NULL, "grid" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "round_to_grid",
        MODULE_UTIL,
        "round a coordinate to a multiple of the given grid",
        "util.round_to_grid(120, 100) -- 100\nutil.round_to_grid(160, 100) -- 200",
        parameters
    ));
}

/* util.fix_to_grid_higher(coordinate, grid) */
{
    struct parameter parameters[] = {
        { "coordinate", INTEGER,    NULL, "coordinate" },
        { "grid",       INTEGER,    NULL, "grid" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "fix_to_grid_higher",
        MODULE_UTIL,
        "fix a coordinate to a multiple of the given grid. This function works like a 'ceil(ing)' function, so the resulting number is either higher or equal. This means that this function does not behave symmetrically for negative and positive input. If this is required, use util.fix_to_grid_abs_higher.",
        "util.fix_to_grid_higher(120, 100) -- 200\nutil.fix_to_grid_higher(-120, 100) -- 100",
        parameters
    ));
}

/* util.fix_to_grid_lower(coordinate, grid) */
{
    struct parameter parameters[] = {
        { "coordinate", INTEGER,    NULL, "coordinate" },
        { "grid",       INTEGER,    NULL, "grid" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "fix_to_grid_lower",
        MODULE_UTIL,
        "fix a coordinate to a multiple of the given grid. This function works like a 'floor(ing)' function, so the resulting number is either lower or equal. This means that this function does not behave symmetrically for negative and positive input. If this is required, use util.fix_to_grid_abs_lower.",
        "util.fix_to_grid_lower(120, 100) -- 100\nutil.fix_to_grid_lower(-120, 100) -- 200",
        parameters
    ));
}

/* util.fix_to_grid_abs_higher(coordinate, grid) */
{
    struct parameter parameters[] = {
        { "coordinate", INTEGER,    NULL, "coordinate" },
        { "grid",       INTEGER,    NULL, "grid" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "fix_to_grid_abs_higher",
        MODULE_UTIL,
        "fix a coordinate to a multiple of the given grid. This function works like a 'ceil(ing)' function, but it is computed on the absolute value, so the absolute of the resulting number is either higher or equal. This means that this function does behave symmetrically for negative and positive input. If this is unwanted, use util.fix_to_grid_higher.",
        "util.fix_to_grid_abs_higher(120, 100) -- 200\nutil.fix_to_grid_abs_higher(-120, 100) -- 200",
        parameters
    ));
}

/* util.fix_to_grid_abs_lower(coordinate, grid) */
{
    struct parameter parameters[] = {
        { "coordinate", INTEGER,    NULL, "coordinate" },
        { "grid",       INTEGER,    NULL, "grid" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "fix_to_grid_abs_lower",
        MODULE_UTIL,
        "fix a coordinate to a multiple of the given grid. This function works like a 'floor(ing)' function, but it is computed on the absolute value, so the absolute of the resulting number is either lower or equal. This means that this function does behave symmetrically for negative and positive input. If this is unwanted, use util.fix_to_grid_lower.",
        "util.fix_to_grid_abs_lower(120, 100) -- 100\nutil.fix_to_grid_abs_lower(-120, 100) -- 100",
        parameters
    ));
}

/* util.foreach(coordinate, grid) */
{
    struct parameter parameters[] = {
        { "table",      TABLE,      NULL, "table (array-like)" },
        { "function",   FUNCTION,   NULL, "function to be applied to the elements" },
        { "...",        VARARGS,    NULL, "additional arguments passed to function" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "foreach",
        MODULE_UTIL,
        "apply a function to every element of a given table. Return a new table containing the results of these calls in the order of the original elements. Additional arguments can be passed to the function.",
        "util.foreach({ 1, 2, 3 }, generics.metal)",
        parameters
    ));
}

/* util.find(coordinate, grid) */
{
    struct parameter parameters[] = {
        { "table",  TABLE,  NULL, "table (array-like)" },
        { "value",  ANY,    NULL, "value" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "find",
        MODULE_UTIL,
        "find a value in an array. This function returns the index of that value and the value itself",
        "util.find({ 3, 4, 5 }, 4) -- 2, 4",
        parameters
    ));
}

/* util.find_predicate(coordinate, grid) */
{
    struct parameter parameters[] = {
        { "table",  TABLE,      NULL, "table (array-like)" },
        { "comp",   FUNCTION,   NULL, "comparison function" },
        { "...",    VARARGS,    NULL, "additional arguments passed to predicate function" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "find_predicate",
        MODULE_UTIL,
        "Like util.find, but call a function to do the comparison.",
        "util.find({ 3, 4, 5 }, function(e) return e == 4 end) -- 2, 4\nlocal target = 4]\nutil.find({ 3, 4, 5 }, function(e, t) return e == t end, target) -- 2, 4\n",
        parameters
    ));
}

/* util.fit_lines_upper(total, size, space) */
{
    struct parameter parameters[] = {
        { "total",  INTEGER,    NULL, "full width/height" },
        { "size",   INTEGER,    NULL, "line width/height" },
        { "space",  INTEGER,    NULL, "line spacing" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "fit_lines_upper",
        MODULE_UTIL,
        "Calculate the number of lines with the given size and space that fit into the given total width/height. This function rounds up.",
        "util.fit_lines_upper(10000, 500, 500) -- 11",
        parameters
    ));
}

/* util.fit_lines_lower(total, size, space) */
{
    struct parameter parameters[] = {
        { "total",  INTEGER,    NULL, "full width/height" },
        { "size",   INTEGER,    NULL, "line width/height" },
        { "space",  INTEGER,    NULL, "line spacing" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "fit_lines_lower",
        MODULE_UTIL,
        "Calculate the number of lines with the given size and space that fit into the given total width/height. This function rounds down.",
        "util.fit_lines_lower(10000, 500, 500) -- 10",
        parameters
    ));
}

/* util.fit_lines_width_grid(total, width, numlines, grid) */
{
    struct parameter parameters[] = {
        { "total",      INTEGER,    NULL, "full region size" },
        { "width",      INTEGER,    NULL, "width of lines to fit" },
        { "numlines",   INTEGER,    NULL, "number of lines to fit" },
        { "grid",       INTEGER,    "1",  "optional grid" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "fit_lines_width_grid",
        MODULE_UTIL,
        "Calculate the spacing of a given number of lines of a certain width that should fit in a region. This function can take a grid and will decrement the space until it fits on the grid",
        "util.fit_lines_lower(10000, 1000, 8) -- 285\nutil.fit_lines_lower(10000, 1000, 8, 10) -- 280",
        parameters
    ));
}

/* util.sum(t) */
{
    struct parameter parameters[] = {
        { "t", TABLE, NULL, "table as array" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "sum",
        MODULE_UTIL,
        "calculate the sum of all items of an numeric array",
        "local sum = util.sum({ 1, 2, 3 }) -- 6",
        parameters
    ));
}

/* util.uniq(t) */
{
    struct parameter parameters[] = {
        { "t", TABLE, NULL, "table as array" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "uniq",
        MODULE_UTIL,
        "create an array where only unique entries of the input array t are present. Equality is checked via the comparison operator '=='",
        "local u = util.uniq({ 1, 2, 3, 1, 4, 5, 2, 1, 7 }) -- { 1, 2, 3, 4, 5, 7 }",
        parameters
    ));
}

/* util.intersection(t) */
{
    struct parameter parameters[] = {
        { "s1", POINT, NULL, "start point of line 1" },
        { "s2", POINT, NULL, "end point of line 1" },
        { "t1", POINT, NULL, "start point of line 2" },
        { "t2", POINT, NULL, "end point of line 2" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "intersection",
        MODULE_UTIL,
        "calculate the intersection point of two lines. If the intersection is found, it is returned. If the lines are parallel, nil is returned. If the lines are not parallel but don't intersect (because they are not infinite), their virtual intersection point is returned after nil (as second return value)",
        "local ptreal, ptvirtual = util.intersection(spt1, spt2, tpt1, tpt2)",
        parameters
    ));
}

/* util.rectangle_union(t) */
{
    struct parameter parameters[] = {
        { "bl1", POINT, NULL, "bottom-left corner of rectangle 1" },
        { "tr1", POINT, NULL, "top-right corner of rectangle 1" },
        { "bl1", POINT, NULL, "bottom-left corner of rectangle 2" },
        { "tr2", POINT, NULL, "top-right corner of rectangle 2" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "rectangle_union",
        MODULE_UTIL,
        "calculate the rectangle union of two rectangles. This only return a non-nil result if the union of the two rectangles is still a true rectangle. The calculated union is return as a table with 'bl' and 'tr' entries",
        "local union = util.rectangle_union(bl1, tr1, bl2, tr2)",
        parameters
    ));
}
