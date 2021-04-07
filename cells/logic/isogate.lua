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
    gate:merge_into_update_alignmentbox(pcell.create_layout("logic/harness", { fingers = 0, drawdummyactivecontacts = false }))
    pcell.pop_overwrites("logic/base")
    gate:translate(xpitch / 2, 0)
end
