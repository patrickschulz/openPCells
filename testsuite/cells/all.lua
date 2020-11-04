-- luacheck: globals report
do
    local cells = {
        { name = "analog/cross_coupled_pair",   result =  true },
        { name = "analog/currentmirror",        result =  true },
        { name = "auxiliary/guardring",         result =  true },
        { name = "auxiliary/pads",              result =  true },
        { name = "auxiliary/text",              result =  true },
        { name = "basic/transistor_array",      result =  true },
        { name = "basic/transistor",            result =  true },
        { name = "logic/and_gate",              result =  true },
        { name = "logic/_base",                 result = false }, -- abstract cell
        { name = "logic/_harness",              result =  true },
        { name = "logic/nand_gate",             result =  true },
        { name = "logic/nor_gate",              result =  true },
        { name = "logic/not_gate",              result =  true },
        { name = "logic/and_gate",              result =  true },
        { name = "logic/or_gate",               result =  true },
        { name = "logic/buf",                   result =  true },
        { name = "passive/inductor/circular",   result =  true },
        { name = "passive/inductor/octagonal",  result =  true },
        { name = "passive/inductor/spiral",     result =  true },
        { name = "passive/capacitor/mom",       result =  true },
    }
    for _, cell in ipairs(cells) do
        local status, msg = pcall(pcell.create_layout, cell.name)
        report(cell.name, status == cell.result, msg)
    end
end
