function parameters()
    pcell.reference_cell("logic/base")
    pcell.add_parameters(
        { "fingers", 4 },
        {"glengths", { 40, 40, 40 }, { argtype = "strtable" } },
        {"gspaces", { 90, 90, 90 }, { argtype = "strtable" } }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")
    pcell.push_overwrites("logic/base", { leftdummies = 0, rightdummies = 0 })
    local harness = pcell.create_layout("logic/harness", { 
        fingers = _P.fingers,
        drawtransistors = false,
        drawgatecontacts = false,
    })
    pcell.pop_overwrites("logic/base")
    gate:merge_into_shallow(harness)
    gate:inherit_alignment_box(harness)

    for i, gl in ipairs(_P.glengths) do
        gate:merge_into_shallow(geometry.rectangle(generics.other("gate"), gl, 1000)
            :translate((gl + _P.gspaces[i]) * ((i - 1) - (#_P.glengths - 1) / 2), 0))
    end
end
