procedure(OPCExportConvertCoordToNanometer(c)
    fix(c * 1000)
) ; OPCExportConvertCoordToNanometer

procedure(OPCExportFormatPoint(pt)
    lsprintf(
        "point.create(%d, %d)"
        OPCExportConvertCoordToNanometer(xCoord(pt))
        OPCExportConvertCoordToNanometer(yCoord(pt))
    )
) ; OPCExportFormatPoint

procedure(OPCExportFormatPoints(pts)
    buildString(mapcar('OPCExportFormatPoint pts) ", ")
) ; OPCExportFormatPoints

procedure(OPCExportFormatLayer(lpp)
    let(
        (layer purpose mapping)
        layer = car(lpp)
        purpose = cadr(lpp)
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
    ) ; let
) ; OPCExportFormatLayer

procedure(OPCExportTransform(pt tmatrix)
    let(
        (x y)
        x = nthelem(1 tmatrix) * xCoord(pt) + nthelem(2 tmatrix) * yCoord(pt) + nthelem(3 tmatrix)
        y = nthelem(4 tmatrix) * xCoord(pt) + nthelem(5 tmatrix) * yCoord(pt) + nthelem(6 tmatrix)
        setf(xCoord(pt) x)
        setf(yCoord(pt) y)
    ) ; let
) ; OPCExportTransform

procedure(OPCExportGetTMatrix(x y orientation)
    case(orientation
        ("R0"     list( 1  0  x  0  1  y))
        ("MX"     list( 1  0  x  0 -1  y))
        ("MY"     list(-1  0  x  0  1  y))
        ("R90"    list( 0 -1  x  1  0  y))
        ("R180"   list(-1  0  x  0 -1  y))
        ("R270"   list( 0  1  x -1  0  y))
        ("MXR90"  list( 0  1  x  1  0  y))
        ("MYR90"  list( 0 -1  x -1  0  y))
    ) ; case orientation
) ; OPCExportGetTMatrix

procedure(OPCExportGetInstanceTMatrix(instance)
    let(
        (x y orientation)
        x = xCoord(instance->xy)
        y = yCoord(instance->xy)
        orientation = cadr(instance->transform)
        OPCExportGetTMatrix(x y orientation)
    ) ; let
) ; OPCExportGetInstanceTMatrix

procedure(OPCExportGetViaTMatrix(via)
    let(
        (x y orientation)
        x = xCoord(via->origin)
        y = yCoord(via->origin)
        orientation = cadr(via->orient)
        OPCExportGetTMatrix(x y orientation)
    ) ; let
) ; OPCExportGetViaTMatrix

procedure(OPCExportGetShape(shape)
    case(shape->objType
        ("rect"
            list("rect" shape->lpp car(shape->bBox) cadr(shape->bBox) if(shape->net shape->net->name nil))
        ) ; rect
        ("polygon"
            list("polygon" shape->lpp mapcar(lambda( (pt) xCoord(pt):yCoord(pt)) shape->points))
        ) ; polygon
        ("path"
            list("path" shape->lpp mapcar(lambda( (pt) xCoord(pt):yCoord(pt)) shape->points) shape->width)
        ) ; path
        ("pathSeg"
            list("path" shape->lpp list(shape->beginPt shape->endPt) shape->width)
        ) ; path
    ) ; case objType
) ; OPCExportGetShape

procedure(OPCExportGatherVias(via)
    mapcar('OPCExportGetShape via->viaHeader->master->shapes)
) ; OPCExportGatherVias

procedure(OPCExportTransformShape(shape tmatrix)
    case(car(shape)
        ("rect"
            OPCExportTransform(nthelem(3 shape) tmatrix)
            OPCExportTransform(nthelem(4 shape) tmatrix)
        ) ; rect
        ("polygon"
            foreach(pt nthelem(3 shape) OPCExportTransform(pt tmatrix))
        ) ; polygon
        ("path"
            foreach(pt nthelem(3 shape) OPCExportTransform(pt tmatrix))
        ) ; path
    ) ; case shape type
    shape
) ; OPCExportTransformShape

procedure(OPCExportGatherCellShapes(cell)
    let(
        (subshapes vias shapes viatmatrix tmatrix)
        ; gather shapes of cell
        shapes = mapcar('OPCExportGetShape cell->shapes)
        ; gather vias of this cell
        foreach(via cell->vias
            vias = OPCExportGatherVias(via)
            ; via transformation matrix
            viatmatrix = OPCExportGetViaTMatrix(via)
            ; apply transformation and add to shapes list
            foreach(viashape vias
                OPCExportTransformShape(viashape viatmatrix)
                shapes = cons(viashape shapes)
            ) ; foreach viashapes
        ) ; foreach vias
        ; gather shapes of sub-cells
        foreach(sub cell->instances
            subshapes = OPCExportGatherCellShapes(sub->master)
            ; instance transformation matrix
            tmatrix = OPCExportGetInstanceTMatrix(sub)
            ; apply transformation and add to shapes list
            foreach(shape subshapes
                OPCExportTransformShape(shape tmatrix)
                shapes = cons(shape shapes)
            ) ; foreach shapes
        ) ; foreach instances
    ) ; let
) ; OPCExportGatherCellShapes

procedure(OPCExportWriteCellShapes(file cellname shapes)
    foreach(shape shapes
        case(car(shape)
            ("rect"
                fprintf(file
                    "geometry.rectanglepoints(%s, %s, %s, %s)"
                    OPCExportFormatLayer(cadr(shape))
                    OPCExportFormatPoint(nthelem(3 shape))
                    OPCExportFormatPoint(nthelem(4 shape))
                )
                when(nthelem(5 shape) ; has net
                    fprintf(file
                        "%s:add_net_shape(\"%s\", %s, %s, %s)"
                        cellname
                        nthelem(5 shape)
                        OPCExportFormatPoint(nthelem(3 shape))
                        OPCExportFormatPoint(nthelem(4 shape))
                        OPCExportFormatLayer(cadr(shape))
                    )
                    newline(file)
                ) ; when net
            ) ; rect
            ("polygon"
                fprintf(file
                    "geometry.polygon(%s, %s, { %s })"
                    OPCExportFormatLayer(cadr(shape))
                    OPCExportFormatPoints(nthelem(3 shape))
                )
            ) ; polygon
            ("path"
                fprintf(file
                    "geometry.path(%s, %s, { %s }, %s)"
                    OPCExportFormatLayer(cadr(shape))
                    OPCExportFormatPoints(nthelem(3 shape))
                    OPCExportConvertCoordToNanometer(nthelem(4 shape))
                )
            ) ; path
        ) ; case shape type
    ) ; foreach shape
) ; OPCExportWriteCellShapes

procedure(OPCExportWriteCell(path)
    let(
        (
            (cv geGetEditCellView())
            file
            shapes
        )
        file = outfile(path "w")
        shapes = OPCExportGatherCellShapes(cv)
        fprintf(file "local %s = object.create(\"%s\")\n" cv->cellName cv->cellName)
        OPCExportWriteCellShapes(file cv->cellName shapes)
        fprintf(file "return %s\n" cv->cellName)
        close(file)
    )
) ; OPCExportWriteCell

procedure(OPCExportGetFilename(filename)
    if(filename filename "openPCells_export.lua")
) ; OPCExportGetFilename

procedure(OPCExportCell(filename)
    let(
        (
            (cv geGetEditCellView())
            (path OPCExportGetFilename(filename))
        )
        OPCExportWriteCell(path)
    )
) ; OPCExportCell

procedure(OPCHiExportCell(filename)
    let(
        (
            (cv geGetEditCellView())
            (path OPCExportGetFilename(filename))
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
) ; OPCHiExportCell
