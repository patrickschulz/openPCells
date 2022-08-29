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
    local guardringxsep = 200
    local guardringysep = 200
    pcell.push_overwrites("basic/mosfet", {
        fingers = _P.fingers,
        sdwidth = _P.sdwidth,
        conndrainwidth = _P.sdwidth,
        connsourcewidth = _P.sdwidth,
        connectsource = true,
        connectdrain = true,
        conndrainspace = guardringysep + _P.guardringwidth + _P.powerspace,
        conndrainmetal = 2,
        drawdrainvia = true,
        drawguardring = true,
        guardringwidth = _P.guardringwidth,
        guardringxsep = guardringxsep,
        guardringysep = guardringysep,
        topgatestrwidth = _P.sdwidth,
        topgatestrspace = _P.sdwidth,
        botgatestrwidth = _P.sdwidth,
        botgatestrspace = _P.sdwidth,
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
    pmos:translate(0, _P.sdwidth / 2 + _P.guardringwidth / 2 + _P.powerspace)
    nmos:move_anchor_y("top")
    nmos:translate(0, -_P.sdwidth / 2 - _P.guardringwidth / 2 - _P.powerspace)
    tgate:merge_into_shallow(pmos)
    tgate:merge_into_shallow(nmos)

    -- additional rails between guard rings
    geometry.rectanglebltr(tgate, generics.metal(1),
        nmos:get_anchor("guardringtl") .. point.create(0, -_P.sdwidth / 2),
        pmos:get_anchor("guardringbr") .. point.create(0,  _P.sdwidth / 2)
    )
    geometry.rectanglebltr(tgate, generics.metal(1),
        pmos:get_anchor("guardringtl"):translate(0, _P.powerspace),
        pmos:get_anchor("guardringtr"):translate(0, _P.powerspace + _P.sdwidth)
    )
    geometry.rectanglebltr(tgate, generics.metal(1),
        nmos:get_anchor("guardringbl"):translate(0, -_P.powerspace - _P.sdwidth),
        nmos:get_anchor("guardringbr"):translate(0, -_P.powerspace)
    )

    -- input connection
    geometry.cshape(tgate, generics.metal(1),
        nmos:get_anchor("sourcestrapcl"),
        pmos:get_anchor("sourcestrapcl"),
        -200,
        _P.sdwidth
    )

    -- alignmentbox
    tgate:set_alignment_box(
        nmos:get_anchor("guardringbl"):translate(0, -_P.powerspace - _P.sdwidth / 2),
        pmos:get_anchor("guardringtr"):translate(0, _P.powerspace + _P.sdwidth / 2)
    )

    tgate:add_anchor_area_bltr("clkp", pmos:get_anchor("topgatestrapbl"), pmos:get_anchor("topgatestraptr"))
    tgate:add_anchor_area_bltr("clkn", nmos:get_anchor("botgatestrapbl"), nmos:get_anchor("botgatestraptr"))
    tgate:add_port("input", generics.metalport(1), (pmos:get_anchor("sourcestrapcl") + nmos:get_anchor("sourcestrapcl")):translate(-200, 0))
    tgate:add_port("output", generics.metalport(1), (pmos:get_anchor("drainstrapcr") + nmos:get_anchor("drainstrapcr")):translate(200, 0))
end
