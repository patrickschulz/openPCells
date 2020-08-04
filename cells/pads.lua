return function(args)
    pcell.clear()
    -- pads settings
    local numpads   = pcell.process_args(args, "numpads", "number", 3)
    local padwidth  = pcell.process_args(args, "padwidth", "number", 60.0)
    local padheight = pcell.process_args(args, "padheight", "number", 80.0)
    local padpitch  = pcell.process_args(args, "padpitch", "number", 100.0)
    pcell.check_args(args)

    local pads = object.create()

    pads:merge_into(layout.multiple(
        layout.rectangle("outermetal", "drawing", padwidth, padheight),
        numpads, 1, padpitch, 0
    ))

    return pads
end
