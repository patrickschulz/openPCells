function parameters()
    pcell.reference_cell("stdcells/base")
    pcell.add_parameter("fingers", 1)
    pcell.add_parameter("shiftoutput", 0)
end

function layout(gate, _P)
    local base = pcell.create_layout("stdcells/nand_nor_layout_base", { fingers = _P.fingers, gatetype = "nand", shiftoutput = _P.shiftoutput })
    gate:exchange(base)
end
