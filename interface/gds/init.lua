local M = {}

function M.get_extension()
    return "gds"
end

-- private variables
local gridfmt = "%.3f"

local recordtypes = {
    HEADER      = 0x00,
    BGNLIB      = 0x01,
    LIBNAME     = 0x02,
    UNITS       = 0x03,
    ENDLIB      = 0x04,
    BGNSTR      = 0x05,
    STRNAME     = 0x06,
    ENDSTR      = 0x07,
    BOUNDARY    = 0x08,
    LAYER       = 0x0d,
    DATATYPE    = 0x0e,
    XY          = 0x10,
    ENDEL       = 0x11,
}

local datatypes = {
    NONE                = 0x00,
    BIT_ARRAY           = 0x01,
    TWO_BYTE_INTEGER    = 0x02,
    FOUR_BYTE_INTEGER   = 0x03,
    FOUR_BYTE_REAL      = 0x04,
    EIGHT_BYTE_REAL     = 0x05,
    ASCII_STRING        = 0x06,
}

-- helper functions
local function _gdsfloat_to_number(data, width)
    local sign      =  data[1] & 0x80
    local exp       = (data[1] & 0x7f) - 64
    local mantissa  = 0
    for m = 2, width do
        mantissa = mantissa + data[m] * (256 ^ (1 - m))
    end
    local num = mantissa * 16^exp
    if sign > 0 then
        return -num
    else
        return num
    end
end

local function _number_to_gdsfloat(num, width)
    local data = {}
    if num == 0 then
        for i = 1, width do
            data[i] = 0x00
        end
        return data
    end
    local num = num
    local sign = num < 0
    local exp = 0
    while num >= 1 do
        num = num / 16
        exp = exp + 1
    end
    while num < 0.0625 do
        num = num * 16
        exp = exp - 1
    end
    if sign then
        data[1] = 0x80 + (exp + 64) & 0x7f
    else
        data[1] = 0x00 + (exp + 64) & 0x7f
    end
    for i = 2, width do
        local int, frac = math.modf(num * 256)
        num = frac
        data[i] = int
    end
    return data
end

local function _split_in_bytes(number, bytes)
    local bits = 8
    local t = {}
    for i = bytes, 1, -1 do
        local byte = (number & ((2^bits - 1) << (i - 1) * bits)) >> (i - 1) * bits
        table.insert(t, byte)
    end
    return t
end

local datatable = {
    [0x00] = nil,
    [0x01] = function(nums) 
        local data = {}
        for _, num in ipairs(nums) do 
            for _, b in ipairs(_split_in_bytes(num, 2)) do
                table.insert(data, b)
            end
        end
        return data
    end,
    [0x02] = function(nums) 
        local data = {}
        for _, num in ipairs(nums) do 
            for _, b in ipairs(_split_in_bytes(num, 2)) do
                table.insert(data, b)
            end
        end
        return data
    end,
    [0x03] = function(nums) 
        local data = {}
        for _, num in ipairs(nums) do 
            for _, b in ipairs(_split_in_bytes(num, 4)) do
                table.insert(data, b)
            end
        end
        return data
    end,
    [0x04] = function(nums)
        local data = {}
        for _, num in ipairs(nums) do
            for _, b in _number_to_gdsfloat(num, 4) do
                table.insert(data, b)
            end
        end
        return data
    end,
    [0x05] = function(nums)
        local data = {}
        for _, num in ipairs(nums) do
            for _, b in ipairs(_number_to_gdsfloat(num, 8)) do
                table.insert(data, b)
            end
        end
        return data
    end,
    [0x06] = function(str) return { string.byte(str, 1, #str) } end,
}

local function _assemble(...)
    local args = { ... }
    local t = {}
    for _, data in ipairs(args) do
        for _, datum in ipairs(data) do
            table.insert(t, string.char(datum))
        end
    end
    return table.concat(t)
end

local function _write_record(file, recordtype, datatype, content)
    local data = {
        0x00, 0x00, -- dummy bytes for length, will be filled later
        recordtype, datatype
    }
    local func = datatable[datatype]
    if func then
        for _, b in ipairs(func(content)) do
            table.insert(data, b)
        end
    end
    -- pad with final zero if #data is odd
    if #data % 2 ~= 0 then
        table.insert(data, 0x00)
    end
    local lenbytes = _split_in_bytes(#data, 2)
    data[1] = lenbytes[1]
    data[2] = lenbytes[2]
    file:write(_assemble(data))
end

local function _start_stream(file)
    _write_record(file, recordtypes.HEADER, datatypes.TWO_BYTE_INTEGER, { 5 })
    _write_record(file, recordtypes.BGNLIB, datatypes.TWO_BYTE_INTEGER, { 2020, 7, 5, 18, 17, 51, 2020, 7, 5, 18, 17, 51 })
    _write_record(file, recordtypes.LIBNAME, datatypes.ASCII_STRING, "testlib")
    _write_record(file, recordtypes.UNITS, datatypes.EIGHT_BYTE_REAL, { 0.001, 1e-9 })
end

local function _unpack_points(pts, multiplier)
    local stream = {}
    for _, pt in ipairs(pts) do
        table.insert(stream, math.floor(pt.x * multiplier))
        table.insert(stream, math.floor(pt.y * multiplier))
    end
    return stream
end

local function _write_shape(file, shape)
    if not shape.lpp then return end
    _write_record(file, recordtypes.BOUNDARY, datatypes.NONE)
    _write_record(file, recordtypes.LAYER, datatypes.TWO_BYTE_INTEGER, { shape.lpp.layer.number })
    _write_record(file, recordtypes.DATATYPE, datatypes.TWO_BYTE_INTEGER, { shape.lpp.purpose.number })
    _write_record(file, recordtypes.XY, datatypes.FOUR_BYTE_INTEGER, _unpack_points(shape.points, 1000))
    _write_record(file, recordtypes.ENDEL, datatypes.NONE)
end

local function _end_stream(file)
    _write_record(file, recordtypes.ENDLIB, datatypes.NONE)
end

function M.print_object(file, obj)
    _start_stream(file)
    _write_record(file, recordtypes.BGNSTR, datatypes.TWO_BYTE_INTEGER, { 2020, 7, 5, 18, 17, 51, 2020, 7, 5, 18, 17, 51 })
    _write_record(file, recordtypes.STRNAME, datatypes.ASCII_STRING, "toplevelcell")
    for shape in obj:iter() do
        _write_shape(file, shape)
    end
    -- write ENDSTR
    _write_record(file, recordtypes.ENDSTR, datatypes.NONE)
    _end_stream(file)
end

return M
