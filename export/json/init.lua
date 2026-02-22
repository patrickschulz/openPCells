local M = {}

-- this file shows how to implement an export
-- functions are marked 'mandatory' or 'optional'
-- optional functions (usually) improve layout quality, as - for instance - hierarchies are enabled
-- 
-- the export assembles the data by itself, getting the unformatted data from the caller via appropriate 
-- functions (e.g. write_rectangle). In the end, a single string has to be given back to the caller with finalize()
-- The usual way here is to collect everything in a table (__content) and concat that in finalize()
-- The export can also do other things with this data (like sorting). Have a look in the SVG interface for an example

local __content = {
    pre = {},
    inner = {},
    post = {},
}

function M.finalize()
    local t = {}
    table.insert(t, table.concat(__content.pre, "\n"))
    table.insert(t, table.concat(__content.inner, ",\n"))
    table.insert(t, table.concat(__content.post, "\n"))
    return table.concat(t, "\n")
end

function M.get_extension()
    return "json"
end

-- * optional *
-- function called at the start of the export, data will be written before other data
function M.at_begin()
    table.insert(__content.pre, "[")
end

-- * optional *
-- function called at the end of the export, data will be written after all other data
function M.at_end()
    table.insert(__content.post, "]")
end

function M.write_rectangle(layer, bl, tr)
    table.insert(__content.inner,
        string.format('    { "type": "rect", "x": %d, "y": %d, "width": %d, "height": %d, "layer": "%s" }',
            bl.x,
            bl.y,
            tr.x - bl.x,
            tr.y - bl.y,
            layer.layer
        )
    )
end

function M.write_polygon(layer, pts)
end

function M.write_path(layer, pts, width, extension)
end

function M.write_port(name, layer, where, sizehint)
    table.insert(__content.inner,
        string.format('    { "type": "text", "x": %d, "y": %d, "text": "%s", "layer": "%s" }',
            where.x,
            where.y,
            name,
            layer.layer
        )
    )
end

return M
