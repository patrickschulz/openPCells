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
    gate:merge_into_shallow(harness)
    gate:inherit_alignment_box(harness)

    -- gate straps
    if _P.fingers > 1 then
        gate:merge_into_shallow(geometry.path(
            generics.metal(1), { harness:get_anchor("G1upper"), harness:get_anchor(string.format("G%dupper", _P.fingers)) },
            bp.gstwidth
        ))
        gate:merge_into_shallow(geometry.path(
            generics.metal(1), { harness:get_anchor("G1lower"), harness:get_anchor(string.format("G%dlower", _P.fingers)) },
            bp.gstwidth
        ))
    end

    -- signal transistors source connections
    local n = _P.fingers + (_P.fingers % 2 == 0 and 1 or 0)
    gate:merge_into_shallow(geometry.path(generics.metal(1), geometry.path_points_xy(
        harness:get_anchor(string.format("pSDo%d", n)):translate(0, -bp.sdwidth / 2), {
            point.combine_12(harness:get_anchor(string.format("pSDo%d", n)), harness:get_anchor(string.format("pSDi%d", n + 1))):translate(0, bp.sdwidth / 2),
            harness:get_anchor("G1upper"):translate(-xpitch / 2 - _P.shiftinput, 0),
            0, -- toggle xy
            point.combine_12(harness:get_anchor(string.format("nSDo%d", n)), harness:get_anchor(string.format("nSDi%d", n + 1))):translate(0, -bp.sdwidth / 2),
            harness:get_anchor(string.format("nSDo%d", n)):translate(0,  bp.sdwidth / 2),
        }), bp.sdwidth))

    -- signal transistors drain connections
    if bp.connectoutput then
        gate:merge_into_shallow(geometry.path(generics.metal(1), geometry.path_points_xy(
            harness:get_anchor("pSDi2"):translate(0, bp.sdwidth / 2), {
                harness:get_anchor(string.format("G%dlower", _P.fingers)):translate(xpitch / 2 + _P.shiftoutput, 0),
                0, -- toggle xy
                harness:get_anchor("nSDi2"):translate(0, -bp.sdwidth / 2),
        }), bp.sdwidth))
    end

    -- ports
    gate:add_port("I", generics.metal(1), point.create(-_P.fingers * xpitch / 2 - _P.shiftinput, 0))
    gate:add_port("O", generics.metal(1), point.create(_P.fingers * xpitch / 2 + _P.shiftoutput, 0))
    gate:add_port("EP", generics.metal(1), harness:get_anchor("G1upper"))
    gate:add_port("EN", generics.metal(1), harness:get_anchor("G1lower"))
    gate:add_port("VDD", generics.metal(1), harness:get_anchor("top"))
    gate:add_port("VSS", generics.metal(1), harness:get_anchor("bottom"))
end
