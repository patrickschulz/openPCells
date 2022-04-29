function config()
    pcell.reference_cell("basic/mosfet")
end

function parameters()
    pcell.add_parameters(
        { "oxidetype(Oxide Type)",                             1 },
        { "pvthtype(PMOS Threshold Voltage Type) ",            1 },
        { "nvthtype(NMOS Threshold Voltage Type)",             1 },
        { "pwidth(PMOS Finger Width)",                         tech.get_dimension("Minimum Gate Width"), even() },
        { "nwidth(NMOS Finger Width)",                         tech.get_dimension("Minimum Gate Width"), even() },
        { "separation(Separation Between Active Regions)",     tech.get_dimension("Minimum Active Space"), even() },
        { "gatelength(Gate Length)",                           tech.get_dimension("Minimum Gate Length"), argtype = "integer", posvals = even() },
        { "gatespace(Gate Spacing)",                           tech.get_dimension("Minimum Gate Space"), argtype = "integer", posvals = even() },
        { "sdwidth(Source/Drain Metal Width)",                 tech.get_dimension("Minimum M1 Width"), even() },
        { "gstwidth(Gate Strap Metal Width)",                  tech.get_dimension("Minimum M1 Width") },
        { "gstspace(Gate Strap Metal Space)",                  tech.get_dimension("Minimum M1 Space") },
        { "gatecontactsplitshift(Gate Contact Split Shift)",   tech.get_dimension("Minimum M1 Width") + tech.get_dimension("Minimum M1 Space") },
        { "powerwidth(Power Rail Metal Width)",                tech.get_dimension("Minimum M1 Width") },
        { "powerspace(Power Rail Space)",                      tech.get_dimension("Minimum M1 Space") },
        { "gateext(Gate Extension)",                           0 },
        { "psdheight(PMOS Source/Drain Contact Height)",       0 },
        { "nsdheight(NMOS Source/Drain Contact Height)",       0 },
        { "psdpowerheight(PMOS Source/Drain Contact Height)",  0 },
        { "nsdpowerheight(NMOS Source/Drain Contact Height)",  0 },
        { "dummycontheight(Dummy Gate Contact Height)",        tech.get_dimension("Minimum M1 Width") },
        { "cutheight",                                         60, posvals = even() },
        { "drawdummygcut(Draw Dummy Gate Cut)",                false },
        { "compact(Compact Layout)",                           true },
        { "connectoutput",                                     true },
        { "drawtransistors", true },
        { "drawactive", true },
        { "drawrails", true },
        { "drawgatecontacts", true },
        { "outergstwidth(Outer Gate Strap Metal Width)",  tech.get_dimension("Minimum M1 Width") },
        { "outergstspace(Outer Gate Strap Metal Space)",  tech.get_dimension("Minimum M1 Space") },
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
        { "drawgcut", false },
        { "dummycontheight(Dummy Gate Contact Height)",        tech.get_dimension("Minimum M1 Width") },
        { "drawnmoswelltap(Draw nMOS Well Tap)", false },
        { "nmoswelltapspace(nMOS Well Tap Space)", tech.get_dimension("Minimum M1 Space") },
        { "nmoswelltapwidth(nMOS Well Tap Width)", tech.get_dimension("Minimum M1 Width") },
        { "drawpmoswelltap(Draw pMOS Well Tap)", false },
        { "pmoswelltapspace(pMOS Well Tap Space)", tech.get_dimension("Minimum M1 Space") },
        { "pmoswelltapwidth(pMOS Well Tap Width)", tech.get_dimension("Minimum M1 Width") }
    )
end

