procedure(OPCOpenEditor(path)
    ipcBeginProcess(lsprintf(OPCSettingsForm->OPCSettingsEditCmd->value path))
) ; procedure

procedure(OPCEditCallback()
    letseq(
        (
            (cv geGetEditCellView())
            (libPath cv->lib->readPath)
            (cellName cv->cellName)
            path OPCArgs
        )
        path = lsprintf("%s/%s/layout/layout.lua" libPath cellName)
        OPCOpenEditor(path)
    )
) ; procedure

procedure(OPCUpdateCallback(@key (deleteAll t) (callopc t) (hierarchical t) (origin list(0 0)) (xpath nil) (xgroupname nil))
    letseq(
        (
            (cv geGetEditCellView())
            (libPath cv->lib->readPath)
            (libname cv->libName) ; read by generated .il script, don't remove
            (cellName cv->cellName)
            path groupname OPCArgs OPCCmd success
        )
        if(xpath
            then
                path = xpath
            else
                path = lsprintf("%s/%s/layout/layout.lua" libPath cellName)
        )
        if(xgroupname
            then
                groupname = xgroupname
            else
                groupname = OPCGetGroupName()
        )
        OPCArgs = OPCPrepareArgsForCellCreation(
            lsprintf("--cellscript %s -f %s" path OPCSettingsForm->OPCCellFilename->value)
            origin
            ?groupname groupname
        )
        unless(hierarchical
            OPCArgs = lsprintf("%s --flat" OPCArgs)
        )
        OPCCmd = OPCBuildCallCommand(OPCArgs)
        if(callopc
            then
                if(OPCCall(OPCCmd)
                    then
                        success = t
                    else
                        printf("opc call: %s\n" OPCCmd)
                        success = nil
                )
            else
                success = t
        )
        when(success
            if(deleteAll
                then
                    foreach(shape cv->shapes dbDeleteObject(shape))
                    foreach(inst cv->instances dbDeleteObject(inst))
                    foreach(via cv->vias dbDeleteObject(via))
                else
                    let(((group dbGetFigGroupByName(cv groupname)))
                        foreach(obj group->figs dbDeleteObject(obj))
                    )
            )
            load(lsprintf("%s.il" OPCSettingsForm->OPCCellFilename->value))
            OPCCleanUp(lsprintf("%s.il" OPCSettingsForm->OPCCellFilename->value))
        )
    )
) ; procedure

procedure(OPCUpdateAsGDS()
    letseq(
        (
            (cv geGetEditCellView())
            (libPath cv->lib->readPath)
            (cellName cv->cellName)
            (path lsprintf("%s/%s/layout/layout.lua" libPath cellName))
            OPCArgs OPCCmd success
        )
        OPCArgs = OPCPrepareArgsForCellCreation(
            lsprintf("--cellscript %s -f %s" path OPCSettingsForm->OPCCellFilename->value)
            list(0 0) ; origin
            ?exporttype "gds"
            ?groupname nil
        )
        /*
        unless(hierarchical
            OPCArgs = lsprintf("%s --flat" OPCArgs)
        )
        */
        OPCCmd = OPCBuildCallCommand(OPCArgs)
        OPCCall(OPCCmd)
    )
) ; procedure

procedure(OPCDeleteDesignFile()

    letseq(
        (
            (cv geGetEditCellView())
            (libPath cv->lib->readPath)
            (cellName cv->cellName)
            (path lsprintf("%s/%s/layout/layout.lua" libPath cellName))
        )
        when(isFile(path)
            deleteFile(path)
        )
    )
) ; procedure
