local function _get_reader(filename)
    local file = io.open(filename, "r")
    if not file then
        return nil, string.format("could not open file '%s'", filename)
    end
    local chunksize = 1000
    return function()
        return file:read(chunksize)
    end
end

local function _generic_load(filename, chunkname)
    local reader, msg = _get_reader(filename)
    if not reader then
        error(msg)
    end

    local func, msg = load(reader, chunkname)

    if not func then
        error(msg)
    end

    local status, chunk = pcall(func)
    if not status then
        error(chunk)
    end

    return chunk
end

function _load_module(modname)
    if not modname then
        error("no module name given")
    end
    local filename = string.format("%s/%s.lua", _get_opc_home(), modname)
    local chunkname = string.format("@%s", modname)

    return _generic_load(filename, chunkname)
end
