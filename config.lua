local M = {}

function M.load_user_config()
    local filename = string.format("%s/.opcconfig.lua", os.getenv("HOME"))
    local chunkname = string.format("@%s", filename)

    local reader = _get_reader(filename)
    if reader then
        local env = {
            prependcellpath = pcell.prepend_cellpath,
            appendcellpath = pcell.append_cellpath
        }
        local status, c = pcall(_generic_load, reader, chunkname, nil, nil, env)
        if not status then
            print(c)
        else
            return c
        end
    end
end

return M
