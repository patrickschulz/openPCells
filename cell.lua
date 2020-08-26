local M = {}

local function _load(name)
    local file = io.open(string.format("%s/cells/%s.lua", _get_opc_home(), name))
    if not file then
        return nil, string.format("unknown cell '%s'", name)
    end
    local get_content = function()
        local s = file:read()
        -- catch empty lines
        if s == "" then s = " " end
        -- append newline (otherwise comments mess up the interpreter)
        if s then s = s .. "\n" end
        return s
    end
    local chunk, msg = load(get_content, string.format("=(loading cells/%s.lua)", name))
    if not chunk then
        return nil, string.format("syntax error in cell '%s': %s", name, msg)
    end
    chunk()
    return { parameters = parameters, layout = layout }
end

function M.create_layout(name, args, evaluate)
    local args = args or {}
    local cellfuncs, msg = _load(name)
    if not cellfuncs then return nil, msg end
    -- create parameters
    pcell.setup()
    aux.call_if_present(cellfuncs.parameters)
    pcell.process(args, evaluate)
    return cellfuncs.layout(args)
end

function M.parameters(name)
    local cellfuncs, msg = _load(name)
    if not cellfuncs then return nil, msg end
    -- create parameters
    pcell.setup()
    if not cellfuncs.parameters then
    else
        cellfuncs.parameters()
    end
    for _, v in pcell.iter() do
        print(string.format("%s %s %s", tostring(v.name), tostring(v.default), tostring(v.argtype)))
    end
end

return M
