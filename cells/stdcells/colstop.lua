function parameters()
    pcell.add_parameter("fingers", 1)
    pcell.add_parameter("leftnotright", true)
    pcell.add_parameter("pwidthoffset", 0)
    pcell.add_parameter("nwidthoffset", 0)
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")
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
        local entry = { length = bp.glength, space = bp.gspace }
        if _P.leftnotright then
            leftpolylines[i] = entry
        else
            rightpolylines[i] = entry
        end
    end
    local harness = pcell.create_layout("stdcells/harness", "harness", {
        gatecontactpos = gatecontactpos,
        pcontactpos = sdcontacts,
        ncontactpos = sdcontacts,
        pwidthoffset = _P.pwidthoffset,
        nwidthoffset = _P.nwidthoffset,
        drawactive = false,
        drawgatecontacts = false,
        drawtopgcut = false,
        drawbotgcut = false,
        drawleftstopgate = _P.leftnotright,
        leftpolylines = leftpolylines,
        drawrightstopgate = not _P.leftnotright,
        rightpolylines = rightpolylines,
    })
    gate:merge_into(harness)
    gate:inherit_alignment_box(harness)
end
