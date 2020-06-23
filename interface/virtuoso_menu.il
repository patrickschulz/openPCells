procedure(MSCHiLayoutInductorOptionsForm()
	when(!boundp('MSCLayoutInductorForm) || (MSCLayoutInductorForm == nil)
		let(
			(donutoptions layerfield Rfield rfield widthfield sepfield gridfield grid)
			donutoptions = hiCreateToggleField(
				?name 'donutoptions
				?prompt "Options"
				?choices list(list('deg45 "Allow Diagonal Shapes"))
			)
			layerfield = hiCreateStringField(
				?name 'layer
				?prompt "Layer"
				?value "QB"
			)
			Rfield = hiCreateFloatField(
				?name 'R
				?prompt "Main Radius"
				?value 60.0
			)
			rfield = hiCreateFloatField(
				?name 'r
				?prompt "Line Radius"
				?value 12.0
			)
			widthfield = hiCreateFloatField(
				?name 'width
				?prompt "Width"
				?value 6.0
			)
			sepfield = hiCreateFloatField(
				?name 'sep
				?prompt "Separation"
				?value 6.0
			)
			gridfield = hiCreateFloatField(
				?name 'grid
				?prompt "Grid"
				?value 0.1
			)
			hiCreateAppForm(
				?name 'MSCLayoutInductorForm
				;?formType 'options
				?formTitle "Create Inductor"
				?buttonLayout 'OKCancel
				;?dialogStyle 'modal
				?fields list(
					layerfield Rfield rfield widthfield sepfield gridfield
				)
				?callback lambda( (form) MSCLayoutCreateInductorBase(form) )
			)
		)
	) 
	MSCLayoutInductorForm
)

procedure(MSCHiLayoutCreateInductor()
    MSCHiLayoutInductorOptionsForm()
    hiDisplayForm('MSCLayoutInductorForm)
)

procedure(MSCLayoutCreateInductorBase(form)
    let(
        (
        	(layer form->layer->value)
        	(R form->R->value)
        	(r form->r->value)
        	(width form->width->value)
        	(sep form->sep->value)
        	(grid form->grid->value)
            command pid str pts
        )
        command = lsprintf("lua /home/pschulz/path/main.lua %f %f %f %f %f" R r width sep grid)
        println(command)
	    pid = ipcBeginProcess(command)
	    ipcWait(pid)
	    filename = ipcReadProcess(pid)
	    println(filename)
	    file = infile(filename)
		when(file
			while(line = lineread(file)
				pts = cons(line pts)
			)
		)
		println(pts)
	    dbCreatePolygon(geGetEditCellView() list(layer "drawing") pts)
    )
)
