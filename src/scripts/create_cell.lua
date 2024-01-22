-- create cell
pcell.enable_debug(args.debugcell)
pcell.enable_dprint(args.enabledprint)
local cell
if args.isscript then
    cell = pcell.create_layout_from_script(args.cell, args.additionalargs)
else
    if #args.additionalargs > 0 then
        error("creating a cell from a cell definition, but additional positional arguments (non-key-value pairs) are present")
    end
    cell = pcell.create_layout_env(args.cell, args.toplevelname, args.cellargs, args.cellenv)
end

return cell
