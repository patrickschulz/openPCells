procedure(OPCCall(args redirect)
    let(
        ((additionalargs ""))
        additionalargs = OPCSettingsForm->OPCSettingsCmdAdditionalArgs->value
        when(OPCSettingsForm->OPCSettingsMerge->value == "true"
            additionalargs = lsprintf("%s --flat --merge-rectangles" additionalargs)
        )
        OPCCommand = lsprintf( "%s/%s %s %s" OPCPath OPCExec additionalargs args)
        when(redirect
            OPCCommand = lsprintf( "%s > %s" OPCCommand redirect)
        )
        when(OPCSettingsForm->OPCSettingsLog->value == "true"
            printf("opc call: %s\n" OPCCommand)
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

procedure(OPCCleanUp(filename)
    when(OPCSettingsForm->OPCSettingsDeleteFile->value == "true"
        when(isFile(filename)
            deleteFile(filename)
        )
    )
)

procedure(OPCPrepareArgsForCellCreation(args)
    OPCArgs = lsprintf("--technology %s --export SKILL %s" OPCTech args)
    when(OPCSettingsForm->OPCSettingsGroup->value == "true"
        OPCArgs = lsprintf("%s -X -g -X '-n %s'" OPCArgs OPCSettingsForm->OPCSettingsGroupname->value)
    )
    when(OPCSettingsForm->OPCSettingsDrawAlignmentbox->value == "true"
        OPCArgs = lsprintf("%s --draw-alignmentbox" OPCArgs)
    )
    OPCArgs
)

procedure(OPCCreateCell(w done pts)
    when(done
        OPCCreateCellInternal(geGetEditCellView() car(pts))
    )
    t
) ; OPCCreateCell

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
            path OPCArgs
        )
        path = lsprintf("%s/%s/layout/layout.lua" libPath cellName)
        unless(isFile(path)
            let(((file outfile(path)))
                fprintf(file "%s" "local cell = object.create()\n\nreturn cell")
                close(file)
                OPCCleanUp(path)
            )
        )
        pid = ipcBeginProcess(lsprintf(OPCSettingsForm->OPCSettingsEditCmd->value path))
    )
) ; procedure

