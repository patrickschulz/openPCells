function parameters()
    pcell.inherit_parameters("stdcells/dff", {
        "clockpolarity",
        "enable_Q",
        "enable_QN",
        "enable_set",
        "enable_reset",
    })
end

function layout(gate, _P)
    local baseparameters = {}
    for name, value in pairs(_P) do
        if pcell.has_parameter("stdcells/harness", name) then
            baseparameters[name] = value
        end
    end
    local dff = pcell.create_layout("stdcells/dff", "dffnrq", util.add_options(baseparameters, {
        clockpolarity = "negative",
        enable_Q = true,
        enable_QN = false,
        enable_set = false,
        enable_reset = true,
    }))
    gate:exchange(dff)
end
