function config()
    pcell.reference_cell("basic/mosfet")
end

function parameters()
    pcell.add_parameters(
        { "fingers", 8 },
        { "oxidetype(Oxide Type)",                        1 },
        { "pvthtype(PMOS Threshold Voltage Type) ",       1 },
        { "nvthtype(NMOS Threshold Voltage Type)",        1 },
        { "glength(Gate Length)",                         100 },
        { "gspace(Gate Spacing)",                         110 },
        { "pwidth(PMOS Finger Width)",                    500 },
        { "nwidth(NMOS Finger Width)",                    500 },
        { "separation(PMOS/NMOS y-Space)",                 200 },
        { "sdwidth(Source/Drain Metal Width)",            60 },
        { "gstwidth(Gate Strap Metal Width)",             60 },
        { "outergstspace(Outer Gate Strap Metal Space)",             60 },
        { "gatecontactpos", { }, argtype = "strtable" },
        { "powerwidth(Power Rail Metal Width)",           200 },
        { "powerspace(Power Rail Space)",                 100 },
        { "pcontactpos", {}, argtype = "strtable" },
        { "ncontactpos", {}, argtype = "strtable" },
        { "pcontactheight", 500, follow = "pwidth" },
        { "ncontactheight", 500, follow = "nwidth" }
    )
end

