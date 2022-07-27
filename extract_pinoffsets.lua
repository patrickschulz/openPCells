local celllist = {
    --"buf",
    --"cinv",
    --"dffpq",
    --"dffnq",
    --"dffprq",
    "not_gate",
    "nand_gate",
    "nor_gate",
    "or_gate",
    "and_gate",
    --"tbuf",
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
    routingspace = routingspace,
    powerwidth = 500,
    pnumtracks = 3,
    nnumtracks = 3,
})

local toplevel = object.create()
local lastanchor

for i, cellname in ipairs(celllist) do
    local cell = pcell.create_layout(string.format("stdcells/%s", cellname))
    local childname = pcell.add_cell_reference(cell, cellname)
    local child = toplevel:add_child(childname)
    if lastanchor then
        child:move_anchor("bottom", lastanchor)
    end
    lastanchor = child:get_anchor("top")

    print(cellname)
    local ports = cell:get_ports()
    for _, port in ipairs(ports) do
        if port.name ~= "VDD" and port.name ~= "VSS" then
            local x, y = port.where:unwrap()
            local xoffset = x // (gatelength + gatespace)
            local yoffset = y // (routingwidth + routingspace)
            print(string.format("%4s (%6d, %6d) -> %3d:%3d", port.name, x, y, xoffset, yoffset))
        end
    end
    print()
end

return toplevel
