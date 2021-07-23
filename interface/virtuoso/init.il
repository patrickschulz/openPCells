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
                hiDisplayAppDBox(
                    ?name        'OPCInfoDialog
                    ?dboxBanner  "openPCells"
                    ?dboxText    lsprintf("errors while executing opc: %s" ipcReadProcess(pid))
                    ?dialogType   hicWarningDialog
                    ?dialogStyle 'modeless
                    ?buttonLayout 'Close
                )
                nil
            else
                t
        ) ; if exitstatus
    ) ; let
)

procedure(OPCCleanUp()
    if(boundp('OPCSettingsForm)
        then
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
            OPCArgs = lsprintf(
                "--cell %s --origin '(%d, %d)' -f %s" 
                lsprintf("%s/%s" OPCCellForm->OPCLibList->value OPCCellForm->OPCCellList->value)
                fix(1000 * xCoord(OPCOrigin)) fix(1000 * yCoord(OPCOrigin)) 
                OPCFilename
            )
            foreach(field OPCCellForm->fieldList
			    unless(equal(field 'OPCLibList) || equal(field 'OPCCellList)
                    unless(get(OPCCellForm field)->value == get(OPCCellForm field)->defValue
                        OPCArgs = lsprintf("%s %s" OPCArgs lsprintf("%s=%A" field get(OPCCellForm field)->value))
                    )
                )
            )
            when(OPCCall(OPCArgs)
                printf("opc: load %s.il\n" OPCFilename)
                load(lsprintf("%s.il" OPCFilename))
                OPCCleanUp()
            )
        ) ; when done
    )
    t
) ; OPCCreateCell

procedure(OPCPlaceCell()
    ;unless('boundp('OPCCellForm)
        OPCCreateParamForm()
    ;)
	enterPoint(
		?prompts list("Enter origin")
		?doneProc "OPCCreateCell"
        ?form OPCCellForm
        ?alwaysMap t
	)
) ; OPCPlaceCell

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

        ; create cell
        cellitem = hiCreateMenuItem(?name 'OPCCellItem ?itemText "Create Cell" ?callback "OPCPlaceCell()")
        settings = hiCreateMenuItem(?name 'OPCSettings ?itemText "Settings" ?callback "OPCSettingsCallback()")

        ; assemble main menu
        itemlist = list(about separator edit update separator script separator export separator cellitem separator settings)
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
            ?value "-X -l"
            ?prompt "Additional Command Line Arguments"
        )
        fieldlist = cons(list(field 0:30*0 350:30 250) fieldlist)
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

procedure(OPCGetCellParameters(cellname)
    let(
        (   
            OPCCommand pid exitstatus result
            fieldlist field (i 0)
        )   
        OPCCommand = lsprintf("/home/pschulz/openPCells/opc --machine --technology GF22FDSOI --parameters --separator ';' --cell %s" cellname)
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
                        if(boundp(stringToSymbol(name))
                            then
                                field = stringToSymbol(name)
                            else
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
                                    /*                           
                                    ("boolean"
                                        field = hiCreateBooleanButton(
                                            ?name stringToSymbol(name)
                                            ?value t
                                            ?buttonText display
                                        )
                                    )
                                    */
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
                                ) ; case
                        ) ; if
                        fieldlist = cons(field fieldlist)
                        i = i + 1
                    )
                ) ; let
        ) ; if exitstatus
        fieldlist
	) ; let
)

procedure(OPCUpdateLibName(lib)
	let((liblist celllist)
		liblist = mapcar(lambda( (lst) car(lst)) OPCData)
		foreach(l OPCData
			when(car(l) == if(lib then lib else car(liblist))
				celllist = cadr(l)
			)
		)
		list(liblist celllist)
	)
)

procedure(OPCLibNameCallback(field form)
	let(
		(celllist)
		celllist = cadr(OPCUpdateLibName(field->value))
		form->OPCCellList->items = celllist
		form->OPCCellList->value = car(celllist)
	)
)

procedure(OPCUpdateCellParameters(cellname)
	let(
		(fieldlist todelete)
		fieldlist = OPCGetCellParameters(cellname)
		foreach(field OPCCellForm->fieldList 
			;unless(member(field fieldlist) || member(field list(OPCLibList OPCCellList))
			unless(equal(field 'OPCLibList) || equal(field 'OPCCellList)
                todelete = cons(field todelete)
			)
		)
		hiDeleteFields(OPCCellForm todelete)
        hiAddField(OPCCellForm fieldlist)
	)
)

procedure(OPCUpdateCellParametersCB(field form)
	OPCUpdateCellParameters(lsprintf("%s/%s" OPCCellForm->OPCLibList->value OPCCellForm->OPCCellList->value))
)

procedure(OPCCreateParamForm()
	let(
		(OPCCommand)
		OPCCommand = lsprintf("%s" "/home/pschulz/openPCells/opc -L --list-format 'OPCData = list(\\n:)\\n:::list(\\\"%b\\\" list(:))\\n:\\\"%c\\\" ' > opccells")
		pid = ipcBeginProcess(OPCCommand)
		ipcWait(pid)
		load("opccells")	
	)
	let((libcelllist)
		libcelllist = OPCUpdateLibName(nil)
		OPCLibList = hiCreateComboField(
			?name 'OPCLibList
			?prompt "Library"
			?items car(libcelllist)
			?value caar(libcelllist)
			?callback 'OPCLibNameCallback
		)
		OPCCellList = hiCreateComboField(
			?name 'OPCCellList
			?prompt "Cell"
			?items cadr(libcelllist)
			?value car(cadr(libcelllist))
			?callback 'OPCUpdateCellParametersCB
		)
	)
	let(
		()
		hiCreateAppForm(
			?name 'OPCCellForm
			?formTitle "OPC Create Cell"
			?fields list(OPCLibList OPCCellList)
			?callback 'OPCCellFormCallback
			?buttonLayout 'OKCancel
			?unmapAfterCB t
		)
		OPCCellForm->extraFields = list(nil 'OPCLibList OPCLibList 'OPCCellList OPCCellList)
		OPCUpdateCellParameters(lsprintf("%s/%s" OPCCellForm->OPCLibList->value OPCCellForm->OPCCellList->value))
		OPCCellForm
	)
)

procedure(OPCMenuTrigger(args)
    list(OPCCreateLayoutMenu())
)
procedure(OPCModeChangeTrigger(args)
    when(boundp('OPCLayoutMenu)
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
