function config()
    pcell.reference_cell("stdcells/base")
    pcell.set_property("hidden", true)
end

function parameters()
    pcell.add_parameters(
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
    local separation = bp.numinnerroutes * bp.gstwidth + (bp.numinnerroutes + 1) * bp.gstspace
    local fingers = #_P.gatecontactpos
    local powerspace = (bp.numtracks * (bp.gstwidth + bp.gstspace) - 2 * bp.powerwidth - bp.nwidth - bp.pwidth - separation) / 2
    local routingshift = (bp.gstwidth + bp.gstspace) / (bp.numinnerroutes % 2 == 0 and 2 or 1)
    local cmos = pcell.create_layout("basic/cmos", {
        nvthtype = bp.nvthtype,
        pvthtype = bp.pvthtype,
        pmosflippedwell = bp.pmosflippedwell,
        nmosflippedwell = bp.nmosflippedwell,
        gatelength = bp.glength,
        gatespace = bp.gspace,
        gatecontactpos = _P.gatecontactpos,
        pcontactpos = _P.pcontactpos,
        ncontactpos = _P.ncontactpos,
        leftdummies = _P.leftdummies,
        rightdummies = _P.rightdummies,
        powerwidth = bp.powerwidth,
        powerspace = powerspace,
        pwidth = bp.pwidth,
        nwidth = bp.nwidth,
        separation = separation,
        gatecontactsplitshift = routingshift,
    })
    gate:exchange(cmos)
end
