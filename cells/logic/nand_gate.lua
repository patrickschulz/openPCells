function parameters()
    pcell.inherit_all_parameters("logic/_base")
    pcell.add_parameter("fingers", 1)
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/_base")
    local base = pcell.create_layout("logic/_nand_nor_layout_base", { fingers = _P.fingers, gatetype = "nand" })
    gate:merge_into(base)

    -- anchors
    gate:add_anchor("left", point.create(-(2 * _P.fingers + bp.leftdummies) * (bp.glength + bp.gspace) / 2, 0))
    gate:add_anchor("right", point.create((2 * _P.fingers + bp.rightdummies) * (bp.glength + bp.gspace) / 2, 0))

    -- ports
    gate:add_port("A", generics.metal(1), point.create( (bp.glength + bp.gspace) / 2,  bp.separation / 4))
    gate:add_port("B", generics.metal(1), point.create(-(bp.glength + bp.gspace) / 2, -bp.separation / 4))
    gate:add_port("Z", generics.metal(1), point.create(_P.fingers * (bp.glength + bp.gspace), 0))
    gate:add_port("VDD", generics.metal(1), point.create(0,  bp.separation / 2 + bp.pwidth + bp.powerspace + bp.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -bp.separation / 2 - bp.nwidth - bp.powerspace - bp.powerwidth / 2))
end
