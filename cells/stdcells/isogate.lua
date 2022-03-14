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

    pcell.push_overwrites("stdcells/base", { leftdummies = 1, rightdummies = 0 })
    local harness = pcell.create_layout("stdcells/harness", { gatecontactpos = {}, drawdummyactivecontacts = false })
    gate:merge_into_shallow(harness)
    pcell.pop_overwrites("stdcells/base")

    gate:inherit_alignment_box(harness)

    gate:add_anchor("VDD", harness:get_anchor("top"))
    gate:add_anchor("VSS", harness:get_anchor("bottom"))

    -- center gate
    gate:translate(xpitch / 2, 0)
end
