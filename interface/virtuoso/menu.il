procedure(OPCCreateLayoutMenu()
    let( (menu itemlist about separator edit update script export settings cellmenu cellitem)
        ; basic information
        about = hiCreateMenuItem(?name 'OPCAbout ?itemText "About" ?callback "OPCAboutCallback()")

        separator = hiCreateSeparatorMenuItem(?name 'OPCLayoutMenuSeparator)

        ; update design
        edit = hiCreateMenuItem(?name 'OPCEditCellScript ?itemText "Edit Design" ?callback "OPCEditCallback()")
        updatehierarchical = hiCreateMenuItem(?name 'OPCCellScriptHierarchical ?itemText "Update Design (Hierarchy)" ?callback "OPCUpdateCallback(?hierarchical t)")
        updateflat = hiCreateMenuItem(?name 'OPCCellScriptFlat ?itemText "Update Design (flat)" ?callback "OPCUpdateCallback(?hierarchical nil)")
        updatehierarchicalold = hiCreateMenuItem(?name 'OPCCellScriptHierarchicalOld ?itemText "Update Design (Hierarchy, reuse existing file)" ?callback "OPCUpdateCallback(?callopc nil ?hierarchical t)")
        updateflatold = hiCreateMenuItem(?name 'OPCCellScriptFlatOld ?itemText "Update Design (flat, reuse existing file)" ?callback "OPCUpdateCallback(?callopc nil ?hierarchical nil)")
        remove = hiCreateMenuItem(?name 'OPCCellScriptRemove ?itemText "Delete Design File" ?callback "OPCDeleteDesignFile()")

        ; export cell
        export = hiCreateMenuItem(?name 'OPCExport ?itemText "Export Cell" ?callback "OPCExportCell(nil)")

        ; backup
        ;backup = hiCreateMenuItem(?name 'OPCBackup ?itemText "Backup Cell" ?callback "OPCCreateCellBackup()")

        ; restore backup
        ;restorebackup = hiCreateMenuItem(?name 'OPCRestoreBackup ?itemText "Restore Backup" ?callback "OPCRestoreCellBackup()")

        ; create cell
        cellitem = hiCreateMenuItem(?name 'OPCCellItem ?itemText "Create Cell" ?callback "OPCPlaceCell()")
        settings = hiCreateMenuItem(?name 'OPCSettings ?itemText "Settings" ?callback "OPCSettingsCallback()")

        ; assemble main menu
        ;itemlist = list(about separator edit updatehierarchical updateflat backup restorebackup separator separator export separator cellitem separator settings)
        itemlist = list(about separator edit updatehierarchical updateflat updatehierarchicalold updateflatold remove separator export separator cellitem separator settings)
        hiCreatePulldownMenu('OPCLayoutMenu "OpenPCells" itemlist)
    )
)

procedure(OPCMenuTrigger(args)
    let((menu)
        menu = OPCCreateLayoutMenu()
        ; check initial editable flag
        when(boundp('OPCLayoutMenu)
            if(geGetEditCellView()->mode == "a"
                then
                    hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptHierarchical->hiMenuItemSym)
                    hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptFlat->hiMenuItemSym)
                    hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellItem->hiMenuItemSym)
                else
                    hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptHierarchical->hiMenuItemSym)
                    hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptFlat->hiMenuItemSym)
                    hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellItem->hiMenuItemSym)
            )
        )
        list(menu)
    )
)

procedure(OPCModeChangeTrigger(args)
    when(boundp('OPCLayoutMenu)
        if(args->action == 'change
            then
                if(args->accessMode == "a"
                    then
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptHierarchical->hiMenuItemSym)
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptFlat->hiMenuItemSym)
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptHierarchicalOld->hiMenuItemSym)
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptFlatOld->hiMenuItemSym)
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellItem->hiMenuItemSym)
                    else
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptHierarchical->hiMenuItemSym)
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptFlat->hiMenuItemSym)
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptHierarchicalOld->hiMenuItemSym)
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptFlatOld->hiMenuItemSym)
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellItem->hiMenuItemSym)
                )
            else
                if(geGetEditCellView()->mode == "a"
                    then
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptHierarchical->hiMenuItemSym)
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptFlat->hiMenuItemSym)
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptHierarchicalOld->hiMenuItemSym)
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptFlatOld->hiMenuItemSym)
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellItem->hiMenuItemSym)
                    else
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptHierarchical->hiMenuItemSym)
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptFlat->hiMenuItemSym)
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptHierarchicalOld->hiMenuItemSym)
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScriptFlatOld->hiMenuItemSym)
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellItem->hiMenuItemSym)
                )
        )
    )
)

; create a user postinstall trigger that automatically adds the menu
foreach(layoutTier list("maskLayoutL" "maskLayoutXL" "maskLayoutEXL" "maskLayoutGXL")
    when(member(layoutTier deGetAllViewTypes())
        deRegUserTriggers(layoutTier nil 'OPCMenuTrigger 'OPCModeChangeTrigger)
    )
)
