function parameters()
    pcell.add_parameters(
        { "numinv(Number of Inverters)", 4 }
    )
end

function layout(chain, _P)
    pcell.push_overwrites("logic/_base", { leftdummies = 0, rightdummies = 0 })
    local anchor = point.create(0, 0)
    for i = 1, _P.numinv do
        local inv = pcell.create_layout("logic/not_gate", { fingers = 2 }):move_anchor("left", anchor)
        anchor = inv:get_anchor("right")
        chain:merge_into(inv)
    end
end
