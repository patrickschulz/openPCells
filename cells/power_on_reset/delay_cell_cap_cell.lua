function parameters() end
function layout(cell)
    local num = 10
    local pitch = 2 * 55 * (44 + 46) / num
    local width = 100
    for i = 1, num do
        cell:merge_into_shallow(geometry.rectanglebltr(generics.metal(2), 
            point.create(-55 * (44 + 46) - pitch / 2 + i * pitch - width / 2,  -10602), 
            point.create(-55 * (44 + 46) - pitch / 2 + i * pitch + width / 2,  -10350) 
        ))
    end
    cell:merge_into_shallow(geometry.rectanglebltr(generics.metal(2), point.create(-55 * (44 + 46),  -10802), point.create(55 * (44 + 46),  -10602)))

    for i = 1, num do
        cell:merge_into_shallow(geometry.rectanglebltr(generics.metal(4), 
            point.create(-55 * (44 + 46) - pitch / 2 + i * pitch - width / 2,  10350), 
            point.create(-55 * (44 + 46) - pitch / 2 + i * pitch + width / 2,  10473) 
        ))
    end
    cell:merge_into_shallow(geometry.rectanglebltr(generics.metal(4), point.create(-5172, 10473), point.create(10200, 10873)))

    local capref = pcell.create_layout("passive/capacitor/mom", {
        fingers = 55,
        fwidth = 44,
        fspace = 46,
        fheight = 20400,
        foffset = 100,
        rwidth = 100,
        firstmetal = 1,
        lastmetal = 7,
    })
    local name = pcell.add_cell_reference(capref)
    cell:add_child(name)
end
