local M = {}

local namelut = {
    M1 = "generics.metal(1)",
    M2 = "generics.metal(2)",
    M3 = "generics.metal(3)",
    M4 = "generics.metal(4)",
    M5 = "generics.metal(5)",
    M6 = "generics.metal(6)",
    M7 = "generics.metal(7)",
    M8 = "generics.metal(8)",
    M9 = "generics.metal(9)",
    M10 = "generics.metal(10)",
    M11 = "generics.metal(11)",
    M12 = "generics.metal(12)",
    M13 = "generics.metal(13)",
    M14 = "generics.metal(14)",
    M15 = "generics.metal(15)",
    M16 = "generics.metal(16)",
    M17 = "generics.metal(17)",
    M18 = "generics.metal(18)",
    M19 = "generics.metal(19)",
    M20 = "generics.metal(20)",
    active = "generics.active()",
    gate = "generics.gate()",
    contactactive = "generics.contact(\"active\")",
    contactsourcedrain = "generics.contact(\"sourcedrain\")",
    contactgate = "generics.contact(\"gate\")",
    contactpoly = "generics.contact(\"poly\")",
    pimplant = "generics.implant(\"p\")",
    nimplant = "generics.implant(\"n\")",
}

function M.reverse_layermap(layermap, targetexport)
    local reverse = {}
    for name, entry in pairs(layermap) do
        if entry.layer and entry.layer[targetexport] then
            local rev
            if namelut[name] then
                rev = {
                    -- FIXME: this currently only makes sense for GDS
                    layer = entry.layer[targetexport].layer,
                    purpose = entry.layer[targetexport].purpose,
                    map = namelut[name]
                }
            else
                local mappings = {}
                for export, exportentry in pairs(entry.layer) do
                    if export ~= targetexport then
                        local content = {}
                        for k, v in pairs(exportentry) do
                            local vv
                            if type(v) == "string" then
                                vv = string.format("\"%s\"", v)
                            elseif type(v) == "number" then
                                if math.tointeger(v) then
                                    vv = string.format("%d", v)
                                else
                                    vv = string.format("%f", v)
                                end
                            elseif type(v) == "boolean" then
                                vv = string.format("%s", v and "true" or "false")
                            else
                                error(string.format("unsupported type in layer map file for reversed-map creation: %s (entry: %s)", type(v), name))
                            end
                            table.insert(content, string.format("%s = %s", k, vv))
                        end
                        table.insert(mappings, string.format("%s = { %s }", export, table.concat(content, ", ")))
                    end
                end
                rev = {
                    -- FIXME: this currently only makes sense for GDS
                    layer = entry.layer[targetexport].layer,
                    purpose = entry.layer[targetexport].purpose,
                    mappings = mappings
                }
            end
            table.insert(reverse, rev)
        end
    end
    return reverse
end

return M
