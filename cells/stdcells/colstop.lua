function parameters()
    pcell.add_parameter("fingers", 1)
    pcell.add_parameter("leftnotright", true)
    pcell.inherit_parameters("stdcells/base")
end

function layout(gate, _P)
    local gatecontactpos = { "dummy" }
    local sdcontacts
    if _P.leftnotright then
        sdcontacts = { "power", "unused" }
    else
        sdcontacts = { "unused", "power" }
    end
    local leftpolylines = {}
    local rightpolylines = {}
    for i = 1, _P.fingers do
        local entry = { length = _P.gatelength, space = _P.gatespace }
        if _P.leftnotright then
            leftpolylines[i] = entry
        else
            rightpolylines[i] = entry
        end
    end
    local baseparameters = {}
    for name, value in pairs(_P) do
        if pcell.has_parameter("stdcells/harness", name) then
            baseparameters[name] = value
        end
    end
    local harness = pcell.create_layout("stdcells/harness", "harness", util.add_options(baseparameters, {
        gatecontactpos = gatecontactpos,
        pcontactpos = sdcontacts,
        ncontactpos = sdcontacts,
        drawactive = false,
        drawgatecontacts = false,
        drawtopgcut = false,
        drawbotgcut = false,
        drawleftstopgate = _P.leftnotright,
        leftpolylines = leftpolylines,
        drawrightstopgate = not _P.leftnotright,
        rightpolylines = rightpolylines,
    }))
    gate:merge_into(harness)
    gate:inherit_alignment_box(harness)
end
