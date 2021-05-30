function parameters()
    pcell.reference_cell("logic/base")
    pcell.add_parameter("fingers", 1)
end

function layout(gate, _P)
    local base = pcell.create_layout("logic/nand_nor_layout_base", { fingers = _P.fingers, gatetype = "nor" })
    gate:exchange(base)
end
