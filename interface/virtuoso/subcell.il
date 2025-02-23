procedure(OPCSubCellGet()
    let(
        (cv selset path)
        cv = geGetEditCellView()
        selset = geGetSelSet()
        when(length(selset) == 1 ; only one object selected
            opcgroup = car(selset)
            when(opcgroup->objType == "figGroup" ; selected object is a group
                when(setof(p opcgroup->prop p->name == "opcpath") ; group is an opc group
                    opcgroup
                ) ; when has opcpath
            ) ; when is group
        ) ; when only one object in selection set
    ) ; let
) ; procedure

procedure(OPCSubCellEdit()
    let(
        (opcgroup)
        opcgroup = OPCSubCellGet()
        when(opcgroup
            OPCOpenEditor(opcgroup->opcpath)
        ) ; when opcgroup
    ) ; let
) ; procedure

procedure(OPCSubCellUpdate()
    let(
        (opcgroup)
        opcgroup = OPCSubCellGet()
        if(opcgroup
            then
                OPCUpdateCallback(?hierarchical nil ?xpath opcgroup->opcpath ?origin opcgroup->origin ?xgroupname opcgroup->name)
            else
                nil
        ) ; if opcgroup
    ) ; let
) ; procedure
