procedure(OPCCreateSettingsForm()
    hiCreateAppForm(
        ?name 'OPCSettingsForm
        ?formTitle "OPC Settings"
        ?buttonLayout 'OKCancel
        ?initialSize t ; size form to fit all fields
        ?fields list(
            hiCreateStringField(
                ?name 'OPCCellEnvironmentFile
                ?value ""
                ?prompt "File Name for Cell Environment"
            )
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
            hiCreateFloatField(
                ?name 'OPCSettingsLabelSize
                ?value 0.1
                ?defValue 0.1
                ?prompt "Size of Created Labels"
            )
            hiCreateRadioField(
                ?name 'OPCSettingsEnableFallbackVias
                ?choices list("true" "false")
                ?value "false"
                ?prompt "Enable Fallback Vias"
            )
            hiCreateRadioField(
                ?name 'OPCSettingsExpandNamecontexts
                ?choices list("true" "false")
                ?value "false"
                ?prompt "Expand Name Contexts"
            )
            hiCreateRadioField(
                ?name 'OPCSettingsWriteChildrenPorts
                ?choices list("true" "false")
                ?value "true"
                ?prompt "Write Ports of Children"
            )
            hiCreateRadioField(
                ?name 'OPCSettingsDrawAlignmentbox
                ?choices list("true" "false")
                ?value "false"
                ?prompt "Draw Alignment Box"
            )
            hiCreateRadioField(
                ?name 'OPCSettingsDrawAllAlignmentboxes
                ?choices list("true" "false")
                ?value "false"
                ?prompt "Draw All Alignment Boxes"
            )
            hiCreateRadioField(
                ?name 'OPCSettingsMerge
                ?choices list("true" "false")
                ?value "false"
                ?prompt "Merge Rectangles (can take a long time)"
            )
            hiCreateStringField(
                ?name 'OPCSettingsCmdAdditionalArgs
                ?value ""
                ?prompt "Additional Command Line Arguments"
            )
            hiCreateRadioField(
                ?name 'OPCSettingsLog
                ?choices list("true" "false")
                ?value "false"
                ?prompt "Log opc calls to CIW"
            )
            hiCreateRadioField(
                ?name 'OPCSettingsGroup
                ?choices list("true" "false")
                ?value "false"
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
                ?name 'OPCSettingsSplitLets
                ?choices list("true" "false")
                ?value "true"
                ?prompt "Split Let Statements"
            )
            hiCreateIntField(
                ?name 'OPCSettingsMaxLetSplits
                ?value 1000 ; I thought higher values should work, but apparently I don't fully understand the problem
                ?prompt "Maximum Values in a 'let' Statement"
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
        )
    )
) ; procedure

procedure(OPCSettingsCallback()
    hiDisplayForm(OPCSettingsForm 100:100)
) ; procedure

