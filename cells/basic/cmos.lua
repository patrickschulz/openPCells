function config()
    pcell.reference_cell("basic/mosfet")
end

function parameters()
    pcell.add_parameters(
        { "fingers", 8 },
        { "oxidetype(Oxide Type)",                         1 },
        { "pvthtype(PMOS Threshold Voltage Type) ",        1 },
        { "nvthtype(NMOS Threshold Voltage Type)",         3 },
        { "glength(Gate Length)",                        200 },
        { "gspace(Gate Spacing)",                        140 },
        { "pwidth(PMOS Finger Width)",                   500 },
        { "nwidth(NMOS Finger Width)",                   500 },
        { "separation(PMOS/NMOS y-Space)",               200 },
        { "sdwidth(Source/Drain Metal Width)",            60 },
        { "gstwidth(Gate Strap Metal Width)",             60 },
        { "outergstspace(Outer Gate Strap Metal Space)",  60 },
        { "gatecontactpos", { }, argtype = "strtable"        },
        { "powerwidth(Power Rail Metal Width)",          120 },
        { "powerspace(Power Rail Space)",                 60 },
        { "pcontactpos", {}, argtype = "strtable"            },
        { "ncontactpos", {}, argtype = "strtable"            },
        { "pcontactheight", 500, follow = "pwidth"           },
        { "ncontactheight", 500, follow = "nwidth"           },
        { "drawdummyactive", false                           },
        { "dummyactivewidth", 80                             }
    )
end

