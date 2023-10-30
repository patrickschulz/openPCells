local numcellsperrow = 100
local numrows = 100

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
for i = 1, numrows do
    local row = {}
    for j = 1, numcellsperrow do
        local idx = math.random(1, #celllut)
        table.insert(row, { instance = string.format("inst_%d_%d", i, j), reference = celllut[idx] })
    end
    table.insert(rows, row)
end

local filename = "digital.lua"

local lines = {}
table.insert(lines, "local toplevel = object.create(\"toplevel\")")
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
table.insert(lines, "local bp = pcell.get_parameters(\"stdcells/base\")")
table.insert(lines, "local cellnames = {")
for _, row in ipairs(rows) do
    table.insert(lines, "    {")
    for _, cell in ipairs(row) do
        table.insert(lines, string.format("        { instance = \"%s\", reference = \"%s\" },", cell.instance, cell.reference))

    end
    table.insert(lines, "    },")
end
table.insert(lines, "}")
table.insert(lines, "local xpitch = bp.gspace + bp.glength")
table.insert(lines, "local rows = placement.create_reference_rows(cellnames, xpitch)")
table.insert(lines, "local cells = placement.rowwise(toplevel, rows)")
table.insert(lines, "return toplevel")

local file = io.open(filename, "w")
file:write(table.concat(lines, "\n"))
file:close()
