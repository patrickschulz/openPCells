function parameters()
    pcell.add_parameter("fingers", 1)
    pcell.add_parameter("shiftoutput", 0)
    pcell.inherit_parameters("stdcells/base")
end

function layout(gate, _P)
    local baseparameters = {}
    for k, v in pairs(_P) do
        if pcell.has_parameter("stdcells/nand_nor_layout_base", k) then
            baseparameters[k] = v
        end
    end
    local base = pcell.create_layout("stdcells/nand_nor_layout_base", "nand_gate", util.add_options(baseparameters, {
        fingers = _P.fingers,
        gatetype = "nor",
        shiftoutput = _P.shiftoutput
    }))
    gate:exchange(base)
end
