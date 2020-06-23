local M = {}

-- private variables
local generate_filename = function()
    return os.tmpname()
end
local layermap 
local gridfmt = "%.3f"

function M.register_filename_generation_func(func)
    generate_filename = func
end

function M.register_layermap(lm)
    layermap = lm
end

local function _write_shape(file, shape)
    local sep = sep or "\n"
    local layer = layermap[shape.layer]
    local purpose = shape.purpose -- TODO: also map the purpose
    local fmt = string.format("%s %s%s", gridfmt, gridfmt, sep)
    for pts in shape:iter() do
        file:write(string.format("%s %s\n", layer, shape.purpose))
        for i, pt in ipairs(pts) do
            file:write(string.format(fmt, pt.x, pt.y, sep))
        end
        file:write("\n")
    end
end

function M.print_object(object)
    local sep = sep or "\n"
    local filename = generate_filename()
    print(filename)
    local file = io.open(filename, "w")
    for shape in object:iter() do
        _write_shape(file, shape)
    end
    file:close()
end

return M
