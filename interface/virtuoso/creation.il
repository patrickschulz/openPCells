procedure(OPCCreateCellInternal(@optional (origin 0:0))
    let(
        (
            (pfile outfile(OPCSettingsForm->OPCPfileFilename->value))
            (parametertable makeTable("opcparamtable"))
            parent name
            OPCArgs OPCCmd
        )
        ; collect parameters
        foreach(field OPCCellForm->fieldList
            name = get(OPCCellForm->fieldNames field)
            parent = get(OPCCellForm->fieldParents field)
            when(parent ; protects against nil parents from separator fields
                unless(equal(field 'OPCLibList) || equal(field 'OPCCellList)
                    unless(tablep(parametertable[parent])
                        parametertable[parent] = makeTable(lsprintf("opc%stable" parent))
                    )
                    parametertable[parent][name] = lsprintf("%A" get(OPCCellForm field)->value)
                )
            )
        )
        ; assemble pfile
        fprintf(pfile "%s\n" "return {")
        foreach(p parametertable
            fprintf(pfile "    [\"%s\"] = {\n" p)
            foreach(pp parametertable[p]
                fprintf(pfile "        %s = %s,\n" pp parametertable[p][pp])
            )
            fprintf(pfile "    },\n" p)
        )
        fprintf(pfile "%s\n" "}")
        close(pfile)

        ; assemble call arguments
        OPCArgs = OPCPrepareArgsForCellCreation(lsprintf(
            "--cell %s --origin '(%d, %d)' -f %s --append-parameter-file %s -X -c"
            lsprintf("%s/%s" OPCCellForm->OPCLibList->value OPCCellForm->OPCCellList->value)
            fix(1000 * xCoord(origin)) fix(1000 * yCoord(origin)) 
            OPCSettingsForm->OPCCellFilename->value
            OPCSettingsForm->OPCPfileFilename->value
        ))
        ; call opc
        OPCCmd = OPCBuildCallCommand(OPCArgs)
        when(OPCCall(OPCCmd nil)
            if(isFile(lsprintf("%s.il" OPCSettingsForm->OPCCellFilename->value))
                then
                    load(lsprintf("%s.il" OPCSettingsForm->OPCCellFilename->value))
                    ;opcscratchshapes = cv->shapes
                    OPCCleanUp(lsprintf("%s.il" OPCSettingsForm->OPCCellFilename->value))
                else
                    hiDisplayAppDBox(
                        ?name        'OPCInfoDialog
                        ?dboxBanner  "openPCells"
                        ?dboxText    lsprintf("opc failed to generate '%s.il'" OPCSettingsForm->OPCCellFilename->value)
                        ?dialogType   hicWarningDialog
                        ?dialogStyle 'modeless
                        ?buttonLayout 'Close
                    )
            ) ; if
        )
        OPCCleanUp(OPCSettingsForm->OPCPfileFilename->value)
    )
) ; OPCCreateCellInternal

procedure(OPCCreateCell(w done pts)
    when(done
        OPCCreateCellInternal(car(pts))
    )
    t
) ; OPCCreateCell

procedure(OPCPlaceCell()
    /*
    let(
        (oldSnapMode oldSegSnapMode)
        ; display main OPC form, which takes care of creating the ghost shapes for dragging
        OPCUpdateCellShapeCB(nil nil)
        hiDisplayForm(OPCCellForm)

        ; store previous snap modes
        oldSnapMode = hiGetCurrentWindow()->snapMode 	
        oldSegSnapMode = hiGetCurrentWindow()->segSnapMode 	

        ; set snap modes
        hiGetCurrentWindow()->snapMode = "anyAngle"
        hiGetCurrentWindow()->segSnapMode = "anyAngle"

        ; display ghost object and get point
        res = geHiDragFig(geGetEditCellViewWindow(geGetEditCellView()) nil "" "Enter Destination Point" "Move" cv->shapes t list(0 0))
        pt = car(cdadr(res))

        ; copy shapes from scratch cell
        foreach(shape cv->shapes
            dbCopyShape(shape geGetEditCellView() list(pt "R0" 1))
        )
        ; restore previous snap modes
        hiGetCurrentWindow()->snapMode = oldSnapMode
        hiGetCurrentWindow()->segSnapMode = oldSegSnapMode

        dbPurge(dbOpenCellViewByType("testing" "__opctempcell__" "layout" "maskLayout" "s"))
    )
    */
    enterPoint(
        ?prompts list("Enter origin")
        ?doneProc "OPCCreateCell"
        ?form OPCCellForm
        ?alwaysMap nil
    )
) ; OPCPlaceCell

