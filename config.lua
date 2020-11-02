local M = {}

function M.get_user_config()
    local filename = string.format("%s/.opcconfig.lua", os.getenv("HOME"))
    local chunkname = "@userconfig"

    local env = {
        addcellpath = pcell.add_cellpath
    }
    return _generic_load(filename, chunkname, "error while loading user configuration", "error while loading user configuration", env)
end

return M
