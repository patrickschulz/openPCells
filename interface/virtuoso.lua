local M = {}

local generate_filename = function()
    return os.tmpname()
end

function M.register_filename_generation_func(func)
    generate_filename = func
end

local function _write_shape(file, shape)
    local sep = sep or "\n"
    file:write(string.format("%s %s\n", shape.layer, shape.purpose))
    for i, pt in ipairs(shape.pts) do
        file:write(string.format("%.1f %.1f%s", pt.x, pt.y, sep))
    end
end

function M.print_object(object)
    local sep = sep or "\n"
    local filename = generate_filename()
    print(filename)
    local file = io.open(filename, "w")
    for shape in object:iter() do
        _write_shape(file, shape)
        file:write("\n")
    end
    file:close()
end

return M
