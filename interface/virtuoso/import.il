procedure(OPCImportWriteInitial(file)
    let(
        (lines)
        lines = list(
            "local filename = \"opctoplevel.cdl\""
            ""
            "local netlist = import.read_CDL_netlist(filename)"
            ""
            "--import.report_netlist(netlist)"
            ""
            "local devicemap = {"
            "   mosfet = {"
            "       nmos = import.maps.mosfet({"
            "           channeltype = \"nmos\","
            "           vthtype = 1,"
            "           oxidetype = 1,"
            "           flippedwell = true,"
            "       "}),"
            "       pmos = import.maps.mosfet({"
            "           channeltype = \"pmos\","
            "           vthtype = 1,"
            "           oxidetype = 1,"
            "           flippedwell = true,"
            "       "}),"
            "   "},"
            "}"
            ""
            "-- placement"
            "local devices = import.map_netlist_devices(netlist, devicemap)"
            "local groups = {"
            "    -- specify devices that should be within one group:"
            "    { \"M0\", \"M1\" }, -- example syntax"
            "}"
            "local constraints = {"
            ""
            "}"
            "local ignored_nets = { \"vdd\", \"vss\", }"
            "local places, pinfo = placement.place_analog(devices, groups, constraints, ignored_nets)"
            ""
            "--import.report_devices(devices)"
            ""
            "--local routes = routing.route_analog(devices, places, ignored_nets)"
            ""
            "--import.check(devices, placeinstructions, { devices = \"warn\", placement = \"error\" })"
            ""
            "local filename = \"toplevel.lua\""
            "local file = io.open(filename, \"w\")"
            "generator.analog(file, settings, devices, places, routes)"
            "file:close()"
            "print(string.format(\"created file '%s'\", filename))"
        )
        foreach(line lines
            fprintf(file "%s\n" line)
        )
    ) ; let
) ; OPCImportWriteInitial

procedure(OPCImportEditScript()
    letseq(
        (
            (cv geGetEditCellView())
            (libPath cv->lib->readPath)
            (cellName cv->cellName)
            path file
        )
        path = lsprintf("%s/%s/layout/opcimport.lua" libPath cellName)
        unless(isFile(path)
            ; add some starting code to empty import scripts
            file = outfile(path "w")
            OPCImportWriteInitial(file)
            close(file)
        )
        OPCOpenEditor(path)
    )
) ; OPCImportEditScript

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

/*
procedure(OPCCollectNetShapes()
    let(
        (cv group)
        cv = geGetEditCellView()
        group = dbCreateFigGroup(cv "opcnetshapes")
        foreach(instance cv->instances
            foreach(shape instance->master->shapes
                dbCopyFig(cv shape)
                dbAddFig
            ) ; foreach shapes
        ) ; foreach instances
    ) ; let
) ;

mapcar(lambda( (instTerm)
    list(nil 
        'name instTerm->name 
        'shapes setof(shape master->shapes shape->net->name == instTerm->term->net->name)
    )
))
*/
