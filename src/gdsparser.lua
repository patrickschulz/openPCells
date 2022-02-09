local recordcodes = gdstypetable.recordtypescodes
local recordnames = gdstypetable.recordtypesnames
local datatable = gdstypetable.datatypes

function gdsparser.read_stream(filename, ignorelpp)
    local libname
    local cells = {}
    local records = gdsparser.read_raw_stream(filename)
    local cell
    local shape
    local function is_record(record, rtype) return record.header.recordtype == recordcodes[rtype] end
    for _, record in ipairs(records) do
        if is_record(record, "LIBNAME") then
            libname = record.data
        elseif is_record(record, "BGNSTR") then
            cell = {
                shapes = {},
                references = {},
                labels = {}
            }
        elseif is_record(record, "ENDSTR") then
            table.insert(cells, cell)
            cell = nil
        elseif is_record(record, "STRNAME") then
            cell.name = record.data
        elseif is_record(record, "BOUNDARY") or
               is_record(record, "BOX") or
               is_record(record, "PATH") then
            obj = { 
                what = "shape",
                shapetype = (is_record(record, "BOUNDARY") and "polygon") or
                       (is_record(record, "BOX") and "rectangle") or
                       (is_record(record, "PATH") and "path")
            }
        elseif is_record(record, "SREF") then
            obj = { what = "sref" }
        elseif is_record(record, "AREF") then
            obj = { what = "aref" }
        elseif is_record(record, "TEXT") then
            obj = { what = "text" }
        elseif is_record(record, "ENDEL") then
            if obj.what == "shape" then
                table.insert(cell.shapes, obj)
            elseif obj.what == "sref" then
                table.insert(cell.references, obj)
            elseif obj.what == "aref" then
                table.insert(cell.references, obj)
            elseif obj.what == "text" then
                table.insert(cell.labels, obj)
            end
            obj = nil
        elseif is_record(record, "LAYER") then
            obj.layer = record.data
        elseif is_record(record, "DATATYPE") then
            obj.purpose = record.data
        elseif is_record(record, "TEXTTYPE") then
            obj.purpose = record.data
        elseif is_record(record, "XY") then
            obj.pts = record.data
        elseif is_record(record, "WIDTH") then
            obj.width = record.data
        elseif is_record(record, "PATHTYPE") then
            if record.data == 0 then
                obj.pathtype = "butt"
            elseif record.data == 1 then
                obj.pathtype = "round"
            elseif record.data == 2 then
                obj.pathtype = "cap"
            elseif record.data == 4 then
                obj.pathtype = { 0, 0 }
            end
        elseif is_record(record, "COLROW") then
            obj.xrep = record.data[1]
            obj.yrep = record.data[2]
        elseif is_record(record, "SNAME") then
            obj.name = record.data
        elseif is_record(record, "STRING") then
            obj.text = record.data
        elseif is_record(record, "STRANS") then
            obj.transformation = record.data
        elseif is_record(record, "ANGLE") then
            obj.angle = record.data
        elseif is_record(record, "BGNEXTN") then
            obj.pathtype[1] = record.data
        elseif is_record(record, "ENDEXTN") then
            obj.pathtype[2] = record.data
        end
    end
    -- check for ignored layer-purpose pairs
    if ignorelpp then
        for _, cell in ipairs(cells) do
            for i = #cell.shapes, 1, -1 do -- backwards for deletion
                local shape = cell.shapes[i]
                for _, lpp in ipairs(ignorelpp) do
                    local layer, purpose = string.match(lpp, "(%w+):(%w+)")
                    if shape.layer == tonumber(layer) and shape.purpose == tonumber(purpose) then
                        table.remove(cell.shapes, i)
                    end
                end
            end
        end
    end
    -- post-process cells
    -- -> BOX is not used for rectangles, at least most tool suppliers seem to do it this way
    --    therefor, we check if some "polygons" are actually rectangles and fix the shape types
    for _, cell in ipairs(cells) do
        for _, shape in ipairs(cell.shapes) do
            if shape.shapetype == "polygon" then
                if #shape.pts == 10 then -- rectangles in GDS have five points (xy -> * 2)
                    if (shape.pts[1] == shape.pts[3]   and
                        shape.pts[4] == shape.pts[6]   and
                        shape.pts[5] == shape.pts[7]   and
                        shape.pts[8] == shape.pts[10]  and
                        shape.pts[9] == shape.pts[1]   and
                        shape.pts[10] == shape.pts[2]) or
                       (shape.pts[2] == shape.pts[4]   and
                        shape.pts[3] == shape.pts[5]   and
                        shape.pts[6] == shape.pts[8]   and
                        shape.pts[7] == shape.pts[9]   and
                        shape.pts[9] == shape.pts[1]   and
                        shape.pts[10] == shape.pts[2])  then

                        shape.shapetype = "rectangle"
                        shape.pts = { 
                            math.min(shape.pts[1], shape.pts[3], shape.pts[5], shape.pts[7], shape.pts[9]),
                            math.min(shape.pts[2], shape.pts[4], shape.pts[6], shape.pts[8], shape.pts[10]),
                            math.max(shape.pts[1], shape.pts[3], shape.pts[5], shape.pts[7], shape.pts[9]),
                            math.max(shape.pts[2], shape.pts[4], shape.pts[6], shape.pts[8], shape.pts[10])
                        }
                    end
                end
            end

            if shape.shapetype == "path" then
                shape.pathtype = shape.pathtype or "butt"
            end
        end
    end
    return { libname = libname, cells = cells }
end

local function _get_cell_references(cell)
    local references = {}
    for _, ref in ipairs(cell.references) do
        table.insert(references, ref.name)
    end
    return references
end

local function _find_cell(cells, cellname)
    for _, cell in ipairs(cells) do
        if cell.name == cellname then
            return cell
        end
    end
end

local function _assemble_tree_element(cells, tree, cell, level)
    for _, ref in ipairs(cell.references) do
        local sub = _find_cell(cells, ref.name)
        table.insert(tree, { level = level + 1, cell = sub })
        _assemble_tree_element(cells, tree, sub, level + 1)
    end
end

function gdsparser.resolve_hierarchy(cells)
    local referenced = {}
    for _, cell in ipairs(cells) do
        local references = _get_cell_references(cell)
        for _, ref in ipairs(references) do
            table.insert(referenced, ref)
        end
    end
    local toplevel = {}
    for _, cell in ipairs(cells) do
        if not aux.any_of(function(r) return cell.name == r end, referenced) then
            table.insert(toplevel, cell)
        end
    end
    local tree = {}
    for _, cell in ipairs(toplevel) do
        table.insert(tree, { level = 0, cell = cell })
        _assemble_tree_element(cells, tree, cell, 0)
    end
    return tree
end
