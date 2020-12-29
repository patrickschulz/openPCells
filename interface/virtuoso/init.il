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
        	println("done")
            if(cv->mode == "a" ; check if cell is open for editing
            	then
	                args = ""
	                foreach(field OPCParamForm->fieldList
	                    unless(get(OPCParamForm field)->value == get(OPCParamForm field)->defValue
	                        args = lsprintf("%s %s" args lsprintf("%s=%A" field get(OPCParamForm field)->value))
	                    )
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
	        	else 
	        		println("cellview not in editing mode")
            ) ; if mode == "a"
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
                        unless(substring(file 1 1) == "_"
                            item = hiCreateMenuItem( 
                                ?name stringToSymbol(substring(file 1 strlen(file) - 4)) 
                                ?itemText substring(file 1 strlen(file) - 4)
                                ?callback lsprintf("OPCPlaceCell(\"%s%s\")" prepend substring(file 1 strlen(file) - 4))
                            )   
                            itemlist = cons(item itemlist)
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
                            itemlist = cons(item itemlist)
                        )
                )
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
            fieldlist field (i 0)
        )
        command = lsprintf("%s --parameters --separator ';' --cell %s" path cell)
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
                let(
                    (linelist name display default type)
                    foreach(line parseString(result ";")
                        linelist = parseString(line ":")
                        name    =    car(linelist)
                        display =   cadr(linelist)
                        default =  caddr(linelist)
                        type    = cadddr(linelist)
                        when(display == "_NONE_"
                            display = name
                        )
                        case(type
                            ("number"
                                field = hiCreateFloatField(
                                    ?name stringToSymbol(name)
                                    ?value atof(default)
                                    ?prompt display
                                )
                            )
                            ("integer"
                                field = hiCreateIntField(
                                    ?name stringToSymbol(name)
                                    ?value atoi(default)
                                    ?prompt display
                                )
                            )
                            ("boolean"
                                field = hiCreateRadioField(
                                    ?name stringToSymbol(name)
                                    ?choices list("true" "false")
                                    ?value default
                                    ?prompt display
                                )
                            )
                            ("string"
                                field = hiCreateStringField(
                                    ?name stringToSymbol(name)
                                    ?value default
                                    ?prompt display
                                )
                            )
                            ("numtable"
                                field = hiCreateStringField(
                                    ?name stringToSymbol(name)
                                    ?value default
                                    ?prompt display
                                )
                            )
                            ("strtable"
                                field = hiCreateStringField(
                                    ?name stringToSymbol(name)
                                    ?value default
                                    ?prompt display
                                )
                            )
                        )
                        fieldlist = cons(list(field 0:30*i 350:30 250) fieldlist)
                        i = i + 1
                    )
                    ;if(boundp('OPCParamForm)
                    ;    hiDeleteForm(OPCParamForm)
                    ;)
                ) ; let
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
