function parameters()
    pcell.reference_cell("stdcells/base")
    pcell.add_parameter("fingers", 1)
    pcell.add_parameter("pwidth", 2 * tech.get_dimension("Minimum Gate Width"))
    pcell.add_parameter("nwidth", 2 * tech.get_dimension("Minimum Gate Width"))
    pcell.add_parameter("shiftinput", 0)
    pcell.add_parameter("inputpos", "center", { posvals = set("center", "lower", "upper") })
    pcell.add_parameter("shiftoutput", 0)
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
    local harness = pcell.create_layout("stdcells/harness", { 
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
        rightdummies = _P.fingers % 2,
        shiftgatecontacts = _P.shiftinput,
        gatecontactpos = gatecontactpos,
        pcontactpos = contactpos,
        ncontactpos = contactpos,
    })
    gate:merge_into_shallow(harness)
    gate:inherit_alignment_box(harness)

    -- gate strap
    if _P.fingers > 1 then
        geometry.rectangle(
            gate, generics.metal(1),
            _P.fingers * bp.glength + (_P.fingers - 1) * bp.gspace, bp.routingwidth,
            0, _P.shiftinput
        )
    end

    -- signal transistors drain connections
    local n = _P.fingers + (_P.fingers % 2 == 0 and 0 or 1)
    if _P.fingers > 2 then
        geometry.path(gate, generics.metal(1), {
            harness:get_anchor("pSDi2"):translate(0, bp.sdwidth / 2),
            harness:get_anchor(string.format("pSDi%d", n)):translate(0, bp.sdwidth / 2)
        }, bp.sdwidth)
        geometry.path(gate, generics.metal(1), {
            harness:get_anchor("nSDi2"):translate(0, -bp.sdwidth / 2),
            harness:get_anchor(string.format("nSDi%d", n)):translate(0, -bp.sdwidth / 2)
        }, bp.sdwidth)
    end
    if bp.connectoutput then
        geometry.path(gate, generics.metal(1),
            geometry.path_points_xy(harness:get_anchor(string.format("pSDi%d", n)):translate(0, bp.sdwidth / 2),
            {
                harness:get_anchor(string.format("Gcc%d", _P.fingers)):translate(xpitch + _P.shiftoutput, 0),
                0, -- toggle xy
                harness:get_anchor(string.format("nSDi%d", n)):translate(0, -bp.sdwidth / 2),
            }),
            bp.sdwidth,
            true
        )
    end

    -- anchors (Out Top/Bottom Left/Right center/inner/outer)
    --          ^      ^           ^               ^
    --    e.g.  O      T           L               c    -> OTLc
    gate:add_anchor("OTLc", harness:get_anchor(string.format("pSDc%d", 1)))
    gate:add_anchor("OBLc", harness:get_anchor(string.format("nSDc%d", 1)))
    gate:add_anchor("OTRc", harness:get_anchor(string.format("pSDc%d", _P.fingers + 1)))
    gate:add_anchor("OBRc", harness:get_anchor(string.format("nSDc%d", _P.fingers + 1)))
    gate:add_anchor("OTLi", harness:get_anchor(string.format("pSDi%d", 1)))
    gate:add_anchor("OBLi", harness:get_anchor(string.format("nSDi%d", 1)))
    gate:add_anchor("OTRi", harness:get_anchor(string.format("pSDi%d", _P.fingers + 1)))
    gate:add_anchor("OBRi", harness:get_anchor(string.format("nSDi%d", _P.fingers + 1)))
    gate:add_anchor("OTLo", harness:get_anchor(string.format("pSDo%d", 1)))
    gate:add_anchor("OBLo", harness:get_anchor(string.format("nSDo%d", 1)))
    gate:add_anchor("OTRo", harness:get_anchor(string.format("pSDo%d", _P.fingers + 1)))
    gate:add_anchor("OBRo", harness:get_anchor(string.format("nSDo%d", _P.fingers + 1)))

    -- ports
    gate:add_port("I", generics.metalport(1), harness:get_anchor("Gcc1"))
    gate:add_port("O", generics.metalport(1), point.create((_P.fingers + 1) * xpitch / 2 + _P.shiftoutput, 0))
    gate:add_port("VDD", generics.metalport(1), harness:get_anchor("top"))
    gate:add_port("VSS", generics.metalport(1), harness:get_anchor("bottom"))
end
