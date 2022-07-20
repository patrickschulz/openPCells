function config()
    pcell.reference_cell("stdcells/base")
    pcell.set_property("hidden", true)
end

function parameters()
    pcell.add_parameters(
        { "pwidth", 2 * tech.get_dimension("Minimum Gate Width") },
        { "nwidth", 2 * tech.get_dimension("Minimum Gate Width") },
        { "drawtransistors", true },
        { "drawactive", true },
        { "drawrails", true },
        { "drawgatecontacts", true },
        { "gatecontactpos", { "center" }, argtype = "strtable" },
        { "shiftgatecontacts", 0 },
        { "pcontactpos", {}, argtype = "strtable" },
        { "ncontactpos", {}, argtype = "strtable" },
        { "leftdummies", 0 },
        { "rightdummies", 0 },
        { "shiftpcontactsinner", 0 },
        { "shiftpcontactsouter", 0 },
        { "shiftncontactsinner", 0 },
        { "shiftncontactsouter", 0 },
        { "drawdummygatecontacts", true },
        { "drawdummyactivecontacts", true },
        { "drawtopgcut", true },
        { "drawbotgcut", true }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")
    local xpitch = bp.gspace + bp.glength
    local xshift = (_P.rightdummies - _P.leftdummies) * xpitch / 2
    local fingers = #_P.gatecontactpos
    -- numtracks + 2 for powerspace calculation: only virtual routes on power bars (no real ones)
    local powerspace
    local separation
    if bp.spacesepautocalc then
        separation = bp.numinnerroutes * bp.routingwidth + (bp.numinnerroutes + 1) * bp.routingspace
        powerspace = ((bp.numtracks + 2) * (bp.routingwidth + bp.routingspace) - 2 * bp.powerwidth - _P.nwidth - _P.pwidth - separation) / 2 - bp.routingspace / 2
        dprint(bp.numtracks, _P.nwidth, _P.pwidth, powerspace)
    else
        separation = bp.separation
        powerspace = bp.powerspace
    end
    local routingshift = (bp.routingwidth + bp.routingspace) / (bp.numinnerroutes % 2 == 0 and 2 or 1)
    local cmos = pcell.create_layout("basic/cmos", {
        nvthtype = bp.nvthtype,
        pvthtype = bp.pvthtype,
        pmosflippedwell = bp.pmosflippedwell,
        nmosflippedwell = bp.nmosflippedwell,
        oxidetype = bp.oxidetype,
        gatemarker = bp.gatemarker,
        gatelength = bp.glength,
        gatespace = bp.gspace,
        gatecontactpos = _P.gatecontactpos,
        pcontactpos = _P.pcontactpos,
        ncontactpos = _P.ncontactpos,
        leftdummies = _P.leftdummies,
        rightdummies = _P.rightdummies,
        powerwidth = bp.powerwidth,
        powerspace = powerspace,
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
        sdwidth = bp.sdwidth,
        separation = separation,
        gatecontactsplitshift = routingshift,
    })
    gate:exchange(cmos)
end
