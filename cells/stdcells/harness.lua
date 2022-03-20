function config()
    pcell.reference_cell("basic/mosfet")
    pcell.reference_cell("stdcells/base")
    pcell.set_property("hidden", true)
end

function parameters()
    pcell.add_parameters(
        { "drawtransistors", true },
        { "drawactive", true },
        { "drawrails", true },
        { "drawgatecontacts", true },
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
        { "drawtopgcut", true },
        { "drawbotgcut", true }
    )
end

function layout(gate, _P)
    local tp = pcell.get_parameters("basic/mosfet")
    local bp = pcell.get_parameters("stdcells/base")
    local xpitch = bp.gspace + bp.glength
    local xshift = (bp.rightdummies - bp.leftdummies) * xpitch / 2
    local separation = bp.numinnerroutes * bp.gstwidth + (bp.numinnerroutes + 1) * bp.gstspace
    local fingers = #_P.gatecontactpos

    -- common transistor options
    pcell.push_overwrites("basic/mosfet", {
        gatelength = bp.glength,
        gatespace = bp.gspace,
        sdwidth = bp.sdwidth,
        drawinnersourcedrain = "none",
        drawoutersourcedrain = "none",
        drawactive = _P.drawactive
    })

    if _P.drawtransistors then
        local ext = math.max(tp.cutheight / 2 + bp.gateext, bp.dummycontheight / 2)

        -- pmos
        pcell.push_overwrites("basic/mosfet", {
            channeltype = "pmos",
            vthtype = bp.pvthtype,
            fwidth = bp.pwidth,
            gbotext = separation / 2,
            gtopext = bp.powerspace + bp.powerwidth / 2 + ext,
            topgcutoffset = ext,
            clipbot = true,
        })
        -- main
        local pmos
        if fingers > 0 then
            pmos = pcell.create_layout("basic/mosfet", { fingers = fingers }):move_anchor("botgate")
            gate:merge_into_shallow(pmos)
        end
        -- left dummy
        if bp.leftdummies > 0 then
            gate:merge_into_shallow(
                pcell.create_layout("basic/mosfet", { fingers = bp.leftdummies, drawtopgcut = bp.drawdummygcut, drawbotgcut = true }
            ):move_anchor("rightbotgate", pmos and pmos:get_anchor("leftbotgate") or nil))
        end
        -- rightdummy
        if bp.rightdummies > 0 then
            gate:merge_into_shallow(
                pcell.create_layout("basic/mosfet", { fingers = bp.rightdummies, drawtopgcut = bp.drawdummygcut, drawbotgcut = true }
            ):move_anchor("leftbotgate", pmos and pmos:get_anchor("rightbotgate") or nil))
        end
        pcell.pop_overwrites("basic/mosfet")

        -- nmos
        pcell.push_overwrites("basic/mosfet", {
            channeltype = "nmos",
            vthtype = bp.nvthtype,
            fwidth = bp.nwidth,
            gtopext = separation / 2,
            gbotext = bp.powerspace + bp.powerwidth / 2 + ext,
            botgcutoffset = ext,
            cliptop = true,
        })
        local nmos
        -- main
        if fingers > 0 then
            nmos = pcell.create_layout("basic/mosfet", { fingers = fingers }):move_anchor("topgate")
            gate:merge_into_shallow(nmos)
        end
        -- left dummy
        if bp.leftdummies > 0 then
            gate:merge_into_shallow(
                pcell.create_layout("basic/mosfet", { fingers = bp.leftdummies, drawbotgcut = bp.drawdummygcut, drawtopgcut = true }
            ):move_anchor("righttopgate", nmos and nmos:get_anchor("lefttopgate") or nil))
        end
        -- rightdummy
        if bp.rightdummies > 0 then
            gate:merge_into_shallow(
                pcell.create_layout("basic/mosfet", { fingers = bp.rightdummies, drawbotgcut = bp.drawdummygcut, drawtopgcut = true }
            ):move_anchor("lefttopgate", nmos and nmos:get_anchor("righttopgate") or nil))
        end
        pcell.pop_overwrites("basic/mosfet")
    end

    -- power rails
    if _P.drawrails then
        geometry.rectangle(
            gate, generics.metal(1), 
            (fingers + bp.leftdummies + bp.rightdummies) * xpitch + bp.sdwidth, bp.powerwidth,
            xshift, (bp.pwidth - bp.nwidth) / 2,
            1, 2, 0, separation + bp.pwidth + bp.nwidth + 2 * bp.powerspace + bp.powerwidth
        )
    end

    -- draw gate contacts
    if _P.drawgatecontacts then
        for i = 1, fingers do
            local x = (2 * i - fingers - 1 + bp.leftdummies - bp.rightdummies) * xpitch / 2 + xshift
            local routingshift = (bp.gstwidth + bp.gstspace) / (bp.numinnerroutes % 2 == 0 and 2 or 1)
            if _P.gatecontactpos[i] == "center" then
                local pt = point.create(x, _P.shiftgatecontacts)
                geometry.contactbltr(gate, "gate", 
                    point.create(x - bp.glength / 2, _P.shiftgatecontacts - bp.gstwidth / 2),
                    point.create(x + bp.glength / 2, _P.shiftgatecontacts + bp.gstwidth / 2)
                )
                gate:add_anchor(string.format("G%d", i), pt)
            elseif _P.gatecontactpos[i] == "upper" then
                local pt = point.create(x, routingshift + _P.shiftgatecontacts)
                geometry.contactbltr(
                    gate, "gate", 
                    point.create(x - bp.glength / 2, routingshift + _P.shiftgatecontacts - bp.gstwidth / 2),
                    point.create(x + bp.glength / 2, routingshift + _P.shiftgatecontacts + bp.gstwidth / 2)
                )
                gate:add_anchor(string.format("G%d", i), pt)
            elseif _P.gatecontactpos[i] == "lower" then
                local pt = point.create(x, -routingshift + _P.shiftgatecontacts)
                geometry.contactbltr(
                    gate, "gate", 
                    point.create(x - bp.glength / 2, -routingshift + _P.shiftgatecontacts - bp.gstwidth / 2),
                    point.create(x + bp.glength / 2, -routingshift + _P.shiftgatecontacts + bp.gstwidth / 2)
                )
                gate:add_anchor(string.format("G%d", i), pt)
            elseif _P.gatecontactpos[i] == "split" then
                local y = _P.shiftgatecontacts
                geometry.multiple_y(
                    function(yi)
                        geometry.contactbltr(
                            gate, "gate", 
                            point.create(x - bp.glength / 2, y + yi - bp.gstwidth / 2),
                            point.create(x + bp.glength / 2, y + yi + bp.gstwidth / 2)
                        )
                    end,
                    2, 2 * routingshift
                )
                gate:add_anchor(string.format("G%d", i), point.create(x, y))
                gate:add_anchor(string.format("G%dupper", i), point.create(x, y + routingshift))
                gate:add_anchor(string.format("G%dlower", i), point.create(x, y - routingshift))
                geometry.rectangle(gate, generics.other("gatecut"), xpitch, tp.cutheight, x, 0)
            elseif _P.gatecontactpos[i] == "dummy" then
                local pt = point.create(x, _P.shiftgatecontacts)
                geometry.multiple_y(
                    function(yi)
                        geometry.contactbltr(
                            gate, "gate", 
                            point.create(x - bp.glength / 2, (bp.pwidth - bp.nwidth) / 2 + yi - bp.dummycontheight / 2),
                            point.create(x + bp.glength / 2, (bp.pwidth - bp.nwidth) / 2 + yi + bp.dummycontheight / 2)
                        )
                    end,
                    2, separation + bp.pwidth + bp.nwidth + 2 * bp.powerspace + bp.powerwidth
                )
                geometry.rectangle(gate, generics.other("gatecut"), xpitch, tp.cutheight, x, 0)
            end
            if _P.gatecontactpos[i] ~= "dummy" then
                geometry.multiple_y(
                    function(yi)
                        geometry.rectanglebltr(
                            gate, generics.other("gatecut"),
                            point.create(x - xpitch / 2, (bp.pwidth - bp.nwidth) / 2 + yi - tp.cutheight / 2),
                            point.create(x + xpitch / 2, (bp.pwidth - bp.nwidth) / 2 + yi + tp.cutheight / 2)
                        )
                    end,
                    2, separation + bp.pwidth + bp.nwidth + 2 * bp.powerspace + bp.powerwidth
                )
            end
        end
    end
    if _P.drawdummygatecontacts then
        geometry.multiple_xy(
            function(xi, yi)
                geometry.contactbltr(
                    gate, "gate", 
                    point.create(xi - (fingers + bp.rightdummies) * xpitch / 2 + xshift - (bp.glength) / 2, yi + (bp.pwidth - bp.nwidth) / 2 - (bp.dummycontheight) / 2),
                    point.create(xi - (fingers + bp.rightdummies) * xpitch / 2 + xshift + (bp.glength) / 2, yi + (bp.pwidth - bp.nwidth) / 2 + (bp.dummycontheight) / 2)
                )
            end,
            bp.leftdummies, 2, xpitch, separation + bp.pwidth + bp.nwidth + 2 * bp.powerspace + bp.powerwidth
        )
        geometry.multiple_xy(
            function(xi, yi)
                geometry.contactbltr(
                    gate, "gate", 
                    point.create(xi + (fingers + bp.leftdummies) * xpitch / 2 + xshift - (bp.glength) / 2, yi + (bp.pwidth - bp.nwidth) / 2 - (bp.dummycontheight) / 2),
                    point.create(xi + (fingers + bp.leftdummies) * xpitch / 2 + xshift + (bp.glength) / 2, yi + (bp.pwidth - bp.nwidth) / 2 + (bp.dummycontheight) / 2)
                )
            end,
            bp.rightdummies, 2, xpitch, separation + bp.pwidth + bp.nwidth + 2 * bp.powerspace + bp.powerwidth
        )
    end

    -- dummy source/drain contacts
    local pcontactheight = (bp.psdheight > 0) and bp.psdheight or bp.pwidth / 2
    local ncontactheight = (bp.nsdheight > 0) and bp.nsdheight or bp.nwidth / 2
    local pcontactpowerheight = (bp.psdpowerheight > 0) and bp.psdpowerheight or bp.pwidth / 2
    local ncontactpowerheight = (bp.nsdpowerheight > 0) and bp.nsdpowerheight or bp.nwidth / 2
    if _P.drawdummyactivecontacts then
        geometry.multiple_x(
            function(xi, yi)
                geometry.contactbltr(
                    gate, "sourcedrain", 
                    point.create(xi - (fingers + bp.rightdummies + 1) * xpitch / 2 + xshift - (bp.sdwidth) / 2, yi + separation / 2 + bp.pwidth - pcontactpowerheight / 2 - (pcontactpowerheight) / 2),
                    point.create(xi - (fingers + bp.rightdummies + 1) * xpitch / 2 + xshift + (bp.sdwidth) / 2, yi + separation / 2 + bp.pwidth - pcontactpowerheight /2 + (pcontactpowerheight) / 2)
                )
            end,
            bp.leftdummies, xpitch
        )
        geometry.multiple_x(
            function(xi, yi)
                geometry.contactbltr(
                    gate, "sourcedrain", 
                    point.create(xi - (fingers + bp.rightdummies + 1) * xpitch / 2 + xshift - (bp.sdwidth) / 2, yi - separation / 2 - bp.nwidth + ncontactpowerheight / 2 - (ncontactpowerheight) / 2),
                    point.create(xi - (fingers + bp.rightdummies + 1) * xpitch / 2 + xshift + (bp.sdwidth) / 2, yi - separation / 2 - bp.nwidth + ncontactpowerheight /2 + (ncontactpowerheight) / 2)
                )
            end,
            bp.leftdummies, xpitch
        )
        geometry.multiple_xy(
            function(xi, yi)
                geometry.rectanglebltr(
                    gate, generics.metal(1), 
                    point.create(xi - (fingers + bp.rightdummies + 1) * xpitch / 2 + xshift - (bp.sdwidth) / 2, yi + (bp.pwidth - bp.nwidth) / 2 - (bp.powerspace) / 2),
                    point.create(xi - (fingers + bp.rightdummies + 1) * xpitch / 2 + xshift + (bp.sdwidth) / 2, yi + (bp.pwidth - bp.nwidth) / 2 + (bp.powerspace) / 2)
                )
            end,
            bp.leftdummies, 2, xpitch, separation + bp.pwidth + bp.nwidth + bp.powerspace
        )
        geometry.multiple_x(
            function(xi, yi)
                geometry.contactbltr(
                    gate, "sourcedrain", 
                    point.create(xi + (fingers + bp.leftdummies + 1) * xpitch / 2 + xshift - (bp.sdwidth) / 2, yi + separation / 2 + bp.pwidth - pcontactpowerheight / 2 - (pcontactpowerheight) / 2),
                    point.create(xi + (fingers + bp.leftdummies + 1) * xpitch / 2 + xshift + (bp.sdwidth) / 2, yi + separation / 2 + bp.pwidth - pcontactpowerheight /2 + (pcontactpowerheight) / 2)
                )
            end,
            bp.rightdummies, xpitch
        )
        geometry.multiple_x(
            function(xi, yi)
                geometry.contactbltr(
                    gate, "sourcedrain", 
                    point.create(xi + (fingers + bp.leftdummies + 1) * xpitch / 2 + xshift - (bp.sdwidth) / 2, yi - separation / 2 - bp.nwidth + ncontactpowerheight / 2 - (ncontactpowerheight) / 2),
                    point.create(xi + (fingers + bp.leftdummies + 1) * xpitch / 2 + xshift + (bp.sdwidth) / 2, yi - separation / 2 - bp.nwidth + ncontactpowerheight /2 + (ncontactpowerheight) / 2)
                )
            end,
            bp.rightdummies, xpitch
        )
        geometry.multiple_xy(
            function(xi, yi)
                geometry.rectanglebltr(
                    gate, generics.metal(1), 
                    point.create(xi + (fingers + bp.leftdummies + 1) * xpitch / 2 + xshift - (bp.sdwidth) / 2, yi + (bp.pwidth - bp.nwidth) / 2 - (bp.powerspace) / 2),
                    point.create(xi + (fingers + bp.leftdummies + 1) * xpitch / 2 + xshift + (bp.sdwidth) / 2, yi + (bp.pwidth - bp.nwidth) / 2 + (bp.powerspace) / 2)
                )
            end,
            bp.rightdummies, 2, xpitch, separation + bp.pwidth + bp.nwidth + bp.powerspace
        )
    end

    -- draw source/drain contacts
    local indexshift = fingers + 2 + bp.rightdummies - bp.leftdummies
    for i = 1, fingers + 1 do
        local x = (2 * i - indexshift) * xpitch / 2 + xshift
        local y = separation / 2 + bp.pwidth / 2
        -- p contacts
        if _P.pcontactpos[i] == "power" or _P.pcontactpos[i] == "outer" then
            local cheight = _P.pcontactpos[i] == "power" and pcontactpowerheight or pcontactheight
            geometry.contactbltr(
                gate, "sourcedrain", 
                point.create(x - bp.sdwidth / 2, y + bp.pwidth / 2 - _P.shiftpcontactsouter - cheight),
                point.create(x + bp.sdwidth / 2, y + bp.pwidth / 2 - _P.shiftpcontactsouter)
            )
            if _P.pcontactpos[i] == "power" then
                geometry.rectanglebltr(
                    gate, generics.metal(1), 
                    point.create(x - bp.sdwidth / 2, y + bp.pwidth / 2 + bp.powerspace / 2 - _P.shiftpcontactsouter - bp.powerspace / 2),
                    point.create(x + bp.sdwidth / 2, y + bp.pwidth / 2 + bp.powerspace / 2 - _P.shiftpcontactsouter + bp.powerspace / 2)
                )
            end
            gate:add_anchor(string.format("pSDc%d", i), point.create(x, y + bp.pwidth / 2 - cheight / 2 - _P.shiftpcontactsouter))
            gate:add_anchor(string.format("pSDi%d", i), point.create(x, y + bp.pwidth / 2 - cheight - _P.shiftpcontactsouter))
            gate:add_anchor(string.format("pSDo%d", i), point.create(x, y + bp.pwidth / 2 - _P.shiftpcontactsouter))
        elseif _P.pcontactpos[i] == "inner" then
            geometry.contactbltr(
                gate, "sourcedrain", 
                point.create(x - bp.sdwidth / 2, y - bp.pwidth / 2 + pcontactheight / 2 + _P.shiftpcontactsinner - pcontactheight / 2),
                point.create(x + bp.sdwidth / 2, y - bp.pwidth / 2 + pcontactheight / 2 + _P.shiftpcontactsinner + pcontactheight / 2)
            )
            gate:add_anchor(string.format("pSDc%d", i), point.create(x, y - bp.pwidth / 2 + pcontactheight / 2 + _P.shiftpcontactsinner))
            gate:add_anchor(string.format("pSDi%d", i), point.create(x, y - bp.pwidth / 2 + _P.shiftpcontactsinner))
            gate:add_anchor(string.format("pSDo%d", i), point.create(x, y - bp.pwidth / 2 + pcontactheight + _P.shiftpcontactsinner))
        elseif _P.pcontactpos[i] == "full" then
            geometry.contactbltr(
                gate, "sourcedrain", 
                point.create(x - bp.sdwidth / 2, y - bp.pwidth / 2),
                point.create(x + bp.sdwidth / 2, y + bp.pwidth / 2)
            )
            gate:add_anchor(string.format("pSDc%d", i), point.create(x, y))
            gate:add_anchor(string.format("pSDi%d", i), point.create(x, y - bp.pwidth / 2))
            gate:add_anchor(string.format("pSDo%d", i), point.create(x, y + bp.pwidth / 2))
        end
        y = -separation / 2 - bp.nwidth / 2
        -- n contacts
        if _P.ncontactpos[i] == "power" or _P.ncontactpos[i] == "outer" then
            local cheight = _P.ncontactpos[i] == "power" and ncontactpowerheight or ncontactheight
            geometry.contactbltr(
                gate, "sourcedrain", 
                point.create(x - bp.sdwidth / 2, y - bp.nwidth / 2 + cheight / 2 + _P.shiftncontactsouter - cheight / 2),
                point.create(x + bp.sdwidth / 2, y - bp.nwidth / 2 + cheight / 2 + _P.shiftncontactsouter + cheight / 2)
            )
            if _P.ncontactpos[i] == "power" then
                geometry.rectanglebltr(
                    gate, generics.metal(1), 
                    point.create(x - bp.sdwidth / 2, y - bp.nwidth / 2 - bp.powerspace / 2 + _P.shiftncontactsouter - bp.powerspace / 2),
                    point.create(x + bp.sdwidth / 2, y - bp.nwidth / 2 - bp.powerspace / 2 + _P.shiftncontactsouter + bp.powerspace / 2)
                )
            end
            gate:add_anchor(string.format("nSDc%d", i), point.create(x, y - bp.nwidth / 2 + cheight / 2 + _P.shiftncontactsouter))
            gate:add_anchor(string.format("nSDi%d", i), point.create(x, y - bp.nwidth / 2 + cheight + _P.shiftncontactsouter))
            gate:add_anchor(string.format("nSDo%d", i), point.create(x, y - bp.nwidth / 2 + _P.shiftncontactsouter))
        elseif _P.ncontactpos[i] == "inner" then
            geometry.contactbltr(
                gate, "sourcedrain", 
                point.create(x - bp.sdwidth / 2, y + bp.nwidth / 2 - ncontactheight / 2 - _P.shiftncontactsinner - ncontactheight / 2),
                point.create(x + bp.sdwidth / 2, y + bp.nwidth / 2 - ncontactheight / 2 - _P.shiftncontactsinner + ncontactheight / 2)
            )
            gate:add_anchor(string.format("nSDc%d", i), point.create(x, y + bp.nwidth / 2 - ncontactheight / 2- _P.shiftncontactsinner))
            gate:add_anchor(string.format("nSDi%d", i), point.create(x, y + bp.nwidth / 2 - _P.shiftncontactsinner))
            gate:add_anchor(string.format("nSDo%d", i), point.create(x, y + bp.nwidth / 2 - ncontactheight - _P.shiftncontactsinner))
        elseif _P.ncontactpos[i] == "full" then
            geometry.contactbltr(
                gate, "sourcedrain", 
                point.create(x - bp.sdwidth / 2, y - bp.nwidth / 2),
                point.create(x - bp.sdwidth / 2, y - bp.nwidth / 2)
            )
            gate:add_anchor(string.format("nSDc%d", i), point.create(x, y))
            gate:add_anchor(string.format("nSDi%d", i), point.create(x, y + bp.nwidth / 2))
            gate:add_anchor(string.format("nSDo%d", i), point.create(x, y - bp.nwidth / 2))
        end
    end

    -- pop general transistor settings
    pcell.pop_overwrites("basic/mosfet")

    gate:set_alignment_box(
        point.create(-(fingers + bp.leftdummies + bp.rightdummies) * (bp.glength + bp.gspace) / 2 + xshift, -separation / 2 - bp.nwidth - bp.powerspace - bp.powerwidth / 2),
        point.create( (fingers + bp.leftdummies + bp.rightdummies) * (bp.glength + bp.gspace) / 2 + xshift, separation / 2 + bp.pwidth + bp.powerspace + bp.powerwidth / 2)
    )
end
