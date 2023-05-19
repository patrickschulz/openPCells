function parameters()
    pcell.add_parameters(
        { "gatelength", technology.get_dimension("Minimum Gate Length") },
        { "gatespace", technology.get_dimension("Minimum Gate XSpace") },
        { "fingerwidth", technology.get_dimension("Minimum Gate Width") },
        { "buf1fingers", 4 },
        { "buf2fingers", 2 },
        { "pfetvthtype", 3 },
        { "nfetvthtype", 1 },
        { "sdwidth", technology.get_dimension("Minimum M1 Width") },
        { "sdspace", technology.get_dimension("Minimum M1 Space") },
        { "gstrwidth", technology.get_dimension("Minimum M1 Width") },
        { "gstrspace", technology.get_dimension("Minimum M1 Space") },
        { "powerwidth", 3 * technology.get_dimension("Minimum M1 Width") },
        { "powerspace", 2 * technology.get_dimension("Minimum M1 Space") }
    )
end

function layout(buf_array, _P)
    --buffer1
    local pmosbuf1 = pcell.create_layout("basic/mosfet", "pmosbuf1", {
        channeltype = "pmos",
        flippedwell = false,
        vthtype = _P.pfetvthtype,
        drawbotgate = true,
        botgatestrwidth = _P.gstrwidth,
        botgatestrspace = _P.gstrspace,
        botgateextendhalfspace = true,
        fingers = _P.buf1fingers,
        fwidth = _P.fingerwidth,
        connectsource = true,
        connsourcemetal = 1,
        connsourcewidth = _P.powerwidth,
        connsourcespace = _P.powerspace,
            connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndraininline = true,
        extendimplantbot = _P.gstrspace / 2,
        extendvthbot = _P.gstrspace / 2,
        extendwellbot = _P.gstrspace / 2,
        gtopext = 1.5 * _P.powerspace + _P.powerwidth,
        gbotext = _P.gstrspace + _P.gstrwidth,
        })

    local nmosbuf1 = pcell.create_layout("basic/mosfet", "nmosbuf1", {
        channeltype = "nmos",
        flippedwell = true,
        vthtype = _P.nfetvthtype,
        drawtopgate = true,
        topgatestrwidth = _P.gstrwidth,
        topgatestrspace = 2 * _P.gstrspace + _P.gstrwidth,
        topgateextendhalfspace = true,
        fingers = _P.buf1fingers,
        fwidth = _P.fingerwidth,
        connectsource = true,
        connsourcemetal = 1,
        connsourcewidth = _P.powerwidth,
        connsourcespace = _P.powerspace,
            connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndraininline = true,
        extendimplanttop = - _P.gstrwidth - _P.gstrspace / 2,
        extendvthtop = - _P.gstrwidth - _P.gstrspace / 2,
        extendwelltop = - _P.gstrwidth - _P.gstrspace / 2,
        gbotext = 1.5 * _P.powerspace + _P.powerwidth,
        drawbotgcut = true,
        cutheight = _P.gstrspace,
        })

    --dummy1
    local pmosdummy1 = pcell.create_layout("basic/mosfet", "pmosdummy1", {
        channeltype = "pmos",
        flippedwell = false,
        vthtype = _P.pfetvthtype,
        fingers = 1,
        fwidth = _P.fingerwidth,
        drawtopgate = true,
        topgatestrwidth = _P.powerwidth,
        topgatestrspace = _P.powerspace,
        topgateextendhalfspace = true,
        gtopext = 1.5 * _P.powerspace + _P.powerwidth,
        gbotext = 1.5 * _P.gstrspace + _P.gstrwidth,
        drawbotgcut = true,
        cutheight = _P.gstrspace,
        })
    local nmosdummy1 = pcell.create_layout("basic/mosfet", "nmosdummy1", {
        channeltype = "nmos",
        flippedwell = true,
        vthtype = _P.nfetvthtype,
        fingers = 1,
        fwidth = _P.fingerwidth,
        drawbotgate = true,
        botgatestrwidth = _P.powerwidth,
        botgatestrspace = _P.powerspace,
        botgateextendhalfspace = true,
        gtopext = 1.5 * _P.gstrspace + _P.gstrwidth,
        gbotext = _P.powerwidth + 1.5 * _P.powerspace,
        drawbotgcut = true,
        cutheight = _P.gstrspace,
        })

    --buffer2
    local pmosbuf2 = pcell.create_layout("basic/mosfet", "pmosbuf2", {
        channeltype = "pmos",
        flippedwell = false,
        vthtype = _P.pfetvthtype,
        drawbotgate = true,
        botgatestrwidth = _P.gstrwidth,
        botgatestrspace = 2 * _P.gstrspace + _P.gstrwidth,
        topgateextendhalfspace = true,
        fingers = _P.buf2fingers,
        fwidth = _P.fingerwidth,
        connectsource = true,
        connsourcemetal = 1,
        drawsourcevia = true,
        connsourcewidth = _P.powerwidth,
        connsourcespace = _P.powerspace,
    --        connectdrain = true,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndraininline = true,
        extendimplantbot = - _P.gstrwidth - _P.gstrspace / 2,
        extendvthbot = - _P.gstrwidth - _P.gstrspace / 2,
        extendwellbot = - _P.gstrwidth - _P.gstrspace / 2,
        gtopext = 1.5 * _P.powerspace + _P.powerwidth,
        gbotext = _P.gstrspace + _P.gstrwidth,
        })

    local nmosbuf2 = pcell.create_layout("basic/mosfet", "nmosbuf2", {
        channeltype = "nmos",
        flippedwell = true,
        vthtype = _P.nfetvthtype,
        drawtopgate = true,
        topgatestrwidth = _P.gstrwidth,
        topgatestrspace = _P.gstrspace,
        topgateextendhalfspace = true,
        fingers = _P.buf2fingers,
        fwidth = _P.fingerwidth,
        connectsource = true,
        connsourcemetal = 1,
        drawsourcevia = true,
        connsourcewidth = _P.powerwidth,
        connsourcespace = _P.powerspace,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndraininline = true,
        extendimplanttop = _P.gstrspace / 2,
        extendvthtop = _P.gstrspace / 2,
        extendwelltop = _P.gstrspace / 2,
        gbotext = 1.5 * _P.powerspace + _P.powerwidth,
        drawbotgcut = true,
        cutheight = _P.gstrspace,
        })

    --dummy2
    local pmosdummy2 = pmosdummy1:copy()
    local nmosdummy2 = nmosdummy1:copy()

    --buffer3
    local pmosbuf3 = pcell.create_layout("basic/mosfet", "pmosbuf3", {
        channeltype = "pmos",
        flippedwell = false,
        vthtype = _P.pfetvthtype,
        drawbotgate = true,
        botgatestrwidth = _P.gstrwidth,
        botgatestrspace = _P.gstrspace,
        botgateextendhalfspace = true,
        fingers = _P.buf2fingers,
        fwidth = _P.fingerwidth,
        connectsource = true,
        connsourcemetal = 1,
        connsourcewidth = _P.powerwidth,
        connsourcespace = _P.powerspace,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndraininline = true,
        extendimplantbot = _P.gstrspace / 2,
        extendvthbot = _P.gstrspace / 2,
        extendwellbot = _P.gstrspace / 2,
        gtopext = 1.5 * _P.powerspace + _P.powerwidth,
        gbotext = _P.gstrspace + _P.gstrwidth,
        })

    local nmosbuf3 = pcell.create_layout("basic/mosfet", "nmosbuf3", {
        channeltype = "nmos",
        flippedwell = true,
        vthtype = _P.nfetvthtype,
        drawtopgate = true,
        topgatestrwidth = _P.gstrwidth,
        topgatestrspace = 2 * _P.gstrspace + _P.gstrwidth,
        topgateextendhalfspace = true,
        fingers = _P.buf2fingers,
        fwidth = _P.fingerwidth,
        connectsource = true,
        connsourcemetal = 1,
        connsourcewidth = _P.powerwidth,
        connsourcespace = _P.powerspace,
        conndrainmetal = 2,
        drawdrainvia = true,
        conndraininline = true,
        extendimplanttop = - _P.gstrwidth - _P.gstrspace / 2,
        extendvthtop = - _P.gstrwidth - _P.gstrspace / 2,
        extendwelltop = - _P.gstrwidth - _P.gstrspace / 2,
        gbotext = 1.5 * _P.powerspace + _P.powerwidth,
        drawbotgcut = true,
        cutheight = _P.gstrspace,
        })

    --buf4
    local pmosbuf4 = pcell.create_layout("basic/mosfet", "pmosbuf4", {
        channeltype = "pmos",
        flippedwell = false,
        vthtype = _P.pfetvthtype,
        drawbotgate = true,
        botgatestrwidth = _P.gstrwidth,
        botgatestrspace = _P.gstrspace,
        botgateextendhalfspace = true,
        fingers = _P.buf1fingers,
        fwidth = _P.fingerwidth,
        connectsource = true,
        connsourcemetal = 1,
        connsourcewidth = _P.powerwidth,
        connsourcespace = _P.powerspace,
            connectdrain = true,
        conndrainmetal = 3,
        drawdrainvia = true,
        conndraininline = true,
        extendimplantbot = _P.gstrspace / 2,
        extendvthbot = _P.gstrspace / 2,
        extendwellbot = _P.gstrspace / 2,
        gtopext = 1.5 * _P.powerspace + _P.powerwidth,
        gbotext = _P.gstrspace + _P.gstrwidth,
        })

    local nmosbuf4 = pcell.create_layout("basic/mosfet", "nmosbuf4", {
        channeltype = "nmos",
        flippedwell = true,
        vthtype = _P.nfetvthtype,
        drawtopgate = true,
        topgatestrwidth = _P.gstrwidth,
        topgatestrspace = 2 * _P.gstrspace + _P.gstrwidth,
        topgateextendhalfspace = true,
        fingers = _P.buf1fingers,
        fwidth = _P.fingerwidth,
        connectsource = true,
        connsourcemetal = 1,
        connsourcewidth = _P.powerwidth,
        connsourcespace = _P.powerspace,
            connectdrain = true,
        conndrainmetal = 3,
        drawdrainvia = true,
        conndraininline = true,
        extendimplanttop = - _P.gstrwidth - _P.gstrspace / 2,
        extendvthtop = - _P.gstrwidth - _P.gstrspace / 2,
        extendwelltop = - _P.gstrwidth - _P.gstrspace / 2,
        gbotext = 1.5 * _P.powerspace + _P.powerwidth,
        drawbotgcut = true,
        cutheight = _P.gstrspace,
        })



    --dummy3
    local pmosdummy3 = pmosdummy1:copy()
    local nmosdummy3 = nmosdummy1:copy()

    --buf5
    local pmosbuf5 = pmosbuf2:copy()
    local nmosbuf5 = nmosbuf2:copy()

    --dummy4
    local pmosdummy4 = pmosdummy1:copy()
    local nmosdummy4 = nmosdummy1:copy()

    --buf6
    local pmosbuf6 = pmosbuf3:copy()
    local nmosbuf6 = nmosbuf3:copy()

    nmosbuf1:move_anchor("topgatestrapcc", pmosbuf1:get_anchor("botgatestrapcc"))
    pmosdummy1:move_anchor("sourcedrainleftcc", pmosbuf1:get_anchor("sourcedrainrightcc"))
    nmosdummy1:move_anchor("sourcedrainleftcc", nmosbuf1:get_anchor("sourcedrainrightcc"))
    pmosbuf2:move_anchor("sourcedrainleftcc", pmosdummy1:get_anchor("sourcedrainrightcc"))
    nmosbuf2:move_anchor("topgatestrapcc", pmosbuf2:get_anchor("botgatestrapcc"))
    pmosdummy2:move_anchor("sourcedrainleftcc", pmosbuf2:get_anchor("sourcedrainrightcc"))
    nmosdummy2:move_anchor("sourcedrainleftcc", nmosbuf2:get_anchor("sourcedrainrightcc"))
    pmosbuf3:move_anchor("sourcedrainleftcc", pmosdummy2:get_anchor("sourcedrainrightcc"))
    nmosbuf3:move_anchor("topgatestrapcc", pmosbuf3:get_anchor("botgatestrapcc"))

    pmosbuf4:move_anchor("sourcestrapcc", nmosbuf1:get_anchor("sourcestrapcc"):translate( 0, -_P.powerspace - _P.powerwidth))
    nmosbuf4:move_anchor("topgatestrapcc", pmosbuf4:get_anchor("botgatestrapcc"))
    pmosdummy3:move_anchor("sourcedrainleftcc", pmosbuf4:get_anchor("sourcedrainrightcc"))
    nmosdummy3:move_anchor("sourcedrainleftcc", nmosbuf4:get_anchor("sourcedrainrightcc"))
    pmosbuf5:move_anchor("sourcedrainleftcc", pmosdummy3:get_anchor("sourcedrainrightcc"))
    nmosbuf5:move_anchor("topgatestrapcc", pmosbuf5:get_anchor("botgatestrapcc"))
    pmosdummy4:move_anchor("sourcedrainleftcc", pmosbuf5:get_anchor("sourcedrainrightcc"))
    nmosdummy4:move_anchor("sourcedrainleftcc", nmosbuf5:get_anchor("sourcedrainrightcc"))
    pmosbuf6:move_anchor("sourcedrainleftcc", pmosdummy4:get_anchor("sourcedrainrightcc"))
    nmosbuf6:move_anchor("topgatestrapcc", pmosbuf6:get_anchor("botgatestrapcc"))

    --sample and anchor
    geometry.viabltr(buf_array, 1, 2,
        pmosbuf1:get_anchor("botgatestrapbl"),
        pmosbuf1:get_anchor("botgatestraptc")
        )
    geometry.viabltr(buf_array, 1, 2,
        pmosbuf4:get_anchor("botgatestrapbl"),
        pmosbuf4:get_anchor("botgatestraptc")
        )
    geometry.path_cshape(buf_array, generics.metal(2),
        pmosbuf1:get_anchor("botgatestrapcl"),
        pmosbuf4:get_anchor("botgatestrapcl"),
        pmosbuf1:get_anchor("botgatestrapcl"):translate( -3 * _P.sdwidth, 0),
        _P.sdwidth)
    buf_array:add_anchor_area_bltr("sample",
        pmosbuf1:get_anchor("botgatestrapbl"),
        pmosbuf1:get_anchor("botgatestraptc")
    )

    --connect buf1 2 3 4 5 6 drain
    geometry.path(buf_array, generics.metal(2),{
        pmosbuf1:get_anchor("sourcedrain4cc"),
        nmosbuf1:get_anchor("sourcedrain4cc")
        }, _P.sdwidth)
    geometry.path(buf_array, generics.metal(2),{
        pmosbuf2:get_anchor("sourcedrain2cc"),
        nmosbuf2:get_anchor("sourcedrain2cc")
        }, _P.sdwidth)
    geometry.path(buf_array, generics.metal(2),{
        pmosbuf3:get_anchor("sourcedrain2cc"),
        nmosbuf3:get_anchor("sourcedrain2cc")
        }, _P.sdwidth)
    geometry.path(buf_array, generics.metal(3),{
        pmosbuf4:get_anchor("sourcedrain4cc"),
        nmosbuf4:get_anchor("sourcedrain4cc")
        }, _P.sdwidth)
    geometry.path(buf_array, generics.metal(2),{
        pmosbuf5:get_anchor("sourcedrain2cc"),
        nmosbuf5:get_anchor("sourcedrain2cc")
        }, _P.sdwidth)
    geometry.path(buf_array, generics.metal(2),{
        pmosbuf6:get_anchor("sourcedrain2cc"),
        nmosbuf6:get_anchor("sourcedrain2cc")
        }, _P.sdwidth)

    --connect buf 1 2 5
    geometry.viabltr(buf_array, 1, 2,
        point.combine_12(pmosbuf1:get_anchor("sourcedrain4cc"),nmosbuf2:get_anchor("topgatestrapbc")),
        nmosbuf2:get_anchor("topgatestraptl")
        )
    geometry.path(buf_array, generics.metal(2),{
        point.combine_12(pmosdummy1:get_anchor("topgatestrapcc"),nmosbuf2:get_anchor("topgatestrapcc")),
        point.combine_12(pmosdummy3:get_anchor("topgatestrapcc"),nmosbuf5:get_anchor("topgatestrapbc"))
        }, _P.sdwidth)
    geometry.viabltr(buf_array, 1, 2,
        point.combine_12(pmosdummy3:get_anchor("topgatestrapcc"),nmosbuf5:get_anchor("topgatestrapbc")),
        nmosbuf5:get_anchor("topgatestraptl")
        )
    --connect buf 3 4 6
    geometry.viabltr(buf_array, 1, 3,
        point.combine_12(pmosdummy2:get_anchor("topgatestrapcl"),nmosbuf3:get_anchor("topgatestrapbc")),
        nmosbuf3:get_anchor("topgatestraptl")
        )
    geometry.viabltr(buf_array, 1, 3,
        point.combine_12(pmosdummy2:get_anchor("topgatestrapcl"),nmosbuf6:get_anchor("topgatestrapbc")),
        nmosbuf6:get_anchor("topgatestraptl")
        )
    geometry.path(buf_array, generics.metal(3),{
        point.combine_12(pmosdummy2:get_anchor("topgatestrapcl"),nmosbuf3:get_anchor("topgatestraptc")),
        point.combine_12(pmosdummy2:get_anchor("topgatestrapcl"),nmosbuf6:get_anchor("topgatestrapbc"))
        }, _P.sdwidth)
    geometry.path(buf_array, generics.metal(3),{
        point.combine_12(pmosbuf4:get_anchor("sourcedrain4cc"),nmosbuf6:get_anchor("topgatestrapcc")),
        point.combine_12(pmosdummy2:get_anchor("topgatestrapcl"),nmosbuf6:get_anchor("topgatestrapcc"))
        }, _P.sdwidth)


    --sample out and anchor
    geometry.path(buf_array, generics.metal(2),{
        pmosbuf2:get_anchor("sourcedrain2tc"),
        pmosbuf2:get_anchor("sourcestraptc"):translate(0, _P.sdspace)
        }, _P.sdwidth)
    buf_array:add_anchor_area_bltr("out1",
        pmosbuf2:get_anchor("sourcedrain2tl"),
        pmosbuf2:get_anchor("sourcestraptc"):translate(0.5 * _P.sdwidth , _P.sdspace)
    )

    geometry.path(buf_array, generics.metal(2),{
        nmosbuf3:get_anchor("sourcedrain2bc"),
        nmosbuf3:get_anchor("sourcestrapbc"):translate(0, - _P.sdspace)
        }, _P.sdwidth)
    buf_array:add_anchor_area_bltr("out2",
        nmosbuf3:get_anchor("sourcestrapbc"):translate( - 0.5 * _P.sdwidth, - _P.sdspace),
        nmosbuf3:get_anchor("sourcedrain2br")
    )

    geometry.path(buf_array, generics.metal(2),{
        nmosbuf5:get_anchor("sourcedrain2bc"),
        nmosbuf5:get_anchor("sourcestrapbc"):translate(0, - _P.sdspace)
        }, _P.sdwidth)
    buf_array:add_anchor_area_bltr("out3",
        nmosbuf5:get_anchor("sourcestrapbc"):translate(- 0.5 * _P.sdwidth, - _P.sdspace),
        nmosbuf5:get_anchor("sourcedrain2br")
    )

    geometry.path(buf_array, generics.metal(2),{
        pmosbuf6:get_anchor("sourcedrain2tc"),
        pmosbuf6:get_anchor("sourcestraptc"):translate(0, _P.sdspace)
        }, _P.sdwidth)
    buf_array:add_anchor_area_bltr("out4",
        pmosbuf6:get_anchor("sourcedrain2tl"),
        pmosbuf6:get_anchor("sourcestraptc"):translate(0.5 * _P.sdwidth, _P.sdspace)
    )

    buf_array:merge_into_shallow(nmosbuf1:flatten())
    buf_array:merge_into_shallow(pmosbuf1:flatten())
    buf_array:merge_into_shallow(pmosdummy1:flatten())
    buf_array:merge_into_shallow(nmosdummy1:flatten())
    buf_array:merge_into_shallow(nmosbuf2:flatten())
    buf_array:merge_into_shallow(pmosbuf2:flatten())
    buf_array:merge_into_shallow(pmosdummy2:flatten())
    buf_array:merge_into_shallow(nmosdummy2:flatten())
    buf_array:merge_into_shallow(nmosbuf3:flatten())
    buf_array:merge_into_shallow(pmosbuf3:flatten())


    buf_array:merge_into_shallow(pmosbuf4:flatten())
    buf_array:merge_into_shallow(nmosbuf4:flatten())
    buf_array:merge_into_shallow(pmosdummy3:flatten())
    buf_array:merge_into_shallow(nmosdummy3:flatten())
    buf_array:merge_into_shallow(nmosbuf5:flatten())
    buf_array:merge_into_shallow(pmosbuf5:flatten())
    buf_array:merge_into_shallow(pmosdummy4:flatten())
    buf_array:merge_into_shallow(nmosdummy4:flatten())
    buf_array:merge_into_shallow(nmosbuf6:flatten())
    buf_array:merge_into_shallow(pmosbuf6:flatten())

    -- add anchors and alignment box
    buf_array:add_anchor_area_bltr("VDD1",
        pmosbuf1:get_anchor("sourcestrapbl"),
        pmosbuf3:get_anchor("sourcestraptr")
    )
    buf_array:add_anchor_area_bltr("VDD2",
        pmosbuf4:get_anchor("sourcestrapbl"),
        pmosbuf6:get_anchor("sourcestraptr")
    )
    buf_array:add_anchor_area_bltr("VSS1",
        nmosbuf1:get_anchor("sourcestrapbl"),
        nmosbuf3:get_anchor("sourcestraptr")
    )
    buf_array:add_anchor_area_bltr("VSS2",
        nmosbuf4:get_anchor("sourcestrapbl"),
        nmosbuf6:get_anchor("sourcestraptr")
    )

    buf_array:set_alignment_box(
        nmosbuf4:get_anchor("sourcestrapbl"):translate(- 0.5 * _P.gatespace + 0.5 * _P.sdwidth - 10, - 0.5 * _P.powerspace),
        pmosbuf3:get_anchor("sourcestraptr"):translate( 0.5 * _P.gatespace - 0.5 * _P.sdwidth + 10, 0.5 * _P.powerspace)
    )
end
