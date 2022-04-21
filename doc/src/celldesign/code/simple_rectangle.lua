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
    geometry.rectangle(obj, generics.metal(1), _P.width, _P.height)
end
