local function _get_cell_width(name)
    local lut = {
        not_gate = 1,
        nand_gate = 2,
        nor_gate = 2,
        xor_gate = 10,
        xnor_gate = 11,
        dffp = 21,
        dffn = 24,
    }
    if not lut[name] then
        moderror(string.format("unknown stdcell '%s'", name))
    end
    return lut[name]
end

local function _get_pin_offset(name, port)
    local lut = {
        not_gate = {
            I = { x = 0, y = 0 },
            O = { x = 1, y = 0 }
        },
        nand_gate = {
            A = { x = 0, y = 0 },
            B = { x = 1, y = 0 },
            O = { x = 2, y = 0 }
        },
        nor_gate = { 
            A = { x = 0, y = 0 },
            B = { x = 1, y = 0 },
            O = { x = 2, y = 0 }
        },
        xor_gate = {
            A = { x = 0, y = 0 },
            B = { x = 1, y = 0 },
            O = { x = 10, y = 0 }
        },
        xnor_gate = {
            A = { x = 0, y = 0 },
            B = { x = 1, y = 0 },
            O = { x = 10, y = 0 }
        },
        dffp = {
            CLK = { x = 0, y = 0 },
            D = { x = 0, y = 0 },
            Q = { x = 20, y = 0 },
        },
        dffn = {
            CLK = { x = 0, y = 0 },
            D = { x = 0, y = 0 },
            Q = { x = 20, y = 0 }
        },
    }
    if not lut[name] then
        moderror(string.format("unknown stdcell '%s'", name))
    end
    --[[
    if not lut[name][port] then
        moderror(string.format("unknown port '%s' for stdcell '%s'", port, name))
    end
    return lut[name][port]
    --]]
    return lut[name]
end

local M = {}

function M.collect_nets_cells(netlist)
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
            table.insert(instances, { 
                instance = instance.name, 
                reference = instance.reference,
                nets = ct,
                pinoffsets = _get_pin_offset(instance.reference),
                width = _get_cell_width(instance.reference),
            })
        end
    end
    return instances, nets
end

return M

