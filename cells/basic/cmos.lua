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
        { "sdwidth(Source/Drain Metal Width)",                 tech.get_dimension("Minimum M1 Width"), even() },
        { "gstwidth(Gate Strap Metal Width)",                  tech.get_dimension("Minimum M1 Width") },
        { "gstspace(Gate Strap Metal Space)",                  tech.get_dimension("Minimum M1 Space") },
        { "numinnerroutes(Number of inner M1 routes)",         3, readonly = true },
        { "powerwidth(Power Rail Metal Width)",                tech.get_dimension("Minimum M1 Width") },
        { "powerspace(Power Rail Space)",                      tech.get_dimension("Minimum M1 Space") },
        { "gateext(Gate Extension)",                           0 },
        { "psdheight(PMOS Source/Drain Contact Height)",       0 },
        { "nsdheight(NMOS Source/Drain Contact Height)",       0 },
        { "psdpowerheight(PMOS Source/Drain Contact Height)",  0 },
        { "nsdpowerheight(NMOS Source/Drain Contact Height)",  0 },
        { "dummycontheight(Dummy Gate Contact Height)",        tech.get_dimension("Minimum M1 Width") },
        { "drawdummygcut(Draw Dummy Gate Cut)",                false },
        { "compact(Compact Layout)",                           true },
        { "connectoutput",                                     true },
        { "separation", 200 },
        { "drawtransistors", true },
        { "drawactive", true },
        { "drawrails", true },
        { "drawgatecontacts", true },
        --{ "gatecontactpos", { }, argtype = "strtable" },
        { "gatecontactpos", { "center" }, argtype = "strtable" },
        { "shiftgatecontacts", 0 },
        { "pcontactpos", {}, argtype = "strtable" },
        { "ncontactpos", {}, argtype = "strtable" },
        { "shiftpcontactsinner", 0 },
        { "shiftpcontactsouter", 0 },
        { "shiftncontactsinner", 0 },
        { "shiftncontactsouter", 0 },
        { "drawdummygatecontacts", true },
        { "drawdummyactivecontacts", true },
        { "drawgcut", false },
        { "dummycontheight(Dummy Gate Contact Height)",        tech.get_dimension("Minimum M1 Width") }
    )
end

