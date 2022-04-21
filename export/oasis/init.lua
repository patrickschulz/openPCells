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

local __content = {}

local function _write_record(recordtype)
    table.insert(__content, string.char(recordtype))
end

local function _write_infobyte(data)
    local byte = 0
    for i = 1, 8 do
        if data[i] == 1 then
            byte = byte + (1 << (8 - i))
        end
    end
    table.insert(__content, string.char(byte))
end

local function _write_int(num)
    if num == 0 then
        table.insert(__content, string.char(0))
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
            table.insert(__content, string.char(byte))
            i = i + 1
        end
    end
end

local function _write_uint(num)
    if num == 0 then
        table.insert(__content, string.char(0))
    else
        while num > 0 do
            local byte = num % 128
            num = (num - byte) >> 7
            if num > 0 then
                byte = byte + 128
            end
            table.insert(__content, string.char(byte))
        end
    end
end

local function _write_real(numerator, denominator)
    denominator = denominator or 1
    if denominator == 1 then
        if numerator >= 0 then
            _write_record(0)
            _write_uint(numerator)
        else
            _write_record(1)
            _write_uint(numerator)
        end
    else
        if numerator == 1 then
            if denominator >= 0 then
                _write_record(2)
                _write_uint(denominator)
            else
                _write_record(3)
                _write_uint(denominator)
            end
        else
            if numerator >= 0 then
                _write_record(4)
                _write_uint(numerator)
                _write_uint(denominator)
            else
                _write_record(5)
                _write_uint(numerator)
                _write_uint(denominator)
            end
        end
    end
end

local function _write_string(str)
    local len = #str
    _write_uint(len)
    table.insert(__content, str)
end

-- public interface
function M.finalize()
    return table.concat(__content)
end

function M.get_extension()
    return "oas"
end

function M.at_begin()
    -- write magic bytes
    table.insert(__content, "%SEMI-OASIS")
    table.insert(__content, string.char(0x0D))
    table.insert(__content, string.char(0x0A))
    -- write START record
    _write_record(recordtypes.START) -- write start byte
    _write_string("1.0")       -- write version
    _write_real(1000)          -- write unit
    _write_uint(0)             -- write offset-flag
    _write_uint(0)
    _write_uint(0)             -- write cellname-flag
    _write_uint(0)
    _write_uint(0)             -- write textstring-flag
    _write_uint(0)
    _write_uint(0)             -- write propname-flag
    _write_uint(0)
    _write_uint(0)             -- write propstring-flag
    _write_uint(0)
    _write_uint(0)             -- write layername-flag
    _write_uint(0)
    _write_uint(0)             -- write xname-flag
    _write_uint(0)
end

function M.at_end()
    -- write END record
    _write_record(recordtypes.END) -- write start byte
    local numpadding = 256 - 1 - 1 -- total 256, minus record id (one byte) minus validation scheme (one byte, currently)
    local padding = string.rep(string.char(0), numpadding)
    _write_string(padding) -- write padding
    _write_uint(0)         -- write validation scheme
end

function M.at_begin_cell(cellname)
    _write_record(recordtypes.CELL_NAME)
    _write_string(cellname)
end

function M.write_rectangle(layer, bl, tr)
    _write_record(recordtypes.RECTANGLE)
    _write_infobyte({ 0, 1, 1, 1, 1, 0, 1, 1 }) -- SWHXYRDL
    _write_uint(layer.layer)
    _write_uint(layer.purpose)
    _write_uint(tr.x - bl.x)
    _write_uint(tr.y - bl.y)
    _write_int(bl.x)
    _write_int(bl.y)
end

---[[
function M.write_polygon()
end
--]]

--[[
function M.write_port(name, layer, where)
end
--]]

return M
