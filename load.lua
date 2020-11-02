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

function _generic_load(filename, chunkname, synerrmsg, semerrmsg, env)
    local reader, msg = _get_reader(filename)
    if not reader then
        error(msg)
    end

    local env = env or _ENV
    local func, msg = load(reader, chunkname, "t", env)

    if not func then
        if synerrmsg then
            error(string.format("%s: %s", synerrmsg, msg), 0)
        else
            error(msg, 0)
        end
    end

    local status, chunk = pcall(func)
    if not status then
        if semerrmsg then
            error(string.format("%s: %s", semerrmsg, chunk), 0)
        else
            error(chunk, 0)
        end
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
