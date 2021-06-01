local M = {}

-- this file shows how to implement an export
-- functions are marked 'mandatory' or 'optional'
-- optional functions (usually) improve layout quality, as for instance hierarchies are enabled

-- mandatory
function M.get_extension()
end

-- optional
function M.set_options(opt)
end

-- mandatory
function M.get_layer(S)
end

-- optional
function M.at_begin(file)
end

-- optional
function M.at_end(file)
end

-- optional
function M.at_begin_cell(file, cellname)
end

-- optional
function M.at_end_cell(file)
end

-- mandatory
function M.write_rectangle(file, layer, bl, tr)
end

-- mandatory
function M.write_polygon(file, layer, pts)
end

-- optional
function M.write_cell_reference(file, identifier, x, y, orientation)
end

-- optional
function M.write_cell_array(file, identifier, x, y, orientation, xrep, yrep, xpitch, ypitch)
end

-- optional
function M.write_port(file, name, layer, where)
end

return M
