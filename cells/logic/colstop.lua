function parameters()
    pcell.reference_cell("logic/base")
    pcell.add_parameter("fingers", 4)
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")
    pcell.push_overwrites("logic/base", { leftdummies = 0, rightdummies = 0 })
    local harness = pcell.create_layout("logic/harness", { 
        fingers = _P.fingers,
        drawactive = false,
        drawgatecontacts = false,
        drawtopgcut = false
    })
    pcell.pop_overwrites("logic/base")
    gate:merge_into_shallow(harness)
    gate:inherit_alignment_box(harness)
end
