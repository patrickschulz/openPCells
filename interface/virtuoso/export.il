procedure(OPCAddPtsOffset(pts x y)
	mapcar(lambda( (pt) xCoord(pt) + x:yCoord(pt) + y) pts)
)

procedure(OPCConvertPtsToNanometer(pts)
	mapcar(lambda( (pt) fix(xCoord(pt) * 1000):fix(yCoord(pt) * 1000)) pts)
)

procedure(OPCFormatLayer(layer purpose)
    lsprintf("generics.premapped(nil, { SKILL = { layer = \"%s\", purpose = \"%s\" } })" layer purpose)
)

procedure(OPCWriteRectangle(file layer purpose bBox)
	let(
		(
		)
        fprintf(file "geometry.rectanglebltr(cell, %s, point.create(%d, %d), point.create(%d, %d))\n", 
            OPCFormatLayer(layer purpose) xCoord(car(bBox)) yCoord(car(bBox)) xCoord(cadr(bBox)) yCoord(cadr(bBox))
        )
	)
)

procedure(OPCWritePolygon(file layer purpose pts)
	let(
		(
		)
        fprintf(file "geometry.polygon(cell, %s, { %s })\n"
            OPCFormatLayer(layer purpose)
            buildString(mapcar(lambda( (pt) lsprintf("point.create(%d, %d)" xCoord(pt) yCoord(pt))) pts) ", ")
        )
	)
)

procedure(OPCWriteLabel(file layer purpose name pt)
	let(
		(
		)
        fprintf(file "cell:add_port(\"%s\", %s, point.create(%d, %d))\n"
            name
            OPCFormatLayer(layer purpose)
            xCoord(pt) yCoord(pt)
        )
	)
)

procedure(OPCWriteShape(file shape x y)
    unless(shape->layerName == "instance"
        case(shape->objType
            ("rect" OPCWriteRectangle(file shape->layerName shape->purpose OPCConvertPtsToNanometer(OPCAddPtsOffset(shape->bBox x y))))
            ("polygon" OPCWritePolygon(file shape->layerName shape->purpose OPCConvertPtsToNanometer(OPCAddPtsOffset(shape->points x y))))
            ("label" OPCWriteLabel(file shape->layerName shape->purpose shape->theLabel car(OPCConvertPtsToNanometer(OPCAddPtsOffset(list(shape->xy) x y)))))
        )
    )
)

procedure(OPCExportCell(filename)
    let(
        (
            (cv geGetEditCellView())
            (path if(filename filename "openPCells_export.lua"))
            file
        )
        file = outfile(path "w")
        println(file)
        fprintf(file "local cell = object.create()\n")
        foreach(shape cv->shapes
            OPCWriteShape(file shape 0 0)
        )
        foreach(inst cv->instances
            foreach(shape inst->master->shapes
                OPCWriteShape(file shape xCoord(inst->xy) yCoord(inst->xy))
            )
        )
        fprintf(file "return cell\n")
        close(file)
        hiDisplayAppDBox(
            ?name        'OPCInfoDialog
            ?dboxBanner  "openPCells"
            ?dboxText    lsprintf("written opc representation of layout to %s" path)
            ?dialogType   hicWarningDialog
            ?dialogStyle 'modeless
            ?buttonLayout 'Close
        )
    )
)
