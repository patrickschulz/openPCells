procedure(OPCConvertCoordToNanometer(c)
    fix(c * 1000)
)

procedure(OPCAddPtsOffset(pts x y)
	mapcar(lambda( (pt) xCoord(pt) + x:yCoord(pt) + y) pts)
)

procedure(OPCConvertPtsToNanometer(pts)
	mapcar(lambda( (pt) fix(xCoord(pt) * 1000):fix(yCoord(pt) * 1000)) pts)
)

procedure(OPCFormatLayer(layer purpose)
    let((mapping)
        mapping = if(boundp('OPCLayerMap) && OPCLayerMap
            then
                setof(entry OPCLayerMap (entry->layer == layer) && (entry->purpose == purpose))
            else
                nil
        )
        if(mapping
            then
                lsprintf("%s" car(mapping)->map)
            else
                lsprintf("generics.premapped(nil, { SKILL = { layer = \"%s\", purpose = \"%s\" } })" layer purpose)
        )
    )
)

procedure(OPCWriteRectangle(file cellname layer purpose bBox)
	let(
		(
		)
        fprintf(file "geometry.rectanglebltr(%s, %s, point.create(%d, %d), point.create(%d, %d))\n",
            cellname
            OPCFormatLayer(layer purpose)
            xCoord(car(bBox)) yCoord(car(bBox))
            xCoord(cadr(bBox)) yCoord(cadr(bBox))
        )
        when(net
            fprintf(file "%s:add_net_shape(\"%s\", point.create(%d, %d), point.create(%d, %d), %s)\n",
                cellname
                net->name
                xCoord(car(bBox)) yCoord(car(bBox))
                xCoord(cadr(bBox)) yCoord(cadr(bBox))
                OPCFormatLayer(layer purpose)
            )
        )
	)
)

procedure(OPCWritePolygon(file cellname layer purpose pts)
	let(
		(
		)
        fprintf(file "geometry.polygon(%s, %s, { %s })\n"
            cellname
            OPCFormatLayer(layer purpose)
            buildString(mapcar(lambda( (pt) lsprintf("point.create(%d, %d)" xCoord(pt) yCoord(pt))) pts) ", ")
        )
	)
)

procedure(OPCWritePath(file cellname layer purpose pts width)
	let(
		(
		)
        fprintf(file "geometry.path(%s, %s, { %s }, %d)\n"
            cellname
            OPCFormatLayer(layer purpose)
            buildString(mapcar(lambda( (pt) lsprintf("point.create(%d, %d)" xCoord(pt) yCoord(pt))) pts) ", ")
            width
        )
	)
)

procedure(OPCWriteLabel(file cellname layer purpose name pt)
	let(
		(
		)
        fprintf(file "%s:add_port(\"%s\", %s, point.create(%d, %d))\n"
            cellname
            name
            OPCFormatLayer(layer purpose)
            xCoord(pt) yCoord(pt)
        )
	)
)

procedure(OPCWriteShape(file cellname shape x y)
    unless(shape->layerName == "instance"
        case(shape->objType
            ("rect"
                OPCWriteRectangle(file
                    cellname
                    shape->layerName shape->purpose
                    OPCConvertPtsToNanometer(OPCAddPtsOffset(shape->bBox x y))
                    shape->net ; support for net shapes on rectangles
                )
            )
            ("polygon"
                OPCWritePolygon(file
                    cellname
                    shape->layerName shape->purpose
                    OPCConvertPtsToNanometer(OPCAddPtsOffset(shape->points x y))
                )
            )
            ("path"
                OPCWritePath(file
                    cellname
                    shape->layerName shape->purpose
                    OPCConvertPtsToNanometer(OPCAddPtsOffset(shape->points x y))
                    OPCConvertCoordToNanometer(shape->width)
                )
            )
            ("pathSeg" 
                foreach(object shape->route->objects
                    OPCWritePath(file
                        cellname
                        object->layerName object->purpose
                        OPCConvertPtsToNanometer(OPCAddPtsOffset(list(object->beginPt object->endPt) x y))
                        OPCConvertCoordToNanometer(object->width)
                    )
                )
            )
            ("label"
                OPCWriteLabel(file
                    cellname
                    shape->layerName shape->purpose
                    shape->theLabel
                    car(OPCConvertPtsToNanometer(OPCAddPtsOffset(list(shape->xy) x y)))
                )
            )
        )
    )
)

procedure(OPCWriteVia(file cellname via x y)
    /*
	let(
		(ovbl obtr viaProp)
        viaProp = via->viaHeader->viaDef
        ; FIXME: calculate overlap
        ; FIXME: if metals are perfectly overlapping, use only viabltr
        ovbl = list(0 0)
        ovtr = list(0 0)
        ; write metal 1
        OPCWriteRectangle(file shape->layerName shape->purpose OPCConvertPtsToNanometer(OPCAddPtsOffset(shape->bBox x y)))
        ; write metal 2
        OPCWriteRectangle(file shape->layerName shape->purpose OPCConvertPtsToNanometer(OPCAddPtsOffset(shape->bBox x y)))
        ; write via cut
        fprintf(file "geometry.viabarebltr(cell, %d, %d, point.create(%d, %d), point.create(%d, %d))\n",
            OPCFormatLayer(layer purpose) xCoord(car(bBox)) yCoord(car(bBox)) xCoord(cadr(bBox)) yCoord(cadr(bBox))
        )
	)
    */
    foreach(shape via->viaHeader->master->shapes
        OPCWriteShape(file cellname shape x + xCoord(via->origin) y + yCoord(via->origin))
    )
)

procedure(OPCWriteInstance(file parent instname)
    let(
        ()
        fprintf(file "%s:add_child(%s, \"%s\")"
            parent
            instname
            name
            OPCFormatLayer(layer purpose)
            xCoord(pt) yCoord(pt)
        )
    )
)

; FIXME: untested/unfinished/broken
procedure(OPCWriteCell(file cell x y)
    foreach(shape cell->shapes
        OPCWriteShape(file cell->cellName shape x y)
    )
    foreach(via cell->vias
        OPCWriteVia(file cell->cellName via y y)
    )
    ; FIXME: check for mosaics
    foreach(inst cell->instances
        ; FIXME: check if object was already exported
        OPCWriteCell(file inst->master inst->master->cellName x + xCoord(inst->xy) y + yCoord(inst->xy))
        OPCWriteInstance(file cell->cellName inst->master inst->master->cellName x + xCoord(inst->xy) y + yCoord(inst->xy))
    )
)

procedure(OPCWriteCellFlat(file cell cellname x y)
    foreach(shape cell->shapes
        OPCWriteShape(file cellname shape x y)
    )
    foreach(via cell->vias
        OPCWriteVia(file cellname via y y)
    )
    ; FIXME: this does not respect instance orientation
    foreach(inst cell->instances
        if(inst->columns
            then ; is array
                for(xi 1 inst->columns
                    for(yi 1 inst->rows
                        OPCWriteCellFlat(file inst->master cellname x + xCoord(inst->xy) + (xi - 1) * inst->uX y + yCoord(inst->xy) + (yi - 1) * inst->uY)
                    )
                )
            else
                OPCWriteCellFlat(file inst->master cellname x + xCoord(inst->xy) y + yCoord(inst->xy))
        )
    )
)

procedure(OPCExportGetFilename(filename)
    if(filename filename "openPCells_export.lua")
)

procedure(OPCExportWriteCell(path)
    let(
        (
            (cv geGetEditCellView())
            file
        )
        file = outfile(path "w")
        fprintf(file "local %s = object.create(\"%s\")\n" cv->cellName cv->cellName)
        OPCWriteCellFlat(file cv cv->cellName 0 0)
        fprintf(file "return %s\n" cv->cellName)
        close(file)
    )
)

procedure(OPCExportCell(filename)
    let(
        (
            (cv geGetEditCellView())
            (path if(filename filename "openPCells_export.lua"))
        )
        OPCExportWriteCell(path)
    )
)

procedure(OPCHiExportCell(filename)
    let(
        (
            (cv geGetEditCellView())
            (path if(filename filename "openPCells_export.lua"))
        )
        OPCExportWriteCell(path)
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
