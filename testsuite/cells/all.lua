-- luacheck: globals report
do
    technology.load("skywater130") -- use skywater130 for testing as it is publicly available
    pcell.add_cellpath(string.format("%s/cells", _get_opc_home()))
    local cells = pcell.list()[1].cells -- only execute for one path (there aren't any more anyways)
    for _, cellname in ipairs(cells) do
        local status, msg = pcall(pcell.create_layout, cellname)
        report(cellname, status == true, msg)
    end
end
