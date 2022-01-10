local modules = {
    "profiler",
    "cmdparser",
    "lpoint",
    "technology",
    "postprocess",
    "export",
    "config",
    "object",
    "transformationmatrix",
    "shape",
    "geometry",
    "graphics",
    "generics",
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
}
for _, module in ipairs(modules) do
    local path = module
    local name = module
    if string.match(module, "/") then
        name = string.match(module, "/([^/]+)$")
    end
    local mod = _load_module(path)
    if mod then
        _ENV[name] = mod
    end
end