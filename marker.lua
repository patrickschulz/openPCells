local M = {}

function M.cross(where)
    local x, y = where:unwrap()
    local obj = object.create()
    obj:merge_into(geometry.rectanglebltr(generics.special(), point.create(x - 5, y - 100), point.create(x + 5, y + 100)))
    obj:merge_into(geometry.rectanglebltr(generics.special(), point.create(x - 100, y - 5), point.create(x + 100, y + 5)))
    return obj
end

return M
