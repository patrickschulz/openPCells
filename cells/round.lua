return function(args)
    pcell.clear()
    local width = pcell.process_args(args, "width", "number", 10.0)
    pcell.check_args(args)

    return layout.corner("M10", "drawing", point.create(0, 0), point.create(100, 100), 10, 30, 0.1)
end
