-- define parameters
function parameters()
    pcell.add_parameters(
        { "width",  100 },
        { "height", 100 }
    )
end

-- define layout
function layout(obj, _P)
    -- create the shape
    local rect = geometry.rectangle(generics.metal(1), width, height)
    -- merge into main cell
    obj:merge_into(rect)
end
