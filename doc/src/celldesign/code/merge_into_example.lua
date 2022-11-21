function layout(toplevel)
    local cell = -- get the layout from somewhere
    toplevel:merge_into(cell)
    toplevel:merge_into(cell:flatten())
    toplevel:merge_into(cell:copy():flatten())
end
