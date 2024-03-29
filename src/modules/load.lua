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

function _dofile(reader, chunkname, synerrmsg, env)
    env = env or _ENV
    local func, msg = load(reader, chunkname, "t", env)

    if not func then
        if synerrmsg then
            error(string.format("%s: %s", synerrmsg, msg), 0)
        else
            error(msg, 0)
        end
    end

    return func()
end

