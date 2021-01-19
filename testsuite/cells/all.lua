-- luacheck: globals report
do
    local cells = pcell.list()
    for _, cellname in ipairs(cells) do
        local status, msg = pcall(pcell.create_layout, cellname)
        report(cellname, status == true, msg)
    end
end
