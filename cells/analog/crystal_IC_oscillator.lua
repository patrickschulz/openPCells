function parameters()
    pcell.add_parameters(
        { "invfingers", 4 },
        { "resfingers", 50 }
    )
end

function layout(oscillator, _P)
    local gatecontacts = util.fill_all_with(_P.invfingers, "center")
    local npcontacts = util.fill_even_with(_P.invfingers + 1, "inner", "power")
    local cmosref = pcell.create_layout("basic/cmos", { 
        gatecontactpos = gatecontacts, 
        pcontactpos = npcontacts, 
        ncontactpos = npcontacts, 
        fingers = _P.invfingers, 
        glength = 40, 
        gspace = 90, 
        separation = 400, 
        pvthtype = 3, 
        nvthtype = 2,
    })
    local cmosname = pcell.add_cell_reference(cmosref, "moscore")

    local resref = pcell.create_layout("basic/polyresistor", { nxfingers = _P.resfingers, nyfingers = 2, dummies = 0, xspace = 90, contactheight = 200, extension = 300 })
    local resname = pcell.add_cell_reference(resref, "resistor")

    local moscore = oscillator:add_child(cmosname)
    local polyres = oscillator:add_child(resname)
    polyres:move_anchor("left", moscore:get_anchor("right"))
    polyres:translate((40 + 90) / 2, 0)
end
