local numcellsperrow = 400
local numrows = 400

local numgates = { -- order corresponding to celllut
    2, -- not_gate 
    3, -- nand_gate 
    5, -- and_gate 
    3, -- nor_gate 
    5, -- or_gate 
    25, -- dffpq 
    25, -- dffnq 
}

local celllut = {
    "not_gate",
    "nand_gate",
    "and_gate",
    "nor_gate",
    "or_gate",
    "dffpq",
    "dffnq",
}

local rows = {}
local rowgates = {}
for i = 1, numrows do
    local row = {}
    rowgates[i] = 0
    for j = 1, numcellsperrow do
        local idx = math.random(1, #celllut)
        rowgates[i] = rowgates[i] + numgates[idx]
        table.insert(row, { instance = string.format("inst_%d_%d", i, j), reference = celllut[idx] })
    end
    table.insert(rows, row)
end

-- max number of gates
local maxgates = 0
for i = 1, numrows do
    maxgates = math.max(maxgates, rowgates[i])
end

-- fill up rows
for i = 1, numrows do
    for j = 1, maxgates - rowgates[i] do
        table.insert(rows[i], { instance = string.format("fill_%d_%d", i, j), reference = "fill" })
    end
end

local filename = "digital.lua"

local lines = {}
table.insert(lines, "local toplevel = object.create(\"toplevel\")")
table.insert(lines, "local cellnames = {")
for _, row in ipairs(rows) do
    table.insert(lines, "    {")
    for _, cell in ipairs(row) do
        table.insert(lines, string.format("        { instance = \"%s\", reference = \"stdcells/%s\" },", cell.instance, cell.reference))

    end
    table.insert(lines, "    },")
end
table.insert(lines, "}")

-- base options
local baseopt = {
    gatelength = 500,
    gatespace = 320,
    sdwidth = 200,
}
table.insert(lines, "local baseopt = {")
for k, v in pairs(baseopt) do
    table.insert(lines, string.format("    %s = %s,", k, v))
end
table.insert(lines, "}")
table.insert(lines, "local xpitch = 820")
table.insert(lines, "local rows = placement.create_reference_rows(cellnames, xpitch, baseopt)")
table.insert(lines, "local cells = placement.rowwise(toplevel, rows)")
table.insert(lines, "return toplevel")

local file = io.open(filename, "w")
file:write(table.concat(lines, "\n"))
file:close()

--[[
table.insert(lines, "pcell.push_overwrites(\"stdcells/base\", {")
table.insert(lines, "    pnumtracks = 4,")
table.insert(lines, "    nnumtracks = 4,")
table.insert(lines, "    numinnerroutes= 3,")
table.insert(lines, "    drawtopbotwelltaps = false,")
table.insert(lines, "    glength = 100,")
table.insert(lines, "    gspace = 150,")
table.insert(lines, "    basepwidth = 500,")
table.insert(lines, "    basenwidth = 500,")
table.insert(lines, "    sdwidth = 60,")
table.insert(lines, "    powerwidth = 200,")
table.insert(lines, "    routingwidth = 84,")
table.insert(lines, "    routingspace = 84,")
table.insert(lines, "    drawtopbotwelltaps = false,")
table.insert(lines, "})")
--]]
