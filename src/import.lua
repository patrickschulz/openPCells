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

local function _format_shape(shape, layermap, x0, y0)
    local lpp = _format_lpp(shape.layer, shape.purpose, layermap)
    -- add offset
    for i = 1, #shape.pts - 1, 2 do
        shape.pts[i + 0] = shape.pts[i + 0] + x0
        shape.pts[i + 1] = shape.pts[i + 1] + y0
    end

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

local function _write_cell(chunk, cell, cells, path, dirname, layermap, alignmentbox, flatpattern, x0, y0)
    for _, shape in ipairs(cell.shapes) do
        if alignmentbox then
            if shape.layer == alignmentbox.layer and shape.purpose == alignmentbox.purpose then
                if shape.shapetype == "rectangle" then
                    cell.alignmentbox = { blx = shape.pts[1], bly = shape.pts[2], trx = shape.pts[3], try = shape.pts[4] }
                else
                    local blx = math.min(cell.alignmentbox[1], cell.alignmentbox[3], cell.alignmentbox[5], cell.alignmentbox[7], cell.alignmentbox[9])
                    local bly = math.min(cell.alignmentbox[2], cell.alignmentbox[4], cell.alignmentbox[6], cell.alignmentbox[8], cell.alignmentbox[10])
                    local trx = math.max(cell.alignmentbox[1], cell.alignmentbox[3], cell.alignmentbox[5], cell.alignmentbox[7], cell.alignmentbox[9])
                    local try = math.max(cell.alignmentbox[2], cell.alignmentbox[4], cell.alignmentbox[6], cell.alignmentbox[8], cell.alignmentbox[10])
                    cell.alignmentbox = { blx = blx, bly = bly, trx = trx, try = try }
                end
            end
        end
        table.insert(chunk, string.format("    cell:merge_into_shallow(%s)", _format_shape(shape, layermap, x0, y0)))
    end
    local references = {}
    -- sort references before placing them, otherwise this can cause placement of wrong cells
    table.sort(cell.references, function(lhs, rhs) return lhs.name < rhs.name end)
    for _, ref in ipairs(cell.references) do
        if flatpattern and string.match(ref.name, flatpattern) then
            local other
            for _, o in ipairs(cells) do
                if o.name == ref.name then
                    other = o
                end
            end
            _write_cell(chunk, other, cells, path, dirname, layermap, alignmentbox, flatpattern, ref.pts[1], ref.pts[2])
        else
            local cellname = string.format("%s/%s", dirname, ref.name)
            if not references[cellname] then
                table.insert(chunk, string.format('    ref = pcell.create_layout("%s")', cellname))
                table.insert(chunk, string.format('    name = pcell.add_cell_reference(ref, "%s")', ref.name))
                references[cellname] = true
            end
            if ref.xrep then -- AREF
                local xpitch = (ref.pts[3] - ref.pts[1]) / ref.xrep
                local ypitch = (ref.pts[6] - ref.pts[2]) / ref.yrep
                table.insert(chunk, string.format('    child = cell:add_child_array(name, %d, %d, %d, %d)', ref.xrep, ref.yrep, xpitch, ypitch))
            else
                table.insert(chunk, string.format('    child = cell:add_child(name)'))
            end
            if ref.angle == 180 then
                if ref.transformation and ref.transformation[1] == 1 then
                    table.insert(chunk, string.format('    child:mirror_at_yaxis()'))
                else
                    table.insert(chunk, string.format('    child:mirror_at_yaxis()'))
                    table.insert(chunk, string.format('    child:mirror_at_xaxis()'))
                end
            elseif ref.angle == 90 then
                table.insert(chunk, string.format('    child:rotate_90()'))
            else
                if ref.transformation and ref.transformation[1] == 1 then
                    table.insert(chunk, string.format('    child:mirror_at_xaxis()'))
                end
            end
            table.insert(chunk, string.format('    child:translate(%d, %d)', ref.pts[1], ref.pts[2]))
        end
    end
    for _, label in ipairs(cell.labels) do
        local pointstr = string.format('point.create(%d, %d)', label.pts[1], label.pts[2])
        local lpp = _format_lpp(label.layer, label.purpose, layermap)
        table.insert(chunk, string.format('    cell:add_port("%s", %s, %s)', label.text, lpp, pointstr))
    end
    if cell.alignmentbox then
        local bl = string.format("point.create(%d, %d)", cell.alignmentbox.blx, cell.alignmentbox.bly)
        local tr = string.format("point.create(%d, %d)", cell.alignmentbox.trx, cell.alignmentbox.try)
        table.insert(chunk, string.format('    cell:set_alignment_box(%s, %s)', bl, tr))
    end
end

function M.translate_cells(cells, prefix, dirname, layermap, alignmentbox, overwrite, flatpattern, namepattern)
    local path
    if prefix and prefix ~= "" then
        path = string.format("%s/%s", prefix, dirname)
    else
        path = string.format("%s/%s", dirname, dirname)
    end
    if not filesystem.exists(path) or overwrite then
        local created = filesystem.mkdir(path)
        if created then
            if not alignmentbox then
                print("importing cells without any alignmentbox information. The resulting cells won't have an alignmentbox")
            end
            for _, cell in ipairs(cells) do
                if not flatpattern or not string.match(cell.name, flatpattern) then
                    local chunk = {
                        "function parameters() end",
                        "function layout(cell)",
                        "    local ref, name, child",
                    }
                    _write_cell(chunk, cell, cells, path, dirname, layermap, alignmentbox, flatpattern, 0, 0)
                    local cellbasename = string.match(cell.name, namepattern)
                    local filename = string.format("%s/%s.lua", path, cellbasename)
                    local cellfile = io.open(filename, "w")
                    if not cellfile then
                        moderror(string.format("import: could not open file for cell export. Did you create the appropriate directory (%s)?", dirname))
                    end
                    table.insert(chunk, "end") -- close 'layout' function
                    cellfile:write(string.format("%s\n", table.concat(chunk, "\n")))
                    cellfile:close()
                    if envlib.get("verbose") then
                        print(string.format("import: created %s", filename))
                    end
                end
                -- flattened cells don't need to be created
            end
        else
            moderror("import: could not create import directory")
        end
    else
        moderror("import: directory exists. Use --import-overwrite to overwrite this directory");
    end
end

return M
