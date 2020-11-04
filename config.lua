local M = {}

function M.get_user_config()
    local filename = string.format("%s/.opcconfig.lua", os.getenv("HOME"))
    local chunkname = "@userconfig"

    local reader = _get_reader(filename)
    if reader then
        local env = {
            addcellpath = pcell.add_cellpath
        }
        return _generic_load(reader, chunkname, "error while loading user configuration", "error while loading user configuration", env)
    end
end

return M
