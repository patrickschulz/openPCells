function parameters()
    pcell.inherit_all_parameters("logic/_base")
end

function layout(gate, _P)
    local xpitch = _P.gspace + _P.glength
    _P.gatetype = "nor"
    local base = pcell.create_layout("logic/_nand_nor_layout_base", _P)
    gate:merge_into(base)

    -- anchors
    gate:add_anchor("left", point.create(-(2 * _P.fingers + _P.leftdummies) * xpitch / 2, 0))
    gate:add_anchor("right", point.create((2 * _P.fingers + _P.rightdummies) * xpitch / 2, 0))

    -- ports
    gate:add_port("A", generics.metal(1), point.create(xpitch / 2, _P.separation / 4))
    gate:add_port("B", generics.metal(1), point.create(-xpitch / 2, -_P.separation / 4))
    gate:add_port("Z", generics.metal(1), point.create(_P.fingers * xpitch, 0))
    gate:add_port("VDD", generics.metal(1), point.create(0,  _P.separation / 2 + _P.pwidth + _P.powerspace + _P.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -_P.separation / 2 - _P.nwidth - _P.powerspace - _P.powerwidth / 2))
end
