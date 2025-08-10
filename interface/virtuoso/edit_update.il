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

procedure(OPCUpdateCellscriptCallback(@key (deleteAll t) (callopc t) (hierarchical t) (origin list(0 0)) (xpath nil) (xgroupname nil))
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
            ?useOrigin nil
            ?groupname groupname
        )
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
) ; OPCUpdateCellscriptCallback

procedure(OPCCellWritePfile(parameterlist)
    let(
        (
            (pfile outfile(OPCSettingsForm->OPCParamFilename->value))
        )
        fprintf(pfile "%s\n" "return {")
        foreach(kvpair parameterlist
            fprintf(pfile "    %s = %s,\n" car(kvpair) cadr(kvpair))
        )
        fprintf(pfile "%s\n" "}")
        close(pfile)
    )
) ; OPCCreateCellInternal

procedure(OPCUpdateCellCellCallback(cellname parameterlist @key (deleteAll t) (callopc t) (hierarchical t) (origin list(0 0)) (xpath nil) (xgroupname nil))
    letseq(
        (
            (cv geGetEditCellView())
            (libPath cv->lib->readPath)
            (libname cv->libName) ; read by generated .il script, don't remove
            groupname OPCArgs OPCCmd success
        )
        if(xgroupname
            then
                groupname = xgroupname
            else
                groupname = OPCGetGroupName()
        )
        OPCCellWritePfile(parameterlist)
        OPCArgs = OPCPrepareArgsForCellCreation(
            lsprintf("--cell %s --pfile %s -f %s" cellname OPCSettingsForm->OPCParamFilename->value OPCSettingsForm->OPCCellFilename->value)
            origin
            ?groupname groupname
        )
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
            OPCCleanUp(OPCSettingsForm->OPCParamFilename->value)
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
        OPCCall(OPCCmd ?redirect OPCSettingsForm->OPCStdoutFileName->value)
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
