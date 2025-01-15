local M = {}

local __libname = "opclib"
local __textmode = false

local __userunit = 0.001
local __databaseunit = 1e-9

local __labelsize = 1

local recordtypes = {
    ["HEADER"] =       { code = 0x00, name = "HEADER", },
    ["BGNLIB"] =       { code = 0x01, name = "BGNLIB", },
    ["LIBNAME"] =      { code = 0x02, name = "LIBNAME", },
    ["UNITS"] =        { code = 0x03, name = "UNITS", },
    ["ENDLIB"] =       { code = 0x04, name = "ENDLIB", },
    ["BGNSTR"] =       { code = 0x05, name = "BGNSTR", },
    ["STRNAME"] =      { code = 0x06, name = "STRNAME", },
    ["ENDSTR"] =       { code = 0x07, name = "ENDSTR", },
    ["BOUNDARY"] =     { code = 0x08, name = "BOUNDARY", },
    ["PATH"] =         { code = 0x09, name = "PATH", },
    ["SREF"] =         { code = 0x0a, name = "SREF", },
    ["AREF"] =         { code = 0x0b, name = "AREF", },
    ["TEXT"] =         { code = 0x0c, name = "TEXT", },
    ["LAYER"] =        { code = 0x0d, name = "LAYER", },
    ["DATATYPE"] =     { code = 0x0e, name = "DATATYPE", },
    ["WIDTH"] =        { code = 0x0f, name = "WIDTH", },
    ["XY"] =           { code = 0x10, name = "XY", },
    ["ENDEL"] =        { code = 0x11, name = "ENDEL", },
    ["SNAME"] =        { code = 0x12, name = "SNAME", },
    ["COLROW"] =       { code = 0x13, name = "COLROW", },
    ["TEXTNODE"] =     { code = 0x14, name = "TEXTNODE", },
    ["NODE"] =         { code = 0x15, name = "NODE", },
    ["TEXTTYPE"] =     { code = 0x16, name = "TEXTTYPE", },
    ["PRESENTATION"] = { code = 0x17, name = "PRESENTATION", },
    ["SPACING"] =      { code = 0x18, name = "SPACING", },
    ["STRING"] =       { code = 0x19, name = "STRING", },
    ["STRANS"] =       { code = 0x1a, name = "STRANS", },
    ["MAG"] =          { code = 0x1b, name = "MAG", },
    ["ANGLE"] =        { code = 0x1c, name = "ANGLE", },
    ["UINTEGER"] =     { code = 0x1d, name = "UINTEGER", },
    ["USTRING"] =      { code = 0x1e, name = "USTRING", },
    ["REFLIBS"] =      { code = 0x1f, name = "REFLIBS", },
    ["FONTS"] =        { code = 0x20, name = "FONTS", },
    ["PATHTYPE"] =     { code = 0x21, name = "PATHTYPE", },
    ["GENERATIONS"] =  { code = 0x22, name = "GENERATIONS", },
    ["ATTRTABLE"] =    { code = 0x23, name = "ATTRTABLE", },
    ["STYPTABLE"] =    { code = 0x24, name = "STYPTABLE", },
    ["STRTYPE"] =      { code = 0x25, name = "STRTYPE", },
    ["ELFLAGS"] =      { code = 0x26, name = "ELFLAGS", },
    ["ELKEY"] =        { code = 0x27, name = "ELKEY", },
    ["LINKTYPE"] =     { code = 0x28, name = "LINKTYPE", },
    ["LINKKEYS"] =     { code = 0x29, name = "LINKKEYS", },
    ["NODETYPE"] =     { code = 0x2a, name = "NODETYPE", },
    ["PROPATTR"] =     { code = 0x2b, name = "PROPATTR", },
    ["PROPVALUE"] =    { code = 0x2c, name = "PROPVALUE", },
    ["BOX"] =          { code = 0x2d, name = "BOX", },
    ["BOXTYPE"] =      { code = 0x2e, name = "BOXTYPE", },
    ["PLEX"] =         { code = 0x2f, name = "PLEX", },
    ["BGNEXTN"] =      { code = 0x30, name = "BGNEXTN", },
    ["ENDEXTN"] =      { code = 0x31, name = "ENDEXTN", },
    ["TAPENUM"] =      { code = 0x32, name = "TAPENUM", },
    ["TAPECODE"] =     { code = 0x33, name = "TAPECODE", },
    ["STRCLASS"] =     { code = 0x34, name = "STRCLASS", },
    ["RESERVED"] =     { code = 0x35, name = "RESERVED", },
    ["FORMAT"] =       { code = 0x36, name = "FORMAT", },
    ["MASK"] =         { code = 0x37, name = "MASK", },
    ["ENDMASKS"] =     { code = 0x38, name = "ENDMASKS", },
    ["LIBDIRSIZE"] =   { code = 0x39, name = "LIBDIRSIZE", },
    ["SRFNAME"] =      { code = 0x3a, name = "SRFNAME", },
    ["LIBSECUR"] =     { code = 0x3b, name = "LIBSECUR", },
}

