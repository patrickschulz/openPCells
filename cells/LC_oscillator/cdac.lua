function parameters()
    pcell.add_parameters(
        { "numcells", 16 },
        { "firstmetal", 1 },
        { "lastmetal", 1 },
        { "innerfingers", 1 },
        { "fingerwidth", 0 },
        { "fingerspace", 0, posvals = even() },
        { "fingerlength", 0 },
        { "railwidth", 0 },
        { "capspace", 0 },
        { "gatelength", 0 },
        { "gatespace", 0 },
        { "sdviaextension", 0 },
        { "switchfingerwidth", 0 },
        { "alternatingpolarity", false },
        { "vsslinewidth", 0 },
        { "vsslinespace", 0 }
    )
end

function layout(cdac, _P)
    -- create LSB cell
    local lsbref = object.create("cdac_lsb")

    -- LSB cell transistors
    local switch = pcell.create_layout("basic/mosfet", "switch", {
        fingers = 3,
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        fingerwidth = _P.switchfingerwidth,
        drawtopgate = true,
        sdwidth = 44,
    })
    switch:move_point(switch:get_area_anchor("gate1").bl, point.create(0, 0))
    switch:translate_x(-_P.gatelength / 2 - 1 * (_P.gatelength + _P.gatespace))
    lsbref:merge_into(switch)

    -- drain/source vias
    geometry.viabltr(lsbref, 1, _P.firstmetal - 1,
        switch:get_area_anchor("sourcedrain2").bl:translate_y(-_P.sdviaextension),
        switch:get_area_anchor("sourcedrain2").tr
    )
    geometry.viabltr(lsbref, 1, _P.firstmetal - 1,
        switch:get_area_anchor("sourcedrain-2").bl:translate_y(-_P.sdviaextension),
        switch:get_area_anchor("sourcedrain-2").tr
    )

    -- LSB cell caps
    local cap = pcell.create_layout("passive/capacitor/mom", "_cap", {
        fingers = _P.innerfingers + ((_P.innerfingers % 2 == 0) and 3 or 2),
        fingerwidth = _P.fingerwidth,
        fingerspace = _P.fingerspace,
        fingerheight = _P.fingerlength,
        fingeroffset = 100,
        alternatingpolarity = _P.alternatingpolarity,
        railwidth = _P.railwidth,
        uviashrink = _P.fingerspace / 2,
        drawlrail = _P.innerfingers > 1,
        lrext = 2 * -_P.fingerspace,
        firstmetal = _P.firstmetal,
        lastmetal = _P.lastmetal,
        viaxcontinuous = true,
        alignmentbox_include_halffinger = true
    })
    local leftcap = cap:copy()
    leftcap:rotate_90_left()
    local rightcap = cap:copy()
    rightcap:rotate_90_right()
    leftcap:move_point(
        point.create(
            leftcap:get_anchor_line_y("railbottom"),
            0.5 * (
                leftcap:get_area_anchor("upperrail").b +
                leftcap:get_area_anchor("upperrail").t
            )
        ),
        point.create(
            switch:get_area_anchor("sourcedrain1").l,
            0.5 * (
                switch:get_area_anchor("sourcedrain1").b +
                switch:get_area_anchor("sourcedrain1").t
            )
        )
    )
    leftcap:translate_x(-_P.capspace)
    rightcap:move_point(
        point.create(
            rightcap:get_anchor_line_y("railbottom"),
            0.5 * (
                rightcap:get_area_anchor("upperrail").b +
                rightcap:get_area_anchor("upperrail").t
            )
        ),
        point.create(
            switch:get_area_anchor("sourcedrain-1").r,
            0.5 * (
                switch:get_area_anchor("sourcedrain-1").b +
                switch:get_area_anchor("sourcedrain-1").t
            )
        )
    )
    rightcap:translate_x(_P.capspace)
    lsbref:merge_into(leftcap)
    lsbref:merge_into(rightcap)
    lsbref:inherit_alignment_box(leftcap)
    lsbref:inherit_alignment_box(rightcap)

    -- left/right vss lines
    lsbref:add_area_anchor_bltr("leftvssline",
        point.create(
            switch:get_area_anchor("sourcedrain1").l - _P.vsslinespace,
            leftcap:get_area_anchor("upperrail").b
        ),
        point.create(
            switch:get_area_anchor("sourcedrain1").l - _P.vsslinespace + _P.vsslinewidth,
            leftcap:get_area_anchor("upperrail").t
        )
    )
    lsbref:add_area_anchor_bltr("rightvssline",
        point.create(
            switch:get_area_anchor("sourcedrain-1").l + _P.vsslinespace - _P.vsslinewidth,
            rightcap:get_area_anchor("upperrail").b
        ),
        point.create(
            switch:get_area_anchor("sourcedrain-1").l + _P.vsslinespace,
            rightcap:get_area_anchor("upperrail").t
        )
    )
    geometry.rectangleareaanchor(lsbref, generics.metal(1), "leftvssline")
    geometry.rectangleareaanchor(lsbref, generics.metal(1), "rightvssline")

    -- connect vss lines to outermost source/drain regions
    geometry.rectanglebltr(lsbref, generics.metal(1),
        point.create(
            lsbref:get_area_anchor("leftvssline").r,
            switch:get_area_anchor("sourcedrain1").b
        ),
        switch:get_area_anchor("sourcedrain1").tl
    )
    geometry.rectanglebltr(lsbref, generics.metal(1),
        switch:get_area_anchor("sourcedrain-1").br,
        point.create(
            lsbref:get_area_anchor("rightvssline").l,
            switch:get_area_anchor("sourcedrain-1").t
        )
    )

    -- instantiate LSB cells
    local lsbcells = cdac:add_child_array(lsbref, "lsbcells", 1, _P.numcells)
    cdac:inherit_alignment_box(lsbcells)
end
