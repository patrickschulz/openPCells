function config()
    pcell.reference_cell("basic/mosfet")
    pcell.reference_cell("logic/base")
    pcell.set_property("hidden", true)
end

function parameters()

end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")
    local xpitch = bp.gspace + bp.glength

    pcell.push_overwrites("logic/base", { leftdummies = 0, rightdummies = 0 })
    gate:merge_into(pcell.create_layout("logic/harness", { fingers = 1 }))
    pcell.pop_overwrites("logic/base")

    -- common transistor options
    pcell.push_overwrites("basic/mosfet", {
        fingers = 1,
        gatelength = bp.glength,
        gatespace = bp.gspace,
        sdwidth = bp.sdwidth,
        drawinnersourcedrain = "none",
        drawoutersourcedrain = "none",
    })

    -- pfet
    local pmos = pcell.create_layout("basic/mosfet",
        {
            channeltype = "pmos",
            fwidth = bp.pwidth,
            gtopext = bp.powerspace + bp.dummycontheight / 2 + bp.powerwidth / 2,
            gbotext = bp.separation / 2,
            drawtopgate = true,
            drawbotgcut = true,
            topgatestrwidth = bp.dummycontheight,
            topgatestrspace = bp.powerspace + bp.powerwidth / 2 - bp.dummycontheight / 2,
            clipbot = true,
        }
    ):move_anchor("botgate")
    gate:merge_into(pmos)

    -- nfet
    local nmos = pcell.create_layout("basic/mosfet",
        {
            channeltype = "nmos",
            fwidth = bp.nwidth,
            gbotext = bp.powerspace + bp.dummycontheight / 2 + bp.powerwidth / 2,
            drawbotgate = true,
            drawtopgcut = true,
            botgatestrwidth = bp.dummycontheight,
            botgatestrspace = bp.powerspace + bp.powerwidth / 2 - bp.dummycontheight / 2,
            gtopext = bp.separation / 2,
            cliptop = true,
        }
    ):move_anchor("topgate")
    gate:merge_into(nmos)

    pcell.pop_overwrites("basic/mosfet")

    gate:set_alignment_box(
        point.create(-xpitch / 2, -bp.separation / 2 - bp.nwidth - bp.powerspace - bp.powerwidth / 2),
        point.create(xpitch / 2, bp.separation / 2 + bp.pwidth + bp.powerspace + bp.powerwidth / 2)
    )
end
