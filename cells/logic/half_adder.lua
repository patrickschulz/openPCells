--[[
        A ----- XOR 
                XOR ---- S 
        B ----- XOR

        A ----- AND
                AND ---- C
        B ----- AND
]] -- 
function parameters() pcell.reference_cell("logic/base") end
function layout(gate, _P)
    local bp = pcell.get_parameters("logic/base")

    local xpitch = bp.gspace + bp.glength

    -- create xorgate
    local xorgate = pcell.create_layout("logic/xor_gate"):move_anchor("right")
    gate:merge_into(xorgate)

    -- create andgate
    local andgate = pcell.create_layout("logic/and_gate"):move_anchor("left",
                                                                      xorgate:get_anchor(
                                                                          "right"))
    gate:merge_into(andgate)

    -- draw connections
    gate:merge_into(geometry.path(generics.metal(1), {
        xorgate.get_anchor("A"), andgate.get_anchor("A")
    }, bp.sdwidth))
    gate:merge_into(geometry.path(generics.metal(1), {
        xorgate.get_anchor("B"), andgate.get_anchor("B")
    }, bp.sdwidth))

    -- draw ports
    gate:add_port("A", generics.metal(1), xorgate:get_anchor("A"))
    gate:add_port("B", generics.metal(1), xorgate:get_anchor("B"))
    gate:add_port("S", generics.metal(1), xorgate:get_anchor("Z"))
    gate:add_port("C", generics.metal(1), andgate:get_anchor("Z"))
    gate:add_port("VDD", generics.metal(1), point.create(0, bp.separation / 2 +
                                                             bp.pwidth +
                                                             bp.powerspace +
                                                             bp.powerwidth / 2))
    gate:add_port("VSS", generics.metal(1), point.create(0, -bp.separation / 2 -
                                                             bp.nwidth -
                                                             bp.powerspace -
                                                             bp.powerwidth / 2))

end
