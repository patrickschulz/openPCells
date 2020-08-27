-- put the cell inside a function
return function(args)
    -- process cell arguments (parameters)
    pcell.setup(args)
    local width  = pcell.process_args("width",  1.0)
    local height = pcell.process_args("height", 1.0)
    pcell.check_args()

    -- create the shape
    local obj = layout.rectangle(generics.metal(1), width, height)

    -- return the object
    return obj
end
