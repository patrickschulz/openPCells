function config()
    pcell.set_property("hidden", true)
end

function parameters()
    pcell.add_parameters(
        { "pwidthoffset", 0 },
        { "nwidthoffset", 0 },
        { "drawtransistors", true },
        { "drawactive", true },
        { "drawrails", true },
        { "drawgatecontacts", true },
        { "gatecontactpos", { "center" }, argtype = "strtable" },
        { "gatenames", {}, argtype = "strtable" },
        { "shiftgatecontacts", 0 },
        { "pcontactpos", {}, argtype = "strtable" },
        { "ncontactpos", {}, argtype = "strtable" },
        { "shiftpcontactsinner", 0 },
        { "shiftpcontactsouter", 0 },
        { "shiftncontactsinner", 0 },
        { "shiftncontactsouter", 0 },
        { "drawdummygatecontacts", true },
        { "drawdummyactivecontacts", true },
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
    local routingpitch = bp.routingwidth + bp.routingspace
    local separation = bp.numinnerroutes * bp.routingwidth + (bp.numinnerroutes + 1) * bp.routingspace
    local ppowerspace = bp.pnumtracks * routingpitch + bp.routingwidth / 2 - bp.basepwidth - _P.pwidthoffset - bp.powerwidth / 2
    local npowerspace = bp.nnumtracks * routingpitch + bp.routingwidth / 2 - bp.basenwidth - _P.nwidthoffset - bp.powerwidth / 2
    local routingshift = (bp.routingwidth + bp.routingspace) * (bp.numinnerroutes % 2 == 0 and 1 or 2)
    local cmos = pcell.create_layout("basic/cmos", "cmos", {
        nvthtype = bp.nvthtype,
        pvthtype = bp.pvthtype,
        pmosflippedwell = bp.pmosflippedwell,
        nmosflippedwell = bp.nmosflippedwell,
        drawpmoswelltap = bp.drawtopbotwelltaps,
        drawnmoswelltap = bp.drawtopbotwelltaps,
        nmoswelltapspace = bp.topbotwelltapspace,
        nmoswelltapwidth = bp.topbotwelltapwidth,
        pmoswelltapspace = bp.topbotwelltapspace,
        pmoswelltapwidth = bp.topbotwelltapwidth,
        oxidetype = bp.oxidetype,
        gatemarker = bp.gatemarker,
        gatelength = bp.glength,
        gatespace = bp.gspace,
        gatecontactpos = _P.gatecontactpos,
        gatenames = _P.gatenames,
        pgateext = ppowerspace + bp.powerwidth / 2,
        ngateext = npowerspace + bp.powerwidth / 2,
        pcontactpos = _P.pcontactpos,
        ncontactpos = _P.ncontactpos,
        powerwidth = bp.powerwidth,
        npowerspace = npowerspace,
        ppowerspace = ppowerspace,
        pwidth = bp.basepwidth + _P.pwidthoffset,
        nwidth = bp.basenwidth + _P.nwidthoffset,
        gatestrapwidth = bp.routingwidth,
        gatestrapspace = bp.routingspace,
        sdwidth = bp.sdwidth,
        separation = separation,
        gatecontactsplitshift = routingshift,
        dummycontheight = bp.drawtopbotwelltaps and bp.powerwidth or (bp.powerwidth / 4),
        dummycontshift = bp.drawtopbotwelltaps and 0 or (-bp.powerwidth / 2 + bp.powerwidth / 8),
        drawleftstopgate = _P.drawleftstopgate,
        leftpolylines = _P.leftpolylines,
        drawrightstopgate = _P.drawrightstopgate,
        rightpolylines = _P.rightpolylines,
        drawgatecut = true,
        drawgatecuteverywhere = true,
    })
    gate:exchange(cmos)
    for i = 1, bp.numinnerroutes do
        gate:add_area_anchor_bltr(
            string.format("innertrack%d", i),
            point.create(0,   bp.basenwidth + _P.nwidthoffset + bp.routingspace + (i - 1) * routingpitch),
            point.create(100, bp.basenwidth + _P.nwidthoffset + bp.routingspace + (i - 1) * routingpitch + bp.routingwidth)
        )
    end
    for i = 1, bp.pnumtracks + 1 do -- +1: one virtual lies in the power bar
        gate:add_area_anchor_bltr(
            string.format("ptrack%d", i),
            point.create(0,   bp.basenwidth + _P.nwidthoffset + separation + (i - 1) * routingpitch),
            point.create(100, bp.basenwidth + _P.nwidthoffset + separation + (i - 1) * routingpitch + bp.routingwidth)
        )
    end
    for i = 1, bp.nnumtracks + 1 do -- +1: one virtual lies in the power bar
        gate:add_area_anchor_bltr(
            string.format("ntrack%d", i),
            point.create(0,   bp.basenwidth + _P.nwidthoffset - (i - 1) * routingpitch - bp.routingwidth),
            point.create(100, bp.basenwidth + _P.nwidthoffset - (i - 1) * routingpitch)
        )
    end
end
