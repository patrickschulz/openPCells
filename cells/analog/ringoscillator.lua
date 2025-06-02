
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
        { "invfingers",             4, posvals = even() },
        { "numinv",                 3, posvals = odd() },
        { "invdummies",             1 },
        { "gatelength",             technology.get_dimension("Minimum Gate Length") },
        { "gatespace",              technology.get_dimension("Minimum Gate XSpace") },
        { "pfingerwidth",           2 * technology.get_dimension("Minimum Gate Width") },
        { "nfingerwidth",           2 * technology.get_dimension("Minimum Gate Width") },
        { "gatestrapwidth",         technology.get_dimension("Minimum M1 Width") },
        { "gatestrapspace",         technology.get_dimension("Minimum M1 Space") },
        { "sdwidth",                technology.get_dimension("Minimum M1 Width") },
        { "powerwidth",             3 * technology.get_dimension("Minimum M1 Width") },
        { "powerspace",             3 * technology.get_dimension("Minimum M1 Space") },
        { "connectionwidth",        technology.get_dimension("Minimum M1 Width"), follow = "sdwidth" },
        { "feedbackmetal",          3 },
        { "pgateext",               0 },
        { "ngateext",               0 }
    )
end

function layout(oscillator, _P)
    local xpitch = _P.gatelength + _P.gatespace

    local fingers = {}
    for i = 1, _P.numinv do
        table.insert(fingers, _P.invfingers)
    end
    local baseopt = {
        fingers = fingers,
        gatelength = _P.gatelength,
        gatespace = _P.gatespace,
        nvthtype = 1,
        pvthtype = 1,
        pwidth = _P.pfingerwidth,
        nwidth = _P.nfingerwidth,
        powerwidth = _P.powerwidth,
        powerspace = _P.powerspace,
        gatestrapwidth = _P.gatestrapwidth,
        gatestrapspace = _P.gatestrapspace,
        sdwidth = _P.sdwidth,
        outputwidth = _P.connectionwidth,
        pgateext = _P.pgateext,
        ngateext = _P.ngateext,
        numleftdummies = _P.invdummies,
        numrightdummies = _P.invdummies,
    }

    local inverter_chain = pcell.create_layout("analog/inverter_chain", "inverter_chain", util.add_options(baseopt, {
    }))
    oscillator:merge_into(inverter_chain)

    -- feedback connection
    geometry.path(oscillator, generics.metal(_P.feedbackmetal), {
            point.combine(
                inverter_chain:get_area_anchor("output").bl,
                inverter_chain:get_area_anchor("output").tr
            ),
            point.combine(
                inverter_chain:get_area_anchor("input").bl,
                inverter_chain:get_area_anchor("input").tl
            ),
        }, _P.gatestrapwidth
    )
    geometry.viabltr(oscillator, 1, _P.feedbackmetal,
        inverter_chain:get_area_anchor("output").bl,
        inverter_chain:get_area_anchor("output").tr
    )
    geometry.viabltr(oscillator, 1, _P.feedbackmetal,
        inverter_chain:get_area_anchor("input").bl,
        inverter_chain:get_area_anchor("input").tr
    )

    --[=[
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
    --]=]
end
