procedure(OPCCall(args redirect)
    let(
        ((additionalargs ""))
        additionalargs = OPCSettingsForm->OPCSettingsCmdAdditionalArgs->value
        when(OPCSettingsForm->OPCSettingsMerge->value == "true"
            additionalargs = lsprintf("%s --flat --merge-rectangles" additionalargs)
        )
        if(redirect
            then
                OPCCommand = lsprintf(
                    "%s/%s %s %s > %s"
                    OPCPath OPCExec additionalargs args redirect
                )
            else
                OPCCommand = lsprintf(
                    "%s/%s %s %s"
                    OPCPath OPCExec additionalargs args
                )
        )
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
    when(OPCSettingsForm->OPCSettingsDeleteFile->value == "true"
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
            "%s/%s --technology %s --export SKILL %s %s"
        when(done
            OPCArgs = lsprintf(
                "--technology %s --export SKILL --cell %s --origin '(%d, %d)' -f %s" 
                OPCTech
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
            when(OPCCall(OPCArgs nil)
                load(lsprintf("%s.il" OPCFilename))
                OPCCleanUp()
            )
        ) ; when done
    )
    t
) ; OPCCreateCell

procedure(OPCPlaceCell()
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
        pid = ipcBeginProcess(lsprintf(OPCSettingsForm->OPCSettingsEditCmd->value path))
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
        OPCArgs = lsprintf("--technology %s --export SKILL --cellscript %s -f %s" OPCTech path OPCFilename)
        when(OPCCall(OPCArgs nil)
            foreach(shape cv->shapes dbDeleteObject(shape))
            foreach(inst cv->instances dbDeleteObject(inst))
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
        field = hiCreateRadioField(
            ?name 'OPCSettingsMerge
            ?choices list("true" "false")
            ?value "false"
            ?prompt "Merge Rectangles"
        )
        fieldlist = cons(list(field 0:30*2 350:30 250) fieldlist)
        field = hiCreateStringField(
            ?name 'OPCSettingsEditCmd
            ;?value "xterm -e 'vim %s'"
            ?value "xterm -fa monaco -fs 13 -e 'vim %s'"
            ?prompt "Edit command for update"
        )
        fieldlist = cons(list(field 0:30*3 350:30 250) fieldlist)
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
            fieldlist field
        )   
        when(OPCCall(lsprintf("--technology %s --cell %s --parameters --parameters-format '%%t:%%n:%%d:%%v:%%a'" OPCTech cellname) "opc.params")
            let(
                ((file infile("opc.params")) params ptype name display default vtype)
                while(line = gets(nil file)
                    params = parseString(substring(line 1 strlen(line) - 1) ":")
                    ptype   =                 car(params)
                    name    =             car(cdr(params))
                    display =         car(cdr(cdr(params)))
                    default =     car(cdr(cdr(cdr(params))))
                    vtype   = car(cdr(cdr(cdr(cdr(params)))))
                    when(display == "_NONE_"
                        display = name
                    )
                    if(get(OPCCellForm->extraFields stringToSymbol(name))
                        then
                            field = get(OPCCellForm->extraFields stringToSymbol(name))
                        else
                            field = case(vtype
                                ("number"
                                    hiCreateFloatField(
                                        ?name stringToSymbol(name)
                                        ?value atof(default)
                                        ?prompt display
                                    )
                                )
                                ("integer"
                                    hiCreateIntField(
                                        ?name stringToSymbol(name)
                                        ?value atoi(default)
                                        ?prompt display
                                    )
                                )                                 
                                ("boolean"
                                    hiCreateRadioField(
                                        ?name stringToSymbol(name)
                                        ?choices list("true" "false")
                                        ?value default
                                        ?prompt display
                                    )
                                )
                                ;("boolean"
                                ;    hiCreateBooleanButton(
                                ;        ?name stringToSymbol(name)
                                ;        ?value t
                                ;        ?buttonText display
                                ;    )
                                ;)
                                ("string"
                                    hiCreateStringField(
                                        ?name stringToSymbol(name)
                                        ?value default
                                        ?prompt display
                                    )
                                )
                                ("numtable"
                                    hiCreateStringField(
                                        ?name stringToSymbol(name)
                                        ?value default
                                        ?prompt display
                                    )
                                )
                                ("strtable"
                                    hiCreateStringField(
                                        ?name stringToSymbol(name)
                                        ?value default
                                        ?prompt display
                                    )
                                )
                                (t
                                    printf("error while parsing parameter line '%s'\n" line)
                                    nil
                                )
                            ) ; case
                            ; store field
                            putprop(OPCCellForm->extraFields field stringToSymbol(name))
                    ) ; if
                    fieldlist = cons(field fieldlist)
                ) ; foreach
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
		(fieldlist toinsert todelete)
		fieldlist = OPCGetCellParameters(cellname)
		foreach(field OPCCellForm->fieldList 
			unless(member(field fieldlist) || equal(field 'OPCLibList) || equal(field 'OPCCellList)
                todelete = cons(field todelete)
			)
		)
        foreach(field fieldlist
            unless(member(field todelete)
                toinsert = cons(field toinsert)
            )
        )
		hiDeleteFields(OPCCellForm todelete)
        hiAddFields(OPCCellForm toinsert)
	)
)

procedure(OPCUpdateCellParametersCB(field form)
	OPCUpdateCellParameters(lsprintf("%s/%s" OPCCellForm->OPCLibList->value OPCCellForm->OPCCellList->value))
)

procedure(OPCCreateParamForm()
	let(
		()
        OPCCall("-L --list-format 'OPCData = list(\\n:)\\n:::list(\\\"%b\\\" list(:))\\n:\\\"%c\\\" '" "opccells")
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
            ?formType 'options
			?formTitle "OPC Create Cell"
			?fields list(OPCLibList OPCCellList)
			?buttonLayout 'HideCancelDef
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

; initialize forms
unless(boundp('OPCSettingsForm)
    OPCCreateSettingsForm()
)
unless(boundp('OPCCellForm)
    OPCCreateParamForm()
)
