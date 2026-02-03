procedure(OPCAboutCallback()
    let(
        (OPCAboutForm)
        OPCAboutForm = hiCreateAppForm(
            ?name 'OPCAboutForm
            ?formTitle "openPCells About"
            ?buttonLayout 'OKCancel
            ?fields list(
                hiCreateHypertextField(
                    ?name 'OPCHTMLField 
                    ?title ""
                    ?value "<div style=\"text-align:center\"><h1>openPCells &ndash; A framework for open layout cell generators</h1><p>openPCells (opc) 0.1.0 &ndash; &copy;Patrick Kurth 2020&ndash;2021</p><A href=https://github.com/patrickschulz/openPCells>Website</A>" 
                )
            )
        )
        hiDisplayForm(OPCAboutForm 100:100)
    )
) ; OPCAboutCallback

procedure(OPCEditConfigFile()
    let(
        (
            path
        )
        path = lsprintf("/home/%s/.opcconfig.lua" getShellEnvVar("USER"))
        OPCOpenEditor(path)
    )
) ; OPCEditConfigFile

procedure(OPCShowTextFile(path)
    view(path)
    /*
    old code. perhaps I will use it, so I'll keep it for now
    the 'view()' approach is much simpler
    let((file line lines str item form)
        ; read file
        file = infile(path)
        while(gets(line file)
            lines = cons(line lines)
        )
        close(file)
        if(car(lines)
            then
                str = buildString(reverse(lines) "")
            else
                str = ""
        )
        item = hiCreateMLTextField(
            ?name gensym('OPCShowTextFileField)
            ?editable nil
            ?defValue str
        )
        form = hiCreateAppForm(
            ?name gensym('OPCShowTextFileForm)
            ?fields list(item)
        )
        hiDisplayForm(form)
    )
    */
) ; OPCShowTextFile

procedure(OPCViewParameterFile()
    let(
        (
            path
        )
        path = lsprintf("%s" OPCSettingsForm->OPCParamFilename->value)
        OPCShowTextFile(path)
    )
) ; OPCViewParameterFile

procedure(OPCViewLogFile()
    let(
        (
            path
        )
        path = lsprintf("%s" OPCSettingsForm->OPCStdoutFileName->value)
        OPCShowTextFile(path)
    )
) ; OPCViewLogFile

procedure(OPCViewDPrintFile()
    let(
        (
            path
        )
        path = lsprintf("%s" OPCSettingsForm->OPCDprintFilename->value)
        OPCShowTextFile(path)
    )
) ; OPCViewDPrintFile

procedure(OPCViewOutputFile()
    let(
        (
            path
        )
        path = lsprintf("%s.il" OPCSettingsForm->OPCCellFilename->value)
        OPCShowTextFile(path)
    )
) ; OPCViewOutputFile

procedure(OPCViewExporttFile()
    let(
        (
            path
        )
        path = lsprintf("%s" OPCSettingsForm->OPCExportFilename->value)
        OPCShowTextFile(path)
    )
) ; OPCViewExporttFile

procedure(OPCGetInfoLayer()
    list(OPCSettingsForm->OPCSettingsInfoLayer->value OPCSettingsForm->OPCSettingsInfoLayerPurpose->value)
) ; OPCGetInfoLayer

procedure(OPCGetSelSetOrigin(selset)
	let((x0 y0)
		x0 = car(sort(mapcar(lambda( (bBox) xCoord(car(bBox))) selset~>bBox) 'lessp))
		y0 = car(sort(mapcar(lambda( (bBox) yCoord(car(bBox))) selset~>bBox) 'lessp))
		list(x0 y0)
	)
) ; OPCGetSelSetOrigin

; this function is written for selection sets but only one group is passed
; I kept the 'list(group)' construct everywhere, perhaps this might be expanded at some point
procedure(OPCMoveGroup(group)
	let((origin dragInfo cv)
		origin = OPCGetSelSetOrigin(list(group))
		dragInfo = geHiDragFig(hiGetCurrentWindow() 0 "origin" "destination" "Move" list(group) nil origin)
		when(dragInfo
			cv = geGetEditCellView()
			destructuringBind(
				(
					(firstCV (firstX firstY))
					(secondCV (secondX secondY))
				)
				dragInfo
				transform = list(list(secondX - firstX secondY - firstY) "R0" 1)
				foreach(obj list(group)
					dbMoveFig(obj cv transform)
				)
			)
		)
	)
) ; OPCMoveGroup
