local filename = arg[1]
if not filename then
    error("no filename given")
end

local _insert_lines_from_file = function(filename, lines, whitespace)
    for line in io.lines(string.format("includes/%s", filename)) do
        table.insert(lines, string.format("%s%s", whitespace or "", line))
    end
end

local _get_prefix = function(level)
    local prefix = ""
    if where ~= 0 then
        prefix = string.rep("../", level)
    end
    return prefix
end

local _insert_header = function(level, title, lines, whitespace)
    table.insert(lines, string.format("%s<head>", whitespace or ""))
    table.insert(lines, string.format("%s    <meta charset=\"utf-8\">", whitespace or ""))
    table.insert(lines, string.format("%s    <title>%s</title>", whitespace or "", title))
    local prefix = _get_prefix(level)
    table.insert(lines, string.format("%s    <link rel=\"stylesheet\" href=\"%sstyle.css\">", whitespace or "", prefix))
    table.insert(lines, string.format("%s</head>", whitespace or ""))
end

local _insert_topbar = function(level, subtitle, lines, whitespace)
    table.insert(lines, string.format("%s<div class=\"topbar\">", whitespace))
    table.insert(lines, string.format("%s    <div class=\"topbar-content\">", whitespace))
    local prefix = _get_prefix(level)
    table.insert(lines, string.format("%s        <a href=\"%sindex.html\" class=\"title\">OpenPCells Documentation</a>", whitespace, prefix))
    table.insert(lines, string.format("%s        <h2 class=\"subtitle\">%s</h2>", whitespace, subtitle))
    table.insert(lines, string.format("%s    </div>", whitespace))
    table.insert(lines, string.format("%s</div>", whitespace))
end

local level = 0
for _, m in string.gmatch(filename, "%/") do
    level = level + 1
end

local file = io.open(string.format("%s.htmlpre", filename), "r")
if not file then
    error(string.format("could not open file '%s.htmlpre'", filename))
end
local lines = {}
for line in file:lines() do
    local whitespace, command, argstr = string.match(line, "^(%s+)%@([%w_]+)%s+(.+)")
    if whitespace then -- command
        local args = {}
        for arg in string.gmatch(argstr, "(%S+)") do
            table.insert(args, arg)
        end
        if command == "include" then
            _insert_lines_from_file(argstr, lines, whitespace)
        elseif command == "make_header" then
            _insert_header(level, argstr, lines, whitespace)
        elseif command == "make_topbar" then
            _insert_topbar(level, argstr, lines, whitespace)
        else
            error(string.format("unknown command '%s'", command))
        end
    else
        table.insert(lines, line)
    end
end

file:close()

local outfile = io.open(string.format("%s.html", filename), "w")
for _, line in ipairs(lines) do
    outfile:write(string.format("%s\n", line))
end
outfile:close()

