--[[
This file is part of the openPCells project.

This module provides a collection of helper functions (not geometry-related)
--]]

aux = {}

function infoprint(msg)
    -- wrap print because I use it for simple debugging
    -- infoprint expresses permanent intention
    print(msg)
end

function errprint(msg)
    io.stderr:write(msg or "")
    io.stderr:write("\n")
end

function aux.clone_shallow(t, predicate)
    local new = {}
    predicate = predicate or function() return true end
    for k, v in pairs(t) do
        if predicate(k, v) then
            new[k] = v
        end
    end
    return new
end

function aux.find(t, value)
    for i, v in ipairs(t) do
        if v == value then
            return i, v
        end
    end
end

function aux.find_predicate(t, predicate)
    for i, v in ipairs(t) do
        if predicate(v) then
            return i, v
        end
    end
end

function aux.shuffle(t)
  for i = #t, 2, -1 do
    local j = math.random(i)
    t[i], t[j] = t[j], t[i]
  end
  return t
end

local gcd2
_gcd2 = function(a, b)
	if b ~= 0 then
		return _gcd2(b, a % b)
	else
		return a
	end
end

function aux.tabgcd(t)
    local gcd = t[1]
    for i = 1, #t do
        for j = 1, #t do
            if i ~= j then
                gcd = math.min(gcd, _gcd2(t[i], t[j]))
            end
        end
    end
    return gcd
end

function aux.gcd(...)
    return aux.tabgcd({...})
end

function aux.sum(t)
    local res = 0
    for _, e in ipairs(t) do
        res = res + e
    end
    return res
end

function aux.make_even(num)
    if num % 2 == 0 then
        return num
    else
        return num + 1
    end
end

function aux.assert_one_of(msg, key, ...)
    assert(aux.any_of(function(v) return v == key end, { ... }),
        string.format("%s must be one of { %s }", msg, table.concat({ ... }, ", "))
    )
end

-- code credit: https://stackoverflow.com/a/43582076/3197530
-- gsplit: iterate over substrings in a string separated by a pattern
-- 
-- Parameters:
-- text (string)    - the string to iterate over
-- pattern (string) - the separator pattern
-- plain (boolean)  - if true (or truthy), pattern is interpreted as a plain
--                    string, not a Lua pattern
-- 
-- Returns: iterator
--
-- Usage:
-- for substr in gsplit(text, pattern, plain) do
--   doSomething(substr)
-- end
function aux.strgsplit(text, pattern, plain)
    local splitStart, length = 1, #text
    return function ()
        if splitStart then
            local sepStart, sepEnd = string.find(text, pattern, splitStart, plain)
            local ret
            if not sepStart then
                ret = string.sub(text, splitStart)
                splitStart = nil
            elseif sepEnd < sepStart then
                -- Empty separator!
                ret = string.sub(text, splitStart, sepStart)
                if sepStart < length then
                    splitStart = sepStart + 1
                else
                    splitStart = nil
                end
            else
                ret = sepStart > splitStart and string.sub(text, splitStart, sepStart - 1) or ''
                splitStart = sepEnd + 1
            end
            return ret
        end
    end
end

-- split: split a string into substrings separated by a pattern.
-- 
-- Parameters:
-- text (string)    - the string to iterate over
-- pattern (string) - the separator pattern
-- plain (boolean)  - if true (or truthy), pattern is interpreted as a plain
--                    string, not a Lua pattern
-- 
-- Returns: table (a sequence table containing the substrings)
function aux.strsplit(text, pattern, plain)
    local ret = {}
    for match in aux.strgsplit(text, pattern, plain) do
        table.insert(ret, match)
    end
    return ret
end

function aux.tprint(tbl, indent)                                                   
    -- Print contents of tbl, with indentation.                                   
    -- indent sets the initial level of indentation.                                 
    indent = indent or 0
    for k, v in pairs(tbl) do                                                     
        local formatting = string.rep("  ", indent) .. k .. ": "                             
        if type(v) == "table" then                                                  
            print(formatting)                                                         
            aux.tprint(v, indent+1)                                                       
        elseif type(v) == 'boolean' then                                            
            print(formatting .. tostring(v))                                          
        else                                                                        
            print(formatting .. v)                                                    
        end                                                                         
    end                                                                           
end

function aux.pop_top_directory(path)
    local base, name = aux.split_path(path)
    return base
end

function aux.split_path(path)
    local base, name = string.match(path, "^(.+)%/([^/]+)$")
    if not base then -- no path separator
        return ".", path
    else
        return base, name
    end
end

