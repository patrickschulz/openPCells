-- very rudimentary SVG parser
local function parseargs(s)
    local arg = {}
    string.gsub(s, "([%-%w]+)=([\"'])(.-)%2", function (w, _, a)
        arg[w] = a
    end)
    return arg
end

local function collect(s)
    local top = {}
    local stack = { top }
    local ni, c, label, xarg, empty
    local i, j = 1, 1
    while true do
        ni, j, c, label, xarg, empty = string.find(s, "<(%/?)([%w:]+)(.-)(%/?)>", i)
        if not ni then break end
        local text = string.sub(s, i, ni - 1)
        if not string.find(text, "^%s*$") then
            table.insert(top, text)
        end
        if empty == "/" then  -- empty element tag
            table.insert(top, { label = label, xarg = parseargs(xarg), empty = true })
        elseif c == "" then   -- start tag
            top = { label = label, xarg = parseargs(xarg) }
            table.insert(stack, top)   -- new level
        else  -- end tag
            local toclose = table.remove(stack)  -- remove top
            top = stack[#stack]
            if #stack < 1 then
                cellerror("nothing to close with " .. label)
            end
            if toclose.label ~= label then
                cellerror("trying to close " .. toclose.label .. " with " .. label)
            end
            table.insert(top, toclose)
        end
        i = j + 1
    end
    local text = string.sub(s, i)
    if not string.find(text, "^%s*$") then
        table.insert(stack[#stack], text)
    end
    if #stack > 1 then
        cellerror("unclosed " .. stack[#stack].label)
    end
    return stack[1]
end

local function find_paths(tree)
    local paths = {}
    local _find
    _find = function(tree)
        if tree.label == "path" then
            table.insert(paths, tree)
        end
        for _, child in ipairs(tree) do
            _find(child)
        end
    end
    _find(tree)
    return paths
end

local function parse_svg_path(path)
    local out = {}
    for instr, vals in string.gmatch(path, "([a-df-zA-DF-Z])([^a-df-zA-DF-Z]*)") do
        local line = { command = instr }
        for v in vals:gmatch("([+-]?[%deE.]+)") do
            table.insert(line, v)
        end
        table.insert(out, line)
    end
    return out
end

function parameters()
    pcell.add_parameters(
        { "filename", "layout.svg" },
        { "metal", -1 },
        { "scale", 1 },
        { "grid", 100 },
        { "allow45", false }
    )
end

function layout(cell, _P)
    -- load svg content
    local filename = _P.filename
    if not filename then
        cellerror("no filename given")
        return nil
    end
    local file = io.open(filename)
    if not file then
        cellerror(string.format("could not read file '%s'", filename))
        return nil
    end
    local content = file:read("a")
    file:close()

    -- parse
    local tree = collect(content)
    local paths = find_paths(tree)

    local function _get_coord(entry, i)
        return math.floor(_P.scale * tonumber(entry[i]))
    end

    -- create layout
    for _, path in ipairs(paths) do 
        local entries = parse_svg_path(path.xarg.d)
        local pts = {}
        local lastx = 0
        local lasty = 0

        local origin
        local curvecontent = {}
        for i, entry in ipairs(entries) do
            if i == 1  then
                if entry.command == "M" then
                    for i = 1, #entry - (2 - 1), 2 do
                        local x = _get_coord(entry, i)
                        local y = _get_coord(entry, i + 1)
                        lastx = x
                        lasty = -y
                    end
                elseif entry.command == "m" then
                    for i = 1, #entry - (2 - 1), 2 do
                        local x = _get_coord(entry, i)
                        local y = _get_coord(entry, i + 1)
                        lastx = lastx + x
                        lasty = lasty - y
                    end
                else
                    cellerror("SVG path does not start with 'M' or 'm'")
                end
                origin = point.create(lastx, lasty)
            else -- i ~= 1
                if entry.command == "M" then
                    for i = 1, #entry - (2 - 1), 2 do
                        local x = _get_coord(entry, i)
                        local y = _get_coord(entry, i + 1)
                        lastx = x
                        lasty = -y
                    end
                elseif entry.command == "m" then
                    for i = 1, #entry - (2 - 1), 2 do
                        local x = _get_coord(entry, i)
                        local y = _get_coord(entry, i + 1)
                        lastx = lastx + x
                        lasty = lasty - y
                    end
                elseif entry.command == "l" then
                    for i = 1, #entry - (2 - 1), 2 do
                        local x = _get_coord(entry, i)
                        local y = _get_coord(entry, i + 1)
                        local segment = curve.lineto(point.create(lastx + x, lasty - y))
                        table.insert(curvecontent, segment)
                        lastx = lastx + x
                        lasty = lasty - y
                    end
                elseif entry.command == "L" then
                    for i = 1, #entry - (2 - 1), 2 do
                        local x = _get_coord(entry, i)
                        local y = _get_coord(entry, i + 1)
                        local segment = curve.lineto(point.create(x, -y))
                        table.insert(curvecontent, segment)
                        lastx = lastx + x
                        lasty = lasty - y
                    end
                elseif entry.command == "h" then
                    for i = 1, #entry, 1 do
                        local x = _get_coord(entry, i)
                        local segment = curve.lineto(point.create(lastx + x, -y))
                        table.insert(curvecontent, segment)
                        lastx = lastx + x
                        lasty = lasty
                    end
                elseif entry.command == "H" then
                    for i = 1, #entry, 1 do
                        local x = _get_coord(entry, i)
                        local segment = curve.lineto(point.create(x, lasty))
                        table.insert(curvecontent, segment)
                        lastx = lastx + x
                        lasty = lasty
                    end
                elseif entry.command == "v" then
                    for i = 1, #entry, 1 do
                        local y = _get_coord(entry, i)
                        local segment = curve.lineto(pts, point.create(lastx, lasty - y))
                        table.insert(curvecontent, segment)
                        lastx = lastx
                        lasty = lasty - y
                    end
                elseif entry.command == "V" then
                    for i = 1, #entry, 1 do
                        local y = _get_coord(entry, i)
                        local segment = curve.lineto(pts, point.create(y, lasty - y))
                        table.insert(curvecontent, segment)
                        lastx = lastx
                        lasty = lasty - y
                    end
                elseif entry.command == "c" then
                    for i = 1, #entry - 5, 6 do
                        local x = _get_coord(entry, i + 4)
                        local y = _get_coord(entry, i + 5)
                        local segment = curve.cubicto(
                            point.create(lastx + _get_coord(entry, i - 1 + 1), lasty - _get_coord(entry, i - 1 + 2)),
                            point.create(lastx + _get_coord(entry, i - 1 + 3), lasty - _get_coord(entry, i - 1 + 4)),
                            point.create(lastx + x, lasty - y)
                        )
                        table.insert(curvecontent, segment)
                        lastx = lastx + x
                        lasty = lasty - y
                    end
                elseif entry.command == "C" then
                    for i = 1, #entry - 5, 6 do
                        local x = _get_coord(entry, i + 4)
                        local y = _get_coord(entry, i + 5)
                        local segment = curve.cubicto(
                            point.create(_get_coord(entry, i - 1 + 1), -_get_coord(entry, i - 1 + 2)),
                            point.create(_get_coord(entry, i - 1 + 3), -_get_coord(entry, i - 1 + 4)),
                            point.create(lastx + x, lasty - y)
                        )
                        table.insert(curvecontent, segment)
                        lastx = lastx + x
                        lasty = lasty - y
                    end
                elseif entry.command == "s" then -- copy of "c", but unsure if this is correct
                    for i = 1, #entry - 5, 6 do
                        local segment = curve.cubicto(
                            point.create(lastx + _get_coord(entry, i - 1 + 1), lasty - _get_coord(entry, i - 1 + 2)),
                            point.create(lastx + _get_coord(entry, i - 1 + 3), lasty - _get_coord(entry, i - 1 + 4)),
                            point.create(lastx + _get_coord(entry, i - 1 + 5), lasty - _get_coord(entry, i - 1 + 6))
                        )
                        table.insert(curvecontent, segment)
                        local x = _get_coord(entry, i + 4)
                        local y = _get_coord(entry, i + 5)
                        lastx = lastx + x
                        lasty = lasty - y
                    end
                elseif entry.command == "S" then -- copy of "C", but unsure if this is correct
                    for i = 1, #entry - 5, 6 do
                        local segment = curve.cubicto(
                            point.create(_get_coord(entry, i - 1 + 1), -_get_coord(entry, i - 1 + 2)),
                            point.create(_get_coord(entry, i - 1 + 3), -_get_coord(entry, i - 1 + 4)),
                            point.create(_get_coord(entry, i - 1 + 5), -_get_coord(entry, i - 1 + 6))
                        )
                        table.insert(curvecontent, segment)
                        local x = _get_coord(entry, i + 4)
                        local y = _get_coord(entry, i + 5)
                        lastx = lastx + x
                        lasty = lasty - y
                    end
                elseif entry.command == "z" then
                    -- finished, do nothing
                else
                    cellerror(string.format("unhandled command: %s", entry.command))
                end
            end
        end
        geometry.curve(cell, generics.metal(_P.metal), origin, curvecontent, _P.grid, _P.allow45)
    end
end
