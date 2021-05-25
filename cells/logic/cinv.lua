function parameters()
    pcell.reference_cell("basic/mosfet")
    pcell.reference_cell("logic/base")
    pcell.add_parameter("fingers", 1)
    pcell.add_parameter("inputpos", "center")
    pcell.add_parameter("swapinputs", false)
    pcell.add_parameter("swapoutputs", false)
    pcell.add_parameter("shiftoutput", 0)
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")
    local xpitch = bp.gspace + bp.glength
    local xincr = bp.compact and 0 or 1

    local gatecontactpos = { }
    for i = 1, 2 * _P.fingers do
        if not _P.swapinputs then
            if i % 4 > 1 then
                gatecontactpos[i] = "split"
            else
                gatecontactpos[i] = _P.inputpos
            end
        else
            if i % 4 > 1 then
                gatecontactpos[i] = _P.inputpos
            else
                gatecontactpos[i] = "split"
            end
        end
    end

    local contactpos = { }
    local ci1 = _P.swapoutputs and 1 or 3
    local ci2 = _P.swapoutputs and 3 or 1
    for i = 1, 2 * _P.fingers + 1 do
        if (i % 4) == ci1 then
            contactpos[i] = "power"
        end
        if (i % 4) == ci2 then
            contactpos[i] = "inner"
        end
    end
    local harness = pcell.create_layout("logic/harness", { 
        fingers = 2 * _P.fingers, 
        gatecontactpos = gatecontactpos,
        pcontactpos = contactpos,
        ncontactpos = contactpos,
    })
    gate:merge_into_update_alignmentbox(harness)

    -- gate straps
    if _P.fingers > 1 then
        if _P.swapinputs then
            gate:merge_into(geometry.path(
                generics.metal(1),
                {
                    harness:get_anchor("G2"),
                    harness:get_anchor(string.format("G%d", 
                        _P.fingers % 2 == 0 and 
                            (2 * _P.fingers - 1) or
                            (2 * _P.fingers)
                    )),
                },
                bp.sdwidth
            ))
            gate:merge_into(geometry.path(
                generics.metal(1),
                {
                    harness:get_anchor("G1upper"),
                    harness:get_anchor(string.format("G%dupper", 
                        _P.fingers % 2 == 0 and 
                            (2 * _P.fingers) or
                            (2 * _P.fingers - 1)
                    )),
                },
                bp.sdwidth
            ))
            gate:merge_into(geometry.path(
                generics.metal(1),
                {
                    harness:get_anchor("G1lower"),
                    harness:get_anchor(string.format("G%dlower", 
                        _P.fingers % 2 == 0 and 
                            (2 * _P.fingers) or
                            (2 * _P.fingers - 1)
                    )),
                },
                bp.sdwidth
            ))
        else
            gate:merge_into(geometry.path(
                generics.metal(1),
                {
                    harness:get_anchor("G1"),
                    harness:get_anchor(string.format("G%d", 
                        _P.fingers % 2 == 0 and 
                            (2 * _P.fingers) or
                            (2 * _P.fingers - 1)
                    )),
                },
                bp.sdwidth
            ))
            gate:merge_into(geometry.path(
                generics.metal(1),
                {
                    harness:get_anchor("G2upper"),
                    harness:get_anchor(string.format("G%dupper", 
                        _P.fingers % 2 == 0 and 
                            (2 * _P.fingers - 1) or
                            (2 * _P.fingers)
                    )),
                },
                bp.sdwidth
            ))
            gate:merge_into(geometry.path(
                generics.metal(1),
                {
                    harness:get_anchor("G2lower"),
                    harness:get_anchor(string.format("G%dlower", 
                        _P.fingers % 2 == 0 and 
                            (2 * _P.fingers - 1) or
                            (2 * _P.fingers)
                    )),
                },
                bp.sdwidth
            ))
        end
    end

    -- drain connection
    if bp.connectoutput then
        local dend = _P.swapoutputs and 3 or 1
        gate:merge_into(geometry.path(generics.metal(1), geometry.path_points_xy(
            harness:get_anchor(string.format("pSDi%d", dend)):translate(0,  bp.sdwidth / 2), {
                harness:get_anchor(string.format("G%d", 2 * _P.fingers)):translate(_P.shiftoutput + xpitch / 2, 0),
                0, -- toggle xy
                harness:get_anchor(string.format("nSDi%d", dend)):translate(0, -bp.sdwidth / 2),
        }), bp.sdwidth))
    end

    -- ports
    if _P.swapinputs then
        gate:add_port("I", generics.metal(1), harness:get_anchor("G2"))
        gate:add_port("EP", generics.metal(1), harness:get_anchor("G1upper"))
        gate:add_port("EN", generics.metal(1), harness:get_anchor("G1lower"))
    else
        gate:add_port("I", generics.metal(1), harness:get_anchor("G1"))
        gate:add_port("EP", generics.metal(1), harness:get_anchor("G2upper"))
        gate:add_port("EN", generics.metal(1), harness:get_anchor("G2lower"))
    end
    gate:add_port("O", generics.metal(1), point.create(_P.fingers * xpitch + _P.shiftoutput, 0))
    gate:add_port("VDD", generics.metal(1), harness:get_anchor("top"))
    gate:add_port("VSS", generics.metal(1),  harness:get_anchor("bottom"))
end
