technology = {}

local layermap
local constraintsmeta = {}
constraintsmeta.__index = function() return 1 end -- fake get_dimension
local constraints = setmetatable({}, constraintsmeta)
local config

local techpaths = {}

function technology.get_dimension(dimension)
    local value = constraints[dimension]
    if not value then
        moderror(string.format("no dimension '%s' found", dimension))
    end
    return value
end

local function _get_tech_filename(name, what)
    for _, path in ipairs(techpaths) do
        local filename = string.format("%s/%s/%s.lua", path, name, what)
        if dir.exists(filename) then
            -- first found matching techfile is used
            return filename
        end
    end
end

local function _load_layermap(name)
    local env = {
        map = function(entry)
            if type(entry) == "function" then
                return {
                    action = "map",
                    func = entry,
                }
            else -- table
                return {
                    action = "map",
                    func = function()
                        return {
                            name = entry.name,
                            layer = entry.layer,
                            left = entry.left or 0,
                            right = entry.right or 0,
                            top = entry.top or 0,
                            bottom = entry.bottom or 0,
                        }
                    end,
                }
            end
        end,
        array = function(entry)
            if type(entry) == "function" then
                return {
                    action = "array",
                    func = entry
                }
            else
                return {
                    action = "array",
                    func = function()
                        local t = {
                            name = entry.name,
                            layer = entry.layer,
                            width = entry.width,
                            height = entry.height,
                            xspace = entry.xspace,
                            yspace = entry.yspace,
                            xencl = entry.xencl,
                            yencl = entry.yencl,
                            conductivity = entry.conductivity or 1,
                            noneedtofit = entry.noneedtofit,
                            fallback = entry.fallback
                        }
                        return t
                    end,
                }
            end
        end,
        refer = function(reference)
            return function()
                return layermap[reference]
            end
        end,
    }
    local filename = _get_tech_filename(name, "layermap")
    if not filename then
        moderror(string.format("no techfile for technology '%s' found", name))
    end
    local chunkname = "@techfile"

    local reader = _get_reader(filename)
    if not reader then
        moderror(string.format("no techfile for technology '%s' found", name))
    end
    return _generic_load(
        reader, chunkname,
        string.format("syntax error while loading layermap for technology '%s'", name),
        string.format("semantic error while loading layermap for technology '%s'", name),
        env
    )
end

local function _load_constraints(name)
    local filename = _get_tech_filename(name, "constraints")
    if not filename then
        moderror(string.format("no constraints for technology '%s' found", name))
    end
    local chunkname = "@techconstraints"

    local reader, msg = _get_reader(filename)
    if not reader then
        moderror(string.format("could not open constraints file for technology '%s' (reason: %d)", name, msg))
    end
    return _generic_load(
        reader, chunkname,
        string.format("syntax error while loading constraints for technology '%s'", name),
        string.format("semantic error while loading constraints for technology '%s'", name)
    )
end

local function _load_config(name)
    local filename = _get_tech_filename(name, "config")
    if not filename then
        moderror(string.format("no constraints for technology '%s' found", name))
    end
    local chunkname = "@techconfig"

    local reader, msg = _get_reader(filename)
    if not reader then
        moderror(string.format("could not open config file for technology '%s' (reason: %d)", name, msg))
    end
    return _generic_load(
        reader, chunkname,
        string.format("syntax error while loading config for technology '%s'", name),
        string.format("semantic error while loading config for technology '%s'", name)
    )
end

function technology.load(name)
    layermap    = _load_layermap(name)
    constraints = _load_constraints(name)
    config      = _load_config(name)
end

function technology.add_techpath(path)
    table.insert(techpaths, path)
end

function technology.list_techpaths()
    for _, path in ipairs(techpaths) do
        print(path)
    end
end

----------------------
function technology.__map(identifier, data)
    local mappings = layermap[identifier]
    local layers = {}
    for _, pre in ipairs(mappings) do
        -- FIXME: handle multiple entries, arrayzation, resizing, ...
        local entry = pre.func(data)
        table.insert(layers, entry.layer)
    end
    return layers
end

function technology.get_config_value(key)
    return config[key]
end
