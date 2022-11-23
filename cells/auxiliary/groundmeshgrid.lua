function parameters()
    pcell.add_parameters(
        { "rows", 2, },
        { "columns", 2 }
    )
end

function layout(cell, _P)
    local baseref = pcell.create_layout("auxiliary/groundmesh", "base", {
        drawleft = false,
        drawright = false,
        drawtop = false,
        drawbottom = false,
    })
    local base = cell:add_child_array(baseref, "base", _P.columns, _P.rows)

    for column = 1, _P.columns do
        geometry.rectanglebltr(
            cell, generics.metal(9),
            base:get_array_anchor(column, 1, "gridcenterbl"),
            base:get_array_anchor(column, _P.rows, "gridcentertr")
        )
        geometry.rectanglebltr(
            cell, generics.metal(10),
            base:get_array_anchor(column, 1, "gridcenterbl"),
            base:get_array_anchor(column, _P.rows, "gridcentertr")
        )
    end
    for row = 1, _P.rows do
        geometry.rectanglebltr(
            cell, generics.metal(9),
            base:get_array_anchor(1, row, "gridcenterbl"),
            base:get_array_anchor(_P.columns, row, "gridcentertr")
        )
        geometry.rectanglebltr(
            cell, generics.metal(10),
            base:get_array_anchor(1, row, "gridcenterbl"),
            base:get_array_anchor(_P.columns, row, "gridcentertr")
        )
    end
end
