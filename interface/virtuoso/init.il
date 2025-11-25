foreach(file list("backup" "call" "edit_update" "export" "fill" "menu" "misc" "settings" "subcell" "cells")
    load(lsprintf("%s/interface/virtuoso/%s.il" OPCPath file))
)

; initialize forms
unless(boundp('OPCSettingsForm)
    OPCCreateSettingsForm()
)
