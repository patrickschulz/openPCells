function parameters()
    pcell.reference_cell("logic/base")
    pcell.add_parameter("fingers", 1)
    pcell.add_parameter("shiftinput", 0)
    pcell.add_parameter("shiftoutput", 0)
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")
    local xpitch = bp.gspace + bp.glength

    local gatecontactpos = {}
    for i = 1, _P.fingers do gatecontactpos[i] = "center" end

    local contactpos = {}
    for i = 1, _P.fingers + 1 do
        if i % 2 == 0 then
            contactpos[i] = "inner"
        else
            contactpos[i] = "power"
        end
    end
    local harness = pcell.create_layout("logic/harness", { 
        fingers = _P.fingers,
        shiftgatecontacts = _P.shiftinput,
        gatecontactpos = gatecontactpos,
        pcontactpos = contactpos,
        ncontactpos = contactpos,
    })
    gate:merge_into_update_alignmentbox(harness)

    -- gate strap
    if _P.fingers > 1 then
        gate:merge_into(geometry.rectangle(
            generics.metal(1),
            _P.fingers * bp.glength + (_P.fingers - 1) * bp.gspace, bp.gstwidth
        ):translate(0, _P.shiftinput))
    end

    -- signal transistors drain connections
    if _P.fingers > 2 then
        gate:merge_into(geometry.multiple_y(
            geometry.path(
                generics.metal(1),
                {
                    point.create(-_P.fingers * xpitch / 2 + xpitch, 0),
                    point.create( _P.fingers * xpitch / 2 - xpitch * enable(_P.fingers % 2 == 0),  0)
                },
                bp.sdwidth,
                true
            ),
            2, bp.separation + bp.sdwidth
        ))
    end
    if bp.connectoutput then
        gate:merge_into(geometry.path(
            generics.metal(1),
            {
                point.create((_P.fingers - 2 * enable(_P.fingers % 2 == 0)) * xpitch / 2,      (bp.separation + bp.sdwidth) / 2),
                point.create(_P.fingers * xpitch / 2 + _P.shiftoutput,  (bp.separation + bp.sdwidth) / 2),
                point.create(_P.fingers * xpitch / 2 + _P.shiftoutput, -(bp.separation + bp.sdwidth) / 2),
                point.create((_P.fingers - 2 * enable(_P.fingers % 2 == 0)) * xpitch / 2,     -(bp.separation + bp.sdwidth) / 2),
            },
            bp.sdwidth,
            true
        ))
    end

    -- anchors
    gate:add_anchor("OTL", point.create(-_P.fingers * xpitch / 2 + xpitch,  bp.separation / 2 + bp.sdwidth / 2))
    gate:add_anchor("OBL", point.create(-_P.fingers * xpitch / 2 + xpitch, -bp.separation / 2 - bp.sdwidth / 2))
    gate:add_anchor("OTR", point.create(_P.fingers * xpitch / 2 - xpitch * enable(_P.fingers % 2 == 0),  bp.separation / 2 + bp.sdwidth / 2))
    gate:add_anchor("OBR", point.create(_P.fingers * xpitch / 2 - xpitch * enable(_P.fingers % 2 == 0), -bp.separation / 2 - bp.sdwidth / 2))

    -- ports
    gate:add_port("I", generics.metal(1), point.create(0, _P.shiftinput))
    gate:add_port("O", generics.metal(1), point.create((_P.fingers - 0) * xpitch / 2 + _P.shiftoutput, 0))
    gate:add_port("VDD", generics.metal(1), point.create(0,  bp.separation / 2 + bp.pwidth + bp.powerspace + bp.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -bp.separation / 2 - bp.nwidth - bp.powerspace - bp.powerwidth / 2))
end
