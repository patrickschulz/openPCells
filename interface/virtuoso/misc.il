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
    let((file line lines str item form)
        ; read file
        file = infile(path)
        while(gets(nextline file)
            lines = cons(line lines)
        )
        str = apply('strcal reverse(lines))
        close(file)
        item = hiCreateMLTextField(
            ?editable nil
            ?defValue str
        )
        form = hiCreateAppForm(
            ?name gensym('OPCShowTextFile)
            ?fields list(item)
        )
        hiDisplayForm(form)
    )
) ; OPCShowTextFile

procedure(OPCViewLogFile()
    let(
        (
            path
        )
        path = lsprintf("%s" OPCSettingsForm->OPCStdoutFileName->value)
        OPCShowTextFile(path)
    )
) ; OPCViewLogFile
