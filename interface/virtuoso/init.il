procedure(OPCcreateCell(w done pts)
    let(
        (
            (path "/home/pschulz/path/opc")
            (tech "cmos22fdsoi")
            (interface "virtuoso")
            (filename "openPCells")
            (origin car(pts))
            args command pid exitstatus 
        )
        when(done
	        args = ""
            foreach(field OPCParamForm->fieldList
                args = lsprintf("%s %s" args lsprintf("%s=%g" field get(OPCParamForm field)->value))
            )
            ; 'cell' is defined one level above (in OPCplaceCell)
	        command = lsprintf(
                "%s -T %s -I %s -C %s --origin '(%d, %d)' -f %s %s" 
                path tech interface cell 
                fix(1000 * xCoord(origin)) fix(1000 * yCoord(origin)) 
                filename args
            )
            println(command)
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
        ) ; when done
    )
) ; OPCcreateCell

procedure(OPCplaceCell(cell)
    OPCCreateOptionsForm(cell)
	enterPoint(
		?prompts list("Enter origin")
		?doneProc "OPCcreateCell"
        ?form OPCParamForm
        ?alwaysMap t
	)
) ; OPCplaceCell

procedure(OPCLayoutAddMenu(args)
    let( 
        (
            (win args->window) 
            utilityitem
            passiveitem
            transistoritem
            menu
        )
        
        ; utilities
        let(
            (
                guardringitem utilitysubmenu
            )
            guardringitem = hiCreateMenuItem( ?name 'OPCmenuguardring ?itemText "Guardring"
                ?callback "OPCplaceCell(\"guardring\")"
            )
            utilitysubmenu = hiCreatePulldownMenu('OPCLayoutUtilitySubMenu "" list(guardringitem))
            utilityitem = hiCreateSliderMenuItem( ?name 'OPCUtilityMenuItem ?itemText "Utility Components" ?subMenu utilitysubmenu)
        )
        ; passives
        let(
            (
                momcapitem cinductoritem oinductoritem sinductoritem passivesubmenu
            )
            momcapitem = hiCreateMenuItem( ?name 'OPCmenumomcap ?itemText "Momcap"
                ?callback "OPCplaceCell(\"momcap\")"
            )
            cinductoritem = hiCreateMenuItem( ?name 'OPCmenucinductor ?itemText "Circular Inductor"
                ?callback "OPCplaceCell(\"circular_inductor\")"
            )
            oinductoritem = hiCreateMenuItem( ?name 'OPCmenuoinductor ?itemText "Octagonal Inductor"
                ?callback "OPCplaceCell(\"octagonal_inductor\")"
            )
            sinductoritem = hiCreateMenuItem( ?name 'OPCmenusinductor ?itemText "Spiral Inductor"
                ?callback "OPCplaceCell(\"spiral_inductor\")"
            )
            passivesubmenu = hiCreatePulldownMenu('OPCLayoutPassiveSubMenu "" list(momcapitem cinductoritem oinductoritem sinductoritem))
            passiveitem = hiCreateSliderMenuItem( ?name 'OPCPassiveMenuItem ?itemText "Passive Components" ?subMenu passivesubmenu)
        )

        ; transistor
        transistoritem = hiCreateMenuItem( ?name 'OPCmenutransistor ?itemText "Transistor"
            ?callback "OPCplaceCell(\"transistor\")"
        )
        
        ; create a menu that includes the menu items
        menu = hiCreatePulldownMenu('OPCLayoutMenu "OpenPCells" list(transistoritem passiveitem))
        
        ; insert this menu as the last menu
        hiInsertBannerMenu(win menu length(hiGetBannerMenus(win)))
    );let
); procedure

procedure(OPCCreateOptionsForm(cell)
    let(
        (
            (path "/home/pschulz/path/opc")
            (filename "openPCells")
            command pid exitstatus result
            name type fieldlist field (i 0)
        )
        command = lsprintf("%s -P -C %s" path cell)
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
                foreach(line parseString(result "\n")
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
                        ("boolean"
                            field = hiCreateToggleField(
                                ?name stringToSymbol(lsprintf("%s_togglefield" name))
                                ?choices list(list(stringToSymbol(name)))
                                ?prompt name
                            )
                            fieldlist = cons(list(field 0:30*i 200:30 120) fieldlist)
                            i = i + 1
                        )
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
deRegUserTriggers("maskLayout" nil nil 'OPCLayoutAddMenu)
deRegUserTriggers("maskLayoutXL" nil nil 'OPCLayoutAddMenu)
deRegUserTriggers("maskLayoutGXL" nil nil 'OPCLayoutAddMenu)
