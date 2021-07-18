procedure(OPCCall(args)
    let(
        ((additionalargs ""))
        when(boundp('OPCSettingsForm)
            additionalargs = OPCSettingsForm->OPCSettingsCmdAdditionalArgs->value
        )
        OPCCommand = lsprintf(
            "%s/%s --technology %s --export SKILL %s %s"
            OPCPath OPCExec OPCTech additionalargs args
        )
        printf("calling opc:\n  %s\n" OPCCommand)
        pid = ipcBeginProcess(OPCCommand)
        ipcWait(pid) ; wait for process to finish
        exitstatus = ipcGetExitStatus(pid)
        if(exitstatus != 0
            then 
                printf("generator exited with status %d. Message:" exitstatus)
                printf("%s" ipcReadProcess(pid))
                nil
            else
                t
        ) ; if exitstatus
    ) ; let
)

procedure(OPCCleanUp()
    if(boundp('OPCSettingsForm)
        then
            println(OPCSettingsForm->OPCSettingsDeleteFile->value)
            when(OPCSettingsForm->OPCSettingsDeleteFile->value == "true"
                printf("opc: delete %s.il\n" OPCFilename)
                deleteFile(lsprintf("%s.il" OPCFilename))
            )
        else
            printf("opc: delete %s.il\n" OPCFilename)
            deleteFile(lsprintf("%s.il" OPCFilename))
    )
)

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
	                ; 'OPCCell' is defined one level above (in OPCPlaceCell)
	                OPCArgs = lsprintf(
	                    "--cell %s --origin '(%d, %d)' -f %s" 
	                    OPCCell 
	                    fix(1000 * xCoord(OPCOrigin)) fix(1000 * yCoord(OPCOrigin)) 
	                    OPCFilename
	                )
	                foreach(field OPCParamForm->fieldList
	                    unless(get(OPCParamForm field)->value == get(OPCParamForm field)->defValue
	                        OPCArgs = lsprintf("%s %s" OPCArgs lsprintf("%s=%A" field get(OPCParamForm field)->value))
	                    )
	                )
                    when(OPCCall(OPCArgs)
                        printf("opc: load %s.il\n" OPCFilename)
                        load(lsprintf("%s.il" OPCFilename))
                        OPCCleanUp()
                    )
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
            unless(pcreMatchp("^\\." file)
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

procedure(OPCEditCallback()
    letseq(
        (
            (cv geGetEditCellView())
            (libPath cv->lib->readPath)
            (cellName cv->cellName)
            (OPCFilename "openPCells")
            path OPCArgs
        )
        path = lsprintf("%s/%s/layout/layout.lua" libPath cellName)
        pid = ipcBeginProcess(lsprintf("xterm -e vim %s" path) "")
    )
) ; procedure

procedure(OPCUpdateCallback()
    letseq(
        (
            (cv geGetEditCellView())
            (libPath cv->lib->readPath)
            (cellName cv->cellName)
            (OPCFilename "openPCells")
            path OPCArgs
        )
        path = lsprintf("%s/%s/layout/layout.lua" libPath cellName)
        OPCArgs = lsprintf("--cellscript %s -f %s" path OPCFilename)
        when(OPCCall(OPCArgs)
            foreach(shape cv->shapes dbDeleteObject(shape))
            foreach(inst cv->instances dbDeleteObject(inst))
            printf("opc: load %s.il" OPCFilename)
            load(lsprintf("%s.il" OPCFilename))
            OPCCleanUp()
        )
    )
) ; procedure

procedure(OPCExportCell()
    let(
        (
            (cv geGetEditCellView())
            (file outfile("openPCells_export.lua" "w"))
        )
        fprintf(file "local cell = object.create()\n")
        foreach(shape cv->shapes
            OPCWriteShape(file shape 0 0)
        )
        foreach(inst cv->instances
            foreach(shape inst->master->shapes
                OPCWriteShape(file shape xCoord(inst->xy) yCoord(inst->xy))
            )
        )
        fprintf(file "return cell\n")
        close(file)
    )
)

procedure(OPCSettingsCallback()
    unless(boundp('OPCSettingsForm)
        OPCCreateSettingsForm()
    )
    hiDisplayForm(OPCSettingsForm 100:100)
) ; procedure

procedure(OPCCreateLayoutMenu()
    let( (menu itemlist about separator edit update script export settings cellmenu cellitem)
        ; basic information
        about = hiCreateMenuItem(?name 'OPCAbout ?itemText "About" ?callback "OPCAboutCallback()")

        separator = hiCreateSeparatorMenuItem(?name 'OPCLayoutMenuSeparator)

        ; update design
        edit = hiCreateMenuItem(?name 'OPCEditCellScript ?itemText "Edit Design" ?callback "OPCEditCallback()")
        update = hiCreateMenuItem(?name 'OPCCellScript ?itemText "Update Design (removes all shapes!)" ?callback "OPCUpdateCallback()")

        ; execute script
        script = hiCreateMenuItem(?name 'OPCScript ?itemText "Execute Script..." ?callback "OPC call script not yet implemented")

        ; export cell
        export = hiCreateMenuItem(?name 'OPCExport ?itemText "Export Cell" ?callback "OPCExportCell()")

		celllist = OPCWalkCellDir(lsprintf("%s/cells" OPCPath) "")
		celllist = append(celllist OPCWalkCellDir(lsprintf("/home/pschulz/serial_interface/cells") ""))

        ; create cell menu
        cellmenu = hiCreatePulldownMenu(
            'OPCCellMenu
            "OPC Cell Creation Menu"
            celllist
        )
        cellitem = hiCreateSliderMenuItem(?name 'OPCCellItem ?itemText "Create Cell..." ?subMenu cellmenu)
        settings = hiCreateMenuItem(?name 'OPCSettings ?itemText "Settings" ?callback "OPCSettingsCallback()")

        ; assemble main menu
        itemlist = list(about separator edit update separator script separator export separator cellitem settings)
        hiCreatePulldownMenu('OPCLayoutMenu "OpenPCells" itemlist)
    )
); procedure

procedure(OPCCreateSettingsForm()
    let(
        (
            OPCCommand pid exitstatus result
            fieldlist field
        )
        field = hiCreateStringField(
            ?name 'OPCSettingsCmdAdditionalArgs
            ?value ""
            ?prompt "Additional Command Line Arguments"
        )
        fieldlist = cons(list(field 0:30*0 350:30 250) fieldlist)
        field = hiCreateStringField(
            ?name 'OPCSettingsCmdAdditionalArgs
            ?value ""
            ?prompt "Additional Command Line Arguments"
        )
        field = hiCreateRadioField(
            ?name 'OPCSettingsDeleteFile
            ?choices list("true" "false")
            ?value "true"
            ?prompt "Delete cell file after creation"
        )
        fieldlist = cons(list(field 0:30*1 350:30 250) fieldlist)
        hiCreateAppForm(
            ?name 'OPCSettingsForm
            ?formTitle "OPC Settings"
            ?buttonLayout 'OKCancel
            ?fields fieldlist
        )
    )
) ; procedure

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

procedure(OPCMenuTrigger(args)
    list(OPCCreateLayoutMenu())
)
procedure(OPCModeChangeTrigger(args)
    when(boundp('OPCLayoutMenu)
        println("Change Trigger")
        if(args->action == 'change
            then
                if(args->accessMode == "a"
                    then
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScript->hiMenuItemSym)
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCScript->hiMenuItemSym)
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellItem->hiMenuItemSym)
                    else
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScript->hiMenuItemSym)
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCScript->hiMenuItemSym)
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellItem->hiMenuItemSym)
                )
            else
                if(geGetEditCellView()->mode == "a"
                    then
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScript->hiMenuItemSym)
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCScript->hiMenuItemSym)
                        hiEnableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellItem->hiMenuItemSym)
                    else
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCCellScript->hiMenuItemSym)
                        hiDisableMenuItem(OPCLayoutMenu OPCLayoutMenu->OPCScript->hiMenuItemSym)
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

/*
 *
 *   Export Functions
 *
*/
procedure(OPCAddPtsOffset(pts x y)
	mapcar(lambda( (pt) xCoord(pt) + x:yCoord(pt) + y) pts)
)

procedure(OPCConvertPtsToNanometer(pts)
	mapcar(lambda( (pt) fix(xCoord(pt) * 1000):fix(yCoord(pt) * 1000)) pts)
)

procedure(OPCWriteRectangle(file layer purpose bBox)
	let(
		(
		)
        fprintf(file "cell:merge_into_shallow(geometry.rectanglebltr(generics.mapped(nil, { layer = \"%s\", purpose = \"%s\" }), point.create(%d, %d), point.create(%d, %d)))\n", 
            layer purpose xCoord(car(bBox)) yCoord(car(bBox)) xCoord(cadr(bBox)) yCoord(cadr(bBox))
        )
	)
)

procedure(OPCWritePolygon(file layer purpose pts)
	let(
		(
		)
        fprintf(file "cell:merge_into_shallow(geometry.polygon(generics.mapped(nil, { layer = \"%s\", purpose = \"%s\" }), { %s }))\n"
            layer purpose 
            buildString(mapcar(lambda( (pt) lsprintf("point.create(%d, %d)" xCoord(pt) yCoord(pt))) pts) ", ")
        )
	)
)

procedure(OPCWriteShape(file shape x y)
    unless(shape->layerName == "instance"
        if(shape->objType == "rect"
            then
                OPCWriteRectangle(file shape->layerName shape->purpose OPCConvertPtsToNanometer(OPCAddPtsOffset(shape->bBox x y)))
            else
                OPCWritePolygon(file shape->layerName shape->purpose OPCConvertPtsToNanometer(OPCAddPtsOffset(shape->points x y)))
        )
    )
)
