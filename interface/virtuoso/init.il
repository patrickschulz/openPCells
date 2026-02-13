foreach(
    filename
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
    load(lsprintf("%s/interface/virtuoso/%s.il" OPCPath filename))
)

; initialize forms
unless(boundp('OPCSettingsForm)
    OPCCreateSettingsForm()
)

; set required environment variables
envSetVal("layout" "extractKeepShapeAssignment" 'boolean t)
