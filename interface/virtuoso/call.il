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
)

procedure(OPCPrepareArgsForCellCreation(args @key (groupname nil) (exporttype "SKILL"))
    ; the SKILL export currently does not properly handle path extensions
    ; therefore, path extensions are being resolved by opc
    OPCArgs = lsprintf("--technology %s --export %s --resolve-path-extensions %s -X '-L %f'" OPCTech exporttype args OPCSettingsForm->OPCSettingsLabelSize->value)
    when(groupname
        OPCArgs = lsprintf("%s -X '-g -n %s'" OPCArgs groupname)
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
)

procedure(OPCBuildCallCommand(args)
    lsprintf( "%s/%s %s %s" OPCPath OPCExec args additionalargs)
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
        ipcWait(pid 30 300) ; wait for process to finish
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

