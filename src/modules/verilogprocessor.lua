local M = {}

function M.read_cellinfo_from_file(filename)
    cellinfo = dofile(filename)
    return cellinfo
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
                if not netset[c.net] then
                    netset[c.net] = true
                    table.insert(nets, c.net)
                end
                table.insert(ct, { name = c.net, port = c.port })
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
    return instances, nets
end

return M
