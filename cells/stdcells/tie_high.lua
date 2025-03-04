function parameters()
    pcell.add_parameters(
        { "fingers", 2, posvals = even() }
    )
    pcell.inherit_parameters("stdcells/base")
end

function layout(cell, _P)
    local baseparameters = {}
    for name, value in pairs(_P) do
        if pcell.has_parameter("stdcells/tie_highlow", name) then
            baseparameters[name] = value
        end
    end
    local base = pcell.create_layout("stdcells/tie_highlow", "tie_high", util.add_options(baseparameters, {
        high = true,
        fingers = _P.fingers
    }))
    cell:exchange(base)
end
