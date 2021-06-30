function config()
    pcell.reference_cell("basic/mosfet")
    pcell.reference_cell("logic/base")
    pcell.set_property("hidden", true)
end

function parameters()

end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")
    local xpitch = bp.gspace + bp.glength

    pcell.push_overwrites("logic/base", { leftdummies = 1, rightdummies = 0 })
    local harness = pcell.create_layout("logic/harness", { fingers = 0, drawdummyactivecontacts = false })
    gate:merge_into_shallow(harness)
    pcell.pop_overwrites("logic/base")

    gate:inherit_alignment_box(harness)

    gate:add_anchor("VDD", harness:get_anchor("top"))
    gate:add_anchor("VSS", harness:get_anchor("bottom"))

    -- center gate
    gate:translate(xpitch / 2, 0)
end
