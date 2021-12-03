
--[[

 Core:
 *****

    --------------------------------------
    |                                    |
    |                                    |
    |  |\   |\   |\   |\   |\   |\   |\  |
    ---| o--| o--| o--| o--| o--| o--| o--
       |/   |/   |/   |/   |/   |/   |/   

        \-------------v--------------/
                   'numinv'

 Inverter:
 *********
                       VDD
                        |
                    |---|
                ---o|    
                |   |---|
         in o---|       *---o out
                |   |---|
                ----|    
                    |---|
                        |
                       VSS


    All transistors with 'invfingers' fingers
--]]
function parameters()
    pcell.reference_cell("basic/cmos")
    pcell.reference_cell("basic/mosfet")
    pcell.add_parameters(
        { "invfingers", 2, posvals = even() },
        { "numinv", 3, posvals = odd() },
        { "glength",             200 },
        { "gspace",              140 },
        { "pfingerwidth",        500 },
        { "nfingerwidth",        500 },
        { "separation",          400 },
        { "gstwidth",             60 },
        { "sdwidth",              60 },
        { "powerwidth",          200 },
        { "powerspace",          120 }
    )
end

function layout(oscillator, _P)
    local cbp = pcell.get_parameters("basic/cmos")
    local xpitch = _P.glength + _P.gspace

    pcell.push_overwrites("basic/mosfet", {
        gatelength = _P.glength,
        gatespace = _P.gspace,
    })
    pcell.push_overwrites("basic/cmos", {
        nvthtype = 3,
        pvthtype = 3,
        separation = _P.separation,
        pwidth = _P.pfingerwidth,
        nwidth = _P.nfingerwidth,
        powerwidth = _P.powerwidth,
        powerspace = _P.powerspace,
        gstwidth = _P.gstwidth,
        sdwidth = _P.sdwidth,
    })

    -- place inverter cells
    local invgatecontacts = {}
    for i = 1, _P.invfingers do
        invgatecontacts[i] = "center"
    end
    local invactivecontacts = {}
    for i = 1, _P.invfingers + 1 do
        if i % 2 == 0 then
            invactivecontacts[i] = "inner"
        else
            invactivecontacts[i] = "power"
        end
    end
    local inverterref = pcell.create_layout("basic/cmos", { 
        gatecontactpos = invgatecontacts, 
        pcontactpos = invactivecontacts, 
        ncontactpos = invactivecontacts,
    })
    inverterref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        inverterref:get_anchor("Gll1"),
        inverterref:get_anchor(string.format("Gur%d", _P.invfingers))
    ))
    inverterref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        inverterref:get_anchor(string.format("pSDi%d", 2)),
        inverterref:get_anchor(string.format("pSDi%d", _P.invfingers)):translate(3 * xpitch / 2, _P.gstwidth)
    ))
    inverterref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        inverterref:get_anchor(string.format("nSDi%d", 2)):translate(0, -_P.gstwidth),
        inverterref:get_anchor(string.format("nSDi%d", _P.invfingers)):translate(3 * xpitch / 2, 0)
    ))
    inverterref:merge_into_shallow(geometry.rectanglebltr(generics.metal(1), 
        inverterref:get_anchor(string.format("nSDi%d", _P.invfingers)):translate(3 * xpitch / 2 - _P.gstwidth / 2, -_P.gstwidth),
        inverterref:get_anchor(string.format("pSDi%d", _P.invfingers)):translate(3 * xpitch / 2 + _P.gstwidth / 2,  _P.gstwidth)
    ))
    local invname = pcell.add_cell_reference(inverterref, "inverter")
    local inverters = {}
    for i = 1, _P.numinv do
        inverters[i] = oscillator:add_child(invname)
        if i > 1 then
            inverters[i]:move_anchor("left", inverters[i - 1]:get_anchor("right"))
        end
    end

    -- feedback connection
    oscillator:merge_into_shallow(geometry.path(generics.metal(2), {
            inverters[_P.numinv]:get_anchor(string.format("Gcc%d", _P.invfingers)):translate(xpitch, 0),
            inverters[1]:get_anchor("Gcc1"):translate(-_P.glength / 2, 0)
        }, _P.gstwidth)
    )
    oscillator:merge_into_shallow(
        geometry.rectangle(generics.via(1, 2), _P.gstwidth, _P.separation + 2 * _P.gstwidth)
        :translate(inverters[_P.numinv]:get_anchor(string.format("Gcc%d", _P.invfingers)):translate(xpitch, 0))
    )
    oscillator:merge_into_shallow(geometry.rectanglebltr(generics.via(1, 2), 
        inverters[1]:get_anchor("Gll1"),
        inverters[1]:get_anchor(string.format("Gur%d", _P.invfingers))
    ))

    local width = point.xdistance(inverters[_P.numinv]:get_anchor("PRpur"), inverters[1]:get_anchor("PRpul"))
    local welltapp = pcell.create_layout("auxiliary/welltap", {
        contype = "n",
        width = width,
        height = _P.powerwidth,
        extension = 50,
    })
    welltapp:move_anchor("bottomleft", inverters[1]:get_anchor("PRpll"))
    oscillator:merge_into_shallow(welltapp)
    local welltapn = pcell.create_layout("auxiliary/welltap", {
        contype = "p",
        width = width,
        height = _P.powerwidth,
        extension = 50,
    })
    welltapn:move_anchor("topleft", inverters[1]:get_anchor("PRnul"))
    oscillator:merge_into_shallow(welltapn)

    --[[
    -- place guardring
    local ringwidth = 200
    local pguardringname = pcell.add_cell_reference(pcell.create_layout("auxiliary/guardring", { 
        contype = "p",
        fillwell = true,
        ringwidth = ringwidth,
        width = (_P.numinv * _P.invfingers + 4) * xpitch, 
        height = 6 * _P.separation + _P.pfingerwidth + _P.nfingerwidth + ringwidth
    }), "pguardring")
    local nguardringname = pcell.add_cell_reference(pcell.create_layout("auxiliary/guardring", { 
        contype = "n",
        fillwell = false,
        drawdeepwell = true,
        ringwidth = ringwidth,
        width = (_P.numinv * _P.invfingers + 4) * xpitch + 2 * _P.separation + 2 * ringwidth,
        height = 8 * _P.separation + _P.pfingerwidth + _P.nfingerwidth + ringwidth + 2 * ringwidth
    }), "nguardring")
    oscillator:add_child(pguardringname)
    oscillator:add_child(nguardringname)
    --]]

    -- ports
    oscillator:add_port("vdd", generics.metal(1), inverters[1]:get_anchor("top"))
    oscillator:add_port("vss", generics.metal(1), inverters[1]:get_anchor("bottom"))
    oscillator:add_port("vout", generics.metal(1), inverters[_P.numinv]:get_anchor(string.format("Gcc%d", _P.invfingers)):translate(xpitch, 0))

    -- center oscillator
    oscillator:translate(-(_P.numinv - 1) * _P.invfingers * xpitch / 2, 0)
end