local datatypes = {
    ["NONE"] =                0x00,
    ["BIT_ARRAY"] =           0x01,
    ["TWO_BYTE_INTEGER"] =    0x02,
    ["FOUR_BYTE_INTEGER"] =   0x03,
    ["FOUR_BYTE_REAL"] =      0x04,
    ["EIGHT_BYTE_REAL"] =     0x05,
    ["ASCII_STRING"] =        0x06,
}

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

local function _split_in_bytes(number, numbytes)
    local data = {}
    for i = 1, numbytes do
        data[i] = number & 0xff
        number = number // 256
    end
    return data
end

local datatable = {
    [datatypes.NONE] = nil,
    [datatypes.BIT_ARRAY] = function(nums)
        local data = {}
        for _, num in ipairs(nums) do
            for _, b in ipairs(_split_in_bytes(num, 2)) do
                table.insert(data, b)
            end
        end
        return data
    end,
    [datatypes.TWO_BYTE_INTEGER] = function(nums)
        local data = {}
        for _, num in ipairs(nums) do
            for _, b in ipairs(_split_in_bytes(num, 2)) do
                table.insert(data, b)
            end
        end
        return data
    end,
    [datatypes.FOUR_BYTE_INTEGER] = function(nums)
        local data = {}
        for _, num in ipairs(nums) do
            for _, b in ipairs(_split_in_bytes(num, 4)) do
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
    local lenbytes = _split_in_bytes(#data, 2)
    data[1], data[2] = lenbytes[1], lenbytes[2]
    return data
end

local __content = {}

local function _intconcat(t, sep)
    local res = {}
    for _, e in ipairs(t) do
        table.insert(res, string.format("%d", e))
    end
    return table.concat(res, sep)
end

local function _write_record(recordtype, datatype, content)
    if datatype == datatypes.NONE then
        table.insert(__content, string.format("%12s (%d)\n", recordtype.name, 4))
    else
        local data = _assemble_data(recordtype.code, datatype, content)
        local str
        if datatype == datatypes.NONE then
        elseif datatype == datatypes.BIT_ARRAY or
               datatype == datatypes.FOUR_BYTE_REAL or
               datatype == datatypes.EIGHT_BYTE_REAL then
            str = table.concat(content, " ")
        elseif datatype == datatypes.TWO_BYTE_INTEGER or
               datatype == datatypes.FOUR_BYTE_INTEGER then
            str = _intconcat(content, " ")
        elseif datatype == datatypes.ASCII_STRING then
            str = content
        end
        table.insert(__content, string.format("%12s (%d) -> data: %s\n", recordtype.name, #data, str))
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

function M.get_techexport()
    return "gds"
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
    local ptstream = _unpack_points(pts)
    _write_record(recordtypes.BOUNDARY, datatypes.NONE)
    _write_record(recordtypes.LAYER, datatypes.TWO_BYTE_INTEGER, { layer.layer })
    _write_record(recordtypes.DATATYPE, datatypes.TWO_BYTE_INTEGER, { layer.purpose})
    _write_record(recordtypes.XY, datatypes.FOUR_BYTE_INTEGER, ptstream)
    _write_record(recordtypes.ENDEL, datatypes.NONE)
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

function M.write_cell_reference(identifier, instname, origin, orientation)
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
    _write_record(recordtypes.XY, datatypes.FOUR_BYTE_INTEGER, { multiplier * origin:getx(), multiplier * origin:gety() })
    _write_record(recordtypes.ENDEL, datatypes.NONE)
end

function M.write_cell_array(identifier, instbasename, origin, orientation, xrep, yrep, xpitch, ypitch)
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
        multiplier * origin:getx(),                   multiplier * origin:gety(),
        multiplier * (origin:getx() + xrep + xpitch), multiplier * origin:gety(),
        multiplier * origin:getx(),                   multiplier * (origin:gety() + yrep + ypitch),
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
