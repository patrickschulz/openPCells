local M = {}

local loadedcells = {}

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

function M.load_cell(name, args, evaluate)
    if loadedcells[name] then
        return loadedcells[name]
    end
    local cellfuncs, msg = _load(name)
    if not cellfuncs then
        print(msg)
        os.exit(exitcodes.syntaxerrorincell)
    end
    pcell.load(cellfuncs.parameters, name)
    loadedcells[name] = cellfuncs
    return cellfuncs
end

function M.create_layout(name, args, evaluate)
    local cellfuncs = M.load_cell(name, args, evaluate)
    local cell = object.create()
    local parameters = pcell.get_parameters(name, args, evaluate)
    local status, msg = pcall(cellfuncs.layout, cell, parameters)
    if not status then
        print(string.format("could not create cell '%s': %s", name, msg))
        os.exit(exitcodes.syntaxerrorincell)
    end
    return cell
end

function M.parameters(name)
    local cellfuncs = M.load_cell(name)
    for _, v in pcell.iter() do
        print(string.format("%s %s %s", tostring(v.name), tostring(v.value), tostring(v.argtype)))
    end
end

return M
