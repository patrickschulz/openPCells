function config()
    pcell.reference_cell("basic/mosfet")
    pcell.reference_cell("stdcells/base")
    pcell.set_property("hidden", true)
end

function parameters()

end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")
    local xpitch = bp.gspace + bp.glength

    local harness = pcell.create_layout("stdcells/harness", {
        gatecontactpos = {}, 
        drawdummyactivecontacts = false,
        leftdummies = 1,
        rightdummies = 0
    })
    gate:merge_into_shallow(harness)

    gate:inherit_alignment_box(harness)

    gate:add_anchor("VDD", harness:get_anchor("top"))
    gate:add_anchor("VSS", harness:get_anchor("bottom"))

    -- center gate
    gate:translate(xpitch / 2, 0)
end
