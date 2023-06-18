if not args[1] then
    error("no target given")
end

local module = args[1]
local exporttype = "gds"

local netlist = verilog.read_parse_file(string.format("%s.v", module))

verilogprocessor.write_spice_netlist(string.format("%s_netlist.sp", module), netlist)

local cellinfo = verilogprocessor.read_cellinfo_from_file("cellinfo.lua")
local ignorednets = {} -- insert names of nets that should be ignored
local circuit = verilogprocessor.collect_nets_cells(netlist, cellinfo, ignorednets)

local utilization = 0.6
local numrows = 2
local floorplan = placement.create_floorplan_fixed_rows(circuit, utilization, numrows)
local rows = placement.optimize(circuit, floorplan)
--local plan = {
--    { "inv", "nand1", "dff_out" },
--    { "nand2", "dff_buf" },
--    { "nand3", "dff_in" },
--}
--local plan = {
--    { "inv1", },
--    { "inv2" }
--}
--local rows = placement.manual(circuit, plan)
placement.insert_filler_names(rows, floorplan.floorplan_width)

-- hack: insert fill at the left side
-- this is done to ensure that routing works if a dff is there, since their gates extend to the left
-- this will be fixed and removed at some point
for i in ipairs(rows) do
    table.insert(rows[i], 1, {
        reference = "isogate",
        instance = string.format("hackfill_%i", i),
        width = 1
    })
end
floorplan.floorplan_width = floorplan.floorplan_width + 1

-- this value can be (at least in theory) changed in the generated layout, but the router assumes this many tracks
-- this means that reducing this value CAN work, but only increasing it will work certainly
local pnumtracks = 4
local nnumtracks = 4
local numinnertracks = 3

local routes = routing.legalize(circuit, rows, numinnertracks, pnumtracks, nnumtracks, floorplan)

local filename = generator.get_cell_filename("verilogimport", "verilogimport", module)
print(string.format("writing to file '%s'", filename))
local file = io.open(filename, "w")
generator.digital(file, rows, routes, numinnertracks, pnumtracks, nnumtracks)
file:close()
