function parameters()
    pcell.add_parameters(
        { "innerfingers", 1 },
        { "alternatingpolarity", false }
    )
end

function layout(cdac, _P)
    -- create LSB cell
    local lsbref = object.create("cdac_lsb")

    -- LSB cell transistors
    local mainswitch = pcell.create_layout("basic/mosfet", "mainswitch", {
        fingers = 1,
        gatelength = 20,
    })
    mainswitch:move_point(mainswitch:get_area_anchor("gate1").bl, point.create(0, 0))
    mainswitch:translate_x(-10)
    lsbref:merge_into(mainswitch)

    -- LSB cell caps
    local cap = pcell.create_layout("passive/capacitor/mom", "_cap", {
        fingers = _P.innerfingers + 2,
        fingerwidth = 50,
        fingerspace = 50,
        fingerheight = 2000,
        fingeroffset = 100,
        alternatingpolarity = _P.alternatingpolarity,
        railwidth = 100,
        firstmetal = 4,
        lastmetal = 7,
        alignmentbox_include_halffinger = true
    })
    local leftcap = cap:copy()
    leftcap:rotate_90_left()
    local rightcap = cap:copy()
    rightcap:rotate_90_right()
    leftcap:move_point(
        point.create(
            leftcap:get_area_anchor("lowerrail").r,
            0.5 * (
                leftcap:get_area_anchor("lowerrail").b +
                leftcap:get_area_anchor("lowerrail").t
            )
        ),
        point.create(
            mainswitch:get_area_anchor("sourcedrain1").l,
            0.5 * (
                mainswitch:get_area_anchor("sourcedrain1").b +
                mainswitch:get_area_anchor("sourcedrain1").t
            )
        )
    )
    leftcap:translate_x(-200)
    rightcap:move_point(
        point.create(
            rightcap:get_area_anchor("lowerrail").l,
            0.5 * (
                rightcap:get_area_anchor("lowerrail").b +
                rightcap:get_area_anchor("lowerrail").t
            )
        ),
        point.create(
            mainswitch:get_area_anchor("sourcedrain-1").r,
            0.5 * (
                mainswitch:get_area_anchor("sourcedrain-1").b +
                mainswitch:get_area_anchor("sourcedrain-1").t
            )
        )
    )
    rightcap:translate_x(200)
    lsbref:merge_into(leftcap)
    lsbref:merge_into(rightcap)
    lsbref:inherit_alignment_box(leftcap)
    lsbref:inherit_alignment_box(rightcap)

    -- instantiate LSB cells
    local lsbcells = cdac:add_child_array(lsbref, "lsbcells", 1, 4)
    cdac:inherit_alignment_box(lsbcells)
end
