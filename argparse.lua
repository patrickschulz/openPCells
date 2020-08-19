local M = {}

local function _advance(state, num)
    local num = num or 1
    state.i = state.i + num
end

local function _next_arg(args, state)
    _advance(state)
    return args[state.i]
end

local function _consume_until_hyphen(args, state)
    local t = {}
    while true do
        local arg = args[state.i + 1]
        if not arg or string.match(arg, "^-") then break end
        table.insert(t, arg)
        _advance(state)
    end
    return table.concat(t, " ")
end

local actions = {
    ["-P"] = function(res)
        res.params = true 
    end,
    ["-T"] = function(res, state, args) 
        res.technology = _next_arg(args, state)
    end,
    ["-I"] = function(res, state, args) 
        res.interface = _next_arg(args, state)
    end,
    ["-C"] = function(res, state, args) 
        res.cell = _next_arg(args, state)
    end,
    ["-f"] = function(res, state, args) 
        res.filename = _next_arg(args, state)
    end,
    ["--iopt"] = function(res, state, args)
        res.interface_options = _consume_until_hyphen(args, state)
    end,
}

function M.parse(args)
    local state = { i = 1 }
    local res = {cellargs = {}}
    while state.i <= #args do
        local arg = args[state.i]
        local action = actions[arg]
        if not action then
            table.insert(res.cellargs, arg)
        else
            action(res, state, args)
        end
        _advance(state)
    end
    return res
end

return M
