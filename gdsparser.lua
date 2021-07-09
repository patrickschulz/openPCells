local M = {}

local recordcodes = gdstypetable.recordtypescodes
local recordnames = gdstypetable.recordtypesnames
local datatable = gdstypetable.datatypes

local function read_bytes(file, numbytes)
    local t = {}
    local chunk = file:read(numbytes)
    for i = 1, numbytes do
        t[i] = string.byte(string.sub(chunk, i, i))
    end
    return t
end

local function read_integer(file, numbytes)
    local data = read_bytes(file, numbytes)
    local num = 0
    for i = 1, numbytes do 
        num = num + data[i] * (1 << (8 * (numbytes - i)))
    end
    return num
end

--[[
local function read_double(file, width)
    local chunk = file:read(width)
    local data = {}
    for i = 1, width do
        data[i] = string.byte(string.sub(chunk, i, i))
    end
    local sign = (data[1] & 0x80) >> 7
    local exp = (data[1] & 0x7f)
    local mantissa = 0
    for i = 2, width do
        mantissa = mantissa + data[i] / (256^(i - 1))
    end
    return sign * mantissa * (16 ^ (exp - 64))
end

local function read_string(file, numchars)
    return file:read(numchars)
end
--]]

local function read_header(file)
    local data = {
        length      = read_integer(file, 2),
        recordtype  = read_integer(file, 1),
        datatype    = read_integer(file, 1),
    }
    return data
end

local function read_data(file, header)
    local numbytes = header.length - 4
    return read_bytes(file, numbytes)
end

local function _parse_integer(data, width, start)
    start = start or 0
    local num = 0
    if data[start + 1] > 127 then -- negative
        num = -1 * 2^32
    end
    for i = 1, width do
        num = num + data[start + i] * (1 << (8 * (width - i)))
    end
    return num
end

local function _parse_data(header, data)
    if header.datatype == datatable.ASCII_STRING then
        local t = {}
        for i = 1, #data do
            table.insert(t, string.char(data[i]))
        end
        if data[#data] == 0 then
            t[#t] = nil
        end
        return table.concat(t)
    elseif header.datatype == datatable.TWO_BYTE_INTEGER then
        if #data > 2 then
            local nums = {}
            for i = 1, #data / 2 do
                local num = _parse_integer(data, 2, (i - 1) * 2)
                table.insert(nums, num)
            end
            return nums
        else
            return _parse_integer(data, 2)
        end
    elseif header.datatype == datatable.FOUR_BYTE_INTEGER then
        if #data > 4 then
            local nums = {}
            for i = 1, #data / 4 do
                local num = _parse_integer(data, 4, (i - 1) * 4)
                table.insert(nums, num)
            end
            return nums
        else
            return _parse_integer(data, 4)
        end
    else
        return 42
    end
end

-- read raw record
local function read_record(file)
    local header = read_header(file)
    if not header then return nil end
    local data = read_data(file, header)
    return header, data
end

local function _read_stream(filename)
    local file = io.open(filename, "r")
    local records = {}
    while true do
        local header, data = read_record(file)
        table.insert(records, { header = header, raw = data, data = _parse_data(header, data) })
        if header.recordtype == recordcodes.ENDLIB then
            break
        end
    end
    return records
end

function M.read(filename)
    local cells = {}
    local records = _read_stream(filename)
    local cell
    local shape
    local function is_record(record, rtype) return record.header.recordtype == recordcodes[rtype] end
    for _, record in ipairs(records) do
        if is_record(record, "BGNSTR") then
            cell = {
                shapes = {},
                references = {}
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
            end
            obj = nil
        elseif is_record(record, "LAYER") then
            obj.layer = record.data
        elseif is_record(record, "DATATYPE") then
            obj.purpose = record.data
        elseif is_record(record, "XY") then
            obj.pts = record.data
        elseif is_record(record, "WIDTH") then
            obj.width = record.data
        elseif is_record(record, "COLROW") then
            obj.xrep = record.data[1]
            obj.yrep = record.data[2]
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

function M.resolve_hierarchy(cells)
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

return M
