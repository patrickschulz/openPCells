return function(args)
    -- start pcell parameters
    pcell.clear()
    local channeltype = pcell.process_args(args, "size", "number", 10)
    pcell.check_args(args) -- finish cell parametrization. This function checks for misspelled arguments 

    -- create the main object
    local obj = object.create()

    -- all layout functions also return an object, in order to add them to the main object you need to merge them:
    obj:merge_into(layout.rectange("M1", "drawing", size, size))

    return obj
end
