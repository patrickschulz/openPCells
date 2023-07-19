procedure(OPCEditCallback()
    letseq(
        (
            (cv geGetEditCellView())
            (libPath cv->lib->readPath)
            (cellName cv->cellName)
            path OPCArgs
        )
        path = lsprintf("%s/%s/layout/layout.lua" libPath cellName)
        unless(isFile(path)
            let(((file outfile(path)))
                fprintf(file "%s" "local cell = object.create(\"cell\")\n\nreturn cell")
                close(file)
                OPCCleanUp(path)
            )
        )
        pid = ipcBeginProcess(lsprintf(OPCSettingsForm->OPCSettingsEditCmd->value path))
    )
) ; procedure

procedure(OPCUpdateCallback(@key (callopc t) (hierarchical t) (xpath nil))
    letseq(
        (
            (cv geGetEditCellView())
            (libPath cv->lib->readPath)
            (libname cv->libName) ; read by generated .il script, don't remove
            (cellName cv->cellName)
            path OPCArgs OPCCmd success
        )
        if(xpath
            then
                path = xpath
            else
                path = lsprintf("%s/%s/layout/layout.lua" libPath cellName)
        )
        OPCArgs = OPCPrepareArgsForCellCreation(lsprintf("--cellscript %s -f %s" path OPCSettingsForm->OPCCellFilename->value))
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
                        success = nil
                        printf("opc call: %s\n" OPCCmd)
                )
            else
                success = t
        )
        when(success
            foreach(shape cv->shapes dbDeleteObject(shape))
            foreach(inst cv->instances dbDeleteObject(inst))
            foreach(via cv->vias dbDeleteObject(via))
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
            ?exporttype "gds"
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
