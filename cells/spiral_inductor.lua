function parameters()
    pcell.add_parameters(
        { "turns",         3 },
        { "width",         6.0 },
        { "spacing",       6.0 },
        { "innerdiameter", 10 }
    )
end

function layout()

    local pathpts = pointarray.create()
    for i = 1, turns do
        local xy = 0.5 * innerdiameter + 0.5 * width + (i - 1) * (width + spacing)
        pathpts:append(point.create( xy + 0.00 * (width + spacing), -xy + 0.00 * (width + spacing)))
        pathpts:append(point.create( xy + 0.00 * (width + spacing),  xy + 0.50 * (width + spacing)))
        pathpts:append(point.create(-xy - 0.50 * (width + spacing),  xy + 0.50 * (width + spacing)))
        pathpts:append(point.create(-xy - 0.50 * (width + spacing), -xy - 1.00 * (width + spacing)))
    end
    return layout.path_midpoint("lastmetal", pathpts, width, "halfangle", true)
end
