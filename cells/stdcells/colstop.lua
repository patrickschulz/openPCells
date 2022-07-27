function parameters()
    pcell.reference_cell("stdcells/base")
    pcell.reference_cell("stdcells/harness")
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
    local harness = pcell.create_layout("stdcells/harness", { 
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
        numleftpolylines = _P.leftnotright and (_P.fingers - 1) or 0,
        drawrightstopgate = not _P.leftnotright,
        numrightpolylines = not _P.leftnotright and (_P.fingers - 1) or 0,
    })
    gate:merge_into_shallow(harness)
    gate:inherit_alignment_box(harness)
end
