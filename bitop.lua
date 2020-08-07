local M = {}

local function _tobits(num, numbits)
    local bits = {}
    for i = 1, numbits do
        local div = 2^(numbits - i)
        bits[i] = math.floor(num / div)
        if bits[i] == 1 then
        local res = math.floor(num / div)
            num = num - div
        end
    end
    return bits
end

local function _tonum(bits)
    local num = 0
    for i = 1, #bits do
        num = num + bits[#bits - i + 1] * 2^(i - 1)
    end
    return num
end

local function _bitop(lhs, rhs, numbits, op)
    local bl = _tobits(lhs, numbits)
    local br = _tobits(rhs, numbits)

    local res = {}
    for i = 1, numbits do
        if op(bl[i], br[i]) then
            res[i] = 1
        else
            res[i] = 0
        end
    end
    return _tonum(res)
end

function M.band(lhs, rhs, numbits)
    return _bitop(lhs, rhs, numbits, function(bl, br) return bl == 1 and br == 1 end)
end

function M.bor(lhs, rhs, numbits)
    return _bitop(lhs, rhs, numbits, function(bl, br) return bl == 1 or br == 1 end)
end
 
function M.bxor(lhs, rhs, numbits)
    return _bitop(lhs, rhs, numbits, function(bl, br) return bl ~= br end)
end

return M
