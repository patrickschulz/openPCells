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
                                field = let(
                                    (func value arglist)
                                    func = case(vtype 
                                        ("number" 'hiCreateFloatField) 
                                        ("integer" 'hiCreateIntField) 
                                        ("boolean" 'hiCreateRadioField)
                                        ("string" 'hiCreateStringField)
                                        ("numtable" 'hiCreateStringField)
                                        ("strtable" 'hiCreateStringField)
                                        (t nil)
                                    )
                                    value = case(vtype 
                                        ("number" atof(default))
                                        ("integer" atoi(default))
                                        (t default)
                                    )
                                    if(func
                                        then
                                            if(vtype == "boolean"
                                                then
                                                    arglist = list(
                                                        ?name sym 
                                                        ?prompt display 
                                                        ?value value
                                                        ?callback list('OPCUpdateCellShapeCB)
                                                        ?choices list("true" "false")
                                                    )
                                                else
                                                    arglist = list(
                                                        ?name sym 
                                                        ?prompt display 
                                                        ?value value
                                                        ?callback 'OPCUpdateCellShapeCB
                                                    )
                                            )
                                            field = apply(func arglist)
                                        else
                                            printf("error while parsing parameter line '%s'\n" line)
                                            printf("parse result:\n ptype = %s\n parent = %s\n name = %s\n display = %s\n default = %s\n vtype = %s\n readonly = %s\n" ptype parent name display default vtype readonly)
                                            nil
                                    )
                                )
                                when(field
                                    ; store field
                                    putprop(OPCCellForm->extraFields field sym)
                                    putprop(OPCCellForm->fieldParents parent sym)
                                    putprop(OPCCellForm->fieldNames name sym)
                                )
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

procedure(OPCLibNameCB(field form)
	let(
		(celllist)
		celllist = cadr(OPCUpdateLibName(field->value))
		form->OPCCellList->items = celllist
		form->OPCCellList->value = car(celllist)
	)
    OPCUpdateCellShapeCB(field form)
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
    OPCUpdateCellShapeCB(field form)
)

procedure(OPCUpdateCellShapeCB(field form)
    let(
        (cv)
        cv = dbOpenCellViewByType("testing" "__opctempcell__" "layout" "maskLayout" "s")
        foreach(shape cv->shapes dbDeleteObject(shape)) ; delete old shapes
        OPCCreateCellInternal(cv 0:0)
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
			?callback 'OPCLibNameCB
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
            ;?formType 'options
            ?dontBlock t
			?formTitle "OPC Create Cell"
			?fields list(OPCLibList OPCCellList)
			;?buttonLayout 'HideCancelDef
			?buttonLayout 'Close
		)
		OPCCellForm->extraFields = list(nil 'OPCLibList OPCLibList 'OPCCellList OPCCellList)
		OPCCellForm->fieldParents = list(nil)
		OPCCellForm->fieldNames = list(nil)
		OPCUpdateCellParameters(lsprintf("%s/%s" OPCCellForm->OPCLibList->value OPCCellForm->OPCCellList->value))
		OPCCellForm
	)
)
