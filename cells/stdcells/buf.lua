function parameters()
    pcell.add_parameters(
        { "ifingers", 1 },
        { "ofingers", 1 },
        { "shiftinput1", 0 },
        { "shiftinput2", 0 }
    )
    pcell.inherit_parameters("stdcells/base")
end

function layout(gate, _P)
    local baseparameters = {}
    for name, value in pairs(_P) do
        if pcell.has_parameter("stdcells/not_gate", name) then
            baseparameters[name] = value
        end
    end
    local iinv = pcell.create_layout("stdcells/not_gate", "iinv", util.add_options(baseparameters, { 
        fingers = _P.ifingers, 
        shiftinput = _P.shiftinput1, 
        shiftoutput = _P.gatelength / 2 + _P.gatespace / 2 
    }))

    local oinv = pcell.create_layout("stdcells/not_gate", "oinv", util.add_options(baseparameters, { 
        fingers = _P.ofingers, 
        shiftinput = _P.shiftinput2, 
        shiftoutput = _P.gatelength / 2 + _P.gatespace / 2 
    }))
    oinv:abut_right(iinv)
    gate:merge_into(iinv)
    gate:merge_into(oinv)

    -- draw connection
    local ishift = _P.ifingers % 2 == 0 and 0 or 1
    geometry.rectanglebltr(gate, generics.metal(1), 
        iinv:get_area_anchor("O").br,
        oinv:get_area_anchor("I").tl
    )

    gate:inherit_alignment_box(iinv)
    gate:inherit_alignment_box(oinv)

    -- anchors
    gate:inherit_area_anchor(iinv, "I")
    gate:inherit_area_anchor(iinv, "O")
    gate:inherit_area_anchor(oinv, "O")

    -- ports
    gate:add_port("I", generics.metalport(1), iinv:get_area_anchor("I").bl)
    gate:add_port("O", generics.metalport(1), oinv:get_area_anchor("O").bl)
    gate:add_port("VDD", generics.metalport(1), oinv:get_area_anchor("VDD").bl)
    gate:add_port("VSS", generics.metalport(1), oinv:get_area_anchor("VSS").bl)
end
