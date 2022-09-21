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
        { "shiftpcontactsinner", 0 },
        { "shiftpcontactsouter", 0 },
        { "shiftncontactsinner", 0 },
        { "shiftncontactsouter", 0 },
        { "drawdummygatecontacts", true },
        { "drawdummyactivecontacts", true },
        { "drawtopbotwelltaps", false },
        { "drawtopgcut", true },
        { "drawbotgcut", true },
        { "drawleftstopgate", false },
        { "drawrightstopgate", false },
        { "leftpolylines", {} },
        { "rightpolylines", {} }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")
    local xpitch = bp.gspace + bp.glength
    local fingers = #_P.gatecontactpos
    -- numtracks + 2 for powerspace calculation: only virtual routes on power bars (no real ones)
    local ppowerspace, npowerspace
    local separation
    if bp.spacesepautocalc then
        separation = bp.numinnerroutes * bp.routingwidth + (bp.numinnerroutes + 1) * bp.routingspace
        -- FIXME: are these calculations really different?
        if bp.numinnerroutes % 2 == 0 then
            ppowerspace = (2 * (bp.pnumtracks + 1) + bp.numinnerroutes - 1) * (bp.routingwidth + bp.routingspace) / 2 - separation / 2 - _P.pwidth - bp.powerwidth / 2
            npowerspace = (2 * (bp.nnumtracks + 1) + bp.numinnerroutes - 1) * (bp.routingwidth + bp.routingspace) / 2 - separation / 2 - _P.nwidth - bp.powerwidth / 2
        else
            ppowerspace = ((bp.numinnerroutes + 1) / 2 + bp.pnumtracks) * (bp.routingwidth + bp.routingspace) - separation / 2 - _P.pwidth - bp.powerwidth / 2
            npowerspace = ((bp.numinnerroutes + 1) / 2 + bp.nnumtracks) * (bp.routingwidth + bp.routingspace) - separation / 2 - _P.nwidth - bp.powerwidth / 2
        end
    else
        separation = bp.separation
        npowerspace = bp.powerspace
        ppowerspace = bp.powerspace
    end
    local routingshift = (bp.routingwidth + bp.routingspace) / (bp.numinnerroutes % 2 == 0 and 2 or 1)
    local cmos = pcell.create_layout("basic/cmos", {
        nvthtype = bp.nvthtype,
        pvthtype = bp.pvthtype,
        pmosflippedwell = bp.pmosflippedwell,
        nmosflippedwell = bp.nmosflippedwell,
        drawpmoswelltap = _P.drawtopbotwelltaps,
        drawnmoswelltap = _P.drawtopbotwelltaps,
        oxidetype = bp.oxidetype,
        gatemarker = bp.gatemarker,
        gatelength = bp.glength,
        gatespace = bp.gspace,
        gatecontactpos = _P.gatecontactpos,
        pcontactpos = _P.pcontactpos,
        ncontactpos = _P.ncontactpos,
        powerwidth = bp.powerwidth,
        npowerspace = npowerspace,
        ppowerspace = ppowerspace,
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
        sdwidth = bp.sdwidth,
        separation = separation,
        gatecontactsplitshift = 2 * routingshift,
        dummycontheight = bp.powerwidth / 4,
        dummycontshift = -bp.powerwidth / 2 + bp.powerwidth / 8,
        drawleftstopgate = _P.drawleftstopgate,
        leftpolylines = _P.leftpolylines,
        drawrightstopgate = _P.drawrightstopgate,
        rightpolylines = _P.rightpolylines,
        drawgcut = true,
        drawgcuteverywhere = true,
    })
    gate:exchange(cmos)
end
