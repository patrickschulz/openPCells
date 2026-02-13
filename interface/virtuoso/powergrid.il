procedure(OPCPowergridWriteInitial(file)
    let(
        (lines)
        lines = list(
            "-- base cell"
            "local base = pcell.create_layout_from_script(\"openPCells_cellshapes.lua\")"
            ""
            "-- target metals (can also be nil/emtpy)"
            "local targetmetals = { 1 }"
            ""
            "-- power nets"
            "local powernets = { \"vdd\", \"vss\" }"
            ""
            "-- power metals"
            "local vmetal = 2"
            "local hmetal = 3"
            ""
            "-- place only full-size vias"
            "local only_full_vias = true"
            ""
            "-- power grid size"
            "local pwidth = 1000"
            "local pspace = 1000"
            "local pgrid = #powernets * (pwidth + pspace)"
            ""
            "-- target area"
            "local pbl = point.create(-10000, -10000)"
            "local ptr = point.create( 10000,  10000)"
            ""
            "-- get shapes on power grid metals for exclusion"
            "local offset = 500 -- offset/distance around shapes as exclusion zones"
            "local vshapes = base:get_shape_outlines(generics.metal(vmetal), offset)"
            "local hshapes = base:get_shape_outlines(generics.metal(hmetal), offset)"
            ""
            "-- main power grid shapes cell"
            "local cell = object.create(\"opcpowergrid\")"
            ""
            "-- draw boundary"
            "geometry.rectanglebltr(cell, generics.outline(), pbl, ptr)"
            ""
            "-- place vertical lines"
            "local vlines = layouthelpers.place_vlines("
            "    cell,"
            "    pbl, ptr,"
            "    generics.metal(vmetal),"
            "    pwidth, pspace,"
            "    pwidth, -- minwidth"
            "    powernets,"
            "    vshapes -- excludes"
            ")"
            ""
            "-- place horizontal lines"
            "local hlines = layouthelpers.place_hlines("
            "    cell,"
            "    pbl, ptr,"
            "    generics.metal(hmetal),"
            "    pwidth, pspace,"
            "    pwidth, -- minwidth"
            "    powernets,"
            "    hshapes -- excludes"
            ")"
            ""
            "-- draw labels to identify shapes"
            "layouthelpers.annotate_netshapes(cell, vlines, 100)"
            "layouthelpers.annotate_netshapes(cell, hlines, 100)"
            ""
            "-- connect target shapes to power grid"
            "for _, targetmetal in ipairs(targetmetals or {}) do"
            "    local netshapes = {}"
            "    for _, net in ipairs(powernets) do"
            "        util.insert_table(netshapes, base:get_net_shapes(net, generics.metal(targetmetal)))"
            "    end"
            "    -- lines to connect to"
            "    local powermetal"
            "    local powerlines"
            "    if targetmetal < math.min(vmetal, hmetal) then -- target metal below power grid"
            "        if vmetal < hmetal then"
            "            powermetal = vmetal)"
            "            powerlines = vlines"
            "        else"
            "            powermetal = hmetal)"
            "            powerlines = hlines"
            "        end"
            "    elseif targetmetal > math.max(vmetal, hmetal) then -- target metal above power grid"
            "        if vmetal > hmetal then"
            "            powermetal = vmetal)"
            "            powerlines = vlines"
            "        else"
            "            powermetal = hmetal)"
            "            powerlines = hlines"
            "        end"
            "    else -- target metal on power grid"
            "        if targetmetal == hmetal then"
            "            powermetal = vmetal)"
            "            powerlines = vlines"
            "        else"
            "            powermetal = hmetal)"
            "            powerlines = hlines"
            "        end"
            "    end"
            "    -- get intermediate shapes between targetmetal and lowest grid metal"
            "    local viaoffset = 500"
            "    local intermediate_shapes = {}"
            "    for metal = targetmetal + 1, math.min(vmetal, hmetal) - 1 do"
            "        local shapes = base:get_shape_outlines(generics.metal(metal), viaoffset)"
            "        util.insert_table(intermediate_shapes, shapes)"
            "    end"
            "    layouthelpers.place_vias("
            "        cell,"
            "        netshapes, powerlines,"
            "        intermediate_shapes, -- excludes"
            "        nil, -- net filter"
            "        only_full_vias"
            "    )"
            "end"
            ""
            "-- place vias between power lines"
            "layouthelpers.place_vias("
            "    cell,"
            "    vlines, hlines"
            ")"
            ""
            "-- return shapes"
            "return cell"
        )
        foreach(line lines
            fprintf(file "%s\n" line)
        )
    ) ; let
) ; OPCPowergridWriteInitial

