procedure(OPCCreateCellBackup()
    let(
        (
            (path lsprintf("%s/%s" getShellEnvVar("HOME") "opcbackups"))
        )
        unless(isDir(path)
            createDir(path)
        )
        let(
            (
                (cv geGetEditCellView())
            )
            OPCExportCell(lsprintf("%s/%s_%s.lua" path cv->libName cv->cellName))
        )
    )
) ; OPCCreateCellBackup

procedure(OPCRestoreCellBackup()
    let(
        (
            (path lsprintf("%s/%s" getShellEnvVar("HOME") "opcbackups"))
        )
        if(isDir(path)
            then
                let(
                    (
                        (cv geGetEditCellView())
                        filename
                    )
                    filename = lsprintf("%s/%s_%s.lua" path cv->libName cv->cellName)
                    if(isFile(filename)
                        then
                            OPCUpdateCellscriptCallback(filename ?hierarchical nil)
                        else
                            hiDisplayAppDBox(
                                ?name        'OPCInfoDialog
                                ?dboxBanner  "openPCells"
                                ?dboxText    lsprintf("no opc backup for this cell (%s) found" filename)
                                ?dialogType   hicWarningDialog
                                ?dialogStyle 'modeless
                                ?buttonLayout 'Close
                            )
                    )
                )
            else
        )
    )
) ; OPCRestoreCellBackup
