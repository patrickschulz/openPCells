function parameters()
    pcell.add_parameters(
        { "numinv(Number of Inverters)", 4 },
        { "fingers(Number of Fingers for each Inverter)", 2 }
    )
end

function layout(chain, _P)
    local inverters = {}
    for i = 1, _P.numinv do
        local inv = pcell.create_layout("stdcells/not_gate", string.format("inv_%d", i), { fingers = _P.fingers })
        table.insert(inverters, inv)
        if i > 1 then
            inv:align_right(inv, inverters[i - 1])
        end
        chain:merge_into(inv)
    end
end
