procedure(OPCCreateCell(w done pts)
    let(
        (
            (path "/home/pschulz/path/opc")
            (tech "cmos22fdsoi")
            (interface "virtuoso")
            (filename "openPCells")
            (origin car(pts))
            (cv geGetEditCellView())
            args command pid exitstatus 
        )
        when(done
            when(cv->mode == "a" ; check if cell is open for editing
                args = ""
                foreach(field OPCParamForm->fieldList
                    args = lsprintf("%s %s" args lsprintf("%s=%A" field get(OPCParamForm field)->value))
                )
                ; 'cell' is defined one level above (in OPCPlaceCell)
                command = lsprintf(
                    "%s --technology %s --interface %s --cell %s --origin '(%d, %d)' -f %s %s" 
                    path tech interface cell 
                    fix(1000 * xCoord(origin)) fix(1000 * yCoord(origin)) 
                    filename args
                )
                printf("calling opc:\n  %s\n" command)
                pid = ipcBeginProcess(command)
                ipcWait(pid) ; wait for process to finish
                exitstatus = ipcGetExitStatus(pid)
                if(exitstatus != 0
                    then 
                        printf("generator exited with status %d. Message:" exitstatus)
                        printf("%s" ipcReadProcess(pid))
                    else
                        load(lsprintf("%s.il" filename))
                ) ; if exitstatus
            ) ; when mode == "a"
        ) ; when done
    )
) ; OPCCreateCell

procedure(OPCPlaceCell(cell)
    OPCCreateOptionsForm(cell)
	enterPoint(
		?prompts list("Enter origin")
		?doneProc "OPCCreateCell"
        ?form OPCParamForm
        ?alwaysMap t
	)
) ; OPCPlaceCell

procedure(OPCWalkCellDir(path prepend)
    let(
        (itemlist item)
        foreach(file getDirFiles(path)
            unless(file == "." || file == ".."
                if(isFile(lsprintf("%s/%s" path file))
                    then
                        item = hiCreateMenuItem( 
                            ?name stringToSymbol(substring(file 1 strlen(file) - 4)) 
                            ?itemText substring(file 1 strlen(file) - 4)
                            ?callback lsprintf("OPCPlaceCell(\"%s%s\")" prepend substring(file 1 strlen(file) - 4))
                        )   
                    else
                        let((submenu)
                            submenu = hiCreatePulldownMenu(
                                stringToSymbol(lsprintf("OPCLayout%sSubMenu" lsprintf("%s%s/" prepend file))) "" 
                                OPCWalkCellDir(lsprintf("%s/%s" path file) lsprintf("%s%s/" prepend file))
                            )
                            item = hiCreateSliderMenuItem(
                                ?name stringToSymbol(file) 
                                ?itemText file
                                ?subMenu submenu
                            )
                        )
                )
                itemlist = cons(item itemlist)
            ) ; unless
        ) ; foreach
        itemlist
    ) ; lfet
) ; procedure

procedure(OPCLayoutAddMenu(args)
    let( (menu itemlist (win args->window))
        itemlist = OPCWalkCellDir("/home/pschulz/path/cells" "")
        menu = hiCreatePulldownMenu('OPCLayoutMenu "OpenPCells" itemlist)
        hiInsertBannerMenu(win menu length(hiGetBannerMenus(win)))
    )
); procedure

procedure(OPCCreateOptionsForm(cell)
    let(
        (
            (path "/home/pschulz/path/opc")
            (filename "openPCells")
            command pid exitstatus result
            name type fieldlist field (i 0)
        )
        command = lsprintf("%s -P --separator ';' --cell %s" path cell)
        println(command)
        pid = ipcBeginProcess(command)
        ipcWait(pid) ; wait for process to finish
        exitstatus = ipcGetExitStatus(pid)
        result = ipcReadProcess(pid)
        if(exitstatus != 0
            then 
                printf("generator exited with status %d. Message:" exitstatus)
                printf("%s" result)
            else
                foreach(line parseString(result ";")
                    name = car(parseString(line))
                    type = caddr(parseString(line))
                    default = cadr(parseString(line))
                    case(type
                        ("number"
                            field = hiCreateFloatField(
                                ?name stringToSymbol(name)
                                ?value atof(default)
                                ?prompt name
                            )
                            fieldlist = cons(list(field 0:30*i 200:30 120) fieldlist)
                            i = i + 1
                        )
                        ("integer"
                            ; integers also get floatFields (for now), since this make the 
                            ; assembly of the argument string (see above) easier
                            field = hiCreateFloatField(
                                ?name stringToSymbol(name)
                                ?value atof(default)
                                ?prompt name
                            )
                            fieldlist = cons(list(field 0:30*i 200:30 120) fieldlist)
                            i = i + 1
                        )
                        ;("boolean"
                        ;    field = hiCreateToggleField(
                        ;        ?name stringToSymbol(lsprintf("%s_togglefield" name))
                        ;        ?choices list(list(stringToSymbol(name)))
                        ;        ?prompt name
                        ;    )
                        ;    fieldlist = cons(list(field 0:30*i 200:30 120) fieldlist)
                        ;    i = i + 1
                        ;)
                        ("string"
                            field = hiCreateStringField(
                                ?name stringToSymbol(name)
                                ?value default
                                ?prompt name
                            )
                            fieldlist = cons(list(field 0:30*i 200:30 120) fieldlist)
                            i = i + 1
                        )
                    )
                )
                ;if(boundp('OPCParamForm)
                ;    hiDeleteForm(OPCParamForm)
                ;)
                hiCreateAppForm(
                    ?name 'OPCParamForm
                    ?formType 'options
                    ?formTitle "OPC Cell Parameters"
                    ?buttonLayout 'HideCancelDef
                    ?fields fieldlist
                )
        ) ; if exitstatus
    )
) ; procedure

; create a user postinstall trigger that automatically adds the menu
;deRegUserTriggers("maskLayout" nil nil 'OPCLayoutAddMenu)
deRegUserTriggers("maskLayoutXL" nil nil 'OPCLayoutAddMenu)
;deRegUserTriggers("maskLayoutGXL" nil nil 'OPCLayoutAddMenu)
