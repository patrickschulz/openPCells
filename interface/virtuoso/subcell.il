procedure(OPCCreateSubCell(name)
    ; (1) create group with given name
    ; (2) open editor for cell script
    ; (3) call opc on cell script (with --flatten)
    ; (4) load generated cell shapes into group
    ; (5) store property with cell script path on group
)

procedure(OPCEditSubCell()
    ; (1) check if selSet contains only one entry
    ; (2) check if selected object is a group
    ; (3) check if group has opc_cellscript_path property
    ; (4) open cell script
)

procedure(OPCUpdateSubCell()
    ; (1) check if selSet contains only one entry
    ; (2) check if selected object is a group
    ; (3) check if group has opc_cellscript_path property
    ; (4) execute cell script
    ; (5) delete all shapes in group
    ; (6) load generated cell shapes into group
)
