-- define parameters
function parameters()
    pcell.add_parameters(
        { "width",  1.0 },
        { "height", 1.0 }
    )
end

-- define layout
function layout()
    -- get parameters
    local P = pcell.get_params()

    -- create the shape
    local obj = geometry.rectangle(generics.metal(1), width, height)

    -- return the object
    return obj
end
