procedure(OPCCreateSettingsForm()
    hiCreateAppForm(
        ?name 'OPCSettingsForm
        ?formTitle "OPC Settings"
        ?buttonLayout 'OKCancel
        ?initialSize t ; size form to fit all fields
        ?fields list(
            hiCreateStringField(
                ?name 'OPCCellFilename
                ?value "openPCells"
                ?prompt "File Name for Generated Layouts"
            )
            hiCreateStringField(
                ?name 'OPCParamFilename
                ?value "opc.parameters"
                ?prompt "File Name for Parameters"
            )
            hiCreateStringField(
                ?name 'OPCListFilename
                ?value "opc.cells"
                ?prompt "File Name for Cell Listings"
            )
            hiCreateStringField(
                ?name 'OPCPfileFilename
                ?value "opc.pfile"
                ?prompt "File Name for Parameter Bindings (Parameter File)"
            )
            hiCreateFloatField(
                ?name 'OPCSettingsLabelSize
                ?value 0.1
                ?defValue 0.1
                ?prompt "Size of Created Labels"
            )
            hiCreateStringField(
                ?name 'OPCSettingsCmdAdditionalArgs
                ?value "-X -l"
                ?prompt "Additional Command Line Arguments"
            )
            hiCreateRadioField(
                ?name 'OPCSettingsDrawAlignmentbox
                ?choices list("true" "false")
                ?value "false"
                ?prompt "Draw Alignment Box"
            )
            hiCreateRadioField(
                ?name 'OPCSettingsLog
                ?choices list("true" "false")
                ?value "false"
                ?prompt "Log opc calls to CIW"
            )
            hiCreateRadioField(
                ?name 'OPCSettingsMerge
                ?choices list("true" "false")
                ?value "false"
                ?prompt "Merge Rectangles (can take a long time)"
            )
            hiCreateRadioField(
                ?name 'OPCSettingsGroup
                ?choices list("true" "false")
                ?value "true"
                ?prompt "Group Created Shapes"
            )
            hiCreateStringField(
                ?name 'OPCSettingsGroupname
                ?value "opcgroup"
                ?prompt "Group Name"
            )
            hiCreateRadioField(
                ?name 'OPCSettingsGroupConsecutively
                ?choices list("true" "false")
                ?value "true"
                ?prompt "Create Groups Consecutively"
            )
            hiCreateRadioField(
                ?name 'OPCSettingsDeleteFile
                ?choices list("true" "false")
                ?value "true"
                ?prompt "Delete cell file after creation"
            )
            hiCreateStringField(
                ?name 'OPCSettingsEditCmd
                ?value "xterm -fa monaco -fs 13 -e 'vim %s'"
                ?prompt "Edit command for update"
            )
            hiCreateButton(
                ?name 'OPCSettingsUpdateCellList
                ?callback "OPCUpdateCellList()"
                ?buttonText "Update List of Cells"
            )
        )
    )
) ; procedure

procedure(OPCSettingsCallback()
    hiDisplayForm(OPCSettingsForm 100:100)
) ; procedure

procedure(OPCUpdateCellList()
	let(
		(OPCCmd)
        OPCCmd = OPCBuildCallCommand("-L --list-format 'OPCData = list(\\n:)\\n:::list(\\\"%b\\\" list(:))\\n:\\\"%c\\\" '")
        OPCCall(OPCCmd OPCSettingsForm->OPCListFilename->value)
		load(OPCSettingsForm->OPCListFilename->value)
        OPCCleanUp(OPCSettingsForm->OPCListFilename->value)
	)
)

