procedure(_write_rectangle(layer, purpose, bBox)
	let(
		(
		)
		println(lsprintf("geometry.rectanglebltr(generics.mapped(nil, { layer = %s, purpose = %s }), point.create(%d, %d), point.create(%d, %d))", 
			layer purpose xCoord(car(bBox)) yCoord(car(bBox)) xCoord(cadr(bBox)) yCoord(cadr(bBox))))
	)
)

procedure(_format_pointlist(pts)
	t
)
procedure(_write_polygon(layer, purpose, pts)
	let(
		(
			(pts "point.create(0, 0), point.create(100, 100), point.create(200, 100)")
		)
		println(lsprintf("geometry.polygon(generics.mapped(nil, { layer = %s, purpose = %s }), { %s })"
			layer purpose pts))
	)
)

procedure(_add_pts_offset(pts x y)
	mapcar(lambda( (pt) xCoord(pt) + x:yCoord(pt) + y) pts)
)

procedure(_convert_pts_to_nanometer(pts)
	mapcar(lambda( (pt) fix(xCoord(pt) * 1000):fix(yCoord(pt) * 1000)) pts)
)

procedure(_write_shape(shape x y)
	if(shape->objType == "rect"
		then
			_write_rectangle(shape->layerName shape->purpose _convert_pts_to_nanometer(_add_pts_offset(shape->bBox x y)))
		else
			_write_polygon(shape->layerName shape->purpose _convert_pts_to_nanometer(_add_pts_offset(shape->points x y)))
	)
)

let(
	(
		(cv geGetEditCellView())
	)
	foreach(shape cv->shapes
		_write_shape(shape 0 0)
	)
	foreach(inst cv->instances
		foreach(shape inst->master->shapes
			_write_shape(shape xCoord(inst->xy) yCoord(inst->xy))
		)
	)
)
