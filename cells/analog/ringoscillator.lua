
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
    pcell.add_parameters(
        { "invfingers", 4, posvals = even() },
        { "numinv", 3, posvals = odd() },
        { "invdummies", 1 },
        { "glength",             technology.get_dimension("Minimum Gate Length") },
        { "gspace",              technology.get_dimension("Minimum Gate Space") },
        { "pfingerwidth",        2 * technology.get_dimension("Minimum Gate Width") },
        { "nfingerwidth",        2 * technology.get_dimension("Minimum Gate Width") },
        { "gstwidth",             technology.get_dimension("Minimum M1 Width") },
        { "gstspace",             technology.get_dimension("Minimum M1 Space") },
        { "sdwidth",              technology.get_dimension("Minimum M1 Width") },
        { "powerwidth",          3 * technology.get_dimension("Minimum M1 Width") },
        { "powerspace",          3 * technology.get_dimension("Minimum M1 Space") }
    )
end

function layout(oscillator, _P)
    local cbp = pcell.get_parameters("basic/cmos")
    local xpitch = _P.glength + _P.gspace

    pcell.push_overwrites("basic/cmos", {
        gatelength = _P.glength,
        gatespace = _P.gspace,
        nvthtype = 1,
        pvthtype = 1,
        separation = 2 * _P.gstspace + _P.gstwidth,
        pwidth = _P.pfingerwidth,
        nwidth = _P.nfingerwidth,
        powerwidth = _P.powerwidth,
        ppowerspace = _P.powerspace,
        npowerspace = _P.powerspace,
        gstwidth = _P.gstwidth,
        gstspace = _P.gstspace,
        sdwidth = _P.sdwidth,
    })

    -- place inverter cells
    local invgatecontacts = {}
    for i = 1, _P.invdummies do
        invgatecontacts[i] = "dummy"
        invgatecontacts[_P.invdummies + _P.invfingers + i] = "dummy"
    end
    for i = 1, _P.invfingers do
        invgatecontacts[_P.invdummies + i] = "center"
    end
    local invactivecontacts = {}
    for i = 1, _P.invdummies do
        invactivecontacts[i] = "power"
        invactivecontacts[_P.invdummies + _P.invfingers + i + 1] = "power"
    end
    for i = 1, _P.invfingers + 1 do
        if i % 2 == 0 then
            invactivecontacts[_P.invdummies + i] = "inner"
        else
            invactivecontacts[_P.invdummies + i] = "power"
        end
    end
    local inverterref = pcell.create_layout("basic/cmos", "inverter", { 
        gatecontactpos = invgatecontacts, 
        pcontactpos = invactivecontacts, 
        ncontactpos = invactivecontacts,
    })
    pcell.pop_overwrites("basic/cmos")

    geometry.rectanglebltr(inverterref, generics.metal(1), 
        inverterref:get_anchor(string.format("G%dll", _P.invdummies + 1)),
        inverterref:get_anchor(string.format("G%dur", _P.invdummies + _P.invfingers))
    )
    geometry.cshape(inverterref, generics.metal(1), 
        inverterref:get_anchor(string.format("pSDi%d", _P.invdummies + 2)):translate(0,  _P.sdwidth / 2),
        inverterref:get_anchor(string.format("nSDi%d", _P.invdummies + 2)):translate(0, -_P.sdwidth / 2),
        (_P.invfingers - 1) * xpitch,
        _P.sdwidth
    )
    local inverters = {}
    for i = 1, _P.numinv do
        inverters[i] = oscillator:add_child(inverterref, string.format("inverter_%d", i))
        if i > 1 then
            inverters[i]:move_anchor("left", inverters[i - 1]:get_anchor("right"))
        end
    end

    -- feedback connection
    geometry.path(oscillator, generics.metal(2), {
            (inverters[_P.numinv]:get_anchor(string.format("nSDi%d", _P.invdummies + _P.invfingers)):translate(xpitch - _P.gstwidth / 2, 0) +
            inverters[_P.numinv]:get_anchor(string.format("pSDi%d", _P.invdummies + _P.invfingers)):translate(xpitch + _P.gstwidth / 2, 0)),
            inverters[1]:get_anchor(string.format("G%dcc", _P.invdummies + 1)):translate(-_P.glength / 2, 0)
        }, _P.gstwidth
    )
    geometry.viabltr(
        oscillator, 1, 2, 
        inverters[_P.numinv]:get_anchor(string.format("nSDi%d", _P.invdummies + _P.invfingers)):translate(xpitch - _P.gstwidth / 2, 0),
        inverters[_P.numinv]:get_anchor(string.format("pSDi%d", _P.invdummies + _P.invfingers)):translate(xpitch + _P.gstwidth / 2, 0)
    )
    geometry.viabltr(
        oscillator, 1, 2,
        inverters[1]:get_anchor(string.format("G%dll", _P.invdummies + 1)),
        inverters[1]:get_anchor(string.format("G%dur", _P.invdummies + _P.invfingers))
    )

    local width = point.xdistance(inverters[_P.numinv]:get_anchor("PRpur"), inverters[1]:get_anchor("PRpul"))
    local pwelltap = pcell.create_layout("auxiliary/welltap", "nwelltap", {
        contype = "n",
        width = width,
        height = _P.powerwidth,
        extension = 50,
    })
    pwelltap:move_anchor("bottomleft", inverters[1]:get_anchor("PRpll"))
    oscillator:merge_into(pwelltap)
    local nwelltap = pcell.create_layout("auxiliary/welltap", "nwelltap", {
        contype = "p",
        width = width,
        height = _P.powerwidth,
        extension = 50,
    })
    nwelltap:move_anchor("topleft", inverters[1]:get_anchor("PRnul"))
    oscillator:merge_into(nwelltap)

    --[[
    -- place guardring
    local ringwidth = 200
    local pguardring = pcell.create_layout("auxiliary/guardring", "pguardring", { 
        contype = "p",
        fillwell = true,
        ringwidth = ringwidth,
        width = (_P.numinv * _P.invfingers + 4) * xpitch, 
        height = 6 * _P.separation + _P.pfingerwidth + _P.nfingerwidth + ringwidth
    })
    local nguardring = pcell.create_layout("auxiliary/guardring", "nguardring", { 
        contype = "n",
        fillwell = false,
        drawdeepwell = true,
        ringwidth = ringwidth,
        width = (_P.numinv * _P.invfingers + 4) * xpitch + 2 * _P.separation + 2 * ringwidth,
        height = 8 * _P.separation + _P.pfingerwidth + _P.nfingerwidth + ringwidth + 2 * ringwidth
    })
    oscillator:add_child(pguardring, "pguardring")
    oscillator:add_child(nguardring, "nguardring")
    --]]

    -- ports
    oscillator:add_port("vdd", generics.metal(1), inverters[1]:get_anchor("top"))
    oscillator:add_port("vss", generics.metal(1), inverters[1]:get_anchor("bottom"))
    oscillator:add_port("vout", generics.metal(1), inverters[_P.numinv]:get_anchor(string.format("G%dcc", _P.invfingers)):translate(xpitch, 0))

    -- center oscillator
    oscillator:translate(-(_P.numinv - 1) * _P.invfingers * xpitch / 2, 0)
end
