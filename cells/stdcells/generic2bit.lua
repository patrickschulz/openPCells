function parameters()
    pcell.reference_cell("stdcells/base")
    pcell.add_parameter("fingers", 1)
    pcell.add_parameter("bitpattern", { 0, 1, 1, 0 } )
end

function layout(gate, _P)
    local bp = pcell.get_parameters("stdcells/base")
    local base = pcell.create_layout("stdcells/nand_nor_layout_base", { fingers = _P.fingers, gatetype = "nand" })
    gate:merge_into_shallow(base)

    -- ports
    gate:add_port("A", generics.metal(1), base:get_anchor("A"))
    gate:add_port("B", generics.metal(1), base:get_anchor("B"))
    gate:add_port("Z", generics.metal(1), base:get_anchor("Z"))
    gate:add_port("VDD", generics.metal(1), base:get_anchor("VDD"))
    gate:add_port("VSS", generics.metal(1), base:get_anchor("VSS"))
end