function layout(obj, _P)
    local tp = pcell.get_parameters("basic/mosfet")
    local xpitch = _P.gspace + _P.glength

    -- common transistor options
    pcell.push_overwrites("basic/mosfet", {
        gatelength = _P.glength,
        gatespace = _P.gspace,
        sdwidth = _P.sdwidth,
        drawinnersourcedrain = "none",
        drawoutersourcedrain = "none",
        topactivedummysep = _P.separation,
        topactivedummywidth = _P.separation / 2,
        botactivedummysep = _P.separation,
        botactivedummywidth = _P.separation / 2,
    })

    -- pmos
    pcell.push_overwrites("basic/mosfet", {
        channeltype = "pmos",
        vthtype = _P.pvthtype,
        fwidth = _P.pwidth,
        gbotext = _P.separation / 2,
        gtopext = _P.powerspace + _P.powerwidth + _P.outergstspace + _P.gstwidth,
        clipbot = true,
        drawtopactivedummy = _P.drawdummyactive
    })
    pmos = pcell.create_layout("basic/mosfet", { fingers = _P.fingers }):move_anchor("botgate")
    obj:merge_into(pmos)
    pcell.pop_overwrites("basic/mosfet")

    -- nmos
    pcell.push_overwrites("basic/mosfet", {
        channeltype = "nmos",
        vthtype = _P.nvthtype,
        fwidth = _P.nwidth,
        gtopext = _P.separation / 2,
        gbotext = _P.powerspace + _P.powerwidth + _P.outergstspace + _P.gstwidth,
        cliptop = true,
        drawbotactivedummy = _P.drawdummyactive
    })
    nmos = pcell.create_layout("basic/mosfet", { fingers = _P.fingers }):move_anchor("topgate")
    obj:merge_into(nmos)
    pcell.pop_overwrites("basic/mosfet")

    -- general transistor settings
    pcell.pop_overwrites("basic/mosfet")

    -- power rails
    obj:merge_into(geometry.multiple_y(
        geometry.rectangle(generics.metal(1), _P.fingers * xpitch + _P.sdwidth, _P.powerwidth),
        2, _P.separation + _P.pwidth + _P.nwidth + 2 * _P.powerspace + _P.powerwidth
    ):translate(0, (_P.pwidth - _P.nwidth) / 2))

    -- draw gate contacts
    for i = 1, _P.fingers do
        if _P.gatecontactpos[i] == "center" then
            obj:merge_into(geometry.rectangle(
                generics.contact("gate"), _P.glength, _P.gstwidth
            ):translate((2 * i - _P.fingers - 1) * xpitch / 2, 0))
            obj:add_anchor(string.format("G%d", i), point.create((2 * i - _P.fingers - 1) * xpitch / 2, 0))
        elseif _P.gatecontactpos[i] == "outer" then
            obj:merge_into(geometry.rectangle(
                generics.contact("gate"), _P.glength, _P.gstwidth
            ):translate((2 * i - _P.fingers - 1) * xpitch / 2, _P.separation / 2 + _P.pwidth + _P.outergstspace + _P.gstwidth / 2 + _P.powerwidth + _P.powerspace))
            obj:merge_into(geometry.rectangle(
                generics.contact("gate"), _P.glength, _P.gstwidth
            ):translate((2 * i - _P.fingers - 1) * xpitch / 2, -_P.separation / 2 - _P.nwidth - _P.outergstspace - _P.gstwidth / 2 - _P.powerwidth - _P.powerspace))
            obj:add_anchor(string.format("Gp%d", i), point.create(
                (2 * i - _P.fingers - 1) * xpitch / 2, 
                _P.separation / 2 + _P.pwidth + _P.outergstspace + _P.gstwidth / 2 + _P.powerwidth + _P.powerspace))
            obj:add_anchor(string.format("Gn%d", i), point.create(
                (2 * i - _P.fingers - 1) * xpitch / 2, 
                -_P.separation / 2 - _P.nwidth - _P.outergstspace - _P.gstwidth / 2 - _P.powerwidth - _P.powerspace))
        elseif _P.gatecontactpos[i] == "split" then
            obj:merge_into(geometry.multiple_y(
                geometry.rectangle(generics.contact("gate"), _P.glength, _P.gstwidth)
                :translate((2 * i - _P.fingers - 1) * xpitch / 2, 0),
                2, 4 * _P.gstwidth
            ))
            obj:add_anchor(string.format("Gu%d", i), point.create((2 * i - _P.fingers - 1) * xpitch / 2,  2 * _P.gstwidth))
            obj:add_anchor(string.format("Gl%d", i), point.create((2 * i - _P.fingers - 1) * xpitch / 2, -2 * _P.gstwidth))
        end
        -- draw gate cut
        if _P.gatecontactpos[i] == "outer" or _P.gatecontactpos[i] == "split" then
            obj:merge_into(geometry.rectanglebltr(
                generics.other("gatecut"),
                point.create((2 * i - _P.fingers - 1) * xpitch / 2 - xpitch / 2, -tp.cutheight / 2),
                point.create((2 * i - _P.fingers - 1) * xpitch / 2 + xpitch / 2,  tp.cutheight / 2)
            ))
        end
    end

    -- draw source/drain contacts
    local indexshift = _P.fingers + 2
    for i = 1, _P.fingers + 1 do
        local x = (2 * i - indexshift) * xpitch / 2
        local y = _P.separation / 2 + _P.pwidth / 2
        -- p contacts
        if _P.pcontactpos[i] == "power" or _P.pcontactpos[i] == "outer" then
            y = y + _P.pwidth / 2 - _P.pcontactheight / 2
            obj:merge_into(geometry.rectangle(
                generics.contact("sourcedrain"), _P.sdwidth, _P.pcontactheight
            ):translate(x, y))
            if _P.pcontactpos[i] == "power" then
                obj:merge_into(geometry.rectangle(
                    generics.metal(1), _P.sdwidth, _P.powerspace)
                :translate(x, y + _P.pcontactheight / 2 + _P.powerspace / 2))
            end
        elseif _P.pcontactpos[i] == "inner" then
            y = y - _P.pwidth / 2 + _P.ncontactheight / 2
            obj:merge_into(geometry.rectangle(
                generics.contact("sourcedrain"), _P.sdwidth, _P.pcontactheight
            ):translate(x, y))
        end
        obj:add_anchor(string.format("pSDi%d", i), point.create(x, y - _P.pcontactheight / 2))
        obj:add_anchor(string.format("pSDo%d", i), point.create(x, y + _P.pcontactheight / 2))
        obj:add_anchor(string.format("pSDc%d", i), point.create(x, y))
        -- n contacts
        local y = -_P.separation / 2 - _P.nwidth / 2
        if _P.ncontactpos[i] == "power" or _P.ncontactpos[i] == "outer" then
            y = y - _P.nwidth / 2 + _P.ncontactheight / 2
            obj:merge_into(geometry.rectangle(
                generics.contact("sourcedrain"), _P.sdwidth, _P.ncontactheight
            ):translate(x, y))
            if _P.ncontactpos[i] == "power" then
                obj:merge_into(geometry.rectangle(
                    generics.metal(1), _P.sdwidth, _P.powerspace)
                :translate(x, y -_P.ncontactheight / 2 - _P.powerspace / 2))
            end
        elseif _P.ncontactpos[i] == "inner" then
            y = y + _P.nwidth / 2 - _P.ncontactheight / 2
            obj:merge_into(geometry.rectangle(
                generics.contact("sourcedrain"), _P.sdwidth, _P.ncontactheight
            ):translate(x, y))
        end
        obj:add_anchor(string.format("nSDi%d", i), point.create(x, y + _P.ncontactheight / 2))
        obj:add_anchor(string.format("nSDo%d", i), point.create(x, y - _P.ncontactheight / 2))
        obj:add_anchor(string.format("nSDc%d", i), point.create(x, y))
    end
    
    -- alignmentbox
    obj:set_alignment_box(
        point.create(-_P.fingers * xpitch/ 2, -_P.separation / 2 - _P.nwidth - _P.powerspace - _P.powerwidth / 2),
        point.create( _P.fingers * xpitch/ 2, _P.separation / 2 + _P.pwidth + _P.powerspace + _P.powerwidth / 2)
    )
end
