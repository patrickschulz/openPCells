function config()
    pcell.set_property("hidden", true)
end

function parameters()
    pcell.add_parameters(
        { "gatecontactpos", { "center" }, argtype = "strtable" },
        { "pcontactpos", {}, argtype = "strtable" },
        { "ncontactpos", {}, argtype = "strtable" },
        { "drawtransistors", true },
        { "drawactive", true },
        { "drawrails", true },
        { "drawgatecontacts", true },
        { "drawdummygatecontacts", true },
        { "drawdummyactivecontacts", true },
        { "drawtopgcut", true },
        { "drawbotgcut", true },
        { "leftpolylines", {} },
        { "rightpolylines", {} },
        { "drawleftstopgate", false },
        { "drawrightstopgate", false }
    )
    pcell.inherit_parameters("stdcells/base")
end

function layout(gate, _P)
    local xpitch = _P.gspace + _P.glength
    local routingpitch = _P.routingwidth + _P.routingspace
    local separation = _P.numinnerroutes * _P.routingwidth + (_P.numinnerroutes + 1) * _P.routingspace
    local ppowerspace = _P.pnumtracks * routingpitch + _P.routingwidth / 2 - _P.basepwidth - _P.pwidthoffset - _P.powerwidth / 2
    local npowerspace = _P.nnumtracks * routingpitch + _P.routingwidth / 2 - _P.basenwidth - _P.nwidthoffset - _P.powerwidth / 2
    local routingshift = (_P.routingwidth + _P.routingspace) * (_P.numinnerroutes % 2 == 0 and 1 or 2)
    local cmos = pcell.create_layout("basic/cmos", "cmos", {
        nvthtype = _P.nvthtype,
        pvthtype = _P.pvthtype,
        pmosflippedwell = _P.pmosflippedwell,
        nmosflippedwell = _P.nmosflippedwell,
        drawpmoswelltap = _P.drawtopbotwelltaps,
        drawnmoswelltap = _P.drawtopbotwelltaps,
        nmoswelltapspace = _P.topbotwelltapspace,
        nmoswelltapwidth = _P.topbotwelltapwidth,
        pmoswelltapspace = _P.topbotwelltapspace,
        pmoswelltapwidth = _P.topbotwelltapwidth,
        oxidetype = _P.oxidetype,
        gatemarker = _P.gatemarker,
        gatelength = _P.glength,
        gatespace = _P.gspace,
        gatecontactpos = _P.gatecontactpos,
        gatenames = _P.gatenames,
        --pgateext = ppowerspace + _P.powerwidth / 2,
        --ngateext = npowerspace + _P.powerwidth / 2,
        pgateext = ppowerspace + ((_P.drawtopbotwelltaps or _P.centereddummycontacts) and _P.powerwidth or (_P.powerwidth / 4)),
        ngateext = npowerspace + ((_P.drawtopbotwelltaps or _P.centereddummycontacts) and _P.powerwidth or (_P.powerwidth / 4)),
        pcontactpos = _P.pcontactpos,
        ncontactpos = _P.ncontactpos,
        powerwidth = _P.powerwidth,
        npowerspace = npowerspace,
        ppowerspace = ppowerspace,
        pwidth = _P.basepwidth + _P.pwidthoffset,
        nwidth = _P.basenwidth + _P.nwidthoffset,
        gatestrapwidth = _P.routingwidth,
        gatestrapspace = _P.routingspace,
        sdwidth = _P.sdwidth,
        separation = separation,
        gatecontactsplitshift = routingshift,
        --dummycontheight = _P.drawtopbotwelltaps and _P.powerwidth or (_P.powerwidth / 4),
        --dummycontshift = _P.drawtopbotwelltaps and 0 or (-_P.powerwidth / 2 + _P.powerwidth / 8),
        dummycontheight = (_P.drawtopbotwelltaps or _P.centereddummycontacts) and _P.powerwidth or (_P.powerwidth / 4),
        dummycontshift = (_P.drawtopbotwelltaps or _P.centereddummycontacts) and 0 or (-_P.powerwidth / 2 + _P.powerwidth / 8),
        drawleftstopgate = _P.drawleftstopgate,
        leftpolylines = _P.leftpolylines,
        drawrightstopgate = _P.drawrightstopgate,
        rightpolylines = _P.rightpolylines,
        --drawgatecut = true,
        drawgatecuteverywhere = true,
    })
    gate:exchange(cmos)
    for i = 1, _P.numinnerroutes do
        gate:add_area_anchor_bltr(
            string.format("innertrack%d", i),
            point.create(0,   _P.basenwidth + _P.nwidthoffset + _P.routingspace + (i - 1) * routingpitch),
            point.create(100, _P.basenwidth + _P.nwidthoffset + _P.routingspace + (i - 1) * routingpitch + _P.routingwidth)
        )
    end
    for i = 1, _P.pnumtracks + 1 do -- +1: one virtual lies in the power bar
        gate:add_area_anchor_bltr(
            string.format("ptrack%d", i),
            point.create(0,   _P.basenwidth + _P.nwidthoffset + separation + (i - 1) * routingpitch),
            point.create(100, _P.basenwidth + _P.nwidthoffset + separation + (i - 1) * routingpitch + _P.routingwidth)
        )
    end
    for i = 1, _P.nnumtracks + 1 do -- +1: one virtual lies in the power bar
        gate:add_area_anchor_bltr(
            string.format("ntrack%d", i),
            point.create(0,   _P.basenwidth + _P.nwidthoffset - (i - 1) * routingpitch - _P.routingwidth),
            point.create(100, _P.basenwidth + _P.nwidthoffset - (i - 1) * routingpitch)
        )
    end
end
