--[[
local M = {}

function M.load_user_config(argparse)
    local filename = string.format("%s/.opcconfig.lua", os.getenv("HOME"))
    local chunkname = string.format("@%s", filename)

    local reader = _get_reader(filename)
    if reader then
        local env = {
            prependcellpath = pcell.prepend_cellpath,
            appendcellpath = pcell.append_cellpath,
            addtechpath = technology.add_techpath,
            setenv = envlib.set,
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
--]]

return {
    techpaths = {
        "/home/pkurth/Workspace/GF22FDSOI_opc_tech"
    }
}
