function parameters()
    pcell.inherit_all_parameters("logic/_base")
    pcell.add_parameters(
        { "norfingers", 1 },
        { "notfingers", 1 }
    )
end

function layout(gate, _P)
    local xpitch = _P.glength + _P.gspace
    local _P1 = pcell.clone_matching_parameters("logic/nor_gate", _P)
    _P1.fingers = _P.norfingers
    _P1.rightdummies = 0
    local _P2 = pcell.clone_matching_parameters("logic/not_gate", _P)
    _P2.fingers = _P.notfingers
    _P2.leftdummies = 0
    local nor = pcell.create_layout("logic/nor_gate", _P1):move_anchor("right")
    local inv = pcell.create_layout("logic/not_gate", _P2):move_anchor("left")
    gate:merge_into(nor)
    gate:merge_into(inv)

    -- draw connection
    gate:merge_into(geometry.path(generics.metal(1), {
        point.create(-_P.sdwidth / 2, 0),
        point.create(_P.glength + _P.gspace / 2, 0),
    }, _P.sdwidth))

    -- ports
    gate:add_port("A", generics.metal(1), nor:get_anchor("A"))
    gate:add_port("B", generics.metal(1), nor:get_anchor("B"))
    gate:add_port("Z", generics.metal(1), inv:get_anchor("O"))
    gate:add_port("VDD", generics.metal(1), point.create(0,  _P.separation / 2 + _P.pwidth + _P.powerspace + _P.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -_P.separation / 2 - _P.nwidth - _P.powerspace - _P.powerwidth / 2))
end
