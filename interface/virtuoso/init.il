foreach(file list("call" "creation" "edit_update" "export" "menu" "misc" "paramform" "settings")
    load(lsprintf("%s/interface/virtuoso/%s.il" OPCPath file))
)

; initialize forms
unless(boundp('OPCSettingsForm)
    OPCCreateSettingsForm()
)
unless(boundp('OPCCellForm)
    OPCCreateParamForm()
)
