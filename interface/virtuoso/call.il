procedure(OPCPrepareArgsForCellCreation(args @key (newgroup nil))
    OPCArgs = lsprintf("--technology %s --export SKILL %s -X '-L %f'" OPCTech args OPCSettingsForm->OPCSettingsLabelSize->value)
    when(OPCSettingsForm->OPCSettingsGroup->value == "true"
        if(!newgroup && OPCSettingsForm->OPCSettingsGroupConsecutively->value == "true"
            then
                let(
                    ((i 1))
                    while(dbGetFigGroupByName(geGetEditCellView() lsprintf("%s_%d" OPCSettingsForm->OPCSettingsGroupname->value i)) != nil
                        i = i + 1
                    )
                    OPCArgs = lsprintf("%s -X -g -X '-n %s_%d'" OPCArgs OPCSettingsForm->OPCSettingsGroupname->value i)
                )
            else
                OPCArgs = lsprintf("%s -X -g -X '-n %s'" OPCArgs OPCSettingsForm->OPCSettingsGroupname->value)
        )
    )
    when(OPCSettingsForm->OPCSettingsDrawAlignmentbox->value == "true"
        OPCArgs = lsprintf("%s --draw-alignmentbox" OPCArgs)
    )
    OPCArgs
)

procedure(OPCBuildCallCommand(args)
    let(
        ((additionalargs ""))
        additionalargs = OPCSettingsForm->OPCSettingsCmdAdditionalArgs->value
        when(OPCSettingsForm->OPCSettingsMerge->value == "true"
            additionalargs = lsprintf("%s --merge-rectangles" additionalargs)
        )
        lsprintf( "%s/%s %s %s" OPCPath OPCExec args additionalargs)
    )
)

procedure(OPCCall(OPCCommand redirect)
    let(
        ()
        when(redirect
            OPCCommand = lsprintf( "%s > %s" OPCCommand redirect)
        )
        when(OPCSettingsForm->OPCSettingsLog->value == "true"
            printf("opc call: %s\n" OPCCommand)
        )
        pid = ipcBeginProcess(OPCCommand)
        ipcWait(pid 30 1) ; wait for process to finish
        exitstatus = ipcGetExitStatus(pid)
        if(exitstatus != 0
            then 
                hiDisplayAppDBox(
                    ?name        'OPCInfoDialog
                    ?dboxBanner  "openPCells"
                    ?dboxText    lsprintf("errors while executing opc: %s" ipcReadProcess(pid))
                    ?dialogType   hicWarningDialog
                    ?dialogStyle 'modeless
                    ?buttonLayout 'Close
                )
                nil
            else
                t
        ) ; if exitstatus
    ) ; let
)

procedure(OPCCleanUp(filename)
    when(OPCSettingsForm->OPCSettingsDeleteFile->value == "true"
        when(isFile(filename)
            deleteFile(filename)
        )
    )
)

