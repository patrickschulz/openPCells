--[[
This file is part of the openPCells project.

This module provides a collection of helper functions (not geometry-related)
--]]

local M = {}

function M.call_if_present(func, ...)
    if func then
        return func(...)
    end
end

function M.map(t, func)
    local res = {}
    for k, v in pairs(t) do
        res[k] = func(v)
    end
    return res
end

function M.concat(data, sep, pre, post, newline)
    pre = pre or ""
    post = post or ""
    sep = sep or ", "
    if newline then
        sep = sep .. "\n"
    end
    local fun = function(str)
        return string.format("%s%s%s", pre, str, post)
    end
    local processed = M.map(data, fun)
    local tabstr = table.concat(processed, sep)
    return tabstr
end

function M.find(t, crit)
    for i, v in ipairs(t) do
        if crit(v) then
            return i, v
        end
    end
end

function M.shuffle(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
  return t
end

function M.gcd(a, b)
	if b ~= 0 then
		return M.gcd(b, a % b)
	else
		return a
	end
end

function M.tabgcd(t)
    local gcd = t[1]
    for i = 1, #t do
        for j = 1, #t do
            if i ~= j then
                gcd = math.min(gcd, M.gcd(t[i], t[j]))
            end
        end
    end
    return gcd
end

function M.sum(t)
    local res = 0
    for _, e in ipairs(t) do
        res = res + e
    end
    return res
end

function M.round(num)
    return num >= 0 and math.floor(num + 0.5) or math.ceil(num - 0.5)
end

function M.any_of(comp, t, ...)
    for _, v in ipairs(t) do
        if comp(v, ...) then
            return true
        end
    end
    return false
end

function M.all_of(comp, t, ...)
    for _, v in ipairs(t) do
        if not comp(v, ...) then
            return false
        end
    end
    return true
end

function M.assert_one_of(msg, key, ...)
    assert(M.any_of(function(v) return v == key end, { ... }),
        string.format("%s must be one of { %s }", msg, table.concat({ ... }, ", "))
    )
end

return M
