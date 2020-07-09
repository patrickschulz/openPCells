procedure(OPCcreateCell(w done pts)
    let(
        (
            (path "/home/pschulz/path/main.lua")
            (origin car(pts))
            args command pid filename file
            state lpp pts exitstatus
        )
        when(done
        	println(origin)
	        args = lsprintf("%.1f" 1.0)
	        command = lsprintf("lua %s %s %s" path cell args)
	        println(command)
	        pid = ipcBeginProcess(command)
	        ipcWait(pid) ; wait for process to finish
	        exitstatus = ipcGetExitStatus(pid)
	        if(exitstatus != 0
	            then 
	                printf("generator exited with status %d" exitstatus)
	            else
	                filename = ipcReadProcess(pid)
	                println(filename)
	                file = infile(filename)
	                state = "header"
	                when(file
	                    while(line = gets(nil file)
	                        if(line == "\n"
	                            then
	                                state = "endshape"
	                                pts = mapcar(lambda( (pt) xCoord(pt) + xCoord(origin):yCoord(pt) + yCoord(origin)) pts)
	                                dbCreatePolygon(geGetEditCellView() lpp pts)
	                                pts = nil ; reset points
	                                state = "header"
	                            else
	                                when(state == "points"
	                                    pts = cons(linereadstring(line) pts)
	                                )
	                                when(state == "header"
	                                    lpp = parseString(line)
	                                    state = "points"
	                                )
	                        )
	                    )
	                )
	        ) ; when status
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
            (win args->window) deviceitem menu
        )
        
        /*
        ; create the menu items
        coloritem = hiCreateMenuItem( ?name 'item4 ?itemText "Lock all colored shapes"
            ?callback "OPCHiLayoutLockColors()"
        )
        flattenitem = hiCreateMenuItem( ?name 'item5 ?itemText "Flatten all PCells..."
            ?callback "flattenPycells()"
        )
        labelitem = hiCreateMenuItem( ?name 'item6 ?itemText "Create Bus Labels..."
            ?callback "OPCHiLayoutCreateBusLabels()"
        )
        groundmeshitem = hiCreateMenuItem( ?name 'item7 ?itemText "Place Groundmesh..."
            ?callback "OPCHiLayoutCreateGroundmesh()"
        )
        fillcellitem = hiCreateMenuItem( ?name 'item8 ?itemText "Place Filling..."
            ?callback "OPCHiLayoutCreateFillcell()"
        )

        ; shape menu
        let(
            (
                circleitem ellipseitem donutitem
            )
            circleitem = hiCreateMenuItem( ?name 'circleitem ?itemText "Create Circle..."
                ?callback "OPCHiLayoutCreateCircle()"
            )
            ellipseitem = hiCreateMenuItem( ?name 'ellipseitem ?itemText "Create Ellipse..."
                ?callback "OPCHiLayoutCreateEllipse()"
            )
            donutitem = hiCreateMenuItem( ?name 'donutitem ?itemText "Create Donut..."
                ?callback "OPCHiLayoutCreateDonut()"
            )
            shapesubmenu = hiCreatePulldownMenu('OPCLayoutShapeSubMenu "" list(circleitem ellipseitem donutitem))
            shapeitem = hiCreateSliderMenuItem( ?name 'OPCShapeMenuItem ?itemText "Create Shape" ?subMenu shapesubmenu)
        )

        ; device menu
        let(
            (
                tlineitem inductoritem devicesubmenu
            )
            tlineitem = hiCreateMenuItem( ?name 'tlineitem ?itemText "Create Transmission Line..."
                ?callback "OPCHiLayoutCreateTransmissionLine()"
            )
            inductoritem = hiCreateMenuItem( ?name 'inductoritem ?itemText "Create Inductor..."
                ?callback "OPCHiLayoutCreateInductor()"
            )
            devicesubmenu = hiCreatePulldownMenu('OPCLayoutDeviceSubMenu "" list(tlineitem inductoritem))
            deviceitem = hiCreateSliderMenuItem( ?name 'OPCDeviceMenuItem ?itemText "Create Device" ?subMenu devicesubmenu)
        )
        */
        transistoritem = hiCreateMenuItem( ?name 'OPCmenutransistor ?itemText "Add Transistor"
            ?callback "OPCplaceCell(\"transistor\")"
        )
        momcapitem = hiCreateMenuItem( ?name 'OPCmenumomcap ?itemText "Add Momcap"
            ?callback "OPCplaceCell(\"momcap\")"
        )
        inductoritem = hiCreateMenuItem( ?name 'OPCmenuinductor ?itemText "Add Symmetric Inductor"
            ?callback "OPCplaceCell(\"symmetric_inductor\")"
        )
        
        ; create a menu that includes the menu items
        menu = hiCreatePulldownMenu('OPCLayoutMenu "OpenPCells" list(transistoritem momcapitem inductoritem))
        
        ; insert this menu as the last menu
        hiInsertBannerMenu(win menu length(hiGetBannerMenus(win))) ; install the menu last (before "help")
    );let
); procedure

; create a user postinstall trigger that automatically adds the menu
deRegUserTriggers("maskLayout" nil nil 'OPCLayoutAddMenu)
deRegUserTriggers("maskLayoutXL" nil nil 'OPCLayoutAddMenu)
deRegUserTriggers("maskLayoutGXL" nil nil 'OPCLayoutAddMenu)
