--------------------
--  Check Config  --
--------------------
if not config then
    error("technology does not define configuration file ('config.lua')")
end
if not config.metals then
    error("config file does not define the number of metals")
end

--------------------
-- Check Layermap --
--------------------
if not layermap then
    error("technology does not define layer map ('layermap.lua')")
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
            error(string.format("layermap: entry '%s' has no layer definition", identifier))
        end
        for export in pairs(entry.layer) do
            exporttypes[export] = true
        end
    end
end

-- check export types
for exporttype in pairs(exporttypes) do
    for identifier, entry in pairs(layermap) do
        if num_table_items(entry) ~= 0 then
            if not entry.layer[exporttype] then
                error(string.format("layermap: entry '%s' does not define the export type '%s', but other entries do define it", identifier, exporttype))
            end
        end
    end
end

--------------------
-- Check Viatable --
--------------------
if not viatable then
    error("technology does not define viatable ('vias.lua')")
end
