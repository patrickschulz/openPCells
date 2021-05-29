local M = {}

function M.cross(where, size)
    local x, y = where:unwrap()
    local obj = object.create()
    size = size or 100
    obj:merge_into(geometry.rectanglebltr(generics.special(), point.create(x - 5, y - size), point.create(x + 5, y + size)))
    obj:merge_into(geometry.rectanglebltr(generics.special(), point.create(x - size, y - 5), point.create(x + size, y + 5)))
    return obj
end

return M
