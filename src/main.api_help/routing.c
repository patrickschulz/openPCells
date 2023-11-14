/* routing.legalize */ // FIXME: legalize
{
    struct parameter parameters[] = {

    };
    vector_append(entries, _make_api_entry(
        "legalize",
        MODULE_ROUTING,
        "",
        "",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/* routing.route */ // FIXME: route
{
    struct parameter parameters[] = {

    };
    vector_append(entries, _make_api_entry(
        "route",
        MODULE_ROUTING,
        "",
        "",
        parameters,
        sizeof(parameters) / sizeof(parameters[0])
    ));
}

/*
    FIXME:
	routing.basic
*/
