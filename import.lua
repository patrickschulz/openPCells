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
        local tr = string.format("point.create(%d, %d)", shape.pts[3], shape.pts[4])
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
        if type(shape.pathtype) == "table" then
            return string.format("geometry.path(%s, { %s }, %d, { %d, %d })", lpp, table.concat(ptsstrt, ", "), shape.width, shape.pathtype[1], shape.pathtype[2])
        else
            return string.format("geometry.path(%s, { %s }, %d, \"%s\")", lpp, table.concat(ptsstrt, ", "), shape.width, shape.pathtype)
        end
    else
        error(string.format("wrong shape: %s", shapetype))
    end
end

local function _write_cell(cell, path, dirname, layermap, alignmentbox)
    local chunkt = {
        "function parameters() end",
        "function layout(cell)",
        "    local ref, name, child",
    }
    for _, shape in ipairs(cell.shapes) do
        if alignmentbox then
            if shape.layer == alignmentbox.layer and shape.purpose == alignmentbox.purpose then
                cell.alignmentbox = shape.pts
            end
        end
        table.insert(chunkt, string.format("    cell:merge_into_shallow(%s)", _format_shape(shape, layermap)))
    end
    local references = {}
    for _, ref in ipairs(cell.references) do
        local cellname = string.format("%s/%s", dirname, ref.name)
        if not references[cellname] then
            table.insert(chunkt, string.format('    ref = pcell.create_layout("%s")', cellname))
            table.insert(chunkt, string.format('    name = pcell.add_cell_reference(ref, "%s")', ref.name))
            references[cellname] = true
        end
        if ref.xrep then -- AREF
            local xpitch = (ref.pts[3] - ref.pts[1]) / ref.xrep
            local ypitch = (ref.pts[6] - ref.pts[2]) / ref.yrep
            table.insert(chunkt, string.format('    child = cell:add_child_array(name, %d, %d, %d, %d):translate(%d, %d)', ref.xrep, ref.yrep, xpitch, ypitch, ref.pts[1], ref.pts[2]))
        else
            table.insert(chunkt, string.format('    child = cell:add_child(name):translate(%d, %d)', ref.pts[1], ref.pts[2]))
        end
        if ref.angle then
            if ref.transformation and ref.transformation[1] == 1 then
                table.insert(chunkt, string.format('    child:mirror_at_yaxis()'))
            else
                table.insert(chunkt, string.format('    child:mirror_at_yaxis()'))
                table.insert(chunkt, string.format('    child:mirror_at_xaxis()'))
            end
        else
            if ref.transformation and ref.transformation[1] == 1 then
                table.insert(chunkt, string.format('    child:mirror_at_xaxis()'))
            end
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

function M.translate_cells(cells, prefix, dirname, layermap, alignmentbox, overwrite)
    local path
    if prefix and prefix ~= "" then
        path = string.format("%s/%s", prefix, dirname)
    else
        path = string.format("%s/%s", dirname, dirname)
    end
    if not filesystem.exists(path) or overwrite then
        local created = filesystem.mkdir(path)
        if created then
            for _, cell in ipairs(cells) do
                _write_cell(cell, path, dirname, layermap, alignmentbox)
            end
        else
            moderror("import: could not create import directory")
        end
    else
        moderror("import: directory exists");
    end
end

return M
