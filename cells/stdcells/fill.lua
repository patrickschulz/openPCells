function parameters()
    pcell.add_parameters(
        { "fingers", 1 }
    )
    pcell.inherit_parameters("stdcells/base")
end

function layout(gate, _P)
    local xpitch = _P.gatespace + _P.gatelength

    local gatecontactpos = {}
    for i = 1, _P.fingers do
        gatecontactpos[i] = "dummy"
    end

    local contactpos = {}
    for i = 1, _P.fingers + 1 do
        contactpos[i] = "unused"
    end
    local baseparameters = {}
    for name, value in pairs(_P) do
        if pcell.has_parameter("stdcells/harness", name) then
            baseparameters[name] = value
        end
    end
    local harness = pcell.create_layout("stdcells/harness", "mosfets", util.add_options(baseparameters, {
        gatecontactpos = gatecontactpos,
        pcontactpos = contactpos,
        ncontactpos = contactpos,
    }))
    gate:merge_into(harness)
    gate:inherit_alignment_box(harness)
end
