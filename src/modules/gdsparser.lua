local recordtypes = {
    BGNSTR          = { name = "BGNSTR",        code = 0x05 },
    STRNAME         = { name = "STRNAME",       code = 0x06 },
    ENDSTR          = { name = "ENDSTR",        code = 0x07 },
    SREF            = { name = "SREF",          code = 0x0a },
    AREF            = { name = "AREF",          code = 0x0b },
    ENDEL           = { name = "ENDEL",         code = 0x11 },
    SNAME           = { name = "SNAME",         code = 0x12 },
}
local recordtypescodes = {}
for k, v in pairs(recordtypes) do
    recordtypescodes[v.name] = v.code
end
local recordcodes = recordtypescodes

function gdsparser.read_cells(filename, ignorelpp)
    local cells = {}
    local records, msg = gdsparser.read_raw_stream(filename)
    if not records then
        print(msg)
        return nil
    end
    local cell
    local obj
    local function is_record(record, rtype) return record.header.recordtype == recordcodes[rtype] end
    for _, record in ipairs(records) do
        if is_record(record, "BGNSTR") then
            cell = {
                references = {},
            }
        elseif is_record(record, "ENDSTR") then
            table.insert(cells, cell)
            cell = nil
        elseif is_record(record, "STRNAME") then
            cell.name = record.data
        elseif is_record(record, "SREF") then
            obj = { what = "sref" }
        elseif is_record(record, "AREF") then
            obj = { what = "aref" }
        elseif is_record(record, "ENDEL") then
            if obj then
                if obj.what == "sref" then
                    table.insert(cell.references, obj)
                elseif obj.what == "aref" then
                    table.insert(cell.references, obj)
                end
                obj = nil
            end
        elseif is_record(record, "SNAME") then
            obj.name = record.data
        end
    end
    return cells
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

local function _resolve_hierarchy(cells)
    local referenced = {}
    for _, cell in ipairs(cells) do
        local references = _get_cell_references(cell)
        for _, ref in ipairs(references) do
            table.insert(referenced, ref)
        end
    end
    local toplevel = {}
    for _, cell in ipairs(cells) do
        if not util.any_of(function(r) return cell.name == r end, referenced) then
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

function gdsparser.get_hierarchy(filename)
    local cells = gdsparser.read_cells(filename)
    return _resolve_hierarchy(cells)
end

