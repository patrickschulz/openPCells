local M = {}

function M.rectanglebltr(entries, bl, tr)
    local obj = object.create()
    for _, entry in ipairs(entries) do
        obj:add_raw_shape(shape.create_rectangle_bltr(entry.layer, bl, tr))
    end
    return obj
end

function M.rectangle(layercoll, width, height)
    if width % 2 ~= 0 then 
        moderror(string.format("layout.rectangle: width (%d) must be a multiple of 2. Use rectanglebltr if you need odd coordinates", width))
    end
    if height % 2 ~= 0 then 
        moderror(string.format("layout.rectangle: height (%d) must be a multiple of 2. Use rectanglebltr if you need odd coordinates", height))
    end
    return M.rectanglebltr(
        layercoll,
        point.create(-width / 2, -height / 2),
        point.create( width / 2,  height / 2)
    )
end

return M
