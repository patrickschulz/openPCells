function parameters()
    pcell.add_parameters(
        { "invfingers", 4 },
        { "resfingers", 50 }
    )
end

function layout(oscillator, _P)
    local gatecontacts = util.fill_all_with(_P.invfingers, "center")
    local npcontacts = util.fill_even_with(_P.invfingers + 1, "inner", "power")
    pcell.push_overwrites("basic/mosfet", { 
        gatelength = 40, 
        gatespace = 90, 
    })
    local cmosref = pcell.create_layout("basic/cmos", "mosfets", { 
        gatecontactpos = gatecontacts, 
        pcontactpos = npcontacts, 
        ncontactpos = npcontacts, 
        separation = 400, 
    })

    local resref = pcell.create_layout("basic/polyresistor", "resistor", { nxfingers = _P.resfingers, nyfingers = 2, dummies = 0, xspace = 90, contactheight = 200, extension = 300 })

    local moscore = oscillator:add_child(cmosref, "moscore")
    local polyres = oscillator:add_child(resref, "resistor")
end