function layout(cmos, _P)
    local xpitch = _P.gatespace + _P.gatelength
    local fingers = #_P.gatecontactpos
    local xshift = (_P.rightdummies - _P.leftdummies) * xpitch / 2

    -- check if outer gates are drawn
    local outergatepresent = false
    if _P.drawgatecontacts then
        for i = 1, fingers do
            if _P.gatecontactpos[i] == "outer" then
                outergatepresent = true
            end
        end
    end
    local outergateshift = outergatepresent and _P.outergstspace + _P.gstwidth or 0

    if _P.drawtransistors then
        -- common transistor options
        pcell.push_overwrites("basic/mosfet", {
            gatelength = _P.gatelength,
            gatespace = _P.gatespace,
            sdwidth = _P.sdwidth,
            drawinnersourcedrain = "none",
            drawoutersourcedrain = "none",
            drawactive = _P.drawactive
        })
        local ext = math.max(_P.powerspace + _P.powerwidth + outergateshift, math.max(_P.gateext, _P.cutheight / 2, _P.dummycontheight / 2))

        -- pmos
        pcell.push_overwrites("basic/mosfet", {
            channeltype = "pmos",
            vthtype = _P.pvthtype,
            fwidth = _P.pwidth,
            gbotext = _P.separation / 2,
            gtopext = ext,
            topgcutoffset = ext,
            clipbot = true,
            drawtopwelltap = _P.drawpmoswelltap,
            topwelltapwidth = _P.pmoswelltapwidth,
            topwelltapspace = _P.powerspace + _P.powerwidth + _P.pmoswelltapspace,
        })
        -- main
        local pmos
        if fingers > 0 then
            pmos = pcell.create_layout("basic/mosfet", { fingers = fingers } ):move_anchor("botgate")
            cmos:merge_into_shallow(pmos)
        end
        -- left dummy
        if _P.leftdummies > 0 then
            cmos:merge_into_shallow(
                pcell.create_layout("basic/mosfet", { fingers = _P.leftdummies, drawtopgcut = false, drawbotgcut = true }
            ):move_anchor("rightbotgate", pmos and pmos:get_anchor("leftbotgate") or nil))
        end
        -- rightdummy
        if _P.rightdummies > 0 then
            cmos:merge_into_shallow(
                pcell.create_layout("basic/mosfet", { fingers = _P.rightdummies, drawtopgcut = false, drawbotgcut = true }
            ):move_anchor("leftbotgate", pmos and pmos:get_anchor("rightbotgate") or nil))
        end
        pcell.pop_overwrites("basic/mosfet")

        -- nmos
        pcell.push_overwrites("basic/mosfet", {
            vthtype = _P.nvthtype,
            fwidth = _P.nwidth,
            gtopext = _P.separation / 2,
            gbotext = ext,
            botgcutoffset = ext,
            cliptop = true,
            drawbotwelltap = _P.drawnmoswelltap,
            botwelltapwidth = _P.nmoswelltapwidth,
            botwelltapspace = _P.powerspace + _P.powerwidth + _P.nmoswelltapspace,
        })
        -- main
        local nmos
        if fingers > 0 then
            nmos = pcell.create_layout("basic/mosfet", { fingers = fingers, channeltype = "nmos" }):move_anchor("topgate")
            cmos:merge_into_shallow(nmos)
        end
        -- left dummy
        if _P.leftdummies > 0 then
            cmos:merge_into_shallow(
                pcell.create_layout("basic/mosfet", { fingers = _P.leftdummies, drawtopgcut = true, drawbotgcut = false }
            ):move_anchor("righttopgate", nmos and nmos:get_anchor("lefttopgate") or nil))
        end
        -- rightdummy
        if _P.rightdummies > 0 then
            cmos:merge_into_shallow(
                pcell.create_layout("basic/mosfet", { fingers = _P.rightdummies, drawtopgcut = true, drawbotgcut = false }
            ):move_anchor("lefttopgate", nmos and nmos:get_anchor("righttopgate") or nil))
        end
        pcell.pop_overwrites("basic/mosfet")
        -- pop general transistor settings
        pcell.pop_overwrites("basic/mosfet")
    end

    -- power rails
    if _P.drawrails then
        geometry.rectangle(cmos,
            generics.metal(1), 
            (fingers + _P.leftdummies + _P.rightdummies) * xpitch + _P.sdwidth, _P.powerwidth,
            xshift, (_P.pwidth - _P.nwidth) / 2,
            1, 2, 0, _P.separation + _P.pwidth + _P.nwidth + 2 * _P.powerspace + _P.powerwidth
        )
    end
    cmos:add_anchor("PRpll", point.create(-fingers * xpitch / 2 - _P.sdwidth / 2,  _P.separation / 2 + _P.pwidth + _P.powerspace))
    cmos:add_anchor("PRpcl", point.create(-fingers * xpitch / 2 - _P.sdwidth / 2,  _P.separation / 2 + _P.pwidth + _P.powerspace + _P.powerwidth / 2))
    cmos:add_anchor("PRpul", point.create(-fingers * xpitch / 2 - _P.sdwidth / 2,  _P.separation / 2 + _P.pwidth + _P.powerspace + _P.powerwidth))
    cmos:add_anchor("PRplc", point.create(0,                      _P.separation / 2 + _P.pwidth + _P.powerspace))
    cmos:add_anchor("PRpcc", point.create(0,                      _P.separation / 2 + _P.pwidth + _P.powerspace + _P.powerwidth / 2))
    cmos:add_anchor("PRpuc", point.create(0,                      _P.separation / 2 + _P.pwidth + _P.powerspace + _P.powerwidth))
    cmos:add_anchor("PRplr", point.create( fingers * xpitch / 2 + _P.sdwidth / 2,  _P.separation / 2 + _P.pwidth + _P.powerspace))
    cmos:add_anchor("PRpcr", point.create( fingers * xpitch / 2 + _P.sdwidth / 2,  _P.separation / 2 + _P.pwidth + _P.powerspace + _P.powerwidth / 2))
    cmos:add_anchor("PRpur", point.create( fingers * xpitch / 2 + _P.sdwidth / 2,  _P.separation / 2 + _P.pwidth + _P.powerspace + _P.powerwidth))
    cmos:add_anchor("PRnll", point.create(-fingers * xpitch / 2 - _P.sdwidth / 2, -_P.separation / 2 - _P.nwidth - _P.powerspace - _P.powerwidth))
    cmos:add_anchor("PRncl", point.create(-fingers * xpitch / 2 - _P.sdwidth / 2, -_P.separation / 2 - _P.nwidth - _P.powerspace - _P.powerwidth / 2))
    cmos:add_anchor("PRnul", point.create(-fingers * xpitch / 2 - _P.sdwidth / 2, -_P.separation / 2 - _P.nwidth - _P.powerspace))
    cmos:add_anchor("PRnlc", point.create(0,                     -_P.separation / 2 - _P.nwidth - _P.powerspace - _P.powerwidth))
    cmos:add_anchor("PRncc", point.create(0,                     -_P.separation / 2 - _P.nwidth - _P.powerspace - _P.powerwidth / 2))
    cmos:add_anchor("PRnuc", point.create(0,                     -_P.separation / 2 - _P.nwidth - _P.powerspace))
    cmos:add_anchor("PRnlr", point.create( fingers * xpitch / 2 + _P.sdwidth / 2, -_P.separation / 2 - _P.nwidth - _P.powerspace - _P.powerwidth))
    cmos:add_anchor("PRncr", point.create( fingers * xpitch / 2 + _P.sdwidth / 2, -_P.separation / 2 - _P.nwidth - _P.powerspace - _P.powerwidth / 2))
    cmos:add_anchor("PRnur", point.create( fingers * xpitch / 2 + _P.sdwidth / 2, -_P.separation / 2 - _P.nwidth - _P.powerspace))

    -- draw gate contacts
    local _make_anchors = function(parent, x, y, xshift, yshift, pre, post)
        parent:add_anchor(string.format("%sll%s", pre, post), point.create(x - xshift / 2, y - yshift / 2))
        parent:add_anchor(string.format("%scl%s", pre, post), point.create(x - xshift / 2, y             ))
        parent:add_anchor(string.format("%sul%s", pre, post), point.create(x - xshift / 2, y + yshift / 2))
        parent:add_anchor(string.format("%slc%s", pre, post), point.create(x,              y - yshift / 2))
        parent:add_anchor(string.format("%scc%s", pre, post), point.create(x,              y             ))
        parent:add_anchor(string.format("%suc%s", pre, post), point.create(x,              y + yshift / 2))
        parent:add_anchor(string.format("%slr%s", pre, post), point.create(x + xshift / 2, y - yshift / 2))
        parent:add_anchor(string.format("%scr%s", pre, post), point.create(x + xshift / 2, y             ))
        parent:add_anchor(string.format("%sur%s", pre, post), point.create(x + xshift / 2, y + yshift / 2))
    end
    if _P.drawgatecontacts then
        for i = 1, fingers do
            local x = (2 * i - fingers - 1 + _P.leftdummies - _P.rightdummies) * xpitch / 2 + xshift
            if _P.gatecontactpos[i] == "center" then
                geometry.contactbltr(
                    cmos, "gate", 
                    point.create(x - _P.gatelength / 2, _P.shiftgatecontacts - _P.gstwidth / 2),
                    point.create(x + _P.gatelength / 2, _P.shiftgatecontacts + _P.gstwidth / 2)
                )
                _make_anchors(cmos, x, _P.shiftgatecontacts, _P.gatelength, _P.gstwidth, "G", string.format("%d", i))
            elseif _P.gatecontactpos[i] == "upper" then
                geometry.contactbltr(
                    cmos, "gate", 
                    point.create(x - _P.gatelength / 2, _P.gatecontactsplitshift + _P.shiftgatecontacts - _P.gstwidth / 2),
                    point.create(x + _P.gatelength / 2, _P.gatecontactsplitshift + _P.shiftgatecontacts + _P.gstwidth / 2)
                )
                _make_anchors(cmos, x, _P.gatecontactsplitshift + _P.shiftgatecontacts, _P.gatelength, _P.gstwidth, "G", string.format("%d", i))
            elseif _P.gatecontactpos[i] == "lower" then
                geometry.contactbltr(
                    cmos, "gate", 
                    point.create(x - _P.gatelength / 2, -_P.gatecontactsplitshift + _P.shiftgatecontacts - _P.gstwidth / 2),
                    point.create(x + _P.gatelength / 2, -_P.gatecontactsplitshift + _P.shiftgatecontacts + _P.gstwidth / 2)
                )
                _make_anchors(cmos, x, -_P.gatecontactsplitshift + _P.shiftgatecontacts, _P.gatelength, _P.gstwidth, "G", string.format("%d", i))
            elseif _P.gatecontactpos[i] == "split" then
                local y = _P.shiftgatecontacts
                geometry.contactbltr(
                    cmos, "gate", 
                    point.create(x - _P.gatelength / 2, y - _P.gstwidth / 2),
                    point.create(x + _P.gatelength / 2, y + _P.gstwidth / 2),
                    1, 2, 0, 2 * _P.gatecontactsplitshift
                )
                _make_anchors(cmos, x, y,                _P.gatelength, _P.gstwidth, "G", string.format("%d", i))
                _make_anchors(cmos, x, y + _P.gatecontactsplitshift, _P.gatelength, _P.gstwidth, "Gupper", string.format("%d", i))
                _make_anchors(cmos, x, y - _P.gatecontactsplitshift, _P.gatelength, _P.gstwidth, "Glower", string.format("%d", i))
                geometry.rectangle(cmos, generics.other("gatecut"), xpitch, _P.cutheight, x, 0)
            elseif _P.gatecontactpos[i] == "dummy" then
                geometry.contactbltr(
                    cmos, "gate", 
                    point.create(x - _P.gatelength / 2, (_P.pwidth - _P.nwidth) / 2 + -_P.dummycontheight / 2),
                    point.create(x + _P.gatelength / 2, (_P.pwidth - _P.nwidth) / 2 +  _P.dummycontheight / 2),
                    1, 2, 0, _P.separation + _P.pwidth + _P.nwidth + 2 * _P.powerspace + _P.powerwidth
                )
                geometry.rectangle(cmos, generics.other("gatecut"), xpitch, _P.cutheight, x, 0)
            elseif _P.gatecontactpos[i] == "outer" then
                geometry.contactbltr(
                    cmos, "gate",
                    point.create(x - _P.gatelength / 2, _P.separation / 2 + _P.pwidth + _P.outergstspace + _P.gstwidth / 2 + _P.powerwidth + _P.powerspace - _P.outergstwidth / 2),
                    point.create(x + _P.gatelength / 2, _P.separation / 2 + _P.pwidth + _P.outergstspace + _P.gstwidth / 2 + _P.powerwidth + _P.powerspace + _P.outergstwidth / 2)
                )
                geometry.contactbltr(
                    cmos, "gate",
                    point.create(x - _P.gatelength / 2, -_P.separation / 2 - _P.nwidth - _P.outergstspace - _P.gstwidth / 2 - _P.powerwidth - _P.powerspace - _P.outergstwidth / 2),
                    point.create(x + _P.gatelength / 2, -_P.separation / 2 - _P.nwidth - _P.outergstspace - _P.gstwidth / 2 - _P.powerwidth - _P.powerspace + _P.outergstwidth / 2)
                )
                cmos:add_anchor(string.format("Gp%d", i), point.create(
                    x,
                    _P.separation / 2 + _P.pwidth + _P.outergstspace + _P.outergstwidth / 2 + _P.powerwidth + _P.powerspace))
                cmos:add_anchor(string.format("Gn%d", i), point.create(
                    x,
                    -_P.separation / 2 - _P.nwidth - _P.outergstspace - _P.outergstwidth / 2 - _P.powerwidth - _P.powerspace))
            else
                moderror(string.format("unknown gate contact position: %s", _P.gatecontactpos[i]))
            end
            if _P.gatecontactpos[i] ~= "dummy" then
                if _P.drawgcut then
                geometry.rectanglebltr(
                    cmos, generics.other("gatecut"),
                    point.create(x - xpitch / 2, (_P.pwidth - _P.nwidth) / 2 - _P.cutheight / 2),
                    point.create(x + xpitch / 2, (_P.pwidth - _P.nwidth) / 2 + _P.cutheight / 2),
                    1, 2, 0, _P.separation + _P.pwidth + _P.nwidth + 2 * _P.powerspace + _P.powerwidth
                )
                end
            end
        end
    end
    if _P.drawdummygatecontacts then
        geometry.contactbltr(
            cmos, "gate", 
            point.create(-(fingers + _P.rightdummies) * xpitch / 2 + xshift - (_P.gatelength) / 2, (_P.pwidth - _P.nwidth) / 2 - (_P.dummycontheight) / 2),
            point.create(-(fingers + _P.rightdummies) * xpitch / 2 + xshift + (_P.gatelength) / 2, (_P.pwidth - _P.nwidth) / 2 + (_P.dummycontheight) / 2),
            _P.leftdummies, 2, xpitch, _P.separation + _P.pwidth + _P.nwidth + 2 * _P.powerspace + _P.powerwidth
        )
        geometry.contactbltr(
            cmos, "gate", 
            point.create((fingers + _P.leftdummies) * xpitch / 2 + xshift - (_P.gatelength) / 2, (_P.pwidth - _P.nwidth) / 2 - (_P.dummycontheight) / 2),
            point.create((fingers + _P.leftdummies) * xpitch / 2 + xshift + (_P.gatelength) / 2, (_P.pwidth - _P.nwidth) / 2 + (_P.dummycontheight) / 2),
            _P.rightdummies, 2, xpitch, _P.separation + _P.pwidth + _P.nwidth + 2 * _P.powerspace + _P.powerwidth
        )
    end

    -- dummy source/drain contacts
    local pcontactheight = (_P.psdheight > 0) and _P.psdheight or _P.pwidth / 2
    local ncontactheight = (_P.nsdheight > 0) and _P.nsdheight or _P.nwidth / 2
    local pcontactpowerheight = (_P.psdpowerheight > 0) and _P.psdpowerheight or _P.pwidth / 2
    local ncontactpowerheight = (_P.nsdpowerheight > 0) and _P.nsdpowerheight or _P.nwidth / 2
    if _P.drawdummyactivecontacts then
        geometry.contactbltr(
            cmos, "sourcedrain", 
            point.create(-(fingers + _P.rightdummies + 1) * xpitch / 2 + xshift - (_P.sdwidth) / 2, _P.separation / 2 + _P.pwidth - pcontactpowerheight / 2 - (pcontactpowerheight) / 2),
            point.create(-(fingers + _P.rightdummies + 1) * xpitch / 2 + xshift + (_P.sdwidth) / 2, _P.separation / 2 + _P.pwidth - pcontactpowerheight / 2 + (pcontactpowerheight) / 2),
            _P.leftdummies, 1, xpitch, 0
        )
        geometry.contactbltr(
            cmos, "sourcedrain", 
            point.create(-(fingers + _P.rightdummies + 1) * xpitch / 2 + xshift - (_P.sdwidth) / 2, -_P.separation / 2 - _P.nwidth + ncontactpowerheight / 2 - (ncontactpowerheight) / 2),
            point.create(-(fingers + _P.rightdummies + 1) * xpitch / 2 + xshift + (_P.sdwidth) / 2, -_P.separation / 2 - _P.nwidth + ncontactpowerheight /2 + (ncontactpowerheight) / 2),
            _P.leftdummies, 1, xpitch, 0
        )
        geometry.rectanglebltr(
            cmos, generics.metal(1), 
            point.create(-(fingers + _P.rightdummies + 1) * xpitch / 2 + xshift - (_P.sdwidth) / 2, (_P.pwidth - _P.nwidth) / 2 - (_P.powerspace) / 2),
            point.create(-(fingers + _P.rightdummies + 1) * xpitch / 2 + xshift + (_P.sdwidth) / 2, (_P.pwidth - _P.nwidth) / 2 + (_P.powerspace) / 2),
            _P.leftdummies, 2, xpitch, _P.separation + _P.pwidth + _P.nwidth + _P.powerspace
        )
        geometry.contactbltr(
            cmos, "sourcedrain", 
            point.create((fingers + _P.leftdummies + 1) * xpitch / 2 + xshift - (_P.sdwidth) / 2, _P.separation / 2 + _P.pwidth - pcontactpowerheight / 2 - (pcontactpowerheight) / 2),
            point.create((fingers + _P.leftdummies + 1) * xpitch / 2 + xshift + (_P.sdwidth) / 2, _P.separation / 2 + _P.pwidth - pcontactpowerheight /2 + (pcontactpowerheight) / 2),
            _P.rightdummies, 1, xpitch, 0
        )
        geometry.contactbltr(
            cmos, "sourcedrain", 
            point.create((fingers + _P.leftdummies + 1) * xpitch / 2 + xshift - (_P.sdwidth) / 2, -_P.separation / 2 - _P.nwidth + ncontactpowerheight / 2 - (ncontactpowerheight) / 2),
            point.create((fingers + _P.leftdummies + 1) * xpitch / 2 + xshift + (_P.sdwidth) / 2, -_P.separation / 2 - _P.nwidth + ncontactpowerheight /2 + (ncontactpowerheight) / 2),
            _P.rightdummies, xpitch
        )
        geometry.rectanglebltr(
            cmos, generics.metal(1), 
            point.create((fingers + _P.leftdummies + 1) * xpitch / 2 + xshift - (_P.sdwidth) / 2, (_P.pwidth - _P.nwidth) / 2 - (_P.powerspace) / 2),
            point.create((fingers + _P.leftdummies + 1) * xpitch / 2 + xshift + (_P.sdwidth) / 2, (_P.pwidth - _P.nwidth) / 2 + (_P.powerspace) / 2),
            _P.rightdummies, 2, xpitch, _P.separation + _P.pwidth + _P.nwidth + _P.powerspace
        )
    end

    -- draw source/drain contacts
    local pcontactheight = (_P.psdheight > 0) and _P.psdheight or _P.pwidth / 2
    local ncontactheight = (_P.nsdheight > 0) and _P.nsdheight or _P.nwidth / 2
    local pcontactpowerheight = (_P.psdpowerheight > 0) and _P.psdpowerheight or _P.pwidth / 2
    local ncontactpowerheight = (_P.nsdpowerheight > 0) and _P.nsdpowerheight or _P.nwidth / 2
    local indexshift = fingers + 2
    for i = 1, fingers + 1 do
        local x = (2 * i - indexshift) * xpitch / 2
        local y = _P.separation / 2 + _P.pwidth / 2
        -- p contacts
        if _P.pcontactpos[i] == "power" or _P.pcontactpos[i] == "outer" then
            local cheight = _P.pcontactpos[i] == "power" and pcontactpowerheight or pcontactheight
            geometry.contactbltr(
                cmos, "sourcedrain", 
                point.create(x - _P.sdwidth / 2, y + _P.pwidth / 2 - cheight / 2 - _P.shiftpcontactsouter - cheight / 2),
                point.create(x + _P.sdwidth / 2, y + _P.pwidth / 2 - cheight / 2 - _P.shiftpcontactsouter + cheight / 2)
            )
            cmos:add_anchor(string.format("pSDc%d", i), point.create(x, y + _P.pwidth / 2 - cheight / 2 - _P.shiftpcontactsouter))
            cmos:add_anchor(string.format("pSDi%d", i), point.create(x, y + _P.pwidth / 2 - cheight - _P.shiftpcontactsouter))
            cmos:add_anchor(string.format("pSDo%d", i), point.create(x, y + _P.pwidth / 2 - _P.shiftpcontactsouter))
        elseif _P.pcontactpos[i] == "inner" then
            geometry.contactbltr(
                cmos, "sourcedrain",
                point.create(x - _P.sdwidth / 2, y - _P.pwidth / 2 + _P.shiftpcontactsinner),
                point.create(x + _P.sdwidth / 2, y - _P.pwidth / 2 + _P.shiftpcontactsinner + pcontactheight)
            )
            cmos:add_anchor(string.format("pSDc%d", i), point.create(x, y - _P.pwidth / 2 + pcontactheight / 2 + _P.shiftpcontactsinner))
            cmos:add_anchor(string.format("pSDi%d", i), point.create(x, y - _P.pwidth / 2 + _P.shiftpcontactsinner))
            cmos:add_anchor(string.format("pSDo%d", i), point.create(x, y - _P.pwidth / 2 + pcontactheight + _P.shiftpcontactsinner))
        elseif _P.pcontactpos[i] == "full" or _P.pcontactpos[i] == "powerfull" then
            geometry.contactbltr(
                cmos, "sourcedrain", 
                point.create(x - _P.sdwidth / 2, y - _P.pwidth / 2),
                point.create(x + _P.sdwidth / 2, y + _P.pwidth / 2)
            )
            cmos:add_anchor(string.format("pSDc%d", i), point.create(x, y))
            cmos:add_anchor(string.format("pSDi%d", i), point.create(x, y - _P.pwidth / 2))
            cmos:add_anchor(string.format("pSDo%d", i), point.create(x, y + _P.pwidth / 2))
        end
        if _P.pcontactpos[i] == "power" or _P.pcontactpos[i] == "powerfull" then
            geometry.rectanglebltr(
                cmos, generics.metal(1), 
                point.create(x - _P.sdwidth / 2, y + _P.pwidth / 2 + _P.powerspace / 2 - _P.shiftpcontactsouter - _P.powerspace / 2),
                point.create(x + _P.sdwidth / 2, y + _P.pwidth / 2 + _P.powerspace / 2 - _P.shiftpcontactsouter + _P.powerspace / 2)
            )
        end
        y = -_P.separation / 2 - _P.nwidth / 2
        -- n contacts
        if _P.ncontactpos[i] == "power" or _P.ncontactpos[i] == "outer" then
            local cheight = _P.ncontactpos[i] == "power" and ncontactpowerheight or ncontactheight
            geometry.contactbltr(
                cmos, "sourcedrain",
                point.create(x - _P.sdwidth / 2, y - _P.nwidth / 2 + cheight / 2 + _P.shiftncontactsouter - cheight / 2),
                point.create(x + _P.sdwidth / 2, y - _P.nwidth / 2 + cheight / 2 + _P.shiftncontactsouter + cheight / 2)
            )
            cmos:add_anchor(string.format("nSDc%d", i), point.create(x, y - _P.nwidth / 2 + cheight / 2 + _P.shiftncontactsouter))
            cmos:add_anchor(string.format("nSDi%d", i), point.create(x, y - _P.nwidth / 2 + cheight + _P.shiftncontactsouter))
            cmos:add_anchor(string.format("nSDo%d", i), point.create(x, y - _P.nwidth / 2 + _P.shiftncontactsouter))
        elseif _P.ncontactpos[i] == "inner" then
            geometry.contactbltr(
                cmos, "sourcedrain",
                point.create(x - _P.sdwidth / 2, y + _P.nwidth / 2 - ncontactheight / 2 - _P.shiftncontactsinner - ncontactheight / 2),
                point.create(x + _P.sdwidth / 2, y + _P.nwidth / 2 - ncontactheight / 2 - _P.shiftncontactsinner + ncontactheight / 2)
            )
            cmos:add_anchor(string.format("nSDc%d", i), point.create(x, y + _P.nwidth / 2 - ncontactheight / 2- _P.shiftncontactsinner))
            cmos:add_anchor(string.format("nSDi%d", i), point.create(x, y + _P.nwidth / 2 - _P.shiftncontactsinner))
            cmos:add_anchor(string.format("nSDo%d", i), point.create(x, y + _P.nwidth / 2 - ncontactheight - _P.shiftncontactsinner))
        elseif _P.ncontactpos[i] == "full" or _P.ncontactpos[i] == "powerfull" then
            geometry.contactbltr(
                cmos, "sourcedrain", 
                point.create(x - _P.sdwidth / 2, y - _P.nwidth / 2),
                point.create(x + _P.sdwidth / 2, y + _P.nwidth / 2)
            )
            cmos:add_anchor(string.format("nSDc%d", i), point.create(x, y))
            cmos:add_anchor(string.format("nSDi%d", i), point.create(x, y + _P.nwidth / 2))
            cmos:add_anchor(string.format("nSDo%d", i), point.create(x, y - _P.nwidth / 2))
        end
        if _P.ncontactpos[i] == "power" or _P.ncontactpos[i] == "powerfull" then
            geometry.rectanglebltr(
                cmos, generics.metal(1), 
                point.create(x - _P.sdwidth / 2, y - _P.nwidth / 2 - _P.powerspace / 2 + _P.shiftncontactsouter - _P.powerspace / 2),
                point.create(x + _P.sdwidth / 2, y - _P.nwidth / 2 - _P.powerspace / 2 + _P.shiftncontactsouter + _P.powerspace / 2)
            )
        end
    end

    cmos:set_alignment_box(
        point.create(-fingers * (_P.gatelength + _P.gatespace) / 2, -_P.separation / 2 - _P.nwidth - _P.powerspace - _P.powerwidth / 2),
        point.create( fingers * (_P.gatelength + _P.gatespace) / 2, _P.separation / 2 + _P.pwidth + _P.powerspace + _P.powerwidth / 2)
    )
end