function layout(gate, _P)
    local tp = pcell.get_parameters("basic/mosfet")
    local xpitch = tp.gatespace + tp.gatelength
    local fingers = #_P.gatecontactpos

    -- common transistor options
    pcell.push_overwrites("basic/mosfet", {
        gatelength = tp.gatelength,
        gatespace = tp.gatespace,
        sdwidth = tp.sdwidth,
        drawinnersourcedrain = "none",
        drawoutersourcedrain = "none",
        drawactive = _P.drawactive
    })

    if _P.drawtransistors then
        local ext = math.max(tp.cutheight / 2, _P.dummycontheight / 2)

        -- pmos
        pcell.push_overwrites("basic/mosfet", {
            channeltype = "pmos",
            vthtype = _P.pvthtype,
            fwidth = _P.pwidth,
            gbotext = _P.separation / 2,
            --gtopext = _P.powerspace + _P.powerwidth / 2 + ext,
            gtopext = ext,
            topgcutoffset = ext,
            clipbot = true,
        })
        -- main
        local pmos
        if fingers > 0 then
            pmos = pcell.create_layout("basic/mosfet", { fingers = fingers }):move_anchor("botgate")
            gate:merge_into_shallow(pmos)
        else
            pmos = object.create_omni()
        end
        pcell.pop_overwrites("basic/mosfet")

        -- nmos
        pcell.push_overwrites("basic/mosfet", {
            channeltype = "nmos",
            vthtype = _P.nvthtype,
            fwidth = _P.nwidth,
            gtopext = _P.separation / 2,
            --gbotext = _P.powerspace + _P.powerwidth / 2 + ext,
            gbotext = ext,
            botgcutoffset = ext,
            cliptop = true,
        })
        local nmos
        -- main
        if fingers > 0 then
            nmos = pcell.create_layout("basic/mosfet", { fingers = fingers }):move_anchor("topgate")
            gate:merge_into_shallow(nmos)
        else
            nmos = object.create_omni()
        end
        pcell.pop_overwrites("basic/mosfet")
    end

    -- power rails
    if _P.drawrails then
        gate:merge_into_shallow(geometry.multiple_y(
            geometry.rectangle(generics.metal(1), (fingers) * xpitch + _P.sdwidth, _P.powerwidth),
            2, _P.separation + _P.pwidth + _P.nwidth + 2 * _P.powerspace + _P.powerwidth
        ):translate(0, (_P.pwidth - _P.nwidth) / 2))
    end
    gate:add_anchor("PRpll", point.create(-fingers * xpitch / 2 - _P.sdwidth / 2,  _P.separation / 2 + _P.pwidth + _P.powerspace))
    gate:add_anchor("PRpcl", point.create(-fingers * xpitch / 2 - _P.sdwidth / 2,  _P.separation / 2 + _P.pwidth + _P.powerspace + _P.powerwidth / 2))
    gate:add_anchor("PRpul", point.create(-fingers * xpitch / 2 - _P.sdwidth / 2,  _P.separation / 2 + _P.pwidth + _P.powerspace + _P.powerwidth))
    gate:add_anchor("PRplc", point.create(0,                      _P.separation / 2 + _P.pwidth + _P.powerspace))
    gate:add_anchor("PRpcc", point.create(0,                      _P.separation / 2 + _P.pwidth + _P.powerspace + _P.powerwidth / 2))
    gate:add_anchor("PRpuc", point.create(0,                      _P.separation / 2 + _P.pwidth + _P.powerspace + _P.powerwidth))
    gate:add_anchor("PRplr", point.create( fingers * xpitch / 2 + _P.sdwidth / 2,  _P.separation / 2 + _P.pwidth + _P.powerspace))
    gate:add_anchor("PRpcr", point.create( fingers * xpitch / 2 + _P.sdwidth / 2,  _P.separation / 2 + _P.pwidth + _P.powerspace + _P.powerwidth / 2))
    gate:add_anchor("PRpur", point.create( fingers * xpitch / 2 + _P.sdwidth / 2,  _P.separation / 2 + _P.pwidth + _P.powerspace + _P.powerwidth))
    gate:add_anchor("PRnll", point.create(-fingers * xpitch / 2 - _P.sdwidth / 2, -_P.separation / 2 - _P.nwidth - _P.powerspace - _P.powerwidth))
    gate:add_anchor("PRncl", point.create(-fingers * xpitch / 2 - _P.sdwidth / 2, -_P.separation / 2 - _P.nwidth - _P.powerspace - _P.powerwidth / 2))
    gate:add_anchor("PRnul", point.create(-fingers * xpitch / 2 - _P.sdwidth / 2, -_P.separation / 2 - _P.nwidth - _P.powerspace))
    gate:add_anchor("PRnlc", point.create(0,                     -_P.separation / 2 - _P.nwidth - _P.powerspace - _P.powerwidth))
    gate:add_anchor("PRncc", point.create(0,                     -_P.separation / 2 - _P.nwidth - _P.powerspace - _P.powerwidth / 2))
    gate:add_anchor("PRnuc", point.create(0,                     -_P.separation / 2 - _P.nwidth - _P.powerspace))
    gate:add_anchor("PRnlr", point.create( fingers * xpitch / 2 + _P.sdwidth / 2, -_P.separation / 2 - _P.nwidth - _P.powerspace - _P.powerwidth))
    gate:add_anchor("PRncr", point.create( fingers * xpitch / 2 + _P.sdwidth / 2, -_P.separation / 2 - _P.nwidth - _P.powerspace - _P.powerwidth / 2))
    gate:add_anchor("PRnur", point.create( fingers * xpitch / 2 + _P.sdwidth / 2, -_P.separation / 2 - _P.nwidth - _P.powerspace))

    -- draw gate contacts
    if _P.drawgatecontacts then
        for i = 1, fingers do
            local x = (2 * i - fingers - 1) * xpitch / 2
            local routingshift = (_P.gstwidth + _P.gstspace) / (_P.numinnerroutes % 2 == 0 and 2 or 1)
            if _P.gatecontactpos[i] == "center" then
                local pt = point.create(x, _P.shiftgatecontacts)
                gate:merge_into_shallow(geometry.rectangle(
                    generics.contact("gate", nil, true), tp.gatelength, _P.gstwidth
                ):translate(pt))
                gate:add_anchor(string.format("Gll%d", i), pt + point.create(-tp.gatelength / 2, -_P.gstwidth / 2))
                gate:add_anchor(string.format("Gcl%d", i), pt + point.create(-tp.gatelength / 2, 0))
                gate:add_anchor(string.format("Gul%d", i), pt + point.create(-tp.gatelength / 2, _P.gstwidth / 2))
                gate:add_anchor(string.format("Glc%d", i), pt + point.create(0, -_P.gstwidth / 2))
                gate:add_anchor(string.format("Gcc%d", i), pt + point.create(0, 0))
                gate:add_anchor(string.format("Guc%d", i), pt + point.create(0, _P.gstwidth / 2))
                gate:add_anchor(string.format("Glr%d", i), pt + point.create(tp.gatelength / 2, -_P.gstwidth / 2))
                gate:add_anchor(string.format("Gcr%d", i), pt + point.create(tp.gatelength / 2, 0))
                gate:add_anchor(string.format("Gur%d", i), pt + point.create(tp.gatelength / 2, _P.gstwidth / 2))
            elseif _P.gatecontactpos[i] == "upper" then
                local pt = point.create(x, routingshift + _P.shiftgatecontacts)
                gate:merge_into_shallow(geometry.rectangle(
                    generics.contact("gate", nil, true), tp.gatelength, _P.gstwidth
                ):translate(pt))
                gate:add_anchor(string.format("Gll%d", i), pt + point.create(-tp.gatelength / 2, -_P.gstwidth / 2))
                gate:add_anchor(string.format("Gcl%d", i), pt + point.create(-tp.gatelength / 2, 0))
                gate:add_anchor(string.format("Gul%d", i), pt + point.create(-tp.gatelength / 2, _P.gstwidth / 2))
                gate:add_anchor(string.format("Glc%d", i), pt + point.create(0, -_P.gstwidth / 2))
                gate:add_anchor(string.format("Gcc%d", i), pt + point.create(0, 0))
                gate:add_anchor(string.format("Guc%d", i), pt + point.create(0, _P.gstwidth / 2))
                gate:add_anchor(string.format("Glr%d", i), pt + point.create(tp.gatelength / 2, -_P.gstwidth / 2))
                gate:add_anchor(string.format("Gcr%d", i), pt + point.create(tp.gatelength / 2, 0))
                gate:add_anchor(string.format("Gur%d", i), pt + point.create(tp.gatelength / 2, _P.gstwidth / 2))
            elseif _P.gatecontactpos[i] == "lower" then
                local pt = point.create(x, -routingshift + _P.shiftgatecontacts)
                gate:merge_into_shallow(geometry.rectangle(
                    generics.contact("gate", nil, true), tp.gatelength, _P.gstwidth
                ):translate(pt))
                gate:add_anchor(string.format("Gll%d", i), pt + point.create(-tp.gatelength / 2, -_P.gstwidth / 2))
                gate:add_anchor(string.format("Gcl%d", i), pt + point.create(-tp.gatelength / 2, 0))
                gate:add_anchor(string.format("Gul%d", i), pt + point.create(-tp.gatelength / 2, _P.gstwidth / 2))
                gate:add_anchor(string.format("Glc%d", i), pt + point.create(0, -_P.gstwidth / 2))
                gate:add_anchor(string.format("Gcc%d", i), pt + point.create(0, 0))
                gate:add_anchor(string.format("Guc%d", i), pt + point.create(0, _P.gstwidth / 2))
                gate:add_anchor(string.format("Glr%d", i), pt + point.create(tp.gatelength / 2, -_P.gstwidth / 2))
                gate:add_anchor(string.format("Gcr%d", i), pt + point.create(tp.gatelength / 2, 0))
                gate:add_anchor(string.format("Gur%d", i), pt + point.create(tp.gatelength / 2, _P.gstwidth / 2))
            elseif _P.gatecontactpos[i] == "split" then
                local x = (2 * i - fingers - 1) * xpitch / 2
                local y = _P.shiftgatecontacts
                gate:merge_into_shallow(geometry.multiple_y(
                    geometry.rectangle(generics.contact("gate", nil, true), tp.gatelength, _P.gstwidth),
                    2, 2 * routingshift
                ):translate(x, y))
                gate:add_anchor(string.format("G%d", i), point.create(x, y))
                gate:add_anchor(string.format("G%dupper", i), point.create(x, y + routingshift))
                gate:add_anchor(string.format("G%dlower", i), point.create(x, y - routingshift))
                gate:merge_into_shallow(geometry.rectangle(generics.other("gatecut"), xpitch, tp.cutheight):translate(x, 0))
            elseif _P.gatecontactpos[i] == "dummy" then
                local pt = point.create(x, _P.shiftgatecontacts)
                gate:merge_into_shallow(geometry.multiple_y(
                    geometry.rectangle(generics.contact("gate", nil, true), tp.gatelength, _P.dummycontheight),
                    2, _P.separation + _P.pwidth + _P.nwidth + 2 * _P.powerspace + _P.powerwidth
                ):translate(x, (_P.pwidth - _P.nwidth) / 2))
                gate:merge_into_shallow(geometry.rectangle(generics.other("gatecut"), xpitch, tp.cutheight):translate(x, 0))
            end
            if _P.gatecontactpos[i] ~= "dummy" then
                if _P.drawgcut then
                    gate:merge_into_shallow(geometry.multiple_y(
                        geometry.rectangle(generics.other("gatecut"), xpitch, tp.cutheight),
                        2, _P.separation + _P.pwidth + _P.nwidth + 2 * _P.powerspace + _P.powerwidth
                    ):translate(x, (_P.pwidth - _P.nwidth) / 2))
                end
            end
        end
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
            gate:merge_into_shallow(geometry.rectangle(
                generics.contact("sourcedrain"), _P.sdwidth, cheight
            ):translate(x, y + _P.pwidth / 2 - cheight / 2 - _P.shiftpcontactsouter))
            gate:add_anchor(string.format("pSDc%d", i), point.create(x, y + _P.pwidth / 2 - cheight / 2 - _P.shiftpcontactsouter))
            gate:add_anchor(string.format("pSDi%d", i), point.create(x, y + _P.pwidth / 2 - cheight - _P.shiftpcontactsouter))
            gate:add_anchor(string.format("pSDo%d", i), point.create(x, y + _P.pwidth / 2 - _P.shiftpcontactsouter))
        elseif _P.pcontactpos[i] == "inner" then
            gate:merge_into_shallow(geometry.rectangle(
                generics.contact("sourcedrain"), _P.sdwidth, pcontactheight
            ):translate(x, y - _P.pwidth / 2 + pcontactheight / 2 + _P.shiftpcontactsinner))
            gate:add_anchor(string.format("pSDc%d", i), point.create(x, y - _P.pwidth / 2 + pcontactheight / 2 + _P.shiftpcontactsinner))
            gate:add_anchor(string.format("pSDi%d", i), point.create(x, y - _P.pwidth / 2 + _P.shiftpcontactsinner))
            gate:add_anchor(string.format("pSDo%d", i), point.create(x, y - _P.pwidth / 2 + pcontactheight + _P.shiftpcontactsinner))
        elseif _P.pcontactpos[i] == "full" or _P.pcontactpos[i] == "powerfull" then
            gate:merge_into_shallow(geometry.rectangle(
                generics.contact("sourcedrain"), _P.sdwidth, _P.pwidth
            ):translate(x, y))
            gate:add_anchor(string.format("pSDc%d", i), point.create(x, y))
            gate:add_anchor(string.format("pSDi%d", i), point.create(x, y - _P.pwidth / 2))
            gate:add_anchor(string.format("pSDo%d", i), point.create(x, y + _P.pwidth / 2))
        end
        if _P.pcontactpos[i] == "power" or _P.pcontactpos[i] == "powerfull" then
            gate:merge_into_shallow(geometry.rectangle(
                generics.metal(1), _P.sdwidth, _P.powerspace)
            :translate(x, y + _P.pwidth / 2 + _P.powerspace / 2 - _P.shiftpcontactsouter))
        end
        y = -_P.separation / 2 - _P.nwidth / 2
        -- n contacts
        if _P.ncontactpos[i] == "power" or _P.ncontactpos[i] == "outer" then
            local cheight = _P.ncontactpos[i] == "power" and ncontactpowerheight or ncontactheight
            gate:merge_into_shallow(geometry.rectangle(
                generics.contact("sourcedrain"), _P.sdwidth, cheight
            ):translate(x, y - _P.nwidth / 2 + cheight / 2 + _P.shiftncontactsouter))
            gate:add_anchor(string.format("nSDc%d", i), point.create(x, y - _P.nwidth / 2 + cheight / 2 + _P.shiftncontactsouter))
            gate:add_anchor(string.format("nSDi%d", i), point.create(x, y - _P.nwidth / 2 + cheight + _P.shiftncontactsouter))
            gate:add_anchor(string.format("nSDo%d", i), point.create(x, y - _P.nwidth / 2 + _P.shiftncontactsouter))
        elseif _P.ncontactpos[i] == "inner" then
            gate:merge_into_shallow(geometry.rectangle(
                generics.contact("sourcedrain"), _P.sdwidth, ncontactheight
            ):translate(x, y + _P.nwidth / 2 - ncontactheight / 2 - _P.shiftncontactsinner))
            gate:add_anchor(string.format("nSDc%d", i), point.create(x, y + _P.nwidth / 2 - ncontactheight / 2- _P.shiftncontactsinner))
            gate:add_anchor(string.format("nSDi%d", i), point.create(x, y + _P.nwidth / 2 - _P.shiftncontactsinner))
            gate:add_anchor(string.format("nSDo%d", i), point.create(x, y + _P.nwidth / 2 - ncontactheight - _P.shiftncontactsinner))
        elseif _P.ncontactpos[i] == "full" or _P.ncontactpos[i] == "powerfull" then
            gate:merge_into_shallow(geometry.rectangle(
                generics.contact("sourcedrain"), _P.sdwidth, _P.nwidth
            ):translate(x, y))
            gate:add_anchor(string.format("nSDc%d", i), point.create(x, y))
            gate:add_anchor(string.format("nSDi%d", i), point.create(x, y + _P.nwidth / 2))
            gate:add_anchor(string.format("nSDo%d", i), point.create(x, y - _P.nwidth / 2))
        end
        if _P.ncontactpos[i] == "power" or _P.ncontactpos[i] == "powerfull" then
            gate:merge_into_shallow(geometry.rectangle(
                generics.metal(1), _P.sdwidth, _P.powerspace)
            :translate(x, y - _P.nwidth / 2 - _P.powerspace / 2 + _P.shiftncontactsouter))
        end
    end

    -- pop general transistor settings
    pcell.pop_overwrites("basic/mosfet")

    gate:set_alignment_box(
        point.create(-fingers * (tp.gatelength + tp.gatespace) / 2, -_P.separation / 2 - _P.nwidth - _P.powerspace - _P.powerwidth / 2),
        point.create( fingers * (tp.gatelength + tp.gatespace) / 2, _P.separation / 2 + _P.pwidth + _P.powerspace + _P.powerwidth / 2)
    )
end
