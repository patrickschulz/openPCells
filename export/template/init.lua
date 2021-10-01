local M = {}

-- this file shows how to implement an export
-- functions are marked 'mandatory' or 'optional'
-- optional functions (usually) improve layout quality, as - for instance - hierarchies are enabled

-- * optional *
-- make arbitrary calculations that are needed for this export
-- the function gets the toplevel cell as argument
function M.initialize(toplevel)
end

-- * mandatory *
-- provides the file ending of the generated layout (e.g. returns "gds" for the gds export)
function M.get_extension()
end

-- * optional *
-- provides a different name to be used for the technology translation
-- usually, each export needs their one layer definitions in the technology layermap,
-- but some exports can reuse other data, such as the OASIS export, which can reuse 
-- layer names from GDS
function M.get_techexport()
end

-- * optional *
-- callback for export command line options
-- before the export starts, this function (if present) is called with the collected
-- command line arguments. Only useful if a cmdoptions.lua file is provided for this export type
function M.set_options(opt)
end

-- * mandatory *
-- function which defines how the export gets its layer
-- usually pretty simple, as most of the work is already done in the technology translation
-- example from the GDS export: return { S:get_lpp():get().layer, purpose = S:get_lpp():get().purpose }
function M.get_layer(S)
end

-- * optional *
-- function called at the start of the export, before any other data is written to the file
function M.at_begin(file)
end

-- * optional *
-- function called at the end of the export, after all other data is written to the file
function M.at_end(file)
end

-- * optional *
-- function called at the start of a cell
-- usefull for exports that support hierarchies, but some exports such as GDS need this 
-- also in the case of flat layouts
function M.at_begin_cell(file, cellname)
end

-- * optional *
-- counterpart to at_begin_cell. Called AFTER the cell is written
function M.at_end_cell(file)
end

-- * mandatory *
-- how to write a rectangle
function M.write_rectangle(file, layer, bl, tr)
end

-- * mandatory *
-- how to write a polygon
function M.write_polygon(file, layer, pts)
end

-- * optional *
-- how to write a path
-- if not present, the shape will be converted accordingly (to a single rectangle if possible, otherwise to a polygon)
function M.write_path(file, layer, pts, width)
end

-- * optional *
-- how to write a cell reference (a child in opc terminology). Needed for hierarchies
function M.write_cell_reference(file, identifier, x, y, orientation)
end

-- * optional *
-- how to write an array of cell reference
function M.write_cell_array(file, identifier, x, y, orientation, xrep, yrep, xpitch, ypitch)
end

-- * optional *
-- how to write a named for layout topology data (e.g. LVS)
function M.write_port(file, name, layer, where)
end

return M
