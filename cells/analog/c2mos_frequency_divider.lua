function parameters()
    pcell.add_parameters(
        { "gatelength", technology.get_dimension("Minimum Gate Length"), argtype = "integer" },
        { "gatespace", technology.get_dimension("Minimum Gate XSpace"), argtype = "integer" },
        { "sdwidth", technology.get_dimension("Minimum M1 Width") },
        { "gatestrapwidth", technology.get_dimension("Minimum M1 Width") },
        { "gatestrapspace", technology.get_dimension("Minimum M1 Space") },
        { "clockfingers", 40 },
        { "nmosclockfingerwidth", 500 },
        { "pmosclockfingerwidth", 500 },
        { "nmosinputfingerwidth", 500 },
        { "pmosinputfingerwidth", 500 },
        { "inputfingers", 32 },
        { "sepfingers", 2 }
    )
end

function layout(divider, _P)
    local latch1 = pcell.create_layout("analog/c2mos_latch", "latch1", {
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        sdwidth = _P.sdwidth,
        gatestrapwidth = _P.gatestrapwidth,
        gatestrapspace = _P.gatestrapspace,
        clockfingers = _P.clockfingers,
        nmosclockfingerwidth = _P.nmosclockfingerwidth,
        pmosclockfingerwidth = _P.pmosclockfingerwidth,
        nmosinputfingerwidth = _P.nmosinputfingerwidth,
        pmosinputfingerwidth = _P.pmosinputfingerwidth,
        inputfingers = _P.inputfingers,
        sepfingers = _P.sepfingers,
    })
    local latch2 = latch1:copy()
    latch2:mirror_at_yaxis()
    latch2:abut_right(latch1)
    divider:merge_into(latch1)
    divider:merge_into(latch2)
    divider:inherit_alignment_box(latch1)
    divider:inherit_alignment_box(latch2)
end
