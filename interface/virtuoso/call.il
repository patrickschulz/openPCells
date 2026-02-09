procedure(OPCGetGroupName(@key (newgroup nil))
    when(OPCSettingsForm->OPCSettingsGroup->value == "true"
        if(!newgroup && OPCSettingsForm->OPCSettingsGroupConsecutively->value == "true"
            then
                let(
                    ((i 1))
                    while(dbGetFigGroupByName(geGetEditCellView() lsprintf("%s_%d" OPCSettingsForm->OPCSettingsGroupname->value i)) != nil
                        i = i + 1
                    )
                    lsprintf("%s_%d" OPCSettingsForm->OPCSettingsGroupname->value i)
                )
            else
                OPCSettingsForm->OPCSettingsGroupname->value
        )
    )
) ; OPCGetGroupName

procedure(OPCPrepareArgsForCellCreation(args origin @key (useOrigin t) (groupname nil) (exporttype "SKILL"))
    ; virtuoso chokes on loading files with malformed shapes, hence these are ignored
    ; furthermore, the SKILL export currently does not properly handle path extensions
    ; therefore, path extensions are being resolved by opc
    if(useOrigin
        then
            OPCArgs = lsprintf(
                "--technology %s --export %s --relative-origin '(%d, %d)' --ignore-malformed-shapes --resolve-path-extensions %s -X '-L %f'"
                OPCTech exporttype
                fix(1000 * xCoord(origin)) fix(1000 * yCoord(origin))
                args
                OPCSettingsForm->OPCSettingsLabelSize->value
            )
        else
            OPCArgs = lsprintf(
                "--technology %s --export %s --ignore-malformed-shapes --resolve-path-extensions %s -X '-L %f'"
                OPCTech exporttype
                args
                OPCSettingsForm->OPCSettingsLabelSize->value
            )
    )
    when(groupname
        OPCArgs = lsprintf("%s -X '-g -n %s'" OPCArgs groupname)
    )
    when(OPCSettingsForm->OPCSettingsDebugCall->value == "true"
        OPCArgs = lsprintf("%s --debug-cell" OPCArgs)
    )
    when(OPCSettingsForm->OPCCellEnvironmentFile->value != ""
        OPCArgs = lsprintf("%s --cell-environment %s" OPCArgs OPCSettingsForm->OPCCellEnvironmentFile->value)
    )
    when(OPCSettingsForm->OPCSettingsEnableDprint->value == "true"
        OPCArgs = lsprintf("%s --enable-dprint --redirect-dprint %s" OPCArgs OPCSettingsForm->OPCDprintFilename->value)
    )
    when(OPCSettingsForm->OPCSettingsEnableFallbackVias->value == "true"
        OPCArgs = lsprintf("%s --enable-fallback-vias" OPCArgs)
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
    OPCArgs = lsprintf("%s %s" OPCArgs OPCSettingsForm->OPCSettingsCmdAdditionalArgs->value)
    when(OPCSettingsForm->OPCSettingsMerge->value == "true"
        OPCArgs = lsprintf("%s --merge-rectangles" OPCArgs)
    )
    OPCArgs
) ; OPCPrepareArgsForCellCreation

procedure(OPCBuildCallCommand(args)
    lsprintf("%s/%s %s" OPCPath OPCExec args)
) ; OPCBuildCallCommand

procedure(OPCCall(OPCCommand @key (redirect nil))
    let(
        (pid exitstatus errmsg)
        when(redirect
            OPCCommand = lsprintf("%s > %s" OPCCommand redirect)
        )
        when(OPCSettingsForm->OPCSettingsLog->value == "true"
            printf("opc call: %s\n" OPCCommand)
        )
        pid = ipcBeginProcess(OPCCommand)
        ipcWait(pid 30 OPCSettingsForm->OPCSettingsTimeout->value) ; wait for process to finish
        if(ipcIsAliveProcess(pid)
            then
                ; opc timed-out, kill
                ipcKillProcess(pid)
                hiDisplayAppDBox(
                    ?name        'OPCInfoDialog
                    ?dboxBanner  "openPCells"
                    ?dboxText    lsprintf("opc call took too long and was killed. The time-out length (current value: %d seconds) can be set in the opc setttings form" OPCSettingsForm->OPCSettingsTimeout->value)
                    ?dialogType   hicWarningDialog
                    ?dialogStyle 'modeless
                    ?buttonLayout 'Close
                )
                nil
            else
                exitstatus = ipcGetExitStatus(pid)
                if(exitstatus != 0
                    then
                        warn("opc call failed, command was: %s\n" OPCCommand)
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
        ) ; if is alive
    ) ; let
) ; OPCCall

procedure(OPCAuxCall(args)
    let(
        (cmd)
        cmd = OPCBuildCallCommand(args)
        when(OPCSettingsForm->OPCSettingsLog->value == "true"
            printf("opc call: %s\n" cmd)
        )
        system(cmd)
    ) ; let
) ; OPCAuxCall

procedure(OPCAuxCallResults(args)
    let(
        (cmd pid exitstatus)
        cmd = OPCBuildCallCommand(args)
        when(OPCSettingsForm->OPCSettingsLog->value == "true"
            printf("opc call: %s\n" cmd)
        )
        pid = ipcBeginProcess(cmd)
        ipcWait(pid 1 1)
        exitstatus = ipcGetExitStatus(pid)
        if(exitstatus != 0
            then
                let(
                    (errmsg)
                    errmsg = ipcReadProcess(pid)
                    warn("opc call (%s) failed:, error message was: %s\n" cmd errmsg)
                ) ; let
            else
                ipcReadProcess(pid)
        )
    ) ; let
) ; OPCAuxCallResults

procedure(OPCCleanUp(filename)
    when(OPCSettingsForm->OPCSettingsDeleteFile->value == "true"
        when(isFile(filename)
            deleteFile(filename)
        )
    )
) ; OPCCleanUp

