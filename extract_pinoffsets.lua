local celllist = {
    --"1_inv_gate",
    --"21_gate",
    --"221_gate",
    --"22_gate",
    --"and_gate",
    --"buf",
    --"cinv",
    --"colstop",
    --"dff",
    --"dffnq",
    --"dffpq",
    --"dffprq",
    --"endcell",
    --"generic2bit",
    --"half_adder",
    --"harness",
    --"isogate",
    --"latch_cell",
    --"latch",
    --"leftcolstop",
    "nand_gate",
    --"nand_nor_layout_base",
    "nor_gate",
    "not_gate",
    --"or_gate",
    --"register",
    --"rightcolstop",
    --"rowstop",
    --"shiftregister",
    --"tbuf",
    --"test",
    --"tgate",
    --"xor_gate",
}

local gatelength = 200
local gatespace = 300
local routingwidth = 200
local routingspace = 300

pcell.push_overwrites("stdcells/base", {
    glength = gatelength,
    gspace = gatespace,
    routingwidth = routingwidth,
    routingspace = routingspace
})

for _, cellname in ipairs(celllist) do
    local cell = pcell.create_layout(string.format("stdcells/%s", cellname))

    print(cellname)
    local ports = cell:get_ports()
    for _, port in ipairs(anchors) do
        local x, y = port.anchor:unwrap()
        local xoffset = x // (gatelength + gatespace)
        local yoffset = y // (routingwidth + routingspace)
        print(string.format("%4s (%6d, %6d) -> %3d:%3d", port.name, x, y, xoffset, yoffset))
    end
    print()
end

return nil
