local celllist = {
    "buf",
    "cinv",
    "not_gate",
    "nand_gate",
    "nor_gate",
    "or_gate",
    "and_gate",
    --"tbuf",
    "xor_gate",
    "dffpq",
    "dffnq",
    "dffprq",
    "dffnrq",
    "dffpsq",
    "dffnsq",
    --"dffprsq",
    --"dffnrsq",
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
    powerwidth = 480,
    pnumtracks = 3,
    nnumtracks = 3,
})

local toplevel = object.create("opctoplevel")
local lastanchor

local lines = {}
table.insert(lines, "return {")
for i, cellname in ipairs(celllist) do
    local cell = pcell.create_layout(string.format("stdcells/%s", cellname), cellname)
    local child = toplevel:add_child(cell, cellname)
    child:move_anchor_y("bottom", lastanchor)
    lastanchor = child:get_anchor("top")

    local left = child:get_anchor("left")
    local right = child:get_anchor("right")
    local width = (right:getx() - left:getx()) / (gatelength + gatespace)
    table.insert(lines, string.format("    %s = {", cellname))
    table.insert(lines, string.format("        width = %d,", width))
    local ports = cell:get_ports()
    table.insert(lines, "        pinoffsets = {")
    for _, port in ipairs(ports) do
        if port.name ~= "VDD" and port.name ~= "VSS" then
            local x, y = port.where:unwrap()
            local xoffset = x / (gatelength + gatespace)
            local yoffset = y / (routingwidth + routingspace)
            --table.insert(lines, string.format("            %s = { x = %d, y = %d },", port.name, math.floor(xoffset), math.floor(yoffset)))
            table.insert(lines, string.format("            %s = { x = %.1f, y = %.1f },", port.name, xoffset, yoffset))
        end
    end
    table.insert(lines, "        },")
    table.insert(lines, "    },")
end
table.insert(lines, "}")
print(table.concat(lines, "\n"))

return toplevel
