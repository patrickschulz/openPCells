local M = {}

local function _collect_cells(path, cells, prepend)
    prepend = prepend or ""
    for _, entry in ipairs(dir.walk(path)) do
        if entry.name:sub(1, 1) ~= "." then
            if entry.type == "regular" and string.match(entry.name, "%.lua$") then
                local name = string.match(entry.name, "^([%w_]+)%.lua$")
                table.insert(cells, string.format("%s%s", prepend, name))
            elseif entry.type == "directory" then
                _collect_cells(string.format("%s/%s", path, entry.name), cells, prepend .. entry.name .. "/")
            end
        end
    end
end

function M.listcells(path)
    local cells = {}
    _collect_cells(path, cells)
    return cells
end

return M
