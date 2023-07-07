procedure(OPCPrepareArgsForCellCreation(args @key (newgroup nil) (exporttype "SKILL"))
    OPCArgs = lsprintf("--technology %s --export %s %s -X '-L %f'" OPCTech exporttype args OPCSettingsForm->OPCSettingsLabelSize->value)
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
    when(OPCSettingsForm->OPCSettingsExpandNamecontexts->value == "false"
        OPCArgs = lsprintf("%s --no-expand-namecontexts" OPCArgs)
    )
    when(OPCSettingsForm->OPCSettingsWriteChildrenPorts->value == "true"
        OPCArgs = lsprintf("%s --write-children-ports" OPCArgs)
    )
    when(OPCSettingsForm->OPCSettingsDrawAlignmentbox->value == "true"
        OPCArgs = lsprintf("%s --draw-alignmentbox" OPCArgs)
    )
    when(OPCSettingsForm->OPCSettingsDrawAllAlignmentboxes->value == "true"
        OPCArgs = lsprintf("%s --draw-all-alignmentboxes" OPCArgs)
    )
    if(OPCSettingsForm->OPCSettingsSplitLets->value == "false"
        then
            OPCArgs = lsprintf("%s -X --no-let-splits" OPCArgs)
        else
            OPCArgs = lsprintf("%s -X '--max-let-splits %d'" OPCArgs OPCSettingsForm->OPCSettingsMaxLetSplits->value)
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

procedure(OPCCall(OPCCommand @key (redirect nil))
    let(
        (errmsg)
        when(redirect
            OPCCommand = lsprintf( "%s > %s" OPCCommand redirect)
        )
        when(OPCSettingsForm->OPCSettingsLog->value == "true"
            printf("opc call: %s\n" OPCCommand)
        )
        pid = ipcBeginProcess(OPCCommand)
        ipcWait(pid 30 30) ; wait for process to finish
        exitstatus = ipcGetExitStatus(pid)
        if(exitstatus != 0
            then 
                errmsg = ipcReadProcess(pid)
                unless(errmsg
                    errmsg = "unknown error, this is a bug in opc (likely a segmentation fault)"
                )
                hiDisplayAppDBox(
                    ?name        'OPCInfoDialog
                    ?dboxBanner  "openPCells"
                    ?dboxText    lsprintf("errors while executing opc: %s" errmsg)
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

