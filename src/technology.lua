technology = {}

local layermap
local constraintsmeta = {}
constraintsmeta.__index = function() return 1 end -- fake get_dimension
local constraints = setmetatable({}, constraintsmeta)
local config
local viadefs

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
        {} -- empty environment
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
        moderror(string.format("no config file for technology '%s' found", name))
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

local function _load_viadefs(name)
    local filename = _get_tech_filename(name, "vias")
    if not filename then
        moderror(string.format("no vias for technology '%s' found", name))
    end
    local chunkname = "@techvias"

    local reader, msg = _get_reader(filename)
    if not reader then
        moderror(string.format("could not open via definitions for technology '%s' (reason: %d)", name, msg))
    end
    return _generic_load(
        reader, chunkname,
        string.format("syntax error while loading via definitions for technology '%s'", name),
        string.format("semantic error while loading via definitions for technology '%s'", name)
    )
end

function technology.load(name)
    layermap    = _load_layermap(name)
    constraints = _load_constraints(name)
    config      = _load_config(name)
    viadefs     = _load_viadefs(name)
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
function technology.map(identifier)
    local entry = layermap[identifier]
    if not entry then
        moderror(string.format("no layer '%s' found in layermap", identifier))
    end
    return entry.layer
end

function technology.get_via_definitions(metal1, metal2)
    return viadefs[string.format("viaM%dM%d", metal1, metal2)].entries
end

--[[
function technology.get_fallback_via(metal1, metal2)
    return { width = viadefs.viaM1M2.fallback.width, height = viadefs.viaM1M2.fallback.height, fallback = true }
end
--]]

function technology.get_contact_definitions(region)
    return viadefs[string.format("contact%s", region)].entries
end

function technology.get_config_value(key)
    return config[key]
end
