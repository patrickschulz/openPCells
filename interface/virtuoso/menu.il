procedure(OPCcreateCell(w done pts)
    let(
        (
            (path "/home/pschulz/path/opc")
            (tech "cmos22fdsoi")
            (interface "virtuoso")
            (origin car(pts))
            args command pid filename file
            state lpp pts exitstatus
        )
        when(done
	        args = lsprintf("%.1f" 1.0)
            ; 'cell' is defined one level above (in OPCplaceCell)
	        command = lsprintf("%s -T %s -I %s -C %s %s" path tech interface cell args)
	        pid = ipcBeginProcess(command)
	        ipcWait(pid) ; wait for process to finish
	        exitstatus = ipcGetExitStatus(pid)
	        if(exitstatus != 0
	            then 
	                printf("generator exited with status %d" exitstatus)
	            else
                    load("openPCells.il")
	        ) ; if exitstatus
        ) ; when done
    )
) ; OPCcreateCell

procedure(OPCplaceCell(cell)
	enterPoint(
		?prompts list("Enter origin")
		?doneProc "OPCcreateCell"
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

procedure(OPCCreateOptionsForm()
    let(
        (fieldlist field (i 0))
        foreach(name names
            field = hiCreateFloatField(
                ?name stringToSymbol(name)
                ?value 5.0
                ?prompt name
            )
            fieldlist = cons(list(field 0:30*i 200:30 120) fieldlist)
        )
        hiCreateAppForm(
            ?name 'OPCParamForm
            ?formType 'options
            ?formTitle "OPC Cell Parameters"
            ?buttonLayout 'HideCancelDef
            ?fields fieldlist
        )
    )
) ; procedure

; create a user postinstall trigger that automatically adds the menu
deRegUserTriggers("maskLayout" nil nil 'OPCLayoutAddMenu)
deRegUserTriggers("maskLayoutXL" nil nil 'OPCLayoutAddMenu)
deRegUserTriggers("maskLayoutGXL" nil nil 'OPCLayoutAddMenu)
