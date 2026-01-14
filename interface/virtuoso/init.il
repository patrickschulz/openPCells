foreach(
    file
    list(
        "backup"
        "call"
        "cells"
        "edit_update"
        "export"
        "fill"
        "menu"
        "misc"
        "powergrid"
        "settings"
        "subcell"
    )
    load(lsprintf("%s/interface/virtuoso/%s.il" OPCPath file))
)

; initialize forms
unless(boundp('OPCSettingsForm)
    OPCCreateSettingsForm()
)
