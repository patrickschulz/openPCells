function parameters()
    pcell.reference_cell("stdcells/base")
    pcell.add_parameter("fingers", 1)
    pcell.add_parameter("pwidth", 2 * tech.get_dimension("Minimum Gate Width"))
    pcell.add_parameter("nwidth", 2 * tech.get_dimension("Minimum Gate Width"))
    pcell.add_parameter("shiftinput", 0)
    pcell.add_parameter("inputpos", "center", { posvals = set("center", "lower", "upper") })
    pcell.add_parameter("shiftoutput", 0)
    pcell.add_parameter("swapoddcorrectiongate", false)
    pcell.add_parameter("connectoutput", true)
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")
    local xpitch = bp.gspace + bp.glength

    local gatecontactpos = {}
    for i = 1, _P.fingers do gatecontactpos[i] = _P.inputpos end

    local contactpos = {}
    for i = 1, _P.fingers + 1 do
        if i % 2 == 0 then
            contactpos[i] = "inner"
        else
            contactpos[i] = "power"
        end
    end
    if _P.fingers % 2 == 1 then
        if _P.swapoddcorrectiongate then
            table.insert(gatecontactpos, 1, "dummy")
        else
            table.insert(gatecontactpos, "dummy")
        end
        table.insert(contactpos, "power")
    end
    local harness = pcell.create_layout("stdcells/harness", { 
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
        shiftgatecontacts = _P.shiftinput,
        gatecontactpos = gatecontactpos,
        pcontactpos = contactpos,
        ncontactpos = contactpos,
    })
    gate:merge_into_shallow(harness)
    gate:inherit_alignment_box(harness)

    -- gate strap
    if _P.fingers > 1 then
        geometry.rectanglebltr(
            gate, generics.metal(1),
            harness:get_anchor("G1bl"),
            harness:get_anchor(string.format("G%dtr", _P.fingers))
        )
    end

    -- signal transistors drain connections
    if _P.connectoutput then
        geometry.path(gate, generics.metal(1),
            geometry.path_points_xy(harness:get_anchor(string.format("pSD%dbr", 2)):translate(0, bp.sdwidth / 2),
            {
                harness:get_anchor(string.format("G%dcc", _P.fingers)):translate(xpitch + _P.shiftoutput, 0),
                0, -- toggle xy
                harness:get_anchor(string.format("nSD%dtr", 2)):translate(0, -bp.sdwidth / 2),
            }),
            bp.sdwidth,
            true
        )
    end

    -- anchors (Out Top/Bottom Left/Right center/inner/outer)
    --          ^      ^           ^               ^
    --    e.g.  O      T           L               c    -> OTLc
    gate:add_anchor("OTLc", harness:get_anchor(string.format("pSD%dcc", 1)))
    gate:add_anchor("OBLc", harness:get_anchor(string.format("nSD%dcc", 1)))
    gate:add_anchor("OTRc", harness:get_anchor(string.format("pSD%dcc", _P.fingers + 1)))
    gate:add_anchor("OBRc", harness:get_anchor(string.format("nSD%dcc", _P.fingers + 1)))
    gate:add_anchor("OTLi", harness:get_anchor(string.format("pSD%dbc", 1)))
    gate:add_anchor("OBLi", harness:get_anchor(string.format("nSD%dtc", 1)))
    gate:add_anchor("OTRi", harness:get_anchor(string.format("pSD%dbc", _P.fingers + 1)))
    gate:add_anchor("OBRi", harness:get_anchor(string.format("nSD%dtc", _P.fingers + 1)))
    gate:add_anchor("OTLo", harness:get_anchor(string.format("pSD%dtc", 1)))
    gate:add_anchor("OBLo", harness:get_anchor(string.format("nSD%dbc", 1)))
    gate:add_anchor("OTRo", harness:get_anchor(string.format("pSD%dtc", _P.fingers + 1)))
    gate:add_anchor("OBRo", harness:get_anchor(string.format("nSD%dbc", _P.fingers + 1)))

    -- ports
    if _P.swapoddcorrectiongate then
        gate:add_port("I", generics.metalport(1), harness:get_anchor("G2cc"))
    else
        gate:add_port("I", generics.metalport(1), harness:get_anchor("G1cc"))
    end
    --if _P.connectoutput then
        gate:add_port("O", generics.metalport(1), harness:get_anchor(string.format("G%dcc", _P.fingers)):translate(xpitch + _P.shiftoutput, 0))
    --end
    gate:add_port("VDD", generics.metalport(1), harness:get_anchor("top"))
    gate:add_port("VSS", generics.metalport(1), harness:get_anchor("bottom"))
end
