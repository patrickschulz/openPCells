function parameters()
    pcell.reference_cell("basic/mosfet")
    pcell.reference_cell("stdcells/base")
    pcell.add_parameters(
        { "fingers", 1 },
        { "splitenables", false },
        { "inputpos", "center" },
        { "enableppos", "upper" },
        { "enablenpos", "lower" },
        { "swapinputs", false },
        { "swapoutputs", false },
        { "shiftoutput", 0 },
        { "connectoutput", true }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")
    local xpitch = bp.gspace + bp.glength
    local xincr = bp.compact and 0 or 1

    local fingers = (_P.splitenables and 3 or 2) * _P.fingers

    local gatecontactpos = { "dummy" }
    if _P.splitenables then
        for i = 1, _P.fingers do
            if i % 2 == 1 then
                gatecontactpos[1 + (i - 1) * 3 + 1] = _P.enablenpos
                gatecontactpos[1 + (i - 1) * 3 + 2] = _P.enableppos
                gatecontactpos[1 + (i - 1) * 3 + 3] = _P.inputpos
            else
                gatecontactpos[1 + (i - 1) * 3 + 1] = _P.inputpos
                gatecontactpos[1 + (i - 1) * 3 + 2] = _P.enableppos
                gatecontactpos[1 + (i - 1) * 3 + 3] = _P.enablenpos
            end
        end
    else
        for i = 1, _P.fingers do
            if i % 2 == (_P.swapinputs and 0 or 1) then
                gatecontactpos[1 + (i - 1) * 2 + 1] = _P.inputpos
                gatecontactpos[1 + (i - 1) * 2 + 2] = "split"
            else
                gatecontactpos[1 + (i - 1) * 2 + 1] = "split"
                gatecontactpos[1 + (i - 1) * 2 + 2] = _P.inputpos
            end
        end
    end

    local pcontactpos = { "power" }
    local ncontactpos = { "power" }
    local ci1 = _P.swapoutputs and 3 or 1
    local ci2 = _P.swapoutputs and 1 or 3
    if _P.splitenables then
        for i = 1, _P.fingers do
            ncontactpos[1 + (i - 1) * 3 + 2] = "outer"
            ncontactpos[1 + (i - 1) * 3 + 3] = "outer"
            if _P.swapoutputs then
                if i % 2 == 1 then
                    pcontactpos[1 + (i - 1) * 3 + 4] = "inner"
                    ncontactpos[1 + (i - 1) * 3 + 4] = "inner"
                    pcontactpos[1 + (i - 1) * 3 + 2] = "power"
                    ncontactpos[1 + (i - 1) * 3 + 1] = "power"
                else
                    pcontactpos[1 + (i - 1) * 3 + 3] = "power"
                end
            else
                if i % 2 == 1 then
                    pcontactpos[1 + (i - 1) * 3 + 1] = "inner"
                    ncontactpos[1 + (i - 1) * 3 + 1] = "inner"
                    pcontactpos[1 + (i - 1) * 3 + 3] = "power"
                    ncontactpos[1 + (i - 1) * 3 + 4] = "power"
                else
                    pcontactpos[1 + (i - 1) * 3 + 2] = "power"
                end
            end
        end
    else
        for i = 1, _P.fingers do
            if i % 2 == 1 then
                pcontactpos[1 + (i - 1) * 2 + ci1] = "inner"
                ncontactpos[1 + (i - 1) * 2 + ci1] = "inner"
                pcontactpos[1 + (i - 1) * 2 + ci2] = "power"
                ncontactpos[1 + (i - 1) * 2 + ci2] = "power"
            else
                pcontactpos[1 + (i - 1) * 2 + ci1] = "power"
                ncontactpos[1 + (i - 1) * 2 + ci1] = "power"
                pcontactpos[1 + (i - 1) * 2 + ci2] = "inner"
                ncontactpos[1 + (i - 1) * 2 + ci2] = "inner"
            end
        end
    end
    local harness = pcell.create_layout("stdcells/harness", "mosfets", {
        gatecontactpos = gatecontactpos,
        pcontactpos = pcontactpos,
        ncontactpos = ncontactpos,
    })
    gate:merge_into(harness)
    gate:inherit_alignment_box(harness)

    -- gate straps
    if _P.fingers > 1 then
        if _P.splitenables then
                geometry.path(
                    gate, generics.metal(1),
                    {
                        harness:get_anchor("G2cc"),
                        harness:get_anchor(string.format("G%dcc",
                            _P.fingers % 2 == 0 and
                                1 + (3 * _P.fingers) or
                                1 + (3 * _P.fingers - 2)
                        )),
                    },
                    bp.sdwidth
                )
                geometry.path(
                    gate, generics.metal(1),
                    {
                        harness:get_anchor("G3cc"),
                        harness:get_anchor(string.format("G%dcc",
                            3 * _P.fingers
                        )),
                    },
                    bp.sdwidth
                )
                geometry.path(
                    gate, generics.metal(1),
                    {
                        harness:get_anchor("G4cc"),
                        harness:get_anchor(string.format("G%dcc",
                            _P.fingers % 2 == 0 and
                                1 + (3 * _P.fingers - 3) or
                                1 + (3 * _P.fingers)
                        )),
                    },
                    bp.sdwidth
                )
        else
            if _P.swapinputs then
                geometry.path(
                    gate, generics.metal(1),
                    {
                        harness:get_anchor("G3cc"),
                        harness:get_anchor(string.format("G%dcc",
                            _P.fingers % 2 == 0 and
                                1 + (2 * _P.fingers - 1) or
                                1 + (2 * _P.fingers)
                        )),
                    },
                    bp.sdwidth
                )
                geometry.path(
                    gate, generics.metal(1),
                    {
                        harness:get_anchor("Gupper2cc"),
                        harness:get_anchor(string.format("Gupper%dcc",
                            _P.fingers % 2 == 0 and
                                1 + (2 * _P.fingers) or
                                1 + (2 * _P.fingers - 1)
                        )),
                    },
                    bp.sdwidth
                )
                geometry.path(
                    gate, generics.metal(1),
                    {
                        harness:get_anchor("Glower2cc"),
                        harness:get_anchor(string.format("Glower%dcc",
                            _P.fingers % 2 == 0 and
                                1 + (2 * _P.fingers) or
                                1 + (2 * _P.fingers - 1)
                        )),
                    },
                    bp.sdwidth
                )
            else
                geometry.path(
                    gate, generics.metal(1),
                    {
                        harness:get_anchor("G2cc"),
                        harness:get_anchor(string.format("G%dcc",
                            _P.fingers % 2 == 0 and
                                1 + (2 * _P.fingers) or
                                1 + (2 * _P.fingers - 1)
                        )),
                    },
                    bp.sdwidth
                )
                geometry.path(
                    gate, generics.metal(1),
                    {
                        harness:get_anchor("Gupper3cc"),
                        harness:get_anchor(string.format("Gupper%dcc",
                            _P.fingers % 2 == 0 and
                                1 + (2 * _P.fingers - 1) or
                                1 + (2 * _P.fingers)
                        )),
                    },
                    bp.sdwidth
                )
                geometry.path(
                    gate, generics.metal(1),
                    {
                        harness:get_anchor("Glower3cc"),
                        harness:get_anchor(string.format("Glower%dcc",
                            _P.fingers % 2 == 0 and
                                1 + (2 * _P.fingers - 1) or
                                1 + (2 * _P.fingers)
                        )),
                    },
                    bp.sdwidth
                )
            end
        end
    end

    -- drain connection
    if _P.connectoutput then
        local dend = _P.splitenables and (_P.swapoutputs and 5 or 2) or (_P.swapoutputs and 4 or 2)
        geometry.path(gate, generics.metal(1), geometry.path_points_xy(
            harness:get_anchor(string.format("pSD%dbr", dend)):translate(0,  bp.sdwidth / 2), {
                harness:get_anchor(string.format("G%dcc", fingers + 1)):translate(_P.shiftoutput + xpitch / 2, 0),
                0, -- toggle xy
                harness:get_anchor(string.format("nSD%dtr", dend)):translate(0, -bp.sdwidth / 2),
        }), bp.sdwidth)
    end

    -- short transistors
    if _P.splitenables then
        for i = 1, _P.fingers do
            geometry.path(gate, generics.metal(1), {
                harness:get_anchor(string.format("nSD%dcc", 1 + (i - 1) * 3 + 2)),
                harness:get_anchor(string.format("nSD%dcc", 1 + (i - 1) * 3 + 3)),
            }, bp.sdwidth)
        end
    end

    -- ports
    if _P.splitenables then
        gate:add_port("I", generics.metalport(1), harness:get_anchor("G4cc"))
        gate:add_port("EP", generics.metalport(1), harness:get_anchor("G3cc"))
        gate:add_port("EN", generics.metalport(1), harness:get_anchor("G2cc"))
    else
        if _P.swapinputs then
            gate:add_port("I", generics.metalport(1), harness:get_anchor("G3cc"))
            gate:add_port("EP", generics.metalport(1), harness:get_anchor("Gupper2cc"))
            gate:add_port("EN", generics.metalport(1), harness:get_anchor("Glower2cc"))
        else
            gate:add_port("I", generics.metalport(1), harness:get_anchor("G2cc"))
            gate:add_port("EP", generics.metalport(1), harness:get_anchor("Gupper3cc"))
            gate:add_port("EN", generics.metalport(1), harness:get_anchor("Glower3cc"))
        end
    end
    gate:add_port("O", generics.metalport(1), point.create(_P.fingers * xpitch + _P.shiftoutput, 0))
    gate:add_port("VDD", generics.metalport(1), harness:get_anchor("top"))
    gate:add_port("VSS", generics.metalport(1),  harness:get_anchor("bottom"))
end
