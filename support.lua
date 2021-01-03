local M = {}

function M.listcells(path, indent)
    indent = indent or 0
    for _, entry in ipairs(walkdir(path)) do
        if entry.name:sub(1, 1) ~= "." then
            for i = 1, indent do
                io.write("    ")
            end
            if entry.type == "regular" then
                print(entry.name)
            elseif entry.type == "directory" then
                print(entry.name)
                M.listcells(string.format("%s/%s", path, entry.name), indent + 1)
            end
        end
    end
end

return M
