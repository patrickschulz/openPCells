function parameters()
    pcell.reference_cell("logic/base")
    pcell.add_parameters(
        { "ifingers", 1 },
        { "ofingers", 1 },
        { "shiftinput1", 0 },
        { "shiftinput2", 0 }
    )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")

    pcell.push_overwrites("logic/base", {
        rightdummies = _P.ifingers % 2 == 0 and 0 or 1
    })
    local iinv = pcell.create_layout("logic/not_gate", { 
        fingers = _P.ifingers, 
        shiftinput = _P.shiftinput1, 
        shiftoutput = bp.glength / 2 + bp.gspace / 2 
    }):move_anchor("right")
    pcell.pop_overwrites("logic/base")

    pcell.push_overwrites("logic/base", {
        leftdummies = 0,
    })
    local oinv = pcell.create_layout("logic/not_gate", { 
        fingers = _P.ofingers, 
        shiftinput = _P.shiftinput2, 
        shiftoutput = bp.glength / 2 + bp.gspace / 2 
    }):move_anchor("left")
    pcell.pop_overwrites("logic/base")
    gate:merge_into(iinv)
    gate:merge_into(oinv)

    -- draw connection
    local ishift = _P.ifingers % 2 == 0 and 0 or 1
    gate:merge_into(geometry.path_yx(generics.metal(1), {
        iinv:get_anchor("O"),
        oinv:get_anchor("I"),
    }, bp.sdwidth))

    gate:set_alignment_box(
        iinv:get_anchor("bottomleft"),
        oinv:get_anchor("topright")
    )

    -- anchors
    gate:add_anchor("in", iinv:get_anchor("I"))
    gate:add_anchor("iout", iinv:get_anchor("O"))
    gate:add_anchor("bout", oinv:get_anchor("O"))

    gate:add_anchor("OTR", oinv:get_anchor("OTRc"))
    gate:add_anchor("OBR", oinv:get_anchor("OBRc"))

    -- ports
    gate:add_port("I", generics.metal(1), iinv:get_anchor("I"))
    gate:add_port("O", generics.metal(1), oinv:get_anchor("O"))
    gate:add_port("VDD", generics.metal(1), oinv:get_anchor("VDD"))
    gate:add_port("VSS", generics.metal(1), oinv:get_anchor("VSS"))
end
