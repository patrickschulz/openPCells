return function(args)
    pcell.setup(args)
    local turns         = pcell.process_args("turns",         3)
    local width         = pcell.process_args("width",         6.0)
    local spacing       = pcell.process_args("spacing",       6.0)
    local innerdiameter = pcell.process_args("innerdiameter", 10)
    pcell.check_args()

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
