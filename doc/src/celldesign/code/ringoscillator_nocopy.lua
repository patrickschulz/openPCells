function layout(toplevel)
    local inverter = -- create inverter layout
    local width = 1000 -- the width needs to be known
    -- translate and merge into toplevel
    toplevel:merge_into(inverter)
    toplevel:merge_into(inverter:translate(width, 0))
    toplevel:merge_into(inverter:translate(width, 0))
end
