/* alignmentgroup.create */
{
    struct parameter parameters[] = {
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "create",
        MODULE_ALIGNMENTGROUP,
        "create an alignment group that stores alignment boxes of several different objects. Objects are added subsequently and the alignment group can be given to any object.align/abut function as a target parameter.",
        "local cell1 = ...\nlocal cell2 = ...\nlocal cell3 = ...\nlocal group = alignmentgroup.create()\ngroup:add(cell1)\ngroup:add(cell2)\ncell3:abut_bottom(group)",
        parameters
    ));
}

/* alignmentgroup.add */
{
    struct parameter parameters[] = {
        { "self",       TABLE,      NULL, "alignment group" },
        { "object",     OBJECT,     NULL, "object whose alignmentbox is added to the group" },
        { NULL }
    };
    vector_append(entries, _make_api_entry(
        "add",
        MODULE_ALIGNMENTGROUP,
        "add the alignment box of a given object to the group",
        "group:add(cell)",
        parameters
    ));
}
