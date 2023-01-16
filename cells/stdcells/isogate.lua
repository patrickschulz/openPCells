function config()
    pcell.set_property("hidden", true)
end

function parameters()
    pcell.add_parameter("pwidth", 2 * technology.get_dimension("Minimum Gate Width"))
    pcell.add_parameter("nwidth", 2 * technology.get_dimension("Minimum Gate Width"))
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")
    local xpitch = bp.gspace + bp.glength

    local harness = pcell.create_layout("stdcells/harness", "mosfets", {
        gatecontactpos = { "dummy" },
        pcontactpos = { "power", "power" },
        ncontactpos = { "power", "power" },
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
        drawdummyactivecontacts = false,
    })
    gate:merge_into(harness)

    gate:inherit_alignment_box(harness)

    gate:add_anchor("VDD", harness:get_anchor("top"))
    gate:add_anchor("VSS", harness:get_anchor("bottom"))
    gate:add_port("VDD", generics.metalport(1), harness:get_anchor("top"))
    gate:add_port("VSS", generics.metalport(1), harness:get_anchor("bottom"))

    -- center gate
    gate:translate(xpitch / 2, 0)
end
