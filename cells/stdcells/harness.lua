function config()
    pcell.set_property("hidden", true)
end

function parameters()
    pcell.add_parameters(
        { "basepwidth(pMOS Finger Width)",                              2 * technology.get_dimension("Minimum Gate Width") },
        { "basenwidth(nMOS Finger Width)",                              2 * technology.get_dimension("Minimum Gate Width") },
        { "oxidetype(Oxide Type)",                                      1 },
        { "gatemarker(Gate Marker Index)",                              1 },
        { "pvthtype(PMOS Threshold Voltage Type) ",                     1 },
        { "nvthtype(NMOS Threshold Voltage Type)",                      1 },
        { "pmosflippedwell(PMOS Flipped Well) ",                        false },
        { "nmosflippedwell(NMOS Flipped Well)",                         false },
        { "glength(Gate Length)",                                       technology.get_dimension("Minimum Gate Length") },
        { "gspace(Gate Spacing)",                                       technology.get_dimension("Minimum Gate XSpace") },
        { "sdwidth(Source/Drain Metal Width)",                          technology.get_dimension("Minimum M1 Width"), posvals = even() },
        { "routingwidth(Routing Metal Width)",                          technology.get_dimension("Minimum M1 Width") },
        { "routingspace(Routing Metal Space)",                          technology.get_dimension("Minimum M1 Space") },
        { "pnumtracks(Number of PMOS Routing Tracks)",                  4 },
        { "nnumtracks(Number of NMOS Routing Tracks)",                  4 },
        { "numinnerroutes(Number of inner M1 routes)",                  3 }, -- the current implementations expects this to be 3 always, so don't change this
        { "powerwidth(Power Rail Metal Width)",                         4 * technology.get_dimension("Minimum M1 Width") },
        { "powerspace(Power Rail Space)",                               4 * technology.get_dimension("Minimum M1 Space") },
        { "gateext(Gate Extension)",                                    0 },
        { "psdheight(PMOS Source/Drain Contact Height)",                0 },
        { "nsdheight(NMOS Source/Drain Contact Height)",                0 },
        { "psdpowerheight(PMOS Source/Drain Contact Height)",           0 },
        { "nsdpowerheight(NMOS Source/Drain Contact Height)",           0 },
        { "drawtopbotwelltaps",                                         false },
        { "topbotwelltapwidth",                                         technology.get_dimension("Minimum M1 Width") },
        { "topbotwelltapspace",                                         technology.get_dimension("Minimum M1 Space") },
        { "dummycontheight(Dummy Gate Contact Height)",                 technology.get_dimension("Minimum M1 Width") },
        { "drawdummygcut(Draw Dummy Gate Cut)",                         false },
        { "centereddummycontacts(Centered Dummy Contacts)",             true },
        { "compact(Compact Layout)",                                    true },
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
        pgateext = ppowerspace + _P.powerwidth / 2,
        ngateext = npowerspace + _P.powerwidth / 2,
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
