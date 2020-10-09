function parameters()
    --pcell.add_parameter("width", 50)
    pcell.add_parameters(
        { "width", 50 }
    )
end

function layout(rectangle, _P)
    rectangle:merge_into(geometry.rectangle(generics.metal(1), _P.width, _P.width))
end
