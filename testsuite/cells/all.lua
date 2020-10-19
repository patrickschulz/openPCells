do
    local cells = {
        "analog/cross_coupled_pair",
        "analog/currentmirror",
        "analog/ota",
        "auxiliary/groundmesh",
        "auxiliary/guardring",
        "auxiliary/pads",
        "auxiliary/text",
        "basic/transistor_array",
        "basic/transistor",
        "logic/and_gate",
        "logic/_base",
        "logic/harness",
        "logic/nand_gate",
        "logic/nor_gate",
        "logic/not_gate",
        "passive/circular_inductor",
        "passive/momcap",
        "passive/octagonal_inductor",
        "passive/polyresistor",
        "passive/spiral_inductor",
    }
    for _, cell in ipairs(cells) do
        local status, msg = pcall(pcell.create_layout, cell)
        report(cell, status, msg)
    end
end
