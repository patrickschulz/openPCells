envlib = {}

local variables = {}

function envlib.set(name, value)
    variables[name] = value
end

function envlib.get(name)
    return variables[name]
end
