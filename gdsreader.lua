local M = {}

local recordtable = {
    [0x00] = "HEADER",
    [0x01] = "BEGINLIB",
    [0x02] = "LIBNAME",
    [0x03] = "UNITS",
    [0x04] = "ENDLIB",
    [0x05] = "BGNSTR",
    [0x06] = "STRNAME",
    [0x07] = "ENDSTR",
    [0x08] = "BOUNDARY",
    [0x09] = "PATH",
    [0x0a] = "SREF",
    [0x0b] = "AREF",
    [0x0c] = "TEXT",
    [0x0d] = "LAYER",
    [0x0e] = "DATATYPE",
    [0x0f] = "WIDTH",
    [0x10] = "XY",
    [0x11] = "ENDEL",
    [0x12] = "SNAME",
    [0x15] = "NODE",
    [0x1a] = "STRANS",
    [0x1f] = "REFLIBS",
    [0x13] = "COLROW",
    [0x16] = "TEXTTYPE",
    [0x17] = "PRESENTATION",
    [0x18] = "MAG",
    [0x19] = "ASCIISTRING",
    [0x1c] = "ANGLE",
    [0x20] = "FONTS",
    [0x21] = "PATHTYPE",
    [0x22] = "GENERATIONS",
    [0x23] = "ATTRTABLE",
    [0x26] = "ELFLAGS",
    [0x2a] = "NODETYPE",
    [0x2d] = "BOX",
    [0x2e] = "BOXTYPE",
    [0x2f] = "PLEX",
    [0x36] = "FORMAT",
    [0x37] = "MASK",
    [0x38] = "ENDMASK",
}
for k, v in ipairs(recordtable) do
    recordtable[v] = k
end
local datatable = {
    NONE                = 0x00,
    BIT_ARRAY           = 0x01,
    TWO_BYTE_INTEGER    = 0x02,
    FOUR_BYTE_INTEGER   = 0x03,
    FOUR_BYTE_REAL      = 0x04,
    EIGHT_BYTE_REAL     = 0x05,
    ASCII_STRING        = 0x06,
}
for k, v in ipairs(datatable) do
    datatable[v] = k
end

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
        if header.recordtype == recordtable.ENDLIB then
            break
        end
    end
    return records
end

local function _format_lpp(layer, purpose, layermap)
    local lppt = {
        string.format("gds = { layer = %d, purpose = %d }", layer, purpose)
    }
    if layermap then
        for k, v in pairs(layermap) do
            if v[layer] then
                if v[layer][purpose] then
                    table.insert(lppt, string.format("%s = { layer = %q, purpose = %q }", k, v[layer][purpose].layer, v[layer][purpose].purpose))
                end
            end
        end
    end
    return string.format("generics.premapped(nil, { %s })", table.concat(lppt, ", "))
end

function M.read_cells_and_write(filename, dirname, layermap)
    local records = _read_stream(filename)
    local instructure = false
    local inshape = "none"
    local strname
    local shapes
    local layer
    local purpose
    local pts
    local width
    local function is_record(record, rtype) return record.header.recordtype == rtype end
    for _, record in ipairs(records) do
        if is_record(record, recordtable.BGNSTR) then
            instructure = true
            shapes = {}
        elseif is_record(record, recordtable.ENDSTR) then
            instructure = false
            local chunkt = {}
            for _, shape in ipairs(shapes) do
                table.insert(chunkt, string.format("cell:merge_into_shallow(%s)", shape))
            end
            local cellfile = io.open(string.format("%s/%s.lua", dirname, strname), "w")
            if not cellfile then
                moderror(string.format("gdsreader: could not open file for cell export. Did you create the appropriate directory (%s)?", dirname))
            end
            cellfile:write("function parameters()\nend\n")
            cellfile:write("\n")
            cellfile:write(string.format("function layout(cell)\n%s\nend\n", table.concat(chunkt, "\n")))
            cellfile:close()
        elseif instructure then
            -- structure name
            if is_record(record, recordtable.STRNAME) then
                strname = record.data
            -- structure shapes
            elseif is_record(record, recordtable.BOX) then
                inshape = "BOX"
            elseif is_record(record, recordtable.BOUNDARY) then
                inshape = "BOUNDARY"
            elseif is_record(record, recordtable.PATH) then
                inshape = "PATH"
            elseif is_record(record, recordtable.ENDEL) then
                if inshape == "BOX" then
                    local lpp = _format_lpp(layer, purpose, layermap)
                    local bl = string.format("point.create(%d, %d)", pts[1], pts[2])
                    local tr = string.format("point.create(%d, %d)", pts[5], pts[6])
                    table.insert(shapes, string.format("geometry.rectanglebltr(%s, %s, %s)", lpp, bl, tr))
                elseif inshape == "BOUNDARY" then
                    local lpp = _format_lpp(layer, purpose, layermap)
                    local ptsstrt = {}
                    for i = 1, #pts - 1, 2 do
                        table.insert(ptsstrt, string.format("point.create(%d, %d)", pts[i], pts[i + 1]))
                    end
                    table.insert(shapes, string.format("geometry.polygon(%s, { %s })", lpp, table.concat(ptsstrt, ", ")))
                elseif inshape == "PATH" then
                    local lpp = _format_lpp(layer, purpose, layermap)
                    local ptsstrt = {}
                    for i = 1, #pts - 1, 2 do
                        table.insert(ptsstrt, string.format("point.create(%d, %d)", pts[i], pts[i + 1]))
                    end
                    table.insert(shapes, string.format("geometry.path(%s, { %s }, %d)", lpp, table.concat(ptsstrt, ", "), width))
                end
                inshape = "none"
            elseif inshape ~= "none" then
                if is_record(record, recordtable.LAYER) then
                    layer = record.data
                elseif is_record(record, recordtable.DATATYPE) then
                    purpose = record.data
                elseif is_record(record, recordtable.XY) then
                    pts = record.data
                elseif is_record(record, recordtable.WIDTH) then
                    width = record.data
                end
            end
        end
    end
end

return M
