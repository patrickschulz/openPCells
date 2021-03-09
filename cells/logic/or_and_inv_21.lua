--[[
        B1 ---- OR 
                OR 
        B2 ---- OR ---- NAND
                        NAND ---- Z
        A  ------------ NAND
]] -- 
function parameters() pcell.reference_cell("logic/base") end

function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base");

    local xpitch = bp.gspace + bp.glength

    -- general settings
    pcell.push_overwrites("logic/base", {leftdummies = 0, rightdummies = 0})

    -- or gate
    local orgate = pcell.create_layout("logic/or_gate"):move_anchor("right")
    gate:merge_into(orgate)

    -- nand gate
    local nandgate = pcell.create_layout("logic/nand_gate"):move_anchor("left",
                                                                        orgate:get_anchor(
                                                                            "right"))
    gate:merge_into(nandgate)

   --  draw connections
    gate:merge_into(geometry.path(generics.metal(1), {
        orgate:get_anchor("Z"), nandgate:get_anchor("B")
    }, bp.sdwidth))

    gate:inherit_alignment_box(orgate)
    gate:inherit_alignment_box(nandgate)

    -- ports
    gate:add_port("A", generics.metal(1), nandgate:get_anchor("A"))
    gate:add_port("B1", generics.metal(1), orgate:get_anchor("A"))
    gate:add_port("B2", generics.metal(1), orgate:get_anchor("B"))
    gate:add_port("Z", generics.metal(2), nandgate:get_anchor("Z"))
    gate:add_port("VDD", generics.metal(1), point.create(0, bp.separation / 2 +
                                                             bp.pwidth +
                                                             bp.powerspace +
                                                             bp.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -bp.separation / 2 -
                                                             bp.nwidth -
                                                             bp.powerspace -
                                                             bp.powerwidth / 2))

end
