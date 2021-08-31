procedure(OPCCreateCellInternal(cv @optional (origin 0:0))
    let(
        (
            (pfile outfile(OPCSettingsForm->OPCPfileFilename->value))
            (parametertable makeTable("opcparamtable"))
            parent name
            OPCArgs
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
            "--cell %s --origin '(%d, %d)' -f %s --append-parameter-file %s"
            lsprintf("%s/%s" OPCCellForm->OPCLibList->value OPCCellForm->OPCCellList->value)
            fix(1000 * xCoord(origin)) fix(1000 * yCoord(origin)) 
            OPCSettingsForm->OPCCellFilename->value
            OPCSettingsForm->OPCPfileFilename->value
        ))
        ; call opc
        when(OPCCall(OPCArgs nil)
            if(isFile(lsprintf("%s.il" OPCSettingsForm->OPCCellFilename->value))
                then
                    load(lsprintf("%s.il" OPCSettingsForm->OPCCellFilename->value))
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
        OPCCreateCellInternal(geGetEditCellView() car(pts))
    )
    t
) ; OPCCreateCell

procedure(OPCCreateScratchCell(libname)
    let(
        ((cv dbOpenCellViewByType(libname "__opctempcell__" "layout" "maskLayout")))
        OPCCreateCellInternal(cv)
    )
) ; OPCCreateScratchCell

procedure(OPCPlaceCell()
	enterPoint(
		?prompts list("Enter origin")
		?doneProc "OPCCreateCell"
        ?form OPCCellForm
        ?alwaysMap t
	)
) ; OPCPlaceCell