procedure(OPCPowergridEditScript()
    letseq(
        (
            (cv geGetEditCellView())
            (libPath cv->lib->readPath)
            (cellName cv->cellName)
            path file
        )
        path = lsprintf("%s/%s/layout/opcpowergrid.lua" libPath cellName)
        unless(isFile(path)
            ; add some starting code to empty powergrid scripts
            file = outfile(path "w")
            OPCPowergridWriteInitial(file)
            close(file)
        )
        OPCOpenEditor(path)
    )
) ; OPCPowergridEditScript

procedure(OPCUpdatePowergridCallback(@key (deleteAll t) (callopc t) (hierarchical nil) (origin list(0 0)) (useOrigin nil))
    letseq(
        (
            (cv geGetEditCellView())
            (libPath cv->lib->readPath)
            (libname cv->libName) ; read by generated .il script, don't remove
            (cellName cv->cellName)
            path groupname OPCArgs OPCCmd success
        )
        groupname = "opcpowergrid"
        let(((group dbGetFigGroupByName(cv groupname)))
            when(group
                foreach(obj group->figs dbDeleteObject(obj))
                dbDeleteObject(group)
            )
        )
        ; write out current cell (for exclude shapes)
        OPCExportCell("openPCells_cellshapes.lua")
        ; call powergrid script
        path = lsprintf("%s/%s/layout/opcpowergrid.lua" libPath cellName)
        OPCArgs = OPCPrepareArgsForCellCreation(
            lsprintf("--cellscript %s -f %s" path OPCSettingsForm->OPCCellFilename->value)
            origin
            ?groupname groupname
        )
        ; FIXME: should powergrid always be flat? Currently it is, as the callback is called without parameters and hierarchical is nil
        unless(hierarchical
            OPCArgs = lsprintf("%s --flat" OPCArgs)
        )
        OPCCmd = OPCBuildCallCommand(OPCArgs)
        success = if(callopc
            then
                OPCCall(OPCCmd ?redirect OPCSettingsForm->OPCStdoutFileName->value)
            else
                t
        )
        when(success
            let(((group dbGetFigGroupByName(cv groupname)))
                foreach(obj group->figs dbDeleteObject(obj))
            )
            load(lsprintf("%s.il" OPCSettingsForm->OPCCellFilename->value))
            OPCCleanUp(lsprintf("%s.il" OPCSettingsForm->OPCCellFilename->value))
        )
    )
) ; OPCUpdateCellscriptCallback

procedure(OPCDeletePowergridGroup()
    let(
        (cv groupname)
        cv = geGetEditCellView()
        groupname = "opcpowergrid"
        let(((group dbGetFigGroupByName(cv groupname)))
            when(group
                foreach(obj group->figs dbDeleteObject(obj))
                dbDeleteObject(group)
            )
        )
    )
) ; OPCDeletePowergridGroup

procedure(OPCDeletePowergridScript()
    letseq(
        (
            (cv geGetEditCellView())
            (libPath cv->lib->readPath)
            (cellName cv->cellName)
            (path lsprintf("%s/%s/layout/opcpowergrid.lua" libPath cellName))
        )
        when(isFile(path)
            deleteFile(path)
        )
    )
) ; OPCDeletePowergridScript
