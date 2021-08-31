procedure(OPCAddPtsOffset(pts x y)
	mapcar(lambda( (pt) xCoord(pt) + x:yCoord(pt) + y) pts)
)

procedure(OPCConvertPtsToNanometer(pts)
	mapcar(lambda( (pt) fix(xCoord(pt) * 1000):fix(yCoord(pt) * 1000)) pts)
)

procedure(OPCWriteRectangle(file layer purpose bBox)
	let(
		(
		)
        fprintf(file "cell:merge_into_shallow(geometry.rectanglebltr(generics.mapped(nil, { layer = \"%s\", purpose = \"%s\" }), point.create(%d, %d), point.create(%d, %d)))\n", 
            layer purpose xCoord(car(bBox)) yCoord(car(bBox)) xCoord(cadr(bBox)) yCoord(cadr(bBox))
        )
	)
)

procedure(OPCWritePolygon(file layer purpose pts)
	let(
		(
		)
        fprintf(file "cell:merge_into_shallow(geometry.polygon(generics.mapped(nil, { layer = \"%s\", purpose = \"%s\" }), { %s }))\n"
            layer purpose 
            buildString(mapcar(lambda( (pt) lsprintf("point.create(%d, %d)" xCoord(pt) yCoord(pt))) pts) ", ")
        )
	)
)

procedure(OPCWriteShape(file shape x y)
    unless(shape->layerName == "instance"
        if(shape->objType == "rect"
            then
                OPCWriteRectangle(file shape->layerName shape->purpose OPCConvertPtsToNanometer(OPCAddPtsOffset(shape->bBox x y)))
            else
                OPCWritePolygon(file shape->layerName shape->purpose OPCConvertPtsToNanometer(OPCAddPtsOffset(shape->points x y)))
        )
    )
)

procedure(OPCExportCell()
    let(
        (
            (cv geGetEditCellView())
            (file outfile("openPCells_export.lua" "w"))
        )
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
            ?dboxText    lsprintf("written opc representation of layout to %s" "openPCells_export.lua")
            ?dialogType   hicWarningDialog
            ?dialogStyle 'modeless
            ?buttonLayout 'Close
        )
    )
)
