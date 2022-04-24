local M = {}

function M.read_cellinfo_from_file(filename)
    return dofile(filename)
end

function M.collect_nets_cells(netlist, cellinfo)
    local netset = {}
    local nets = {}
    local instances = {}
    for module in netlist:modules() do
        for instance in module:instances() do
            -- create nets
            local ct = {}
            for _, c in ipairs(instance.connections) do
                if not aux.any_of(function(v) return v == c.net end, module:get_ports()) then
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
            table.insert(instances, { 
                instance = instance.name, 
                reference = instance.reference,
                nets = ct,
                pinoffsets = pinoffsets,
                width = width
            })
        end
    end
    return instances, nets
end

return M
