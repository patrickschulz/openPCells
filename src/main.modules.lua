local modules = {
    "profiler",
    "cmdparser",
    "point",
    "technology",
    "postprocess",
    "export",
    "config",
    "object",
    "geometry",
    "layout",
    "graphics",
    --"generics",
    "util",
    "aux",
    "reduce",
    "stack",
    "support",
    "envlib",
    "globals",
    "union",
    "marker",
    "support/gdstypetable",
    "gdsparser",
    "verilog_parser",
    "generator",
    "import",
    "pcell",
    "placement",
    "input",
    "assistant",
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
