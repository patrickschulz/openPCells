-- put the cell inside a function
return function(args)
    -- process cell arguments (parameters)
    pcell.setup(args)
    local width  = pcell.process_args("width",  1.0)
    local height = pcell.process_args("height", 1.0)
    local pitch  = pcell.process_args("pitch",  2.0)
    local rep    = pcell.process_args("rep",    10)
    pcell.check_args()

    -- create the main object
    local obj = object.create()

    -- first naive attempt
    for i = 1, rep do
        for j = 1, rep do
            local o = layout.rectangle(
                generics.metal(1), width, height
            )
            obj:merge_into(o)
        end
    end

    -- better approach
    local obj = layout.multiple(
        layout.rectangle(generics.metal(1), width, height),
        rep, rep, pitch, pitch
    )

    -- return the object
    return obj
end
