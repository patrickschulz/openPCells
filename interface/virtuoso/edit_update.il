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
                fprintf(file "%s" "local cell = object.create()\n\nreturn cell")
                close(file)
                OPCCleanUp(path)
            )
        )
        pid = ipcBeginProcess(lsprintf(OPCSettingsForm->OPCSettingsEditCmd->value path))
    )
) ; procedure

procedure(OPCUpdateCallback()
    letseq(
        (
            (cv geGetEditCellView())
            (libPath cv->lib->readPath)
            (cellName cv->cellName)
            path OPCArgs OPCCmd
        )
        path = lsprintf("%s/%s/layout/layout.lua" libPath cellName)
        OPCArgs = OPCPrepareArgsForCellCreation(lsprintf("--cellscript %s -f %s" path OPCSettingsForm->OPCCellFilename->value) ?newgroup t)
        OPCCmd = OPCBuildCallCommand(OPCArgs)
        if(OPCCall(OPCCmd nil)
            then
                foreach(shape cv->shapes dbDeleteObject(shape))
                foreach(inst cv->instances dbDeleteObject(inst))
                foreach(via cv->vias dbDeleteObject(via))
                load(lsprintf("%s.il" OPCSettingsForm->OPCCellFilename->value))
                OPCCleanUp(lsprintf("%s.il" OPCSettingsForm->OPCCellFilename->value))
            else
                printf("opc call: %s\n" OPCCmd)
        )
    )
) ; procedure
