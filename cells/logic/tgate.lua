function parameters()
    pcell.reference_cell("logic/base")
    pcell.add_parameter("fingers", 1)
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")
    local xpitch = bp.gspace + bp.glength

    local gatecontactpos = {}
    for i = 1, _P.fingers do gatecontactpos[i] = "split" end

    local contactpos = {}
    for i = 1, _P.fingers + 1 do
        if i % 2 == 0 then
            contactpos[i] = "inner"
        else
            contactpos[i] = "outer"
        end
    end
    local harness = pcell.create_layout("logic/harness", { 
        fingers = _P.fingers,
        gatecontactpos = gatecontactpos,
        pcontactpos = contactpos,
        ncontactpos = contactpos,
    })
    gate:merge_into_update_alignmentbox(harness)

    -- gate straps
    if _P.fingers > 1 then
        gate:merge_into(geometry.path(
            generics.metal(1), { harness:get_anchor("G1upper"), harness:get_anchor(string.format("G%dupper", _P.fingers)) },
            bp.gstwidth
        ))
        gate:merge_into(geometry.path(
            generics.metal(1), { harness:get_anchor("G1lower"), harness:get_anchor(string.format("G%dlower", _P.fingers)) },
            bp.gstwidth
        ))
    end

    -- signal transistors source connections
    if _P.fingers > 1 then
        gate:merge_into(geometry.path(
            generics.metal(1),
            {
                point.create( _P.fingers * xpitch / 2,  (bp.separation + 2 * bp.pwidth - bp.sdwidth) / 2),
                point.create(-_P.fingers * xpitch / 2,  (bp.separation + 2 * bp.pwidth - bp.sdwidth) / 2),
                point.create(-_P.fingers * xpitch / 2, -(bp.separation + 2 * bp.nwidth - bp.sdwidth) / 2),
                point.create( _P.fingers * xpitch / 2, -(bp.separation + 2 * bp.nwidth - bp.sdwidth) / 2),
            },
            bp.sdwidth,
            true
        ))
    else
        gate:merge_into(geometry.path(
            generics.metal(1),
            {
                point.create(-_P.fingers * xpitch / 2,  (bp.separation + 2 * bp.pwidth - bp.sdwidth) / 2),
                point.create(-_P.fingers * xpitch / 2, -(bp.separation + 2 * bp.nwidth - bp.sdwidth) / 2),
            },
            bp.sdwidth,
            true
        ))
    end

    -- signal transistors drain connections
    if bp.connectoutput then
        gate:merge_into(geometry.path(
            generics.metal(1),
            {
                point.create(-_P.fingers * xpitch / 2 + xpitch,  (bp.separation + bp.sdwidth) / 2),
                point.create( _P.fingers * xpitch / 2,           (bp.separation + bp.sdwidth) / 2),
                point.create( _P.fingers * xpitch / 2,          -(bp.separation + bp.sdwidth) / 2),
                point.create(-_P.fingers * xpitch / 2 + xpitch, -(bp.separation + bp.sdwidth) / 2),
            },
            bp.sdwidth,
            true
        ))
    end

    -- ports
    gate:add_port("I", generics.metal(1), point.create(-_P.fingers * xpitch / 2, 0))
    gate:add_port("O", generics.metal(1), point.create(_P.fingers * xpitch / 2, 0))
    gate:add_port("EP", generics.metal(1), point.create(0, bp.separation / 4 + bp.sdwidth / 4))
    gate:add_port("EN", generics.metal(1), point.create(0, -bp.separation / 4 - bp.sdwidth / 4))
    gate:add_port("VDD", generics.metal(1), point.create(0,  bp.separation / 2 + bp.pwidth + bp.powerspace + bp.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -bp.separation / 2 - bp.nwidth - bp.powerspace - bp.powerwidth / 2))
end