function layout(gate, _P)
    local xpitch = _P.gspace + _P.glength

    -- common transistor options
    pcell.push_overwrites("basic/mosfet", {
        gatelength = _P.glength,
        gatespace = _P.gspace,
        sdwidth = _P.sdwidth,
        drawinnersourcedrain = "none",
        drawoutersourcedrain = "none"
    })

    -- pmos
    pcell.push_overwrites("basic/mosfet", {
        channeltype = "pmos",
        vthtype = _P.pvthtype,
        fwidth = _P.pwidth,
        gbotext = _P.separation / 2,
        gtopext = _P.powerspace + _P.powerwidth + _P.outergstspace + _P.gstwidth,
        clipbot = true,
        drawtopgcut = true
    })
    pmos = pcell.create_layout("basic/mosfet", { fingers = _P.fingers }):move_anchor("botgate")
    gate:merge_into(pmos)
    pcell.pop_overwrites("basic/mosfet")

    -- nmos
    pcell.push_overwrites("basic/mosfet", {
        channeltype = "nmos",
        vthtype = _P.nvthtype,
        fwidth = _P.nwidth,
        gtopext = _P.separation / 2,
        gbotext = _P.powerspace + _P.powerwidth + _P.outergstspace + _P.gstwidth,
        cliptop = true,
        drawbotgcut = true,
    })
    nmos = pcell.create_layout("basic/mosfet", { fingers = _P.fingers }):move_anchor("topgate")
    gate:merge_into(nmos)
    pcell.pop_overwrites("basic/mosfet")

    -- general transistor settings
    pcell.pop_overwrites("basic/mosfet")

    -- power rails
    gate:merge_into(geometry.multiple_y(
        geometry.rectangle(generics.metal(1), _P.fingers * xpitch + _P.sdwidth, _P.powerwidth),
        2, _P.separation + _P.pwidth + _P.nwidth + 2 * _P.powerspace + _P.powerwidth
    ):translate(0, (_P.pwidth - _P.nwidth) / 2))

    -- draw gate contacts
    for i = 1, _P.fingers do
        if _P.gatecontactpos[i] == "center" then
            gate:merge_into(geometry.rectangle(
                generics.contact("gate"), _P.glength, _P.gstwidth
            ):translate((2 * i - _P.fingers - 1) * xpitch / 2, 0))
            gate:add_anchor(string.format("G%d", i), point.create((2 * i - _P.fingers - 1) * xpitch / 2, 0))
        end
        if _P.gatecontactpos[i] == "outer" then
            gate:merge_into(geometry.rectangle(
                generics.contact("gate"), _P.glength, _P.gstwidth
            ):translate((2 * i - _P.fingers - 1) * xpitch / 2, _P.separation / 2 + _P.pwidth + _P.outergstspace + _P.gstwidth / 2 + _P.powerwidth + _P.powerspace))
            gate:merge_into(geometry.rectangle(
                generics.contact("gate"), _P.glength, _P.gstwidth
            ):translate((2 * i - _P.fingers - 1) * xpitch / 2, -_P.separation / 2 - _P.nwidth - _P.outergstspace - _P.gstwidth / 2 - _P.powerwidth - _P.powerspace))
            gate:add_anchor(string.format("Gp%d", i), point.create(
                (2 * i - _P.fingers - 1) * xpitch / 2, 
                _P.separation / 2 + _P.pwidth + _P.outergstspace + _P.gstwidth / 2 + _P.powerwidth + _P.powerspace))
            gate:add_anchor(string.format("Gn%d", i), point.create(
                (2 * i - _P.fingers - 1) * xpitch / 2, 
                -_P.separation / 2 - _P.nwidth - _P.outergstspace - _P.gstwidth / 2 - _P.powerwidth - _P.powerspace))
        end
    end

    -- draw source/drain contacts
    local indexshift = _P.fingers + 2
    for i = 1, _P.fingers + 1 do
        local x = (2 * i - indexshift) * xpitch / 2
        local y = _P.separation / 2 + _P.pwidth / 2
        -- p contacts
        if _P.pcontactpos[i] == "power" or _P.pcontactpos[i] == "outer" then
            gate:merge_into(geometry.rectangle(
                generics.contact("active"), _P.sdwidth, _P.pcontactheight
            ):translate(x, y + _P.pwidth / 2 - _P.pcontactheight / 2))
            if _P.pcontactpos[i] == "power" then
                gate:merge_into(geometry.rectangle(
                    generics.metal(1), _P.sdwidth, _P.powerspace)
                :translate(x, y + _P.pwidth / 2 + _P.powerspace / 2))
            end
            gate:add_anchor(string.format("pSDc%d", i), point.create(x, y + _P.pwidth / 2 - _P.pcontactheight / 2))
            gate:add_anchor(string.format("pSDi%d", i), point.create(x, y))
            gate:add_anchor(string.format("pSDo%d", i), point.create(x, y + _P.pcontactheight))
        elseif _P.pcontactpos[i] == "inner" then
            gate:merge_into(geometry.rectangle(
                generics.contact("active"), _P.sdwidth, _P.pcontactheight
            ):translate(x, y - _P.pwidth / 2 + _P.pcontactheight / 2))
            gate:add_anchor(string.format("pSDc%d", i), point.create(x, y - _P.pwidth / 2 + _P.pcontactheight / 2))
            gate:add_anchor(string.format("pSDi%d", i), point.create(x, y - _P.pwidth / 2))
            gate:add_anchor(string.format("pSDo%d", i), point.create(x, y - _P.pwidth / 2 + _P.pcontactheight))
        end
        y = -_P.separation / 2 - _P.ncontactheight
        -- n contacts
        local y = -_P.separation / 2 - _P.nwidth / 2
        if _P.ncontactpos[i] == "power" or _P.ncontactpos[i] == "outer" then
            gate:merge_into(geometry.rectangle(
                generics.contact("active"), _P.sdwidth, _P.ncontactheight
            ):translate(x, y - _P.nwidth / 2 + _P.ncontactheight / 2))
            if _P.ncontactpos[i] == "power" then
                gate:merge_into(geometry.rectangle(
                    generics.metal(1), _P.sdwidth, _P.powerspace)
                :translate(x, y - _P.nwidth / 2 - _P.powerspace / 2))
            end
            gate:add_anchor(string.format("nSDc%d", i), point.create(x, y - _P.pwidth / 4))
            gate:add_anchor(string.format("nSDi%d", i), point.create(x, y))
            gate:add_anchor(string.format("nSDo%d", i), point.create(x, y - _P.ncontactheight))
        elseif _P.ncontactpos[i] == "inner" then
            gate:merge_into(geometry.rectangle(
                generics.contact("active"), _P.sdwidth, _P.ncontactheight
            ):translate(x, y + _P.nwidth / 2 - _P.ncontactheight / 2))
            gate:add_anchor(string.format("nSDc%d", i), point.create(x, y + _P.nwidth / 2 - _P.ncontactheight / 2))
            gate:add_anchor(string.format("nSDi%d", i), point.create(x, y + _P.nwidth / 2))
            gate:add_anchor(string.format("nSDc%d", i), point.create(x, y + _P.nwidth / 2 - _P.ncontactheight))
        end
    end
end
