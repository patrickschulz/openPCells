local modules = {
    "profiler",
    "cmdparser",
    "point",
    "geometry",
    "graphics",
    "util",
    "aux",
    "stack",
    "support",
    "envlib",
    "globals",
    "marker",
    "support/gdstypetable",
    "gdsparser",
    "verilog",
    "verilogprocessor",
    "generator",
    "import",
    "pcell",
    "placement",
    "routing",
    "public"
}
for _, module in ipairs(modules) do
    local path = module
    local name = module
    if string.match(module, "/") then
        name = string.match(module, "/([^/]+)$")
    end
    local mod = _load_module(path)
    if mod then -- some modules directly manipulate global variables and hence don't return anything
        _ENV[name] = mod
    end
end
