int cell_powergrid_layout(struct object* powergrid, struct technology_state* techstate, struct pcell_state* pcell_state)
{
    (void)pcell_state;
    geometry_rectanglebltrxy(
        powergrid,
        generics_create_metal(techstate, 1),
        0, 0,
        100, 100
    );
    return 1;
}
