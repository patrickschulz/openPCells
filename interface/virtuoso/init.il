procedure(OPCCreateCell(w done pts)
    let(
        (
            (OPCFilename "openPCells")
            (OPCOrigin car(pts))
            (cv geGetEditCellView())
            OPCArgs OPCCommand pid exitstatus 
        )
        when(done
            if(cv->mode == "a" || cv->mode == "w" ; check if cell is open for editing
            	then
                    OPCArgs = ""
	                foreach(field OPCParamForm->fieldList
	                    unless(get(OPCParamForm field)->value == get(OPCParamForm field)->defValue
	                        OPCArgs = lsprintf("%s %s" OPCArgs lsprintf("%s=%A" field get(OPCParamForm field)->value))
	                    )
	                )
	                ; 'OPCCell' is defined one level above (in OPCPlaceCell)
	                OPCCommand = lsprintf(
	                    "%s/%s --technology %s --export SKILL --cell %s --origin '(%d, %d)' -f %s %s" 
	                    OPCPath OPCExec OPCTech OPCCell 
	                    fix(1000 * xCoord(OPCOrigin)) fix(1000 * yCoord(OPCOrigin)) 
	                    OPCFilename OPCArgs
	                )
	                printf("calling opc:\n  %s\n" OPCCommand)
	                pid = ipcBeginProcess(OPCCommand)
	                ipcWait(pid) ; wait for process to finish
	                exitstatus = ipcGetExitStatus(pid)
	                if(exitstatus != 0
	                    then 
	                        printf("generator exited with status %d. Message:" exitstatus)
	                        printf("%s" ipcReadProcess(pid))
	                    else
	                        load(lsprintf("%s.il" OPCFilename))
                            deleteFile(lsprintf("%s.il" OPCFilename)) ; clean up after ourselves
	                ) ; if exitstatus
	        	else 
	        		println("cellview not in editing mode")
            ) ; if mode == "a"
        ) ; when done
    )
) ; OPCCreateCell

procedure(OPCPlaceCell(OPCCell)
    OPCCreateOptionsForm(OPCCell)
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
    ) ; let
) ; procedure

procedure(OPCAboutCallback()
    let(
        (OPCAboutForm)
        OPCAboutForm = hiCreateAppForm(
            ?name 'OPCAboutForm
            ?formTitle "openPCells About"
            ?buttonLayout 'OKCancel
            ?fields list(
                hiCreateHypertextField(
                    ?name 'OPCHTMLField 
                    ?title ""
                    ?value "<div style=\"text-align:center\"><h1>openPCells &ndash; A framework for open layout cell generators</h1><p>openPCells (opc) 0.1.0 &ndash; &copy;Patrick Kurth 2020&ndash;2021</p><A href=https://github.com/patrickschulz/openPCells>Website</A>" 
                )
            )
        )
        hiDisplayForm(OPCAboutForm 100:100)
    )
) ; procedure

procedure(OPCLayoutAddMenu(args)
    let( (menu itemlist about separator script settings cellmenu cellitem (win args->window))
        ; basic information
        about = hiCreateMenuItem(?name 'OPCAbout ?itemText "About" ?callback "OPCAboutCallback()")
        separator = hiCreateSeparatorMenuItem(?name 'OPCLayoutMenuSeparator)

        ; execute script
        script = hiCreateMenuItem(?name 'OPCScript ?itemText "Execute Script..." ?callback "OPC call script not yet implemented")

        ; create cell menu
        cellmenu = hiCreatePulldownMenu(
            'OPCCellMenu
            "foobar"
            OPCWalkCellDir(lsprintf("%s/cells" OPCPath) "")
        )
        cellitem = hiCreateSliderMenuItem(?name 'OPCCellItem ?itemText "Create Cell..." ?subMenu cellmenu)
        settings = hiCreateMenuItem(?name 'OPCSettings ?itemText "Settings" ?callback "println(\"openPCells Settings\")")

        ; assemble main menu
        itemlist = list(about separator script separator cellitem settings)
        menu = hiCreatePulldownMenu('OPCLayoutMenu "OpenPCells" itemlist)
        hiInsertBannerMenu(win menu length(hiGetBannerMenus(win)))
    )
); procedure

procedure(OPCCreateOptionsForm(OPCCell)
    let(
        (
            OPCCommand pid exitstatus result
            fieldlist field (i 0)
        )
        OPCCommand = lsprintf("%s/%s --machine --technology %s --parameters --separator ';' --cell %s" OPCPath OPCExec OPCTech OPCCell)
        println(OPCCommand)
        pid = ipcBeginProcess(OPCCommand)
        ipcWait(pid) ; wait for process to finish
        exitstatus = ipcGetExitStatus(pid)
        result = ipcReadProcess(pid)
        if(exitstatus != 0
            then 
                printf("generator exited with status %d. Message:" exitstatus)
                printf("%s" result)
            else
                let(
                    (linelist ptype name display default vtype)
                    foreach(line parseString(result ";")
                        linelist = parseString(line ":")
                        ptype   =                 car(linelist)
                        name    =             car(cdr(linelist))
                        display =         car(cdr(cdr(linelist)))
                        default =     car(cdr(cdr(cdr(linelist))))
                        vtype    = car(cdr(cdr(cdr(cdr(linelist)))))
                        when(display == "_NONE_"
                            display = name
                        )
                        case(vtype
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
