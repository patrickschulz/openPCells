procedure(OPCCreateGuardring()
    let((group properties)
        properties = list(
            list(nil 'name "opccell" 'type "string" 'value lsprintf("%s" "auxiliary/guardring"))
            list(nil 'name "contype" 'type "string" 'value "n")
            list(nil 'name "ringwidth" 'type "float" 'value 0.2)
        )
        group = OPCSubCellCreateBase(geGetEditCellView() "guardring" properties)
        OPCSubCellUpdateCell(group)
    )
    /*
    hiCreateAppForm(
        ?name 'OPCCreateGuardringForm
        ?formTitle "Create Guardring"
        ?buttonLayout 'OKCancel
        ?initialSize t ; size form to fit all fields
        ?fields list(
            hiCreateStringField(
                ?name 'OPCGuardringConttype
                ?value "p"
                ?prompt "Connection Type"
            )
            hiCreateIntField(
                ?name 'OPCGuardringTopmetal
                ?value 1
                ?prompt "Top Metal"
            )
            hiCreateRadioField(
                ?name 'OPCGuardringDrawmetal
                ?value "true"
                ?prompt "Top Metal"
                ?choices list("true" "false")
            )
            hiCreateIntField(
                ?name 'OPCGuardringHolewidth
                ?value 5000
                ?prompt "Hole Width"
            )
            hiCreateIntField(
                ?name 'OPCGuardringHoleheight
                ?value 5000
                ?prompt "Hole Height"
            )
            hiCreateIntField(
                ?name 'OPCGuardringRingwidth
                ?value 200
                ?prompt "Hole Height"
            )
            hiCreateIntField(
                ?name 'OPCGuardringWellextension
                ?value 50
                ?prompt "Well Extension"
            )
            hiCreateIntField(
                ?name 'OPCGuardringWellinnerextension
                ?value 50
                ?prompt "Well Inner Extension"
            )
            hiCreateIntField(
                ?name 'OPCGuardringWellouterextension
                ?value 50
                ?prompt "Well Outer Extension"
            )
            hiCreateIntField(
                ?name 'OPCGuardringDrawsoiopen
                ?value true
                ?prompt "Draw SOI Opening"
            )
            hiCreateRadioField(
                ?name 'OPCGuardringFillsoiopen
                ?value "false"
                ?prompt "Fill Inner Area with SOI Opening"
                ?choices list("true" "false")
            )
            hiCreateIntField(
                ?name 'OPCGuardringSoiopenextension
                ?value 50
                ?prompt "SOI Opening Extension"
            )
            hiCreateIntField(
                ?name 'OPCGuardringSoiopeninnerextension
                ?value 50
                ?prompt "SOI Opening Inner Extension"
            )
            hiCreateIntField(
                ?name 'OPCGuardringSoiopenouterextension
                ?value 50
                ?prompt "SOI Outer Opening Extension"
            )
            hiCreateIntField(
                ?name 'OPCGuardringImplantextension
                ?value 50
                ?prompt "Implant Extension"
            )
            hiCreateIntField(
                ?name 'OPCGuardringImplantinnerextension
                ?value 50
                ?prompt "Implant Inner Extension"
            )
            hiCreateIntField(
                ?name 'OPCGuardringImplantouterextension
                ?value 50
                ?prompt "Implant Outer Extension"
            )
            hiCreateRadioField(
                ?name 'OPCGuardringDrawimplant
                ?value "true"
                ?prompt "Draw Implant"
                ?choices list("true" "false")
            )
            hiCreateRadioField(
                ?name 'OPCGuardringFillinnerimplant
                ?value "false"
                ?prompt "Fill Inner Implant"
                ?choices list("true" "false")
            )
            hiCreateStringField(
                ?name 'OPCGuardringInnerimplantpolarity
                ?value "p"
                ?prompt "Inner Implant Polarity"
            )
            hiCreateIntField(
                ?name 'OPCGuardringInnerimplantspace
                ?value 0
                ?prompt "Inner Implant Space"
            )
            hiCreateRadioField(
                ?name 'OPCGuardringFillwell
                ?value "true"
                ?prompt "Fill Well"
                ?choices list("true" "false")
            )
            hiCreateRadioField(
                ?name 'OPCGuardringFillwelldrawhole
                ?value "false"
                ?prompt "Draw Hole in Filled Well"
                ?choices list("true" "false")
            )
            hiCreateIntField(
                ?name 'OPCGuardringFillwellholeoffsettop
                ?value 0
                ?prompt "Fill Well Hole Offset (Top)"
            )
            hiCreateIntField(
                ?name 'OPCGuardringFillwellholeoffsetbottom
                ?value 0
                ?prompt "Fill Well Hole Offset (Bottom)"
            )
            hiCreateIntField(
                ?name 'OPCGuardringFillwellholeoffsetleft
                ?value 0
                ?prompt "Fill Well Hole Offset (Left)"
            )
            hiCreateIntField(
                ?name 'OPCGuardringFillwellholeoffsetright
                ?value 0
                ?prompt "Fill Well Hole Offset (Right)"
            )
            hiCreateRadioField(
                ?name 'OPCGuardringDrawdeepwell
                ?value "false"
                ?prompt "Draw Deep Well"
                ?choices list("true" "false")
            )
            hiCreateIntField(
                ?name 'OPCGuardringDeepwelloffset
                ?value 0
                ?prompt "Deep Well Offset"
            )
            hiCreateRadioField(
                ?name 'OPCGuardringFit
                ?value "false"
                ?prompt "fit"
                ?choices list("true" "false")
            )
            hiCreateRadioField(
                ?name 'OPCGuardringFailifnotfit
                ?value "false"
                ?prompt "failifnotfit"
                ?choices list("true" "false")
            )
            hiCreateStringField(
                ?name 'OPCGuardringDrawsegments
                ?value "left right top bottom"
                ?prompt "Draw Segments"
            )
        )
    )
    hiDisplayForm(OPCSubCellCreationForm 100:100)
    */
)

procedure(OPCCreateMosfet()
    t
) ; OPCCreateMosfet
