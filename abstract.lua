local M = {}

--[[
local lut = {}
local function _make_lazy(func)
    return function(...)
        local entry = {
            func = func,
            args = table.pack(...)
        }
        table.insert(lut, entry)
    end
end
--]]

--local geometrylut = {}
M.geometry = {}
for name, func in pairs(geometry) do
    M.geometry[name] = func
    --M.geometry[name] = _make_lazy(func)
end
M.graphics = {}
for name, func in pairs(graphics) do
    M.graphics[name] = func
end

function M.realize_shapes()

end

return M
