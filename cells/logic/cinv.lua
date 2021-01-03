function parameters()
    pcell.inherit_all_parameters("logic/base")
    pcell.add_parameter("fingers", 1)
    pcell.add_parameter("swapinputs", false)
    pcell.add_parameter("swapoutputs", false)
    pcell.add_parameter("drawoutputs", true)
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")
    local xpitch = bp.gspace + bp.glength
    local xincr = bp.compact and 0 or 1
    local block = object.create()

    gate:merge_into(pcell.create_layout("logic/harness", { fingers = 2 * _P.fingers }))

    -- common transistor options
    pcell.push_overwrites("basic/transistor", {
        fingers = 1,
        gatelength = bp.glength,
        gatespace = bp.gspace,
        sdwidth = bp.sdwidth,
        drawinnersourcedrain = "none",
        drawoutersourcedrain = "none",
    })

    -- pmos
    pcell.push_overwrites("basic/transistor", {
        channeltype = "pmos",
        fwidth = bp.pwidth,
        gtopext = bp.powerspace + bp.dummycontheight / 2 + bp.powerwidth / 2,
        gbotext = bp.separation / 2,
        clipbot = true,
    })
    block:merge_into(pcell.create_layout("basic/transistor"):move_anchor("leftbotgate"))
    pcell.push_overwrites("basic/transistor", { drawbotgcut = true })
    block:merge_into(pcell.create_layout("basic/transistor"):move_anchor("rightbotgate"))
    pcell.pop_overwrites("basic/transistor")
    pcell.pop_overwrites("basic/transistor")

    -- nmos
    pcell.push_overwrites("basic/transistor", {
        channeltype = "nmos",
        fwidth = bp.nwidth,
        gbotext = bp.powerspace + bp.dummycontheight / 2 + bp.powerwidth / 2,
        gtopext = bp.separation / 2,
        cliptop = true,
    })
    block:merge_into(pcell.create_layout("basic/transistor"):move_anchor("lefttopgate"))
    pcell.push_overwrites("basic/transistor", { drawtopgcut = true })
    block:merge_into(pcell.create_layout("basic/transistor"):move_anchor("righttopgate"))
    pcell.pop_overwrites("basic/transistor")
    pcell.pop_overwrites("basic/transistor")

    -- gate contacts
    if _P.swapinputs then
        block:merge_into(geometry.rectangle(
            generics.contact("gate"), bp.glength, bp.gstwidth
        ):translate(-xpitch / 2, 0))
        block:merge_into(geometry.rectangle(
            generics.contact("gate"), bp.glength, bp.gstwidth
        ):translate(xpitch / 2, -bp.separation / 4 - bp.sdwidth / 4))
        block:merge_into(geometry.rectangle(
            generics.contact("gate"), bp.glength, bp.gstwidth
        ):translate(xpitch / 2, bp.separation / 4 + bp.sdwidth / 4))
        local num = 2 * _P.fingers - 1 - math.abs(_P.fingers % 2 - 1)
        local num2 = 2 * _P.fingers - 1 + math.abs(_P.fingers % 2 - 1)
        gate:merge_into(geometry.rectangle(
            generics.metal(1), num * bp.glength + (num - 1) * bp.gspace, bp.gstwidth
        ):translate(-(_P.fingers % 2) * xpitch / 2, 0))
        gate:merge_into(geometry.rectangle(
            generics.metal(1), num2 * bp.glength + (num2 - 1) * bp.gspace, bp.gstwidth
        ):translate((_P.fingers % 2) * xpitch / 2,  bp.separation / 4 + bp.sdwidth / 4))
        gate:merge_into(geometry.rectangle(
            generics.metal(1), num2 * bp.glength + (num2 - 1) * bp.gspace, bp.gstwidth
        ):translate((_P.fingers % 2) * xpitch / 2, -bp.separation / 4 - bp.sdwidth / 4))
    else
        block:merge_into(geometry.rectangle(
            generics.contact("gate"), bp.glength, bp.gstwidth
        ):translate(xpitch / 2, 0))
        block:merge_into(geometry.rectangle(
            generics.contact("gate"), bp.glength, bp.gstwidth
        ):translate(-xpitch / 2, -bp.separation / 4 - bp.sdwidth / 4))
        block:merge_into(geometry.rectangle(
            generics.contact("gate"), bp.glength, bp.gstwidth
        ):translate(-xpitch / 2, bp.separation / 4 + bp.sdwidth / 4))
        local num = 2 * _P.fingers - 1 - math.abs(_P.fingers % 2 - 1)
        local num2 = 2 * _P.fingers - 1 + math.abs(_P.fingers % 2 - 1)
        gate:merge_into(geometry.rectangle(
            generics.metal(1), num * bp.glength + (num - 1) * bp.gspace, bp.gstwidth
        ):translate(-(_P.fingers % 2) * xpitch / 2, -bp.separation / 4 - bp.sdwidth / 4))
        gate:merge_into(geometry.rectangle(
            generics.metal(1), num * bp.glength + (num - 1) * bp.gspace, bp.gstwidth
        ):translate(-(_P.fingers % 2) * xpitch / 2,  bp.separation / 4 + bp.sdwidth / 4))
        gate:merge_into(geometry.rectangle(
            generics.metal(1), num2 * bp.glength + (num2 - 1) * bp.gspace, bp.gstwidth
        ):translate((_P.fingers % 2) * xpitch / 2, 0))
    end

    -- pmos source/drain contacts
    if _P.swapoutputs then
        block:merge_into(geometry.rectangle(
            generics.contact("active"), bp.sdwidth, bp.pwidth / 2
        ):translate(xpitch, (bp.separation + bp.pwidth / 2) / 2))
        block:merge_into(geometry.rectangle(
            generics.contact("active"), bp.sdwidth, bp.pwidth / 2
        ):translate(-xpitch, bp.separation / 2 + bp.pwidth * 3 / 4))
        block:merge_into(geometry.rectangle(
            generics.metal(1), bp.sdwidth, bp.powerspace
        ):translate(-xpitch, bp.separation / 2 + bp.pwidth + bp.powerspace / 2))
        -- nmos source/drain contacts
        block:merge_into(geometry.rectangle(
            generics.contact("active"), bp.sdwidth, bp.nwidth / 2
        ):translate(xpitch, -(bp.separation + bp.nwidth / 2) / 2))
        block:merge_into(geometry.rectangle(
            generics.contact("active"), bp.sdwidth, bp.nwidth / 2
        ):translate(-xpitch, -bp.separation / 2 - bp.nwidth * 3 / 4))
        block:merge_into(geometry.rectangle(
            generics.metal(1), bp.sdwidth, bp.powerspace
        ):translate(-xpitch, -bp.separation / 2 - bp.nwidth - bp.powerspace / 2))
    else
        block:merge_into(geometry.rectangle(
            generics.contact("active"), bp.sdwidth, bp.pwidth / 2
        ):translate(-xpitch, (bp.separation + bp.pwidth / 2) / 2))
        block:merge_into(geometry.rectangle(
            generics.contact("active"), bp.sdwidth, bp.pwidth / 2
        ):translate(xpitch, bp.separation / 2 + bp.pwidth * 3 / 4))
        block:merge_into(geometry.rectangle(
            generics.metal(1), bp.sdwidth, bp.powerspace
        ):translate(xpitch, bp.separation / 2 + bp.pwidth + bp.powerspace / 2))
        -- nmos source/drain contacts
        block:merge_into(geometry.rectangle(
            generics.contact("active"), bp.sdwidth, bp.nwidth / 2
        ):translate(-xpitch, -(bp.separation + bp.nwidth / 2) / 2))
        block:merge_into(geometry.rectangle(
            generics.contact("active"), bp.sdwidth, bp.nwidth / 2
        ):translate(xpitch, -bp.separation / 2 - bp.nwidth * 3 / 4))
        block:merge_into(geometry.rectangle(
            generics.metal(1), bp.sdwidth, bp.powerspace
        ):translate(xpitch, -bp.separation / 2 - bp.nwidth - bp.powerspace / 2))
    end

    -- place block
    for i = 1, _P.fingers do
        local shift = 2 * (i - 1) - (_P.fingers - 1)
        if i % 2 == 0 then
            gate:merge_into(block:copy():flipx():translate(-shift * xpitch, 0))
        else
            gate:merge_into(block:copy():translate(-shift * xpitch, 0))
        end
    end

    -- drain connection
    if _P.drawoutputs then
        local poffset = _P.fingers % 2 == (_P.swapoutputs and 1 or 0) and (_P.fingers - 2) or _P.fingers
        gate:merge_into(geometry.path(
            generics.metal(1),
            {
                point.create(-poffset * xpitch,               (bp.separation + bp.sdwidth) / 2),
                point.create( (_P.fingers + xincr) * xpitch,  (bp.separation + bp.sdwidth) / 2),
                point.create( (_P.fingers + xincr) * xpitch, -(bp.separation + bp.sdwidth) / 2),
                point.create(-poffset * xpitch,              -(bp.separation + bp.sdwidth) / 2),
            },
            bp.sdwidth,
            true
        ))
    end

    pcell.pop_overwrites("basic/transistor")

    -- anchors
    gate:add_anchor("left", point.create(-(_P.fingers + bp.leftdummies) * xpitch, 0))
    gate:add_anchor("right", point.create((_P.fingers + bp.rightdummies) * xpitch, 0))

    -- ports
    if _P.swapinputs then
        gate:add_port("EP", generics.metal(1), point.create(xpitch / 2,  bp.separation / 4 + bp.sdwidth / 4))
        gate:add_port("EN", generics.metal(1), point.create(xpitch / 2, -bp.separation / 4 - bp.sdwidth / 4))
        gate:add_port("I", generics.metal(1), point.create(-xpitch / 2, 0))
    else
        gate:add_port("EP", generics.metal(1), point.create(-xpitch / 2,  bp.separation / 4 + bp.sdwidth / 4))
        gate:add_port("EN", generics.metal(1), point.create(-xpitch / 2, -bp.separation / 4 - bp.sdwidth / 4))
        gate:add_port("I", generics.metal(1), point.create(xpitch / 2, 0))
    end
    gate:add_port("O", generics.metal(1), point.create((_P.fingers + xincr) * xpitch, 0))
    gate:add_port("VDD", generics.metal(1), point.create(0,  bp.separation / 2 + bp.pwidth + bp.powerspace + bp.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -bp.separation / 2 - bp.nwidth - bp.powerspace - bp.powerwidth / 2))
end
