function parameters()
    pcell.add_parameters(
        { "glength", technology.get_dimension("Minimum Gate Length") },
        { "gspace", technology.get_dimension("Minimum Gate Space") },
        { "fingers", 2 },
        { "pwidth", 2 * technology.get_dimension("Minimum Gate Width") },
        { "nwidth", 2 * technology.get_dimension("Minimum Gate Width") },
        { "gstwidth", technology.get_dimension("Minimum M1 Width") },
        { "gstspace", technology.get_dimension("Minimum M1 Space") },
        { "sdwidth", technology.get_dimension("Minimum M1 Width") },
        { "powerspace", technology.get_dimension("Minimum M1 Space") },
        { "nmosflippedwell", false },
        { "pmosflippedwell", false },
        { "guardringwidth", technology.get_dimension("Minimum M1 Width") },
        { "nmosvthtype", 1 },
        { "pmosvthtype", 1 }
    )
end

function layout(tgate, _P)
    local guardringxsep = 200
    local guardringysep = 200
    pcell.push_overwrites("basic/mosfet", {
        gatelength = _P.glength,
        gatespace = _P.gspace,
        fingers = _P.fingers,
        sdwidth = _P.sdwidth,
        conndrainwidth = _P.sdwidth,
        connsourcewidth = _P.sdwidth,
        connectsource = true,
        connectdrain = true,
        conndrainspace = _P.sdwidth + _P.sdwidth + guardringysep + _P.guardringwidth + _P.powerspace,
        conndrainmetal = 2,
        drawdrainvia = true,
        drawguardring = true,
        guardringwidth = _P.guardringwidth,
        guardringxsep = guardringxsep,
        guardringysep = guardringysep,
        guardringsegments = { "top", "bottom" },
        drawtopgate = true,
        drawbotgate = true,
        topgatestrwidth = _P.sdwidth,
        topgatestrspace = _P.sdwidth,
        botgatestrwidth = _P.sdwidth,
        botgatestrspace = _P.sdwidth,
    })
    local pmos = pcell.create_layout("basic/mosfet", "pmos", {
        channeltype = "pmos",
        fingers = _P.fingers,
        fwidth = _P.pwidth,
        vthtype = _P.pmosvthtype,
        flippedwell = _P.pmosflippedwell,
        botgatecompsd = false,
    })
    local nmos = pcell.create_layout("basic/mosfet", "nmos", {
        channeltype = "nmos",
        fingers = _P.fingers,
        fwidth = _P.nwidth,
        vthtype = _P.nmosvthtype,
        flippedwell = _P.nmosflippedwell,
        topgatecompsd = false,
    })
    pcell.pop_overwrites("basic/mosfet")
    pmos:move_anchor_y("bottom")
    pmos:translate(0, _P.sdwidth / 2 + _P.guardringwidth / 2 + _P.powerspace)
    nmos:move_anchor_y("top")
    nmos:translate(0, -_P.sdwidth / 2 - _P.guardringwidth / 2 - _P.powerspace)
    tgate:merge_into(pmos)
    tgate:merge_into(nmos)

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

    -- connect top and bottom gate strap
    geometry.cshape(tgate, generics.metal(1),
        nmos:get_anchor("botgatestrapcr"),
        nmos:get_anchor("topgatestrapcr"),
        2 * (_P.glength + _P.gspace),
        _P.sdwidth
    )
    geometry.cshape(tgate, generics.metal(1),
        pmos:get_anchor("botgatestrapcr"),
        pmos:get_anchor("topgatestrapcr"),
        2 * (_P.glength + _P.gspace),
        _P.sdwidth
    )

    -- input connection
    local inputconnoffset = 500
    geometry.cshape(tgate, generics.metal(1),
        nmos:get_anchor("sourcestrapcl"),
        pmos:get_anchor("sourcestrapcl"),
        -inputconnoffset,
        _P.sdwidth
    )

    -- alignmentbox
    tgate:set_alignment_box(
        nmos:get_anchor("guardringbl"):translate(0, -_P.powerspace - _P.sdwidth / 2),
        pmos:get_anchor("guardringtr"):translate(0, _P.powerspace + _P.sdwidth / 2)
    )

    tgate:add_area_anchor_bltr("clkp", pmos:get_anchor("topgatestrapbl"), pmos:get_anchor("topgatestraptr"))
    tgate:add_area_anchor_bltr("clkn", nmos:get_anchor("botgatestrapbl"), nmos:get_anchor("botgatestraptr"))
    tgate:add_port("input", generics.metalport(1), (pmos:get_anchor("sourcestrapcl") + nmos:get_anchor("sourcestrapcl")):translate(-inputconnoffset, 0))
    tgate:add_port("output", generics.metalport(1), (pmos:get_anchor("drainstrapcc") + nmos:get_anchor("drainstrapcc")))
end
