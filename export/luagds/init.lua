local M = {}

local __libname = "opclib"
local __textmode = false

local __userunit = 0.001
local __databaseunit = 1e-9

local __labelsize = 1

local recordtypes = {
    HEADER          = { name = "HEADER",        code = 0x00 },
    BGNLIB          = { name = "BGNLIB",        code = 0x01 },
    LIBNAME         = { name = "LIBNAME",       code = 0x02 },
    UNITS           = { name = "UNITS",         code = 0x03 },
    ENDLIB          = { name = "ENDLIB",        code = 0x04 },
    BGNSTR          = { name = "BGNSTR",        code = 0x05 },
    STRNAME         = { name = "STRNAME",       code = 0x06 },
    ENDSTR          = { name = "ENDSTR",        code = 0x07 },
    BOUNDARY        = { name = "BOUNDARY",      code = 0x08 },
    PATH            = { name = "PATH",          code = 0x09 },
    SREF            = { name = "SREF",          code = 0x0a },
    AREF            = { name = "AREF",          code = 0x0b },
    TEXT            = { name = "TEXT",          code = 0x0c },
    LAYER           = { name = "LAYER",         code = 0x0d },
    DATATYPE        = { name = "DATATYPE",      code = 0x0e },
    WIDTH           = { name = "WIDTH",         code = 0x0f },
    XY              = { name = "XY",            code = 0x10 },
    ENDEL           = { name = "ENDEL",         code = 0x11 },
    SNAME           = { name = "SNAME",         code = 0x12 },
    COLROW          = { name = "COLROW",        code = 0x13 },
    TEXTNODE        = { name = "TEXTNODE",      code = 0x14 },
    NODE            = { name = "NODE",          code = 0x15 },
    TEXTTYPE        = { name = "TEXTTYPE",      code = 0x16 },
    PRESENTATION    = { name = "PRESENTATION",  code = 0x17 },
    SPACING         = { name = "SPACING",       code = 0x18 },
    STRING          = { name = "STRING",        code = 0x19 },
    STRANS          = { name = "STRANS",        code = 0x1a },
    MAG             = { name = "MAG",           code = 0x1b },
    ANGLE           = { name = "ANGLE",         code = 0x1c },
    UINTEGER        = { name = "UINTEGER",      code = 0x1d },
    USTRING         = { name = "USTRING",       code = 0x1e },
    REFLIBS         = { name = "REFLIBS",       code = 0x1f },
    FONTS           = { name = "FONTS",         code = 0x20 },
    PATHTYPE        = { name = "PATHTYPE",      code = 0x21 },
    GENERATIONS     = { name = "GENERATIONS",   code = 0x22 },
    ATTRTABLE       = { name = "ATTRTABLE",     code = 0x23 },
    STYPTABLE       = { name = "STYPTABLE",     code = 0x24 },
    STRTYPE         = { name = "STRTYPE",       code = 0x25 },
    ELFLAGS         = { name = "ELFLAGS",       code = 0x26 },
    ELKEY           = { name = "ELKEY",         code = 0x27 },
    LINKTYPE        = { name = "LINKTYPE",      code = 0x28 },
    LINKKEYS        = { name = "LINKKEYS",      code = 0x29 },
    NODETYPE        = { name = "NODETYPE",      code = 0x2a },
    PROPATTR        = { name = "PROPATTR",      code = 0x2b },
    PROPVALUE       = { name = "PROPVALUE",     code = 0x2c },
    BOX             = { name = "BOX",           code = 0x2d },
    BOXTYPE         = { name = "BOXTYPE",       code = 0x2e },
    PLEX            = { name = "PLEX",          code = 0x2f },
    BGNEXTN         = { name = "BGNEXTN",       code = 0x30 },
    ENDEXTN         = { name = "ENDEXTN",       code = 0x31 },
    TAPENUM         = { name = "TAPENUM",       code = 0x32 },
    TAPECODE        = { name = "TAPECODE",      code = 0x33 },
    STRCLASS        = { name = "STRCLASS",      code = 0x34 },
    RESERVED        = { name = "RESERVED",      code = 0x35 },
    FORMAT          = { name = "FORMAT",        code = 0x36 },
    MASK            = { name = "MASK",          code = 0x37 },
    ENDMASKS        = { name = "ENDMASKS",      code = 0x38 },
    LIBDIRSIZE      = { name = "LIBDIRSIZE",    code = 0x39 },
    SRFNAME         = { name = "SRFNAME",       code = 0x3a },
    LIBSECUR        = { name = "LIBSECUR",      code = 0x3b },
}
local recordtypesnames = {}
for k, v in pairs(recordtypes) do
    recordtypesnames[v.code] = v.name
