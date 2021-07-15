local M = {}

local function _format_lpp(layer, purpose, layermap)
    local lppt = {
        string.format("gds = { layer = %d, purpose = %d }", layer, purpose)
    }
    if layermap then
        for k, v in pairs(layermap) do
            if v[layer] and v[layer][purpose] then
                table.insert(lppt, string.format("%s = { layer = %q, purpose = %q }", k, v[layer][purpose].layer, v[layer][purpose].purpose))
            else
                modwarning(string.format("import: layermap was provided, but not found for layer-purpose-pair (%d, %d). Exports of generated cells to any type other than GDS must set the environment variable 'ignoremissingexport' to true for successful export", layer, purpose))
            end
        end
    end
    return string.format("generics.premapped(nil, { %s })", table.concat(lppt, ", "))
end

local function _format_shape(shape, layermap)
    local lpp = _format_lpp(shape.layer, shape.purpose, layermap)
    if shape.shapetype == "rectangle" then
        local bl = string.format("point.create(%d, %d)", shape.pts[1], shape.pts[2])
        local tr = string.format("point.create(%d, %d)", shape.pts[5], shape.pts[6])
        return string.format("geometry.rectanglebltr(%s, %s, %s)", lpp, bl, tr)
    elseif shape.shapetype == "polygon" then
        local ptsstrt = {}
        for i = 1, #shape.pts - 1, 2 do
            table.insert(ptsstrt, string.format("point.create(%d, %d)", shape.pts[i], shape.pts[i + 1]))
        end
        return string.format("geometry.polygon(%s, { %s })", lpp, table.concat(ptsstrt, ", "))
    elseif shape.shapetype == "path" then
        local ptsstrt = {}
        for i = 1, #shape.pts - 1, 2 do
            table.insert(ptsstrt, string.format("point.create(%d, %d)", shape.pts[i], shape.pts[i + 1]))
        end
        return string.format("geometry.path(%s, { %s }, %d)", lpp, table.concat(ptsstrt, ", "), shape.width)
    else
        error(string.format("wrong shape: %s", shapetype))
    end
end

local function _write_cell(cell, path, dirname, layermap, alignmentbox)
    local chunkt = {
        "function parameters() end",
        "function layout(cell)",
        "    local ref",
        "    local name"
    }
    for _, shape in ipairs(cell.shapes) do
        if alignmentbox then
            if shape.layer == alignmentbox.layer and shape.purpose == alignmentbox.purpose then
                cell.alignmentbox = shape.pts
            end
        end
        table.insert(chunkt, string.format("    cell:merge_into_shallow(%s)", _format_shape(shape, layermap)))
    end
    for _, ref in ipairs(cell.references) do
        table.insert(chunkt, string.format('    ref = pcell.create_layout("%s/%s")', dirname, ref.name))
        table.insert(chunkt, string.format('    name = pcell.add_cell_reference(ref, "%s")', ref.name))
        if ref.xrep then -- AREF
            local xpitch = (ref.pts[3] - ref.pts[1]) / ref.xrep
            local ypitch = (ref.pts[4] - ref.pts[2]) / ref.yrep
            table.insert(chunkt, string.format('    for i = 1, %d do', ref.xrep))
            table.insert(chunkt, string.format('        for j = 1, %d do', ref.yrep))
            table.insert(chunkt, string.format('            cell:add_child(name):translate(%d + (i - 1) * %d, %d + (j - 1) * %d)', ref.pts[1], xpitch, ref.pts[2], ypitch))
            table.insert(chunkt, '        end')
            table.insert(chunkt, '    end')
        else
            table.insert(chunkt, string.format('    cell:add_child(name):translate(%d, %d)', ref.pts[1], ref.pts[2]))
        end
    end
    for _, label in ipairs(cell.labels) do
        local pointstr = string.format('point.create(%d, %d)', label.pts[1], label.pts[2])
        local lpp = _format_lpp(label.layer, label.purpose, layermap)
        table.insert(chunkt, string.format('    cell:add_port("%s", %s, %s)', label.text, lpp, pointstr))
    end
    if cell.alignmentbox then
        local blx = math.min(cell.alignmentbox[1], cell.alignmentbox[3], cell.alignmentbox[5], cell.alignmentbox[7], cell.alignmentbox[9])
        local bly = math.min(cell.alignmentbox[2], cell.alignmentbox[4], cell.alignmentbox[6], cell.alignmentbox[8], cell.alignmentbox[10])
        local trx = math.max(cell.alignmentbox[1], cell.alignmentbox[3], cell.alignmentbox[5], cell.alignmentbox[7], cell.alignmentbox[9])
        local try = math.max(cell.alignmentbox[2], cell.alignmentbox[4], cell.alignmentbox[6], cell.alignmentbox[8], cell.alignmentbox[10])
        local bl = string.format("point.create(%d, %d)", blx, bly)
        local tr = string.format("point.create(%d, %d)", trx, try)
        table.insert(chunkt, string.format('    cell:set_alignment_box(%s, %s)', bl, tr))
    end
    local cellfile = io.open(string.format("%s/%s.lua", path, cell.name), "w")
    if not cellfile then
        moderror(string.format("import: could not open file for cell export. Did you create the appropriate directory (%s)?", dirname))
    end
    table.insert(chunkt, "end") -- close 'layout' function
    cellfile:write(string.format("%s\n", table.concat(chunkt, "\n")))
    cellfile:close()
end

function M.translate_cells(cells, prefix, dirname, layermap, alignmentbox)
    local path = dirname
    if prefix and prefix ~= "" then
        path = string.format("%s/%s", prefix, dirname)
    end
    filesystem.mkdir(path)
    for _, cell in ipairs(cells) do
        _write_cell(cell, path, dirname, layermap, alignmentbox)
    end
end

return M
