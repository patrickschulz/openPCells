procedure(OPCCreateLayoutMenu()
    let(
        (
            menu
            itemlist
            about
            SEP
            export
            settings
            editconfig
            viewlog
            designmenu
            subcellmenu
            cellmenu
            fillmenu
        )
        ; basic information
        about = hiCreateMenuItem(?name 'OPCAbout ?itemText "About" ?callback "OPCAboutCallback()")

        SEP = hiCreateSeparatorMenuItem(?name 'OPCLayoutMenuSeparator)

        ; design
        let(
            (
                edit
                updatehierarchical
                updateflat
                remove
                designmenupulldown
            )
            edit = hiCreateMenuItem(?name 'OPCEditCellScript ?itemText "Edit Design" ?callback "OPCEditCallback()")
            updatehierarchical = hiCreateMenuItem(?name 'OPCCellScriptHierarchical ?itemText "Update Design (Hierarchy)" ?callback "OPCUpdateCellscriptCallback(?hierarchical t)")
            updateflat = hiCreateMenuItem(?name 'OPCCellScriptFlat ?itemText "Update Design (flat)" ?callback "OPCUpdateCellscriptCallback(?hierarchical nil)")
            remove = hiCreateMenuItem(?name 'OPCCellScriptRemove ?itemText "Delete Design File" ?callback "OPCDeleteDesignFile()")
            designmenupulldown = hiCreatePulldownMenu('OPCDesignMenuPulldown "" list(edit updatehierarchical updateflat remove))
            designmenu = hiCreateSliderMenuItem(?name 'OPCDesignMenu ?itemText "Design" ?subMenu designmenupulldown)
        )

        ; sub cells
        let(
            (
                createsubcellscript
                createsubcellcell
                editsubcellscript
                updatesubcell
                cleanupsubcell
                subcellmenupulldown
            )
            createsubcellscript = hiCreateMenuItem(?name 'OPCCreateSubCellScript ?itemText "Create Sub-Cell (Cell Script)" ?callback "OPCSubCellCreateScript()")
            createsubcellcell = hiCreateMenuItem(?name 'OPCCreateSubCellCell ?itemText "Create Sub-Cell (Cell)" ?callback "OPCSubCellCreateCell()")
            editsubcellscript = hiCreateMenuItem(?name 'OPCEditSubCellScript ?itemText "Edit Sub-Cell Script" ?callback "OPCSubCellEditScript()")
            updatesubcell = hiCreateMenuItem(?name 'OPCSubCellScript ?itemText "Update Sub-Cell" ?callback "OPCSubCellUpdate()")
            cleanupsubcell = hiCreateMenuItem(?name 'OPCSubCellCleanUp ?itemText "Delete Unused Sub-Cell Scripts" ?callback "OPCSubCellCleanUp()")
            subcellmenupulldown = hiCreatePulldownMenu('OPCSubCellMenuPulldown "" list(createsubcellscript createsubcellcell editsubcellscript updatesubcell))
            subcellmenu = hiCreateSliderMenuItem(?name 'OPCSubCellMenu ?itemText "Sub-Cells" ?subMenu subcellmenupulldown)
        )

        ; specific cells
        let(
            (
                mosfet
                guardring
                metalgrid
                cellmenupulldown
            )
            mosfet = hiCreateMenuItem(?name 'OPCCreateMosfet ?itemText "Create MOSFET" ?callback "OPCCreateMosfet()")
            guardring = hiCreateMenuItem(?name 'OPCCreateGuardring ?itemText "Create Guardring" ?callback "OPCCreateGuardring()")
            metalgrid = hiCreateMenuItem(?name 'OPCCreateMetalgrid ?itemText "Create Metal Grid" ?callback "OPCCreateMetalgrid()")
            cellmenupulldown = hiCreatePulldownMenu('OPCCellMenuPulldown "" list(mosfet guardring metalgrid))
            cellmenu = hiCreateSliderMenuItem(?name 'OPCCellMenu ?itemText "Cells" ?subMenu cellmenupulldown)
        )

        ; export cell
        export = hiCreateMenuItem(?name 'OPCExport ?itemText "Export Cell" ?callback "OPCHiExportCell(nil)")

        ; fill cell
        let(
            (
                editfillscript
                runfillscript
                deletefillgroup
                deletefillscript
                fillmenupulldown
            )
            editfillscript = hiCreateMenuItem(?name 'OPCEditFillScript ?itemText "Edit Fill Script" ?callback "OPCFillEditScript()")
            runfillscript = hiCreateMenuItem(?name 'OPCFillScriptRun ?itemText "Run Fill Script" ?callback "OPCUpdateFillCallback()")
            deletefillgroup = hiCreateMenuItem(?name 'OPCFillDeleteGroup ?itemText "Delete Fill Shapes" ?callback "OPCDeleteFillGroup()")
            deletefillscript = hiCreateMenuItem(?name 'OPCFillScriptDelete ?itemText "Delete Fill Script" ?callback "OPCDeleteFillScript()")
            fillmenupulldown = hiCreatePulldownMenu('OPCFillMenuPulldown "" list(editfillscript runfillscript deletefillgroup deletefillscript))
            fillmenu = hiCreateSliderMenuItem(?name 'OPCFillMenu ?itemText "Fill" ?subMenu fillmenupulldown)
        )

        ; backup
        ;backup = hiCreateMenuItem(?name 'OPCBackup ?itemText "Backup Cell" ?callback "OPCCreateCellBackup()")

        ; restore backup
        ;restorebackup = hiCreateMenuItem(?name 'OPCRestoreBackup ?itemText "Restore Backup" ?callback "OPCRestoreCellBackup()")

        ; settings
        settings = hiCreateMenuItem(?name 'OPCSettings ?itemText "Settings" ?callback "OPCSettingsCallback()")
        editconfig = hiCreateMenuItem(?name 'OPCEditConfig ?itemText "Edit Configgile" ?callback "OPCEditConfigFile()")
        viewlog = hiCreateMenuItem(?name 'OPCViewLogFile ?itemText "View Logfile" ?callback "OPCViewLogFile()")
        viewdprint = hiCreateMenuItem(?name 'OPCViewDPrintFile ?itemText "View Debug Print File" ?callback "OPCViewDPrintFile()")
        viewoutput = hiCreateMenuItem(?name 'OPCViewOutputFile ?itemText "View Output File" ?callback "OPCViewOutputFile()")

        ; assemble main menu
        itemlist = list(
            about
            SEP
            settings editconfig viewlog viewdprint viewoutput
            SEP
            designmenu
            SEP
            subcellmenu
            SEP
            cellmenu
            SEP
            fillmenu
            SEP
            export
        )
        hiCreatePulldownMenu('OPCLayoutMenu "OpenPCells" itemlist)
    )
)

procedure(OPCMenuTrigger(args)
    let((menu)
        menu = OPCCreateLayoutMenu()
        ; check initial editable flag
        ; FIXME: this was always buggy and now changed with the new menu structure
        /*
        when(boundp('OPCLayoutMenu)
            if(geGetEditCellView()->mode == "a"
                then
                    hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptHierarchical->hiMenuItemSym)
                    hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptFlat->hiMenuItemSym)
                    hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptHierarchicalOld->hiMenuItemSym)
                    hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptFlatOld->hiMenuItemSym)
                else
                    hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptHierarchical->hiMenuItemSym)
                    hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptFlat->hiMenuItemSym)
                    hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptHierarchicalOld->hiMenuItemSym)
                    hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptFlatOld->hiMenuItemSym)
            )
        )
        */
        list(menu)
    )
)

procedure(OPCModeChangeTrigger(args)
    ; FIXME: needs update after re-structuring menu
    /*
    when(boundp('OPCLayoutMenu)
        if(args->action == 'change
            then
                if(args->accessMode == "a"
                    then
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptHierarchical->hiMenuItemSym)
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptFlat->hiMenuItemSym)
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptHierarchicalOld->hiMenuItemSym)
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptFlatOld->hiMenuItemSym)
                    else
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptHierarchical->hiMenuItemSym)
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptFlat->hiMenuItemSym)
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptHierarchicalOld->hiMenuItemSym)
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptFlatOld->hiMenuItemSym)
                )
            else
                if(geGetEditCellView()->mode == "a"
                    then
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptHierarchical->hiMenuItemSym)
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptFlat->hiMenuItemSym)
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptHierarchicalOld->hiMenuItemSym)
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptFlatOld->hiMenuItemSym)
                    else
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptHierarchical->hiMenuItemSym)
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptFlat->hiMenuItemSym)
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptHierarchicalOld->hiMenuItemSym)
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptFlatOld->hiMenuItemSym)
                )
        )
    )
    */
    t
)

; create a user postinstall trigger that automatically adds the menu
foreach(layoutTier list("layout" "maskLayout" "maskLayoutL" "maskLayoutXL" "maskLayoutEXL" "maskLayoutGXL" "maskLayoutEAD")
    when(member(layoutTier deGetAllViewTypes())
        deRegUserTriggers(layoutTier nil 'OPCMenuTrigger 'OPCModeChangeTrigger)
    )
)

; vim: nowrap
