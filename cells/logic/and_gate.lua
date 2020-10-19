function parameters()
    pcell.inherit_all_parameters("logic/_base")
    pcell.add_parameters(
        { "nandfingers", 1 },
        { "notfingers", 1 }
    )
end

function layout(gate, _P)
    local _P1 = pcell.clone_parameters(_P)
    _P1.fingers = _P.nandfingers
    _P1.notfingers = nil
    _P1.nandfingers = nil
    local _P2 = pcell.clone_parameters(_P)
    _P2.fingers = _P.notfingers
    _P2.notfingers = nil
    _P2.nandfingers = nil
    gate:merge_into(pcell.create_layout("logic/nand_gate", _P1):move_anchor("right"))
    gate:merge_into(pcell.create_layout("logic/not_gate", _P2):move_anchor("left"))
end
