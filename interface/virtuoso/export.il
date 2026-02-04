procedure(OPCExportConvertCoordToOPCUnit(c)
    fix(c * 1000)
) ; OPCExportConvertCoordToOPCUnit

procedure(OPCExportFormatPoint(pt)
    lsprintf(
        "point.create(%d, %d)"
        OPCExportConvertCoordToOPCUnit(xCoord(pt))
        OPCExportConvertCoordToOPCUnit(yCoord(pt))
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

procedure(OPCExportTranslate(pt dx dy)
    let(
        (x y)
        x = xCoord(pt) + dx
        y = yCoord(pt) + dy
        setf(xCoord(pt) x)
        setf(yCoord(pt) y)
    ) ; let
) ; OPCExportTranslate

procedure(OPCExportGetTMatrix(xpre ypre x y orientation)
    ; orientation first, including xpre and ypre, than translation by x and y
    case(orientation
        ("R0"     list( 1  0  xpre + x  0  1  ypre + y))
        ("MX"     list( 1  0  xpre + x  0 -1 -ypre + y))
        ("MY"     list(-1  0 -xpre + x  0  1  ypre + y))
        ("R90"    list( 0 -1 -ypre + x  1  0  xpre + y))
        ("R180"   list(-1  0 -xpre + x  0 -1 -ypre + y))
        ("R270"   list( 0  1  ypre + x -1  0 -xpre + y))
        ("MXR90"  list( 0  1  ypre + x  1  0  xpre + y))
        ("MYR90"  list( 0 -1 -ypre + x -1  0 -xpre + y))
    ) ; case orientation
) ; OPCExportGetTMatrix

procedure(OPCExportGetInstanceTMatrix(instance)
    let(
        (x y orientation)
        x = xCoord(instance->xy)
        y = yCoord(instance->xy)
        orientation = cadr(instance->transform)
        OPCExportGetTMatrix(0 0 x y orientation)
    ) ; let
) ; OPCExportGetInstanceTMatrix

procedure(OPCExportGetArrayInstanceTMatrix(instance xi yi)
    ; FIXME: the existance of 'tileArray' as a list suggests that non-regular tiling is possible
    ;        While I have never seen this and I also don't know how this can be achieved in virtuoso
    ;        (possibly not via gui tools), it would still be nice to support this.
    let(
        (x y orientation)
        x = xCoord(instance->xy)
        y = yCoord(instance->xy)
        orientation = car(instance->tileArray)
        OPCExportGetTMatrix(xi yi x y orientation)
    ) ; let
) ; OPCExportGetInstanceTMatrix

procedure(OPCExportGetViaTMatrix(via)
    let(
        (x y orientation)
        x = xCoord(via->origin)
        y = yCoord(via->origin)
        orientation = via->orient
        OPCExportGetTMatrix(0 0 x y orientation)
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
        (t nil) ; ignore everything else
    ) ; case objType
) ; OPCExportGetShape

procedure(OPCExportGetShapeNoNets(shape)
    case(shape->objType
        ("rect"
            list("rect" shape->lpp car(shape->bBox) cadr(shape->bBox))
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
        (t nil) ; ignore everything else
    ) ; case objType
) ; OPCExportGetShape

procedure(OPCExportGatherVias(via)
    mapcar('OPCExportGetShapeNoNets via->viaHeader->master->shapes)
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

procedure(OPCExportDisplaceShape(shape dx dy)
    case(car(shape)
        ("rect"
            OPCExportTranslate(nthelem(3 shape) dx dy)
            OPCExportTranslate(nthelem(4 shape) dx dy)
        ) ; rect
        ("polygon"
            foreach(pt nthelem(3 shape) OPCExportTranslate(pt dx dy))
        ) ; polygon
        ("path"
            foreach(pt nthelem(3 shape) OPCExportTranslate(pt dx dy))
        ) ; path
    ) ; case shape type
    shape
) ; OPCExportDisplaceShape

procedure(OPCExportGatherCellShapes(cell level gather_only_toplevel_nets)
    let(
        (transformfun shapes subshapes vias viatmatrix tmatrix)
        ; shape transformation function (possibly includes nets)
        if(gather_only_toplevel_nets && (level > 0)
            then
                transformfun = 'OPCExportGetShapeNoNets
            else
                transformfun = 'OPCExportGetShape
        )
        ; gather shapes of cell
        shapes = mapcar(transformfun cell->shapes)
        ; remove nils (ignored shapes)
        remd(nil shapes)
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
        ; gather shapes of instances
        foreach(instance cell->instances
            ; gather instance shapes in inner loop, as otherwise the shapes need to be copied for arrays
            if(instance->columns
                then ; is array
                    for(xi 1 instance->columns
                        for(yi 1 instance->rows
                            ; instance transformation matrix (takes also care of array displacement)
                            tmatrix = OPCExportGetArrayInstanceTMatrix(instance (xi - 1) * instance->uX (yi - 1) * instance->uY)
                            subshapes = OPCExportGatherCellShapes(instance->master level + 1 gather_only_toplevel_nets)
                            ; apply transformation and add to shapes list
                            foreach(shape subshapes
                                OPCExportTransformShape(shape tmatrix)
                                shapes = cons(shape shapes)
                            ) ; foreach shapes
                        )
                    )
                else ; single instance
                    ; instance transformation matrix
                    tmatrix = OPCExportGetInstanceTMatrix(instance)
                    subshapes = OPCExportGatherCellShapes(instance->master level + 1 gather_only_toplevel_nets)
                    ; apply transformation and add to shapes list
                    foreach(shape subshapes
                        OPCExportTransformShape(shape tmatrix)
                        shapes = cons(shape shapes)
                    ) ; foreach shapes
            ) ; if is array
        ) ; foreach instances
        shapes
    ) ; let
) ; OPCExportGatherCellShapes

procedure(OPCExportWriteCellShapes(file cellname shapes)
    foreach(shape shapes
        case(car(shape)
            ("rect"
                fprintf(file
                    "geometry.rectanglepoints(%s, %s, %s, %s)"
                    cellname
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
                    cellname
                    OPCExportFormatLayer(cadr(shape))
                    OPCExportFormatPoints(nthelem(3 shape))
                )
            ) ; polygon
            ("path"
                fprintf(file
                    "geometry.path(%s, %s, { %s }, %d)"
                    cellname
                    OPCExportFormatLayer(cadr(shape))
                    OPCExportFormatPoints(nthelem(3 shape))
                    OPCExportConvertCoordToOPCUnit(nthelem(4 shape))
                )
            ) ; path
        ) ; case shape type
        newline(file)
    ) ; foreach shape
) ; OPCExportWriteCellShapes

procedure(OPCExportWriteCell(path @key (export_only_toplevel_nets t))
    let(
        (
            (cv geGetEditCellView())
            file
            shapes
        )
        file = outfile(path "w")
        shapes = OPCExportGatherCellShapes(cv 0 export_only_toplevel_nets)
        fprintf(file "local %s = object.create(\"%s\")\n" cv->cellName cv->cellName)
        OPCExportWriteCellShapes(file cv->cellName shapes)
        fprintf(file "return %s\n" cv->cellName)
        close(file)
    )
) ; OPCExportWriteCell

procedure(OPCExportGetFilename(filename)
    if(filename filename OPCSettingsForm->OPCExportFilename->value)
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
            ?dialogType   hicMessageDialog
            ?dialogStyle 'modeless
            ?buttonLayout 'Close
        )
    )
) ; OPCHiExportCell
