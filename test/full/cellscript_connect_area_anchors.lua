local cell = object.create("cell")

local function make_anchor(name, width, height, xoffset, yoffset)
    cell:add_area_anchor_bltr(
        name,
        point.create(xoffset - width / 2, yoffset - height / 2),
        point.create(xoffset + width / 2, yoffset + height / 2)
    )
end

local anchors = {
    {
        width1 = 100,
        height1 = 100,
        width2 = 100,
        height2 = 100,
        xoffset1 = 0,
        yoffset1 = 0,
        xoffset2 = 0,
        yoffset2 = 500,
    },
    {
        width1 = 100,
        height1 = 100,
        width2 = 100,
        height2 = 100,
        xoffset1 = 0,
        yoffset1 = 0,
        xoffset2 = 500,
        yoffset2 = 500,
    },
    {
        width1 = 100,
        height1 = 100,
        width2 = 100,
        height2 = 100,
        xoffset1 = 0,
        yoffset1 = 500,
        xoffset2 = 500,
        yoffset2 = 0,
    },
    {
        width1 = 100,
        height1 = 100,
        width2 = 100,
        height2 = 100,
        xoffset1 = 500,
        yoffset1 = 0,
        xoffset2 = 0,
        yoffset2 = 500,
    },
    {
        width1 = 100,
        height1 = 100,
        width2 = 100,
        height2 = 100,
        xoffset1 = 500,
        yoffset1 = 500,
        xoffset2 = 0,
        yoffset2 = 0,
    },
    {
        width1 = 400,
        height1 = 100,
        width2 = 400,
        height2 = 100,
        xoffset1 = 0,
        yoffset1 = 0,
        xoffset2 = 500,
        yoffset2 = 500,
    },
    {
        width1 = 100,
        height1 = 400,
        width2 = 400,
        height2 = 100,
        xoffset1 = 0,
        yoffset1 = 500,
        xoffset2 = 500,
        yoffset2 = 0,
    },
}

local x = 0
local y = 0
for i, anchor in ipairs(anchors) do
    local anchor1 = string.format("anchor1_%d", i)
    local anchor2 = string.format("anchor2_%d", i)
    make_anchor(anchor1, anchor.width1, anchor.height1, x + anchor.xoffset1, y + anchor.yoffset1)
    make_anchor(anchor2, anchor.width2, anchor.height2, x + anchor.xoffset2, y + anchor.yoffset2)
    geometry.rectangleareaanchor(cell, generics.metal(1), anchor1)
    geometry.rectangleareaanchor(cell, generics.metal(1), anchor2)
    layouthelpers.connect_area_anchor(cell,
        generics.metal(2),
        50,
        cell:get_area_anchor(anchor1),
        cell:get_area_anchor(anchor2)
    )
    x = x + 800
end

return cell
