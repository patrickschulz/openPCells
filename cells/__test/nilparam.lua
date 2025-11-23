function parameters()
    pcell.add_parameters(
        { "extralayers", nil }
    )
end

function layout(cell, _P)
    geometry.rectanglebltr(cell, generics.metal(1), point.create(0, 0), point.create(100, 100))
    if rawget(_P, "extralayers") then
        for _, layer in ipairs(_P.extralayers) do
            geometry.rectanglebltr(cell, layer, point.create(0, 0), point.create(100, 100))
        end
    end
end
