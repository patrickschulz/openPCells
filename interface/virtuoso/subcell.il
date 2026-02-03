procedure(OPCIsOPCGroup(group)
    let(
        ((found nil))
        when(group->objType == "figGroup" ; selected object is a group
            when(setof(p group->prop p->name == "opcpath") ; group is an opc group (cellscript)
                found = t
            ) ; when has opcpath
            when(setof(p group->prop p->name == "opccell") ; group is an opc group (cell)
                found = t
            ) ; when has opcpath
        ) ; when is group
        found
    )
) ; OPCIsOPCGroup

procedure(OPCSubCellGet()
    setof(group geGetSelSet() OPCIsOPCGroup(group))
) ; OPCSubCellGet

procedure(OPCSubCellCreateScript()
    ; (1) open dialog to get group name/layout path (should they be the same?)
    hiCreateAppForm(
        ?name 'OPCSubCellScriptCreationForm
        ?formTitle "Create OPC Sub-Cell"
        ?buttonLayout 'OKCancel
        ?initialSize t ; size form to fit all fields
        ?fields list(
            hiCreateStringField(
                ?name 'OPCSubCellScriptName
                ?value ""
                ?prompt "Name of Sub-Cell"
            )
            hiCreateStringField(
                ?name 'OPCSubCellScriptTemplate
                ?value ""
                ?prompt "Template for Cell Creation"
            )
            hiCreateRadioField(
                ?name 'OPCSubCellScriptAutoTemplate
                ?value "true"
                ?choices '("true" "false")
                ?prompt "Use Automatic Template"
            )
        )
        ?callback "OPCSubCellScriptCreateCallback()"
    )
    hiDisplayForm(OPCSubCellScriptCreationForm 100:100)
) ; OPCSubCellCreateScript

procedure(OPCSubCellCreateCell()
    ; (1) open dialog to get cell name
    hiCreateAppForm(
        ?name 'OPCSubCellCellCreationForm
        ?formTitle "Create OPC Sub-Cell"
        ?buttonLayout 'OKCancel
        ?initialSize t ; size form to fit all fields
        ?fields list(
            hiCreateStringField(
                ?name 'OPCSubCellCellName
                ?value ""
                ?prompt "Name of Cell"
            )
            hiCreateStringField(
                ?name 'OPCSubCellCellGroupname
                ?value ""
                ?prompt "Group Name for Cell Creation"
            )
        )
        ?callback "OPCSubCellCellCreateCallback()"
    )
    hiDisplayForm(OPCSubCellCellCreationForm 100:100)
) ; OPCSubCellCreateCell

procedure(OPCSubCellCreateBase(cv name properties)
    let((group)
        group = dbCreateFigGroup(cv name nil 0:0 "R0")
        foreach(prop properties
            dbCreateProp(group getq(prop name) getq(prop type) getq(prop value))
        )
        group
    )
) ; OPCSubCellCreateBase

procedure(OPCGetSubCellScriptDirectory(cv)
    lsprintf("%s/%s/layout/opcsubgroups" cv->lib->readPath cv->cellName)
) ; OPCGetSubCellScriptDirectory

