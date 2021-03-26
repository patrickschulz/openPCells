local M = {}

function M.load_user_config()
    local filename = string.format("%s/.opcconfig.lua", os.getenv("HOME"))
    local chunkname = string.format("@%s", filename)

    local reader = _get_reader(filename)
    if reader then
        local env = {
            prependcellpath = pcell.prepend_cellpath,
            appendcellpath = pcell.append_cellpath,
            set_option = function(key, val) argparse:set_option(key, val) end,
        }
        local status, msg = pcall(_generic_load, reader, chunkname, nil, nil, env)
        if not status then
            print(msg)
            return false
        else
            return true
        end
    else
        -- no user config found, this is not an error
        return true
    end
end

return M
