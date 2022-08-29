function parameters()
    pcell.add_parameters(
        { "fingers", 2 },
        { "pwidth", 2 * tech.get_dimension("Minimum Gate Width") },
        { "nwidth", 2 * tech.get_dimension("Minimum Gate Width") },
        { "gstwidth", tech.get_dimension("Minimum M1 Width") },
        { "gstspace", tech.get_dimension("Minimum M1 Space") },
        { "sdwidth", tech.get_dimension("Minimum M1 Width") },
        { "powerspace", tech.get_dimension("Minimum M1 Space") },
        { "nmosflippedwell", false },
        { "pmosflippedwell", false },
        { "guardringwidth", tech.get_dimension("Minimum M1 Width") },
        { "nmosvthtype", 1 },
        { "pmosvthtype", 1 }
    )
    pcell.reference_cell("basic/mosfet")
end

function layout(tgate, _P)
    pcell.push_overwrites("basic/mosfet", {
        fingers = _P.fingers,
        connectsource = true,
        connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        drawguardring = true,
        guardringwidth = _P.guardringwidth,
        guardringxsep = 500,
        guardringysep = 500,
    })
    local pmos = pcell.create_layout("basic/mosfet", {
        channeltype = "pmos",
        fingers = _P.fingers,
        fwidth = _P.pwidth,
        vthtype = _P.pmosvthtype,
        flippedwell = _P.pmosflippedwell,
        drawtopgate = true,
    })
    local nmos = pcell.create_layout("basic/mosfet", {
        channeltype = "nmos",
        fingers = _P.fingers,
        fwidth = _P.nwidth,
        vthtype = _P.nmosvthtype,
        flippedwell = _P.nmosflippedwell,
        drawbotgate = true,
    })
    pcell.pop_overwrites("basic/mosfet")
    pmos:move_anchor_y("bottom")
    pmos:translate(0, _P.guardringwidth / 2 + _P.powerspace / 2)
    nmos:move_anchor_y("top")
    nmos:translate(0, -_P.guardringwidth / 2 - _P.powerspace / 2)
    tgate:merge_into_shallow(pmos)
    tgate:merge_into_shallow(nmos)

    geometry.rectanglebltr(tgate, generics.metal(1), nmos:get_anchor("guardringtl"), pmos:get_anchor("guardringbr"))

    tgate:inherit_alignment_box(pmos)
    tgate:inherit_alignment_box(nmos)

    --[[
    local cmos = pcell.create_layout("basic/cmos", {
        separation = 3 * _P.gstwidth + 5 * _P.gstspace,
        pwidth = _P.pwidth,
        nwidth = _P.nwidth,
        nvthtype = _P.nmosvthtype,
        pvthtype = _P.pmosvthtype,
        nmosflippedwell = _P.nmosflippedwell,
        pmosflippedwell = _P.pmosflippedwell,
        drawnmoswelltap = true,
        drawpmoswelltap = true,
        nmoswelltapwidth = _P.welltapwidth,
        pmoswelltapwidth = _P.welltapwidth,
        nmoswelltapspace = _P.powerspace,
        pmoswelltapspace = _P.powerspace,
        gatecontactpos = util.fill_all_with(_P.fingers, "split"),
        ncontactpos = util.fill_odd_with(_P.fingers + 1, "inner", "power"),
        pcontactpos = util.fill_odd_with(_P.fingers + 1, "inner", "power"),
        gstwidth = _P.gstwidth,
        gstspace = _P.gstspace,
        gatecontactsplitshift = _P.gstwidth + _P.gstspace,
        separation = 3 * _P.gstspace + 2 * _P.gstwidth,
        powerwidth = _P.sdwidth,
        npowerspace = _P.powerspace,
        ppowerspace = _P.powerspace,
    })
    tgate:merge_into_shallow(cmos)
    geometry.rectanglebltr(tgate, generics.metal(1),
        cmos:get_anchor(string.format("Glower%dll", 1)),
        cmos:get_anchor(string.format("Glower%dur", _P.fingers))
    )
    geometry.rectanglebltr(tgate, generics.metal(1),
        cmos:get_anchor(string.format("Gupper%dll", 1)),
        cmos:get_anchor(string.format("Gupper%dur", _P.fingers))
    )
    geometry.path(tgate, generics.metal(1), {
        cmos:get_anchor(string.format("nSDi%d", 1)):translate(0, -_P.sdwidth / 2),
        cmos:get_anchor(string.format("nSDi%d", _P.fingers + 1)):translate(0, -_P.sdwidth / 2)
    }, _P.sdwidth)
    geometry.path(tgate, generics.metal(1), {
        cmos:get_anchor(string.format("pSDi%d", 1)):translate(0, _P.sdwidth / 2),
        cmos:get_anchor(string.format("pSDi%d", _P.fingers + 1)):translate(0, _P.sdwidth / 2)
    }, _P.sdwidth)
    geometry.cshape(tgate, generics.metal(1),
        cmos:get_anchor("PRpcl"),
        cmos:get_anchor("PRncl"),
        -200,
        _P.sdwidth
    )
    geometry.cshape(tgate, generics.metal(1),
        cmos:get_anchor(string.format("pSDi%d", _P.fingers + 1)):translate(0,  _P.sdwidth / 2),
        cmos:get_anchor(string.format("nSDi%d", _P.fingers + 1)):translate(0, -_P.sdwidth / 2),
        200,
        _P.sdwidth
    )

    -- add additional rails
    geometry.rectanglebltr(tgate, generics.metal(1),
        cmos:get_anchor("PRpll"):translate(0, _P.sdwidth + 2 * _P.powerspace + _P.welltapwidth),
        cmos:get_anchor("PRpur"):translate(0, _P.sdwidth + 2 * _P.powerspace + _P.welltapwidth)
    )
    geometry.rectanglebltr(tgate, generics.metal(1),
        cmos:get_anchor("PRnll"):translate(0, -_P.sdwidth - 2 * _P.powerspace - _P.welltapwidth),
        cmos:get_anchor("PRnur"):translate(0, -_P.sdwidth - 2 * _P.powerspace - _P.welltapwidth)
    )

    tgate:set_alignment_box(
        cmos:get_anchor("PRpur"):translate(0,  2 * _P.powerspace + _P.welltapwidth + _P.sdwidth / 2),
        cmos:get_anchor("PRnll"):translate(0, -2 * _P.powerspace - _P.welltapwidth - _P.sdwidth / 2)
    )

    tgate:add_anchor_area_bltr("clkp", cmos:get_anchor("Glower1ll"), cmos:get_anchor(string.format("Glower%dur", _P.fingers)))
    tgate:add_anchor_area_bltr("clkn", cmos:get_anchor("Gupper1ll"), cmos:get_anchor(string.format("Gupper%dur", _P.fingers)))
    tgate:add_port("input", generics.metalport(1), (cmos:get_anchor("PRpcl") + cmos:get_anchor("PRncl")):translate(-200, 0))
    tgate:add_port("output", generics.metalport(1), (cmos:get_anchor(string.format("pSDi%d", _P.fingers + 1)) + cmos:get_anchor(string.format("nSDi%d", _P.fingers + 1))):translate(200, 0))
    --]]
end
