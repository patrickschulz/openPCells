; FIXME: with the layout update the form looks better,
;        but the field alignment is not very nice.
;        Use labels and horizontal grids for better alignment
procedure(OPCCreateSettingsForm()
    let(
        (
            timeout
            editcmd
            infolayerfield
            infolayerpurposefield
            cellenvironmentfile
            filename
            paramfilename
            exportfilename
            labelsize
            enabledprint
            stdoutfilename
            dprintfilename
            enablefallbackvias
            expandnamecontexts
            writechildrenports
            drawalignmentbox
            drawallalignmentboxes
            merge
            cmdadditionalargs
            log
            group
            groupname
            groupconsecutively
            splitlets
            maxletsplits
            deletefile
            generationoptionsgrid
            groupoptionsgrid
            infolayergrid
            calloptionsgrid
            dprintgrid
            exportoptionsgrid
            filenameoptionsgrid
            topgrid
        )
        ; info layer
        infolayerfield = hiCreateStringField(
            ?name 'OPCSettingsInfoLayer
            ?value "text"
            ?prompt "Layer for Info Layer"
        )
        infolayerpurposefield = hiCreateStringField(
            ?name 'OPCSettingsInfoLayerPurpose
            ?value "drawing"
            ?prompt "Purpose for Info Layer"
        )
        infolayergrid = hiCreateVerticalBoxLayout(
            'OPCSettingsInfoLayerGrid
            ?frame "Info Layer"
            ?spacing 10
            ?items list(infolayerfield infolayerpurposefield)
        )
        ; debug print
        enabledprint = hiCreateRadioField(
            ?name 'OPCSettingsEnableDprint
            ?choices list("true" "false")
            ?value "false"
            ?prompt "Enable Cell Debug Print (dprint)"
        )
        dprintfilename = hiCreateStringField(
            ?name 'OPCDprintFilename
            ?value "openPCells.dprint"
            ?prompt "File Name for Debug Print (dprint)"
        )
        dprintgrid = hiCreateVerticalBoxLayout(
            'OPCSettingsDprintGrid
            ?frame "Debug Print"
            ?spacing 10
            ?items list(enabledprint dprintfilename)
        )
        ; generation options
        enablefallbackvias = hiCreateRadioField(
            ?name 'OPCSettingsEnableFallbackVias
            ?choices list("true" "false")
            ?value "false"
            ?prompt "Enable Fallback Vias"
        )
        labelsize = hiCreateFloatField(
            ?name 'OPCSettingsLabelSize
            ?value 0.1
            ?defValue 0.1
            ?prompt "Size of Created Labels"
        )
        merge = hiCreateRadioField(
            ?name 'OPCSettingsMerge
            ?choices list("true" "false")
            ?value "false"
            ?prompt "Merge Rectangles (can take a long time)"
        )
        expandnamecontexts = hiCreateRadioField(
            ?name 'OPCSettingsExpandNamecontexts
            ?choices list("true" "false")
            ?value "true"
            ?prompt "Expand Name Contexts"
            ?enabled nil
        )
        writechildrenports = hiCreateRadioField(
            ?name 'OPCSettingsWriteChildrenPorts
            ?choices list("true" "false")
            ?value "true"
            ?prompt "Write Ports of Children"
        )
        drawalignmentbox = hiCreateRadioField(
            ?name 'OPCSettingsDrawAlignmentbox
            ?choices list("true" "false")
            ?value "false"
            ?prompt "Draw Alignment Box"
        )
        drawallalignmentboxes = hiCreateRadioField(
            ?name 'OPCSettingsDrawAllAlignmentboxes
            ?choices list("true" "false")
            ?value "false"
            ?prompt "Draw All Alignment Boxes"
        )
        generationoptionsgrid = hiCreateVerticalBoxLayout(
            'OPCSettingsGenerationOptionsGrid
            ?frame "Generation Options"
            ?spacing 10
            ?items list(enablefallbackvias labelsize merge expandnamecontexts writechildrenports drawalignmentbox drawallalignmentboxes)
        )
        ; group options
        group = hiCreateRadioField(
            ?name 'OPCSettingsGroup
            ?choices list("true" "false")
            ?value "false"
            ?prompt "Group Created Shapes"
        )
        groupname = hiCreateStringField(
            ?name 'OPCSettingsGroupname
            ?value "opcgroup"
            ?prompt "Group Name"
        )
        groupconsecutively = hiCreateRadioField(
            ?name 'OPCSettingsGroupConsecutively
            ?choices list("true" "false")
            ?value "true"
            ?prompt "Create Groups Consecutively"
        )
        groupoptionsgrid = hiCreateVerticalBoxLayout(
            'OPCSettingsGroupOptionsGrid
            ?frame "Group Options"
            ?spacing 10
            ?items list(group groupname groupconsecutively)
        )
        ; export options
        splitlets = hiCreateRadioField(
            ?name 'OPCSettingsSplitLets
            ?choices list("true" "false")
            ?value "true"
            ?prompt "Split Let Statements"
        )
        maxletsplits = hiCreateIntField(
            ?name 'OPCSettingsMaxLetSplits
            ?value 1000 ; I thought higher values should work, but apparently I don't fully understand the problem
            ?prompt "Maximum Values in a 'let' Statement"
        )
        exportoptionsgrid = hiCreateVerticalBoxLayout(
            'OPCSettingsExportOptionsGrid
            ?frame "Export Options"
            ?spacing 10
            ?items list(splitlets maxletsplits)
        )
        ; call options
        log = hiCreateRadioField(
            ?name 'OPCSettingsLog
            ?choices list("true" "false")
            ?value "false"
            ?prompt "Log opc calls to CIW"
        )
        timeout = hiCreateIntField(
            ?name 'OPCSettingsTimeout
            ?value 10
            ?prompt "OPC Call Time-Out Length in Seconds"
        )
        cmdadditionalargs = hiCreateStringField(
            ?name 'OPCSettingsCmdAdditionalArgs
            ?value ""
            ?prompt "Additional Command Line Arguments"
        )
        editcmd = hiCreateStringField(
            ?name 'OPCSettingsEditCmd
            ?value "xterm -fa monaco -fs 13 -e 'vim %s'"
            ?prompt "Edit command for update"
        )
        deletefile = hiCreateRadioField(
            ?name 'OPCSettingsDeleteFile
            ?choices list("true" "false")
            ?value "true"
            ?prompt "Delete cell file after creation"
        )
        calloptionsgrid = hiCreateVerticalBoxLayout(
            'OPCSettingsCallOptionsGrid
            ?frame "Call Options"
            ?spacing 10
            ?items list(log timeout cmdadditionalargs editcmd deletefile)
        )
        ; filenames
        cellenvironmentfile = hiCreateStringField(
            ?name 'OPCCellEnvironmentFile
            ?value ""
            ?prompt "File Name for Cell Environment"
        )
        cellfilename = hiCreateStringField(
            ?name 'OPCCellFilename
            ?value "openPCells"
            ?prompt "File Name for Generated Layouts"
        )
        paramfilename = hiCreateStringField(
            ?name 'OPCParamFilename
            ?value "opc.parameters"
            ?prompt "File Name for Parameters (pfiles)"
        )
        stdoutfilename = hiCreateStringField(
            ?name 'OPCStdoutFileName
            ?value "openPCells.stdout"
            ?prompt "File Name for Standard Output"
        )
        exportfilename = hiCreateStringField(
            ?name 'OPCExportFilename
            ?value "openPCells_export.lua"
            ?prompt "File Name for Cell Exports"
        )
        filenameoptionsgrid = hiCreateVerticalBoxLayout(
            'OPCSettingsFilenameOptionsGrid
            ?frame "File Names"
            ?spacing 10
            ?items list(cellenvironmentfile cellfilename paramfilename stdoutfilename exportfilename)
        )
        topgrid = hiCreateGridLayout(
            'OPCSettingsTopGrid
            ?frame ""
            ?spacing 10
            ?items list(
                list(generationoptionsgrid 'row 0 'col 0 'row_span 2)
                list(groupoptionsgrid 'row 2 'col 0)
                list(infolayergrid 'row 3 'col 0)
                list(calloptionsgrid 'row 0 'col 1)
                list(filenameoptionsgrid 'row 1 'col 1)
                list(dprintgrid 'row 2 'col 1)
                list(exportoptionsgrid 'row 3 'col 1)
            )
        )
        hiCreateLayoutForm(
            'OPCSettingsForm
            "OPC Settings"
            topgrid
            ?buttonLayout 'OKCancel
        )
    ) ; let
) ; OPCCreateSettingsForm

procedure(OPCSettingsCallback()
    hiDisplayForm(OPCSettingsForm 100:100)
) ; OPCSettingsCallback

