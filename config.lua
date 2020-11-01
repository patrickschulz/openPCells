local M = {}

function M.get_user_config()
    local file = io.open(string.format("%s/.opcconfig.lua", os.getenv("HOME")))
    if not file then
        return
    end
    local content = file:read("*a")
    local env = {
        addcellpath = pcell.add_cellpath
    }
    local chunkname = string.format("=config '%s'", cellname)
    local chunk, msg = load(content, chunkname, "t", env)
    if not chunk then
        error(string.format("error while loading user configuration: %s", msg), 0)
    end
    local status, msg = pcall(chunk)
    if not status then
        error(string.format("error while loading user configuration: %s", msg), 0)
    end
    return msg
end

return M
