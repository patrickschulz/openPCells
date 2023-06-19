local M = {}

local __libname = "opclib"
local __textmode = false

local __userunit = 0.001
local __databaseunit = 1e-9

local __labelsize = 1

local recordtypes = gdstypetable.recordtypes
local datatypes = gdstypetable.datatypes

local function _number_to_gdsfloat(num, width)
    local data = {}
    if num == 0 then
        for i = 1, width do
            data[i] = 0x00
        end
        return data
    end
    local sign = false
    if num < 0.0 then
        sign = true
        num = -num
    end
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
        data[1] = 0x80 + ((exp + 64) & 0x7f)
    else
        data[1] = 0x00 + ((exp + 64) & 0x7f)
    end
    for i = 2, width do
        local int, frac = math.modf(num * 256)
        num = frac
        data[i] = int
    end
    return data
end

local datatable = {
    [datatypes.NONE] = nil,
    [datatypes.BIT_ARRAY] = function(nums)
        local data = {}
        for _, num in ipairs(nums) do
            for _, b in ipairs(binarylib.split_in_bytes(num, 2)) do
                table.insert(data, b)
            end
        end
        return data
    end,
    [datatypes.TWO_BYTE_INTEGER] = function(nums)
        local data = {}
        for _, num in ipairs(nums) do
            for _, b in ipairs(binarylib.split_in_bytes(num, 2)) do
                table.insert(data, b)
            end
        end
        return data
    end,
    [datatypes.FOUR_BYTE_INTEGER] = function(nums)
        local data = {}
        for _, num in ipairs(nums) do
            for _, b in ipairs(binarylib.split_in_bytes(num, 4)) do
                table.insert(data, b)
            end
        end
        return data
    end,
    [datatypes.FOUR_BYTE_REAL] = function(nums)
        local data = {}
        for _, num in ipairs(nums) do
            for _, b in _number_to_gdsfloat(num, 4) do
                table.insert(data, b)
            end
        end
        return data
    end,
    [datatypes.EIGHT_BYTE_REAL] = function(nums)
        local data = {}
        for _, num in ipairs(nums) do
            for _, b in ipairs(_number_to_gdsfloat(num, 8)) do
                table.insert(data, b)
            end
        end
        return data
    end,
    [datatypes.ASCII_STRING] = function(str) return { string.byte(str, 1, #str) } end,
}

local function _assemble_data(recordtype, datatype, content)
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
    local lenbytes = binarylib.split_in_bytes(#data, 2)
    data[1], data[2] = lenbytes[1], lenbytes[2]
    return data
end

local __content = {}

local function _write_record(recordtype, datatype, content)
    if datatype == datatypes.NONE then
        table.insert(__content, string.format("%12s #(%4d)\n", recordtype.name, 4))
    else
        local data = _assemble_data(recordtype.code, datatype, content)
        local str
        if datatype == datatypes.NONE then
        elseif datatype == datatypes.BIT_ARRAY or
               datatype == datatypes.TWO_BYTE_INTEGER or
               datatype == datatypes.FOUR_BYTE_INTEGER or
               datatype == datatypes.FOUR_BYTE_REAL or
               datatype == datatypes.EIGHT_BYTE_REAL then
            str = table.concat(content, " ")
        elseif datatype == datatypes.ASCII_STRING then
            str = content
        end
        table.insert(__content, string.format("%12s #(%4d): { %s }\n", recordtype.name, #data, str))
    end
end

local function _unpack_points(pts)
    local multiplier = 1e9 * __databaseunit -- opc works in nanometers
    local stream = {}
    for _, pt in ipairs(pts) do
        table.insert(stream, multiplier * pt.x)
        table.insert(stream, multiplier * pt.y)
    end
    return stream
end

-- public interface
function M.finalize()
    return table.concat(__content)
end

function M.get_extension()
    return "gdstext"
end

function M.set_options(opt)
    if opt.libname then __libname = opt.libname end

    if opt.userunit then
        __userunit = tonumber(opt.userunit)
    end
    if opt.databaseunit then
        __databaseunit = tonumber(opt.databaseunit)
    end

    if opt.disablepath then
        M.write_path = nil
    end

    if opt.labelsize then
        __labelsize = opt.labelsize
    end
end

function M.get_layer(S)
    local lpp = S:get_lpp():get()
    return { layer = lpp.layer, purpose = lpp.purpose }
end

function M.at_begin()
    _write_record(recordtypes.HEADER, datatypes.TWO_BYTE_INTEGER, { 258 }) -- release 6.0
    local date = os.date("*t")
    _write_record(recordtypes.BGNLIB, datatypes.TWO_BYTE_INTEGER, { 
        date.year, date.month, date.day, date.hour, date.min, date.sec, -- last modification time
        date.year, date.month, date.day, date.hour, date.min, date.sec  -- last access time
    })
    _write_record(recordtypes.LIBNAME, datatypes.ASCII_STRING, __libname)
    _write_record(recordtypes.UNITS, datatypes.EIGHT_BYTE_REAL, { __userunit, __databaseunit })
end

function M.at_end()
    _write_record(recordtypes.ENDLIB, datatypes.NONE)
end

function M.at_begin_cell(cellname)
    local date = os.date("*t")
    _write_record(recordtypes.BGNSTR, datatypes.TWO_BYTE_INTEGER, { 
        date.year, date.month, date.day, date.hour, date.min, date.sec, -- last modification time
        date.year, date.month, date.day, date.hour, date.min, date.sec  -- last access time
    })
    _write_record(recordtypes.STRNAME, datatypes.ASCII_STRING, cellname)
end

function M.at_end_cell()
    _write_record(recordtypes.ENDSTR, datatypes.NONE)
end

function M.write_rectangle(layer, bl, tr)
    _write_record(recordtypes.BOUNDARY, datatypes.NONE)
    _write_record(recordtypes.LAYER, datatypes.TWO_BYTE_INTEGER, { layer.layer })
    _write_record(recordtypes.DATATYPE, datatypes.TWO_BYTE_INTEGER, { layer.purpose})
    local multiplier = 1e9 * __databaseunit -- opc works in nanometers
    local ptstream = {
        multiplier * bl.x, multiplier * bl.y,
        multiplier * tr.x, multiplier * bl.y,
        multiplier * tr.x, multiplier * tr.y,
        multiplier * bl.x, multiplier * tr.y,
        multiplier * bl.x, multiplier * bl.y
    }
    _write_record(recordtypes.XY, datatypes.FOUR_BYTE_INTEGER, ptstream)
    _write_record(recordtypes.ENDEL, datatypes.NONE)
end

function M.write_polygon(layer, pts)
    --local ptstream = _unpack_points(pts)
    --_write_record(recordtypes.BOUNDARY, datatypes.NONE)
    --_write_record(recordtypes.LAYER, datatypes.TWO_BYTE_INTEGER, { layer.layer })
    --_write_record(recordtypes.DATATYPE, datatypes.TWO_BYTE_INTEGER, { layer.purpose})
    --_write_record(recordtypes.XY, datatypes.FOUR_BYTE_INTEGER, ptstream)
    --_write_record(recordtypes.ENDEL, datatypes.NONE)
end

function M.write_path(layer, pts, width, extension)
    local ptstream = _unpack_points(pts)
    _write_record(recordtypes.PATH, datatypes.NONE)
    _write_record(recordtypes.LAYER, datatypes.TWO_BYTE_INTEGER, { layer.layer })
    _write_record(recordtypes.DATATYPE, datatypes.TWO_BYTE_INTEGER, { layer.purpose })
    if extension == "butt" then
        -- (implicit)
        --_write_record(recordtypes.PATHTYPE, datatypes.TWO_BYTE_INTEGER, { 0 })
    elseif extension == "round" then
        _write_record(recordtypes.PATHTYPE, datatypes.TWO_BYTE_INTEGER, { 1 })
    elseif extension == "cap" then
        _write_record(recordtypes.PATHTYPE, datatypes.TWO_BYTE_INTEGER, { 2 })
    elseif type(extension) == "table" then
        _write_record(recordtypes.PATHTYPE, datatypes.TWO_BYTE_INTEGER, { 4 })
    end
    _write_record(recordtypes.WIDTH, datatypes.FOUR_BYTE_INTEGER, { width })
    -- these records have to come after WIDTH (at least for klayout, but they also are in this order in the GDS manual)
    if type(extension) == "table" then
        _write_record(recordtypes.BGNEXTN, datatypes.FOUR_BYTE_INTEGER, { extension[1] })
        _write_record(recordtypes.ENDEXTN, datatypes.FOUR_BYTE_INTEGER, { extension[2] })
    end
    _write_record(recordtypes.XY, datatypes.FOUR_BYTE_INTEGER, ptstream)
    _write_record(recordtypes.ENDEL, datatypes.NONE)
end

function M.write_cell_reference(identifier, instname, x, y, orientation)
    _write_record(recordtypes.SREF, datatypes.NONE)
    _write_record(recordtypes.SNAME, datatypes.ASCII_STRING, identifier)
    if orientation == "fx" then
        _write_record(recordtypes.STRANS, datatypes.BIT_ARRAY, { 0x8000 })
        _write_record(recordtypes.ANGLE, datatypes.EIGHT_BYTE_REAL, { 180 })
    elseif orientation == "fy" then
        _write_record(recordtypes.STRANS, datatypes.BIT_ARRAY, { 0x8000 })
    elseif orientation == "R180" then
        _write_record(recordtypes.STRANS, datatypes.BIT_ARRAY, { 0x0000 })
        _write_record(recordtypes.ANGLE, datatypes.EIGHT_BYTE_REAL, { 180 })
    elseif orientation == "R90" then
        _write_record(recordtypes.STRANS, datatypes.BIT_ARRAY, { 0x0000 })
        _write_record(recordtypes.ANGLE, datatypes.EIGHT_BYTE_REAL, { 90 })
    end
    local multiplier = 1e9 * __databaseunit -- opc works in nanometers
    _write_record(recordtypes.XY, datatypes.FOUR_BYTE_INTEGER, { multiplier * x, multiplier * y })
    _write_record(recordtypes.ENDEL, datatypes.NONE)
end

function M.write_cell_array(identifier, instbasename, x, y, orientation, xrep, yrep, xpitch, ypitch)
    _write_record(recordtypes.AREF, datatypes.NONE)
    _write_record(recordtypes.SNAME, datatypes.ASCII_STRING, identifier)
    if orientation == "fx" then
        _write_record(recordtypes.STRANS, datatypes.BIT_ARRAY, { 0x8000 })
        _write_record(recordtypes.ANGLE, datatypes.EIGHT_BYTE_REAL, { 180 })
    elseif orientation == "fy" then
        _write_record(recordtypes.STRANS, datatypes.BIT_ARRAY, { 0x8000 })
    elseif orientation == "R180" then
        _write_record(recordtypes.ANGLE, datatypes.EIGHT_BYTE_REAL, { 180 })
    end
    _write_record(recordtypes.COLROW, datatypes.TWO_BYTE_INTEGER, { xrep, yrep })
    local multiplier = 1e9 * __databaseunit -- opc works in nanometers
    _write_record(recordtypes.XY, datatypes.FOUR_BYTE_INTEGER, {
        multiplier * x,                   multiplier * y,
        multiplier * (x + xrep + xpitch), multiplier * y,
        multiplier * x,                   multiplier * (y + yrep + ypitch),
    })
    _write_record(recordtypes.ENDEL, datatypes.NONE)
end

function M.write_port(name, layer, where)
    _write_record(recordtypes.TEXT, datatypes.NONE)
    _write_record(recordtypes.LAYER, datatypes.TWO_BYTE_INTEGER, { layer.layer })
    _write_record(recordtypes.TEXTTYPE, datatypes.TWO_BYTE_INTEGER, { layer.purpose })
    _write_record(recordtypes.PRESENTATION, datatypes.BIT_ARRAY, { 0x0005 }) -- center:center presentation
    _write_record(recordtypes.MAG, datatypes.EIGHT_BYTE_REAL, { __labelsize * __databaseunit })
    local multiplier = 1e9 * __databaseunit -- opc works in nanometers
    _write_record(recordtypes.XY, datatypes.FOUR_BYTE_INTEGER, { multiplier * where.x, multiplier * where.y })
    _write_record(recordtypes.STRING, datatypes.ASCII_STRING, name)
    _write_record(recordtypes.ENDEL, datatypes.NONE)
end

return M
