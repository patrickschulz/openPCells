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

function M.load_cell(name, args, evaluate)
    debug.print("cell", string.format("loading cell '%s'", name))
    local cellfuncs, msg = _load(name)
    if not cellfuncs then
        print(msg)
        os.exit(exitcodes.syntaxerrorincell)
    end
    debug.down()
    pcell.load(cellfuncs.parameters, name)
    debug.up()
    return cellfuncs
end

function M.create_layout(name, args, evaluate)
    debug.print("cell", string.format("creating layout '%s'", name))
    debug.down()
    local cellfuncs = M.load_cell(name, args, evaluate)
    pcell.process(name, args, evaluate)
    local cell = object.create()
    local parameters = pcell.get_parameters(name)
    local status, msg = pcall(cellfuncs.layout, cell, parameters)
    if not status then
        print(string.format("could not create cell '%s': %s", name, msg))
        os.exit(exitcodes.syntaxerrorincell)
    end
    debug.up()
    return cell
end

function M.parameters(name)
    local cellfuncs = M.load_cell(name)
    for _, v in pcell.iter() do
        print(string.format("%s %s %s", tostring(v.name), tostring(v.value), tostring(v.argtype)))
    end
end

return M
