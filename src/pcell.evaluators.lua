local function identity(arg) return arg end

local function toboolean(arg)
    assert(
        string.match(arg, "true") or string.match(arg, "false"), 
        string.format("toboolean: argument must be 'true' or 'false' (is '%s')", arg)
    )
    return arg == "true" and true or false
end

local function tointeger(arg)
    return math.floor(tonumber(arg))
end

local function tonumtable(arg)
    local t = {}
    for e in string.gmatch(arg, "[^;,]+") do
        table.insert(t, tonumber(e))
    end
    return t
end

local function tostrtable(arg)
    local t = {}
    for e in string.gmatch(arg, "[^;,]+") do
        table.insert(t, tostring(e))
    end
    return t
end

local function evaluate(arg, argtype)
    local evaluators = {
        number   = tonumber,
        integer  = tointeger,
        string   = identity,
        boolean  = toboolean,
        numtable = tonumtable,
        strtable = tostrtable,
    }
    local eval = evaluators[argtype]
    return eval(arg)
end

return evaluate
