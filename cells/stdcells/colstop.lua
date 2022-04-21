function parameters()
    pcell.reference_cell("stdcells/base")
    pcell.reference_cell("stdcells/harness")
    pcell.add_parameter("fingers", 4)
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")
    pcell.push_overwrites("stdcells/harness", { leftdummies = 0, rightdummies = 0 })
    local gatecontactpos = {}
    for i = 1, _P.fingers do
        gatecontactpos[i] = "unused"
    end
    local harness = pcell.create_layout("stdcells/harness", { 
        gatecontactpos = gatecontactpos,
        drawactive = false,
        drawgatecontacts = false,
        drawtopgcut = false,
        drawbotgcut = false
    })
    pcell.pop_overwrites("stdcells/harness")
    gate:merge_into_shallow(harness)
    gate:inherit_alignment_box(harness)
end
