return function(args)
    pcell.setup(args)
    local numpads   = pcell.process_args("numpads",    3)
    local padwidth  = pcell.process_args("padwidth",  60.0)
    local padheight = pcell.process_args("padheight", 80.0)
    local padpitch  = pcell.process_args("padpitch", 100.0)
    pcell.check_args()

    local pads = object.create()

    pads:merge_into(layout.multiple(
        layout.rectangle(generics.metal(-1), padwidth, padheight),
        numpads, 1, padpitch, 0
    ))

    return pads
end