procedure(OPCUpdateCallback()
    letseq(
        (
            (cv geGetEditCellView())
            (libPath cv->lib->readPath)
            (cellName cv->cellName)
            path OPCArgs
        )
        path = lsprintf("%s/%s/layout/layout.lua" libPath cellName)
        OPCArgs = OPCPrepareArgsForCellCreation(lsprintf("--cellscript %s -f %s" path OPCSettingsForm->OPCCellFilename->value))
        when(OPCCall(OPCArgs nil)
            foreach(shape cv->shapes dbDeleteObject(shape))
            foreach(inst cv->instances dbDeleteObject(inst))
            load(lsprintf("%s.il" OPCSettingsForm->OPCCellFilename->value))
            OPCCleanUp(lsprintf("%s.il" OPCSettingsForm->OPCCellFilename->value))
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
        hiDisplayAppDBox(
            ?name        'OPCInfoDialog
            ?dboxBanner  "openPCells"
            ?dboxText    lsprintf("written opc representation of layout to %s" "openPCells_export.lua")
            ?dialogType   hicWarningDialog
            ?dialogStyle 'modeless
            ?buttonLayout 'Close
        )
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
    hiCreateAppForm(
        ?name 'OPCSettingsForm
        ?formTitle "OPC Settings"
        ?buttonLayout 'OKCancel
        ?initialSize t ; size form to fit all fields
        ?fields list(
            hiCreateStringField(
                ?name 'OPCCellFilename
                ?value "openPCells"
                ?prompt "File Name for Generated Layouts"
            )
            hiCreateStringField(
                ?name 'OPCParamFilename
                ?value "opc.parameters"
                ?prompt "File Name for Parameters"
            )
            hiCreateStringField(
                ?name 'OPCListFilename
                ?value "opc.cells"
                ?prompt "File Name for Cell Listings"
            )
            hiCreateStringField(
                ?name 'OPCPfileFilename
                ?value "opc.pfile"
                ?prompt "File Name for Parameter Bindings (Parameter File)"
            )
            hiCreateStringField(
                ?name 'OPCSettingsCmdAdditionalArgs
                ?value "-X -l"
                ?prompt "Additional Command Line Arguments"
            )
            hiCreateRadioField(
                ?name 'OPCSettingsDrawAlignmentbox
                ?choices list("true" "false")
                ?value "false"
                ?prompt "Draw Alignment Box"
            )
            hiCreateRadioField(
                ?name 'OPCSettingsLog
                ?choices list("true" "false")
                ?value "false"
                ?prompt "Log opc calls to CIW"
            )
            hiCreateRadioField(
                ?name 'OPCSettingsMerge
                ?choices list("true" "false")
                ?value "false"
                ?prompt "Merge Rectangles (can take a long time)"
            )
            hiCreateRadioField(
                ?name 'OPCSettingsGroup
                ?choices list("true" "false")
                ?value "true"
                ?prompt "Group Created Shapes"
            )
            hiCreateStringField(
                ?name 'OPCSettingsGroupname
                ?value "opcgroup"
                ?prompt "Group Name"
            )
            hiCreateRadioField(
                ?name 'OPCSettingsDeleteFile
                ?choices list("true" "false")
                ?value "true"
                ?prompt "Delete cell file after creation"
            )
            hiCreateStringField(
                ?name 'OPCSettingsEditCmd
                ?value "xterm -fa monaco -fs 13 -e 'vim %s'"
                ?prompt "Edit command for update"
            )
            hiCreateButton(
                ?name 'OPCSettingsUpdateCellList
                ?callback "OPCUpdateCellList()"
                ?buttonText "Update List of Cells"
            )
        )
    )
) ; procedure

procedure(OPCGetCellParameters(cellname)
    let(
        (   
            fieldlist field
        )   
        when(OPCCall(lsprintf("--technology %s --cell %s --parameters --parameters-format '%%t:%%p:%%n:%%d:%%v:%%a:%%r'" OPCTech cellname) OPCSettingsForm->OPCParamFilename->value)
            let(
                ((file infile(OPCSettingsForm->OPCParamFilename->value)) (isown t) params ptype name display default vtype readonly sym)
                while(line = gets(nil file)
                    params = parseString(substring(line 1 strlen(line) - 1) ":")
                    ptype    =                         car(params)
                    parent   =                     car(cdr(params))
                    name     =                 car(cdr(cdr(params)))
                    display  =             car(cdr(cdr(cdr(params))))
                    default  =         car(cdr(cdr(cdr(cdr(params)))))
                    vtype    =     car(cdr(cdr(cdr(cdr(cdr(params))))))
                    readonly = car(cdr(cdr(cdr(cdr(cdr(cdr(params)))))))
                    unless(readonly == "true"
                        when(display == "_NONE_"
                            display = name
                        )
                        ; change from own to referenced parameters
                        when(isown && parent != cellname
                            fieldlist = cons(hiCreateSeparatorField(?name gensym()) fieldlist)
                            fieldlist = cons(hiCreateLabel(?name gensym() ?labelText "Referenced Parameters (some might be overwritten by the cell and thus without effect)" ?justification 'center) fieldlist)
                            fieldlist = cons(hiCreateSeparatorField(?name gensym()) fieldlist)
                            isown = nil
                        )
                        sym = stringToSymbol(lsprintf("%s.%s" parent name))
                        if(get(OPCCellForm->extraFields sym)
                            then
                                field = get(OPCCellForm->extraFields sym)
                            else
                                field = case(vtype
                                    ("number"
                                        hiCreateFloatField(
                                            ?name sym
                                            ?value atof(default)
                                            ?prompt display
                                        )
                                    )
                                    ("integer"
                                        hiCreateIntField(
                                            ?name sym
                                            ?value atoi(default)
                                            ?prompt display
                                        )
                                    )                                 
                                    ("boolean"
                                        hiCreateRadioField(
                                            ?name sym
                                            ?choices list("true" "false")
                                            ?value default
                                            ?prompt display
                                        )
                                    )
                                    ;("boolean"
                                    ;    hiCreateBooleanButton(
                                    ;        ?name sym
                                    ;        ?value t
                                    ;        ?buttonText display
                                    ;    )
                                    ;)
                                    ("string"
                                        hiCreateStringField(
                                            ?name sym
                                            ?value default
                                            ?prompt display
                                        )
                                    )
                                    ("numtable"
                                        hiCreateStringField(
                                            ?name sym
                                            ?value default
                                            ?prompt display
                                        )
                                    )
                                    ("strtable"
                                        hiCreateStringField(
                                            ?name sym
                                            ?value default
                                            ?prompt display
                                        )
                                    )
                                    (t
                                        printf("error while parsing parameter line '%s'\n" line)
                                        printf("parse result:\n ptype = %s\n parent = %s\n name = %s\n display = %s\n default = %s\n vtype = %s\n readonly = %s\n" ptype parent name display default vtype readonly)
                                        nil
                                    )
                                ) ; case
                                ; store field
                                putprop(OPCCellForm->extraFields field sym)
                                putprop(OPCCellForm->fieldParents parent sym)
                                putprop(OPCCellForm->fieldNames name sym)
                        ) ; if
                        fieldlist = cons(field fieldlist)
                    ) ; unless readonly
                ) ; while
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
        when(todelete
		    hiDeleteFields(OPCCellForm todelete)
        )
        when(toinsert
            hiAddFields(OPCCellForm toinsert)
        )
	)
)

procedure(OPCUpdateCellParametersCB(field form)
	OPCUpdateCellParameters(lsprintf("%s/%s" OPCCellForm->OPCLibList->value OPCCellForm->OPCCellList->value))
)

procedure(OPCUpdateCellList()
	let(
		()
        OPCCall("-L --list-format 'OPCData = list(\\n:)\\n:::list(\\\"%b\\\" list(:))\\n:\\\"%c\\\" '" OPCSettingsForm->OPCListFilename->value)
		load(OPCSettingsForm->OPCListFilename->value)	
	)
)

procedure(OPCCreateParamForm()
    OPCUpdateCellList()
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
		OPCCellForm->fieldParents = list(nil)
		OPCCellForm->fieldNames = list(nil)
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
