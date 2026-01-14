procedure(OPCPowergridWriteInitial(file)
    fprintf(file "%s\n" "-- base cell")
    fprintf(file "%s\n" "local base = pcell.create_layout_from_script(\"openPCells_cellshapes.lua\")")
    newline(file)
    fprintf(file "%s\n" "-- target metals")
    fprintf(file "%s\n" "local targetmetals = { 2 }")
    newline(file)
    fprintf(file "%s\n" "-- power nets")
    fprintf(file "%s\n" "local powernets = { \"vdd\", \"vss\" }")
    newline(file)
    fprintf(file "%s\n" "-- power metals")
    fprintf(file "%s\n" "local vmetal = 3")
    fprintf(file "%s\n" "local hmetal = 4")
    newline(file)
    fprintf(file "%s\n" "-- power grid size")
    fprintf(file "%s\n" "local pwidth = 1000")
    fprintf(file "%s\n" "local pspace = 1000")
    fprintf(file "%s\n" "local pgrid = #powernets * (pwidth + pspace)")
    newline(file)
    fprintf(file "%s\n" "-- target area")
    fprintf(file "%s\n" "local pbl = point.create(-10000, -10000),")
    fprintf(file "%s\n" "local ptr = point.create( 10000,  10000)")
    newline(file)
    fprintf(file "%s\n" "local netshapes = {}")
    fprintf(file "%s\n" "for _, net in ipairs(powernets) do")
    fprintf(file "%s\n" "    for _, net in ipairs(targetmetals) do")
    fprintf(file "%s\n" "        util.insert_table(netshapes, base:get_net_shapes(net, generics.metal(metal)))")
    fprintf(file "%s\n" "    end")
    fprintf(file "%s\n" "end")
    newline(file)
    fprintf(file "%s\n" "-- get shapes on power grid metals for exclusion")
    fprintf(file "%s\n" "local vshapes = base:get_shape_outlines(generics.metal(vmetal))")
    fprintf(file "%s\n" "local hshapes = base:get_shape_outlines(generics.metal(hmetal))")
    newline(file)
    fprintf(file "%s\n" "-- main power grid shapes cell")
    fprintf(file "%s\n" "local cell = object.create(\"opcpowergrid\")")
    newline(file)
    fprintf(file "%s\n" "-- draw boundary")
    fprintf(file "%s\n" "geometry.rectanblebltr(fillcell, generics.outline(), pbl, ptr)")
    newline(file)
    fprintf(file "%s\n" "-- place vertical lines")
    fprintf(file "%s\n" "local vlines = layouthelpers.place_vlines(")
    fprintf(file "%s\n" "    cell,")
    fprintf(file "%s\n" "    pbl, ptr,")
    fprintf(file "%s\n" "    generics.metal(vmetal),")
    fprintf(file "%s\n" "    pwidth, pspace,")
    fprintf(file "%s\n" "    pwidth, -- minwidth")
    fprintf(file "%s\n" "    powernets,")
    fprintf(file "%s\n" "    vshapes -- excludes")
    fprintf(file "%s\n" ")")
    newline(file)
    fprintf(file "%s\n" "-- place horizontal lines")
    fprintf(file "%s\n" "local hlines = layouthelpers.place_hlines(")
    fprintf(file "%s\n" "    cell,")
    fprintf(file "%s\n" "    pbl, ptr,")
    fprintf(file "%s\n" "    generics.metal(hmetal),")
    fprintf(file "%s\n" "    pwidth, pspace,")
    fprintf(file "%s\n" "    pwidth, -- minwidth")
    fprintf(file "%s\n" "    powernets,")
    fprintf(file "%s\n" "    hshapes -- excludes")
    fprintf(file "%s\n" ")")
    newline(file)
    fprintf(file "%s\n" "-- draw labels to identify shapes")
    fprintf(file "%s\n" "layouthelpers.annotate_netshapes(cell, vlines, 100)")
    fprintf(file "%s\n" "layouthelpers.annotate_netshapes(cell, hlines, 100)")
    newline(file)
    fprintf(file "%s\n" "-- connect target shapes to lower metal")
    fprintf(file "%s\n" "local lowerlines = vmetal < hmetal and vlines or hlines")
    fprintf(file "%s\n" "for _, metal in ipairs(targetmetals) do")
    fprintf(file "%s\n" "    layouthelpers.place_vias(")
    fprintf(file "%s\n" "        cell,")
    fprintf(file "%s\n" "        metal, math.min(vmetal, hmetal),")
    fprintf(file "%s\n" "        netshapes, vlines")
    fprintf(file "%s\n" "    )")
    newline(file)
    fprintf(file "%s\n" "layouthelpers.place_vias(")
    fprintf(file "%s\n" "    cell,")
    fprintf(file "%s\n" "    vmetal, hmetal,")
    fprintf(file "%s\n" "    vlines, hlines")
    fprintf(file "%s\n" ")")
    newline(file)
    fprintf(file "%s\n" "-- return shapes")
    fprintf(file "%s\n" "return cell")
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
            ; add some starting code to empty fill scripts
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
        ; call fill script
        path = lsprintf("%s/%s/layout/opcpowergrid.lua" libPath cellName)
        OPCArgs = OPCPrepareArgsForCellCreation(
            lsprintf("--cellscript %s -f %s" path OPCSettingsForm->OPCCellFilename->value)
            origin
            ?groupname groupname
        )
        ; FIXME: should fill always be flat? Currently it is, as the callback is called without parameters and hierarchical is nil
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
