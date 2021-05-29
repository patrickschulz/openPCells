function config()
    pcell.reference_cell("basic/mosfet")
    pcell.reference_cell("logic/base")
    pcell.set_property("hidden", true)
end

function parameters()
    pcell.add_parameters(
        { "fingers", 1 },
        { "drawgatecontacts", true },
        { "gatecontactpos", { }, argtype = "strtable" },
        { "shiftgatecontacts", 0 },
        { "pcontactpos", {}, argtype = "strtable" },
        { "ncontactpos", {}, argtype = "strtable" },
        { "shiftpcontactsinner", 0 },
        { "shiftpcontactsouter", 0 },
        { "shiftncontactsinner", 0 },
        { "shiftncontactsouter", 0 },
        { "drawdummygatecontacts", true },
        { "drawdummyactivecontacts", true }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")
    local xpitch = bp.gspace + bp.glength
    local xshift = (bp.rightdummies - bp.leftdummies) * xpitch / 2
    local separation = bp.numinnerroutes * bp.gstwidth + (bp.numinnerroutes + 1) * bp.gstspace
    local fingers = _P.fingers + bp.leftdummies + bp.rightdummies

    -- common transistor options
    pcell.push_overwrites("basic/mosfet", {
        gatelength = bp.glength,
        gatespace = bp.gspace,
        sdwidth = bp.sdwidth,
        drawinnersourcedrain = "none",
        drawoutersourcedrain = "none"
    })

    -- pmos
    pcell.push_overwrites("basic/mosfet", {
        channeltype = "pmos",
        vthtype = bp.pvthtype,
        fwidth = bp.pwidth,
        gbotext = separation / 2,
        gtopext = bp.powerspace + bp.powerwidth / 2,
        clipbot = true,
        drawtopgcut = true
    })
    -- main
    local pmos
    if _P.fingers > 0 then
        pmos = pcell.create_layout("basic/mosfet", { fingers = _P.fingers }):move_anchor("botgate")
        gate:merge_into(pmos)
    else
        pmos = object.create_omni()
    end
    -- left dummy
    if bp.leftdummies > 0 then
        gate:merge_into(
            pcell.create_layout("basic/mosfet", { fingers = bp.leftdummies, drawbotgcut = true }
        ):move_anchor("rightbotgate", pmos:get_anchor("leftbotgate")))
    end
    -- rightdummy
    if bp.rightdummies > 0 then
        gate:merge_into(
            pcell.create_layout("basic/mosfet", { fingers = bp.rightdummies, drawbotgcut = true }
        ):move_anchor("leftbotgate", pmos:get_anchor("rightbotgate")))
    end
    pcell.pop_overwrites("basic/mosfet")

    -- nmos
    pcell.push_overwrites("basic/mosfet", {
        channeltype = "nmos",
        vthtype = bp.nvthtype,
        fwidth = bp.nwidth,
        gtopext = separation / 2,
        gbotext = bp.powerspace + bp.powerwidth / 2,
        cliptop = true,
        drawbotgcut = true,
    })
    local nmos
    -- main
    if _P.fingers > 0 then
        nmos = pcell.create_layout("basic/mosfet", { fingers = _P.fingers }):move_anchor("topgate")
        gate:merge_into(nmos)
    else
        nmos = object.create_omni()
    end
    -- left dummy
    if bp.leftdummies > 0 then
        gate:merge_into(
            pcell.create_layout("basic/mosfet", { fingers = bp.leftdummies, drawtopgcut = true }
        ):move_anchor("righttopgate", nmos:get_anchor("lefttopgate")))
    end
    -- rightdummy
    if bp.rightdummies > 0 then
        gate:merge_into(
            pcell.create_layout("basic/mosfet", { fingers = bp.rightdummies, drawtopgcut = true }
        ):move_anchor("lefttopgate", nmos:get_anchor("righttopgate")))
    end
    pcell.pop_overwrites("basic/mosfet")

    -- power rails
    gate:merge_into(geometry.multiple_y(
        geometry.rectangle(generics.metal(1), (_P.fingers + bp.leftdummies + bp.rightdummies) * xpitch + bp.sdwidth, bp.powerwidth),
        2, separation + bp.pwidth + bp.nwidth + 2 * bp.powerspace + bp.powerwidth
    ):translate(xshift, (bp.pwidth - bp.nwidth) / 2))

    -- draw gate contacts
    if _P.drawgatecontacts then
        for i = 1, _P.fingers do
            local x = (2 * i - _P.fingers - 1 + bp.leftdummies - bp.rightdummies) * xpitch / 2 + xshift
            local routingshift = (bp.gstwidth + bp.gstspace) / (bp.numinnerroutes % 2 == 0 and 2 or 1)
            if _P.gatecontactpos[i] == "center" then
                local pt = point.create(x, _P.shiftgatecontacts)
                gate:merge_into(geometry.rectangle(
                    generics.contact("gate"), bp.glength, bp.gstwidth
                ):translate(pt))
                gate:add_anchor(string.format("G%d", i), pt)
            elseif _P.gatecontactpos[i] == "upper" then
                local pt = point.create(x, routingshift + _P.shiftgatecontacts)
                gate:merge_into(geometry.rectangle(
                    generics.contact("gate"), bp.glength, bp.gstwidth
                ):translate(pt))
                gate:add_anchor(string.format("G%d", i), pt)
            elseif _P.gatecontactpos[i] == "lower" then
                local pt = point.create(x, -routingshift + _P.shiftgatecontacts)
                gate:merge_into(geometry.rectangle(
                    generics.contact("gate"), bp.glength, bp.gstwidth
                ):translate(pt))
                gate:add_anchor(string.format("G%d", i), pt)
            elseif _P.gatecontactpos[i] == "split" then
                local x = (2 * i - _P.fingers - 1 + bp.leftdummies - bp.rightdummies) * xpitch / 2 + xshift
                local y = _P.shiftgatecontacts
                gate:merge_into(geometry.multiple_y(
                    geometry.rectangle(generics.contact("gate"), bp.glength, bp.gstwidth),
                    2, 2 * routingshift
                ):translate(x, y))
                gate:add_anchor(string.format("G%d", i), point.create(x, y))
                gate:add_anchor(string.format("G%dupper", i), point.create(x, y + routingshift))
                gate:add_anchor(string.format("G%dlower", i), point.create(x, y - routingshift))
                -- FIXME: simplify gate cut drawing
                pcell.push_overwrites("basic/mosfet", {
                    channeltype = "pmos",
                    vthtype = bp.pvthtype,
                    fwidth = bp.pwidth,
                    gbotext = separation / 2,
                    gtopext = bp.powerspace + bp.powerwidth / 2,
                    clipbot = true,
                })
                gate:merge_into(pcell.create_layout("basic/mosfet", { fingers = 1, drawbotgcut = true }):move_anchor("botgate", point.create(x, 0)))
                pcell.pop_overwrites("basic/mosfet")
                pcell.push_overwrites("basic/mosfet", {
                    channeltype = "nmos",
                    vthtype = bp.nvthtype,
                    fwidth = bp.nwidth,
                    gtopext = separation / 2,
                    gbotext = bp.powerspace + bp.powerwidth / 2,
                    cliptop = true,
                })
                gate:merge_into(pcell.create_layout("basic/mosfet", { fingers = 1, drawtopgcut = true }):move_anchor("topgate", point.create(x, 0)))
                pcell.pop_overwrites("basic/mosfet")
            end
        end
    end
    if _P.drawdummygatecontacts then
        gate:merge_into(geometry.multiple_xy(
            geometry.rectangle(generics.contact("gate", nil, true), bp.glength, bp.dummycontheight),
            bp.leftdummies, 2, xpitch, separation + bp.pwidth + bp.nwidth + 2 * bp.powerspace + bp.dummycontheight
        ):translate(-(_P.fingers + bp.rightdummies) * xpitch / 2 + xshift, (bp.pwidth - bp.nwidth) / 2))
        gate:merge_into(geometry.multiple_xy(
            geometry.rectangle(generics.contact("gate", nil, true), bp.glength, bp.dummycontheight),
            bp.rightdummies, 2, xpitch, separation + bp.pwidth + bp.nwidth + 2 * bp.powerspace + bp.dummycontheight
        ):translate( (_P.fingers + bp.leftdummies) * xpitch / 2 + xshift, (bp.pwidth - bp.nwidth) / 2))
    end

    -- dummy source/drain contacts
    if _P.drawdummyactivecontacts then
        gate:merge_into(geometry.multiple_x(
            geometry.rectangle(generics.contact("sourcedrain"), bp.sdwidth, bp.pwidth / 2),
            bp.leftdummies, xpitch
        ):translate(-(_P.fingers + bp.rightdummies + 1) * xpitch / 2 + xshift, separation / 2 + bp.pwidth * 3 / 4))
        gate:merge_into(geometry.multiple_x(
            geometry.rectangle(generics.contact("sourcedrain"), bp.sdwidth, bp.nwidth / 2),
            bp.leftdummies, xpitch
        ):translate(-(_P.fingers + bp.rightdummies + 1) * xpitch / 2 + xshift, -separation / 2 - bp.nwidth * 3 / 4))
        gate:merge_into(geometry.multiple_xy(
            geometry.rectangle(generics.metal(1), bp.sdwidth, bp.powerspace),
            bp.leftdummies, 2, xpitch, separation + bp.pwidth + bp.nwidth + bp.powerspace
        ):translate(-(_P.fingers + bp.rightdummies + 1) * xpitch / 2 + xshift, (bp.pwidth - bp.nwidth) / 2))
        gate:merge_into(geometry.multiple_x(
            geometry.rectangle(generics.contact("sourcedrain"), bp.sdwidth, bp.pwidth / 2),
            bp.rightdummies, xpitch
        ):translate( (_P.fingers + bp.leftdummies + 1) * xpitch / 2 + xshift, separation / 2 + bp.pwidth * 3 / 4))
        gate:merge_into(geometry.multiple_x(
            geometry.rectangle(generics.contact("sourcedrain"), bp.sdwidth, bp.nwidth / 2),
            bp.rightdummies, xpitch
        ):translate( (_P.fingers + bp.leftdummies + 1) * xpitch / 2 + xshift, -separation / 2 - bp.nwidth * 3 / 4))
        gate:merge_into(geometry.multiple_xy(
            geometry.rectangle(generics.metal(1), bp.sdwidth, bp.powerspace),
            bp.rightdummies, 2, xpitch, separation + bp.pwidth + bp.nwidth + bp.powerspace
        ):translate( (_P.fingers + bp.leftdummies + 1) * xpitch / 2 + xshift, (bp.pwidth - bp.nwidth) / 2))
    end

    -- draw source/drain contacts
    local indexshift = _P.fingers + 2 + bp.rightdummies - bp.leftdummies
    for i = 1, _P.fingers + 1 do
        local x = (2 * i - indexshift) * xpitch / 2 + xshift
        local y = separation / 2 + bp.pwidth / 2
        -- p contacts
        if _P.pcontactpos[i] == "power" or _P.pcontactpos[i] == "outer" then
            gate:merge_into(geometry.rectangle(
                generics.contact("sourcedrain"), bp.sdwidth, bp.pwidth / 2
            ):translate(x, y + bp.pwidth / 4 - _P.shiftpcontactsouter))
            if _P.pcontactpos[i] == "power" then
                gate:merge_into(geometry.rectangle(
                    generics.metal(1), bp.sdwidth, bp.powerspace)
                :translate(x, y + bp.pwidth / 2 + bp.powerspace / 2 - _P.shiftpcontactsouter))
            end
            gate:add_anchor(string.format("pSDc%d", i), point.create(x, y + bp.pwidth / 4 - _P.shiftpcontactsouter))
            gate:add_anchor(string.format("pSDi%d", i), point.create(x, y                 - _P.shiftpcontactsouter))
            gate:add_anchor(string.format("pSDo%d", i), point.create(x, y + bp.pwidth / 2 - _P.shiftpcontactsouter))
        elseif _P.pcontactpos[i] == "inner" then
            gate:merge_into(geometry.rectangle(
                generics.contact("sourcedrain"), bp.sdwidth, bp.pwidth / 2
            ):translate(x, y - bp.pwidth / 4 + _P.shiftpcontactsinner))
            gate:add_anchor(string.format("pSDc%d", i), point.create(x, y - bp.pwidth / 4 + _P.shiftpcontactsinner))
            gate:add_anchor(string.format("pSDi%d", i), point.create(x, y - bp.pwidth / 2 + _P.shiftpcontactsinner))
            gate:add_anchor(string.format("pSDo%d", i), point.create(x, y                 + _P.shiftpcontactsinner))
        end
        y = -separation / 2 - bp.nwidth / 2
        -- n contacts
        if _P.ncontactpos[i] == "power" or _P.ncontactpos[i] == "outer" then
            gate:merge_into(geometry.rectangle(
                generics.contact("sourcedrain"), bp.sdwidth, bp.nwidth / 2
            ):translate(x, y - bp.nwidth / 4 + _P.shiftncontactsouter))
            if _P.ncontactpos[i] == "power" then
                gate:merge_into(geometry.rectangle(
                    generics.metal(1), bp.sdwidth, bp.powerspace)
                :translate(x, y - bp.nwidth / 2 - bp.powerspace / 2 + _P.shiftncontactsouter))
            end
            gate:add_anchor(string.format("nSDc%d", i), point.create(x, y - bp.nwidth / 4 + _P.shiftncontactsouter))
            gate:add_anchor(string.format("nSDi%d", i), point.create(x, y                 + _P.shiftncontactsouter))
            gate:add_anchor(string.format("nSDo%d", i), point.create(x, y - bp.nwidth / 2 + _P.shiftncontactsouter))
        elseif _P.ncontactpos[i] == "inner" then
            gate:merge_into(geometry.rectangle(
                generics.contact("sourcedrain"), bp.sdwidth, bp.nwidth / 2
            ):translate(x, y + bp.nwidth / 4 - _P.shiftncontactsinner))
            gate:add_anchor(string.format("nSDc%d", i), point.create(x, y + bp.nwidth / 4 - _P.shiftncontactsinner))
            gate:add_anchor(string.format("nSDi%d", i), point.create(x, y + bp.nwidth / 2 - _P.shiftncontactsinner))
            gate:add_anchor(string.format("nSDo%d", i), point.create(x, y                 - _P.shiftncontactsinner))
        end
    end

    -- pop general transistor settings
    pcell.pop_overwrites("basic/mosfet")

    gate:set_alignment_box(
        point.create(-(_P.fingers + bp.leftdummies + bp.rightdummies) * (bp.glength + bp.gspace) / 2 + xshift, -separation / 2 - bp.nwidth - bp.powerspace - bp.powerwidth / 2),
        point.create( (_P.fingers + bp.leftdummies + bp.rightdummies) * (bp.glength + bp.gspace) / 2 + xshift, separation / 2 + bp.pwidth + bp.powerspace + bp.powerwidth / 2)
    )
end
