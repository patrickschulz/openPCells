procedure(OPCSubCellGet()
    let(
        (cv selset path (found nil))
        cv = geGetEditCellView()
        selset = geGetSelSet()
        when(length(selset) == 1 ; only one object selected
            opcgroup = car(selset)
            when(opcgroup->objType == "figGroup" ; selected object is a group
                when(setof(p opcgroup->prop p->name == "opcpath") ; group is an opc group (cellscript)
                    found = t
                ) ; when has opcpath
                when(setof(p opcgroup->prop p->name == "opccell") ; group is an opc group (cell)
                    found = t
                ) ; when has opcpath
            ) ; when is group
        ) ; when only one object in selection set
        if(found
            then
                opcgroup
            else
                hiDisplayAppDBox(
                    ?name        'OPCInfoDialog
                    ?dboxBanner  "openPCells"
                    ?dboxText    "Tried to perform an action on an opcgroup, but the selected object is not an opcgroup or more than one object was selected"
                    ?dialogType   hicWarningDialog
                    ?dialogStyle 'modeless
                    ?buttonLayout 'Close
                )
                nil
        )
    ) ; let
) ; procedure

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
                ?prompt "Template for Cell Creation"
            )
        )
        ?callback "OPCSubCellScriptCreateCallback()"
    )
    hiDisplayForm(OPCSubCellScriptCreationForm 100:100)
)

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
)

procedure(OPCSubCellCreateBase(cv name properties)
    let((group)
        group = dbCreateFigGroup(cv name nil 0:0 "R0")
        foreach(prop properties
            ; FIXME: check whether getq is correct
            dbCreateProp(group getq(prop name) getq(prop type) getq(prop value))
        )
        group
    )
)

procedure(OPCSubCellScriptCreateCallback()
    let(
        (cv group path label groupname template)
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
                path = lsprintf("%s/%s/layout/opcsubgroups" cv->lib->readPath cv->cellName)
                unless(isDir(path)
                    createDir(path)
                )
                group = OPCSubCellCreateBase(cv groupname list(list(nil 'name "opcpath" 'type "string" 'value lsprintf("%s/%s.lua" path groupname))))
                label = dbCreateLabel(cv list("OUTLINE" "drawing") 0:0 groupname "centerCenter" "R0" "fixed" 1)
                dbAddFigToFigGroup(group label)
                unless(template == ""
                    let((filename cmd)
                        if(OPCSubCellCellCreationForm->OPCSubCellScriptAutoTemplate->value == "true"
                            then
                                cmd = OPCBuildCallCommand(lsprintf("--template-auto %s" template))
                            else
                                cmd = OPCBuildCallCommand(lsprintf("--template %s" template))
                        )
                        filename = lsprintf("%s/%s.lua" path groupname)
                        OPCCall(cmd ?redirect filename)
                    ) ; let
                ) ; unless template == ""
                t
        )
    )
    ; (2) create group with some dummy shape
    ; (3) set name of group
    ; (4) add opcpath property
    ; (5) call opc and fill group with shapes
    ; (6) place/move group
) ; procedure

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
                group = OPCSubCellCreateBase(cv groupname list(list(nil 'name "opccell" 'type "string" 'value lsprintf("%s" cellname))))
                label = dbCreateLabel(cv list("OUTLINE" "drawing") 0:0 groupname "centerCenter" "R0" "fixed" 1)
                dbAddFigToFigGroup(group label)
                t
        )
    )
    ; (2) create group with some dummy shape
    ; (3) set name of group
    ; (4) add opcpath property
    ; (5) call opc and fill group with shapes
    ; (6) place/move group
) ; procedure

procedure(OPCSubCellEditScript()
    let(
        (opcgroup)
        opcgroup = OPCSubCellGet()
        when(opcgroup
            OPCOpenEditor(opcgroup->opcpath)
        ) ; when opcgroup
    ) ; let
) ; procedure

procedure(OPCGetSubCellCellParameters(opcgroup)
    let((value parameterlist)
        parameterlist = nil
        foreach(p opcgroup->prop
            unless(p->name == "opccell"
                value = case(p->valueType
                    ("int" lsprintf("%d" p->value)) ; integers stay integers (e.g. number of fingers)
                    ("float" lsprintf("%d" int(p->value * 1000))) ; convert micro-meter to nano-meter
                    ("boolean" lsprintf("%s" if(p->value == "TRUE" "true" "false")))
                    ("string" lsprintf("\"%s\"" p->value))
                    (t nil)
                )
                parameterlist = cons(list(p->name value) parameterlist)
            )
        )
        parameterlist
    )
); OPCGetSubCellCellParameters

procedure(OPCSubCellUpdateCellScript()
    t
)

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
)

procedure(OPCSubCellUpdate()
    let(
        (opcgroup)
        opcgroup = OPCSubCellGet()
        if(opcgroup
            then
                if(setof(p opcgroup->prop p->name == "opcpath") ; group is an opc group (cellscript)
                    then
                        OPCUpdateCellscriptCallback(
                            ?hierarchical nil
                            ?deleteAll nil
                            ?xpath opcgroup->opcpath
                            ?origin opcgroup->origin
                            ?xgroupname opcgroup->name
                        )
                    else
                        OPCSubCellUpdateCell(opcgroup)
                )
            else
                nil
        ) ; if opcgroup
    ) ; let
) ; procedure
