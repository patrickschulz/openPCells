function parameters()
    pcell.reference_cell("logic/base")
    pcell.add_parameters(
        { "numinv(Number of Inverters)", 4 },
        { "fingers(Number of Fingers for each Inverter)", 2 }
    )
end

function layout(chain, _P)
    pcell.push_overwrites("logic/base", { leftdummies = 0, rightdummies = 0 })
    local anchor = point.create(0, 0)
    for i = 1, _P.numinv do
        local inv = pcell.create_layout("logic/not_gate", { fingers = _P.fingers }):move_anchor("left", anchor)
        anchor = inv:get_anchor("right")
        chain:merge_into_shallow(inv)
    end
end
