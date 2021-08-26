function parameters()
    pcell.reference_cell("basic/mosfet")
    pcell.reference_cell("logic/base")
    pcell.add_parameters(
        {"glengths", { 40, 40, 40, 40, 40 }, { argtype = "strtable" } },
        {"gspaces", { 90, 90, 90, 90, 90 }, { argtype = "strtable" } }
    )
end

function layout(gate, _P)
    local tp = pcell.get_parameters("basic/mosfet")
    local bp = pcell.get_parameters("logic/base")
    pcell.push_overwrites("logic/base", { leftdummies = 0, rightdummies = 0 })
    local harness = pcell.create_layout("logic/harness", { 
        fingers = #_P.glengths,
        drawtransistors = false,
        drawgatecontacts = false,
    })
    pcell.pop_overwrites("logic/base")
    gate:merge_into_shallow(harness)
    gate:inherit_alignment_box(harness)

    local height = bp.pwidth + bp.nwidth + bp.numinnerroutes * bp.gstwidth + (bp.numinnerroutes + 1) * bp.gstspace + 2 * bp.powerspace + bp.powerwidth + 2 * math.max(tp.cutheight / 2 + bp.gateext, bp.dummycontheight / 2)
    local numgates = #_P.glengths
    local startx = gate:get_anchor("right"):getx()
    for i = 1, numgates do
        local gl = _P.glengths[i]
        local gs = _P.gspaces[i]
        gate:merge_into_shallow(geometry.rectangle(generics.other("gate"), gl, height)
            :translate(startx - (bp.glength + bp.gspace) / 2 + (gl + gs) * -(i - 1), 0))
    end
end
