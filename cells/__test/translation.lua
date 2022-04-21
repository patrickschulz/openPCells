function parameters()
end

function layout(cell, _P)
    geometry.rectangle(cell, generics.metal(1), 50, 50)
    cell:translate(200, 0)
    geometry.rectangle(cell, generics.metal(2), 50, 50)
end
