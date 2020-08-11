return function(args)
    -- start pcell parameters
    pcell.setup(args)
    --local channeltype = pcell.process_args("size", 10, "number")
    local channeltype = pcell.process_args("size", 10) -- normally, the type can be inferred, but it can be explicitly given
    pcell.check_args() -- finish cell parametrization. This function checks for misspelled arguments 

    -- create the main object
    local obj = object.create()

    -- all layout functions also return an object, in order to add them to the main object you need to 
    -- merge them (in this simple example you could of course just return the value from layout.rectangle)
    obj:merge_into(layout.rectange("M1", size, size))

    return obj
end
