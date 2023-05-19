function parameters()
    pcell.add_parameter("fingers", 1)
    pcell.add_parameter("pwidthoffset", 0)
    pcell.add_parameter("nwidthoffset", 0)
    pcell.add_parameter("shiftoutput", 0)
end

function layout(gate, _P)
    local base = pcell.create_layout("stdcells/nand_nor_layout_base", "nor_gate", {
        fingers = _P.fingers,
        gatetype = "nor",
        pwidthoffset = _P.pwidthoffset,
        nwidthoffset = _P.nwidthoffset,
        shiftoutput = _P.shiftoutput
    })
    gate:exchange(base)
end
