local function _error(str)
    terminal.set_foreground_color(0xFF, 0, 0)
    print(str)
    terminal.reset_color()
end

local function _warning(str)
    terminal.set_foreground_color(0xFF, 0x80, 0)
    print(str)
    terminal.reset_color()
end

--------------------
--  Check Config  --
--------------------
if not config then
    _error(string.format("technology does not define configuration file ('config.lua'). File path: '%s'", config_path))
end
if not config.metals then
    _error(string.format("config file ('%s') does not define the number of metals", config_path))
end

--------------------
-- Check Layermap --
--------------------
if not layermap then
    _error(string.format("technology does not define layer map ('layermap.lua'). File path: '%s'", layermap_path))
end
local function num_table_items(t)
    local num = 0
    for k in pairs(t) do
        num = num + 1
    end
    return num
end

local exporttypes = {}

-- gather export types
for identifier, entry in pairs(layermap) do
    if num_table_items(entry) ~= 0 then
        if not entry.layer then
            _error(string.format("layermap ('%s'): entry '%s' has no layer definition", layermap_path, identifier))
        end
        for export in pairs(entry.layer) do
            exporttypes[export] = true
        end
    end
end

-- check export types
if not ignore_export_errors then
    for exporttype in pairs(exporttypes) do
        for identifier, entry in pairs(layermap) do
            if num_table_items(entry) ~= 0 then
                if not entry.layer[exporttype] then
                    _warning(string.format("layermap ('%s'): entry '%s' does not define the export type '%s', but other entries define it", layermap_path, identifier, exporttype))
                end
            end
        end
    end
end

--------------------
-- Check Viatable --
--------------------
if not viatable then
    _error(string.format("technology does not define viatable ('vias.lua'). File path: '%s'", viatable_path))
end

--------------------
--  Check Constraints  --
--------------------
local function _check_dimension(constraints, str)
    if not constraints[str] then
        _error(string.format("constraints file ('%s') does not specify '%s'", constraints_path, str))
    end
end

local function _check_dimensions(constraints, basestr, entries)
    for _, what in ipairs(entries) do
        local str = string.format(basestr, what)
        _check_dimension(constraints, str)
    end
end

if not constraints then
    _error(string.format("technology does not define constraints file ('constraints.lua'). File path: '%s'", constraints_path))
end
-- check well constraints
_check_dimensions(constraints, "Minimum Well %s", { "Extension" })
-- check implant constraints
_check_dimensions(constraints, "Minimum Implant %s", { "Extension" })
-- check soiopen constraints
if config.is_SOI then
    _check_dimensions(constraints, "Minimum Soiopen %s", { "Extension" })
end
-- check gate constraints
_check_dimensions(constraints, "Minimum Gate %s", { "Width", "XSpace", "YSpace" })
-- check active constraints
_check_dimensions(constraints, "Minimum Active %s", { "Width", "Space" })
-- check metal constraints
for i = 1, config.metals do
    _check_dimensions(constraints, string.format("Minimum M%d %%s", i), { "Width", "Space" })
end
