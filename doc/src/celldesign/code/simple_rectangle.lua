-- define parameters
function parameters()
    pcell.add_parameters(
        { "width",  100 },
        { "height", 100 }
    )
end

-- define layout
function layout(obj, _P)
    -- create the shape and add it to the main object
    geometry.rectanglebltr(
        obj,
        generics.metal(1),
        point.create(0, 0),
        point.create(_P.width, _P.height)
    )
end
