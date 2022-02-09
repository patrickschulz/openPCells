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
                error("nothing to close with " .. label)
            end
            if toclose.label ~= label then
                error("trying to close " .. toclose.label .. " with " .. label)
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
        error("unclosed " .. stack[#stack].label)
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
        { "scale", 1 }
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
        local lastx, lasty = 0, 0

        local function _update(entry, incr, a, b, c, d)
            for i = 1, #entry - (incr - 1), incr do
                if incr == 1 then
                    local delta = math.floor(_P.scale * tonumber(entry[i]))
                    table.insert(pts, point.create(a * lastx + b * delta, c * lasty - d * delta))
                    lastx = a * lastx + b * delta
                    lasty = c * lasty - d * delta
                else
                    local x = math.floor(_P.scale * tonumber(entry[i]))
                    local y = math.floor(_P.scale * tonumber(entry[i + 1]))
                    table.insert(pts, point.create(a * lastx + b * x, c * lasty - d * y))
                    lastx = a * lastx + b * x
                    lasty = c * lasty - d * y
                end
            end
        end

        for _, entry in ipairs(entries) do
            if entry.command == "M" then
                _update(entry, 2, 0, 1, 0, 1)
            elseif entry.command == "m" then
                _update(entry, 2, 1, 1, 1, 1)
            elseif entry.command == "l" then
                _update(entry, 2, 1, 1, 1, 1)
            elseif entry.command == "h" then
                _update(entry, 1, 1, 1, 1, 0)
            elseif entry.command == "v" then
                _update(entry, 1, 1, 0, 1, 1)
            elseif entry.command == "c" then
                for i = 1, #entry - 5, 6 do
                    local x = _get_coord(entry, i + 4)
                    local y = _get_coord(entry, i + 5)
                    local coords = graphics.flatten_cubic_bezier(
                        lastx, lasty,
                        lastx + _get_coord(entry, i - 1 + 1), lasty - _get_coord(entry, i - 1 + 2),
                        lastx + _get_coord(entry, i - 1 + 3), lasty - _get_coord(entry, i - 1 + 4),
                        lastx + _get_coord(entry, i - 1 + 5), lasty - _get_coord(entry, i - 1 + 6)
                    )
                    for j = 1, #coords, 2 do
                        table.insert(pts, point.create(coords[j], coords[j + 1]))
                    end
                    lastx = lastx + x
                    lasty = lasty - y
                end
            elseif entry.command == "C" then
                for i = 1, #entry - 5, 6 do
                    local x = _get_coord(entry, i + 4)
                    local y = _get_coord(entry, i + 5)
                    local coords = graphics.flatten_cubic_bezier(
                        lastx, lasty,
                        _get_coord(entry, i - 1 + 1), -_get_coord(entry, i - 1 + 2),
                        _get_coord(entry, i - 1 + 3), -_get_coord(entry, i - 1 + 4),
                        _get_coord(entry, i - 1 + 5), -_get_coord(entry, i - 1 + 6)
                    )
                    for j = 1, #coords, 2 do
                        table.insert(pts, point.create(coords[j], coords[j + 1]))
                    end
                    lastx = lastx + x
                    lasty = lasty - y
                end
            elseif entry.command == "z" then
                -- finished, do nothing
            else
                dprint(string.format("unhandled command: %s", entry.command))
            end
        end
        cell:merge_into_shallow(geometry.polygon(generics.metal(-1), pts))
    end
end
