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

function _load_module(modname)
    local filename = string.format("%s/%s.lua", _get_opc_home(), modname)
    local chunkname = string.format("@%s", modname)

    local reader, msg = _get_reader(filename)
    if not reader then
        print(msg)
        return
    end

    local func, msg = load(reader, chunkname)

    if not func then
        print(msg)
        return nil
    end

    local status, chunk = pcall(func)
    if not status then
        print(chunk)
        return nil
    end

    return chunk
end
