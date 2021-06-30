local M = {}

local recordtypes = {
    PAD             = 0,
    START           = 1,
    END             = 2,
    CELLNAME        = 3,
    CELLNAMEREF     = 4,
    TEXTSTRING      = 5,
    TEXTSTRINGREF   = 6,
    PROPNAME        = 7,
    PROPNAMEREF     = 8,
    PROPSTRING      = 9,
    PROPSTRINGREF   = 10,
    LAYERNAMELAYER  = 11,
    LAYERNAMETEXT   = 12,
    CELL_INDEX      = 13,
    CELL_NAME       = 14,
    XYABSOLUTE      = 15,
    XYRELATIVE      = 16,
    PLACEMENT_1     = 17,
    PLACEMENT_2     = 18,
    TEXT            = 19,
    RECTANGLE       = 20,
    POLYGON         = 21,
    PATH            = 22,
    TRAPEZOID_1     = 23,
    TRAPEZOID_2     = 24,
    CTRAPEZOID      = 26,
    CIRCLE          = 27,
    PROPERTY_1      = 28,
    PROPERTY_2      = 29,
    XNAME_1         = 30,
    XNAME_2         = 31,
    XELEMENT        = 32,
    XGEOMETRY       = 33,
    CBLOCK          = 34,
}

local function _write_record(file, recordtype)
    file:writebyte(recordtype)
end

local function _write_infobyte(file, data)
    local byte = 0
    for i = 1, 8 do
        if data[i] == 1 then
            byte = byte + (1 << (8 - i))
        end
    end
    file:writebyte(byte)
end

local function _write_int(file, num)
    if num == 0 then
        file:writebyte(0)
    else
        local sign = 0
        if num < 0 then
            sign = 1
            num = -num
        end
        local i = 1
        while num > 0 do
            local byte
            if i == 1 then
                byte = num % 64
                num = (num - byte) >> 6
                byte = 2 * byte
                byte = byte + sign
            else
                byte = num % 128
                num = (num - byte) >> 7
            end
            if num > 0 then
                byte = byte + 128
            end
            file:writebyte(byte)
            i = i + 1
        end
    end
end

local function _write_uint(file, num)
    if num == 0 then
        file:writebyte(0)
    else
        while num > 0 do
            local byte = num % 128
            num = (num - byte) >> 7
            if num > 0 then
                byte = byte + 128
            end
            file:writebyte(byte)
        end
    end
end

local function _write_real(file, numerator, denominator)
    denominator = denominator or 1
    if denominator == 1 then
        if numerator >= 0 then
            _write_record(file, 0)
            _write_uint(file, numerator)
        else
            _write_record(file, 1)
            _write_uint(file, numerator)
        end
    else
        if numerator == 1 then
            if denominator >= 0 then
                _write_record(file, 2)
                _write_uint(file, denominator)
            else
                _write_record(file, 3)
                _write_uint(file, denominator)
            end
        else
            if numerator >= 0 then
                _write_record(file, 4)
                _write_uint(file, numerator)
                _write_uint(file, denominator)
            else
                _write_record(file, 5)
                _write_uint(file, numerator)
                _write_uint(file, denominator)
            end
        end
    end
end

local function _write_string(file, str)
    local len = #str
    _write_uint(file, len)
    file:write(str)
end

-- public interface
function M.get_extension()
    return "oas"
end

function M.get_techexport()
    return "gds"
end

function M.get_layer(shape)
    return { layer = shape.lpp:get().layer, purpose = shape.lpp:get().purpose }
end

function M.at_begin(file)
    -- write magic bytes
    file:write("%SEMI-OASIS")
    file:writebyte(0x0D)
    file:writebyte(0x0A)
    -- write START record
    _write_record(file, recordtypes.START) -- write start byte
    _write_string(file, "1.0")       -- write version
    _write_real(file, 1000)          -- write unit
    _write_uint(file, 0)             -- write offset-flag
    _write_uint(file, 0)
    _write_uint(file, 0)             -- write cellname-flag
    _write_uint(file, 0)
    _write_uint(file, 0)             -- write textstring-flag
    _write_uint(file, 0)
    _write_uint(file, 0)             -- write propname-flag
    _write_uint(file, 0)
    _write_uint(file, 0)             -- write propstring-flag
    _write_uint(file, 0)
    _write_uint(file, 0)             -- write layername-flag
    _write_uint(file, 0)
    _write_uint(file, 0)             -- write xname-flag
    _write_uint(file, 0)
end

function M.at_end(file)
    -- write END record
    _write_record(file, recordtypes.END) -- write start byte
    local numpadding = 256 - 1 - 1 -- total 256, minus record id (one byte) minus validation scheme (one byte, currently)
    local padding = string.rep(string.char(0), numpadding)
    _write_string(file, padding) -- write padding
    _write_uint(file, 0)         -- write validation scheme
end

function M.at_begin_cell(file, cellname)
    _write_record(file, 14)
    _write_string(file, cellname)
end

function M.at_end_cell(file)
end

function M.write_rectangle(file, layer, bl, tr)
    _write_record(file, recordtypes.RECTANGLE)
    _write_infobyte(file, { 0, 1, 1, 1, 1, 0, 1, 1 }) -- SWHXYRDL
    _write_uint(file, layer.layer)
    _write_uint(file, layer.purpose)
    local blx, bly = bl:unwrap()
    local trx, try = tr:unwrap()
    _write_uint(file, trx - blx)
    _write_uint(file, try - bly)
    _write_int(file, blx)
    _write_int(file, bly)
end

function M.write_polygon(file)
end

function M.write_port(file, name, layer, where)
end

return M
