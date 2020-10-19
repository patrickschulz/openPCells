do
    local cells = {
        { name = "analog/cross_coupled_pair",   result = true },
        { name = "analog/currentmirror",        result = true },
        { name = "auxiliary/guardring",         result = true },
        { name = "auxiliary/pads",              result = true },
        { name = "auxiliary/text",              result = true },
        { name = "basic/transistor_array",      result = true },
        { name = "basic/transistor",            result = true },
        { name = "logic/and_gate",              result = true },
        { name = "logic/_base",                 result = false },
        { name = "logic/harness",               result = true },
        { name = "logic/nand_gate",             result = true },
        { name = "logic/nor_gate",              result = true },
        { name = "logic/not_gate",              result = true },
        { name = "passive/circular_inductor",   result = true },
        { name = "passive/momcap",              result = true },
        { name = "passive/octagonal_inductor",  result = true },
        { name = "passive/spiral_inductor",     result = true },
    }
    for _, cell in ipairs(cells) do
        local status, msg = pcall(pcell.create_layout, cell.name)
        report(cell.name, status == cell.result, msg)
    end
end
