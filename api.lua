object     = _load_module("object")
shape      = _load_module("shape")
geometry   = _load_module("geometry")
graphics   = _load_module("graphics")
pcell      = _load_module("pcell")
generics   = _load_module("generics")
celllib    = _load_module("cell")
stringfile = _load_module("stringfile")
util       = _load_module("util")
aux        = _load_module("aux")
exitcodes  = _load_module("exitcodes")
funcobject = _load_module("funcobject")

-- for polygon triangulation
delaunay   = _load_module("delaunay")
helpers    = _load_module("helpers")
edge       = _load_module("edge")
triangle   = _load_module("triangle")
sanitize   = _load_module("sanitize")

debuglib   = _load_module("debug")

-- FIXME: put this somewhere else (and is this really the best name?)
function enable(bool, value)
    return (bool and 1 or 0) * value
end
