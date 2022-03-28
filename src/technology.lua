local constraints

local techpaths = {}

function technology.get_dimension(dimension)
    local value = constraints[dimension]
    if not value then
        moderror(string.format("technology: no dimension '%s' found", dimension))
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

local function _load_constraints(name)
    local filename = _get_tech_filename(name, "constraints")
    if not filename then
        moderror(string.format("technology: no constraints for technology '%s' found", name))
    end
    local chunkname = "@techconstraints"

    local reader, msg = _get_reader(filename)
    if not reader then
        moderror(string.format("technology: could not open constraints file for technology '%s' (reason: %d)", name, msg))
    end
    return _generic_load(
        reader, chunkname,
        string.format("syntax error while loading constraints for technology '%s'", name),
        string.format("semantic error while loading constraints for technology '%s'", name)
    )
end

function technology.load(name)
    local layermapname = _get_tech_filename(name, "layermap")
    if not layermapname then
        moderror(string.format("technology: no techfile for technology '%s' found", name))
    end
    technology.load_layermap(layermapname)

    local vianame = _get_tech_filename(name, "vias")
    if not vianame then
        moderror(string.format("technology: no config file for technology '%s' found", name))
    end
    technology.load_viadefinitions(vianame)

    local configname = _get_tech_filename(name, "config")
    if not configname then
        moderror(string.format("technology: no config file for technology '%s' found", name))
    end
    technology.load_config(configname)

    constraints = _load_constraints(name)
end

function technology.add_techpath(path)
    table.insert(techpaths, path)
end

function technology.list_techpaths()
    for _, path in ipairs(techpaths) do
        print(path)
    end
end