end
recordtypescodes = {}
for k, v in pairs(recordtypes) do
    recordtypescodes[v.name] = v.code
end

local datatypes = {
    NONE                = 0x00,
    BIT_ARRAY           = 0x01,
    TWO_BYTE_INTEGER    = 0x02,
    FOUR_BYTE_INTEGER   = 0x03,
    FOUR_BYTE_REAL      = 0x04,
    EIGHT_BYTE_REAL     = 0x05,
    ASCII_STRING        = 0x06,
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

local __content = bytebuffer.create()

local function _write_text_record(recordtype, datatype, content)
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

local function _write_binary_record(recordtype, datatype, content)
    local data = _assemble_data(recordtype.code, datatype, content)
    for _, datum in ipairs(data) do
        __content:append_byte(datum)
    end
end

-- function "pointer" which (affected by __textmode option)
local _write_record = _write_binary_record

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
    if __textmode then
        return table.concat(__content)
    else
        return __content:str()
    end
end

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
        __content = {}
    end

    if opt.disablepath then
        M.write_path = nil
    end

    if opt.labelsize then
        __labelsize = opt.labelsize
    end
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
    -- BOUNDARY
    __content:append_byte(0x00)
    __content:append_byte(0x04)
    __content:append_byte(0x08)
    __content:append_byte(0x00)

    -- LAYER
    __content:append_byte(0x00)
    __content:append_byte(0x06)
    __content:append_byte(0x0d)
    __content:append_byte(0x02)
    __content:append_two_bytes(layer.layer)

    -- DATATYPE
    __content:append_byte(0x00)
    __content:append_byte(0x06)
    __content:append_byte(0x0e)
    __content:append_byte(0x02)
    __content:append_two_bytes(layer.purpose)

    -- XY
    local multiplier = 1e9 * __databaseunit -- opc works in nanometers
    bl.x = bl.x * multiplier
    bl.y = bl.y * multiplier
    tr.x = tr.x * multiplier
    tr.y = tr.y * multiplier
    __content:append_byte(0x00)
    __content:append_byte(0x2c)
    __content:append_byte(0x10) -- XY
    __content:append_byte(0x03) -- FOUR_BYTE_INTEGER
    __content:append_four_bytes(bl.x)
    __content:append_four_bytes(bl.y)
    __content:append_four_bytes(tr.x)
    __content:append_four_bytes(bl.y)
    __content:append_four_bytes(tr.x)
    __content:append_four_bytes(tr.y)
    __content:append_four_bytes(bl.x)
    __content:append_four_bytes(tr.y)
    __content:append_four_bytes(bl.x)
    __content:append_four_bytes(bl.y)

    -- ENDEL
    __content:append_byte(0x00)
    __content:append_byte(0x04)
    __content:append_byte(0x11)
    __content:append_byte(0x00)
end

function M.write_polygon(layer, pts)
    -- BOUNDARY
    __content:append_byte(0x00)
    __content:append_byte(0x04)
    __content:append_byte(0x08)
    __content:append_byte(0x00)

    -- LAYER
    __content:append_byte(0x00)
    __content:append_byte(0x06)
    __content:append_byte(0x0d)
    __content:append_byte(0x02)
    __content:append_two_bytes(layer.layer)

    -- DATATYPE
    __content:append_byte(0x00)
    __content:append_byte(0x06)
    __content:append_byte(0x0e)
    __content:append_byte(0x02)
    __content:append_two_bytes(layer.purpose)

    local ptstream = _unpack_points(pts)
    local len = #ptstream
    __content:append_two_bytes(4 + 4 * len)
    __content:append_byte(0x10) -- XY
    __content:append_byte(0x03) -- FOUR_BYTE_INTEGER
    for i = 1, len do
        __content:append_four_bytes(ptstream[i])
    end

    -- ENDEL
    __content:append_byte(0x00)
    __content:append_byte(0x04)
    __content:append_byte(0x11)
    __content:append_byte(0x00)
end

function M.write_path(layer, pts, width, extension)
    -- PATH
    __content:append_byte(0x00)
    __content:append_byte(0x04)
    __content:append_byte(0x09)
    __content:append_byte(0x00)

    -- LAYER
    __content:append_byte(0x00)
    __content:append_byte(0x06)
    __content:append_byte(0x0d)
    __content:append_byte(0x02)
    __content:append_two_bytes(layer.layer)

    -- DATATYPE
    __content:append_byte(0x00)
    __content:append_byte(0x06)
    __content:append_byte(0x0e)
    __content:append_byte(0x02)
    __content:append_two_bytes(layer.purpose)

    -- PATHTYPE
    __content:append_byte(0x00)
    __content:append_byte(0x06)
    __content:append_byte(0x21)
    __content:append_byte(0x02)
    __content:append_byte(0x00)
    if extension == "round" then
        __content:append_byte(0x01)
    elseif extension == "cap" then
        __content:append_byte(0x02)
    elseif type(extension) == "table" then
        __content:append_byte(0x04)
    else
        __content:append_byte(0x00)
    end

    -- WIDTH
    __content:append_byte(0x00)
    __content:append_byte(0x08)
    __content:append_byte(0x0f)
    __content:append_byte(0x03)
    __content:append_four_bytes(width)

    -- these records have to come after WIDTH (at least for klayout, but they also are in this order in the GDS manual)
    if type(extension) == "table" then
        -- BGNEXTN
        __content:append_byte(0x00)
        __content:append_byte(0x08)
        __content:append_byte(0x30)
        __content:append_byte(0x03)
        __content:append_four_bytes(extension[1])
        -- ENDEXTN
        __content:append_byte(0x00)
        __content:append_byte(0x08)
        __content:append_byte(0x31)
        __content:append_byte(0x03)
        __content:append_four_bytes(extension[2])
    end
    local ptstream = _unpack_points(pts)
    local len = #ptstream
    __content:append_two_bytes(4 + 4 * len)
    __content:append_byte(0x10) -- XY
    __content:append_byte(0x03) -- FOUR_BYTE_INTEGER
    for i = 1, len do
        __content:append_four_bytes(ptstream[i])
    end

    -- ENDEL
    __content:append_byte(0x00)
    __content:append_byte(0x04)
    __content:append_byte(0x11)
    __content:append_byte(0x00)
end

local function _get_matrix_orientation(matrix)
    if matrix[1] >= 0 and matrix[5] >= 0 then
        if matrix[2] < 0 then
            return R90;
        else
            return R0;
        end
    elseif matrix[1] <  0 and matrix[5] >= 0 then
        return MY;
    elseif matrix[1] >= 0 and matrix[5] <  0 then
        return MX;
    elseif matrix[1] <  0 and matrix[5] <  0 then
        return R180;
    end
    -- FIXME: R270?
end

function M.write_cell_reference(identifier, x, y, trans)
    -- SREF
    __content:append_byte(0x00)
    __content:append_byte(0x04)
    __content:append_byte(0x0a)
    __content:append_byte(0x00)

    -- SNAME
    local len = 4 + string.len(identifier)
    if len % 2 == 0 then
        __content:append_two_bytes(len)
    else
        __content:append_two_bytes(len + 1)
    end
    __content:append_byte(0x12)
    __content:append_byte(0x06)
    __content:append_string(identifier)
    if len % 2 == 1 then
        __content:append_byte(0x00)
    end

    -- STRANS/ANGLE
    local orientation = _get_matrix_orientation(trans)
    if orientation == "MX" then
        -- STRANS
        __content:append_byte(0x00)
        __content:append_byte(0x06)
        __content:append_byte(0x1a)
        __content:append_byte(0x01)
        __content:append_byte(0x80)
        __content:append_byte(0x00)
    elseif orientation == "MY" then
        -- STRANS
        __content:append_byte(0x00)
        __content:append_byte(0x06)
        __content:append_byte(0x1a)
        __content:append_byte(0x01)
        __content:append_byte(0x80)
        __content:append_byte(0x00)
        -- ANGLE (180 degrees)
        __content:append_byte(0x00)
        __content:append_byte(0x0c)
        __content:append_byte(0x1c)
        __content:append_byte(0x05)
        __content:append_byte(0x42)
        __content:append_byte(0xb4)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
    elseif orientation == "R180" then
        -- STRANS
        __content:append_byte(0x00)
        __content:append_byte(0x06)
        __content:append_byte(0x1a)
        __content:append_byte(0x01)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        -- ANGLE (180 degrees)
        __content:append_byte(0x00)
        __content:append_byte(0x0c)
        __content:append_byte(0x1c)
        __content:append_byte(0x05)
        __content:append_byte(0x42)
        __content:append_byte(0xb4)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
    elseif orientation == "R90" then
        -- STRANS
        __content:append_byte(0x00)
        __content:append_byte(0x06)
        __content:append_byte(0x1a)
        __content:append_byte(0x01)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        -- ANGLE (90 degrees)
        __content:append_byte(0x00)
        __content:append_byte(0x0c)
        __content:append_byte(0x1c)
        __content:append_byte(0x05)
        __content:append_byte(0x42)
        __content:append_byte(0x5a)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
    end
    local multiplier = 1e9 * __databaseunit -- opc works in nanometers
    __content:append_byte(0x00)
    __content:append_byte(0x0c)
    __content:append_byte(0x10) -- XY
    __content:append_byte(0x03) -- FOUR_BYTE_INTEGER
    __content:append_four_bytes(x * multiplier)
    __content:append_four_bytes(y * multiplier)

    -- ENDEL
    __content:append_byte(0x00)
    __content:append_byte(0x04)
    __content:append_byte(0x11)
    __content:append_byte(0x00)
end

function M.write_cell_array(identifier, x, y, trans, xrep, yrep, xpitch, ypitch)
    -- SREF
    __content:append_byte(0x00)
    __content:append_byte(0x04)
    __content:append_byte(0x0b)
    __content:append_byte(0x00)

    -- SNAME
    __content:append_byte(0x00)
    local len = 4 + string.len(identifier)
    if len % 2 == 0 then
        __content:append_byte(len)
    else
        __content:append_byte(len + 1)
    end
    __content:append_byte(0x12)
    __content:append_byte(0x06)
    __content:append_string(identifier)
    if len % 2 == 1 then
        __content:append_byte(0x00)
    end

    -- STRANS/ANGLE
    local orientation = _get_matrix_orientation(trans)
    if orientation == "MX" then
        -- STRANS
        __content:append_byte(0x00)
        __content:append_byte(0x06)
        __content:append_byte(0x1a)
        __content:append_byte(0x01)
        __content:append_byte(0x80)
        __content:append_byte(0x00)
    elseif orientation == "MY" then
        -- STRANS
        __content:append_byte(0x00)
        __content:append_byte(0x06)
        __content:append_byte(0x1a)
        __content:append_byte(0x01)
        __content:append_byte(0x80)
        __content:append_byte(0x00)
        -- ANGLE (180 degrees)
        __content:append_byte(0x00)
        __content:append_byte(0x0c)
        __content:append_byte(0x1c)
        __content:append_byte(0x05)
        __content:append_byte(0x42)
        __content:append_byte(0xb4)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
    elseif orientation == "R180" then
        -- STRANS
        __content:append_byte(0x00)
        __content:append_byte(0x06)
        __content:append_byte(0x1a)
        __content:append_byte(0x01)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        -- ANGLE (180 degrees)
        __content:append_byte(0x00)
        __content:append_byte(0x0c)
        __content:append_byte(0x1c)
        __content:append_byte(0x05)
        __content:append_byte(0x42)
        __content:append_byte(0xb4)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
    elseif orientation == "R90" then
        -- STRANS
        __content:append_byte(0x00)
        __content:append_byte(0x06)
        __content:append_byte(0x1a)
        __content:append_byte(0x01)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        -- ANGLE (90 degrees)
        __content:append_byte(0x00)
        __content:append_byte(0x0c)
        __content:append_byte(0x1c)
        __content:append_byte(0x05)
        __content:append_byte(0x42)
        __content:append_byte(0x5a)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
        __content:append_byte(0x00)
    end

    -- COLROW
    _write_record(recordtypes.COLROW, datatypes.TWO_BYTE_INTEGER, { xrep, yrep })

    -- XY
    _write_record(recordtypes.XY, datatypes.FOUR_BYTE_INTEGER, 
        _unpack_points({ { x = x, y = y }, { x = x + xrep * xpitch, y = y }, { x = x, y = y + yrep * ypitch } }))

    -- ENDEL
    __content:append_byte(0x00)
    __content:append_byte(0x04)
    __content:append_byte(0x11)
    __content:append_byte(0x00)
end

function M.write_port(name, layer, where)
    -- TEXT
    __content:append_byte(0x00)
    __content:append_byte(0x04)
    __content:append_byte(0x0c)
    __content:append_byte(0x00)

    -- LAYER
    __content:append_byte(0x00)
    __content:append_byte(0x06)
    __content:append_byte(0x0d)
    __content:append_byte(0x02)
    __content:append_two_bytes(layer.layer)

    -- TEXTTYPE
    __content:append_byte(0x00)
    __content:append_byte(0x06)
    __content:append_byte(0x16)
    __content:append_byte(0x02)
    __content:append_two_bytes(layer.purpose)

    -- PRESENTATION
    __content:append_byte(0x00)
    __content:append_byte(0x06)
    __content:append_byte(0x17)
    __content:append_byte(0x01)
    __content:append_byte(0x00)
    __content:append_byte(0x05)

    __content:append_byte(0x00)
    __content:append_byte(0x0c)
    __content:append_byte(0x1b)
    __content:append_byte(0x05)
    for _, b in ipairs(_number_to_gdsfloat(__labelsize * __databaseunit, 8)) do
        __content:append_byte(0x00)
    end

    -- XY
    local multiplier = 1e9 * __databaseunit -- opc works in nanometers
    local x, y = where:unwrap()
    __content:append_byte(0x00)
    __content:append_byte(0x0c)
    __content:append_byte(0x10) -- XY
    __content:append_byte(0x03) -- FOUR_BYTE_INTEGER
    __content:append_four_bytes(x * multiplier)
    __content:append_four_bytes(y * multiplier)

    local len = 4 + string.len(name)
    if len % 2 == 0 then
        __content:append_two_bytes(len)
    else
        __content:append_two_bytes(len + 1)
    end
    __content:append_byte(0x19)
    __content:append_byte(0x06)
    __content:append_string(name)
    if len % 2 == 1 then
        __content:append_byte(0x00)
    end

    -- ENDEL
    __content:append_byte(0x00)
    __content:append_byte(0x04)
    __content:append_byte(0x11)
    __content:append_byte(0x00)
end

return M
