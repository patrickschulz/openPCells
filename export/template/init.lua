local M = {}

-- this file shows how to implement an export
-- functions are marked 'mandatory' or 'optional'
-- optional functions (usually) improve layout quality, as - for instance - hierarchies are enabled
-- 
-- the export assembles the data by itself, getting the unformatted data from the caller via appropriate 
-- functions (e.g. write_rectangle). In the end, a single string has to be given back to the caller with finalize()
-- The usual way here is to collect everything in a table (__content) and concat that in finalize()
-- The export can also do other things with this data (like sorting). Have a look in the SVG interface for an example

local __content = {}

-- * optional *
-- make arbitrary calculations that are needed for this export
-- the function gets the minimum and maximum coordinates (x and y)
function M.initialize(minx, maxx, miny, maxy)
end

-- * mandatory *
-- function which defines how the export gets its layer
-- usually pretty simple, as most of the work is already done in the technology translation
-- example from the GDS export: return { S:get_lpp():get().layer, purpose = S:get_lpp():get().purpose }
function M.finalize()
    -- example for string return
    -- most exports work like this, but some need to do something else
    return table.concat(__content)
end

-- * mandatory *
-- provides the file ending of the generated layout (e.g. returns "gds" for the gds export)
function M.get_extension()
    return "TEMPLATE"
end

-- * optional *
-- provides a different name to be used for the technology translation
-- usually, each export needs their one layer definitions in the technology layermap,
-- but some exports can reuse other data, such as the OASIS export, which can reuse 
-- layer names from GDS
function M.get_techexport()
    return "OTHERTEMPLATE"
end

-- * optional *
-- callback for export command line options
-- before the export starts, this function (if present) is called with the collected
-- command line arguments.
function M.set_options(opt)
end

-- * optional *
-- function called at the start of the export, data will be written before other data
function M.at_begin()
end

-- * optional *
-- function called at the end of the export, data will be written after all other data
function M.at_end()
end

-- * optional *
-- function called at the start of a cell
-- usefull for exports that support hierarchies, but some exports such as GDS need this 
-- also in the case of flat layouts
function M.at_begin_cell(cellname)
end

-- * optional *
-- counterpart to at_begin_cell. Called AFTER the cell is written
function M.at_end_cell()
end

-- * mandatory *
-- how to write a rectangle
function M.write_rectangle(layer, bl, tr)
end

-- * optional *
-- how to write a triangle
function M.write_triangle(layer, pt1, pt2, pt3)
end

-- * sort-of mandatory *
-- how to write a polygon
-- if this is not present but write_triangle is provided,
-- polygons are triangulated and written by write_triangle
function M.write_polygon(layer, pts)
end

-- * optional *
-- how to write a path
-- if not present, the shape will be converted accordingly
-- (to a single rectangle if possible, otherwise to a polygon)
function M.write_path(layer, pts, width)
end

-- * optional *
-- how to write a cell reference (a child in opc terminology). Needed for hierarchies
function M.write_cell_reference(identifier, x, y, orientation)
end

-- * optional *
-- how to write an array of cell reference
function M.write_cell_array(identifier, x, y, orientation, xrep, yrep, xpitch, ypitch)
end

-- * optional *
-- how to write a named for layout topology data (e.g. LVS)
function M.write_port(name, layer, where)
end

return M
