function layout(toplevel)
    local cell = -- get the layout from somewhere
    toplevel:merge_into_shallow(cell)
    toplevel:merge_into_shallow(cell:flatten())
    toplevel:merge_into_shallow(cell:copy():flatten())
end
