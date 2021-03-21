-- luacheck: ignore _get_reader _generic_load _load_module load
function _get_reader(filename)
    local file = io.open(filename, "r")
    if not file then
        return nil, string.format("could not open file '%s'", filename)
    end
    local chunksize = 1000
    return function()
        return file:read(chunksize)
    end
end

function _generic_load(reader, chunkname, synerrmsg, semerrmsg, env)
    env = env or _ENV
    local func, msg = load(reader, chunkname, "t", env)

    if not func then
        if synerrmsg then
            moderror(string.format("%s: %s", synerrmsg, msg))
        else
            moderror(msg)
        end
    end

    local status, chunk = pcall(func)
    if not status then
        if semerrmsg then
            moderror(string.format("%s: %s", semerrmsg, chunk))
        else
            moderror(chunk)
        end
    end

    return chunk
end

function _load_module(modname)
    if not modname then
        moderror("no module name given")
    end
    local filename = string.format("%s/%s.lua", _get_opc_home(), modname)
    local chunkname = string.format("@%s", modname)

    local reader, msg = _get_reader(filename)
    if not reader then
        moderror(msg)
    end

    return _generic_load(reader, chunkname)
end
