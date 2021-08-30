function parameters()
    pcell.reference_cell("stdcells/base")
    pcell.add_parameter("fingers", 4)
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")
    pcell.push_overwrites("stdcells/base", { leftdummies = 0, rightdummies = 0 })
    local harness = pcell.create_layout("stdcells/harness", { 
        fingers = _P.fingers,
        drawactive = false,
        drawgatecontacts = false,
        drawtopgcut = false,
        drawbotgcut = false
    })
    pcell.pop_overwrites("stdcells/base")
    gate:merge_into_shallow(harness)
    gate:inherit_alignment_box(harness)
end