procedure(OPCSubCellScriptCreateCallback()
    let(
        (cv group path filename label rect groupname template)
        cv = geGetEditCellView()
        groupname = OPCSubCellScriptCreationForm->OPCSubCellScriptName->value
        template = OPCSubCellScriptCreationForm->OPCSubCellScriptTemplate->value
        if(dbGetFigGroupByName(cv groupname)
            then
                hiDisplayAppDBox(
                    ?name        'OPCInfoDialog
                    ?dboxBanner  "openPCells"
                    ?dboxText    "Tried to create a new sub-cell, but the name for the group is already taken"
                    ?dialogType   hicWarningDialog
                    ?dialogStyle 'modeless
                    ?buttonLayout 'Close
                )
                nil
            else
                path = OPCGetSubCellScriptDirectory(cv)
                unless(isDir(path)
                    createDir(path)
                )
                filename = lsprintf("%s/%s.lua" path groupname)
                OPCOpenEditor(filename)
                group = OPCSubCellCreateBase(cv
                    groupname
                    list(
                        list(nil 'name "opcpath" 'type "string" 'value filename)
                        list(nil 'name "opcprotect" 'type "boolean" 'value nil)
                    )
                )
                label = dbCreateLabel(cv OPCGetInfoLayer() 0:0 groupname "centerCenter" "R0" "fixed" 1)
                dbAddFigToFigGroup(group label)
                rect = dbCreateRect(cv OPCGetInfoLayer() list(-0.5:-0.5 0.5:0.5))
                dbAddFigToFigGroup(group rect)
                unless(template == ""
                    let((cmd)
                        if(OPCSubCellScriptCreationForm->OPCSubCellScriptAutoTemplate->value == "true"
                            then
                                cmd = OPCBuildCallCommand(lsprintf("--template-auto %s" template))
                            else
                                cmd = OPCBuildCallCommand(lsprintf("--template %s" template))
                        )
                        OPCCall(cmd ?redirect filename)
                    ) ; let
                ) ; unless template == ""
                OPCMoveGroup(group)
                t
        )
    )
    ; (2) create group with some dummy shape
    ; (3) set name of group
    ; (4) add opcpath property
    ; (5) call opc and fill group with shapes
    ; (6) place/move group
) ; OPCSubCellScriptCreateCallback

procedure(OPCSubCellCellCreateCallback()
    let(
        (cv group path label groupname cellname)
        cv = geGetEditCellView()
        groupname = OPCSubCellCellCreationForm->OPCSubCellCellGroupname->value
        cellname = OPCSubCellCellCreationForm->OPCSubCellCellName->value
        if(dbGetFigGroupByName(cv groupname)
            then
                hiDisplayAppDBox(
                    ?name        'OPCInfoDialog
                    ?dboxBanner  "openPCells"
                    ?dboxText    "Tried to create a new sub-cell, but the name for the group is already taken"
                    ?dialogType   hicWarningDialog
                    ?dialogStyle 'modeless
                    ?buttonLayout 'Close
                )
                nil
            else
                group = OPCSubCellCreateBase(cv
                    groupname
                    list(
                        list(nil 'name "opccell" 'type "string" 'value lsprintf("%s" cellname))
                        list(nil 'name "opcprotect" 'type "boolean" 'value nil)
                    )
                )
                label = dbCreateLabel(cv OPCGetInfoLayer() 0:0 groupname "centerCenter" "R0" "fixed" 1)
                dbAddFigToFigGroup(group label)
                t
        )
    )
    ; (2) create group with some dummy shape
    ; (3) set name of group
    ; (4) add opcpath property
    ; (5) call opc and fill group with shapes
    ; (6) place/move group
) ; OPCSubCellCellCreateCallback

procedure(OPCSubCellEditScript()
    let(
        (opcgroups)
        opcgroups = OPCSubCellGet()
        foreach(opcgroup opcgroups
            OPCOpenEditor(opcgroup->opcpath)
        ) ; when opcgroup
    ) ; let
) ; OPCSubCellEditScript

procedure(OPCSubCellMapILListEntry(entry)
    case(type(entry)
        ('fixnum lsprintf("%d" entry))
        ('flonum lsprintf("%d" 1000 * entry))
        ('string lsprintf("\"%s\"" entry))
        ('symbol lsprintf("\"%s\"" symbolToString(entry)))
        ('list  OPCSubCellFormatILList(entry))
        (t error(lsprintf(
                "openPCells virtuoso sub-cell: received an unknown entry type for parameter formatting: %s" 
                symbolToString(type(entry))
           ))
        )
    ) ; case
) ; OPCSubCellMapILListEntry

procedure(OPCSubCellFormatILList(l)
    let(
        (flist)
        flist = mapcar('OPCSubCellMapILListEntry l)
        lsprintf("{ %s }" buildString(flist ", "))
    ) ; let
) ; OPCSubCellFormatILList

procedure(OPCGetSubCellCellParameters(opcgroup)
    let((value parameterlist)
        parameterlist = nil
        foreach(p opcgroup->prop
            unless(p->name == "opccell" || p->name == "opcprotect"
                value = case(p->valueType
                    ("int"      lsprintf("%d" p->value)) ; integers stay integers (e.g. number of fingers)
                    ("float"    lsprintf("%d" int(p->value * 1000))) ; convert micro-meter to nano-meter
                    ("boolean"  lsprintf("%s" if(p->value == "TRUE" "true" "false")))
                    ("string"   lsprintf("\"%s\"" p->value))
                    ("ILList"   OPCSubCellFormatILList(p->value))
                    (t nil) ; should be unreachable?
                )
                parameterlist = cons(list(p->name value) parameterlist)
            )
        )
        parameterlist
    )
); OPCGetSubCellCellParameters

procedure(OPCSubCellUpdateCellScript()
    t
) ; OPCSubCellUpdateCellScript

procedure(OPCSubCellUpdateCell(opcgroup)
    let(
        (parameterlist)
        parameterlist = OPCGetSubCellCellParameters(opcgroup)
        OPCUpdateCellCellCallback(
            opcgroup->opccell
            parameterlist
            ?hierarchical nil
            ?deleteAll nil
            ?origin opcgroup->origin
            ?xgroupname opcgroup->name
        )
    )
) ; OPCSubCellUpdateCell

procedure(OPCSubCellUpdate()
    let(
        (opcgroups)
        opcgroups = OPCSubCellGet()
        foreach(opcgroup opcgroups
            when(opcgroup->opcprotect == "FALSE"
                if(setof(p opcgroup->prop p->name == "opcpath") ; group is an opc group (cellscript)
                    then
                        OPCUpdateCellscriptCallback(
                            ?hierarchical nil
                            ?deleteAll nil
                            ?xpath opcgroup->opcpath
                            ?origin opcgroup->origin
                            ?useOrigin t
                            ?xgroupname opcgroup->name
                        )
                    else
                        OPCSubCellUpdateCell(opcgroup)
                )
            )
        ) ; foreach opcgroup
    ) ; let
) ; OPCSubCellUpdate

procedure(OPCSubCellCleanUp()
    let(
        (cv basepath groupnames pattern todelete)
        cv = geGetEditCellView()
        ; gather all groups in the current cellview
        groupnames = mapcar(g cv->figGroups g->name) ; FIXME: check property names
        ; collect all subcell script files
        basepath = OPCGetSubCellScriptDirectory(cv)
        pattern = pcreCompile("*.lua")
        when(isDir(basepath)
            let((subscriptfiles)
                subscriptfiles = setof(file getDirFiles() pcreMatch(file pattern)) ; FIXME: check syntax/names
                todelete = setof(g groupnames member(g subscriptfiles)) ; FIXME: check syntax
            )
        )
        foreach(d todelete
            deleteFile(d)
        )
    ) ; let
) ; OPCSubCellCleanUp
