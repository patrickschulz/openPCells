function parameters()
    pcell.add_parameter("fingers", 1)
    pcell.add_parameter("leftnotright", true)
    pcell.add_parameter("pwidth", 2 * tech.get_dimension("Minimum Gate Width"))
    pcell.add_parameter("nwidth", 2 * tech.get_dimension("Minimum Gate Width"))
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
        local entry = { bp.glength, bp.gspace }
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
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
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
