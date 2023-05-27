local M = {}

function M.read_cellinfo_from_file(filename)
    cellinfo = dofile(filename)
    return cellinfo
end

function M.collect_nets_cells(netlist, cellinfo, ignorednets)
    local netset = {}
    local nets = {}
    local instances = {}
    for module in netlist:modules() do
        for instance in module:instances() do
            -- create nets
            local ct = {}
            for _, c in ipairs(instance.connections) do
                if not aux.any_of(
                    function(v) return c.net == v end,
                    ignorednets or {}
                ) then
                    if not netset[c.net] then
                        netset[c.net] = true
                        table.insert(nets, c.net)
                    end
                    table.insert(ct, { name = c.net, port = c.port })
                end
            end
            local pinoffsets = cellinfo[instance.reference] and cellinfo[instance.reference].pinoffsets
            if not pinoffsets then
                error(string.format("no pinoffsets data for cell '%s'", instance.reference))
            end
            local width = cellinfo[instance.reference] and cellinfo[instance.reference].width
            if not width then
                error(string.format("no width data for cell '%s'", instance.reference))
            end
            -- some cells dont have blockages so no error if they dont have it
            local blockages = cellinfo[instance.reference].blockages
            table.insert(instances, {
                instance = instance.name,
                reference = instance.reference,
                nets = ct,
                pinoffsets = pinoffsets,
                width = width,
                blockages = blockages
            })
        end
    end
    return {
        instances = instances,
        nets = nets
    }
end

function M.write_spice_netlist(filename, netlist)
    local file = io.open(filename, "w")
    if not file then
        error(string.format("verilogprocessor.write_spice_netlist: could not open file '%s'", filename))
    end
    for module in netlist:modules() do
        file:write(string.format(".SUBCKT %s %s\n", module.name, table.concat(module.ports, " ")))
        for instance in module:instances() do
            local connections = {}
            for _, connection in ipairs(instance.connections) do
                table.insert(connections, string.format("%s=%s", connection.port, connection.net))
            end
            file:write(string.format("    X%s %s $PINS %s VDD=VDD VSS=VSS BULK_N=BULK_N BULK_P=BULK_P\n", instance.name, instance.reference, table.concat(connections, " ")))
        end
        file:write(".ENDS\n")
    end
    file:close()
end

return M
