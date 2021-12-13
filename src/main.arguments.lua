local argparse = cmdparser()
argparse:load_options_from_file(string.format("%s/src/%s.lua", _get_opc_home(), "cmdoptions"))
argparse:prepend_to_help_message([[
openPCells layout generator (opc) - Patrick Kurth 2020 - 2021

Generate layouts of integrated circuit geometry
opc supports technology-independent descriptions of parametric layout cells (pcells), 
which can be translated into a physical technology and exported to a file via a specific export.
]])
argparse:append_to_help_message([[

Most common usage examples:
   get cell parameter information:             opc --cell logic/dff --parameters
   create a cell:                              opc --technology TECH --export gds --cell logic/dff
   create a cell from a foreign collection:    opc --add-cellpath /path/to/collection --technology TECH --export gds --cell other/somecell
   create a cell by using a cellscript:        opc --technology TECH --export gds --cellscript celldef.lua
   read a GDS stream file and create cells:    opc --read-GDS stream.gds]])
local args, msg = argparse:parse(arg)
if not args then
    moderror(msg)
end
argparse:set_defaults(args)
-- check command line options sanity
if args.human and args.machine then
    moderror("you can't specify --human and --machine at the same time")
end

-- load user configuration
if not args.nouserconfig then
    if not config.load_user_config(argparse) then
        return 1
    end
end

-- set environment variables
envlib.set("debug", args.debug)
envlib.set("humannotmachine", true) -- default is --human
if args.machine then
    envlib.set("humannotmachine", false)
end
envlib.set("verbose", args.verbose)
if args.ignoremissinglayers then
    envlib.set("ignoremissinglayers", true)
end
if args.ignoremissingexport then
    envlib.set("ignoremissingexport", true)
end
envlib.set("usefallbackvias", args.usefallbackvias)

return args
