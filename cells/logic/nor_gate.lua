function parameters()
    pcell.reference_cell("logic/base")
    pcell.add_parameter("fingers", 1)
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")
    local base = pcell.create_layout("logic/nand_nor_layout_base", { fingers = _P.fingers, gatetype = "nor" })
    gate:merge_into(base)

    gate:inherit_alignment_box(base)

    -- ports
    gate:add_port("A", generics.metal(1), point.create( (bp.glength + bp.gspace) / 2,  bp.separation / 4))
    gate:add_port("B", generics.metal(1), point.create(-(bp.glength + bp.gspace) / 2, -bp.separation / 4))
    gate:add_port("Z", generics.metal(1), point.create(_P.fingers * (bp.glength + bp.gspace) / 2, 0))
    gate:add_port("VDD", generics.metal(1), point.create(0,  bp.separation / 2 + bp.pwidth + bp.powerspace + bp.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -bp.separation / 2 - bp.nwidth - bp.powerspace - bp.powerwidth / 2))
end
