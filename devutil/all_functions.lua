-- to be called by: opc --technology opc --export gds --cellscript all_functions.lua
-- (the technology and the export do not matter as long as existing ones are used.
--  the cell script fails anyway as it does not return an object.)

local exclude = { "_G", "debug", "math", "string", "io", "package", "rawlen", "rawequal", "assert", "pairs", "ipairs" }

for k, v in pairs(_ENV) do
    if not util.any_of(k, exclude) then
        if type(v) == "table" then
            for kk, vv in pairs(v) do
                if type(vv) == "function" then
                    print(string.format("%s.%s", k, kk))
                end
            end
        elseif type(v) == "function" then
            print(k)
        end
    end
end
