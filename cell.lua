local M = {}

local function _load(name)
    local file = io.open(string.format("%s/cells/%s.lua", _get_opc_home(), name))
    if not file then
        return nil, string.format("unknown cell '%s'", name)
    end
    local content = file:read("*a")
    local env = setmetatable({}, { __index = _ENV })
    local chunk, msg = load(content, string.format("=(loading cells/%s.lua)", name), "t", env)
    if not chunk then
        return nil, string.format("syntax error in cell '%s': %s", name, msg)
    end
    chunk()
    return env
end

function M.create_layout(name, args, evaluate)
    local cellfuncs, msg = _load(name)
    if not cellfuncs then return nil, msg end
    -- create parameters
    pcell.setup()
    aux.call_if_present(cellfuncs.parameters)
    pcell.process(args, evaluate)
    return cellfuncs.layout(args)
end

function M.params(name)
    local cellfuncs, msg = _load(name)
    if not cellfuncs then return nil, msg end
    -- create parameters
    pcell.setup()
    if not cellfuncs.parameters then
    else
        cellfuncs.parameters()
    end
    pcell.process(args)
end

return M
