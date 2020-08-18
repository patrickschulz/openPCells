local M = {}

local function _load(name)
    local file = io.open(string.format("%s/cells/%s.lua", _get_opc_home(), name))
    if not file then
        return nil, string.format("unknown cell '%s'", name)
    end
    local content = file:read("*a")
    local env = setmetatable({}, { __index = _ENV })
    local chunk, msg = load(content, "=(OPC cell loading)", "t", env)
    if not chunk then
        return nil, string.format("syntax error in cell '%s': %s", name, msg)
    end
    chunk()
    return env
end

function M.create_layout(name, args)
    local cellfuncs, msg = _load(name)
    if not cellfuncs then return nil, msg end
    -- create parameters
    pcell.setup()
    cellfuncs.parameters()
    pcell.process(args)
    return cellfuncs.layout(args)
end

function M.params(name)

end

return M
