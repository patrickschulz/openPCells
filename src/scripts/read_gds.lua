local layermap = {}
if args.gdslayermap then
    layermap = dofile(args.gdslayermap)
end

local gdslib = gdsparser.read_stream(args.readgds, args.gdsignorelpp)
local cells = gdslib.cells
local alignmentboxinfo
if args.gdsalignmentboxlayer and args.gdsalignmentboxpurpose then
    alignmentboxinfo = { layer = tonumber(args.gdsalignmentboxlayer), purpose = tonumber(args.gdsalignmentboxpurpose) }
end
local libname
if args.gdsusestreamlibname then
    libname = gdslib.libname
elseif args.importlibname then
    libname = args.importlibname
else
    libname = string.gsub(args.readgds, "%.gds", "")
end
local namepattern = "(.+)"
if args.importnamepattern then
    namepattern = args.importnamepattern
end
import.translate_cells(cells, args.importprefix, libname, layermap, alignmentboxinfo, args.importoverwrite, args.importflatpattern, namepattern)
