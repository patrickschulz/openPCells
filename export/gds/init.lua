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

local function _write_text_record(file, recordtype, datatype, content)
    if datatype == datatypes.NONE then
        file:write(string.format("%12s #(%4d)\n", recordtype.name, 4))
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
        file:write(string.format("%12s #(%4d): { %s }\n", recordtype.name, #data, str))
    end
end

local function _write_binary_record(file, recordtype, datatype, content)
    local data = _assemble_data(recordtype.code, datatype, content)
    file:write_binary(data)
end

-- function "pointer" which (affected by __textmode option)
local _write_record = _write_binary_record

local function _unpack_points(pts)
    local multiplier = 1e9 * __databaseunit -- opc works in nanometers
    local stream = {}
    for _, pt in ipairs(pts) do
        local x, y = pt:unwrap()
        table.insert(stream, multiplier * x)
        table.insert(stream, multiplier * y)
    end
    return stream
end

-- public interface
function M.get_extension()
    if __textmode then
        return "gdstext"
    else
        return "gds"
    end
end

function M.set_options(opt)
    if opt.libname then __libname = opt.libname end

    if opt.userunit then
        __userunit = tonumber(opt.userunit)
    end
    if opt.databaseunit then
        __databaseunit = tonumber(opt.databaseunit)
    end

    if opt.textmode then -- enable textmode
        __textmode = true
        _write_record = _write_text_record
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

function M.at_begin(file)
    _write_record(file, recordtypes.HEADER, datatypes.TWO_BYTE_INTEGER, { 258 }) -- release 6.0
    local date = os.date("*t")
    _write_record(file, recordtypes.BGNLIB, datatypes.TWO_BYTE_INTEGER, { 
        date.year, date.month, date.day, date.hour, date.min, date.sec, -- last modification time
        date.year, date.month, date.day, date.hour, date.min, date.sec  -- last access time
    })
    _write_record(file, recordtypes.LIBNAME, datatypes.ASCII_STRING, __libname)
    _write_record(file, recordtypes.UNITS, datatypes.EIGHT_BYTE_REAL, { __userunit, __databaseunit })
end

function M.at_end(file)
    _write_record(file, recordtypes.ENDLIB, datatypes.NONE)
end

function M.at_begin_cell(file, cellname)
    local date = os.date("*t")
    _write_record(file, recordtypes.BGNSTR, datatypes.TWO_BYTE_INTEGER, { 
        date.year, date.month, date.day, date.hour, date.min, date.sec, -- last modification time
        date.year, date.month, date.day, date.hour, date.min, date.sec  -- last access time
    })
    _write_record(file, recordtypes.STRNAME, datatypes.ASCII_STRING, cellname)
end

function M.at_end_cell(file)
    _write_record(file, recordtypes.ENDSTR, datatypes.NONE)
end

function M.write_rectangle(file, layer, bl, tr)
    _write_record(file, recordtypes.BOUNDARY, datatypes.NONE)
    _write_record(file, recordtypes.LAYER, datatypes.TWO_BYTE_INTEGER, { layer.layer })
    _write_record(file, recordtypes.DATATYPE, datatypes.TWO_BYTE_INTEGER, { layer.purpose})
    local ptstream = _unpack_points({ bl, point.combine_21(bl, tr), tr, point.combine_12(bl, tr), bl })
    _write_record(file, recordtypes.XY, datatypes.FOUR_BYTE_INTEGER, ptstream)
    _write_record(file, recordtypes.ENDEL, datatypes.NONE)
end

function M.write_polygon(file, layer, pts)
    local ptstream = _unpack_points(pts)
    _write_record(file, recordtypes.BOUNDARY, datatypes.NONE)
    _write_record(file, recordtypes.LAYER, datatypes.TWO_BYTE_INTEGER, { layer.layer })
    _write_record(file, recordtypes.DATATYPE, datatypes.TWO_BYTE_INTEGER, { layer.purpose})
    _write_record(file, recordtypes.XY, datatypes.FOUR_BYTE_INTEGER, ptstream)
    _write_record(file, recordtypes.ENDEL, datatypes.NONE)
end

function M.write_path(file, layer, pts, width, extension)
    local ptstream = _unpack_points(pts)
    _write_record(file, recordtypes.PATH, datatypes.NONE)
    _write_record(file, recordtypes.LAYER, datatypes.TWO_BYTE_INTEGER, { layer.layer })
    _write_record(file, recordtypes.DATATYPE, datatypes.TWO_BYTE_INTEGER, { layer.purpose })
    if extension == "butt" then
        -- (implicit)
        --_write_record(file, recordtypes.PATHTYPE, datatypes.TWO_BYTE_INTEGER, { 0 })
    elseif extension == "round" then
        _write_record(file, recordtypes.PATHTYPE, datatypes.TWO_BYTE_INTEGER, { 1 })
    elseif extension == "square" then
        _write_record(file, recordtypes.PATHTYPE, datatypes.TWO_BYTE_INTEGER, { 2 })
    elseif type(extension) == "table" then
        _write_record(file, recordtypes.PATHTYPE, datatypes.TWO_BYTE_INTEGER, { 4 })
    end
    _write_record(file, recordtypes.WIDTH, datatypes.FOUR_BYTE_INTEGER, { width })
    -- these records have to come after WIDTH (at least for klayout, but they also are in this order in the GDS manual)
    if type(extension) == "table" then
        _write_record(file, recordtypes.BGNEXTN, datatypes.FOUR_BYTE_INTEGER, { extension[1] })
        _write_record(file, recordtypes.ENDEXTN, datatypes.FOUR_BYTE_INTEGER, { extension[2] })
    end
    _write_record(file, recordtypes.XY, datatypes.FOUR_BYTE_INTEGER, ptstream)
    _write_record(file, recordtypes.ENDEL, datatypes.NONE)
end

function M.write_cell_reference(file, identifier, x, y, orientation)
    _write_record(file, recordtypes.SREF, datatypes.NONE)
    _write_record(file, recordtypes.SNAME, datatypes.ASCII_STRING, identifier)
    if orientation == "fx" then
        _write_record(file, recordtypes.STRANS, datatypes.BIT_ARRAY, { 0x8000 })
        _write_record(file, recordtypes.ANGLE, datatypes.EIGHT_BYTE_REAL, { 180 })
    elseif orientation == "fy" then
        _write_record(file, recordtypes.STRANS, datatypes.BIT_ARRAY, { 0x8000 })
    elseif orientation == "R180" then
        _write_record(file, recordtypes.ANGLE, datatypes.EIGHT_BYTE_REAL, { 180 })
    elseif orientation == "R90" then
        _write_record(file, recordtypes.ANGLE, datatypes.EIGHT_BYTE_REAL, { 90 })
    end
    _write_record(file, recordtypes.XY, datatypes.FOUR_BYTE_INTEGER, _unpack_points({ point.create(x, y) }))
    _write_record(file, recordtypes.ENDEL, datatypes.NONE)
end

function M.write_cell_array(file, identifier, x, y, orientation, xrep, yrep, xpitch, ypitch)
    _write_record(file, recordtypes.AREF, datatypes.NONE)
    _write_record(file, recordtypes.SNAME, datatypes.ASCII_STRING, identifier)
    if orientation == "fx" then
        _write_record(file, recordtypes.STRANS, datatypes.BIT_ARRAY, { 0x8000 })
        _write_record(file, recordtypes.ANGLE, datatypes.EIGHT_BYTE_REAL, { 180 })
    elseif orientation == "fy" then
        _write_record(file, recordtypes.STRANS, datatypes.BIT_ARRAY, { 0x8000 })
    elseif orientation == "R180" then
        _write_record(file, recordtypes.ANGLE, datatypes.EIGHT_BYTE_REAL, { 180 })
    end
    _write_record(file, recordtypes.COLROW, datatypes.TWO_BYTE_INTEGER, { xrep, yrep })
    _write_record(file, recordtypes.XY, datatypes.FOUR_BYTE_INTEGER, 
        _unpack_points({ point.create(x, y), point.create(x + xrep * xpitch, y), point.create(x, y + yrep * ypitch) }))
    _write_record(file, recordtypes.ENDEL, datatypes.NONE)
end

function M.write_port(file, name, layer, where)
    _write_record(file, recordtypes.TEXT, datatypes.NONE)
    _write_record(file, recordtypes.LAYER, datatypes.TWO_BYTE_INTEGER, { layer.layer })
    _write_record(file, recordtypes.TEXTTYPE, datatypes.TWO_BYTE_INTEGER, { layer.purpose })
    _write_record(file, recordtypes.PRESENTATION, datatypes.BIT_ARRAY, { 0x0005 }) -- center:center presentation
    _write_record(file, recordtypes.MAG, datatypes.EIGHT_BYTE_REAL, { __labelsize * __databaseunit })
    _write_record(file, recordtypes.XY, datatypes.FOUR_BYTE_INTEGER, _unpack_points({ where }))
    _write_record(file, recordtypes.STRING, datatypes.ASCII_STRING, name)
    _write_record(file, recordtypes.ENDEL, datatypes.NONE)
end

return M
